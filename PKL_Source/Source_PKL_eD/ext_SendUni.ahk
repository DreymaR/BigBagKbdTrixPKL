/*
------------------------------------------------------------------------

SendU module for sending Unicode characters
http://www.autohotkey.com

------------------------------------------------------------------------

Version: 0.0.12 2008-05
License: GNU General Public License
Author: FARKAS, Máté <http://fmate14.try.hu/> (My given name is Máté)

Tested Platform:  Windows XP/Vista
Tested AutoHotkey Version: 1.0.47.04
Location in AutoHotkey forum: http://www.autohotkey.com/forum/viewtopic.php?t=25566

Contributors:
	* Laszlo Hars <www.Hars.US>
		original SendU function, _SendU_UnicodeChar function
		and some bugfixes
	* Shimanov
		original SendU function
	* Piz
		Fixed goto issues
		http://www.autohotkey.com/forum/viewtopic.php?p=182218#182218

------------------------------------------------------------------------

*/

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; You can localize the messages, see the
; SendU_SetLocaleTxt( variable, value ) and
;  _SendU_GetLocaleTxt( variable, value, 1 ) functions!

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; PUBLIC FUNCTIONS

SendCh( Ch ) ; Character number code, for example 97 (or 0x61) for 'a'
{
	Ch += 0
	if ( Ch < 0 ) {
		; What do you want???
		return
	} else if ( Ch < 33 ) {
		; http://en.wikipedia.org/wiki/Control_character#How_control_characters_map_to_keyboards
		Char = ;
		if ( Ch == 32 ) {
			Char = {Space}
		} else if ( Ch == 9 ) {
			Char = {Tab}
		} else if ( Ch > 0 && Ch <= 26 ) {
			Char := "^" . Chr( Ch + 64 )
		} else if ( Ch == 27 ) {
			Char = ^{VKDB}
		} else if ( Ch == 28 ) {
			Char = ^{VKDC}
		} else if ( Ch == 29 ) {
			Char = ^{VKDD}
		} else {
			SendU( Ch )
			return
		}
		Send %Char%
	} else if ( Ch < 129 ) {
		; ASCII characters
		Char := "{" . Chr( Ch ) . "}"
		Send %Char%
	} else {
		; Unicode characters
		SendU( Ch )
	}
}


SendU( UC )
{
	UC += 0
	if ( UC <= 0 )
		return
	mode := SendU_Mode()
	if ( mode = "d" ) { ; dynamic
		WinGet, pn, ProcessName, A
		mode := _SendU_Dynamic_Mode( pn )
	}
	
	if ( mode = "i" )
		_SendU_Input(UC)
	else if ( mode = "c" ) ; clipboard
		_SendU_Clipboard(UC)
	else if ( mode = "a" ) { ; {ASC nnnn}
		if ( UC < 256 )
			UC := "0" . UC
		Send {ASC %UC%}
	} else { ; input
		_SendU_Input(UC)
	}
}

SendU_utf8_string( str )
{
	mode := SendU_Mode()
	if ( mode = "d" ) { ; dynamic
		WinGet, pn, ProcessName, A
		mode := _SendU_Dynamic_Mode( pn )
	}
	
	if ( mode = "c" ) ; clipboard
		_SendU_Clipboard( str, 1 )
	else if ( mode = "a" ) { ; {ASC nnnn}
		codes := _SendU_Utf_To_Codes( str, "_" )
		Loop, parse, codes, _
		{
			UC := A_LoopField
			if ( UC < 256 )
				UC := "0" . UC
			Send {ASC %UC%}
		}
	} else {
		codes := _SendU_Utf_To_Codes( str, "_" )
		Loop, parse, codes, _
		{
			_SendU_Input(A_LoopField)
		}
	}
}

SendU_Mode( newMode = -1 )
{
	static mode := "d"
	if ( newmode == "d" || newMode == "i" || newmode == "a" || newmode == "c" )
		mode := newMode
	return mode
}

SendU_Clipboard_Restore_Mode( newMode = -1 )
{
	static mode := 1
	if ( newMode == 1 || newMode == 0 ) ; Enable, disable
		mode := newMode
	else if ( newMode == 2 ) ; Toggle
		mode := 1 - mode
	return mode
}

SendU_Try_Dynamic_Mode()
{
	WinGet, processName, ProcessName, A
	mode := _SendU_GetMode( processName )
	if ( mode == "i" )
		mode = c
	else if ( mode == "c" )
		mode = a
	else
		mode = i
	_SendU_Dynamic_Mode_Tooltip( processName, mode )
	SendU_SetMode( processName, mode )
	_SendU_Dynamic_Mode( "", 1 ) ; Clears the PrevProcess variable
}

