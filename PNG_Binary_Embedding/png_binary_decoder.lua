--=============================================================================
-- PNG (Binary) Decoder for Lua
--=============================================================================
-- REQUIRES: png-lua library (https://github.com/Didericis/png-lua)
--=============================================================================

-- 1. PLACE THE 'png.lua' FILE IN YOUR PROJECT
local pngImage = require("png") -- Adjust this path if needed

-- 2. PASTE THE GENERATED LUA CODE FROM THE PYTHON SCRIPT HERE
--    (It will define 'png_binary_data')
local png_binary_data = ""
-- PASTE FROM 'image_to_png_binary.py' HERE --


--=============================================================================
-- INTERNAL DECODER LOGIC (No changes needed below)
--=============================================================================

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

--! @brief Main function to create a texture from the embedded binary data.
local function create_texture()
    -- The 'png_binary_data' is already the raw PNG byte string

    -- Use a temporary file as png-lua requires a file path
    local temp_file_path = "temp_image.png"
    local file = io.open(temp_file_path, "wb")
    if not file then
        error("Failed to create temporary file for PNG decoding.")
        return
    end
    file:write(png_binary_data)
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

    print("Successfully created texture from binary PNG data.")
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
