local pre_init
do
	-- Get component
	local screen = component.list("screen")()
	local gpu = component.list("gpu")()
	local eeprom = component.list("eeprom")()
	local component_invoke = component.invoke
	local function boot_invoke(address, method, ...)
	
	-- Bind GPU to screen
    if gpu and screen then
		boot_invoke(gpu, "bind", screen)
		local screenWidth, screenHeight = component_invoke(gpu, "getResolution")
		component_invoke(gpu, "setBackground", 0x000000)
		component_invoke(gpu, "fill", 1, 1, screenWidth, screenHeight, " ")
    end
end

local function error(message)
	computer.shutdown()
end


local init
do
	
	-- Boot invoke
		local result = table.pack(pcall(component_invoke, address, method, ...))
		if not result[1] then
			return nil, result[2]
		else
			return table.unpack(result, 2, result.n)
		end
	end
	
	
	-- Get boot adress
	computer.getBootAddress = function()
		return boot_invoke(eeprom, "getData")
	end
	computer.setBootAddress = function(address)
		return boot_invoke(eeprom, "setData", address)
	end
	local reason2
	local function loadFrom(address, loadAddr)
		local handle, reason = boot_invoke(address, "open", loadAddr)
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
		init, reason = loadFrom(computer.getBootAddress(), "/corner.lua")
		if not init then
			init, reason = loadFrom(computer.getBootAddress(), "/init.lua")
		end
	end
	reason2 = "No bootable disk"
	if not init then
		computer.setBootAddress()
		for address in component.list("filesystem") do
			init, reason = loadFrom(address, "/corner.lua")
			if not init then
				init, reason = loadFrom(address, "/init.lua")
			end
			if init then
				computer.setBootAddress(address)
				break
			end
		end
	end
	
	-- Error no boot
	if not init then
		error("Couldn't boot." .. (reason and (": " .. tostring(reason)) or "") .. (reason2 and (" ; " .. tostring(reason2)) or ""), 0)
	end
computer.beep(500, 0.2)
end

pre_init()

init()