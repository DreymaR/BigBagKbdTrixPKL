pkl_set_tray_menu()
{
	ShowMoreInfo := getPklInfo( "AdvancedMode" )	; eD: Show extra technical info and the Reset hotkey
	
	ExitAppHotkey   := getReadableHotkeyString( getPklInfo( "HK_ExitApp"      ) )
	ChngLayHotkey   := getReadableHotkeyString( getPklInfo( "HK_ChangeLayout" ) )
	SuspendHotkey   := getReadableHotkeyString( getPklInfo( "HK_Suspend"      ) )
	RefreshHotkey   := getReadableHotkeyString( getPklInfo( "HK_Refresh"      ) )
	HelpImgHotkey   := getReadableHotkeyString( getPklInfo( "HK_ShowHelpImg"  ) )
	
	activeLayout    := getLayInfo( "active" )
	activeLayName   := ""
	numOfLayouts  := getLayInfo( "numOfLayouts" )
	
	aboutmeMenuItem := getPklInfo( "LocStr_9"  )			; pklLocaleString()
	keyhistMenuItem := getPklInfo( "LocStr_KeyHistMenu" )
	deadkeyMenuItem := getPklInfo( "LocStr_12" )
	helpimgMenuItem := getPklInfo( "LocStr_15" )
	layoutsMenu     := getPklInfo( "LocStr_19" )
	chnglayMenuItem := getPklInfo( "LocStr_18" )
	refreshMenuItem := getPklInfo( "LocStr_RefreshMenu" )
	suspendMenuItem := getPklInfo( "LocStr_10" )
	exitappMenuItem := getPklInfo( "LocStr_11" )
	makeimgMenuItem := getPklInfo( "LocStr_MakeImgMenu" )
	helpimgMenuItem .= ( HelpImgHotkey ) ? _FixAmpInMenu( HelpImgHotkey ) : ""
	chnglayMenuItem .= ( ChngLayHotkey ) ? _FixAmpInMenu( ChngLayHotkey ) : ""
	refreshMenuItem .= ( RefreshHotkey ) ? _FixAmpInMenu( RefreshHotkey ) : ""
	suspendMenuItem .= ( SuspendHotkey ) ? _FixAmpInMenu( SuspendHotkey ) : ""
	exitappMenuItem .= ( ExitAppHotkey ) ? _FixAmpInMenu( ExitAppHotkey ) : ""
	setPklInfo( "LocStr_ShowHelpImgMenu", helpimgMenuItem )
	
	Loop, % numOfLayouts
	{
		layName := getLayInfo( "layout" . A_Index . "name" )	; Layout menu name
		layCode := getLayInfo( "layout" . A_Index . "code" )	; Layout dir name
		Menu, changeLayout, add, %layName%, changeLayoutMenu
		if ( layCode == activeLayout ) {
			Menu, changeLayout, Default, %layName%
			Menu, changeLayout, Check, %layName%
			activeLayName := layName
		}
		
		layIcon = Layouts\%layCode%\on.ico
		if ( not FileExist( layIcon ) )
			layIcon := A_ScriptName								; icon = on.ico
		Menu, changeLayout, Icon,        %layName%, %layIcon%, 1
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
		Menu, Tray, add, %makeimgMenuItem%, makeHelpImages					; Help Image Generator
	}
	Menu, Tray, add, %helpimgMenuItem%, showHelpImageToggle					; Show image
	if ( numOfLayouts > 1 ) {
		Menu, Tray, add,													; (separator)
		Menu, Tray, add, %layoutsMenu%, :changeLayout						; Layouts
		Menu, Tray, add, %chnglayMenuItem%, changeActiveLayout				; Change layout
	}
	Menu, Tray, add,
	if ( ShowMoreInfo ) {
		Menu, Tray, add, %refreshMenuItem%, rerunWithSameLayout 			; eD: Refresh
	}
	Menu, Tray, add, %suspendMenuItem%, toggleSuspend						; Suspend
	Menu, Tray, add, %exitappMenuItem%, ExitPKL								; Exit
	
	pklAppName := getPklInfo( "pklName" )
	pklVersion := getPklInfo( "pklVers" )
	Menu, Tray, Tip, %pklAppName% v%pklVersion%`n(%activeLayName%)

	Menu, Tray, Click, 2
	try {
		Menu, Tray, Default, % pklIniRead( "trayMenuDefault", suspendMenuItem, "Pkl_Ini", "eD" )
	} catch {
		MsgBox, PKL_eD.ini:`nNon-existent menu item specified as default!?
	}
;	if ( numOfLayouts > 1 ) {
;		Menu, Tray, Default, %chnglayMenuItem%
;	} else {
;		Menu, Tray, Default, %suspendMenuItem%
;	}
	
	; eD: Icon lists with numbers can be found using the enclosed Resources\AHK_MenuIconList.ahk script.
	Menu, Tray, Icon,      %aboutmeMenuItem%,  shell32.dll ,  24		; %aboutmeMenuItem% ico - about/question
	if ( ShowMoreInfo ) {
		Menu, Tray, Icon,  %keyhistMenuItem%,  shell32.dll , 222		; %keyhistMenuItem% ico - info
		Menu, Tray, Icon,  %deadkeyMenuItem%,  shell32.dll , 172		; %deadkeyMenuItem% ico - search (25: "speed")
		Menu, Tray, Icon,  %refreshMenuItem%,  shell32.dll , 239		; %refreshMenuItem% ico - refresh arrows
		Menu, Tray, Icon,  %makeimgMenuItem%,  shell32.dll , 142		; %makeimgMenuItem% ico - painting on screen
	}
	Menu, Tray, Icon,      %helpimgMenuItem%,  shell32.dll , 174		; %helpimgMenuItem% ico - keyboard (116: film)
	if ( numOfLayouts > 1 ) {
		Menu, Tray, Icon,  %layoutsMenu%    ,  shell32.dll ,  44		; %layoutsMenu%     ico - star
		Menu, Tray, Icon,  %chnglayMenuItem%,  shell32.dll , 138		; %chnglayMenuItem% ico - forward arrow
	}
	Menu, Tray, Icon,      %suspendMenuItem%,  shell32.dll , 110		; %suspendMenuItem% ico - crossed circle
	Menu, Tray, Icon,      %exitappMenuItem%,  shell32.dll ,  28		; %exitappMenuItem% ico - power off
