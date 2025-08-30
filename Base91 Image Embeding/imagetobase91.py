import os
import glob
import pyperclip
from PIL import Image, ImageGrab
import struct

# Lua-safe Base91 character set (91 printable ASCII characters, excludes ] and =)
BASE91_ALPHABET = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!#$%&()*+,./:;<>?@\\^_`{|}~"-'

def base91_encode(data):
    """Encode binary data to Base91 string."""
    if not data:
        return ''
    
    alphabet = BASE91_ALPHABET
    accumulator = 0
    bits = 0
    output = []
    
    for byte in data:
        accumulator |= (byte << bits)
        bits += 8
        
        while bits > 13:
            value = accumulator & 8191  # 2^13 - 1
            if value > 88:
                accumulator >>= 13
                bits -= 13
            else:
                value = accumulator & 16383  # 2^14 - 1
                accumulator >>= 14
                bits -= 14
            
            output.append(alphabet[value % 91])
            output.append(alphabet[value // 91])
    
    # Handle remaining bits
    if bits > 0:
        output.append(alphabet[accumulator % 91])
        if bits > 7 or accumulator > 90:
            output.append(alphabet[accumulator // 91])
    
    return ''.join(output)

def nearest_power_of_2_smaller(x):
    """Calculate the nearest power of 2 smaller than or equal to x."""
    if x <= 0:
        return 1
    return 2 ** (x.bit_length() - 1)

def optimize_image_to_smaller_power_of_2(image):
    """Resize image to the nearest smaller power-of-2 dimensions."""
    img = image.convert("RGBA")  # Ensure RGBA format
    original_width, original_height = img.width, img.height
    new_width = nearest_power_of_2_smaller(original_width)
    new_height = nearest_power_of_2_smaller(original_height)
    img = img.resize((new_width, new_height), Image.Resampling.LANCZOS)
    return img, new_width, new_height

def create_rgba_base91(image, width, height):
    """Convert image to raw RGBA bytes and encode with dimensions."""
    # Get raw RGBA pixel data
    rgba_data = image.tobytes()
    
    # Pack dimensions as 4-byte big-endian integers + RGBA data
    header = struct.pack('>II', width, height)  # Big-endian uint32 for width, height
    full_data = header + rgba_data
    
    # Encode to base91
    return base91_encode(full_data)

def find_first_image_in_directory():
    """Find the first image file in the current directory (sorted alphabetically)."""
    supported_extensions = ['*.png', '*.jpg', '*.jpeg', '*.bmp', '*.gif', '*.tiff', '*.webp']
    image_files = []
    
    for ext in supported_extensions:
        image_files.extend(glob.glob(ext))
        image_files.extend(glob.glob(ext.upper()))
    
    if image_files:
        # Sort alphabetically and return the first one
        image_files.sort()
        return image_files[0]
    
    return None

def get_image_from_clipboard():
    """Retrieve the first valid image from the clipboard or directory."""
    clipboard_content = ImageGrab.grabclipboard()

    if clipboard_content is None:
        # Try to find an image in the current directory
        image_file = find_first_image_in_directory()
        if image_file:
            print(f"No clipboard image found. Using file: {image_file}")
            return Image.open(image_file)
        raise ValueError("No image found in clipboard or current directory.")

    if isinstance(clipboard_content, list):  # Windows clipboard sometimes returns file paths
        for item in clipboard_content:
            if isinstance(item, str):  # If it's a file path
                try:
                    return Image.open(item)  # Try opening the image file
                except Exception:
                    continue  # Ignore invalid image files

        # If clipboard list failed, try directory fallback
        image_file = find_first_image_in_directory()
        if image_file:
            print(f"Clipboard contains invalid items. Using file: {image_file}")
            return Image.open(image_file)
        raise ValueError("Clipboard contains multiple items, but no valid images.")

    if isinstance(clipboard_content, Image.Image):  # Directly copied image
        return clipboard_content

    # Final fallback to directory
    image_file = find_first_image_in_directory()
    if image_file:
        print(f"Clipboard content invalid. Using file: {image_file}")
        return Image.open(image_file)
    
    raise ValueError("Clipboard does not contain an image and no images found in directory.")

def main():
    try:
        # Grab the first valid image from clipboard or directory
        image = get_image_from_clipboard()
        print(f"Original dimensions: {image.width}x{image.height}")

        # Optimize the image
        optimized_img, width, height = optimize_image_to_smaller_power_of_2(image)
        print(f"Optimized dimensions: {width}x{height}")

        # Convert to RGBA base91
        base91_string = create_rgba_base91(optimized_img, width, height)

        # Copy to clipboard
        pyperclip.copy(base91_string)
        print(f"✅ RGBA data successfully converted and copied to clipboard!")
        print(f"Data size: {len(base91_string)} characters")
        print(f"Expected RGBA bytes: {width * height * 4}")
        print("\n📋 Base91 string is now in clipboard - paste it into your Lua script!")

    except Exception as e:
        print(f"❌ Error: {e}")

if __name__ == "__main__":
    main()
