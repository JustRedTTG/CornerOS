-- Get ALL components
local function getComponentAddress(name)
	return component.list(name)() or error("Required " .. name .. " component is missing")
end

local EEPROMAddress, internetAddress, gpuAddress = 
	getComponentAddress("eeprom"),
	getComponentAddress("internet"),
	getComponentAddress("gpu")

-- Get Ready ~
do
local addr, invoke = computer.getBootAddress(), component.invoke
  local function loadfile(file)
    local handle = assert(invoke(addr, "open", file))
    local buffer = ""
    repeat
      local data = invoke(addr, "read", handle, math.huge)
      buffer = buffer .. (data or "")
    until not data
    invoke(addr, "close", handle)
    return load(buffer, "=" .. file, "bt", _G)
  end
end
local function deserialize(text)
	local result, reason = load("return " .. text, "=string")
	if result then
		return result()
	else
		error(reason)
	end
end

-- Internet
local config
local repositoryURL = "https://raw.githubusercontent.com/JustRedTTG/CornerOS/main/"
local installerURL = "Installer/"

local function rawRequest(url, chunkHandler)
	local internetHandle, reason = component.invoke(internetAddress, "request", repositoryURL .. url:gsub("([^%w%-%_%.%~])", function(char)
		return string.format("%%%02X", string.byte(char))
	end))

	if internetHandle then
		local chunk, reason
		while true do
			chunk, reason = internetHandle.read(math.huge)	
			
			if chunk then
				chunkHandler(chunk)
			else
				if reason then
					error("Internet request failed: " .. tostring(reason))
				end

				break
			end
		end

		internetHandle.close()
	else
		error("Connection failed: " .. url)
	end
end
local function request(url)
	local data = ""
	
	rawRequest(url, function(chunk)
		data = data .. chunk
	end)

	return data
end
local function download(url, path)
	selectedFilesystemProxy.makeDirectory(filesystemPath(path))

	local fileHandle, reason = selectedFilesystemProxy.open(path, "wb")
	if fileHandle then	
		rawRequest(url, function(chunk)
			selectedFilesystemProxy.write(fileHandle, chunk)
		end)

		selectedFilesystemProxy.close(fileHandle)
	else
		error("File opening failed: " .. tostring(reason))
	end
end

-- Binding GPU to screen
component.invoke(gpuAddress, "bind", getComponentAddress("screen"))
local screenWidth, screenHeight = component.invoke(gpuAddress, "getResolution")

-- Drawing functions
local function background(color)
	component.invoke(gpuAddress, "setBackground", color)
	component.invoke(gpuAddress, "fill", 1, 1, screenWidth, screenHeight, " ")
end
local function centerOf(width)
	return math.floor(screenWidth/2 - width/2)
end
local function centerText(y, color, text)
	component.invoke(gpuAddress, "fill", 1, y, screenWidth, 1, " ")
	component.invoke(gpuAddress, "setForeground", color)
	component.invoke(gpuAddress, "set", centerOf(#text), y, text)
end
local function title(textColor)
	local y = math.floor(screenHeight / 2 - 2)
	centerText(y, textColor, "CornerOS")
	return y + 4
end
local function fullProgress(config)
	local width = math.floor(screenWidth/5)
	local x, y = centerOf(width), title(config.mainColors.text)-2
	component.invoke(gpuAddress, "setForeground", 0x878787)
	component.invoke(gpuAddress, "set", x, y, string.rep("─", width))
	component.invoke(gpuAddress, "setForeground", config.mainColors.progressbarBAD)
	component.invoke(gpuAddress, "set", x + width, y, string.rep("─", width))
end
local function progress(p, config)
	local width = math.floor(screenWidth/5)
	local x, y, length = centerOf(width), title(config.mainColors.text)-2, math.ceil(width * p)
	component.invoke(gpuAddress, "setForeground", 0x878787)
	component.invoke(gpuAddress, "set", x, y, string.rep("─", length))
	component.invoke(gpuAddress, "setForeground", config.mainColors.progressbarOK)
	component.invoke(gpuAddress, "set", x + length, y, string.rep("─", width - length))
end

-- Begin Downloads
local config = deserialize(request(installerURL .. "config.cfg"))
--
fullProgress(config)
background(config.mainColors.background)
progress(0.5, config)
while true do

end