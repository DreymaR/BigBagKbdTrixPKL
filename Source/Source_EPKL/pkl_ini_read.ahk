;;  -----------------------------------------------------------------------------------------------
;;
;;  Read a section of an .ini file
;;      Strips away blank and comment lines but not end-of-line comments
;;      Able to read UTF-8 files, as AHK's IniRead can only handle UTF-16(?)
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
	Return StrSplit( secTxt, "`n", "`r" ) 							; Return an array of lines
}

;;  -----------------------------------------------------------------------------------------------
;;
;;  Read a (pkl).ini value
;;      Usage: val := pklIniRead( <key>, [default], [inifile(s)|shortstr], [section], [stripcomments] )
;;      Special key values return a section list or the contents of a section
;;      Note: AHK IniRead trims off whitespace and a pair of quotes if present, but not comments.
;
pklIniRead( key, default = "", iniFile = "PklSet", section = "pkl", strip = 1 )
{
	if ( not key )
		Return
	layStck := ( iniFile == "LayStk" ) ? true : false
	if ( layStck ) { 													; The LayStack is a special case,
		iniFile := getPklInfo( "LayStack" ) 							; going through all 4 layout files.
		iniDirs := getPklInfo( "DirStack" )
	}
	if ( ! IsObject( iniFile ) ) 										; Turn single-file calls into arrays
		iniFile := [ iniFile ]
	For ix, theFile in iniFile { 										; Read from iniFile. Failing that, altFile.
		hereDir := ( layStck ) ? iniDirs[ix] : "." 						; LayStack files may use own home dirs
		if ( ( not InStr(theFile, ".") ) && FileExist(getPklInfo("File_" . theFile)) )	; Special files
			theFile := getPklInfo( "File_" . theFile )					; (These include PklSet, PklLay, PklDic)
		if        ( key == "__List" ) { 								; Specify key = -1 for a section list
			IniRead, val, %theFile% 									; (AHK v1.0.90+)
		} else if ( key == "__Sect" ) { 								; Specify key = -2 to read a whole section
			IniRead, val, %theFile%, %section% 							; (AHK v1.0.90+)
		} else {
			IniRead, val, %theFile%, %section%, %key%, %A_Space%		; IniRead uses a Space for blank defaults
		}
		if ( val ) 														; Once a value is found, break the for loop
			Break
	}	; end For theFile
	val := convertToUTF8( val ) 										; Convert string to enable UTF-8 files (not UTF-16)
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

pklIniCSVs( key, default = "", iniFile = "PklSet", section = "pkl"
		  , sch = ",", ich = " `t" ) 									; Read a CSV-type .ini entry into an array
{
	val := pklIniRead( key, default, iniFile, section ) 				; The default could be, e.g., "400,300"
	Return StrSplit( val, sch, ich ) 									; Split by sch, ignore ich
}

;;  -----------------------------------------------------------------------------------------------
;;
;;  Helper functions for .ini file handling
;
pklIniKeyVal( row, ByRef key, ByRef val, esc=0, com=1 ) 	; Because PKL doesn't always use IniRead? Why though?
{
	pos := InStr( row, "=" )
	key := Trim( SubStr( row, 1, pos-1 ))
	val := Trim( SubStr( row,    pos+1 ))
	val := ( com ) ? strCom( val ) : val 					; Comment stripping
	val := ( esc ) ? strEsc( val ) : val 					; Character escapes
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
