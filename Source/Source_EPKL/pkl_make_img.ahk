;;  -----------------------------------------------------------------------------------------------
;;
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

makeHelpImages()
{
	HIG         := {} 											; This parameter object is passed to subfunctions
	HIG.Title   :=  "EPKL Help Image Generator"
	remapFile   := "Files\_eD_Remap.ini"
	HIG.PngDic  := ReadKeyLayMapPDic( "Co", "SC", remapFile ) 	; PDic from the Co codes of the SVG template to SC
	FormatTime, theNow,, yyyy-MM-dd_HHmm 						; Use A_Now (local time) for a folder time stamp
	imgRoot     := getLayInfo( "Dir_LayIni" ) . "\ImgGen_" . theNow
	HIG.ImgDirs := { "root" : imgRoot , "raw" : imgRoot . "\RawFiles_Tmp" , "dkey" : imgRoot . "\DeadkeyImg" }
	HIG.Ini     := pklIniRead( "imgGenIniFile", "Files\ImgGenerator\EPKL_ImgGen_Settings.ini" )
	HIG.States  := pklIniRead( "imgStates", "0:1:6:7", HIG.Ini ) 	; Which shift states, if present, to render
	onlyMakeDK  := pklIniRead( "dkOnlyMakeThis",, HIG.Ini ) 		; Refresh specified DK imgs
	makeMsgStr  := ( onlyMakeDK ) ? "`n`nNOTE: Only creating images for DK:`n" . onlyMakeDK . "." : ""
	if ( onlyMakeDK )
		HIG.ImgDirs[ "dkey" ] := HIG.ImgDirs[ "root" ]
	HIG.OrigImg := pklIniRead( "OrigImgFile"    ,       , HIG.Ini )
	HIG.InkPath := pklIniRead( "InkscapePath"   ,       , HIG.Ini )
	HIG.MkNaChr := pklIniRead( "imgNonCharMark" , 0x25AF, HIG.Ini ) 	; U+25AF White Rectangle
	HIG.MkDkBas := pklIniRead( "dkBaseCharMark" , 0x2B24, HIG.Ini ) 	; U+2B24 Black Large Circle
	HIG.MkDkCmb := pklIniRead( "dkCombCharMark" , 0x25CC, HIG.Ini ) 	; U+25CC Dotted Circle
	HIG.MkTpMod := pklIniRead( "tmTapOrModMark" , 0x25CC, HIG.Ini ) 	; U+25CC Dotted Circle
	
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
	HIG.imgType := ( onlyMakeDK ) ? "--" : "shift state" 		; If refreshing one DK, don't render state images
	HIG.destDir := HIG.ImgDirs[ "root" ]
	HIG.imgName := "state"
	Loop, Parse, shiftStates, : 								; Shift state loop - also detects dead keys
	{
		_makeImgDicThenImg( HIG, A_LoopField )
	}
	HIG.imgType := "deadkey"
	HIG.destDir := HIG.ImgDirs[ "dkey" ]
	HIG.DKNames := ( onlyMakeDK ) ? StrSplit( onlyMakeDK, "," ) : HIG.DKNames
	For key, dkName in HIG.DKNames 								; Dead key loop
	{
		if ( stateImgOnly )
			Break
		HIG.imgName := "dk_" . dkName
		Loop, Parse, shiftStates, :
		{
			_makeImgDicThenImg( HIG, A_LoopField )
		}
	}
;		( 1 ) ? pklDebug( "`n`n`n`n`n`n`n`n`n`n`n`n" . HIG.InkPath . HIG.inkOpts . HIG.inkFile, 16 )  ; eD DEBUG
;		Return 		; eD DEBUG
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
	pklSplash( HIG.Title, "Image generation done!", 2 )
	delTmpFiles := pklIniRead( "delTmpSvgFiles" , 0, HIG.Ini ) 	; 0: Don't delete. 1: Recycle. 2: Delete.
	if        ( delTmpFiles == 2 ) {
		FileRemoveDir % HIG.ImgDirs["raw"], 1 					; Recurse = 1 to remove files inside dir
	} else if ( delTmpFiles == 1 ) {
		FileRecycle % HIG.ImgDirs["raw"]
	}
;	VarSetCapacity( HIG, 0 ) 									; Clean up the big variables after use; not necessary?
}

