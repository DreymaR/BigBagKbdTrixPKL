;
; AutoHotkey Version: 1.x
; Language:       English
; Platform:       Win9x/NT
; Author:         A.N.Other <myemail@nowhere.com>
;
; Script Function:
;	Template script (you can customize this template by editing "ShellNew\Template.ahk" in your Windows folder)
;

#SingleInstance	; Replace on rerun
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

; EXAMPLE #4: This is a working script that adds icons to its menu items.
Menu, TestMenu, Add, Script Icon , MenuHandler
Menu, TestMenu, Add, Suspend Icon, MenuHandler
Menu, TestMenu, Add, Pause Icon  , MenuHandler
Menu, TestMenu, Add, Test Icon   , MenuHandler
; eD: The icons for a non-Tray menu couldn't be loaded with AHK 1.0.48, but with AHK 1.1
;if ( A_AhkVersion >= "1.1." )
{
	Menu, TestMenu, Icon, Script Icon , %A_AhkPath%,    2	;Use the 2nd icon group from the file
	Menu, TestMenu, Icon, Suspend Icon, %A_AhkPath%, -206	;Use icon with resource identifier 206
	Menu, TestMenu, Icon, Pause Icon  , %A_AhkPath%, -207	;Use icon with resource identifier 207
	Menu, TestMenu, Icon, Test Icon   , shell32.dll,  220	;Use the 2nd icon group from the file
}
Menu, MyMenuBar, Add, &File, :TestMenu
Gui, Menu, MyMenuBar

;icoPath = C:\Windows\System32\shell32.dll
; eD: The icons couldn't be loaded with AHK 1.0.48, but with AHK 1.1
Menu, Tray, Icon, shell32.dll, 40						; Change tray icon
Menu, Tray, Add, 										; Separator line
Menu, Tray, Add,  TestItem   , MenuHandler				
Menu, Tray, Icon, TestItem   , shell32.dll, 222			; Test tray menu item icon
Menu, Tray, Add,  &TestMenu  , :TestMenu				; Test tray submenu icons

Gui, Add, Button, gExit, Thanks for visiting!
Gui, Show

MenuHandler:
Return

Exit:
ExitApp
