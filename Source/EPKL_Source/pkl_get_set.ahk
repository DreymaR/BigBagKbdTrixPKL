;;  ================================================================================================================================================
;;  EPKL Get/Set ###Info module
;;  - Read and set global variables without having to declare them
;;  - Static associative dictionaries are used instead of most globals
;;  - Organized in three main types: (E)PKL, Layout and Key info
;;  - Some other get/set fns below: Locale, Hotkeys and Composer
;;  
;;  LayoutInfo entries:
;;  -------------------
;;  ActiveLay     := "" ; The active layout
;;  dir           := "" ; The directory of the active layout (eD: Obsolete)
;;  LayHasAltGr   := 0  ; Should Right Alt work as AltGr in the layout?
;;  ExtendKey     := [] ; Extend modifier(s) for navigation, editing, etc.
;;  
;;  NextLayout    := "" ; If you set multiple layouts, this is the next one.
;;                      ; see the "rerunNextLayout:" label!
;;  NumOfLayouts  := 0  ; Array size
;;  LayoutsXcode        ; layout code
;;  LayoutsXname        ; layout name
;;  Ico_On_File         ; Icon for On  (file)
;;  Ico_On_Num_         ; --"--        (# in file)
;;  Ico_OffFile         ; Icon for Off (file)
;;  Ico_OffNum_         ; --"--        (# in file)
;;  ...and more...
;

setKeyInfo( key, val )
{
	Return getKeyInfo( key, val, 1 )
}

setLayInfo( key, val )
{
	Return getLayInfo( key, val, 1 )
}

setPklInfo( key, val )
{
	Return getPklInfo( key, val, 1 )
}

getKeyInfo( key, val := "", set := 0 )
{
	static pdic     := {}
	If ( set == 1 )
		pdic[key]   := val
	Return pdic[key]
}

getLayInfo( key, val := "", set := 0 )
{
	static pdic     := {}
	If ( set == 1 )
		pdic[key]   := val
	Return pdic[key]
}

getPklInfo( key, val := "", set := 0 )
{
	static pdic     := {}
	If ( set == 1 )
		pdic[key]   := val
	Return pdic[key]
}

;;  ================================================================================================================================================
;;  EPKL locale module
;;      Functions to set up locale strings
;;      Used by initPklIni() in pkl_init.ahk
;

