/*
------------------------------------------------------------------------

SendU module for detecting the deadkeys in current keyboard layout
http://www.autohotkey.com

------------------------------------------------------------------------

Version: 0.0.3 2008-05
License: GNU General Public License
Author: FARKAS Máté <http://fmate14.try.hu> (My given name is Máté)

Tested Platform:  Windows XP/Vista
Tested AutoHotkey Version: 1.0.47.04

------------------------------------------------------------------------

TODO: A better version without Send/Clipboard (I don't have idea)

------------------------------------------------------------------------

Why? In hungarian keyboard layout ~ is a dead key: 
	Send ~o ; is o with ~ accent
	Send ~ ; is nothing
	Send ~{Space} ; is ~ character
So... If I would like send ~, I must send ~{Space}. This script detect these characters

------------------------------------------------------------------------
*/

detectDeadKeysInCurrentLayout()
{
	DeadKeysInCurrentLayout = ;
	
	notepadMode = 0
	t := _detectDeadKeysInCurrentLayout_GetLocale( "MSGBOX_TITLE" )
	x := _detectDeadKeysInCurrentLayout_GetLocale( "MSGBOX" )
	MsgBox 51, %t%, %x%
	IfMsgBox Cancel
		return
	IfMsgBox Yes
	{
		notepadMode = 1
		Run Notepad
		Sleep 2000
		e := _detectDeadKeysInCurrentLayout_GetLocale( "EDITOR" )
		SendInput {Raw}%e%
		Send {Enter}
	} else {
		Send `n{Space}+{Home}{Del}
	}
	
	ord = 33
	Loop
	{
		clipboard = ;
		ch := chr( ord )
		Send {%ch%}{space}+{Left}^{Ins}
		ClipWait
		ifNotEqual clipboard, %A_Space%
			DeadKeysInCurrentLayout = %DeadKeysInCurrentLayout%%ch%
		++ord
		if ( ord >= 0x80 )
			break
	}
	Send {Ctrl Up}{Shift Up}
	Send +{Home}{Del}
	dk := _detectDeadKeysInCurrentLayout_GetLocale("DEADKEYS")
	Send {RAW}%dk%:%A_Space%
	Send {RAW}%DeadKeysInCurrentLayout%
	Send {Enter}
	
	lc := _detectDeadKeysInCurrentLayout_GetLocale("LAYOUT_CODE") 
	Send {Raw}%lc%:%A_Space%
	WinGet, WinID,, A
	ThreadID := DllCall("GetWindowThreadProcessId", "Int", WinID, "Int", 0)
	Layout := DllCall("GetKeyboardLayout", "Int", ThreadID) 
	Layout := ( Layout & 0xFFFF0000 )>>16
	Send %Layout%
	Send {Enter}
	
	If ( notepadMode )
		Send !{F4}
	
	return DeadKeysInCurrentLayout
}

detectDeadKeysInCurrentLayout_SetLocale( variable, value )
{
	_detectDeadKeysInCurrentLayout_GetLocale( variable, value, 1 )
}

_detectDeadKeysInCurrentLayout_GetLocale( variable, value = "", set = 0 )
{
	static lMSGBOX_TITLE := "Open Notepad?"
	static lMSGBOX := "To detect the deadkeys in your current keyboard layout,`nI need an editor.`n`nClick Yes to open the Notepad`nClick No if you already in an editor`nClick Cancel if you KNOW, your system doesn't have dead keys"
	static lEDITOR := "Detecting deadkeys... Do not interrupt!"
	static lDEADKEYS := "ASCII deadkeys"
	static lLAYOUT_CODE := "Layout code"
	
	if ( set == 1 )
		l%variable% := value
	return l%variable%
}
