local computer = computer
local component = component
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

function requests.get(page)
    if internet == nil then
        getNetworkComponent()
        if internet == nil then
            error.mild("Can't complete GET request, no internet component")
            return nil
        end
    end
    local response = internet.request(page)
    local body = ""
    for chunk in response do
      body = body .. chunk
    end
    return body
end

function requests.download(page, path, fileProxy)
    fileProxy.makeDirectory(filesystem.path(path))

    local data = requests.get(page)
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
