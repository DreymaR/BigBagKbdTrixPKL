pkl_set_tray_menu()
{
	global gPv_DebugInfo	; eD: Show extra technical info and the Reset hotkey
	
	ExitAppHotkey := getReadableHotkeyString( getPklInfo( "ExitAppHotkey" ) )
	ChangeLayoutHotkey := getReadableHotkeyString( getPklInfo( "ChangeLayoutHotkey" ) )
	SuspendHotkey := getReadableHotkeyString( getPklInfo( "SuspendHotkey" ) )
	RefreshHotkey := getReadableHotkeyString( getPklInfo( "RefreshHotkey" ) )
	HelpImageHotkey := getReadableHotkeyString( getPklInfo( "DisplayHelpImageHotkey" ) )
	
	Layout := getLayoutInfo( "active" )
	activeLayoutName := ""
	countOfLayouts := getLayoutInfo( "countOfLayouts" )
	
	aboutmeMenuItem := pklLocaleString(9)
	keyhistMenuItem := getLayoutInfo( "keyhistMenuItem" )
	refreshMenuItem := getLayoutInfo( "refreshMenuItem" )
	suspendMenuItem := pklLocaleString(10)
	exitappMenuItem := pklLocaleString(11)
	deadkeyMenuItem := pklLocaleString(12)
	helpimgMenuItem := pklLocaleString(15)
	chnglayMenuItem := pklLocaleString(18)
	if ( SuspendHotkey != "" )
		suspendMenuItem .= " (" . FixAtForMenu( SuspendHotkey ) . ")"
	if ( RefreshHotkey != "" )
		refreshMenuItem .= " (" . FixAtForMenu( RefreshHotkey ) . ")"
	if ( ExitAppHotkey != "" )
		exitappMenuItem .= " (" . FixAtForMenu( ExitAppHotkey ) . ")"
	if ( HelpImageHotkey != "" )
		helpimgMenuItem .= " (" . FixAtForMenu( HelpImageHotkey ) . ")"
	if ( ChangeLayoutHotkey != "" )
		chnglayMenuItem .= " (" . FixAtForMenu( ChangeLayoutHotkey ) . ")"
	setPklInfo( "DisplayHelpImageMenuName", helpimgMenuItem )
	layoutsMenu := pklLocaleString(19)
	
	Loop, % countOfLayouts
	{
		layName := getLayoutInfo( "layout" . A_Index . "name" )
		layCode := getLayoutInfo( "layout" . A_Index . "code" )
		Menu, changeLayout, add, %layName%, changeLayoutMenu
		if ( layCode == Layout ) {
			Menu, changeLayout, Default, %layName%
			Menu, changeLayout, Check, %layName%
			activeLayoutName := layName
		}
		
		icon = Layouts\%layCode%\on.ico
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
		Menu, Tray, add,
		iconNum = 11
	} else {
		Menu, Tray, NoStandard
		iconNum = 0
	}
	
	; eD: Icon list found at http://help4windows.com/ - but the numbers there are 1 lower.
	Menu, Tray, add, %aboutmeMenuItem%, showAbout
	tr := MI_GetMenuHandle("Tray")
	MI_SetMenuItemIcon(tr, ++iconNum, "SHELL32.dll", 24, 16) ; about/question icon
	if ( gPv_DebugInfo ) {
		Menu, Tray, add, %keyhistMenuItem%, keyHistory
		MI_SetMenuItemIcon(tr, ++iconNum, "SHELL32.dll", 222, 16) ; info icon
;		Menu, Tray, Icon, %keyhistMenuItem%, SHELL32.dll, 222, 16 ; eD: TEST
		Menu, Tray, add, %deadkeyMenuItem%, detectDeadKeysInCurrentLayout
		MI_SetMenuItemIcon(tr, ++iconNum, "SHELL32.dll", 25, 16) ; "speed" icon
	}
	Menu, Tray, add, %helpimgMenuItem%, displayHelpImageToggle
	MI_SetMenuItemIcon(tr, ++iconNum, "SHELL32.dll", 174, 16) ; keyboard icon, was 116 - film icon
	if ( countOfLayouts > 1 ) {
		Menu, Tray, add,
		++iconNum
		Menu, Tray, add, %layoutsMenu%, :changeLayout
		MI_SetMenuItemIcon(tr, ++iconNum, "SHELL32.dll", 44, 16) ; star icon
		Menu, Tray, add, %chnglayMenuItem%, changeTheActiveLayout
		MI_SetMenuItemIcon(tr, ++iconNum, "SHELL32.dll", 138, 16) ; forward arrow icon
	}
	if ( gPv_DebugInfo ) {
		Menu, Tray, add, %refreshMenuItem%, rerunWithSameLayout ; eD: Refresh option
		MI_SetMenuItemIcon(tr, ++iconNum, "SHELL32.dll", 239, 16) ; refresh arrows icon
	}
	Menu, Tray, add, %suspendMenuItem%, toggleSuspend
	MI_SetMenuItemIcon(tr, ++iconNum, "SHELL32.dll", 110, 16) ; crossed circle icon
	Menu, Tray, add,
	++iconNum
	Menu, Tray, add, %exitappMenuItem%, exitApp
	MI_SetMenuItemIcon(tr, ++iconNum, "SHELL32.dll", 28, 16) ; power off icon
	pklAppName := getPklInfo( "pklName" )
	pklVersion := getPklInfo( "pklVers" )
	Menu, Tray, Tip, %pklAppName% v%pklVersion%`n(%activeLayoutName%)

	Menu, Tray, Click, 2
	if ( countOfLayouts > 1 ) {
		Menu, Tray, Default, %chnglayMenuItem%
	} else {
		Menu, Tray, Default, %suspendMenuItem%
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
	global gPv_LayIniFil	; eD: "layout.ini"
	global gPv_DebugInfo	; eD: Show extra technical info and the Reset hotkey
	
	mslid := getWinLocaleID() ; eD: Get the Windows locale ID
	dkstr := getDeadKeysInCurrentLayout() ; eD: Show the current Windows layout's dead key string
	dkstr := dkstr ? dkstr : "<none found>"
	lfile := getLayoutInfo( "dir" ) . "\" . gPv_LayIniFil
	pklAppName := getPklInfo( "pklName" )
	pklMainURL := "http://pkl.sourceforge.net"
	pklProgURL := getPklInfo( "pkl_URL" )
	pklVersion := getPklInfo( "pklVers" )
	compiledAt := getPklInfo( "pklComp" )

	unknown := pklLocaleString(3)
	active_layout := pklLocaleString(4)
	locVersion := pklLocaleString(5)
	locLanguage := pklLocaleString(6)
	locCopyright := pklLocaleString(7)
	locCompany := pklLocaleString(8)
	license := pklLocaleString(13)
	infos := pklLocaleString(14)
	contributors := pklLocaleString(20)
	translationName := pklLocaleString(21)
	translatorName := pklLocaleString(22)
	
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
	Gui, Add, Text, , %pklAppName%, v%pklVersion% (%compiledAt%)
	Gui, Add, Edit, , %pklMainURL%
	if ( pklProgURL != pklMainURL )
		Gui, Add, Edit, , %pklProgURL%
	Gui, Add, Text, , ......................................................................
	Gui, Add, Text, , (c) FARKAS, Máté, 2007-2010
	Gui, Add, Text, , %infos%
	Gui, Add, Text, , %license%
	Gui, Add, Edit, , http://www.gnu.org/licenses/gpl-3.0.txt
	Gui, Add, Text, , ......................................................................
	text = ;
	text = %text%%contributors%:
	text = %text%`nOEystein "DreymaR" Gadmar: PKL[eD]	; edition DreymaR
	text = %text%`nAutoHotkey authors && contributors
	text = %text%`n- Chris Mallet: AHK
	text = %text%`n- The AutoHotkey Foundation: AHK v1.1
	text = %text%`n- Steve Gray alias Lexikos: AHK v1.1, MI.ahk,...
	text = %text%`n- majkinetor: Ini.ahk
	text = %text%`n- Shimanov && Laszlo Hars: SendU.ahk
	if ( translatorName != "[[Translator name]]" )
		text = %text%`n`n%translatorName%: %translationName%
	Gui, Add, Text, , %text%
	Gui, Add, Text, , ......................................................................
	text = ;
	text = %text%%ACTIVE_LAYOUT%: %lname%
	text = %text%`n%locVersion%: %lver%
	text = %text%`n%locLanguage%: %llang%
	text = %text%`n%locCopyright%: %lcopy%
	text = %text%`n%locCompany%: %lcomp%
	Gui, Add, Text, , %text%
	Gui, Add, Edit, , %lwebsite%
	Gui, Add, Text, , ......................................................................
	if ( gPv_DebugInfo ) {
		text = ; eD: Show MS Locale ID and current underlying layout dead keys
		text = %text%Current Microsoft Windows Locale ID: %mslid%
		text = %text%`nDead keys in current Windows layout: %dkstr%
		Gui, Add, Text, , %text%
	}
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
	
	global gPv_CurDKsNum	; eD: Current # of dead keys active
	global gPv_CurDKName	; eD: Current dead key's name
	global gPv_Lay_eDFil	; eD: My extra "layout.ini" file
	
	static guiActiveBeforeSuspend := 0
	static guiActive := 0
	static prevFile
	static HelperImage
	static displayOnTop := 0
	static yPosition := -1
	static imgWidth_
	static imgHeight
	static layoutDir := 0
	static hasAltGr
	static extendKey
	
; eD: Added and reworked help image functionality
;     - Separate background image
;     - Transparent color for images (not yet working - need to use separate GUIs for Bg and key imgs!?)
;     - Overall image opacity
;     - Adjustable top/bottom screen gutters
	static DreyLayIni
	static HelperBgImg
	static imgBgImage
	static imgBgColor
	static imgTopGutr
	static imgLowGutr
	static imgOpacity
	
	if ( layoutDir == 0 )
	{
		layoutDir := getLayoutInfo( "dir" )
		hasAltGr  := getLayoutInfo( "hasAltGr" )
		extendKey := getLayoutInfo( "extendKey" )
		DreyLayIni := layoutDir . "\" . gPv_Lay_eDFil
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
		Menu, Tray, Check, % getPklInfo( "DisplayHelpImageMenuName" )
		IniRead, imgBgImage, %DreyLayIni%, hlpimg, hlpimg_bgimage, %layoutDir%\backgr.png
		; eD: The default imgBgImage may not be robust if there's no backgr.png nor DreymaR_layout.ini entry?
		;     Therefore, replace the above default by an if statement checking whether the file exists?!
		IniRead, imgBgColor, %DreyLayIni%, hlpimg, hlpimg_bgcolor, fefeff
		IniRead, imgLowGutr, %DreyLayIni%, hlpimg, img_low_margin, 60
		IniRead, imgTopGutr, %DreyLayIni%, hlpimg, img_top_margin, 10
		IniRead, imgOpacity, %DreyLayIni%, hlpimg, img_opacity, 255
		if ( yPosition == -1 ) {
			IniRead, imgWidth_, %DreyLayIni%, hlpimg, img_width_, 300
			IniRead, imgHeight, %DreyLayIni%, hlpimg, img_height, 100
			yPosition := A_ScreenHeight - imgHeight - imgLowGutr ; eD: Low margin used to be 60, 40 is no margin
		}
		
/*
		; eD: Seems that vVv got transparent color to work with separate GUIs for front/back. I'll try that then?
		;     NOTE: This isn't working yet.
		Gui, 3:+AlwaysOnTop -Border -Caption +ToolWindow ; eD: +LastFound not needed?
		Gui, 3:margin, 0, 0
		Gui, 3:Color, %imgBgColor%
		Gui, 3:Add, Pic, xm vHelperBgImg ; eD: +BackgroundTrans not needed?
		GuiControl, 3:, HelperBgImg, *w%imgWidth_% *h%imgHeight% %imgBgImage%
		if ( imgBgImage <> "" )
			Gui, 3:Show, xCenter y%yPosition% AutoSize NA, pklHelperBgImg
		
*/
		Gui, 2:+AlwaysOnTop -Border -Caption +ToolWindow +LastFound
		Gui, 2:margin, 0, 0
		Gui, 2:Color, %imgBgColor%
		if ( imgOpacity == -1 ) {
			WinSet, TransColor, %imgBgColor%, pklHelperBgImg
			WinSet, TransColor, %imgBgColor%, pklHelperImage
		} else if ( imgOpacity < 255 )
			WinSet, Transparent, %imgOpacity%
		if ( imgBgImage <> "" )
			Gui, 2:Show, xCenter y%yPosition% AutoSize NA, pklHelperBgImg
		Gui, 2:Add, Pic, xm +BackgroundTrans vHelperBgImg AltSubmit ; eD: +BackgroundTrans?
		GuiControl, 2:, HelperBgImg, *w%imgWidth_% *h%imgHeight% %imgBgImage%
		Gui, 2:Show, xCenter y%yPosition% AutoSize NA, pklHelperBgImg
		Gui, 2:Add, Pic, xm +BackgroundTrans vHelperImage AltSubmit ; eD: +BackgroundTrans not needed/working? With AltSubmit?
		GuiControl, 2:, HelperImage, *w%imgWidth_% *h%imgHeight% %layoutDir%\state0.png
		Gui, 2:Show, xCenter y%yPosition% AutoSize NA, pklHelperImage
		
		setTimer, displayHelpImage, 200
	} else if ( activate == -1 ) {
		Menu, Tray, UnCheck, % getPklInfo( "DisplayHelpImageMenuName" )
		setTimer, displayHelpImage, Off
		Gui, 2:Destroy
;		Gui, 3:Destroy
		return
	}
	if ( guiActive == 0 )
		return

	MouseGetPos, , , id
	WinGetTitle, title, ahk_id %id%
	if ( title == "pklHelperImage" ) { ; eD:  || title == "pklHelperBgImg"
		displayOnTop := 1 - displayOnTop
		if ( displayOnTop )
			yPosition := imgTopGutr ; eD: Top margin used to be fixed = 5
		else
			yPosition := A_ScreenHeight - imgHeight - imgLowGutr ; eD: Low margin was fixed = 60
;		Gui, 3:Show, xCenter y%yPosition% AutoSize NA, pklHelperBgImg
		Gui, 2:Show, xCenter y%yPosition% AutoSize NA, pklHelperImage
	}
	
	if ( gPv_CurDKsNum ) {
		if ( not getKeyState( "Shift" ) ) {
			fileName = deadkey%gPv_CurDKName%
		} else {
			fileName = deadkey%gPv_CurDKName%sh
			if ( not FileExist( layoutDir . "\" . filename . ".png" ) )
				fileName = deadkey%gPv_CurDKName%
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
	GuiControl,2:, HelperImage, *w%imgWidth_% *h%imgHeight% %layoutDir%\%fileName%.png
}

FixAtForMenu( menuItem )
{
	StringReplace, menuItem, menuItem, %A_Space%&%A_Space%, +, 1	; eD: Used to be '& , &&,' to display the ampersand.
	return menuItem
}

pkl_MsgBox( msg, s = "", p = "", q = "", r = "" )
{
	message := pklLocaleString( msg, s, p, q, r )
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
	} else if ( lParam == 0x201 ) { ; WM_LBUTTONDOWN
		gosub ToggleSuspend
	}
}
