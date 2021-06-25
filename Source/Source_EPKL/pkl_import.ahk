;; ================================================================================================
;;  EPKL Import module: Turn any MSKLC (or other format?) file into an EPKL layout.
;;    - Works from the Layouts\_Import directory, turning any .klc files in _Inbox into layouts.
;;    - Uses a template with a set of regular expression (RegEx) entries to generate the layout.ini file.
;

importLayouts() 	; eD TODO
{
	IMP                 := {}
	IMP.Name            := "EPKL Layout Import Module"
	IMP.LayDic          := {}
	
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
	pklSplash( IMP.Name, "Starting...", 2 )
	IMP.Inbox := [ "CmkCAWeD_WIP" ] 					; eD WIP: Make a list of the _Inbox dir .klc files from a dir cmd
	try {
		For dirTag, theDir in IMP.Inbox
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

	pklSplash( IMP.Name, "Layout import done!", 2 )
	
;	VarSetCapacity( IMP , 0 )							; Clean up the object after use, if static/global
}

_importOneLayout( IMP )								; Function to import one layout via a template .ini
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
;;    - Uses an X11 keysymdef.h file to translate keysym names into Unicode points.
;

importComposer() { 	;
	Cmp         := {} 											; Variables for the Compose Import module
	Cmp.Title   := "EPKL Compose Import Module"
	Cmp.Dir     := "Files\Composer\"
	Cmp.RegExes := Cmp.Dir   . "RegEx_Composer.ini"
	Cmp.InDir   := Cmp.Dir   . "_Inbox\"
	Cmp.SymFile := Cmp.InDir . "KeySymDef.ini" 					; KeySymDef.ini
	Cmp.SymOrig := Cmp.InDir . "keysymdef.h" 	 				; Original X-libs keysymdef.h
	Cmp.CmpFile := Cmp.InDir . "Compose.ini" 					; Compose.ini
	Cmp.CmpOrig := Cmp.InDir . "compose.h" 						; Original X-libs compose; add a .h ending for Win text editor convenience
	CRLF        := "`r`n"
	SPCX    := "          " 									; 10 spaces for easier counting below
	SPCs    := SPCX . SPCX . SPCX . SPCX 						; 40 spaces for padding purposes
	compCHR := "⇒" 												; This char is used in compose comments: char + char ⇒ char
	
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
		Return
	if FileExist( Cmp.SymFile ) {
		pklSplash( Cmp.Title, "Found key file " . Cmp.SymFile . "`nProceeding..." )
	} else {
		if not imp_convertFile( Cmp, Cmp.SymOrig, Cmp.SymFile, "KeySymDef", "Key symbol definition file for the " . Cmp.Title )
	;		pklErrorMsg( "Original KeySym file not found!`nExiting " . Cmp.Title )
			Return false
	}
	compStr := imp_convertFile( Cmp, Cmp.CmpOrig, Cmp.CmpFile, "XCompose" ,    "Compose definition file for the " . Cmp.Title, false ) 	; Doesn't write the file yet
	if not compStr 												; Is there a 5000 lines limit to the FileRead? We can trim X compose files to under that manually.
		Return false
	pklSplash( Cmp.Title, "Recomposing composes... Hang on...", 30 )
	shorts  := { "ascii"    : "ASC" , "Greek_"     : "Gre_", "Arabic_"     : "Ara_"
			   , "hebrew_"  : "Heb_", "Cyrillic_"  : "Cyr_", "Ukrainian_"  : "Ukr_" }
	For ix, row in pklIniSect( Cmp.SymFile, "KeySymDef" ) { 	; Read the list key symbol definitions. KeySym -> 0x####[#], so 4 keys will be 27-31 chars long... or?
	;; keysymdef.h has entries like `Ecircumflexbelowdot = 0x1001ec6` (9 chars) and compose uses those... but never more than one per sequence. So, 31 is still okay.
		pklIniKeyVal( row, key, val, 0 ) 						; Read without character escapes (with comment stripping)
		compStr := StrReplace( compStr, "<" . key . ">", val )
		For src, rep in shorts { 								; Replace long strings in [KeySym] names
			ky2 := StrReplace( key, src, rep )
			if InStr( key, src )
				Break
		}
		compStr := StrReplace( compStr, "[" . key . "]", SubStr( ky2 . SPCs, 1, 10 ) )
	} 	; end for KeySymDef
	tempStr  := ""
	For ix, row in StrSplit( compStr, "`n", "`r" ) { 			; This allows Linux as well as Windows line endings, but we may already have settled that
		if ( SubStr( row, 1, 2 ) == "0x" ) {
			pos     := RegExMatch( row, "^\S*", mat ) 			; Find the (length of the) key
			len     := StrLen( mat )
			row     := ( len > 30 ) ? row : SubStr( mat . SPCs, 1, 30 ) . SubStr( row, len + 1 )
			pad3    := ( len > 19 ) ? "" : SPCX . "   " 		; In the comment, pad 2-key entries (len >= 13) to 3-key (len >= 20) length for prettiness
			row     := StrReplace( row, compCHR, pad3 . compCHR )
			srchPos := 1
			While ( pos := RegExMatch( row, "\[U[[:xdigit:]]{4,7}\]", mat, srchPos ) ) { 	; Find any [U####] Unicode points
				mat := SubStr( mat, 2, -1 ) 					; Strip the [] from the U####
				row := SubStr( row, 1, pos -1 ) . SubStr( mat . SPCs, 1, 10 ) . SubStr( row, pos + StrLen( mat ) + 2 ) 	; len(mat) -2 +1 ?
			}
		} 	; end if ^0x####
		tempStr .= row . CRLF
	} 	; end for row in compStr
	compStr := RegExReplace( tempStr, "\R+$", "`r`n" ) ;tempStr ;SubStr( tempStr, -2 ) 							; Strip off the last CRLF
	if not pklFileWrite( compStr, Cmp.CmpFile )
		Return false
	pklSplash( Cmp.Title, "Finished converting " . Cmp.CmpFile . "!", 2.5 )
}

imp_convertFile( Imp, inFile, outFile, regExSect, title = "Imported EPKL file", write = true ) {
	if not FileExist( outFile ) { 								; Convert a file into another format using a series of RegExes
		pklSplash( Imp.Title, "Creating " . inFile . " now..."  , 2.5 )
	} else {
		FileDelete % outFile 									; FileWrite appends to files, so delete any outFile. Remove this eventually? It's mostonly here for debugging
		pklSplash( Imp.Title, "Deleted "  . inFile . " first...", 2.5 )
	} 	; end if FileExist outFile
	ini         := ".ini"
	CRLF        := "`r`n"
	QU          := "" 	;"""" 									; Literal double quote for the log, if applied. Use ” instead?
	a_SC        := "`;"
	COMM        := a_SC . a_SC . "  " 							; Start of a ;; comment line
	SPCX    := "          " 									; 10 spaces for easier counting below
	SPCs    := SPCX . SPCX . SPCX . SPCX 						; 40 spaces for padding purposes
	
	if not fileStr := pklFileRead( inFile, inFile )
		Return false
	rExLog  := ";;  The following RegExes were used in the conversion of this file:" . CRLF 
			 . ";;  ===============================================================" . CRLF 
	regExes := {}
	For ix, row in pklIniSect( Imp.RegExes, regExSect ) { 		; Read the list of regular expressions to use on this file
		pklIniKeyVal( row, key, val, 0 ) 						; Read without character escapes yet, as they should only be performed for val[2]
		if ( key == "<NoKey>" || key == "<Blank>" )
			Continue 
		key     := SubStr( key . SPCX, 1, 8 ) . " :  "
		val     := StrSplit( val, "→", " `t" ) 					; Split by the special character →, ignore whitespace
		needle  := SubStr( val[1], 2, -1 ) 						; Any character can be used as "quotes" around the entries.
		repTxt  := SubStr( val[2], 2, -1 ) 						; Note: Actual " at entry boundaries may get stripped by IniRead().
		spcN    := StrLen( SPCs )
		val_1   := ( StrLen( needle ) > spcN ) ? QU . needle . QU
				 : QU . SubStr( needle . QU . SPCs, 1, spcN ) 	; Pad needle with spaces, iff shorter than SPCs
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
	fileStr := header . "[" . regExSect . "]" . CRLF . COMM . "Imported by the EPKL Import Module" . CRLF . fileStr
	pklSplash( Imp.Title, "Importing " . inFile . " done!", 2 )
	if ( write ) {
		if not pklFileWrite( fileStr, outFile )
			Return false
		Return true
	} else {
		Return fileStr
	}
} 	; end convertFile
