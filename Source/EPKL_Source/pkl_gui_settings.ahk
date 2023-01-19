;; ================================================================================================
;;  EPKL Settings UI module
;;  - Handles the EPKL Layout/Settings... menu, consisting of several settings tabs
;;  - It writes your choices to the right EPKL Override files, generating these first as necessary.
;;  - Note: To Reset a certain choice, the same choice (.ini key) needs to be currently selected.
;;  - For a list of AHK GUI Controls, see https://www.autohotkey.com/docs/commands/GuiControls.htm
;

setUIGlobals:   												; Declare globals (can't be done inside a function for "global globals")
;	global UI_Set    											; eD WIP: Would like to use UI_Set.MainLay etc, but can't? Single variables needed for UI
	global UI_Tab, UI_Btn1, UI_Btn2, UI_Btn3, UI_Btn4   		; GUI Control vars must be global (or static) to work
	global UI_LayMain, UI_LayType, UI_LayKbTp, UI_LayVari, UI_LayMods   				; Layout Selector    UI variables
	global UI_SetThis, UI_SetDefs, UI_SetComm, UI_SetLine   							; General Settings   UI variables
	global UI_KeyRowS, UI_KeyCodS, UI_KeyRowV, UI_KeyCodV, UI_KeyModL, UI_KeyModN, UI_KeyType
	global UI_KeyThis, UI_KeyLine, UI_LayFile, UI_LayMenu   							; KeyMapper & Layout UI variables
	global UI_SpcExtS, UI_SpcExLn, UI_SpcCmpS, UI_SpcCoLn, UI_SpcCDLn ;, UI_SpcCDCo   	; Special Keys       UI variables
	global ui_NA        := "<none>" 							; For UI functions (Note: ui_### aren't control variables like UI_###)
	global ui_Revert    := false 								; For the GUI Reset button
	global ui_Written   := false 								; For whether EPKL Refresh is needed
	global ui_KLMs      := []   								; For the Help UI, showing the KLM code table
	global ui_KLMp  	;, ui_SepLine, ui_WideTxt
Return

pklSetUI() { 													; EPKL Settings GUI
	pklAppName  := getPklInfo( "pklName" )
	winTitle    := "EPKL Settings"
	if WinActive( winTitle ) {  								; Toggle the GUI off if it's the active window
		GUI, UI: Destroy
		Return
	}
	SP          := A_Space . A_Space
	BL          := 524  										; Position of the button line, in px from the top
	ui_SepLine  := "————————————————" . "————————————————" . "————————————————" . "————" . "————" . "————" . "————"
	ui_WideTxt  := "                " . "                " . "                " . "    " . "    " . "    " ;. "    "
	ui_WideTxt  .= ui_WideTxt . "  " 							; Standard edit box text, autosizing the box width
	footText    := ""
				.  "`n* Settings are written to an _Override.ini file, in the appropriate [section]."
				.  "`n* Only the topmost active ""<key> = <entry>"" line in a section is used."
				.  "`n* Lines starting with a semicolon are commented out (disabled).`n"
	
	GUI, UI:New,       , %winTitle%
	GUI, UI:Add, Tab3, vUI_Tab gUIhitTab +AltSubmit 			; Multi-tab GUI. AltSubmit gets tab # not name.
			, % "Layout||Settings|Special Keys|Key Mapper"  	; The tab followed by double pipes is default
	
	;; ================================================================================================
	;;  Layout Picker UI
	;
	GUI, UI:Add, Text, section  								; 'section' stores the x value for later
					, % "`nLayout Selector for " . pklAppName
					.   "`n" . ui_SepLine 	; ————————————————————————————————————————————————
	choices     := _uiGetDir( "Layouts" ) 								; LayMain values: "Colemak", "Dvorak", ... , "Tarmak"
	_uiAddSel(  "Main layout: "
			,       "LayMain"   , ""            , choices               )
	GuiControl, ChooseString, UI_LayMain, % "Colemak"   				; We may have layouts before Colemak in the alphabet
	GUI, UI:Add, Text,      , % "Layout type:"
	GUI, UI:Add, Text, x+92 , % "Keyboard type:" 						; Unsure how this works at other resolutions?
	choices     := [ "eD"   , "VK"  ]   								; LayType starting values
	_uiAddSel(  "" 	;"Layout type:" 									; Place at the x value of the previous section
			,       "LayType"   , "Choose1"     , choices   , "xs y+m"  )
	choices     := [ "ANS"  , "ISO" ]   								; KbdType starting values
	_uiAddSel(  "" 	;"Keyboard type:"   								; Place to the right of the previous control
			,       "LayKbTp"   , "Choose2"     , choices   , "x+30"    )
	_uiAddSel(  "Variant/Locale, if any: "
			,       "LayVari"   , "Choose1"     , [ ui_NA ] , "xs y+m"  )
	_uiAddSel( "Mods, if any: " 										; Make a box wider than the previous one: "wp+100"
			,       "LayMods"   , "Choose1"     , [ ui_NA ]             )
																		; (A default here may fail on the first selection if a nonexisting combo is chosen)
	_uiAddEdt( "`nIn the Layouts_Override [pkl] section: layout = " 		; eD WIP: Replace this with a ComboBox
			,       "LayFile"   , ""            , ui_WideTxt            )
	layFiles    := [ "--"   , "<add layout>" ]  						; Default entry for the LayFile ComboBox
;	_uiAddSel( "`nIn the Layouts_Override [pkl] section: layout = " 		; eD WIP: For multi-layout select, make this a ComboBox. Use AltSubmit for position selection?
;			,       "LayFile"   , "Choose1 w350"     , layFiles         )
	_uiAddEdt( "`nEPKL Layouts menu name. Edit it if you wish:"
			,       "LayMenu"   , ""            , ui_WideTxt            )
	GUI, UI:Add, Text,, % footText
						. "`n* VK layouts only move the keys around, eD maps each shift state."
						. "`n* To get multiple layouts, submit twice then join the entries"
						. "`n    in the Override file on one ""layout ="" line with a comma." . "`n"
	GUI, UI:Add, Button, xs y%BL% vUI_Btn1  gUIsubLaySel, &Submit Layout Choice
	GUI, UI:Add, Button, xs+244 yp          gUIrevLay   , %SP%&Reset%SP% 	; Note: Using absolute pos., specify both x & y
	
	;; ================================================================================================
	;;  General Settings UI
	;
	GUI, UI:Tab, 2
	GUI, UI:Add, Text, section  								; 'section' stores the x value for later
					, % "`nGeneral settings for " . pklAppName
					.   "`n" . ui_SepLine 	; ————————————————————————————————————————————————
	setThis := pklIniCSVs( "setInGUI", "showHelpImage, img_HideStates, advancedMode", "PklDic" )
	_uiAddSel(  "Change this setting from Settings_Default: " 	;,"menuLanguage","stickyMods","stickyTime","systemDeadKeys","suspendTimeOut","exitAppTimeOut"
			,       "SetThis"   , "Choose1 w160" , setThis  , "xs y+m" ) 		; Submits the entry itself
	_uiAddEdt( "`nDefault value:"
			,       "SetDefs"   , "Disabled"       , ui_WideTxt, "xs y+m" )
	_uiAddEdt( "`nLine comments etc for this option:"
			,       "SetComm"   , "Disabled"       , ui_WideTxt, "xs y+m" ) 	; "cGray" lets you select/view the whole line
	_uiAddEdt( "`n`nSubmit this to the Settings_Override [pkl] section:"
			,       "SetLine"   , ""            , ui_WideTxt, "xs y+m" )
	GUI, UI:Add, Text,   xs y390, % footText    				; Make the text position as in the previous tab
						. "`n* For Yes/No settings you may also use y/n, true/false or 1/0."
						. "`n* There are even more settings in the Settings_Default file."
						. "`n* Also, settings are explained somewhat better in that file."     . "`n`n"
	GUI, UI:Add, Button, xs y%BL% vUI_Btn2  gUIsubSetSel, &Submit Setting%SP%
	GUI, UI:Add, Button, xs+244 yp          gUIrevSet   , %SP%&Reset%SP%
	
	;; ================================================================================================
	;;  Special Keys UI
	;
	GUI, UI:Tab, 3
	GUI, UI:Add, Text, section  								; 'section' stores the x value for later
					, % "`nSpecial keys settings for " . pklAppName ;. " [WIP]"
					.   "`n" . ui_SepLine 	; ————————————————————————————————————————————————
	choices     :=  [ "CapsLock           	(waste.)"
					, "Backspace         	(oki...)"
					, "Extend key         	(wowza!)"
					, "Back/Extend      	(fancy!)"
					, "Mother-of-DK      	(POWAH!)"   ]
	_uiAddSel(  "CapsLock key behavior, and the resultant mapping entry:"
			,       "SpcExtS"   , "Choose3 w170 +AltSubmit" , choices   , "xs y+m" )
	_uiAddEdt(  ""  ;"CapsLock/Extend key mapping entry:"
			,       "SpcExLn"   , ""                        , ui_WideTxt, "xs y+m" )
	choices     :=  [ "ISO102 / <LSGT>"
					, "Right Ctrl"
					, "Right Win"
					, "PrintScreen"
					, "Menu"                ]
	_uiAddSel(  "`n`nCompose key location, and the resultant mapping entry:"
			,       "SpcCmpS"   , "Choose3 w170 +AltSubmit" , choices   , "xs y+m" )
	_uiAddEdt(  ""  ;"Compose key mapping entry:"
			,       "SpcCoLn"   , ""                        , ui_WideTxt, "xs y+m" )
;	choices     :=  [ "These named Compose keys double as CoDeKeys [Compose+DeadKeys]:" ]
;	_uiAddSel(  "", "SpcCDCo"   , "Checked1 -Wrap"          , choices,, "CheckBox" )  	; Fn piggybacking w/ type DDL -> CheckBox. "-Wrap" is said to be more robust.
	_uiAddEdt(  "These named Compose keys double as CoDeKeys [Compose+DeadKeys]:"
			,       "SpcCDLn"   , ""                        , ui_WideTxt, "xs y+m" )
	GUI, UI:Add, Text,, % "`n`n`n`n`n`n`n"  				; (I'm dropping the footText here for clarity)
						. "`n* EPKL has powerful special keys! This tab simplifies their activation."
						. "`n* Press Help for info, and read more in DreymaR's Big Bag of Kbd Tricks."
						. "`n"
						. "`n* The mapping lines above get written to the Layouts_Override [layout] section."
						. "`n* The lines are freely editable before submission, e.g., to change key codes."
						. "`n* You could also achieve the same with the Key Mapper tab or direct file editing."
						. "`n* Click Help for more info, and/or look inside the EPKL_Layouts .ini files."
						. "`n"
	GUI, UI:Add, Button, xs y%BL% vUI_Btn3  gUIsubSpcExt, &Submit Extend Key
	GUI, UI:Add, Button, x+14   yp          gUIsubSpcCmp, Submit &Compose Key
	GUI, UI:Add, Button, xs+244 yp          gUIrevSpc   , %SP%&Reset%SP%
	GUI, UI:Add, Button, xs+310 yp          gUIhlpShow  , %SP%&Help%SP%
	
	;; ================================================================================================
	;;  Key Mapper UI [advanced]
	;
	klmLi1  := "  XX======+======+======+======+======+======+======+======+======+======+======+======+======XX======+======XX======+======+======XX======+======+======+======XX  "
	klmLi2  := "  XX======+======+======+======+======+======+======+======+======+======+======+======+======XX======+======XX======+======+======XX------+------+------+------XX  "
	klmLi3  := "  XX------+------+------+------+------+------+------+------+------+------+------+------+------XX------+------XX------+------+------XX------+------+------+------XX  "
	klmLix  :=     [ 2,3,3,3,1 ] 								; What type of line comes after each row in the ASCII table
	ui_KLMp := klmLi1   										; It starts off with a Line1
	For ix, row in [ 0,1,2,3,4 ] {  							; Get the KLM codes for each keyboard row
		rawRow  := pklIniRead( "QW" . row, "", getPklInfo( "RemapsFile" ), "KeyLayoutMap" )
		lix     := klmLix[ ix ]
		ui_KLMp .= "`n  ||" . rawRow . "|  `n" . klmLi%lix% 	; Format the row to the ASCII table layout for later display
		keyRow  := RegExReplace( rawRow, "[|]{2}.*", "|" )  	; Delete any mappings after a double pipe, as...
		keyRow  := RegExReplace( keyRow, "[ `t]*" ) 			;   ...these are advanced and clutter up the selector
		keyRow  := ( row == 1 ) ? keyRow . "BSP|" : keyRow 		; The KLM map has Backspace on row 0 beyond the ||.
		if ( row > 0 )  										; Only show row 1-4 in the DDLs
			ui_KLMs[ row ] := keyRow 	;StrSplit( keyRow, "|", " `t" ) 	; Split by pipe
	} 	; end For KLM codes
	GUI, UI:Tab, 4
	GUI, UI:Add, Text, section  								; 'section' stores the x value for later
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
			,       "KeyModL"   , "Choose1 w70" , [ " " ]  , "xs y+m"  ) 				; Submits the entry itself
	_uiAddSel(  "" 	;"Modifier:"
			,       "KeyModN"   , "Choose1"     , [ "Ext", "Shift", "Ctrl", "Alt", "Win" ], "x+30"    )
	_uiAddEdt( "`nKey mapping for the Layouts_Override [layout] section:"
			,       "KeyThis"   , ""            , ui_WideTxt, "xs y+m" )
	_uiAddEdt( "  =  "
			,       "KeyLine"   , ""            , ui_WideTxt, "xs y+m" )
	GUI, UI:Add, Text,, % "`n"
						. "`n* The default settings map CapsLock to a Backspace-on-tap, Extend-on-hold key."
						. "`n* Press the Help button for useful info including a key code table."
						. "`n* For keys defined by the (base-)layout, use the ""Submit to Layout.ini"" button."
						. "`n"
						. "`n* VKey mappings simply move keys around. Modifier mappings are Shift-type."
						. "`n* State maps specify the output for each modifier state, e.g., Shift + AltGr."
						. "`n* Tap-or-Mod and MoDK keys are a key press on tap and a modifier on hold."
						. "`n* Ext alias Extend is a wonderful special modifier! Read about it elsewhere."
						. "`n"
	GUI, UI:Add, Button, xs y%BL% vUI_Btn4  gUIsubKeyMap, &Submit Key Mapping
	GUI, UI:Add, Button, x+14   yp          gUIsubKeyLay, Submit to &Layout.ini
	GUI, UI:Add, Button, xs+244 yp          gUIrevKey   , %SP%&Reset%SP%
	GUI, UI:Add, Button, xs+310 yp          gUIhlpShow  , %SP%&Help%SP%
	
	GUI, UI:Show
	Gosub UIselKey  											; First, handle Key Mapper...
	Gosub UIselSpc  											; ...then, Special Keys...
	Gosub UIselSet  											; ...then, Settings...
	Gosub UIselLay  											; ...then, Layout
	Gosub UIhitTab
} 	; end fn pklSetUI

	;; ================================================================================================
	;;  UI Control sections
	;
UIhitTab:   													; When a tab is selected, make its button the default.
	GUI, UI:Submit, Nohide  									; Not needed: 'GUI, +LastFound'? GuiControlGet,thisTab,,UI_Tab
	GuiControl, +Default, UI_Btn%UI_Tab%
Return

UIselLay:   													; Handle UI Layout selections
	GUI, UI:Submit, Nohide
	mainDir := "Layouts\" . UI_LayMain
	main3LA := getLayStrInfo( UI_LayMain )[2]   				; '3LA' 3-letter layout name abbreviation
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
				Continue 										; Layout folders contain a Layout.ini file
			layDirs.Push( subDir )
			layPath[ subDir ] := theDir . "\"
		} 	; end For subDir
		if not RegExMatch( theDir, need . ".+_" ) 				; '3LA-<LayType>[-<LayVar>]_<KbdType>[_<LayMods>]'
			Continue 											; Layout folders have a name on the form 3LA-LT[-LV]_KbT[_Mods]
		if not FileExist( ourDir . "\" . getPklInfo("LayFileName") )
			Continue 											; Layout folders contain a Layout.ini file
		layDirs.Push( theDir )
		layPath[ theDir ] := ""
	} 	; end For theDir
	layTyps     := _uiCheckLaySet( layDirs, 1, 2, need   )  	; Get the available Lay Types for the chosen MainLay
	if inArray( layTyps, "eD" )
		layTyps.InsertAt( inArray(layTyps,"eD"), "eD2VK" )  	; The special ##2VK layType reads a state-mapped BaseLayout as VK mapped
	_uiControl( "LayType", _uiPipeIt( layTyps, 1 ) ) 			; Update the LayType list (eD, VK)
	ui_layTyp3  := ( UI_LayType == "eD2VK" ) ? "eD" : UI_LayType
	needle      := need . ui_layTyp3
	kbdTyps     := _uiCheckLaySet( layDirs, 2, 0, need   )  	; Get the available Kbd Types for the chosen MainLay (and LayType?)
	_uiControl( "LayKbTp", _uiPipeIt( kbdTyps, 1 ) )
	needle      := need . ui_layTyp3 . ".*_" . UI_LayKbTp . "?(_|$)" 	; The bit after KbTp separates types like ISO-Orth from ISO
	layVari     := _uiCheckLaySet( layDirs, 1, 3, needle )  	; Get the available Layout Variants for the chosen MainLay/LayType/LayKbTp
	_uiControl( "LayVari", _uiPipeIt( layVari, 1 ) )
	layVariName := ( UI_LayVari == ui_NA ) ? "" : "-" . UI_LayVari
	needle      := need . ui_layTyp3 . layVariName . "_" . UI_LayKbTp . "?(_|$)"
	layMods     := _uiCheckLaySet( layDirs, 3, 0, needle )  	; Get the available Mods for the chosen MainLay/LayType/LayKbTp/LayVari
	_uiControl( "LayMods", _uiPipeIt( layMods, 1 ) )
	layModsName := ( UI_LayMods != ui_NA ) ? UI_LayMods : ""
	layModsPref := ( layModsName ) ? "_" : ""
	layDir1     := main3LA . "-" ,  layDir3 := layVariName . "_" . UI_LayKbTp . layModsPref . layModsName 	; Used to be one var, layFolder
	layPath     := layPath[ layDir1 . ui_layTyp3 . layDir3 ] 	; Subdirectory, if there is one
;	_uiControl( "LayFile", ControlGet, tmpList, List, ,ComboBox6, EPKL Settings 			; DDL boxes are regarded as ComboBox
	_uiControl( "LayFile", UI_LayMain . "\" . layPath . layDir1 . UI_LayType . layDir3 ) 	; eD WIP: Make this update the right line in LayFile ComboBox?
	layMenuName := UI_LayMain . "-" . UI_LayType . layVariName . " " . layModsName . "(" . UI_LayKbTp . ")"
	_uiControl( "LayMenu", layMenuName )
Return

UIselSet: 														; Handle UI Settings selections
	GUI, UI:Submit, Nohide
	set     := _setValDefCom( UI_SetThis )  					; Get Setting value/default/commentaries
	_uiControl( "SetLine", set.Val )
	_uiControl( "SetDefs", set.Def )
	_uiControl( "SetComm", set.Com )
Return

_setValDefCom( setting ) {  									; Get value/default/commentaries for a Setting
	set     := []
	def_Ini := getPklInfo( "File_PklSet" ) . "_Default.ini" 	; The Settings_Default file
	set.Val := pklIniRead( setting  , "<N/A>"          )    	; Read from SetStck. Strip EOL comments.
	set.Def := pklIniRead( setting  , "<N/A>", def_Ini )    	; Read from Default. Strip EOL comments.
	set.Com := pklIniRead( setting  , "<N/A>", def_Ini, , 0 ) 	; Read from Default. Don't strip comments.
	set.Com := RegExReplace( set.Com, "^" . set.Def . "[ `t]*;[ `t]*" ) 	; ^ $ beginning/end of line (\A \z for whole string)
	set.Com := RegExReplace( set.Com, "[`t]+"   , "  " )
	set.Com := RegExReplace( set.Com, "[ ]{3,}" , "  " ) 		; Compactify whitespace
	Return set
} 	; end fn

UIselSpc:   													; Handle UI Special Key selections
	GUI, UI:Submit, Nohide
	case    :=  UI_SpcExtS  									; eD TODO: The Switch command only appears with AHK v1.1.31+!
	mapping :=  ( case == 1 ) ? "System" 					;"CAPITAL     VKey"  	; [ "Caps", "Back", "Ext", "Back/Ext", "MoDK" ]
			:   ( case == 2 ) ? "qwBSP       SKey"  		;"BACK        VKey"
			:   ( case == 3 ) ? "Extend      Modifier"
			:   ( case == 4 ) ? "BACK/Ext    VKey"
			:   ( case == 5 ) ? "BACK/Ext    0   	@ex0	@ex1	*#. 	@ex6	@ex7"
			:                   " --"
	_uiControl( "SpcExLn", "QWCLK = " . mapping )
	case    :=  UI_SpcCmpS  									; eD TODO: The Switch command only appears with AHK v1.1.31+!
	mapping :=  ( case == 1 ) ? "QW_LG = vc_LG    " 			; [ "ISO", "RCtrl", "RWin", "PrtScn", "Menu/App" ]
			:   ( case == 2 ) ? "QWRCT = vcRCT    "
			:   ( case == 3 ) ? "QWRWI = vcRWI    "
			:   ( case == 4 ) ? "QWPSC = vcPSC    "
			:   ( case == 5 ) ? "QWAPP = vcAPP    "
			:                   " --"
	_uiControl( "SpcCoLn", mapping .             "0   	©Def	@co1	--  	®®  	®®  " )
;	CoDeVal := pklIniRead( "CoDeKeys", "<N/A>" ) 				; Read from SetStck. Strip EOL comments.
	set     := _setValDefCom( "CoDeKeys" )  					; Get Setting value/default/commentaries
	_uiControl( "SpcCDLn", set.Val )
Return

UIselKey:   													; Handle UI Key Mapping selections
	GUI, UI:Submit, Nohide
	_uiControl( "KeyCodS", "|" . ui_KLMs[ UI_KeyRowS ]  )
	_uiControl( "KeyCodV", "|" . ui_KLMs[ UI_KeyRowV ]  )
	_uiControl( "KeyThis", "QW" . UI_KeyCodS            )
	keyModL := ( UI_KeyModN == "Ext" ) ? "| |" : "| |L|R|"
	_uiControl( "KeyModL", keyModL  )
	modifer := ( UI_KeyModL == " " ) ? UI_KeyModN : UI_KeyModL . UI_KeyModN
	vcVK    :=  "vc" . UI_KeyCodV
	case    :=  UI_KeyType  									; eD TODO: The Switch command only appears with AHK v1.1.31+!
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

UIhlpShow:  													; Help button: Show the KeyMapper and other info Help GUI
	hlpText :=  ""
;			.   "EPKL Key Mapper help:"
			. "`nFirstly: This is a complex topic! Please refer to the BigBag web pages and read inside the relevant EPKL files if you wish to understand it better."
			. "`nDreymaR's Big Bag of Keyboard Tricks is found at: https://dreymar.colemak.org"
			. "`n"
			. "`n•   S P E C I A L   K E Y S   I N   E P K L"
			. "`n"
			. "`n- The Extend key is a layer modifier, usually replacing the Caps key. You can get different Extend layers using modifier combos."
			. "`n- For instance, hold RAlt then hold Extend then release RAlt while keeping Extend down, to activate the ""Ext2"" NumPad layer."
			. "`n- Extend can furthermore do something else on tap instead of hold. For Ext-tap, tap Extend – with modifiers if you wish."
			. "`n- Combining Ext and Ext-tap, you can have many different layers! This is called a MoDK (Mother-of-DeadKeys) Extend key."
			. "`n"
			. "`n- Compose is a sequence recognizer. You type a sequence and hit it. Its traditional use is for accents, but it can do lots of things."
			. "`n- If a Compose key is set as a CoDeKey, it'll be a dead key too. A CoDeKey composes if it recognises a sequence, or else is a DK. Very powerful!"
			. "`n- Dead keys are also very useful on their own. You can have as many as you like, and use them in ingenious ways. See the Deadkeys .ini file."
			. "`n`n"
			. "`n•   K E Y   V S   S T A T E   M A P P I N G S"
			. "`n"
			. "`n- VirtualKey (VK) or ScanCode (SC) key mapping means that a key press is emulated and as a result whatever is in the system layout for that key is sent."
			. "`n- State mappings such as [eD] are different: They send characters directly into the Input Stream, so you can send anything regardless of the system layout."
			. "`n"
			. "`n- State mappings can be lots of different things, from simple characters via AHK syntax and PowerStrings to advanced dead or Compose/Completion/Repeat keys."
			. "`n- Learn about EPKL Prefix-Entry syntax, Extend, dead keys, Compose and more in the main Readme file. Also in the Compose, DeadKeys, Extend and PowerStrings files."
			. "`n- The Windows ShiftStates are: [#]  Unshifted  Shifted  Ctrl  AltGr  Shift+AltGr. Usually, ignore the initial CapsBehavior number, and don't map the Ctrl state."
;	pesText :=  ""
;			.   "    This is an overview of EPKL prefix-entry syntax:"  	; . ui_PrefEntr
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
			. "`n  |  - Any entry may start with «#»: '#' is one or more characters to display on help images for the following mapping.   |"
			. "`n  |  - Other advanced state mappings:                                                                                     |"
			. "`n  |      ®® |  ®# : Repeat the previous character. '#' may be a hex number. Nice for avoiding same-finger bigrams.        |"
			. "`n  |      ©‹name›  : Named Compose key, replacing the last written character sequence with something else.                 |"
			. "`n  |      ##       : Send the active system layout's Virtual Key code. Good for OS shortcuts, but EPKL can't see it.       |"
			. "`n  X=======================================================================================================================X"
	klmText :=  ""
			.   "•   K E Y   C O D E S   A N D   R E M A P S"
			. "`n"
			. "`n- EPKL maps keys using their scan codes. 'QW_' codes denote QWERTY locations, see the table below. Actual SC### scan codes work as well."
			. "`n- Keys may get moved around by mod _Remaps_ such as ergo mods. When mapping something to a key, map to the unmodded location (the old 'N' key is still QW_N)."
			. "`n- Example: Standard Colemak has G on the top row, where Colemak-DH has B. To edit the B key in Cmk-DH, still use its QWERTY (and Colemak) position QW_B."
			. "`n"
			. "`n    This is a table of all KeyLayoutMap codes from the _eD_Remap.ini file, useable both as ""Map from QW"" Scan Codes and ""Map to vc"" Virtual Key codes."
			. "`n    You can edit the key mapping lines directly to any valid key codes and mappings. The KLM codes to the right, for example, aren't in the dropdown lists."
	GUI, UI_KEYHLP:New  , ToolWindow , EPKL Key Mapper Help
	GUI, UI_KEYHLP:Add  , Text,      , % hlpText    			; Help introduction
;	GUI, UI_KEYHLP:Add  , Text,      , % pesText    			; Syntax-Entry table w/ intro text
	GUI, UI_KEYHLP:Font , s10 , Courier New
	GUI, UI_KEYHLP:Add  , Text,      , % pesTabl . "`n"
	GUI, UI_KEYHLP:Font 										; (Restore the default system font)
	GUI, UI_KEYHLP:Add  , Text,      , % klmText    			; KLM key code table, generated above
	GUI, UI_KEYHLP:Font , s10 , Courier New
	GUI, UI_KEYHLP:Add  , Text,      , % ui_KLMp . "`n" 		; The table is made from the Remap file KLM table
	GUI, UI_KEYHLP:Font
	GUI, UI_KEYHLP:Add  , Button, gUIhlpHide Default, &Hide
	GUI, UI_KEYHLP:Show , x16 y16 								; Show the help window in the screen corner
Return

UIhlpHide:  													; Remove the Help GUI
	GUI, UI_KEYHLP:Destroy
Return

UIsubLaySel: 													; Submit Layout Override button pressed
	_uiSubmit( [ _uiGetParams( "LaySel" ) ] )   				; Note: The parameters are sent as a 1×n array of vectors
Return

UIsubSetSel: 													; Submit Settings button pressed
	_uiSubmit( [ _uiGetParams( "SetSel" ) ] )
Return

UIsubSpcExt: 													; Submit Special Key Extend button pressed
	_uiSubmit( [ _uiGetParams( "SpcExt" ) ] )
Return

UIsubSpcCmp: 													; Submit Special Key Compose button pressed
	_uiSubmit( [ _uiGetParams( "SpcCmp" ) 
	           , _uiGetParams( "SpcCm2" ) ] )
Return

UIsubKeyMap: 													; Submit Key Mapping button pressed
	_uiSubmit( [ _uiGetParams( "KeyMap" ) ] )
Return

UIsubKeyLay: 													; Submit Key Mapping to Layout.ini button pressed
	_uiSubmit( [ _uiGetParams( "KeyLay" ) ] )
Return

UIrevLay: 														; Revert UI setting(s) by deleting any matching UI entries
	_uiRevert( [ _uiGetParams( "LaySel" ) ], "Lay" )
Return

UIrevSpc:   													; Revert UI setting(s)
	_uiRevert( [ _uiGetParams( "SpcExt" ) 
	           , _uiGetParams( "SpcCmp" ) 
	           , _uiGetParams( "SpcCm2" ) ], "Spc" )
Return

UIrevSet:   													; Revert UI setting(s)
	_uiRevert( [ _uiGetParams( "SetSel" ) ], "Set" )
Return

UIrevKey:   													; Revert UI setting(s)
	_uiRevert( [ _uiGetParams( "KeyMap" ) 
	           , _uiGetParams( "KeyLay" ) ], "Key" )
Return

	;; ================================================================================================
	;;  UI functions
	;
_uiControl( var, values ) { 									; Update an UI Control with new values and, if applicable, choice
	var := "UI_" . var  										; Name of the global UI var
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
	if ( iTxt ) {
		GUI, UI:Add, Text,           %pos% , % iTxt
	}
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
		if not inArray( theList, match ) 						; Add the match if it isn't added yet
			theList.Push( match )
	} 	; end For
	Return theList  											; Return an array of the relevant layout settings
}

_uiGetParams( which ) { 										; Provide UI parameters for WriteOverride
	GUI, UI:Submit, Nohide  									; Refresh UI parameter values
	layDir  := StrReplace( getLayInfo("ActiveLay"), "2VK" ) 	; Account for st2VK layTypes such as eD2VK
	case    := inArray( [ "LaySel", "SetSel", "SpcExt", "SpcCmp", "SpcCm2", "KeyMap", "KeyLay" ], which )
	Return      ( case == 1 ) ? [ "layout = " . UI_LayFile . ":" . UI_LayMenu   , "LayoutPicker"
		, "pkl"     , getPklInfo( "File_PklLay" )   , "_Override_Example"   ] 	;  LaySel
			:   ( case == 2 ) ? [ UI_SetThis . " = " . UI_SetLine               , "Settings"    
		, "pkl"     , getPklInfo( "File_PklSet" )   , "_Default"            ] 	;  SetSel
			:   ( case == 3 ) ? [ UI_SpcExLn                                    , "SpecialKeys" 
		, "layout"  , getPklInfo( "File_PklLay" )   , "_Override_Example"   ] 	;  SpcExt
			:   ( case == 4 ) ? [ UI_SpcCoLn                                    , "SpecialKeys" 
		, "layout"  , getPklInfo( "File_PklLay" )   , "_Override_Example"   ] 	;  SpcCmp
			:   ( case == 5 ) ? [ "CoDeKeys" . " = " . UI_SpcCDLn               , "SpecialKeys" 
		, "pkl"     , getPklInfo( "File_PklSet" )   , "_Default"            ] 	;  SpcCm2
			:   ( case == 6 ) ? [ UI_KeyThis . " = " . UI_KeyLine               , "KeyMapper"   
		, "layout"  , getPklInfo( "File_PklLay" )   , "_Override_Example"   ] 	;  KeyMap
			:   ( case == 7 ) ? [ UI_KeyThis . " = " . UI_KeyLine               , "KeyMapper"   
		, "layout"  , "Layouts\" . layDir . "\layout", ""                   ] 	;  KeyLay
			:   []
}

_uiSubmit( parset ) {   										; WriteOverride calls for several sets of parameters 	; eD WIP
	ui_Written  := false
	For ix, pr in parset {
		_uiWriteOverride( pr[1], pr[2], pr[3], pr[4], pr[5] ) 	; key_entry, module, section, ovrFile, tplFile
	} 	; end For pars
	if ( ui_Written )
		_uiMsg_RefreshPKL()
}

_uiRevert( parset, sel ) {  									; Revert changes, as above
	ui_Revert   := true
	_uiSubmit( parset )
	ui_Revert   := false
	gosub UIsel%sel% 											; Refresh selection (UIselKey etc)
}

_uiWriteOverride( key_entry, module = "Settings" 				; Write a line to Override. If necessary, make the file first.
	, section = "pkl", ovrFile = "EPKL_Settings", tplFile = "" ) {
	revert  := ui_Revert
	a_SC    := "`;"
	ini     := ".ini"
	tplFile := ( tplFile ) ? ovrFile . tplFile : ""
	ovrFile .= ( tplFile ) ? "_Override" : "" 					; If there isn't a template, use the main file as its override
	if not FileExist( ovrFile . ini ) { 						; If there isn't an Override file...
		if ( tplFile && not revert ) {  						; ...ask whether to generate one from a template.
			if _uiMsg_MakeFile( module, ovrFile, tplFile ) {
				if not tmpFile := pklFileRead( tplFile . ini ) 	; Try to read the override template
					Return false
				laySect := "`r`n[layout]`r`n"
				laySect := InStr( tmpFile, laySect ) ? laySect : ""
				tmpFile := RegExReplace( tmpFile, "s)\R\[pkl\]\R\K.*" )
				tmpFile .= laySect
				if not pklFileWrite( tmpFile, ovrFile . ini ) 	; Try to write the override file
					Return false
			} else {
				Return false
			} 	; end if makeFile
		} else {
			pklInfo( "Override file not found:`n`n" . ovrFile, 3 )
			Return false
		} 	; end if tplFile
	} 	; end if not FileExist ovrFile
	pklIniKeyVal( key_entry, key, entry )   					; Split the "key = entry" line
	makeLine := false   										; Make the new line and tidy up old ones, ...
	if revert { 												; ...or revert all previous changes.
		ms1 := "Reset Override?"
		ms2 := "Reset"
		ms3 := "Revert this UI generated setting to default:`n`n" . key
	} else {
		ms1 := "Write Override line?"
		ms2 := "Submit"
		ms3 := "Write this setting override:`n`n" . key . " = " . entry
	} 	; end if revert
	if not _uiMsg_Override( ms1, ms2, ms3, section, ovrFile ) 	; Write override, if desired and possible
		Return false
	if not tmpFile := pklFileRead( ovrFile . ini ) 				; The standard IniWrite writes to the end of the section. We want the start.
		Return false
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
		entry   := key . " = " . entry . " `t`t" . comText . thisMinute()
		secStrt := "s)\R\[" . section . "\]" 					; s: Match including line breaks
		tmpFile := RegExReplace( tmpFile, secStrt . "\R\K(.*)", entry . "`r`n$1" )
	}
	if pklFileWrite( tmpFile, ovrFile . ini )   				; Write/revert the override
		ui_Written  := true  									; Files were changed, so ask whether to refresh EPKL
} 	; end fn UI WriteOverride

_uiMsg_MakeFile( module, ovrFile, tplFile ) {
	MsgBox, 0x021, Make Override file?, 						;  0x000: 1st button default. 0x20: Exclamation. 0x1: OK/Cancel
(   															; (0x100: 2nd button default. 0x30: Warning. 0x3: Yes/No/Cancel)
EPKL %module% Submit
—————————————————————————————

EPKL uses Override files for settings,
to avoid messing with the Default files.
No "%ovrFile%" file was detected.

Would you like to create one from %tplFile%.ini?
)
	IfMsgBox, OK
		Return true
	Return false 	;	IfMsgBox, Cancel
}

_uiMsg_Override( ms1, ms2, ms3, section, ovrFile ) {
	MsgBox, 0x021, %ms1%,   									; 0x021: 1st button default. Exclamation/Question. OK/Cancel
(
EPKL %module% %ms2%
—————————————————————————————

%ms3%

in the [%section%] section of %ovrFile%.ini?
)
	IfMsgBox, OK
		Return true
	Return false
}

_uiMsg_RefreshPKL( purpose = " to use the chosen setting(s)" ) {
	ui_Written  := false
	MsgBox, 0x021, Refresh EPKL?,   		 					; 0x021: 1st button default. Exclamation/Question. OK/Cancel
(
Write successful.

Refresh EPKL now%purpose%?

You can also refresh it later by the tray menu,
or by the Refresh hotkey (default Ctrl+Shift+5).
)
	IfMsgBox, OK
		gosub rerunSameLayout
} 	; end fn UI RefreshPKL
