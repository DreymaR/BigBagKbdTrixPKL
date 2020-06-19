  													;   ###############################################################
initPklIni( layoutFromCommandLine ) 				;   ########################## epkl.ini ###########################
{ 													;   ###############################################################
	pklIniFile := getPklInfo( "File_PklSet" ) . ".ini"
	if not FileExist( pklIniFile ) {
		MsgBox, %pklIniFile% file NOT FOUND`nSorry. The program will exit.
		ExitApp
	}
	setPklInfo( "File_PklSet", pklIniFile )
	setPklInfo( "AdvancedMode", bool(pklIniRead("advancedMode")) ) 		; Extra debug info etc
	pklLays := getPklInfo( "File_PklLay" ) 								; EPKL_Layouts
	pklLays := [ pklLays . "_Override.ini", pklLays . "_Default.ini" ] 	; Now an array of override and default
	setPklInfo( "Arr_PklLay", pklLays )
	
	lang := pklIniRead( "language", "auto" ) 							; Load locale strings
	if ( lang == "auto" )
		lang := pklIniRead( SubStr( A_Language , -3 ), "", "PklDic", "LangStrFromLangID" )
	pkl_locale_load( lang )
	
	;;  Legend: (  hkIniName       ,  gotoLabel            ,  pklInfoTag       ) 	; Set a (menu) hotkey
	pklSetHotkey( "suspendMeHotkey", "ToggleSuspend"       , "HK_Suspend"      )
	pklSetHotkey( "helpImageHotkey", "showHelpImageToggle" , "HK_ShowHelpImg"  )
	pklSetHotkey( "changeLayHotkey", "changeActiveLayout"  , "HK_ChangeLayout" )
	pklSetHotkey( "exitMeNowHotkey", "ExitPKL"             , "HK_ExitApp"      )
	pklSetHotkey( "refreshMeHotkey", "rerunWithSameLayout" , "HK_Refresh"      ) 	; Advanced Mode only
	pklSetHotkey( "zoomImageHotkey", "zoomHelpImage"       , "HK_ZoomHelpImg"  )
	pklSetHotkey( "moveImageHotkey", "moveHelpImage"       , "HK_MoveHelpImg"  ) 	; Hidden from menu
	pklSetHotkey( "opaqImageHotkey", "opaqHelpImage"       , "HK_OpaqHelpImg"  ) 	; Hidden from menu
	pklSetHotkey( "showAboutHotkey", "showAbout"           , "HK_ShowAbout"    ) 	; Hidden from menu
	pklSetHotkey( "epklDebugHotkey", "epklDebugWIP"        , "HK_DebugWIP"     ) 	; Hidden from menu
	
	setDeadKeysInCurrentLayout( pklIniRead( "systemsDeadkeys" ) )
	setPklInfo( "CtrlAltlIsAltGr", bool(pklIniRead("ctrlAltIsAltGr")) )
	
	activity_setTimeout( 1, pklIniRead( "suspendTimeOut", 0 ) )
	activity_setTimeout( 2, pklIniRead( "exitAppTimeOut", 0 ) )
	setPklInfo( "cleanupTimeOut", pklIniRead( "cleanupTimeOut" ) ) 		; Time idle before mods etc are cleaned up
	
	setPklInfo( "stickyMods", pklIniRead( "stickyMods" ) )				; Sticky/One-Shot modifiers (CSV)
	setPklInfo( "stickyTime", pklIniRead( "stickyTime" ) )				; --"--
	
	extMods := pklIniCSVs( "extendMods" )								; Multi-Extend w/ tap-release
	setPklInfo( "extendMod1", ( extMods[1] ) ? extMods[1] : "" )
	setPklInfo( "extendMod2", ( extMods[2] ) ? extMods[2] : "" )
	setPklInfo( "extendTaps", pklIniRead( "extendTaps" ) )				; --"--
	setPklInfo( "tapModTime", pklIniRead( "tapModTime" ) )				; Tap-or-Mod time
	
	theLays := pklIniRead( "layout", "", pklLays ) 						; Read the layouts string from EPKL_Layouts
	layType := _pklLayRead( "LayType", "eD"         ) 					; Layout type, mostly eD or VK
	kbdType := _pklLayRead( "KbdType", "ISO", "_"   ) 					; Keyboard type, _ISO/_ANS/_etc
	localID := _pklLayRead( "LocalID",      , "-"   ) 					; Locale ID, e.g., "-Pl"
	curlMod := _pklLayRead( "CurlMod"               ) 					; --, Curl, CurlM
	ergoMod := _pklLayRead( "ErgoMod"               ) 					; --, Angle, AWide...
	othrMod := _pklLayRead( "OthrMod"               ) 					; --, Other mod suffix
	theLays := StrReplace( theLays, "@V",   "@K@C@E@O" ) 				; Shorthand .ini notation for layout variants
	kbdTypU := ( curlMod || ergoMod || othrMod ) ? "_" : "" 			; Use "KbdType_Mods" iff Mods are active
	theLays := StrReplace( theLays, "@K@","@K" . kbdTypU . "@" ) 		; --"--
	theLays := StrReplace( theLays, "@T",   layType )
	theLays := StrReplace( theLays, "@L",   localID )
	theLays := StrReplace( theLays, "@K",   kbdType ) 					; (Later on, will use atKbdType() for layout files)
	theLays := StrReplace( theLays, "@C",   curlMod )
	theLays := StrReplace( theLays, "@E",   ergoMod )
	theLays := StrReplace( theLays, "@O",   othrMod )
	layouts := StrSplit( theLays, ",", " " )							; Split the CSV layout list
	numLayouts := layouts.MaxIndex()
	setLayInfo( "NumOfLayouts", numLayouts )							; Store the number of listed layouts
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
		pklMsgBox( "01", "layouts .ini" ) 								; "You must set the layout file in the EPKL layouts .ini!"
		ExitApp
	}
	setLayInfo( "ActiveLay", theLayout )
	
	nextLayoutIndex := 1												; Determine the next layout's index
	Loop % numLayouts {
		if ( theLayout == getLayInfo( "layout" . A_Index . "code") ) {
			nextLayoutIndex := A_Index + 1
			break
		}
	}
	nextLayoutIndex := ( nextLayoutIndex > numLayouts ) ? 1 : nextLayoutIndex
	setLayInfo( "NextLayout", getLayInfo( "layout" . nextLayoutIndex . "code" ) )
}	; end fn initPklIni()

  													;   ###############################################################
initLayIni() 										;   ######################### layout.ini  #########################
{ 													;   ###############################################################
	static initialized  := false
	
	theLayout := getLayInfo( "ActiveLay" )
	layDir  := bool(pklIniRead("compactMode")) ? "." 
			 : layDir := "Layouts\" . theLayout 						; If in compact mode, use main dir as layDir
	mainLay := layDir . "\" . getPklInfo( "LayFileName" )				; The name of the main layout .ini file
	setLayInfo( "Dir_LayIni"        , layDir  )
	setPklInfo( "File_LayIni"       , mainLay )							; The main layout file path
	kbdType := pklIniRead( "KbdType", getLayInfo("Ini_KbdType") ,"LayIni" ) 	; eD WIP: BaseLayout is unified for KbdType, so this isn't necessary now?
	setLayInfo( "Ini_KbdType", kbdType ) 								; A KbdType setting in layout.ini overrides the first Layout_ setting
	basePath        := pklIniRead( "baseLayout",, "LayIni" ) 			; Read a base layout then augment/replace it
	basePath        := atKbdType( basePath ) 							; Replace '@K' w/ KbdType 	; eD WIP: Unnecessary w/ unified BaseLayout?
	SplitPath, basePath, baseLay, baseDir
	baseDir         := "Layouts\" . baseDir
	baseLay         := "Layouts\" . basePath . ".ini"
	if FileExist( baseLay ) {
		setLayInfo( "Dir_BasIni"    , baseDir )
		setPklInfo( "File_BasIni"   , baseLay ) 						; The base layout file path
	} else if ( basePath ) {
		setLayInfo( "Dir_BasIni"    , "" )
		setPklInfo( "File_BasIni"   , "" )
		pklWarning( "File '" . baseLay . "' not found!" ) 				; "File not found" iff base is defined but not present
	}
	pklLays := getPklInfo( "Arr_PklLay" )
	pklLays := [ mainLay, baseLay, pklLays[1], pklLays[2] ] 			; Could also concatenate w/, e.g., pklStck.push( pklLays* )
	pklDirs := [ layDir , baseDir, "."       , "."        ]
	layStck := [] 														; The LayStack is the stack of layout info files
	dirStck := []
	For ix, file in pklLays
	{
		if FileExist( file ) { 											; If the file exists...
			layStck.push( file ) 										; ...add it to the LayStack
			dirStck.push( pklDirs[ix] )
		}
	}	; end For
	setPklInfo( "LayStack", layStck ) 									; Layout.ini, BaseLayout.ini, Layouts_Override, Layouts_Default
	setPklInfo( "DirStack", dirStck )
	
	mapFile := pklIniRead( "remapsFile",, "LayStk" ) 					; Layout remapping for ergo mods, ANSI/ISO conversion etc.
	if ( not initialized ) && ( FileExist( mapFile ) ) 					; Ensure the tables are read only once
	{																	; Read/set remap dictionaries
		mapTypes    := "  scMapLay     ,  scMapExt     ,  vkMapMec    "
		mapSects    := [ "mapSC_layout", "mapSC_extend", "mapVK_mecSym" ]	; Section names in the .ini file
		Loop, Parse, mapTypes, CSV, %A_Space%%A_Tab%
		{
			mapType := A_LoopField
			mapList := pklIniRead( mapSects[ A_Index ],, "LayStk" ) 	; First, get the name of the map list
			mapList := atKbdType( mapList ) 							; Replace '@K' w/ KbdType
			%mapType% := ReadRemaps( mapList,            mapFile ) 		; Parse the map list into a list of base cycles
			%mapType% := ReadCycles( mapType, %mapType%, mapFile ) 		; Parse the cycle list into a pdic of mappings
		}
		mapVK   := ReadRemaps( "ANS2ISO",         mapFile ) 			; Map between ANSI (default in the Remap file) and ISO mappings
		mapVK   := ReadCycles( "vkMapMec", mapVK, mapFile ) 			; --"--
		SCVKdic := ReadKeyLayMapPDic( "SC", "VK", mapFile )				; Make a code dictionary for SC-2-VK mapping below
		QWVKdic := ReadKeyLayMapPDic( "QW", "VK", mapFile )				; Make a code dictionary for QW-2-VK mapping below (Co is unintuitive since KLM VK names are QW based?) 	; eD WIP: Maybe use QW-2-SC then SC-2-VK to save on number of dics? Need QWSC or CoSC too, later on.
;		CoSCdic := ReadKeyLayMapPDic( "Co", "SC", mapFile )				; Make a code dictionary Co2SC mapping below 	; eD WIP. Make these only on demand, allowing for other codes than Co?
		initialized := true
	}
	
	kbdType := pklIniRead( "KbdType", kbdType,"LayStk" ) 				; This time, look for a KbdType down the whole LayStack
	setLayInfo( "Ini_KbdType", kbdType ) 								; A KbdType setting in layout.ini overrides the first Layout_ setting
	shStates := pklIniRead( "shiftStates", "0:1"   , "LayStk", "global" ) 	; .= ":8:9" ; SgCap should be declared explicitly
	shStates := pklIniRead( "shiftStates", shStates, "LayStk", "layout" ) 	; This was in [global] then [pkl]
	shStates := RegExReplace( shStates, "[ `t]+" ) 						; Remove any whitespace
	setLayInfo( "LayHasAltGr", InStr( shStates, 6 ) ? 1 : 0 )
	setLayInfo( "shiftStates", shStates ) 								; Used by the Help Image Generator
	shiftState := StrSplit( shStates, ":" )
	
	For ix, layFile in layStck 											; Loop parsing all the LayStack layout files
	{
	map := iniReadSection( layFile, "layout" )
	extKey := pklIniRead( "extend_key","", layFile ) 					; Extend was in layout.ini [global]. Can map it directly now.
	( extKey ) ? map .= "`r`n" . extKey . " = Extend Modifier" 			; Define the Extend key. Lifts earlier req of a layout entry.
	Loop, Parse, map, `r`n 												; Loop parsing the layout 'key = entries' lines
	{ 
		pklIniKeyVal( A_LoopField, key, entries, 0, 0 )	; Key SC and entries. No comment stripping here to avoid nuking the semicolon!
		if ( key == "<NoKey>" ) || ( key == "shiftStates" ) 			; This could be mapped, but usually it's from pklIniKeyVal()
			Continue
		key     := scMapLay[ key ] ? scMapLay[ key ] : key 				; If there is a SC remapping, apply it 	; eD WIP: Also handle SC aliases like Co_TAB
		if ( getKeyInfo( key . "isSet" ) == "KeyIsSet" ) 				; If a key is at all defined, mark it as set
			Continue
		setKeyInfo( key . "isSet", "KeyIsSet" ) 						; Skip marked keys for the rest of the LayStack
		entries := RegExReplace( entries, "[ `t]+", "`t" ) 				; Turn any consecutive whitespace into single tabs, so...
		entry   := StrSplit( entries, "`t" ) 							; The Tab delimiter and no padding requirements are lifted
		numEntr := ( entry.MaxIndex() < 2 + shiftState.MaxIndex() ) 
			? entry.MaxIndex() : 2 + shiftState.MaxIndex() 				; Comments make pseudo-entries, so truncate them
		entry1  := ( numEntr > 0 ) ? entry[1] : ""
		entry2  := ( numEntr > 1 ) ? entry[2] : ""
		if ( InStr( entry1, "/" ) ) { 									; Check for Tap-or-Modifier keys (ToM):
			tomEnts := StrSplit( entry1, "/" ) 							;   Their VK entry is of the form 'VK/ModName'.
			entry1  := tomEnts[1]
			tapMod  := _checkModName( tomEnts[2] )
			extKey  := ( loCase( tapMod ) == "extend" ) ? key : extKey 	; Mark this key as the Extend key (for ExtendIsPressed)
			setKeyInfo( key . "ToM", tapMod )
		} else {
			tapMod  := ""
		}
		vkStr := "i)^(virtualkey|vk|vkey|-1)$" 							; RegEx needle for VKey entries, ignoring case. Allow -1 or not?
		if RegExMatch( entry1, vkStr) { 								; If the first entry is a VKey synonym, VK map the key to itself
			numEntr   := 2
			entry1    := "VK" . getVKeyCodeFromName( SCVKdic[key] ) 	; Find the right VK code for the key's SC, from the Remap file
			entry2    := "VKey" 										; Note: This is the QWERTY mapping of that SC###.
		}
		if ( numEntr < 2 ) || ( entry1 == "--" ) { 						; An empty or one-entry key mapping will deactivate the key
			Hotkey, *%key%   ,  doNothing 								; The *SC### format maps the key regardless of modifiers.
			Hotkey, *%key% Up,  doNothing 								; eD WIP: Does a key Up doNothing help to unset better?
			Continue 													; eD WIP: Is this working though? With base vs layout?
		}
		if ( InStr( "modifier", loCase(entry2) ) == 1 ) { 				; Entry 2 is either the Cap state (0-5), 'VK' or 'Modifier'
			entry1    := _checkModName( entry1 ) 						; Modifiers are stored as their AHK or special names
			extKey    := ( entry1 == "Extend" ) ? key : extKey 			; Directly mapped 'key = Extend Modifier'
			setKeyInfo( key . "vkey", entry1 ) 							; Set VK as modifier name, e.g., "RShift", "AltGr" or "Extend"
			entry2  := -2 												; -2 = Modifier
		} else {
			KLM := RegExMatch( entry1, "i)^(QW)" ) ? SubStr( entry1, 1, 2 ) : false 	; Co/QW KLM remappings of VK codes 	; eD WIP: |Co
			entry1  := ( KLM ) ? %KLM%VKdic[ SubStr( entry1, 3 ) ] : entry1 	; Use CoVK (Colemak) and QWVK (QWERTY) dictionaries
			vkcode := getVKeyCodeFromName( entry1 ) 					; Translate to the two-digit VK## hex code (Uppercase)
			vkcode  := KLM && ( kbdType == "ISO" ) && mapVK[vkcode] 	; If necessary, convert ANSI-to-ISO
					? mapVK[ vkcode ] : vkcode
			vkcode := vkMapMec[vkcode] ? vkMapMec[vkcode] : vkcode 		; Remap the VKey here before assignment, if applicable.
			setKeyInfo( key . "vkey", vkcode ) 							; Set VK code (hex ##) for the key
			entry2  := RegExMatch( entry2, vkStr ) ? -1 : entry2 		; -1 = VKey internally
;			( key == "SC01A" ) ? pklDebug( "`nSC01A codes:`n" . entry1 . " / VK" . vkcode . "`n" )  ; eD DEBUG
		}
		setKeyInfo( key . "capSt", entry2 ) 							; Set Caps state (0-5 for states; -1 VK; -2 Mod)
		if ( tapMod ) { 												; Tap-or-Modifier
			Hotkey, *%key%   ,  tapOrModDown
			Hotkey, *%key% Up,  tapOrModUp
		} else if ( entry2 == -2 ) {									; Set modifier keys, including Extend
			Hotkey, *%key%   ,  modifierDown
			Hotkey, *%key% Up,  modifierUp
		} else {
			Hotkey, *%key%,     keyPressed 								; Set normal keys
			Hotkey, *%key% Up,  doNothing 	 							; eD WIP: Only Down needed? - EPKL sends a lot of Down-Up presses. But if the key is redefined?
		}	; end if entries
		Loop % numEntr - 2 { 											; Loop through all entries for the key, starting at #3
			ks  := shiftState[ A_Index ]								; This shift state for this key
			ksE := entry[ A_Index + 2 ]									; The value/entry for that state
			if        ( StrLen( ksE ) == 0 ) {							; Empty entry; ignore
				Continue
			} else if ( StrLen( ksE ) == 1 ) {							; Single character entry:
;				setKeyInfo( key . ks . "s", "+" ) 						; eD WIP: Mark set states as '+' and empty as '-', to read the LayStack top-down? No, mark the keys.
				setKeyInfo( key . ks , Ord(ksE) )						; Convert to ASCII/Unicode ordinal number; was Asc()
			} else if ( ksE == "--" ) || ( ksE == -1 ) { 				; --: Disabled state entry (MSKLC uses -1)
				setKeyInfo( key . ks      , "" ) 						; "key<state>" empty
			} else if RegExMatch( ksE, "i).*(space|spc).*" ) { 			; Spc: Special space entry; can also use &Spc, ={Space}...
				setKeyInfo( key . ks , 32 ) 							; The ASCII/Unicode ordinal number for Space; lets a space release DKs
			} else {
				ksP := SubStr( ksE, 1, 1 )								; Multi-character entries may have a prefix
				if InStr( "→§αβ«Ð¶%$*=~@&", ksP ) {
					ksE := SubStr( ksE, 2 ) 							; = : Send {Blind} - use current mod state
				} else {												; * : Omit {Raw}; use special !+^#{} AHK syntax
					ksP := "%"											; %$: Literal/ligature (Unicode/ASCII allowed)
				}														; @&: Dead keys and named literals/strings
				setKeyInfo( key . ks      , ksP )						; "key<state>"  is the entry prefix
				setKeyInfo( key . ks . "s", ksE )						; "key<state>s" is the entry itself
			}
		}	; end loop entries
	}	; end loop (parse keymap)
	if ( extKey ) && ( ! getLayInfo("ExtendKey") ) { 					; Found an Extend key, and it wasn't already set higher in the LayStack
		setLayInfo( "ExtendKey", extKey ) 								; The extendKey LayInfo is used by ExtendIsPressed
	}
	}	; end loop (parse layoutFiles)
	
  													;   ###############################################################
;initOtherInfo() 									;   ####################### other settings  #######################
  													;   ###############################################################
	
	;;  -----------------------------------------------------------------------------------------------
	;;  Read and set Extend mappings and help image info
	;
	if getLayInfo( "ExtendKey" ) { 										; If there is an Extend key, set the Extend mappings.
;		extFile  := fileOrAlt( pklIniRead( "extendFile",, "LayStk" )
;								, getPklInfo( "File_PklSet" ) )			; Default Extend file: pkl.ini 	; eD WIP: Deprecate - keep Ext info in the LayStack
		extFile := pklIniRead( "extendFile",, "LayStk" )
		extStck := layStck
		if FileExist( extFile )
			extStck.push( extFile ) 										; The LayStack overrides the dedicated file
		hardLayers  := strSplit( pklIniRead( "extHardLayers", "1/1/1/1", extStck ), "/", " " ) 	; Array of hard layers
		For ix, thisFile in extStck 									; Go through the LayStack then the ExtendFile. eD WIP: Turn around the sequence and check for existing mappings, consistent with LayStack?!
		{																; Parse the Extend files
			Loop % 4 {													; Loop the multi-Extend layers
				extN := A_Index
				thisSect := pklIniRead( "ext" . extN ,, "LayStk" ) 		; ext1/ext2/ext3/ext4
;				thisSect := ( thisFile == getPklInfo( "File_PklSet" ) ) ? "extend" : thisSect
				map := iniReadSection( thisFile, thisSect )
				if ( not map ) 											; If this map layer is empty, go on
					Continue
				Loop, Parse, map, `r`n
				{
					pklIniKeyVal( A_LoopField , key, extMapping )		; Read the Extend mapping for this SC
					key := upCase( key )
					if ( hardLayers[ extN ] ) {
						key := scMapExt[ key ] ? scMapExt[ key ] : key 	; If applicable, hard remap entry
					} else {
						key := scMapLay[ key ] ? scMapLay[ key ] : key 	; If applicable, soft remap entry
					}
					if ( getKeyInfo( key . "ext" . extN ) != "" ) 		; Skip mapping if already defined
						Continue
					setKeyInfo( key . "ext" . extN , extMapping )
				}	; end loop (parse extMappings)
			}	; end loop ext#
		}	; end loop (parse extStck)
		setPklInfo( "extReturnTo", pklIniRead( "extReturnTo", "1/2/3/4", extStck ) ) 	; ReturnTo layers
		Loop % 4 {
			setLayInfo( "extImg" . A_Index								; Extend images
				  , fileOrAlt( pklIniRead( "img_Extend" . A_Index ,, "LayStk" ), layDir . "\extend.png" ) )
		}	; end loop ext#
	}	; end if ( extendKey )
	
	;;  -----------------------------------------------------------------------------------------------
	;;  Read and set the deadkey name list and help image info, and the string table file
	;;
	;;  - NOTE: Any file in the LayStack may contain named DK sections with extra or overriding DK mappings.
	;;  - A -- or -1 entry in a overriding LayStack file disables any corresponding entry in the base DK file.
	;
	Loop % 32 {															; Start with the default dead key table
		key := "@" . Format( "{:02}", A_Index ) 						; Pad with zero if index < 10
		ky2 := "@" .                  A_Index   						; e.g., "dk1" or "dk14"
		val := "deadkey" . A_Index
		setKeyInfo( key, val )											; "dk01" = "deadkey1"
		if ( ky2 != key )												; ... and also, ...
			setKeyInfo( ky2, val )										; "dk1" = "deadkey1", backwards compatible
	}
	dknames := "deadKeyNames"											; The .ini section that holds dk names
	dkFile  := pklIniRead( "dkListFile",, "LayStk" )
	dkStack := layStck
	if FileExist( dkFile )
		dkStack.push( dkFile ) 											; The LayStack overrides the dedicated file
	setLayInfo( "dkFile", dkStack )										; These files should contain the actual dk tables
	For ix, thisFile in dkStack											; Go through both DK and Layout files for names
	{
		map   := iniReadSection( thisFile, dknames ) 					; Make the dead key name lookup table
		Loop, Parse, map, `r`n
		{
			pklIniKeyVal( A_LoopField, key, val )
			if ( val )
				setKeyInfo( key, val )									; e.g., "dk01" = "dk_dotbelow"
		}
	}
	dkImDir := fileOrAlt( pklIniRead( "img_DKeyDir", ".\DeadkeyImg" 	; Read/set DK image data
									, "LayStk" ), layDir ) 				; Default DK img dir: Layout dir or DeadkeyImg
	setLayInfo( "dkImgDir", dkImDir )
	HIGfile := pklIniRead( "imgGenIniFile" )							; DK img state suffix was in LayIni
	setLayInfo( "dkImgSuf", pklIniRead( "img_DKStateSuf", "", HIGfile ) )	; DK img state suffix. Defaults to old ""/"sh".
	
	strFile  := fileOrAlt( pklIniRead( "stringFile",, "LayStk" )
						, mainLay )										; Default literals/powerstring file: layout.ini
	setLayInfo( "strFile", strFile )									; This file should contain the string tables 	; eD WIP: Allow the whole LayStack instead?
	
	;;  -----------------------------------------------------------------------------------------------
	;;  Read and set layout on/off icons and the tray menu
	;
	ico := readLayoutIcons( "LayStk" )
	setLayInfo( "Ico_On_File", ico.Fil1 )
	setLayInfo( "Ico_On_Num_", ico.Num1 )
	setLayInfo( "Ico_OffFile", ico.Fil2 )
	setLayInfo( "Ico_OffNum_", ico.Num2 )
	pkl_set_tray_menu()
}	; end fn initLayIni()

activatePKL() 										; Activate EPKL single-instance, with a tray icon etc
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
	
	pkl_showHelpImage( 1 ) 							; Initialize/show the help mage...
	Sleep, 10 										; The image flashes on startup if this is long
	if ! bool(pklIniRead("showHelpImage",true))
		pkl_showHelpImage( 2 ) 						; ...then toggle it off if necessary

	Sleep, 200 										; I don't want to kill myself...
	OnMessage( 0x398, "_MessageFromNewInstance" )
	
	activity_ping(1) 								; Update the current ping time
	activity_ping(2)
	SetTimer, activityTimer, 20000 					; Check for timeouts every 20 s 	; eD WIP: Put this into cleanup?!
	SetTimer, pklJanitorTic,  2000 					; Perform cleanup routine every 2 s
	
	if bool(pklIniRead("startSuspended")) {
		Suspend
		gosub afterSuspend
	}
}	; end fn

