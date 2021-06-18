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
		for dirTag, theDir in IMP.Inbox
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

importCompose() 	; eD WIP
{
	Cmp         := {} 											; Variables for the Compose Import module
	Cmp.Title   := "Compose Import Module"
	Cmp.Dir     := "Files\Composer\"
	Cmp.SymFile := Cmp.Dir . "KeySymDef.ini" 					; KeySymDef.ini
	Cmp.SymOrig := Cmp.Dir . "keysymdef.h" 	 					; keysymdef.h
	Cmp.RegExes := Cmp.Dir . "RegEx_Composer.ini"
	
/*
	MsgBox, 0x021, Convert Compose tables?,  					; 0x100: 2nd button default. 0x30: Warning. 0x1: OK/Cancel
(
EPKL Compose Import Module
—————————————————————————————

From a compose.h file in Files\Composer\_Inbox,
generate a Compose.ini file useable with EPKL.

Do you wish to do this now?
Large files may take some time.
)
	IfMsgBox, Cancel 				; MsgBox type is 0x3 (Yes/No/Cancel) + 0x30 (Warning) + 0x100 (2nd button is default)
		Return
*/ 	; eD DEBUG: Skip for now, while testing RegEx
	if not keySyms imp_convertFile( Cmp, Cmp.SymOrig, Cmp.SymFile, "KeySymDef" )
;		pklErrorMsg( "Original KeySym file not found!`nExiting " . Cmp.Title )
		Return
	
;;  - Look for a keysymdef.ini file. If not found, try to make one. Use a file picker dialog maybe?
;;  - Look for a compose_###.h file in _Inbox, and read it in. Is there a 5000 lines limit?
;;  - Remove comments? Leave some? Reduce multiple empty lines to single ones.
;;  - Convert by parsing lines w/ RegExReplace() statements
;;  - Save w/ a time stamp?
}

imp_convertFile( Imp, inFile, outFile, regExSect ) { 			; Convert a file into another format using a series of RegExes
	if not FileExist( outFile ) {
		pklSplash( Imp.Title, "Creating " . inFile . " now...", 2.5 )
	} else {
		FileDelete % outFile 									; FileWrite appends to files, so delete any outFile. Remove this eventually? It's mostonly here for debugging
		pklSplash( Imp.Title, "Deleted "  . inFile . " first...", 2.5 )
	} 	; end if FileExist outFile
	ini         := ".ini"
	CRLF        := "`r`n"
	QU          := "" 	;"""" 										; Literal double quote for the log, if applied. Use ” instead?
	SPCs        := "        " . "        " . "        " . "        " . "        " 	; 8×5 = 40 spaces for padding log entries with
	
	if not fileStr := pklFileRead( inFile, inFile )
		Return false
	; eD WIP: m) is multiline mode. \K to drop everything matched so far. (?=...) lookahead. (?<=...) lookbehind.
	regExes := {}
	rExLog  := ";;  These RegExes were used in the conversion of this file:" . CRLF 
			 . ";;  =======================================================" . CRLF . CRLF
	loopInx := 0
	Loop {
		key := SubStr( "00" . ++loopInx, 1, 3 ) 				; 001, 002 ... 999
		val := pklIniCSVs( key, -1, Imp.RegExes, regExSect, "⇒" )
		if ( val[1] == -1 )
			Break
		val[1] := SubStr( val[1], 2, -1 ) 						; Any character can be used as "quotes" around the entries.
		val[2] := SubStr( val[2], 2, -1 ) 						; Note: Actual " at entry boundaries may get stripped by IniRead().
		val[2] := StrReplace( val[2], "\r\n", CRLF ) 			; Can't read newlines from the file it seems? So here's a workaround.
;			( 1 ) ? pklDebug( "key = " key . "`n'" . val[1] . "'`n'" . val[2] . "'", 1.5 )  ; eD DEBUG
		fileStr := RegExReplace( fileStr, val[1], val[2] )
		val1    := QU . SubStr( val[1] . QU . SPCs, 1, 40 ) 	; Pad val[1] with spaces
		val2    := ( val[2] == CRLF ) ? QU . "\r\n" . QU : QU . val[2] . QU
		rExLog  .= ";;  " . val1 . " ⇒ " . val2 . CRLF
	}
	fileStr := rExLog . ";" . CRLF . "[" . regExSect . "]" . CRLF . fileStr
	if not pklFileWrite( fileStr, outFile )
		Return false
	pklSplash( Imp.Title, "Importing " . inFile . " done!", 2 )
	
;		for row in StrSplit( fileStr, "`r`n" ) { 	; eD WIP: Use a set of multiline RegExReplace instead?
;		} 	; end for row
;		for ix, needle in needles {
;			fileStr := RegExReplace( fileStr, needle, results[ix] )
;		}
;		RegExReplace( fileStr, "\R", "`r`n") 					; Normalize line endings to Windows format
;		needle  := ">\K" . CO . tstx . "(.*>)" . CO . tstx 		; The RegEx to search for (ignore the start w/ \K)
;		result  := dChr . tstx . "${1}" . aChr . tstx 			; CO -> dChr, then next CO -> aChr
;		tmpFile := RegExReplace( fileStr, needle , result )
	Return true
} 	; end importFile
