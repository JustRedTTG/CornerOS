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
    config_loader = require("/lib/screen.lua")
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
    screen.box(0x000000, 0xFFFFFF, 0xFF0000, 2, 2, 5, 10, config)
    while computer.pullSignal() do
        
    end
    computer.shutdown()
end

return corner