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
	kbdType  := getLayInfo( "KbdType" )
	ergoMod  := getLayInfo( "CurlMod" ) . " / " . getLayInfo( "ErgoMod" )

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

pkl_showHelpImage( activate = 0 )
{
	; Parameter:
	; 0 = display, if activated
	;-1 = deactivate
	; 1 = activate
	; 2 = toggle
	; 3 = suspend on
	; 4 = suspend off
	
	static guiActiveBeforeSuspend := 0
	static guiActive := 0
	static prevFile
	static imgPosX   := []
	static imgPosY   := []
	static imgPosNr  := 0
	static xPos
	static yPos
	static img_Width
	static imgHeight
	static layoutDir := 0
	static extendKey
	static HelpImage
	static HelpBgImg
	static HelpShImg
	static imgBgImage
	static imgShftDir
	static imgBgColor
	static imgOpacity
	static imgHorZone
	
; eD: Added and reworked help image functionality
;     - Separate background image and Shift/AltGr indicator overlay
;     - Transparent color for images (works for top vs bottom image, but not for the GUI window vs underlying windows?)
;     - Overall image opacity
;     - Six positions with adjustable screen gutters and right/left push in addition to up/down
	
	if ( layoutDir == 0 )
	{
		layoutDir := getLayInfo( "layDir" )
		extendKey := getLayInfo( "extendKey" )
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
	state := _GetState()

	if ( activate == 1 ) {
		Menu, Tray, Check, % getPklInfo( "LocStr_ShowHelpImgMenu" )
		imgBgImage := pklIniRead( "img_bgImage"  , layoutDir . "\backgr.png", "Lay_Ini", "eD_info" )	; BG image
		if ( not FileExist ( imgBgImage ) )
			imgBgImage := ""	; eD: Is default robust if there's no .png nor layout.ini entry?
		imgShftDir := pklIniRead( "img_shftDir"  , ""                       , "Lay_Ini", "eD_info" )	; Shift images
		if ( not FileExist ( imgShftDir . "\state?.png" ) )
			imgShftDir := ""
		imgBgColor := pklIniRead( "img_bgColor"  , "fefeff"                 , "Lay_Ini", "eD_info" )	; BG color
		imgOpacity := pklIniRead( "img_opacity"  , 255                      , "Pkl_Ini", "eD" )
		imgHorZone := pklIniRead( "img_horZone"  , 20                       , "Pkl_Ini", "eD" )
		if ( not imgPosNr ) {
			img_Width := pklIniRead( "img_width"    , 0                     , "Lay_Ini", "eD_info"  )	; [global] is old default
			img_Width := ( img_Width ) ? img_Width : pklIniRead( "img_width" , 460, "Lay_Ini", "global" )
			imgHeight := pklIniRead( "img_height"   , 0                     , "Lay_Ini", "eD_info"  )	; --"--
			imgHeight := ( imgHeight ) ? imgHeight : pklIniRead( "img_height", 160, "Lay_Ini", "global" )
			img_Scale := pklIniRead( "img_scale"    , 100.0                 , "Lay_Ini", "eD_info" )	; Scale factor, in % (float)
			img_Width := Ceil( img_Scale * img_Width / 100.0 )
			imgHeight := Ceil( img_Scale * imgHeight / 100.0 )
			imgTopMrg := pklIniRead( "img_top_mrg"  , 10                    , "Pkl_Ini", "eD" )
			imgLowMrg := pklIniRead( "img_low_mrg"  , 60                    , "Pkl_Ini", "eD" )
			imgHorMrg := pklIniRead( "img_hor_mrg"  , 10                    , "Pkl_Ini", "eD" )
			imgHorPos := [ imgHorMrg, ( A_ScreenWidth - img_Width )/2, A_ScreenWidth  - img_Width - imgHorMrg ]	; Left/Mid/Right
			imgVerPos := [ imgTopMrg,                                  A_ScreenHeight - imgHeight - imgLowMrg ]	; Top/bottom
			Loop, 6 {
				imgPosX[ A_Index ] := imgHorPos[ 1 + Mod( ( A_Index - 1 ) , 3 ) ]
				imgPosY[ A_Index ] := imgVerPos[ Ceil( A_Index / 3 ) ]
			}
			imgPosNr := 5							; Default image position is bottom center (used to be "xCenter")
			xPos := imgPosX[ imgPosNr ]
			yPos := imgPosY[ imgPosNr ]
		}
		imgHorZone := Floor( img_Width * imgHorZone / 100 )		; Convert from percent to pixels
		Gui, 2:+AlwaysOnTop -Border -Caption +ToolWindow +LastFound
		Gui, 2:margin, 0, 0
		Gui, 2:Color, %imgBgColor%
		if ( imgOpacity > 0 && imgOpacity < 255 )
			WinSet, Transparent, %imgOpacity%
;		if ( imgBgImage <> "" )
;			Gui, 2:Show, x%xPos% y%yPos% AutoSize NA, pklHelpBgImg
		Gui, 2:Add, Pic, xm +BackgroundTrans vHelpBgImg AltSubmit
		GuiControl, 2:, HelpBgImg, *w%img_Width% *h%imgHeight% %imgBgImage%
		Gui, 2:Show, x%xPos% y%yPos% AutoSize NA, pklHelpBgImg
		Gui, 2:Add, Pic, xm +BackgroundTrans vHelpImage AltSubmit
		GuiControl, 2:, HelpImage, *w%img_Width% *h%imgHeight% %layoutDir%\state%state%.png
		Gui, 2:Show, x%xPos% y%yPos% AutoSize NA, pklHelpImage
		Gui, 2: Add, Pic, xm +BackgroundTrans vHelpShImg AltSubmit
		GuiControl, 2:, HelpShImg, *w%img_Width% *h%imgHeight% %imgShftDir%\state%state%.png
		Gui, 2: Show, x%xPos% y%yPos% AutoSize NA, pklHelpShImg
		if ( imgOpacity == -1 ) {
			WinSet, TransColor, %imgBgColor%, pklHelpBgImg
			WinSet, TransColor, %imgBgColor%, pklHelpImage
			WinSet, TransColor, %imgBgColor%, pklHelpShImg
		}	; eD: Seems that vVv got transparent color to work with separate GUIs for front/back?

		
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
	
	CoordMode, Mouse, Screen
	MouseGetPos, mouseX, , id
	WinGetTitle, title, ahk_id %id%
	if ( title == "pklHelpImage" ) || ( title == "pklHelpShImg" ) {
		if ( mouseX - xPos < imgHorZone ) {
			imgPosNr := ( imgPosNr = 6 ) ? 1 : imgPosNr + 1				; Right (with wrap)
		} else if ( mouseX - xPos > img_Width - imgHorZone ) {
			imgPosNr := ( imgPosNr = 1 ) ? 6 : imgPosNr - 1				; Left   --"--
		} else {
			imgPosNr := ( imgPosNr > 3 ) ? imgPosNr - 3 : imgPosNr + 3	; Top/Bottom
		}
		xPos := imgPosX[ imgPosNr ]
		yPos := imgPosY[ imgPosNr ]
		Gui, 2:Show, x%xPos% y%yPos% AutoSize NA, pklHelpImage
		Gui, 2:Show, x%xPos% y%yPos% AutoSize NA, pklHelpShImg
	}
	
	imgDir := LayoutDir
	if ( getKeyInfo( "CurrNumOfDKs" ) ) {
		imgDir := getLayInfo( "dkImgDir" )
		ssuf   := getLayInfo( "dkImgSuf" )		; Image state suffix
		thisDK := getKeyInfo( "CurrNameOfDK" )
		dkS    := []
		dkS0   := ( ssuf ) ? ssuf . "0" : ""  	; Img file state 0 suffix
		dkS[1] := ( ssuf ) ? ssuf . "1" : "sh"	; Img file state 1 suffix
		dkS[6] := ssuf . "6"
		dkS[7] := ssuf . "7"					; eD TODO: Add shift states 6-7 to images!
		if ( state ) {
			fileName := thisDK . dkS[state] . ".png"
			if ( not FileExist( imgDir . "\" . filename ) )
				fileName := thisDK . dkS0 . ".png"
		} else {
			fileName := thisDK . dkS0 . ".png"
		}
	} else if ( extendKey && getKeyState( extendKey, "P" ) ) {
		fileName = extend.png
	} else {
		fileName = state%state%.png
	}
	if ( not FileExist( imgDir . "\" . fileName ) )
		fileName = state0.png
	
	if ( prevFile == fileName )
		return
	prevFile := fileName
	
	GuiControl, 2:, HelpImage, *w%img_Width% *h%imgHeight% %imgDir%\%fileName%
	GuiControl, 2:, HelpShImg, *w%img_Width% *h%imgHeight% %imgShftDir%\state%state%.png
}

_GetState()	; The shift state 0:1:6:7 as in layout.ini and image names
{
	state = 0
	state += 1 * getKeyState( "Shift" )
	state += 6 * getLayInfo( "hasAltGr" ) * AltGrIsPressed()
	return state
}

_FixAmpInMenu( menuItem )
{
	menuItem := StrReplace( menuItem, " & ", "+" )		; Used to be '& , &&,' to display the ampersand.
	menuItem := " (" . menuItem . ")"
	return menuItem
}

pkl_MsgBox( msg, s = "", p = "", q = "", r = "" )
{
	msg := getPklInfo( "LocStr_" . msg )
	Loop, Parse, % "spqr"
	{
		it := A_LoopField
		msg := ( %it% == "" ) ? msg : StrReplace( msg, "#" . it . "#", %it% )
	}
	MsgBox %msg%
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
