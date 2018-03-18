pkl_set_tray_menu()
{
	global gP_ShowMoreInfo	; eD: Show extra technical info and the Reset hotkey
	
	ahk11 := ( A_AhkVersion < "1.1" ) ? false : true
	
	ExitAppHotkey      := getReadableHotkeyString( getPklInfo( "HK_ExitApp"      ) )
	ChangeLayoutHotkey := getReadableHotkeyString( getPklInfo( "HK_ChangeLayout" ) )
	SuspendHotkey      := getReadableHotkeyString( getPklInfo( "HK_Suspend"      ) )
	RefreshHotkey      := getReadableHotkeyString( getPklInfo( "HK_Refresh"      ) )
	HelpImageHotkey    := getReadableHotkeyString( getPklInfo( "HK_ShowHelpImg"  ) )
	
	Layout := getLayoutInfo( "active" )
	activeLayoutName := ""
	countOfLayouts := getLayoutInfo( "countOfLayouts" )
	
	aboutmeMenuItem := getPklInfo( "LocStr_9"  )			; pklLocaleString()
	suspendMenuItem := getPklInfo( "LocStr_10" )
	exitappMenuItem := getPklInfo( "LocStr_11" )
	deadkeyMenuItem := getPklInfo( "LocStr_12" )
	helpimgMenuItem := getPklInfo( "LocStr_15" )
	chnglayMenuItem := getPklInfo( "LocStr_18" )
	layoutsMenu     := getPklInfo( "LocStr_19" )
	keyhistMenuItem := getPklInfo( "LocStr_KeyHistMenu" )
	refreshMenuItem := getPklInfo( "LocStr_RefreshMenu" )
	if ( SuspendHotkey      != "" )
		suspendMenuItem .= " (" . FixAmpInMenu( SuspendHotkey      ) . ")"
	if ( RefreshHotkey      != "" )
		refreshMenuItem .= " (" . FixAmpInMenu( RefreshHotkey      ) . ")"
	if ( ExitAppHotkey      != "" )
		exitappMenuItem .= " (" . FixAmpInMenu( ExitAppHotkey      ) . ")"
	if ( HelpImageHotkey    != "" )
		helpimgMenuItem .= " (" . FixAmpInMenu( HelpImageHotkey    ) . ")"
	if ( ChangeLayoutHotkey != "" )
		chnglayMenuItem .= " (" . FixAmpInMenu( ChangeLayoutHotkey ) . ")"
	setPklInfo( "LocStr_ShowHelpImgMenu", helpimgMenuItem )
	
	Loop, % countOfLayouts
	{
		layName := getLayoutInfo( "layout" . A_Index . "name" )	; Layout menu name
		layCode := getLayoutInfo( "layout" . A_Index . "code" )	; Layout dir name
		Menu, changeLayout, add, %layName%, changeLayoutMenu
		if ( layCode == Layout ) {
			Menu, changeLayout, Default, %layName%
			Menu, changeLayout, Check, %layName%
			activeLayoutName := layName
		}
		
		layIcon = Layouts\%layCode%\on.ico
		if ( not FileExist( layIcon ) )
			layIcon := A_ScriptName								; icon = on.ico
		if ( ahk11 ) {
			Menu, changeLayout, Icon,        %layName%, %layIcon%, 1
		} else {
			MI_SetMenuItemIcon("changeLayout", A_Index,  layIcon , 1, 16)
		}
	}

	if ( not A_IsCompiled ) {
		SplitPath, A_AhkPath,, SpyPath
		SpyPath = %SpyPath%\AU3_Spy.exe
		if ( ahk11 ) {
			; eD WIP TODO: Can I assign icons without the menu titles? Or find the default AHK titles?
		} else {
			tr := MI_GetMenuHandle("Tray")							; eD: Are these icons necessary?
			MI_SetMenuItemIcon(tr, 1, A_AhkPath, 1, 16) 			; open
			MI_SetMenuItemIcon(tr, 2, A_WinDir "\hh.exe", 1, 16) 	; help
			MI_SetMenuItemIcon(tr, 4, SpyPath,   1, 16) 			; spy
			MI_SetMenuItemIcon(tr, 5, "shell32.dll", 147, 16) 		; reload
			MI_SetMenuItemIcon(tr, 6, A_AhkPath, 2, 16) 			; edit
			MI_SetMenuItemIcon(tr, 8, A_AhkPath, 3, 16) 			; suspend
			MI_SetMenuItemIcon(tr, 9, A_AhkPath, 4, 16) 			; pause
			MI_SetMenuItemIcon(tr, 10, "shell32.dll", 28, 16) 		; exit
			iconNum = 11
		}
		Menu, Tray, add,											; (separator)
	} else {
		Menu, Tray, NoStandard										; no standard AHK tray menu items
		iconNum = 0
	}
	
	Menu, Tray, add, %aboutmeMenuItem%, showAbout							; About
	if ( gP_ShowMoreInfo ) {
		Menu, Tray, add, %keyhistMenuItem%, keyHistory						; Key history
		Menu, Tray, add, %deadkeyMenuItem%, detectDeadKeysInCurrentLayout	; Detect DKs
	}
	Menu, Tray, add, %helpimgMenuItem%, showHelpImageToggle					; Show image
	if ( countOfLayouts > 1 ) {
		Menu, Tray, add,													; (separator)
		Menu, Tray, add, %layoutsMenu%, :changeLayout						; Layouts
		Menu, Tray, add, %chnglayMenuItem%, changeActiveLayout				; Change layout
	}
	Menu, Tray, add,
	if ( gP_ShowMoreInfo ) {
		Menu, Tray, add, %refreshMenuItem%, rerunWithSameLayout 			; eD: Refresh
	}
	Menu, Tray, add, %suspendMenuItem%, toggleSuspend						; Suspend
	Menu, Tray, add, %exitappMenuItem%, ExitPKL								; Exit
	
	pklAppName := getPklInfo( "pklName" )
	pklVersion := getPklInfo( "pklVers" )
	Menu, Tray, Tip, %pklAppName% v%pklVersion%`n(%activeLayoutName%)

	Menu, Tray, Click, 2
	Menu, Tray, Default, % pklIniRead( "trayMenuDefault", suspendMenuItem, "Pkl_eD_" )
;	if ( countOfLayouts > 1 ) {
;		Menu, Tray, Default, %chnglayMenuItem%
;	} else {
;		Menu, Tray, Default, %suspendMenuItem%
;	}
	
	; eD: Icon lists with numbers can be found using the enclosed Resources\AHK_MenuIconList.ahk script.
	if ( ahk11 ) {		; eD: Menu icons, using the new or old (Lexicos MenuIcons) way
	Menu, Tray, Icon,      %aboutmeMenuItem%,  shell32.dll ,  24		; %aboutmeMenuItem% ico - about/question
	if ( gP_ShowMoreInfo ) {
		Menu, Tray, Icon,  %keyhistMenuItem%,  shell32.dll , 222		; %keyhistMenuItem% ico - info
		Menu, Tray, Icon,  %deadkeyMenuItem%,  shell32.dll , 172		; %deadkeyMenuItem% ico - search (25: "speed")
		Menu, Tray, Icon,  %refreshMenuItem%,  shell32.dll , 239		; %refreshMenuItem% ico - refresh arrows
	}
	Menu, Tray, Icon,      %helpimgMenuItem%,  shell32.dll , 174		; %helpimgMenuItem% ico - keyboard (116: film)
	if ( countOfLayouts > 1 ) {
		Menu, Tray, Icon,  %layoutsMenu%    ,  shell32.dll ,  44		; %layoutsMenu%     ico - star
		Menu, Tray, Icon,  %chnglayMenuItem%,  shell32.dll , 138		; %chnglayMenuItem% ico - forward arrow
	}
	if ( gP_ShowMoreInfo ) {
	}
	Menu, Tray, Icon,      %suspendMenuItem%,  shell32.dll , 110		; %suspendMenuItem% ico - crossed circle
	Menu, Tray, Icon,      %exitappMenuItem%,  shell32.dll ,  28		; %exitappMenuItem% ico - power off
	} else {
		tr := MI_GetMenuHandle("Tray")
		MI_SetMenuItemIcon(    tr, ++iconNum, "shell32.dll",  24, 16)	; %aboutmeMenuItem% ico - about/question
		if ( gP_ShowMoreInfo ) {
			MI_SetMenuItemIcon(tr, ++iconNum, "shell32.dll", 222, 16)	; %keyhistMenuItem% ico - info
			MI_SetMenuItemIcon(tr, ++iconNum, "shell32.dll", 172, 16)	; %deadkeyMenuItem% ico - search (25: "speed")
		}
		MI_SetMenuItemIcon(    tr, ++iconNum, "shell32.dll", 174, 16)	; %helpimgMenuItem% ico - keyboard (116: film)
		if ( countOfLayouts > 1 ) {
			++iconNum													; *** separator bar *** - (skip icon count)
			MI_SetMenuItemIcon(tr, ++iconNum, "shell32.dll",  44, 16)	; %layoutsMenu%     ico - star
			MI_SetMenuItemIcon(tr, ++iconNum, "shell32.dll", 138, 16)	; %chnglayMenuItem% ico - forward arrow
		}
		++iconNum														; *** separator bar *** - (skip icon count)
		if ( gP_ShowMoreInfo ) {
			MI_SetMenuItemIcon(tr, ++iconNum, "shell32.dll", 239, 16)	; %refreshMenuItem% ico - refresh arrows
		}
		MI_SetMenuItemIcon(    tr, ++iconNum, "shell32.dll", 110, 16)	; %suspendMenuItem% ico - crossed circle
		MI_SetMenuItemIcon(    tr, ++iconNum, "shell32.dll",  28, 16)	; %exitappMenuItem% ico - power off
		
		if (A_OSVersion == "WIN_XP")
		{
			; It is necessary to hook the tray icon for owner-drawing to work. Owner-drawing is not used on Windows Vista.
			MI_SetMenuStyle( tr, 0x4000000 ) ; MNS_CHECKORBMP (optional)
			setPklInfo( "trayMenuHandler", tr )
		}
		OnMessage( 0x404, "AHK_NOTIFYICON" )
	}
}

pkl_about()
{
	global gP_Lay_Ini_File	; eD: "layout.ini"
	global gP_ShowMoreInfo	; eD: Show extra technical info and the Reset hotkey
	
	mslid := getWinLocaleID() ; eD: Get the Windows locale ID
	dkstr := getDeadKeysInCurrentLayout() ; eD: Show the current Windows layout's dead key string
	dkstr := dkstr ? dkstr : "<none found>"
	lfile := gP_Lay_Ini_File
	pklAppName := getPklInfo( "pklName" )
	pklMainURL := "http://pkl.sourceforge.net"
	pklProgURL := getPklInfo( "pkl_URL" )
	pklVersion := getPklInfo( "pklVers" )
	compiledAt := getPklInfo( "pklComp" )

	unknown         := getPklInfo( "LocStr_3"  )
	active_layout   := getPklInfo( "LocStr_4"  )
	locVersion      := getPklInfo( "LocStr_5"  )
	locLanguage     := getPklInfo( "LocStr_6"  )
	locCopyright    := getPklInfo( "LocStr_7"  )
	locCompany      := getPklInfo( "LocStr_8"  )
	license         := getPklInfo( "LocStr_13" )
	infos           := getPklInfo( "LocStr_14" )
	contributors    := getPklInfo( "LocStr_20" )
	translationName := getPklInfo( "LocStr_21" )
	translatorName  := getPklInfo( "LocStr_22" )
	
	IniRead, lname   , %lfile%, informations, layoutname, %unknown%
	IniRead, lver    , %lfile%, informations, version   , %unknown%
	IniRead, lcode   , %lfile%, informations, layoutcode, %unknown%
	IniRead, lcopy   , %lfile%, informations, copyright , %unknown%
	IniRead, lcomp   , %lfile%, informations, company   , %unknown%
	IniRead, llocale , %lfile%, informations, localeid  , 0409
	IniRead, lwebsite, %lfile%, informations, homepage  , %A_Space%
	llang := pklIniRead( SubStr( llocale, -3 ), "", "Pkl_Dic", "LangStrFromLangID" )	; eD: Replaced getLangStrFromDigits( llocale )

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
	text = %text%%ACTIVE_LAYOUT%:`n  %lname%
	text = %text%`n%locVersion%: %lver%
	text = %text%`n%locLanguage%: %llang%
	text = %text%`n%locCopyright%: %lcopy%
	text = %text%`n%locCompany%: %lcomp%
	Gui, Add, Text, , %text%
	Gui, Add, Edit, , %lwebsite%
	Gui, Add, Text, , ......................................................................
	if ( gP_ShowMoreInfo ) {
		text = ; eD: Show MS Locale ID and current underlying layout dead keys
		text = %text%Current Microsoft Windows Locale ID: %mslid%
		text = %text%`nDead keys in current Windows layout: %dkstr%
		Gui, Add, Text, , %text%
	}
	Gui, Show
}

pkl_showHelpImage( activate = 0 )
{
	; Parameter:
	; 0 = display, if activated
	;-1 = deactivate
	; 1 = activate
	; 2 = toggle
	; 3 = suspend on
	; 4 = suspend off
	
	global gP_CurrNumOfDKs	; eD: Current # of dead keys active
	global gP_CurrNameOfDK	; eD: Current dead key's name
	global gP_Lay_eD__File	; eD: My extra "layout.ini" file
	
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
	static Lay_eD_
	static HelperBgImg
	static imgBgImage
	static imgBgColor
	static imgTopGutr
	static imgLowGutr
	static imgOpacity
	
	if ( layoutDir == 0 )
	{
		layoutDir := getLayoutInfo( "layDir" )
		hasAltGr  := getLayoutInfo( "hasAltGr" )
		extendKey := getLayoutInfo( "extendKey" )
		Lay_eD_   := gP_Lay_eD__File	;layoutDir . "\" . gP_Lay_eD__File
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
		Menu, Tray, Check, % getPklInfo( "LocStr_ShowHelpImgMenu" )
		IniRead, imgBgImage, %Lay_eD_%, hlpimg, img_bgimage, %layoutDir%\backgr.png
		; eD: The default imgBgImage may not be robust if there's no backgr.png nor DreymaR_layout.ini entry?
		;     Therefore, replace the above default by an if statement checking whether the file exists?!
		IniRead, imgBgColor, %Lay_eD_%, hlpimg, img_bgcolor, fefeff
		IniRead, imgLowGutr, %Lay_eD_%, hlpimg, img_low_margin, 60
		IniRead, imgTopGutr, %Lay_eD_%, hlpimg, img_top_margin, 10
		IniRead, imgOpacity, %Lay_eD_%, hlpimg, img_opacity, 255
		if ( yPosition == -1 ) {
			IniRead, imgWidth_, %Lay_eD_%, hlpimg, img_width_, 300
			IniRead, imgHeight, %Lay_eD_%, hlpimg, img_height, 100
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
		
		setTimer, showHelpImage, 200
	} else if ( activate == -1 ) {
		Menu, Tray, UnCheck, % getPklInfo( "LocStr_ShowHelpImgMenu" )
		setTimer, showHelpImage, Off
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
	
	imgDir := LayoutDir
	if ( gP_CurrNumOfDKs ) {
		imgDir := getLayoutInfo( "dkImgDir" )	; eD
		ssuf := getLayoutInfo( "dkImgSuf" )
		dkS1 := ( ssuf ) ? ssuf . "1" : ""  	; eD: Img file state 1 suffix
		dkS2 := ( ssuf ) ? ssuf . "2" : "sh"	; eD: Img file state 2 suffix
		dkS6 := ssuf . "6"
		dkS7 := ssuf . "7"
		; eD TODO: Add shift states 6-7 to images!
		if ( getKeyState( "Shift" ) ) {
			fileName = %gP_CurrNameOfDK%%dkS2%	; sh
			if ( not FileExist( imgDir . "\" . filename . ".png" ) )
				fileName = %gP_CurrNameOfDK%%dkS1%
		} else {
			fileName = %gP_CurrNameOfDK%%dkS1%	; deadkey%gP_CurrNameOfDK%
		}
	} else if ( extendKey && getKeyState( extendKey, "P" ) ) {
		fileName = extend
	} else {
		state = 0
		state += 1 * getKeyState( "Shift" )
		state += 6 * ( hasAltGr * AltGrIsPressed() )
		fileName = state%state%
	}
	if ( not FileExist( imgDir . "\" . fileName . ".png" ) )
		fileName = state0
	
	if ( prevFile == fileName )
		return
		
	prevFile := fileName
	GuiControl,2:, HelperImage, *w%imgWidth_% *h%imgHeight% %imgDir%\%fileName%.png
}

FixAmpInMenu( menuItem )
{
	StringReplace, menuItem, menuItem, %A_Space%&%A_Space%, +, 1	; eD: Used to be '& , &&,' to display the ampersand.
	return menuItem
}

pkl_MsgBox( msg, s = "", p = "", q = "", r = "" )
{
	message := getPklInfo( "LocStr_" . msg ) 		; pklLocaleString( msg, s, p, q, r )
	if ( s <> "" )
		StringReplace, m, m, #s#, %s%, A
	if ( p <> "" )
		StringReplace, m, m, #p#, %p%, A
	if ( q <> "" )
		StringReplace, m, m, #q#, %q%, A
	if ( r <> "" )
		StringReplace, m, m, #r#, %r%, A
	msgbox %message%
}

if ( ! ahk11 ) {							; eD: Phase this out as WinXP is now obsolete?!
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
}

; eD: In preparation of using AHK v1.1 to render icons without the old Lexicos MenuIcons (which doesn't work with this version?):
;if ( ! A_AhkVersion < "1.1" )	{
	#Include ext_MenuIcons.ahk ; http://www.autohotkey.com/forum/viewtopic.php?t=21991 ; eD: Renamed from MI.ahk
