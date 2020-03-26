pkl_set_tray_menu()
{
	ShowMoreInfo := getPklInfo( "AdvancedMode" )	; Show extra technical info and the Reset hotkey
	
	ExitAppHotkey   := getReadableHotkeyString( getPklInfo( "HK_ExitApp"      ) )
	ChngLayHotkey   := getReadableHotkeyString( getPklInfo( "HK_ChangeLayout" ) )
	SuspendHotkey   := getReadableHotkeyString( getPklInfo( "HK_Suspend"      ) )
	RefreshHotkey   := getReadableHotkeyString( getPklInfo( "HK_Refresh"      ) )
	HelpImgHotkey   := getReadableHotkeyString( getPklInfo( "HK_ShowHelpImg"  ) )
	ZoomImgHotkey   := getReadableHotkeyString( getPklInfo( "HK_ZoomHelpImg"  ) )
;	MoveImgHotkey   := getReadableHotkeyString( getPklInfo( "HK_MoveHelpImg"  ) ) 	; Don't show this to avoid clutter
;	DebugMeHotkey   := getReadableHotkeyString( getPklInfo( "HK_DebugWIP"     ) )
	
	activeLayout    := getLayInfo( "active" )
	activeLayName   := ""
	numOfLayouts  := getLayInfo( "numOfLayouts" )
	
	aboutmeMenuItem := getPklInfo( "LocStr_9"  )			; pklLocaleString()
	keyhistMenuItem := getPklInfo( "LocStr_KeyHistMenu" )
	deadkeyMenuItem := getPklInfo( "LocStr_12" )
	helpimgMenuItem := getPklInfo( "LocStr_15" )
	zoomimgMenuItem := getPklInfo( "LocStr_ZoomImgMenu" )
;	moveimgMenuItem := getPklInfo( "LocStr_MoveImgMenu" )
	layoutsMenu     := getPklInfo( "LocStr_19" )
	chnglayMenuItem := getPklInfo( "LocStr_18" )
	refreshMenuItem := getPklInfo( "LocStr_RefreshMenu" )
	suspendMenuItem := getPklInfo( "LocStr_10" )
	exitappMenuItem := getPklInfo( "LocStr_11" )
;	importsMenuItem := getPklInfo( "LocStr_ImportsMenu" )
	makeimgMenuItem := getPklInfo( "LocStr_MakeImgMenu" )
	helpimgMenuItem .= ( HelpImgHotkey ) ? _FixAmpInMenu( HelpImgHotkey ) : ""
	zoomimgMenuItem .= ( ZoomImgHotkey ) ? _FixAmpInMenu( ZoomImgHotkey ) : ""
;	moveimgMenuItem .= ( MoveImgHotkey ) ? _FixAmpInMenu( MoveImgHotkey ) : ""
	chnglayMenuItem .= ( ChngLayHotkey ) ? _FixAmpInMenu( ChngLayHotkey ) : ""
	refreshMenuItem .= ( RefreshHotkey ) ? _FixAmpInMenu( RefreshHotkey ) : ""
	suspendMenuItem .= ( SuspendHotkey ) ? _FixAmpInMenu( SuspendHotkey ) : ""
	exitappMenuItem .= ( ExitAppHotkey ) ? _FixAmpInMenu( ExitAppHotkey ) : ""
	setPklInfo( "LocStr_ShowHelpImgMenu", helpimgMenuItem )
	
	Loop % numOfLayouts { 										; Layouts menu list w/ icons
		layName := getLayInfo( "layout" . A_Index . "name" )	; Layout menu name
		layCode := getLayInfo( "layout" . A_Index . "code" )	; Layout dir name
		Menu, changeLayout, add, %layName%, changeLayoutMenu
		if ( layCode == activeLayout ) {
			Menu, changeLayout, Default, %layName%
			Menu, changeLayout, Check, %layName%
			activeLayName := layName
		}
		ico := readLayoutIcons( "Layouts\" . layCode . "\" . getPklInfo( "LayFileName" ) )
		Menu, changeLayout, Icon, %layName%, % ico.Fil1, % ico.Num1
	}

	if ( A_IsCompiled ) {
		Menu, Tray, NoStandard									; No standard AHK tray menu items
	} else {
		SplitPath, A_AhkPath,, AhkDir
		Menu, Tray, Icon,  1&, %A_AhkPath%			,   1		; Open
		Menu, Tray, Icon,  2&, %A_WinDir%\hh.exe	,   1 		; Help
		Menu, Tray, Icon,  4&, %AhkDir%\AU3_Spy.exe	,   1 		; Spy
		Menu, Tray, Icon,  5&, shell32.dll			, 147		; Reload
		Menu, Tray, Icon,  6&, %A_AhkPath%			,   2 		; Edit
		Menu, Tray, Icon,  8&, %A_AhkPath%			,   3 		; Suspend
		Menu, Tray, Icon,  9&, %A_AhkPath%			,   4 		; Pause
		Menu, Tray, Icon, 10&, shell32.dll			,  28 		; Exit
		Menu, Tray, add,										; (separator)
	}
	
	Menu, Tray, add, %aboutmeMenuItem%, showAbout							; About
	if ( ShowMoreInfo ) {
		Menu, Tray, add, %keyhistMenuItem%, keyHistory						; Key history
		Menu, Tray, add, %deadkeyMenuItem%, detectDeadKeysInCurrentLayout	; Detect DKs
;		Menu, Tray, add, %importsMenuItem%, importLayouts 					; Import Module
		Menu, Tray, add, %makeimgMenuItem%, makeHelpImages					; Help Image Generator
		Menu, Tray, add,													; (separator)
	}
	Menu, Tray, add, %helpimgMenuItem%, showHelpImageToggle					; Show image
	Menu, Tray, add, %zoomimgMenuItem%, zoomHelpImage 						; Zoom image
;	Menu, Tray, add, %moveimgMenuItem%, moveHelpImage 						; Move image
	if ( numOfLayouts > 1 ) {
		Menu, Tray, add,													; (separator)
		Menu, Tray, add, %layoutsMenu%, :changeLayout						; Layouts
		Menu, Tray, add, %chnglayMenuItem%, changeActiveLayout				; Change layout
	}
	Menu, Tray, add,
	if ( ShowMoreInfo ) {
		Menu, Tray, add, %refreshMenuItem%, rerunWithSameLayout 			; Refresh
	}
	Menu, Tray, add, %suspendMenuItem%, toggleSuspend						; Suspend
	Menu, Tray, add, %exitappMenuItem%, ExitPKL								; Exit
	
	pklAppName := getPklInfo( "pklName" )
	pklVersion := getPklInfo( "pklVers" )
	Menu, Tray, Tip, %pklAppName% v%pklVersion%`n(%activeLayName%)

	Menu, Tray, Click, 2
	try {
		Menu, Tray, Default, % pklIniRead( "trayMenuDefault", suspendMenuItem )
	} catch {
		pklWarning( "EPKL_Settings.ini:`nNon-existing menu item specified as default!?" )
	}
;	if ( numOfLayouts > 1 ) {
;		Menu, Tray, Default, %chnglayMenuItem%
;	} else {
;		Menu, Tray, Default, %suspendMenuItem%
;	}
	
	; eD: Icon lists with numbers can be found using the enclosed Resources\AHK_MenuIconList.ahk script.
	Menu, Tray, Icon,      %aboutmeMenuItem%,  shell32.dll ,  24		; aboutmeMenuItem icon - about/question
	if ( ShowMoreInfo ) {
		Menu, Tray, Icon,  %keyhistMenuItem%,  shell32.dll , 222		; keyhistMenuItem icon - info
		Menu, Tray, Icon,  %deadkeyMenuItem%,  shell32.dll , 172		; deadkeyMenuItem icon - search
		Menu, Tray, Icon,  %refreshMenuItem%,  shell32.dll , 239		; refreshMenuItem icon - refresh arrows
		Menu, Tray, Icon,  %makeimgMenuItem%,  shell32.dll , 142		; makeimgMenuItem icon - painting on screen
	}
	Menu, Tray, Icon,      %helpimgMenuItem%,  shell32.dll , 174		; helpimgMenuItem icon - keyboard (116: film)
	Menu, Tray, Icon,      %zoomimgMenuItem%,  shell32.dll ,  23		; zoomimgMenuItem icon - spyglass
;	Menu, Tray, Icon,      %moveimgMenuItem%,  shell32.dll ,  25		; moveimgMenuItem icon - speeding window
	if ( numOfLayouts > 1 ) {
		Menu, Tray, Icon,  %layoutsMenu%    ,  shell32.dll ,  44		; layoutsMenu     icon - star
		Menu, Tray, Icon,  %chnglayMenuItem%,  shell32.dll , 138		; chnglayMenuItem icon - forward arrow
	}
	Menu, Tray, Icon,      %suspendMenuItem%,  shell32.dll , 110		; suspendMenuItem icon - crossed circle
	Menu, Tray, Icon,      %exitappMenuItem%,  shell32.dll ,  28		; exitappMenuItem icon - power off
;	OnMessage( 0x404, "_AHK_NOTIFYICON" )								; Handle tray icon clicks. Using AHK defaults now.
}

