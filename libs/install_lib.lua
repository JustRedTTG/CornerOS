local computer = computer

local error = require("/lib/error.lua")

local requests = require("/lib/requests.lua")
local filesystem = require("/lib/filesystem.lua")
local config_loader = require("/lib/config_loader.lua")
local screen = require("/lib/screen.lua")
local filelib = require("/lib/filelib.lua")

local proxy = filesystem.getRoot()

local install_lib = {}

function install_lib.update(update_config)
    local branch = update_config.branch
    requests.download("https://raw.githubusercontent.com/JustRedTTG/CornerOS/"..branch.."/full_config.cfg", "/config.cfg", proxy)
    local config = config_loader.from_text(filelib.load_file_text("/files/config.cfg", proxy))

    screen.background(config.mainColors.background, config.mainColors.backgroundUpper, config.mainColors.backgroundMidrange, config)
    screen.progress(0, config)
    screen.status("Update, please wait", config.mainColors.text)

    -- Install files
    requests.download("https://raw.githubusercontent.com/JustRedTTG/CornerOS/"..branch.."/libs/install_lib.lua", "/lib/install_lib.lua", proxy)
    error.okay("Everything is good!")

    config.update = 0

    filelib.write_file_text("/files/update.cfg", config_loader.to_text(config), proxy)

    computer.shutdown(true)
end

function install_lib.check()
    local update_config = config_loader.from_text(filelib.load_file_text("/files/update.cfg", proxy))
    if update_config.update == 1 then
        install_lib.update(update_config)
    end
end

return install_lib