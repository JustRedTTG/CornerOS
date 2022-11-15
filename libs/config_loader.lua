
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

function config_loader.to_text(config)
	local result, reason = load("return " .. config, "=table")
	if result then
		return tostring(result())
	else
		error.major(reason)
	end
end

return config_loader