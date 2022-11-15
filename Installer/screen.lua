local error = require("/lib/error.lua")

local install_screen = {}
local gpuAddr = getComponentAddress("gpu")

if gpuAddr == nil then
  error.major("no gpu")
end

local gpu = getComponent(gpuAddr)

local screenWidth, screenHeight = gpu.getResolution()

function install_screen.centerOf(width)
	return math.floor(screenWidth/2 - width/2)
end
function install_screen.centerText(y, color, text)
	gpu.fill(install_screen.centerOf(#text) , y, #text, 1, " ")
	gpu.setForeground(color)
	gpu.set(install_screen.centerOf(#text), y, text)
end
function install_screen.status(text, color)
	install_screen.centerText(screenHeight * .5, color, text)
end

return install_screen
