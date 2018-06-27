pkl_locale_load( lang, compact = 0 )
{
	static initialized := 0	; Ensure the defaults are read only once (as this function is run on layout change too)
	if ( initialized == 0 )
	{																	; eD: Read/set default locale string list
		Loop, 22														; Read default locale strings (numbered)
		{
			str := pklIniRead( "LocStr" . SubStr( "00" . A_Index, -1 ), "", "Pkl_Dic", "DefaultLocaleStr" ) ; eD: Pad with zero if index < 10
			str := strEsc( str )										; Replace \n and \\ escapes
			setPklInfo( "LocStr_" . A_Index , str )
		}
		sect := iniReadSection( getPklInfo( "File_Pkl_Dic" ), "DefaultLocaleTxt" )	; Read default locale strings (key/value)
;		sect := iniReadSection( getPklInfo( "File_Pkl_Dic" ), "DefaultLocaleTxt" )	; Read default locale strings (key/value)
		Loop, Parse, sect, `r`n
		{
			pklIniKeyVal( A_Loopfield, key, val, 1 )					; Extraction with \n escape replacement
			setPklInfo( key, val )
		}
		initialized := 1
	}

	if ( compact )
		file = %lang%.ini
	else
		file = Languages\%lang%.ini

	setPklInfo( "LocStr_RefreshMenu", pklIniRead( "refreshMenuText", "Refresh"        ) )
	setPklInfo( "LocStr_KeyHistMenu", pklIniRead( "keyhistMenuText", "Key history..." ) )
	
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

getReadableHotkeyString( str )
{
	StringReplace, str, str, <^>!, AltGr &%A_Space%, 1
	StringReplace, str, str, SC029, Tilde, 1
	
	StringReplace, str, str, <+, LShift &%A_Space%, 1
	StringReplace, str, str, <^, LCtrl &%A_Space%, 1
	StringReplace, str, str, <!, LAlt &%A_Space%, 1
	StringReplace, str, str, <#, LWin &%A_Space%, 1

	StringReplace, str, str, >+, RShift &%A_Space%, 1
	StringReplace, str, str, >^, RCtrl &%A_Space%, 1
	StringReplace, str, str, >!, RAlt &%A_Space%, 1
	StringReplace, str, str, >#, RWin &%A_Space%, 1
	
	StringReplace, str, str, +, Shift &%A_Space%, 1
	StringReplace, str, str, ^, Ctrl &%A_Space%, 1
	StringReplace, str, str, !, Alt &%A_Space%, 1
	StringReplace, str, str, #, Win &%A_Space%, 1
	
	StringReplace, str, str, *,, 1
	StringReplace, str, str, $,, 1
	StringReplace, str, str, ~,, 1

	str := RegExReplace( str, "(\w+)", "#[$1]" )
	hotkeys := _getHotkeyText( "all" )
	Loop, Parse, hotkeys, %A_Space%
	{
		lhk := _getHotkeyText( A_LoopField )
		StringReplace, str, str, #[%A_LoopField%], %lhk%, 1
	}
	str := RegExReplace( str, "#\[(\w+)\]", "$1" )
	
	; eD: Moved the shorter key names down so they'll work on the Languages file.
	StringReplace, str, str, Return, Enter, 1
	StringReplace, str, str, Escape, Esc, 1
	StringReplace, str, str, BackSpace, Back, 1
	StringReplace, str, str, Backspace, Back, 1
	StringReplace, str, str, Delete, Del, 1
	StringReplace, str, str, Insert, Ins, 1
	StringReplace, str, str, Control, Ctrl, 1
	
	return str
}
