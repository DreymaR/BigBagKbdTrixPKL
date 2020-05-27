pkl_set_tray_menu()
{
	ShowMoreInfo := getPklInfo( "AdvancedMode" )	; Show extra technical info and the Reset hotkey
	
	ExitAppHotkey   := getReadableHotkeyString( getPklInfo( "HK_ExitApp"      ) )
	ChngLayHotkey   := getReadableHotkeyString( getPklInfo( "HK_ChangeLayout" ) )
	SuspendHotkey   := getReadableHotkeyString( getPklInfo( "HK_Suspend"      ) )
	RefreshHotkey   := getReadableHotkeyString( getPklInfo( "HK_Refresh"      ) )
	ShowImgHotkey   := getReadableHotkeyString( getPklInfo( "HK_ShowHelpImg"  ) )
	ZoomImgHotkey   := getReadableHotkeyString( getPklInfo( "HK_ZoomHelpImg"  ) )
;	MoveImgHotkey   := getReadableHotkeyString( getPklInfo( "HK_MoveHelpImg"  ) ) 	; Don't show this to avoid clutter
;	AboutMeHotkey   := getReadableHotkeyString( getPklInfo( "HK_ShowAbout"    ) ) 	; Don't show this to avoid clutter
;	DebugMeHotkey   := getReadableHotkeyString( getPklInfo( "HK_DebugWIP"     ) ) 	; "Secret" Debug/WIP hotkey
	
	activeLayout    := getLayInfo( "ActiveLay" )
	activeLayName   := ""
	numOfLayouts  := getLayInfo( "NumOfLayouts" )
	
	aboutMeMenuItem := getPklInfo( "LocStr_09" )			; pklLocaleString()
	keyHistMenuItem := getPklInfo( "LocStr_AHKeyHist" )
	deadKeyMenuItem := getPklInfo( "LocStr_12" )
	showImgMenuItem := getPklInfo( "LocStr_15" )
	zoomImgMenuItem := getPklInfo( "LocStr_ZoomImage" )
;	moveImgMenuItem := getPklInfo( "LocStr_MoveImage" )
	layoutsMenu     := getPklInfo( "LocStr_19" )
	chngLayMenuItem := getPklInfo( "LocStr_18" )
	refreshMenuItem := getPklInfo( "LocStr_RefreshMe" )
	suspendMenuItem := getPklInfo( "LocStr_10" )
	exitAppMenuItem := getPklInfo( "LocStr_11" )
;	importsMenuItem := getPklInfo( "LocStr_ImportKLC" )
	makeImgMenuItem := getPklInfo( "LocStr_MakeImage" )
	showImgMenuItem .= ( ShowImgHotkey ) ? _FixAmpInMenu( ShowImgHotkey ) : ""
	zoomImgMenuItem .= ( ZoomImgHotkey ) ? _FixAmpInMenu( ZoomImgHotkey ) : ""
;	moveImgMenuItem .= ( MoveImgHotkey ) ? _FixAmpInMenu( MoveImgHotkey ) : ""
	chngLayMenuItem .= ( ChngLayHotkey ) ? _FixAmpInMenu( ChngLayHotkey ) : ""
	refreshMenuItem .= ( RefreshHotkey ) ? _FixAmpInMenu( RefreshHotkey ) : ""
	suspendMenuItem .= ( SuspendHotkey ) ? _FixAmpInMenu( SuspendHotkey ) : ""
	exitAppMenuItem .= ( ExitAppHotkey ) ? _FixAmpInMenu( ExitAppHotkey ) : ""
	setPklInfo( "LocStr_ShowHelpImgMenu", showImgMenuItem ) 	; Used in pkl_gui_image to recognize the Show Img menu item
	
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
		Menu, Tray, NoStandard 									; No standard AHK tray menu items
	} else {
		SplitPath, A_AhkPath,, AhkDir
		Menu, Tray, Icon,  1&, %A_AhkPath%			,   1 		; Open
		Menu, Tray, Icon,  2&, %A_WinDir%\hh.exe	,   1 		; Help
		Menu, Tray, Icon,  4&, %AhkDir%\AU3_Spy.exe	,   1 		; Spy
		Menu, Tray, Icon,  5&, shell32.dll			, 147		; Reload
		Menu, Tray, Icon,  6&, %A_AhkPath%			,   2 		; Edit
		Menu, Tray, Icon,  8&, %A_AhkPath%			,   3 		; Suspend
		Menu, Tray, Icon,  9&, %A_AhkPath%			,   4 		; Pause
		Menu, Tray, Icon, 10&, shell32.dll			,  28 		; Exit
		Menu, Tray, add, 										; (separator)
	}
	
	Menu, Tray, add, %aboutMeMenuItem%, showAbout 							; About
	if ( ShowMoreInfo ) {
		Menu, Tray, add, %keyHistMenuItem%, keyHistory 						; Key history
		Menu, Tray, add, %deadKeyMenuItem%, detectDeadKeysInCurrentLayout 	; Detect DKs
;		Menu, Tray, add, %importsMenuItem%, importLayouts 					; Import Module
		Menu, Tray, add, %makeImgMenuItem%, makeHelpImages 					; Help Image Generator
		Menu, Tray, add, 													; (separator)
	}
	Menu, Tray, add, %showImgMenuItem%, showHelpImageToggle 				; Show image
	Menu, Tray, add, %zoomImgMenuItem%, zoomHelpImage 						; Zoom image
