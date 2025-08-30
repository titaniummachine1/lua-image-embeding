# **Binary RGBA Image Embedding**

### **Overview**
This method converts images to binary hex-escaped RGBA data for embedding in Lua scripts. It produces larger files than Base64 but offers faster decoding performance.

---

### **How It Works**
1. **Image Processing**: Takes image from clipboard or first image file in directory (alphabetically sorted)
2. **Power-of-2 Resizing**: Automatically resizes to nearest smaller power-of-2 dimensions for GPU compatibility
3. **RGBA Conversion**: Converts to raw RGBA pixel data (4 bytes per pixel)
4. **Header Encoding**: Prepends 8-byte binary header with width/height as big-endian uint32s
5. **Hex Escape Encoding**: Converts binary data to `\xXX` hex escape format for Lua strings
6. **Clipboard Output**: Copies the hex string to clipboard for pasting into Lua

## Files

- **`imagetobinary.py`** - Python script that converts images to binary hex strings
- **`binarytoimage.lua`** - Lua decoder with direct hex parsing and texture rendering

---

### **Step-by-Step Instructions**

#### **1. Prepare Your Environment**
- Ensure you have **Python installed** on your system.  
  You can download it from [python.org](https://www.python.org/) if needed.
- Install **required dependencies** (only needed once):
  ```bash
  pip install pillow pyperclip
  ```

---

#### **2. Copy an Image**
- Find an image you want to embed.
- **Right-click → Copy**, or use **Ctrl+C** to copy the image to your clipboard.

---

#### **3. Run the Python Script**
- Run the script:
  ```bash
  python imagetobinary.py
  ```
- The script will:
  ✅ Grab the image from clipboard or directory.  
  ✅ Resize it to **the nearest power-of-2 dimensions** for compatibility.  
  ✅ Convert it into **a Lua-compatible binary hex string**.  
  ✅ **Automatically copy** the result back to your clipboard.

---

#### **4. Paste into Your Lua Script**
- Open your Lua script.
- Find the placeholder for the binary string:
  ```lua
  local binary_image = [[ -- paste your binary string here ]]
  ```
- **Press `Ctrl+V`** to paste the copied binary string.

---

#### **5. Save and Run**
- Save the Lua script.
- Load it into your game or application as per your standard process.  
  The image will be **decoded from binary hex and displayed dynamically**.

---

## Advantages

- **Faster decoding** - Direct hex parsing without Base64 decoding step
- **Simple format** - Uses standard `\xXX` hex escape sequences
- **No lookup tables** - Straightforward byte extraction

## Disadvantages

- **Larger file size** (~2MB for typical images vs ~686KB for Base64)
- **Lower encoding efficiency** - 25% efficiency (4 chars = 1 byte)
- **Less readable** - Harder to manually inspect or edit

---

## Supported Image Formats

PNG, JPG, JPEG, BMP, GIF, TIFF, WEBP (case-insensitive)

## Technical Details

- Uses direct hex parsing for optimal decoding speed
- Binary dimension headers avoid UTF-8 parsing overhead
- Bitwise operations for fast dimension extraction
- Single texture creation at load time  

---

### **Troubleshooting**
❌ **"Clipboard does not contain an image."**  
👉 Make sure you copied an image, not a file path or text.

❌ **"Image looks too small."**  
👉 The script automatically resizes the image to the nearest **power of 2**, which can slightly shrink it.

❌ **"Python script doesn’t run."**  
👉 Ensure you have **Python 3.x** installed and `pillow` + `pyperclip` installed:
   ```bash
   pip install pillow pyperclip
   ```

---

### **Example Workflow**
1. **Copy an image to your clipboard** (`Ctrl+C` on an image) or place image file in directory.  
2. **Run the Python script (`imagetobinary.py`)**.  
3. **Paste the binary string into your Lua script (`Ctrl+V`)**.  
4. **Run your Lua script—your image is decoded and displayed!**  

---

### **License**
This setup is free to use and modify. Attribution is appreciated but not required.

---

### **Contact**
For questions, suggestions, or issues, feel free to contact the script author. Happy coding! 🚀

---

### **Example Output in Lua**
```lua
local binary_image = [[
\x00\x00\x02\x00\x00\x00\x02\x00\xff\x00\x00\xff...
-- (Generated binary hex data)
]]
```

This binary string **can be decoded and displayed in Lua dynamically** without requiring external files!
