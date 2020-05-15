;;  -----------------------------------------------------------------------------------------------
;;
;;  EPKL get/set module
;;      Static associative dictionaries for EPKL info are used instead of most globals
;
/*
	LayoutInfo entries:
	-------------------
	ActiveLay     := "" ; The active layout
	dir           := "" ; The directory of the active layout (eD: Obsolete)
	LayHasAltGr   := 0  ; Should Right Alt work as AltGr in the layout?
	ExtendKey     := "" ; Extend modifier for navigation, editing, etc.
	
	NextLayout    := "" ; If you set multiple layouts, this is the next one.
	                    ; see the "changeActiveLayout:" label!
	NumOfLayouts  := 0  ; Array size
	LayoutsXcode        ; layout code
	LayoutsXname        ; layout name
	Ico_On_File         ; Icon for On  (file)
	Ico_On_Num_         ; --"--        (# in file)
	Ico_OffFile         ; Icon for Off (file)
	Ico_OffNum_         ; --"--        (# in file)
	...and more...
*/
	
setKeyInfo( key, value )
{
	Return getKeyInfo( key, value, 1 )
}

setLayInfo( var, val )
{
	Return getLayInfo( var, val, 1 )
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
		Return pdic[key]
}

getLayInfo( key, value = "", set = 0 )
{
	static pdic     := {}
	if ( set == 1 )
		pdic[key]   := value
	else
		Return pdic[key]
}

getPklInfo( key, value = "", set = 0 )
{
	static pdic     := {}
	if ( set == 1 )
		pdic[key]   := value
	else
		Return pdic[key]
}

;;  -----------------------------------------------------------------------------------------------
;;
;;  EPKL locale module
;;      Functions to set up locale strings
;;      Used by initPklIni() in pkl_init.ahk
;

pkl_locale_load( lang )
{
	static initialized  := false 	; Defaults are read only once, as this function is run on layout change too
	if ( not initialized )
	{																	; Read/set default locale string list
		Loop, 22														; Read default locale strings (numbered)
		{
			str := pklIniRead( "LocStr" . SubStr( "00" . A_Index, -1 ), "", "PklDic", "DefaultLocaleStr" ) ; Pad with zero if index < 10
			str := strEsc( str )										; Replace \# escapes
			setPklInfo( "LocStr_" . A_Index , str )
		}
		sect := iniReadSection( getPklInfo( "File_PklDic" ), "DefaultLocaleTxt" )	; Read default locale strings (key/value)
		Loop, Parse, sect, `r`n
		{
			pklIniKeyVal( A_Loopfield, key, val, 1 )					; Extraction with \n escape replacement
			setPklInfo( key, val )
		}
		initialized := true
	}
	
	setPklInfo( "LocStr_RefreshMenu", pklIniRead( "refreshMenuText", "Refresh"        ) ) 	; eD TODO: Move these into the languages file
	setPklInfo( "LocStr_ZoomImgMenu", pklIniRead( "zoomImgMenuText", "Zoom image"     ) )
	setPklInfo( "LocStr_MoveImgMenu", pklIniRead( "moveImgMenuText", "Move image"     ) )
	setPklInfo( "LocStr_KeyHistMenu", pklIniRead( "keyHistMenuText", "Key history..." ) )
	setPklInfo( "LocStr_ImportsMenu", pklIniRead( "importsMenuText", "Import layouts..." ) )
	setPklInfo( "LocStr_MakeImgMenu", pklIniRead( "makeImgMenuText", "Make help images...", pklIniRead( "imgGenIniFile" ) ) )
	
	file := lang . ".ini"
	file := ( bool(pklIniRead("compactMode")) ) ? file : "Files\Languages\" . file
	if not FileExist( file ) 						; If the language file isn't found, we'll just use the defaults
		Return
	sect := iniReadSection( file, "pkl" )
	Loop, Parse, sect, `r`n
	{
		pklIniKeyVal( A_Loopfield, key, val, 1 )	; A more compact way than before (but still in a loop)
		if ( val != "" )
			setPklInfo( "LocStr_" . key , val ) 	; pklLocaleStrings( key, val, 1 )
	}
	
	sect := iniReadSection( file, "detectDeadKeys" )
	Loop, Parse, sect, `r`n
	{
		pklIniKeyVal( A_Loopfield, key, val, 1 )
		setPklInfo( "DetecDK_" . key, val ) 		; detectDeadKeys_SetLocaleTxt(
	}
	
	sect := iniReadSection( file, "keyNames" )
	Loop, Parse, sect, `r`n
	{
		pklIniKeyVal( A_Loopfield, key, val, 0 )	; Read without character escapes
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
			Return localizedHotkeys
		Return getKeyInfo( "HKtxt_" . hk )
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
	
	; The shorter key names were moved down so they'll work on the Languages file.
	strDic := {                      "Delete" : "Del"   ,    "Insert" : "Ins"   ,   "Control" : "Ctrl"
		,    "Return" : "Enter" ,    "Escape" : "Esc"   , "BackSpace" : "Back"  , "Backspace" : "Back" }
	for key, val in strDic
		str := StrReplace( str, key, val )
	
	Return str
}
