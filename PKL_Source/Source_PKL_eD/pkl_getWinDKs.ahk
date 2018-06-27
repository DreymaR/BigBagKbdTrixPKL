; eD: Renamed this file from detectDeadKeysInCurrentLayout.ahk

/*
------------------------------------------------------------------------

Get the deadkeys of the active layout

Version: 0.0.2 2008-06
License: GNU General Public License
Author: FARKAS Máté <http://fmate14.try.hu> (My given name is Máté)

Tested Platform:  Windows XP/Vista
Tested AutoHotkey Version: 1.0.47.04

------------------------------------------------------------------------

Why? In hungarian keyboard layout ^ is a dead key: 
	Send ^o         ; is o with ^ accent
	Send ^          ; is nothing
	Send ^{Space}   ; is the ^ character
So... If I want to send ^, I must send ^{Space}.

------------------------------------------------------------------------
*/

getWinLocaleID() ; eD: This was in the detect/get functions
{
	WinGet, WinID,, A
	WinThreadID := DllCall("GetWindowThreadProcessId", "Int", WinID, "Int", 0)
	WinLocaleID := DllCall("GetKeyboardLayout", "Int", WinThreadID)
	WinLocaleID := ( WinLocaleID & 0xFFFFFFFF )>>16
	return WinLocaleID
}

/*
------------------------------------------------------------------------

Module for detecting the deadkeys in current keyboard layout

Version: 0.0.3 2008-05
License: GNU General Public License
Author: FARKAS Máté <http://fmate14.try.hu> (My given name is Máté)

Tested Platform:  Windows XP/Vista
Tested AutoHotkey Version: 1.0.47.04

TODO: A better version without Send/Clipboard (I don't have any ideas)

------------------------------------------------------------------------
*/

detectDeadKeysInCurrentLayout()
{
	DeadKeysInCurrentLayout = ;
	
	notepadMode = 0
	txt := getPklInfo( "DetecDK_" .  "MSGBOX_TITLE" )
	tx2 := getPklInfo( "DetecDK_" .  "MSGBOX" )
	MsgBox 51, %txt%, %tx2%
	IfMsgBox Cancel
		return
	IfMsgBox Yes
	{
		notepadMode = 1
		Run Notepad
		Sleep 2000
		txt := getPklInfo( "DetecDK_" .  "EDITOR" )
		SendInput {Raw}%txt%
		Send {Enter}
	} else {
		Send `n{Space}+{Home}{Del}
	}
	
	ord = 33
	; eD TODO: Detect AltGr+key hotkeys as well?! But then we'd have to send keys and not just characters.
	Loop
	{
		clipboard = ;
		cha := Chr( ord )
		Send {%cha%}{space}+{Left}^{Ins}
		ClipWait
		ifNotEqual clipboard, %A_Space%
			DeadKeysInCurrentLayout = %DeadKeysInCurrentLayout%%ch%
		++ord
		if ( ord >= 0x80 )
			break
	}
	Send {Ctrl Up}{Shift Up}
	Send +{Home}{Del}
	txt := getPklInfo( "DetecDK_" . "DEADKEYS" )
	Send {RAW}%txt%:%A_Space%
	Send {RAW}%DeadKeysInCurrentLayout%
	Send {Enter}
	
	txt := getPklInfo( "DetecDK_" . "LAYOUT_CODE" )
	Send {Raw}%txt%:%A_Space%
	WinLayoutID := getWinLocaleID() ; eD
	Send %WinLayoutID%
	Send {Enter}
	
	if ( notepadMode )
		Send !{F4}
		Send {Right}				; Select "Don't save"
	
	return DeadKeysInCurrentLayout
}
