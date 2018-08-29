pkl_init( layoutFromCommandLine = "" )
{
	_initReadPklIni( layoutFromCommandLine )			; Read settings from pkl.ini
	_initReadLayIni()									; Read settings from layout.ini
	_initReadAndSetOtherInfo()							; Other layout settings (dead key images, icons)
}	; end fn

_initReadPklIni( layoutFromCommandLine )			;   ####################### pkl.ini #######################
{
	PklIniFile := getPklInfo( "File_Pkl_Ini" )
	if ( not FileExist( PklIniFile ) ) {
		MsgBox, %PklIniFile% file NOT FOUND`nSorry. The program will exit.
		ExitApp
	}
	
	it := pklIniRead( "language", "auto" )								; Load locale strings
	if ( it == "auto" )
		it := pklIniRead( SubStr( A_Language , -3 ), "", "Pkl_Dic", "LangStrFromLangID" )
	pkl_locale_load( it, pklIniBool( "compactMode", false ) )

	pklSetHotkey( pklIniRead( "suspendHotkey"         ), "ToggleSuspend"       , "HK_Suspend"      )
	pklSetHotkey( pklIniRead( "showHelpImageHotkey"   ), "showHelpImageToggle" , "HK_ShowHelpImg"  )
	pklSetHotkey( pklIniRead( "changeLayoutHotkey"    ), "changeActiveLayout"  , "HK_ChangeLayout" )
	pklSetHotkey( pklIniRead( "exitAppHotkey"         ), "ExitPKL"             , "HK_ExitApp"      )
	pklSetHotkey( pklIniRead( "refreshHotkey",,, "eD" ), "rerunWithSameLayout" , "HK_Refresh"      )
	
	setDeadKeysInCurrentLayout( pklIniRead( "systemsDeadkeys" ) )
	setPklInfo( "altGrEqualsAltCtrl", pklIniBool( "altGrEqualsAltCtrl", false ) )
	
	activity_setTimeout( 1, pklIniRead( "suspendTimeOut", 0 ) )
	activity_setTimeout( 2, pklIniRead( "exitTimeOut"   , 0 ) )
	
	theLays := pklIniRead( "layout", "", "Pkl_Ini" )
	curlMod := _pklLayRead( "CurlMod", "<CurlMod N/A>" )
	ergoMod := _pklLayRead( "ErgoMod", "<ErgoMod N/A>" )
	modded  := ( curlMod || ergoMod ) ? "_" : ""						; Use an underscore between KbdType and Mods
	theLays := StrReplace( theLays, "@LT", "@L@K" . modded . "@C@E" )	; eD: Shorthand .ini notation for kbd/mod types
	theLays := StrReplace( theLays,  "@T",   "@K" . modded . "@C@E" )	; --"--
; eD TODO: Devise a way to omit the underscore at the end of layout folder names w/o Curl/Ergo mods.
;			Simply feed _pklLayRead a prefix that's used if non-zero? But what about Curl vs CurlAngle? OK, I think.
	theLays := StrReplace( theLays, "@K", _pklLayRead( "KbdType", "<KbdType N/A>", "_" ) )	; ISO/ANSI/etc
	theLays := StrReplace( theLays, "@C",               curlMod                          )	; Curl/--
	theLays := StrReplace( theLays, "@E",               ergoMod                          )	; Plain, Angle, AWide etc
	theLays := StrReplace( theLays, "@L", _pklLayRead( "LocalID", "<LocalID N/A>", "-" ) )	; Locale ID, e.g., "Pl"
	layouts := StrSplit( theLays, ",", " " )							; Split the CSV layout list
	numLayouts := layouts.MaxIndex()
	setLayInfo( "numOfLayouts", numLayouts )							; Store the number of listed layouts
	Loop, % numLayouts {												; Store the layout dir names and menu names
		nameParts := StrSplit( layouts[ A_Index ], ":" )
		theCode := nameParts[1]
		theName := ( nameParts.MaxIndex() > 1 ) ? nameParts[2] : nameParts[1]
		setLayInfo( "layout" . A_Index . "code", theCode )
		setLayInfo( "layout" . A_Index . "name", theName )
	}
	
	if ( layoutFromCommandLine ) {										; The cmd line layout could be not in theLays?
		theLayout   := layoutFromCommandLine
		if ( SubStr( theLayout, 1, 10 ) == "UseLayPos_" ) {				; Use layout # in list instead of full path
			thePos      := SubStr( theLayout, 11 )
			thePos      := ( thePos > numLayouts ) ? 1 : thePos
			theLayout   := getLayInfo( "layout" . thePos . "code" )
		}
	} else {
		theLayout := getLayInfo( "layout1code" )
	}
	if ( theLayout == "" ) {
		pklMsgBox( 1, getPklInfo( "File_Pkl_Ini" ) )					; "You must set the layout file in PKL .ini!"
		ExitApp
	}
	setLayInfo( "active", theLayout )
	
	nextLayoutIndex := 1												; Determine the next layout's index
	Loop, % numLayouts {
		if ( theLayout == getLayInfo( "layout" . A_Index . "code") ) {
			nextLayoutIndex := A_Index + 1
			break
		}
	}
	nextLayoutIndex := ( nextLayoutIndex > numLayouts ) ? 1 : nextLayoutIndex
	setLayInfo( "nextLayout", getLayInfo( "layout" . nextLayoutIndex . "code" ) )
}	; end fn

_initReadLayIni()									;   ####################### layout.ini #######################
{
	theLayout := getLayInfo( "active" )
	if ( pklIniBool( "compactMode", false )	) {
		layoutDir := "."
	} else {
		layoutDir := "Layouts\" . theLayout
	}
	layoutFile1 := layoutDir . "\" . getPklInfo( "File_Lay_Ini" )
	if ( not FileExist(layoutFile1) ) {
		pklMsgBox( 2, layoutFile1 )										; "File not found, exiting"
		ExitApp
	}
	setPklInfo( "File_Lay_Ini", layoutFile1 )							; eD: Update as file path
	setLayInfo( "layDir", layoutDir )
	
	extendKey := pklIniRead( "extend_key", "", layoutFile1, "global" )	; eD TODO: If this is set, look for multi-Extend in layout.ini
	if ( extendKey <> "" ) {
		setLayInfo( "extendKey", extendKey )
	}
	
	static initiated := 0	; Ensure the tables are read only once (eD TODO: Is this the right way? Necessary?)
	mapFile := pklIniRead( "remapsFile", "", "Lay_Ini", "eD_info" )		; Layout remapping for ergo mods, ANSI/ISO conversion etc. 
	if ( not initiated ) && ( FileExist( mapFile ) )
	{																	; Read/set remap dictionaries
		mapTypes  := "  scMapLay     ,  scMapExt     ,  vkMapMec    "
		mapSects  := [ "mapSC_layout", "mapSC_extend", "mapVK_mecSym" ]
		Loop, Parse, mapTypes, CSV, %A_Space%%A_Tab%
		{
			mapType := A_LoopField
			mapList := pklIniRead( mapSects[ A_Index ], "", "Lay_Ini", "eD_info" )	; First, get the name of the map list
;			Loop, Parse, mapList, CSV, %A_Space%%A_Tab%					; eD TODO: Allow the map list to be a CSV, or only singular maps?
			%mapType% := ReadRemaps( mapList, mapFile )					; Parse the map list into a list of base cycles
			%mapType% := ReadCycles( mapType, %mapType%, mapFile )		; Parse the cycle list into a pdic of mappings
		}
	initiated := 1
	}
	
	layoutFile0 := pklIniRead( "baseLayout", "", "Lay_Ini", "eD_info" )	; eD: Read a base layout then augment/replace it
	if ( not layoutFile0 == "" ) && ( not FileExist(layoutFile0) )
		MsgBox, Warning: File '%layoutFile0%' not found!				; "File not found"
	layoutFiles := ( FileExist(layoutFile0) ) ? layoutFile0 . "," . layoutFile1 : layoutFile1
	Loop, Parse, layoutFiles, CSV
	{																	; Loop to parse the layout file(s)
	layoutFile := A_LoopField
	
	shiftStates := pklIniRead( "shiftstates", "0:1", layoutFile, "global" )
	shiftStates := shiftStates . ":8:9"									; SgCap, SgCap + Shift	(eD TODO: Utilize these somewhere?)
	setLayInfo( "hasAltGr", ( InStr( shiftStates, 6 ) ) ? 1 : 0 )
	setLayInfo( "shiftStates", shiftStates )							; Used by the Help Image Generator
	shiftState := StrSplit( shiftStates, ":" )
	
	remap := iniReadSection( layoutFile, "layout" )
	Loop, Parse, remap, `r`n
	{
		pklIniKeyVal( A_LoopField, key, entries, 0, 0 )	; Key SC and entries. No comment stripping here to avoid nuking the semicolon!
		if ( key == "<NoKey>" )
			Continue
		key := scMapLay[ key ] ? scMapLay[ key ] : key					; If there is a SC remapping, apply it
		entry := StrSplit( entries, "`t" )		; eD TODO: Trim these so that we can prettify the layouts? But then, ligatures may need a %{} syntax? Or, trim only if not %?
		numEntries := entry.MaxIndex()
		if ( numEntries < 2 ) {
			Hotkey, *%key%, doNothing
			Continue
		}
		entry[2] := Format( "{:L}", entry[2] )							; Check the 2nd entry (in lower case) for 'VK' or 'Modifier'
		if ( entry[2] == "virtualkey" || entry[2] == "vk")
			entry[2] := -1
		else if ( entry[2] == "modifier" )
			entry[2] := -2
		vkcode := getVKeyCodeFromName( entry[1] )
		vkcode := vkMapMec[ vkcode ] ? vkMapMec[ vkcode ] : vkcode		; Remap the VK here before assignment. eD WIP: Check this!
		setKeyInfo( key . "vkey", vkcode )								; Set VK code (hex ##) for key
		setKeyInfo( key . "capSt", entry[2] )							; Normally caps state (0-5 for states; -1 for vk; -2 for mod)
		if ( entry[2] == -2 ) {											; The key is a modifier
			Hotkey, *%key%, modifierDown
			Hotkey, *%key% Up, modifierUp
			if ( getLayInfo( "hasAltGr" ) && entry[1] == "RAlt" )
				setKeyInfo( key . "vkey", "AltGr" )						; Set RAlt as AltGr
			else
				setKeyInfo( key . "vkey", entry[1] )					; Set VK modifier name, e.g., "rshift"
		} else if ( key == extendKey ) {								; Set the Extend key
			Hotkey, *%key% Up, upToDownKeyPress
		} else {
			Hotkey, *%key%, keyPressed
		}
		Loop, % numEntries - 3 {										; Loop through all entries for the key
			ks := shiftState[ A_Index ]									; ks is the shift state being processed
			sv := entry[ A_Index + 2 ]									; sv is the value for that state
			if ( StrLen( sv ) == 0 ) {
				sv = -- ; Disabled
			} else if ( StrLen( sv ) == 1 ) {
				sv := asc( sv )
			} else {
				if ( SubStr( sv, 1, 1 ) == "*" ) { 						; * : Special chars
					setKeyInfo( key . ks . "s", SubStr( sv, 2 ) )
					sv := "*"
				} else if ( SubStr( sv, 1, 1 ) == "=" ) { 				; = : Special chars with {Blind}
					setKeyInfo( key . ks . "s", SubStr( sv, 2 ) )
					sv := "="
				} else if ( SubStr( sv, 1, 1 ) == "%" ) { 				; % : Ligature (with unicode chars, too)
					setKeyInfo( key . ks . "s", SubStr( sv, 2 ) )
					sv := "%"
				} else if ( sv == "--" ) {
					sv = -- ;) Disabled
				} else if ( SubStr( sv, 1, 2 ) == "dk" ) { 				; dk: Dead key
					setKeyInfo( key . ks . "s", SubStr( sv, 3 ) )
					sv := "dk"
				} else {
					Loop, Parse, sv
					{
						if ( A_Index == 1 ) {
							ligature = 0
						} else if ( asc( A_LoopField ) < 128 ) {		; eD TOFIX: Does this mean ligatures can't be Unicode?
							ligature = 1
							break
						}
					}
					if ( ligature ) { 									; Ligature
						setKeyInfo( key . ks . "s", sv )
						sv := "%"
					} else { 											; One character
						sv := "0x" . _HexUC( sv )
						sv += 0
					}
				}
			}
			if ( sv != "--" )
				setKeyInfo( key . ks , sv )
		}	; end loop entries
	}	; end loop (parse remap)
	
	}	; end loop (parse layoutFiles)
	
	if ( extendKey ) {													; Set the Extend key mappings.
		extendFile  := pklIniRead( "extendFile", "", "Lay_Ini", "eD_info" )
		extendFile  := ( FileExist( extendFile ) ) ? extendFile : getPklInfo( "File_Pkl_Ini" )	; default: pkl.ini
		extendFiles := extendFile . "," . layoutFile	; An [extend] section in layout.ini overrides pkl.ini maps
		Loop, Parse, extendFiles, CSV
		{																; Loop to parse the Extend files
			thisFile := A_LoopField
			Loop, 4														; eD TODO: Multi-Extend
			{
				thisExt  := A_Index
				thisSect := pklIniRead( "ext" . thisExt, "", thisFile, "ExtendMaps" )
				thisSect := ( thisFile == getPklInfo( "File_Pkl_Ini" ) ) ? "extend" : thisSect
				remap := iniReadSection( thisFile, thisSect )
				If ( not remap )										; If this remap is empty, continue to the next
					Continue
				Loop, Parse, remap, `r`n
				{
					pklIniKeyVal( A_LoopField , key, extMapping )		; Read the Extend mapping for this SC
					key := Format( "{:U}", key )
					key := scMapExt[ key ] ? scMapExt[ key ] : key		; If applicable, remap Extend entries
					setKeyInfo( key . "ext" . thisExt, extMapping )
				}
			}
		}	; end loop (parse extendFiles)
	}	; end if ( extendKey )
}	; end fn

