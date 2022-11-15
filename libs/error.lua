local component = component
local computer = computer

local gpu = component.proxy(component.list("gpu")()) or error("Couldn't get GPU address in error.lua.")

local error = {}

function error.beep()
	for i = 1, 3 do
		computer.beep(i * 500, 0.3)
	end
end

function error.screen(message, interupt_message)
	local screenWidth, screenHeight = gpu.getResolution()
	gpu.setBackground(0x180d21)
	gpu.setForeground(0xFFFFFF)
	gpu.fill(1, 1, screenWidth, screenHeight, " ")
	gpu.set(4, 2, "Corner OS error screen.")
	gpu.set(4, screenHeight-1, "Press any key.")
	gpu.set(screenWidth * .5 - (#interupt_message or 22) * .5 , screenHeight * .5 -1, interupt_message or "Sorry to interrupt  :(")
	gpu.set(screenWidth * .5 - #message * .5, screenHeight * .5, message)
end

function error.mild(message, custom_error_message)
	error.screen(message, custom_error_message)
	error.beep()
	while computer.pullSignal() ~= "key_down" do
		
	end
end

function error.okay(message)
	return error.mild(message, "Everything is good :)")
end

function error.major(message)
	error.screen(message, "Unrecoverable error :(")
	error.beep()
	while computer.pullSignal() ~= "key_down" do
		computer.shutdown()
	end
end

return error
