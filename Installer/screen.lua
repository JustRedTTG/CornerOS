local error = require("/lib/error.lua")

local install_screen = {}
local gpuAddress = getComponentAddress("gpu")

local screenWidth, screenHeight = component.invoke(gpuAddress, "getResolution")

function install_screen.centerOf(width)
	return math.floor(screenWidth/2 - width/2)
end
function install_screen.centerText(y, color, text)
	component.invoke(gpuAddress, "fill", centerOf(#text) , y, #text, 1, " ")
	component.invoke(gpuAddress, "setForeground", color)
	component.invoke(gpuAddress, "set", centerOf(#text), y, text)
end
function install_screen.status(text, color)
	centerText(screenHeight * .5, color, text)
end

return install_screen