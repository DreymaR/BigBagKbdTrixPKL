;; ================================================================================================
;;  EPKL Help Image Generator: Generate help images from the active layout
;;      Calls InkScape with a .SVG template to generate a set of .PNG help images
;;      Edits the SVG template using a lookup dictionary of KLD(Co) key names; see the Remap file
;;      Example – KLD(Co) letters: |_Q|_W|_F|_P|_G|_J|_L|_U|_Y||_A|_R|_S|_T|_D|_H|_N|_E|_I|_O||_Z|_X|_C|_V|_B|_K|_M|
;;      The template can hold an area for ISO and another for ANSI, specified in the EPKL_ImgGen_Settings.ini file
;;      Images are made for each shift state, also for any dead keys if "Full" is chosen
;;      Images as state#.png in a time-marked subfolder of the layout folder. The DK images in a subfolder of that.
;;      Dead keys can be marked in a separate layer of the template image (in bold yellow in the default template)
;;      Special marks for released DK base chars and combining accents
;;      An Extend image is not generated, as these require a special layout
;

makeHelpImages() {
	HIG         := {} 											; This parameter object is passed to subfunctions
	HIG.Title   :=  "EPKL Help Image Generator"
	remapFile   := getPklInfo( "RemapFile" ) 					; _eD_Remap.ini
	HIG.PngDic  := ReadKeyLayMapPDic( "Co", "SC", remapFile ) 	; PDic from the Co codes of the SVG template to SC
	imgRoot     := getLayInfo( "Dir_LayIni" ) . "\ImgGen_" . thisMinute()
	HIG.ImgDirs := { "root" : imgRoot , "raw" : imgRoot . "\RawFiles_Tmp" , "dkey" : imgRoot . "\DeadkeyImg" }
	HIG.Ini     := pklIniRead( "imgGenIniFile", "Files\HelpImgGenerator\EPKL_HelpImgGen_Settings.ini" )
	HIG.States  := pklIniRead( "imgStates", "0:1:6:7", HIG.Ini ) 	; Which shift states, if present, to render
	onlyMakeDK  := pklIniRead( "dkOnlyMakeThis",, HIG.Ini ) 		; Remake specified DK imgs (easier to test this var w/o using pklIniCSVs)
	makeMsgStr  := ( onlyMakeDK ) ? "`n`nNOTE: Only creating images for DK:`n" . onlyMakeDK . "." : ""
	if ( onlyMakeDK )
		HIG.ImgDirs[ "dkey" ] := HIG.ImgDirs[ "root" ]
	HIG.OrigImg := pklIniRead( "svgImgTemplate" ,       , HIG.Ini )
	HIG.InkPath := pklIniRead( "InkscapePath"   ,       , HIG.Ini )
	HIG.MkNaChr := pklIniRead( "imgNonCharMark" , 0x25AF, HIG.Ini ) 	; U+25AF White Rectangle
	HIG.MkDkBas := pklIniRead( "dkBaseCharMark" , 0x2B24, HIG.Ini ) 	; U+2B24 Black Large Circle
	HIG.MkDkCmb := pklIniRead( "dkCombCharMark" , 0x25CC, HIG.Ini ) 	; U+25CC Dotted Circle
	HIG.MkTpMod := pklIniRead( "tmTapOrModMark" , 0x25CC, HIG.Ini ) 	; U+25CC Dotted Circle
	HIG.MkEllip := 0x22EF 												; U+22EF Midline horizontal ellipsis (⋯)
	
	imXY        := pklIniCSVs( "imgPos" . getLayInfo( "Ini_KbdType" ) ,     , HIG.Ini )
	imWH        := pklIniCSVs( "imgSizeWH"                            ,     , HIG.Ini )
	imgDPI      := pklIniRead( "imgResDPI"                            , 96  , HIG.Ini )
	areaStr     := imXY[1] . ":" . imXY[2] . ":" . imXY[1]+imWH[1] . ":" . imXY[2]+imWH[2]	; --export-area=x0:y0:x1:y1
	HIG.inkOpts := " --export-type=""png""" 					; Prior to InkScape v1.0, the export command was "--export-png=" . pngFile for each file
				.  " --export-area=" . areaStr . " --export-dpi=" . imgDPI
	
	SetTimer, ChangeButtonNamesHIG, 100 						; Timer routine to change the MsgBox button texts
	MsgBox, 0x133, Make Help Images?, 
(
EPKL Help Image Generator
—————————————————————————————

Using Inkscape, make a help image for each Shift/AltGr state
and dead key under a subfolder of the current layout folder.
These may then be moved up to the folder for use with EPKL.

Do you want to make a full set of help images
for the current layout, or only state images?
(Many Inkscape calls will take a long time!)%makeMsgStr%
)
	IfMsgBox, Cancel 				; MsgBox type is 0x3 (Yes/No/Cancel) + 0x30 (Warning) + 0x100 (2nd button is default)
		Return
	IfMsgBox, No 					; Make only the state images, not the full set with deadkey images
		stateImgOnly := true
	stateImgOnly := ( onlyMakeDK ) ? false : stateImgOnly 		; StateImgOnly overrides DK images, unless DK only is set
	if not FileExist( HIG.InkPath ) {
		pklErrorMsg( "You must set a path to a working copy of Inkscape in " . HIG.Ini . "!" )
		Return
	}
	pklSplash( HIG.Title, "Starting...", 3 ) 					;MsgBox, 0x41, %HIG.Title%, Starting..., 1.0
	try {
		for dirTag, theDir in HIG.ImgDirs 						; Make directories
		{
			if ( dirTag == "dkey" && ( stateImgOnly || onlyMakeDK ) )
				Continue
			FileCreateDir % theDir
		}
	} catch {
		pklErrorMsg( "Couldn't create folders." )
		Return
	}
	shiftStates := getLayInfo( "shiftStates" ) 					; may skip some, e.g., state 2 (Ctrl), by imgStates
	HIG.imgMake := ( onlyMakeDK ) ? "--" : "shift state" 		; If refreshing one DK, don't render state images
	HIG.destDir := HIG.ImgDirs[ "root" ]
	HIG.imgType := "ShSt"
	HIG.imgName := "state"
	For ix, state in shiftStates 								; Shift state loop - also detects dead keys
		_makeImgDicThenImg( HIG, state )
	HIG.imgMake := "deadkey" 									; What type of image to render
	HIG.destDir := HIG.ImgDirs[ "dkey" ]
	HIG.imgType := "DKSS"
	HIG.DKNames := ( onlyMakeDK ) ? StrSplit( onlyMakeDK, "," ) : HIG.DKNames
	For ix, dkName in HIG.DKNames { 							; Dead key loop
		if ( stateImgOnly )
			Break
		HIG.imgName := dkName
		For ix, state in shiftStates
			_makeImgDicThenImg( HIG, state )
	}
;	Return 		; eD DEBUG
	_callInkscape( HIG ) 										; Call InkScape with all the SVG files at once now
	sleepTime := 5 												; Time to wait between each file check, in s
	Loop, 6
	{
		if ( A_Index >= 0 ) 	; eD WIP Check whether the last .PNG file has been made yet; how about full DK set?
			Break
		pklSplash( HIG.Title, "Waiting for images... " . A_Index * sleepTime . " s", 2 )
		Sleep % sleepTime * 1000
	}
	FileMove % HIG.ImgDirs["root"] . "\*.svg", % HIG.ImgDirs["raw"]
	FileMove % HIG.ImgDirs["dkey"] . "\*.svg", % HIG.ImgDirs["raw"]
	pklSplash( HIG.Title, "Image generation done!", 1 )
	delTmpFiles := pklIniRead( "delTmpSvgFiles" , 0, HIG.Ini ) 	; 0: Don't delete. 1: Recycle. 2: Delete.
	if        ( delTmpFiles == 2 ) {
		FileRemoveDir % HIG.ImgDirs["raw"], 1 					; Recurse = 1 to remove files inside dir
	} else if ( delTmpFiles == 1 ) {
		FileRecycle % HIG.ImgDirs["raw"]
	}
;	VarSetCapacity( HIG, 0 ) 									; Clean up the big variables after use; not necessary?
}