_makeImgDicThenImg( ByRef HIG, state ) 							; Function to create a help image by a pdic.
{
	if not InStr( HIG.States, state ) 							; If this state isn't marked for rendering, skip it
		Return
	stateImg        := ( HIG.imgName == "state" ) ? true : false
	if ( SubStr( HIG.imgName, 1, 2 ) == "dk" ) { 				; "dk_<dkName>" for dead keys
		dkName      := SubStr( HIG.imgName, 4 )
		For ix, rel in [ 0, 1, 4, 5, 6, 7 ] { 					; Loop through DK releases to be marked
			dkv     := DeadKeyvalue( dkName, "s" . rel ) 		; Get the DeadKeyValue for the special entries...
			if not dkv
				Continue
			dkv     := "¤" . dkv . "¤" 							; Pad to avoid matching, e.g., 123 to 1234
			dkvp    := ( dkvs ) ? "|" . dkv : dkv 				; For if in, use CSV?; for RegEx, "|"
			dkvs    .= InStr( dkvs, dkv ) ? "" : dkvp 			; If not already there, add the DKVal entry
		}	; end For release
	}
	emptyBool       := true
	for CO, SC in HIG.PngDic
	{
		if ( stateImg ) {
			ent     := getKeyInfo( SC . state ) 				; Current layout key/state main entry
			ents    := ent . getKeyInfo( SC . state . "s" ) 	; Two-part key/state entry
			emptyBool := ( ent ) ? false : emptyBool
			if ( not ent ) {
				Continue
			} else if ( ent == "@" ) { 							; Entry is a DeadKey; was "dk"
				dkName := getKeyInfo( ents ) 					; Get the true name of the dead key
				HIG.DKNames[ ents ] := dkName 					; eD TODO: Support chained DK. How? By using a DK list instead of this?
				res := "dk_" . dkName
			} else if RegExMatch( ents, "i).*(space|spc).*" ) { 	; Note: As Spc is stored as 32, this isn't needed for normal entries.
				res := 32 										; Space may be stored as (&)spc or ={space}; if so, show it as a space
			} else if ( getKeyInfo( SC . "tom" ) ) && ( InStr( "0:1", state ) ) {
				res := "tm_" . res 								; Mark Tap-or-Mod keys, for state 0:1
			} else {
				ent := ( isInt( ent ) )  ? ent : "--" 			; Replace unprintables (see pkl_send)
				ent := ( ent >= 32 )     ? ent : "--" 			; Replace control characters (ASCII < 0x20)
				res := ent
			}
			HIG.ImgDic[ state . CO ]   := res 					; Store the result unicode value for this state/key
		} else { 												; Dead key image
			base := HIG.ImgDic[ state . CO ]
			if ( not base )
				Continue
			dkv     := DeadKeyValue( dkName, base ) 			; Get the DeadKeyValue for the current state/key...
			dkvp    := "¤" . dkv . "¤" 							; Pad to avoid matching, e.g., 123 to 1234
			if not InStr( dkvs, "¤" . -dkv . "¤" ) 				; Negative DK s# entries mean don't mark this char
				dkv := ( dkvp ~= dkvs ) ? "dc_" . dkv : dkv		; The DKV is in the base/mark list, so mark it for display
			HIG.ImgDic[ dkName . "_" . state . CO ] := dkv 		; Store the release value for this DK/state/key
			emptyBool := ( dkv ) ? false : emptyBool
		}	; end if imgName
	}	; end For CO, SC
	
	if ( HIG.imgType == "--" ) 									; Sometimes we just need the dictionary, like for single DK.
		Return
	preName := ( stateImg ) ? "" : HIG.imgName . " "
	if ( emptyBool ) {
		pklSplash( HIG.Title, "Layout " . HIG.imgType . "`n" . preName . "state" . state . "`nempty - skipping.", 2 )
		Return
	} else {
		pklSplash( HIG.Title, "Making " . HIG.imgType . " image for:`n" . preName . "state" . state . "`n", 3 )
	}
	;;  -----------------------------------------------------------------------------------------------
	;:  _makeOneHelpImg( HIG, state ) 						; Generate a vector graphics (.SVG) help image from a template
	;
	if ( stateImg ) {
		indx    := state
		imgName := HIG.imgName . state
	} else { 												; e.g., "dk_breve"
		dkName  := SubStr( HIG.imgName, 4 )
		indx    := dkName . "_" . state
		ssuf    := getLayInfo( "dkImgSuf" ) 				; DK image state suffix
		imgName := dkName . ssuf . state 					; e.g., "breve_s0"
	}
	svgFile     := HIG.destDir . "\" . imgName . ".svg" 	; Was in HIG.ImgDirs["raw"] but multi-file call can't specify different destination paths
	
	try {
		FileRead, tempImg, % HIG.OrigImg 					; eD NOTE: Use FileRead or Loop, Read, ? Nah, 160 kB isn't big.
	} catch {
		pklErrorMsg( "Reading SVG template failed." )
		Return
	}
	for CO, SC in HIG.PngDic
	{
		ch      := HIG.ImgDic[ indx . CO ]
		chrTag  := SubStr( ch, 1, 2 ) 						; Character entry, e.g., "dk_breve"
		chrVal  := SubStr( ch, 4 )
		if ( not ch ) { 									; Empty entry
			aChr := "" 										; Alpha layer char
			dChr := "" 										; DKey layer char (mark, by default bold yellow)
		} else if ( chrTag == "dk" ) { 						; Dead key (full dkName, or classic name if used)
			dkv2 := DeadKeyValue( chrVal, "s2" ) 			; Get the base char (entry 2) for the dead key
			dkv2 := ( dkv2 ) ? dkv2 : DeadKeyValue( chrVal, "s0" ) 	; Fallback is entry0
			comb := _combAcc( dkv2 ) ? " " : "" 			; Pad combining accents w/ a space for better display
			aChr := comb . _svgChar( dkv2 ) 				; Note: Padding may lead to unwanted lateral shift
			dkv3 := DeadKeyValue( chrVal, "s3" ) 			; Get the alternate display base char, if it exists
			if ( dkv3 ) && ( dkv3 != dkv2 ) { 				; If there is a second display char, show both
				comb := ""	;_combAcc( dkv3 ) ? " " : "" 	; Note: Padding works well for some but not others.
				aChr := aChr . comb . _svgChar( dkv3 )
			}
			dChr := aChr
		} else if ( chrTag == "dc" ) { 						; Dead key base char (marked in pdic)
			mark := _combAcc( chrVal ) ? HIG.MkDkCmb : HIG.MkDkBas
			aChr := _svgChar( chrVal )
			dChr := Chr( mark ) 							; Mark for DK base chars: Default U+2B24 Black Large Circle
		} else if ( chrTag == "tm" ) { 						; Tap-or-Mod key
			aChr := _svgChar( chrVal )
			dChr := Chr( HIG.MkTpMod )
		} else if ( chrTag == "--" ) {
			aChr := Chr( HIG.MkNaChr ) 						; Replace nonprintables (marked in pdic), default U+25AF Rect.
			dChr := ""
		} else { ; eD TODO:	Make an exception for letter keys, to avoid marking, e.g., greek mu on M? Or specify exceptions in Settings?!
			aChr := _svgChar( ch )
			dChr := "" 										; The dead key layer entry is empty for non-DK keys
		}
		CO := RegExReplace( CO, "_(\w\w)", "${1}" ) 		; Co _## entries are missing the underscore in the SVG template
		tstx := "</tspan></text>" 							; This always follows text elements in an SVG file
		needle := ">\K" . CO . tstx . "(.*>)" . CO . tstx 	; The RegEx to search for (ignore the start w/ \K)
		result := dChr . tstx . "${1}" . aChr . tstx 		; CO -> dChr, then next CO -> aChr
		tempImg := RegExReplace( tempImg, needle , result )
	}
;	Return 		; eD DEBUG
	try { 													; Save the changed image file in a temp folder
		FileAppend, %tempImg%, %svgFile%, UTF-8 			; Inkscape SVG is UTF-8, w/ Linux line endings
		HIG.inkFile .= " " . svgFile 						; In InkScape v1.0, the "--file" option is gone, but multiple files can be used
	} catch {
		pklErrorMsg( "Writing temporary SVG file failed." )
		Return
	}
}

