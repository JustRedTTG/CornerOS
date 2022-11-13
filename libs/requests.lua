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

	local fileHandle, reason = fileProxy.open(page, "wb")
	if fileHandle then
		rawRequest(url, function(chunk)
			fileProxy.write(fileHandle, chunk)
		end)

		fileProxy.close(fileHandle)
	else
		error.mild("File opening failed: " .. tostring(reason))
	end
end

return requests