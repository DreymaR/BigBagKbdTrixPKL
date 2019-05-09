  													;   ###############################################################
initPklIni( layoutFromCommandLine ) 				;   ########################### pkl.ini ###########################
{ 													;   ###############################################################
	PklIniFile := getPklInfo( "File_PklIni" )
	if ( not FileExist( PklIniFile ) ) {
		MsgBox, %PklIniFile% file NOT FOUND`nSorry. The program will exit.
		ExitApp
	}
	
	it := pklIniRead( "language", "auto" )								; Load locale strings
	if ( it == "auto" )
		it := pklIniRead( SubStr( A_Language , -3 ), "", "PklDic", "LangStrFromLangID" )
	pkl_locale_load( it, pklIniBool( "compactMode", false ) )

	pklSetHotkey( "suspendMeHotkey", "ToggleSuspend"       , "HK_Suspend"      )
	pklSetHotkey( "helpImageHotkey", "showHelpImageToggle" , "HK_ShowHelpImg"  )
	pklSetHotkey( "changeLayHotkey", "changeActiveLayout"  , "HK_ChangeLayout" )
	pklSetHotkey( "exitMeNowHotkey", "ExitPKL"             , "HK_ExitApp"      )
	pklSetHotkey( "refreshMeHotkey", "rerunWithSameLayout" , "HK_Refresh"      )
	pklSetHotkey( "zoomImageHotkey", "zoomHelpImage"       , "HK_ZoomHelpImg"  )
	pklSetHotkey( "moveImageHotkey", "moveHelpImage"       , "HK_MoveHelpImg"  )
	pklSetHotkey( "epklDebugHotkey", "epklDebugWIP"        , "HK_DebugWIP"     )
	
	setDeadKeysInCurrentLayout( pklIniRead( "systemsDeadkeys" ) )
	setPklInfo( "altGrEqualsAltCtrl", pklIniBool( "ctrlAltIsAltGr", false ) )
	
	activity_setTimeout( 1, pklIniRead( "suspendTimeOut", 0 ) )
	activity_setTimeout( 2, pklIniRead( "exitTimeOut"   , 0 ) )
	
	setPklInfo( "stickyMods", pklIniRead( "stickyMods" ) )				; Sticky/One-Shot modifiers (CSV)
	setPklInfo( "stickyTime", pklIniRead( "stickyTime" ) )				; --"--
	
	extMods := pklIniCSVs( "extendMods" )								; Multi-Extend w/ tap-release
	setPklInfo( "extendMod1", ( extMods[1] ) ? extMods[1] : "" )
	setPklInfo( "extendMod2", ( extMods[2] ) ? extMods[2] : "" )
	setPklInfo( "extendTaps", pklIniRead( "extendTaps" ) )				; --"--
	setPklInfo( "tapModTime", pklIniRead( "tapModTime" ) )				; Tap-or-Mod time
	
	theLays := pklIniRead( "layout", "" )								; Read the layouts string from PKL_Ini
	curlMod := _pklLayRead( "CurlMod", "<CurlMod N/A>" )
	ergoMod := _pklLayRead( "ErgoMod", "<ErgoMod N/A>" )
	modded  := ( curlMod || ergoMod ) ? "_" : ""						; Use an underscore between KbdType and Mods
	theLays := StrReplace( theLays, "@V",        "@K@C@E" )				; Shorthand .ini notation for kbd/mod
	theLays := StrReplace( theLays, "@L", _pklLayRead( "LocalID", "<LocalID N/A>", "-" ) )	; Locale ID, e.g., "-Pl"
	theLays := StrReplace( theLays, "@K", _pklLayRead( "KbdType", "<KbdType N/A>", "_" ) )	; _ISO/_ANS/_etc
	theLays := StrReplace( theLays, "@C@E", modded . curlMod . ergoMod )	; CurlAngle[Wide]
	theLays := StrReplace( theLays, "@C",   modded . curlMod           )	; --, Curl
	theLays := StrReplace( theLays, "@E",   modded . ergoMod           )	; --, Angle, AWide...
	layouts := StrSplit( theLays, ",", " " )							; Split the CSV layout list
	numLayouts := layouts.MaxIndex()
	setLayInfo( "numOfLayouts", numLayouts )							; Store the number of listed layouts
	Loop % numLayouts {													; Store the layout dir names and menu names
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
		pklMsgBox( 1, getPklInfo( "File_PklIni" ) ) 					; "You must set the layout file in PKL .ini!"
		ExitApp
	}
	setLayInfo( "active", theLayout )
	
	nextLayoutIndex := 1												; Determine the next layout's index
	Loop % numLayouts {
		if ( theLayout == getLayInfo( "layout" . A_Index . "code") ) {
			nextLayoutIndex := A_Index + 1
			break
		}
	}
	nextLayoutIndex := ( nextLayoutIndex > numLayouts ) ? 1 : nextLayoutIndex
	setLayInfo( "nextLayout", getLayInfo( "layout" . nextLayoutIndex . "code" ) )
}	; end fn initPklIni()

  													;   ###############################################################
initLayIni() 										;   ######################### layout.ini  #########################
{ 													;   ###############################################################
	static initialized  := false
	
	theLayout := getLayInfo( "active" )
	if ( pklIniBool( "compactMode", false )	) {
		layDir := "."
	} else {
		layDir := "Layouts\" . theLayout
	}
	mainLay := layDir . "\" . getPklInfo( "LayFileName" )				; The name of the main layout .ini file
	if ( not FileExist( mainLay ) ) {
		pklMsgBox( 2, mainLay ) 										; "File not found, exiting"
		ExitApp 	;gosub ExitPKL 										; eD TOFIX: Why isn't the program exiting here?
	}
	setLayInfo( "layDir"            , layDir  )
	setPklInfo( "File_LayIni"       , mainLay )							; The main layout file path
	basePath        := pklIniRead( "baseLayout",, "LayIni" ) 			; Read a base layout then augment/replace it
	SplitPath, basePath, baseLay, baseDir
	baseDir         := "Layouts\" . baseDir
	baseLay         := "Layouts\" . basePath . ".ini"
	if ( FileExist( baseLay ) ) {
		setLayInfo( "basDir"        , baseDir )
		setPklInfo( "File_BasIni"   , baseLay ) 						; The base layout file path
	} else if ( basePath ) {
		setLayInfo( "basDir"        , "" )
		setPklInfo( "File_BasIni"   , "" )
		pklWarning( "File '" . baseLay . "' not found!" ) 				; "File not found" iff base is defined but not present
	}
	
	mapFile := pklIniRead( "remapsFile",, "LayIni",, "BasIni" ) 		; Layout remapping for ergo mods, ANSI/ISO conversion etc.
	if ( not initialized ) && ( FileExist( mapFile ) ) 					; Ensure the tables are read only once
	{																	; Read/set remap dictionaries
		mapTypes    := "  scMapLay     ,  scMapExt     ,  vkMapMec    "
		mapSects    := [ "mapSC_layout", "mapSC_extend", "mapVK_mecSym" ]	; Section names in the .ini file
		Loop, Parse, mapTypes, CSV, %A_Space%%A_Tab%
		{
			mapType := A_LoopField
			mapList := pklIniRead( mapSects[ A_Index ],, "LayIni",, "BasIni" )	; First, get the name of the map list
			%mapType% := ReadRemaps( mapList, mapFile )					; Parse the map list into a list of base cycles
			%mapType% := ReadCycles( mapType, %mapType%, mapFile )		; Parse the cycle list into a pdic of mappings
		}
		vkDic := ReadKeyLayMapPDic( "SC", "VK", mapFile )				; Make a dictionary of SC to VK codes for VK mapping below
		initialized := true
	}
	
	shStates := pklIniRead( "shiftStates", "0:1"   , mainLay, "global", baseLay ) 	; .= ":8:9" ; SgCap should be declared explicitly
	shStates := pklIniRead( "shiftStates", shStates, mainLay, "layout", baseLay ) 	; This was in [global] then [pkl]
	shStates := RegExReplace( shStates, "[ `t]+" ) 						; Remove any whitespace
	setLayInfo( "hasAltGr", InStr( shStates, 6 ) ? 1 : 0 )
	setLayInfo( "shiftStates", shStates ) 								; Used by the Help Image Generator
	shiftState := StrSplit( shStates, ":" )
	
	layoutFiles := FileExist( baseLay ) ? [ baseLay, mainLay ] : [ mainLay ]
	for ix, layFile in layoutFiles										; Loop parsing the layout file(s), baseLayout then layout.
	{
	extKey := pklIniRead( "extend_key","", layFile ) 					; Extend was in layout.ini [global]. Can map it directly now.
	map := iniReadSection( layFile, "layout" )
	( extKey ) ? map .= "`r`n" . extLay . " = Extend Modifier" 			; Define the Extend key. Lifts earlier req of a layout entry.
	Loop, Parse, map, `r`n 												; Loop parsing the layout 'key = entries' lines
	{
		pklIniKeyVal( A_LoopField, key, entries, 0, 0 )	; Key SC and entries. No comment stripping here to avoid nuking the semicolon!
		if ( key == "<NoKey>" ) || ( key == "shiftStates" ) 			; This could be mapped, but usually it's from pklIniKeyVal()
			Continue
		key     := scMapLay[ key ] ? scMapLay[ key ] : key 				; If there is a SC remapping, apply it
		entries := RegExReplace( entries, "[ `t]+", "`t" ) 				; Turn any consecutive whitespace into single tabs, so...
		entry   := StrSplit( entries, "`t" ) 							; The Tab delimiter and no padding requirements are lifted
		numEntr  := ( entry.MaxIndex() < 2 + shiftState.MaxIndex() ) 
			? entry.MaxIndex() : 2 + shiftState.MaxIndex() 				; Comments make pseudo-entries, so truncate them
		extKey := "--" 													; For each layout file, look to mark a key as Extend key
		if ( InStr( entry[1], "/" ) ) { 								; Check for Tap-or-Modifier keys (ToM):
			tomEnts  := StrSplit( entry[1], "/" ) 						;   Their VK entry is of the form 'VK/ModName'.
			entry[1] := tomEnts[1]
			tapMod   := _checkModName( tomEnts[2] )
			extKey := ( loCase( tapMod ) == "extend" ) ? key : extKey 	; Mark this key as the Extend key?
;			if ( loCase( tapMod ) == "extend" )
;				setLayInfo( "extendKey", key ) 							; The extendKey LayInfo is used by ExtendIsPressed
			setKeyInfo( key . "ToM", tapMod )
		} else {
			tapMod   := ""
		}
		vkStr := "i)virtualkey|vk|vkey|-1" 								; RegEx needle for VKey entries, ignoring case
		if ( numEntr == 1 ) && RegExMatch( entry[1], vkStr) { 			; Check the entry for VK/-1/etc (VK map the key to itself)
			numEntr  := 2
			entry[1] := "VK" . getVKeyCodeFromName( vkDic[key] )		; Find the right VK code for the key, from the Remap file
			entry[2] := "VKey"
		}
		if ( numEntr < 2 ) { 											; An empty or one-entry key mapping will deactivate the key
			Hotkey, *%key%   ,  doNothing 								; The *SC### format maps the key regardless of modifiers.
			Hotkey, *%key% Up,  doNothing 								; eD WIP: Does a key Up doNothing help to unset better?
			Continue 									; eD WIP: Is this working though? With base vs layout?
		}
		if ( InStr( "modifier", loCase(entry[2]) ) == 1 ) { 			; Entry 2 is either the Cap state (0-5), 'VK' or 'Modifier'
			entry[1] := _checkModName( entry[1] ) 						; Modifiers are stored as their AHK or special names
			extKey := ( entry[1] == "Extend" ) ? key : extKey 			; Directly mapped 'key = Extend Modifier'
			setKeyInfo( key . "vkey", entry[1] ) 						; Set VK as modifier name, e.g., "RShift", "AltGr" or "Extend"
			entry[2] := -2 												; -2 = Modifier
		} else {
			vkcode := getVKeyCodeFromName( entry[1] )					; Translate to the two-digit VK## hex code (Uppercase)
			vkcode := vkMapMec[ vkcode ] ? vkMapMec[ vkcode ] : vkcode	; Remap the VKey here before assignment.
			setKeyInfo( key . "vkey", vkcode )							; Set VK code (hex ##) for the key
			entry[2] := RegExMatch( entry[2], vkStr ) ? -1 : entry[2] 	; -1 = VKey
		}
		setKeyInfo( key . "capSt", entry[2] ) 							; Set Caps state (0-5 for states; -1 VK; -2 Mod)
;			Hotkey, *%key%   ,  Off 	; eD WIP: This crashes if hotkey isn't set. Check first? Or unnecessary?
;			Hotkey, *%key% Up,  Off
		if ( tapMod ) { 												; Tap-or-Modifier
			Hotkey, *%key%   ,  tapOrModDown
			Hotkey, *%key% Up,  tapOrModUp
		} else if ( entry[2] == -2 ) {									; Set modifier keys, including Extend
			Hotkey, *%key%   ,  modifierDown
			Hotkey, *%key% Up,  modifierUp
		} else {
			Hotkey, *%key%,     keyPressed 								; Set normal keys
			Hotkey, *%key% Up,  doNothing 	 							; eD WIP: Only Down needed? - PKL sends a lot of Down-Up presses. But if the key is redefined?
		}	; end if entries
		Loop % numEntr - 2 { 											; Loop through all entries for the key, starting at #3
			ks  := shiftState[ A_Index ]								; This shift state for this key
			ksE := entry[ A_Index + 2 ]									; The value/entry for that state
			if        ( StrLen( ksE ) == 0 ) {							; Empty entry; ignore
				Continue
			} else if ( StrLen( ksE ) == 1 ) {							; Single character entry:
				setKeyInfo( key . ks , Ord(ksE) )						; Convert to ASCII/Unicode ordinal number; was Asc()
			} else if ( ksE == "--" ) || ( ksE == -1 ) { 				; --: Disabled state entry (MSKLC uses -1)
				setKeyInfo( key . ks      , "" )						;     "key<state>"  is the entry code
				setKeyInfo( key . ks . "s", "" )						;     "key<state>s" is the entry itself
			} else if ( loCase( KsE ) == "spc" ) { 						; Spc: Special space entry; can also use &Spc now
				setKeyInfo( key . ks      , "=" ) 						;     "key<state>"  to send the key {Blind} w/ mods
				setKeyInfo( key . ks . "s", "{Space}" ) 				;     "key<state>s" is the entry itself
			} else {
				ksP := SubStr( ksE, 1, 1 )								; Multi-character entries may have a prefix
				if ( InStr( "%$*=~@&", ksP ) ) {
					ksE := SubStr( ksE, 2 ) 							; = : Send {Blind} - use current mod state
				} else {												; * : Omit {Raw}; use special !+^#{} AHK syntax
					ksP := "%"											; % : Unicode/ASCII (auto-)literal/ligature
				}														; @&: Dead keys and named literals/strings
				setKeyInfo( key . ks      , ksP )						; "key<state>"  is the entry code (=/*/%/@/&)
				setKeyInfo( key . ks . "s", ksE )						; "key<state>s" is the entry itself
			}
;		debug   .= "`n" key " = VK" getKeyInfo( key . "vkey" ) "`tCapSt:" getKeyInfo( key . "CapSt" ) "`tState0/1:" getKeyInfo( key . "0s" ) " " getKeyInfo( key . "1s" )
		}	; end loop entries
	if ( key == extBase ) && ( key != extKey ) 							; baseLay set this as Extend key but mainLay unset it
		setLayInfo( "extendKey", "" )
	}	; end loop (parse keymap)
;	( 1 ) ? pklDebug( "" RegExReplace( debug, "is).SC053*" ), 99 )  ; eD DEBUG
	extBase := ( layFile == baseLay ) ? extKey : ""
	if ( extKey != "--" )
		setLayInfo( "extendKey", extKey ) 								; The extendKey LayInfo is used by ExtendIsPressed
	}	; end loop (parse layoutFiles)
	
  													;   ###############################################################
;initOtherInfo() 									;   ####################### other settings  #######################
  													;   ###############################################################
	
	;;  -----------------------------------------------------------------------------------------------
	;;  Read and set Extend mappings and help image info
	;
	if ( getLayInfo( "extendKey" ) ) {									; Set the Extend key mappings.
		extendFile  := fileOrAlt( pklIniRead( "extendFile",, "LayIni",, "BasIni" )
								, getPklInfo( "File_PklIni" ) )			; Default Extend file: pkl.ini
		extendFiles := [ extendFile, mainLay ]		; An [extend] section in layout.ini overrides pkl.ini maps	; eD WIP: Add baseLay in the middle?!
		hardLayers  := strSplit( pklIniRead( "extHardLayers", "1/1/1/1", extendFile,, mainLay ), "/", " " ) 	; Array of hard layers
		for ix, thisFile in extendFiles
		{																; Loop to parse the Extend files
			Loop % 4 {													; Loop the multi-Extend layers
				thisExtN := A_Index
				thisSect := pklIniRead( "ext" . thisExtN , "", thisFile ) 	; eD: , "ExtendMaps" )
				thisSect := ( thisFile == getPklInfo( "File_PklIni" ) ) ? "extend" : thisSect
				map := iniReadSection( thisFile, thisSect )
				if ( not map ) 											; If this map layer is empty, go on
					Continue
				Loop, Parse, map, `r`n
				{
					pklIniKeyVal( A_LoopField , key, extMapping )		; Read the Extend mapping for this SC
					key := upCase( key )
					if ( hardLayers[ thisExtN ] ) { 					; If this Ext# layer is hard-modded...
						key := scMapExt[ key ] ? scMapExt[ key ] : key		; If applicable, hard remap entry
					} else {
						key := scMapLay[ key ] ? scMapLay[ key ] : key		; If applicable, soft remap entry
					}
					setKeyInfo( key . "ext" . thisExtN , extMapping )
				}	; end loop (parse extMappings)
			}	; end loop ext#
		}	; end loop (parse extendFiles)
		setPklInfo( "extReturnTo", pklIniRead( "extReturnTo", "1/2/3/4", extendFile,, mainLay ) ) 	; ReturnTo layers
		Loop % 4 {
			setLayInfo( "extImg" . A_Index								; Extend images
				  , fileOrAlt( pklIniRead( "img_Extend" . A_Index ,, "LayIni",, "BasIni" ), layDir . "\extend.png" ) )
		}	; end loop ext#
	}	; end if ( extendKey )
	
	;;  -----------------------------------------------------------------------------------------------
	;;  Read and set the deadkey name list and help image info, and the string table file
	;;
	;;  eD TODO: List both a base DK table file and an optional local one adding/overriding it?
	;;           Or, always use a local deadkey.ini in addition if it exists?
	;;           An overriding file could add a -1 entry to remove a dk entry found in the base file
	;
	Loop % 32 {															; Start with the default dead key table
		key := "@" . Format( "{:02}", A_Index ) 						; Pad with zero if index < 10
		ky2 := "@" .                  A_Index   						; e.g., "dk1" or "dk14"
		val := "deadkey" . A_Index
		setKeyInfo( key, val )											; "dk01" = "deadkey1"
		if ( ky2 != key )												; ... and also, ...
			setKeyInfo( ky2, val )										; "dk1" = "deadkey1", backwards compatible
	}
	dkFile  := fileOrAlt( pklIniRead( "dkListFile",, "LayIni",, "BasIni" )
						, mainLay )										; Default DK file: layout.ini
	setLayInfo( "dkFile", dkFile )										; This file should contain the actual dk tables
	dknames := "deadKeyNames"											; The .ini section that holds dk names
	dkFiles := ( dkFile != mainLay ) ? [ dkFile, mainLay ] : [ mainLay ]
	for ix, thisFile in dkFiles											; Go through both DK and Layout files for names
	{
		map   := iniReadSection( thisFile, dknames ) 					; Make the dead key name lookup table
		Loop, Parse, map, `r`n
		{
			pklIniKeyVal( A_LoopField, key, val )
			if ( val )
				setKeyInfo( key, val )									; e.g., "dk01" = "dk_dotbelow"
		}
	}
	dkImDir := fileOrAlt( pklIniRead( "img_DKeyDir", ".\DeadkeyImg", "LayIni",, "BasIni" )	; Read/set DK image data
						, layDir )										; Default DK img dir: Layout dir or DeadkeyImg
	setLayInfo( "dkImgDir", dkImDir )
	HIGfile := pklIniRead( "imgGenIniFile" )							; DK img state suffix was in LayIni
	setLayInfo( "dkImgSuf", pklIniRead( "img_DKStateSuf", "", HIGfile ) )	; DK img state suffix. Defaults to old ""/"sh".
	
	strFile  := fileOrAlt( pklIniRead( "stringFile",, "LayIni",, "BasIni" )
						, mainLay )										; Default literals/powerstring file: layout.ini
	setLayInfo( "strFile", strFile )									; This file should contain the string tables
	
	;;  -----------------------------------------------------------------------------------------------
	;;  Read and set layout on/off icons and the tray menu
	;
	ico := readLayoutIcons( mainLay, baseLay )
	setLayInfo( "Ico_On_File", ico.Fil1 )
	setLayInfo( "Ico_On_Num_", ico.Num1 )
	setLayInfo( "Ico_OffFile", ico.Fil2 )
	setLayInfo( "Ico_OffNum_", ico.Num2 )
	pkl_set_tray_menu()
}	; end fn initLayIni()

activatePKL() 										; Activate PKL single-instance, with a tray icon etc
{
	SetTitleMatchMode 2
	DetectHiddenWindows on
	WinGet, id, list, %A_ScriptName%
	Loop % id {
		id := id%A_Index% 							; If this isn't the first instance...
		PostMessage, 0x398, 422,,, ahk_id %id% 		; ...send a "kill yourself" message to all instances.
	}
	Sleep, 10
	
	Menu, Tray, Icon, % getLayInfo( "Ico_On_File" ), % getLayInfo( "Ico_On_Num_" )
	Menu, Tray, Icon,,, 1 							; Freeze the tray icon
	
	if ( pklIniBool( "showHelpImage", true ) )
		pkl_showHelpImage( 1 ) 						; Show the help image

	Sleep, 200 										; I don't want to kill myself...
	OnMessage( 0x398, "_MessageFromNewInstance" )
	
	activity_ping(1) 								; Update the current ping time
	activity_ping(2)
	SetTimer, activityTimer, 20000 					; Check for timeouts every 20 s
	
	if ( pklIniBool( "startSuspended", false ) ) {
		Suspend
		gosub afterSuspend
	}
}	; end fn

changeLayout( nextLayout ) 							; Rerun PKL with a specified layout
{
	Menu, Tray, Icon,,, 1 							; Freeze the tray icon
	Suspend, On
	
	if ( A_IsCompiled )
		Run %A_ScriptName% /f %nextLayout%
	else
		Run %A_AhkPath% /f %A_ScriptName% %nextLayout%
}

_pklLayRead( type, def = "<N/A>", prefix = "" )		; Read kbd type/mods from PKL.ini (used in pkl_init)
{
	val := pklIniRead( type, def )
	setLayInfo( "Ini_" . type, val )				; Stores KbdType etc for use with other parts
	val := ( val == "--" ) ? "" : prefix . val		; Replace -- with nothing, otherwise use prefix
	Return val
}

_checkModName( key ) 								; Mod keys need only the first letters of their name
{
	static modNames := [ "LShift", "RShift", "CapsLock", "Extend"
						, "LCtrl", "RCtrl", "LAlt", "RAlt", "LWin", "RWin" ]
	
	for ix, modName in modNames {
		if ( InStr( modName, key, 0 ) == 1 ) 		; Case insensitive match: Does modName start with key?
			key := modName
	}
	if ( getLayInfo( "hasAltGr" ) && key == "RAlt" ) {
		Return "AltGr" 								; RAlt as AltGr
	} else {
		Return key 									; AHK modifier names, e.g., "RS" or "RSh" -> "RShift"
	}
}

_MessageFromNewInstance( lparam ) 					; Called by OnMessage( 0x0398 ) in pkl_init
{ 													; If running a second instance, this message is sent
	if ( lparam == 422 )
		ExitApp
}
