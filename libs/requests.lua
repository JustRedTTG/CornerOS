local computer = computer
local component = component
local error = require('/lib/error.lua')
local requests = {}

local internet = getComponentAddressSafe('internet')

if not internet == nil then
    internet = component.get(internet)
end

local function getNetworkComponent()
    internet = getComponentAddressSafe('internet')
    if not internet == nil then
        internet = component.get(internet)
    end
end


function requests.get(page)
    if internet == nil then
        error.mild("Can't complete GET request, no internet component")
        getNetworkComponent()
        return nil
    end
    local response = inet.request(page)
    local body = ""
    for chunk in response do
      body = body .. chunk
    end
    return body
end

function requests.download(page, path, fileProxy)
    fileProxy.makeDirectory(path)

	local fileHandle, reason = fileProxy.open(path, "wb")
	if fileHandle then
		fileProxy.write(fileHandle, requests.get(page))

		fileProxy.close(fileHandle)
	else
		error.mild("File opening failed: " .. tostring(reason))
	end
end

return requests