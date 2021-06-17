;; ================================================================================================
;;  EPKL get/set module
;;      Static associative dictionaries for EPKL info are used instead of most globals
;
/*
	LayoutInfo entries:
	-------------------
	ActiveLay     := "" ; The active layout
	dir           := "" ; The directory of the active layout (eD: Obsolete)
	LayHasAltGr   := 0  ; Should Right Alt work as AltGr in the layout?
	ExtendKey     := "" ; Extend modifier for navigation, editing, etc.
	
	NextLayout    := "" ; If you set multiple layouts, this is the next one.
	                    ; see the "changeActiveLayout:" label!
	NumOfLayouts  := 0  ; Array size
	LayoutsXcode        ; layout code
	LayoutsXname        ; layout name
	Ico_On_File         ; Icon for On  (file)
	Ico_On_Num_         ; --"--        (# in file)
	Ico_OffFile         ; Icon for Off (file)
	Ico_OffNum_         ; --"--        (# in file)
	...and more...
*/
	
setKeyInfo( key, value )
{
	Return getKeyInfo( key, value, 1 )
}

setLayInfo( var, val )
{
	Return getLayInfo( var, val, 1 )
}

setPklInfo( key, value )
{
	getPklInfo( key, value, 1 )
}

getKeyInfo( key, value = "", set = 0 )
{
	static pdic     := {}
	if ( set == 1 )
		pdic[key]   := value
	else
		Return pdic[key]
}

getLayInfo( key, value = "", set = 0 )
{
	static pdic     := {}
	if ( set == 1 )
		pdic[key]   := value
	else
		Return pdic[key]
}

getPklInfo( key, value = "", set = 0 )
{
	static pdic     := {}
	if ( set == 1 )
		pdic[key]   := value
	else
		Return pdic[key]
}

;; ================================================================================================
;;  EPKL locale module
;;      Functions to set up locale strings
;;      Used by initPklIni() in pkl_init.ahk
;

