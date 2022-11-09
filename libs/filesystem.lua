local component = component

local error = require('/lib/error.lua')

local function getComponentAddress(name)
	return component.list(name)() or error.major("Required " .. name .. " component is missing")
end

local EEPROMAddress = getComponentAddress("eeprom")

local filesystem = {}

function filesystem.getRoot()
    return component.proxy(component.invoke(EEPROMAddress, "getData"))
end

filesystem.root = filesystem.getRoot()


return filesystem