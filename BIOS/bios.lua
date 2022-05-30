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
	local GPUAddress = component.list("gpu")()
	local screenWidth, screenHeight = component_invoke(GPUAddress, "getResolution")
	component_invoke(GPUAddress, "setBackground", 0x06181C)
	component_invoke(GPUAddress, "fill", 1, 1, screenWidth, screenHeight, " ")
	
	-- Get boot adress
	computer.getBootAddress = function()
		return boot_invoke(eeprom, "getData")
	end
	
	local function loadFrom(address)
		local handle, reason = boot_invoke(address, "open", "/craft.lua")
		if not handle then
			return nil, reason
		end
		local buffer = ""
		repeat
			local data, reason = boot_invoke(address, "read", handle, math.huge)
			if not data and reason then
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
		error("Couldn't find bootable disk." .. (reason and (": " .. tostring(reason)) or ""), 0)
	end
end
init()