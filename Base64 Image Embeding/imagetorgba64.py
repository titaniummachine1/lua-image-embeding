import base64
import io
import os
import pyperclip
from PIL import Image, ImageGrab

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
    img = img.resize((new_width, new_height), Image.Resampling.BOX)
    return img, new_width, new_height

def prepend_dimensions_to_base64(base64_string, width, height):
    """Prepend image dimensions to the Base64 string in a decodable format."""
    dimensions = f"{width:04}{height:04}"  # 4 digits each for width and height
    dimensions_bytes = dimensions.encode("utf-8")
    dimensions_encoded = base64.b64encode(dimensions_bytes).decode('utf-8')
    return f"{dimensions_encoded}{base64_string}"

def get_image_from_clipboard():
    """Retrieve an image from the clipboard, handling different formats."""
    clipboard_content = ImageGrab.grabclipboard()

    if clipboard_content is None:
        raise ValueError("No image found in clipboard. Copy an image first.")

    if isinstance(clipboard_content, list):  # Windows clipboard sometimes returns file paths
        for item in clipboard_content:
            if isinstance(item, str) and os.path.exists(item):  # Check if it's a file path
                try:
                    return Image.open(item)  # Open the image file
                except Exception:
                    continue  # Ignore if it's not a valid image file

        raise ValueError("Clipboard contains multiple items, but no valid images.")

    if isinstance(clipboard_content, Image.Image):  # Directly copied image
        return clipboard_content

    raise ValueError("Clipboard does not contain an image.")

def main():
    try:
        # Grab the first valid image from clipboard
        image = get_image_from_clipboard()

        # Optimize the image
        optimized_img, width, height = optimize_image_to_smaller_power_of_2(image)

        # Convert the optimized image to Base64
        with io.BytesIO() as output:
            optimized_img.save(output, format="PNG")
            base64_string = base64.b64encode(output.getvalue()).decode('utf-8')

        # Prepend the dimensions to the Base64 string
        full_base64_string = prepend_dimensions_to_base64(base64_string, width, height)

        # Copy Base64 string to clipboard
        pyperclip.copy(full_base64_string)
        print(f"✅ Image successfully converted and copied to clipboard! Dimensions: {width}x{height}")

    except Exception as e:
        print(f"❌ Error: {e}. Make sure an image is copied to the clipboard.")

if __name__ == "__main__":
    main()
