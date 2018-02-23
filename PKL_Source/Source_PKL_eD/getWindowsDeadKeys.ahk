; eD: Renamed this file from detectDeadKeysInCurrentLayout.ahk, and moved getDeadKeysOfSystemsActiveLayout.ahk into it.

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

getDeadKeysOfSystemsActiveLayout()
{
	; Some default locale dead key strings are defined here
	lid1033 = -1        ; USA
	lid1038 = ^         ; Hungarian
	lid1036 = ^`~       ; French AZERTY
	lid1044 = ¨´^`~     ; Norwegian Bm
	lid2068 = ¨´^`~     ; Norwegian Nn
	
/*
; eD TODO: Overwrite the hardcoded localeID values with a [osdeadkeys] section in my PKL_eD.ini
; eD TODO: Figure out encoding for non-ANSI accents (see vVv's iniReadUtf8!)
;lid := {} ; eD: Use an associative AHK array for (key,value) pairs?
	global gP_Pkl_eD__File	; eD: My "pkl.ini"
	inisec := iniReadSection( gP_Pkl_eD__File, "osdeadkeys" )
	Loop, parse, inisec, `r`n
	{
		pos := InStr( A_LoopField, "=" )
		key := Trim( SubStr( A_LoopField, 1, pos-1 ))
		val := Trim( SubStr( A_LoopField, pos+1 ))
		lid%key% = %val%
	}
MsgBox, DebugTest: US='%lid1033% No(Nn)='%lid2068%'
*/
	
	WinLayoutID := getWinLocaleID() ; eD
	if ( lid%WinLayoutID% == "-1" || lid%WinLayoutID% == "" )
		return ""
	else
		return lid%WinLayoutID%
}


/*
------------------------------------------------------------------------

SendU module for detecting the deadkeys in current keyboard layout

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
	txt := _detectDeadKeys_GetLocaleTxt( "MSGBOX_TITLE" )
	tx2 := _detectDeadKeys_GetLocaleTxt( "MSGBOX" )
	MsgBox 51, %txt%, %tx2%
	IfMsgBox Cancel
		return
	IfMsgBox Yes
	{
		notepadMode = 1
		Run Notepad
		Sleep 2000
		txt := _detectDeadKeys_GetLocaleTxt( "EDITOR" )
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
	txt := _detectDeadKeys_GetLocaleTxt("DEADKEYS")
	Send {RAW}%txt%:%A_Space%
	Send {RAW}%DeadKeysInCurrentLayout%
	Send {Enter}
	
	txt := _detectDeadKeys_GetLocaleTxt("LAYOUT_CODE")
	Send {Raw}%txt%:%A_Space%
	WinLayoutID := getWinLocaleID() ; eD
	Send %WinLayoutID%
	Send {Enter}
	
	If ( notepadMode )
		Send !{F4}
	
	return DeadKeysInCurrentLayout
}

detectDeadKeys_SetLocaleTxt( variable, value )
{
	_detectDeadKeys_GetLocaleTxt( variable, value, 1 )
}

_detectDeadKeys_GetLocaleTxt( variable, value = "", set = 0 )
{
	static locMSGBOX_TITLE := "Open Notepad?"
	static locMSGBOX := "To detect the deadkeys in the current default OS keyboard layout,`nPKL needs an editor.`n`nClick Yes to open Notepad`nClick No if you are already in an editor`nClick Cancel if you KNOW your system doesn't have dead keys"
	static locEDITOR := "Detecting deadkeys... Do not interrupt!"
	static locDEADKEYS := "ASCII deadkeys"
	static locLAYOUT_CODE := "Layout code"
	
	if ( set == 1 )
		loc%variable% := value
	return loc%variable%
}
