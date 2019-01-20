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
;     Usage: val := pklIniRead( <key>, [default], [inifile|shortstr], [section], [altfile|str], [stripcomments] )
;     Note: AHK IniRead trims off whitespace and a pair of quotes if present, but not comments.
;
pklIniRead( key, default = "", iniFile = "PklIni", section = "pkl", altFile = "", strip = 1 )
{
	if ( not key )
		Return
	for inx, theFile in [ iniFile, altFile ]							; Read from iniFile. Failing that, altFile.
	{
		if        ( theFile == "LayIni" ) {
			hereDir := getLayInfo( "layDir" )							; ".\" syntax for the main layout dir
		} else if ( theFile == "BasIni" ) {
			hereDir := getLayInfo( "basDir" )							; ".\" syntax for the base layout dir
		} else {
			hereDir := "."
		}
		if ( ( not inStr( theFile, "." ) ) and FileExist( getPklInfo( "File_" . theFile ) ) )	; Special files
			theFile := getPklInfo( "File_" . theFile )					; (These include PklIni, LayIni, PklDic)
		if        ( key == -1 ) {										; Specify key = -1 for a section list
			IniRead, val, %theFile%										; (AHK v1.0.90+)
		} else if ( key == -2 ) {										; Specify key = -2 to read a whole section
			IniRead, val, %theFile%, %section%							; (AHK v1.0.90+)
		} else {
			IniRead, val, %theFile%, %section%, %key%, %A_Space%		; IniRead uses a Space for blank defaults
		}
		if ( val )
			Break
	}	; end for
	val := ( val ) ? val : default										; (IniRead's std. default is the word ERROR)
	val := ( strip ) ? strCom( val ) : val								; Strip end-of-line comments
	if        ( SubStr( val, 1, 3 ) == "..\" ) {						; "..\" syntax for layout dirs
		val := hereDir . "\.." . SubStr( val, 3 )
	} else if ( SubStr( val, 1, 2 ) == ".\"  ) {						; ".\"  syntax --"--
		val := hereDir .         SubStr( val, 2 )
	}
;	MsgBox, '%val%', '%theFile%', '%section%', '%key%', '%default%'		; eD DEBUG
	Return val
}

pklIniBool( key, default = "", iniFile = "PklIni", section = "pkl", altFile = "" )	; Special .ini read for boolean values
{
	val := pklIniRead( key, default, iniFile, section, altFile )
	val := ( val == "1" || val == "yes" || val == "y" || val == "true" ) ? true : false
	Return val
}

pklIniCSVs( key, default = "", iniFile = "PklIni", section = "pkl", altFile = "" )	; Read a CSV .ini entry into an array
{
	val := pklIniRead( key, default, iniFile, section, altFile )		; The default could be, e.g., "400,300"
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
	val := ( com ) ? strCom( val ) : val					; Comment stripping
	val := ( esc ) ? strEsc( val ) : val					; Character escapes
	key := ( pos == 0 ) ? "<NoKey>" : key
}

strCom( str )												; Remove end-of-line comments (whitespace then semicolon)
{
	str := RegExReplace( str, "m)[ `t]+;.*$" )				; Multiline option for matching single lines
	Return str
}

strEsc( str )												; Replace \# character escapes in a string
{
	str := StrReplace( str, "\r", "`r" )
	str := StrReplace( str, "\n", "`n" )
	str := StrReplace( str, "\t", "`t" )
	str := StrReplace( str, "\b", "`b" )
	str := StrReplace( str, "\\", "\"  )
	Return str
}
