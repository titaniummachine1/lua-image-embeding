# Base64 RGBA Image Embedding

This method converts images to Base64-encoded RGBA data for embedding in Lua scripts.

## How It Works

1. **Image Processing**: Takes image from clipboard or first image file in directory (alphabetically sorted)
2. **Power-of-2 Resizing**: Automatically resizes to nearest smaller power-of-2 dimensions for GPU compatibility
3. **RGBA Conversion**: Converts to raw RGBA pixel data (4 bytes per pixel)
4. **Header Encoding**: Prepends 8-byte binary header with width/height as big-endian uint32s
5. **Base64 Encoding**: Encodes the header + RGBA data to Base64 string
6. **Clipboard Output**: Copies the Base64 string to clipboard for pasting into Lua

## Files

- **`imagetorgba64.py`** - Python script that converts images to Base64 RGBA strings
- **`Base64toimage.lua`** - Lua decoder with optimized Base64 decoding and texture rendering

## Usage

1. Copy an image to clipboard OR place an image file in this directory
2. Run: `python imagetorgba64.py`
3. Paste the Base64 string into your Lua script
4. Use the decoder from `Base64toimage.lua` to render the image

## Advantages

- **Smaller file size** (~686KB for typical images vs ~2MB for binary hex)
- **Text-based format** - easier to read and debug
- **Efficient encoding** - 75% efficiency (4 Base64 chars = 3 bytes)

## Supported Image Formats

PNG, JPG, JPEG, BMP, GIF, TIFF, WEBP (case-insensitive)

## Technical Details

- Uses lookup table Base64 decoder for optimal performance
- Binary dimension headers avoid UTF-8 parsing overhead
- Bitwise operations for fast dimension extraction
- Single texture creation at load time
