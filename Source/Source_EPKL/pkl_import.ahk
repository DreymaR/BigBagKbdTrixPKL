;; ================================================================================================
;;  EPKL Import module: Turn any MSKLC (or other format?) file into an EPKL layout.
;;    - Works from the Layouts\_Import directory, turning any .klc files in _Inbox into layouts.
;;    - Uses a template with a set of regular expression (RegEx) entries to generate the layout.ini file.
;

importLayouts() 	; eD TODO
{
	IMP                 := {}
	IMP.Name            := "EPKL Import Module"
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

importComposer() 	; eD WIP
{
	Cmp         := {} 											; Variables for the Compose Import module
	Cmp.Title   := "Compose Import Module"
	Cmp.Dir     := "Files\Composer\"
	Cmp.InDir   := Cmp.Dir   . "_Inbox\"
	Cmp.SymFile := Cmp.InDir . "KeySymDef.ini" 					; KeySymDef.ini
	Cmp.SymOrig := Cmp.InDir . "keysymdef.h" 	 				; keysymdef.h
	Cmp.RegExes := Cmp.Dir   . "RegEx_Composer.ini"
	
/*
	MsgBox, 0x021, Convert Compose tables?,  					; 0x100: 2nd button default. 0x30: Warning. 0x1: OK/Cancel
(
EPKL Composer Import Module
—————————————————————————————

From a compose.h file in Files\Composer\_Inbox,
generate a Compose.ini file useable with EPKL.

Do you wish to do this now?
Large files may take some time.
)
	IfMsgBox, Cancel 				; MsgBox type is 0x3 (Yes/No/Cancel) + 0x30 (Warning) + 0x100 (2nd button is default)
		Return
*/ 	; eD DEBUG: Skip for now, while testing RegEx
	if not keySyms imp_convertFile( Cmp, Cmp.SymOrig, Cmp.SymFile, "KeySymDef", "Key symbol definition file for the EPKL" . Cmp.Title )
;		pklErrorMsg( "Original KeySym file not found!`nExiting " . Cmp.Title )
		Return
	
;;  - Look for a keysymdef.ini file. If not found, try to make one. Use a file picker dialog maybe?
;;  - Look for a compose_###.h file in _Inbox, and read it in. Is there a 5000 lines limit?
;;  - Remove comments? Leave some? Reduce multiple empty lines to single ones.
;;  - Convert by parsing lines w/ RegExReplace() statements
;;  - Save w/ a time stamp?
}

imp_convertFile( Imp, inFile, outFile, regExSect, title = "Imported EPKL file" ) {
	if not FileExist( outFile ) { 								; Convert a file into another format using a series of RegExes
		pklSplash( Imp.Title, "Creating " . inFile . " now..."  , 2.5 )
	} else {
		FileDelete % outFile 									; FileWrite appends to files, so delete any outFile. Remove this eventually? It's mostonly here for debugging
		pklSplash( Imp.Title, "Deleted "  . inFile . " first...", 2.5 )
	} 	; end if FileExist outFile
	ini         := ".ini"
	CRLF        := "`r`n"
	QU          := "" 	;"""" 									; Literal double quote for the log, if applied. Use ” instead?
	SC          := "`;"
	COMM        := SC . SC . "  " 								; Start of a ;; comment line
	SPC8        := "        "
	SPCs        := SPC8 . SPC8 . SPC8 . SPC8 . SPC8 			; 8×5 = 40 spaces for padding log entries with
	
	if not fileStr := pklFileRead( inFile, inFile )
		Return false
	rExLog  := ";;  The following RegExes were used in the conversion of this file:" . CRLF 
			 . ";;  ===============================================================" . CRLF 
	regExes := {}
	For ix, row in pklIniSect( Imp.RegExes, regExSect ) { 		; Read the list of keys and mouse buttons
		pklIniKeyVal( row, key, val, 0 ) 						; Read without character escapes yet, as they should only be performed for val[2]
		if ( key == "<NoKey>" || key == "<Blank>" )
			Continue
		key     := SubStr( key . SPC8, 1, 8 ) . " :  "
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
			 . COMM . "This file was imported and converted from " . inFile . " by the " . Imp.Title . getPklInfo( "pklHdrB" )
	header  .= rExLog . SC . CRLF . CRLF
	fileStr := header . "[" . regExSect . "]" . CRLF . fileStr
	if not pklFileWrite( fileStr, outFile )
		Return false
	pklSplash( Imp.Title, "Importing " . inFile . " done!", 2 )
	Return true
} 	; end importFile