_initReadAndSetOtherInfo()							;   ####################### other settings #######################
{
	layoutFile  := getPklInfo( "File_Lay_Ini" )
	layoutDir   := getLayInfo( "layDir" )
	
	;-------------------------------------------------------------------------------------
	; Read and set the deadkey name list and help image info
	;
	; eD TODO: List both a base DK table file and an optional local one adding/overriding it?
	;          Or, always use a local deadkey.ini in addition if it exists?
	;          An overriding file could add a -1 entry to remove a dk entry found in the base file
	Loop, 32
	{																	; Start with the default dead key table
		key := "dk" . Format( "{:02}", A_Index )						; Pad with zero if index < 10
		ky2 := "dk" .                  A_Index  						; e.g., "dk1" or "dk14"
		val := "deadkey" . A_Index
		setKeyInfo( key, val )											; "dk01" = "deadkey1"
		if ( ky2 != key )												; ... and also, ...
			setKeyInfo( ky2, val )										; "dk1" = "deadkey1", backwards compatible
	}
	dkFile  := pklIniRead( "dkListFile", "", "Lay_Ini", "eD_info" )
	dkFile  := ( FileExist( dkFile ) ) ? dkFile : ""
	file    := ( dkFile ) ? dkFile : LayoutFile							; If no dedicated DK file, use the layout file
	setLayInfo( "dkfile", file )										; This file should contain the actual dk tables
	dknames := "deadKeyNames"											; The .ini section that holds dk names
;	file := ( InStr( pklIniRead( -1, -1, layoutFile ) , dknames ) ) ? layoutFile : file	; Prefer the layout file
	dkFiles := ( dkFile ) ? dkFile . "," . layoutFile : layoutFile
	Loop, Parse, dkFiles, CSV											; Go through both DK and Layout files for names
	{
		remap   := iniReadSection( A_LoopField, dknames )				; Make the dead key name lookup table
		Loop, Parse, remap, `r`n
		{
			pklIniKeyVal( A_LoopField, key, val )
			if ( val )
				setKeyInfo( key, val )									; e.g., "dk01" = "dk_dotbelow"
		}
	}
	dkImDir := pklIniRead( "img_DKeyDir", ".\DeadkeyImg", "Lay_Ini", "eD_info" )	; Read/set dead key image data
	dkImDir := ( FileExist( dkImDir ) ) ? dkImDir : layoutDir			; If no dedicated DK image dir, try the layout dir (old default)
	setLayInfo( "dkImgDir", dkImDir )
	HIGfile := pklIniRead( "imgGenIniFile",,, "eD" )					; DK img state suffix was in Lay_Ini, eD_info
	setLayInfo( "dkImgSuf", pklIniRead( "img_DKStateSuf", "", HIGfile ) )	; DK img state suffix, if used. Defaults to old ""/"sh".
	
	;-------------------------------------------------------------------------------------
	; Read and set layout on/off icons
	;
	if ( FileExist( layoutDir . "\on.ico") ) {
		icoFile := layoutDir . "\on.ico"
		icoNum_ := 1
	} else if ( A_IsCompiled ) {
		icoFile := A_ScriptName
		icoNum_ := 2	; was 6 in original PKL.exe - green 'H' icon
	} else {
		icoFile := "Resources\on.ico"
		icoNum_ := 1
	}
	setLayInfo( "Ico_On_File", icoFile )
	setLayInfo( "Ico_On_Num_", icoNum_ )
	if ( FileExist( layoutDir . "\off.ico") ) {
		icoFile := layoutDir . "\off.ico"
		icoNum_ := 1
	} else if ( A_IsCompiled ) {
		icoFile := A_ScriptName
		icoNum_ := 4	;was 3 in original PKL.exe - keyboard icon
	} else {
		icoFile := "Resources\off.ico"
		icoNum_ := 1
	}
	setLayInfo( "Ico_OffFile", icoFile )
	setLayInfo( "Ico_OffNum_", icoNum_ )
	pkl_set_tray_menu()
}	; end fn

