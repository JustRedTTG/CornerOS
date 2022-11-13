local computer = computer
local component = component
local error = require('/lib/error.lua')
local requests = {}

local internet = component.get('internet')

local function getNetworkComponent()
    internet = component.get('internet')
end


function requests.get(page)
    if internet == nil then
        error.mild("Can't complete GET request, no internet component")
        getNetworkComponent()
        return nil
    end
    local response = internet.request(page)
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
        local data = requests.get(page)
        if data then
		    fileProxy.write(fileHandle, data)
        else
            error.mild("Got no data from requests.get(page)")
        end

		fileProxy.close(fileHandle)
	else
		error.mild("File opening failed: " .. tostring(reason))
	end
end

return requests