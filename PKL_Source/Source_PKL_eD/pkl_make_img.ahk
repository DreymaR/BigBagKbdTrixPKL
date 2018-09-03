;-------------------------------------------------------------------------------------
;
; PKL Help Image Generator: Generate help images from the active layout
;     Calls InkScape with a .SVG template to generate a set of .PNG help images
;     Edits the SVG template using a lookup dictionary of KLD(CO) key names; see the Remap file
;     Example – KLD(CO) letters: |_Q|_W|_F|_P|_G|_J|_L|_U|_Y||_A|_R|_S|_T|_D|_H|_N|_E|_I|_O||_Z|_X|_C|_V|_B|_K|_M|
;     The template can hold an area for ISO and another for ANSI, specified in the PKL_ImgGen_Settings.ini file
;     Images are made for each shift state, also for any dead keys if "Full" is chosen
;     Images as state#.png in a time-marked subfolder of the layout folder. The DK images in a subfolder of that.
;     Dead keys can be marked in a separate layer of the template image (in bold yellow in the default template)
;     Special marks for released DK base chars and combining accents
;     An Extend image is not generated, as these require a special layout
;

makeHelpImages()
{
	HIG_Name            := "PKL Help Image Generator"
	global HIG_PngDic   := {}	; A little dirty, but saves passing it to every subfunction (declare only as needed)
	global HIG_ImgDic   := {}	; --"--
	global HIG_ImgDirs  := {}	; --"--
	global HIG_DKNames  := {}	; --"--
	
	remapFile   := "PKL_eD\_eD_Remap.ini"
	HIG_PngDic  := ReadKeyLayMapPDic( "CO", "SC", remapFile )	; PDic from the CO codes of the SVG template to SC
	FormatTime, theNow,, yyyy-MM-dd_HHmm						; Use A_Now (local time) for a folder time stamp
	imgRoot     := getLayInfo( "layDir" ) . "\ImgGen_" . theNow
	HIG_ImgDirs := { "root" : imgRoot , "raw" : imgRoot . "\RawFiles_Tmp" , "dkey" : imgRoot . "\DeadkeyImg" }
	
	SetTimer, ChangeButtonNamesHIG, 100
	MsgBox, 0x133, Make Help Images?, 
(
Do you want to make a full set of help images
for the current layout, or only state images?
(Many Inkscape calls will take a long time!)
)
	IfMsgBox, Cancel				; MsgBox type 0x133 (3+48+256) is Yes/No/Cancel, Warning, 2nd button is default
		Return
	IfMsgBox, No					; Make only the state images, not the full set with deadkey images
		stateImgOnly := true
	pklSplash( HIG_Name, "Starting...", 4 )					;MsgBox, 0x41, %HIG_Name%, Starting..., 1.0
	try {
		for dirTag, theDir in HIG_ImgDirs
		{
			If ( dirTag == "dkey" && stateImgOnly )
				Continue
			FileCreateDir % theDir
		}
	} catch {
		pklErrorMsg( "Couldn't create folders." )
		Return
	}
	shiftStates := "0:1:6:7:8:9"							;getLayInfo( "shiftStates" ) - but may skip, e.g., state 2 (Ctrl)
	Loop, Parse, shiftStates, :								; Shift state loop - these are colon separated
	{
		state := A_LoopField
		empty := _makeHelpImgDic( "state", state )
		if ( empty ) {
			pklSplash( HIG_Name, "Layout state`n" . state . "`nempty - skipping.", 4 )	;MsgBox, 0, %HIG_Name%, % <txt>, 0.8
		} else {
			pklSplash( HIG_Name, "Making image for:`nstate" . state . "`n" )			
			_makeOneHelpImg( "state", state, "root" )
		}
	}
;	HIG_DKNames := Array( "ringabov-lig" )		; DEBUG, often "acute-sup" "dotbelow" "dblacute-sci"
	for key, dkName in HIG_DKNames							; Dead key image loop
	{
		if ( stateImgOnly )
			Break
		Loop, Parse, shiftStates, :
		{
			state := A_LoopField
			empty := _makeHelpImgDic( "dk_" . dkName, state )
			if ( empty ) {
				pklSplash( HIG_Name, "Deadkey`n" . dkName . " state" . state . "`nempty - skipping.", 4 )
			} else {
				pklSplash( HIG_Name, "Making deadkey image for:`n" . dkName . " state" . state . "`n" )
				_makeOneHelpImg( "dk_" . dkName, state, "dkey" )
			}
		}
	}
	pklSplash( HIG_Name, "Image generation done!", 2 )
	
	VarSetCapacity( HIG_PngDic , 0 )						; Clean up the globals after use
	VarSetCapacity( HIG_ImgDic , 0 )						; --"--
	VarSetCapacity( HIG_ImgDirs, 0 )						; --"--
	VarSetCapacity( HIG_DKNames, 0 )						; --"--
}

