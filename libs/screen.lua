local error = require("/lib/error.lua")

local screen = {}
local gpuAddress = getComponentAddress("gpu")

local screenWidth, screenHeight = component.invoke(gpuAddress, "getResolution")

function screen.box(color, color2, color3, x, y, sizeX, sizeY, config)
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
function screen.background(color, color2, color3, config)
	screen.box(color, color2, color3, 1, 1, screenWidth, screenHeight, config)
	component.invoke(gpuAddress, "fill", 2, 2, screenWidth -2, screenHeight -2, " ")
end
function screen.centerOf(width)
	return math.floor(screenWidth/2 - width/2)
end
function screen.centerText(y, color, text)
	component.invoke(gpuAddress, "fill", screen.centerOf(#text) , y, #text, 1, " ")
	component.invoke(gpuAddress, "setForeground", color)
	component.invoke(gpuAddress, "set", screen.centerOf(#text), y, text)
end
function screen.title(textColor)
	local y = math.floor(screenHeight / 2 - 2)
	screen.centerText(y, textColor, "CornerOS")
	return y + 4
end
function screen.status(text, color)
	local y = screen.title(color)
	screen.centerText(y, color, text)
end
function screen.progress(p, config)
	local width = math.floor(screenWidth/5)
	local x, y, length = screen.centerOf(width), screen.title(config.mainColors.text)-2, math.ceil(width * p)
	component.invoke(gpuAddress, "setForeground", config.mainColors.progressbarOK)
	component.invoke(gpuAddress, "set", x, y, string.rep("─", length))
	component.invoke(gpuAddress, "setForeground", config.mainColors.backgroundLower)
	component.invoke(gpuAddress, "set", x + length, y, string.rep("─", width - length))
end

return screen