pkl_about()
{
	msLID := getWinLocaleID() 					; Get the Windows locale ID
	dkStr := getDeadKeysInCurrentLayout() 		; Show the current Windows layout's dead key string
	dkStr := dkStr ? dkStr : "<none>"

	pklAppName      := getPklInfo( "pklName" )
	pklMainURL      := "https://github.com/Portable-Keyboard-Layout"
	pklProgURL      := getPklInfo( "pkl_URL" )
	pklVersion      := getPklInfo( "pklVers" )
	compiledAt      := getPklInfo( "pklComp" )

	locUnknown      := getPklInfo( "LocStr_3"  )
	activeLayout    := getPklInfo( "LocStr_4"  )
	locVersion      := getPklInfo( "LocStr_5"  )
	locLanguage     := getPklInfo( "LocStr_6"  )
	locCopyright    := getPklInfo( "LocStr_7"  )
	locCompany      := getPklInfo( "LocStr_8"  )
	locLicense      := getPklInfo( "LocStr_13" )
	locInfo         := getPklInfo( "LocStr_14" )
	locContributors := getPklInfo( "LocStr_20" )
	translationName := getPklInfo( "LocStr_21" )
	translatorName  := getPklInfo( "LocStr_22" )
	
	layName  := pklIniRead( "layoutName", locUnknown, "LayIni", "information" )
	layVers  := pklIniRead( "version"   , locUnknown, "LayIni", "information" )
	layCode  := pklIniRead( "layoutCode", locUnknown, "LayIni", "information" )
	layCopy  := pklIniRead( "copyright" , locUnknown, "LayIni", "information" )
	layComp  := pklIniRead( "company"   , locUnknown, "LayIni", "information" )
	layPage  := pklIniRead( "homepage"  , ""        , "LayIni", "information" )
	lLocale  := pklIniRead( "localeID"  , "0409"    , "LayIni", "information" )
	layLang  := pklIniRead( SubStr( lLocale, -3 ), "", "PklDic", "LangStrFromLangID" )
	kbdType  := getLayInfo( "Ini_KbdType" ) . " " . getLayInfo( "Ini_LayType" )
	ergoMod  := getLayInfo( "Ini_CurlMod" ) . " " . getLayInfo( "Ini_ErgoMod" ) . " " . getLayInfo( "Ini_OthrMod" )

	Gui, Add, Text, , %pklAppName% v%pklVersion% (%compiledAt%)
	if ( pklProgURL != pklMainURL ) {
		Gui, Add, Edit, , %pklProgURL%
		Gui, Add, Text, , Based on Portable Keyboard Layout v0.4
	}
	Gui, Add, Edit, , %pklMainURL%
	Gui, Add, Text, , ......................................................................
	Gui, Add, Text, , (c) FARKAS, Máté, 2007-2010`n(c) OEystein B Gadmar, 2015-
	Gui, Add, Text, , %locContributors%: Chris Mallet && The AHK Foundation
	Gui, Add, Text, , %locInfo%
	Gui, Add, Text, , %locLicense%
	Gui, Add, Edit, , http://www.gnu.org/licenses/gpl-3.0.txt
	Gui, Add, Text, , ......................................................................
	text :=        activeLayout . ": " . layName
	text .= "`n" . locVersion   . ": " . layVers
	text .= "`n" . locLanguage  . ": " . layLang . " (++?)"
	text .= ( translatorName == "[[Translator name]]" ) ? "" : "`n" . translationName . ": " . translatorName
	text .= "`n" . locCopyright . ": " . layCopy
	text .= "`n" . locCompany   . ": " . layComp
	Gui, Add, Text, , %text% 								; Layout info
	Gui, Add, Edit, , %layPage%
	if getPklInfo( "AdvancedMode" ) { 						; Advanced Mode shows more info
		Gui, Add, Text, , ......................................................................
		text := "Keyboard/Layout type from settings: "      . kbdType
		text .= "`nCurl/Ergo/Other mod from settings: "     . ergoMod
		text .= "`nCurrent Microsoft Windows Locale ID: "   . msLID
		text .= "`nDead keys set for this Windows layout: " . dkStr
		Gui, Add, Text, , %text% 							; Win Locale ID and OS layout DKs
	}
	Gui, Show
}