_makeHelpImgDic( imgName, state )						; Function to create a help image pdic.
{
	global HIG_PngDic
	global HIG_ImgDic
	global HIG_DKNames
	
	if ( SubStr( imgName, 1, 2 ) == "dk" ) {			; "dk_<dkName>" for dead keys
		dkName      := SubStr( imgName, 4 )
		For i, rel in [ 0, 1, 4, 5, 6, 7 ]				; Loop through DK releases to be marked
		{
			dkv     := DeadKeyvalue( dkName, "s" . rel )
			if not dkv
				Continue
			dkv 	:= "_" . dkv . "_"					; Pad to avoid matching, e.g., 123 to 1234
			dkvp    := ( dkvs ) ? "|" . dkv : dkv		; For if in, CSV; for RegEx, "|"
			dkvs    .= ( InStr( dkvs, dkv ) ) ? "" : dkvp	; If not already there, add the DKVal entry
		}
	}
	emptyBool := true
	for CO, SC in HIG_PngDic
	{
		if ( imgName == "state" ) {
			cha     := getKeyInfo( SC . state )			; Current layout key/state main entry
			chas    := cha . getKeyInfo( SC . state . "s" )	; Two-part key/state entry
			emptyBool := ( cha ) ? false : emptyBool
			if ( not cha ) {
				Continue
			} else if ( cha == "dk" ) {
				dkName := getKeyInfo( chas )			; Get the true name of the dead key
				HIG_DKNames[ chas ] := dkName			; eD TODO: Support chained DK. How?
				res := "dk_" . dkName
			} else if ( chas == "={space}" ) {
				res := 32								; Space is stored as ={space}; show it as a space
			} else {
				cha := ( isInt( cha ) )  ? cha : -1		; Replace unprintables (see pkl_send)
				cha := ( cha >= 32 )     ? cha : -1		; Replace control characters (ASCII < 0x20)
				res := cha
			}
			HIG_ImgDic[ state . CO ]   := res			; Store the result unicode value for this state/key
		} else {										; Dead key image
			base := HIG_ImgDic[ state . CO ]
			if ( not base )
				Continue
			dkv     := DeadKeyValue( dkName, base )		; Get the DKV for the current state/key
			dkvp    := "_" . dkv . "_"					; Pad to avoid matching, e.g., 123 to 1234
			if ( not InStr( dkvs, "_" . -dkv . "_" ) )	; Negative DK s# entries mean don't mark this char
				dkv := ( dkvp ~= dkvs ) ? "dc_" . dkv : dkv	; The DKV is in the base/mark list, so mark it for display
			HIG_ImgDic[ dkName . "_" . state . CO ] := dkv	; Store the release value for this DK/state/key
;	if ( CO == "_1" ) {		; DEBUG
;		debugStr := imgName . "`nTag/Val: " . chrTag . " / " . chrVal
;		debugStr := dkName . " state" . state . "`ndkvs: " . dkvs . "`ndkv: " . dkv
;		pklSplash( "Debug", debugStr, 0.2 )
;		MsgBox % debugStr
;	}		; end DEBUG
			emptyBool := ( dkv ) ? false : emptyBool
		}	; end if imgName
	}	; end for CO, SC
	Return emptyBool
}

