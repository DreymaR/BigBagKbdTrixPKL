﻿pkl_set_tray_menu()
{
	ShowMoreInfo    := getPklInfo( "AdvancedMode" ) 	; Show extra technical info and the Reset hotkey
	
	layoutsMenu     := getPklInfo( "LocStr_19" ) 		; Menu text for the Layouts menu
	menuItems   :=  {   "menuItm" : [ "LocStr_##" , "HK_#########" ]		; Dummy legend menu item
					,   "aboutMe" : [ "09"        , ""             ]		; ---
					,   "keyHist" : [ "AHKeyHist" , ""             ]		; ---
					,   "deadKey" : [ "12"        , ""             ]		; ---
					,   "makeImg" : [ "MakeImage" , ""             ]		; ---
					,   "showImg" : [ "15"        , "ShowHelpImg"  ]		; ^+1
					,   "chngLay" : [ "18"        , "ChangeLayout" ]		; ^+2
					,   "suspend" : [ "10"        , "Suspend"      ]		; ^+3/`
					,   "exitApp" : [ "11"        , "ExitApp"      ]		; ^+4
					,   "refresh" : [ "RefreshMe" , "Refresh"      ]		; ^+5
					,   "setting" : [ "LaysSetts" , "SettingsUI"   ]		; ^+6
					,   "zoomImg" : [ "ZoomImage" , "ZoomHelpImg"  ]		; ^+7
					,   "opaqImg" : [ "OpaqImage" , "OpaqHelpImg"  ]		; ^+8 - Don't show this to avoid clutter
					,   "moveImg" : [ "MoveImage" , "MoveHelpImg"  ]		; ^+9 - Don't show this to avoid clutter
					,   "winInfo" : [ ""          , "AhkWinInfo"   ]		; ^+0 - Don't show this to avoid clutter
					,   "debugMe" : [ ""          , "DebugWIP"     ] } 		; ^+= - Don't show the Debug/WIP hotkey
	For item, val in menuItems
	{
		%item%MenuItem  := getPklInfo( "LocStr_" . val[1] ) 	; Menu item text - hotkey text is added on the next lines
		hotkeyInMenu    := getReadableHotkeyString( getPklInfo( "HK_" . val[2] ) )
		%item%MenuItem  .= ( hotkeyInMenu ) ? _FixAmpInMenu( hotkeyInMenu ) : ""
	}
	
	setPklInfo( "LocStr_ShowHelpImgMenu", showImgMenuItem ) 	; Used in pkl_gui_image to recognize the Show Img menu item
	
	activeLayout    := getLayInfo( "ActiveLay" )
	activeLayName   := ""
	numOfLayouts    := getLayInfo( "NumOfLayouts" )
	Loop % numOfLayouts { 										; Layouts menu list w/ icons
		layName := getLayInfo( "layout" . A_Index . "name" )	; Layout menu name
		layCode := getLayInfo( "layout" . A_Index . "code" )	; Layout dir name
		if ( layCode == "<N/A>" ) 								; Empty name entries cause an icon error below
			Continue
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
	Menu, Tray, add, %settingMenuItem%, changeSettings 						; Layouts/Settings UI
	if ( ShowMoreInfo ) {
		Menu, Tray, add, %keyHistMenuItem%, keyHistory 						; Key history
		Menu, Tray, add, %deadKeyMenuItem%, detectCurrentWinLayDeadKeys 	; Detect DKs
;		Menu, Tray, add, %importsMenuItem%, importLayouts 					; Import Module
		Menu, Tray, add, %makeImgMenuItem%, makeHelpImages 					; Help Image Generator
		Menu, Tray, add, 													; (separator)
	}
	Menu, Tray, add, %showImgMenuItem%, showHelpImageToggle 				; Show image
	Menu, Tray, add, %zoomImgMenuItem%, zoomHelpImage 						; Zoom image
;	Menu, Tray, add, %moveImgMenuItem%, moveHelpImage 						; Move image
;	Menu, Tray, add, %opaqImgMenuItem%, opaqHelpImage 						; Opaque/transparent image
	if ( numOfLayouts > 1 ) {
		Menu, Tray, add, 													; (separator)
		Menu, Tray, add, %layoutsMenu%, :changeLayout 						; Layouts
		Menu, Tray, add, %chngLayMenuItem%, changeActiveLayout 				; Change layout
	}
	Menu, Tray, add,
	Menu, Tray, add, %refreshMenuItem%, rerunWithSameLayout 				; Refresh
	Menu, Tray, add, %suspendMenuItem%, suspendToggle						; Suspend
	Menu, Tray, add, %exitAppMenuItem%, exitPKL								; Exit
	
	pklAppName := getPklInfo( "pklName" )
	pklVersion := getPklInfo( "pklVers" )
	Menu, Tray, Tip, %pklAppName% v%pklVersion%`n(%activeLayName%)

	Menu, Tray, Click, 2
	try {
		Menu, Tray, Default, % pklIniRead( "trayMenuDefault", suspendMenuItem )
	} catch {
		pklWarning( "EPKL_Settings .ini:`nNon-existing menu item specified as default!?" )
	}
;	if ( numOfLayouts > 1 ) {
;		Menu, Tray, Default, %chngLayMenuItem%
;	} else {
;		Menu, Tray, Default, %suspendMenuItem%
;	}
	
	; eD: Icon lists with numbers can be found using the enclosed Resources\AHK_MenuIconList.ahk script.
	Menu, Tray, Icon,      %aboutMeMenuItem%,  shell32.dll ,  24 		; aboutMe icon - about/question
	Menu, Tray, Icon,      %settingMenuItem%,  shell32.dll ,  72 		; showImg icon - cogwheels in window (91: Cogs over window; 317: Blue cogs)
	if ( ShowMoreInfo ) {
		Menu, Tray, Icon,  %keyHistMenuItem%,  shell32.dll , 222 		; keyHist icon - info
		Menu, Tray, Icon,  %deadKeyMenuItem%,  shell32.dll , 172 		; deadKey icon - search
		Menu, Tray, Icon,  %makeImgMenuItem%,  shell32.dll , 142 		; makeImg icon - painting on screen
	}
	Menu, Tray, Icon,  %refreshMenuItem%,  shell32.dll , 239 			; refresh icon - refresh arrows
	Menu, Tray, Icon,      %showImgMenuItem%,  shell32.dll , 174 		; showImg icon - keyboard (116: film)
	Menu, Tray, Icon,      %zoomImgMenuItem%,  shell32.dll ,  23 		; zoomImg icon - spyglass
;	Menu, Tray, Icon,      %moveImgMenuItem%,  shell32.dll ,  25 		; moveImg icon - speeding window
;	Menu, Tray, Icon,      %opaqImgMenuItem%,  shell32.dll ,  90 		; opaqImg icon - double windows
	if ( numOfLayouts > 1 ) {
		Menu, Tray, Icon,  %layoutsMenu%    ,  shell32.dll ,  44 		; layouts menu icon - star
		Menu, Tray, Icon,  %chngLayMenuItem%,  shell32.dll , 138 		; chngLay icon - forward arrow
	}
	Menu, Tray, Icon,      %suspendMenuItem%,  shell32.dll , 110 		; suspend icon - crossed circle
	Menu, Tray, Icon,      %exitAppMenuItem%,  shell32.dll ,  28 		; exitApp icon - power off
;	OnMessage( 0x404, "_AHK_NOTIFYICON" ) 								; Handle tray icon clicks. Using AHK defaults now.
}

pkl_about()
{
	msLID := getWinLocaleID() 									; The 4-xdigit Windows Locale ID (usually decimal)
	wLang := A_Language 										; The 4-xdigit Language code (often same as LID)
	dkStr := getCurrentWinLayDeadKeys() 						; The Windows layout's dead key string
	dkStr := dkStr ? dkStr : "<none>"

	pklAppName      := getPklInfo( "pklName" )
	pklMainURL      := "https://github.com/Portable-Keyboard-Layout"
	pklProgURL      := getPklInfo( "pklHome" )
	pklVersion      := getPklInfo( "pklVers" )
	compiledOn      := getPklInfo( "pklComp" )
	aboutTitle      := "About EPKL"
	
	locUnknown      := getPklInfo( "LocStr_03" ) 				; "Unknown"
	locActLayout    := getPklInfo( "LocStr_04" ) 				; "Active Layout"
	locVersion      := getPklInfo( "LocStr_05" ) 				; "Version"
	locLanguage     := getPklInfo( "LocStr_06" ) 				; "Language"
	locCopyright    := getPklInfo( "LocStr_07" ) 				; "Copyright"
	locCompany      := getPklInfo( "LocStr_08" ) 				; "Company"
	locLicense      := getPklInfo( "LocStr_13" ) 				; "Licence: GPL v3"
	locDisclaim     := getPklInfo( "LocStr_14" ) 				; Program disclaimer
	locThanksTo     := getPklInfo( "LocStr_20" ) 				; "Thanks to"
	locTransFile    := getPklInfo( "LocStr_21" ) 				; Translation file
	locTransName    := getPklInfo( "LocStr_22" ) 				; Translator name
	
	layName  := pklIniRead( "layoutName", locUnknown, "LayIni", "information" )
	layVers  := pklIniRead( "version"   , locUnknown, "LayIni", "information" )
	layCode  := pklIniRead( "layoutCode", locUnknown, "LayIni", "information" )
	layCopy  := pklIniRead( "copyright" , locUnknown, "LayIni", "information" )
	layComp  := pklIniRead( "company"   , locUnknown, "LayIni", "information" )
	layPage  := pklIniRead( "homepage"  , ""        , "LayIni", "information" )
	lLocale  := pklIniRead( "localeID"  , "0409"    , "LayIni", "information" )
	layLang  := pklIniRead( SubStr( lLocale, -3 ), "", "PklDic", "LangStrFromLangID" )
	kbdType  := getLayInfo( "Ini_KbdType" ) . " " . getLayInfo( "Ini_LayType" )
	hardMod  := getLayInfo( "Ini_CurlMod" ) . " " . getLayInfo( "Ini_ErgoMod" ) . " " . getLayInfo( "Ini_OthrMod" )
	layFile  := StrReplace( getPklInfo( "File_LayIni" ), "layout.ini", "" )
	basFile  :=             getPklInfo( "File_BasIni" )
	menuSep  := "............................................................................................"
	
	if WinActive( aboutTitle ) { 								; Toggle the GUI off if it's the active window
		GUI, AW: Destroy
		Return
	}
	GUI, AW:New,       , %aboutTitle% 							; About... window (default GUI)
	GUI, AW:Add, Text, , %pklAppName% v%pklVersion%
	if ( pklProgURL != pklMainURL ) {
		GUI, AW:Add, Edit, , %pklProgURL%
		GUI, AW:Add, Text, , Based on Portable Keyboard Layout v0.4
	}
	GUI, AW:Add, Edit, , %pklMainURL%
	GUI, AW:Add, Text, , `n(c) FARKAS, Máté, 2007-2010`n(c) OEystein Bech-Aase, 2015-
	GUI, AW:Add, Text, , %locThanksTo%: Chris Mallet && The AHK Foundation
	GUI, AW:Add, Text, , %locDisclaim%`n`n%locLicense%
	GUI, AW:Add, Edit, , http://www.gnu.org/licenses/gpl-3.0.txt
	GUI, AW:Add, Text, , % ( locTransName == "[[Translator name]]" ) ? "" : "`n" . locTransFile . ": " . locTransName
	GUI, AW:Add, Text, , % menuSep  	; ——————————————————————————————————————————————————————
	text := locActLayout . ": " . layName . "`n"
	text .= locVersion   . ": " . layVers . "`n"
	text .= locLanguage  . ": " . layLang . " (++?)`n"
	text .= locCopyright . ": " . layCopy . "`n"
	text .= locCompany   . ": " . layComp
	GUI, AW:Add, Text, , %text% 								; Layout info
	GUI, AW:Add, Edit, , %layPage%
	if getPklInfo( "AdvancedMode" ) { 							; Advanced Mode shows more info
		GUI, AW:Add, Text, , % menuSep  	; ——————————————————————————————————————————————————————
;		text :=   "Keyboard/Layout type from settings: "    . kbdType
;		text .= "`nCurl/Ergo/Other mod from settings: "     . hardMod
;		text .= "`n" 											; Since layouts can be chosen with the Layout Picker, this info is confusing now
		text :=   "EPKL.exe compiled on: "                  . compiledOn            . "`n"
		text .= "`nCurrent Windows Locale / Language ID: "  . msLID . " / " . wLang
		text .= "`nDead keys set for this Windows layout: " . dkStr                 . "`n"
		text .= "`nLayout/BaseLayout file paths:`n- " . layFile . "`n- " . basFile
		GUI, AW:Add, Text, , %text% 							; Win Locale ID and OS layout DKs
	}
	GUI, AW:Show
}

readLayoutIcons( layIni ) 										; Read On/Off icons for a specified layout
{
	For ix, icon in [ "on.ico", "off.ico" ] {
		SplitPath, layIni, , layDir 							; The icon files may be in the layout dir
		layDir  := ( layIni == "LayStk" ) ? getPklInfo( "Dir_LayIni" ) : layDir
		dirIco  := layDir . "\" . icon
		iniIco  := fileOrAlt( pklIniRead( "icons_OnOff",, layIni ) . icon
							, "Files\ImgIcons\Gray_" . icon ) 	; If not specified in layout file or in dir, use this
		icoNum%ix%  := 1
		if FileExist( dirIco ) {
			icoFil%ix%  := dirIco
		} else if FileExist( iniIco ) {
			icoFil%ix%  := iniIco
		} else if ( A_IsCompiled ) { 							; If EPKL is compiled, can use internal icons from the .exe
			icoFil%ix%  := A_ScriptName
			icoNum%ix%  := ( icon == "on.ico" ) ? 1 : 5 		; was 6/3 in original PKL.exe - keyboard and red 'S' icons
		} else {
			icoFil%ix%  := "Resources\" . icon 					; If all else fails, look for a Resources\ .ico file
		}
	}	; end For icon
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
			Gosub ToggleSuspend				; This suspends EPKL on tray icon single-click
		}
	}
*/
