os.execute("clear")
os.execute("echo Flashing Corner OS")
os.execute("echo crude build reference: 55")
local branch = "debug"
os.execute("wget -fq https://raw.githubusercontent.com/JustRedTTG/CornerOS/"..branch.."/Installer/install.lua /corner.lua")
os.execute("wget -fq https://raw.githubusercontent.com/JustRedTTG/CornerOS/"..branch.."/BIOS/bios.lua /tmp/bios.lua && flash -q /tmp/bios.lua CornerOS && reboot")