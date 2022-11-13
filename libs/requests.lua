local computer = computer
local component = component
local error = require('/lib/error.lua')
local filesystem = require('/lib/filesystem.lua')
local requests = {}

local internet = getComponentAddressSafe('internet')

local function getNetworkComponent()
    getComponentAddressSafe('internet')
end


function requests.get(page)
    if internet == nil then
        getNetworkComponent()
        if internet == nil then
            error.mild("Can't complete GET request, no internet component")
            return nil
        end
    end
    local response = component.invoke(internet, 'request', page)
    local body = ""
    for chunk in response do
      body = body .. chunk
    end
    return body
end

function requests.download(page, path, fileProxy)
    fileProxy.makeDirectory(filesystem.path(path))

	local fileHandle, reason = fileProxy.open(path, "wb")
	if fileHandle then
        local data = requests.get(page)
        if not data == "" then
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