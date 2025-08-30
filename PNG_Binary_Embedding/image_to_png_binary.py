import io
import pyperclip
from PIL import Image, ImageGrab

# --- CONFIGURATION ---
# Set to True to resize the image to the nearest smaller power-of-2.
# This is often better for GPU texture memory alignment.
OPTIMIZE_DIMENSIONS = True

def get_image_from_clipboard():
    """Retrieve a valid image from the clipboard."""
    clipboard_content = ImageGrab.grabclipboard()
    if isinstance(clipboard_content, Image.Image):
        return clipboard_content
    if isinstance(clipboard_content, list):
        for item in clipboard_content:
            if isinstance(item, str):
                try:
                    return Image.open(item)
                except Exception:
                    continue
    raise ValueError("No valid image found in clipboard. Please copy an image first.")

def resize_to_power_of_2(image):
    """Resize image to the nearest smaller power-of-2 dimensions."""
    if not OPTIMIZE_DIMENSIONS:
        return image
    
    original_width, original_height = image.size
    new_width = 2 ** (original_width.bit_length() - 1)
    new_height = 2 ** (original_height.bit_length() - 1)

    if (new_width, new_height) == (original_width, original_height):
        print("Image dimensions are already a power of 2.")
        return image

    print(f"Resizing from {original_width}x{original_height} to {new_width}x{new_height}...")
    return image.resize((new_width, new_height), Image.Resampling.LANCZOS)

def create_lua_binary_string(data):
    """Converts raw bytes into a Lua-compatible binary string using escape sequences."""
    # Using string formatting for each byte is faster than concatenation in a loop
    return "".join([f'\\{byte}' for byte in data])

def main():
    """Main function to process the image and generate the binary string."""
    try:
        print("Grabbing image from clipboard...")
        original_image = get_image_from_clipboard()
        
        # Ensure image has an alpha channel for transparency
        image = original_image.convert("RGBA")
        
        # Resize if needed
        optimized_image = resize_to_power_of_2(image)
        
        # Convert to PNG in memory
        png_buffer = io.BytesIO()
        optimized_image.save(png_buffer, format='PNG', optimize=True)
        png_data = png_buffer.getvalue()
        
        # Convert raw PNG bytes to a Lua-safe string
        lua_binary_string = create_lua_binary_string(png_data)
        
        # Prepare the final Lua code for clipboard
        lua_code = f'local png_binary_data = "{lua_binary_string}"'
        
        pyperclip.copy(lua_code)
        
        # --- Output ---
        print("\n-----------------------------------------------------")
        print("✅ Success! Lua code copied to clipboard.")
        print(f"   - Final Lua String Length: {len(lua_code)} chars")
        print(f"   - Original PNG Size: {len(png_data)} bytes")
        print(f"   - Encoding Overhead: None (1:1 byte mapping)")
        print("-----------------------------------------------------\n")

    except Exception as e:
        print(f"\n❌ ERROR: {e}")

if __name__ == "__main__":
    main()
