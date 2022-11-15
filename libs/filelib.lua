local error = require("/lib/error.lua")

local filelib = {}

function filelib.load_file_text(file, proxy)
	if not proxy then
		error.mild("File Lib, proxy error")
		return ''
	end
	if not proxy.exists(file) then
		error.mild("File does not exist: " .. tostring(file))
		return ''
	end
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

function filelib.write_file_text(file, data, proxy)
	if not proxy then
		error.mild("File Lib, proxy error")
		return ''
	end
	local handle, reason = proxy.open(file, "w")
	if handle then
		handle.write(data)

		proxy.close(handle)
	else
		error.major("File opening failed: " .. tostring(reason))
	end
end

return filelib