_makeImgDicThenImg( ByRef HIG, shSt ) { 						; Function to create a help image by a pdic.
	if not InStr( HIG.States, shSt ) 							; If this state isn't marked for rendering, skip it
		Return
	stateImg    := ( HIG.imgType == "ShSt" ) ? true : false 	; Base shift state image
	if ( HIG.imgType == "DKSS" ) { 								; Dead key shift state image
		dkName := HIG.imgName 									; DK name is used here and later
		dkMk := {}
		For ix, rel in [ 0, 1, 4, 5, 6, 7 ] { 					; Loop through DK releases to be marked, see the Deadkeys file
			dkV := DeadKeyValue( dkName, "s" . rel ) 			; Get the DeadKeyValue for the special entries
			if dkV
				dkMk[ _oneChr( dkV ) ] := true 					; Base char and comb. accents will be marked
;	( dkV == 180 ) ? pklDebug( "`n`n`n`n`n`n`n`n`n`n`n`ndkV: " . dkV . "`nrel: " . rel . "`nChr: " Chr(dkV) . "`n1Ch: " _oneChr(dkV), 6 )  ; eD DEBUG
		}	; end For release
	}
	emptyBool   := true 										; Keep track of whether a state layer is empty
	for CO, SC in HIG.PngDic
	{
		rel := ""
		tag := ""
		idKey   := shSt . CO
		if ( stateImg ) { 										; ****** Main layout shift state image ******
			ent     :=       getKeyInfo( SC . shSt       ) 		; Current layout key/state main entry
			ents    := ent . getKeyInfo( SC . shSt . "s" ) 		; Two-part key/state entry
			if ( not ent ) {
				Continue
			} else if ( ent == "@" ) { 							; Entry is a DeadKey; was "dk"
				dkName := getKeyInfo( ents ) 					; Get the true name of the dead key
				HIG.DKNames[ ents ] := dkName 					; eD TODO: Support chained DK. How? By using a DK list instead of this?
				rel := dkName
				tag := "DK_Key"
			} else if RegExMatch( ents, "i).*(space|spc).*" ) { 	; Note: As Spc is stored as 32, this isn't needed for normal entries.
				rel := 32 										; Space may be stored as (&)spc or ={space}; if so, show it as a space
			} else if ( getKeyInfo( SC . "tom" ) ) && ( InStr( "0:1", shSt ) ) {
				rel := ent
				tag := "ToMKey" 								; Mark Tap-or-Mod keys, for state 0:1
			} else {
				rel := ent
				tag := ""
;				naChr := Chr( HIG.MkNaChr ) 					; Not-a-char mark, default U+25AF Rect.
;				rel := ( isInt( ent ) )  ? ent : naChr 			; Replace unprintables (see pkl_send) 		; eD WIP: Make this more refined to support advanced entries?
;				rel := ( ent >= 32 )     ? rel : naChr 			; Replace control characters (ASCII < 0x20)
			}
		} else { 												; ****** Dead key shift state image ******
			base := HIG.ImgDic[ idKey ]
			if ( not base )
				Continue
			rel     := DeadKeyValue( dkName, base ) 			; Get the DeadKeyValue for the current state/key...
			tag := DkMk.HasKey( _oneChr(rel) ) ? "MrkdDK" : "" 	; The DKVal is in the base/mark list, so mark it for display (was "dc_") 	; eD WIP: This marks éèē for some reason?! Also Ω ƑƲ Ƕ ŪȲ æ Ɨ Ÿ . Mystery!
;				For macron: Plain macron is 175, ē/Ū/Ȳ are 275/362/562
			
			psp := pkl_ParseSend( rel, "ParseOnly" ) 			; Check for a parseable entry, without sending it
			ntr := SubStr( rel, 2 )
			if        InStr( "~«", psp ) { 						; ~ : Hex Unicode point U+####
				psp := ""
				rel := "0x" . ntr 								; No need for Format( "{:i}", "0x" . ntr ) here
			} else if InStr( "%→$§", psp ) { 					; Literals can have these prefixes, or be unprefixed
				psp := ""
				rel := SubStr( rel, 2 )
			} else if InStr( "*α=β@Ð&¶", psp ) { 				; AHK string(*α), Blind send(=β), DK(@Ð), PwrString(&¶)
				rel := "·" . psp . "·"
			}										; eD WIP: Move this to the write svg section, use on state imgs too. 1) Use _oneChr() 2) Mark prefix 3) Long literals (w/ or w/o %→ prefix) ".."
			if ( not psp ) {
			rel := ( rel && (rel + 0) == "" && StrLen( rel ) > 2 ) 		; eD WIP: Must not mark "dc_" keys here! Add if else to the above? 	; eD WIP: Do this in the image generating fn instead?
				? HIG.MkEllip : rel 							; Entry is a string, like {Home}+{End} or prefix-entry. Marked as an ellipse (midline ellipse?).
			}
			
			idKey   := dkName . "_" . idKey
