local component = component
local computer = computer
local unicode = unicode

local function getComponentAddress(name)
	return component.list(name)() or error("Required " .. name .. " component is missing")
end
local function getComponentAddressSafe(name)
	return component.list(name)() or nil
end

local EEPROMAddress, internetAddress, gpuAddress = 
	getComponentAddress("eeprom"),
	getComponentAddressSafe("internet"),
	getComponentAddress("gpu")

-- Get Ready ~
local filesystemProxy = component.proxy(component.invoke(EEPROMAddress, "getData"))

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

		local handle, reason = temporaryFilesystemProxy.open(installerPath .. "Libraries/" .. module .. ".lua", "rb")
		if handle then
			local data, chunk = ""
			repeat
				chunk = temporaryFilesystemProxy.read(handle, math.huge)
				data = data .. (chunk or "")
			until not chunk

			temporaryFilesystemProxy.close(handle)
			
			local result, reason = load(data, "=" .. module)
			if result then
				package.loaded[module] = result() or true
			else
				error(reason)
			end
		else
			error("File opening failed: " .. tostring(reason))
		end

		package.loading[module] = nil

		return package.loaded[module]
	end
end


GUI = require("/lib/GUI.lua")



computer.shutdown()