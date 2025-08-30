# Base91 RGBA Image Embedding

This method uses Base91 encoding for maximum space efficiency while maintaining simple embedded implementation.

## How It Works

1. **Image Processing**: Takes image from clipboard or first image file in directory (alphabetically sorted)
2. **Power-of-2 Resizing**: Automatically resizes to nearest smaller power-of-2 dimensions for GPU compatibility
3. **RGBA Conversion**: Converts to raw RGBA pixel data (4 bytes per pixel)
4. **Header Encoding**: Prepends 8-byte binary header with width/height as big-endian uint32s
5. **Base91 Encoding**: Encodes the header + RGBA data using 91-character alphabet for optimal density
6. **Clipboard Output**: Copies the Base91 string to clipboard for pasting into Lua

## Files

- **`imagetobase91.py`** - Python script that converts images to Base91 RGBA strings
- **`base91toimage.lua`** - Lua decoder with Base91 decoding and texture rendering

## Usage

1. Copy an image to clipboard OR place an image file in this directory
2. Run: `python imagetobase91.py`
3. Paste the Base91 string into your Lua script
4. Use the decoder from `base91toimage.lua` to render the image

## Advantages

- **Most space efficient** - Base91 uses 91 characters vs Base64's 64, achieving ~88% efficiency
- **Smaller than Base64** - Approximately 15-20% smaller files than Base64
- **Simple decoder** - Self-contained Lua implementation, no external dependencies
- **Printable ASCII** - Uses only safe printable characters

## Size Comparison

| Method | Efficiency | Relative Size | Example Size |
|--------|------------|---------------|--------------|
| **Base91** | ~88% | 1.0x | ~580KB |
| **Base64** | ~75% | 1.2x | ~686KB |
| **Binary Hex** | ~25% | 4.0x | ~2MB |

## Supported Image Formats

PNG, JPG, JPEG, BMP, GIF, TIFF, WEBP (case-insensitive)

## Technical Details

- Uses 91-character alphabet for maximum density
- Integer-based encoding/decoding for simplicity
- Binary dimension headers avoid UTF-8 parsing overhead
- Bitwise operations for fast dimension extraction
- Single texture creation at load time
