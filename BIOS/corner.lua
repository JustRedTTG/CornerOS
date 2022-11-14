local component = component
local computer = computer
local unicode = unicode
local errorfun = error
function getComponentAddress(name)
	return component.list(name)() or errorfun("Required " .. name .. " component is missing")
end
function getComponentAddressSafe(name)
	return component.list(name)() or nil
end
function getComponent(addr)
  return component.proxy(addr) or nil
end
local EEPROMAddress = getComponentAddress("eeprom")

filesystemProxy = component.proxy(component.invoke(EEPROMAddress, "getData"))

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
package = {loading = {}, loaded = {}}

function require(module)
	if package.loaded[module] then
		return package.loaded[module]
	elseif package.loading[module] then
		errorfun("already loading " .. module .. ": " .. debug.traceback())
	else
		package.loading[module] = true

		local handle, reason = filesystemProxy.open(module, "rb")
		if handle then
			local data, chunk = "", nil
			repeat
				chunk = filesystemProxy.read(handle, math.huge)
				data = data .. (chunk or "")
			until not chunk

			filesystemProxy.close(handle)
			
			local result, reason = load(data, "=" .. module)
			if result then
				package.loaded[module] = result() or true
			else
				errorfun(reason)
			end
		else
			errorfun("fail opening module: " .. tostring(module))
		end

		package.loading[module] = nil

		return package.loaded[module]
	end
end
errorfun = require("/lib/error.lua").major
local corner = require("/corner2.lua")
local install_lib = require("/lib/install_lib.lua")
install_lib.check()
corner.load()
