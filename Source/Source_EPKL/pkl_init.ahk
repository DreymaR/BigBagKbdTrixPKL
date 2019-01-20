pkl_init( layoutFromCommandLine = "" )
{
	_initReadPklIni( layoutFromCommandLine )			; Read settings from pkl.ini
	_initReadLayIni()									; Read settings from layout.ini and layout part files
}	; end fn

_initReadPklIni( layoutFromCommandLine )			;   ####################### pkl.ini #######################
{
	PklIniFile := getPklInfo( "File_PklIni" )
	if ( not FileExist( PklIniFile ) ) {
		MsgBox, %PklIniFile% file NOT FOUND`nSorry. The program will exit.
		ExitApp
	}
	
	it := pklIniRead( "language", "auto" )								; Load locale strings
	if ( it == "auto" )
		it := pklIniRead( SubStr( A_Language , -3 ), "", "PklDic", "LangStrFromLangID" )
	pkl_locale_load( it, pklIniBool( "compactMode", false ) )

	pklSetHotkey( pklIniRead( "suspendHotkey"   ), "ToggleSuspend"       , "HK_Suspend"      )
	pklSetHotkey( pklIniRead( "helpImageHotkey" ), "showHelpImageToggle" , "HK_ShowHelpImg"  )
	pklSetHotkey( pklIniRead( "changeLayHotkey" ), "changeActiveLayout"  , "HK_ChangeLayout" )
	pklSetHotkey( pklIniRead( "exitAppHotkey"   ), "ExitPKL"             , "HK_ExitApp"      )
	pklSetHotkey( pklIniRead( "refreshHotkey"   ), "rerunWithSameLayout" , "HK_Refresh"      )
	
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
	setPklInfo( "extendTime", pklIniRead( "extTapTime" ) )				; --"--
	
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
}	; end fn _initReadPklIni()

_initReadLayIni()									;   ####################### layout.ini #######################
{
	theLayout := getLayInfo( "active" )
	if ( pklIniBool( "compactMode", false )	) {
		layDir := "."
	} else {
		layDir := "Layouts\" . theLayout
	}
	mainLay := layDir . "\" . getPklInfo( "LayFileName" )				; The name of the main layout .ini file
	if ( not FileExist( mainLay ) ) {
		pklMsgBox( 2, mainLay ) 										; "File not found, exiting"
		ExitApp	; eD TOFIX: Why isn't the program exiting here? Use pklExit instead?
	}
	setLayInfo( "layDir"      , layDir  )
	setPklInfo( "File_LayIni", mainLay )								; The main layout file path
	baseDir := "Layouts\" . pklIniRead( "baseLayout",, "LayIni" )		; Read a base layout then augment/replace it
	baseLay := ( baseDir == "Layouts\" ) ? "" : baseDir . "\baseLayout.ini"
	if ( FileExist( baseLay ) ) {
		setLayInfo( "basDir"      , baseDir )
		setPklInfo( "File_BasIni", baseLay )							; The base layout file path
	} else if ( baseLay ) {
		setLayInfo( "basDir"      , "" )
		setPklInfo( "File_BasIni", "" )
		pklWarning( "File '" . baseLay . "' not found!" )				; "File not found" iff base is defined but not present
	}
	
	static initiated							; Ensure the tables are read only once (eD TODO: Is this the right way? Necessary?)
	mapFile := pklIniRead( "remapsFile",, "LayIni",, "BasIni" ) 		; Layout remapping for ergo mods, ANSI/ISO conversion etc. 
	if ( not initiated ) && ( FileExist( mapFile ) )
	{																	; Read/set remap dictionaries
		mapTypes  := "  scMapLay     ,  scMapExt     ,  vkMapMec    "
		mapSects  := [ "mapSC_layout", "mapSC_extend", "mapVK_mecSym" ]	; Section names in the .ini file
		Loop, Parse, mapTypes, CSV, %A_Space%%A_Tab%
		{
			mapType := A_LoopField
			mapList := pklIniRead( mapSects[ A_Index ],, "LayIni",, "BasIni" )	; First, get the name of the map list
			%mapType% := ReadRemaps( mapList, mapFile )					; Parse the map list into a list of base cycles
			%mapType% := ReadCycles( mapType, %mapType%, mapFile )		; Parse the cycle list into a pdic of mappings
		}
		vkDic := ReadKeyLayMapPDic( "SC", "VK", mapFile )				; Make a dictionary of SC to VK codes for VK mapping below
	initiated := 1
	}
	
	extendKey := pklIniRead( "extend_key",, mainLay,, baseLay ) 		; Extend key (was in layout.ini [global])
	if ( extendKey )
		setLayInfo( "extendKey", extendKey )
	shiftStates := pklIniRead( "shiftstates", "0:1", mainLay,, baseLay )
	shiftStates .= ":8:9"												; SgCap, SgCap + Shift		eD TODO: Utilize these somewhere?
	setLayInfo( "hasAltGr", ( InStr( shiftStates, 6 ) ) ? 1 : 0 )
	setLayInfo( "shiftStates", shiftStates )							; Used by the Help Image Generator
	shiftState := StrSplit( shiftStates, ":" )
	
	layoutFiles := FileExist( baseLay ) ? [ baseLay, mainLay ] : [ mainLay ]
	for ix, layFile in layoutFiles										; Loop to parse the layout file(s)
	{
	remap := iniReadSection( layFile, "layout" )
	Loop, Parse, remap, `r`n
	{
		pklIniKeyVal( A_LoopField, key, entries, 0, 0 )	; Key SC and entries. No comment stripping here to avoid nuking the semicolon!
		if ( key == "<NoKey>" )											; eD WIP: Are there key entries using <NoKey> for SC? Documented?
			Continue
		key := scMapLay[ key ] ? scMapLay[ key ] : key					; If there is a SC remapping, apply it
		entries := RegExReplace( entries, "[ `t]+", "`t" )				; Turn any consecutive whitespace into single tabs, so...
		entry := StrSplit( entries, "`t" )								; The Tab delimiter and no padding requirements are lifted
		numEntries := ( entry.MaxIndex() < 2+shiftState.MaxIndex() ) ? entry.MaxIndex() : 2+shiftState.MaxIndex()	; Comments make pseudo-entries
		if ( numEntries == 1 ) {
			ent := Format( "{:L}", entry[1] )							; Check the entry for 'VK'/'-1' (VK map the key to itself)
			if ( ent == "virtualkey" || ent == "vk" || ent == -1 ) {
				numEntries  := 2
				entry[2] := "vk"
				entry[1] := "VK" . getVKeyCodeFromName( vkDic[key] )	; Find the right VK code for the key, from the Remap file
			}
		}
		if ( numEntries < 2 ) {											; An empty or one-entry key mapping will deactivate the key
			Hotkey, *%key%, doNothing
			Continue
		}
		entry[2] := Format( "{:L}", entry[2] )							; Check the 2nd entry (in lower case) for 'VK' or 'Modifier'
		if ( entry[2] == "virtualkey" || entry[2] == "vk")
			entry[2] := -1
		else if ( entry[2] == "modifier" )
			entry[2] := -2
		vkcode := getVKeyCodeFromName( entry[1] )						; Two-digit VK hex code (Uppercase)
		vkcode := vkMapMec[ vkcode ] ? vkMapMec[ vkcode ] : vkcode		; Remap the VK here before assignment.
		setKeyInfo( key . "vkey", vkcode )								; Set VK code (hex ##) for key
		setKeyInfo( key . "capSt", entry[2] )							; Normally caps state (0-5 for states; -1 for vk; -2 for mod)
		if ( entry[2] == -2 ) {											; The key is a modifier
			Hotkey, *%key%   ,  modifierDown
			Hotkey, *%key% Up,  modifierUp
			if ( getLayInfo( "hasAltGr" ) && entry[1] == "RAlt" )
				setKeyInfo( key . "vkey", "AltGr" )						; Set RAlt as AltGr
			else
				setKeyInfo( key . "vkey", entry[1] )					; Set VK modifier name, e.g., "rshift"
		} else if ( key == extendKey ) {								; Set the Extend key (was only mapped to Up, keyReleased)
			Hotkey, *%key%   ,  extendDown
			Hotkey, *%key% Up,  extendUp
		} else {
			Hotkey, *%key%,     keyPressed
		}
		Loop % numEntries - 3 { 										; Loop through all entries for the key
			ks  := shiftState[ A_Index ]								; This shift state for this key
			ksE := entry[ A_Index + 2 ]									; The value/entry for that state
			if        ( StrLen( ksE ) == 0 ) {							; Empty entry; ignore
				Continue
			} else if ( StrLen( ksE ) == 1 ) {							; Single character entry:
				setKeyInfo( key . ks , Ord(ksE) )						; Convert to ASCII/Unicode ordinal number; was Asc()
			} else if ( ksE == "--" ) { 								; --: Disabled state entry
				setKeyInfo( key . ks      , "" )						; "key<state>"  is the entry code
				setKeyInfo( key . ks . "s", "" )						; "key<state>s" is the entry itself
			} else {
				ksP := SubStr( ksE, 1, 1 )								; Multi-character entries may have a prefix
;				ksD := SubStr( ksE, 1, 2 )
;				if ( ksD == "dk" || ksD == "li" ) { 					; Dead key or Literal/PowerString
;					ksP := ksD
;					ksE := SubStr( ksE, 3 )
;				} else if ( not InStr( "%$*=@&", ksP ) ) {
				if ( InStr( "%$*=@&", ksP ) ) {
					ksE := SubStr( ksE, 2 ) 							; = : Send {Blind} - use current mod state
				} else {												; * : Omit {Raw}; use special !+^#{} AHK syntax
					ksP := "%"											; % : Unicode/ASCII (auto-)literal/ligature
				}														; @&: Dead keys and named literals/strings
				setKeyInfo( key . ks      , ksP )						; "key<state>"  is the entry code (=/*/%/@/&)
				setKeyInfo( key . ks . "s", ksE )						; "key<state>s" is the entry itself
			}
		}	; end loop entries
	}	; end loop (parse remap)
	}	; end loop (parse layoutFiles)
	
;_initReadOtherInfo()								;   ####################### other settings #######################
	
	;-------------------------------------------------------------------------------------
	; Read and set Extend mappings and help imagefo
	;
	if ( getLayInfo( "extendKey" ) ) {									; Set the Extend key mappings.
		extendFile  := fileOrAlt( pklIniRead( "extendFile",, "LayIni",, "BasIni" )
								, getPklInfo( "File_PklIni" ) )		; Default Extend file: pkl.ini
		extendFiles := [ extendFile, mainLay ]		; An [extend] section in layout.ini overrides pkl.ini maps	; eD WIP: Add baseLay in the middle?!
		for ix, thisFile in extendFiles
		{																; Loop to parse the Extend files
			Loop % 4 {													; Loop the multi-Extend layers
				thisExtN := A_Index
				thisSect := pklIniRead( "ext" . thisExtN , "", thisFile, "ExtendMaps" )
				thisSect := ( thisFile == getPklInfo( "File_PklIni" ) ) ? "extend" : thisSect
				remap := iniReadSection( thisFile, thisSect )
				if ( not remap )										; If this remap is empty, continue to the next
					Continue
				Loop, Parse, remap, `r`n
				{
					pklIniKeyVal( A_LoopField , key, extMapping )		; Read the Extend mapping for this SC
					key := Format( "{:U}", key )
					key := scMapExt[ key ] ? scMapExt[ key ] : key		; If applicable, remap Extend entries
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
	
	;-------------------------------------------------------------------------------------
	; Read and set the deadkey name list and help image info, and the string table file
	;
	; eD TODO: List both a base DK table file and an optional local one adding/overriding it?
	;          Or, always use a local deadkey.ini in addition if it exists?
	;          An overriding file could add a -1 entry to remove a dk entry found in the base file
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
		remap   := iniReadSection( thisFile, dknames )					; Make the dead key name lookup table
		Loop, Parse, remap, `r`n
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
	
	;-------------------------------------------------------------------------------------
	; Read and set layout on/off icons and the tray menu
	;
	ico := readLayoutIcons( layDir, baseDir )
	setLayInfo( "Ico_On_File", ico.Fil1 )
	setLayInfo( "Ico_On_Num_", ico.Num1 )
	setLayInfo( "Ico_OffFile", ico.Fil2 )
	setLayInfo( "Ico_OffNum_", ico.Num2 )
	pkl_set_tray_menu()
}	; end fn _initReadLayIni()

readLayoutIcons( layDir, altDir = "" )									; Read icons for a specified layout dir
{
	layIni  := layDir . "\" . getPklInfo( "LayFileName" )
	altIni  := altDir . "\" . getPklInfo( "LayFileName" )
	for ix, OnOff in [ "on", "off" ]
	{
		icon := OnOff . ".ico"
		icoFile := fileOrAlt( pklIniRead( "icons_OnOff", layDir . "\", layIni,, altIni ) . icon
							, "Files\ImgIcons\Gray_" . icon )	; If not specified in layout file or in dir, use this
		if ( FileExist( icoFile ) ) {
			icoFil%ix%  := icoFile
			icoNum%ix%  := 1
		} else if ( A_IsCompiled ) {
			icoFil%ix%  := A_ScriptName
			icoNum%ix%  := ( OnOff == "on" ) ? 1 : 5	; was 6/3 in original PKL.exe - keyboard and red 'S' icons
		} else {
			icoFil%ix%  := "Resources\" . icon
			icoNum%ix%  := 1
		}
	}
	Return { Fil1 : icoFil1, Num1 : icoNum1, Fil2 : icoFil2, Num2 : icoNum2 }
}

pkl_activate()
{
	SetTitleMatchMode 2
	DetectHiddenWindows on
	WinGet, id, list, %A_ScriptName%
	Loop % id {				; This isn't the first instance: Send "kill yourself" message to all instances.
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
	
	if ( pklIniBool( "startSuspended", false ) ) {
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
	val := pklIniRead( type, def )
	setLayInfo( "Ini_" . type, val )				; Stores KbdType etc for use with other parts
	val := ( val == "--" ) ? "" : prefix . val		; Replace -- with nothing, otherwise use prefix
	Return val
}

_MessageFromNewInstance( lparam )	; Called by OnMessage( 0x0398 ) in pkl_init
{	; If running a second instance, this message is sent
	if ( lparam == 422 )
		ExitApp
}
