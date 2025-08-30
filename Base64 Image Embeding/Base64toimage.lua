-- Base64-encoded RGBA image data
local base64_image = [[
--image goes here--
]]

-- Optimized Base64 decoder with lookup table
local b64_chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
local b64_lookup = {}
for i = 1, #b64_chars do
    b64_lookup[b64_chars:sub(i, i)] = i - 1
end

local function base64_decode(data)
    -- Remove whitespace and padding
    data = data:gsub('%s+', ''):gsub('=+$', '')
    
    local decoded = {}
    local padding = (4 - (#data % 4)) % 4
    
    -- Process 4 characters at a time
    for i = 1, #data, 4 do
        local chunk = data:sub(i, i + 3)
        local n = 0
        
        -- Convert 4 base64 chars to 24-bit number
        for j = 1, #chunk do
            local char = chunk:sub(j, j)
            local val = b64_lookup[char]
            if val then
                n = n * 64 + val
            end
        end
        
        -- Extract 3 bytes from 24-bit number
        if #chunk >= 2 then
            decoded[#decoded + 1] = string.char((n >> 16) & 0xFF)
        end
        if #chunk >= 3 then
            decoded[#decoded + 1] = string.char((n >> 8) & 0xFF)
        end
        if #chunk >= 4 then
            decoded[#decoded + 1] = string.char(n & 0xFF)
        end
    end
    
    return table.concat(decoded)
end

-- Extract dimensions from first 8 bytes (big-endian uint32s)
local function extract_dimensions(raw_data)
    local width = (raw_data:byte(1) << 24) + (raw_data:byte(2) << 16) + 
                  (raw_data:byte(3) << 8) + raw_data:byte(4)
    local height = (raw_data:byte(5) << 24) + (raw_data:byte(6) << 16) + 
                   (raw_data:byte(7) << 8) + raw_data:byte(8)
    return width, height
end

-- Main function to create texture from Base64 RGBA data
local function create_texture_from_base64(base64_data)
    -- Decode base64 to raw bytes
    local raw_data = base64_decode(base64_data)
    
    -- Extract dimensions from header
    local width, height = extract_dimensions(raw_data)
    
    -- Extract RGBA pixel data (skip 8-byte header)
    local rgba_data = raw_data:sub(9)
    
    -- Validate data length
    local expected_length = width * height * 4
    if #rgba_data ~= expected_length then
        error(string.format("Invalid RGBA data length. Expected %d bytes, got %d bytes.", 
                          expected_length, #rgba_data))
    end
    
    -- Create texture
    local texture = draw.CreateTextureRGBA(rgba_data, width, height)
    if not texture then
        error("Failed to create texture from RGBA data.")
    end
    
    return texture, width, height
end

-- Create texture once at load time
local texture, width, height = create_texture_from_base64(base64_image)

-- Named draw function
local function draw_texture()
    local x, y = 100, 100 -- Position to draw the texture
    draw.Color(255, 255, 255, 255) -- Set color to white (opaque)
    draw.TexturedRect(texture, x, y, x + width, y + height)
end

-- Register the draw function to be called every frame
callbacks.Register("Draw", "RenderTexture", draw_texture)