;	( idKey == "Acute-Sup_0SPC" ) ? pklDebug( "`n`n`n`n`n`n`n`n`n`n`n`nBase: " . base . "`nent: " . ent . "`nrel: " . rel . "`ntag: " . tag . "`nChr: " Chr(rel), 6 )  ; eD DEBUG
		}	; end if imgName
		emptyBool := ( rel ) ? false : emptyBool
		HIG.ImgDic[ idKey       ]  := rel 						; Store the release value for this (DK/)state/key
		HIG.ImgDic[ idKey . "¤" ]  := tag 						; Store the tag            --"--
	}	; end For CO, SC
	
	if ( HIG.imgMake == "--" ) 									; Sometimes we just need the dictionary, like for single DK.
		Return
	;; ================================================================================================
	;:  _makeOneSVG( ByRef HIG, shSt ) 							; Generate a vector graphics (.SVG) help image from a template
	;
	preName := ( stateImg ) ? "" : HIG.imgName . " "
	if ( emptyBool ) {
		pklSplash( HIG.Title, "Layout " . HIG.imgMake . "`n" . preName . "state" . shSt . "`nempty - skipping.", 2 )
		Return
	} else {
		pklSplash( HIG.Title, "Making " . HIG.imgMake . " image for:`n" . preName . "state" . shSt . "`n", 3 )
	}
	
	if ( stateImg ) {
		indx    := shSt
		imgName := HIG.imgName . shSt
	} else { 													; e.g., "dk_breve"
		dkName  := HIG.imgName
		indx    := dkName . "_" . shSt
		imgName := dkName . getLayInfo( "dkImgSuf" ) . shSt 	; DK image state suffix, e.g., "breve_s0"
	}
	svgFile     := HIG.destDir . "\" . imgName . ".svg" 		; Was in HIG.ImgDirs["raw"] but multi-file call can't specify different destination paths
	
	if not tempImg := pklFileRead( HIG.OrigImg, "SVG template" )
		Return
	for CO, SC in HIG.PngDic
	{
		idKey   := indx . CO
		chrVal  := HIG.ImgDic[ idKey       ]
		chrTag  := HIG.ImgDic[ idKey . "¤" ] 					; Tags such as "DK_Key" for a Dead Key
		if ( not chrVal ) { 									; Empty entry
			aChr := "" 											; Alpha layer char
			dChr := "" 											; DKey layer char (mark, by default bold yellow)
		} else if ( chrTag == "DK_Key" ) { 						; Dead key (full dk Name, or classic name if used)
			dkV2 := DeadKeyValue( chrVal, "s2" ) 				; Get the base char (entry 2) for the dead key
			dkV2 := ( dkV2 ) ? dkV2 : DeadKeyValue( chrVal, "s0" ) 	; Fallback is entry0
			comb := _combAcc( dkV2 ) ? " " : "" 				; Pad combining accents w/ a space for better display
			aChr := comb . _svgChar( dkV2 ) 					; Note: Padding may lead to unwanted lateral shift
			dkV3 := DeadKeyValue( chrVal, "s3" ) 				; Get the alternate display base char, if it exists
			if ( dkV3 ) && ( dkV3 != dkV2 ) { 					; If there is a second display char, show both
				comb := ""	;_combAcc( dkV3 ) ? " " : "" 		; Note: Padding works well for some but not others.
				aChr := aChr . comb . _svgChar( dkV3 )
			}
			dChr := aChr
		} else if ( chrTag == "MrkdDK" ) { 						; Marked dead key base/accent char (marked in pdic)
			mark := _combAcc( chrVal ) ? HIG.MkDkCmb : HIG.MkDkBas
			aChr := _svgChar( chrVal )
			dChr := Chr( mark ) 								; Mark for DK base chars: Default U+2B24 Black Large Circle
		} else if ( chrTag == "ToMKey" ) { 						; Tap-or-Mod key
			aChr := _svgChar( chrVal )
			dChr := Chr( HIG.MkTpMod )
;		} else if ( chrTag == "--" ) {
;			aChr := Chr( HIG.MkNaChr ) 							; Replace nonprintables (marked in pdic)
;			dChr := ""
		} else { ; eD TODO:	Make an exception for letter keys, to avoid marking, e.g., greek mu on M? Or specify exceptions in Settings?!
			aChr := _svgChar( chrVal )
			dChr := "" 											; The dead key layer entry is empty for non-DK keys
		}
;	( idKey == "Acute-Sup_6SPC" ) ? pklDebug( "`n`n`n`n`n`n`n`n`n`n`n`nImg: " . ImgName . "`nKey: " . idKey . "`nVal: " . chrVal . "`nTag: " . chrTag . "`naChr: " . aChr . "`ndChr: " . dChr, 6 )  ; eD DEBUG
		CO := RegExReplace( CO, "_(\w\w)", "${1}" ) 			; Co _## entries are missing the underscore in the SVG template
		tstx := "</tspan></text>" 								; This always follows text elements in an SVG file
		needle := ">\K" . CO . tstx . "(.*>)" . CO . tstx 		; The RegEx to search for (ignore the start w/ \K)
		result := dChr . tstx . "${1}" . aChr . tstx 			; CO -> dChr, then next CO -> aChr
		tempImg := RegExReplace( tempImg, needle , result )
	}
