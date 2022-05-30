local function getComponentAddress(name)
	return component.list(name)() or error("Required " .. name .. " component is missing")
end

local EEPROMAddress, internetAddress, GPUAddress = 
	getComponentAddress("eeprom"),
	getComponentAddress("internet"),
	getComponentAddress("gpu")

-- Binding GPU to screen in case it's not done yet
component.invoke(GPUAddress, "bind", getComponentAddress("screen"))
local screenWidth, screenHeight = component.invoke(GPUAddress, "getResolution")

local repositoryURL = "https://raw.githubusercontent.com/JustRedTTG/CraftOS/main/"

component.invoke(GPUAddress, "setBackground", 0xE1E1E1)
component.invoke(GPUAddress, "fill", 1, 1, screenWidth, screenHeight, " ")