_makeOneHelpImg( imgName, state, destDir )				; Generate an actual help image from a pdic using an Inkscape call
{
	global HIG_PngDic
	global HIG_ImgDic
	global HIG_ImgDirs
	
	static iniFileHIG
	static origImgFile
	static inkscapeStr
	static naCharMark
	static dkBaseMark
	static dkCombMark
	static initialized  := false
	if ( not initialized ) {							; eD TOFIX: Is this still running several times...?
		iniFileHIG  := pklIniRead( "imgGenIniFile"  ,       ,,     "eD" )
		origImgFile := pklIniRead( "origImgFile"    ,       , iniFileHIG )
		inkscapeStr := pklIniRead( "InkscapePath"   ,       , iniFileHIG )
		naCharMark  := pklIniRead( "imgNonCharMark" , 0x25AF, iniFileHIG )	; U+25AF White Rectangle
		dkBaseMark  := pklIniRead( "dkBaseCharMark" , 0x2B24, iniFileHIG )	; U+2B24 Black Large Circle
		dkCombMark  := pklIniRead( "dkCombCharMark" , 0x25CC, iniFileHIG )	; U+25CC Dotted Circle
		if not FileExist( inkscapeStr ) {
			pklErrorMsg( "You must set a path to a working copy of Inkscape in " . iniFileHIG . "!" )
			Return
		}
		initialized := true
	}
	if ( imgName == "state" ) {
		indx    := state
		imgName := imgName . state
	} else {											; e.g., "dk_breve"
		dkName  := SubStr( imgName, 4 )
		indx    := dkName . "_" . state
		ssuf    := getLayInfo( "dkImgSuf" )				; DK image state suffix
		imgName := dkName . ssuf . state				; e.g., "breve_s0"
	}
	tempFile    := HIG_ImgDirs[ "raw" ] . "\" . imgName . ".svg"
	destFile    := HIG_ImgDirs[destDir] . "\" . imgName . ".png"
	imXY        := pklIniPair( "imgPos" . getLayInfo( "Ini_KbdType" ) ,, iniFileHIG )
	imWH        := pklIniPair( "imgSizeWH"                            ,, iniFileHIG )
	imgDPI      := pklIniRead( "imgResDPI", 96                         , iniFileHIG )
	areaStr     := imXY[1] . ":" . imXY[2] . ":" . imXY[1]+imWH[1] . ":" . imXY[2]+imWH[2]	; --export-area=x0:y0:x1:y1
	
	try {
		FileRead, templateFile, %origImgFile%			; eD: Use FileRead or Loop, Read, ? Nah, 160 kB isn't so big.
	} catch {
		pklErrorMsg( "Reading SVG template failed." )
		Return
	}
	for CO, SC in HIG_PngDic
	{
		ch      := HIG_ImgDic[ indx . CO ]
		chrTag  := SubStr( ch, 1, 2 )					; Character entry, e.g., "dk_breve"
		chrVal  := SubStr( ch, 4 )
		if ( not ch ) {									; Empty entry
			aChr := ;
			dChr := ;
		} else if ( chrTag == "dk" ) {					; Dead key (full dkName, or classic name if used)
			dkv2 := DeadKeyValue( chrVal, "s2" )		; Get the base char (entry 2) for the dead key
			dkv2 := ( dkv2 ) ? dkv2 : DeadKeyValue( chrVal, "s0" )	; Fallback is entry0
			comb := _combAcc( dkv2 ) ? " " : ""			; Pad combining accents w/ a space for better display
			aChr := comb . _svgChar( dkv2 )				; Note: Padding may lead to unwanted lateral shift
			dkv3 := DeadKeyValue( chrVal, "s3" )		; Get the alternate display base char, if it exists
			if ( dkv3 ) && ( dkv3 != dkv2 ) {			; If there is a second display char, show both
				comb := ;_combAcc( dkv3 ) ? " " : ""	; Note: Padding works well for some but not others...?
				aChr := aChr . comb . _svgChar( dkv3 )
			}
			dChr := aChr
		} else if ( chrTag == "dc" ) {					; Dead key base char (marked in pdic)
			mark := _combAcc( chrVal ) ? dkCombMark : dkBaseMark
			aChr := _svgChar( chrVal )
			dChr := chr( mark )							; Mark for DK base chars: Default U+2B24 Black Large Circle
; eD TODO:	Make an exception for letter keys, to avoid marking, e.g., greek mu on M? Or specify exceptions in Settings?!
		} else if ( ch == -1 ) {
			aChr := chr( naCharMark )					; Replace nonprintables (marked in pdic), default U+25AF Rect.
			dChr := ;
		} else {
			aChr := _svgChar( ch )
			dChr := ;									; The dead key layer entry is empty for non-DK keys
		}
		tstx := "</tspan></text>"							; This always follows text elements in an SVG file
		needle := ">\K" . CO . tstx . "(.*>)" . CO . tstx	; The RegEx to search for (ignore the start w/ \K)
		result := dChr . tstx . "${1}" . aChr . tstx		; CO -> dChr, then next CO -> aChr
		templateFile := RegExReplace( templateFile, needle , result )
	}
;	Return	; DEBUG
	try {												; Save the changed image file in a temp folder
		FileAppend, %templateFile%, %tempFile%, UTF-8	; Inkscape SVG is UTF-8, w/ Linux line endings
	} catch {
		pklErrorMsg( "Writing temporary SVG file failed." )
		Return
	}
	inkOptStr  := " --file=" . tempFile . " --export-png=" . destFile 
				. " --export-area=" . areaStr . " --export-dpi=" . imgDPI
	try {												; Call InkScape w/ cmd line options
		RunWait % inkscapeStr . inkOptStr				; eD TODO: Can I use --shell to avoid many Inkscape restarts? How?
		;Run % inkscapeStr . " --shell" ???				; " --without-gui" does nothing on Windows I think.
	} catch {
		pklErrorMsg( "Running Inkscape failed." )
		Return
	}
}

_combAcc( ch )											; Check whether a character code is a Combining Accent
{
	comb := ( ch >= 768 && ch <= 879 ) ? true : false	; The Unicode range for combining marks
	Return comb
}

_svgChar( ch )											; Convert character code to RegEx-able SVG text entry
{
	static escapeDic := {}
	escapeDic   :=  { "&"  : "&amp;"  , "'"  : "&apos;" , """" : "&quot;"		; &'"<> for SVG XML compliance.
					, "<"  : "&lt;"   , ">"  : "&gt;"   , "$"  : "$$"     }		; $ -> $$ for use with RegExReplace.
	txt := chr( ch )
	for key, val in escapeDic {
		txt := ( txt == key ) ? val : txt				; Escape forbidden characters for XML/SVG and $ for RegEx
	}
	Return txt
}

ChangeButtonNamesHIG:									; For the MsgBox asking whether to make full or state images
IfWinNotExist, Make Help Images?
	Return		; Keep waiting for the MsgBox
SetTimer, ChangeButtonNamesHIG, Off
WinActivate
ControlSetText, Button1, &Full
ControlSetText, Button2, &State
Return
