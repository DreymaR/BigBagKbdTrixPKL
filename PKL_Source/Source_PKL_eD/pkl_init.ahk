; eD: Added Trim() around any 'SubStr( A_LoopField, 1, pos-1 )' entries
;     (From vVv, AHK v1.1 function. Not in AHK v1.0, so make a version here.)
if ( A_AhkVersion < "1.0.90" ) {
	Trim( str )
	{
		str := RegExReplace( str, "(^\s*|\s*$)")
		return str
	}
}

pkl_init( layoutFromCommandLine = "" )
{
	if ( not FileExist("pkl.ini") ) {
		MsgBox, pkl.ini file NOT FOUND`nSorry. The program will exit.
		ExitApp
	}
	
	debugMe := iniReadBoolean( getPklInfo( "DreyPkl" ), "pkl", "eD_DebugInfo", false )
	debugMe ? setPklInfo( "DebugMe", "yes" ) :  setPklInfo( "DebugMe", "no" )
	
	compactMode := iniReadBoolean( "pkl.ini", "pkl", "compactMode", false )
	
	IniRead, t, pkl.ini, pkl, language, auto
	if ( t == "auto" )
		t := getLanguageStringFromDigits( A_Language )
	pkl_locale_load( t, compactMode )
	
	IniRead, t, pkl.ini, pkl, exitAppHotkey, %A_Space%
	if ( t <> "" ) {
		Loop, parse, t, `,
		{
			Hotkey, %A_LoopField%, ExitApp
			if ( A_Index == 1 )
				setPklInfo( "ExitAppHotkey", A_LoopField )
		}
	}
	
	IniRead, t, pkl.ini, pkl, suspendHotkey, LAlt & RCtrl
	Loop, parse, t, `,
	{
		Hotkey, %A_LoopField%, ToggleSuspend
		if ( A_Index == 1 )
			setpklInfo( "SuspendHotkey", A_LoopField )
	}
	
	IniRead, t, pkl.ini, pkl, changeLayoutHotkey, %A_Space%
	if ( t <> "" ) {
		Loop, parse, t, `,
		{
			Hotkey, %A_LoopField%, changeTheActiveLayout
			if ( A_Index == 1 )
				setPklInfo( "ChangeLayoutHotkey", A_LoopField )
		}
	}
	
	IniRead, t, pkl.ini, pkl, displayHelpImageHotkey, %A_Space%
	if ( t <> "" ) {
		Loop, parse, t, `,
		{
			Hotkey, %A_LoopField%, displayHelpImageToggle
			if ( A_Index == 1 )
				setPklInfo( "DisplayHelpImageHotkey", A_LoopField )
		}
	}
	
	IniRead, t, pkl.ini, pkl, systemsDeadkeys, %A_Space%
	setDeadKeysInCurrentLayout( t )
	setPklInfo( "altGrEqualsAltCtrl", iniReadBoolean( "pkl.ini", "pkl", "altGrEqualsAltCtrl", false ) )
	
	IniRead, t, pkl.ini, pkl, changeNonASCIIMode, %A_Space%
	if ( t <> "" ) {
		Loop, parse, t, `,
		{
			Hotkey, %A_LoopField%, _SendU_Change_Dynamic_Mode
		}
	}
	
	SendU_Clipboard_Restore_Mode( iniReadBoolean( "nonASCII.ini", "global", "restoreClipboard", 1) )
	Loop, read, nonASCII.ini
	{
		t := RegExReplace(A_LoopReadLine, "^\s+")
		if ( SubStr( t, 1, 1 ) == ";" )
			Continue
		StringSplit, a, t, =
		if ( a0 != 2 )
			Continue
		a1 := RegExReplace(a1, "^\s+")
		a2 := RegExReplace(a2, "^\s+")
		a1 := RegExReplace(a1, "\s+$")
		a2 := RegExReplace(a2, "\s+$")
		if ( a1 == "restoreClipboard" )
			Continue
		SendU_SetMode( a1, a2 )
	}
	
	IniRead, t, pkl.ini, pkl, suspendTimeOut, 0
	activity_setTimeout( 1, t )
	IniRead, t, pkl.ini, pkl, exitTimeOut, 0
	activity_setTimeout( 2, t )
	
	
	IniRead, Layout, pkl.ini, pkl, layout, %A_Space%
	StringSplit, layouts, Layout, `,
	setLayoutInfo( "countOfLayouts", layouts0 )
	Loop, % layouts0 {
		StringSplit, parts, layouts%A_Index%, :
		A_Layout := parts1
		if ( parts0 > 1 )
			A_Name := parts2
		else
			A_Name := parts1
		setLayoutInfo( "layout" . A_Index . "code", A_Layout )
		setLayoutInfo( "layout" . A_Index . "name", A_Name )
	}
	
	if ( layoutFromCommandLine )
		Layout := layoutFromCommandLine
	else
		Layout := getLayoutInfo( "layout1code" )
	if ( Layout == "" ) {
		pkl_MsgBox( 1 )
		ExitApp
	}
	setLayoutInfo( "active", Layout )
	
	nextLayoutIndex := 1
	Loop, % layouts0 {
		if ( Layout == getLayoutInfo( "layout" . A_Index . "code") ) {
			nextLayoutIndex := A_Index + 1
			break
		}
	}
	if ( nextLayoutIndex > layouts0 )
			nextLayoutIndex := 1
	setLayoutInfo( "nextLayout", getLayoutInfo( "layout" . nextLayoutIndex . "code" ) )
	
	if ( compactMode ) {
		LayoutFile = layout.ini
		setLayoutInfo( "dir", "." )
	} else {
		LayoutFile := "Layouts\" . Layout . "\layout.ini"
		if (not FileExist(LayoutFile)) {
			pkl_MsgBox( 2, LayoutFile )
			ExitApp
		}
		setLayoutInfo( "dir", "Layouts\" . Layout )
	}
	IniRead, ShiftStates, %LayoutFile%, global, shiftstates, 0:1
	ShiftStates = %ShiftStates%:8:9 ; SgCap, SgCap + Shift
	StringSplit, ShiftStates, ShiftStates, :
	IfInString, ShiftStates, 6
		setLayoutInfo( "hasAltGr", 1)
	else
		setLayoutInfo( "hasAltGr", 0)
	IniRead, extendKey, %LayoutFile%, global, extend_key, %A_Space%
	if ( extendKey <> "" ) {
		setLayoutInfo( "extendKey", extendKey )
	}
	
	remap := iniReadSection( LayoutFile, "layout" )
	Loop, parse, remap, `r`n
	{
		pos := InStr( A_LoopField, "=" )
		If (pos == 0)
			Continue
		key := Trim( SubStr( A_LoopField, 1, pos-1 ))
		parts := Trim( SubStr( A_LoopField, pos+1 ))
		StringSplit, parts, parts, %A_Tab%
		if ( parts0 < 2 ) {
			Hotkey, *%key%, doNothing
			Continue
		}
		StringLower, parts2, parts2
		if ( parts2 == "virtualkey" || parts2 == "vk")
			parts2 = -1
		else if ( parts2 == "modifier" )
			parts2 = -2
		setLayoutItem( key . "v", getVirtualKeyCodeFromName(parts1) ) ; virtual key
		setLayoutItem( key . "c", parts2 ) ; caps state
		if ( parts2 == -2 ) {
			Hotkey, *%key%, modifierDown
			Hotkey, *%key% Up, modifierUp
			if ( getLayoutInfo( "hasAltGr" ) && parts1 == "RAlt" )
				setLayoutItem( key . "v", "AltGr" )
			else
				setLayoutItem( key . "v", parts1 )
		} else if ( key == extendKey ) {
			Hotkey, *%key% Up, upToDownKeyPress
		} else {
			Hotkey, *%key%, keyPressed
		}
		Loop, % parts0 - 3 {
			k = ShiftStates%A_Index%
			k := %k%
			
			v := A_Index + 2
			v = parts%v%
			v := %v%
;			v := Trim( v )
			if ( StrLen( v ) == 0 ) {
				v = -- ; Disabled
			} else if ( StrLen( v ) == 1 ) {
				v := asc( v )
			} else {
				if ( SubStr( v, 1, 1 ) == "*" ) { ; Special chars
					setLayoutItem( key . k . "s", SubStr( v, 2 ) )
					v := "*"
				} else if ( SubStr( v, 1, 1 ) == "=" ) { ; Special chars with {Blind}
					setLayoutItem( key . k . "s", SubStr( v, 2 ) )
					v := "="
				} else if ( SubStr( v, 1, 1 ) == "%" ) { ; Ligature (with unicode chars, too)
					setLayoutItem( key . k . "s", SubStr( v, 2 ) )
					v := "%"
				} else if ( v == "--" ) {
					v = -- ;) Disabled
				} else if ( SubStr( v, 1, 2 ) == "dk" ) {
					v := "-" . SubStr( v, 3 )
					v += 0
				} else {
					Loop, parse, v
					{
						if ( A_Index == 1 ) {
							ligature = 0
						} else if ( asc( A_LoopField ) < 128 ) {
							ligature = 1
							break
						}
					}
					if ( ligature ) { ; Ligature
						setLayoutItem( key . k . "s", v )
						v := "%"
					} else { ; One character
						v := "0x" . HexUC( v )
						v += 0
					}
				}
			}
			if ( v != "--" )
				setLayoutItem( key . k , v )
		}
	}
	
	if ( extendKey )
	{
		remap := iniReadSection( "pkl.ini", "extend" )
		Loop, parse, remap, `r`n
		{
			pos := InStr( A_LoopField, "=" )
			key := SubStr( A_LoopField, 1, pos-1 )
			parts := SubStr( A_LoopField, pos+1 )
			setLayoutItem( key . "e", parts )
		}
		remap := iniReadSection( LayoutFile, "extend" )
		Loop, parse, remap, `r`n
		{
			pos := InStr( A_LoopField, "=" )
			key := SubStr( A_LoopField, 1, pos-1 )
			parts := SubStr( A_LoopField, pos+1 )
			setLayoutItem( key . "e", parts )
		}
	}
	
	if ( FileExist( getLayoutInfo("dir") . "\on.ico") ) {
		setTrayIconInfo( "FileOn", getLayoutInfo( "dir" ) . "\on.ico" )
		setTrayIconInfo( "NumOn", 1 )
	} else if ( A_IsCompiled ) {
		setTrayIconInfo( "FileOn", A_ScriptName )
		setTrayIconInfo( "NumOn", 6 )
	} else {
		setTrayIconInfo( "FileOn", "Resources\on.ico" )
		setTrayIconInfo( "NumOn", 1 )
	}
	if ( FileExist( getLayoutInfo( "dir" ) . "\off.ico") ) {
		setTrayIconInfo( "FileOff", getLayoutInfo( "dir" ) . "\off.ico" )
		setTrayIconInfo( "NumOff", 1 )
	} else if ( A_IsCompiled ) {
		setTrayIconInfo( "FileOff", A_ScriptName )
		setTrayIconInfo( "NumOff", 3 )
	} else {
		setTrayIconInfo( "FileOff", "Resources\off.ico" )
		setTrayIconInfo( "NumOff", 1 )
	}
	pkl_set_tray_menu()
}

pkl_activate()
{
	SetTitleMatchMode 2
	DetectHiddenWindows on
	WinGet, id, list, %A_ScriptName%
	Loop, %id%
	{
		; This isn't the first instance. Send "kill yourself" message to all instances
		id := id%A_Index%
		PostMessage, 0x398, 422,,, ahk_id %id%
	}
	Sleep, 10
	pkl_show_tray_menu()
	
	if ( iniReadBoolean( "pkl.ini", "pkl", "displayHelpImage", true ) )
		pkl_displayHelpImage( 1 )

	Sleep, 200 ; I don't want to kill myself...
	OnMessage( 0x398, "MessageFromNewInstance" )
	
	activity_ping(1)
	activity_ping(2)
	SetTimer, activityTimer, 20000
	
	if ( iniReadBoolean( "pkl.ini", "pkl", "startsInSuspendMode", false ) ) {
		Suspend
		gosub afterSuspend
	}
}

pkl_show_tray_menu()
{
	Menu, Tray, Icon, % getTrayIconInfo( "FileOn" ), % getTrayIconInfo( "NumOn" )
	Menu, Tray, Icon,,, 1 ; Freeze the icon
}

MessageFromNewInstance(lparam)
{
	; The second instance send this message
	if ( lparam == 422 )
		ExitApp
}

changeLayout( nextLayout )
{
	Menu, Tray, Icon,,, 1 ; Freeze the icon
	Suspend, On
	
	if ( A_IsCompiled )
		Run %A_ScriptName% /f %nextLayout%
	else
		Run %A_AhkPath% /f %A_ScriptName% %nextLayout%
}
