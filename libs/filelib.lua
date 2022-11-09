local component = component

error = require("/lib/error.lua")

local filelib = {}

function filelib.load_file_text(file, proxy)
    local handle, reason = proxy.open(file, "r")
		if handle then
			local data, chunk = "", nil
			repeat
				chunk = proxy.read(handle, math.huge)
				data = data .. (chunk or "")
			until not chunk

			proxy.close(handle)

            return data
		else
			error.major("File opening failed: " .. tostring(reason))
		end
end

return filelib