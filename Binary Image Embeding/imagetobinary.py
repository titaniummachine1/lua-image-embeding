import os
from PIL import Image

def find_first_image(folder_path):
    """Find the first image file in the directory."""
    image_extensions = ('.png', '.jpg', '.jpeg', '.gif', '.bmp')
    for filename in os.listdir(folder_path):
        if filename.lower().endswith(image_extensions):
            return filename
    return None

def nearest_power_of_2_smaller(x):
    """Calculate the nearest power of 2 smaller than or equal to x."""
    if x <= 0:
        return 1
    return 2 ** (x.bit_length() - 1)

def optimize_image_to_smaller_power_of_2(image_path):
    """Resize image to the nearest smaller power-of-2 dimensions."""
    with Image.open(image_path) as img:
        img = img.convert("RGBA")  # Ensure RGBA format
        original_width, original_height = img.width, img.height
        new_width = nearest_power_of_2_smaller(original_width)
        new_height = nearest_power_of_2_smaller(original_height)
        img = img.resize((new_width, new_height), Image.Resampling.BOX)
        return img, new_width, new_height

def prepend_dimensions_to_binary_string(rgba_data, width, height):
    """Prepend dimensions to the binary string."""
    dimensions = width.to_bytes(4, 'big') + height.to_bytes(4, 'big')  # 4 bytes each for width and height
    return dimensions + rgba_data

def format_as_lua_string(binary_data):
    """Format binary data as a Lua-compatible string."""
    lua_compatible_string = ''.join(f'\\x{byte:02x}' for byte in binary_data)
    return lua_compatible_string

def save_binary_string_to_file(lua_string, output_filename="embedded_image.txt"):
    """Save the Lua-compatible binary string to a file."""
    with open(output_filename, 'w') as file:
        file.write(lua_string)

def main():
    folder_path = os.getcwd()  # Current directory
    output_file = "embedded_image.txt"

    # Find the first image file in the folder
    image_filename = find_first_image(folder_path)
    if not image_filename:
        print("No image files found in the directory.")
        return

    print(f"Found image: {image_filename}")

    image_path = os.path.join(folder_path, image_filename)
    optimized_img, width, height = optimize_image_to_smaller_power_of_2(image_path)

    # Convert the image to raw binary (RGBA format)
    rgba_data = optimized_img.tobytes()

    # Prepend dimensions to the binary data
    binary_data = prepend_dimensions_to_binary_string(rgba_data, width, height)

    # Format as a Lua-compatible string
    lua_compatible_string = format_as_lua_string(binary_data)

    # Save the Lua-compatible binary string to a file
    save_binary_string_to_file(lua_compatible_string, output_file)

    print(f"Binary string saved to '{output_file}' with dimensions {width}x{height}.")

if __name__ == "__main__":
    main()
