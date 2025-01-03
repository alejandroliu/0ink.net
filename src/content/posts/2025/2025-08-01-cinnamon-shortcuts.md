---
title: Cinnamon Keyboard shortcuts
date: "2025-01-02"
author: alex
tags: desktop, windows, power, terminal, browser, network, manager
---
![Settings]({static}/images/2025/kbd-settings.png)


To familiarize with the [Cinnamon][cd] desktop, here is a list of its shortcuts:


Function | Category | Keys
---|----|----
Show the window selection screen | General | Ctrl+Alt+Down
Show the workspace selection screen | General | Ctrl+Alt+Up, Alt+F1, Super+Tab
Show desktop | General | Super+D
Show Desklets | General | Super+S
Cycle through open windows |General | Alt+Tab
Cycle backwards through open windows |General | Shift+Alt+Tab
Cycle through windows from all workspaces|General | Ctrl+Alt+Tab
Cycle backwards through windows from all workspaces |General | Ctrl+Shift+Alt+Tab
Run dialog | General | Alt+F2
Toggle Looking Glass | General:Troubleshooting | Ctrl+Alt+L *(Default: Super+L)*
Unmaximize window| Windows | Alt+F5
Close window| Windows | Alt+F4
Activate window menu| Windows | Alt+Space
Toggle maximization state| Windows | Alt+F10
Resize window | Windows:Positioning | Alt+F8
Move window | Windows:Positioning | Alt+F7
Push tile left| Windows:Tiling and Snapping | Super+Left
Push tile right| Windows:Tiling and Snapping | Super+Right
Push tile up| Windows:Tiling and Snapping | Super+Up
Push tile down| Windows:Tiling and Snapping | Super+Down
Move window to left workspace| Windows:Inter-workspace | Shift+Ctrl+Alt+Left
Move window to right workspace| Windows:Inter-workspace | Shift+Ctrl+Alt+Right
Move window to workspace above| Windows:Inter-workspace | Shift+Ctrl+Alt+Up
Move window to workspace below| Windows:Inter-workspace | Shift+Ctrl+Alt+Down
Move window to left monitor | Windows:Inter-monitor | Shift+Super+Left
Move window to right monitor | Windows:Inter-monitor | Shift+Super+Right
Move window to monitor above | Windows:Inter-monitor | Shift+Super+Up
Move window to monitor below | Windows:Inter-monitor | Shift+Super+Down
Switch to left workspace | Workspaces | Ctrl+Alt+Left
Switch to right workspace | Workspaces | Ctrl+Alt+Right
Log out | System | Ctrl+Alt+Delete
Shut down | System | Ctrl+Alt+End
Lock screen | System | Super+L, ==Screensaver== *(Default: Ctrl+Alt+L)*
Suspend | System | ==Sleep==
Hibernate | System | ==Suspend==
Restart Cinnamon | System | Ctrl+Alt+Escape
Switch monitor configurations | System:Hardware | Super+P, ==Display==
Rotate display | System:Hardware | ==RotateWindows==
Orientation Lock | System:Hardware | Super+O
Increase screen brightness | System:Hardware | ==MonitorBrignessUp==
Decrease screen brightness | System:Hardware | ==MonitorBrignessDown==
Toggle keyboard backlight | System:Hardware | ==KbdLightOnOff==
Increase keyboard backlight level | System:Hardware | ==KbdLightUp==
Decrease keyboard backlight level | System:Hardware | ==KbdLightDown==
Toggle touchpad state | System:Hardware | ==TouchpadToggle==
Turn touchpad on | System:Hardware | ==TouchpadOn==
Turn touchpad off | System:Hardware | ==TouchpadOff==
Show power statistics | System:Hardware | ==Battery==
Take a screenshot of an area | System:Screenshots and Recording | Shift+Print *not default*
Copy a screenshot of an area to clipboard | System:Screenshots and Recording | Ctrl+Print *not default*
Take a screenshot | System:Screenshots and Recording | Unassigned, *Default: Print*
Copy a screenshot to clipboard | System:Screenshots and Recording | Unassigned *Default: Ctrl+Print*
Take a screenshot of a window | System:Screenshots and Recording | Alt+Print
Copy a screenshot of a window to clipboard | System:Screenshots and Recording | Ctrl+Alt+Print
Toggle recording desktop | System:Screenshots and Recording | Shift+Ctrl+Alt+R
Launch terminal | Launchers |  Ctrl+Alt+T
Launch calculator | Launchers | ==Calculator==
Launch email client | Launchers | ==Mail==
Launch web browser  | Launchers | ==WWW==
Home folder | Launchers | Super+E, ==Explorer==
Search | Launchers | ==Search==
Volume mute | Sound and Media | ==AudioMute==
Volume down | Sound and Media | ==AudioLowerVolume==
Volume up | Sound and Media | ==AudioRaiseVolume==
Mic mute | Sound and Media | ==AudioMicMute==
Launch media player | Sound and Media | ==AudioMedia==
Play | Sound and Media | ==AudioPlay==
Pause playback | Sound and Media | ==AudioPause==
Stop playback | Sound and Media | ==AudioStop==
Previous track | Sound and Media | ==AudioPrev==
Next track | Sound and Media | ==AudioNext==
Eject | Sound and Media | ==Eject==
Rewind | Sound and Media | ==AudioRewind==
Fast-forward | Sound and Media | ==AudioFastForward==
Volume mute (Quiet) | Sound and Media:Quiet Keys | Alt+ ==AudioMute==
Volume down (Quiet) | Sound and Media:Quiet Keys | Alt+ ==AudioLowerVolume==
Volume up (Quiet) | Sound and Media:Quiet Keys | Alt+ ==AudioRaiseVolume==
Zoom in | Universal Access | Alt+Super+=
Zoom out | Universal Access | Alt+Super+-
Turn screen reader on or off | Universal Access | Alt+Super+S