readLayoutIcons( layIni ) 										; Read On/Off icons for a specified layout
{
	for ix, OnOff in [ "on", "off" ]
	{
		icon := OnOff . ".ico"
		icoFile := fileOrAlt( pklIniRead( "icons_OnOff", layDir . "\", layIni ) . icon
							, "Files\ImgIcons\Gray_" . icon )	; If not specified in layout file or in dir, use this
		if FileExist( icoFile ) {
			icoFil%ix%  := icoFile
			icoNum%ix%  := 1
		} else if ( A_IsCompiled ) {
			icoFil%ix%  := A_ScriptName
			icoNum%ix%  := ( OnOff == "on" ) ? 1 : 5			; was 6/3 in original PKL.exe - keyboard and red 'S' icons
		} else {
			icoFil%ix%  := "Resources\" . icon
			icoNum%ix%  := 1
		}
	}
	Return { Fil1 : icoFil1, Num1 : icoNum1, Fil2 : icoFil2, Num2 : icoNum2 }
}

_FixAmpInMenu( menuItem )
{
	menuItem := StrReplace( menuItem, " & ", "+" )		; Used to be '& , &&,' to display the ampersand.
	menuItem := " (" . menuItem . ")"
	Return menuItem
}

/*
	_AHK_NOTIFYICON(wParam, lParam)			; Called by tray icon clicks w/ OnMessage( 0x404 ). Now disabled.
	{
		if ( lParam == 0x205 ) { 			; WM_RBUTTONUP
			Return
		} else if ( lParam == 0x201 ) { 	; WM_LBUTTONDOWN
			gosub ToggleSuspend				; This suspends EPKL on tray icon single-click
		}
	}
*/
