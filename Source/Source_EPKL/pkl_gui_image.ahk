pkl_showHelpImage( activate = 0 )
{
;;  EPKL: Added and reworked help image functionality
;;      - Separate background image and Shift/AltGr indicator overlay, configurable in layout.ini
;;      - Transparent color for images (may work for the GUI window vs underlying windows now?)
;;      - Overall image opacity
;;      - Six positions with adjustable screen gutters and right/left push in addition to up/down
;;      - Rescaling by hotkey
;;  
;;  Parameter values:
;;   0 = display, if activated earlier
;;   1 = activate
;;  -1 = deactivate
;;   2 = toggle
;;   3 = suspend on
;;   4 = suspend off
;;   5 = zoom in/out
;;   6 = move between positions
;;  
	
	static guiActive    := 0 		; Whether the GUI is currently active; needed for toggling etc
	static guiActiveBeforeSuspend := 0
	static prevImg 					; The previous image file; if it hasn't changed, don't redraw
	static extendKey
	static imgPosXs     := []
	static imgPosYs     := []
	static imgPosNr     := 5 		; Default image position is bottom center (used to be "xCenter")
	static xPos
	static yPos
	static img_Width
	static imgHeight
	static wSiz
	static hSiz
	static imgZooms     := [] 		; Default [ 100, 150 ]
	static imgZoomNr    := 1
	static imgMrg       := [] 		; [ left, right, top, low, HorzPushPx ] image margins/gutters
	static imgHorZone 				; Part of image width that activates horizontal push, in %
	static layoutDir    := "--"
	static HelpImage 				; Image handle variable
	static HelpBgImg 				; --"--
	static HelpShImg 				; --"--
	static imgBgImage 				; BG image file
	static imgShftDir 				; Shift image directory
	static imgBgColor 				; Image GUI background color is set from the (base)layout.ini
	static imgOpacity 				; Global image opacity: 0 is invisible, 255 opaque
	
	if ( layoutDir == "--" ) 														; First-time initialization
	{
		layoutDir := getLayInfo( "layDir" )
		extendKey := getLayInfo( "extendKey" )
		imgBgImage  := fileOrAlt( pklIniRead( "img_bgImage",, "LayIni",, "BasIni" ) 
								, layoutDir . "\backgr.png"                       ) ; BG image, if found
		imgShftDir  := fileOrAlt( pklIniRead( "img_shftDir",, "LayIni",, "BasIni" ) 
								, layoutDir . "\ModStateImg"                      ) ; Shift state images
		imgBgColor  := pklIniRead( "img_bgColor"  , "fefeff", "LayIni",, "BasIni" ) ; BG color
		imgOpacity  := pklIniRead( "img_opacity"  , 255         )
		imgZooms    := pklIniCSVs( "img_zooms"    , "100,150"   )
		imgSizeWH   := pklIniCSVs( "img_sizeWH","541,188", "LayIni",, "BasIni" ) 	; Was img_width/img_height in [global]
;		img_Width   := pklIniRead( "img_width"    , 0     , "LayIni",, "BasIni" ) 	; Was in [global]
;		imgHeight   := pklIniRead( "img_height"   , 0     , "LayIni",, "BasIni" ) 	; --"--
		img_Scale   := pklIniRead( "img_scale"    , 100   , "LayIni",, "BasIni" ) 	; Image scale factor, in % (may be float)
		img_Width   := Ceil( img_Scale * imgSizeWH[1] / 100 )
		imgHeight   := Ceil( img_Scale * imgSizeWH[2] / 100 )
		img_Width   := ( img_Width ) ? img_Width : pklIniRead( "img_width" , 460, "LayIni", "global" )
		imgHeight   := ( imgHeight ) ? imgHeight : pklIniRead( "img_height", 160, "LayIni", "global" )
		imgHorZone  := pklIniRead( "img_horZone"  , 20 ) 					; % of width that activates horizontal push - stored as a margin
		imgMrg      := pklIniCSVs( "img_mrg_lrtb" , "2,2,2,42" ) 			; [ Left, Right, Top, Bottom ] image margins, in px
;		imgMrg.Push( 0 ) 													; [5]: The horz. push zone in px will be set/rescaled later
		scaleImage  := 1 													; Request an image scaling before drawing it below
	}	; end first-time initialization
	
	if ( activate == 2 ) 			; Toggle
		activate    := 1 - 2 * guiActive
	if ( activate == 1 ) { 			; Activate
		guiActive   := 1
	} else if ( activate == -1 ) { 	; Deactivate
		guiActive   := 0
	} else if ( activate == 3 ) { 	; Suspend on
		guiActiveBeforeSuspend := guiActive
		activate    := -1
		guiActive   := 0
	} else if ( activate == 4 ) { 	; Suspend off
		if ( guiActiveBeforeSuspend == 1 && guiActive != 1) {
			activate    := 1
			guiActive   := 1
		}
	} else if ( activate == 5 ) { 	; Zoom in/out
		if ( ++imgZoomNr > imgZooms.maxIndex() )
			imgZoomNr := 1
		scaleImage := 1
	} else if ( activate == 6 ) { 	; Move image +1 position
		if ( ++imgPosNr > 6 )
			imgPosNr := 1
		scaleImage := 1
	}
	state := _GetState()
	
	if ( activate == 1 ) { 												; Activate the help image
		Menu, Tray, Check, % getPklInfo( "LocStr_ShowHelpImgMenu" ) 	; Tick off the Show Help Image menu item
		Gui, 2:+AlwaysOnTop -Border -Caption +ToolWindow +LastFound 	; Create GUI 2 for the images
		Gui, 2:Margin, 0, 0
		Gui, 2:Color, %imgBgColor%
		if ( imgOpacity > 0 && imgOpacity < 255 )
			WinSet, Transparent, %imgOpacity%
		Gui, 2: Add, Pic, xm +BackgroundTrans vHelpBgImg AltSubmit 		; Make image controls stored in Help##### variables
		Gui, 2: Add, Pic, xm +BackgroundTrans vHelpImage AltSubmit
		Gui, 2: Add, Pic, xm +BackgroundTrans vHelpShImg AltSubmit
;		GuiControl, 2:, HelpBgImg, *w%wSiz% *h%hSiz% %imgBgImage% 		; eD WIP: Refresh the controls only at the end of this fn
;		GuiControl, 2:, HelpImage, *w%wSiz% *h%hSiz% %layoutDir%\state%state%.png
;		GuiControl, 2:, HelpShImg, *w%wSiz% *h%hSiz% %imgShftDir%\state%state%.png
;		Gui, 2: Show, x%xPos% y%yPos% AutoSize NA, pklHelpImage 		; eD WIP: The window title shouldn't be redone over and over.
		
		if ( imgOpacity == -1 ) {
			WinSet, TransColor, %imgBgColor%, pklHelpImage
		}	; eD NOTE: Seems that vVv got transparent color to work with separate GUIs for front/back?
		
		setTimer, showHelpImage, 200 									; Refresh the help image every 0.2 s
	} else if ( activate == -1 ) { 										; Deactivate image
		Menu, Tray, UnCheck, % getPklInfo( "LocStr_ShowHelpImgMenu" )
		setTimer, showHelpImage, Off
		Gui, 2:Destroy
		Return
	}
	if ( guiActive == 0 )
		Return
	
	CoordMode, Mouse, Screen 											; Mousing over the image pushes it away
	MouseGetPos, mouseX, , id
	WinGetTitle, title, ahk_id %id%
	if ( title == "pklHelpImage" ) {
		if ( mouseX - xPos < imgMrg[5] ) {
			imgPosNr := ( imgPosNr = 6 ) ? 1 : imgPosNr + 1				; Right (with wrap)
		} else if ( mouseX - xPos > wSiz - imgMrg[5] ) {
			imgPosNr := ( imgPosNr = 1 ) ? 6 : imgPosNr - 1				; Left   --"--
		} else {
			imgPosNr := ( imgPosNr > 3 ) ? imgPosNr - 3 : imgPosNr + 3	; Top/Bottom
		}
		scaleImage := 1
	}
	
	if ( getKeyInfo( "CurrNumOfDKs" ) ) {								; DeadKey image
		thisDK  := getLayInfo( "dkImgDir" ) . "\" . getKeyInfo( "CurrNameOfDK" )
		ssuf    := getLayInfo( "dkImgSuf" )								; DK image state suffix
		dkS     := []
		dkS0    := ( ssuf ) ? ssuf . "0.png" :   ".png"					; Img file state 0 suffix
		dkS[1]  := ( ssuf ) ? ssuf . "1.png" : "sh.png"					; Img file state 1 suffix
		for ix, st in [ 6, 7, 8, 9 ] {									; Loop through the remaining states
			dkS[ st ] := ssuf . st . ".png"
		}	; eD TOFIX: A state6 img w/ a state6 DK sometimes seems to break DK img display if we're too fast?
		imgPath := thisDK . dkS0
		imgPath := ( state ) ? fileOrAlt( thisDK . dkS[state], imgPath ) : imgPath
	} else if ( extendKey && getKeyState( extendKey, "P" ) ) { 			; Extend image
		imgPath := getLayInfo( "extendImg" )							; Default layoutDir . "\extend.png"
	} else {															; Shift state image
		imgPath := layoutDir . "\state" . state . ".png"
	}
	imgPath := FileExist( imgPath ) ? imgPath : layoutDir . "\state0.png" 	; The fallback image is state0
	
	if ( scaleImage ) {
		wSiz        := Ceil( img_Width * imgZooms[ imgZoomNr ] / 100 )
		hSiz        := Ceil( imgHeight * imgZooms[ imgZoomNr ] / 100 )
		imgMrg[5]   := Floor( wSiz * imgHorZone / 100 ) 				; Horz. push zone, in px
		imgHorPos := [ imgMrg[1], ( A_ScreenWidth - wSiz )/2, A_ScreenWidth  - wSiz - imgMrg[2] ]	; Left/Mid/Right
		imgVerPos := [ imgMrg[3],                             A_ScreenHeight - hSiz - imgMrg[4] ]	; Top/bottom
		Loop % 6 {
			imgPosXs[ A_Index ] := imgHorPos[ 1 + Mod( ( A_Index - 1 ) , 3 ) ]
			imgPosYs[ A_Index ] := imgVerPos[ Ceil( A_Index / 3 ) ]
		}
		xPos := imgPosXs[ imgPosNr ]
		yPos := imgPosYs[ imgPosNr ]
	} else if ( prevImg == imgPath ) && ( ! activate ) {
		Return 															; Only redraw the images if they changed
	}
	prevImg := imgPath
	
	GuiControl, 2:, HelpBgImg, *w%wSiz% *h%hSiz% %imgBgImage% 			; Show the images with the right size
	GuiControl, 2:, HelpImage, *w%wSiz% *h%hSiz% %imgPath%
	GuiControl, 2:, HelpShImg, *w%wSiz% *h%hSiz% %imgShftDir%\state%state%.png
	Gui, 2: Show, x%xPos% y%yPos% AutoSize NA, pklHelpImage 			; Use AutoSize NA to avoid stealing focus
}

_GetState() 															; Get the 0:1:6:7 shift state as in layout.ini and img names
{
	state = 0
	state += 1 * getKeyState( "Shift" )
	state += 6 * getLayInfo( "hasAltGr" ) * AltGrIsPressed()
	Return state
}
