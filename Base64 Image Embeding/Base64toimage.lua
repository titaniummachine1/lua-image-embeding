-- Base64-encoded RGBA image data
local base64_image = [[
--image goes here--
]]

-- Base64 decoding function
local b = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
local function base64_decode(data)
    data = string.gsub(data, '[^' .. b .. '=]', '')
    local decoded = {}
    local padding = 0

    if string.sub(data, -2) == '==' then
        padding = 2
        data = string.sub(data, 1, -3)
    elseif string.sub(data, -1) == '=' then
        padding = 1
        data = string.sub(data, 1, -2)
    end

    for i = 1, #data, 4 do
        local n = (string.find(b, string.sub(data, i, i)) - 1) * 262144 +
                  (string.find(b, string.sub(data, i + 1, i + 1)) - 1) * 4096 +
                  (string.find(b, string.sub(data, i + 2, i + 2)) - 1) * 64 +
                  (string.find(b, string.sub(data, i + 3, i + 3)) - 1)
        table.insert(decoded, string.char(math.floor(n / 65536) % 256))
        table.insert(decoded, string.char(math.floor(n / 256) % 256))
        table.insert(decoded, string.char(n % 256))
    end

    if padding > 0 then
        decoded = {table.unpack(decoded, 1, #decoded - padding)}
    end

    return table.concat(decoded)
end

-- Decode dimensions from the first 12 characters of the Base64 string
local dimension_encoded = string.sub(base64_image, 1, 12)
local dimension_decoded = base64_decode(dimension_encoded)
local width = tonumber(string.sub(dimension_decoded, 1, 4)) -- First 4 digits: width
local height = tonumber(string.sub(dimension_decoded, 5, 8)) -- Next 4 digits: height

-- Decode the Base64 data (excluding the first 12 characters for dimensions)
local image_data = string.sub(base64_image, 13)
local decoded_data = base64_decode(image_data)

-- Validate data length
local expected_length = width * height * 4
if #decoded_data ~= expected_length then
    print("Invalid data length. Expected " .. expected_length .. " bytes, got " .. #decoded_data .. " bytes.")
    return
end

-- Create texture once
local texture = draw.CreateTextureRGBA(decoded_data, width, height)

-- Validate texture creation
if not texture then
    print("Failed to create texture.")
    return
end

-- Named draw function
local function draw_texture()
    local x, y = 100, 100 -- Position to draw the texture
    draw.Color(255, 255, 255, 255) -- Set color to white (opaque)
    draw.TexturedRect(texture, x, y, x + width, y + height)
end

-- Register the draw function to be called every frame
callbacks.Register("Draw", "RenderTexture", draw_texture)
