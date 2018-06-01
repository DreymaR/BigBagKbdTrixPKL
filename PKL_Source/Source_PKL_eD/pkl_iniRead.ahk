;-------------------------------------------------------------------------------------
;
; Read a section of an .ini file
;     Strips away blank and comment lines but not end-of-line comments
;     Able to read UTF-8 files, as AHK's IniRead can only handle UTF-16?
;
iniReadSection( file, section )
{
	try {
		FileRead, fileTxt, *P65001 %file%							; A way to read UTF-8 files
	} catch {
		MsgBox, PKL error:`nUnable to open file %file% `n
		ExitApp, 35
	}
	spc := "[^\S\n\r]*"
	RegExMatch( fileTxt, "is)(^|\R)" . spc . "\[" . spc . section . spc . "\][^\R]*(\R.*?)($|\R" . spc . "\[)", secTxt )
	secTxt := RegExReplace( secTxt2, "`am)^[ `t]*;.*" )				; Strip comment lines (multiline mode)
	secTxt := RegExReplace( secTxt , "\R([ `t]*\R)+", "`r`n" )		; Strip empty and whitespace lines
	;msgbox, %secTxt%
	return secTxt	; The match string of RegExMatch
}

;-------------------------------------------------------------------------------------
;
; Read a (pkl).ini value
;     Usage: val := pklIniRead( <key>, [default], [inifile|shortstr], [section] )
;     Note: AHK IniRead trims off whitespace and a pair of quotes if present, but not comments.
;
pklIniRead( key, default = "", inifile = "Pkl_Ini", section = "pkl", strip = 1 )
{
	if ( ( not inStr( inifile, "." ) ) and FileExist( getPklInfo( "File_" . inifile ) ) )	; special files
		inifile := getPklInfo( "File_" . inifile )
	default := ( default == "" ) ? A_Space : default					; IniRead uses a Space for blank defaults
	if ( key == -1 ) {													; Specify key = -1 for a section list
		IniRead, val, %inifile%											; (AHK v1.0.90+)
	} else {
		IniRead, val, %inifile%, %section%, %key%, %default%
	}
	val := ( strip ) ? strCom( val ) : val								; Strip end-of-line comments
;	MsgBox, '%val%', '%inifile%', '%section%', '%key%', '%default%'		; eD: Debug
	return val
}

pklIniBool( key, default = "", inifile = "Pkl_Ini", section = "pkl" )	; Special read function for boolean values
{
	val := pklIniRead( key, default, inifile, section )		;IniRead, val, %inifile%, %section%, %key%, %default%
	val := ( val == "1" || val == "yes" || val == "y" || val == "true" ) ? true : false
	return val
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
	return str
}

strEsc( str )												; Replace \n and \\ escapes
{
	StringReplace, str, str, \n, `n, A
	StringReplace, str, str, \\, \, A
	return str
}

/*
; eD TODO: Make a function that reads a section and returns a pdic of (key,value) pairs?
;			- Better than it is today in, say, locale.ahk!
;			- How to "save" existing layout files?! Exclude `t;`t sequences?
;			- Today's solution of parsing layout.ini by column should be sufficient though!
*/