;	OnMessage( 0x404, "_AHK_NOTIFYICON" )								; Handle tray icon clicks. Using AHK defaults now.
}

pkl_about()
{
	msLID := getWinLocaleID() 					; Get the Windows locale ID
	dkStr := getDeadKeysInCurrentLayout() 		; Show the current Windows layout's dead key string
	dkStr := dkStr ? dkStr : "<none>"

	pklAppName      := getPklInfo( "pklName" )
	pklMainURL      := "http://pkl.sourceforge.net"
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
	locInfos        := getPklInfo( "LocStr_14" )
	locContributors := getPklInfo( "LocStr_20" )
	translationName := getPklInfo( "LocStr_21" )
	translatorName  := getPklInfo( "LocStr_22" )
	
	layName  := pklIniRead( "layoutname", locUnknown, "Lay_Ini", "informations" )
	layVers  := pklIniRead( "version"   , locUnknown, "Lay_Ini", "informations" )
	layCode  := pklIniRead( "layoutcode", locUnknown, "Lay_Ini", "informations" )
	layCopy  := pklIniRead( "copyright" , locUnknown, "Lay_Ini", "informations" )
	layComp  := pklIniRead( "company"   , locUnknown, "Lay_Ini", "informations" )
	layPage  := pklIniRead( "homepage"  , ""        , "Lay_Ini", "informations" )
	lLocale  := pklIniRead( "localeid"  , "0409"    , "Lay_Ini", "informations" )
	layLang  := pklIniRead( SubStr( lLocale, -3 ), "", "Pkl_Dic", "LangStrFromLangID" )
	kbdType  := getLayInfo( "Ini_KbdType" )
	ergoMod  := getLayInfo( "Ini_CurlMod" ) . " / " . getLayInfo( "Ini_ErgoMod" )

	text = ;
	text = %text%
	Gui, Add, Text, , %pklAppName%, v%pklVersion% (%compiledAt%)
	Gui, Add, Edit, , %pklMainURL%
	if ( pklProgURL != pklMainURL )
		Gui, Add, Edit, , %pklProgURL%
	Gui, Add, Text, , ......................................................................
	Gui, Add, Text, , (c) FARKAS, Máté, 2007-2010
	Gui, Add, Text, , %locInfos%
	Gui, Add, Text, , %locLicense%
	Gui, Add, Edit, , http://www.gnu.org/licenses/gpl-3.0.txt
	Gui, Add, Text, , ......................................................................
	text = ;
	text = %text%%locContributors%:
	text = %text%`n- OEystein "DreymaR" Gadmar: PKL[eD]	; edition DreymaR
;	text = %text%`nAutoHotkey authors && contributors
	text = %text%`n- Chris Mallet && The AutoHotkey Foundation
;	text = %text%`n- The AutoHotkey Foundation: AHK v1.1
;	text = %text%`n  (Lexikos, Majkinetor, Shimanov, L. Hars...)
	if ( translatorName != "[[Translator name]]" )
		text = %text%`n`n%translatorName%: %translationName%
	Gui, Add, Text, , %text%
	Gui, Add, Text, , ......................................................................
	text = ;
	text = %text%%activeLayout%:`n  %layName%
	text = %text%`n%locVersion%: %layVers%
	text = %text%`n%locLanguage%: %layLang%
	text = %text%`n%locCopyright%: %layCopy%
	text = %text%`n%locCompany%: %layComp%
	Gui, Add, Text, , %text%
	Gui, Add, Edit, , %layPage%
	if ( getPklInfo( "AdvancedMode" ) ) {
		Gui, Add, Text, , ......................................................................
		text = ; eD: Show MS Locale ID and current underlying layout dead keys
		text = %text%Keyboard type (from PKL.ini): %kbdType%
		text = %text%`nCurl/Ergo mod type: %ergoMod%
		text = %text%`nCurrent Microsoft Windows Locale ID: %msLID%
		text = %text%`nDead keys set for this Windows layout: %dkStr%
		Gui, Add, Text, , %text%
	}
	Gui, Show
}

_FixAmpInMenu( menuItem )
{
	menuItem := StrReplace( menuItem, " & ", "+" )		; Used to be '& , &&,' to display the ampersand.
	menuItem := " (" . menuItem . ")"
	return menuItem
}

/*
	_AHK_NOTIFYICON(wParam, lParam)			; Called by tray icon clicks w/ OnMessage( 0x404 ). Now disabled.
	{
		if ( lParam == 0x205 ) { 			; WM_RBUTTONUP
			return
		} else if ( lParam == 0x201 ) { 	; WM_LBUTTONDOWN
			gosub ToggleSuspend				; This suspends PKL on tray icon single-click
		}
	}
*/
