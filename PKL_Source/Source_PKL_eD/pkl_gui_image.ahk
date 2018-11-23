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
	static prevImg
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
		imgBgImage  := fileOrAlt( pklIniRead( "img_bgImage",, "LayIni",, "BasIni" ) 
								, layoutDir . "\backgr.png"                       ) 	; BG image, if found
		imgShftDir  := fileOrAlt( pklIniRead( "img_shftDir",, "LayIni",, "BasIni" ) 
								, layoutDir . "\ModStateImg"                      ) 	; Shift state images
		imgBgColor := pklIniRead( "img_bgColor"  , "fefeff" , "LayIni",, "BasIni" ) 	; BG color
		imgOpacity := pklIniRead( "img_opacity"  , 255   )
		imgHorZone := pklIniRead( "img_horZone"  , 20    )
		if ( not imgPosNr ) {
			imgSizeWH := pklIniCSVs( "img_sizeWH",, "LayIni",, "BasIni" )				; Was img_width/img_height in [global]
;			img_Width := pklIniRead( "img_width"    , 0     , "LayIni",, "BasIni" ) 	; Was in [global]
;			imgHeight := pklIniRead( "img_height"   , 0     , "LayIni",, "BasIni" ) 	; --"--
			img_Scale := pklIniRead( "img_scale"    , 100.0 , "LayIni",, "BasIni" ) 	; Scale factor, in % (float)
			img_Width := Ceil( img_Scale * imgSizeWH[1] / 100.0 )
			imgHeight := Ceil( img_Scale * imgSizeWH[2] / 100.0 )
			img_Width := ( img_Width ) ? img_Width : pklIniRead( "img_width" , 460, "LayIni", "global" )
			imgHeight := ( imgHeight ) ? imgHeight : pklIniRead( "img_height", 160, "LayIni", "global" )
			imgTopMrg := pklIniRead( "img_top_mrg"  , 10 )								; Image margins are in PklIni
			imgLowMrg := pklIniRead( "img_low_mrg"  , 60 )
			imgHorMrg := pklIniRead( "img_hor_mrg"  , 10 )
			imgHorPos := [ imgHorMrg, ( A_ScreenWidth - img_Width )/2, A_ScreenWidth  - img_Width - imgHorMrg ]	; Left/Mid/Right
			imgVerPos := [ imgTopMrg,                                  A_ScreenHeight - imgHeight - imgLowMrg ]	; Top/bottom
			Loop % 6 {
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
		Return
	}
	if ( guiActive == 0 )
		Return
	
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
	
	if ( getKeyInfo( "CurrNumOfDKs" ) ) {								; DK images
		thisDK  := getLayInfo( "dkImgDir" ) . "\" . getKeyInfo( "CurrNameOfDK" )
		ssuf    := getLayInfo( "dkImgSuf" )					; DK image state suffix
		dkS     := []
		dkS0    := ( ssuf ) ? ssuf . "0.png" :   ".png"		; Img file state 0 suffix
		dkS[1]  := ( ssuf ) ? ssuf . "1.png" : "sh.png"		; Img file state 1 suffix
		for ix, st in [ 6, 7, 8, 9 ] {						; Loop through the remaining states
			dkS[ st ] := ssuf . st . ".png"
		}	; eD TOFIX: A state6 img w/ a state6 DK sometimes seems to break DK img display if we're too fast?
		imgPath := thisDK . dkS0
		imgPath := ( state ) ? fileOrAlt( thisDK . dkS[state], imgPath ) : imgPath
	} else if ( extendKey && getKeyState( extendKey, "P" ) ) {			; Extend image
		imgPath := getLayInfo( "extndImg" )					; Default layoutDir . "\extend.png"
	} else {															; Shift state images
		imgPath := layoutDir . "\state" . state . ".png"
	}
	imgPath := FileExist( imgPath ) ? imgPath : layoutDir . "\state0.png"
	if ( prevImg == imgPath )
		Return
	prevImg := imgPath
	
	GuiControl, 2:, HelpImage, *w%img_Width% *h%imgHeight% %imgPath%
	GuiControl, 2:, HelpShImg, *w%img_Width% *h%imgHeight% %imgShftDir%\state%state%.png
}

_GetState()	; The shift state 0:1:6:7 as in layout.ini and image names
{
	state = 0
	state += 1 * getKeyState( "Shift" )
	state += 6 * getLayInfo( "hasAltGr" ) * AltGrIsPressed()
	Return state
}
