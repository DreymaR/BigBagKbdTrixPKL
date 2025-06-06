﻿;;  ================================================================================================================================================
;;  EPKL initialization
;;  - Load 1) general settings and layout choice, 2) the layout itself, 3) other stuff.
;

													;   ###############################################################
initPklIni( layoutFromCommandLine ) {   			;   ######################## EPKL Settings ########################
													;   ###############################################################
	
	;;  ============================================================================================================================================
	;;  Before we start... Initialize former globals, now included in the get/set info framework:
	;
	setPklInfo( "File_PklSet", "EPKL_Settings"         ) 				; Used globally (used to be in pkl.ini)
	setPklInfo( "File_PklLay", "EPKL_Layouts"          ) 				; --"--
	setPklInfo( "LaysDirName", "Layouts"               ) 				; --"--
	setPklInfo( "LayFileName", "Layout"                ) 				; --"--
	setPklInfo( "File_PklDic", "Files\EPKL_Tables.ini" ) 				; Info dictionary file, mostly from internal tables
	;setKeyInfo( "HotKeyBufDn", 0 ) 									; Hotkey buffer for pkl_keypress (was 'HotkeysBuffer')
	setPklInfo( "WinMatchDef", 2                       ) 				; Default TitleMatchMode for window recognition; 2 = Match partial title
	resetDeadKeys() 													; Resetting the DKs initializes them - necessary for function
	setPklInfo( "osmMax", 3 )   										; Allow this many concurrent OneShot Modifiers (OSM)
	setPklInfo( "osmN", 1 )  											; OSM number counter
	
	;;  ============================================================================================================================================
	;;  Find and read from the Settings file(s)
	;
	setFile := getPklInfo( "File_PklSet" )  							; The default file name will still be available.
	setStck := []
	For ix, type in [ "", "_Override", "_Default" ] {
		file := setFile . type . ".ini"
		If FileExist( file ) 											; If the file exists...
			setStck.push( file ) 										; ...add it to the SetStack
	}   ; <-- For type
	If ( setStck.Length() == 0 ) {
		MsgBox, %setFile% file NOT FOUND.`nEPKL cannot run without this file.`n`n• EPKL.exe must be run inside its home folder.`n• This folder must be uncompressed/extracted.
		ExitApp
	}
	setPklInfo( "SetStack", setStck )   								; Settings_Override, Settings_Default
	setPklInfo( "AdvancedMode", bool(pklIniRead("advancedMode")) )  	; Extra debug info etc
	pklLays := getPklInfo( "File_PklLay" )  							; "EPKL_Layouts"
	pklLays := [ pklLays . "_Override.ini", pklLays . "_Default.ini" ] 	; Now an array of override [1] and default [2] (if present)
	setPklInfo( "pklLaysFiles", pklLays )
	
	lang := pklIniRead( "menuLanguage", "auto" ) 						; Load locale strings
	If ( lang == "auto" )
		lang := pklIniRead( SubStr( A_Language , -3 ), "", "PklDic", "LangStrFromLangID" )
	pkl_locale_load( lang )
	
	;;  Legend: (  hkIniName       ,  gotoLabel            ,  pklInfoTag       ) 	; Set a (menu) hotkey
	pklSetHotkey( "helpImageHotkey", "toggleHelpImage"     , "HK_ShowHelpImg"  ) 	; 1
	pklSetHotkey( "changeLayHotkey", "rerunNextLayout"     , "HK_ChangeLayout" ) 	; 2
	pklSetHotkey( "suspendMeHotkey", "toggleSuspend"       , "HK_Suspend"      ) 	; 3/` - 3 didn't work well?
	pklSetHotkey( "doSuspendHotkey", "suspendOn"           , "HK_SuspendOn"    ) 	; ? - Not normally in use, but may help some.
	pklSetHotkey( "unSuspendHotkey", "suspendOff"          , "HK_SuspendOff"   ) 	; ? - --"-- (https://github.com/DreymaR/BigBagKbdTrixPKL/issues/54)
	pklSetHotkey( "exitMeNowHotkey", "exitPKL"             , "HK_ExitApp"      ) 	; 4
	pklSetHotkey( "refreshMeHotkey", "rerunSameLayout"     , "HK_Refresh"      ) 	; 5
	pklSetHotkey( "settingUIHotkey", "changeSettings"      , "HK_SettingsUI"   ) 	; 6
	pklSetHotkey( "runTargetHotkey", "openTarget"          , "HK_OpenTarget"   ) 	; 7
	pklSetHotkey( "zoomImageHotkey", "zoomHelpImage"       , "HK_ZoomHelpImg"  ) 	; 8
	pklSetHotkey( "opaqImageHotkey", "opaqHelpImage"       , "HK_OpaqHelpImg"  ) 	; 9 - Hidden from menu
	pklSetHotkey( "procStatsHotkey", "getWinInfo"          , "HK_AhkWinInfo"   ) 	; 0 - Hidden from menu
	pklSetHotkey( "epklDebugHotkey", "epklDebugUtil"       , "HK_DebugUtil"    ) 	; = - Hidden from menu
	pklSetHotkey( "moveImageHotkey", "moveHelpImage"       , "HK_MoveHelpImg"  ) 	; ? - Hidden from menu
	#MaxThreadsBuffer       Off 										; Turn on hotkey buffering for subsequent hotkeys (key presses)
	
	setCurrentWinLayDeadKeys( pklIniRead( "systemDeadKeys" ) )  		; eD WIP: Better DK detection fn!
	setKeyInfo( "CtrlAltIsAltGr", bool(pklIniRead("ctrlAltIsAltGr")) )
	
	_pklSetInf( "openMenuTarget", "ŁayÐir"  )   						; Target to open by menu/HK; "." = A_ScriptDir; "ŁayÐir" = LayIni_Dir.
	_pklSetInf( "cleanupTimeOut", 4         )   						; Time idle (sec) before mods etc are cleaned up
	_pklSetInf( "suspendTimeOut", 0         )   						; Time idle (min) before program suspends itself
	_pklSetInf( "exitAppTimeOut", 0         )   						; Time idle (min) before program exits itself
	For ix,suspApp in pklIniCSVs( "suspendingApps" ) { 					; Programs that suspend EPKL when active
		If ( suspApp == "--" )
			Break
		shorthand := { "C " : "ahk_class " , "X " : "ahk_exe " , "T " : "" }
		For needle, newtxt in shorthand 								; C/X/[T] matches by window Class/Exe/Title
			suspApp := RegExReplace( suspApp, "^" . needle, newtxt )
		GroupAdd, SuspendingApps, %suspApp% 							;     Used by pklJanitor
	}   ; <-- For suspApp
	_pklSetInf( "suspendingMode", "--"      )   						; Window TitleMatchMode to use for suspendingApps
	_pklSetInf( "suspendingLIDs", "--"      )   						; Layouts that suspend EPKL when active (actually CSV, but it's okay)
	
	_pklSetInf( "stickyMods", "LShift"      )   						; Sticky/One-Shot modifiers (actually CSV, but store it as a string)
	_pklSetInf( "stickyTime", 600           )   						; --"--
	
	extMods := pklIniCSVs( "extendMods" )								; Multi-Extend w/ tap-release
	setPklInfo( "extendMod1", ( extMods[1] ) ? extMods[1] : "" )
	setPklInfo( "extendMod2", ( extMods[2] ) ? extMods[2] : "" )
;	_pklSetInf( "extendTaps"                )   						; --"--
	_pklSetInf( "tapModTime", 200           )   						; Tap-or-Mod time
;	setPklInfo( "unicodeVKs", bool(pklIniRead("unicodeVKs")) )  		; Whether to Compose w/ ToUnicode for VK/SC mappings: Its side effect ruins OS DKs.  	; eD FIXED
	
	;;  ============================================================================================================================================
	;;  Find and read from the EPKL_Layouts file(s)
	;
	shortLays   := pklIniCSVs( "shortLays", "Colemak/Cmk", "PklDic" )
	shortLayDic := {}   												; CSV list of main layout name abbreviations
	For ix, entr in shortLays { 										;     (Default: First 3 letters)
		split := StrSplit( entr, "/" )
		If ( split.Length() != 2 )
			Continue
		shortLayDic[ split[1] ] := split[2]
	}
	setPklInfo( "shortLays", shortLayDic )
	
	theLays :=  pklIniRead( "layout", "", pklLays ) 					; Read the layouts string from EPKL_Layouts. May contain @# shorthand.
	layMain := _pklLayRead( "LayMain", "Colemak" )  					; Main Layout: Colemak, Tarmak, Dvorak etc.; now the same as LayName
	If InStr( layMain, "/" ) {  										; The LayMain may be on the form 'LayName/3LA' already...
		split   := StrSplit( layMain, "/" )
		layMain := split[1]
		lay3LA  := split[2]
	} else {    														; ...or not, in which case we look up or generate the 3LA.
		lay3LA  := shortLayDic[ layMain ]   	; Was layName
		lay3LA  := ( lay3LA ) ? lay3LA : SubStr( layMain, 1, 3 )    	; If not specified in shortLayDic, the 3LA is the first 3 letters.
	}
	layPath := _pklLayRead( "LayPath", "@L\@3-@T@V" )   				; Path to layout folders: @L\<subfolder>. Simple layouts just have `@L`.
;	split   := StrSplit( layMain, "\" ), layName := split[1]    		; LayMain can also contain a subfolder.
	layType := _pklLayRead( "LayType", "eD"         )   				; Layout type, mostly eD or VK
	layVari := _pklLayRead( "LayVari",      , "-"   )   				; Locale ID, e.g., "-Pl", or other variant such as Tarmak steps
	polyLID := {}
	For ix, LVars in pklIniCSVs( "multiLocs",, "pklDic" ) { 			; For layouts with compound Locale IDs, any component can be used alone
		harmLID := StrReplace( LVars, "/" ) 							; The Harmonized Locale ID is a compound of its components, like BeCaFr
		For ix, var in StrSplit( LVars, "/" ) { 						; The Tables file entry is a CSV list of slash-separated variants
			polyLID["-" . var] := "-" . harmLID 						; Example: Both "-Dk" and "-No" point to the "-DkNo" layout
		}   ; <-- For LVar
	}   ; <-- For LVars
	localID := ( polyLID[layVari] ) ? polyLID[layVari] : layVari    	;   (can be a single locale of a harmonized layout like BeCaFr)
	kbdType := _pklKbdType( "Lays" )    								; Keyboard type - ISO/ANS(I)/etc - from pklLays
	curlMod := _pklLayRead( "CurlMod"               )   				; --, Curl/DH mod
	hardMod := _pklLayRead( "HardMod"               )   				; --, Hard mod - Angle, AWide...
	othrMod := _pklLayRead( "OthrMod"               )   				; --, Other mod suffix like Sym
	
	theLays := StrReplace( theLays, "@Ʃ",   "@P-@T@V"  )    			; Shorthand .ini notation for main layout path, type and variant
	theLays := StrReplace( theLays, "@Ç",   "@K@C@H@O" )    			; Shorthand .ini notation for KbdType[_]ErgoMods; not in use?
	theLays := StrReplace( theLays, "@E",     "@C@H@O" )    			; Shorthand .ini notation for the full ergomods battery
	theLays := StrReplace( theLays, "@P",   layPath "\@3" ) 			; Replaces @P w/ LayPath\3LA in layout paths, as in 'Colemak\Cmk'
	theLays := StrReplace( theLays, "@L",   layMain    )    			; Replaces @L w/ LayName
	theLays := StrReplace( theLays, "@3",   lay3LA     )
	theLays := StrReplace( theLays, "@T",   layType    )
	theLays := StrReplace( theLays, "@V",   localID    )    			; NOTE: Any one locale in a compound locale (like BrPt) can be used alone.
	kbdTypJ := ( curlMod || hardMod || othrMod ) ? "_" : "" 			; Use "KbdType_Mods" with a joiner character iff any ergoMods are active
	theLays := StrReplace( theLays, "@K@","@K" kbdTypJ "@" )    		; --"--
	theLays := StrReplace( theLays, "@K",   kbdType    )    			; Later on, EPKL will use atKbdType() for layout files instead of this one 	; . "_"
	theLays := StrReplace( theLays, "@C",   curlMod    )
	theLays := StrReplace( theLays, "@H",   hardMod    )
	theLays := StrReplace( theLays, "@O",   othrMod    )
	layouts := StrSplit( theLays, ",", " `t" )  						; Split the CSV layout list
	numLayouts := layouts.Length()
	setLayInfo( "NumOfLayouts", numLayouts )    						; Store the number of listed layouts
	For ix, thisLay in layouts {    									; Store the layout dir names and menu names
;		kbdTypJ := ( curlMod || hardMod || othrMod ) ? "_" : ""
;		needle  := kbdType .           curlMod . hardMod . othrMod 		; Use "KbdType_Mods" with a joiner character iff any ergoMods are active
;		newtxt  := kbdType . kbdTypJ . curlMod . hardMod . othrMod
;		thisLay := RegExReplace( thisLay, needle, newtxt )
		nameParts := StrSplit( thisLay, ":" )
		theCode := nameParts[1]
		theCode := RegExReplace( theCode, "_$"       )  				; If the layout code ends with the KbdType, the trailing underscore is omitted
		theCode := RegExReplace( theCode, "_\\", "\" )  				; The trailing underscore may also figure in subpaths
		If ( not theCode ) {    										; Empty entries cause an error, but any other layouts still work
			theCode := "<N/A>"
			pklWarning( "At least one layout entry is empty" )
		}
		theName := ( nameParts.Length() > 1 ) ? nameParts[2] : theCode
		setLayInfo( "layout" . A_Index . "code", theCode )
		setLayInfo( "layout" . A_Index . "name", theName )
	}   ; <-- for thisLay
	
	If ( layoutFromCommandLine ) {  									; The cmd line layout could be not in theLays?
		thisLay   := layoutFromCommandLine
		If ( SubStr( thisLay, 1, 10 ) == "UseLayPos_" ) {   			; Use layout # in list instead of full path
			thePos      := SubStr( thisLay, 11 )
			thePos      := ( thePos > numLayouts ) ? 1 : thePos
			thisLay   := getLayInfo( "layout" . thePos . "code" )
		}
	} else {
		thisLay := getLayInfo( "layout1code" )
	}
	If ( thisLay == "" ) {
		pklMsgBox( "01", "layouts .ini" )   							; "You must set a layout file in the EPKL_Layouts .ini!"
		ExitApp
	}
	setLayInfo( "ActiveLay", thisLay )
	
	nextLayoutIndex := 1    											; Determine the next layout's index
	Loop % numLayouts {
		If ( thisLay == getLayInfo( "layout" . A_Index . "code") ) {
			nextLayoutIndex := A_Index + 1
			break
		}
	}
	nextLayoutIndex := ( nextLayoutIndex > numLayouts ) ? 1 : nextLayoutIndex
	setLayInfo( "NextLayout", getLayInfo( "layout" . nextLayoutIndex . "code" ) )
}   ; <-- fn initPklIni()

													;   ###############################################################
initLayIni() {  									;   ######################### Layout.ini  #########################
													;   ###############################################################
	
	;;  ============================================================================================================================================
	;;  Find and read from the Layout.ini file and, if applicable, BaseLayout/LayStack
	;
	static initialized  := false
	
	laysDir := getPklInfo( "LaysDirName" )  							; The top-level "Layouts" folder, starting from EPKL root.
	thisLay := getLayInfo( "ActiveLay" )    							; From initPklIni(). For example, Colemak\Cmk-eD\Cmk-eD_ANS.
	layType := getLayStrInfo( thisLay )[4]  							; Returns layName as [1], L3A as [2] and L3A-from-string as [3]
	st2VK   := InStr( layType, "2VK" ) ? true : false   				; ##2VK layType: The (eD) BaseLayout is read as VK, Layout.ini as usual.
	layType := st2VK ? SubStr(layType,1,-3) : layType   				; Make layType reflect actual layType, and set St2VK as necessary.
	thisLay := StrReplace( thisLay, layType . "2VK", layType )
	setLayInfo( "St2VK", st2VK )    									; This is tested for each layFile below
	mainDir := bool( pklIniRead("compactMode") ) ? "." 
			 : laysDir "\" thisLay  									; If in compact mode, use the EPKL root dir as mainDir
	layFiNa := getPklInfo( "LayFileName" )
	layFiPa := mainDir "\" layFiNa  									; Path to "Layout" .ini file(s)
	mainLay := layFiPa . ".ini" 										; The path of the main layout .ini file
	mainOvr := layFiPa . "_Override.ini" 								; Layout_Override.ini, if present
	setPklInfo( "LayIni_Dir"        , mainDir )
	setPklInfo( "LayIni_File"       , mainLay )
	pklLays := [ mainOvr, mainLay ] 									; Start building names for the LayStack
	pklDirs := [ mainDir, mainDir ] 									; Also, building names for the DirStack
	
	baseArr := _seekBaseLayout( pklLays, mainDir, laysDir ) 			; Look for a BaseLayout, as [ files[], dirs[] ]
	If ( baseArr ) {
		baseLay := baseArr[1]   										; An array of baseLayout files
		baseDir := baseArr[2]   										; An array of baseLayout dirs
		dummyIx := pklLays.push( baseLay* ) 							; Array concatenation returns the index of the last inserted value (not needed)
		dummyIx := pklDirs.push( baseDir* ) 							; Can push a value, array or array pointer (`myArray*`)
	}   ; <-- If baseArr
	pklLaFi := getPklInfo( "pklLaysFiles" ) 							; "EPKL_Layouts_Default" (2) and its _Override (1)
	dummyIx := pklLays.push( pklLaFi* ) 								; The two EPKL_Layouts files are found in the EPKL root dir
	dummyIx := pklDirs.push( [ ".", "." ] )
	layStck := []   													; The LayStack is the stack of layout info files
	dirStck := []   													; The DirStack is the stack of layout info file dirs
	For ix, file in pklLays {
		If FileExist( file ) && ! inArray( layStck, file ) {    		; If the file exists and isn't already added...
			layStck.push( file )    									; ...add it to the LayStack
			dirStck.push( pklDirs[ix] )
		}
	}   ; <-- For pklLays
	setPklInfo( "LayStack", layStck )   								; Layout_Override.ini, Layout.ini, BaseLayout.ini, Layouts_Override, Layouts_Default
	setPklInfo( "DirStack", dirStck )
	kbdType := _pklKbdType( "LayStk", kbdType ) 						; This time, a kbd type found in the whole LayStack overrides the first one from pklLaFi.
	
	imgsDir := pklIniPath( "img_MainDir", mainDir, "LayStk" )   		; Help imgs are in the main layout folder, unless otherwise specified. Allow path dots.
	setPklInfo( "Dir_LayImg", atKbdType( imgsDir ) )
	
	feD := "Files\_eD_", LSt := "LayStk"    							; Read and set layout support files. Often read at the bottom of a LayStack+1.
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
	
	If ( not initialized ) && ( FileExist( mapFile ) ) {    			; Read/set remap dictionaries. Ensure the tables are read only once.
		secList := ""
		For ix, file in layStck {
			secList .= pklIniRead( "__List", , layStck[ ix ] )  		; Check all section names in the LayStack
		}
		remStck := InStr( secList, "Remaps"      ) ? mapStck : mapFile 	; Only check the LayStack if [Remaps] is in secList, to save startup time.
		cycStck := InStr( secList, "RemapCycles" ) ? mapStck : mapFile 	; InStr() is case insensitive.
		mapTypes := [ "scMapLay"    ,"scMapExt"    ,"vkMapMec"     ] 	; Map types: Main remap, Extend/"hard" remap, VK remap
		mapSects := [ "mapSC_layout","mapSC_extend","mapVK_mecSym" ] 	; Section names in the .ini file
		For ix, mapType in mapTypes {
			mapList := pklIniRead( mapSects[ A_Index ],, "LayStk" ) 	; First, get the name of the map list
			mapList := atKbdType( mapList ) 							; Replace '@K' w/ KbdType
			%mapType% := ReadRemaps( mapList,            remStck )  	; Parse the map list into a list of base cycles
			%mapType% := ReadCycles( mapType, %mapType%, cycStck )  	; Parse the cycle list into a pdic of mappings
		}   ; <-- For mapType
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
	For ix, state in shStats {
		shStats[ix] := Format( "{:i}", "0x" . state )   				; Use hex in layout files for states (above 9), but dec internally
	}
	setLayInfo( "shiftStates", shStats ) 								; An array of the active shift states. Used by the Help Image Generator (HIG).
	
	cmpKeys := []   													; Any Compose keys are registered before calling init_Composer().
	For ix, layFile in layStck { 										; Loop parsing all the LayStack layout files
		st2VK   := getLayInfo("St2VK") && inArray( baseLay, layFile ) 	; State-2-VK layout type: BaseStack entries are made VK.
		layMap  := pklIniSect( layFile, "layout" )  						; An array of lines. Not End-of-line comment stripped (yet).
		extKey  := pklIniRead( "extend_key","", layFile )   				; Extend was in Layout.ini [global]. Can map it directly now.
		( extKey ) ? layMap.Push("`r`n" . extKey . " = Extend Modifier") 	; Define the Extend key. Lifts earlier req of a layout entry.
		For ix, row in layMap { 											; Loop parsing the layout 'key = entries' lines
			pklIniKeyVal( row, key, entrys, 0, 0 )  						; Key SC and entries. No comment stripping here to avoid nuking the semicolon.
			If InStr( "<NoKey><Blank>shiftStates", key ) 					; This could be mapped, but usually it's from pklIniKeyVal() failure.
				Continue 													; The shiftStates entry is special, defining the layout's states
;			keyOrig := key  												; eD WIP: Can we make the System layout remappable, so you could apply ergomods etc to your OS layout?
			KLM     := _mapKLM( key, "SC" ) 								; Co/QW-2-SC KLM remapping, if applicable
			key     := scMapLay[ key ] ? scMapLay[ key ] : key 				; If there is a SC remapping, apply it
			If ( getKeyInfo( key . "isSet" ) != "" )    					; Skip previously set keys for the rest of the LayStack
				Continue
			setKeyInfo( key . "isSet", layFile )    						; If a key is at all defined, mark it as set for rest of the LayStack
			entrys  := RegExReplace( entrys, "`t;[ ]{2,}`t", "Ş₡εɳŦŕ¥" ) 	; Conserve semicolon entries so they aren't comment-stripped
			entrys  := StrReplace( strCom(entrys), "Ş₡εɳŦŕ¥", "`t;`t" ) 	; Strip end-of-line comments (whitespace-then-semicolon)
			entrys  := RegExReplace( entrys, "[ `t]+", "`t" ) 				; Turn any consecutive whitespace into single tabs, so...
			entry   := StrSplit( entrys, "`t" ) 							; The Tab delimiter and no padding requirements are lifted
			numEntr := entry.Length()
			entr1   := ( numEntr > 0 ) ? entry[1] : ""
			entr2   := ( numEntr > 1 ) ? entry[2] : ""
			If ( InStr( entr1, "/" ) ) { 									; Check for Tap-or-Modifier keys (ToM):
				tomEnts := StrSplit( entr1, "/" )   						;   Their VK entry is of the form 'VK/ModName'.
				entr1   := tomEnts[1]
				tapMod  := _checkModName( tomEnts[2] )
				extKey  := ( loCase( tapMod ) == "extend" ) ? key : extKey 	; Mark this key as an Extend key (for ExtendIsPressed)
				setKeyInfo( key . "ToM", tapMod )
			} else {
				tapMod  := ""
			}   ; <-- if ToM
			keyVK   := "VK" . Format( "{:X}", GetKeyVK( key ) ) 			; Find the right VK code for the key's SC, from the active layout.
			noStr   := "i)^(--|disabled)$"      							; -1; RegEx needle for disabled keys. MSKLC uses `-1` for state entries.
			vkStr   := "i)^(vk|vkey|virtualkey)$"   						; -2; RegEx needle for VK entries, ignoring case. Don't use `-2` as entry.
			scStr   := "i)^(sc|skey|scancode|system)$"  					; -3; RegEx needle for SC entries  --"--
			unStr   := "i)^(<>|unmapped)$"  								; -4; RegEx needle for unmapped keys
			If RegExMatch( entr1, noStr) {      							; This key is disabled.
				Hotkey, *%key%   ,  doNothing   							; The *SC### format maps the key regardless of modifiers.
;				Hotkey, *%key% Up,  doNothing   							; eD WIP: Does a key Up doNothing help to unset better?
				Continue 													; eD WIP: Is this working though? With base vs layout?
			} else if RegExMatch( entr1, vkStr) {   						; VK map the key to itself if the first entry is a VKey synonym
				numEntr   := 2
				entr1     := keyVK  										; The right VK code for the key's SC, from the active layout.
				entr2     := "VKey" 										; Note: This is the KLM vc=QWERTY mapping of that SC###.
			} else if RegExMatch( entr1, scStr ) {  						; SC map the key to itself
				numEntr   := 2
				entr1     := key
				entr2     := "ScanCode"
			} else if ( numEntr < 2 )   									; Any other empty or one-entry key mapping will leave the key ignored, ...
								|| ( InStr(entr2,";") == 1 )    			;   ... also if the 2nd entry is a comment.
								|| RegExMatch( entr1, unStr) {  			; (Explicit unmapping with unStr is only needed if there are more entries.)
				Continue    												; This key is to be left unmapped. Since isSet is now set, it will be.
			}   ; <-- if Single-Entry
			
			If ( InStr( "modifier", loCase(entr2) ) == 1 ) { 				; Entry 2 is either the Cap state (0-5), 'Modifier', 'VKey' or 'SKey'
				entr1   := _checkModName( entr1 )   						; Modifiers are stored as their AHK names, e.g., "RShift", "AltGr"...
				extKey  := ( entr1 == "Extend" ) ? key : extKey 			; Directly mapped 'key = Extend Modifier'. Special modifier.
;				entr1   := entr1 											; Set VK as modifier name
				entr2   := -1   											; -1 : Modifier
			} else if RegExMatch( entr2, scStr ) {
				qw  := SubStr( entr1, 3 )   								; Check for a KLM QW### ScanCode entry
				iq  := ( InStr( entr1, "QW" ) == 1 && QWSCdic.HasKey( qw ) ) ? 1 : 0 	; This isn't case sensitive now.
				entr1   := ( iq ) ? QWSCdic[ qw ] : entr1   				; Set the scan code for the key as its key info
				entr2   := -3   											; -3 : ScanCode
			} else {    													; The entry is either VK or state mapped. Remap its VK.
				KLM     := _mapKLM( entr1, "VK" )   						; Co/QW-2-VK KLM remapping, if applicable. Can use Vc too.
				mpdVK   := getVKnrFromName( entr1 ) 						; Translate to the four-digit VK## hex code (Uppercase)
				mpdVK   :=    mapVK[mpdVK] ?    mapVK[mpdVK] : mpdVK 		; If necessary, convert VK(_OEM_#) key codes 	; kbdType == "ISO" && 
				mpdVK   := vkMapMec[mpdVK] ? vkMapMec[mpdVK] : mpdVK 		; Remap the VKey here before assignment, if applicable.
				entr1   := mpdVK    										; Set the (mapped) VK## code as key info
				entr2   := RegExMatch( entr2, vkStr ) ? -2  				; -2 : VirtualKey (if "VKey" mapped or it's set as a eD2VK-type layout)
							: ( st2VK )               ? -2 : entr2  		; ...or in the case of a state entry, its Cap state
			}
			setKeyInfo( key . "ent1", entr1 )   							; Set the "vkey" info (`VK_` in MSKLC layouts)
			setKeyInfo( key . "ent2", entr2 )   							; Set CapsState (`CAP`: 0-5 for states; -1 Mod; -2 VK; -3 SC)
			If ( tapMod ) { 												; Tap-or-Modifier
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
			}   ; <-- if entries
			If ( entr2 < 0 )
				numEntr := 2    											; If the key is VK/SC/Mod, ignore any extra entries
			Loop % numEntr - 2 {    										; Loop through all entries for the key, starting at #3
				dicName := key . shStats[ A_Index ] 						; Dictionary key name for this key/state
				ksE     := entry[ A_Index + 2 ] 							; The value/entry for that state
				If        ( StrLen( ksE ) == 0 ) {  						; Empty entry; ignore
					Continue
				} else if ( StrLen( ksE ) == 1 ) {  						; Single character entry:
					setKeyInfo( dicName , Ord(ksE)   )  					; Convert to ASCII/Unicode ordinal number; was Asc()
				} else if ( ksE == "--" ) || ( ksE == -1 ) { 				; --: Disabled state entry (MSKLC uses -1)
					setKeyInfo( dicName , ""         )  					; "key<state>" empty
				} else if ( ksE == "##" ) {
					setKeyInfo( dicName      , -2    )  					; Send this state {Blind} as its VK##
					setKeyInfo( dicName . "s", mpdVK )  					; Use the remapped VK## code found above
				} else if RegExMatch( ksE, "i)^(spc|=.space.)" ) {  		; 'Spc' or '={Space}': Special entry. &Spc for instance, works differently.
					setKeyInfo( dicName , 32         )  					; The ASCII/Unicode ordinal number for Space; lets a space release DKs
				} else {
					ksP := SubStr( ksE, 1, 1 )  							; Multi-character entries may have a single-character prefix
					ksE := hig_deTag( ksE, dicName )    					; Remove any `«#»` tag, and save it separately for the HIG
					ks2 := SubStr( ksE, 2 )
					If InStr( "%→$§*α=β~†@Ð&¶®©", ksP ) {   				; Prefix-Entry syntax
						If ( ksP == "©" )   								; ©### entry: Named Compose/Completion key – compose previous key(s)
							cmpKeys.Push( ks2 ) 							; Register Compose key for initialization
						ksE := ks2  										; = : Send {Blind} - use current mod state
					} else {    											; * : Omit {Text}; use special +^!#{} AHK syntax
						ksP := "%"  										; %$: Literal/ligature (Unicode/ASCII allowed)
					}														; @&: Dead keys and named literals/strings
					setKeyInfo( dicName      , ksP )    					; "key<state>"  is the entry prefix
					setKeyInfo( dicName . "s", ksE )    					; "key<state>s" is the entry itself
				}   ; <-- if prefix
			}   ; <-- loop entries
		}   ; <-- loop (parse layMap)
		If ( extKey ) && ( ! getLayInfo("ExtendKey") ) { 					; Found an Extend key, and it wasn't already set higher in the LayStack
			setLayInfo( "ExtendKey", extKey ) 								; The extendKey LayInfo is used by ExtendIsPressed  	; eD WIP: Use a modKeys[] array instead?!
		}   ; <-- For row in map
	}   ; <-- For layFile (parse layoutFiles)
	
													;   ###############################################################
;initOtherInfo() 									;   ####################### Other settings  #######################
													;   ###############################################################
	
	;;  ============================================================================================================================================
	;;  Read and set Extend mappings and help image info
	;
	If getLayInfo( "ExtendKey" ) {  									; If there is an Extend key, set the Extend mappings.
		hardLayers  := strSplit( pklIniRead( "extHardLayers", "1/1/1/1", extStck ), "/", " " ) 	; Array of hard layers
		For ix, stckFile in extStck {  									; Parse the LayStack then the ExtendFile. Defined above.
			Loop % 4 {  												; Loop the multi-Extend layers
				extN := A_Index
				thisSect := pklIniRead( "ext" . extN ,, extStck )  		; ext1/ext2/ext3/ext4 	; Deprecated: [extend] in pkl.ini
				map := pklIniSect( stckFile, thisSect )
				If ( map.Length() == 0 )  								; If this map layer is empty, go on
					Continue
				For ix, row in map {
					pklIniKeyVal( row, key, extMapping )    			; Read the Extend mapping for this SC
					KLM := _mapKLM( key, "SC" )  						; Co/QW-2-SC KLM remapping, if applicable
					key := upCase( key )
					If ( hardLayers[ extN ] ) {
						key := scMapExt[ key ] ? scMapExt[ key ] : key 	; If applicable, hard remap entry
					} else {
						key := scMapLay[ key ] ? scMapLay[ key ] : key 	; If applicable, soft remap entry
					}
					dicName := key . "ext" . extN
					If ( getKeyInfo( dicName ) != "" )  				; Skip mapping if already defined
						Continue
					If ( InStr( extMapping, "©" ) == 1 )
						cmpKeys.Push( SubStr( extMapping, 2 ) ) 		; Register Compose key for initialization
					tmp := extMapping
					extMapping := hig_deTag( extMapping, dicName )  	; Lop off any HIG tag 	; eD TODO: We don't yet generate Extend images. Could we?
					setKeyInfo( dicName, extMapping )
				}   ; <-- for row (parse extMappings)
			}   ; <-- Loop ext#
		}   ; <-- For stckFile (parse extStck)
		setPklInfo( "extReturnTo", StrSplit( pklIniRead( "extReturnTo"
							, "1/2/3/4", extStck ), "/", " " ) )    	; ReturnTo layers for each Extend layer
		Loop % 4 {
			setLayInfo( "extImg" . A_Index  							; Extend images
				  , fileOrAlt( pklIniPath( "img_Extend" . A_Index ,, "LayStk" ), mainDir . "\extend.png" ) ) 	; eD WIP: Allow imgDir instead
		}   ; <-- loop ext#
	}   ; <-- if ( ExtendKey )
	
	init_Composer( cmpKeys ) 											; Initialise the EPKL Compose tables once for all ©-keys
	
	;;  ============================================================================================================================================
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
		If ( ky2 != key )   											; ... and also, ...
			setKeyInfo( ky2, val )  									; "dk1" = "deadkey1", backwards compatible
	}
	dknames := "deadKeyNames"   										; The .ini section that holds dk names
	For ix, stckFile in dksStck {   									; Go through both DK and Layout files for names
		For ix, row in pklIniSect( stckFile, dknames ) { 				; Make the dead key name lookup table
			pklIniKeyVal( row, key, val )
			If ( val )
				setKeyInfo( key, val )  								; e.g., "dk01" = "dk_dotbelow"
		}
	}
	dkImDir := fileOrAlt( atKbdType( pklIniPath( "img_DKeyDir"  		; Read/set DK image data
						, ".\DeadkeyImg", "LayStk" ) ), mainDir )   	; Default DK img dir: Layout dir or DeadkeyImg
	setLayInfo( "dkImgDir", dkImDir )
	setLayInfo( "dkImgSuf", pklIniRead( "img_DKStateSuf",,, "hig" ) ) 	; DK help img state suffix. "" is the old ""/"sh" style.
	
	;;  ============================================================================================================================================
	;;  Read and set layout on/off icons, initialize the tray menu and the Settings GUI
	;
	ico := readLayoutIcons( "LayStk" )
	setLayInfo( "Ico_On_File", ico.Fil1 )
	setLayInfo( "Ico_On_Num_", ico.Num1 )
	setLayInfo( "Ico_OffFile", ico.Fil2 )
	setLayInfo( "Ico_OffNum_", ico.Num2 )
	pkl_set_tray_menu() 							; Initialize the Tray menu
	init_Settings_UI()  							; Initialize the Settings GUI
}   ; <-- fn initLayIni()

activatePKL() { 									; Activate EPKL single-instance, with a tray icon etc
	SetCapsLockState, Off 							; Remedy those pesky CapsLock hangups at restart
	SetTitleMatchMode % getPklInfo("WinMatchDef") 	; 2: "A window's title can contain WinTitle anywhere inside it to be a match"
	DetectHiddenWindows on
	WinGet, id, list, %A_ScriptName%
	Loop % id {
		id := id%A_Index% 							; If this isn't the first instance...
		PostMessage, 0x398, 422,,, ahk_id %id% 		; ...send a "kill yourself" message to all instances.
	}
	Sleep % 20
	
	Menu, Tray, Icon, % getLayInfo( "Ico_On_File" ), % getLayInfo( "Ico_On_Num_" )
	Menu, Tray, Icon,,, 1 							; Freeze the tray icon
	
	pkl_showHelpImage( 1 ) 							; Initialize/show the help mage...
	ims := bool(pklIniRead("showHelpImage",true)) ? 2 : 3
	Loop % ims {
		pkl_showHelpImage( 2 ) 						; ...then toggle it off if necessary
		Sleep % 42  								; The image flashes on startup if this is too long
	}   											; Repeat image on/off to avoid minimize-to-taskbar bug 	; eD WIP: This is hacky but hopefully effective?!
	setExtendInfo() 								; Prepare Extend info for the first time
	
	Sleep % 200 									; I don't want to kill myself...
	OnMessage( 0x398, "_MessageFromNewInstance" )
	
	SetTimer, pklJanitorTic,  1000  				; Perform regular tasks routine every 1 s
	If bool(pklIniRead("startSuspended")) {
		Suspend
		Gosub afterSuspend
	}
	_pklJanitorLocaleVK( true ) 					; Force the first janitor locale update by calling it with `true`
;	Gosub pklJanitorTic 							; Do the first janitor sweep right away
}   ; <-- fn

changeLayout( nextLayout ) { 						; Rerun EPKL with a specified layout
	Menu, Tray, Icon,,, 1 							; Freeze the tray icon
	Suspend, On
	
	If ( A_IsCompiled )
		Run %A_ScriptName% /f %nextLayout%
	Else
		Run %A_AhkPath% /f %A_ScriptName% %nextLayout%
}

_pklSetInf( pklInfo, def := "" ) {  				; Simple setting for EPKL_Settings entries
	val := pklIniRead( pklInfo, def )   			; Returns def if not found
	val := ( val == "--" ) ? "" : val   			; An `--` entry means empty (useful for overrides)
	setPklInfo( pklInfo, val )
}

_seekBaseLayout( layPath, sameDir, laysDir ) {  						; Look for a BaseLayout file in a specified file path. Return [[baseLays],[baseDirs]].
	static baseIx   := 0
	static baseLays := []
	static baseDirs := []
	
	basePath    := pklIniRead( "baseLayout",, layPath,,1,0 )    		; Read the BaseLayout, with comment stripping, without path dots handling.
	basePath    := dotPath( basePath, sameDir, laysDir )    			; Dot syntax; default to Layouts dir. Done separately to handle layPath vs mainDir.
	SplitPath, basePath, baseLay, baseDir   							; There's no AHK v1 fn for SplitPath; could probably use SplitStr().
	baseLay         := basePath ".ini"
;	(baseIx >= 0 ) ? pklDebug( "basePath: " basePath "`n`nbaseDir: " baseDir "`n`nbaseLay: " baseLay, 24 )    ; eD DEBUG
	If FileExist( baseLay ) && not inArray( baseLays, baseLay ) {
		dummyIx     := baseLays.push( baseLay )
		dummyIx     := baseDirs.push( baseDir )
		If ( ++baseIx == 1 )    										; Increment the base layout index
			setPklInfo( "VarIni_File"   , baseLay ) 					; The "Variant" base layout file path. Only for display in the About menu.
		setPklInfo( "BasIni_File"   , baseLay ) 						; The "Deepest" base layout file path. --"--
		If (   baseIx <  4 )    										; Put a cap on stack depth, for sanity. This value is arbitrarily set.
			newSeek := _seekBaseLayout( baseLay, baseDir, laysDir ) 	; Look for a multi-level BaseStack.
		Return [ baseLays, baseDirs ]   								; Returns an array of arrays for [BaseLays,BaseDirs].
	} Else If ( basePath != laysDir . "\" ) {
		setPklInfo( "BasIni_File"   , "" )
		pklWarning( "The specified BaseLayout file`n'" . baseLay 
					. "'`nwas not found!" ) 							; "File not found" iff base is defined but not present
	}
	Return false
}

_pklStckUp( The, theFile, at1 := 0 ) {  			; Add a support file to the bottom of a LayStack clone
	theStck := getPklInfo( "LayStack" ).Clone() 	; Use a clone, or we'll edit the actual LayStack array
	If FileExist( theFile ) {
		If ( at1 ) { 								; If specified, add at a certain location instead
			theStck.InsertAt( at1, theFile )
		} else {
			theStck.Push(          theFile ) 		; By pushing mapFile at the end of the stack, maps may be overridden.
		}
	}
	setPklInfo( The . "File", theFile )
	setPklInfo( The . "Stck", theStck )
	Return theStck
}

_pklLayRead( type, def := "--", prefix := "" ) { 	; Read kbd type/mods (used in pkl_init) and set Lay info
	pklLays := getPklInfo( "pklLaysFiles" ) 		; Read from the EPKL_Layouts .ini file(s)
	val := pklIniRead( type, def, pklLays ) 		; 
	setLayInfo( "Ini_" . type, val )    			; Store layout info for use with other parts
	val := ( val == "--" ) ? "" : prefix . val  	; Replace -- with nothing, otherwise use prefix
;	val := ( InStr( val, "<", 0 ) ) ? false : val 	; If the value is <N/A> or similar, return boolean false 	; eD WIP: Don't use that anymore
	Return val
}

_pklKbdType( files := "Lays", def := "ISO" ) {  	; Read and set kbd type(s) from Layout(s) files
	If ( files == "Lays" )
		files   := getPklInfo( "pklLaysFiles" ) 	; EPKL_Layouts and its override is the default
	kbd := pklIniRead( "KbdType", def, files )  	; Read from the layout .ini file(s)
	If ( mn := InStr( kbd, "-" ) ) {    			; Tried `split := StrSplit( kbd, "-",, 2 )`. NB: The MaxParts arg used here needs AHK v1.1.28+.
		geo := SubStr( kbd,     mn + 1 )    		; Geometric  board type (RowStagger/Ortho/etc)
		kbd := SubStr( kbd, 1,  mn - 1 )    		; Logical keyboard type (ISO/ANS/ANSI/etc)
	}
	kbd := ( kbd == "ANSI"  ) ? "ANS"   : kbd   	; You can use ANSI as a better-known synonym to the ANS type
	setLayInfo( "Ini_KbdType", kbd )
	geo := ( geo == ""      ) ? "RowS"  : geo   	; RowStag is the default geometry
	setLayInfo( "Ini_GeoType", geo )
	Return kbd
}

_mapKLM( ByRef key, type ) {
	static QWSCdic      := []
	static QWVKdic      := []
	static CoSCdic      := []
	static CoVKdic      := []
	static initialized  := false
	
	If ( not initialized ) {
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
	If ( KLM )
		key := %KLM%%type%dic[ SubStr( key, 3 ) ] 	; [Co|QW][SC|VK]dic from Colemak/QWERTY KLM codes to SC/VK
	Return KLM
}

_checkModName( key ) {  							; Mod keys need only the first letters of their name
	static modAlias := {  "Shift" : "SHF|SH|SHIFT"
						, "Ctrl"  : "CTL|CT|CONTROL"
						, "Alt"   : "ALT|AL|MENU"
						, "Win"   : "WIN|WI|WIN" } 	; Translate VK names to AHK mod names
	static modNames := [ "LShift", "RShift", "CapsLock", "Extend", "SGCaps"
						, "LCtrl", "RCtrl", "LAlt", "RAlt", "LWin", "RWin"
						, "SwiSh", "FliCK" ] 		; SwiSh (SGCaps) & FliCK (FlipCapKey) special mods
	For modName, aliases in modAlias {
		If RegExMatch( key, "i)^(?:vc)?([LR]?)(?:" . aliases . ")$", mat )
			key := mat1 . modName   				; Is key an alias for a mod name (e.g., `LCONTROL`, `RWIN` or `vcLSH`)?
	}   ; <-- For modName (aliases)
	For ix, modName in modNames {
		If ( InStr( modName, key, 0 ) == 1 ) 		; Case insensitive match: Does modName start with key?
			key := modName
	}   ; <-- For modName
	If ( getLayInfo( "LayHasAltGr" ) && key == "RAlt" ) {
		Return "AltGr"  							; RAlt as AltGr
	} else {
		Return key  								; AHK modifier names, e.g., "RS" or "RSh" -> "RShift"
	}
}

_MessageFromNewInstance( lparam ) { 				; Called by OnMessage( 0x0398 ) in pkl_init
	If ( lparam == 422 ) 							; If you run a second EPKL instance, this message is sent
		ExitApp
}