pkl_activate()
{
	SetTitleMatchMode 2
	DetectHiddenWindows on
	WinGet, id, list, %A_ScriptName%
	Loop, %id%				; This isn't the first instance. Send "kill yourself" message to all instances.
	{
		id := id%A_Index%
		PostMessage, 0x398, 422,,, ahk_id %id%
	}
	Sleep, 10
	
	Menu, Tray, Icon, % getLayInfo( "Ico_On_File" ), % getLayInfo( "Ico_On_Num_" )	; _pkl_show_tray_menu()
	Menu, Tray, Icon,,, 1 ; Freeze the icon
	
	if ( pklIniBool( "showHelpImage", true ) )
		pkl_showHelpImage( 1 )

	Sleep, 200 ; I don't want to kill myself...
	OnMessage( 0x398, "_MessageFromNewInstance" )
	
	activity_ping(1)
	activity_ping(2)
	SetTimer, activityTimer, 20000
	
	if ( pklIniBool( "startsInSuspendMode", false ) ) {
		Suspend
		gosub afterSuspend
	}
}

changeLayout( nextLayout )
{
	Menu, Tray, Icon,,, 1 ; Freeze the icon
	Suspend, On
	
	if ( A_IsCompiled )
		Run %A_ScriptName% /f %nextLayout%
	else
		Run %A_AhkPath% /f %A_ScriptName% %nextLayout%
}