pkl_locale_load( lang )
{
	static initialized  := false 	; Defaults are read only once, as this function is run on layout change too 	; eD WIP: Does that really work, or matter?
	if ( not initialized )
	{															; Read/set default locale string list
		For ix, sectName in [ "DefaultLocaleStr", "DefaultLocaleTxt" ] { 	; Read defaults from the EPKL_Tables file
			For ix, row in pklIniSect( getPklInfo( "File_PklDic" ), sectName ) { 	; Read default locale strings (key/value)
				pklIniKeyVal( row, key, val, 1 ) 				; Extraction with \n escape replacement
				setPklInfo( key, val )
			}
		}	; end For
		initialized := true
	}
	
	file := lang . ".ini"
	file := ( bool(pklIniRead("compactMode")) ) ? file : "Files\Languages\" . file
	if not FileExist( file ) 									; If the language file isn't found, we'll just use the defaults
		Return
	For ix, row in pklIniSect( file, "pkl" ) { 					; Read the main locale strings frome the PKL section
		pklIniKeyVal( row, key, val, 1 ) 						; A more compact way than before (but still in a loop)
		if ( val != "" ) { 						; LocStr_ 00-22,LaysSetts,AHKeyHist,MakeImage,ImportKLC,ZoomImage,MoveImage,RefreshMe...
			key := ( key <= 9 ) 
					? SubStr("00" . key, -1) : key 				; If key is #, zero pad it to 0# instead
			setPklInfo( "LocStr_" . key , val ) 				; pklLocaleStrings( key, val, 1 )
		}
	}	; end For
	
	For ix, row in pklIniSect( file, "detectDeadKeys" ) { 		; Read the locale strings for DK detection
		pklIniKeyVal( row, key, val, 1 )
		setPklInfo( "DetecDK_" . key, val ) 					; detectDeadKeys_SetLocaleTxt(
	}	; end For
	
	For ix, row in pklIniSect( file, "keyNames" ) { 			; Read the list of keys and mouse buttons
		pklIniKeyVal( row, key, val, 0 ) 						; Read without character escapes
		_setHotkeyText( key, val )
	}	; end For
}

_setHotkeyText( hk, localehk )
{
	_getHotkeyText( hk, localehk, 1 )
}

_getHotkeyText( hk, localehk = "", set = 0 )
{
	static localizedHotkeys := ""
	
	if ( set == 1 ) {
		setKeyInfo( "HKtxt_" . hk, localehk )
		localizedHotkeys    .= " " . hk
	} else {
		if ( hk == "all" )
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

;; ================================================================================================
;;  EPKL Composer module
;;      Set up compose string tables from a file
;;      The tables are used by pkl_Composer() in pkl_send.ahk
;;      Called in pkl_init.ahk
;

init_Composer( compKeys ) { 									; Initialize EPKL Compose tables for all detected ©-keys 	; eD WIP
	static initialized := false
	
	mapFile := pklIniRead( "cmposrFile", , "LayStk" ) 			; eD TODO: Allow searches in BasIni and LayIni as well?! Lay > Bas > Compose, as usual
	if ( not initialized ) { 									; First-time initialization
		setKeyInfo( "LastKeys", [ "", "", "", "" ] ) 			; Used by the Compose/Completion key, via pkl_SendThis()
		lengths := pklIniCSVs( "lengths", "4,3,2,1",  mapFile ) 	; An array of the sequence lengths to look for. By default 1–4, longest first.
		setLayInfo( "composeLength" , lengths ) 				; Example: [ 4,3,2,1 ]
		initialized := true
	} 	; end if init
	if compKeys.IsEmpty()
		Return
	usedTables  := {} 											; Array of the compose tables in use, with sendBS info
	cmpKeyTabs  := {} 											; Array of tables for each ©-key
	for ix, cmpKey in compKeys { 								; Loop through all detected ©-keys in the layout
;		if compKeys.HasKey( cmpKey ) 								; This key occurs in several mappings on one layout, so don't define it again
;			Return
;		pklInfo( "init_Composer( " . cmpKey . " )" ) 	; eD DEBUG
		
		tables      := pklIniCSVs( cmpKey, , mapFile, "compose-tables" )
		for ix, sct in tables { 									; [ "+dynCmk", "x11" ] etc.
			sendBS      := 1
			if ( SubStr( sct, 1, 1 ) == "+" ) { 					; Non-eating Compose sections are marked with a "+" sign
				sct     := SubStr( sct, 2 )
				tables[ ix ] := sct 								; Rewrite this tables entry without the "+" sign.
				sendBS  := 0 										; Don't send Backspaces before the compose entry
			}
			if usedTables.HasKey( sct ) {
				Continue 											; This table was already read in, so proceed to the next one for this key
			} else {
				usedTables[ sct ] := sendBS 						; compTables[ section ] contains the sendBS info for that table section
			}
			for ix, len in lengths { 								; Look for sequences of length for instance 1–4
				keyArr%len% := {} 									; These reside in their own arrays, to reduce lookup time etc.
			} 	; end for lengths
			for ix, row in pklIniSect( mapFile, "compose_" . sct ) {
				pklIniKeyVal( row, key, val ) 						; Compose table key,val pairs
				if ( not SubStr( key, 1, 2 ) == "0x" ) { 			; The key is a sequence of characters instead of a sequence of hex strings
					kyt := ""
					kys := ""
					for ix, chr in StrSplit( key ) { 
						if ( ix == 1 ) { 
							cht := Format( "{:U}", chr ) 			; Also make an entry for the Titlecase version of the string key (if different)
						} else {
							cht := chr
						} 	; end if ch1
						kyt .= "_" . formatUni( cht )
						kys .= "_" . formatUni( chr )
					} 	; end for chr
					kyt := ( kyt == kys ) ? false : SubStr( kyt, 2 )
					key := SubStr( kys, 2 )
				} 	; end if 0x####
				dum := StrReplace( key, "0x",, len ) 				; Trick to count the number of "0x", i.e., the pattern length
				keyArr%len%[key] := val
				if ( kyt )
					keyArr%len%[kyt] := val
			} 	; end for row
			for ix, len in lengths { 								; Look for sequences of length for instance 1–4
				setLayInfo( "comps_" . sct . len, keyArr%len% )
			} 	; end for lengths
		} 	; end for sct in tables
		cmpKeyTabs[ cmpKey ] := tables 								; For each named key, specify its required tables
	} 	; end for cmpKey in compKeys
	setLayInfo( "composeKeys"   , cmpKeyTabs ) 						; At this point, the tables don't contain "+" signs
	setLayInfo( "composeTables" , usedTables )
;	test := getLayInfo( "composeTables" )
;	( sct != "x" ) ? pklDebug( "BS[" . sct . "] = " . test[sct] . "/" . usedTables[sct] . "`nBS[dynCmk] = " . test["dynCmk"] . "`nBS[x11] = " . test["x11"], 3 )  ; eD DEBUG
}