Spices, these relate to the panel applets:


Function | Category | Keys
---|----|----
Show Calendar | Calendar | Super+C
Global hotkey or cycling through thumbnail menus | Grouped window list | *unassigned*
Global hotkey to show the order of apps  | Grouped window list | Super+\`
Keyboard shortcut to open and close the menu | Menu | Super
Show menu | Network Manager | Shift+Super+N
Show notifications | Notifications | Super+N	
Clear notifications | Notifications | Shift+Super+C
Show menu | Sound | Shift+Super+S



Unasigned functions

Function | Category
----|-----
Move pointer to the next monitor | General:Pointer
Move pointer to the previous monitor | General:Pointer
Maximize window | Windows |
Miminize window| Windows |
Raise window| Windows |
Lower window| Windows |
Toggle fullscreen state| Windows |
Toggle shaded state| Windows |
Toggle always on top| Windows |
Toggle showing window on all workspaces| Windows |
Increase opacity| Windows |
Decrease opacity| Windows |
Toggle vertical maximization| Windows |
Toggle horizontal maximization| Windows |
Center window in screen | Windows:Positioning | 
Move window to upper-right | Windows:Positioning |
Move window to upper-left | Windows:Positioning |
Move window to lower-right | Windows:Positioning |
Move window to lower-left | Windows:Positioning |
Move window to right edge | Windows:Positioning |
Move window to top edge | Windows:Positioning |
Move window to bottom edge  | Windows:Positioning |
Move window to left edge | Windows:Positioning |
Move window to new workspace | Windows:Inter-workspace
Move window to workspace 1-12 | Windows:Inter-workspace
Switch to workspace 1-12 | Workspaces:Direct Navigation
Launch help browser | Launchers | 
Repeat | Sound and Media | 
Shuffle | Sound and Media | 
Turn on-screen keyboard on or off | Universal Access | 
Increase text size | Universal Access | 
Decrease text size | Universal Access | 
High contrast on or off | Universal Access | 

My custom commands:

Function | Command | Keys
---|----|----
System Monitor | `gnome-system-monitor -r` | Ctrl+Alt+S
Switch Workspace | `wsswitch` | Ctrl+Escape
Find Dialog | `catfish` | Super+F
Run Dialog | `rundlg` | Super+R
Screenshot UI | `gnome-screenshot -i` | ==Print==
Show windows in All Workspaces | `rofi -show window` | Ctrl+\`
patoggle | `patoggle output` | Super+KP_Insert







  [cd]: https://github.com/linuxmint/cinnamon

