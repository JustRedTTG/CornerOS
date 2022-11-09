local computer

local error = require("/lib/error.lua")

local requests = require("/lib/requests.lua")
local filesystem = require("/lib/filesystem.lua")
local config_loader = require("/lib/config_loader.lua")
local filelib = require("/lib/filelib.lua")

local install_lib = {}

function install_lib.update()
    error.mild("gonna update now!")
    local config = config_loader.from_text(filelib.load_file_text("/files/config.cfg", filesystem.root))

    error.major(config.branch)
    -- display the branch

    computer.shutdown(true)
end

function install_lib.check()
    local update = filelib.load_file_text("/files/update.txt")
    if update == 'true' then
        install_lib.update()
    end
end

return install_lib