local error = require('/lib/error.lua')
local filesystem = require('/lib/filesystem.lua')
local requests = {}

local internetAddr = nil
local internet = nil

local function getNetworkComponent()
    internetAddr = getComponentAddressSafe('internet')
    if internetAddr == nil then
      return nil
    end
    internet = getComponent(internetAddr)
end

getNetworkComponent()

local function rawRequest(page, postData, headers, chunkHandler, chunkSize, method)
	if internet == nil then
        getNetworkComponent()
        if internet == nil then
            error.mild("Can't complete GET request, no internet component")
            return nil
        end
    end
	local requestHandle, requestReason = internet.request(page, postData, headers, method)
	if requestHandle then
        while true do
            local chunk, reason = requestHandle.read(chunkSize or math.huge)

            if chunk then
                chunkHandler(chunk)
            else
                requestHandle:close()
                
                if reason then
                    return false, reason
                else
                    return true
                end
            end
        end
    else
        error.mild(requestReason or "Invalid URL-address")
        return nil
    end
end

function requests.request(page, postData, headers, mothod)
    local body = ""
	rawRequest(
		page,
		postData,
		headers,
		function(chunk)
			body = body .. chunk
		end,
		method
	)

	return body
end

function requests.download(page, path, fileProxy)
    fileProxy.makeDirectory(filesystem.path(path))

    local data = requests.request(page)
    if type(data) == nil or data == "" then
        error.mild("Got no data from requests.get(page)")
        return nil
    end
	local fileHandle, reason = fileProxy.open(path, "wb")
	if fileHandle then
        fileProxy.write(fileHandle, data)
		fileProxy.close(fileHandle)
	else
		error.mild("File opening failed: " .. tostring(reason))
	end
end

return requests
