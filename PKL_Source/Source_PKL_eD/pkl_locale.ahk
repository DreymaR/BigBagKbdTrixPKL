; eD: Added Trim() around any 'SubStr( A_LoopField, 1, pos-1 )' entries (from vVv, AHK v1.1+ so I use my own for now)
; eD TODO: Even using Trim(), AHK v1.1 UniCode (but not ANSI) compiled PKL-eD crashes b/c var. m%msg% is too long!?
pklLocaleStrings( msg, newValue = "", set = 0 )
{
	global gP_Pkl_Ini_File
	
	static m1 := "You must set the layout file in " . gP_Pkl_Ini_File . "!"
	static m2 := "#s# file NOT FOUND`nSorry. The program will exit."
	static m3 := "unknown"
	static m4 := "ACTIVE LAYOUT"
	static m5 := "Version"
	static m6 := "Language"
	static m7 := "Copyright"
	static m8 := "Company"
	static m9 := "About..."
	static m10 := "Suspend"
	static m11 := "Exit"
	static m12 := "Detect deadkeys..."
	static m13 := "License: GPL v3"
	static m14 := "This program comes with`nABSOLUTELY NO WARRANTY`nThis is free software, and you`nare welcome to redistribute it`nunder certain conditions."
	static m15 := "Display help image"
	static m18 := "Change layout"
	static m19 := "Layouts"
	static m20 := "Contributors"
	static m21 := "Translation"
	static m22 := "[[Translator Name]]"
	if ( set == 1 ) {
		m%msg% := newValue
	}
	return m%msg%
}

pkl_locale_load( lang, compact = 0 )
{
	if ( compact )
		file = %lang%.ini
	else
		file = Languages\%lang%.ini

	line := iniReadSection( file, "pkl" )
	Loop, parse, line, `r`n
	{
		pos := InStr( A_LoopField, "=" )
		key := Trim( SubStr( A_LoopField, 1, pos-1 ))
		val := Trim( SubStr( A_LoopField, pos+1 ))
		StringReplace, val, val, \n, `n, A
		StringReplace, val, val, \\, \, A
		if ( val != "" )
			pklLocaleStrings( key, val, 1 )
	}

	line := iniReadSection( file, "SendU" )
	Loop, parse, line, `r`n
	{
		pos := InStr( A_LoopField, "=" )
		key := Trim( SubStr( A_LoopField, 1, pos-1 ))
		val := Trim( SubStr( A_LoopField, pos+1 ))
		StringReplace, val, val, \n, `n, A
		StringReplace, val, val, \\, \, A
		SendU_SetLocaleTxt( key, val )
	}

	line := iniReadSection( file, "detectDeadKeys" )
	Loop, parse, line, `r`n
	{
		pos := InStr( A_LoopField, "=" )
		key := Trim( SubStr( A_LoopField, 1, pos-1 ))
		val := Trim( SubStr( A_LoopField, pos+1 ))
		StringReplace, val, val, \n, `n, A
		StringReplace, val, val, \\, \,
			detectDeadKeys_SetLocaleTxt( key, val )
	}
	
	line := iniReadSection( file, "keyNames" )
	Loop, parse, line, `r`n
	{
		pos := InStr( A_LoopField, "=" )
		key := Trim( SubStr( A_LoopField, 1, pos-1 ))
		val := Trim( SubStr( A_LoopField, pos+1 ))
		setHotkeyText( key, val )
	}
}

pklLocaleString( msg, s = "", p = "", q = "", r = "" )
{
	m := pklLocaleStrings( msg )
	if ( s <> "" )
		StringReplace, m, m, #s#, %s%, A
	if ( p <> "" )
		StringReplace, m, m, #p#, %p%, A
	if ( q <> "" )
		StringReplace, m, m, #q#, %q%, A
	if ( r <> "" )
		StringReplace, m, m, #r#, %r%, A
	return m
}

setHotkeyText( hk, localehk )
{
	getHotkeyText( hk, localehk, 1 )
}

getHotkeyText( hk, localehk = "", set = 0 )
{
	static localizedHotkeys := ""
	static pdic := 0
	if ( pdic == 0 )
	{
		pdic := HashTable_New()
	}
	if ( set == 1 ) {
		HashTable_Set( pdic, hk, localehk )
		localizedHotkeys .= " " . hk
	} else {
		if ( hk == "all" )
			return localizedHotkeys
		return HashTable_Get( pdic, hk )
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
	hotkeys := getHotkeyText( "all" )
	Loop, Parse, hotkeys, %A_Space%
	{
		lhk := getHotkeyText( A_LoopField )
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
