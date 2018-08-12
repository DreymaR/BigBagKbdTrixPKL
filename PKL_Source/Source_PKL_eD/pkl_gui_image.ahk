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
		ssuf   := getLayInfo( "dkImgSuf" )		; DK image state suffix
		thisDK := getKeyInfo( "CurrNameOfDK" )
		dkS    := []
		dkS0   := ( ssuf ) ? ssuf . "0" : ""  	; Img file state 0 suffix
		dkS[1] := ( ssuf ) ? ssuf . "1" : "sh"	; Img file state 1 suffix
		for i, st in [ 6, 7, 8, 9 ] {			; Loop through the remaining states
			dkS[ st ] := ssuf . st
		}	; eD TOFIX: A state6 img w/ a state6 DK sometimes seems to break DK img display if we're too fast?
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
