local component = component
local computer = computer

error = require("/lib/error.lua")

local gpu = component.list("gpu")() or error("Couldn't get GPU address in GUI.lua.")

local gui = {}

function gui.box(color, color2, color3, x, y, sizeX, sizeY, config)
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

return gui