;	Return 		; eD DEBUG
	if not pklFileWrite( tempImg, svgFile 						; Save the changed image file in a temp folder
						, "temporary SVG file" ) 				; Note: Inkscape SVG is UTF-8, w/ Linux line endings
		Return
	HIG.inkFile .= " " . svgFile 								; In InkScape v1.0, the "--file" option is gone, but multiple files can be used
}

_oneChr( ent ) { 												; Get a single-character entry in various formats (number, hex, prefix syntax)
	psp     := pkl_ParseSend( ent, "ParseOnly" ) 				; Check for prefix-entry syntax, without sending
	ntry    := SubStr( ent, 2 )
	if        InStr( "~«", psp ) { 								; ~ : Hex Unicode point U+####
		ent := "0x" . ntry
	} else if InStr( "$§%→", psp ) { 							; → : Literal string
		ent := ntry
	}
	if ( not ent + 0 ) 											; Non-numeric entry
		ent := ( StrLen(ent) == 1 ) ? Ord(ent) : "" 			; Convert single-char literals to their ordinal value
	Return % ent + 0 											; Convert hex to dec, longer entries to ""
}

_callInkscape( ByRef HIG ) {
	try { 														; Call InkScape w/ cmd line options
		RunWait % HIG.InkPath . HIG.inkOpts . HIG.inkFile 		; --without-gui is implicit for export commands.
	} catch {
		pklErrorMsg( "Running Inkscape failed." )
		Return
	}
}

_combAcc( ch ) { 												; Check whether a character code is a Combining Accent
	comb := ( ch >= 768 && ch <= 879 ) ? true : false 			; The main Unicode range for combining marks (768-879)
	Return comb
}

_svgChar( ch ) { 												; Convert character code to RegEx-able SVG text entry
	static escapeDic := {}
	escapeDic   :=  { "&"  : "&amp;"  , "'"  : "&apos;" , """" : "&quot;" 		; &'"<> for SVG XML compliance.
					, "<"  : "&lt;"   , ">"  : "&gt;"   , "$"  : "$$"     } 	; $ -> $$ for use with RegExReplace.
	txt := isInt( ch ) ? Chr( ch ) : ch
	For key, val in escapeDic
		txt := ( txt == key ) ? val : txt 						; Escape forbidden characters for XML/SVG and $ for RegEx
	Return txt
}

ChangeButtonNamesHIG: 											; For the MsgBox asking whether to make full or state images
	IfWinNotExist, Make Help Images?
		Return  												; Keep waiting for the message box if it isn't ready
	SetTimer, ChangeButtonNamesHIG, Off
	WinActivate
	ControlSetText, Button1, &Full
	ControlSetText, Button2, &State
Return
