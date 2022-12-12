;; ================================================================================================
;;  EPKL initialization
;;  - Load 1) general settings and layout choice, 2) the layout itself, 3) other stuff.
;

													;   ###############################################################
initPklIni( layoutFromCommandLine ) {   			;   ######################## EPKL Settings ########################
													;   ###############################################################
	
	;; ================================================================================================
	;;  Before we start... Initialize former globals, now included in the get/set info framework:
	;
	setPklInfo( "File_PklSet", "EPKL_Settings"          ) 				; Used globally (used to be in pkl.ini)
	setPklInfo( "File_PklLay", "EPKL_Layouts"           ) 				; --"--
	setPklInfo( "LayFileName", "layout.ini"             ) 				; --"--
	setPklInfo( "File_PklDic", "Files\EPKL_Tables.ini"  ) 				; Info dictionary file, mostly from internal tables
	;setKeyInfo( "HotKeyBufDn", 0 ) 									; Hotkey buffer for pkl_keypress (was 'HotkeysBuffer')
	resetDeadKeys() 													; Resetting the DKs initializes them - necessary for function
	setPklInfo( "osmMax", 3 )   										; Allow this many concurrent OneShot Modifiers (OSM)
	setPklInfo( "osmN", 1 )  											; OSM number counter
	
	;; ================================================================================================
	;;  Find and read from the Settings file(s)
	;
	setFile := getPklInfo( "File_PklSet" ) 								; The default file name will still be available.
	setStck := []
	For ix, type in [ "", "_Override", "_Default" ] {
		file := setFile . type . ".ini"
		if FileExist( file ) 											; If the file exists...
			setStck.push( file ) 										; ...add it to the SetStack
	}	; end For type
	if ( setStck.Length() == 0 ) {
		MsgBox, %setFile% file NOT FOUND.`nEPKL cannot run without this file.`n`n• EPKL.exe must be run inside its home folder.`n• This folder must be uncompressed/extracted.
		ExitApp
	}
	setPklInfo( "SetStack", setStck ) 									; Settings_Override, Settings_Default
	setPklInfo( "AdvancedMode", bool(pklIniRead("advancedMode")) ) 		; Extra debug info etc
	pklLays := getPklInfo( "File_PklLay" ) 								; EPKL_Layouts
	pklLays := [ pklLays . "_Override.ini", pklLays . "_Default.ini" ] 	; Now an array of override and default
	setPklInfo( "Arr_PklLay", pklLays )
	
	lang := pklIniRead( "menuLanguage", "auto" ) 						; Load locale strings
	if ( lang == "auto" )
		lang := pklIniRead( SubStr( A_Language , -3 ), "", "PklDic", "LangStrFromLangID" )
	pkl_locale_load( lang )
	
	;;  Legend: (  hkIniName       ,  gotoLabel            ,  pklInfoTag       ) 	; Set a (menu) hotkey
	pklSetHotkey( "helpImageHotkey", "toggleHelpImage"     , "HK_ShowHelpImg"  ) 	; 1
	pklSetHotkey( "changeLayHotkey", "rerunNextLayout"     , "HK_ChangeLayout" ) 	; 2
	pklSetHotkey( "suspendMeHotkey", "toggleSuspend"       , "HK_Suspend"      ) 	; 3/` - 3 didn't work well?
	pklSetHotkey( "exitMeNowHotkey", "exitPKL"             , "HK_ExitApp"      ) 	; 4
	pklSetHotkey( "refreshMeHotkey", "rerunSameLayout"     , "HK_Refresh"      ) 	; 5
	pklSetHotkey( "settingUIHotkey", "changeSettings"      , "HK_SettingsUI"   ) 	; 6
	pklSetHotkey( "zoomImageHotkey", "zoomHelpImage"       , "HK_ZoomHelpImg"  ) 	; 7
	pklSetHotkey( "opaqImageHotkey", "opaqHelpImage"       , "HK_OpaqHelpImg"  ) 	; 8 - Hidden from menu
	pklSetHotkey( "moveImageHotkey", "moveHelpImage"       , "HK_MoveHelpImg"  ) 	; 9 - Hidden from menu 	; eD WIP: Use this for something better?
	pklSetHotkey( "procStatsHotkey", "getWinInfo"          , "HK_AhkWinInfo"   ) 	; 0 - Hidden from menu
	pklSetHotkey( "epklDebugHotkey", "epklDebugUtil"       , "HK_DebugUtil"    ) 	; = - Hidden from menu
	#MaxThreadsBuffer       Off 										; Turn on hotkey buffering for subsequent hotkeys (key presses)
	
	setCurrentWinLayDeadKeys( pklIniRead( "systemDeadKeys" ) )  		; eD WIP: Better DK detection fn!
	setKeyInfo( "CtrlAltIsAltGr", bool(pklIniRead("ctrlAltIsAltGr")) )
	
	_pklSetInf( "cleanupTimeOut" )  									; Time idle (sec) before mods etc are cleaned up
	_pklSetInf( "suspendTimeOut" )  									; Time idle (min) before program suspends itself
	_pklSetInf( "exitAppTimeOut" )  									; Time idle (min) before program exits itself
	For ix,suspApp in pklIniCSVs( "suspendingApps" ) { 					; Programs that suspend EPKL when active
		if ( suspApp == "--" )
			Break
		shorthand := { "C " : "ahk_class " , "X " : "ahk_exe " , "T " : "" }
		For needle, newtxt in shorthand 								; C/X/[T] matches by window Class/Exe/Title
			suspApp := RegExReplace( suspApp, "^" . needle, newtxt )
		GroupAdd, SuspendingApps, %suspApp% 							;     Used by pklJanitor
	}	; end For suspApp
	_pklSetInf( "suspendingLIDs" ) 										; Layouts that suspend EPKL when active (actually CSV, but it's okay)
	
	_pklSetInf( "stickyMods" ) 											; Sticky/One-Shot modifiers (actually CSV, but store it as a string)
	_pklSetInf( "stickyTime" ) 											; --"--
	
	extMods := pklIniCSVs( "extendMods" )								; Multi-Extend w/ tap-release
	setPklInfo( "extendMod1", ( extMods[1] ) ? extMods[1] : "" )
	setPklInfo( "extendMod2", ( extMods[2] ) ? extMods[2] : "" )
	_pklSetInf( "extendTaps" )  										; --"--
	_pklSetInf( "tapModTime" )  										; Tap-or-Mod time
;	setPklInfo( "unicodeVKs", bool(pklIniRead("unicodeVKs")) )  		; Whether to Compose w/ ToUnicode for VK/SC mappings: It has a side effect ruining OS DKs.  	; eD FIXED
	
	;; ================================================================================================
	;;  Find and read from the EPKL_Layouts file(s)
	;
	shortLays   := pklIniCSVs( "shortLays", "Colemak/Cmk", "PklDic" )
	shortLayDic := {}   												; CSV list of main layout name abbreviations
	For ix, entr in shortLays { 										;     (Default: First 3 letters)
		split := StrSplit( entr, "/" )
		if ( split.Length() != 2 )
			Continue
		shortLayDic[ split[1] ] := split[2]
	}
	setPklInfo( "shortLays", shortLayDic )
	
	theLays :=  pklIniRead( "layout", "", pklLays ) 					; Read the layouts string from EPKL_Layouts. May contain @# shorthand.
	layMain := _pklLayRead( "LayMain", "Colemak" )  					; Main Layout: Colemak, Tarmak, Dvorak etc.; now the same as LayName
	if InStr( layMain, "/" ) { 											; The LayMain may be on the form 'LayName/3LA' already...
		split   := StrSplit( layMain, "/" )
		layMain := split[1]
		lay3LA  := split[2]
	} else { 															; ...or not, in which case we look up or generate the 3LA.
		lay3LA  := shortLayDic[ layMain ]   	; Was layName
		lay3LA  := ( lay3LA ) ? lay3LA : SubStr( layMain, 1, 3 )    	; If not specified in shortLayDic, the 3LA is the first 3 letters.
	}
	layPath := _pklLayRead( "LayPath", "@L\@3-@T@V" )   				; Path to layout folders: @L\<subfolder>. Simple layouts just have `@L`.
;	split   := StrSplit( layMain, "\" ), layName := split[1]    		; LayMain can also contain a subfolder.
	layType := _pklLayRead( "LayType", "eD"         )   				; Layout type, mostly eD or VK
	layVari := _pklLayRead( "LayVari",      , "-"   ) 					; Locale ID, e.g., "-Pl", or other variant such as Tarmak steps
	polyLID := {}
	For ix, LVars in pklIniCSVs( "multiLocs",, "pklDic" ) { 			; For layouts with compound Locale IDs, any component can be used alone
		harmLID := StrReplace( LVars, "/" ) 							; The Harmonized Locale ID is a compound of its components, like BeCaFr
		For ix, var in StrSplit( LVars, "/" ) { 						; The Tables file entry is a CSV list of slash-separated variants
			polyLID["-" . var] := "-" . harmLID 						; Example: Both "-Dk" and "-No" point to the "-DkNo" layout
		}	; end For LVar
	}	; end For LVars
	localID := ( polyLID[layVari] ) ? polyLID[layVari] : layVari 		;   (can be a single locale of a harmonized layout like BeCaFr)
	kbdType := _pklLayRead( "KbdType", "ISO"        ) 					; Keyboard type, ISO/ANS(I)/etc
	curlMod := _pklLayRead( "CurlMod"               ) 					; --, Curl/DH mod
	hardMod := _pklLayRead( "HardMod"               ) 					; --, Hard mod - Angle, AWide...
	othrMod := _pklLayRead( "OthrMod"               ) 					; --, Other mod suffix like Sym
	
	theLays := StrReplace( theLays, "@Ʃ",   "@P-@T@V"  ) 				; Shorthand .ini notation for main layout path, type and variant
	theLays := StrReplace( theLays, "@Ç",   "@K@C@H@O" ) 				; Shorthand .ini notation for KbdType[_]ErgoMods; not in use?
	theLays := StrReplace( theLays, "@E",     "@C@H@O" ) 				; Shorthand .ini notation for the full ergomods battery
	theLays := StrReplace( theLays, "@P",   layPath "\@3" ) 			; Replaces @P w/ LayPath\3LA in layout paths, as in 'Colemak\Cmk'
	theLays := StrReplace( theLays, "@L",   layMain    ) 				; Replaces @L w/ LayName
	theLays := StrReplace( theLays, "@3",   lay3LA     )
	theLays := StrReplace( theLays, "@T",   layType    )
	theLays := StrReplace( theLays, "@V",   localID    ) 				; NOTE: Any one locale in a compound locale (like BrPt) can be used alone.
	kbdTypJ := ( curlMod || hardMod || othrMod ) ? "_" : "" 			; Use "KbdType_Mods" with a joiner character iff any ergoMods are active
	theLays := StrReplace( theLays, "@K@","@K" kbdTypJ "@" ) 			; --"--
	theLays := StrReplace( theLays, "@K",   kbdType    ) 				; Later on, EPKL will use atKbdType() for layout files instead of this one 	; . "_"
	theLays := StrReplace( theLays, "@C",   curlMod    )
	theLays := StrReplace( theLays, "@H",   hardMod    )
	theLays := StrReplace( theLays, "@O",   othrMod    )
	layouts := StrSplit( theLays, ",", " `t" )  						; Split the CSV layout list
	numLayouts := layouts.Length()
	setLayInfo( "NumOfLayouts", numLayouts ) 							; Store the number of listed layouts
	For ix, thisLay in layouts { 										; Store the layout dir names and menu names
;		kbdTypJ := ( curlMod || hardMod || othrMod ) ? "_" : ""
;		needle  := kbdType .           curlMod . hardMod . othrMod 		; Use "KbdType_Mods" with a joiner character iff any ergoMods are active
;		newtxt  := kbdType . kbdTypJ . curlMod . hardMod . othrMod
;		thisLay := RegExReplace( thisLay, needle, newtxt )
		nameParts := StrSplit( thisLay, ":" )
		theCode := nameParts[1]
		theCode := RegExReplace( theCode, "_$"       )  				; If the layout code ends with the KbdType, the trailing underscore is omitted
		theCode := RegExReplace( theCode, "_\\", "\" )  				; The trailing underscore may also figure in subpaths
		if ( not theCode ) { 											; Empty entries cause an error, but any other layouts still work
			theCode := "<N/A>"
			pklWarning( "At least one layout entry is empty" )
		}
		theName := ( nameParts.Length() > 1 ) ? nameParts[2] : theCode
		setLayInfo( "layout" . A_Index . "code", theCode )
		setLayInfo( "layout" . A_Index . "name", theName )
	} 	; end for thisLay
	
	if ( layoutFromCommandLine ) {										; The cmd line layout could be not in theLays?
		thisLay   := layoutFromCommandLine
		if ( SubStr( thisLay, 1, 10 ) == "UseLayPos_" ) {				; Use layout # in list instead of full path
			thePos      := SubStr( thisLay, 11 )
			thePos      := ( thePos > numLayouts ) ? 1 : thePos
			thisLay   := getLayInfo( "layout" . thePos . "code" )
		}
	} else {
		thisLay := getLayInfo( "layout1code" )
	}
	if ( thisLay == "" ) {
		pklMsgBox( "01", "layouts .ini" ) 								; "You must set a layout file in the EPKL_Layouts .ini!"
		ExitApp
	}
	setLayInfo( "ActiveLay", thisLay )
	
	nextLayoutIndex := 1												; Determine the next layout's index
	Loop % numLayouts {
		if ( thisLay == getLayInfo( "layout" . A_Index . "code") ) {
			nextLayoutIndex := A_Index + 1
			break
		}
	}
	nextLayoutIndex := ( nextLayoutIndex > numLayouts ) ? 1 : nextLayoutIndex
	setLayInfo( "NextLayout", getLayInfo( "layout" . nextLayoutIndex . "code" ) )
}	; end fn initPklIni()

													;   ###############################################################
initLayIni() {  									;   ######################### layout.ini  #########################
													;   ###############################################################
	
	;; ================================================================================================
	;;  Find and read from the layout.ini file and, if applicable, BaseLayout/LayStack
	;
	static initialized  := false
	
	laysDir := "Layouts\"
	thisLay := getLayInfo( "ActiveLay" ) 								; From initPklIni(). For example, Colemak\Cmk-eD\Cmk-eD_ANS.
	layType := getLayStrInfo( thisLay )[4]  							; Returns layName as [1], L3A as [2] and L3A-from-string as [3]
	st2VK   := InStr( layType, "2VK" ) ? true : false   				; ##2VK layType: The (eD) BaseLayout is read as VK, layout.ini as usual.
	layType := st2VK ? SubStr(layType,1,-3) : layType   				; Make layType reflect actual layType, and set St2VK as necessary.
	thisLay := StrReplace( thisLay, layType . "2VK", layType )
	setLayInfo( "St2VK", st2VK )    									; This is tested for each layFile below
	mainDir := bool( pklIniRead("compactMode") ) ? "." 
			 : laysDir . thisLay 										; If in compact mode, use the EPKL root dir as mainDir
	mainLay := mainDir . "\" . getPklInfo( "LayFileName" )  			; The path of the main layout .ini file
	setPklInfo( "Dir_LayIni"        , mainDir )
	setPklInfo( "File_LayIni"       , mainLay )
;	kbdType := pklIniRead( "KbdType", getLayInfo("Ini_KbdType") ,"LayIni" ) 	; eD WIP: BaseLayout is unified for KbdType, so this isn't necessary now?!
;	setLayInfo( "Ini_KbdType", _AnsiAns( kbdType ) ) 					; A KbdType setting in layout.ini overrides the first Layout_ setting
;	basePath        := pklIniRead( "baseLayout",, "LayIni" ) 			; Read a base layout then augment/replace it
;	basePath        := atKbdType( basePath ) 							; Replace '@K' w/ KbdType 	; eD WIP: Unnecessary w/ unified BaseLayout
	IniRead, basePath, %mainLay%, % "pkl", % "baseLayout", %A_Space% 	; Read the base layout. Note that pklIniRead() adds .\ to ..\ so we don't use it here.
	basePath        := StrCom( basePath )   							; Strip comments, like in pklIniRead()
	SplitPath, basePath, baseLay, baseDir   							; eD WIP: Manage to use pklIniRead() for this?! It should handle ..\ too.
	useDots         := ( InStr( basePath, "..\" ) == 1 ) ? true : false
	baseDir         := ( useDots ) ? mainDir . "\.."         : laysDir . baseDir
	baseLay         := ( useDots ) ? baseDir . "\" . baseLay : laysDir . basePath
	baseLay         .= ".ini"
;	pklDebug( "basePath: " . basePath . "`nbaseDir: " . baseDir . "`nbaseLay:    " . baseLay . "`n`nmainDir: " . mainDir . "`nmainLay:    " . mainLay, 30 )  ; eD DEBUG
	if FileExist( baseLay ) {
		setPklInfo( "Dir_BasIni"    , baseDir )
		setPklInfo( "File_BasIni"   , baseLay ) 						; The base layout file path
	} else if ( basePath ) {
		setPklInfo( "Dir_BasIni"    , "" )
		setPklInfo( "File_BasIni"   , "" )
		pklWarning( "File '" . baseLay . "' not found!" )   			; "File not found" iff base is defined but not present
	}
	pklLays := getPklInfo( "Arr_PklLay" )
	pklLays := [ mainLay, baseLay, pklLays[1], pklLays[2] ] 			; Could also concatenate w/, e.g., pklStck.push( pklLays* )
	pklDirs := [ mainDir, baseDir, "."       , "."        ]
	layStck := []   													; The LayStack is the stack of layout info files
	dirStck := []   													; eD WIP: Allow a BaseStack, where any BaseLayout can include others? SubBase?
	For ix, file in pklLays {
		if FileExist( file ) {  										; If the file exists...
			layStck.push( file ) 										; ...add it to the LayStack
			dirStck.push( pklDirs[ix] )
		}
	}	; end For file
	setPklInfo( "LayStack", layStck )   								; Layout.ini, BaseLayout.ini, Layouts_Override, Layouts_Default
	setPklInfo( "DirStack", dirStck )
	kbdType := pklIniRead( "KbdType", kbdType,"LayStk" ) 				; This time, look for a KbdType down the whole LayStack
	kbdType := _AnsiAns( kbdType )
	setLayInfo( "Ini_KbdType", kbdType ) 								; A KbdType setting in layout.ini overrides the first Layout_ setting
	
	imgsDir := pklIniRead( "img_MainDir", mainDir, "LayStk" )   		; Help imgs are in the main layout folder, unless otherwise specified.
	setPklInfo( "Dir_LayImg", atKbdType( imgsDir ) )
	
	feD := "Files\_eD_", LSt := "LayStk" 								; Read and set layout support files. Often read at the bottom of a LayStack+1.
	mapFile := pklIniRead( "remapsFile", feD "Remap.ini"      , LSt ) 	; Layout remapping for ergo mods, ANSI/ISO conversion etc.
	extFile := pklIniRead( "extendFile", feD "Extend.ini"     , LSt ) 	; Extend mappings used to be in pkl.ini (now EPKL_Settings)
	dksFile := pklIniRead( "dkListFile", feD "DeadKeys.ini"   , LSt ) 	; DeadKeys
	cmpFile := pklIniRead( "cmposrFile", feD "Compose.ini"    , LSt ) 	; Compose settings and mappings
	strFile := pklIniRead( "stringFile", feD "PwrStrings.ini" , LSt ) 	; PowerStrings
	strFile := fileOrAlt( strFile, mainLay )    						; eD WIP: Can't use LayStack+1 here? pkl_PwrString() uses IniRead. Read time is an issue?
	mapStck := _pklStckUp( "Remaps", mapFile    )   					; Store the file and LayStack+1 as PklInfo
	extStck := _pklStckUp( "Extend", extFile    )   					; This will only be used below here, so PklInfo is strictly not necessary
	dksStck := _pklStckUp( "dkList", dksFile    )   					; The DK file stack is called both below and in pkl_deadkey.ahk
	           _pklStckUp( "Cmposr", cmpFile, 1 )   					; No stack variable needed, as the won't be called below here but elsewhere from PklInfo
	setPklInfo( "StringFile", strFile ) 								; This file should contain the string tables. As discussed above, it can't be a LayStack+1 (now).
	
	if ( not initialized ) && ( FileExist( mapFile ) ) { 				; Read/set remap dictionaries. Ensure the tables are read only once.
		secList := pklIniRead( "__List", , layStck[1] ) 				; A list of sections in the topmost LayStack file (layout.ini).
		secList .= pklIniRead( "__List", , layStck[2] ) 				; A list of sections in the second  LayStack file (BaseLayout).
		remStck := InStr( secList, "Remaps" ) ? mapStck : mapFile   	; Only check the whole LayStack if [Remaps] is in secList, to save startup time.
		cycStck := InStr( secList, "RemapCycles" ) ? mapStck : mapFile 	; InStr() is case insensitive.
		mapTypes    := [ "scMapLay"    , "scMapExt"    , "vkMapMec"     ] 	; Map types: Main remap, Extend/"hard" remap, VK remap
		mapSects    := [ "mapSC_layout", "mapSC_extend", "mapVK_mecSym" ] 	; Section names in the .ini file
		For ix, mapType in mapTypes {
			mapList := pklIniRead( mapSects[ A_Index ],, "LayStk" ) 	; First, get the name of the map list
			mapList := atKbdType( mapList ) 							; Replace '@K' w/ KbdType
			%mapType% := ReadRemaps( mapList,            remStck )  	; Parse the map list into a list of base cycles
			%mapType% := ReadCycles( mapType, %mapType%, cycStck )  	; Parse the cycle list into a pdic of mappings
		}	; end For mapType
		setPklInfo( "scMapLay", scMapLay )
;		SCVKdic := ReadKeyLayMapPDic( "SC", "VK", mapFile ) 			; Make a code dictionary for SC-2-VK mapping below
		QWSCdic := ReadKeyLayMapPDic( "QW", "SC", mapFile ) 	; KLM code dictionary for QW-2-SC mapping 	; eD WIP. Make these only on demand, allowing for other code tables?
		setPklInfo( "QWSCdic", QWSCdic )
		QWVKdic := ReadKeyLayMapPDic( "QW", "VK", mapFile ) 	; KLM code dictionary for QW-2-VK mapping 	; Co is unintuitive since KLM VK names are QW based.
		setPklInfo( "QWVKdic", QWVKdic )
;		CoSCdic := ReadKeyLayMapPDic( "Co", "SC", mapFile ) 	; KLM code dictionary for Co-2-SC mapping 	; eD WIP: Maybe use QW-2-SC then SC-2-VK to save on number of dics?
;		mapVK   := ReadRemaps( "ANS2ISO-Sc",      mapFile ) 			; Map between ANSI (default in the Remap file) and ISO mappings 	; eD WIP: Instead, use GetKeyVK(SC)
;		mapVK   := ReadCycles( "vkMapMec", mapVK, mapFile ) 			; --"--
		mapVK   := getWinLayVKs()   									; Map the OEM_ VK codes to the right ones for the current system layout (locale dependent) 	; eD WIP
		initialized := true
	}
	
	shStats := pklIniRead("shiftStates", "0:1"  , "LayStk", "global") 	; .= ":8:9" ; SgCap/SwiSh should be declared explicitly
	shStats := pklIniRead("shiftStates", shStats, "LayStk", "layout") 	; This was in [global] then [pkl]
	setLayInfo( "LayHasAltGr", InStr( shStats, 6 ) ? 1 : 0 )
	shStats := StrSplit( RegExReplace( shStats, "[ `t]+" ), ":" ) 		; Remove any whitespace and make it an array
	for ix, state in shStats {
		shStats[ix] := Format( "{:i}", "0x" . state )   				; Use hex in layout files for states (above 9), but dec internally
	}
	setLayInfo( "shiftStates", shStats ) 								; An array of the active shift states. Used by the Help Image Generator (HIG).
	
	cmpKeys := []   													; Any Compose keys are registered before calling init_Composer().
	For ix, layFile in layStck { 										; Loop parsing all the LayStack layout files
	st2VK   := getLayInfo("St2VK") && ( layFile == baseLay ) 			; State-2-VK layout type: BaseLay entries are made VK.  	; eD WIP: Use BaseStack here when implemented
	layMap  := pklIniSect( layFile, "layout" )  						; An array of lines. Not End-of-line comment stripped (yet).
	extKey  := pklIniRead( "extend_key","", layFile )   				; Extend was in layout.ini [global]. Can map it directly now.
	( extKey ) ? layMap.Push("`r`n" . extKey . " = Extend Modifier") 	; Define the Extend key. Lifts earlier req of a layout entry.
	For ix, row in layMap { 											; Loop parsing the layout 'key = entries' lines
		pklIniKeyVal( row, key, entrys, 0, 0 )  						; Key SC and entries. No comment stripping here to avoid nuking the semicolon.
		if InStr( "<NoKey><Blank>shiftStates", key ) 					; This could be mapped, but usually it's from pklIniKeyVal()
			Continue 													; The shiftStates entry is special, defining the layout's states
;		keyOrig := key  												; eD WIP: Can we make the System layout remappable, so you could apply ergomods etc to your OS layout?
		KLM     := _mapKLM( key, "SC" ) 								; Co/QW-2-SC KLM remapping, if applicable
		key     := scMapLay[ key ] ? scMapLay[ key ] : key 				; If there is a SC remapping, apply it
		if ( getKeyInfo( key . "isSet" ) == "KeyIsSet" ) 				; If a key is at all defined, mark it as set
			Continue
		setKeyInfo( key . "isSet", "KeyIsSet" ) 						; Skip marked keys for the rest of the LayStack
		entrys  := RegExReplace( entrys, "`t;[ ]{2,}`t", "Ş₡εɳŦŕ¥" ) 	; Conserve semicolon entries so they aren't comment-stripped
		entrys  := StrReplace( strCom(entrys), "Ş₡εɳŦŕ¥", "`t;`t" ) 	; Strip end-of-line comments (whitespace-then-semicolon)
		entrys  := RegExReplace( entrys, "[ `t]+", "`t" ) 				; Turn any consecutive whitespace into single tabs, so...
		entry   := StrSplit( entrys, "`t" ) 							; The Tab delimiter and no padding requirements are lifted
		numEntr := entry.Length()
		entr1   := ( numEntr > 0 ) ? entry[1] : ""
		entr2   := ( numEntr > 1 ) ? entry[2] : ""
		if ( InStr( entr1, "/" ) ) { 									; Check for Tap-or-Modifier keys (ToM):
			tomEnts := StrSplit( entr1, "/" )   						;   Their VK entry is of the form 'VK/ModName'.
			entr1   := tomEnts[1]
			tapMod  := _checkModName( tomEnts[2] )
			extKey  := ( loCase( tapMod ) == "extend" ) ? key : extKey 	; Mark this key as an Extend key (for ExtendIsPressed)
			setKeyInfo( key . "ToM", tapMod )
		} else {
			tapMod  := ""
		}
		keyVK := "VK" . Format( "{:X}", GetKeyVK( key ) )   			; Find the right VK code for the key's SC, from the active layout.
		vkStr := "i)^(vkey|-2|vk|virtualkey)$"  						; RegEx needle for VK entries, ignoring case. Allow -2 or not?
		scStr := "i)^(skey|-3|sc|scancode|system)$"  					; RegEx needle for SC entries  --"--
		if RegExMatch( entr1, vkStr) {  								; VK map the key to itself if the first entry is a VKey synonym
			numEntr   := 2
			entr1     := keyVK  										; The right VK code for the key's SC, from the active layout.
			entr2     := "VKey" 										; Note: This is the KLM vc=QWERTY mapping of that SC###.
		} else if RegExMatch( entr1, scStr ) {  						; SC map the key to itself
			numEntr   := 2
			entr1     := key
			entr2     := "ScanCode"
		}
		if ( numEntr < 2 )  || ( entr1 == "--" )    					; Any other empty or one-entry key mapping will deactivate the key
							|| ( InStr(entr2,";") == 1 ) {   			; (This includes if the 2nd entry is a comment)
			Hotkey, *%key%   ,  doNothing   							; The *SC### format maps the key regardless of modifiers.
;			Hotkey, *%key% Up,  doNothing   							; eD WIP: Does a key Up doNothing help to unset better?
			Continue 													; eD WIP: Is this working though? With base vs layout?
		}
		if ( InStr( "modifier", loCase(entr2) ) == 1 ) { 				; Entry 2 is either the Cap state (0-5), 'Modifier', 'VKey' or 'SKey'
			entr1   := _checkModName( entr1 )   						; Modifiers are stored as their AHK names, e.g., "RShift", "AltGr"...
			extKey  := ( entr1 == "Extend" ) ? key : extKey 			; Directly mapped 'key = Extend Modifier'. Special modifier.
;			entr1   := entr1 											; Set VK as modifier name
			entr2   := -1   											; -1 = Modifier
		} else if RegExMatch( entr2, scStr ) {
			qw  := SubStr( entr1, 3 )   								; Check for a KLM QW### ScanCode entry
			iq  := ( InStr( entr1, "QW" ) == 1 && QWSCdic.HasKey( qw ) ) ? 1 : 0 	; This isn't case sensitive now.
			entr1   := ( iq ) ? QWSCdic[ qw ] : entr1   				; Set the scan code for the key as its key info
			entr2   := -3   											; -3 = ScanCode
		} else {    													; The entry is either VK or state mapped. Remap its VK.
			KLM     := _mapKLM( entr1, "VK" )   						; Co/QW-2-VK KLM remapping, if applicable. Can use Vc too.
			mpdVK   := getVKnrFromName( entr1 ) 						; Translate to the four-digit VK## hex code (Uppercase)
			mpdVK   :=    mapVK[mpdVK] ?    mapVK[mpdVK] : mpdVK 		; If necessary, convert VK(_OEM_#) key codes 	; kbdType == "ISO" && 
			mpdVK   := vkMapMec[mpdVK] ? vkMapMec[mpdVK] : mpdVK 		; Remap the VKey here before assignment, if applicable.
			entr1   := mpdVK    										; Set the (mapped) VK## code as key info
			entr2   := RegExMatch( entr2, vkStr ) ? -2  				; -2 = VirtualKey (if "VKey" mapped or it's set as a eD2VK-type layout)
			            : ( st2VK )               ? -2 : entr2  		; ...or in the case of a state entry, its Cap state
		}
		setKeyInfo( key . "ent1", entr1 )   							; Set the "vkey" info (`VK_` in MSKLC layouts)
		setKeyInfo( key . "ent2", entr2 )   							; Set CapsState (`CAP`: 0-5 for states; -1 Mod; -2 VK; -3 SC)
		if ( tapMod ) { 												; Tap-or-Modifier
			Hotkey, *%key%   ,  tapOrModDown
			Hotkey, *%key% Up,  tapOrModUp
		} else if ( entr2 == -1 ) { 									; Set modifier keys, including Extend
			Hotkey, *%key%   ,  modifierDown
			Hotkey, *%key% Up,  modifierUp
		} else if ( entr2 == -2 ) || ( entr2 == -3 ) {   				; Set VK/SC mapped keys, activated on down and released on up
			Hotkey, *%key%   ,  keypressDown
			Hotkey, *%key% Up,  keypressUp   							; In this case, A_ThisHotkey will contain a trailing ` UP`
		} else {
			Hotkey, *%key%   ,  keypressDown 							; Set state mapped keys; these use AHK Send (Down/Up)
			Hotkey, *%key% Up,  doNothing   							; eD WIP: Only Down needed? Or is this an advantage?
		}	; end if entries
		if ( entr2 < 0 )
			numEntr := 2 												; If the key is VK/SC/Mod, ignore any extra entries
		Loop % numEntr - 2 { 											; Loop through all entries for the key, starting at #3
			ks      := shStats[ A_Index ]   							; This shift state for this key
			ksE     := entry[ A_Index + 2 ] 							; The value/entry for that state
			if        ( StrLen( ksE ) == 0 ) { 							; Empty entry; ignore
				Continue
			} else if ( StrLen( ksE ) == 1 ) { 							; Single character entry:
;				setKeyInfo( key . ks . "s", "+" ) 						; eD WIP: Mark set states as '+' and empty as '-', to read the LayStack top-down? No, mark the keys.
				setKeyInfo( key . ks , Ord(ksE) ) 						; Convert to ASCII/Unicode ordinal number; was Asc()
			} else if ( ksE == "--" ) || ( ksE == -1 ) { 				; --: Disabled state entry (MSKLC uses -1)
				setKeyInfo( key . ks      , "" ) 						; "key<state>" empty
			} else if ( ksE == "##" ) {
				setKeyInfo( key . ks , -2 ) 							; Send this state {Blind} as its VK##
				setKeyInfo( key . ks . "s", mpdVK ) 					; Use the remapped VK## code found above
			} else if RegExMatch( ksE, "i)^(spc|=.space.)" ) { 			; Spc: Special 'Spc' or '={Space}' entry for space; &Spc for instance, works differently.
				setKeyInfo( key . ks , 32 ) 							; The ASCII/Unicode ordinal number for Space; lets a space release DKs
			} else {
				ksP := SubStr( ksE, 1, 1 )  							; Multi-character entries may have a single-character prefix
				tag := hig_tag( ksE )   								; Any mapping may start with a HIG display tag for help images
				if ( tag ) {    										; This tag is formatted `«#»` w/ # any character(s) except `»`
					setKeyInfo( key . ks . "Ħ", tag )   				; The display tag is kept so the HIG can find it if necessary
					ksE := hig_untag( ksE ) 							; eD WIP: Or not? Just do this in ParseSend so DKs etc may use it too? Or both?
				} 	; end if HIG tag
				ks2 := SubStr( ksE, 2 )
				if InStr( "%→$§*α=β~†@Ð&¶®©", ksP ) {   				; Prefix-Entry syntax
					if ( ksP == "©" )   								; ©### entry: Named Compose/Completion key – compose previous key(s)
						cmpKeys.Push( ks2 ) 							; Register Compose key for initialization
					ksE := ks2  										; = : Send {Blind} - use current mod state
				} else {												; * : Omit {Text}; use special !+^#{} AHK syntax
					ksP := "%"  										; %$: Literal/ligature (Unicode/ASCII allowed)
				}														; @&: Dead keys and named literals/strings
				setKeyInfo( key . ks      , ksP ) 						; "key<state>"  is the entry prefix
				setKeyInfo( key . ks . "s", ksE ) 						; "key<state>s" is the entry itself
			}	; end if prefix
		}	; end loop entries
	}	; end loop (parse layMap)
	if ( extKey ) && ( ! getLayInfo("ExtendKey") ) { 					; Found an Extend key, and it wasn't already set higher in the LayStack
		setLayInfo( "ExtendKey", extKey ) 								; The extendKey LayInfo is used by ExtendIsPressed  	; eD WIP: Use an extKeys[] array instead!
	}	; end For row in map
	}	; end For layFile (parse layoutFiles)
	
													;   ###############################################################
;initOtherInfo() 									;   ####################### Other settings  #######################
													;   ###############################################################
	
	;; ================================================================================================
	;;  Read and set Extend mappings and help image info
	;
	if getLayInfo( "ExtendKey" ) {  									; If there is an Extend key, set the Extend mappings.
		hardLayers  := strSplit( pklIniRead( "extHardLayers", "1/1/1/1", extStck ), "/", " " ) 	; Array of hard layers
		For ix, stckFile in extStck {  									; Parse the LayStack then the ExtendFile. Defined above.
			Loop % 4 {  												; Loop the multi-Extend layers
				extN := A_Index
				thisSect := pklIniRead( "ext" . extN ,, extStck )  		; ext1/ext2/ext3/ext4 	; Deprecated: [extend] in pkl.ini
				map := pklIniSect( stckFile, thisSect )
				if ( map.Length() == 0 )  								; If this map layer is empty, go on
					Continue
				For ix, row in map {
					pklIniKeyVal( row , key, extMapping )   			; Read the Extend mapping for this SC
					KLM := _mapKLM( key, "SC" )  						; Co/QW-2-SC KLM remapping, if applicable
					key := upCase( key )
					if ( hardLayers[ extN ] ) {
						key := scMapExt[ key ] ? scMapExt[ key ] : key 	; If applicable, hard remap entry
					} else {
						key := scMapLay[ key ] ? scMapLay[ key ] : key 	; If applicable, soft remap entry
					}
					if ( getKeyInfo( key . "ext" . extN ) != "" )   	; Skip mapping if already defined
						Continue
					if ( InStr( extMapping, "©" ) == 1 )
						cmpKeys.Push( SubStr( extMapping, 2 ) ) 		; Register Compose key for initialization
					tmp := extMapping
					extMapping := hig_untag( extMapping )   			; Lop off any HIG tag   	; eD TODO: We don't yet generate Extend images. Could we?
					setKeyInfo( key . "ext" . extN , extMapping )
				}	; end for row (parse extMappings)
			}	; end Loop ext#
		}	; end For stckFile (parse extStck)
		setPklInfo( "extReturnTo", StrSplit( pklIniRead( "extReturnTo"
							, "1/2/3/4", extStck ), "/", " " ) )    	; ReturnTo layers for each Extend layer
		Loop % 4 {
			setLayInfo( "extImg" . A_Index  							; Extend images
				  , fileOrAlt( pklIniRead( "img_Extend" . A_Index ,, "LayStk" ), mainDir . "\extend.png" ) ) 	; eD WIP: Allow imgDir instead
		}	; end loop ext#
	}	; end if ( ExtendKey )
	
	init_Composer( cmpKeys ) 											; Initialise the EPKL Compose tables once for all ©-keys
	
	;; ================================================================================================
	;;  Read and set the deadkey name list and help image info, and the string table file
	;;
	;;  - NOTE: Any file in the LayStack may contain named DK sections with extra or overriding DK mappings.
	;;  - A -- (or -1) entry in a overriding LayStack file disables any corresponding entry in the base DK file.
	;
	Loop % 32 { 														; Start with the default dead key table
		key := "@" . Format( "{:02}", A_Index ) 						; Pad with zero if index < 10
		ky2 := "@" .                  A_Index   						; e.g., "dk1" or "dk14"
		val := "deadkey" . A_Index
		setKeyInfo( key, val )  										; "dk01" = "deadkey1"
		if ( ky2 != key )   											; ... and also, ...
			setKeyInfo( ky2, val )  									; "dk1" = "deadkey1", backwards compatible
	}
	dknames := "deadKeyNames"   										; The .ini section that holds dk names
	For ix, stckFile in dksStck {   									; Go through both DK and Layout files for names
		For ix, row in pklIniSect( stckFile, dknames ) { 				; Make the dead key name lookup table
			pklIniKeyVal( row, key, val )
			if ( val )
				setKeyInfo( key, val )  								; e.g., "dk01" = "dk_dotbelow"
		}
	}
	dkImDir := fileOrAlt( atKbdType( pklIniRead( "img_DKeyDir"  		; Read/set DK image data
						, ".\DeadkeyImg", "LayStk" ) ), mainDir )   	; Default DK img dir: Layout dir or DeadkeyImg
	setLayInfo( "dkImgDir", dkImDir )
	setLayInfo( "dkImgSuf", pklIniRead( "img_DKStateSuf",,, "hig" ) ) 	; DK img state suffix. Defaults to old ""/"sh"?
	
	;; ================================================================================================
	;;  Read and set layout on/off icons and the tray menu
	;
	ico := readLayoutIcons( "LayStk" )
	setLayInfo( "Ico_On_File", ico.Fil1 )
	setLayInfo( "Ico_On_Num_", ico.Num1 )
	setLayInfo( "Ico_OffFile", ico.Fil2 )
	setLayInfo( "Ico_OffNum_", ico.Num2 )
	pkl_set_tray_menu()
}	; end fn initLayIni()

activatePKL() { 									; Activate EPKL single-instance, with a tray icon etc
	SetCapsLockState, Off 							; Remedy those pesky CapsLock hangups at restart
	SetTitleMatchMode 2
	DetectHiddenWindows on
	WinGet, id, list, %A_ScriptName%
	Loop % id {
		id := id%A_Index% 							; If this isn't the first instance...
		PostMessage, 0x398, 422,,, ahk_id %id% 		; ...send a "kill yourself" message to all instances.
	}
	Sleep, 20
	
	Menu, Tray, Icon, % getLayInfo( "Ico_On_File" ), % getLayInfo( "Ico_On_Num_" )
	Menu, Tray, Icon,,, 1 							; Freeze the tray icon
	
	pkl_showHelpImage( 1 ) 							; Initialize/show the help mage...
	ims := bool(pklIniRead("showHelpImage",true)) ? 2 : 3
	Loop % ims {
		pkl_showHelpImage( 2 ) 						; ...then toggle it off if necessary
		Sleep, 42 									; The image flashes on startup if this is too long
	} 												; Repeat image on/off to avoid minimize-to-taskbar bug 	; eD WIP: This is hacky but hopefully effective?!
	setExtendInfo() 								; Prepare Extend info for the first time
	
	Sleep, 200 										; I don't want to kill myself...
	OnMessage( 0x398, "_MessageFromNewInstance" )
	
	SetTimer, pklJanitorTic,  1000  				; Perform regular tasks routine every 1 s
	if bool(pklIniRead("startSuspended")) {
		Suspend
		Gosub afterSuspend
	}
	_pklJanitorLocaleVK( true ) 					; Force the first janitor locale update
;	Gosub pklJanitorTic 							; Do the first janitor sweep right away
}	; end fn

changeLayout( nextLayout ) { 						; Rerun EPKL with a specified layout
	Menu, Tray, Icon,,, 1 							; Freeze the tray icon
	Suspend, On
	
	if ( A_IsCompiled )
		Run %A_ScriptName% /f %nextLayout%
	else
		Run %A_AhkPath% /f %A_ScriptName% %nextLayout%
}

_pklSetInf( pklInfo ) { 							; Simple setting for EPKL_Settings entries
	setPklInfo( pklInfo, pklIniRead( pklInfo ) )
}

_pklStckUp( The, theFile, at1 = 0 ) {   			; Add a support file to the bottom of a LayStack clone
	theStck := getPklInfo( "LayStack" ).Clone() 	; Use a clone, or we'll edit the actual LayStack array
	if FileExist( theFile ) {
		if ( at1 ) { 								; If specified, add at a certain location instead
			theStck.InsertAt( at1, theFile )
		} else {
			theStck.Push(          theFile ) 		; By pushing mapFile at the end of the stack, maps may be overridden.
		}
	}
	setPklInfo( The . "File", theFile )
	setPklInfo( The . "Stck", theStck )
	Return theStck
}

_pklLayRead( type, def = "--", prefix = "" ) {  	; Read kbd type/mods (used in pkl_init) and set Lay info
	pklLays := getPklInfo( "Arr_PklLay" )
	val := pklIniRead( type, def, pklLays ) 		; Read from the EPKL_Layouts .ini file(s)
	val := ( type = "KbdType" ) ? _AnsiAns( val ) : val
	setLayInfo( "Ini_" . type, val )				; Stores KbdType etc for use with other parts
	val := ( val == "--" ) ? "" : prefix . val		; Replace -- with nothing, otherwise use prefix
;	val := ( InStr( val, "<", 0 ) ) ? false : val 	; If the value is <N/A> or similar, return boolean false 	; eD WIP: Don't use that anymore
	Return val
}

_AnsiAns( kbdt ) { 									; You're allowed to use ANSI as a more well-known synonym to the ANS KbdType
	Return ( kbdt = "ANSI" ) ? "ANS" : kbdt
}

_mapKLM( ByRef key, type ) {
	static QWSCdic      := []
	static QWVKdic      := []
	static CoSCdic      := []
	static CoVKdic      := []
	static initialized  := false
	
	if ( not initialized ) {
		mapFile := getPklInfo( "RemapsFile" )
		QWSCdic := ReadKeyLayMapPDic( "QW", "SC", mapFile ) 	; KLM code dictionary for QW-2-SC mapping 	; eD WIP. Make these only on demand, allowing for other codes too?
		QWVKdic := ReadKeyLayMapPDic( "QW", "VK", mapFile ) 	; KLM code dictionary for QW-2-VK mapping 	; Co is unintuitive since KLM VK names are QW based.
		CoSCdic := ReadKeyLayMapPDic( "Co", "SC", mapFile ) 	; KLM code dictionary for Co-2-SC mapping
;		CoVKdic := ReadKeyLayMapPDic( "Co", "VK", mapFile ) 	; KLM code dictionary for Co-2-VK mapping 	; eD WIP: Maybe use QW-2-SC then SC-2-VK to save on number of dics?
		initialized := true
	}
	
	KLM := RegExMatch( key, "i)^(Co|QW|vc)" ) 
		? SubStr( key, 1, 2 ) : false 				; Co/QW-2-SC/VK KLM remappings
	KLM := ( KLM == "vc" ) ? "QW" : KLM 			; The vc synonym (case sensitive!) for QW is used for VK codes
	if ( KLM )
		key := %KLM%%type%dic[ SubStr( key, 3 ) ] 	; [Co|QW][SC|VK]dic from Colemak/QWERTY KLM codes to SC/VK
	Return KLM
}

_checkModName( key ) {  							; Mod keys need only the first letters of their name
	static modNames := [ "LShift", "RShift", "CapsLock", "Extend", "SGCaps"
						, "LCtrl", "RCtrl", "LAlt", "RAlt", "LWin", "RWin"
						, "SwiSh", "FliCK" ] 		; eD WIP: SwiSh (SGCaps) modifier, FliCK (FlipCapKey)
	
	For ix, modName in modNames {
		if ( InStr( modName, key, 0 ) == 1 ) 		; Case insensitive match: Does modName start with key?
			key := modName
	}	; end For modName
	if ( getLayInfo( "LayHasAltGr" ) && key == "RAlt" ) {
		Return "AltGr" 								; RAlt as AltGr
	} else {
		Return key 									; AHK modifier names, e.g., "RS" or "RSh" -> "RShift"
	}
}

_MessageFromNewInstance( lparam ) { 				; Called by OnMessage( 0x0398 ) in pkl_init
	if ( lparam == 422 ) 							; If you run a second EPKL instance, this message is sent
		ExitApp
}
