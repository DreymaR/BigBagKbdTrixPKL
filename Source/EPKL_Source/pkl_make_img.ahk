;;  ========================================================================================================================================================
;;  EPKL Help Image Generator: Generate help images from the active layout
;;  - Calls Inkscape with a .SVG template to generate a set of .PNG help images
;;  - Edits the SVG template using a lookup dictionary of KLD(Co) key names; see the Remap file
;;  - Example – KLD(Co) letters: |_Q|_W|_F|_P|_G|_J|_L|_U|_Y||_A|_R|_S|_T|_D|_H|_N|_E|_I|_O||_Z|_X|_C|_V|_B|_K|_M|
;;  - The template can hold an area for ISO and another for ANSI, specified in the EPKL_ImgGen_Settings.ini file
;;  - Images are made for each shift state, also for any dead keys if "Full" is chosen
;;  - Images as state#.png in a time-marked subfolder of the layout folder. The DK images in a subfolder of that.
;;  - Dead keys can be marked in a separate layer of the template image (in bold yellow in the default template)
;;  - Special marks for released DK base chars and combining accents
;;  - Extend images are not generated, as these use a special layout template. Ext-tap and CoDeKey images are made.
;

makeHelpImages() {
	HIG         := {} 												; This parameter object is passed to subfunctions
	HIG.Title   :=  "EPKL Help Image Generator"
	remapFile   := getPklInfo( "RemapsFile" )   					; _eD_Remap.ini
	HIG.PngDic  := ReadKeyLayMapPDic( "Co", "SC", remapFile ) 		; PDic from the Co codes of the SVG template to SC
	layDir      := getPklInfo( "Dir_LayIni" )
	dksDir      := "\DeadkeyImg"
	imgRoot     := layDir . "\ImgGen_" . thisMinute()
	HIG.ImgDirs := { "root" : imgRoot , "raw" : imgRoot . "\RawFiles_Tmp" , "dkey" : imgRoot . dksDir }
	HIG.InkPath := pklIniRead( "InkscapePath"   ,       ,, "hig" )  	; HIG settings are in the EPKL_Settings file, under the [hig] section
	HIG.OrigImg := pklIniRead( "svgImgTemplate" ,       ,, "hig" )  	; The SVG image template file to use
	HIG.States  := pklIniRead( "HIG_imgStates", "0:1:6:7",,"hig" )  	; Which shift states, if present, to render
	onlyMakeDK  := pklIniRead( "dkOnlyMakeThis" ,       ,, "hig" )  	; Remake specified DK imgs (easier to test this var w/o using pklIniCSVs)
	If ( onlyMakeDK )
		HIG.ImgDirs[ "dkey" ] := HIG.ImgDirs[ "root" ]
	HIG.Debug   := pklIniRead( "HIG_DebugMode"  , false ,, "hig" )  	; Debug level: Don't call Inkscape if >= 2, make no files if >= 3.
	HIG.Brute   := pklIniRead( "HIG_Efficiency" , 0     ,, "hig" )  	; Move images to layout folder if >=1, overwrite current ones if >=2.
	HIG.ShowKey := pklIniRead( "HIG_DebugKeyID" , "N/A" ,, "hig" )  	; Debug: Show info on this idKey during image generation.
	HIG.MkNaChr := pklIniRead( "imgNonCharMark" , 0x25af,, "hig" )  	; U+25AF  White Rectangle
	HIG.MkDkBas := pklIniRead( "dkBaseCharMark" , 0x2b24,, "hig" )  	; U+2B24  Black Large Circle
	HIG.MkDkCmb := pklIniRead( "dkCombCharMark" , 0x25cc,, "hig" )  	; U+25CC  Dotted Circle
	HIG.MkTpMod := pklIniRead( "k_TapOrModMark" , 0x25cc,, "hig" )  	; U+25CC  Dotted Circle
	HIG.ChRepet := pklIniRead( "k_RepeatItChar" ,0x1f504,, "hig" )  	;
	HIG.MkRepet := pklIniRead( "k_RepeatItMark" ,0x1f504,, "hig" )  	; U+1F504 Anticlockwise Downwards and Upwards Open Circle Arrows
	HIG.ChComps := pklIniRead( "k_ComposerChar" , 0x24b8,, "hig" )  	; U+24B8  Circled Latin Capital Letter C
	HIG.MkComps := pklIniRead( "k_ComposerMark" , 0x25cf,, "hig" )  	; U+25CF  Black Circle (goes with the © symbol?)
;	HIG.MkOther := pklIniRead( "k_OtherKeyMark" , 0x25cf,, "hig" )  	; U+25CF  Black Circle
	HIG.MkEllip :=                                0x22ef 				; U+22EF  Midline horizontal ellipsis
	
	HIG.fontDef := pklIniRead( "imgFontDefault" , 32    ,, "hig" )  	; The default font size used in the file template is 32px
	HIG.fontSiz := pklIniCSVs( "imgFontSizes"   , 32    ,, "hig" )  	; Array of font sizes to use depending on number of glyphs
	HIG.fontSiz := ( HIG.fontSiz.Length() == 1 )    					; If there's only one size, make it also work for two character entries
					? [ HIG.fontSiz[1], HIG.fontSiz[1] ] : HIG.fontSiz
	imXY        := pklIniCSVs( "imgPos" . getLayInfo( "Ini_KbdType" ) ,     ,, "hig" )
	imWH        := pklIniCSVs( "imgSizeWH"                            ,     ,, "hig" )
	imgDPI      := pklIniRead( "imgResDPI"                            , 96  ,, "hig" )
	areaStr     := imXY[1] . ":" . imXY[2] . ":" . imXY[1]+imWH[1] . ":" . imXY[2]+imWH[2]	; --export-area=x0:y0:x1:y1
	HIG.inkOpts := " --export-type=""png""" 							; Prior to Inkscape v1.0, the export command was "--export-png=" . pngFile for each file
				.  " --export-area=" . areaStr . " --export-dpi=" . imgDPI
	HIG.inkFile := []   												; Array of the .SVG image file paths used to call Inkscape with
	HIG.maxFils := pklIniRead( "HIG_BatchSize"  , 64    ,, "hig" )  	; Batch size for Inkscape calls. It couldn't handle more than ≈80 files at once.
	
	makeMsgStr  := ( onlyMakeDK ) ? "`n`nNOTE: Only creating images for DK:`n" . onlyMakeDK . "." 	: ""
	makeMsgStr  .= ( HIG.Debug  ) ? "`n`nDEBUG Level " . HIG.Debug  								: ""
	makeMsgStr  .= ( HIG.Brute  ) ? "`n`nEFFICIENCY: IMAGES WILL BE MOVED TO THE LAYOUT FOLDER." 	: ""
	makeMsgStr  .= ( HIG.Brute == 1 ) ? "`n  (They will NOT OVERWRITE any existing images.)"    	: ""
	makeMsgStr  .= ( HIG.Brute > 1  ) ? "`nANY EXISTING IMAGES WILL BE OVERWRITTEN!"    			: ""
	SetTimer, ChangeButtonNamesHIG, 100 						; Timer routine to change the MsgBox button texts
	MsgBox, 0x133, Make Help Images?, 							; MsgBox type 0x3[Yes/No/Cancel] + 0x30[Warning] + 0x100[2nd button is default]
(
EPKL Help Image Generator
—————————————————————————————

Using Inkscape, make a help image for each Shift/AltGr state
and dead key under a subfolder of the current layout folder.

These may then be moved up to the folder for use with EPKL, 
depending on the 'HIG_Efficiency' setting in EPKL_Settings.

Do you want to make a full set of all help images
for the current layout, or only the main state images?
(Many Inkscape calls will take a long time!)%makeMsgStr%
)
	IfMsgBox, Cancel
		Return
	IfMsgBox, No 					; Make only the state images, not the full set with deadkey images
		stateImgOnly := true
	stateImgOnly := ( onlyMakeDK ) ? false : stateImgOnly 		; StateImgOnly overrides DK images, unless DK only is set
	If not FileExist( HIG.InkPath ) {
		pklErrorMsg( "You must set a path to a working copy of Inkscape in the Settings file!" )
		Return
	}
	pklSplash( HIG.Title, "Starting...", 2.5 ) 					;MsgBox, 0x41, %HIG.Title%, Starting..., 2.0
	If ( HIG.Debug < 3 ) {
		try {
			For dirTag, theDir in HIG.ImgDirs 						; Make directories
			{
				If ( dirTag == "dkey" && ( stateImgOnly || onlyMakeDK ) )
					Continue
				FileCreateDir % theDir
			}
		} catch {
			pklErrorMsg( "Couldn't create folders." )
			Return
		}
	} 	; end if Debug
	shiftStates := getLayInfo( "shiftStates" )  				; may skip some, e.g., state 2 (Ctrl), by imgStates
	HIG.imgMake := ( onlyMakeDK ) ? "--" : "shift state" 		; If refreshing one DK, don't render state images
	HIG.destDir := HIG.ImgDirs[ "root" ]
	HIG.imgType := "ShSt"
	HIG.imgName := "state"
	For ix, state in shiftStates 								; Shift state loop - also detects dead keys
		hig_makeImgDicThenImg( HIG, state )
	HIG.imgMake := "deadkey" 									; What type of image to render
	HIG.destDir := HIG.ImgDirs[ "dkey" ]
	HIG.imgType := "DKSS"
	HIG.DKNames := ( onlyMakeDK ) ? StrSplit( onlyMakeDK, "," ) : HIG.DKNames
	For ix, dkName in HIG.DKNames { 							; Dead key loop
		If ( stateImgOnly )
			Break
		HIG.imgName := dkName
		For ix, state in shiftStates
			hig_makeImgDicThenImg( HIG, state )
	}
	If ( HIG.Debug >= 2 ) 		; eD DEBUG: Don't call Inkscape
		Return
	hig_callInkscape( HIG ) 									; Call Inkscape with all the SVG files at once now
	sleepTime := 3 												; Time to wait between each file check, in s
	Loop % 6 {
		If ( A_Index >= 0 ) 	; eD WIP Check whether the last .PNG file has been made yet; how about full DK set?
			Break
		pklSplash( HIG.Title, "Waiting for images... " . A_Index * sleepTime . " s", 2.5 )
		Sleep % sleepTime * 1000
	}
	FileMove    % HIG.ImgDirs["root"] . "\*.svg", % HIG.ImgDirs["raw"]
	FileMove    % HIG.ImgDirs["dkey"] . "\*.svg", % HIG.ImgDirs["raw"]
	delTmpFiles := pklIniRead( "HIG_DelTmpSVGs" , 0,, "hig" ) 	; 0: Don't delete. 1: Recycle. 2: Delete.
	delTmpFiles := ( HIG.Brute >= 1 ) ? 2 : delTmpFiles
	If        ( delTmpFiles == 2 ) {
		FileRemoveDir   % HIG.ImgDirs["raw"], 1 				; Recurse = 1 to remove files inside dir
	} else if ( delTmpFiles == 1 ) {
		FileRecycle     % HIG.ImgDirs["raw"]
	}
	If ( HIG.Brute >= 1 ) {
		flg := ( HIG.Brute >= 2 ) ? 1 : 0 						; Flag 1: Overwrite existing files
		FileMove    % HIG.ImgDirs["root"] . "\*.png", % layDir, flg
		FileCopyDir % HIG.ImgDirs["dkey"] ,  % layDir . dksDir, flg
		FileRemoveDir   % HIG.ImgDirs["root"], 1 				; Recurse = 1 to remove files inside dir
	}
	pklInfo( "Help Image Generator: Done!", 2.0 ) 				; pklSplash() lingers too long?
	VarSetCapacity( HIG, 0 ) 									; Clean up the big variables after use; not necessary?
}

