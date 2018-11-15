;-------------------------------------------------------------------------------------
;
; Read a section of an .ini file
;     Strips away blank and comment lines but not end-of-line comments
;     Able to read UTF-8 files, as AHK's IniRead can only handle UTF-16(?)
;
iniReadSection( file, section )
{
	try {
		FileRead, fileTxt, *P65001 %file%							; A way to read UTF-8 files
	} catch {
		pklErrorMsg( "Unable to open .ini file " . file )
		ExitApp, 35
	}
	needle := "is)(?:^|\R)[ `t]*\[[ `t]*" . section . "[ `t]*\][^\R]*?\R\K(.*?)(?=$|\R[ `t]*\[)"
	RegExMatch( fileTxt, needle, secTxt )							; is) = IgnoreCase, DotAll. \K = LookBehind.
	secTxt := RegExReplace( secTxt, "`am)^[ `t]*;.*" )				; Strip comment lines (multiline mode, any \R)
	secTxt := RegExReplace( secTxt, "\R([ `t]*\R)+", "`r`n" )		; Strip empty and whitespace lines
	Return secTxt
}

;-------------------------------------------------------------------------------------
;
; Read a (pkl).ini value
;     Usage: val := pklIniRead( <key>, [default], [inifile|shortstr], [section] )
;     Note: AHK IniRead trims off whitespace and a pair of quotes if present, but not comments.
;
pklIniRead( key, default = "", iniFile = "Pkl_Ini", section = "pkl", strip = 1 )	; eD WIP: Add an altFile?
{
	if ( not key )
		Return
; 	for inx, theFile in [ iniFile, altFile ]	; eD WIP
	hereLay := ( iniFile == "Lay_Ini" ) ? getLayInfo( "layDir" ) : "."	; Allow ".\" syntax for the Layouts dir
	if ( ( not inStr( iniFile, "." ) ) and FileExist( getPklInfo( "File_" . iniFile ) ) )	; Special files
		iniFile := getPklInfo( "File_" . iniFile )						; (These include Pkl_Ini, Lay_Ini, Pkl_Dic)
	default := ( default == "" ) ? A_Space : default					; IniRead uses a Space for blank defaults
	if ( key == -1 ) {													; Specify key = -1 for a section list
		IniRead, val, %iniFile%											; (AHK v1.0.90+)
	} else {
		IniRead, val, %iniFile%, %section%, %key%, %default%
	}
	val := ( strip ) ? strCom( val ) : val								; Strip end-of-line comments
	val := ( SubStr( val, 1, 2 ) == ".\" ) ? hereLay . SubStr( val, 2 ) : val	; ".\" syntax for the Layouts dir
;	MsgBox, '%val%', '%iniFile%', '%section%', '%key%', '%default%'		; eD DEBUG
	Return val
}

pklIniBool( key, default = "", iniFile = "Pkl_Ini", section = "pkl" )	; Special read function for boolean values
{
	val := pklIniRead( key, default, iniFile, section )		;IniRead, val, %iniFile%, %section%, %key%, %default%
	val := ( val == "1" || val == "yes" || val == "y" || val == "true" ) ? true : false
	Return val
}

pklIniPair( key, default = "", iniFile = "Pkl_Ini", section = "pkl" )	; Read a CSV .ini entry into an array
{
	val := pklIniRead( key, default, iniFile, section )
	val := StrSplit( val, ",", " `t" )
	Return val
}

;-------------------------------------------------------------------------------------
;
; Helper functions for .ini file handling
;
pklIniKeyVal( iniLine, ByRef key, ByRef val, esc=0, com=1 )		; Because PKL doesn't always use IniRead? Why though?
{
	pos := InStr( iniLine, "=" )
	key := Trim( SubStr( iniLine, 1, pos-1 ))
	val := Trim( SubStr( iniLine,    pos+1 ))
	val := ( com ) ? strCom( val ) : val
	val := ( esc ) ? strEsc( val ) : val
	key := ( pos == 0 ) ? "<NoKey>" : key
}

strCom( str )												; Remove end-of-line comments (whitespace then semicolon)
{
	str := RegExReplace( str, "m)[ `t]+;.*$" )				; Multiline option for matching single lines
	Return str
}

strEsc( str )												; Replace \# escapes
{
	str := StrReplace( str, "\r", "`r" )
	str := StrReplace( str, "\n", "`n" )
	str := StrReplace( str, "\t", "`t" )
	str := StrReplace( str, "\b", "`b" )
	str := StrReplace( str, "\\", "\"  )
	Return str
}

/*
; eD TODO: Make a function that reads a section and returns a pdic of (key,value) pairs?
;			- Better than it is today in, say, locale.ahk!
;			- How to "save" existing layout files?! Exclude `t;`t sequences?
;			- Today's solution of parsing layout.ini by column should be sufficient though!
*/