_pklLayRead( type, def = "<N/A>", prefix = "" )		; Read kbd type/mods from PKL.ini (used in pkl_init)
{
	val := pklIniRead( type, def, "Pkl_Ini" )
	setLayInfo( "Ini_" . type, val )				; Stores KbdType etc for use with other parts
	val := ( val == "--" ) ? "" : prefix . val		; Replace "--" with nothing, otherwise use prefix
	return val
}

_MessageFromNewInstance( lparam )	; Called by OnMessage( 0x0398 ) in pkl_init
{	; If running a second instance, this message is sent
	if ( lparam == 422 )
		ExitApp
}

; eD TODO: Moved this here from ext_Uni2Hex.ahk. In AHK v1.1, can it be replaced?
_HexUC(utf8) {   ; by Laszlo Hars: Return 4 hex Unicode digits of a UTF-8 input CHAR
   format = %A_FormatInteger%   ; save original integer format
   SetFormat Integer, Hex       ; for converting bytes to hex
   VarSetCapacity(U, 2)        ; from CoHelper.ahk
   DllCall("MultiByteToWideChar", UInt,65001, UInt,0, Str,utf8, Int,-1, UInt,&U, Int,1)
   h := 0x10000 + (*(&U+1)<<8) + *(&U)
   StringTrimLeft h, h, 3
   SetFormat Integer, %format%  ; restore original format
   return h
}
