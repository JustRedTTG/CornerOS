os.execute("clear")
os.execute("echo Flashing Corner OS")
os.execute("echo crude build reference: 6")
os.execute("rm /corner.lua")
os.execute("wget -f https://raw.githubusercontent.com/JustRedTTG/CornerOS/main/Installer/install.lua /corner.lua")
os.execute("wget -f https://raw.githubusercontent.com/JustRedTTG/CornerOS/main/BIOS/bios.lua /tmp/bios.lua && flash -q /tmp/bios.lua CornerOS && reboot")