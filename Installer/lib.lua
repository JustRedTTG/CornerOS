local computer

local error = require("/lib/error.lua")

local requests = require("/lib/requests.lua")
local filesystem = require("/lib/filesystem.lua")
local config_loader = require("/lib/config_loader.lua")
local screen = require("/files/install_screen.lua")
local filelib = require("/lib/filelib.lua")

local proxy = filesystem.getRoot()

local install_lib = {}

function install_lib.check()
    local config = config_loader.from_text(filelib.load_file_text("/files/config.cfg", proxy))

    local branch = config.branch
    screen.status("Installer is being downloaded.", 0x00FF00)

    -- Install the full installer
    requests.download("https://raw.githubusercontent.com/JustRedTTG/CornerOS/"..branch.."/libs/install_lib.lua", "/lib/install_lib.lua", proxy)
    requests.download("https://raw.githubusercontent.com/JustRedTTG/CornerOS/"..branch.."/full_config.cfg", "/config.cfg", proxy)

    computer.shutdown(true)
end


return install_lib