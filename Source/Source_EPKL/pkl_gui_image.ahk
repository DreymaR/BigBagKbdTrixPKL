﻿;; ================================================================================================
;;  EPKL Image module: Display help images by shift state, also for dead keys and Extend layers.
;;    - Separate background image and Shift/AltGr indicator overlay, configurable in layout.ini
;;    - Transparent color for images (may work for the GUI window vs underlying windows now?)
;;    - Overall image opacity
;;    - Six positions with adjustable screen gutters and right/left push in addition to up/down
;;    - Rescaling by hotkey
;

pkl_showHelpImage( activate = 0 )
{
;;  Parameter values:
;;  Show    	 0 = display, if activated earlier
;;  Init    	 1 = activate
;;  Kill    	-1 = deactivate
;;  Toggle  	 2 = toggle image
;;  SuspOn  	 3 = suspend on
;;  SuspOff 	-3 = suspend off
;;  Zoom    	 5 = zoom in/out
;;  Move    	 6 = move between positions
;;  Opaq    	 7 = opaque/transparent
	
	static im           := {} 			; Only one static now. But: Not compatible with %var% notation!
;	static im.Active    := 0 			; Whether the GUI is currently active; needed for toggling etc
;	static im.Prev 						; The previous image file; if it hasn't changed, don't redraw
;	static im.PosNr     := 5 			; Default image position is bottom center (used to be "xCenter")
;	static im.Mrg       := [] 			; [ left, right, top, low, HorzPushPx ] image margins/gutters
;	static im.HorZone 					; Part of image width that activates horizontal push, in %
;	static im.BgPath 					; Background image file
;	static im.ShRoot 					; Shift image directory
;	static im.BgColor 					; Image GUI background color is set from the (base)layout.ini
;	static im.Opacity 					; Global image opacity: 0 is invisible, 255 opaque
	static imgX, imgY 					; Keep these for %var% use with the Gui commands
	static imgW, imgH
	static CtrlKyImg 					; Image control handle
	static CtrlBgImg 					; --"--
	static CtrlShImg 					; --"--
	static initialized  := false
	
	if ( not initialized ) 				; First-time initialization
	{
		im.LayDir   := getPklInfo( "Dir_LayImg" ) 							; The dir for state etc images; by default Dir_LayIni
		im.DK1Dir   := getPklInfo( "Dir_LayIni" ) . "\DeadkeyImg" 			; The 1st DK img dir is local, if found
		im.DK2Dir   := getLayInfo( "dkImgDir" )  							; The 2nd DK img dir, if set
		im.BgPath   := fileOrAlt( pklIniRead( "img_bgImage"  ,,  "LayStk" ) 
								, im.LayDir . "\backgr.png"              ) 	; BG image, if found
		im.ShRoot   := fileOrAlt( pklIniRead( "img_ModsDir"  ,,  "LayStk" ) 
								, im.LayDir . "\ModStateImg"             ) 	; Shift state images
		im.BgColor  := pklIniRead( "img_bgColor"  , "333333",   "LayStk" ) 	; BG color (was fefeff)
		im.OpacIni  := pklIniRead( "img_opacity"  , 255         )
		im.Opacity  := im.OpacIni 											; The actual image opacity (0-255; 255 is opaque)
		im.HiddenS  := pklIniCSVs( "img_HideStates" ) 						; Shift state images to hide, as CSV
		im.PosDef   := imgPosDic( pklIniRead( "img_StartPos", "BM" ), 5 ) 	; Default position is bottom center (used to be "xCenter")
		tmpPosArr   := pklIniCSVs( "img_Positions", "2,5" ) 				; Allowed image positions (used to be top/bottom middle)
		im.PosArr   := []
		For ix, pos in tmpPosArr {
			pos     := imgPosDic( pos, false )
			if ( pos && not hasValue( im.PosArr, pos ) ) {
				im.PosArr.Push( pos )
			}
		}
		im.PosDef   := hasValue( im.PosArr, im.PosDef ) ? im.PosDef : im.PosArr[1]
		im.PosIx    := hasValue( im.PosArr, im.PosDef ) 					; Physical image positions are Nr, logical Ix
		im.PosNr    := im.PosDef
		im.Zooms    := pklIniCSVs( "img_Zooms"    , "100,150"   )
		im.ZoomNr   := 1
		imgSizeWH   := pklIniCSVs( "img_sizeWH"   , "812,282",  "LayStk" ) 	; Image size in px, given as Width,Height
		img_Scale   := pklIniRead( "img_scale"    , 100      ,  "LayStk" ) 	; Image scale factor, in % (may be float)
		im.Width_   := Ceil( img_Scale * imgSizeWH[1] / 100 )
		im.Height   := Ceil( img_Scale * imgSizeWH[2] / 100 )
		im.Width_   := ( im.Width_ ) ? im.Width_ : pklIniRead( "img_width" , 460, "LayIni", "global" ) 	; The old PKL had sizes in [global]
		im.Height   := ( im.Height ) ? im.Height : pklIniRead( "img_height", 160, "LayIni", "global" ) 	; --"--
		im.HorZone  := pklIniRead( "img_horZone"  , 20 ) 					; % of width that activates horizontal push - stored as a margin
		im.Mrg      := pklIniCSVs( "img_mrg_lrtb" , "2,2,2,42" ) 			; [ Left, Right, Top, Bottom ] image margins, in px
;		im.Mrg.Push( 0 ) 													; [5]: The horz. push zone in px will be set/rescaled later
		scaleImage  := 1 													; Request an image scaling before drawing it below
		initialized := true
	}	; end first-time initialization
	
	if ( activate == 2 ) 												; Toggle image
		activate    := 1 - 2 * im.Active
	if        ( activate == 1 ) { 		; Activate
		im.Active   := 1
	} else if ( activate == -1 ) { 										; Deactivate
		im.Active   := 0
	} else if ( activate ==  3 ) { 										; Suspend on
		im.ActiveBeforeSuspend := im.Active
		activate    := -1
		im.Active   := 0
	} else if ( activate == -3 ) { 										; Suspend off
		if ( im.ActiveBeforeSuspend == 1 && im.Active != 1) {
			activate    := 1
			im.Active   := 1
		}
	} else if ( activate == 5 ) { 										; Zoom in/out
		if ( ++im.ZoomNr > im.Zooms.maxIndex() )
			im.ZoomNr   := 1
		scaleImage  := 1
	} else if ( activate == 6 ) { 										; Move image +1 position
		im.PosIx    := ( im.PosIx == im.PosArr.MaxIndex() ) ? 1 : ++im.PosIx
		scaleImage  := 1
	} else if ( activate == 7 ) { 										; Flip image between opaque and transparent (by opacity setting)
		im.Opacity  := ( im.Opacity == 255 ) ? im.OpacIni : 255
		activate    := 1 												; Ensure redrawing w/ new opacity
	}
	state := pklGetState()
	
	if ( activate == 1 ) { 												; Activate the help image
		Menu, Tray, Check, % getPklInfo( "LocStr_ShowHelpImgMenu" ) 	; Tick off the Show Help Image menu item
		GUI, HI:New, +AlwaysOnTop -Border -Caption +ToolWindow 			; Create a GUI for the help images
					+LastFound +Owner, 				pklImgWin 			; Owner removes the task bar button?
		GUI, HI:Margin, 0, 0
		GUI, HI:Color, % im.BgColor
		if ( im.Opacity > 0 && im.Opacity < 256 ) {
			WinSet, Transparent, % im.Opacity
		} else if ( im.Opacity == -1 ) {
			WinSet, TransColor, % im.BgColor, pklImgWin  				; eD WIP: This actually works, but if I resize the window it goes away again?
		}
		GUI, HI:Add, Pic, xm +BackgroundTrans vCtrlBgImg ; AltSubmit 	; Make image controls stored in Help##### variables
		GUI, HI:Add, Pic, xm +BackgroundTrans vCtrlKyImg ; AltSubmit
		GUI, HI:Add, Pic, xm +BackgroundTrans vCtrlShImg ; AltSubmit
		GUI, HI:Show, NA, 							pklImgWin
		
		SetTimer, showHelpImage, 170 									; Redraw the help image every # ms (screen refresh takes 16.7 ms @ 60 Hz)
	} else if ( activate == -1 ) { 										; Deactivate image
		Menu, Tray, UnCheck, % getPklInfo( "LocStr_ShowHelpImgMenu" )
		SetTimer, showHelpImage, Off
		GUI, HI:Destroy
		Return
	}
	if ( im.Active == 0 )
		Return
	
	CoordMode, Mouse, Screen 											; Mousing over the image pushes it away
	MouseGetPos, mouseX, , id
	WinGetTitle, title, ahk_id %id%
	if ( title == "pklImgWin" ) {
		max         := im.PosArr.MaxIndex()
		if ( mouseX - imgX < im.Mrg[5] ) { 								; Push +1/right (with wrap)
			im.PosIx    := ( im.PosIx = max ) ? 1 : ++im.PosIx
		} else if ( mouseX - imgX > imgW - im.Mrg[5] ) { 				; Push -1/left   --"--
			im.PosIx    := ( im.PosIx = 1 ) ? max : --im.PosIx
		} else { 														; Push up/down, if available
			here        := im.PosArr[ im.PosIx ]
			move        := ( here > 3 ) ? here - 3 : here + 3
			movIx       := hasValue( im.PosArr, move )
			im.PosIx    := movIx ? movIx 
						 : ( im.PosIx = max ) ? 1 : ++im.PosIx 			; If up/down isn't possible, move +1 instead
		}
		scaleImage  := 1
	}
	
	if getKeyInfo( "CurrNumOfDKs" ) { 									; DeadKey image
		thisDK  := getKeyInfo( "CurrNameOfDK" )
		pathDK  := FileExist( im.DK1Dir . "\" . thisDK . "*.*" )  		; Look for DK imgs in two dirs: Set, and local
							? im.DK1Dir . "\" . thisDK
							: im.DK2Dir . "\" . thisDK
		ssuf    := getLayInfo( "dkImgSuf" ) 							; DK image state suffix
		dkS     := []
		dkS0    := ( ssuf ) ? ssuf . "0.png" :   ".png" 				; Img file state 0 suffix
		dkS[1]  := ( ssuf ) ? ssuf . "1.png" : "sh.png" 				; Img file state 1 suffix
		For ix, st in [ 6, 7, 8, 9 ] {  								; Loop through the remaining states
			dkS[ st ] := ssuf . st . ".png"
		}	; A state6 img w/ a state6 DK may break DK img display if we're too fast. See 'SetTimer, showHelpImage'.
		imgPath := pathDK . dkS0 										; State0 is fallback for DK state imgs
		imgPath := ( state ) ? fileOrAlt( pathDK . dkS[state], imgPath ) : imgPath
		stateOn := "dk_" . thisDK 	; . "_s" . state 					; Only hide explicitly defined DK images
		imgPath := hasValue( im.HiddenS, "DKs", 0 ) ? "" : imgPath  	; If desired, hide all DK images instead 	; eD WIP: Hiding a DK image triggered by an AltGr+<key> DK fails!
	} else if ExtendIsPressed() { 										; Extend image
		imgPath := getLayInfo( "extendImg" ) 							; Default im.LayDir . "\extend.png"
		stateOn := "ext"
	} else { 															; Shift state image
		imgPath := im.LayDir . "\state" . state . ".png"
		stateOn := state
	}
	imgPath := hasValue( im.HiddenS, stateOn, 0 ) ? "" : imgPath 		; Hide specified states (caseless comparison)
	if ( imgPath )
		imgPath := FileExist( imgPath ) ? imgPath : im.LayDir . "\state0.png" 	; The fallback image is state0
	
	if ( scaleImage ) {
		imgW        := Ceil( im.Width_ * im.Zooms[ im.ZoomNr ] / 100 )
		imgH        := Ceil( im.Height * im.Zooms[ im.ZoomNr ] / 100 )
		im.Mrg[5]   := Floor( imgW * im.HorZone / 100 ) 				; Horz. push zone, in px
		imgHorPos := [ im.Mrg[1], ( A_ScreenWidth - imgW )/2, A_ScreenWidth  - imgW - im.Mrg[2] ]	; Left/Mid/Right
		imgVerPos := [ im.Mrg[3],                             A_ScreenHeight - imgH - im.Mrg[4] ]	; Top/bottom
		Loop % 6 { 														; Available rescaled image positions on screen
			im.PosXs[ A_Index ] := imgHorPos[ 1 + Mod( ( A_Index - 1 ) , 3 ) ]
			im.PosYs[ A_Index ] := imgVerPos[ Ceil( A_Index / 3 ) ]
		}
		imgX        := im.PosXs[ im.PosArr[ im.PosIx ] ]
		imgY        := im.PosYs[ im.PosArr[ im.PosIx ] ]
	} else if ( im.Prev == imgPath ) && ( ! activate ) {
		Return 															; Only redraw the images if they changed
	}
	im.Prev     := imgPath
	
	if ( imgPath ) {
	imgBgPath   := im.BgPath 											; Bg image
	imgShPath   := im.ShRoot . "\state" . state . ".png" 				; Shift state markers
	GuiControl, HI:, CtrlBgImg, *w%imgW% *h%imgH% %imgBgPath%
	GuiControl, HI:, CtrlKyImg, *w%imgW% *h%imgH% %imgPath%
	GuiControl, HI:, CtrlShImg, *w%imgW% *h%imgH% %imgShPath%
	GUI, HI: Show, x%imgX% y%imgY% AutoSize NA, 		pklImgWin 		; Use AutoSize NA to avoid stealing focus
	} else {
		GUI, HI:Hide
	}
}

pklGetState() { 														; Get the 0:1:6:7 shift state as in layout.ini and img names
	state  = 0
	state += 1 * getKeyState( "Shift" )
;	state += 2 * getKeyState( "Ctrl" )
	state += 6 * getLayInfo( "LayHasAltGr" ) * AltGrIsPressed()
	Return state
}

imgPosDic( pos, def = 0 ) { 											; Get a numerical image position from a T/B+L/M/R one, if needed
	posDic  := { "TL" : 1, "TM" : 2, "TR" : 3
			   , "BL" : 4, "BM" : 5, "BR" : 6 }
	if hasValue( [ 1, 2, 3, 4, 5, 6 ], pos ) { 							; Image positions may be numeric 1–6 already...
		posNr   := pos
	} else if posDic.HasKey( pos ) { 									; ...or in the posDic conversion array...
		posNr   := posDic[ pos ]
	} else { 															; ...or not
		posNr   := def
	}
	Return posNr
}
