# **README: Base64 Image Embedding for Lua Scripts (Clipboard Version)**

### **Overview**
This setup allows you to **convert an image directly from your clipboard** into a **Base64-encoded Lua string**. This is useful for embedding images inside a Lua script **without requiring users to install additional files or dependencies**.

---

### **How It Works**
1. **Copy an Image to Your Clipboard:**  
   Instead of manually selecting a file, simply copy an image (`Ctrl+C` on an image).
   
2. **Run the Python Script:**  
   The script **grabs the image from the clipboard**, processes it, and converts it into a **Base64-encoded Lua-compatible string**.

3. **Paste the Base64 String into Your Lua Script:**  
   The script **automatically copies the result back to the clipboard**, so you can **paste it (`Ctrl+V`) directly into your Lua script**.

4. **Run the Lua Script:**  
   The embedded Base64 string is **decoded back into an image at runtime** and rendered without needing external files.

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
- **Double-click the script (`clipboard_to_lua.py`)** or run it manually via the command line:
  ```bash
  python clipboard_to_lua.py
  ```
- The script will:
  ✅ Grab the image from the clipboard.  
  ✅ Resize it to **the nearest power-of-2 dimensions** for compatibility.  
  ✅ Convert it into **a Lua-compatible Base64 string**.  
  ✅ **Automatically copy** the result back to your clipboard.

---

#### **4. Paste into Your Lua Script**
- Open your Lua script (`example.lua`).
- Find the placeholder for the Base64 string:
  ```lua
  local base64_image = [[ -- paste your Base64 string here ]]
  ```
- **Press `Ctrl+V`** to paste the copied Base64 string.

---

#### **5. Save and Run**
- Save the Lua script.
- Load it into your game or application as per your standard process.  
  The image will be **decoded from Base64 and displayed dynamically**.

---

### **🔄 Changes from the Previous Binary Method**
| Feature | **Old Binary Method** | **New Base64 Method** |
|---------|------------------|------------------|
| **Encoding Format** | `\xXX` notation (raw binary) | Base64 string (`A-Za-z0-9+/=`) |
| **Size Efficiency** | Smaller (direct byte representation) | ~33% larger due to Base64 encoding |
| **Decoding Process** | Directly extracts bytes from `\xXX` format | Requires Base64 decoding in Lua |
| **Performance** | Faster (no decoding needed) | Slightly slower due to Base64 decoding step |
| **Readability** | Harder to edit manually | Easier to read, copy, and edit |
| **Integration** | More efficient for embedded scripts | Better for external transmission and API compatibility |

---

### **Key Features**
✅ **Clipboard-Based** – No need to manually select files. Just copy an image and run the script!  
✅ **Standalone** – Users don’t need to install extra dependencies in Lua. The image is embedded inside the script.  
✅ **Automatic Resizing** – The script ensures the image dimensions are optimized (powers of 2).  
✅ **Quick & Easy** – The Base64 string is copied directly to your clipboard for instant pasting.  
✅ **More Compatible** – Base64 works well for networking, APIs, and data transmission.  

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
1. **Copy an image to your clipboard** (`Ctrl+C` on an image).  
2. **Run the Python script (`clipboard_to_lua.py`)**.  
3. **Paste the Base64 string into your Lua script (`Ctrl+V`)**.  
4. **Run your Lua script—your image is decoded and displayed!** 🎩✨  

---

### **License**
This setup is free to use and modify. Attribution is appreciated but not required.

---

### **Contact**
For questions, suggestions, or issues, feel free to contact the script author. Happy coding! 🚀

---

### **Example Output in Lua**
```lua
local base64_image = [[
iVBORw0KGgoAAAANSUhEUgAAAMgAAADICAYAAACtWK6eAAA...
-- (Generated Base64 data)
]]
```

This Base64 string **can be decoded and displayed in Lua dynamically** without requiring external files! 🎉
