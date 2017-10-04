; <COMPILER: v1.0.48.5>
; #Include %A_ScriptDir%\source
#NoEnv
#Persistent
#NoTrayIcon
#InstallKeybdHook
#SingleInstance force
#MaxThreadsBuffer
#MaxThreadsPerHotkey  3
#MaxHotkeysPerInterval 300
#MaxThreads 20

setPklInfo( "version", "0.4 preview" )
setPklInfo( "compiled", "not released yet" )

SendMode Event
SetBatchLines, -1
Process, Priority, , H
Process, Priority, , R
SetWorkingDir, %A_ScriptDir%


CurrentDeadKeys = 0
CurrentBaseKey  = 0

t = %1%
pkl_init( t )
pkl_activate()
return



exitApp:
	exitApp
return

detectDeadKeysInCurrentLayout:
	setDeadKeysInCurrentLayout( detectDeadKeysInCurrentLayout() )
return

processKeyPress0:
processKeyPress1:
processKeyPress2:
processKeyPress3:
processKeyPress4:
processKeyPress5:
processKeyPress6:
processKeyPress7:
processKeyPress8:
processKeyPress9:
processKeyPress10:
processKeyPress11:
processKeyPress12:
processKeyPress13:
processKeyPress14:
processKeyPress15:
processKeyPress16:
processKeyPress17:
processKeyPress18:
processKeyPress19:
processKeyPress20:
processKeyPress21:
processKeyPress22:
processKeyPress23:
processKeyPress24:
processKeyPress25:
processKeyPress26:
processKeyPress27:
processKeyPress28:
processKeyPress29:
	runKeyPress()
return

keyPressedwoStar:
	activity_ping()
	Critical
	ThisHotkey := A_ThisHotkey
	processKeyPress( ThisHotkey )
return

keyPressed:
	activity_ping()
	Critical
	ThisHotkey := substr( A_ThisHotkey, 2 )
	processKeyPress( ThisHotkey )
return

upToDownKeyPress:
	activity_ping()
	Critical
	ThisHotkey := A_ThisHotkey
	ThisHotkey := substr( ThisHotkey, 2 )
	ThisHotkey := substr( ThisHotkey, 1, -3 )
	processKeyPress( ThisHotkey )
return

modifierDown:
	activity_ping()
	Critical
	ThisHotkey := substr( A_ThisHotkey, 2 )
	setModifierState( getLayoutItem( ThisHotkey . "v" ), 1 )
return

modifierUp:
	activity_ping()
	Critical
	ThisHotkey := A_ThisHotkey
	ThisHotkey := substr( ThisHotkey, 2 )
	ThisHotkey := substr( ThisHotkey, 1, -3 )
	setModifierState( getLayoutItem( ThisHotkey . "v" ), 0 )
return

ShowAbout:
	pkl_about()
return

displayHelpImage:
	pkl_displayHelpImage()
return

displayHelpImageToggle:
	pkl_displayHelpImage( 2 )
return

changeTheActiveLayout:
	changeLayout( getLayoutInfo( "nextLayout" ) )
return

changeLayoutMenu:
	changeLayout( getLayoutInfo( "layout" . A_ThisMenuItemPos . "code" ) )
return

doNothing:
return

ToggleSuspend:
	Suspend
	goto afterSuspend
return

afterSuspend:
	if ( A_IsSuspended ) {
		pkl_displayHelpImage( 3 )
		Menu, tray, Icon, % getTrayIconInfo( "FileOff" ), % getTrayIconInfo( "NumOff" )
	} else {
		activity_ping( 1 )
		activity_ping( 2 )
		pkl_displayHelpImage( 4 )
		Menu, tray, Icon, % getTrayIconInfo( "FileOn" ), % getTrayIconInfo( "NumOn" )
	}
return




DeadKeyValue( dk, base )
{
	static file := ""
	static pdic := 0
	if ( file == "" ) {
		file := getLayoutInfo( "dir" ) . "\layout.ini"
		pdic := HashTable_New()
	}

	res := HashTable_Get( pdic, dk . "_" . base )
	if ( res ) {
		if ( res == -1 )
			res = 0
		return res
	}
	IniRead, res, %file%, deadkey%dk%, %base%, -1`t;
	t := InStr( res, A_Tab )
	res := subStr( res, 1, t - 1 )
	HashTable_Set( pdic, dk . "_" . base, res)
	if ( res == -1 )
		res = 0
	return res
}

DeadKey(DK)
{
	global CurrentDeadKeys
	global CurrentBaseKey
	global CurrentDeadKeyNum
	static PVDK := ""
	DeadKeyChar := DeadKeyValue( DK, 0)


	if ( CurrentDeadKeys > 0 && DK == CurrentDeadKeyNum )
	{
		pkl_Send( DeadKeyChar )
		return
	}

	CurrentDeadKeyNum := DK
	CurrentDeadKeys++
	Input, nk, L1, {F1}{F2}{F3}{F4}{F5}{F6}{F7}{F8}{F9}{F10}{F11}{F12}{Left}{Right}{Up}{Down}{Home}{End}{PgUp}{PgDn}{Del}{Ins}{BS}
	IfInString, ErrorLevel, EndKey
	{
		endk := "{" . Substr(ErrorLevel,8) . "}"
		CurrentDeadKeys = 0
		CurrentBaseKey = 0
		pkl_Send( DeadKeyChar )
		Send %endk%
		return
	}

	if ( CurrentDeadKeys == 0 ) {
		pkl_Send( DeadKeyChar )
		return
	}
	if ( CurrentBaseKey != 0 ) {
		hx := CurrentBaseKey
		nk := chr(hx)
	} else {
		hx := asc(nk)
	}
	CurrentDeadKeys--
	CurrentBaseKey = 0
	newkey := DeadKeyValue( DK, hx)

	if ( newkey && (newkey + 0) == "" ) {

		if ( PVDK ) {
			PVDK := ""
			CurrentDeadKeys = 0
		}
		SendInput %newkey%
	} else if ( newkey && PVDK == "" ) {
		pkl_Send( newkey )
	} else {
		if ( CurrentDeadKeys == 0 ) {
			pkl_Send( DeadKeyChar )
			if ( PVDK ) {
				StringTrimRight, PVDK, PVDK, 1
				StringSplit, DKS, PVDK, " "
				Loop %DKS0% {
					pkl_Send( DKS%A_Index% )
				}
				PVDK := ""
			}
		} else {
			PVDK := DeadKeyChar  . " " . PVDK
		}
		pkl_Send( hx )
	}
}

setDeadKeysInCurrentLayout( deadkeys )
{
	getDeadKeysInCurrentLayout( deadkeys, 1 )
}

getDeadKeysInCurrentLayout( newDeadkeys = "", set = 0 )
{
	static deadkeys := 0
	if ( set == 1 ) {
		if ( newDeadkeys == "auto" )
			deadkeys := getDeadKeysOfSystemsActiveLayout()
		else if ( newDeadkeys == "dynamic" )
			deadkeys := 0
		else
			deadkeys := newDeadkeys
		return
	}
	if ( deadkeys == 0 )
		return getDeadKeysOfSystemsActiveLayout()
	else
		return deadkeys
}

; #Include pkl_deadkey.ahk
setLayoutItem( key, value )
{
	return getLayoutItem( key, value, 1 )
}

getLayoutItem( key, value = "", set = 0 )
{
	static pdic := 0
	if ( pdic == 0 )
	{
		pdic := HashTable_New()
	}
	if ( set == 1 )
		HashTable_Set( pdic, key, value )
	else
		return HashTable_Get( pdic, key )
}

setTrayIconInfo( var, val )
{
	return getTrayIconInfo( var, val, 1 )
}

getTrayIconInfo( var, val = "", set = 0 )
{
	static FileOn := ""
	static NumOn := -1
	static FileOff := ""
	static NumOff := -1
	if ( set == 1 )
		%var% := val
	return  %var% . ""
}

setLayoutInfo( var, val )
{
	return getLayoutInfo( var, val, 1 )
}

getLayoutInfo( key, value = "", set = 0 )
{



	static pdic := 0
	if ( pdic == 0 )
	{
		pdic := HashTable_New()
	}
	if ( set == 1 )
		HashTable_Set( pdic, key, value )
	else
		return HashTable_Get( pdic, key )
}

setPklInfo( key, value )
{
	getPklInfo( key, value, 1 )
}

getPklInfo( key, value = "", set = 0 )
{
	static pdic := 0
	if ( pdic == 0 )
	{
		pdic := HashTable_New()
	}
	if ( set == 1 )
		HashTable_Set( pdic, key, value )
	else
		return HashTable_Get( pdic, key )
}
; #Include pkl_getset.ahk
pkl_set_tray_menu()
{
	ChangeLayoutHotkey := getHotkeyStringInLocale( getPklInfo( "ChangeLayoutHotkey" ) )
	SuspendHotkey := getHotkeyStringInLocale( getPklInfo( "SuspendHotkey" ) )
	HelpImageHotkey := getHotkeyStringInLocale( getPklInfo( "DisplayHelpImageHotkey" ) )

	Layout := getLayoutInfo( "active" )
	LayoutName := ""

	about := pkl_locale_string(9)
	susp := pkl_locale_string(10) . " (" . AddAtForMenu(SuspendHotkey) . ")"
	exit := pkl_locale_string(11)
	deadk := pkl_locale_string(12)
	helpimage := pkl_locale_string(15)
	if ( HelpImageHotkey != "" )
		helpImage .= " (" . AddAtForMenu(HelpImageHotkey) . ")"
	setPklInfo( "DisplayHelpImageMenuName", helpImage )
	changeLayout := pkl_locale_string(18)
	if ( ChangeLayoutHotkey != "" )
		changeLayout .= " (" . AddAtForMenu(ChangeLayoutHotkey) . ")"
	layoutsMenu := pkl_locale_string(19)

	Loop, % getLayoutInfo( "countOfLayouts" )
	{
		l := getLayoutInfo( "layout" . A_Index . "name" )
		c := getLayoutInfo( "layout" . A_Index . "code" )
		Menu, changeLayout, add, %l%, changeLayoutMenu
		if ( c == Layout ) {
			Menu, changeLayout, Default, %l%
			Menu, changeLayout, Check, %l%
			LayoutName := l
		}

		icon = layouts\%c%\on.ico
		if ( not FileExist( icon ) )
			icon = on.ico
		MI_SetMenuItemIcon("changeLayout", A_Index, icon, 1, 16)
	}

	if ( not A_IsCompiled ) {
		tr := MI_GetMenuHandle("Tray")
		MI_SetMenuItemIcon(tr, 1, A_AhkPath, 1, 16)
		MI_SetMenuItemIcon(tr, 2, A_WinDir "\hh.exe", 1, 16)
		SplitPath, A_AhkPath,, SpyPath
		SpyPath = %SpyPath%\AU3_Spy.exe
		MI_SetMenuItemIcon(tr, 4, SpyPath,   1, 16)
		MI_SetMenuItemIcon(tr, 5, "SHELL32.dll", 147, 16)
		MI_SetMenuItemIcon(tr, 6, A_AhkPath, 2, 16)
		MI_SetMenuItemIcon(tr, 8, A_AhkPath, 3, 16)
		MI_SetMenuItemIcon(tr, 9, A_AhkPath, 4, 16)
		MI_SetMenuItemIcon(tr, 10, "SHELL32.dll", 28, 16)
		Menu, tray, add,
		iconNum = 11
	} else {
		Menu, tray, NoStandard
		iconNum = 0
	}

	Menu, tray, add, %about%, ShowAbout
	tr := MI_GetMenuHandle("Tray")
	MI_SetMenuItemIcon(tr, ++iconNum, "SHELL32.dll", 24, 16)
	Menu, tray, add, %helpimage%, displayHelpImageToggle
	MI_SetMenuItemIcon(tr, ++iconNum, "SHELL32.dll", 116, 16)
	Menu, tray, add, %deadk%, detectDeadKeysInCurrentLayout
	MI_SetMenuItemIcon(tr, ++iconNum, "SHELL32.dll", 25, 16)
	if ( getLayoutInfo( "countOfLayouts" ) > 1 ) {
		Menu, tray, add,
		++iconNum
		Menu, tray, add, %layoutsMenu%, :changeLayout
		MI_SetMenuItemIcon(tr, ++iconNum, "SHELL32.dll", 44, 16)
		Menu, tray, add, %changeLayout%, changeTheActiveLayout
		MI_SetMenuItemIcon(tr, ++iconNum, "SHELL32.dll", 138, 16)
	}
	Menu, tray, add, %susp%, toggleSuspend
	MI_SetMenuItemIcon(tr, ++iconNum, "SHELL32.dll", 110, 16)
	Menu, tray, add,
	++iconNum
	Menu, tray, add, %exit%, exitApp
	MI_SetMenuItemIcon(tr, ++iconNum, "SHELL32.dll", 28, 16)
	pklVersion := getPklInfo( "version" )
	Menu, Tray, Tip, Portable Keyboard Layout v%pklVersion%`n(%LayoutName%)

	Menu, Tray, Click, 2
	if ( getLayoutInfo( "countOfLayouts" ) > 1 ) {
		Menu, tray, Default , %changeLayout%
	} else {
		Menu, tray, Default , %susp%
	}

	if (A_OSVersion == "WIN_XP")
	{


		MI_SetMenuStyle( tr, 0x4000000 )
		setPklInfo( "trayMenuHandler", tr )
	}
	OnMessage( 0x404, "AHK_NOTIFYICON" )
}

