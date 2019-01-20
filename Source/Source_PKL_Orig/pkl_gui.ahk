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
		MI_SetMenuItemIcon(tr, 1, A_AhkPath, 1, 16) ; open
		MI_SetMenuItemIcon(tr, 2, A_WinDir "\hh.exe", 1, 16) ; help
		SplitPath, A_AhkPath,, SpyPath
		SpyPath = %SpyPath%\AU3_Spy.exe
		MI_SetMenuItemIcon(tr, 4, SpyPath,   1, 16) ; spy
		MI_SetMenuItemIcon(tr, 5, "SHELL32.dll", 147, 16) ; reload
		MI_SetMenuItemIcon(tr, 6, A_AhkPath, 2, 16) ; edit
		MI_SetMenuItemIcon(tr, 8, A_AhkPath, 3, 16) ; suspend
		MI_SetMenuItemIcon(tr, 9, A_AhkPath, 4, 16) ; pause
		MI_SetMenuItemIcon(tr, 10, "SHELL32.dll", 28, 16) ; exit
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
		; It is necessary to hook the tray icon for owner-drawing to work.
		; (Owner-drawing is not used on Windows Vista.)
		MI_SetMenuStyle( tr, 0x4000000 ) ; MNS_CHECKORBMP (optional)
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

	text = ;
	text = %text%
	Gui, Add, Text, , Portable Keyboard Layout v%pklVersion% (%compiledAt%)
	Gui, Add, Edit, , http://pkl.sourceforge.net/
	Gui, Add, Text, , ......................................................................
	Gui, Add, Text, , (c) FARKAS, Mate, 2007-2010
	Gui, Add, Text, , %license%
	Gui, Add, Text, , %infos%
	Gui, Add, Edit, , http://www.gnu.org/licenses/gpl-3.0.txt
	Gui, Add, Text, , ......................................................................
	text = ;
	text = %text%%contributors%:
	text = %text%`nmajkenitor (Ini.ahk)
	text = %text%`nLexicos (MI.ahk)
	text = %text%`nShimanov && Laszlo Hars (SendU.ahk)
	text = %text%`n%translatorName% (%translationName%)
	Gui, Add, Text, , %text%
	Gui, Add, Text, , ......................................................................
	text = ;
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
	; Parameter:
	; 0 = display, if activated
	;-1 = deactivate
	; 1 = activate
	; 2 = toggle
	; 3 = suspend on
	; 4 = suspend off
	
	global CurrentDeadKeys
	global CurrentDeadKeyName
	
	static guiActiveBeforeSuspend := 0
	static guiActive := 0
	static prevFile
	static HelperImage
	static displayOnTop := 0
	static yPosition := -1
	static imgWidth
	static imgHeight
	static LayoutDir := 0
	static hasAltGr
	static extendKey
	
	if ( LayoutDir == 0 )
	{
		LayoutDir := getLayoutInfo( "dir" )
		hasAltGr  := getLayoutInfo( "hasAltGr" )
		extendKey := getLayoutInfo( "extendKey" )
	}
	
	if ( activate == 2 ) ; toggle
		activate := 1 - 2 * guiActive
	if ( activate == 1 ) { ; activate
		guiActive = 1
	} else if ( activate == -1 ) { ; deactivate
		guiActive = 0
	} else if ( activate == 3 ) { ; suspend on
		guiActiveBeforeSuspend := guiActive
		activate = -1
		guiActive = 0
	} else if ( activate == 4 ) { ; suspend off
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
		GuiControl,2:, HelperImage, *w%imgWidth% *h%imgHeight% %LayoutDir%\state0.png
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
			fileName = deadkey%CurrentDeadKeyName%
		} else {
			fileName = deadkey%CurrentDeadKeyName%sh
			if ( not FileExist( LayoutDir . "\" . filename . ".png" ) )
				fileName = deadkey%CurrentDeadKeyName%
		}
	} else if ( extendKey && getKeyState( extendKey, "P" ) ) {
		fileName = extend
	} else {
		state = 0
		state += 1 * getKeyState( "Shift" )
		state += 6 * ( hasAltGr * AltGrIsPressed() )
		fileName = state%state%
	}
	if ( not FileExist( LayoutDir . "\" . fileName . ".png" ) )
		fileName = state0
	
	if ( prevFile == fileName )
		return
		
	prevFile := fileName
	GuiControl,2:, HelperImage, *w%imgWidth% *h%imgHeight% %LayoutDir%\%fileName%.png
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
	if ( lParam == 0x205 ) { ; WM_RBUTTONUP
		if ( A_OSVersion != "WIN_XP" ) ; HOOK for Windows XP
			return
		; Show menu to allow owner-drawing.
		MI_ShowMenu( getPklInfo( "trayMenuHandler" ) )
		return 0 ; Withouth this double right click is without icons
	} else if ( lParam ==0x201 ) { ; WM_LBUTTONDOWN
		gosub ToggleSuspend
	}
}
