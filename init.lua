os.execute("rm /corner.lua")
os.execute("wget -f https://raw.githubusercontent.com/JustRedTTG/CornerOS/main/Installer/install.lua /corner.lua")
os.execute("wget -f https://raw.githubusercontent.com/JustRedTTG/CornerOS/main/BIOS/bios.lua /tmp/bios.lua && flash -q /tmp/bios.lua CornerOS && reboot")