pkl_about()
{
	lfile := getLayoutInfo( "dir" ) . "\layout.ini"
	pklVersion := getPklInfo( "version" )
	compiledAt := getPklInfo( "compiled" )

	unknown := pkl_locale_string(3)
	active_layout := pkl_locale_string(4)
	version := pkl_locale_string(5)
	language := pkl_locale_string(6)
	copyright := pkl_locale_string(7)
	company := pkl_locale_string(8)
	license := pkl_locale_string(13)
	infos := pkl_locale_string(14)
	contributors := pkl_locale_string(20)
	translationName := pkl_locale_string(21)
	translatorName := pkl_locale_string(22)

	IniRead, lname, %lfile%, informations, layoutname, %unknown%
	IniRead, lver, %lfile%, informations, version, %unknown%
	IniRead, lcode, %lfile%, informations, layoutcode, %unknown%
	IniRead, lcopy, %lfile%, informations, copyright, %unknown%
	IniRead, lcomp, %lfile%, informations, company, %unknown%
	IniRead, llocale, %lfile%, informations, localeid, 0409
	IniRead, lwebsite, %lfile%, informations, homepage, %A_Space%
	llang := getLanguageStringFromDigits( llocale )

	text =
	text = %text%
	Gui, Add, Text, , Portable Keyboard Layout v%pklVersion% (%compiledAt%)
	Gui, Add, Edit, , http://pkl.sourceforge.net/
	Gui, Add, Text, , ......................................................................
	Gui, Add, Text, , (c) FARKAS, Mate, 2007-2010
	Gui, Add, Text, , %license%
	Gui, Add, Text, , %infos%
	Gui, Add, Edit, , http://www.gnu.org/licenses/gpl-3.0.txt
	Gui, Add, Text, , ......................................................................
	text =
	text = %text%%contributors%:
	text = %text%`nmajkenitor (Ini.ahk)
	text = %text%`nLexicos (MI.ahk)
	text = %text%`nShimanov && Laszlo Hars (SendU.ahk)
	text = %text%`n%translatorName% (%translationName%)
	Gui, Add, Text, , %text%
	Gui, Add, Text, , ......................................................................
	text =
	text = %text%%ACTIVE_LAYOUT%: %lname%
	text = %text%`n%version%: %lver%
	text = %text%`n%language%: %llang%
	text = %text%`n%copyright%: %lcopy%
	text = %text%`n%company%: %lcomp%
	Gui, Add, Text, , %text%
	Gui, Add, Edit, , %lwebsite%
	Gui, Add, Text, , ......................................................................
	Gui, Show
}

