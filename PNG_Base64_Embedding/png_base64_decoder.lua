--=============================================================================
-- PNG (Base64) Decoder for Lua
--=============================================================================
-- REQUIRES: png-lua library (https://github.com/Didericis/png-lua)
--=============================================================================

-- 1. PLACE THE 'png.lua' FILE IN YOUR PROJECT
local pngImage = require("png") -- Adjust this path if needed

-- 2. PASTE THE GENERATED LUA CODE FROM THE PYTHON SCRIPT HERE
--    (It will define 'png_base64_data')
local png_base64_data = [[
-- PASTE FROM 'image_to_png_base64.py' HERE --
]]

--=============================================================================
-- INTERNAL DECODER LOGIC (No changes needed below)
--=============================================================================

-- Base64 Decoding Table
local b64_chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
local b64_lookup = {}
for i = 1, #b64_chars do
    b64_lookup[b64_chars:sub(i, i)] = i - 1
end

--! @brief Decodes a Base64 string into a raw binary string.
--! @param data The Base64 encoded string.
--! @return The decoded binary string.
local function base64_decode(data)
    data = data:gsub('[^A-Za-z0-9+/=]', '')
    local output = {}
    for i = 1, #data, 4 do
        local c1, c2, c3, c4 = data:sub(i, i + 3):byte(1, 4)
        local b1 = b64_lookup[string.char(c1)]
        local b2 = b64_lookup[string.char(c2)]
        local b3 = c3 and string.char(c3) ~= '=' and b64_lookup[string.char(c3)]
        local b4 = c4 and string.char(c4) ~= '=' and b64_lookup[string.char(c4)]

        if b1 and b2 then
            output[#output + 1] = string.char((b1 << 2) | (b2 >> 4))
            if b3 then
                output[#output + 1] = string.char(((b2 & 0x0F) << 4) | (b3 >> 2))
                if b4 then
                    output[#output + 1] = string.char(((b3 & 0x03) << 6) | b4)
                end
            end
        end
    end
    return table.concat(output)
end

--! @brief Converts the pixel table from png-lua into a raw RGBA string.
local function convert_pixels_to_rgba(pixels, width, height)
    local rgba_data = {}
    for y = 1, height do
        for x = 1, width do
            local p = pixels[y][x]
            rgba_data[#rgba_data + 1] = string.char(p.R, p.G, p.B, p.A)
        end
    end
    return table.concat(rgba_data)
end

--! @brief Main function to create a texture from the embedded Base64 data.
local function create_texture()
    -- Decode the base64 data to get the raw PNG byte string
    local png_byte_data = base64_decode(png_base64_data)

    -- Use a temporary file as png-lua requires a file path
    local temp_file_path = "temp_image.png"
    local file = io.open(temp_file_path, "wb")
    if not file then
        error("Failed to create temporary file for PNG decoding.")
        return
    end
    file:write(png_byte_data)
    file:close()

    -- Decode the PNG file into a pixel table
    local img = pngImage(temp_file_path)
    os.remove(temp_file_path) -- Clean up the temp file immediately

    if not img or not img.pixels then
        error("Failed to decode PNG data. Is the 'png.lua' library correct?")
        return
    end

    -- Convert the pixel table to a raw RGBA string for the game engine
    local rgba_string = convert_pixels_to_rgba(img.pixels, img.width, img.height)

    -- Create the texture
    -- NOTE: Replace 'draw.CreateTextureRGBA' with your game engine's actual function if different.
    local texture = draw.CreateTextureRGBA(rgba_string, img.width, img.height)
    if not texture then
        error("Failed to create texture. Check your game engine's texture creation function.")
        return
    end

    print("Successfully created texture from Base64 PNG data.")
    return texture, img.width, img.height
end

-- Create the texture when the script loads
local TEXTURE, WIDTH, HEIGHT = create_texture()

--=============================================================================
-- EXPORTED TABLE (for use in other files)
--=============================================================================
return {
    Texture = TEXTURE,
    Width = WIDTH,
    Height = HEIGHT,

    --! @brief Draws the texture at a given position.
    --! @param x The X coordinate.
    --! @param y The Y coordinate.
    --! @param w Optional width override.
    --! @param h Optional height override.
    Draw = function(x, y, w, h)
        if not TEXTURE then return end
        -- NOTE: Replace 'draw.Color' and 'draw.TexturedRect' with your engine's functions.
        draw.Color(255, 255, 255, 255)
        draw.TexturedRect(TEXTURE, x, y, x + (w or WIDTH), y + (h or HEIGHT))
    end
}
