
local error = require("/lib/error.lua")

local config_loader = {}

function config_loader.from_text(text)
	local result, reason = load("return " .. text, "=string")
	if result then
		return result()
	else
		error.major(reason)
	end
end

return config_loader