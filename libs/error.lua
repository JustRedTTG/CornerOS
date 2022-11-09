local component = component
local computer = computer

local gpu = component.list("gpu")() or error("Couldn't get GPU address in error.lua.")

local error = {}

function error.beep()
	for i = 1, 3 do
		computer.beep(i * 500, 0.3)
	end
end

function error.screen(message)
	local screenWidth, screenHeight = component.invoke(gpu, "getResolution")
	component.invoke(gpu, "setBackground", 0x180d21)
	component.invoke(gpu, "fill", 1, 1, screenWidth, screenHeight, " ")
	component.invoke(gpu, "set", 4, 2, "Corner OS error screen.")
	component.invoke(gpu, "set", 4, screenHeight, "Press any key.")
	component.invoke(gpu, "set", screenWidth * .5 - 11, screenHeight * .5 -1, "Sorry to interrupt  :(")
	component.invoke(gpu, "set", screenWidth * .5 - #message * .5, screenHeight * .5, message)
end

function error.mild(message)
	error.screen(message)
	error.beep()
	while computer.pullSignal() ~= "key_down" do
		
	end
end

function error.major(message)
	error.screen(message)
	error.beep()
	while computer.pullSignal() ~= "key_down" do
		computer.shutdown()
	end
end

return error