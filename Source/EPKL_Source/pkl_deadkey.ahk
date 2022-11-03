;; ================================================================================================
;;  EPKL dead key functions
;

DeadKeyValue( dkName, base )								; In old PKL, 'dk' was just a number. It's a name now.
{															; NOTE: Entries 0-31, if used, are named "s#" as pklIniRead can't read a "0" key
	val := getKeyInfo( "DKval_" . dkName . "_" . base )
	if ( not val ) {
		dkStck  := getPklInfo( "DkListStck" )
		chr := Chr( base )
		upp := ( ( 64 < base ) && ( base < 91 ) ) ? "+" : "" 	; Mark upper case with a tag, as IniRead() lacks base letter case distinction
		cha := convertToANSI( chr ) 						; Convert the key from UTF-8 to ANSI so IniRead() can handle more char entries
		val :=                 pklIniRead( base                   ,, dkStck, "dk_" . dkName ) 	; Key as decimal number (original PKL style),
		val := ( val ) ? val : pklIniRead( "<" . cha . ">" . upp  ,, dkStck, "dk_" . dkName ) 	;     as <#> character (UTF-8 Unicode allowed)
		val := ( val ) ? val : pklIniRead( Format("0x{:04X}",base),, dkStck, "dk_" . dkName ) 	;     as 0x#### hex Unicode point
		val := ( val ) ? val : pklIniRead( Format( "~{:04X}",base),, dkStck, "dk_" . dkName ) 	;     as  ~#### hex Unicode point
		val := ( val == "--" ) ? -1 : val 					; A '-1' or '--' value means unmapping, to be used in the LayStack
		val := ( val ) ? val : "--"
		if val is integer
			val := Format( "{:i}", val ) 					; Converts hex to decimal so it's always treated as the same number
		setKeyInfo( "DKval_" . dkName . "_" . base, val)	; The DK info pdic is filled in gradually with use
	}
;	if ( base == 960 ) 												; eD DEBUG: Only for one key ( 97 = 'a'; 960 = 'π' ) ...
;		pklDebug( "DK: " dkName "`nBase: " base " (" Chr(base) ")`nVal: " val, 6 ) 	; --"--     Check DK value functionality
	val := ( val == "--" ) ? 0 : val 						; Store any empty entry so it isn't reread, but return it as 0
	Return val
}

