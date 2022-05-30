setUIGlobals: 													; Declare globals (can't be done inside a function for "global globals")
;	global UI_Set 												; eD WIP: Would like to use UI_Set.MainLay etc, but can't? Single variables needed for UI
	global UI_Tab, UI_Btn1, UI_Btn2, UI_Btn3, UI_Btn4   		; GUI Control vars must be global (or static) to work
	global UI_LayMain, UI_LayType, UI_LayKbTp, UI_LayVari, UI_LayMods
	global UI_KeyRowS, UI_KeyCodS, UI_KeyRowV, UI_KeyCodV, UI_KeyModL, UI_KeyModN, UI_KeyType
	global UI_SetThis, UI_SetThat, UI_SetComm, UI_SetLine
	global UI_LayFile, UI_LayMenu, UI_KeyThis, UI_KeyLine
	global ui_NA        := "<none>" 							; Value used in the UI functions (not a control variable)
	global ui_Reset     := false 								; Boolean for the GUI Reset button
	global ui_KLMs      := []
	global ui_Lay3LAs, ui_KLMp 	;, ui_SepLine, ui_WideTxt
Return

	;; ================================================================================================
	;;  EPKL Settings UI module
	;;  - For a list of AHK GUI Controls, see https://www.autohotkey.com/docs/commands/GuiControls.htm
	;
pklSetUI() { 													; EPKL Settings GUI
	pklAppName  := getPklInfo( "pklName" )
	winTitle    := "EPKL Settings"
	if WinActive( winTitle ) { 									; Toggle the GUI off if it's the active window
		GUI, UI: Destroy
		Return
	}
	ui_SepLine  := "————————————————" . "————————————————" . "————————————————" . "————" . "————" . "————" ;. "————"
	ui_WideTxt  := "                " . "                " . "                " . "    " . "    " ;. "    " . "    "
	ui_WideTxt  .= ui_WideTxt . "  " 							; Standard edit box text, autosizing the box width
	footText    := "`n* Only the topmost active ""<key> ="" line in the section is used."
	footText    .= "`n* Lines starting with a semicolon are commented out (inactive)."
	
	GUI, UI:New,       , %winTitle%
	GUI, UI:Add, Tab3, vUI_Tab gUIhitTab +AltSubmit 			; Multi-tab GUI. AltSubmit gets tab # not name.
			, % "Layout||Settings|Special|KeyMapper"    		; The first tab (double pipe) is default
	
	;; ================================================================================================
	;;  Layout Picker UI
	;
	ui_Lay3LAs  := getPklInfo( "shortLays" ) 					; Dictionary of 3-letter layout name abbreviation (3LA)
	mainLays    := _uiGetDir( "Layouts" ) 						; "Colemak", "Dvorak", "QUARTZ", "QWERTY", "Tarmak"
	layTypes    := [ "eD"   , "VK"  ] 							; Starting values
	kbdTypes    := [ "ANS"  , "ISO" ] 							; --"--
	
	GUI, UI:Add, Text, section 									; 'section' stores the x value for later
					, % "`nLayout Selector for " . pklAppName
					.   "`n" . ui_SepLine 	; ————————————————————————————————————————————————
	_uiAddSel(  "Main layout: "
			,       "LayMain"   , ""            , mainLays              )
	GuiControl, ChooseString, UI_LayMain, % "Colemak" 			; We may have layouts before Colemak in the alphabet
	GUI, UI:Add, Text,      , % "Layout type:"
	GUI, UI:Add, Text, x+92 , % "Keyboard type:" 				; Unsure how this works at other resolutions?
	_uiAddSel(  "" 	;"Layout type:" 							; Place at the x value of the previous section
			,       "LayType"   , "Choose1"     , layTypes  , "xs y+m"  )
	_uiAddSel(  "" 	;"Keyboard type:" 							; Place to the right of the previous control
			,       "LayKbTp"   , "Choose2"     , kbdTypes  , "x+30"    )
	_uiAddSel(  "Variant/Locale, if any: "
			,       "LayVari"   , "Choose1"     , [ ui_NA ] , "xs y+m"  )
	_uiAddSel( "Mods, if any: " 								; Make a box wider than the previous one: "wp+100"
			,       "LayMods"   , "Choose1"     , [ ui_NA ]             ) 	; A default here may fail on the first selection if a nonexisting combo is chosen
	
	_uiAddEdt( "`nIn the Layouts_Override [pkl] section: layout = " 	; eD WIP: Replace this with a ComboBox
			,       "LayFile"   , ""            , ui_WideTxt            )
	layFiles    := [ "--"   , "<add layout>" ] 					; Default entry for the LayFile ComboBox
;	_uiAddSel( "`nIn the Layouts_Override [pkl] section: layout = " 	; eD WIP: For multi-layout select, make this a ComboBox. Use AltSubmit for position selection?
;			,       "LayFile"   , "Choose1 w350"     , layFiles         )
	_uiAddEdt( "`nEPKL Layouts menu name. Edit it if you wish:"
			,       "LayMenu"   , ""            , ui_WideTxt            )
	GUI, UI:Add, Text,, % footText . "`n"
						. "`n* VK layouts only move the keys around, eD maps each shift state."
						. "`n* To get multiple layouts, submit twice then join the entries"
						. "`n    in the Override file on one ""layout ="" line with a comma." . "`n"
	GUI, UI:Add, Button, xs y500  vUI_Btn1  gUIhitLayBtn, &Submit Override
	GUI, UI:Add, Button, xs+250 yp          gUIrevLay   , &Reset
	
	;; ================================================================================================
	;;  Settings UI
	;
	GUI, UI:Tab, 2
	GUI, UI:Add, Text, section 									; 'section' stores the x value for later
					, % "`nGeneral settings for " . pklAppName
					.   "`n" . ui_SepLine 	; ————————————————————————————————————————————————
	setThis := pklIniCSVs( "setInGUI", "showHelpImage, img_HideStates, advancedMode", "PklDic" )
	_uiAddSel(  "Change this setting from Settings_Default: " 	;,"menuLanguage","stickyMods","stickyTime","systemDeadKeys","suspendTimeOut","exitAppTimeOut"
			,       "SetThis"   , "Choose1 w160" , setThis  , "xs y+m" ) 	; Submits the entry itself
	_uiAddEdt( "`nDefault value:"
			,       "SetThat"   , "Disabled"       , ui_WideTxt, "xs y+m" )
	_uiAddEdt( "`nLine comments etc for this option:"
			,       "SetComm"   , "Disabled"       , ui_WideTxt, "xs y+m" ) 	; "cGray" lets you select/view the whole line
	_uiAddEdt( "`n`nSubmit this to the Settings_Override [pkl] section:"
			,       "SetLine"   , ""            , ui_WideTxt, "xs y+m" )
	GUI, UI:Add, Text,, % footText . "`n"
						. "`n* For Yes/No settings you may also use y/n, true/false or 1/0."
						. "`n* There are more settings in the Settings_Default file."
						. "`n* Also, settings are explained somewhat in that file."     . "`n`n"
	GUI, UI:Add, Button, xs y500  vUI_Btn2  gUIhitSetBtn, &Submit Settings
	GUI, UI:Add, Button, xs+250 yp          gUIrevSet   , &Reset
	
	;; ================================================================================================
	;;  Special Keys UI [WIP]
	;
	GUI, UI:Tab, 3
	GUI, UI:Add, Text, section 									; 'section' stores the x value for later
					, % "`nSpecial keys settings for " . pklAppName . " [WIP]"
					.   "`n" . ui_SepLine 	; ————————————————————————————————————————————————
	GUI, UI:Add, Text,, % "" 									; Drop the footText here for clarity
						. "`n"
						. "`n* EPKL has powerful special keys!"
						. "`n"
						. "`n* Extend is a layer modifier, usually replacing the Caps key."
						. "`n* Read more about this in DreymaR's Big Bag of Kbd Tricks!"
						. "`n"
						. "`n* You can get different Extend layers with modifier combos."
						. "`n* For instance, hold RAlt then hold Extend then release RAlt..."
						. "`n* ...while keeping Extend down, to activate a NumPad layer."
						. "`n"
						. "`n* Extend can furthermore do something else on tap instead of hold."
						. "`n* For Ext-tap, tap Extend – with modifiers if you wish."
						. "`n* Combining Ext and Ext-tap, you can have many different layers!"
						. "`n* This is called a MoDK (Mother-of-DeadKeys) Extend."
						. "`n"
						. "`n* Compose is a sequence recognizer. You type a sequence and hit it."
						. "`n* If the Compose key is a CoDeKey, it'll be a dead key too."
						. "`n* A CoDeKey composes if it recognises a sequence, or else is a DK."
						. "`n"
						. "`n* This tab is Work-In-Progress."
						. "`n* Please refer to the Layouts/Settings files for now."
						. "`n* (Note that there can be both default and override files.)"
						. "`n"
	GUI, UI:Add, Button, xs+310 y500        gUIklmShow  , %spc%&Help%spc% 	; Note: Using absolute pos., specify both x & y
	
	;; ================================================================================================
	;;  Key Mapper UI [advanced]
	;
	klmLi1  := "  XX======+======+======+======+======+======+======+======+======+======+======+======+======XX======+======XX======+======+======XX======+======+======+======XX  "
	klmLi2  := "  XX======+======+======+======+======+======+======+======+======+======+======+======+======XX======+======XX======+======+======XX------+------+------+------XX  "
	klmLi3  := "  XX------+------+------+------+------+------+------+------+------+------+------+------+------XX------+------XX------+------+------XX------+------+------+------XX  "
	klmLix  :=     [ 2,3,3,3,1 ] 								; What type of line comes after each row in the ASCII table
	ui_KLMp := klmLi1 											; It starts off with a Line1
	For ix, row in [ 0,1,2,3,4 ] { 								; Get the KLM codes for each keyboard row
		rawRow  := pklIniRead( "QW" . row, "", getPklInfo( "RemapFile" ), "KeyLayoutMap" )
		lix     := klmLix[ ix ]
		ui_KLMp .= "`n  ||" . rawRow . "|  `n" . klmLi%lix% 	; Format the row to the ASCII table layout for later display
		keyRow  := RegExReplace( rawRow, "[|]{2}.*", "|" ) 		; Delete any mappings after a double pipe, as...
		keyRow  := RegExReplace( keyRow, "[ `t]*" ) 			;   ...these are advanced and clutter up the selector
		keyRow  := ( row == 1 ) ? keyRow . "BSP|" : keyRow 		; The KLM map has Backspace on row 0 beyond the ||.
		if ( row > 0 ) 											; Only show row 1-4 in the DDLs
			ui_KLMs[ row ] := keyRow 	;StrSplit( keyRow, "|", " `t" ) 	; Split by pipe
	}
	GUI, UI:Tab, 4
	GUI, UI:Add, Text, section 									; 'section' stores the x value for later
					, % "`nKey mapping editor for " . pklAppName . " [advanced]"
					.   "`n" . ui_SepLine 	; ————————————————————————————————————————————————
	_uiAddSel(  "Mapping type: "
			,       "KeyType"   , "Choose4 +AltSubmit", [ "VirtualKey", "State maps", "Modifier", "Tap-or-Mod", "MoDK" ], "xs y+m" )
	klmRows     := [ "Number", "Upper", "Home", "Lower" ]   	; Num,Upp,Hom,Low. Row 1-4 in the KLM.
	GUI, UI:Add, Text,          , % "SC Row:"
	GUI, UI:Add, Text, x+60     , % "Map from QW Scan code:"
	_uiAddSel(  "" 	;"Row: "
			,       "KeyRowS"   , "Choose3 w70 +AltSubmit" , klmRows  , "xs y+m"  ) 	; Submits row #
	_uiAddSel(  "" 	;"Scan code:"
			,       "KeyCodS"   , "Choose1"     , [ "CLK" ], "x+30"    )
	GUI, UI:Add, Text, xs y+m   , % "VK Row:"
	GUI, UI:Add, Text, x+60     , % "Map to vc VirtualKey code:"
	_uiAddSel(  "" 	;"Row: "
			,       "KeyRowV"   , "Choose1 w70 +AltSubmit" , klmRows  , "xs y+m"  ) 	; Submits row #
	_uiAddSel(  "" 	;"VKey code:"
			,       "KeyCodV"   , "Choose1"     , [ "BSP" ], "x+30"    )
	GUI, UI:Add, Text, xs y+m   , % "L/R:"
	GUI, UI:Add, Text, x+80     , % "Modifier, if applicable:"
	_uiAddSel(  "" 	;"L/R: "
			,       "KeyModL"   , "Choose1 w70" , [ " " ]  , "xs y+m"  ) 	; Submits the entry itself
	_uiAddSel(  "" 	;"Modifier:"
			,       "KeyModN"   , "Choose1"     , [ "Ext", "Shift", "Ctrl", "Alt", "Win" ], "x+30"    )
	_uiAddEdt( "`nKey mapping for the Layouts_Override [layout] section:"
			,       "KeyThis"   , ""            , ui_WideTxt, "xs y+m" )
	_uiAddEdt( "  =  "
			,       "KeyLine"   , ""            , ui_WideTxt, "xs y+m" )
	GUI, UI:Add, Text,, % "" 									; Drop the footText here for clarity
						. "`n* Default settings map CapsLock to Backspace-on-tap, Extend-on-hold."
						. "`n* Press the Help button for useful info including a key code table."
						. "`n* For layout-defined keys, use the ""Write to layout.ini"" button."
						. "`n"
						. "`n* VKey mappings only move keys. Modifier mappings are for Shift-type keys."
						. "`n* State maps specify the output for each modifier state, e.g., Shift + AltGr."
						. "`n* Tap-or-Mod and MoDK keys are a key press on tap and a modifier on hold."
						. "`n* Ext alias Extend is a wonderful special modifier! Read about it elsewhere."
						. "`n"
	spc := A_Space . A_Space
	GUI, UI:Add, Button, xs y500  vUI_Btn4  gUIhitKeyBtn, &Submit Key Mapping
	GUI, UI:Add, Button, x+20               gUIhitKeyLay, &Write to layout.ini
	GUI, UI:Add, Button, xs+310 yp          gUIklmShow  , %spc%&Help%spc% 	; Note: Using absolute pos., specify both x & y
	GUI, UI:Add, Button, xs+250 yp          gUIrevKey   , &Reset
	
	GUI, UI:Show
	Gosub UIselKey  											; First, handle Key Mapper...
	Gosub UIselSet  											; ...then, Settings...
	Gosub UIselLay  											; ...then, Layout
	Gosub UIhitTab
}

	;; ================================================================================================
	;;  UI Control sections
	;
UIhitTab: 														; When a tab is selected, make its button the default.
	GUI, UI:Submit, Nohide 										; Not needed: 'GUI, +LastFound'? GuiControlGet,thisTab,,UI_Tab
	GuiControl, +Default, UI_Btn%UI_Tab%
Return

UIselLay: 														; Handle UI Layout selections
	GUI, UI:Submit, Nohide
	mainDir := "Layouts\" . UI_LayMain
	main3LA := ( ui_Lay3LAs[UI_LayMain] ) ? ui_Lay3LAs[UI_LayMain] : SubStr( UI_LayMain, 1, 3 )
	need        := main3LA . "-" 								; Needle for the MainLay: '3LA-', e.g., 'Cmk-'
	layPath := {} 												; Variant folders for locales etc may contain several mods
	layDirs := [] 												; Layout folders hold the layouts themselves
	For ix, theDir in _uiGetDir( mainDir ) { 					; Get a layout directory list for the chosen MainLay
		ourDir := mainDir . "\" . theDir
		if not RegExMatch( theDir, need ) 						; '3LA-<LayType>'
			Continue 											; Layout folders have a name on the form 3LA-LT[-LV]_KbT[_Mods]
		For i2, subDir in _uiGetDir( ourDir ) { 				; Scan each subdir for variant folders
			if not RegExMatch( subDir, need . ".+_" ) 			; '3LA-<LayType>[-<LayVar>]_<KbdType>[_<LayMods>]'
				Continue 										; Layout folders have a name on the form 3LA-LT[-LV]_KbT[_Mods]
			if not FileExist( ourDir . "\" . subDir . "\" . getPklInfo("LayFileName") )
				Continue 										; Layout folders contain a layout.ini file
			layDirs.Push( subDir )
			layPath[ subDir ] := theDir . "\"
		} 	; end For subDir
		if not RegExMatch( theDir, need . ".+_" ) 				; '3LA-<LayType>[-<LayVar>]_<KbdType>[_<LayMods>]'
			Continue 											; Layout folders have a name on the form 3LA-LT[-LV]_KbT[_Mods]
		if not FileExist( ourDir . "\" . getPklInfo("LayFileName") )
			Continue 											; Layout folders contain a layout.ini file
		layDirs.Push( theDir )
		layPath[ theDir ] := ""
	} 	; end For theDir
	layTyps     := _uiCheckLaySet( layDirs, 1, 2, need   )  	; Get the available Lay Types for the chosen MainLay
	_uiControl( "LayType", _uiPipeIt( layTyps, 1 ) ) 			; Update the LayType list (eD, VK)
	needle      := need . UI_LayType
	kbdTyps     := _uiCheckLaySet( layDirs, 2, 0, need   )  	; Get the available Kbd Types for the chosen MainLay (and LayType?)
	_uiControl( "LayKbTp", _uiPipeIt( kbdTyps, 1 ) )
	needle      := need . UI_LayType . ".*_" . UI_LayKbTp . "?(_|$)" 	; The bit after KbTp separates types like ISO-Orth from ISO
	layVari     := _uiCheckLaySet( layDirs, 1, 3, needle )  	; Get the available Layout Variants for the chosen MainLay/LayType/LayKbTp
	_uiControl( "LayVari", _uiPipeIt( layVari, 1 ) )
	layVariName := ( UI_LayVari == ui_NA ) ? "" : "-" . UI_LayVari
	needle      := need . UI_LayType . layVariName . "_" . UI_LayKbTp . "?(_|$)"
	layMods     := _uiCheckLaySet( layDirs, 3, 0, needle )  	; Get the available Mods for the chosen MainLay/LayType/LayKbTp/LayVari
	_uiControl( "LayMods", _uiPipeIt( layMods, 1 ) )
	layModsName := ( UI_LayMods != ui_NA ) ? UI_LayMods : ""
	layModsPref := ( layModsName ) ? "_" : ""
	layFolder   := main3LA . "-" . UI_LayType . layVariName . "_" . UI_LayKbTp . layModsPref . layModsName
	layPath     := layPath[ layFolder ]
;	( 1 ) ? pklDebug( "`nDir:  " . layFolder . "`nPath: " . layPath , 1 )  ; eD DEBUG
;	_uiControl( "LayFile", 
;	ControlGet, tmpList, List, ,ComboBox6, EPKL Settings 		; The DDL boxes are counted as ComboBox
;	( 1 ) ? pklDebug( "" . tmpList, 3 )  ; eD DEBUG
	_uiControl( "LayFile", UI_LayMain . "\" . layPath . layFolder ) 	; eD WIP: Make this update the right line in the LayFile ComboBox
	layMenuName := UI_LayMain . "-" . UI_LayType . layVariName . " " . layModsName . "(" . UI_LayKbTp . ")"
	_uiControl( "LayMenu", layMenuName )
Return

UIselKey: 														; Handle UI Key Mapping selections
	GUI, UI:Submit, Nohide
	_uiControl( "KeyCodS", "|" . ui_KLMs[ UI_KeyRowS ]  )
	_uiControl( "KeyCodV", "|" . ui_KLMs[ UI_KeyRowV ]  )
	_uiControl( "KeyThis", "QW" . UI_KeyCodS            )
	keyModL := ( UI_KeyModN == "Ext" ) ? "| |" : "| |L|R|"
	_uiControl( "KeyModL", keyModL  )
	modifer := ( UI_KeyModL == " " ) ? UI_KeyModN : UI_KeyModL . UI_KeyModN
	vcVK    :=  "vc" . UI_KeyCodV
	case    :=  UI_KeyType 										; eD TODO: The Switch command only appears with AHK v1.1.31+!
	mapping :=  ( case == 1 ) ? vcVK . " VKey" 					; [ "VirtualKey", "StateMaps", "Modifier", "Tap-or-Mod", "MoDK" ]
			:   ( case == 2 ) ? vcVK .                 " 	1   	a   	A   	--  	á   	α   "
			:   ( case == 3 ) ?              modifer . " Modifier"
			:   ( case == 4 ) ? vcVK . "/" . modifer . " VKey"
			:   ( case == 5 ) ? vcVK . "/" . modifer . " 	0   	@ex0	@ex1	@ex2	@ex6	@ex7"
			:                   " --"
	_uiControl( "KeyLine", mapping )
	if InStr( "12", case ) { 									; These cases don't use the modifier controls
		GuiControl, Disable , UI_KeyModL
		GuiControl, Disable , UI_KeyModN
	} else {
		GuiControl, Enable  , UI_KeyModL
		GuiControl, Enable  , UI_KeyModN
	}
Return

UIselSet: 														; Handle UI Settings selections
	GUI, UI:Submit, Nohide
	currVal := pklIniRead( UI_SetThis, "<N/A>"          ) 		; Read from SetStck. Strip EOL comments.
	_uiControl( "SetLine", currVal )
	settIni := getPklInfo( "File_PklSet" ) . "_Default.ini" 	; The Settings_Default file
	settVal := pklIniRead( UI_SetThis, "<N/A>", settIni )
	_uiControl( "SetThat", settVal )
	settCom := pklIniRead( UI_SetThis, "<N/A>", settIni, , 0 ) 	; Read from default. Don't strip comments.
	settCom := RegExReplace( settCom, "^" . settVal . "[ `t]*;[ `t]*" )
	settCom := RegExReplace( settCom, "[`t]+"   , "  " )
	settCom := RegExReplace( settCom, "[ ]{3,}" , "  " ) 		; Compactify whitespace
	_uiControl( "SetComm", settCom )
Return

UIklmShow:  													; Show the KLM code table GUI and other info
	hlpText :=  ""
;			.   "EPKL Key Mapper help:"
			. "`nFirstly: This is a complex topic! Please refer to the BigBag web pages and read inside the relevant EPKL files if you wish to understand it better."
			. "`nDreymaR's Big Bag of Keyboard Tricks is found at: https://dreymar.colemak.org"
			. "`n"
			. "`n•   V I R T U A L K E Y   A N D   S T A T E   M A P P I N G"
;			. "`n•   V i r t u a l K e y   A n d   S t a t e   M a p p i n g"
			. "`n"
			. "`n- VirtualKey (VK) mapping a key means that a key press is emulated and as a result whatever is in the system layout for that key is sent."
			. "`n- State mappings such as [eD] are different: They send characters directly into the Input Stream, so you can send anything regardless of the system layout."
			. "`n"
			. "`n- State mappings can be lots of different things, from simple characters via AHK syntax and PowerStrings to advanced dead or Compose/Completion/Repeat keys."
			. "`n- To learn more about the most powerful options, read in the main Readme file about EPKL Prefix-Entry syntax, Extend, dead keys, Compose and more."
			. "`n- Also look in the Files folder and study these files: Compose, DeadKeys, Extend and PowerStrings."
			. "`n- Shift states for state maps are: [#]  Unshifted  Shifted  Ctrl  AltGr  Shift+AltGr. Usually, ignore the initial CapsBehavior number and don't map the Ctrl state."
	pesText :=  ""
			.   "    This is an overview of EPKL prefix-entry syntax:"  	; . ui_PrefEntr
	pesTabl :=  ""
			.   "  X=======================================================================================================================X"
			. "`n  |  EPKL prefix-entry syntax is useable in layout state mappings, Extend, Compose, PowerString and dead key entries.     |"
			. "`n  |  - There are two equivalent prefixes for each entry type: One easy-to-type ASCII, one from the eD Shift+AltGr layer.  |"
			. "`n  |      →  |  %  : Send a literal string/ligature by the SendInput {Text} method                                         |"
			. "`n  |      §  |  $  : Send a literal string/ligature by the SendMessage method                                              |"
			. "`n  |      α  |  *  : Send entry as AHK syntax in which !+^# are modifiers, and {} contain key names                        |"
			. "`n  |      β  |  =  : Send {Blind}‹entry›, keeping the current modifier state                                               |"
			. "`n  |      †  |  ~  : Send the hex Unicode point U+<entry> (normally but not necessarily 4-digit)                           |"
			. "`n  |      Ð  |  @  : Send the current layout's dead key named ‹entry› (often a 3-character code)                           |"
			. "`n  |      ¶  |  &&  : Send the current layout's powerstring named ‹entry›; some are abbreviations like &&Esc, &&Tab…          |" 	; Need to && escape the &amp;
			. "`n  |  - Any entry may start with «#» with '#' one or more characters to display on help images for the following mapping.  |"
			. "`n  |  - Other advanced state mappings:                                                                                     |"
			. "`n  |      ®® |  ®# : Repeat the previous character. '#' may be a hex number. Nice for avoiding same-finger bigrams.        |"
			. "`n  |      ©‹name›  : Named Compose key, replacing the last written character sequence with something else.                 |"
			. "`n  |      ##       : Send the active system layout's Virtual Key code. Good for OS shortcuts, but EPKL can't see it.       |"
			. "`n  X=======================================================================================================================X"
	klmText :=  ""
			.   "•   K E Y   C O D E S   A N D   R E M A P P I N G"
			. "`n"
			. "`n- EPKL maps keys using their scan codes. 'QW_' codes denote QWERTY locations, see the table below."
			. "`n- Keys may get moved around by mod remaps such as ergo mods. When key mapping, map to the unmodded location (the N key is still N)."
			. "`n- Example: Standard Colemak has G on the top row, where Colemak-DH has B. To remap the B key for Cmk-DH, refer to it by its vanilla position QW_B (or Co_B)."
			. "`n"
			. "`n    This is a table of all KeyLayoutMap codes from the _eD_Remap.ini file, useable both as ""Map from QW"" Scan Codes and ""Map to vc"" Virtual Key codes."
			. "`n    You can edit the key mapping lines directly to any valid key codes and mappings. The KLM codes to the right, for example, aren't in the dropdown lists."
	GUI, KLM:New    , ToolWindow , Key Mapper Help & KLM Code Table
	GUI, KLM:Add    , Text,      , % hlpText    				; Help introduction
	GUI, KLM:Add    , Text,      , % pesText    				; Syntax-Entry table w/ intro text
	GUI, KLM:Font   , s10 , Courier New
	GUI, KLM:Add    , Text,      , % pesTabl . "`n"
	GUI, KLM:Font   											; (Restore the default system font)
	GUI, KLM:Add    , Text,      , % klmText    				; KLM key code table, generated above
	GUI, KLM:Font   , s10 , Courier New
	GUI, KLM:Add    , Text,      , % ui_KLMp . "`n" 			; The table is made from the Remap file KLM table
	GUI, KLM:Font
	GUI, KLM:Add, Button, gUIklmHide Default, &Hide
	GUI, KLM:Show   , x16 y16 									; Show the help window in the screen corner
Return

UIklmHide: 														; Hide the KLM code table GUI
	GUI, KLM:Destroy
Return

UIhitLayBtn: 													; Submit Layout Override button pressed
	GUI, UI:Submit, Nohide
	layLine := UI_LayFile . ":" . UI_LayMenu
	_uiWriteOverride(   "layout"    ,    layLine    , "Layout Picker"
		, "pkl"     , getPklInfo( "File_PklLay" )   , "_Override_Example" )
Return

UIhitKeyBtn: 													; Submit Key Mapping button pressed
	GUI, UI:Submit, Nohide
	_uiWriteOverride( UI_KeyThis    , UI_KeyLine    , "Key Mapper"
		, "layout"  , getPklInfo( "File_PklLay" )   , "_Override_Example" )
Return

UIhitKeyLay: 													; Submit Key Mapping to layout.ini button pressed
	GUI, UI:Submit, Nohide
	_uiWriteOverride( UI_KeyThis    , UI_KeyLine    , "Key Mapper"
		, "layout"  , "Layouts\" . getLayInfo( "ActiveLay" ) . "\layout", "" )
Return

UIhitSetBtn: 													; Submit Settings button pressed
	GUI, UI:Submit, Nohide
	_uiWriteOverride( UI_SetThis    , UI_SetLine    , "Settings"
		, "pkl"     , getPklInfo( "File_PklSet" )   , "_Default" )
Return

UIrevLay: 														; Reverse any UI setting by deleting its UI entries
	ui_Reset := true
	gosub UIhitLayBtn
	gosub UIselLay
Return

UIrevKey: 														; Reverse any UI setting by deleting its UI entries
	ui_Reset := true
	gosub UIhitKeyBtn
;	gosub UIhitKeyLay 											; eD WIP: How to handle this?
	gosub UIselKey
Return

UIrevSet: 														; Reverse any UI setting by deleting its UI entries
	ui_Reset := true
	gosub UIhitSetBtn
	gosub UIselSet
Return

	;; ================================================================================================
	;;  UI functions
	;
_uiControl( var, values ) { 									; Update an UI Control with new values and, if applicable, choice
	var := "UI_" . var 											; Name of the global UI var
	val := %var% 												; Content of the UI var
	GuiControl, , %var%, %values% 								; This also works for edit/text controls
	if InStr( values, val ) { 									; Try to keep the chosen option in a DDL, or take the first choice
		GuiControl, ChooseString, %var%, %val%
	} else {
		GuiControl, Choose      , %var%, 1
	}
	GUI, UI:Submit, Nohide 										; Needed to update the GUI values (or maybe I could've used |%val% ?)
}

_uiAddEdt( iTxt, var, opts, editTxt, pos = "" ) { 				; Add an Edit box with text
	GUI, UI:Add, Text,           %pos% , % iTxt
	GUI, UI:Add, Edit, vUI_%var% %opts%, % editTxt
}

_uiAddSel( iTxt, var, opts, listArr, pos = "", typ = "DDL" ) { 	; Add a DropDownList selection box with text and some choices
	listStr := _uiPipeIt( listArr, 0, 0 )
	if ( iTxt ) {
		GUI, UI:Add, Text, %pos%, % "" . iTxt 					; Whitespace pad the text a little?
	} else {
		opts .= " " . pos
	}
	mod := SubStr( var, 1, 3 ) 									; UI_Lay####, Key, Set
	GUI, UI:Add, %typ% , gUIsel%mod% vUI_%var% %opts%, % listStr
}

_uiGetDir( getDir, theVar = "" ) { 								; Get a list of a directory in an array
	dirs := ( theVar ) ? theVar : [] 							; If starting with entries, add to them
	Loop, Files, % getDir . "\*", D
	{
		theDir := A_LoopFileName
		if ( SubStr( theDir, 1, 1 ) != "_" )
			dirs.Push( theDir )
	}
	Return dirs
}

_uiPipeIt( listArr, sort = 0, clear = 1 ) { 					; Convert an array to a pipe delimited list, e.g., for DDLs
	For ix, elem in listArr { 									; eD WIP: Use IfObject to make it more robust?
		pipe        := ( listStr ) ? "|" : ""
		listStr     .= pipe . elem
	} 	; end For
	if sort
		Sort, listStr, D| U 									; Sort options: U - Unique, D# - use # as delimiter
	listStr := ( clear ) ? "|" . listStr : listStr 				; Prepend "|" if replacing the list
	Return listStr
}

_uiCheckLaySet( dirList, splitUSn, splitMNn = 0, needle = "" ) {
	theList     := []
	For ix, item in dirList {
		splitUS := StrSplit( item, "_" )
		splitMN := StrSplit( splitUS[splitUSn], "-" )
		match   := ( splitMNn ) ? splitMN[splitMNn] : splitUS[splitUSn]
		match   := ( match ) ? match : ui_NA 					; If there isn't a third part, there's no variant/mods
		if ( needle ) { 										; Check if this match works with the other chosen ones
			if not RegExMatch( item, needle ) 					; InStr( item, needle ) for a simple search
				Continue
		} 	; end if needle
		if not hasValue( theList, match ) 						; Add the match if it isn't added yet
			theList.Push( match )
	} 	; end For
	Return theList
}

_uiWriteOverride( key, layLine, module = "Settings" 			; Write a line to Override. If necessary, make the file first.
	, section = "pkl", ovrFile = "EPKL_Settings", tplFile = "" ) {
	revert  := ui_Reset
	ui_Reset := false
	a_SC    := "`;"
	ini     := ".ini"
	tplFile := ( tplFile ) ? ovrFile . tplFile : ""
	ovrFile .= ( tplFile ) ? "_Override" : "" 					; If there isn't a template, use the main file as its override
	if not FileExist( ovrFile . ini ) { 						; If there isn't an Override file...
;		( 1 ) ? pklDebug( "`ntpl: " . tplFile . "`novr: " . ovrFile, 4 )  ; eD DEBUG
		if ( tplFile && not revert ) {
			MsgBox, 0x021, Make Override file?, 				; 0x100: 2nd button default. 0x20: Exclamation. 0x1: OK/Cancel
(
EPKL %module% Submit
—————————————————————————————

EPKL uses Override files for settings,
to avoid messing with the Default files.
No "%ovrFile%" was detected.

Would you like to create one from %tplFile%.ini?
)
			makeFile := false
			IfMsgBox, Cancel
				Return
			IfMsgBox, OK
				makeFile := true
			if makeFile {
				if not tmpFile := pklFileRead( tplFile . ini )
					Return
				laySect := "`r`n[layout]`r`n"
				laySect := InStr( tmpFile, laySect ) ? laySect : ""
				tmpFile := RegExReplace( tmpFile, "s)\R\[pkl\]\R\K.*" )
				tmpFile .= laySect
				if not pklFileWrite( tmpFile, ovrFile . ini )
					Return
			} 	; end if makeFile
		} else {
			Return
		} 	; end if tplFile
	} 	; end if not FileExist ovrFile
	makeLine := false 											; Make the new line and tidy up old ones
	if revert {
		MsgBox, 0x021, Reset Override?,
(
EPKL %module% Reset
—————————————————————————————

Revert this setting to default: %key%

in the [%section%] section of %ovrFile%.ini?
)
	} else {
		MsgBox, 0x021, Write Override line?, 					; 0x100: 2nd button default. 0x20: Exclamation. 0x1: OK/Cancel
(
EPKL %module% Submit
—————————————————————————————

Write this line to the [%section%] section of
%ovrFile%.ini ?

%key% = %layLine%
)
	} 	; end if revert
	IfMsgBox, Cancel 											; MsgBox type is 0x3 (Yes/No/Cancel) + 0x30 (Warning) + 0x100 (2nd button is default)
		Return
	IfMsgBox, OK
		makeLine := true
	if not makeLine
		Return
	if not tmpFile := pklFileRead( ovrFile . ini ) 				; The standard IniWrite writes to the end of the section. We want the start.
		Return
	FileDelete, % ovrFile . ini 								; In order to rewrite the file and not just append to it, it must be deleted.
	maxEntr := revert ? 0 : 4 									; Delete old UI entries with the same key over this number.
	comText := a_SC . " Generated by the EPKL " . module . " UI, "
	inSect  := false
	rows    := ""
	count   := 0
	For ix, row in StrSplit( tmpFile, "`r`n" ) { 				; Parse the file by rows (could use "`n", "`r" )
		if ( InStr( row, "[" . section . "]" ) == 1 ) { 		; We're in the right section
			inSect := ix 		; true
		} else if ( inSect ) { 	; && ix > inSect
			if RegExMatch( row, "\[.+\]" ) { 					; Start of next section 	; ( InStr( row, "[" ) == 1 )
				inSect := false
			}
			if ( InStr( row, comText ) && InStr( row, key . " = " ) ) {
				if ( count++ >= maxEntr ) 						; Only count UI generated lines with the same key
					Continue 									; Delete/skip old lines if too many
				row := ( SubStr( row, 1, 1 ) == a_SC ) ? row : a_SC . row 	; Comment out old submitted lines
			} 	; end if InStr
		} 	; end if inSect
		rows := rows . "`r`n" . row
	} 	; end For row
	tmpFile := SubStr( rows, 3 ) 								; Lop off the initial line break from 'rows =' above
	if not revert {
		layLine := key . " = " . layLine . " `t`t" . comText . thisMinute()
		secStrt := "s)\R\[" . section . "\]" 					; s: Match including line breaks
		tmpFile := RegExReplace( tmpFile, secStrt . "\R\K(.*)", layLine . "`r`n$1" )
	}
	if not pklFileWrite( tmpFile, ovrFile . ini )
		Return
;	pklInfo( "Write successful.`n`nRefreshing EPKL with the chosen settings.", 3 )
	MsgBox, 0x021, Refresh EPKL?,		 					; 0x100: 2nd button default. 0x20: Exclamation. 0x1: OK/Cancel
(
Write successful.

Refresh EPKL now to use the chosen setting?

You can also refresh it later by the tray menu,
or by the Refresh hotkey (default Ctrl+Shift+5).
)
	IfMsgBox, OK
		gosub rerunWithSameLayout
} 	; end fn
