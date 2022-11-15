local computer = computer

local error = require("/lib/error.lua")

local requests = require("/lib/requests.lua")
local filesystem = require("/lib/filesystem.lua")
local config_loader = require("/lib/config_loader.lua")
local screen = require("/lib/screen.lua")
local filelib = require("/lib/filelib.lua")

local proxy = filesystem.getRoot()

local install_lib = {}
local url = "https://raw.githubusercontent.com/JustRedTTG/CornerOS/"

function install_lib.update(update_config, installDir)
    local branch = update_config.branch
    requests.download(url..branch.."/full_config.cfg", "/config.cfg", proxy)
    local config = config_loader.from_text(filelib.load_file_text("/files/config.cfg", proxy))

    screen.background(config.mainColors.background, config.mainColors.backgroundUpper, config.mainColors.backgroundMidrange, config)
    screen.progress(0, config)
    screen.status("Update, please wait", config.mainColors.text)

    -- Download required libs
    screen.background(config.mainColors.background, config.mainColors.backgroundUpper, config.mainColors.backgroundMidrange, config)
    screen.status("Downloading Required Libraries...", config.mainColors.text)
    for i = 1, #config.install_required_libs do
        screen.progress(i / #config.install_required_libs, config)
        requests.download(url..branch.."/libs/" .. config.install_required_libs[i], installerDir .. "/lib/" .. config.install_required_libs[i], proxy)
    end

    -- Download libs
    screen.background(config.mainColors.background, config.mainColors.backgroundUpper, config.mainColors.backgroundMidrange, config)
    screen.status("Downloading Libraries...", config.mainColors.text)
    for i = 1, #config.libs do
        screen.progress(i / #config.libs, config)
        requests.download(url..branch.."/libs/" .. config.libs[i], installerDir .. "/lib/" .. config.libs[i], proxy)
    end

    -- Download bios/boot
    screen.background(config.mainColors.background, config.mainColors.backgroundUpper, config.mainColors.backgroundMidrange, config)
    screen.status("Downloading Boot...", config.mainColors.text)
    for i = 1, #config.bios do
        screen.progress(i / #config.bios, config)
        requests.download(url..branch.."/BIOS/" .. config.bios[i], installerDir .. "/boot/" .. config.bios[i], proxy)
    end

    -- Download files
    screen.background(config.mainColors.background, config.mainColors.backgroundUpper, config.mainColors.backgroundMidrange, config)
    screen.status("Downloading Files...", config.mainColors.text)
    for i = 1, #config.files do
        screen.progress(i / #config.files, config)
        requests.download(url..branch.. config.files[i], installerDir .. "/files/" .. config.files_names[i], proxy)
    end

    local totalI = #config.install_required_libs + #config.libs + #config.bios + #config.files
    local currentI = 0

    -- Install CornerOS
    screen.background(config.mainColors.background, config.mainColors.backgroundUpper, config.mainColors.backgroundMidrange, config)
    screen.status("Installing CornerOS!", config.mainColors.text)

    -- Install required libs
    for i = 1, #config.install_required_libs do
        screen.progress(currentI+i / totalI, config)
        filelib.copy(installerDir .. "/lib/" .. config.install_required_libs[i], installDir .. "/lib/" .. config.install_required_libs[i], proxy)
    end
    currentI = currentI + #config.install_required_libs

    -- Install libs
    for i = 1, #config.libs do
        screen.progress(currentI+i / totalI, config)
        filelib.copy(installerDir .. "/lib/" .. config.libs[i], installDir .. "/lib/" .. config.libs[i], proxy)
    end
    currentI = currentI + #config.libs

    -- Install bios/boot
    for i = 1, #config.bios do
        screen.progress(currentI+i / totalI, config)
        filelib.copy(installerDir .. "/boot/" .. config.bios[i], installDir .. config.bios[i], proxy)
    end
    currentI = currentI + #config.bios

    -- Install files
    for i = 1, #config.files do
        screen.progress(currentI+i / totalI, config)
        filelib.copy(installerDir .. "/files/" .. config.files_names[i], installDir .. config.files_names[i], proxy)
    end
    


    -- update_config.update = 0

    -- filelib.write_file_text("/files/update.cfg", config_loader.to_text(update_config), proxy)

    -- computer.shutdown(true)
end

function install_lib.check()
    local update_config = config_loader.from_text(filelib.load_file_text("/files/update.cfg", proxy))
    if update_config.update == 1 then
        install_lib.update(update_config, "")
    end
end

return install_lib