local computer

local error = require("error")

local requests = require("requests")
local config_loader = require("config_loader")
local filelib = require("filelib")

local install_lib = {}

function install_lib.update()
    error.mild("gonna update now!")
    local config = config_loader.from_text(filelib.load_file_text("/files/config.cfg", filesystemProxy))

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