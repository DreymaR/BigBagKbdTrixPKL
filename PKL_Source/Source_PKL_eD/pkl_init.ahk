pkl_init( layoutFromCommandLine = "" )
{
	_initReadPklIni( layoutFromCommandLine )			; Read settings from pkl.ini
	_initReadLayIni()									; Read settings from layout.ini
	_initReadAndSetOtherInfo()							; Other layout settings (dead key images, icons)
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

_initReadPklIni( layoutFromCommandLine )			;   ####################### pkl.ini #######################
{
	PklIniFile := getPklInfo( "File_Pkl_Ini" )
	if ( not FileExist( PklIniFile ) ) {
		MsgBox, %PklIniFile% file NOT FOUND`nSorry. The program will exit.
		ExitApp
	}
	
	it := pklIniRead( "language", "auto" )				; Load locale strings
	if ( it == "auto" )
		it := pklIniRead( SubStr( A_Language , -3 ), "", "Pkl_Dic", "LangStrFromLangID" )
	pkl_locale_load( it, pklIniBool( "compactMode", false ) )

	_pklSetHotkey( pklIniRead( "suspendHotkey"         ), "ToggleSuspend"       , "HK_Suspend"      )
	_pklSetHotkey( pklIniRead( "showHelpImageHotkey"   ), "showHelpImageToggle" , "HK_ShowHelpImg"  )
	_pklSetHotkey( pklIniRead( "changeLayoutHotkey"    ), "changeActiveLayout"  , "HK_ChangeLayout" )
	_pklSetHotkey( pklIniRead( "exitAppHotkey"         ), "ExitPKL"             , "HK_ExitApp"      )
	_pklSetHotkey( pklIniRead( "refreshHotkey",,, "eD" ), "rerunWithSameLayout" , "HK_Refresh"      )
	
	setDeadKeysInCurrentLayout( pklIniRead( "systemsDeadkeys" ) )
	setPklInfo( "altGrEqualsAltCtrl", pklIniBool( "altGrEqualsAltCtrl", false ) )
	
	activity_setTimeout( 1, pklIniRead( "suspendTimeOut", 0 ) )
	activity_setTimeout( 2, pklIniRead( "exitTimeOut"   , 0 ) )
	
	theLayout := pklIniRead( "layout", "", "Pkl_Ini" )
	theLayout := StrReplace( theLayout, "@T", "@K_@C@E" )	; eD: Shorthand .ini notation for kbd/mod types
	theLayout := StrReplace( theLayout, "@K", _pklLayRead( "KbdType", "<KbdType N/A>" ) )	; ISO/ANSI/etc
	theLayout := StrReplace( theLayout, "@C", _pklLayRead( "CurlMod", "<CurlMod N/A>" ) )	; Curl/--
	theLayout := StrReplace( theLayout, "@E", _pklLayRead( "ErgoMod", "<ErgoMod N/A>" ) )	; Plain, Angle, AWide etc
	layouts := StrSplit( theLayout, ",", " " )				; Split the CSV layout list
	numLayouts := layouts.MaxIndex()
	setLayInfo( "numOfLayouts", numLayouts )
	Loop, % numLayouts {									; Store the layout dir names and menu names
		nameParts := StrSplit( layouts[ A_Index ], ":" )
		theCode := nameParts[1]
		theName := ( nameParts.MaxIndex() > 1 ) ? nameParts[2] : nameParts[1]
		setLayInfo( "layout" . A_Index . "code", theCode )
		setLayInfo( "layout" . A_Index . "name", theName )
	}
	
	if ( layoutFromCommandLine )
		theLayout := layoutFromCommandLine
	else
		theLayout := getLayInfo( "layout1code" )
	if ( theLayout == "" ) {
		pkl_MsgBox( 1, getPklInfo( "File_Pkl_Ini" ) )	; "You must set the layout file in PKL .ini!"
		ExitApp
	}
	setLayInfo( "active", theLayout )
	
	nextLayoutIndex := 1								; Determine the next layout's index
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
		pkl_MsgBox( 2, layoutFile1 )											; "File not found, exiting"
		ExitApp
	}
	setPklInfo( "File_Lay_Ini", layoutFile1                                    )	; eD: Update as file path
	setLayInfo( "layDir", layoutDir )
	
	extendKey   := pklIniRead( "extend_key", "", layoutFile1, "global" )		; eD TODO: If this is set, look for multi-Extend in layout.ini
	if ( extendKey <> "" ) {
		setLayInfo( "extendKey", extendKey )
	}
	
	static initiated := 0	; Ensure the tables are read only once (eD TODO: Is this the right way? Necessary?)
	mapFile     := pklIniRead( "remapsFile", "", "Lay_Ini", "eD_info" )			; Layout remapping for ergo mods, ANSI/ISO conversion etc. 
	if ( not initiated ) && ( FileExist( mapFile ) )
	{																			; Read/set remap dictionaries
		mapTypes  := "  scMapLay     ,  scMapExt     ,  vkMapMec    "
		mapSects  := [ "mapSC_layout", "mapSC_extend", "mapVK_mecSym" ]
		Loop, Parse, mapTypes, CSV, %A_Space%%A_Tab%
		{
			mapType := A_LoopField
			mapList := pklIniRead( mapSects[ A_Index ], "", "Lay_Ini", "eD_info" )	; First, get the name of the map list
;			Loop, Parse, mapList, CSV, %A_Space%%A_Tab%							; eD TODO: Allow the map list to be a CSV, or only singular maps?
			%mapType% := _ReadRemaps( mapList, mapFile )						; Parse the map list into a list of base cycles
			%mapType% := _ReadCycles( mapType, %mapType%, mapFile )				; Parse the cycle list into a pdic of mappings
		}
	initiated := 1
	}
	
	layoutFile0 := pklIniRead( "baseLayout", "", "Lay_Ini", "eD_info" )			; eD: Read a base layout then augment/replace it
	if ( not layoutFile0 == "" ) && ( not FileExist(layoutFile0) )
		MsgBox, Warning: File '%layoutFile0%' not found!						; "File not found"
	layoutFiles := ( FileExist(layoutFile0) ) ? layoutFile0 . "," . layoutFile1 : layoutFile1
	Loop, Parse, layoutFiles, CSV
	{																			; Loop to parse the layout file(s)
	layoutFile := A_LoopField
	
	shiftStates := pklIniRead( "shiftstates", "0:1", layoutFile, "global" )
	shiftStates := shiftStates . ":8:9"					; SgCap, SgCap + Shift	(eD TODO: Utilize these somewhere?)
	setLayInfo( "hasAltGr", ( InStr( shiftStates, 6 ) ) ? 1 : 0 )
	shiftState := StrSplit( shiftStates, ":" )
	
	remap := iniReadSection( layoutFile, "layout" )
	Loop, Parse, remap, `r`n
	{
		pklIniKeyVal( A_LoopField, key, entries, 0, 0 )	; Key SC and entries. No comment stripping here to avoid nuking the semicolon!
		if ( key == "<NoKey>" )
			Continue
		key := scMapLay[ key ] ? scMapLay[ key ] : key				; If there is a SC remapping, apply it
		entry := StrSplit( entries, "`t" )
		numEntries := entry.MaxIndex()
		if ( numEntries < 2 ) {
			Hotkey, *%key%, doNothing
			Continue
		}
		entry[2] := Format( "{:L}", entry[2] )						; Check the 2nd entry (in lower case) for 'VK' or 'Modifier'
		if ( entry[2] == "virtualkey" || entry[2] == "vk")
			entry[2] := -1
		else if ( entry[2] == "modifier" )
			entry[2] := -2
		vkcode := _getVKeyCodeFromName( entry[1] )
		vkcode := vkMapMec[ vkcode ] ? vkMapMec[ vkcode ] : vkcode	; Remap the VK here before assignment. eD WIP: Check this!
		setKeyInfo( key . "vkey", vkcode )							; Set VK code (hex ##) for key
		setKeyInfo( key . "capSt", entry[2] )						; Normally caps state (0-5 for states; -1 for vk; -2 for mod)
		if ( entry[2] == -2 ) {										; The key is a modifier
			Hotkey, *%key%, modifierDown
			Hotkey, *%key% Up, modifierUp
			if ( getLayInfo( "hasAltGr" ) && entry[1] == "RAlt" )
				setKeyInfo( key . "vkey", "AltGr" )					; Set RAlt as AltGr
			else
				setKeyInfo( key . "vkey", entry[1] )				; Set VK modifier name, e.g., "rshift"
		} else if ( key == extendKey ) {							; Set the Extend key
			Hotkey, *%key% Up, upToDownKeyPress
		} else {
			Hotkey, *%key%, keyPressed
		}
		Loop, % numEntries - 3 {									; Loop through all entries for the key
			ks := shiftState[ A_Index ]								; ks is the shift state being processed
			sv := entry[ A_Index + 2 ]								; sv is the value for that state
			if ( StrLen( sv ) == 0 ) {
				sv = -- ; Disabled
			} else if ( StrLen( sv ) == 1 ) {
				sv := asc( sv )
			} else {
				if ( SubStr( sv, 1, 1 ) == "*" ) { 					; * : Special chars
					setKeyInfo( key . ks . "s", SubStr( sv, 2 ) )
					sv := "*"
				} else if ( SubStr( sv, 1, 1 ) == "=" ) { 			; = : Special chars with {Blind}
					setKeyInfo( key . ks . "s", SubStr( sv, 2 ) )
					sv := "="
				} else if ( SubStr( sv, 1, 1 ) == "%" ) { 			; % : Ligature (with unicode chars, too)
					setKeyInfo( key . ks . "s", SubStr( sv, 2 ) )
					sv := "%"
				} else if ( sv == "--" ) {
					sv = -- ;) Disabled
				} else if ( SubStr( sv, 1, 2 ) == "dk" ) { 			; dk: Dead key
					setKeyInfo( key . ks . "s", SubStr( sv, 3 ) )
					sv := "dk"
				} else {
					Loop, Parse, sv
					{
						if ( A_Index == 1 ) {
							ligature = 0
						} else if ( asc( A_LoopField ) < 128 ) {	; eD TODO: Does this mean ligatures can't be Unicode? Fix that?
							ligature = 1
							break
						}
					}
					if ( ligature ) { 								; Ligature
						setKeyInfo( key . ks . "s", sv )
						sv := "%"
					} else { 										; One character
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
	
	if ( extendKey ) {												; Set the Extend key mappings.
		extendFile  := pklIniRead( "extendFile", "", "Lay_Ini", "eD_info" )
		extendFile  := ( FileExist( extendFile ) ) ? extendFile : getPklInfo( "File_Pkl_Ini" )	; default: pkl.ini
		extndFiles  := extendFile . "," . layoutFile	; An [extend] section in layout.ini overrides pkl.ini maps
		Loop, Parse, extndFiles, CSV
		{															; Loop to parse the Extend files
			thisFile := A_LoopField
			Loop, 4													; eD WIP: Multi-Extend
			{
				thisExt  := A_Index
				thisSect := pklIniRead( "ext" . thisExt, "", thisFile, "ExtendMaps" )
				thisSect := ( thisFile == getPklInfo( "File_Pkl_Ini" ) ) ? "extend" : thisSect
				remap := iniReadSection( thisFile, thisSect )
				If ( not remap )									; If this remap is empty, continue to the next
					Continue
				Loop, Parse, remap, `r`n
				{
					pklIniKeyVal( A_LoopField , key, extMapping )	; Read the Extend mapping for this SC
					key := Format( "{:U}", key )
					key := scMapExt[ key ] ? scMapExt[ key ] : key	; If applicable, remap Extend entries
					setKeyInfo( key . "ext" . thisExt, extMapping )
				}
			}
		}	; end loop (parse extendFiles)
	}	; end if ( extendKey )
}	; end fn

_initReadAndSetOtherInfo()							;   ####################### other settings #######################
{
	layoutFile1 := getPklInfo( "File_Lay_Ini" )
	layoutDir   := getLayInfo( "layDir" )
	
	; eD TODO: List both a base DK table file and an optional local one adding/overriding it?
	;          Or, always use a local deadkey.ini in addition if it exists?
	;          An overriding file could add a -1 entry to remove a dk entry found in the base file
	Loop, 32											; Read/set deadkey name list
	{													; Start with the default dead key table
		key := "dk" . Format( "{:02}", A_Index )		; Pad with zero if index < 10
		ky2 := "dk" .                  A_Index     		; e.g., "dk1" or "dk14"
		val := "deadkey" . A_Index
		setKeyInfo( key, val )							; e.g., "dk01" = "deadkey1"
		if ( ky2 != key )
			setKeyInfo( ky2, val )						; e.g., "dk1" = "deadkey1"; backwards compatible
	}
	file := pklIniRead( "dkListFile", "", "Lay_Ini", "eD_info" )
	file := ( FileExist( file ) ) ? file : layoutFile1	; If no dedicated DK file, try the layout file
	setLayInfo( "dkfile", file )						; This file should contain the actual dk tables
	dknames := "deadKeyNames"							; The .ini section that holds dk names
	file := ( InStr( pklIniRead( -1, -1, layoutFile1 ) , dknames ) ) ? Layoutfile1 : file	; again, try the layout file
	remap := iniReadSection( file, dknames )			; Make the dead key name lookup table
	Loop, Parse, remap, `r`n
	{
		pklIniKeyVal( A_LoopField, key, val )
		if ( val )
			setKeyInfo( key, val )						; e.g., "dk01" = "dk_dotbelow"
	}
	
	; eD TODO: Allow some code for layoutDir; just .\ maybe ?!? Could have a readDir function that does this and also ..\?
	dir := pklIniRead( "img_DKeyDir", "", "Lay_Ini", "eD_info" )		; Read/set dead key image data
;	dir := ( SubStr( dir, 1, 2 ) == ".\" ) ? ( layoutDir . SubStr( dir, 2 ) ) : dir
	dir := ( FileExist( dir ) ) ? dir : layoutDir		; If no dedicated DK image dir, try the layout dir (old default)
	setLayInfo( "dkImgDir", dir )
	setLayInfo( "dkImgSuf", pklIniRead( "dk_imgSuf", "", dir . "\_dkImg.ini", "info" ) )	; A special dk image info file
	
	if ( FileExist( layoutDir . "\on.ico") ) {							; Read/set layout on/off icons
		setLayInfo( "Ico_On_File", layoutDir . "\on.ico" )
		setLayInfo( "Ico_On_Num_", 1 )
	} else if ( A_IsCompiled ) {
		setLayInfo( "Ico_On_File", A_ScriptName )
		setLayInfo( "Ico_On_Num_", 2 )	; was 6 in original PKL.exe - green 'H' icon
	} else {
		setLayInfo( "Ico_On_File", "Resources\on.ico" )
		setLayInfo( "Ico_On_Num_", 1 )
	}
	if ( FileExist( layoutDir . "\off.ico") ) {
		setLayInfo( "Ico_OffFile", layoutDir . "\off.ico" )
		
		setLayInfo( "Ico_OffNum_", 1 )
	} else if ( A_IsCompiled ) {
		setLayInfo( "Ico_OffFile", A_ScriptName )
		setLayInfo( "Ico_OffNum_", 4 )	;was 3 in original PKL.exe - keyboard icon
	} else {
		setLayInfo( "Ico_OffFile", "Resources\off.ico" )
		setLayInfo( "Ico_OffNum_", 1 )
	}
	pkl_set_tray_menu()
}	; end fn

_ReadRemaps( mapList, mapFile )					; Parse a remap string to a CSV list of cycles
{
	mapList     := pklIniRead( mapList, "", mapFile, "remaps" )		; List name -> actual list
	mapCycList  := ;
	Loop, Parse, mapList, CSV, %A_Space%%A_Tab%						; Parse CSV by comma
	{
		tmpCycle    := ;
		Loop, Parse, A_LoopField , +, %A_Space%%A_Tab%				; Parse by plus sign
		{
			theMap  := A_LoopField
			if ( SubStr( A_LoopField , 1, 1 ) == "^" )	; Ref. to another map -> Self recursion
				theMap := _ReadRemaps( SubStr( A_LoopField , 2 ), mapFile )
			tmpCycle := tmpCycle . ( ( tmpCycle ) ? ( " + " ) : ( "" ) ) . theMap		; re-attach +
		}	; end loop
		mapCycList  := mapCycList . ( ( mapCycList ) ? ( ", " ) : ( "" ) ) . tmpCycle	; re-attach CSV
	}	; end loop
	return mapCycList
}	; end fn

_ReadCycles( mapType, mapList, mapFile )					; Parse a remap string to a dictionary of remaps
{
	test0 := mapType										; eD DEBUG
	mapType := Format( "{:U}", SubStr( mapType, 1, 2 ) )	; MapTypes: (sc|vk)map(Lay|Ext|Mec) => SC|VK
	pdic    := {}
	if ( mapType == "SC" )									; Create a fresh SC pdic from mapFile KeyLayMap
		pdic := _ReadKeyLayMap( "SC", "SC", mapFile )
	rdic    := pdic.Clone()									; Reverse dictionary (instead of if loop)?
	tdic	:= {}											; Temporary dictionary used while mapping loops
	Loop, Parse, mapList, CSV, %A_Space%%A_Tab%				; Parse cycle list by comma
	{
		fullCycle := ;
		Loop, Parse, A_LoopField , +, %A_Space%%A_Tab%		; Parse and merge composite cycles by plus sign
		{
			thisCycle := pklIniRead( A_LoopField , "", mapFile, "RemapCycles" )
			thisType  := SubStr( thisCycle, 1, 2 )			; KLM map type, such as TC for TMK-like Colemak
;			rorl      := ( SubStr( thisCycle, 3, 1 ) == "<" ) ? -1 : 1		; eD TODO: R(>) or L(<) cycle?
			thisCycle := RegExReplace( thisCycle, "^.*?\|(.*)\|$", "$1" )	; Strip defs and extra pipes
			fullCycle := fullCycle . ( ( fullCycle ) ? ( " | " ) : ( "" ) ) . thisCycle	; Merge cycles
		}	; end loop
		if ( mapType == "SC" )								; Remap pdic from thisType to SC
			mapDic := _ReadKeyLayMap( thisType, "SC", mapFile )
		thisCycle := StrSplit( fullCycle, "|", " `t" )		; Parse cycle by pipe, and create mapping pdic
		numSteps  := thisCycle.MaxIndex()
		Loop, % numSteps
		{													; Loop to get proper key codes
			this := thisCycle[ A_Index ]
			if ( mapType == "SC" ) {						; Remap from thisType to SC
				thisCycle[ A_Index ] := mapDic[ this ]
			} else if ( mapType == "VK" )  {				; Remap from VK name/code to VK code (upper case)
				this := Format( "{:U}", this )
				this := ( InStr( this, "VK" ) == 1 ) ? ( SubStr( this, 3 ) ) : ( _getVKeyCodeFromName( this ) )	; "VK" . 
				thisCycle[ A_Index ] := this
			}	; end if
		}	; end loop
		test3 := test3 . ( ( test3 ) ? ( "`n" ) : ( "" ) ) . "|" . fullCycle	; eD DEBUG
		Loop, % numSteps
		{													; Loop to (re)write remap pdic
			this := thisCycle[ A_Index ]					; This key's code gets remapped to...
			this := ( mapType == "SC" ) ? rdic[ this ] : this	; When chaining maps, map the remapped key ( a→b→c )
			that := ( A_Index == numSteps ) ? thisCycle[ 1 ] : thisCycle[ A_Index + 1 ]	; ...next code
			pdic[ this ] := that							; Map the (remapped?) code to the next one
			tdic[ that ] := this							; Keep the reverse mapping for later cycles
		}	; end loop (remap one full cycle)
		for key, val in tdic 
			rdic[ key ] := val								; Activate the lookup dict for the next cycle
	}	; end loop (parse CSV)
;; eD remapping cycle notes:
;; Need this:    ( a | b | c , b | d )                           => 2>:[ a:b:d, b:c, c:a, d:b   ]
;; With rdic: 1<:[ b:a, c:b, a:c, d:d ] => 2>:[ r[b]:d, r[d]:b ] => 2>:[ a:d  , b:c, c:a, d:b   ]
;; Note that:    ( b | d , a | b | c )                           => 2>:[ a:b  , b:d, c:a, d:b:c ] - so order matters!
;; Lay(CAW): 022(Cmk-D) -> 02E(Cmk-C); 023(Cmk-H) -> 033(Cmk-,); 024(Cmk-N) -> 025(Cmk-E)
;; Ext(AWi): 022(Cmk-D) -> 022(Cmk-D); 023(Cmk-H) -> 024(Cmk-N); 030(Cmk-B) -> 02F(Cmk-V) -> 02E(Cmk-C) -> 02D(Cmk-X)
;	if ( test0 == "" . "scMapLay" ) {						; eD DEBUG
;	test1 := pdic[ "SC012" ] . " " . pdic[ "SC022" ] . " " . pdic[ "SC02F" ] . " " . pdic[ "SC02E" ] . " " . pdic[ "SC023" ] . " " . pdic[ "SC032" ]
;	test2 := rdic[ "SC012" ] . " " . rdic[ "SC022" ] . " " . rdic[ "SC02F" ] . " " . rdic[ "SC02E" ] . " " . rdic[ "SC023" ] . " " . rdic[ "SC032" ]
;	MsgBox, Debug %test0%:`n SC012 SC022 SC02F SC02E SC023 SC032 `n __E/F___G/D____V_____C_____H_____M___ `n %test1% `n %test2% `n`n%test3%
;	}	; end eD DEBUG
	return pdic
}	; end fn

_ReadKeyLayMap( keyType, valType, mapFile )	; Create a pdic from a pair of KLMaps in a remap.ini file
{
	pdic := {}
	Loop, 5											; Loop through KLM rows 0-4
	{
		keyRow := pklIniRead( keyType . ( A_Index - 1 ), "", mapFile, "KeyLayoutMap" )
		valRow := pklIniRead( valType . ( A_Index - 1 ), "", mapFile, "KeyLayoutMap" )
		valRow := StrSplit( valRow, "|", " `t" )
		Loop, Parse, keyRow, |, %A_Space%%A_Tab%
		{
			if ( not A_LoopField )
				Continue
			key := A_LoopField
			val := valRow[ A_Index ]
			if ( keyType == "SC" )					; ensure upper case for SC###
				key := Format( "{:U}", key )
			pdic[ key ] := Format( "{:U}", val )	; e.g., pdic[ "SC001" ] := "SC001"
		}	; end loop
	}	; end loop
	return pdic
}	; end fn

_getVKeyCodeFromName( name )	; Get the two-digit hex VK## code from a VK name
{
	return pklIniRead( "VK_" . Format( "{:U}", name ), "00", "Pkl_Dic", "VKeyCodeFromName" )
}

_pklLayRead( type, default )						; Read kbd type/mods from PKL.ini
{
	val := pklIniRead( type, default, "Pkl_Ini" )
	setLayInfo( type, val )							; For display
	val := ( val == "--" ) ? "" : val				; Replace "--" with nothing
	return val
}

_MessageFromNewInstance( lparam )	; Called by OnMessage( 0x0398 )
{	; If running a second instance, this message is sent
	if ( lparam == 422 )
		ExitApp
}

; eD: Moved this here from ext_Uni2Hex.ahk. eD TODO: In AHK v1.1, can it be replaced?
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

_pklSetHotkey( hkStr, gotoLabel, pklInfoTag )						; Set a PKL menu hotkey
{
	if ( hkStr <> "" ) {
		Loop, Parse, hkStr, `,
		{
			Hotkey, %A_LoopField%, %gotoLabel%
			if ( A_Index == 1 )
				setPklInfo( pklInfoTag, A_LoopField )
		}	; end loop
	}	; end if
}	; end fn