pkl_locale_load( lang )
{
	static initialized  := false 	; Defaults are read only once, as this function is run on layout change too 	; eD WIP: Does that really work, or matter?
	
	If ( not initialized ) {    								; Read/set default locale string list
		For ix, sectName in [ "DefaultLocaleStr", "DefaultLocaleTxt" ] { 	; Read defaults from the EPKL_Tables file
			For ix, row in pklIniSect( getPklInfo( "File_PklDic" ), sectName ) { 	; Read default locale strings (key/value)
				pklIniKeyVal( row, key, val, 1 ) 				; Extraction with \n escape replacement
				setPklInfo( key, val )
			}
		}   ; <-- For
		initialized := true
	}
	
	file := lang . ".ini"
	file := ( bool(pklIniRead("compactMode")) ) ? file : "Files\Languages\" . file
	If not FileExist( file ) 									; If the language file isn't found, we'll just use the defaults
		Return
	For ix, row in pklIniSect( file, "pkl" ) { 					; Read the main locale strings frome the PKL section
		pklIniKeyVal( row, key, val, 1 ) 						; A more compact way than before (but still in a loop)
		If ( val != "" ) { 						; LocStr_ 00-22,LaysSetts,AHKeyHist,MakeImage,ImportKLC,ZoomImage,MoveImage,RefreshMe...
			key := ( key <= 9 ) 
					? SubStr("00" . key, -1) : key 				; If key is #, zero pad it to 0# instead
			setPklInfo( "LocStr_" . key , val ) 				; pklLocaleStrings( key, val, 1 )
		}
	}   ; <-- For
	
	For ix, row in pklIniSect( file, "detectDeadKeys" ) { 		; Read the locale strings for DK detection  	; eD WIP: Phase this out? Use getWinLayDKs().
		pklIniKeyVal( row, key, val, 1 )
		setPklInfo( "DetecDK_" . key, val ) 					; detectDeadKeys_SetLocaleTxt(
	}   ; <-- For
	
	For ix, row in pklIniSect( file, "keyNames" ) { 			; Read the list of keys and mouse buttons
		pklIniKeyVal( row, key, val, 0 ) 						; Read without character escapes
		_setHotkeyText( key, val )
	}   ; <-- For
}

_setHotkeyText( hk, localehk )
{
	_getHotkeyText( hk, localehk, 1 )
}

_getHotkeyText( hk, localehk := "", set := 0 )
{
	static localizedHotkeys := ""
	
	If ( set == 1 ) {
		setKeyInfo( "HKtxt_" . hk, localehk )
		localizedHotkeys    .= " " . hk
	} else {
		If ( hk == "all" )
			Return localizedHotkeys
		Return getKeyInfo( "HKtxt_" . hk )
	}
}

getReadableHotkeyString( str ) 									; Replace hard-to-read, hard-to-print parts of hotkey names
{
	strDic := {              "<^>!" : "AltGr"
		,  "<+" : "LShift"  ,  "<^" : "LCtrl"  ,  "<!" : "LAlt"  ,  "<#" : "LWin"
		,  ">+" : "RShift"  ,  ">^" : "RCtrl"  ,  ">!" : "RAlt"  ,  ">#" : "RWin" }
	For key, val in strDic
		str := StrReplace( str, key, val . " & " )
	strDic := { ""
		.  "+"    :  "Shift & " ,  "^"    :  "Ctrl & " ,  "!"    :  "Alt & " ,  "#"    :  "Win & "
		, "SC029" : "Tilde"     ,  "*"    : ""         ,  "$"    : ""        ,  "~"    : "" }
	For key, val in strDic
		str := StrReplace( str, key, val )

	str := RegExReplace( str, "(\w+)", "#[$1]" )
	hotkeys := _getHotkeyText( "all" )
	Loop, Parse, hotkeys, %A_Space%
	{
;		lhk := _getHotkeyText( A_LoopField )
		str := StrReplace( str, "#[" . A_LoopField . "]", _getHotkeyText( A_LoopField ) )	;StringReplace, str, str, #[%A_LoopField%], %lhk%, 1
	}
	str := RegExReplace( str, "#\[(\w+)\]", "$1" )
	strDic := {                      "Delete" : "Del"   ,    "Insert" : "Ins"   ,   "Control" : "Ctrl"
		,    "Return" : "Enter" ,    "Escape" : "Esc"   , "BackSpace" : "Back"  , "Backspace" : "Back" }
	For key, val in strDic 				; The shorter key names were moved down so they'll work on the Languages file.
		str := StrReplace( str, key, val )
	Return str
}

;;  ================================================================================================================================================
;;  EPKL Composer module
;;      Set up compose string tables from a file
;;      The tables are used by pkl_Composer() in pkl_send.ahk
;;      Called in pkl_init.ahk
;

init_Composer( compKeys ) { 									; Initialize EPKL Compose tables for all detected ©-keys
	static initialized  := false
	
	If ( not initialized ) {
		cmpFile := getPklInfo( "CmposrFile" )
		cmpStck := getPklInfo( "CmposrStck" )
		CDKs    := pklIniCSVs( "CoDeKeys"     ) 				; An array of which named Compose keys are CoDeKeys – Compose+DeadKeys.
		setLayInfo( "CoDeKeys"      , CDKs    ) 				; 
;		seqLens := pklIniCSVs( "seqLens", "4,3,2,1", cmpFile ) 	; An array of the sequence lengths to look for. By default 1–n, longest first.
;		seqMax  := Max( seqLens* )  							; eD WIP: Use a single sequenceBuffer setting, read directly from the compose file.
		seqMax  := pklIniRead( "bufSize", 16, cmpFile ) 		; How many previously typed characters to keep track of.
		seqLens := [], keysArr := []
		Loop % ix := seqMax {
			seqLens.Push( ix-- ) 								; Process sequences from the longest to the shortest
			keysArr.Push( "" )  								; Example: [ "", "", "", "" ] if 4 is the max compose length used
		}
		setLayInfo( "composeLength" , seqLens ) 				; Example: [ 4,3,2,1 ] for seqMax = 4.
		setKeyInfo( "NullKeys", keysArr )
		setKeyInfo( "LastKeys", keysArr.Clone() )   			; Used by the Compose/Completion key, via pkl_SendThis()
		initialized := true
	}
	
	If compKeys.IsEmpty()
		Return
	usedTables  := {} 											; Array of the compose tables in use, with sendBS info
	cmpKeyTabs  := {} 											; Array of table arrays for each ©-key
	For ix, cmpKey in compKeys { 								; Loop through all detected ©-keys in the layout
		tables  := pklIniCSVs( cmpKey, , cmpStck, "compose-tables" )
		For ix, sct in tables { 									; [ "+dynCmk", "x11" ] etc.
			sendBS      := 1
			If ( SubStr( sct, 1, 1 ) == "+" ) { 					; Non-eating Compose sections are marked with a "+" sign
				sct     := SubStr( sct, 2 )
				tables[ ix ] := sct 								; Rewrite this tables entry without the "+" sign.
				sendBS  := 0 										; Don't send Backspaces before the compose entry
			}
			If usedTables.HasKey( sct ) {
				Continue 											; This table was already read in, so proceed to the next one for this key
			} else {
				usedTables[ sct ] := sendBS 						; compTables[ section ] contains the sendBS info for that table section
			}
			For ix, len in seqLens { 								; Look for sequences of length for instance 1–4
				keyArr%len% := {}   								; These reside in their own arrays, to reduce lookup time etc.
			}   ; <-- for seqLens
			For ix, mapFile in cmpStck { 							; Read from the LayStack+1
				For ix, row in pklIniSect( mapFile, "compose_" . sct ) {
					If ( row == "" )
						Continue
					pklIniKeyVal( row, key, val ) 						; Compose table key,val pairs
					If ( RegExMatch(key,"U[[:xdigit:]]{4}") != 1 ) { 	; The key is a sequence of characters instead of a sequence of hex strings
						kyt := ""
						kys := ""
						For ix, chr in StrSplit( key ) { 				; Format the character string to a U####[_U####]* key
							If ( ix == 1 ) { 
								cht := upCase( chr ) 					; Also make an entry for the Titlecase version of the string key (if different)
							} else {
								cht := chr
							}   ; <-- if ch1
							kyt .= "_U" . formatUnicode( cht )
							kys .= "_U" . formatUnicode( chr )
						}   ; <-- for chr
						kyt := ( kyt == kys ) ? false : SubStr( kyt, 2 )
						key := SubStr( kys, 2 )
					}   ; <-- if string
					dum := StrReplace( key, "U",, len ) 				; Trick to count the number of "0x", i.e., the pattern length (could count _ +1)
					keyArr%len%[key] := val
					If ( kyt && keyArr%len%[kyt] == "" ) 				; Only write the Titlecase entry if previously undefined.
						keyArr%len%[kyt] := val
				}   ; <-- for row
			}   ; <-- for mapFile
			For ix, len in seqLens { 								; Look for sequences of length for instance 1–4
				setLayInfo( "comps_" . sct . len, keyArr%len% )
			}   ; <-- for seqLens
		}   ; <-- for sct in tables
		cmpKeyTabs[ cmpKey ] := tables  							; For each named key, specify its required tables
		tmp := ""
	}   ; <-- for cmpKey in compKeys
	setLayInfo( "composeKeys"   , cmpKeyTabs ) 						; At this point, the tables don't contain "+" signs
	setLayInfo( "composeTables" , usedTables )
}

lastKeys( cmd, chr := "" ) {    									; Manipulate the LastKeys array of previously sent characters for Compose
	lastKeys := getKeyInfo( "LastKeys" )  							; This links to the actual LastKeys array, not a copy
	If        ( cmd == "push" ) { 									; Push one key to the lastKeys buffer
		lastKeys.Push( chr )
		lastKeys.RemoveAt( 1 )
	} else if ( cmd == "pop1" ) { 									; Remove the last entry in lastKeys (after Backspace presses)
		lastKeys.Pop()  											; (We aren't using the pop value for anything)
		lastKeys.InsertAt( 1, "" )
	} else if ( cmd == "null" ) { 									; Reset the last-keys-pressed buffer.
		setKeyInfo( "LastKeys", getKeyInfo( "NullKeys" ).Clone() ) 	; Note: Use Clone() here, or you'll make a link to NullKeys instead
		Return
	}
}

;;  ================================================================================================================================================
;;  EPKL other Get/Set functions
;

getLayStrInfo( layStr ) {   											; Get 1) LayMain, 2) 3LA (3-letter-abbreviation), 3) string/LayDir 3LA, ...
	d3LA    := getPklInfo( "shortLays" ) 								; Global dictionary of '3LA' 3-letter layout name abbreviations. From pkl_init.
	splt    := StrSplit( layStr, "\" )  								; LayMain can also contain a subfolder. Its name often starts w/ 3LA.
	mLay    := splt[1]
	m3LA    := ( d3LA[mLay] ) ? d3LA[mLay] : SubStr( mLay,1,3 ) 		; The 3LA found in the table, or just the 3 first letters of theLay.
	endS    := splt[ splt.maxIndex() ]  								; The last part of a full layStr will normally be the LayDir itself
	s3LA    := InStr( endS, m3LA ) ? m3LA  : SubStr( endS,1,3 ) 		; The 3LA found in the string itself (the last part).
	LayType := RegExMatch( layStr, mLay . "(?:\\.*)?\\" . m3LA . "-(\w+?)(?:-\w+?)?_", REMatch ), LayType := REMatch1
;;  TODO: Make this fn return other info parsed from a layout string as well? [ LayMain, 3LA, LayPath, LayType, LayVari, KbdType, OthrMod ] ?
	Return [ mLay, m3LA, s3LA, LayType ] 								; You may specify one output by calling, e.g., getLayStrInfo(str)[2].
}

pklGetState() { 														; Get the 0:1:6:7 etc shift state as in Layout.ini and img names
	state :=  0
	state +=  1 * getKeyState( "Shift" )
;	state +=  2 * getKeyState( "Ctrl" ) 								; AltGr registers Ctrl too since it's LCtrl+RAlt (<^>!); may have to get clever here?
	state +=  6 * getLayInfo( "LayHasAltGr" ) * AltGrIsPressed()
	state +=  8 * getKeyInfo( "ModState_SwiSh" )
	state += 16 * getKeyInfo( "ModState_FliCK" )
	Return state
}
