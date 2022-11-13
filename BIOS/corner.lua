component = component
computer = computer
unicode = unicode

local function getComponentAddress(name)
	return component.list(name)() or error("Required " .. name .. " component is missing")
end
function getComponentAddressSafe(name)
	return component.list(name)() or nil
end
local EEPROMAddress = getComponentAddress("eeprom")

---@diagnostic disable-next-line: lowercase-global
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
local function filesystemPath(path)
	return path:match("^(.+%/).") or ""
end

package = {loading = {}, loaded = {}}

function require(module)
	if package.loaded[module] then
		return package.loaded[module]
	elseif package.loading[module] then
		error("already loading " .. module .. ": " .. debug.traceback())
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
				error(reason)
			end
		else
			error("Fail opening module: " .. tostring(module))
		end

		package.loading[module] = nil

		return package.loaded[module]
	end
end
local error = require("/corner2.lua")
function getComponentAddress(name)
	return component.list(name)() or error.mild("Required " .. name .. " component is missing")
end
local corner = require("/corner2.lua")
local install_lib = require("/files/install_lib.lua")
install_lib.check()
corner.load()