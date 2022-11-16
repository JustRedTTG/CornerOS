local error = require("/lib/error.lua")

local screen = {}
local gpuAddr = getComponentAddress("gpu")

if gpuAddr == nil then
  error.major("no gpu")
end

local gpu = getComponent(gpuAddr)
screen.screenWidth, screen.screenHeight = gpu.getResolution()

function screen.box(color, color2, color3, x, y, sizeX, sizeY, config)
	gpu.setBackground(color)
	gpu.setForeground(color2)
	gpu.fill(x, y, sizeX, 1, config.mainCharacters.boxHorizontal)
	gpu.fill(x, y, 1, sizeY, config.mainCharacters.boxVertical)

	gpu.set(x, y, config.mainCharacters.boxTopLeft)
	gpu.set(x, y+sizeY-1, config.mainCharacters.boxBottomLeft)
	gpu.setForeground(color3)
	gpu.fill(x+1, y+sizeY-1, sizeX-1, 1, config.mainCharacters.boxHorizontal)
	gpu.fill(x+sizeX-1, y+1, 1, sizeY-1, config.mainCharacters.boxVertical)

	gpu.set(x+sizeX-1, y, config.mainCharacters.boxTopRight)
	gpu.set(x+sizeX-1, y+sizeY-1, config.mainCharacters.boxBottomRight)
end
function screen.background(color, color2, color3, config)
	screen.box(color, color2, color3, 1, 1, screen.screenWidth, screen.screenHeight, config)
	gpu.fill(2, 2, screen.screenWidth -2, screen.screenHeight -2, " ")
end
function screen.centerOf(width)
	return math.floor(screen.screenWidth/2 - width/2)
end
function screen.centerText(y, color, text)
	gpu.fill(screen.centerOf(#text) , y, #text, 1, " ")
	gpu.setForeground(color)
	gpu.set(screen.centerOf(#text), y, text)
end
function screen.centeredBox(color, color2, color3, w, h, config)
	local x, y = screen.screenWidth * .5 - w * .5, screen.screenHeight * .5 - h * .5
	screen.box(color, color2, color3, x, y, w, h, config)
	gpu.fill(x+1, y+1, w-2, h-2, " ")
end
function screen.title(textColor)
	local y = math.floor(screen.screenHeight / 2 - 2)
	screen.centerText(y, textColor, "CornerOS")
	return y + 4
end
function screen.status(text, color)
	local y = screen.title(color)
	screen.centerText(y, color, text)
end
function screen.progress(p, config)
	local width = math.floor(screen.screenWidth/5)
	local x, y, length = screen.centerOf(width), screen.title(config.mainColors.text)-2, math.ceil(width * p)
	gpu.setForeground(config.mainColors.progressbarOK)
	gpu.set(x, y, string.rep("─", length))
	gpu.setForeground(config.mainColors.backgroundLower)
	gpu.set(x + length, y, string.rep("─", width - length))
end

return screen
