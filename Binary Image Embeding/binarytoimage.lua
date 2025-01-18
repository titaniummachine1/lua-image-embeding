-- Binary-encoded RGBA image data
local binary_image = [[
--image data here--
]]

-- Convert a binary string in \xXX format to raw byte data
local function to_raw_bytes(data)
    local raw = {}
    for byte in data:gmatch("\\x(%x%x)") do
        table.insert(raw, string.char(tonumber(byte, 16)))
    end
    return table.concat(raw)
end

-- Extract dimensions (first 8 bytes) as big-endian integers
local function extract_dimensions(data)
    local width = (data:byte(1) * 16777216) + (data:byte(2) * 65536) +
                  (data:byte(3) * 256) + data:byte(4)
    local height = (data:byte(5) * 16777216) + (data:byte(6) * 65536) +
                   (data:byte(7) * 256) + data:byte(8)
    return width, height
end

-- Parse the binary image data and create a texture
local function create_texture_from_binary(binary_data)
    -- Convert binary string to raw bytes
    local raw_binary = to_raw_bytes(binary_data)
    
    -- Extract dimensions from the first 8 bytes
    local width, height = extract_dimensions(raw_binary)
    
    -- Extract RGBA pixel data (from byte 9 onward)
    local rgba_data = raw_binary:sub(9)
    
    -- Create texture
    local texture = draw.CreateTextureRGBA(rgba_data, width, height)
    if not texture then
        error("Failed to create texture.")
    end
    
    return texture, width, height
end

-- Draw a texture at a specified position
local function draw_texture(texture, x, y, width, height)
    draw.Color(255, 255, 255, 255) -- Set color to white (opaque)
    draw.TexturedRect(texture, x, y, x + width, y + height)
end

-- Parse the binary image and create a texture
local texture, width, height = create_texture_from_binary(binary_image)

-- Named draw function to render the texture
local function draw_texture_example()
    local x, y = 100, 100 -- Position to draw the texture
    draw_texture(texture, x, y, width, height)
end

-- Register the draw function to be called every frame
callbacks.Register("Draw", "RenderSingleTexture", draw_texture_example)
