-- Get ALL components
local component = component
local computer = computer
local unicode = unicode

local function getComponentAddress(name)
	return component.list(name)() or error("Required " .. name .. " component is missing")
end

local EEPROMAddress, internetAddress, gpuAddress = 
	getComponentAddress("eeprom"),
	getComponentAddress("internet"),
	getComponentAddress("gpu")

-- Get Ready ~
local installerDir = "/download/"
local installDir = "/mnt/1cd/"

local filesystemProxy = component.proxy(component.invoke(EEPROMAddress, "getData"))

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
local function filesystemPath(path)
	return path:match("^(.+%/).") or ""
end

package = {loading = {}, loaded = {}}

function require(module)
	if package.loaded[module] then
		return package.loaded[module]
	elseif package.loading[module] then
		error("already loading " .. module .. ": " .. debug.traceback())
	else
		package.loading[module] = true

		local handle, reason = temporaryFilesystemProxy.open(installerPath .. "Libraries/" .. module .. ".lua", "rb")
		if handle then
			local data, chunk = ""
			repeat
				chunk = temporaryFilesystemProxy.read(handle, math.huge)
				data = data .. (chunk or "")
			until not chunk

			temporaryFilesystemProxy.close(handle)
			
			local result, reason = load(data, "=" .. module)
			if result then
				package.loaded[module] = result() or true
			else
				error(reason)
			end
		else
			error("File opening failed: " .. tostring(reason))
		end

		package.loading[module] = nil

		return package.loaded[module]
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
	filesystemProxy.makeDirectory(filesystemPath(path))

	local fileHandle, reason = filesystemProxy.open(path, "wb")
	if fileHandle then	
		rawRequest(url, function(chunk)
			filesystemProxy.write(fileHandle, chunk)
		end)

		filesystemProxy.close(fileHandle)
	else
		error("File opening failed: " .. tostring(reason))
	end
end

-- Filesystem
local function copy_file(from, to)
	filesystemProxy.makeDirectory(filesystemPath(to))

	local fileHandle, reason = filesystemProxy.open(from, "rb")
	local fileHandle2, reason = filesystemProxy.open(to, "wb")
	local chunk = ""
	if fileHandle and fileHandle2 then
		chunk = filesystemProxy.read(fileHandle, math.huge)
		filesystemProxy.write(fileHandle2, chunk or "")
	end
end

-- Binding GPU to screen
component.invoke(gpuAddress, "bind", getComponentAddress("screen"))
local screenWidth, screenHeight = component.invoke(gpuAddress, "getResolution")

-- Drawing functions
local function box(color, color2, color3, x, y, sizeX, sizeY, config)
	component.invoke(gpuAddress, "setBackground", color)
	component.invoke(gpuAddress, "setForeground", color2)
	component.invoke(gpuAddress, "fill", x, y, sizeX, 1, config.mainCharacters.boxHorizontal)
	component.invoke(gpuAddress, "fill", x, y, 1, sizeY, config.mainCharacters.boxVertical)
	
	component.invoke(gpuAddress, "set", x, y, config.mainCharacters.boxTopLeft)
	component.invoke(gpuAddress, "set", x, y+sizeY-1, config.mainCharacters.boxBottomLeft)
	component.invoke(gpuAddress, "setForeground", color3)
	component.invoke(gpuAddress, "fill", x+1, y+sizeY-1, sizeX-1, 1, config.mainCharacters.boxHorizontal)
	component.invoke(gpuAddress, "fill", x+sizeX-1, y+1, 1, sizeY-1, config.mainCharacters.boxVertical)
	
	component.invoke(gpuAddress, "set", x+sizeX-1, y, config.mainCharacters.boxTopRight)
	component.invoke(gpuAddress, "set", x+sizeX-1, y+sizeY-1, config.mainCharacters.boxBottomRight)
end
local function background(color, color2, color3, config)
	box(color, color2, color3, 1, 1, screenWidth, screenHeight, config)
	component.invoke(gpuAddress, "fill", 2, 2, screenWidth -2, screenHeight -2, " ")
end
local function centerOf(width)
	return math.floor(screenWidth/2 - width/2)
end
local function centerText(y, color, text)
	component.invoke(gpuAddress, "fill", centerOf(#text) , y, #text, 1, " ")
	component.invoke(gpuAddress, "setForeground", color)
	component.invoke(gpuAddress, "set", centerOf(#text), y, text)
end
local function title(textColor)
	local y = math.floor(screenHeight / 2 - 2)
	centerText(y, textColor, "CornerOS")
	return y + 4
end
local function status(text, color)
	local y = title(color)
	centerText(y, color, text)
end
local function progress(p, config)
	local width = math.floor(screenWidth/5)
	local x, y, length = centerOf(width), title(config.mainColors.text)-2, math.ceil(width * p)
	component.invoke(gpuAddress, "setForeground", config.mainColors.progressbarOK)
	component.invoke(gpuAddress, "set", x, y, string.rep("─", length))
	component.invoke(gpuAddress, "setForeground", config.mainColors.backgroundLower)
	component.invoke(gpuAddress, "set", x + length, y, string.rep("─", width - length))
end

-- Begin Downloads
local config = deserialize(request(installerURL .. "config.cfg"))
--
local debug = true
background(config.mainColors.background, config.mainColors.backgroundUpper, config.mainColors.backgroundMidrange, config)
progress(0, config)
status("Please wait...", config.mainColors.text)


background(config.mainColors.background, config.mainColors.backgroundUpper, config.mainColors.backgroundMidrange, config)
if debug then
	status("Debug Screen", config.mainColors.text)
	progress(0.25, config)
	repeat
		needWait = computer.pullSignal()
	until needWait == "key_down" or needWait == "touch"
end

background(config.mainColors.background, config.mainColors.backgroundUpper, config.mainColors.backgroundMidrange, config)
status("Downloading Libraries...", config.mainColors.text)
for i = 1, #config.libs do
	progress(i / #config.libs, config)
	download("/libs/" .. config.libs[i], installerDir .. "/lib/" .. config.libs[i])
end

background(config.mainColors.background, config.mainColors.backgroundUpper, config.mainColors.backgroundMidrange, config)
status("Downloading Boot...", config.mainColors.text)
for i = 1, #config.libs do
	progress(i / #config.libs, config)
	download("/BOOT/" .. config.libs[i], installerDir .. "/boot/" .. config.libs[i])
end

background(config.mainColors.background, config.mainColors.backgroundUpper, config.mainColors.backgroundMidrange, config)
status("Copying files...", config.mainColors.text)
local total = #config.libs + #config.bios
for i = 1, #config.libs do
	progress(i / total, config)
	copy_file(installerDir .. "/lib/" .. config.libs[i], installDir .. "/lib/" .. config.libs[i])
end

for i = 1, #config.bios do
	progress(i+#config.libs / total, config)
	copy_file(installerDir .. "/boot/" .. config.bios[i], installDir .. config.bios[i])
end