hig_makeImgDicThenImg( ByRef HIG, shSt ) {  					; Function to create a help image by a pdic.
	If not InStr( HIG.States, Format("{:x}",shSt) ) 			; If this state isn't marked for rendering, skip it (hex comparison)
		Return
	stateImg    := ( HIG.imgType == "ShSt" ) ? true : false 	; Base shift state image
	If ( HIG.imgType == "DKSS" ) { 								; Dead key shift state image
		dkName := HIG.imgName 									; DK name is used here and later
;		dkMk := {}
;		For ix, rel in [ 0, 1, 4, 5, 6, 7 ] { 					; Loop through DK releases to be marked, see the Deadkeys file
;			dkV := DeadKeyValue( dkName, "s" . rel ) 			; Get the DeadKeyValue for the special entries
;			If dkV
;				dkMk[ hig_aChr( dkV ) ] := true 				; Base char and comb. accents will be marked
;	( dkV == 180 ) ? pklDebug( "`ndkV: " . dkV . "`nrel: " . rel . "`nChr: " Chr(dkV) . "`n1Ch: " hig_aChr(dkV), 6 )  ; eD DEBUG
;		}	; end For release
	}
	HIG.Empty   := true 										; Keep track of whether a state layer is empty
	For CO, SC in HIG.PngDic
	{
		rel := ""   											; Release mapping
		tag := ""
		idKey   := shSt . CO
		If ( SC == "SC056" && getLayInfo( "Ini_KbdType" ) != "ISO" ) {
			Continue 											; Ignore the ISO key on non-ISO images
		}
															;;  ################################################################
		If ( stateImg ) {   								;;  ################  MainLayout shift state image  ################
															;;  ################################################################
			ent     :=       getKeyInfo( SC . shSt       )  	; Current layout key/state main entry
			ents    := ent . getKeyInfo( SC . shSt . "s" )  	; Two-part key/state entry
			If ( not ent ) {
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
				tag := HIG.MkTpMod  							; Mark Tap-or-Mod keys, for state 0:1
			} else if ( ent == -2 ) { 							; VKey state entry
				key := GetKeyName( SubStr( ents, 3 ) )
				fmt := ( shSt == 1 ) ? "{:U}" : "{:L}"  		; Upper/Lower case
				rel := Ord( Format( fmt , key ) ) 				; Use the glyph's ordinal number as entry
				tag := ""
			} else if ( ent == "®" ) {  						; Repeat key
				rel := Chr( HIG.ChRepet )
				tag := HIG.MkRepet
			} else if ( ent == "©" ) {  						; Compose/Context key
				dkName := getKeyInfo( "@co0" )  				; Special Compose-Deadkey (CoDeKey) DK, if used. By default dk_CoDeKey_0.
				If ( dkName )
					HIG.DKNames[ "co0" ] := dkName  			; Add it to the DK list so its help images are generated.
				rel := Chr( HIG.ChComps )
				tag := HIG.MkComps
			} else {
				rel := hig_parseEntry( HIG, ents )  			; Prepare the entry for display vis-a-vis HIG «» tags
				tag := ""
			}
															;;  ################################################################
		} else { 											;;  ################   Dead key shift state image   ################
															;;  ################################################################
			ent     := HIG.ImgDic[ idKey ]  					; Here, the entry is the base for the DK entry
			rel     := DeadKeyValue( dkName, ent )  			; Get the DeadKeyValue for the current state/key...
			If ( not ent || not rel )
				Continue
			tag     := DkMk.HasKey( hig_aChr(rel) ) 
						? "MrkdDK" : "" 						; The DKVal is in the base/mark list, so mark it for display
			rel     := hig_parseEntry( HIG, rel )   			; Prepare the entry for display vis-a-vis HIG «» tags
			idKey   := dkName . "_" . idKey
		}	; end if imgName
		HIG.Empty   := ( rel ) ? false : HIG.Empty  			; If rel is something, the layer isn't empty anymore
		HIG.ImgDic[ idKey       ]  := rel   					; Store the release value for this (DK/)state/key
		HIG.ImgDic[ idKey . "¤" ]  := tag   					; Store the tag            --"--
	( HIG.Debug && idKey == HIG.ShowKey ) ? pklDebug( "`nidKey: " . idKey . "`nent: " . ent . "`nents: " . ents . "`nrel: " . rel . "`ntag: " . tag . "`nChr: " Chr(rel), 6 )  ; eD DEBUG
	}	; end For CO, SC
	
	If ( HIG.imgMake == "--" )  								; Sometimes we just need the dictionary, like for single DK.
		Return
	;;  ====================================================================================================================================================
	;:  _makeOneSVG( ByRef HIG, shSt ) 							; Generate a vector graphics (.SVG) help image from a template
	;
	preName := ( stateImg ) ? "" : HIG.imgName . " "
	If ( HIG.Empty ) {
		pklSplash( HIG.Title, "Layout " . HIG.imgMake . "`n" . preName . "state" . shSt . "`nempty - skipping.", 1.5 )
		Return
	} else {
		pklSplash( HIG.Title, "Making " . HIG.imgMake . " image for:`n`n" . preName . "state" . shSt . "`n", 2.0 )
	}
	
	If ( stateImg ) {
		indx    := shSt
		imgName := HIG.imgName . shSt
	} else { 													; e.g., "dk_breve"
		dkName  := HIG.imgName
		indx    := dkName . "_" . shSt
		imgName := dkName . getLayInfo( "dkImgSuf" ) . shSt 	; DK image state suffix, e.g., "breve_s0"
	}
	svgFile     := HIG.destDir . "\" . imgName . ".svg" 		; Was in HIG.ImgDirs["raw"] but multi-file call can't specify different destination paths
	
	If not tempImg := pklFileRead( HIG.OrigImg, "SVG template" )
		Return
	;;  Constants used in image search-n-replace below are defined outside the `For CO,SC` loop for speed
;	imgLen  := StrLen( tempImg ) 							; Should be around 159,509 characters for my SVG template
	tsTx    := "</tspan></text>" 							; This always follows text elements in our SVG file
	tsTxLn  := StrLen( tsTx )
	fsTx    := "font-size:" 								; This always preceeds the font size specification
	fsTxLn  := StrLen( fsTx )
	fsDf    := HIG.fontDef  								; The template's font-size for replaceable entries
	fsDfLn  := StrLen( fsDf )
	fsRp    := fsTx . fsDf
	For CO, SC in HIG.PngDic {  								; Run through each CO and corresponding SC code 	; { "_Q":"SC010", "_W":"SC011" } { 
		size    := false    									; Don't resize all entries (such as spc-padded ones)
		idKey   := indx . CO
		chrVal  := HIG.ImgDic[ idKey       ]
		chrTag  := HIG.ImgDic[ idKey . "¤" ] 					; Tags such as "DK_Key" for a Dead Key
		If ( not chrVal ) { 									; Empty entry
			aChr := "" 											; Alpha layer char
			dChr := "" 											; DKey layer char (mark, by default bold yellow)
		} else if ( chrTag == "DK_Key" ) {  					; Dead key (full dk Name, or classic name if used)
			dkD1 := DeadKeyValue( chrVal, "disp0" ) 			; There may be a display tag entry
			If ( dkD1 ) {
				aChr := SubStr( dkD1, 2, -1 )   				; A display entry will be enclosed in, e.g., «».
			} else {
				dkD1 := DeadKeyValue( chrVal, "disp1" ) 			; Get the display base char for the dead key
				dkD1 := ( dkD1 ) ? dkD1 : DeadKeyValue( chrVal, "base1" ) 	; Fallback is the usual base char
				comb := hig_combAcc( dkD1 ) ? " " : "" 				; Pad combining accents w/ a space for better display
				aChr := comb . hig_makeChr( dkD1 ) 					; Note: Padding may lead to unwanted lateral shift
				dkD2 := DeadKeyValue( chrVal, "disp2" ) 			; Get the alternate display base char, if it exists
				If ( dkD2 ) && ( dkD2 != dkD1 ) { 					; If there is a second display char, show both
					comb := hig_combAcc( dkD2 ) ? " " : ""  		; Note: Padding works well for some but not others.
					aChr := aChr . comb . hig_makeChr( dkD2 )
				}
			} 	; end if display tag
			dChr := aChr
		} else if ( chrTag == "MrkdDK" ) {  					; Marked dead key base/accent char (marked in pdic)
			mark := hig_combAcc( chrVal ) ? HIG.MkDkCmb : HIG.MkDkBas
			aChr := hig_makeChr( chrVal )
			dChr := Chr( mark ) 								; Mark for DK base chars: Default U+2B24 Black Large Circle
		} else if ( InStr( chrTag, "0x" ) == 1 ) {  			; Direct Unicode point tag
			aChr := hig_makeChr( chrVal )
			dChr := hig_makeChr( chrTag )
;		} else if ( chrTag == "--" ) {
;			aChr := Chr( HIG.MkNaChr )   						; Replace nonprintables (marked in pdic) 	; NOTE: I don't do this anymore
;			dChr := ""
		} else { ; eD TODO: Make an exception for letter keys, to avoid marking, e.g., greek mu on M? Or specify exceptions in Settings?!
			aChr := hig_makeChr( chrVal )
			dChr := ""  										; The dead key layer entry is empty for non-DK keys
			size := true    									; Allow resizing generic entries by number of characters
		}
		( HIG.Debug && idKey == HIG.ShowKey ) ? pklDebug( "`nImage: " . ImgName 
			. "`nidKey: " . idKey . "`nVal: " . chrVal . "`nTag: " . chrTag . "`naChr: " . aChr . "`ndChr: " . dChr, 6 ) 	; eD DEBUG
		CO      := RegExReplace( CO, "_(\w\w)", "${1}" ) 		; Co _## entries are missing the underscore in the SVG template
		fsSz    := ( size ) ? HIG.fontSiz[ StrLen( aChr ) ] 	; If applicable...
							: fsDf  							; ...tabulate font size based on number of characters in the entry
		For ix, chr in [ dChr, aChr ] {
			chr     := hig_svgText( chr )   					; Escape any SVG forbidden characters in the entry
			psEi    := InStr( tempImg, ">" . CO . tsTx ) +1 	; Inner position of pattern end
;			psEo    := psEi + StrLen( CO )
;			psF     := psEi - imgLen    						; Negative value, specifies backwards search from end of the string 	; eD WIP: This seems to not quite work?!
			psBo    := InStr( SubStr( tempImg, 1, psEi ), fsRp,, -1 ) + fsTxLn  	; Outer position of pattern beginning
			psBi    := psBo + fsDfLn
;			iniStr  := SubStr( tempImg, 1, psBo - 1 )   		; The file-string up to the font-size
			midStr  := SubStr( tempImg, psBi, psEi - psBi ) 	; The file-string between font-size and CO entry
;			endStr  := SubStr( tempImg, psEo )  				; The file-string after the CO entry
			tempImg := StrReplace( tempImg, fsDf . midStr . CO
										  , fsSz . midStr . chr,, 1 )   	; It all comes together again.
		}	; end For chr
;;		tmp := ( aChr ) ? tmp . "`n" . CO . " - " . fsSz . ": '" . aChr . "'" : tmp
	}	; end For CO,SC in PngDic
;;		( 1 ) ? pklDebug( "" . tmp, 30 )  ; eD DEBUG
	If ( HIG.Debug >= 3 )   	; eD DEBUG: Don't make files
		Return
	If not pklFileWrite( tempImg, svgFile   					; Save the changed image file in a temp folder
						, "temporary SVG file" ) 				; Note: Inkscape SVG is UTF-8, w/ Linux line endings
		Return
	HIG.inkFile.Push( svgFile ) 								; In Inkscape v1.0, the "--file" option is gone, but multiple files can be used
}

hig_aChr( ent ) {   											; Get a single-character entry in various formats (number, hex, prefix syntax)
	psp     := hig_ParsePrefix( ent )   						; Check for a tag or prefix-entry syntax, without sending
	If ( not ent + 0 )  										; Non-numeric entry
		ent := ( StrLen(ent) == 1 ) ? Ord(ent) : "" 			; Convert single-char literals to their ordinal value
	Return  ent 												; Longer entries would be converted to ""
}

hig_ParsePrefix( ByRef ent ) {  					  			; Check for tag or prefix-entry syntax, without sending
	psp     := pkl_ParseSend( ent, "HIG" )  					; Will return a prefix only if one is recognized
	ntry    := SubStr( ent, 2 ) 								; This function may change the value of ent
	If        hig_tag( ent ) {  								; Specified `«#»` HIG tag for display
		psp := "Ħ"
		ent := hig_tag( ent )
	} else if InStr( "~†", psp ) {  							; ~ : Hex Unicode point U+####
		psp := ""
		ent := "0x" . ntry  									; No need for Format( "{:i}", "0x" . ntry ) here
	} else if InStr( "%→$§", psp ) { 							; Literals can have these prefixes, or be unprefixed
		psp := ""
		ent := ntry
	}
	ent     := isInt( ent ) ? ent + 0 : ent  					; Convert hex to decimal for numeric entries with this trick
	Return psp
}

hig_parseEntry( ByRef HIG, ent ) {  							; Parse a state or DK mapping for help image display
	naChr   := Chr( HIG.MkNaChr )   							; Not-a-char mark, default U+25AF Rect.
	psp     := hig_ParsePrefix( ent )   						; Check for a tag or prefix-entry syntax, without sending
	If ( psp && psp != "Ħ" ) {  ;InStr( "*α=β@Ð&¶", psp ) { 	; AHK string(*α), Blind send(=β), DK(@Ð), PwrString(&¶)
		ent := "·" . psp . "·"  								; Show untagged prefix-entries as the prefix between dots
;	} 	; end if psp 		; eD WIP: Move this to the write svg section? 1) Use hig_aChr() 2) Mark prefix 3) Long literals (w/ or w/o %→ prefix) ".."
	} else if ( not isInt(ent) ) {  							; eD WIP: Must not mark "dc_" keys here! Add if else to the above?
		maxLen := HIG.fontSiz.Length()  						; The number of specified font sizes; ellipse out anything longer
		ent := ( StrLen(ent) > maxLen ) ? HIG.MkEllip : ent 	; Entry is a string, like {Home}+{End}. Marked as a (midline) ellipse.
																; eD WIP: Do this in the image generating fn instead?!
	}
	ent     := isInt( ent ) && ( ent < 32 ) ? naChr : ent   	; Replace control characters (ASCII < 0x20)
	Return ent
}

