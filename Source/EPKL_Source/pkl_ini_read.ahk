;;  ========================================================================================================================================================
;;  EPKL Ini read module
;;  - Functions for reading and preprocessing sections and values from .ini data files
;

;;  ========================================================================================================================================================
;;  Read a section of an .ini file
;;      Strips away blank and comment lines but not end-of-line comments by default
;;      Able to read UTF-8 files, as AHK's IniRead can only handle UTF-16(?)
;

pklIniSect( file, section := "pkl", strip := 0 ) {  				; Read an .ini section as a line array
	If not fileTxt := pklFileRead( file )   						; Use "*P65001 <file>" to read UTF-8 .ini files
		ExitApp, 35
	needle := "is)(?:^|\R)[ `t]*\[[ `t]*" . section . "[ `t]*\][^\R]*?\R\K(.*?)(?=$|\R[ `t]*\[)"
	RegExMatch( fileTxt, needle, secTxt )   						; is) = IgnoreCase, DotAll. \K = LookBehind.
	secTxt := RegExReplace( secTxt, "`am)^[ `t]*;.*" )  			; Strip comment lines (multiline mode, any \R)
	secTxt := RegExReplace( secTxt, "\R([ `t]*\R)+", "`r`n" )   	; Strip empty and whitespace lines
	secTxt := ( strip ) ? strCom( secTxt ) : secTxt 				; Strip end-of-line comments, if set
	Return StrSplit( secTxt, "`n", "`r" )   						; Return an array of lines
}

;;  ========================================================================================================================================================
;;  Read a (pkl).ini value
;;      Usage: val := pklIniRead( <key>, [default], [inifile(s)|shortstr], [section], [stripcomments] )
;;      Special key values return a section list or the contents of a section
;;      Note: AHK IniRead trims off whitespace and a pair of quotes if present, but not comments.
;
pklIniRead( key, default := "", iniFile := "PklSet", section := "pkl", strip := 1 ) { 
	If ( not key )
		Return
	If ( layStck := ( iniFile == "LayStk" ) ? true : false ) {  		; The LayStack is a special case,
		iniFile := getPklInfo( "LayStack" ) 							; going through all (4+ or so) layout stack files.
		iniDirs := getPklInfo( "DirStack" )
	} else if ( iniFile == "PklSet" ) {
		iniFile := getPklInfo( "SetStack" )
	}
	If ( ! IsObject( iniFile ) ) 										; Turn single-file calls into arrays
		iniFile := [ iniFile ]
	For ix, theFile in iniFile { 										; Read from iniFile. Failing that, altFile.
		SplitPath, theFile, , hereDir
;		hereDir := ( theFile == "LayIni" ) ? getPklInfo( "Dir_LayIni" ) : 	; eD WIP: This somehow made layouts lose their tray icons?!
		hereDir := ( layStck ) ? iniDirs[ix] : hereDir  				; LayStack files may use own home dirs
		If ( ( not InStr(theFile, ".") ) && FileExist(getPklInfo("File_" . theFile)) )	; Special files
			theFile := getPklInfo( "File_" . theFile )					; (These include PklSet, PklLay, PklDic)
		If        ( key == "__List" ) { 								; Use key = __List for a section list
			val := IniRead( theFile )   								; (AHK v1.0.90+)
		} else if ( key == "__Sect" ) { 								; Use key = __Sect to read a whole section
			val := IniRead( theFile, section )  						; (AHK v1.0.90+)
		} else {
			val := IniRead( theFile, section, key, " " )    			; IniRead uses a Space for blank defaults
		}
		If ( val )  													; Once a value is found, break the for loop
			Break
	}	; end For theFile
	val := convertToUTF8( val ) 										; Convert string to enable UTF-8 files (not UTF-16)
	val := ( val ) ? val : default										; (IniRead's std. default is the word ERROR; EPKL uses "")
	val := ( strip ) ? strCom( val ) : val								; Strip end-of-line comments
	If        ( SubStr( val, 1, 3 ) == "..\" ) {						; "..\" syntax for layout dirs
		val := hereDir . "\.." . SubStr( val, 3 )
	} else if ( SubStr( val, 1, 2 ) == ".\"  ) {						; ".\"  syntax --"--
		val := hereDir .         SubStr( val, 2 )
	}
;	MsgBox, '%val%', '%theFile%', '%section%', '%key%', '%default%'		; eD DEBUG
	Return val
}

pklIniCSVs( key, default := "", iniFile := "PklSet", section := "pkl"
		  , splch := ",", ignch := " `t" ) {    						; Read a CSV-type .ini entry into an array
	val := pklIniRead( key, default, iniFile, section ) 				; The default could be, e.g., "400,300"
	Return StrSplit( val, splch, ignch ) 									; Split by splch, ignore ignch
}

;;  ========================================================================================================================================================
;;  Helper functions for .ini and other file handling
;
pklIniKeyVal( row, ByRef key, ByRef val, esc := 0, com := 1, quo := 0 ) {   	; Because PKL doesn't always use IniRead? Why though?
	pos := InStr( row, "= " )   							; Spc after `=` is enforced. Avoids ambiguity vis-a-vis `<=> = ‹entry›` etc.
	key := Trim( SubStr( row, 1, pos-1 ))   				; Trim() removes surrounding WhiteSpace
	val := Trim( SubStr( row,    pos+1 ))
	val := ( com ) ? strCom( val ) : val    				; Comment stripping
	val := ( quo ) ? Trim( val, "'""" ) : val   			; Single+double quote stripping (preserves any whitespace within quotes)
	val := ( esc ) ? strEsc( val ) : val    				; Character escapes
	If ( StrLen( row ) == 0 || SubStr( row, 1, 1 ) == ";" ) {
		key := "<Blank>"
	} else if ( pos == 0 ) {
		key := "<NoKey>"
	}
}

strCom( str ) { 											; Remove end-of-line comments (whitespace, then semicolon, then anything)
	str := RegExReplace( str, "m)[ `t]+;.*$" )  			; Multiline option for matching single lines
	Return str
}

strEsc( str ) { 											; Replace \# character escapes in a string
	str := StrReplace( str, "\r", "`r" )
	str := StrReplace( str, "\n", "`n" )
	str := StrReplace( str, "\t", "`t" )
	str := StrReplace( str, "\b", "`b" )
	str := StrReplace( str, "\\", "\"  )
	Return str
}

pklFileRead( file, name := "" ) {   						; Read a file
	name := ( name ) ? name : file
	try { 													; eD NOTE: Use Loop, Read, ? Nah, 160 kB or so isn't big.
		FileRead, content, *P65001 %file% 					; "*P65001 " is a way to read UTF-8 files
	} catch {
		pklErrorMsg( "Failed to read `n  " . name )
		Return false
	}
	Return content
}

pklFileWrite( content, file, name := "" ) { 				; Write/Append to a file
	name := ( name ) ? name : file
	try {
		FileAppend, %content%, %file%, UTF-8
	} catch {
		pklErrorMsg( "Failed writing to `n  " . file )
		Return false
	}
	Return true
}
