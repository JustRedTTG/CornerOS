local init
do
	-- Get component
	local screen = component.list("screen")()
	local gpu = component.list("gpu")()
	local eeprom = component.list("eeprom")()
	local component_invoke = component.invoke
	local function boot_invoke(address, method, ...)
	-- Boot invoke
		local result = table.pack(pcall(component_invoke, address, method, ...))
		if not result[1] then
			return nil, result[2]
		else
			return table.unpack(result, 2, result.n)
		end
	end
	-- Bind GPU to screen
    if gpu and screen then
		boot_invoke(gpu, "bind", screen)
    end
	
	-- Get boot adress
	computer.getBootAddress = function()
		return boot_invoke(eeprom, "getData")
	end
	local reason2
	local function loadFrom(address)
		local handle, reason = boot_invoke(addre0ss, "open", "/craft.lua")
		if not handle then
			reason2 = "opening File"
			return nil, reason
		end
		local buffer = ""
		repeat
			local data, reason = boot_invoke(address, "read", handle, math.huge)
			if not data and reason then
				reason2 = "reading file"
				return nil, reason
			end
			buffer = buffer .. (data or "")
		until not data
		boot_invoke(address, "close", handle)
		return load(buffer, "=init")
	end
	
	-- Try to boot
	if computer.getBootAddress() then
		init, reason = loadFrom(computer.getBootAddress())
	end
	
	-- Error no boot
	if not init then
		error("Couldn't boot." .. (reason and (": " .. tostring(reason)) or "") .. (reason2 and (" ; " .. tostring(reason2)) or "") .. (computer.getBootAddress() and (" ; " .. tostring(computer.getBootAddress())) or ""), 0)
	end
end
init()