;	Menu, Tray, add, %moveImgMenuItem%, moveHelpImage 						; Move image
	if ( numOfLayouts > 1 ) {
		Menu, Tray, add, 													; (separator)
		Menu, Tray, add, %layoutsMenu%, :changeLayout 						; Layouts
		Menu, Tray, add, %chngLayMenuItem%, changeActiveLayout 				; Change layout
	}
	Menu, Tray, add,
	if ( ShowMoreInfo ) {
		Menu, Tray, add, %refreshMenuItem%, rerunWithSameLayout 			; Refresh
	}
	Menu, Tray, add, %suspendMenuItem%, toggleSuspend						; Suspend
	Menu, Tray, add, %exitAppMenuItem%, ExitPKL								; Exit
	
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
;		Menu, Tray, Default, %chngLayMenuItem%
;	} else {
;		Menu, Tray, Default, %suspendMenuItem%
;	}
	
	; eD: Icon lists with numbers can be found using the enclosed Resources\AHK_MenuIconList.ahk script.
	Menu, Tray, Icon,      %aboutMeMenuItem%,  shell32.dll ,  24 		; aboutMeMenuItem icon - about/question
	if ( ShowMoreInfo ) {
		Menu, Tray, Icon,  %keyHistMenuItem%,  shell32.dll , 222 		; keyHistMenuItem icon - info
		Menu, Tray, Icon,  %deadKeyMenuItem%,  shell32.dll , 172 		; deadKeyMenuItem icon - search
		Menu, Tray, Icon,  %refreshMenuItem%,  shell32.dll , 239 		; refreshMenuItem icon - refresh arrows
		Menu, Tray, Icon,  %makeImgMenuItem%,  shell32.dll , 142 		; makeImgMenuItem icon - painting on screen
	}
	Menu, Tray, Icon,      %showImgMenuItem%,  shell32.dll , 174 		; showImgMenuItem icon - keyboard (116: film)
	Menu, Tray, Icon,      %zoomImgMenuItem%,  shell32.dll ,  23 		; zoomImgMenuItem icon - spyglass
;	Menu, Tray, Icon,      %moveImgMenuItem%,  shell32.dll ,  25 		; moveImgMenuItem icon - speeding window
	if ( numOfLayouts > 1 ) {
		Menu, Tray, Icon,  %layoutsMenu%    ,  shell32.dll ,  44 		; layoutsMenu     icon - star
		Menu, Tray, Icon,  %chngLayMenuItem%,  shell32.dll , 138 		; chngLayMenuItem icon - forward arrow
	}
	Menu, Tray, Icon,      %suspendMenuItem%,  shell32.dll , 110 		; suspendMenuItem icon - crossed circle
	Menu, Tray, Icon,      %exitAppMenuItem%,  shell32.dll ,  28 		; exitAppMenuItem icon - power off
;	OnMessage( 0x404, "_AHK_NOTIFYICON" ) 								; Handle tray icon clicks. Using AHK defaults now.
}