pkl_DeadKey( dkCode ) { 									; Handle DK presses. Dead key names are given as `@###` where `###` is dkCode.
	CurrNumOfDKs    := getKeyInfo( "CurrNumOfDKs" ) 		; Current # of dead keys active. 	; eD ONHOLD: Revert to global? No, because it's used in many files?
	CurrNameOfDK    := getKeyInfo( "CurrNameOfDK" ) 		; Current dead key's name
	CurrBaseKey     := getKeyInfo( "CurrBaseKey"  ) 		; Current base/release key, set by pkl_CheckForDKs() via pkl_Send() 	; eD WIP: This gets nulled somehow?!?
	PDKVs           := getKeyInfo( "PressedDKVs"  ) 		; Used to be the static PVDK ("Pressed Dead Key Values queue"?)
	DK              := getKeyInfo( "@" . dkCode   ) 		; Find the dk's full name
	DeadKeyChar     := DeadKeyValue( DK, "base1" )  		; Base release char for this DK
	DeadKeyChr1     := DeadKeyValue( DK, "base2" )  		; Alternative release char, if defined
	DeadKeyChr1     := ( DeadKeyChr1 ) ? DeadKeyChr1 : DeadKeyChar
	
	if ( CurrNumOfDKs > 0 && DK == CurrNameOfDK ) { 		; Pressed the deadkey twice - release DK base char
		pkl_Send( DeadKeyChr1 ) 							; eD WIP: Pressing the dead key twice now releases entry 1 (or does it? Seems the s0 entry is still sent...?!)
		resetDeadKeys() 									; Note: Resetting before sending would output both base chars.
		Return
	}
	
	setKeyInfo( "CurrNumOfDKs", ++CurrNumOfDKs ) 			; Increase the # of registered DKs, both as variable and KeyInfo
	setKeyInfo( "CurrNameOfDK", DK )
	SetTimer, showHelpImageOnce, -35 						; Redraw the img once if active (refresh takes 16.7 ms). A showHelpImage() call loses releases.
	endDKs  := "{F1}{F2}{F3}{F4}{F5}{F6}{F7}{F8}{F9}{F10}{F11}{F12}"
			.  "{Left}{Right}{Up}{Down}{BS}{Esc}"
			.  "{Home}{End}{PgUp}{PgDn}{Del}{Ins}"  		; eD WIP: These keys don't work for canceling a DK? Why? Their Ext counterparts work fine.
	Input, nk, L1, %endDKs% 								; Any ending key cancels the DK
	IfInString, ErrorLevel, EndKey  						; NOTE: The OTB style for { is incompatible with this command
	{ 														; Test for "forbidden" keys from the next-key input 	;( 1 ) ? pklDebug( "DK canceled", 1 )  ; eD DEBUG
		resetDeadKeys()
		Return
	}
;	pklDebug( "DK: " DK "`nNumOfDKs: " CurrNumOfDKs "`nBaseKey: " CurrBaseKey " / " getKeyInfo( "CurrBaseKey" ), 1.3 ) 	; eD DEBUG
	
;	if ( CurrNumOfDKs == 0 ) { 								; eD WIP: When is this triggered? And Why? CurrNum gets increased above!?
;		pkl_Send( DeadKeyChar )								; If queue is empty, release entry 0 and return
;		Return
;	}
	
	CurrBaseKey     := getKeyInfo( "CurrBaseKey"  ) 		; Current base/release key, set by pkl_CheckForDKs() via pkl_Send() 	; eD WIP: This gets nulled somehow?!?
	if ( CurrBaseKey != 0 ) { 								; If a BaseKey is set, use that, otherwise use the nk input directly
		hx := CurrBaseKey
		nk := Chr( hx )										; The chr symbol for the current base key (e.g., 65 = A)
	} else {
		hx := Ord( nk )										; The ASCII/Unicode ordinal number for the pressed key; was Asc()
	} 	; end if CurrBaseKey
	
	setKeyInfo( "CurrNumOfDKs", --CurrNumOfDKs ) 			; Pop one DK from the queue. Note: ++ and -- have the Input between them.
	setKeyInfo( "CurrBaseKey" , 0 )
	dkEnt   := DeadKeyValue( DK, hx )   					; Get the DK value/entry for this base key
	
	if ( dkEnt && (dkEnt + 0) == "" ) { 					; Entry is a special string, like {Home}+{End} or prefix-entry
		psp := pkl_ParseSend( dkEnt )
		if ( not psp )  				 					; If not a recognized prefix-entry...
			SendInput {Text}%dkEnt% 						; ...just send the entry as text by default.
;		if ( PDKVs && psp != "@" ) { 						; eD WIP: Allow chained DKs too! This means not erasing the DK queue.
;		}
		resetDeadKeys()
	} else if ( dkEnt && PDKVs == "" ) {
		pkl_Send( dkEnt )									; Send the normal single-character final entry
	} else {
		if ( getKeyInfo( "CurrNumOfDKs" ) == 0 ) {			; No more active dead keys, so release...
			pkl_Send( DeadKeyChar ) 						; ...this DKs base char, then...
			if ( PDKVs ) {
				StringTrimRight, PDKVs, PDKVs, 1
				Loop, Parse, PDKVs, %A_Space%
				{
					pkl_Send( A_LoopField )					; ...send all chars in DK queue and delete it.
				}
			}
			resetDeadKeys()
		} else {
			PDKVs := DeadKeyChar  . " " . PDKVs 			; Add DK base char to space separated DK queue
			setKeyInfo( "PressedDKVs", PDKVs )  			; eD WIP: Try to clear up the DK code? Unsure what it does...
		} 	; end if CurrNumOfDKs
		pkl_Send( hx )										; Send the release key's char
	} 	; end if dkEnt
}

resetDeadKeys( ) {  										; Tidy up and reset all global DK info parameters
	setKeyInfo( "CurrNumOfDKs"  , 0  )  					; How many dead keys were pressed 	(was 'CurrentDeadKeys')
	setKeyInfo( "CurrNameOfDK"  , "" )  					; Current dead key's name 			(was 'CurrentDeadKeyName')
	setKeyInfo( "CurrBaseKey"   , 0  )  					; Current base key  				(was 'CurrentBaseKey')
	setKeyInfo( "PressedDKVs"   , "" )  					; eD WIP: DK stuckness wasn't removed by resetting CurrNum or CurrBase alone?
	pkl_CheckForDKs( 0 ) 									; Resets the SpaceWasSentForSystemDKs static variable
}

setCurrentWinLayDeadKeys( deadkeys ) {
	getCurrentWinLayDeadKeys( deadkeys, 1 )
}

getCurrentWinLayDeadKeys( newDKs = "", set = 0 ) {  		; eD TODO: Make EPKL sensitive to a change of underlying Windows LocaleID?! Use SetTimer?
	static DKs := 0
	DKsOfSysLayout := pklIniRead( getWinLocaleID(), "", "PklDic", "DeadKeysFromLocID" )
	if ( DKsOfSysLayout == "-2" )
		setKeyInfo( "RAltAsAltGrLocale", true ) 			; Set RAlt to act as AltGr using the EPKL_Tables 	; eD WIP: This seems wrong. Should do it separately, not mixed up with OS DKs?!
	DKsOfSysLayout := ( InStr( DKsOfSysLayout, "-" ) == 1 ) ? "" : DKsOfSysLayout
	if ( set == 1 ) {
		if ( newDKs == "auto" )
			DKs := DKsOfSysLayout
		else if ( newDKs == "none" || newDKs == "--" )
			DKs := 0
		else
			DKs := newDKs
		Return
	}
	if ( DKs == 0 )
		Return DKsOfSysLayout 			; eD: replaced getDeadKeysOfSystemsActiveLayout()
	else
		Return DKs
}

/*
------------------------------------------------------------------------

Module for detecting the deadkeys in current keyboard layout

Version: 0.0.3 2008-05
License: GNU General Public License
Author: FARKAS Máté <http://fmate14.try.hu> (My given name is Máté)

Tested Platform:  Windows XP/Vista
Tested AutoHotkey Version: 1.0.47.04

WHY:  In hungarian keyboard layout ^ is a dead key: 
		Send ^o         ; is o with ^ accent
		Send ^          ; is nothing
		Send ^{Space}   ; is the ^ character
	  So... If I want to send ^, I must send ^{Space}.

TODO: A better version without Send/Clipboard (I don't have any ideas)

------------------------------------------------------------------------
*/

detectCurrentWinLayDeadKeys()   						; Detects which keys in the OS layout are DKs.
{   													; eD WIP: Freezes up mid-detection sometimes? Due to ClipWait? And does it actually detect DKs now?
	CurrentWinLayDKs := ""
	CR  := "{Enter}"
	SPC := A_Space
	
	notepadMode = 0
	txt := getPklInfo( "DetecDK_" .  "MSGBOX_TITLE" )
	tx2 := getPklInfo( "DetecDK_" .  "MSGBOX" )
	MsgBox 51, %txt%, %tx2%
	IfMsgBox Cancel
		Return
	IfMsgBox Yes
	{
		notepadMode = 1
		Run Notepad
		Sleep 1500
		txt := getPklInfo( "DetecDK_" .  "EDITOR" )
		SendInput {Text}%txt%
		Send %CR%%CR%
	} else {
		Send `n{Space}+{Home}{Del}
	}
	
	ord := 0x20 										; Character ordinal numbers to check. 0x00–0x1F are Ctrl characters.
	Loop {  		; eD TODO: Detect AltGr+key hotkeys as well?! But then we'd have to send keys and not just characters.
		++ord
		if ( ord >= 0x80 && ord <= 0x9F ) 				; These UTF-8 code points are non-printing
			Continue
		if not Mod( ord, 0x10 ) 						; Send a CR every 16 characters, for neatness
			Send %CR%
		clipboard := ""
		cha := Chr( ord )
		Send {%cha%}{Space}+{Left}^{Ins}
		Sleep 50
		ClipWait
		ifNotEqual clipboard, %SPC%
			CurrentWinLayDKs := CurrentWinLayDKs . cha
	} Until ord >= 0xBF 								; Could've gone to 0xFF, but it's only special/accented letters there.
	Send {Ctrl Up}{Shift Up}%CR%%CR% 	;+{Home}{Del}
	txt := getPklInfo( "DetecDK_" . "DEADKEYS" )
	Send {Text}%txt%:%SPC%
	Send {Text}%CurrentWinLayDKs%
	Send %CR%
	txt := getPklInfo( "DetecDK_" . "LAYOUT_CODE" )
	Send {Text}%txt%:%SPC%
	Send % getWinLocaleID()
	Send %CR%
	
	if ( notepadMode )
		Sleep 1000
		Send !{F4}
		Send {Right}									; Select "Don't save"
	
	Return CurrentWinLayDKs
}
