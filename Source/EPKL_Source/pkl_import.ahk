;; ================================================================================================
;;  EPKL Layout Import module: Turn any MSKLC (or other format?) file into an EPKL layout.
;;    - Works from the Layouts\_Import directory, turning any .klc files in _Inbox into layouts.
;;    - WIP: Just use an _Inbox under layouts, and generate directly into the Layout dir? Check if existing then.
;;    - Uses a template with a set of regular expression (RegEx) entries to generate the Layout.ini file.
;

importLayouts() 	; eD TODO
{
	LIM                 := {}
	LIM.Name            := "EPKL Layout Import Module"
	LIM.LayDic          := {}
	
	impRoot             := "Layouts\_Import"
	layToFrom           := "KLC-EPKL" 					; eD TODO: More possibilities here? Set in Settings, or dialog?
	layTemplate         := impRoot . "\_Files\ImportTemplate_" . LayToFrom . ".ini"
;	FormatTime, theNow,, yyyy-MM-dd_HHmm				; Use A_Now (local time) for a folder time stamp

	MsgBox, 0x21, Import layouts?, 						; MsgBox type is 0x1 (OK/Cancel) + 0x20 (Question)
(
Working from %impRoot%
Do you want to import the layouts in _Inbox
from MSKLC to EPKL format under this folder?
)
	IfMsgBox, Cancel
		Return
	pklSplash( LIM.Name, "Starting...", 2 )
	LIM.Inbox := [ "CmkCAWeD_WIP" ] 					; eD WIP: Make a list of the _Inbox dir .klc files from a dir cmd
	try {
		For dirTag, theDir in LIM.Inbox
		{
			if ( 0 )
				Continue
			FileCreateDir % impRoot . "\" . theDir
		}
	} catch {
		pklErrorMsg( "Couldn't create folders." )
		Return
	}
	Return  	; eD DEBUG

	pklSplash( LIM.Name, "Layout import done!", 2 )
	
;	VarSetCapacity( LIM , 0 )							; Clean up the object after use, if static/global
}

_importOneLayout( LIM )								; Function to import one layout via a template .ini
{
	static temp
	static initialized  := false
	
	if ( not initialized ) {
		if not theFile := pklFileRead( importFile, "template" )
			Return
		initialized := true
	}
	
;	needle := "\K" . "(.*)" 		; The RegEx to search for (ignore the start w/ \K)
;	result := "${1}" 			; 
	theFile := RegExReplace( theFile, needle , result )
;	Return 		; eD DEBUG
	if not pklFileWrite( theFile, tempFile, "temporary file" )
		Return
}


