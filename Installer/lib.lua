local computer

local error = require("error")

local requests = require("requests")
local config_loader = require("config_loader")
local filelib = require("filelib")

local install_lib = {}

function install_lib.update()
    local config = config_loader.from_text(filelib.load_file_text("/files/config.cfg", filesystemProxy))

    error.major(config.branch)

    computer.shutdown(true)
end

return install_lib