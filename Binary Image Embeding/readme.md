# **README: Binary Image Embedding for Lua Scripts**

### **Overview**
This setup allows you to embed images directly into a Lua script as a binary string. It’s perfect for creating a lightweight, standalone Lua script that displays images without requiring users to install additional files or dependencies.

---

### **How It Works**
1. **Convert Your Image to Binary:**  
   A Python script processes your image and generates a binary string representation, complete with dimensions, ready for use in Lua.

2. **Embed the Binary String:**  
   Copy the generated string and paste it into the specified section of the Lua script.

3. **Enjoy Seamless Integration:**  
   When the Lua script is run, it displays the image without requiring the user to download or install anything extra.

---

### **Step-by-Step Instructions**

#### **1. Prepare Your Environment**
- Ensure you have **Python installed** on your system. You can download it from [python.org](https://www.python.org/) if needed.
- Place your **image file** (e.g., `.png`, `.jpg`) into this folder alongside the provided Python script.

---

#### **2. Run the Python Script**
- Double-click the Python script (`generate_binary.py`) or run it manually via the command line:
  ```bash
  python generate_binary.py
  ```
- The script will process your image and create an `output.txt` file in the same folder.

---

#### **3. Copy the Binary String**
- Open `output.txt` and press **Ctrl+A** to select all the text.
- Copy it with **Ctrl+C**.

---

#### **4. Edit Your Lua Script**
- Open the Lua script (`example.lua`) in this folder.
- Locate the placeholder for the binary string, which looks like this:
  ```lua
  local binary_image = [[ -- paste your binary string here ]]
  ```
- Paste the copied binary string between the `[[ ]]` brackets.

---

#### **5. Save and Run**
- Save the Lua script.
- Load it into your game or application as per your standard process. The image will be displayed directly, no external files required!

---

### **Key Features**
- **Standalone:** Users don’t need to download or install extra dependencies. Everything is embedded in the Lua script.
- **Automatic Resizing:** The Python script ensures the image dimensions are optimized (powers of 2) for compatibility.
- **Customizable:** Use the Lua script as a template to easily swap out images.

---

### **Troubleshooting**
- If the script doesn’t run, ensure you have Python 3.x installed and added to your system PATH.
- If your image doesn’t display, check that the binary string is correctly pasted and the Lua script is saved properly.

---

### **Example Workflow**
1. Place `my_image.png` in the folder.
2. Run the Python script to generate `output.txt`.
3. Copy the contents of `output.txt`.
4. Paste it into the `example.lua` script.
5. Load `example.lua` into your game—your image appears like magic!

---

### **License**
This setup is free to use and modify. Attribution is appreciated but not required.

---

### **Contact**
For questions, suggestions, or issues, feel free to contact the script author. Have fun embedding your images!
