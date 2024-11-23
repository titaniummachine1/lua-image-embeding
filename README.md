# Image to RGBA Base64 Encoder and Lua Renderer

This repository provides a simple and effective way to embed any image into your Lua scripts using Base64-encoded RGBA textures. The workflow ensures compatibility with your Lua environment, dynamically retrieves texture dimensions, and renders the image seamlessly.

---

## Features

- Automatically resizes images to the **nearest smaller power-of-2 dimensions**.
- Converts images into **Base64-encoded RGBA** strings for direct use in Lua scripts.
- Dynamically calculates texture dimensions in Lua—no need to manually specify image sizes.
- Easy-to-use scripts for Python (encoding) and Lua (rendering).

---

## Prerequisites

### Python Requirements
1. Install **Python 3.x** if not already installed.

## Workflow

### Step 1: Prepare the Image
1. **Place your image** in the same folder as the Python script.
2. Supported formats include: `.png`, `.jpg`, `.jpeg`, `.bmp`, `.gif`.

> Ensure the folder contains only the image you want to process for simplicity.

---

### Step 2: Run the Python Script
#1. double click on python script to run it 
or
Open a terminal or command prompt in the folder containing the Python script and your image.
2. Run the following command:
   ```bash
   python image_to_rgba.py
   ```
3. The script will:
   - Resize the image to the nearest **power-of-2 dimensions**.
   - Convert the image to a Base64-encoded RGBA string.
   - Save the encoded string in a file named `embedded_image.txt`.

---

### Step 3: Use the Base64 String in Lua
1. Open the `embedded_image.txt` file.
2. Use `Ctrl + A` to select the entire content and `Ctrl + C` to copy it.
3. Paste the copied string into the Lua script inside the `base64_image` variable:
   ```lua
   local base64_image = [[
   -- Paste the Base64 string here
   ]]
   ```

4. The Lua script will handle decoding, texture creation, and rendering dynamically. No need to specify image dimensions manually.

---

### Lua Rendering Script

Use the following Lua script to render the embedded image dynamically:

```lua
-- Base64-encoded image data
local base64_image = [[
-- Paste your Base64 string here
]]

-- Base64 decoding function
local b = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
function base64_decode(data)
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

-- Decode the Base64 data
local decoded_data = base64_decode(base64_image)

-- Create texture once
local texture = draw.CreateTextureRGBA(decoded_data)

-- Validate texture creation
if not texture then
    print("Failed to create texture.")
    return
end

-- Named draw function
function draw_texture()
    -- Get texture dimensions dynamically
    local width, height = draw.GetTextureSize(texture)
    local x, y = 100, 100 -- Position to draw the texture

    draw.Color(255, 255, 255, 255) -- Set color to white (opaque)
    draw.TexturedRect(texture, x, y, x + width, y + height)
end

-- Register the draw function to be called every frame
callbacks.Register("Draw", "RenderTexture", draw_texture)
```

---

## Troubleshooting

### Python Script Issues
- **No image found**: Ensure there’s only one image in the folder, and it is in a supported format.
- **Missing dependencies**: Install required libraries:
  ```bash
  pip install pillow clipboard
  ```

### Lua Script Issues
- **Failed to create texture**: Ensure the Base64 string is correctly copied and pasted.
- **Image not rendering**: Verify that your Lua environment supports the required `draw` library functions (`CreateTextureRGBA`, `GetTextureSize`, etc.).

---

## FAQ

### Why use Base64-encoded RGBA images?
Base64 encoding allows embedding raw image data directly into Lua scripts, avoiding dependency on external files or paths.

### What are "power-of-2 dimensions"?
Textures work best when their width and height are powers of 2 (e.g., 32, 64, 128, 256). This ensures compatibility and avoids rendering issues in some environments.

---

Let me know if you have further questions or need additional explanations!
