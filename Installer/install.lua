-- Get ALL components
local function getComponentAddress(name)
	return component.list(name)() or error("Required " .. name .. " component is missing")
end

local EEPROMAddress, internetAddress, GPUAddress = 
	getComponentAddress("eeprom"),
	getComponentAddress("internet"),
	getComponentAddress("gpu")

-- Binding GPU to screen
component.invoke(GPUAddress, "bind", getComponentAddress("screen"))
local screenWidth, screenHeight = component.invoke(GPUAddress, "getResolution")

local repositoryURL = "https://raw.githubusercontent.com/JustRedTTG/CornerOS/main/"

component.invoke(GPUAddress, "setBackground", 0x06181C)
component.invoke(GPUAddress, "fill", 1, 1, screenWidth, screenHeight, " ")

while true do
computer.pullSignal()
end