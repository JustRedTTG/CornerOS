-- Get ALL components
local component = component
local computer = computer
local unicode = unicode

local function getComponentAddress(name)
	return component.list(name)() or error("Required " .. name .. " component is missing")
end

local screenWidth, screenHeight
local EEPROMAddress, internetAddress = 
	getComponentAddress("eeprom"),
	getComponentAddress("internet")
local screen = component.list("screen", true)()
local gpu = component.list("gpu", true)()

-- Get Ready ~
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
if gpu and screen then
	gpu = component.proxy(gpu)
	screenWidth, screenHeight = gpu.maxResolution()
	gpu.setResolution(screenWidth, screenHeight)
	gpu = component.proxy(gpu)
	if not gpu.getScreen() then
		gpu.bind(screen)
	end
	screenWidth, screenHeight = gpu.maxResolution()
	gpu.setResolution(screenWidth, screenHeight)
end

-- Drawing functions
local function box(color, color2, color3, x, y, sizeX, sizeY, config)
	gpu.setBackground(color)
	gpu.setForeground(color2)
	gpu.fill( x, y, sizeX, 1, config.mainCharacters.boxHorizontal)
	gpu.fill( x, y, 1, sizeY, config.mainCharacters.boxVertical)
	
	gpu.set( x, y, config.mainCharacters.boxTopLeft)
	gpu.set( x, y+sizeY-1, config.mainCharacters.boxBottomLeft)
	gpu.setForeground(color3)
	gpu.fill( x+1, y+sizeY-1, sizeX-1, 1, config.mainCharacters.boxHorizontal)
	gpu.fill( x+sizeX-1, y+1, 1, sizeY-1, config.mainCharacters.boxVertical)
	
	gpu.set( x+sizeX-1, y, config.mainCharacters.boxTopRight)
	gpu.set( x+sizeX-1, y+sizeY-1, config.mainCharacters.boxBottomRight)
end
local function background(color, color2, color3, config)
	box(color, color2, color3, 1, 1, screenWidth, screenHeight, config)
	gpu.fill( 2, 2, screenWidth -2, screenHeight -2, " ")
end
local function centerOf(width)
	return math.floor(screenWidth/2 - width/2)
end
local function centerText(y, color, text)
	gpu.fill( centerOf(#text) , y, #text, 1, " ")
	gpu.setForeground(color)
	gpu.set( centerOf(#text), y, text)
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
	gpu.setForeground(config.mainColors.progressbarOK)
	gpu.set( x, y, string.rep("─", length))
	gpu.setForeground(config.mainColors.backgroundLower)
	gpu.set( x + length, y, string.rep("─", width - length))
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

