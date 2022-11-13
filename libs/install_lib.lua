local computer

local error = require("/lib/error.lua")

local requests = require("/lib/requests.lua")
local filesystem = require("/lib/filesystem.lua")
local config_loader = require("/lib/config_loader.lua")
local screen = require("/files/install_screen.lua")
local filelib = require("/lib/filelib.lua")

local proxy = filesystem.getRoot()

local install_lib = {}

function install_lib.update()
    local config = config_loader.from_text(filelib.load_file_text("/files/config.cfg", proxy))

    branch = config.branch

    screen.background(config.mainColors.background, config.mainColors.backgroundUpper, config.mainColors.backgroundMidrange, config)
    screen.progress(0, config)
    screen.status("Update, please wait", config.mainColors.text)

    -- Install files
    requests.download("https://raw.githubusercontent.com/JustRedTTG/CornerOS/"..branch.."/libs/install_lib.lua", "/lib/install_lib.lua")
    requests.download("https://raw.githubusercontent.com/JustRedTTG/CornerOS/"..branch.."/full_config.cfg", "/config.cfg")
    error.mild("Everything is good!")
    computer.shutdown(true)
end

function install_lib.check()
    if tostring(filelib.load_file_text("/files/update.txt", proxy)) == 'true' then
        install_lib.update()
    end
end

return install_lib