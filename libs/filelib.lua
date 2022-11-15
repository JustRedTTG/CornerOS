local error = require("/lib/error.lua")
local filesystem = require("/lib/filesystem.lua")
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
	proxy.makeDirectory(filesystem.path(file))
	if not proxy then
		error.mild("filelib, proxy is nil")
		return nil
	end
	local handle, reason = proxy.open(file, "w")
	if handle then
		proxy.write(handle, data)
		proxy.close(handle)
	else
		error.major("File opening failed: " .. tostring(reason))
	end
end

function filelib.copy(old, new, proxy)
	proxy.makeDirectory(filesystem.path(new))

	local fileHandle, reason1 = proxy.open(old, "rb")
	local fileHandle2, reason2 = proxy.open(new, "wb")
	local chunk = ""
	if fileHandle and fileHandle2 then
		chunk = filesystemProxy.read(fileHandle, math.huge)
		filesystemProxy.write(fileHandle2, chunk or "")

		filesystemProxy.close(fileHandle)
		filesystemProxy.close(fileHandle2)
	else
		error.mild(tostring(reason) .. " ; " .. tostring(reason2), "File opening failed")
	end
end

function filelib.remove(file, proxy)
	proxy.remove(file)
end

function filelib.move(old, new, proxy)
	filelib.copy(old, new, proxy)
	filelib.remove(old)
end

return filelib