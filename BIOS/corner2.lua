local computer = computer

local corner = {}

-- Libs
local error = require("/lib/error.lua")
local screen
local config_loader
local filelib
local filesystem

-- Vars
local config
local filesystemProxy

function corner.import()
    screen = require("/lib/screen.lua")
    config_loader = require("/lib/config_loader.lua")
    filelib = require("/lib/filelib.lua")
    filesystem = require("/lib/filesystem.lua")
end

function corner.setup()
    filesystemProxy = filesystem.getRoot()
    config = config_loader.from_text(filelib.read_file_text("/config.cfg", filesystemProxy))
end

function corner.load()
    corner.import()
    corner.setup()
    screen.background(config.mainColors.background, config.mainColors.backgroundUpper, config.mainColors.backgroundMidrange, config)
    screen.centeredBox(config.mainColors.guiLower, config.mainColors.guiUpper, config.mainColors.guiMidrange, screen.screenWidth * .5, screen.screenHeight * .5, config)
    while computer.pullSignal() do
        
    end
    computer.shutdown()
end

return corner