pkl_displayHelpImage( activate = 0 )
{








	global CurrentDeadKeys
	global CurrentDeadKeyNum

	static guiActiveBeforeSuspend := 0
	static guiActive := 0
	static prevFile
	static HelperImage
	static displayOnTop := 0
	static yPosition := -1
	static imgWidth
	static imgHeight

	static layoutDir = 0
	static hasAltGr
	static extendKey

	if ( layoutDir == 0 )
	{
		layoutDir := getLayoutInfo( "dir" )
		hasAltGr  := getLayoutInfo( "hasAltGr" )
		extendKey := getLayoutInfo( "extendKey" )
	}

	if ( activate == 2 )
		activate := 1 - 2 * guiActive
	if ( activate == 1 ) {
		guiActive = 1
	} else if ( activate == -1 ) {
		guiActive = 0
	} else if ( activate == 3 ) {
		guiActiveBeforeSuspend := guiActive
		activate = -1
		guiActive = 0
	} else if ( activate == 4 ) {
		if ( guiActiveBeforeSuspend == 1 && guiActive != 1) {
			activate = 1
			guiActive = 1
		}
	}

	if ( activate == 1 ) {
		Menu, tray, Check, % getPklInfo( "DisplayHelpImageMenuName" )
		if ( yPosition == -1 ) {
			yPosition := A_ScreenHeight - 160
			IniRead, imgWidth, %LayoutDir%\layout.ini, global, img_width, 300
			IniRead, imgHeight, %LayoutDir%\layout.ini, global, img_height, 100
		}
		Gui, 2:+AlwaysOnTop -Border +ToolWindow
		Gui, 2:margin, 0, 0
		Gui, 2:Add, Pic, xm vHelperImage
		GuiControl,2:, HelperImage, *w%imgWidth% *h%imgHeight% %layoutDir%\state0.png
		Gui, 2:Show, xCenter y%yPosition% AutoSize NA, pklHelperImage
		setTimer, displayHelpImage, 200
	} else if ( activate == -1 ) {
		Menu, tray, UnCheck, % getPklInfo( "DisplayHelpImageMenuName" )
		setTimer, displayHelpImage, Off
		Gui, 2:Destroy
		return
	}
	if ( guiActive == 0 )
		return

	MouseGetPos, , , id
	WinGetTitle, title, ahk_id %id%
	if ( title == "pklHelperImage" ) {
		displayOnTop := 1 - displayOnTop
		if ( displayOnTop )
			yPosition := 5
		else
			yPosition := A_ScreenHeight - imgHeight - 60
		Gui, 2:Show, xCenter y%yPosition% AutoSize NA, pklHelperImage
	}

	if ( CurrentDeadKeys ) {
		if ( not getKeyState( "Shift" ) ) {
			fileName = deadkey%CurrentDeadKeyNum%
		} else {
			fileName = deadkey%CurrentDeadKeyNum%sh
			if ( not FileExist( layoutDir . "\" . filename . ".png" ) )
				fileName = deadkey%CurrentDeadKeyNum%
		}
	} else if ( extendKey && getKeyState( extendKey, "P" ) ) {
		fileName = extend
	} else {
		state = 0
		state += 1 * getKeyState( "Shift" )
		state += 6 * ( hasAltGr * AltGrIsPressed() )
		fileName = state%state%
	}
	if ( not FileExist( layoutDir . "\" . fileName . ".png" ) )
		fileName = state0

	if ( prevFile == fileName )
		return

	prevFile := fileName
	GuiControl,2:, HelperImage, *w%imgWidth% *h%imgHeight% %layoutDir%\%fileName%.png
}

AddAtForMenu( menuItem )
{
	StringReplace, menuItem, menuItem, & , &&, 1
	return menuItem
}


pkl_MsgBox( msg, s = "", p = "", q = "", r = "" )
{
	message := pkl_locale_string( msg, s, p, q, r )
	msgbox %message%
}

AHK_NOTIFYICON(wParam, lParam)
{
	if ( lParam == 0x205 ) {
		if ( A_OSVersion != "WIN_XP" )
			return

		MI_ShowMenu( getPklInfo( "trayMenuHandler" ) )
		return 0
	} else if ( lParam ==0x201 ) {
		gosub ToggleSuspend
	}
}

; #Include pkl_gui.ahk
pkl_init( layoutFromCommandLine = "" )
{
	if ( not FileExist("pkl.ini") ) {
		msgBox, pkl.ini file NOT FOUND`nSorry. The program will exit.
		ExitApp
	}

	compact_mode := IniReadBoolean( "pkl.ini", "pkl", "compactMode", false )

	IniRead, t, pkl.ini, pkl, language, auto
	if ( t == "auto" )
		t := getLanguageStringFromDigits( A_Language )
	pkl_locale_load( t, compact_mode )

	IniRead, t, pkl.ini, pkl, exitAppHotkey, %A_Space%
	if ( t <> "" )
	{
		Loop, parse, t, `,
		{
			Hotkey, %A_LoopField%, ExitApp
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
	setPklInfo( "altGrEqualsAltCtrl", IniReadBoolean( "pkl.ini", "pkl", "altGrEqualsAltCtrl", false ) )

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

	if ( compact_mode ) {
		LayoutFile = layout.ini
		setLayoutInfo( "dir", "." )
	} else {
		LayoutFile := "layouts\" . Layout . "\layout.ini"
		if (not FileExist(LayoutFile)) {
			pkl_MsgBox( 2, LayoutFile )
			ExitApp
		}
		setLayoutInfo( "dir", "layouts\" . Layout )
	}
	IniRead, ShiftStates, %LayoutFile%, global, shiftstates, 0:1
	ShiftStates = %ShiftStates%:8:9
	StringSplit, ShiftStates, ShiftStates, :
	IfInString, ShiftStates, 6
		setLayoutInfo( "hasAltGr", 1)
	else
		setLayoutInfo( "hasAltGr", 0)
	IniRead, extendKey, %LayoutFile%, global, extend_key, %A_Space%
	if ( extendKey <> "" ) {
		setLayoutInfo( "extendKey", extendKey )
	}

	remap := Ini_LoadSection( LayoutFile, "layout" )
	Loop, parse, remap, `r`n
	{
		pos := InStr( A_LoopField, "=" )
		key := subStr( A_LoopField, 1, pos-1 )
		parts := subStr(A_LoopField, pos+1 )
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
		setLayoutItem( key . "v", virtualKeyCodeFromName(parts1) )
		setLayoutItem( key . "c", parts2 )
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
			if ( StrLen( v ) == 0 ) {
				v = --
			} else if ( StrLen( v ) == 1 ) {
				v := asc( v )
			} else {
				if ( SubStr(v,1,1) == "*" ) {
					setLayoutItem( key . k . "s", SubStr(v,2) )
					v := "*"
				} else if ( SubStr(v,1,1) == "=" ) {
					setLayoutItem( key . k . "s", SubStr(v,2) )
					v := "="
				} else if ( SubStr(v,1,1) == "%" ) {
					setLayoutItem( key . k . "s", SubStr(v,2) )
					v := "%"
				} else if ( v == "--" ) {
					v = --
				} else if ( substr(v,1,2) == "dk" ) {
					v := "-" . substr(v,3)
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
					if ( ligature ) {
						setLayoutItem( key . k . "s", v )
						v := "%"
					} else {
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
		remap := Ini_LoadSection( "pkl.ini", "extend" )
		Loop, parse, remap, `r`n
		{
			pos := InStr( A_LoopField, "=" )
			key := subStr( A_LoopField, 1, pos-1 )
			parts := subStr(A_LoopField, pos+1 )
			setLayoutItem( key . "e", parts )
		}
		remap := Ini_LoadSection( LayoutFile, "extend" )
		Loop, parse, remap, `r`n
		{
			pos := InStr( A_LoopField, "=" )
			key := subStr( A_LoopField, 1, pos-1 )
			parts := subStr(A_LoopField, pos+1 )
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
		setTrayIconInfo( "FileOn", "source\on.ico" )
		setTrayIconInfo( "NumOn", 1 )
	}
	if ( FileExist( getLayoutInfo( "dir" ) . "\off.ico") ) {
		setTrayIconInfo( "FileOff", getLayoutInfo( "dir" ) . "\off.ico" )
		setTrayIconInfo( "NumOff", 1 )
	} else if ( A_IsCompiled ) {
		setTrayIconInfo( "FileOff", A_ScriptName )
		setTrayIconInfo( "NumOff", 3 )
	} else {
		setTrayIconInfo( "FileOff", "source\off.ico" )
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

		id := id%A_Index%
		PostMessage, 0x398, 422,,, ahk_id %id%
	}
	Sleep, 10
	pkl_show_tray_menu()

	if ( IniReadBoolean( "pkl.ini", "pkl", "displayHelpImage", true ) )
		pkl_displayHelpImage( 1 )

	Sleep, 200
	OnMessage(0x398, "MessageFromNewInstance")

	activity_ping(1)
	activity_ping(2)
	SetTimer, activityTimer, 20000

	if ( IniReadBoolean( "pkl.ini", "pkl", "startsInSuspendMode", false ) ) {
		Suspend
		gosub afterSuspend
	}
}

pkl_show_tray_menu()
{
	Menu, tray, Icon, % getTrayIconInfo( "FileOn" ), % getTrayIconInfo( "NumOn" )
	Menu, Tray, Icon,,, 1
}

MessageFromNewInstance(lparam)
{

	if ( lparam == 422 )
		exitApp
}

changeLayout( nextLayout )
{
	Menu, Tray, Icon,,, 1
	Suspend, On

	if ( A_IsCompiled )
		Run %A_ScriptName% /f %nextLayout%
	else
		Run %A_AhkPath% /f %A_ScriptName% %nextLayout%
}
; #Include pkl_init.ahk
keyPressed( HK )
{
	static extendKeyStroke := 0
	static extendKey := "--"
	modif =
	state = 0
	if ( extendKey == "--" )
		extendKey := getLayoutInfo( "extendKey" )
	cap := getLayoutItem( HK . "c" )

	if ( extendKey && getKeyState( extendKey, "P" ) ) {
		extendKeyStroke = 1
		extendKeyPressed( HK )
		return
	} else if ( HK == extendKey && extendKeyStroke ) {
		extendKeyStroke = 0
		Send {RShift Up}{LCtrl Up}{LAlt Up}{LWin Up}
		return
	} else if ( cap == -1 ) {
		t := getLayoutItem( HK . "v" )
		t = {VK%t%}
		Send {Blind}%t%
		return
	}
	extendKeyStroke = 0
	if ( getLayoutInfo("hasAltGr") ) {
		if ( AltGrIsPressed() ) {
			sh := getKeyState("Shift")
			if ( (cap & 4) && getKeyState("CapsLock", "T") )
				sh := 1 - sh
			state := 6 + sh
		} else {
			if ( getKeyState("LAlt")) {
				modif .= "!"
				if ( getKeyState("RCtrl"))
					modif .= "^"
				state := pkl_ShiftState( cap )
			} else {
				pkl_CtrlState( HK, cap, state, modif )
			}
		}
	} else {
		if ( getKeyState("Alt")) {
			modif .= "!"
			if ( getKeyState("RCtrl") || ( getKeyState("LCtrl") && !getKeyState("RAlt") ) )
				modif .= "^"
			state := pkl_ShiftState( cap )
		} else {
			pkl_CtrlState( HK, cap, state, modif )
		}
	}
	if ( getKeyState("LWin") || getKeyState("RWin") )
		modif .= "#"


	ch := getLayoutItem( HK . state )
	if ( ch == "" ) {
		return
	} else if ( state == "v" ) {
		pkl_SendThis( modif, "{VK" . ch . "}" )
	} else if ( ch == 32 && HK == "SC039" ) {
		Send, {Blind}{Space}
	} else if ( ( ch + 0 ) > 0 ) {
		pkl_Send( ch, modif )
	} else if ( ch == "*" || ch == "="  ) {

		if ( ch == "=" )
			modif = {Blind}
		else
			modif := ""

		ch := getLayoutItem( HK . state . "s" )
		if ( ch == "{CapsLock}" ) {
			toggleCapsLock()
		} else {
			toSend =
			if ( ch != "" ) {
				toSend = %modif%%ch%
			} else {
				ch := getLayoutItem( HK . "0s" )
				if ( ch != "" )
					ToSend = %modif%%ch%
			}
			pkl_SendThis( "", toSend )
		}
	} else if ( ch == "%" ) {
		SendU_utf8_string( getLayoutItem( HK . state . "s" ) )
	} else if ( ch < 0 ) {
		DeadKey( -1 * ch )
	}
}

extendKeyPressed( HK )
{
	static shiftPressed := ""
	static ctrlPressed := ""
	static altPressed := ""
	static winPressed := ""

	ch := getLayoutItem( HK . "e" )
	if ( ch == "") {
		return
	} else if ( ch == "Shift" ) {
		shiftPressed := HK
		Send {RShift Down}
		return
	} else if ( ch == "Ctrl" ) {
		ctrlPressed := HK
		Send {LCtrl Down}
		return
	} else if ( ch == "Alt" ) {
		altPressed := HK
		Send {LAlt Down}
		return
	} else if ( ch == "Win" ) {
		winPressed := HK
		Send {LWin Down}
		return
	}

	if ( SubStr( ch, 1, 1 ) == "!" ) {
		ch := SubStr( ch, 2 )
		SendInput, {RAW}%ch%
		return
	} else if ( SubStr( ch, 1, 1 ) == "*" ) {
		ch := SubStr( ch, 2 )
		SendInput, %ch%
		return
	}
	if ( ShiftPressed && !getKeyState( ShiftPressed, "P" ) ) {
		Send {RShift Up}
		ShiftPressed := ""
	}
	if ( CtrlPressed && !getKeyState( CtrlPressed, "P" ) ) {
		Send {LCtrl Up}
		CtrlPressed := ""
	}
	if ( AltPressed && !getKeyState( AltPressed, "P" ) ) {
		Send {LAlt Up}
		AltPressed := ""
	}
	if ( WinPressed && !getKeyState( WinPressed, "P" ) ) {
		Send {LWin Up}
		WinPressed := ""
	}
	if ( !AltPressed && getKeyState( "RAlt", "P" ) ) {
		Send {LAlt Down}
		altPressed = RAlt
	}
	if ( A_OSMajorVersion < 6 ) {
		if ( ch == "WheelLeft" ) {
			ControlGetFocus, control, A
			Loop 5
				SendMessage, 0x114, 0, 0,  %control%, A
			return
		} else if ( ch == "WheelRight" ) {
			ControlGetFocus, control, A
			Loop 5
				SendMessage, 0x114, 1, 0,  %control%, A
			return
		}
	}
	if ( ch == "Cut" ) {
		ch = +{Del}
	} else if ( ch == "Copy" ) {
		ch = ^{Ins}
	} else if ( ch == "Paste" ) {
		ch = +{Ins}
	} else {
		ch = {Blind}{%ch%}
	}
	Send %ch%
}

pkl_CtrlState( HK, capState, ByRef state, ByRef modif )
{
	if ( getKeyState("Ctrl") ) {
		state = 2
		if ( getKeyState("Shift") ) {
			state++
			if ( !getLayoutItem( HK . state ) ) {
				state--
				modif .= "+"
				if ( !getLayoutItem( HK . state ) ) {
					state := "v"
					modif .= "^"
				}
			}
		} else if ( !getLayoutItem( HK . state ) ) {
			state := "v"
			modif .= "^"
		}
	} else {
		state := pkl_ShiftState( capState )
	}
}

pkl_ShiftState( capState )
{
	res = 0
	if ( capState == 8 ) {
		if ( getKeyState("CapsLock", "T") )
			res = 8
		if ( getKeyState("Shift") )
			res++
	} else {
		res := getKeyState("Shift")
		if ( (capState & 1) && getKeyState("CapsLock", "T") )
			res := 1 - res
	}
	return res
}

setAltGrState( isdown )
{
	getAltGrState( isdown, 1 )
}

getAltGrState( isdown = 0, set = 0 )
{
	static AltGr := 0
	if ( set == 1 ) {
		if ( isdown == 1 ) {
			AltGr = 1
			Send {LCtrl Down}{RAlt Down}
		} else {
			AltGr = 0
			Send {RAlt Up}{LCtrl Up}
		}
	} else {
		return AltGr
	}
}

setModifierState( modifier, isdown )
{
	getModifierState( modifier, isdown, 1 )
}

getModifierState( modifier, isdown = 0, set = 0 )
{
	static pdic := 0

	if ( modifier == "AltGr" )
		return getAltGrState( isdown, set )

	if ( pdic == 0 )
	{
		pdic := HashTable_New()
	}
	if ( set == 1 ) {
		if ( isdown == 1 ) {
			HashTable_Set( pdic, modifier, 1 )
			Send {%modifier% Down}
		} else {
			HashTable_Set( pdic, modifier, 0 )
			Send {%modifier% Up}
		}
	} else {
		return HashTable_Get( pdic, modifier )
	}
}

AltGrIsPressed()
{
	static altGrEqualsAltCtrl := -1
	if ( altGrEqualsAltCtrl == -1 )
		altGrEqualsAltCtrl := getPklInfo( "AltGrEqualsAltCtrl" )
	return getKeyState( "RAlt" ) || ( altGrEqualsAltCtrl && getKeyState( "Ctrl" ) && getKeyState( "Alt" ) )
}


processKeyPress( ThisHotkey )
{
	Critical
	global HotkeysBuffer
	HotkeysBuffer .= ThisHotkey . "¤"

	static timerCount = 0
	++timerCount
	if ( timerCount >= 30 )
		timerCount = 0
	setTimer, processKeyPress%timerCount%, -1
}

runKeyPress()
{
	Critical
	global HotkeysBuffer
	pos := InStr( HotkeysBuffer, "¤" )
	if ( pos <= 0 )
		return
	ThisHotkey := SubStr( HotkeysBuffer, 1, pos - 1 )
	StringTrimLeft, HotkeysBuffer, HotkeysBuffer, %pos%
	Critical, Off

	keyPressed( ThisHotkey )
}
; #Include pkl_keypress.ahk
pkl_locale_strings( msg, newValue = "", set = 0 )
{
	static m1 := "You must set the layout file in pkl.ini!"
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
	static m12 := "Detect deadkeys"
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
		file = languages\%lang%.ini

	line := Ini_LoadSection( file, "pkl" )
	Loop, parse, line, `r`n
	{
		pos := InStr( A_LoopField, "=" )
		key := subStr( A_LoopField, 1, pos-1 )
		val := subStr(A_LoopField, pos+1 )
		StringReplace, val, val, \n, `n, A
		StringReplace, val, val, \\, \, A
		if ( val != "" )
			pkl_locale_strings( key, val, 1)
	}

	line := Ini_LoadSection( file, "SendU" )
	Loop, parse, line, `r`n
	{
		pos := InStr( A_LoopField, "=" )
		key := subStr( A_LoopField, 1, pos-1 )
		val := subStr(A_LoopField, pos+1 )
		StringReplace, val, val, \n, `n, A
		StringReplace, val, val, \\, \, A
		SendU_SetLocale( key, val )
	}

	line := Ini_LoadSection( file, "detectDeadKeys" )
	Loop, parse, line, `r`n
	{
		pos := InStr( A_LoopField, "=" )
		key := subStr( A_LoopField, 1, pos-1 )
		val := subStr(A_LoopField, pos+1 )
		StringReplace, val, val, \n, `n, A
		StringReplace, val, val, \\, \,
			detectDeadKeysInCurrentLayout_SetLocale( key, val )
	}

	line := Ini_LoadSection( file, "keyNames" )
	Loop, parse, line, `r`n
	{
		pos := InStr( A_LoopField, "=" )
		key := subStr( A_LoopField, 1, pos-1 )
		val := subStr(A_LoopField, pos+1 )
		setHotkeyLocale( key, val )
	}
}

pkl_locale_string( msg, s = "", p = "", q = "", r = "" )
{
	m := pkl_locale_strings( msg )
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

setHotkeyLocale( hk, localehk )
{
	getHotkeyLocale( hk, localehk, 1 )
}

getHotkeyLocale( hk, localehk = "", set = 0 )
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

getHotkeyStringInLocale( str )
{
	StringReplace, str, str, Return, Enter, 1
	StringReplace, str, str, Escape, Esc, 1
	StringReplace, str, str, BackSpace, BS, 1
	StringReplace, str, str, Delete, Del, 1
	StringReplace, str, str, Insert, Ins, 1
	StringReplace, str, str, Control, Ctrl, 1

	StringReplace, str, str, <^>!, RAlt &%A_Space%, 1

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
	hotkeys := getHotkeyLocale( "all" )
	Loop, Parse, hotkeys, %A_Space%
	{
		lhk := getHotkeyLocale( A_LoopField )
		StringReplace, str, str, #[%A_LoopField%], %lhk%, 1
	}
	str := RegExReplace( str, "#\[(\w+)\]", "$1" )
	return str
}

; #Include pkl_locale.ahk
toggleCapsLock()
{
	if ( getKeyState("CapsLock", "T") )
	{
		SetCapsLockState, Off
	} else {
		SetCapsLockState, on
	}
}

pkl_Send( ch, modif = "" )
{
	static SpaceWasSentForDeadkeys = 0

	if ( getGlobal( "CurrentDeadKeys" ) = 0 ) {
		SpaceWasSentForDeadkeys = 0
	} else {
		setGlobal( "CurrentBaseKey", ch )
		if ( SpaceWasSentForDeadkeys = 0 )
			Send {Space}
		SpaceWasSentForDeadkeys = 1
		return
	}

	if ( 32 < ch && ch < 128 ) {
		char := "{" . chr(ch) . "}"
		if ( inStr( getDeadKeysInCurrentLayout(), chr(ch) ) )
			char .= "{Space}"
	} else if ( ch == 32 ) {
		char = {Space}
	} else if ( ch == 9 ) {
		char = {Tab}
	} else if ( ch > 0 && ch <= 26 ) {

		char := "^" . chr( ch + 64 )
	} else if ( ch == 27 ) {
		char = ^{VKDB}
	} else if ( ch == 28 ) {
		char = ^{VKDC}
	} else if ( ch == 29 ) {
		char = ^{VKDD}
	} else {

		sendU(ch)
		return
	}
	pkl_SendThis( modif, char )
}

pkl_SendThis( modif, toSend )
{
	toggleAltgr := getAltGrState()
	prefix := ""

	if ( toggleAltgr )
		setAltGrState( 0 )

	if ( inStr( modif, "!" ) && getKeyState("Alt") )
		prefix = {Blind}

	Send, %prefix%%modif%%toSend%

	if ( toggleAltgr )
		setAltGrState( 1 )
}
; #Include pkl_send.ahk
activity_ping(mode = 1) {
	activity_main(mode, 1)
}

activity_setTimeout(mode, timeout) {
	activity_main(mode, 2, timeout)
}

activity_main(mode = 1, ping = 1, value = 0) {
	static mode1ping := 0
	static mode2ping := 0
	static mode1timeout := 0
	static mode2timeout := 0
	if ( ping == 1 ) {
		mode%mode%ping := A_TickCount
	} else if ( ping == 2 ) {
		mode%mode%timeout := value
	}
	return

	activityTimer:
	if ( mode1timeout > 0 && A_TickCount - mode1ping > mode1timeout * 60000 ) {
		if ( not A_IsSuspended ) {
			gosub toggleSuspend
			activity_ping( 2 )
			return
		}
	}
	if ( mode2timeout > 0 && A_TickCount - mode2ping > mode2timeout * 60000 ) {
		gosub exitApp
		return
	}
	return
}
; #Include pkl_activity.ahk






A_OSMajorVersion := DllCall("GetVersion") & 0xff
A_OSMinorVersion := DllCall("GetVersion") >> 8 & 0xff
; #include A_OSVersion.ahk
HexUC(utf8) {

   format = %A_FormatInteger%
   SetFormat Integer, Hex
   VarSetCapacity(U, 2)
   DllCall("MultiByteToWideChar", UInt,65001, UInt,0, Str,utf8, Int,-1, UInt,&U, Int,1)
   h := 0x10000 + (*(&U+1)<<8) + *(&U)
   StringTrimLeft h, h, 3
   SetFormat Integer, %format%
   Return h
}

; #Include HexUC.ahk











































MI_SetMenuItemIcon(MenuNameOrHandle, ItemPos, FilenameOrHICON, IconNumber=1, IconSize=0, ByRef h_bitmap="", ByRef h_icon="")
{
    h_icon = 0
    h_bitmap = 0

    if MenuNameOrHandle is integer
        h_menu := MenuNameOrHandle
    else
        h_menu := MI_GetMenuHandle(MenuNameOrHandle)

    if !h_menu
        return false

    loaded_icon := false

    if FilenameOrHICON is not integer
    {
        h_icon := MI_ExtractIcon(FilenameOrHICON, IconNumber, IconSize)

        loaded_icon := true
    } else
        h_icon := FilenameOrHICON

    if !h_icon
        return false


    if A_OSVersion = WIN_VISTA
    {


        h_bitmap := MI_GetBitmapFromIcon32Bit(h_icon, IconSize, IconSize)


        if (loaded_icon)
            DllCall("DestroyIcon","uint",h_icon), h_icon:=0

        if !h_bitmap
            return false

        VarSetCapacity(mii,48,0), NumPut(48,mii), NumPut(0x80,mii,4), NumPut(h_bitmap,mii,44)
        return DllCall("SetMenuItemInfo","uint",h_menu,"uint",ItemPos-1,"uint",1,"uint",&mii)
    }





    if IconSize
    {

        h_icon := DllCall("CopyImage","uint",h_icon,"uint",1,"int",IconSize
                            ,"int",IconSize,"uint",loaded_icon ? 4|8 : 4)
    }




    VarSetCapacity(mii,48,0), NumPut(48,mii), NumPut(0xA0,mii,4)
    NumPut(h_icon,  mii,32)
    NumPut(-1,      mii,44)
    if DllCall("SetMenuItemInfo","uint",h_menu,"uint",ItemPos-1,"uint",1,"uint",&mii)
        return true

    if loaded_icon
        DllCall("DestroyIcon","uint",h_icon), h_icon:=0
    return false
}



MI_SetMenuItemBitmap(MenuNameOrHandle, ItemPos, hBitmap)
{
    if MenuNameOrHandle is integer
        h_menu := MenuNameOrHandle
    else
        h_menu := MI_GetMenuHandle(MenuNameOrHandle)

    if !h_menu
        return false

    VarSetCapacity(mii,48,0), NumPut(48,mii), NumPut(0x80,mii,4), NumPut(hBitmap,mii,44)
    return DllCall("SetMenuItemInfo","uint",h_menu,"uint",ItemPos-1,"uint",1,"uint",&mii)
}








MI_GetMenuHandle(menu_name)
{
    static   h_menuDummy
    If h_menuDummy=
    {
        Menu, menuDummy, Add
        Menu, menuDummy, DeleteAll

        Gui, 99:Menu, menuDummy
        Gui, 99:Show, Hide, guiDummy

        old_DetectHiddenWindows := A_DetectHiddenWindows
        DetectHiddenWindows, on

        Process, Exist
        h_menuDummy := DllCall( "GetMenu", "uint", WinExist( "guiDummy ahk_class AutoHotkeyGUI ahk_pid " ErrorLevel ) )
        If ErrorLevel or h_menuDummy=0
            return 0

        DetectHiddenWindows, %old_DetectHiddenWindows%

        Gui, 99:Menu
        Gui, 99:Destroy
    }

    Menu, menuDummy, Add, :%menu_name%
    h_menu := DllCall( "GetSubMenu", "uint", h_menuDummy, "int", 0 )
    DllCall( "RemoveMenu", "uint", h_menuDummy, "uint", 0, "uint", 0x400 )
    Menu, menuDummy, Delete, :%menu_name%

    return h_menu
}





MI_SetMenuStyle(h_menu, style)
{
    VarSetCapacity(mi,28,0), NumPut(28,mi)
    NumPut(0x10,mi,4)
    NumPut(style,mi,8)
    DllCall("SetMenuInfo","uint",h_menu,"uint",&mi)
}


MI_ExtractIcon(Filename, IconNumber, IconSize)
{








    if A_OSVersion in WIN_VISTA,WIN_2003,WIN_XP,WIN_2000
    {
        DllCall("PrivateExtractIcons"
            ,"str",Filename,"int",IconNumber-1,"int",IconSize,"int",IconSize
            ,"uint*",h_icon,"uint*",0,"uint",1,"uint",0,"int")
        if !ErrorLevel
            return h_icon
    }

    if DllCall("shell32.dll\ExtractIconExA","str",Filename,"int",IconNumber-1
                ,"uint*",h_icon,"uint*",h_icon_small,"uint",1)
    {
        SysGet, SmallIconSize, 49


        if (IconSize <= SmallIconSize) {
            DllCall("DestroyIcon","uint",h_icon)
            h_icon := h_icon_small
        } else
            DllCall("DestroyIcon","uint",h_icon_small)



        if (h_icon && IconSize)
            h_icon := DllCall("CopyImage","uint",h_icon,"uint",1,"int",IconSize
                                ,"int",IconSize,"uint",4|8)
    }

    return h_icon ? h_icon : 0
}






MI_ShowMenu(MenuNameOrHandle, x="", y="")
{
    static hInstance, hwnd, ClassName := "OwnerDrawnMenuMsgWin"

    if MenuNameOrHandle is integer
        h_menu := MenuNameOrHandle
    else
        h_menu := MI_GetMenuHandle(MenuNameOrHandle)

    if !h_menu
        return false

    if !hwnd
    {


        if !hInstance
            hInstance := DllCall("GetModuleHandle", "UInt", 0)



        wndProc := RegisterCallback("MI_OwnerDrawnMenuItemWndProc")
        if !wndProc {
            ErrorLevel = RegisterCallback
            return false
        }


        VarSetCapacity(wc, 40, 0)
        NumPut(wndProc,   wc, 4)
        NumPut(hInstance, wc,16)
        NumPut(&ClassName,wc,36)


        if !DllCall("RegisterClass","uint",&wc)
        {
            DllCall("GlobalFree","uint",wndProc)
            ErrorLevel = RegisterClass
            return false
        }




        if A_OSVersion in WIN_XP,WIN_VISTA
            hwndParent = -3
        else
            hwndParent = 0

        hwnd := DllCall("CreateWindowExA","uint",0,"str",ClassName,"str",ClassName
                        ,"uint",0,"int",0,"int",0,"int",0,"int",0,"uint",hwndParent
                        ,"uint",0,"uint",hInstance,"uint",0)
        if !hwnd {
            ErrorLevel = CreateWindowEx
            return false
        }
    }

    prev_hwnd := DllCall("GetForegroundWindow")


    DllCall("SetForegroundWindow","uint",hwnd)

    if (x="" or y="") {
        CoordMode, Mouse, Screen
        MouseGetPos, x, y
    }


    ret := DllCall("TrackPopupMenu","uint",h_menu,"uint",0,"int",x,"int",y
                    ,"int",0,"uint",hwnd,"uint",0)

    if WinExist("ahk_id " prev_hwnd)
        DllCall("SetForegroundWindow","uint",prev_hwnd)




    Sleep, 1

    return ret
}
MI_OwnerDrawnMenuItemWndProc(hwnd, Msg, wParam, lParam)
{
    static WM_DRAWITEM = 0x002B, WM_MEASUREITEM = 0x002C, WM_COMMAND = 0x111
    static ScriptHwnd

    if (Msg = WM_MEASUREITEM)
    {
        h_icon := NumGet(lParam+20)
        if !h_icon
            return false


        VarSetCapacity(buf,24)
        if DllCall("GetIconInfo","uint",h_icon,"uint",&buf)
        {
            hbmColor := NumGet(buf,16)
            hbmMask  := NumGet(buf,12)
            x := DllCall("GetObject","uint",hbmColor,"int",24,"uint",&buf)
            DllCall("DeleteObject","uint",hbmColor)
            DllCall("DeleteObject","uint",hbmMask)
            if !x
                return false
            NumPut(NumGet(buf,4,"int")+2, lParam+12)
            NumPut(NumGet(buf,8,"int")  , lParam+16)
            return true
        }
        return false
    }
    else if (Msg = WM_DRAWITEM)
    {
        hdcDest := NumGet(lParam+24)
        x       := NumGet(lParam+28)
        y       := NumGet(lParam+32)
        h_icon  := NumGet(lParam+44)
        if !(h_icon && hdcDest)
            return false

        return DllCall("DrawIconEx","uint",hdcDest,"int",x,"int",y,"uint",h_icon
                        ,"uint",0,"uint",0,"uint",0,"uint",0,"uint",3)
    }
    else if (Msg = WM_COMMAND)
    {
        DetectHiddenWindows, On
        if !ScriptHwnd {
            Process, Exist
            ScriptHwnd := WinExist("ahk_class AutoHotkey ahk_pid " ErrorLevel)
        }

        SendMessage, Msg, wParam, lParam,, ahk_id %ScriptHwnd%
        return ErrorLevel
    }

    return DllCall("DefWindowProc","uint",hwnd,"uint",Msg,"uint",wParam,"uint",lParam)
}








MI_GetBitmapFromIcon32Bit(h_icon, width=0, height=0)
{
    VarSetCapacity(buf,40)
    if DllCall("GetIconInfo","uint",h_icon,"uint",&buf) {
        hbmColor := NumGet(buf,16)
        hbmMask  := NumGet(buf,12)
    }

    if !(width && height) {
        if !hbmColor or !DllCall("GetObject","uint",hbmColor,"int",24,"uint",&buf)
            return 0
        width := NumGet(buf,4,"int"),  height := NumGet(buf,8,"int")
    }


    if (hdcDest := DllCall("CreateCompatibleDC","uint",0))
    {

        VarSetCapacity(buf,40,0), NumPut(40,buf), NumPut(1,buf,12,"ushort")
        NumPut(width,buf,4), NumPut(height,buf,8), NumPut(32,buf,14,"ushort")

        if (bm := DllCall("CreateDIBSection","uint",hdcDest,"uint",&buf,"uint",0
                            ,"uint*",pBits,"uint",0,"uint",0))
        {

            if (bmOld := DllCall("SelectObject","uint",hdcDest,"uint",bm))
            {

                DllCall("DrawIconEx","uint",hdcDest,"int",0,"int",0,"uint",h_icon
                        ,"uint",width,"uint",height,"uint",0,"uint",0,"uint",3)

                DllCall("SelectObject","uint",hdcDest,"uint",bmOld)
            }


            has_alpha_data := false
            Loop, % height*width
                if NumGet(pBits+0,(A_Index-1)*4) & 0xFF000000 {
                    has_alpha_data := true
                    break
                }
            if !has_alpha_data
            {

                hbmMask := DllCall("CopyImage","uint",hbmMask,"uint",0
                                    ,"int",width,"int",height,"uint",4|8)

                VarSetCapacity(mask_bits, width*height*4, 0)
                if DllCall("GetDIBits","uint",hdcDest,"uint",hbmMask,"uint",0
                            ,"uint",height,"uint",&mask_bits,"uint",&buf,"uint",0)
                {
                    Loop, % height*width
                        if (NumGet(mask_bits, (A_Index-1)*4))
                            NumPut(0, pBits+(A_Index-1)*4)
                        else
                            NumPut(NumGet(pBits+(A_Index-1)*4) | 0xFF000000, pBits+(A_Index-1)*4)
                } else {
                    Loop, % height*width
                        NumPut(NumGet(pBits+(A_Index-1)*4) | 0xFF000000, pBits+(A_Index-1)*4)
                }
            }
        }


        DllCall("DeleteDC","uint",hdcDest)
    }

    if hbmColor
        DllCall("DestroyObject","uint",hbmColor)
    if hbmMask
        DllCall("DestroyObject","uint",hbmMask)
    return bm
}
; #Include MI.ahk


































Ini_LoadSection( pIniFile, pSection="", pPrefix="inis_") {
	local sIni,v,v1,v2,j,s,res
	static x = ",,, ,	,``,¬,¦,!,"",£,%,^,&,*,(,),=,+,{,},;,:,',~,,,<,.,>,/,\,|,-"



	if pSection !=
	{
		Loop, %pIniFile%, 0
			pIniFile := A_LoopFileLongPath


		VarSetCapacity(res, 0x7FFF, 0),  s := DllCall("GetPrivateProfileSection" , "str", pSection, "str", res, "uint", 0x7FFF, "str", pIniFile)

		Loop, % s-1
			if !NumGet(res, A_Index-1, "UChar")
				NumPut(10, res, A_Index-1, "UChar")

		if A_OSVersion in WIN_ME,WIN_98,WIN_95
			res := RegExReplace(res, "m`n)^[ `t]*(?:;.*`n?|`n)|^[ `t]+|[ `t]+$")

		return res
	}


	FileRead, sIni, *t %pIniFile%


	sIni := RegExReplace(RegExReplace(sIni, "`nm)^;.+\R" ), "`nm)^\n" )	"`n["

	j := 0
	if pSection=
	Loop{
		j := RegExMatch( sIni, "(?<=^|\n)\s*\[([^\n]+?)\]\n\s*([^[].*?)(?=\n\s*\[)", v, j+StrLen(v)+1)
		if !j
			break

		if v1 contains %x%
		{
			 v1 := RegExReplace(v1, "[" x "]")
			 ifEqual, v1, , continue
		}


		%pPrefix%%v1% := v2
		res .= v1 "`n"
	}
	return SubStr(res, 1, -1)
}











Ini_GetSectionNames(pIniFile) {
	Loop, %pIniFile%, 0
        pIniFile := A_LoopFileLongPath

    VarSetCapacity(text, 0x1000), len := DllCall("GetPrivateProfileSectionNames", "str", text, "uint", 0x1000, "str", pIniFile)
    Loop, % len-1
        if (NumGet(text, A_Index-1, "UChar") = 0)
            NumPut(10, text, A_Index-1, "UChar")

    return text
}






































Ini_LoadKeys(pIniFile, section = "", pInfo=0, prefix = "", filter="", reverse = false){
	local s, p, v1, v2, res, at, l, re, f, fl
	static x = ",,, ,	,``,¬,¦,!,"",£,%,^,&,*,(,),=,+,{,},;,:,',~,,,<,.,>,/,\,|,-"
	at = %A_AutoTrim%
	AutoTrim, On

	if pInfo is not Integer
	   pInfo := pInfo = "vals" ? 2 : pinfo="keys" ? 1 : 0

	if (pIniFile = "")
			pIniFile := section
	else if section !=
		 pIniFile := "[" section "]`n" Ini_LoadSection(pIniFile, section)
	else  {
		FileRead, pIniFile, *t %pIniFile%
		pIniFile := RegExReplace(RegExReplace(pIniFile, "`nm)^;.+\R" ), "`nm)^\n" )	"`n["
	}

	if pInfo
		 prefix .= prefix="" ? "`n" : ""
	else res := 0

	f := filter != "", fl := StrLen(filter)
	if (re := *&filter = 10)
		filter := SubStr(filter, 2)


	Loop, parse, pIniFile, `n, `r`n
	{
  		l = %A_LoopField%
		If InStr(l, "[") = 1 {
			StringMid, s, l, 2, InStr(l, "]") - 2
			If s contains %x%
 				s := RegExReplace(s, "[" x "]")
		}
		Else If p := InStr(l, "=")
		{
			StringLeft, v1, l, p-1
			v1 = %v1%

			if f
				if re {
					if !RegExMatch( v1, filter ) {
						  IfEqual, reverse, 0, continue
					}else IfEqual, reverse, 1, continue
				}else if SubStr(v1, 1, fl) != filter {
						  IfEqual, reverse, 0, continue
					}else IfEqual, reverse, 1, continue

			If v1 contains %x%
			{
 				 v1 := RegExReplace(v1, "[" x "]")
				 IfEqual, v1, , continue
			}

			StringTrimLeft, v2, l, p

			if !pInfo
				%prefix%%s%_%v1% := v2,  res++
			else res .= (pInfo=1 ? v1 : v2) prefix
		}
   }
   AutoTrim, %at%
   Return, pInfo ? SubStr(res, 1, -StrLen(prefix)) : res
}























Ini_MakeSection( prefix ) {
    static hwndEdit, pSFW, pSW, bkpSFW, bkpSW
	static header="Global Variables (alphabetical)`r`n--------------------------------------------------`r`n"

    if !hwndEdit
    {
        dhw := A_DetectHiddenWindows
        DetectHiddenWindows, On
        Process, Exist
        ControlGet, hwndEdit, Hwnd,, Edit1, ahk_class AutoHotkey ahk_pid %ErrorLevel%
        DetectHiddenWindows, %dhw%

        hmod := DllCall("GetModuleHandle", "str", "user32.dll")
        pSFW := DllCall("GetProcAddress", "uint", hmod, "str", "SetForegroundWindow")
        pSW := DllCall("GetProcAddress", "uint", hmod, "str", "ShowWindow")
        DllCall("VirtualProtect", "uint", pSFW, "uint", 8, "uint", 0x40, "uint*", 0)
        DllCall("VirtualProtect", "uint", pSW, "uint", 8, "uint", 0x40, "uint*", 0)
        bkpSFW := NumGet(pSFW+0, 0, "int64")
        bkpSW := NumGet(pSW+0, 0, "int64")
    }


	critical 1000000000
		NumPut(0x0004C200000001B8, pSFW+0, 0, "int64")
		NumPut(0x0008C200000001B8, pSW+0, 0, "int64")
		ListVars
		NumPut(bkpSFW, pSFW+0, 0, "int64"),  NumPut(bkpSW, pSW+0, 0, "int64")
	critical off

    ControlGetText, text,, ahk_id %hwndEdit%
	text := SubStr( text, InStr(text, header)+85 )




	len := StrLen(prefix)
	loop, parse, text, `n, `r`n
	{
		j := InStr(A_LoopField, ":")
		if !j
			continue
		k := SubStr( A_LoopField, 1, j-1)
		j := InStr(k, "[", 0, 0)
		if !j
			continue
		k := SubStr( k, 1, j-1)
		if (k < prefix)
			continue
		if (SubStr(k, 1, len) != prefix)
			break

		k1 := SubStr( k, len+1), res .= k1 "=" %k% "`n"
	}
	return SubStr(res, 1, -1)
}











Ini_ReplaceSection( pIniFile, section, ByRef data=""){
	IniDelete, %pIniFile%, %section%
	FileAppend, [%section%]`n%data%, %pIniFile%
}












Ini_UpdateSection( ByRef sSection, ByRef data){
	return, data (data !="" ? "`n" :) Ini_DelKeys(sSection, Ini_LoadKeys("", data, 2, ","))
}














Ini_GetVal(ByRef sSection, name, def="") {
	return RegExMatch(sSection, "`aim)^\s*\Q" name "\E\s*=(.+)$", out) ? out1 : def
}










Ini_SetVal(ByRef sSection, name, val="") {
	sSection := RegExReplace(sSection, "`aim)^\s*\Q" name "\E\s*=(.+)$", name "=" val )
}













Ini_GetKeyName(ByRef sSection, val){
	return RegExMatch(sSection, "`aim)^\s*(.+?)\s*=\Q" val "\E$", out) ? out1 : ""
}














Ini_DelKeys( ByRef sSection, keys, rev=false, sep=",") {
	at = %A_AutoTrim%
	AutoTrim, On

	keys := sep keys sep
	loop, parse, sSection, `n, `n`r
	{
 		l = %A_LoopField%
		If !(p := InStr(l, "="))
			continue
		StringLeft, k, l, p-1
		k = %k%

		if InStr(keys, sep k sep) {
			   IfEqual, rev, 0, continue
		} else IfEqual, rev, 1, continue
		res .= l "`n"
	}
	AutoTrim, %at%

	return SubStr(res, 1, -1)
}






















Ini_DelKeysRe( ByRef sSection, re) {
	k := InStr(re, ")"), j := InStr(re, "(")
	re := "m" ( k && (!j || j>k) ? "" : ")") re

	k := RegExReplace( Ini_LoadKeys("", sSection, "keys"), re )
	return Ini_DelKeys( sSection, k, true, "`n")

}



















Ini_AddMRU(ByRef sSection, pLine, pMax=10, prefix="m") {

	res := prefix "1=" pLine, j:=1, ret:=1
	loop, parse, sSection, `n, `r
	{
		if (A_Index >= pMax)
			break

		if (A_LoopField = "m" A_Index "=" pLine) {
			if A_Index = 1
				return 0
			j:=0, pMax++, ret := A_Index
			continue
		}
		else res .= "`n" prefix (A_Index+j) "=" SubStr(A_LoopField, InStr(A_LoopField, "=")+1)
	}

	sSection := res
	return ret
}






; #Include Ini.ahk


















SendCh( Ch )
{
	Ch += 0
	if ( Ch < 0 ) {

		return
	} else if ( Ch < 33 ) {

		Char =
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

		Char := "{" . Chr( Ch ) . "}"
		Send %Char%
	} else {

		SendU( Ch )
	}
}


SendU( UC )
{
	UC += 0
	if ( UC <= 0 )
		return
	mode := SendU_Mode()
	if ( mode = "d" ) {
		WinGet, pn, ProcessName, A
		mode := _SendU_Dynamic_Mode( pn )
	}

	if ( mode = "i" )
		_SendU_Input(UC)
	else if ( mode = "c" )
		_SendU_Clipboard(UC)
	else if ( mode = "a" ) {
		if ( UC < 256 )
			UC := "0" . UC
		Send {ASC %UC%}
	} else {
		_SendU_Input(UC)
	}
}

SendU_utf8_string( str )
{
	mode := SendU_Mode()
	if ( mode = "d" ) {
		WinGet, pn, ProcessName, A
		mode := _SendU_Dynamic_Mode( pn )
	}

	if ( mode = "c" )
		_SendU_Clipboard( str, 1 )
	else if ( mode = "a" ) {
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
	if ( newMode == 1 || newMode == 0 )
		mode := newMode
	else if ( newMode == 2 )
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
	_SendU_Dynamic_Mode( "", 1 )
}

SendU_SetLocale( variable, value )
{
	_SendU_GetLocale( variable, value, 1 )
}






_SendU_Input( UC )
{


	static buffer := "#"
	if buffer = #
	{
		VarSetCapacity( buffer, 56, 0 )
		DllCall("RtlFillMemory", "uint",&buffer,"uint",1, "uint", 1)
		DllCall("RtlFillMemory", "uint",&buffer+28, "uint",1, "uint", 1)
	}
	DllCall("ntdll.dll\RtlFillMemoryUlong","uint",&buffer+6, "uint",4,"uint",0x40000|UC)
	DllCall("ntdll.dll\RtlFillMemoryUlong","uint",&buffer+34,"uint",4,"uint",0x60000|UC)

	Suspend On
	DllCall("SendInput", UInt,2, UInt,&buffer, Int,28)
	Suspend Off

	return
}

_SendU_Utf_To_Codes( utf8, separator = "," ) {


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
	Sleep, 50
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

_SendU_UnicodeChar( UC )
{
	VarSetCapacity(UText, 4, 0)
	NumPut(UC, UText, 0, "UShort")
	VarSetCapacity(AText, 4, 0)
	DllCall("WideCharToMultiByte"
		, "UInt", 65001
		, "UInt", 0
		, "Str",  UText
		, "Int",  -1
		, "Str",  AText
		, "Int",  4
		, "UInt", 0
		, "UInt", 0)
	return %AText%
}



_SendU_Get_Mode_Name( mode )
{
	if ( mode == "c" && SendU_Clipboard_Restore_Mode() )
		mode = r
	m := _SendU_GetLocale( "Mode_Name_" . mode )
	if ( m == "" )
		m := _SendU_GetLocale( "Mode_Name_0" )
	return m
}

_SendU_Get_Mode_Type( mode )
{
	if ( mode == "c" && SendU_Clipboard_Restore_Mode() )
		mode = r
	m := _SendU_GetLocale( "Mode_Type_" . mode )
	if ( m == "" )
		m := _SendU_GetLocale( "Mode_Type_0" )
	return m
}

_SendU_Dynamic_Mode_Tooltip( processName = -1, mode = -1 )
{
	tt := _SendU_GetLocale("DYNAMIC_MODE_TOOLTIP")
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
	static prevProcess := "fOyj9b4f79YmA7sZRBrnDbp75dGhiauj"
	static mode := ""
	if ( clearPrevProcess == 1 )
		prevProcess := "fOyj9b4f79YmA7sZRBrnDbp75dGhiauj"
	if ( processName == prevProcess )
		return mode
	prevProcess := processName
	mode := _SendU_GetMode( processName )
	return mode
}




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

_SendU_GetLocale( sKey, sVal = "", set = 0 )
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





__SendU_Labels_And_Includes__This_Is_Not_A_Function()
{
	return




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




	_SendU_Try_Dynamic_Mode:
	_SendU_Change_Dynamic_Mode:
		SendU_Try_Dynamic_Mode()
	return

	_SendU_Toggle_Clipboard_Restore_Mode:
		SendU_Clipboard_Restore_Mode( 2 )
		_SendU_Dynamic_Mode_Tooltip()
	return

}

VTable(ppv, idx)
{
	Return	NumGet(NumGet(1*ppv)+4*idx)
}

QueryInterface(ppv, ByRef IID)
{
	If	StrLen(IID)=38
		GUID4String(IID,IID)
	DllCall(NumGet(NumGet(1*ppv)), "Uint", ppv, "str", IID, "UintP", ppv)
	Return	ppv
}

AddRef(ppv)
{
	Return	DllCall(NumGet(NumGet(1*ppv)+4), "Uint", ppv)
}

Release(ppv)
{
	Return	DllCall(NumGet(NumGet(1*ppv)+8), "Uint", ppv)
}

QueryService(ppv, ByRef SID, ByRef IID)
{
	If	StrLen(SID)=38
		GUID4String(SID,SID)
	If	StrLen(IID)=38
		GUID4String(IID,IID)
	GUID4String(IID_IServiceProvider,"{6D5140C1-7436-11CE-8034-00AA006009FA}")
	DllCall(NumGet(NumGet(1*ppv)+4*0), "Uint", ppv, "str", IID_IServiceProvider, "UintP", psp)
	DllCall(NumGet(NumGet(1*psp)+4*3), "Uint", psp, "str", SID, "str", IID, "UintP", ppv)
	DllCall(NumGet(NumGet(1*psp)+4*2), "Uint", psp)
	Return	ppv
}

FindConnectionPoint(pdp, DIID)
{
	DllCall(NumGet(NumGet(1*pdp)+ 0), "Uint", pdp, "Uint", GUID4String(IID_IConnectionPointContainer,"{B196B284-BAB4-101A-B69C-00AA00341D07}"), "UintP", pcc)
	DllCall(NumGet(NumGet(1*pcc)+16), "Uint", pcc, "Uint", GUID4String(DIID,DIID), "UintP", pcp)
	DllCall(NumGet(NumGet(1*pcc)+ 8), "Uint", pcc)
	Return	pcp
}

GetConnectionInterface(pcp)
{
	VarSetCapacity(DIID, 16, 0)
	DllCall(NumGet(NumGet(1*pcp)+12), "Uint", pcp, "str", DIID)
	Return	String4GUID(&DIID)
}

Advise(pcp, psink)
{
	DllCall(NumGet(NumGet(1*pcp)+20), "Uint", pcp, "Uint", psink, "UintP", nCookie)
	Return	nCookie
}

Unadvise(pcp, nCookie)
{
	Return	DllCall(NumGet(NumGet(1*pcp)+24), "Uint", pcp, "Uint", nCookie)
}


Invoke(pdisp, sName, arg1="vT_NoNe",arg2="vT_NoNe",arg3="vT_NoNe",arg4="vT_NoNe",arg5="vT_NoNe",arg6="vT_NoNe",arg7="vT_NoNe",arg8="vT_NoNe",arg9="vT_NoNe")
{
	nParams:=0
	Loop,	9
		If	(arg%A_Index% == "vT_NoNe")
			Break
		Else	++nParams
	VarSetCapacity(DispParams,16,0), VarSetCapacity(varResult,16,0), VarSetCapacity(IID_NULL,16,0), VarSetCapacity(varg,nParams*16,0)
		NumPut(&varg,DispParams,0), NumPut(nParams,DispParams,8)
	If	(nFlags := SubStr(sName,0) <> "=" ? 3 : 12) = 12
		NumPut(&varResult,DispParams,4), NumPut(1,DispParams,12), NumPut(-3,varResult), sName:=SubStr(sName,1,-1)
	Loop, %	nParams
		If	arg%A_Index% Is Not Integer
         		NumPut(8,varg,(nParams-A_Index)*16,"Ushort"), NumPut(SysAllocString(arg%A_Index%),varg,(nParams-A_Index)*16+8)
		Else	NumPut(SubStr(arg%A_Index%,1,1)="+" ? 9 : 3,varg,(nParams-A_Index)*16,"Ushort"), NumPut(arg%A_Index%,varg,(nParams-A_Index)*16+8)
	If	DllCall(NumGet(NumGet(1*pdisp)+20), "Uint", pdisp, "Uint", &IID_NULL, "UintP", Unicode4Ansi(wName, sName), "Uint", 1, "Uint", LCID, "intP", dispID)=0
	&&	DllCall(NumGet(NumGet(1*pdisp)+24), "Uint", pdisp, "int", dispID, "Uint", &IID_NULL, "Uint", LCID, "Ushort", nFlags, "Uint", &dispParams, "Uint", &varResult, "Uint", 0, "Uint", 0)=0
	&&	nFlags = 3
		Result:=(vt:=NumGet(varResult,0,"Ushort"))=8||vt<0x1000&&DllCall("oleaut32\VariantChangeTypeEx","Uint",&varResult,"Uint",&varResult,"Uint",LCID,"Ushort",1,"Ushort",8)=0 ? Ansi4Unicode(bstr:=NumGet(varResult,8)) . SubStr(SysFreeString(bstr),1,0) : NumGet(varResult,8)
	Loop, %	nParams
		NumGet(varg,(A_Index-1)*16,"Ushort")=8 ? SysFreeString(NumGet(varg,(A_Index-1)*16+8)) : ""
	Return	Result
}

Invoke_(pdisp, sName, type1="",arg1="",type2="",arg2="",type3="",arg3="",type4="",arg4="",type5="",arg5="",type6="",arg6="",type7="",arg7="",type8="",arg8="",type9="",arg9="")
{
	nParams:=0
	Loop,	9
		If	(type%A_Index% = "")
			Break
		Else	++nParams
	VarSetCapacity(dispParams,16,0), VarSetCapacity(varResult,16,0), VarSetCapacity(IID_NULL,16,0), VarSetCapacity(varg,nParams*16,0)
		NumPut(&varg,dispParams,0), NumPut(nParams,dispParams,8)
	If	(nFlags := SubStr(sName,0) <> "=" ? 1|2 : 4|8) & 12
		NumPut(&varResult,dispParams,4), NumPut(1,dispParams,12), NumPut(-3,varResult), sName:=SubStr(sName,1,-1)
	Loop, %	nParams
		NumPut(type%A_Index%,varg,(nParams-A_Index)*16,"Ushort"), type%A_Index%&0x4000=0 ? NumPut(type%A_Index%=8 ? SysAllocString(arg%A_Index%) : arg%A_Index%,varg,(nParams-A_Index)*16+8,type%A_Index%=5||type%A_Index%=7 ? "double" : type%A_Index%=4 ? "float" : "int64") : type%A_Index%=0x400C||type%A_Index%=0x400E ? NumPut(arg%A_Index%,varg,(nParams-A_Index)*16+8) : VarSetCapacity(ref%A_Index%,8,0) . NumPut(&ref%A_Index%,varg,(nParams-A_Index)*16+8) . NumPut(type%A_Index%=0x4008 ? SysAllocString(arg%A_Index%) : arg%A_Index%,ref%A_Index%,0,type%A_Index%=0x4005||type%A_Index%=0x4007 ? "double" : type%A_Index%=0x4004 ? "float" : "int64")
	If	DllCall(NumGet(NumGet(1*pdisp)+20), "Uint", pdisp, "Uint", &IID_NULL, "UintP", Unicode4Ansi(wName, sName), "Uint", 1, "Uint", LCID, "intP", dispID)=0
	&&	DllCall(NumGet(NumGet(1*pdisp)+24), "Uint", pdisp, "int", dispID, "Uint", &IID_NULL, "Uint", LCID, "Ushort", nFlags, "Uint", &dispParams, "Uint", &varResult, "Uint", 0, "Uint", 0)=0
	&&	nFlags = 3
		Result:=(vt:=NumGet(varResult,0,"Ushort"))=8||vt<0x1000&&DllCall("oleaut32\VariantChangeTypeEx","Uint",&varResult,"Uint",&varResult,"Uint",LCID,"Ushort",1,"Ushort",8)=0 ? Ansi4Unicode(bstr:=NumGet(varResult,8)) . SubStr(SysFreeString(bstr),1,0) : NumGet(varResult,8)
	Loop, %	nParams
		type%A_Index%&0x4000=0 ? (type%A_Index%=8 ? SysFreeString(NumGet(varg,(nParams-A_Index)*16+8)) : "") : type%A_Index%=0x400C||type%A_Index%=0x400E ? "" : type%A_Index%=0x4008 ? (_TEMP_VT_BYREF_%A_Index%:=Ansi4Unicode(NumGet(ref%A_Index%))) . SysFreeString(NumGet(ref%A_Index%)) : (_TEMP_VT_BYREF_%A_Index%:=NumGet(ref%A_Index%,0,type%A_Index%=0x4005||type%A_Index%=0x4007 ? "double" : type%A_Index%=0x4004 ? "float" : "int64"))
	Return	Result
}

DispInterface(this, prm1="", prm2="", prm3="", prm4="", prm5="", prm6="", prm7="", prm8="")
{
	Critical
	If	A_EventInfo = 6
		DllCall(NumGet(NumGet(NumGet(this+8))+28),"Uint",NumGet(this+8),"Uint",prm1,"UintP",pname,"Uint",1,"UintP",0), VarSetCapacity(sfn,63), DllCall("user32\wsprintfA","str",sfn,"str","%s%S","Uint",this+40,"Uint",pname,"Cdecl"), SysFreeString(pname), (pfn:=RegisterCallback(sfn,"C F")) ? (hResult:=DllCall(pfn, "Uint", prm5, "Uint", this, "Cdecl")) . DllCall("kernel32\GlobalFree", "Uint", pfn) : (hResult:=0x80020003)
	Else If	A_EventInfo = 5
		hResult:=DllCall(NumGet(NumGet(NumGet(this+8))+40),"Uint",NumGet(this+8),"Uint",prm2,"Uint",prm3,"Uint",prm5)
	Else If	A_EventInfo = 4
		NumPut(0,prm3+0), hResult:=0x80004001
	Else If	A_EventInfo = 3
		NumPut(0,prm1+0), hResult:=0
	Else If	A_EventInfo = 2
		NumPut(hResult:=NumGet(this+4)-1,this+4), hResult ? "" : Unadvise(NumGet(this+16),NumGet(this+20)) . Release(NumGet(this+16)) . Release(NumGet(this+8)) . CoTaskMemFree(this)
	Else If	A_EventInfo = 1
		NumPut(hResult:=NumGet(this+4)+1,this+4)
	Else If	A_EventInfo = 0
		IsEqualGUID(this+24,prm1)||InStr("{00020400-0000-0000-C000-000000000046}{00000000-0000-0000-C000-000000000046}",String4GUID(prm1)) ? NumPut(this,prm2+0) . NumPut(NumGet(this+4)+1,this+4) . (hResult:=0) : NumPut(0,prm2+0) . (hResult:=0x80004002)
	Return	hResult
}

DispGetParam(pDispParams, Position = 0, vtType = 8)
{
	VarSetCapacity(varResult,16,0)
	DllCall("oleaut32\DispGetParam", "Uint", pDispParams, "Uint", Position, "Ushort", vtType, "Uint", &varResult, "UintP", nArgErr)
	Return	NumGet(varResult,0,"Ushort")=8 ? Ansi4Unicode(NumGet(varResult,8)) . SubStr(SysFreeString(NumGet(varResult,8)),1,0) : NumGet(varResult,8)
}

CreateIDispatch()
{
	Static	IDispatch
	If Not	VarSetCapacity(IDispatch)
	{
		VarSetCapacity(IDispatch,28,0),   nParams=3112469
		Loop,   Parse,   nParams
		NumPut(RegisterCallback("DispInterface","",A_LoopField,A_Index-1),IDispatch,4*(A_Index-1))
	}
	Return &IDispatch
}

GetDefaultInterface(pdisp, LCID = 0)
{
	DllCall(NumGet(NumGet(1*pdisp) +12), "Uint", pdisp , "UintP", ctinf)
	If	ctinf
	{
	DllCall(NumGet(NumGet(1*pdisp)+16), "Uint", pdisp, "Uint" , 0, "Uint", LCID, "UintP", ptinf)
	DllCall(NumGet(NumGet(1*ptinf)+12), "Uint", ptinf, "UintP", pattr)
	DllCall(NumGet(NumGet(1*pdisp)+ 0), "Uint", pdisp, "Uint" , pattr, "UintP", ppv)
	DllCall(NumGet(NumGet(1*ptinf)+76), "Uint", ptinf, "Uint" , pattr)
	DllCall(NumGet(NumGet(1*ptinf)+ 8), "Uint", ptinf)
	If	ppv
	DllCall(NumGet(NumGet(1*pdisp)+ 8), "Uint", pdisp),	pdisp := ppv
	}
	Return	pdisp
}

GetDefaultEvents(pdisp, LCID = 0)
{
	DllCall(NumGet(NumGet(1*pdisp)+16), "Uint", pdisp, "Uint" , 0, "Uint", LCID, "UintP", ptinf)
	DllCall(NumGet(NumGet(1*ptinf)+12), "Uint", ptinf, "UintP", pattr)
	VarSetCapacity(IID,16), DllCall("RtlMoveMemory", "Uint", &IID, "Uint", pattr, "Uint", 16)
	DllCall(NumGet(NumGet(1*ptinf)+76), "Uint", ptinf, "Uint" , pattr)
	DllCall(NumGet(NumGet(1*ptinf)+72), "Uint", ptinf, "UintP", ptlib, "UintP", idx)
	DllCall(NumGet(NumGet(1*ptinf)+ 8), "Uint", ptinf)
	Loop, %	DllCall(NumGet(NumGet(1*ptlib)+12), "Uint", ptlib)
	{
		DllCall(NumGet(NumGet(1*ptlib)+20), "Uint", ptlib, "Uint", A_Index-1, "UintP", TKind)
		If	TKind <> 5
			Continue
		DllCall(NumGet(NumGet(1*ptlib)+16), "Uint", ptlib, "Uint", A_Index-1, "UintP", ptinf)
		DllCall(NumGet(NumGet(1*ptinf)+12), "Uint", ptinf, "UintP", pattr)
		nCount:=NumGet(pattr+48,0,"Ushort")
		DllCall(NumGet(NumGet(1*ptinf)+76), "Uint", ptinf, "Uint" , pattr)
		Loop, %	nCount
		{
			DllCall(NumGet(NumGet(1*ptinf)+36), "Uint", ptinf, "Uint", A_Index-1, "UintP", nFlags)
			If	!(nFlags & 1)
				Continue
			DllCall(NumGet(NumGet(1*ptinf)+32), "Uint", ptinf, "Uint", A_Index-1, "UintP", hRefType)
			DllCall(NumGet(NumGet(1*ptinf)+56), "Uint", ptinf, "Uint", hRefType , "UintP", prinf)
			DllCall(NumGet(NumGet(1*prinf)+12), "Uint", prinf, "UintP", pattr)
			nFlags & 2 ? DIID:=String4GUID(pattr) : bFind:=IsEqualGUID(pattr,&IID)
			DllCall(NumGet(NumGet(1*prinf)+76), "Uint", prinf, "Uint" , pattr)
			DllCall(NumGet(NumGet(1*prinf)+ 8), "Uint", prinf)
		}
		DllCall(NumGet(NumGet(1*ptinf)+ 8), "Uint", ptinf)
		If	bFind
			Break
	}
	DllCall(NumGet(NumGet(1*ptlib)+ 8), "Uint", ptlib)
	Return	bFind ? DIID : "{00000000-0000-0000-0000-000000000000}"
}

GetGuidOfName(pdisp, Name, LCID = 0)
{
	DllCall(NumGet(NumGet(1*pdisp)+16), "Uint", pdisp, "Uint", 0, "Uint", LCID, "UintP", ptinf)
	DllCall(NumGet(NumGet(1*ptinf)+72), "Uint", ptinf, "UintP", ptlib, "UintP", idx)
	DllCall(NumGet(NumGet(1*ptinf)+ 8), "Uint", ptinf), ptinf:=0
	DllCall(NumGet(NumGet(1*ptlib)+44), "Uint", ptlib, "Uint", Unicode4Ansi(Name,Name), "Uint", 0, "UintP", ptinf, "UintP", memID, "UshortP", 1)
	DllCall(NumGet(NumGet(1*ptlib)+ 8), "Uint", ptlib)
	DllCall(NumGet(NumGet(1*ptinf)+12), "Uint", ptinf, "UintP", pattr)
	GUID := String4GUID(pattr)
	DllCall(NumGet(NumGet(1*ptinf)+76), "Uint", ptinf, "Uint" , pattr)
	DllCall(NumGet(NumGet(1*ptinf)+ 8), "Uint", ptinf)
	Return	GUID
}

GetTypeInfoOfGuid(pdisp, GUID, LCID = 0)
{
	DllCall(NumGet(NumGet(1*pdisp)+16), "Uint", pdisp, "Uint", 0, "Uint", LCID, "UintP", ptinf)
	DllCall(NumGet(NumGet(1*ptinf)+72), "Uint", ptinf, "UintP", ptlib, "UintP", idx)
	DllCall(NumGet(NumGet(1*ptinf)+ 8), "Uint", ptinf), ptinf := 0
	DllCall(NumGet(NumGet(1*ptlib)+24), "Uint", ptlib, "Uint", GUID4String(GUID,GUID), "UintP", ptinf)
	DllCall(NumGet(NumGet(1*ptlib)+ 8), "Uint", ptlib)
	Return	ptinf
}


ConnectObject(psource, prefix = "", DIID = "{00020400-0000-0000-C000-000000000046}")
{
	If	(DIID = "{00020400-0000-0000-C000-000000000046}")
		0+(pconn:=FindConnectionPoint(psource,DIID)) ? (DIID:=GetConnectionInterface(pconn))="{00020400-0000-0000-C000-000000000046}" ? DIID:=GetDefaultEvents(psource) : "" : pconn:=FindConnectionPoint(psource,DIID:=GetDefaultEvents(psource))
	Else	pconn:=FindConnectionPoint(psource,SubStr(DIID,1,1)="{" ? DIID : DIID:=GetGuidOfName(psource,DIID))
	If	!pconn || !(ptinf:=GetTypeInfoOfGuid(psource,DIID))
	{
		MsgBox, No Event Interface Exists! Now exit the application.
		ExitApp
	}
	psink:=CoTaskMemAlloc(40+StrLen(prefix)+1), NumPut(1,NumPut(CreateIDispatch(),psink+0)), NumPut(psource,NumPut(ptinf,psink+8))
	DllCall("RtlMoveMemory", "Uint", psink+24, "Uint", GUID4String(DIID,DIID), "Uint", 16)
	DllCall("RtlMoveMemory", "Uint", psink+40, "Uint", &prefix, "Uint", StrLen(prefix)+1)
	NumPut(Advise(pconn,psink),NumPut(pconn,psink+16))
	Return	psink
}

CreateObject(ByRef CLSID, ByRef IID, CLSCTX = 5)
{
	If	StrLen(CLSID)=38
		GUID4String(CLSID,CLSID)
	If	StrLen(IID)=38
		GUID4String(IID,IID)
	DllCall("ole32\CoCreateInstance", "str", CLSID, "Uint", 0, "Uint", CLSCTX, "str", IID, "UintP", ppv)
	Return	ppv
}

ActiveXObject(ProgID)
{
	DllCall("ole32\CoCreateInstance", "Uint", SubStr(ProgID,1,1)="{" ? GUID4String(ProgID,ProgID) : CLSID4ProgID(ProgID,ProgID), "Uint", 0, "Uint", 5, "Uint", GUID4String(IID_IDispatch,"{00020400-0000-0000-C000-000000000046}"), "UintP", pdisp)
	Return	GetDefaultInterface(pdisp)
}

GetObject(Moniker)
{
	DllCall("ole32\CoGetObject", "Uint", Unicode4Ansi(Moniker,Moniker), "Uint", 0, "Uint", GUID4String(IID_IDispatch,"{00020400-0000-0000-C000-000000000046}"), "UintP", pdisp)
	Return	GetDefaultInterface(pdisp)
}

GetActiveObject(ProgID)
{
	DllCall("oleaut32\GetActiveObject", "Uint", SubStr(ProgID,1,1)="{" ? GUID4String(ProgID,ProgID) : CLSID4ProgID(ProgID,ProgID), "Uint", 0, "UintP", punk)
	DllCall(NumGet(NumGet(1*punk)+0), "Uint", punk, "Uint", GUID4String(IID_IDispatch,"{00020400-0000-0000-C000-000000000046}"), "UintP", pdisp)
	DllCall(NumGet(NumGet(1*punk)+8), "Uint", punk)
	Return	GetDefaultInterface(pdisp)
}

CLSID4ProgID(ByRef CLSID, ProgID)
{
	VarSetCapacity(CLSID, 16)
	DllCall("ole32\CLSIDFromProgID", "Uint", Unicode4Ansi(ProgID,ProgID), "Uint", &CLSID)
	Return	&CLSID
}

GUID4String(ByRef CLSID, String)
{
	VarSetCapacity(CLSID, 16)
	DllCall("ole32\CLSIDFromString", "Uint", Unicode4Ansi(String,String,38), "Uint", &CLSID)
	Return	&CLSID
}

ProgID4CLSID(pCLSID)
{
	DllCall("ole32\ProgIDFromCLSID", "Uint", pCLSID, "UintP", pProgID)
	Return	Ansi4Unicode(pProgID) . SubStr(CoTaskMemFree(pProgID),1,0)
}

String4GUID(pGUID)
{
	VarSetCapacity(String, 38 * 2 + 1)
	DllCall("ole32\StringFromGUID2", "Uint", pGUID, "Uint", &String, "int", 39)
	Return	Ansi4Unicode(&String, 38)
}

IsEqualGUID(pGUID1, pGUID2)
{
	Return	DllCall("ole32\IsEqualGUID", "Uint", pGUID1, "Uint", pGUID2)
}

CoCreateGuid()
{
	VarSetCapacity(GUID, 16, 0)
	DllCall("ole32\CoCreateGuid", "Uint", &GUID)
	Return	String4GUID(&GUID)
}

CoTaskMemAlloc(cb)
{
	Return	DllCall("ole32\CoTaskMemAlloc", "Uint", cb)
}

CoTaskMemFree(pv)
{
	Return	DllCall("ole32\CoTaskMemFree", "Uint", pv)
}

CoInitialize()
{
	Return	DllCall("ole32\CoInitialize", "Uint", 0)
}

CoUninitialize()
{
	Return	DllCall("ole32\CoUninitialize")
}

OleInitialize()
{
	Return	DllCall("ole32\OleInitialize", "Uint", 0)
}

OleUninitialize()
{
	Return	DllCall("ole32\OleUninitialize")
}

SysAllocString(sString)
{
	Return	DllCall("oleaut32\SysAllocString", "Uint", Ansi2Unicode(sString,wString))
}

SysFreeString(bstr)
{
	Return	DllCall("oleaut32\SysFreeString", "Uint", bstr)
}

SysStringLen(bstr)
{
	Return	DllCall("oleaut32\SysStringLen", "Uint", bstr)
}

SafeArrayDestroy(psa)
{
	Return	DllCall("oleaut32\SafeArrayDestroy", "Uint", psa)
}

VariantClear(pvarg)
{
	Return	DllCall("oleaut32\VariantClear", "Uint", pvarg)
}

AtlAxWinInit(Version = "")
{
	CoInitialize()
	If !DllCall("GetModuleHandle", "str", "atl" . Version)
	    DllCall("LoadLibrary"    , "str", "atl" . Version)
	Return	DllCall("atl" . Version . "\AtlAxWinInit")
}

AtlAxWinTerm(Version = "")
{
	CoUninitialize()
	If hModule:=DllCall("GetModuleHandle", "str", "atl" . Version)
	Return	DllCall("FreeLibrary"    , "Uint", hModule)
}

AtlAxGetControl(hWnd, Version = "")
{
	DllCall("atl" . Version . "\AtlAxGetControl", "Uint", hWnd, "UintP", punk)
	pdsp:=QueryInterface(punk,IID_IDispatch:="{00020400-0000-0000-C000-000000000046}")
	Release(punk)
	Return	pdsp
}

AtlAxAttachControl(pdsp, hWnd, Version = "")
{
	punk:=QueryInterface(pdsp,IID_IUnknown:="{00000000-0000-0000-C000-000000000046}")
	DllCall("atl" . Version . "\AtlAxAttachControl", "Uint", punk, "Uint", hWnd, "Uint", 0)
	Release(punk)
}

AtlAxCreateControl(hWnd, Name, Version = "")
{
	VarSetCapacity(IID_NULL, 16, 0)
	DllCall("atl" . Version . "\AtlAxCreateControlEx", "Uint", Unicode4Ansi(Name,Name), "Uint", hWnd, "Uint", 0, "Uint", 0, "UintP", punk, "Uint", &IID_NULL, "Uint", 0)
	pdsp:=QueryInterface(punk,IID_IDispatch:="{00020400-0000-0000-C000-000000000046}")
	Release(punk)
	Return	pdsp
}

AtlAxCreateContainer(hWnd, l, t, w, h, Name = "", Version = "")
{
	Return	DllCall("CreateWindowEx", "Uint",0x200, "str", "AtlAxWin" . Version, "Uint", Name ? &Name : 0, "Uint", 0x54000000, "int", l, "int", t, "int", w, "int", h, "Uint", hWnd, "Uint", 0, "Uint", 0, "Uint", 0)
}

AtlAxGetContainer(pdsp)
{
	DllCall(NumGet(NumGet(1*pdsp)+ 0), "Uint", pdsp, "Uint", GUID4String(IID_IOleWindow,"{00000114-0000-0000-C000-000000000046}"), "UintP", pwin)
	DllCall(NumGet(NumGet(1*pwin)+12), "Uint", pwin, "UintP", hCtrl)
	DllCall(NumGet(NumGet(1*pwin)+ 8), "Uint", pwin)
	Return	DllCall("GetParent", "Uint", hCtrl)
}

Ansi4Unicode(pString, nSize = "")
{
	If (nSize = "")
	    nSize:=DllCall("kernel32\WideCharToMultiByte", "Uint", 0, "Uint", 0, "Uint", pString, "int", -1, "Uint", 0, "int",  0, "Uint", 0, "Uint", 0)
	VarSetCapacity(sString, nSize)
	DllCall("kernel32\WideCharToMultiByte", "Uint", 0, "Uint", 0, "Uint", pString, "int", -1, "str", sString, "int", nSize + 1, "Uint", 0, "Uint", 0)
	Return	sString
}

Unicode4Ansi(ByRef wString, sString, nSize = "")
{
	If (nSize = "")
	    nSize:=DllCall("kernel32\MultiByteToWideChar", "Uint", 0, "Uint", 0, "Uint", &sString, "int", -1, "Uint", 0, "int", 0)
	VarSetCapacity(wString, nSize * 2 + 1)
	DllCall("kernel32\MultiByteToWideChar", "Uint", 0, "Uint", 0, "Uint", &sString, "int", -1, "Uint", &wString, "int", nSize + 1)
	Return	&wString
}

Ansi2Unicode(ByRef sString, ByRef wString, nSize = "")
{
	If (nSize = "")
	    nSize:=DllCall("kernel32\MultiByteToWideChar", "Uint", 0, "Uint", 0, "Uint", &sString, "int", -1, "Uint", 0, "int", 0)
	VarSetCapacity(wString, nSize * 2 + 1)
	DllCall("kernel32\MultiByteToWideChar", "Uint", 0, "Uint", 0, "Uint", &sString, "int", -1, "Uint", &wString, "int", nSize + 1)
	Return	&wString
}

Unicode2Ansi(ByRef wString, ByRef sString, nSize = "")
{
	pString := wString + 0 > 65535 ? wString : &wString
	If (nSize = "")
	    nSize:=DllCall("kernel32\WideCharToMultiByte", "Uint", 0, "Uint", 0, "Uint", pString, "int", -1, "Uint", 0, "int",  0, "Uint", 0, "Uint", 0)
	VarSetCapacity(sString, nSize)
	DllCall("kernel32\WideCharToMultiByte", "Uint", 0, "Uint", 0, "Uint", pString, "int", -1, "str", sString, "int", nSize + 1, "Uint", 0, "Uint", 0)
	Return	&sString
}

DecodeInteger(ref, nSize = 4)
{
	DllCall("RtlMoveMemory", "int64P", val, "Uint", ref, "Uint", nSize)
	Return	val
}

EncodeInteger(ref, val = 0, nSize = 4)
{
	DllCall("RtlMoveMemory", "Uint", ref, "int64P", val, "Uint", nSize)
}

ScriptControl(sCode, sLang = "", bExec = False, sName = "", pdisp = 0, bGlobal = False)
{
	CoInitialize()
	psc  :=	ActiveXObject("MSScriptControl.ScriptControl")
		Invoke(psc, "Language=", sLang ? sLang : "VBScript")
	sName ?	Invoke(psc, "AddObject", sName, "+" . pdisp, bGlobal) : ""
	ret  :=	Invoke(psc, bExec ? "ExecuteStatement" : "Eval", sCode)
	Release(psc)
	CoUninitialize()
	Return	ret
}
; #include CoHelper.ahk




















HashTable_Set( pdic, sKey, sItm )
{
	pKey := SysAllocString(sKey)
	VarSetCapacity(var1, 8 * 2, 0)
	EncodeInteger(&var1 + 0, 8)
	EncodeInteger(&var1 + 8, pKey)
	pItm := SysAllocString(sItm)
	VarSetCapacity(var2, 8 * 2, 0)
	EncodeInteger(&var2 + 0, 8)
	EncodeInteger(&var2 + 8, pItm)
	DllCall(VTable(pdic, 8), "Uint", pdic, "Uint", &var1, "Uint", &var2)
	SysFreeString(pKey)
	SysFreeString(pItm)
}

HashTable_Get( pdic, sKey )
{
	pKey := SysAllocString(sKey)
	VarSetCapacity(var1, 8 * 2, 0)
	EncodeInteger(&var1 + 0, 8)
	EncodeInteger(&var1 + 8, pKey)
	DllCall(VTable(pdic, 12), "Uint", pdic, "Uint", &var1, "intP", bExist)
	If bExist
	{
		VarSetCapacity(var2, 8 * 2, 0)
		DllCall(VTable(pdic, 9), "Uint", pdic, "Uint", &var1, "Uint", &var2)
		pItm := DecodeInteger(&var2 + 8)
		Unicode2Ansi(pItm, sItm)
		SysFreeString(pItm)
	}
	SysFreeString(pKey)
	Return sItm
}

HashTable_New()
{
	CoInitialize()
	CLSID_Dictionary := "{EE09B103-97E0-11CF-978F-00A02463E06F}"
	IID_IDictionary := "{42C642C1-97E1-11CF-978F-00A02463E06F}"
	pdic := CreateObject(CLSID_Dictionary, IID_IDictionary)
	DllCall(VTable(pdic, 18), "Uint", pdic, "int", 1)
	return pdic
}

; #include CoHelper.ahk
; #Include HashTableSystemCalls.ahk
; #include HashTable.ahk




; #Include SendU.ahk
getGlobal( var )
{
	global
	return %var% . ""
}

setGlobal( var, value )
{
	global
	%var% := value
}
; #Include getGlobal.ahk
; #Include HashTable.ahk
iniReadBoolean( file, group, key, default = "" )
{
	IniRead, t, %file%, %group%, %key%, %default%
	if ( t == "1" || t == "yes" || t == "y" || t == "true" )
		return true
	else
		return false
}
; #Include iniReadBoolean.ahk










detectDeadKeysInCurrentLayout()
{
	DeadKeysInCurrentLayout =

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
		clipboard =
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
; #Include detectDeadKeysInCurrentLayout.ahk








virtualKeyCodeFromName( name )
{
	if ( name == "0")
		return "30"
	if ( name == "1")
		return "31"
	if ( name == "2")
		return "32"
	if ( name == "3")
		return "33"
	if ( name == "4")
		return "34"
	if ( name == "5")
		return "35"
	if ( name == "6")
		return "36"
	if ( name == "7")
		return "37"
	if ( name == "8")
		return "38"
	if ( name == "9")
		return "39"
	if ( name == "A")
		return "41"
	if ( name == "B")
		return "42"
	if ( name == "C")
		return "43"
	if ( name == "D")
		return "44"
	if ( name == "E")
		return "45"
	if ( name == "F")
		return "46"
	if ( name == "G")
		return "47"
	if ( name == "H")
		return "48"
	if ( name == "I")
		return "49"
	if ( name == "J")
		return "4A"
	if ( name == "K")
		return "4B"
	if ( name == "L")
		return "4C"
	if ( name == "M")
		return "4D"
	if ( name == "N")
		return "4E"
	if ( name == "O")
		return "4F"
	if ( name == "P")
		return "50"
	if ( name == "Q")
		return "51"
	if ( name == "R")
		return "52"
	if ( name == "S")
		return "53"
	if ( name == "T")
		return "54"
	if ( name == "U")
		return "55"
	if ( name == "V")
		return "56"
	if ( name == "W")
		return "57"
	if ( name == "X")
		return "58"
	if ( name == "Y")
		return "59"
	if ( name == "Z")
		return "5A"
	if ( name == "OEM_1")
		return "BA"
	if ( name == "OEM_PLUS")
		return "BB"
	if ( name == "OEM_COMMA")
		return "BC"
	if ( name == "OEM_MINUS")
		return "BD"
	if ( name == "OEM_PERIOD")
		return "BE"
	if ( name == "OEM_2")
		return "BF"
	if ( name == "OEM_3")
		return "C0"
	if ( name == "OEM_4")
		return "DB"
	if ( name == "OEM_5")
		return "DC"
	if ( name == "OEM_6")
		return "DD"
	if ( name == "OEM_7")
		return "DE"
	if ( name == "OEM_8")
		return "DF"
	if ( name == "OEM_102")
		return "E2"



	if ( name == "LBUTTON")
		return "01"
	if ( name == "RBUTTON")
		return "02"
	if ( name == "CANCEL")
		return "03"
	if ( name == "MBUTTON")
		return "04"
	if ( name == "XBUTTON1")
		return "05"
	if ( name == "XBUTTON2")
		return "06"
	if ( name == "BACK")
		return "08"
	if ( name == "TAB")
		return "09"
	if ( name == "CLEAR")
		return "0C"
	if ( name == "RETURN")
		return "0D"
	if ( name == "SHIFT")
		return "10"
	if ( name == "CONTROL")
		return "11"
	if ( name == "MENU")
		return "12"
	if ( name == "PAUSE")
		return "13"
	if ( name == "CAPITAL")
		return "14"
	if ( name == "KANA")
		return "15"
	if ( name == "HANGUEL")
		return "15"
	if ( name == "HANGUL")
		return "15"
	if ( name == "JUNJA")
		return "17"
	if ( name == "FINAL")
		return "18"
	if ( name == "HANJA")
		return "19"
	if ( name == "KANJI")
		return "19"
	if ( name == "ESCAPE")
		return "1B"
	if ( name == "CONVERT")
		return "1C"
	if ( name == "NONCONVERT")
		return "1D"
	if ( name == "ACCEPT")
		return "1E"
	if ( name == "MODECHANGE")
		return "1F"
	if ( name == "SPACE")
		return "20"
	if ( name == "PRIOR")
		return "21"
	if ( name == "NEXT")
		return "22"
	if ( name == "END")
		return "23"
	if ( name == "HOME")
		return "24"
	if ( name == "LEFT")
		return "25"
	if ( name == "UP")
		return "26"
	if ( name == "RIGHT")
		return "27"
	if ( name == "DOWN")
		return "28"
	if ( name == "SELECT")
		return "29"
	if ( name == "PRINT")
		return "2A"
	if ( name == "EXECUTE")
		return "2B"
	if ( name == "SNAPSHOT")
		return "2C"
	if ( name == "INSERT")
		return "2D"
	if ( name == "DELETE")
		return "2E"
	if ( name == "HELP")
		return "2F"
	if ( name == "LWIN")
		return "5B"
	if ( name == "RWIN")
		return "5C"
	if ( name == "APPS")
		return "5D"
	if ( name == "SLEEP")
		return "5F"
	if ( name == "NUMPAD0")
		return "60"
	if ( name == "NUMPAD1")
		return "61"
	if ( name == "NUMPAD2")
		return "62"
	if ( name == "NUMPAD3")
		return "63"
	if ( name == "NUMPAD4")
		return "64"
	if ( name == "NUMPAD5")
		return "65"
	if ( name == "NUMPAD6")
		return "66"
	if ( name == "NUMPAD7")
		return "67"
	if ( name == "NUMPAD8")
		return "68"
	if ( name == "NUMPAD9")
		return "69"
	if ( name == "MULTIPLY")
		return "6A"
	if ( name == "ADD")
		return "6B"
	if ( name == "SEPARATOR")
		return "6C"
	if ( name == "SUBTRACT")
		return "6D"
	if ( name == "DECIMAL")
		return "6E"
	if ( name == "DIVIDE")
		return "6F"
	if ( name == "F1")
		return "70"
	if ( name == "F2")
		return "71"
	if ( name == "F3")
		return "72"
	if ( name == "F4")
		return "73"
	if ( name == "F5")
		return "74"
	if ( name == "F6")
		return "75"
	if ( name == "F7")
		return "76"
	if ( name == "F8")
		return "77"
	if ( name == "F9")
		return "78"
	if ( name == "F10")
		return "79"
	if ( name == "F11")
		return "7A"
	if ( name == "F12")
		return "7B"
	if ( name == "F13")
		return "7C"
	if ( name == "F14")
		return "7D"
	if ( name == "F15")
		return "7E"
	if ( name == "F16")
		return "7F"
	if ( name == "F17")
		return "80"
	if ( name == "F18")
		return "81"
	if ( name == "F19")
		return "82"
	if ( name == "F20")
		return "83"
	if ( name == "F21")
		return "84"
	if ( name == "F22")
		return "85"
	if ( name == "F23")
		return "86"
	if ( name == "F24")
		return "87"
	if ( name == "NUMLOCK")
		return "90"
	if ( name == "SCROLL")
		return "91"
	if ( name == "OEM_NEC_EQUAL")
		return "92"
	if ( name == "OEM_FJ_JISHO")
		return "92"
	if ( name == "OEM_FJ_MASSHOU")
		return "93"
	if ( name == "OEM_FJ_TOUROKU")
		return "94"
	if ( name == "OEM_FJ_LOYA")
		return "95"
	if ( name == "OEM_FJ_ROYA")
		return "96"
	if ( name == "LSHIFT")
		return "A0"
	if ( name == "RSHIFT")
		return "A1"
	if ( name == "LCONTROL")
		return "A2"
	if ( name == "RCONTROL")
		return "A3"
	if ( name == "LMENU")
		return "A4"
	if ( name == "RMENU")
		return "A5"
	if ( name == "BROWSER_BACK")
		return "A6"
	if ( name == "BROWSER_FORWARD")
		return "A7"
	if ( name == "BROWSER_REFRESH")
		return "A8"
	if ( name == "BROWSER_STOP")
		return "A9"
	if ( name == "BROWSER_SEARCH")
		return "AA"
	if ( name == "BROWSER_FAVORITES")
		return "AB"
	if ( name == "BROWSER_HOME")
		return "AC"
	if ( name == "VOLUME_MUTE")
		return "AD"
	if ( name == "VOLUME_DOWN")
		return "AE"
	if ( name == "VOLUME_UP")
		return "AF"
	if ( name == "MEDIA_NEXT_TRACK")
		return "B0"
	if ( name == "MEDIA_PREV_TRACK")
		return "B1"
	if ( name == "MEDIA_STOP")
		return "B2"
	if ( name == "MEDIA_PLAY_PAUSE")
		return "B3"
	if ( name == "LAUNCH_MAIL")
		return "B4"
	if ( name == "LAUNCH_MEDIA_SELECT")
		return "B5"
	if ( name == "LAUNCH_APP1")
		return "B6"
	if ( name == "LAUNCH_APP2")
		return "B7"
	if ( name == "PROCESSKEY")
		return "E5"
	if ( name == "PACKET")
		return "E7"
	if ( name == "OEM_RESET")
		return "E9"
	if ( name == "OEM_JUMP")
		return "EA"
	if ( name == "OEM_PA1")
		return "EB"
	if ( name == "OEM_PA2")
		return "EC"
	if ( name == "OEM_PA3")
		return "ED"
	if ( name == "OEM_WSCTRL")
		return "EE"
	if ( name == "OEM_CUSEL")
		return "EF"
	if ( name == "OEM_ATTN")
		return "F0"
	if ( name == "OEM_FINNISH")
		return "F1"
	if ( name == "OEM_COPY")
		return "F2"
	if ( name == "OEM_AUTO")
		return "F3"
	if ( name == "OEM_ENLW")
		return "F4"
	if ( name == "OEM_BACKTAB")
		return "F5"
	if ( name == "ATTN")
		return "F6"
	if ( name == "CRSEL")
		return "F7"
	if ( name == "EXSEL")
		return "F8"
	if ( name == "EREOF")
		return "F9"
	if ( name == "PLAY")
		return "FA"
	if ( name == "ZOOM")
		return "FB"
	if ( name == "NONAME")
		return "FC"
	if ( name == "PA1")
		return "FD"
	if ( name == "OEM_CLEAR")
		return "FE"
	return "00"
}
; #Include virtualKeyCodeFromName.ahk








getDeadKeysOfSystemsActiveLayout()
{
	l1033 = -1
	l1038 = ^
	l1036 = ~^`

	WinGet, WinID,, A
	ThreadID := DllCall("GetWindowThreadProcessId", "Int", WinID, "Int", 0)
	Layout := DllCall("GetKeyboardLayout", "Int", ThreadID)
	Layout := ( Layout & 0xFFFFFFFF )>>16
	if ( l%Layout% == "-1" )
		return ""
	else if ( l%Layout% == "" )
		return "^"
	else
		return l%Layout%
}
; #Include getDeadKeysOfSystemsActiveLayout.ahk

getLanguageStringFromDigits( langc )
{
	languageCode_0436 = Afrikaans
	languageCode_041c = Albanian
	languageCode_0401 = Arabic_Saudi_Arabia
	languageCode_0801 = Arabic_Iraq
	languageCode_0c01 = Arabic_Egypt
	languageCode_0401 = Arabic_Saudi_Arabia
	languageCode_0801 = Arabic_Iraq
	languageCode_0c01 = Arabic_Egypt
	languageCode_1001 = Arabic_Libya
	languageCode_1401 = Arabic_Algeria
	languageCode_1801 = Arabic_Morocco
	languageCode_1c01 = Arabic_Tunisia
	languageCode_2001 = Arabic_Oman
	languageCode_2401 = Arabic_Yemen
	languageCode_2801 = Arabic_Syria
	languageCode_2c01 = Arabic_Jordan
	languageCode_3001 = Arabic_Lebanon
	languageCode_3401 = Arabic_Kuwait
	languageCode_3801 = Arabic_UAE
	languageCode_3c01 = Arabic_Bahrain
	languageCode_4001 = Arabic_Qatar
	languageCode_042b = Armenian
	languageCode_042c = Azeri_Latin
	languageCode_082c = Azeri_Cyrillic
	languageCode_042d = Basque
	languageCode_0423 = Belarusian
	languageCode_0402 = Bulgarian
	languageCode_0403 = Catalan
	languageCode_0404 = Chinese_Taiwan
	languageCode_0804 = Chinese_PRC
	languageCode_0c04 = Chinese_Hong_Kong
	languageCode_1004 = Chinese_Singapore
	languageCode_1404 = Chinese_Macau
	languageCode_041a = Croatian
	languageCode_0405 = Czech
	languageCode_0406 = Danish
	languageCode_0413 = Dutch_Standard
	languageCode_0813 = Dutch_Belgian
	languageCode_0409 = English_United_States
	languageCode_0809 = English_United_Kingdom
	languageCode_0c09 = English_Australian
	languageCode_1009 = English_Canadian
	languageCode_1409 = English_New_Zealand
	languageCode_1809 = English_Irish
	languageCode_1c09 = English_South_Africa
	languageCode_2009 = English_Jamaica
	languageCode_2409 = English_Caribbean
	languageCode_2809 = English_Belize
	languageCode_2c09 = English_Trinidad
	languageCode_3009 = English_Zimbabwe
	languageCode_3409 = English_Philippines
	languageCode_0425 = Estonian
	languageCode_0438 = Faeroese
	languageCode_0429 = Farsi
	languageCode_040b = Finnish
	languageCode_040c = French_Standard
	languageCode_080c = French_Belgian
	languageCode_0c0c = French_Canadian
	languageCode_100c = French_Swiss
	languageCode_140c = French_Luxembourg
	languageCode_180c = French_Monaco
	languageCode_0437 = Georgian
	languageCode_0407 = German_Standard
	languageCode_0807 = German_Swiss
	languageCode_0c07 = German_Austrian
	languageCode_1007 = German_Luxembourg
	languageCode_1407 = German_Liechtenstein
	languageCode_0408 = Greek
	languageCode_040d = Hebrew
	languageCode_0439 = Hindi
	languageCode_040e = Hungarian
	languageCode_040f = Icelandic
	languageCode_0421 = Indonesian
	languageCode_0410 = Italian_Standard
	languageCode_0810 = Italian_Swiss
	languageCode_0411 = Japanese
	languageCode_043f = Kazakh
	languageCode_0457 = Konkani
	languageCode_0412 = Korean
	languageCode_0426 = Latvian
	languageCode_0427 = Lithuanian
	languageCode_042f = Macedonian
	languageCode_043e = Malay_Malaysia
	languageCode_083e = Malay_Brunei_Darussalam
	languageCode_044e = Marathi
	languageCode_0414 = Norwegian_Bokmal
	languageCode_0814 = Norwegian_Nynorsk
	languageCode_0415 = Polish
	languageCode_0416 = Portuguese_Brazilian
	languageCode_0816 = Portuguese_Standard
	languageCode_0418 = Romanian
	languageCode_0419 = Russian
	languageCode_044f = Sanskrit
	languageCode_081a = Serbian_Latin
	languageCode_0c1a = Serbian_Cyrillic
	languageCode_041b = Slovak
	languageCode_0424 = Slovenian
	languageCode_040a = Spanish_Traditional_Sort
	languageCode_080a = Spanish_Mexican
	languageCode_0c0a = Spanish_Modern_Sort
	languageCode_100a = Spanish_Guatemala
	languageCode_140a = Spanish_Costa_Rica
	languageCode_180a = Spanish_Panama
	languageCode_1c0a = Spanish_Dominican_Republic
	languageCode_200a = Spanish_Venezuela
	languageCode_240a = Spanish_Colombia
	languageCode_280a = Spanish_Peru
	languageCode_2c0a = Spanish_Argentina
	languageCode_300a = Spanish_Ecuador
	languageCode_340a = Spanish_Chile
	languageCode_380a = Spanish_Uruguay
	languageCode_3c0a = Spanish_Paraguay
	languageCode_400a = Spanish_Bolivia
	languageCode_440a = Spanish_El_Salvador
	languageCode_480a = Spanish_Honduras
	languageCode_4c0a = Spanish_Nicaragua
	languageCode_500a = Spanish_Puerto_Rico
	languageCode_0441 = Swahili
	languageCode_041d = Swedish
	languageCode_081d = Swedish_Finland
	languageCode_0449 = Tamil
	languageCode_0444 = Tatar
	languageCode_041e = Thai
	languageCode_041f = Turkish
	languageCode_0422 = Ukrainian
	languageCode_0420 = Urdu
	languageCode_0443 = Uzbek_Latin
	languageCode_0843 = Uzbek_Cyrillic
	languageCode_042a = Vietnamese

	langc := substr( langc, -3 )
	return languageCode_%langc%
}
; #Include getLanguageStringFromDigits.ahk
; #Include pkl_main.ahk
