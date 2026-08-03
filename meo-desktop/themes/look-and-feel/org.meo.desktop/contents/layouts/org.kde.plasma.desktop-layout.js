var shelf = new Panel
shelf.location = "bottom"
shelf.height = 64
shelf.floating = true
shelf.hiding = "normal"

var launcher = shelf.addWidget("org.kde.plasma.kickoff")
launcher.currentConfigGroup = ["/Configuration/General"]
launcher.writeConfig("icon", "start-here-kde")

var tasks = shelf.addWidget("org.kde.plasma.icontasks")
tasks.currentConfigGroup = ["/Configuration/General"]
tasks.writeConfig("launchers", [
    "applications:org.kde.dolphin.desktop",
    "applications:org.kde.konsole.desktop"
])
tasks.writeConfig("showOnlyCurrentDesktop", "false")
tasks.writeConfig("showOnlyCurrentActivity", "false")

shelf.addWidget("org.kde.plasma.marginsseparator")
shelf.addWidget("org.kde.plasma.systemtray")
shelf.addWidget("org.kde.plasma.digitalclock")

var existingDesktops = desktopsForActivity(currentActivity())
for (var i = 0; i < existingDesktops.length; ++i) {
    existingDesktops[i].wallpaperPlugin = "org.kde.image"
    existingDesktops[i].currentConfigGroup = ["/Wallpaper/org.kde.image/General"]
    existingDesktops[i].writeConfig("Image", "file:///usr/share/wallpapers/MeoArch/installer_background.png")
    existingDesktops[i].writeConfig("FillMode", "2")
}
