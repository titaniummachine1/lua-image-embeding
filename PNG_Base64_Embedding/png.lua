-- The MIT License (MIT)

-- Copyright (c) 2013 DelusionalLogic

-- Permission is hereby granted, free of charge, to any person obtaining a copy of
-- this software and associated documentation files (the "Software"), to deal in
-- the Software without restriction, including without limitation the rights to
-- use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
-- the Software, and to permit persons to whom the Software is furnished to do so,
-- subject to the following conditions:

-- The above copyright notice and this permission notice shall be included in all
-- copies or substantial portions of the Software.

-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
-- FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
-- COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
-- IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
-- CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

local deflate = require("deflatelua")
local requiredDeflateVersion = "0.3.20111128"

if (deflate._VERSION ~= requiredDeflateVersion) then
    error("Incorrect deflate version: must be "..requiredDeflateVersion..", not "..deflate._VERSION)
end

local function bsRight(num, pow)
    return math.floor(num / 2^pow)
end

local function bsLeft(num, pow)
    return math.floor(num * 2^pow)
end

local function bytesToNum(bytes)
    local n = 0
    for k,v in ipairs(bytes) do
        n = bsLeft(n, 8) + v
    end
    if (n > 2147483647) then
        return (n - 4294967296)
    else
        return n
    end
    n = (n > 2147483647) and (n - 4294967296) or n
    return n
end

local function readInt(stream, bps)
    local bytes = {}
    bps = bps or 4
    for i=1,bps do
        bytes[i] = stream:read(1):byte()
    end
    return bytesToNum(bytes)
end

local function readChar(stream, num)
    num = num or 1
    return stream:read(num)
end

local function readByte(stream)
    return stream:read(1):byte()
end

local function getDataIHDR(stream, length)
    local data = {}
    data["width"] = readInt(stream)
    data["height"] = readInt(stream)
    data["bitDepth"] = readByte(stream)
    data["colorType"] = readByte(stream)
    data["compression"] = readByte(stream)
    data["filter"] = readByte(stream)
    data["interlace"] = readByte(stream)
    return data
end

local function getDataIDAT(stream, length, oldData)
    local data = {}
    if (oldData == nil) then
        data.data = readChar(stream, length)
    else
        data.data = oldData.data .. readChar(stream, length)
    end
    return data
end

local function getDataPLTE(stream, length)
    local data = {}
    data["numColors"] = math.floor(length/3)
    data["colors"] = {}
    for i = 1, data["numColors"] do
        data.colors[i] = {
            R = readByte(stream),
            G = readByte(stream),
            B = readByte(stream)
        }
    end
    return data
end

local function extractChunkData(stream)
    local chunkData = {}
    local length
    local type
    local crc

    while type ~= "IEND" do
        length = readInt(stream)
        type = readChar(stream, 4)
        if (type == "IHDR") then
            chunkData[type] = getDataIHDR(stream, length)
        elseif (type == "IDAT") then
            chunkData[type] = getDataIDAT(stream, length, chunkData[type])
        elseif (type == "PLTE") then
            chunkData[type] = getDataPLTE(stream, length)
        else
            readChar(stream, length)
        end
        crc = readChar(stream, 4)
    end

    return chunkData
end

local function makePixel(stream, depth, colorType, palette)
    local bps = math.floor(depth/8) --bits per sample
    local pixelData = { R = 0, G = 0, B = 0, A = 0 }
    local grey
    local index
    local color 

    if colorType == 0 then
        grey = readInt(stream, bps)
        pixelData.R = grey
        pixelData.G = grey
        pixelData.B = grey
        pixelData.A = 255
    elseif colorType == 2 then
        pixelData.R = readInt(stream, bps)
        pixelData.G = readInt(stream, bps)
        pixelData.B = readInt(stream, bps)
        pixelData.A = 255
    elseif colorType == 3 then
        index = readInt(stream, bps)+1
        color = palette.colors[index]
        pixelData.R = color.R
        pixelData.G = color.G
        pixelData.B = color.B
        pixelData.A = 255
    elseif colorType == 4 then
        grey = readInt(stream, bps)
        pixelData.R = grey
        pixelData.G = grey
        pixelData.B = grey
        pixelData.A = readInt(stream, bps)
    elseif colorType == 6 then
        pixelData.R = readInt(stream, bps)
        pixelData.G = readInt(stream, bps)
        pixelData.B = readInt(stream, bps)
        pixelData.A = readInt(stream, bps)
    end

    return pixelData
