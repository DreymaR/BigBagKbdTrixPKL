setUIGlobals: 													; Declare globals (can't be done inside a function for "global globals")
;	global UI_Set 												; eD WIP: Would like to use UI_Set.MainLay etc, but can't? Single variables needed
	global UI_Tab, UI_Btn1, UI_Btn2, UI_Btn3 					; GUI Control vars must be global (or static) to work
	global UI_LayMain, UI_LayType, UI_LayKbTp, UI_LayVari, UI_LayMods, UI_LayFile, UI_LayMenu
	global UI_KeyRowS, UI_KeyCodS, UI_KeyRowV, UI_KeyCodV, UI_KeyModL, UI_KeyModN, UI_KeyType
	global UI_KeyKyLi, UI_KeyLine
	global ui_NA        := "<none>" 							; Value used in the UI functions (not a control variable)
	global ui_Lay3LAs 	;, ui_SepLine, ui_WideTxt
	global ui_KLMs   := []
Return

pklSetUI() { 													; EPKL Settings GUI
	pklAppName  := getPklInfo( "pklName" )
	winTitle    := "EPKL Settings"
	if WinActive( winTitle ) { 									; Toggle the GUI off if it's the active window
		GUI, UI: Destroy
		Return
	} 															; AHK GUI Controls: https://www.autohotkey.com/docs/commands/GuiControls.htm
	ui_Lay3LAs  := getPklInfo( "shortLays" ) 					; Dictionary of 3-letter layout name abbreviation (3LA)
	ui_SepLine  := "————————————————" . "————————————————" . "————————————————" 	; . "——"
	ui_WideTxt  := "                                        " 	; Standard edit box text (for autosizing its width)
	ui_WideTxt  .= ui_WideTxt . "    "
	For ix, row in [ 1,2,3,4 ] { 								; Get the KLM codes for each keyboard row
		keyRow  := pklIniRead( "QW" . row, "", getPklInfo( "RemapFile" ), "KeyLayoutMap" )
		keyRow  := RegExReplace( keyRow, "[|]{2}.*", "|" ) 				; Delete any mappings after a double pipe
		keyRow  := RegExReplace( keyRow, "[ `t]*" )
		keyRow  := ( row == 1 ) ? keyRow . "BSP|" : keyRow 		; The KLM map has Backspace on row 0 beyond the ||.
		ui_KLMs[ ix ] := keyRow 	;StrSplit( keyRow, "|", " `t" ) 	 	; Split by pipe, row 1 is the Number row etc
	}
	footText    := "`n* Only the topmost active '<key> =' line in the section is used."
	footText    .= "`n* Lines starting with a semicolon are commented out (inactive)."
	
	mainLays    := _uiGetDir( "Layouts" ) 						; "Colemak", "Dvorak", "QUARTZ", "QWERTY", "Tarmak"
	layTypes    := [ "eD"   , "VK"  ] 							; Starting values
	kbdTypes    := [ "ANS"  , "ISO" ] 							; --"--
	GUI, UI:New,       , %winTitle%
	GUI, UI:Add, Tab3, vUI_Tab gUIhitTab +AltSubmit 			; AltSubmit gets tab # not name
			, % "Layout||Keys|Settings" 						; The first tab (double pipe) is default
	
	GUI, UI:Add, Text, section 									; 'section' stores the x value for later
					   , % "`nLayout Selector for " . pklAppName
	GUI, UI:Add, Text, , % ui_SepLine 	; ————————————————————————————————————————————————
	_uiAddSel(  "Main layout: "
			,       "LayMain"   , "Choose1"     , mainLays              )
	GUI, UI:Add, Text,      , % "Layout type:"
	GUI, UI:Add, Text, x+92 , % "Keyboard type:" 				; Unsure how this works at other resolutions?
	_uiAddSel(  "" 	;"Layout type:" 							; Place at the x value of the previous section
			,       "LayType"   , "Choose1"     , layTypes  , "xs y+m"  )
	_uiAddSel(  "" 	;"Keyboard type:" 							; Place to the right of the previous control
			,       "LayKbTp"   , "Choose2"     , kbdTypes  , "x+30"    )
	_uiAddSel(  "Variant/Locale, if any: "
			,       "LayVari"   , "Choose1"     , [ ui_NA ] , "xs y+m"  )
	_uiAddSel( "Mods, if any: " 								; Make a box wider than the previous one: "wp+100"
			,       "LayMods"   , "Choose1"     , [ "AWide" ]           ) 	; ui_NA
	
	_uiAddEdt( "`nIn the Layouts_Override [pkl] section: layout = "
			,       "LayFile"   , ""            , ui_WideTxt            ) 	; . "`n"
	_uiAddEdt( "`nEPKL Layouts menu name. Edit it if you wish:"
			,       "LayMenu"   , ""            , ui_WideTxt            )
	GUI, UI:Add, Text,, % footText
						. "`n* To get multiple layouts, submit twice then join the entries"
						. "`n    in the Override file on one 'layout =' line with a comma." . "`n"
	GUI, UI:Add, Button, vUI_Btn1 gUIhitLayBtn, &Submit Override
	
	GUI, UI:Tab, 2
	GUI, UI:Add, Text, section 									; 'section' stores the x value for later
					   , % "`nKey mapping editor for " . pklAppName
	GUI, UI:Add, Text, , % ui_SepLine 	; ————————————————————————————————————————————————
	klmRows     := [ "Number", "Upper", "Home", "Lower" ] 		; Num,Upp,Hom,Low. Row 0-3 in the KLM.
	GUI, UI:Add, Text,          , % "SC Row:"
	GUI, UI:Add, Text, x+60     , % "Map from QW Scan code:"
	_uiAddSel(  "" 	;"Row: "
			,       "KeyRowS"   , "Choose3 w70 +AltSubmit" , klmRows  , "xs y+m"  ) 	; Submits the row #
	_uiAddSel(  "" 	;"Scan code:"
			,       "KeyCodS"   , "Choose1"     , [ "CLK" ], "x+30"    )
	GUI, UI:Add, Text, xs y+m   , % "VK Row:"
	GUI, UI:Add, Text, x+60     , % "Map to vc VKey code:"
	_uiAddSel(  "" 	;"Row: "
			,       "KeyRowV"   , "Choose1 w70 +AltSubmit" , klmRows  , "xs y+m"  ) 	; Submits the row #
	_uiAddSel(  "" 	;"VKey code:"
			,       "KeyCodV"   , "Choose1"     , [ "BSP" ], "x+30"    )
	GUI, UI:Add, Text, xs y+m   , % "L/R:"
	GUI, UI:Add, Text, x+70     , % "Modifier:"
	_uiAddSel(  "" 	;"L/R: "
			,       "KeyModL"   , "Choose1 w70" , [" ","L","R"]  , "xs y+m"  ) 	; Submits the entry itself
	_uiAddSel(  "" 	;"Modifier:"
			,       "KeyModN"   , "Choose1"     , [ "Ext", "Shift", "Ctrl", "Alt", "Win" ], "x+30"    )
	_uiAddSel(  "Mapping type: "
			,       "KeyType"   , "Choose4 +AltSubmit", [ "VirtualKey", "StateMaps", "Modifier", "Tap-or-Mod", "MoDK" ], "xs y+m" )
	_uiAddEdt( "`nKey mapping for the Layouts_Override [layout] section:"
			,       "KeyKyLi"   , ""            , ui_WideTxt, "xs y+m" )
	_uiAddEdt( "  =  "
			,       "KeyLine"   , ""            , ui_WideTxt, "xs y+m" )
	GUI, UI:Add, Text,, % footText
						. "`n* For layout keys, move the mapping line to your layout.ini file." . "`n"
	GUI, UI:Add, Button, vUI_Btn2 gUIhitKeyBtn, &Submit Key Mapping
	
	GUI, UI:Tab, 3
	GUI, UI:Add, Text, section 									; 'section' stores the x value for later
					   , % "`nGeneral settings for " . pklAppName
	GUI, UI:Add, Text, , % ui_SepLine 	; ————————————————————————————————————————————————
	GUI, UI:Add, Text, , TODO/WIP: Here you'll be able to edit program settings.
	GUI, UI:Add, Text, , For now, edit these in the EPKL_Settings .ini file.
	GUI, UI:Add, Text, , % ui_SepLine 	; ————————————————————————————————————————————————
	GUI, UI:Add, Text,, % footText
						. "`n* There are more settings in the Settings_Default file." . "`n"
	GUI, UI:Add, Button, vUI_Btn3 gUIhitSetBtn, &Submit Settings
	
	GUI, UI:Show
	Gosub UIhitTab
	Gosub UIselLay
	Gosub UIselKey
	Gosub UIselSet
}

UIhitTab: 														; When a tab is selected, make its button the default.
	GUI, UI:Submit, Nohide 										; Not needed: 'GUI, +LastFound'? GuiControlGet,thisTab,,UI_Tab
	GuiControl, +Default, UI_Btn%UI_Tab%
Return

UIselLay: 														; Handle UI Layout selections
	GUI, UI:Submit, Nohide
	mainDir := "Layouts\" . UI_LayMain
	main3LA := ( ui_Lay3LAs[UI_LayMain] ) ? ui_Lay3LAs[UI_LayMain] : SubStr( UI_LayMain, 1, 3 )
	need        := main3LA . "-" 								; Needle for the MainLay
	layDirs := []
	For ix, theDir in _uiGetDir( mainDir ) { 					; Get a layout directory list for the chosen MainLay
		if not RegExMatch( theDir, need . ".+_" )
			Continue 											; Layout folders have a name on the form 3LA-LT[-LV]_KbT[_Mods]
		if not FileExist( mainDir . "\" . theDir . "\" . getPklInfo("LayFileName") )
			Continue 											; Layout folders contain a layout.ini file
		layDirs.Push( theDir )
	}
;	GuiControlGet, ctrlID, Hwnd, UI_LayType 					; Get the HWND handle for the UI control
;	ControlGet, layTypeUI, List,, ctrlID 						; Get the current content of the control, as a string 	; eD WIP: This didn't work?
	layTyps     := _uiCheckLaySet( layDirs, 1, 2, need   ) 		; Get the available Lay Types for the chosen MainLay
	_uiControl( "LayType", _uiPipeIt( layTyps, 1 ) ) 			; Update the LayType list
	needle      := need . UI_LayType
	kbdTyps     := _uiCheckLaySet( layDirs, 2, 0, need   ) 		; Get the available Kbd Types for the chosen MainLay (and LayType?)
	_uiControl( "KbdType", _uiPipeIt( kbdTyps, 1 ) )
	needle      := need . UI_LayType . ".*_" . UI_LayKbTp
	layVari     := _uiCheckLaySet( layDirs, 1, 3, needle ) 		; Get the available Layout Variants for the chosen MainLay/LayType/KbdType
	_uiControl( "LayVari", _uiPipeIt( layVari, 1 ) )
	layVariName := ( UI_LayVari == ui_NA ) ? "" : "-" . UI_LayVari
	needle      := need . UI_LayType . layVariName . "_" . UI_LayKbTp
	layMods     := _uiCheckLaySet( layDirs, 3, 0, needle ) 		; Get the available Mods for the chosen MainLay/LayType/KbdType/LayVari
	_uiControl( "LayMods", _uiPipeIt( layMods, 1 ) )
	layModsName := ( UI_LayMods == ui_NA ) ? "" : "_" . UI_LayMods
	layFileName := UI_LayMain . "\" . main3LA . "-" . UI_LayType . layVariName . "_" . UI_LayKbTp . layModsName
	_uiControl( "LayFile", layFileName )
	layMenuName := UI_LayMain . "-" . UI_LayType . layVariName . layModsName 	; . "(" . UI_LayKbTp . ")"
	_uiControl( "LayMenu", layMenuName )
Return

UIselKey: 														; Handle UI Key Mapping selections
	GUI, UI:Submit, Nohide
	_uiControl( "KeyCodS", "|" . ui_KLMs[ UI_KeyRowS ] )
	_uiControl( "KeyCodV", "|" . ui_KLMs[ UI_KeyRowV ] )
	_uiControl( "KeyKyLi", "QW" . UI_KeyCodS                    )
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
Return

UIselSet: 														; Handle UI Settings selections 	; eD WIP
	GUI, UI:Submit, Nohide
Return

UIhitLayBtn: 													; Submit Layout Override button pressed
	GUI, UI:Submit, Nohide
	layLine := UI_LayFile . ":" . UI_LayMenu
	_uiWriteOverride( "layout"      , layLine       , "Layout Picker"
		, "pkl"     , getPklInfo( "File_PklLay" )   , "_Override_Example" )
Return

UIhitKeyBtn: 													; Submit Key Mapping button pressed
	GUI, UI:Submit, Nohide
	_uiWriteOverride( UI_KeyKyLi    , UI_KeyLine    , "Key Mapper"
		, "layout"  , getPklInfo( "File_PklLay" )   , "_Override_Example" )
Return

UIhitSetBtn: 													; Submit Settings button pressed
	_uiWriteOverride( TODO_SetKey   , TODO_SetEntry , "Settings"
		, "pkl"     , getPklInfo( "File_PklSet" )   , "_Default" )
Return

_uiControl( var, values ) { 									; Update an UI Control with new values and, if applicable, choice
	var := "UI_" . var 											; Name of the global UI var
	val := %var% 												; Content of the UI var
	GUIControl, , %var%, %values% 								; This also works for edit/text controls
	if InStr( values, val ) { 									; Try to keep the chosen option in a DDL, or take the first choice
		GUIControl, ChooseString, %var%, %val%
	} else {
		GUIControl, Choose      , %var%, 1
	}
	GUI, UI:Submit, Nohide 										; Needed to update the GUI values
}

_uiAddEdt( intro, var, opts, editTxt, pos = "" ) { 				; Add an Edit box with text
	GUI, UI:Add, Text,           %pos% , % intro
	GUI, UI:Add, Edit, vUI_%var% %opts%, % editTxt
}

_uiAddSel( intro, var, opts, listArr, pos = "" ) { 				; Add a DropDownList selection box with text and some choices
	listStr := _uiPipeIt( listArr, 0, 0 )
	if ( intro ) {
		GUI, UI:Add, Text, %pos%, % "" . intro 					; Whitespace pad the text a little?
	} else {
		opts .= " " . pos
	}
	mod := SubStr( var, 1, 3 ) 									; UI_Lay####, Key, Set
	GUI, UI:Add, DDL , gUIsel%mod% vUI_%var% %opts%, % listStr
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
	For ix, elem in listArr { 									; eD WIP: IfObject?
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
	, section = "pkl", ovrFile = "EPKL_Settings", tplFile = "_Default" ) {
	maxEntr := 4 												; Delete old UI entries with the same key over this number.
	A_SC    := ";"
	ini     := ".ini"
	tplFile := ovrFile . tplFile
	ovrFile .= "_Override"
	if not FileExist( ovrFile . ini ) {
		makeFile := false
		MsgBox, 0x031, Make Override file?, 					; 0x100: 2nd button default. 0x20: Exclamation. 0x1: OK/Cancel
(
EPKL %module% Submit
—————————————————————————————

No "%ovrFile%" detected.

Would you like to create one from %tplFile%.ini?
)
		IfMsgBox, Cancel 										; MsgBox type is 0x3 (Yes/No/Cancel) + 0x30 (Warning) + 0x100 (2nd button is default)
			Return
		IfMsgBox, OK 											; Make only the state images, not the full set with deadkey images
			makeFile := true
		if makeFile {
			if not tmpFile := pklFileRead( tplFile . ini )
				Return
			laySect := "`r`n[layout]`r`n"
			laySect := InStr( tmpFile, laySect ) ? laySect : ""
			tmpFile := RegExReplace( tmpFile, "s)\R\[pkl\]\R\K.*" ) 	;(\R\[layout\]\R).*", "$1" )
			tmpFile .= laySect
			if not pklFileWrite( tmpFile, ovrFile . ini )
				Return
		} 	; end if makeFile
	} 	; end if FileExist ovrFile
	makeLine := false
	MsgBox, 0x031, Write Override line?, 						; 0x100: 2nd button default. 0x20: Exclamation. 0x1: OK/Cancel
(
EPKL %module% Submit
—————————————————————————————

Write this line to the [%section%] section 
of the %ovrFile%.ini file?

%key% = %layLine%
)
	IfMsgBox, Cancel 											; MsgBox type is 0x3 (Yes/No/Cancel) + 0x30 (Warning) + 0x100 (2nd button is default)
		Return
	IfMsgBox, OK 												; Make only the state images, not the full set with deadkey images
		makeLine := true
	if not makeLine
		Return
;	IniWrite, %layLine%, %ovrFile%%ini%, %section%, %key% 		; The standard IniWrite writes to the end of the section. We want the start.
	if not tmpFile := pklFileRead( ovrFile . ini )
		Return
	FileDelete, % ovrFile . ini 								; In order to rewrite the file and not just append to it, it must be deleted.
	comText := A_SC . " Generated by the EPKL " . module . " UI, " 	; Start with a semicolon
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
				row := ( SubStr( row, 1, 1 ) == A_SC ) ? row : A_SC . row 	; Comment out old submitted lines
			} 	; end if InStr
		} 	; end if inSect
		rows := rows . "`r`n" . row
	} 	; end For row
	tmpFile := SubStr( rows, 3 ) 								; Lop off the initial line break
;	( 1 ) ? pklDebug( "inSection line: " . inSect . "`nThis line: " . ix, 6 )
/*
	comMent := "[^\R;]*" . comText . "[^\R]*\R" 				; Matches one comment line from the start of the line to the line break
	matchIt := tmpFile 											; Comment out any old layLines. Also limit their number to, say, 10!
	While RegExMatch( matchIt, secStrt . "(?).*\R" . comMent ) { 	;  . ".*\R\[" 	; Problem: Hard to count the entries with RegEx?
		matchIt := RegExReplace( matchIt, secStrt . "\K(.*\R)(" . comMent . ".*)", "$1;$2" )
	}
*/
	layLine := key . " = " . layLine . " `t`t" . comText . thisMinute()
	secStrt := "s)\R\[" . section . "\]" 						; s: Match including line breaks
	tmpFile := RegExReplace( tmpFile, secStrt . "\R\K(.*)", layLine . "`r`n$1" )
	if not pklFileWrite( tmpFile, ovrFile . ini )
		Return
	pklInfo( "Write successful. Refresh EPKL to use the chosen settings." )
} 	; end fn
