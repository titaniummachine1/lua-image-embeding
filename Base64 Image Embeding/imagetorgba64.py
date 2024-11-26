import os
import base64
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

def prepend_dimensions_to_base64(base64_string, width, height):
    """Prepend image dimensions to the Base64 string in a decodable format."""
    dimensions = f"{width:04}{height:04}"  # 4 digits each for width and height
    dimensions_bytes = dimensions.encode("utf-8")
    dimensions_encoded = base64.b64encode(dimensions_bytes).decode("utf-8")
    return f"{dimensions_encoded}{base64_string}"

def save_base64_to_txt(base64_string, output_filename="embedded_image.txt"):
    """Overwrite the file with only the Base64 string."""
    with open(output_filename, 'w') as txt_file:
        txt_file.write(base64_string)

def main():
    # Directory where the script will look for the first image
    folder_path = os.getcwd()  # Current directory
    output_file = "embedded_image.txt"

    # Find the first image file in the folder
    image_filename = find_first_image(folder_path)
    if not image_filename:
        print("No image files found in the directory.")
        return

    print(f"Found image: {image_filename}")

    # Full path to the image file
    image_path = os.path.join(folder_path, image_filename)

    # Optimize the image
    optimized_img, width, height = optimize_image_to_smaller_power_of_2(image_path)

    # Convert the optimized image to Base64
    base64_string = base64.b64encode(optimized_img.tobytes()).decode('utf-8')

    # Prepend the dimensions to the Base64 string
    full_base64_string = prepend_dimensions_to_base64(base64_string, width, height)

    # Save the Base64 string to a text file
    save_base64_to_txt(full_base64_string, output_file)
    print(f"Base64 string saved to '{output_file}' with dimensions {width}x{height}.")

if __name__ == "__main__":
    main()