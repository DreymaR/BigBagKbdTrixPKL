setUIGlobals: 													; Declare globals (can't be done inside a function for "global globals")
;	global UI_Set 												; eD WIP: Would like to use UI_Set.MainLay etc, but can't? Single variables needed
	global UI_MainLay, UI_LayType, UI_KbdType, UI_LayVari, UI_LayMods
	global UI_LayFile, UI_LayMenu 								; GUI Control vars must be global (or static) to work
	global UI_NA        := "<none>" 							; Value used in the UI functions (not a control variable)
	global UI_Lay3LAs 	;, UI_SepLine, UI_WideTxt
Return

pklSetUI() { 													; EPKL Settings GUI
	winTitle    := "EPKL Settings"
	if WinActive( winTitle ) { 									; Toggle the GUI off if it's the active window
		GUI, UI: Destroy
		Return
	}
	UI_Lay3LAs  := getPklInfo( "shortLays" ) 					; Dictionary of 3-letter layout name abbreviation (3LA)
	UI_SepLine  := "————————————————" . "————————————————" . "————————————————" 	; . "——"
	UI_WideTxt  := "                                        " 	; Standard edit box text (for autosizing its width)
	UI_WideTxt  .= UI_WideTxt . "    "
	pklAppName  := getPklInfo( "pklName" )
	mainLays    := _uiGetDir( "Layouts" ) 						; "Colemak", "Dvorak", "QUARTZ", "QWERTY", "Tarmak"
	layTypes    := [ "eD"   , "VK"  ] 							; Starting values
	kbdTypes    := [ "ANS"  , "ISO" ] 							; --"--
	
	;;  For a list of AHK GUI Controls, see https://www.autohotkey.com/docs/commands/GuiControls.htm
	GUI, UI:New,       , %winTitle%
	GUI, UI:Add, Tab3, , % "Layout||Keys|Settings" 				; eD WIP: Other settings; Extend key definition
	
	GUI, UI:Add, Text, section 									; 'section' stores the x value for later
					   , % "`nLayout Selector for " . pklAppName
	GUI, UI:Add, Text, , % UI_SepLine 	; ————————————————————————————————————————————————
	_uiAddSel(  "Main layout: "
			,       "UI_MainLay"    , "Choose1"     , mainLays              )
;	GUI, UI:Add, DDL , gUIsel vUI_LayType Choose2          , % _uiPipeIt( LayTypes )
	GUI, UI:Add, Text,      , % "Layout type:"
	GUI, UI:Add, Text, x+92 , % "Keyboard type:" 				; Unsure how this works at other resolutions?
	_uiAddSel(  "" 	;"Layout type:" 							; Place at the x value of the previous section
			,       "UI_LayType"    , "Choose1"     , layTypes  , "xs y+m"  )
	_uiAddSel(  "" 	;"Keyboard type:" 							; Place to the right of the previous control
			,       "UI_KbdType"    , "Choose2"     , kbdTypes  , "x+30"    )
	_uiAddSel(  "Variant/Locale, if any: "
			,       "UI_LayVari"    , "Choose1"     , [ UI_NA ] , "xs y+m"  )
	_uiAddSel( "Mods, if any: " 								; Make a box wider than the previous one: "wp+100"
			,       "UI_LayMods"    , "Choose1"     , [ "AWide" ]           ) 	; UI_NA
	
	_uiAddEdt( "`nIn the Layouts_Override [pkl] section: layout = "
			,       "UI_LayFile"    , ""            , UI_WideTxt            ) 	; . "`n"
	_uiAddEdt( "`nEPKL Layouts menu name. Edit it if you wish:"
			,       "UI_LayMenu"    , ""            , UI_WideTxt            )
	GUI, UI:Add, Text,, % "`n* Only the topmost active line in the [pkl] section is used."
						. "`n* Lines starting with a semicolon are commented out (inactive)."
						. "`n* To get multiple layouts, submit twice then join the entries"
						. "`n    in the Override file on one 'layout =' line with a comma."
	GUI, UI:Add, Text, , 
	GUI, UI:Add, Button, gUIsubmitLayBtn Default, &Submit Override 	; vUI_LaySBtn
	
	GUI, UI:Tab, 2
	GUI, UI:Add, Text, section 									; 'section' stores the x value for later
					   , % "`nKey mapping editor for " . pklAppName
	GUI, UI:Add, Text, , % UI_SepLine 	; ————————————————————————————————————————————————
	GUI, UI:Add, Text, , TODO/WIP: Here you'll be able to define key overrides.
	GUI, UI:Add, Text, , For now, add these in the EPKL_Override [layout] section.
	
	GUI, UI:Tab, 3
	GUI, UI:Add, Text, section 									; 'section' stores the x value for later
					   , % "`nGeneral settings for " . pklAppName
	GUI, UI:Add, Text, , % UI_SepLine 	; ————————————————————————————————————————————————
	GUI, UI:Add, Text, , TODO/WIP: Here you'll be able to edit program settings.
	GUI, UI:Add, Text, , For now, edit these in the EPKL_Settings.ini file.
	
	GUI, UI:Show
	Gosub UIsel
}

UIsel: 															; Routine for handling UI selections
	GUI, UI:Submit, Nohide 										; Not needed: 'GUI, +LastFound'?
	mainDir := "Layouts\" . UI_MainLay
	main3LA := ( UI_Lay3LAs[UI_MainLay] ) ? UI_Lay3LAs[UI_MainLay] : SubStr( UI_MainLay, 1, 3 )
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
	layTyps     := _uiCheckSetting( layDirs, 1, 2, need   ) 	; Get the available Lay Types for the chosen MainLay
	_uiControl( "LayType", _uiPipeIt( layTyps, 1 ) ) 			; Update the LayType list
	needle      := need . UI_LayType
	kbdTyps     := _uiCheckSetting( layDirs, 2, 0, need   ) 	; Get the available Kbd Types for the chosen MainLay (and LayType?)
	_uiControl( "KbdType", _uiPipeIt( kbdTyps, 1 ) )
	needle      := need . UI_LayType . ".*_" . UI_KbdType
	layVari     := _uiCheckSetting( layDirs, 1, 3, needle ) 	; Get the available Layout Variants for the chosen MainLay/LayType/KbdType
	_uiControl( "LayVari", _uiPipeIt( layVari, 1 ) )
	layVariName := ( UI_LayVari == UI_NA ) ? "" : "-" . UI_LayVari
	needle      := need . UI_LayType . layVariName . "_" . UI_KbdType
	layMods     := _uiCheckSetting( layDirs, 3, 0, needle ) 	; Get the available Mods for the chosen MainLay/LayType/KbdType/LayVari
	_uiControl( "LayMods", _uiPipeIt( layMods, 1 ) )
	layModsName := ( UI_LayMods == UI_NA ) ? "" : "_" . UI_LayMods
	layFileName := UI_MainLay . "\" . main3LA . "-" . UI_LayType . layVariName . "_" . UI_KbdType . layModsName
	_uiControl( "LayFile", layFileName )
	layMenuName := UI_MainLay . "-" . UI_LayType . layVariName . layModsName 	; . "(" . UI_KbdType . ")"
	_uiControl( "LayMenu", layMenuName )
Return

UIsubmitLayBtn: 												; Submit Layout Override button pressed
	layLine := UI_LayFile . ":" . UI_LayMenu
	_uiWriteOverride( "layout"  , layLine           , "Layout Picker"
		, "pkl"     , getPklInfo( "File_PklLay" )   , "_Example" )
Return

UIsubmitKeyBtn: 												; Submit Key Mapping button pressed 	; eD WIP
	_uiWriteOverride( TODO_Key  , TODO_Mapping      , "Key Mapper"
		, "layout"  , getPklInfo( "File_PklLay" )   , "_Example" )
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

_uiAddEdt( intro, var, opts, editTxt ) { 						; Add an Edit box with text
	GUI, UI:Add, Text, , %intro%
	GUI, UI:Add, Edit, v%var% %opts%, % editTxt
}

_uiAddSel( intro, var, opts, listArr, pos = "" ) { 				; Add a DropDownList selection box with text and some choices
	listStr := _uiPipeIt( listArr )
	if ( intro ) {
		GUI, UI:Add, Text, %pos%, % "" . intro 					; Whitespace pad the text a little?
	} else {
		opts .= " " . pos
	}
	GUI, UI:Add, DDL , gUIsel v%var% %opts%, % listStr
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

_uiPipeIt( listArr, clear = 0 ) { 								; Convert an array to a pipe delimited list, e.g., for DDLs
	For ix, elem in listArr {
		pipe        := ( listStr ) ? "|" : ""
		listStr     .= pipe . elem
	} 	; end For
	Sort, listStr, D| U 										; Sort options: U - Unique, D# - use # as delimiter
	listStr := ( clear ) ? "|" . listStr : listStr 				; Prepend "|" if replacing the list
	Return listStr
}

_uiCheckSetting( dirList, splitUSn, splitMNn = 0, needle = "" ) {
	theList     := []
	For ix, item in dirList {
		splitUS := StrSplit( item, "_" )
		splitMN := StrSplit( splitUS[splitUSn], "-" )
		match   := ( splitMNn ) ? splitMN[splitMNn] : splitUS[splitUSn]
		match   := ( match ) ? match : UI_NA 					; If there isn't a third part, there's no variant/mods
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
	, section = "pkl", ovrFile = "EPKL_Layouts", template = "_Default" ) {
	maxEntr := 4 												; Delete old UI entries with the same key over this number.
	A_SC    := ";"
	ovrFile .= "_Override"
	ini     := ".ini"
	if not FileExist( ovrFile . ini ) {
		makeFile := false
		MsgBox, 0x031, Make Override file?, 					; 0x100: 2nd button default. 0x20: Exclamation. 0x1: OK/Cancel
(
EPKL %module% Submit
—————————————————————————————

No "%ovrFile%.ini" detected.

Would you like to create one from the %template% file?
)
		IfMsgBox, Cancel 										; MsgBox type is 0x3 (Yes/No/Cancel) + 0x30 (Warning) + 0x100 (2nd button is default)
			Return
		IfMsgBox, OK 											; Make only the state images, not the full set with deadkey images
			makeFile := true
		if makeFile {
			if not tmpFile := pklFileRead( ovrFile . template . ini )
				Return
			tmpFile := RegExReplace( tmpFile, "s)\R\[pkl\]\R\K.*(\R\[layout\]\R).*", "$1" )
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