_callInkscape( ByRef HIG )
{
	try { 													; Call InkScape w/ cmd line options
		RunWait % HIG.InkPath . HIG.inkOpts . HIG.inkFile 		; --without-gui is implicit for export commands.
	} catch {
		pklErrorMsg( "Running Inkscape failed." )
		Return
	}
}

_combAcc( ch ) 												; Check whether a character code is a Combining Accent
{
	comb := ( ch >= 768 && ch <= 879 ) ? true : false 		; The main Unicode range for combining marks (768-879)
	Return comb
}

_svgChar( ch ) 												; Convert character code to RegEx-able SVG text entry
{
	static escapeDic := {}
	escapeDic   :=  { "&"  : "&amp;"  , "'"  : "&apos;" , """" : "&quot;" 		; &'"<> for SVG XML compliance.
					, "<"  : "&lt;"   , ">"  : "&gt;"   , "$"  : "$$"     } 	; $ -> $$ for use with RegExReplace.
	txt := Chr( ch )
	For key, val in escapeDic
		txt := ( txt == key ) ? val : txt 					; Escape forbidden characters for XML/SVG and $ for RegEx
	Return txt
}

ChangeButtonNamesHIG: 										; For the MsgBox asking whether to make full or state images
	IfWinNotExist, Make Help Images?
		Return  											; Keep waiting for the message box if it isn't ready
	SetTimer, ChangeButtonNamesHIG, Off
	WinActivate
	ControlSetText, Button1, &Full
	ControlSetText, Button2, &State
Return
