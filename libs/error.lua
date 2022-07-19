local component = component
local computer = computer

local gpu = component.list("gpu")() or error("Couldn't get GPU address in error.lua.")

local error = {}

function error.beep()
	for i = 1, 3 do
		computer.beep(1000, 0.5)
	end
end

function error.screen()
	local screenWidth, screenHeight = component_invoke(gpu, "getResolution")
	component_invoke(gpu, "setBackground", 0x180d21)
	component_invoke(gpu, "fill", 1, 1, screenWidth, screenHeight, " ")
	component_invoke(gpu, "set", 2, 2, "Corner OS error screen.")
end

function error.mild(message)
	error.screen()
	error.beep()
	computer.shutdown(true)
end

return error