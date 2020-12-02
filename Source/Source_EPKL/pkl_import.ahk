;; ================================================================================================
;;  EPKL Import module: Turn any MSKLC (or other format?) file into an EPKL layout.
;;      Works from the Layouts\_Import directory, turning any .klc files in _Inbox into layouts.
;;      Uses a template with a set of regular expression (RegEx) entries to generate the layout.ini file.
;

importLayouts()
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
