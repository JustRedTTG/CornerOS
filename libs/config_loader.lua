
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

function config_loader.to_text(config_table, prettyLook, indentator, recursionStackLimit)
	recursionStackLimit = recursionStackLimit or math.huge
	indentator = indentator or "  "
	
	local equalsSymbol = prettyLook and " = " or "="

	local function serialize(config_table, currentIndentationSymbol, currentRecusrionStack)
		local result, nextIndentationSymbol, keyType, valueType, stringValue = {"{"}, currentIndentationSymbol .. indentator, nil, nil, nil
		
		if prettyLook then
			table.insert(result, "\n")
		end
		
		for key, value in pairs(config_table) do
			keyType, valueType, stringValue = type(key), type(value), tostring(value)

			if prettyLook then
				table.insert(result, nextIndentationSymbol)
			end
			
			if keyType == "number" then
				table.insert(result, "[")
				table.insert(result, key)
				table.insert(result, "]")
				table.insert(result, equalsSymbol)
			elseif keyType == "string" then
				if prettyLook and key:match("^%a") and key:match("^[%w%_]+$") then
					table.insert(result, key)
				else
					table.insert(result, "[\"")
					table.insert(result, key)
					table.insert(result, "\"]")
				end

				table.insert(result, equalsSymbol)
			end

			if valueType == "number" or valueType == "boolean" or valueType == "nil" then
				table.insert(result, stringValue)
			elseif valueType == "string" or valueType == "function" then
				table.insert(result, "\"")
				table.insert(result, stringValue)
				table.insert(result, "\"")
			elseif valueType == "table" then
				if currentRecusrionStack < recursionStackLimit then
					table.insert(
						result,
						table.concat( serialize(value, nextIndentationSymbol, currentRecusrionStack + 1 ) )
					)
				else
					table.insert(result, "\"…\"")
				end
			end
			
			table.insert(result, ",")

			if prettyLook then
				table.insert(result, "\n")
			end
		end

		if prettyLook then
			if #result > 2 then
				table.remove(result, #result - 1)
			end

			table.insert(result, currentIndentationSymbol)
		else
			if #result > 1 then
				table.remove(result, #result)
			end
		end

		table.insert(result, "}")

		return result
	end
	
	return table.concat(serialize(config_table, "", 1))
end

return config_loader