SendU_SetLocaleTxt( variable, value )
{
	_SendU_GetLocaleTxt( variable, value, 1 )
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; PRIVATE FUNCTIONS


_SendU_Input( UC )
{
	; Original SendU function written by Shimanov and Laszlo
	; http://www.autohotkey.com/forum/topic7328.html
	static buffer := "#"
	if buffer = #
	{
		VarSetCapacity( buffer, 56, 0 )
		DllCall("RtlFillMemory", "uint",&buffer,"uint",1, "uint", 1)
		DllCall("RtlFillMemory", "uint",&buffer+28, "uint",1, "uint", 1)
	}
	DllCall("ntdll.dll\RtlFillMemoryUlong","uint",&buffer+6, "uint",4,"uint",0x40000|UC) ;KEYEVENTF_UNICODE
	DllCall("ntdll.dll\RtlFillMemoryUlong","uint",&buffer+34,"uint",4,"uint",0x60000|UC) ;KEYEVENTF_KEYUP|

	Suspend On ; SendInput conflicts with scan codes (SCxxx)!
	DllCall("SendInput", UInt,2, UInt,&buffer, Int,28)
	Suspend Off

	return
}

_SendU_Utf_To_Codes( utf8, separator = "," ) {
	; Return (comma) separated Unicode numbers of UTF-8 input STRING
	; Written by Laszlo Hars and FARKAS Mate (fmate14)
	static U := "#"
	static res
	if ( U == "#" ) {
		VarSetCapacity(U,   256 * 2)
		VarSetCapacity(res, 256 * 4)
	}
	DllCall("MultiByteToWideChar", UInt,65001, UInt,0, Str,utf8, Int,-1, UInt,&U, Int,256)
	res := ""
	pointer := &U
	Loop, 256
	{
		h := (*(pointer+1)<<8) + *(pointer)
		if ( h == 0 )
			break
		if ( res )
			res .= separator
		res .= h
		pointer += 2
	}
	Return res
}

; --------------------- functions for clipboard mode ----------------------------

_SendU_Clipboard( UC, isUtfString = 0 )
{
	Critical
	restoreMode := SendU_Clipboard_Restore_Mode()
	if ( isUtfString ) {
		utf := UC
	} else {
		utf := _SendU_UnicodeChar( UC )
	}
	if restoreMode
		_SendU_SaveClipboard()
	Transform Clipboard, Unicode, %utf%
	ClipWait
	SendInput ^v
	Sleep, 50 ; see http://www.autohotkey.com/forum/viewtopic.php?p=159301#159306
	if restoreMode {
		_SendU_Last_Char_In_Clipboard( Clipboard )
		SetTimer, _SendU_restore_Clipboard, -3000
	}
	Critical, Off
}

_SendU_RestoreClipboard()
{
	_SendU_SaveClipboard(1)
}

_SendU_SaveClipboard( restore = 0 )
{
	static cb
	if ( !restore && _SendU_Last_Char_In_Clipboard() == "" )
		cb := ClipboardALL
	else
		Clipboard := cb
}

_SendU_Last_Char_In_Clipboard( newChar = -1 )
{
	static ch := ""
	if ( newChar <> -1 )
		ch := newChar
	return ch
}

_SendU_UnicodeChar( UC )  ; Return the Utf-8 char from the Unicode numeric code (UC)
{ ; Written by Laszlo Hars
	VarSetCapacity(UText, 4, 0)
	NumPut(UC, UText, 0, "UShort")
	VarSetCapacity(AText, 4, 0)
	DllCall("WideCharToMultiByte"
		, "UInt", 65001  ; CodePage: CP_ACP=0 (current Ansi), CP_UTF7=65000, CP_UTF8=65001
		, "UInt", 0      ; dwFlags
		, "Str",  UText  ; LPCWSTR lpWideCharStr
		, "Int",  -1     ; cchWideChar: size in WCHAR values: Len or -1 (= null terminated)
		, "Str",  AText  ; LPSTR lpMultiByteStr
		, "Int",  4      ; cbMultiByte: Len or 0 (= get required size / allocate!)
		, "UInt", 0      ; LPCSTR lpDefaultChar
		, "UInt", 0)     ; LPBOOL lpUsedDefaultChar
	return %AText%
}

; --------------------- functions for dynamic mode ----------------------------

_SendU_Get_Mode_Name( mode )
{
	if ( mode == "c" && SendU_Clipboard_Restore_Mode() )
		mode = r
	m := _SendU_GetLocaleTxt( "Mode_Name_" . mode )
	if ( m == "" )
		m := _SendU_GetLocaleTxt( "Mode_Name_0" )
	return m
}

_SendU_Get_Mode_Type( mode )
{
	if ( mode == "c" && SendU_Clipboard_Restore_Mode() )
		mode = r
	m := _SendU_GetLocaleTxt( "Mode_Type_" . mode )
	if ( m == "" )
		m := _SendU_GetLocaleTxt( "Mode_Type_0" )
	return m
}

_SendU_Dynamic_Mode_Tooltip( processName = -1, mode = -1 )
{
	tt := _SendU_GetLocaleTxt("DYNAMIC_MODE_TOOLTIP")
	if not tt
		return
	if ( processName = -1 || mode == -1 ) {
		WinGet, processName, ProcessName, A
		mode := _SendU_GetMode( processName )
	}
	WinGetTitle, title, A
	StringReplace, tt,tt, $processName$, %processName%, A
	StringReplace, tt,tt, $title$, %title%, A
	StringReplace, tt,tt, $mode$, %mode%, A
	StringReplace, tt,tt, $modeType$, % _SendU_Get_Mode_Type( mode ), A
	StringReplace, tt,tt, $modeName$, % _SendU_Get_Mode_Name( mode ), A
	ToolTip, %tt%
	SetTimer, _SendU_Remove_Tooltip, 2000
}

_SendU_Dynamic_Mode( processName, clearPrevProcess = -1 )
{
	static prevProcess := "fOyj9b4f79YmA7sZRBrnDbp75dGhiauj" ; Nothing
	static mode := ""
	if ( clearPrevProcess == 1 )
		prevProcess := "fOyj9b4f79YmA7sZRBrnDbp75dGhiauj" ; Nothing
	if ( processName == prevProcess )
		return mode
	prevProcess := processName
	mode := _SendU_GetMode( processName )
	return mode
}

; --------------------- other functions ----------------------------


SendU_SetMode( processName, mode )
{
	return _SendU_GetMode( processName, mode, 1 )
}

_SendU_GetMode( processName, mode = "", set = 0 )
{
	static pdic := 0

	if ( pdic == 0 ) {
		pdic := HashTable_New()
		HashTable_Set( pdic,  "default", "i" )
	}

	if ( set == 1 ) {
		HashTable_Set( pdic, processName, mode )
	} else {
		result := HashTable_Get( pdic, processName )
		if ( result == "" )
			result := HashTable_Get( pdic, "default" )
		return result
	}
}

_SendU_GetLocaleTxt( sKey, sVal = "", set = 0 )
{
	static pdic := 0
	if ( pdic == 0 ) {
		pdic := HashTable_New()
		HashTable_Set( pdic, "DYNAMIC_MODE_TOOLTIP", "New mode for $processName$`n($title$)`nis ""$mode$"" ($modeName$ - $modeType$)")
		
		HashTable_Set( pdic, "Mode_Name_i", "SendInput")
		HashTable_Set( pdic, "Mode_Name_c", "Clipboard")
		HashTable_Set( pdic, "Mode_Name_r", "Restore Clipboard")
		HashTable_Set( pdic, "Mode_Name_a", "Alt+Numbers")
		HashTable_Set( pdic, "Mode_Name_d", "Dynamic")
		HashTable_Set( pdic, "Mode_Name_0", "Unknown")
		
		HashTable_Set( pdic, "Mode_Type_i", "the best, if works")
		HashTable_Set( pdic, "Mode_Type_c", "clears the clipboard")
		HashTable_Set( pdic, "Mode_Type_r", "maybe slow")
		HashTable_Set( pdic, "Mode_Type_a", "maybe not work")
		HashTable_Set( pdic, "Mode_Type_d", "dynamic mode for the programs")
		HashTable_Set( pdic, "Mode_Type_0", "unknown mode")
	}
	if ( set == 1 )
		HashTable_Set( pdic, sKey, sVal )
	else
		return HashTable_Get( pdic, sKey )
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; LABELS AND INCLUDES
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

__SendU_Labels_And_Includes__This_Is_Not_A_Function()
{
	return
	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; LABELS for internal use
	
	_SendU_Remove_Tooltip:
		SetTimer, _SendU_Remove_Tooltip, Off
		ToolTip
	return

	_SendU_Restore_Clipboard:
		Critical
		if ( _SendU_Last_Char_In_Clipboard() == Clipboard )
			_SendU_RestoreClipboard()
		_SendU_Last_Char_In_Clipboard( "" )
		Critical, Off
	return

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; LABELS for public use
	
	_SendU_Try_Dynamic_Mode:
	_SendU_Change_Dynamic_Mode:
		SendU_Try_Dynamic_Mode()
	return

	_SendU_Toggle_Clipboard_Restore_Mode:
		SendU_Clipboard_Restore_Mode( 2 )
		_SendU_Dynamic_Mode_Tooltip()
	return

}

#include ext_CoHelper.ahk ; eD: Renamed from CoHelper.ahk
#include ext_HashTable.ahk ; eD: Renamed from HashTable.ahk

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; END OF SENDU MODULE
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