hig_callInkscape( ByRef HIG ) {
	numFils := HIG.inkFile.Length()
	batch   := HIG.maxFils  									; Max batch size for Inkscape calls
	turns   := 1 + ( (numFils-1) // batch ) 					; Using floor division, loop if numFils > maxFils
	Loop % turns {
		turn    := A_Index
		minInx  := batch * (turn-1) + 1
		maxInx  := batch *  turn
		maxInx  := ( maxInx > numFils ) ? numFils : maxInx
		inkFils := ""
		Loop % 1 + maxInx - minInx {
			inkFils .= " " . HIG.inkFile[ minInx + A_Index - 1 ] 	; Precede and join by spaces 	;	inkFils := " " . joinArr( HIG.inkFile, " " )
		}
		pklSplash( HIG.Title, "Calling Inkscape with files " . minInx . "-" . maxInx . " of " . numFils . " [batch " . turn . "/" . turns . "] ...", 8 )
		try {   													; Call Inkscape w/ cmd line options
			RunWait % HIG.InkPath . HIG.inkOpts . inkFils   		; --without-gui is implicit for export commands, and since v1.1(?) deprecated.
;			pklInfo( HIG.InkPath . HIG.inkOpts . inkFils, 30 )  	; eD DEBUG
		} catch {
			pklErrorMsg( "Running Inkscape failed." )
			Return
		}
	}
}

hig_combAcc( ch ) { 											; Check whether a character code is a Combining Accent
	comb := ( ch >= 768 && ch <= 879 ) ? true : false 			; The main Unicode range for combining marks (768-879)
	Return comb
}

hig_makeChr( ch ) { 											; Convert character code to a char, if applicable
	ch := isInt( ch ) ? Chr( ch ) : ch  						; The isInt() fn allows hex numbers too
	Return ch   	;hig_svgEsc( ch )
}

hig_svgText( str ) { 											; Convert character string to SVG text
	txt := ""
	Loop, Parse, str
		txt .= hig_svgEsc( A_LoopField )
	Return txt
}

hig_svgEsc( ch ) {  											; Escape one character to RegEx-able SVG format
	static escapeDic := {}
	escapeDic   :=  { "&"  : "&amp;"  , "'"  : "&apos;" , """" : "&quot;"   	; &'"<> for SVG XML compliance.
					, "<"  : "&lt;"   , ">"  : "&gt;"   } 	;, "$"  : "$$"     } 	; $ -> $$ for use with RegExReplace only.
	For key, val in escapeDic
		ch  := ( ch == key ) ? val : ch     					; Escape forbidden characters for XML/SVG and $ for RegEx
	Return ch
}

hig_tag( ent, retur := "tag" ) {    							; Detect and sort an entry HIG tag of the form «#»[  ]‹entry› 	; eD WIP
	tag := false
	pre := SubStr( ent, 1, 1 )
	If ( pre == "«" ) { 										; Any mapping may start with a HIG display tag for help images
		pos := InStr( ent, "»",, 3 )    						; This tag is formatted `«#»` w/ # any character(s) except `»`
		If ( pos ) {
			tag :=       SubStr( ent, 2, pos - 2 )
			ent := Trim( SubStr( ent,    pos + 1 ) )    		; Allow whitespace padding after the HIG tag (but it can't be used in layout entries!)
		} else {
			ent := "%" . ent    								; If there is no properly formed tag, interpret entry as a string [not necessary?]
		}
;	( tag ) ? pklDebug( "«» tag found!`ntag: '" . tag . "'`nent: '" . ent . "'", 1.5 )  ; eD DEBUG
	} 	; end if HIG tag
	Return ( retur == "tag" ) ? tag : ent
}

hig_untag( ent ) {  											; Convenient call to hig_tag to return the entry
	Return hig_tag( ent, "entry" )
}

ChangeButtonNamesHIG: 											; For the MsgBox asking whether to make full or state images
	IfWinNotExist, Make Help Images?
		Return  												; Keep waiting for the message box if it isn't ready
	SetTimer, ChangeButtonNamesHIG, Off
	WinActivate
	ControlSetText, Button1, &Full
	ControlSetText, Button2, &Main
Return
