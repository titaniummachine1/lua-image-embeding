# **📌 Image to Lua Encoder (Binary & Base64)**
This repository provides **two powerful methods** to embed images directly into Lua scripts:  
1️⃣ **Base64-Encoded RGBA**  
2️⃣ **Binary `\xXX` Notation**  

These allow **seamless image rendering in Lua without requiring external files**.

---

## **✨ Features**
✅ **Clipboard-Based Encoding** – Copy an image, run the script, and paste the output into Lua!  
✅ **Supports Two Encoding Methods** – Choose between **Base64** (readable) or **Binary** (efficient).  
✅ **Automatic Power-of-2 Resizing** – Ensures maximum compatibility with rendering engines.  
✅ **No External Image Files Required** – The Lua script decodes & renders images dynamically.  
✅ **Easy Integration** – Just **copy & paste** the generated Lua-compatible image string.

---

## **📌 Prerequisites**
### **Python Requirements**
1. Install **Python 3.x** (Download from [python.org](https://www.python.org/)).
2. Install required dependencies:
   ```bash
   pip install pillow pyperclip
   ```

### **Lua Requirements**
- Your Lua environment must support **texture rendering** (`draw.CreateTextureRGBA`, `draw.TexturedRect`).

---

## **🚀 Quick Start Guide**
### **Step 1: Copy an Image**
- Right-click an image and select **"Copy"**, or press **Ctrl+C**.

### **Step 2: Run the Python Script**
- **Option 1: Double-click the script** (`clipboard_to_lua.py`).  
- **Option 2: Run from the terminal**:
  ```bash
  python clipboard_to_lua.py
  ```
- The script will:
  ✅ Grab the image from the clipboard.  
  ✅ Resize it to **nearest power-of-2 dimensions**.  
  ✅ Convert it into a **Lua-compatible Base64 or Binary string**.  
  ✅ **Automatically copy** the result to the clipboard.  

### **Step 3: Paste into Your Lua Script**
- Open your Lua script (`example.lua`).
- Choose **Base64** or **Binary** storage method:
  - **For Base64:** Paste into `local base64_image = [[ ]]`
  - **For Binary:** Paste into `local binary_image = [[ ]]`
- **Press `Ctrl+V`** to paste the copied string.

### **Step 4: Run Your Lua Script**
- Your Lua script will **decode and render the image dynamically**.

---

## **🟢 Option 1: Base64 Lua Rendering Script**
Use the following Lua script to decode & render a **Base64-encoded image**:

```lua
-- Base64-encoded RGBA image data
local base64_image = [[
-- Paste the Base64 string here
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

-- Decode dimensions from Base64
local dimension_encoded = string.sub(base64_image, 1, 12)
local dimension_decoded = base64_decode(dimension_encoded)
local width = tonumber(string.sub(dimension_decoded, 1, 4))
local height = tonumber(string.sub(dimension_decoded, 5, 8))

-- Decode RGBA data
local image_data = string.sub(base64_image, 13)
local decoded_data = base64_decode(image_data)

-- Validate & render image
local expected_length = width * height * 4
if #decoded_data ~= expected_length then
    print("Invalid data length.")
    return
end

local texture = draw.CreateTextureRGBA(decoded_data, width, height)
if not texture then print("Failed to create texture.") return end

-- Draw function
local function draw_texture()
    local x, y = 100, 100
    draw.Color(255, 255, 255, 255)
    draw.TexturedRect(texture, x, y, x + width, y + height)
end

callbacks.Register("Draw", "RenderTexture", draw_texture)
```

---

## **🔵 Option 2: Binary Lua Rendering Script**
Use this Lua script for **Binary-encoded image** rendering:

```lua
-- Binary-encoded RGBA image data
local binary_image = [[
-- Paste the binary string here
]]

-- Convert \xXX format to raw byte data
local function to_raw_bytes(data)
    local raw = {}
    for byte in data:gmatch("\\x(%x%x)") do
        table.insert(raw, string.char(tonumber(byte, 16)))
    end
    return table.concat(raw)
end

-- Extract dimensions from binary data
local function extract_dimensions(data)
    local width = (data:byte(1) * 16777216) + (data:byte(2) * 65536) +
                  (data:byte(3) * 256) + data:byte(4)
    local height = (data:byte(5) * 16777216) + (data:byte(6) * 65536) +
                   (data:byte(7) * 256) + data:byte(8)
    return width, height
end

-- Convert binary data to texture
local function create_texture(binary_data)
    local raw_binary = to_raw_bytes(binary_data)
    local width, height = extract_dimensions(raw_binary)
    local rgba_data = raw_binary:sub(9)

    local texture = draw.CreateTextureRGBA(rgba_data, width, height)
    if not texture then error("Failed to create texture.") end
    return texture, width, height
end

-- Draw function
local texture, width, height = create_texture(binary_image)
local function draw_texture()
    local x, y = 100, 100
    draw.Color(255, 255, 255, 255)
    draw.TexturedRect(texture, x, y, x + width, y + height)
end

callbacks.Register("Draw", "RenderBinaryTexture", draw_texture)
```

---

## **📊 Base64 vs Binary Comparison**
| Feature | **Base64** | **Binary (`\xXX`)** |
|---------|----------------|----------------|
| **Size Efficiency** | ❌ Larger (Base64 increases size by ~33%) | ✅ Smaller (Direct binary) |
| **Decoding Speed** | ❌ Slower (Base64 decoding step) | ✅ Faster (No decoding needed) |
| **Readability** | ✅ More readable (text-based) | ❌ Harder to read manually |
| **Compatibility** | ✅ Works well in APIs & networking | ✅ Works well in compact scripts |

---

## **🛠 Troubleshooting**
❌ **"Clipboard does not contain an image."**  
👉 Make sure you copied an **actual image**, not just a file path.

❌ **"Python script doesn’t run."**  
👉 Install dependencies:
   ```bash
   pip install pillow pyperclip
   ```

❌ **"Failed to create texture in Lua."**  
👉 Ensure the Base64 or Binary string is **correctly copied and pasted**.

---

## **📜 License**
This project is **open-source** and free to use. Attribution is appreciated but not required.

---

## **📬 Contact & Support**
For questions, suggestions, or bug reports, feel free to contact the script author.  

Happy coding! 🚀
