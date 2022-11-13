local computer = computer

local corner = {}

local error = require("/lib/error.lua")

function corner.load()
    error.mild("gonna load now!")

    computer.shutdown()
end

return corner