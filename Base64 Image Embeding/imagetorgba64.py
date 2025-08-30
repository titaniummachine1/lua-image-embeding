import base64
import io
import pyperclip
from PIL import Image, ImageGrab
import struct

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

def create_rgba_base64(image, width, height):
    """Convert image to raw RGBA bytes and encode with dimensions."""
    # Get raw RGBA pixel data
    rgba_data = image.tobytes()
    
    # Pack dimensions as 4-byte big-endian integers + RGBA data
    header = struct.pack('>II', width, height)  # Big-endian uint32 for width, height
    full_data = header + rgba_data
    
    # Encode to base64
    return base64.b64encode(full_data).decode('utf-8')

def get_image_from_clipboard():
    """Retrieve the first valid image from the clipboard."""
    clipboard_content = ImageGrab.grabclipboard()

    if clipboard_content is None:
        raise ValueError("No image found in clipboard. Copy an image first.")

    if isinstance(clipboard_content, list):  # Windows clipboard sometimes returns file paths
        for item in clipboard_content:
            if isinstance(item, str):  # If it's a file path
                try:
                    return Image.open(item)  # Try opening the image file
                except Exception:
                    continue  # Ignore invalid image files

        raise ValueError("Clipboard contains multiple items, but no valid images.")

    if isinstance(clipboard_content, Image.Image):  # Directly copied image
        return clipboard_content

    raise ValueError("Clipboard does not contain an image.")

def main():
    try:
        # Grab the first valid image from clipboard
        image = get_image_from_clipboard()
        print(f"Original dimensions: {image.width}x{image.height}")

        # Optimize the image
        optimized_img, width, height = optimize_image_to_smaller_power_of_2(image)
        print(f"Optimized dimensions: {width}x{height}")

        # Convert to RGBA base64
        base64_string = create_rgba_base64(optimized_img, width, height)

        # Copy to clipboard
        pyperclip.copy(base64_string)
        print(f"✅ RGBA data successfully converted and copied to clipboard!")
        print(f"Data size: {len(base64_string)} characters")
        print(f"Expected RGBA bytes: {width * height * 4}")

    except Exception as e:
        print(f"❌ Error: {e}")

if __name__ == "__main__":
    main()