end

local function unfilterPixel(filterType, pixel, left, up, upLeft, bps)
    local unfiltered = {}
    
    if filterType == 0 then
        unfiltered = pixel
    elseif filterType == 1 then
        for i=1,bps do
            unfiltered[i] = (pixel[i] + left[i]) % 256
        end
    elseif filterType == 2 then
        for i=1,bps do
            unfiltered[i] = (pixel[i] + up[i]) % 256
        end
    elseif filterType == 3 then
        for i=1,bps do
            unfiltered[i] = (pixel[i] + math.floor((left[i] + up[i])/2)) % 256
        end
    elseif filterType == 4 then
        for i=1,bps do
            local p = left[i] + up[i] - upLeft[i]
            local pa = math.abs(p - left[i])
            local pb = math.abs(p - up[i])
            local pc = math.abs(p - upLeft[i])
            local pr
            if pa <= pb and pa <= pc then
                pr = left[i]
            elseif pb <= pc then
                pr = up[i]
            else
                pr = upLeft[i]
            end
            unfiltered[i] = (pixel[i] + pr) % 256
        end
    end
    
    return unfiltered
end

local function pngImage(path, newRowCallback, verbose, memSave)
    local file = io.open(path, "rb")
    if not file then
        error("Could not open file: " .. path)
    end
    
    local signature = readChar(file, 8)
    if signature ~= "\137PNG\r\n\026\n" then
        error("Invalid PNG signature")
    end
    
    local chunkData = extractChunkData(file)
    file:close()
    
    local ihdr = chunkData["IHDR"]
    local idat = chunkData["IDAT"]
    local plte = chunkData["PLTE"]
    
    local width = ihdr.width
    local height = ihdr.height
    local bitDepth = ihdr.bitDepth
    local colorType = ihdr.colorType
    
    local decompressed = deflate.inflate_zlib(idat.data)
    local stream = {
        data = decompressed,
        pos = 1,
        read = function(self, n)
            local result = self.data:sub(self.pos, self.pos + n - 1)
            self.pos = self.pos + n
            return result
        end
    }
    
    local bpp = math.ceil(bitDepth / 8) -- bytes per pixel component
    local pixelBytes = 1
    if colorType == 0 then pixelBytes = bpp
    elseif colorType == 2 then pixelBytes = bpp * 3
    elseif colorType == 3 then pixelBytes = bpp
    elseif colorType == 4 then pixelBytes = bpp * 2
    elseif colorType == 6 then pixelBytes = bpp * 4
    end
    
    local pixels = {}
    local prevRow = {}
    
    for y = 1, height do
        local filterType = stream:read(1):byte()
        local row = {}
        local rawRow = {}
        
        -- Read raw pixel data
        for x = 1, width do
            local pixel = {}
            for i = 1, pixelBytes do
                pixel[i] = stream:read(1):byte()
            end
            rawRow[x] = pixel
        end
        
        -- Unfilter the row
        for x = 1, width do
            local left = (x > 1) and row[x-1] or {}
            local up = prevRow[x] or {}
            local upLeft = (x > 1) and (prevRow[x-1] or {}) or {}
            
            -- Fill missing values with 0
            for i = 1, pixelBytes do
                left[i] = left[i] or 0
                up[i] = up[i] or 0
                upLeft[i] = upLeft[i] or 0
            end
            
            row[x] = unfilterPixel(filterType, rawRow[x], left, up, upLeft, pixelBytes)
        end
        
        -- Convert to RGBA pixels
        pixels[y] = {}
        for x = 1, width do
            local pixelStream = {
                data = string.char(table.unpack(row[x])),
                pos = 1,
                read = function(self, n)
                    local result = self.data:sub(self.pos, self.pos + n - 1)
                    self.pos = self.pos + n
                    return result
                end
            }
            pixels[y][x] = makePixel(pixelStream, bitDepth, colorType, plte)
        end
        
        prevRow = row
        
        if newRowCallback then
            newRowCallback(y, height, pixels[y])
        end
        
        if memSave then
            pixels[y] = nil
        end
    end
    
    return {
        width = width,
        height = height,
        depth = bitDepth,
        colorType = colorType,
        pixels = pixels
    }
end

return pngImage
