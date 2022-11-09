os.execute("clear")
os.execute("echo Flashing Corner OS")
os.execute("echo crude build reference: 44")
local branch = "debug"
os.execute("wget -fq https://corneros.pythonanywhere.com/"..branch.."/Installer/install.lua /corner.lua")
os.execute("wget -fq https://corneros.pythonanywhere.com/"..branch.."/BIOS/bios.lua /tmp/bios.lua && flash -q /tmp/bios.lua CornerOS && reboot")