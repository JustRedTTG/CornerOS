local computer = computer

local error = require("/lib/error.lua")

local requests = require("/lib/requests.lua")
local filesystem = require("/lib/filesystem.lua")
local screen = require("/files/install_screen.lua")
local filelib = require("/lib/filelib.lua")

local proxy = filesystem.getRoot()

local install_lib = {}
local url = "https://raw.githubusercontent.com/JustRedTTG/CornerOS/"

local function from_text(text)
	local result, reason = load("return " .. text, "=string")
	if result then
		return result()
	else
		error.major(reason)
	end
end

function install_lib.check()
    local config = from_text(filelib.load_file_text("/files/config.cfg", proxy))

    local branch = config.branch
    screen.status("Installer is being downloaded.", 0x00FF00)

    -- Install the full installer
    requests.download(url..branch.."/libs/config_loader.lua", "/lib/config_loader.lua", proxy)
    requests.download(url..branch.."/libs/install_lib.lua", "/lib/install_lib.lua", proxy)
    requests.download(url..branch.."/libs/screen.lua", "/lib/screen.lua", proxy)
    requests.download(url..branch.."/full_config.cfg", "/config.cfg", proxy)

    computer.shutdown(true)
end


return install_lib