;; ================================================================================================
;;  EPKL Compose Import module: Turn any X11-libs Compose file into an EPKL Compose table.
;;    - Works from the Files\Composer directory, turning a Compose.h file in _Inbox into .ini files.
;;    - Uses a template with a set of regular expression (RegEx) entries to generate the .ini file.
;;    - Uses a keysymdef file to translate keysym names into Unicode points.
;;    - Note: The usual X11 keysymdef.h doesn't always use Unicode! It's fine for normal characters.
;;    - Instead, use the keysyms.txt file by [Dr Markus Kuhn](https://www.cl.cam.ac.uk/~mgk25/) .
;

importComposer() { 	;
	CIM         := {} 											; Variables for the Compose Import module
	CIM.Title   := "EPKL Compose Import Module"
	CIM.Dir     := "Files\Composer\"
	CIM.RegExes := CIM.Dir   . "RegEx_Composer.ini"
	CIM.InDir   := CIM.Dir   . "_Inbox\"
	CIM.SymFile := CIM.InDir . "KeySyms.ini" 					; KeySymDef.ini
	CIM.SymOrig := CIM.InDir . "keysyms.txt" 	 				; Original X-libs keysymdef.h -> Markus Kuhn's Unicode keysyms.txt
	CIM.CmpFile := CIM.InDir . "Compose.ini" 					; Compose.ini
	CIM.CmpOrig := CIM.InDir . "compose.h" 						; Original X-libs compose; add a .h ending for Win text editor convenience
	CRLF    := "`r`n"
	a_SC    := "`;"
	compCHR := "⇒" 												; This char is used in compose file comments: char + char ⇒ char
	
	MsgBox, 0x021, Convert Compose tables?,  					; 0x100: 2nd button default. 0x30: Warning. 0x1: OK/Cancel
(
 Composer Import Module
—————————————————————————————

From a compose.h file in Files\Composer\_Inbox,
generate a Compose.ini file useable with EPKL.

Do you wish to do this now?
Large files may take some time.
)
	IfMsgBox, Cancel 				; MsgBox type is 0x3 (Yes/No/Cancel) + 0x30 (Warning) + 0x100 (2nd button is default)
		Return false
	if FileExist( CIM.SymFile ) {
		pklSplash( CIM.Title, "Found key file " . CIM.SymFile . "`nProceeding..." )
	} else {
		fileStr := imp_convertFile( CIM, CIM.SymOrig, CIM.SymFile, "KeySyms", "Key symbol definition file for the " . CIM.Title, false ) 	; don't write the file yet
		if not fileStr
			Return false
;			pklErrorMsg( "Original KeySym file not found!`nExiting " . CIM.Title )
		tempStr := ""
		For ix, row in StrSplit( fileStr, "`n", "`r" ) { 		; This allows Linux as well as Windows line endings, but we may already have settled that
			row := ( SubStr( row, 1, 1 ) == a_SC ) ? row
				 : padStr( row, 28, "=" ) 						; Pad the key with spaces
			tempStr .= row . CRLF
		} 	; end for KeySym
		fileStr := RegExReplace( tempStr, "\R+$", "`r`n" ) 		; Strip off the last CRLF
		if not pklFileWrite( fileStr, CIM.SymFile )
			Return false
	}
	fileStr := imp_convertFile( CIM, CIM.CmpOrig, CIM.CmpFile, "XCompose" ,    "Compose definition file for the " . CIM.Title, false ) 	; don't write the file yet
	if not fileStr 												; Is there a 5000 lines limit to the FileRead? We can trim X compose files to under that manually.
		Return false
	pklSplash( CIM.Title, "Recomposing composes... Hang on...", 30 )
	shorts  := { "ascii"    : "ASC" , "Greek_"     : "Gre_", "Arabic_"     : "Ara_"
			   , "hebrew_"  : "Heb_", "Cyrillic_"  : "Cyr_", "Ukrainian_"  : "Ukr_" }
	For ix, row in pklIniSect( CIM.SymFile, "KeySyms" ) { 		; Read the list key symbol definitions. KeySym -> U####[#], so 4 keys will be 23-27 chars long... or?
		pklIniKeyVal( row, key, val, 0 ) 						; Read without character escapes (with comment stripping)
		fileStr := StrReplace( fileStr, "<" . key . ">", val )
		For src, rep in shorts { 								; Replace long strings in [KeySym] names
			ky2 := StrReplace( key, src, rep )
			if InStr( key, src )
				Break
		}
		fileStr := StrReplace( fileStr, "[" . key . "]", padStr( ky2, 12 ) )
	} 	; end for KeySyms
	tempStr  := ""
	For ix, row in StrSplit( fileStr, "`n", "`r" ) {
		if ( InStr( row, "U" ) == 1 ) { 						; Used to be 0x####; now it's U####.
			row     := padStr( row, 26, "=" )
			len     := RegExMatch( row, "[ \t]" ) -1 			; Find the length of the key by matching the first whitespace
			pad3    := ( len > 14 ) ? "" : "               " 	; In the comment, pad 2-key entries (len >= 11) to 3-key (len >= 17) length for prettiness
			row     := StrReplace( row, compCHR, pad3 . compCHR )
			srchPos := 1
			While ( pos := RegExMatch( row, "\[U[[:xdigit:]]{4,7}\]", mat, srchPos ) ) { 	; Find any [U####] Unicode points
				mat := SubStr( mat, 2, -1 ) 					; Strip the [] from the U####
				row := SubStr( row, 1, pos -1 ) . padStr( mat, 12 ) . SubStr( row, pos + StrLen( mat ) + 2 ) 	; len(mat) -2 +1 ?
			}
		} 	; end if ^U####
		tempStr .= row . CRLF
	} 	; end for row in fileStr
	fileStr := RegExReplace( tempStr, "\R+$", "`r`n" ) 			; Strip off the last CRLF
	if not pklFileWrite( fileStr, CIM.CmpFile )
		Return false
	pklSplash( CIM.Title, "Finished converting " . CIM.CmpFile . "!", 2.5 )
}


;; ================================================================================================
;;  EPKL Import Module Process: Import a file and convert it using a specified set of regular expressions.
;

imp_convertFile( IMP, inFile, outFile, regExSect, title = "Imported EPKL file", write = true ) {
	if not FileExist( outFile ) { 								; Convert a file into another format using a series of RegExes
		pklSplash( IMP.Title, "Creating " . inFile . " now..."  , 2.5 )
	} else {
		FileDelete % outFile 									; FileWrite appends to files, so delete any outFile. Remove this eventually? It's mostonly here for debugging
		pklSplash( IMP.Title, "Deleted "  . inFile . " first...", 2.5 )
	} 	; end if FileExist outFile
	ini     := ".ini"
	CRLF    := "`r`n"
	a_SC    := "`;"
	QU      := "" 	;"""" 										; Literal double quote for the log, if applied. Use ” instead?
	COMM    := a_SC . a_SC . "  " 								; Start of a ;; comment line
	
	if not fileStr := pklFileRead( inFile, inFile )
		Return false
	rExLog  := ";;  The following RegExes were used in the conversion of this file:" . CRLF 
			 . ";;  ===============================================================" . CRLF 
	regExes := {}
	For ix, row in pklIniSect( IMP.RegExes, regExSect ) { 		; Read the list of regular expressions to use on this file
		pklIniKeyVal( row, key, val, 0 ) 						; Read without character escapes yet, as they should only be performed for val[2]
		if ( key == "<NoKey>" || key == "<Blank>" )
			Continue 
		key     := padStr( key, 8 ) . " :  "
		val     := StrSplit( val, "→", " `t" ) 					; Split by the special character →, ignore whitespace
		needle  := SubStr( val[1], 2, -1 ) 						; Any character can be used as "quotes" around the entries.
		repTxt  := SubStr( val[2], 2, -1 ) 						; Note: Actual " at entry boundaries may get stripped by IniRead().
		val_1   := padStr( needle, 40, , QU . needle . QU )
		val_2   := QU . repTxt . QU
		repTxt  := strEsc( repTxt ) 							; AHK can't read newlines from the file? Use escapes in repTxt.
		if ( upCase( SubStr(key,1,2) ) == "SR" ) {
			fileStr := StrReplace(   fileStr, needle, repTxt ) 	; Search-and-replace is simpler and faster than RegEx
		} else { 		; RegEx syntax tips: m) is multiline mode. \K to drop everything matched so far. (?=…)/(?<=…) lookahead/-behind. (?!…) negative lookahead.
			fileStr := RegExReplace( fileStr, needle, repTxt )
		}
		rExLog  .= COMM . key . val_1 . " → " . val_2 . CRLF
	} 	; end for row in regExSection
	header  := getPklInfo( "pklHdrA" ) . title . CRLF 
			 . COMM . "This file was imported and converted from " . inFile . getPklInfo( "pklHdrB" )
	header  .= rExLog . a_SC . CRLF . CRLF
	fileStr := header . "[" . regExSect . "]" . CRLF . COMM . "Imported and processed by the EPKL IMP" . CRLF . fileStr
	pklSplash( IMP.Title, "Importing " . inFile . " done!", 2 )
	if ( write ) {
		if not pklFileWrite( fileStr, outFile )
			Return false
		Return true
	} else {
		Return fileStr
	}
} 	; end convertFile

padStr( str, padTo, sep = false , out = false ) { 				; Pads a key with spaces up to a desired length. If it's longer, leave it.
	SPCX    := "          " . "          " 						; 20 spaces for easier counting below
	SPCs    := SPCX . SPCX . SPCX . SPCX . SPCX . SPCX 			; 120 spaces for padding purposes
	if ( sep ) { 												; Pad the key in a 'key = val' type string
		pos := InStr( str, sep )
		key := Trim( SubStr( str, 1, pos-1 ))
	} else { 													; Pad a single string
		key := str
		pos := StrLen( str ) + 1
	}
	if ( pos ) {
		out := ( out ) ? out : key
		len := StrLen( out )
		if ( ( len > padTo ) || ( len > StrLen( SPCs ) ) )
			Return str
		out := SubStr( out . SPCs, 1, padTo )
		Return out . SubStr( str, pos )
	} else { 													; No separator found
	Return str
	}
}