pkl_about()
{
	msLID := getWinLocaleID() 								; The 4-digit Windows Locale ID
	wLang := A_Language 									; The 4-digit Language code
	dkStr := getDeadKeysInCurrentLayout() 					; The Windows layout's dead key string
	dkStr := dkStr ? dkStr : "<none>"

	pklAppName      := getPklInfo( "pklName" )
	pklMainURL      := "https://github.com/Portable-Keyboard-Layout"
	pklProgURL      := getPklInfo( "pkl_URL" )
	pklVersion      := getPklInfo( "pklVers" )
	compiledAt      := getPklInfo( "pklComp" )

	locUnknown      := getPklInfo( "LocStr_03" ) 			; "Unknown"
	locActLayout    := getPklInfo( "LocStr_04" ) 			; "Active Layout"
	locVersion      := getPklInfo( "LocStr_05" ) 			; "Version"
	locLanguage     := getPklInfo( "LocStr_06" ) 			; "Language"
	locCopyright    := getPklInfo( "LocStr_07" ) 			; "Copyright"
	locCompany      := getPklInfo( "LocStr_08" ) 			; "Company"
	locLicense      := getPklInfo( "LocStr_13" ) 			; "Licence: GPL v3"
	locDisclaim     := getPklInfo( "LocStr_14" ) 			; Program disclaimer
	locThanksTo     := getPklInfo( "LocStr_20" ) 			; "Thanks to"
	locTransFile    := getPklInfo( "LocStr_21" ) 			; Translation file
	locTransName    := getPklInfo( "LocStr_22" ) 			; Translator name
	
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
	layFile  := StrReplace( getPklInfo( "File_LayIni" ), "layout.ini", "" )
	basFile  :=             getPklInfo( "File_BasIni" )

	Gui, Add, Text, , %pklAppName% v%pklVersion% (%compiledAt%)
	if ( pklProgURL != pklMainURL ) {
		Gui, Add, Edit, , %pklProgURL%
		Gui, Add, Text, , Based on Portable Keyboard Layout v0.4
	}
	Gui, Add, Edit, , %pklMainURL%
	Gui, Add, Text, , ......................................................................
	Gui, Add, Text, , (c) FARKAS, Máté, 2007-2010`n(c) OEystein B Gadmar, 2015-
	Gui, Add, Text, , %locThanksTo%: Chris Mallet && The AHK Foundation
	Gui, Add, Text, , %locDisclaim%
	Gui, Add, Text, , %locLicense%
	Gui, Add, Edit, , http://www.gnu.org/licenses/gpl-3.0.txt
	Gui, Add, Text, , % ( locTransName == "[[Translator name]]" ) ? "" : "`n" . locTransFile . ": " . locTransName
	Gui, Add, Text, , ......................................................................
	text :=        locActLayout . ": " . layName
	text .= "`n" . locVersion   . ": " . layVers
	text .= "`n" . locLanguage  . ": " . layLang . " (++?)"
	text .= "`n" . locCopyright . ": " . layCopy
	text .= "`n" . locCompany   . ": " . layComp
	Gui, Add, Text, , %text% 								; Layout info
	Gui, Add, Edit, , %layPage%
	if getPklInfo( "AdvancedMode" ) { 						; Advanced Mode shows more info
		Gui, Add, Text, , ......................................................................
		text := "Keyboard/Layout type from settings: "      . kbdType
		text .= "`nCurl/Ergo/Other mod from settings: "     . ergoMod
		text .= "`nCurrent Windows Locale / Language ID: "   . msLID . " " . wLang
		text .= "`nDead keys set for this Windows layout: " . dkStr
		text .= "`nLayout/BaseLayout file paths:`n- "         . layFile . "`n- " . basFile
		Gui, Add, Text, , %text% 							; Win Locale ID and OS layout DKs
	}
	Gui, Show
}

readLayoutIcons( layIni ) 										; Read On/Off icons for a specified layout
{
	For ix, OnOff in [ "on", "off" ]
	{
		icon := OnOff . ".ico"
		SplitPath, layIni, , layDir 							; The icon files may be in the layout dir
		layDir := ( layIni == "LayStk" ) ? getLayInfo( "Dir_LayIni" ) : layDir
		icoFile := fileOrAlt( pklIniRead( "icons_OnOff", layDir . "\", layIni ) . icon
							, "Files\ImgIcons\Gray_" . icon ) 	; If not specified in layout file or in dir, use this
		if FileExist( icoFile ) {
			icoFil%ix%  := icoFile
			icoNum%ix%  := 1
		} else if ( A_IsCompiled ) { 							; If EPKL is compiled, can use internal icons from the .exe
			icoFil%ix%  := A_ScriptName
			icoNum%ix%  := ( OnOff == "on" ) ? 1 : 5 			; was 6/3 in original PKL.exe - keyboard and red 'S' icons
		} else {
			icoFil%ix%  := "Resources\" . icon 					; If all else fails, look for a Resources\ .ico file
			icoNum%ix%  := 1
		}
	}
	Return { Fil1 : icoFil1, Num1 : icoNum1, Fil2 : icoFil2, Num2 : icoNum2 }
}

_FixAmpInMenu( menuItem )
{
	menuItem := StrReplace( menuItem, " & ", "+" ) 		; Used to be '& , &&,' to display the ampersand.
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
