-- Base91 RGBA image data (paste your Base91 string here)
local base91_image = [=[
-- Paste the Base91 string here
]=]

-- Base91 character set
local BASE91_ALPHABET = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!#$%&()*+,./:;<=>?@[]^_`{|}~"'

-- Create lookup table for Base91 decoding
local base91_lookup = {}
for i = 1, #BASE91_ALPHABET do
	base91_lookup[BASE91_ALPHABET:sub(i, i)] = i - 1
end

local function base91_decode(data)
	---Decode Base91 string to binary data.
	if not data or data == "" then
		return ""
	end

	local alphabet = BASE91_ALPHABET
	local accumulator = 0
	local bits = 0
	local output = {}
	local i = 1

	while i <= #data do
		local char = data:sub(i, i)
		local val = base91_lookup[char]
		if not val then
			i = i + 1
		else
			if i + 1 <= #data then
				local next_char = data:sub(i + 1, i + 1)
				local next_val = base91_lookup[next_char]
				if next_val then
					local combined = val + next_val * 91
					accumulator = accumulator | (combined << bits)
					if combined > 88 then
						bits = bits + 13
					else
						bits = bits + 14
					end
					i = i + 2
				else
					accumulator = accumulator | (val << bits)
					bits = bits + 13
					i = i + 1
				end
			else
				accumulator = accumulator | (val << bits)
				bits = bits + 13
				i = i + 1
			end

			while bits >= 8 do
				table.insert(output, string.char(accumulator & 255))
				accumulator = accumulator >> 8
				bits = bits - 8
			end
		end
	end

	return table.concat(output)
end

-- Extract dimensions from first 8 bytes (big-endian uint32s)
local function extract_dimensions(raw_data)
	local width = (raw_data:byte(1) << 24) + (raw_data:byte(2) << 16) + (raw_data:byte(3) << 8) + raw_data:byte(4)
	local height = (raw_data:byte(5) << 24) + (raw_data:byte(6) << 16) + (raw_data:byte(7) << 8) + raw_data:byte(8)
	return width, height
end

-- Main function to create texture from Base91 RGBA data
local function create_texture_from_base91(base91_data)
	-- Decode base91 to raw bytes
	local raw_data = base91_decode(base91_data)

	-- Extract dimensions from header
	local width, height = extract_dimensions(raw_data)

	-- Extract RGBA pixel data (skip 8-byte header)
	local rgba_data = raw_data:sub(9)

	-- Validate data length
	local expected_length = width * height * 4
	if #rgba_data ~= expected_length then
		error(string.format("Invalid RGBA data length. Expected %d bytes, got %d bytes.", expected_length, #rgba_data))
	end

	-- Create texture
	local texture = draw.CreateTextureRGBA(rgba_data, width, height)
	if not texture then
		error("Failed to create texture from RGBA data.")
	end

	return texture, width, height
end

-- Create texture once at load time
local texture, width, height = create_texture_from_base91(base91_image)

-- Named draw function
local function draw_texture()
	local x, y = 0, 0 -- Position to draw the texture
	draw.Color(255, 255, 255, 255) -- Set color to white (opaque)
	draw.TexturedRect(texture, x, y, x + width, y + height)
end

-- Register the draw function to be called every frame
callbacks.Register("Draw", "RenderBase91Texture", draw_texture)