changeLayout( nextLayout ) 							; Rerun EPKL with a specified layout
{
	Menu, Tray, Icon,,, 1 							; Freeze the tray icon
	Suspend, On
	
	if ( A_IsCompiled )
		Run %A_ScriptName% /f %nextLayout%
	else
		Run %A_AhkPath% /f %A_ScriptName% %nextLayout%
}

_pklLayRead( type, def = "<N/A>", prefix = "" )		; Read kbd type/mods (used in pkl_init) and set Lay info
{
	pklLays := getPklInfo( "Arr_PklLay" )
	val := pklIniRead( type, def, pklLays ) 		; Read from the EPKL_Layouts .ini file(s)
	setLayInfo( "Ini_" . type, val )				; Stores KbdType etc for use with other parts
	val := ( val == "--" ) ? "" : prefix . val		; Replace -- with nothing, otherwise use prefix
	val := ( InStr( val, "<", 0 ) ) ? false : val 	; If the value is <N/A> or similar, return boolean false
	Return val
}

_checkModName( key ) 								; Mod keys need only the first letters of their name
{
	static modNames := [ "LShift", "RShift", "CapsLock", "Extend", "SGCaps"
						, "LCtrl", "RCtrl", "LAlt", "RAlt", "LWin", "RWin" ]
	
	For ix, modName in modNames
	{
		if ( InStr( modName, key, 0 ) == 1 ) 		; Case insensitive match: Does modName start with key?
			key := modName
	}
	if ( getLayInfo( "LayHasAltGr" ) && key == "RAlt" ) {
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
