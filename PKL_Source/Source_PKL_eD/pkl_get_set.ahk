;-------------------------------------------------------------------------------------
;
; PKL get/set module
;     Handles associative dictionaries for PKL info; usable instead of globals
;
/*
	LayoutInfo entries:
	-------------------
	active         := "" ; The active layout
	dir            := "" ; The directory of the active layout
	hasAltGr       := 0  ; Should Right Alt work as AltGr in the layout?
	extendKey      := "" ; Extend modifier for navigation, editing, etc.
	
	nextLayout     := "" ; If you set multiple layouts, this is the next one.
	                     ; see the "changeActiveLayout:" label!
	numOfLayouts := 0  ; Array size
	LayoutsXcode         ; layout code
	LayoutsXname         ; layout name
	Ico_On_File          ; Icon for On  (file)
	Ico_On_Num_          ; --"--        (# in file)
	Ico_OffFile          ; Icon for Off (file)
	Ico_OffNum_          ; --"--        (# in file)
*/
	
setKeyInfo( key, value )
{
	return getKeyInfo( key, value, 1 )
}

setLayInfo( var, val )
{
	return getLayInfo( var, val, 1 )
}

setPklInfo( key, value )
{
	getPklInfo( key, value, 1 )
}

getKeyInfo( key, value = "", set = 0 )
{
	static pdic     := {}
	if ( set == 1 )
		pdic[key]   := value
	else
		return pdic[key]
}

getLayInfo( key, value = "", set = 0 )
{
	static pdic     := {}
	if ( set == 1 )
		pdic[key]   := value
	else
		return pdic[key]
}

getPklInfo( key, value = "", set = 0 )
{
	static pdic     := {}
	if ( set == 1 )
		pdic[key]   := value
	else
		return pdic[key]
}

;-------------------------------------------------------------------------------------
;
; PKL locale module
;     Functions to set up locale strings
;     Used by _initReadPklIni() in pkl_init.ahk
;

pkl_locale_load( lang, compact = 0 )
{
	static initialized := 0	; Ensure the defaults are read only once (as this function is run on layout change too)	; eD TODO: Is this working?
	if ( initialized == 0 )
	{																	; eD: Read/set default locale string list
		Loop, 22														; Read default locale strings (numbered)
		{
			str := pklIniRead( "LocStr" . SubStr( "00" . A_Index, -1 ), "", "Pkl_Dic", "DefaultLocaleStr" ) ; eD: Pad with zero if index < 10
			str := strEsc( str )										; Replace \n and \\ escapes
			setPklInfo( "LocStr_" . A_Index , str )
		}
		sect := iniReadSection( getPklInfo( "File_Pkl_Dic" ), "DefaultLocaleTxt" )	; Read default locale strings (key/value)
		Loop, Parse, sect, `r`n
		{
			pklIniKeyVal( A_Loopfield, key, val, 1 )					; Extraction with \n escape replacement
			setPklInfo( key, val )
		}
		initialized := 1
	}
	
	setPklInfo( "LocStr_RefreshMenu", pklIniRead( "refreshMenuText", "Refresh"       ,, "eD" ) )
	setPklInfo( "LocStr_KeyHistMenu", pklIniRead( "keyhistMenuText", "Key history...",, "eD" ) )
	setPklInfo( "LocStr_MakeImgMenu", pklIniRead( "makeimgMenuText", "Make help images...", pklIniRead( "imgGenIniFile",,, "eD" ) ) )
	
	if ( compact )
		file = %lang%.ini
	else
		file = Languages\%lang%.ini
	
	if ( not FileExist( file ) )					; If the language file isn't found, we'll just use the defaults
		return
	sect := iniReadSection( file, "pkl" )
	Loop, Parse, sect, `r`n
	{
		pklIniKeyVal( A_Loopfield, key, val, 1 )	; eD: A more compact way than before (but still in a loop)
		if ( val != "" )
			setPklInfo( "LocStr_" . key , val )		; pklLocaleStrings( key, val, 1 )
	}

	sect := iniReadSection( file, "detectDeadKeys" )
	Loop, Parse, sect, `r`n
	{
		pklIniKeyVal( A_Loopfield, key, val, 1 )
		setPklInfo( "DetecDK_" . key, val )			; detectDeadKeys_SetLocaleTxt(
	}
	
	sect := iniReadSection( file, "keyNames" )
	Loop, Parse, sect, `r`n
	{
		pklIniKeyVal( A_Loopfield, key, val, 0 )
		_setHotkeyText( key, val )
	}
}

_setHotkeyText( hk, localehk )
{
	_getHotkeyText( hk, localehk, 1 )
}

_getHotkeyText( hk, localehk = "", set = 0 )
{
	static localizedHotkeys := ""
	
	if ( set == 1 ) {
		setKeyInfo( "HKtxt_" . hk, localehk )
		localizedHotkeys .= " " . hk
	} else {
		if ( hk == "all" )
			return localizedHotkeys
		return getKeyInfo( "HKtxt_" . hk )
	}
}

getReadableHotkeyString( str )		; Replace hard-to-read, hard-to-print parts of hotkey names
{
	strDic := {                   "<^>!"  : "AltGr & "
		, "<+"    : "LShift & " , "<^"    : "LCtrl & " , "<!"    : "LAlt & " , "<#"    : "LWin & "
		, ">+"    : "RShift & " , ">^"    : "RCtrl & " , ">!"    : "RAlt & " , ">#"    : "RWin & "
		,  "+"    :  "Shift & " ,  "^"    :  "Ctrl & " ,  "!"    :  "Alt & " ,  "#"    :  "Win & "
		, "SC029" : "Tilde"     ,  "*"    : ""         ,  "$"    : ""        ,  "~"    : "" }
	for key, val in strDic
		str := StrReplace( str, key, val )

	str := RegExReplace( str, "(\w+)", "#[$1]" )
	hotkeys := _getHotkeyText( "all" )
	Loop, Parse, hotkeys, %A_Space%
	{
;		lhk := _getHotkeyText( A_LoopField )
		str := StrReplace( str, "#[" . A_LoopField . "]", _getHotkeyText( A_LoopField ) )	;StringReplace, str, str, #[%A_LoopField%], %lhk%, 1
	}
	str := RegExReplace( str, "#\[(\w+)\]", "$1" )
	
	; eD: Moved the shorter key names down so they'll work on the Languages file.
	strDic := {                      "Delete" : "Del"   ,    "Insert" : "Ins"   ,   "Control" : "Ctrl"
		,    "Return" : "Enter" ,    "Escape" : "Esc"   , "BackSpace" : "Back"  , "Backspace" : "Back" }
	for key, val in strDic
		str := StrReplace( str, key, val )
	
	return str
}
