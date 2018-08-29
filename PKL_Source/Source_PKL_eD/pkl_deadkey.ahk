DeadKeyValue( dkName, base )								; eD: 'dk' was just a number, but in PKL_eD it's a name
{															; Note: Entries 0-31 are named "s#", as pklIniRead can't read a "0" key
	res := getKeyInfo( "DKval_" . dkName . "_" . base )
	if ( not res ) {
		res := pklIniRead( base, -1, getLayInfo( "dkFile" ), "dk_" . dkName )
;		MsgBox,,, DKey: %dkName%`nBase: %base%`nChar: %res%, 1	; DEBUG
		setKeyInfo( "DKval_" . dkName . "_" . base, res)	; The DK info pdic is filled in gradually with use
	}
	res := ( res == -1 ) ? 0 : res
	return res
}

DeadKey(DK)
{
	;CurrNumOfDKs    := getKeyInfo( "CurrNumOfDKs" )		; Current # of dead keys active	; eD NOTE: Revert to global? No, because it's used in many files?
	CurrNameOfDK    := getKeyInfo( "CurrNameOfDK" )			; Current dead key's name
	CurrBaseKey_    := getKeyInfo( "CurrBaseKey_" )			; Current base key	eD TODO: Is this definition used/needed?
	DK              := getKeyInfo( "dk" . DK )				; Find the dk's full name
	static PVDK     := "" 									; Pressed Dead Key Values?
	DeadKeyChar     := DeadKeyValue( DK, "s0" )
	DeadKeyChr1     := DeadKeyValue( DK, "s1" )				; eD WIP: The "1" entry gives alternative release char, if defined
	DeadKeyChr1     := ( DeadKeyChr1 ) ? DeadKeyChr1 : DeadKeyChar
	
	if ( getKeyInfo( "CurrNumOfDKs" ) > 0 && DK == getKeyInfo( "CurrNameOfDK" ) )	; Pressed the deadkey twice - release DK base char
	{
		pkl_Send( DeadKeyChr1 )								; eD WIP: Pressing the dead key twice now releases entry 1
		return
	}

	setKeyInfo( "CurrNumOfDKs", getKeyInfo( "CurrNumOfDKs" ) + 1 )	;++CurrNumOfDKs )	; CurrNumOfDKs++
	setKeyInfo( "CurrNameOfDK", DK )
	Input, nk, L1, {F1}{F2}{F3}{F4}{F5}{F6}{F7}{F8}{F9}{F10}{F11}{F12}{Left}{Right}{Up}{Down}{Home}{End}{PgUp}{PgDn}{Del}{Ins}{BS}{Esc}	; eD: Added {Esc}
	IfInString, ErrorLevel, EndKey							; Test for "forbidden" keys
	{
		setKeyInfo( "CurrNumOfDKs", 0 )
		setKeyInfo( "CurrBaseKey_", 0 )
;		endk := "{" . Substr(ErrorLevel,8) . "}"			; eD: I found it strange that Esc and others shouldn't just cancel the dead key.
;		pkl_Send( DeadKeyChar )								; Forbidden keys release entry 0 and...
;		if ( not InStr( "{Backspace}{Delete}{Escape}{F", endk ) )
;			Send %endk%										; ...do their thing, so beware!
		return
	}

	if ( getKeyInfo( "CurrNumOfDKs" ) == 0 ) {
		pkl_Send( DeadKeyChar )								; If queue is empty(?), release entry 0
		return
	}
	if ( getKeyInfo( "CurrBaseKey_" ) != 0 ) {
		hx := getKeyInfo( "CurrBaseKey_" )
		nk := chr( hx )										; Send the base key
	} else {
		hx := asc( nk )										; Send key listed above like {BS}
	}
	
	setKeyInfo( "CurrNumOfDKs", getKeyInfo( "CurrNumOfDKs" ) - 1 )	;--CurrNumOfDKs )	; CurrNumOfDKs--
	setKeyInfo( "CurrBaseKey_", 0 )
	newkey := DeadKeyValue( DK, hx )						; Get the DK value

	if ( newkey && (newkey + 0) == "" ) {					; New key (value) is a special string, like {Home}+{End}
		if ( PVDK ) {
			PVDK := ""
			setKeyInfo( "CurrNumOfDKs", 0 )
		}
		SendInput %newkey%
	} else if ( newkey && PVDK == "" ) {
		pkl_Send( newkey )
	} else {
		if ( getKeyInfo( "CurrNumOfDKs" ) == 0 ) {			; No more active dead keys, so release
			pkl_Send( DeadKeyChar )
			if ( PVDK ) {
				StringTrimRight, PVDK, PVDK, 1
				Loop, Parse, PVDK, %A_Space%
				{
					pkl_Send( A_LoopField )					; Send all release chars in PVDK queue
				}
				PVDK := ""
			}
		} else {
			PVDK := DeadKeyChar  . " " . PVDK				; Add DK base char to space separated PVDK queue
		}
		pkl_Send( hx )
	}
}

setDeadKeysInCurrentLayout( deadkeys )
{
	getDeadKeysInCurrentLayout( deadkeys, 1 )
}

getDeadKeysInCurrentLayout( newDeadkeys = "", set = 0 )
{				; eD TODO: Make PKL sensitive to a change of underlying Windows LocaleID?! Use SetTimer?
	static deadkeys := 0
	DKsOfSysLayout := pklIniRead( getWinLocaleID(), "", "Pkl_Dic", "DeadKeysFromLocID" ) ; eD
	if ( DKsOfSysLayout == "-2" )
		setPklInfo( "RAltAsAltGrLocale", true )
	DKsOfSysLayout := ( SubStr(DKsOfSysLayout,1,1) == "-" ) ? "" : DKsOfSysLayout
	if ( set == 1 ) {
		if ( newDeadkeys == "auto" )
			deadkeys := DKsOfSysLayout
		else if ( newDeadkeys == "dynamic" )
			deadkeys := 0
		else
			deadkeys := newDeadkeys
		return
	}
	if ( deadkeys == 0 )
		return DKsOfSysLayout 			; eD: replaced getDeadKeysOfSystemsActiveLayout()
	else
		return deadkeys
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

detectDeadKeysInCurrentLayout()
{
	DeadKeysInCurrentLayout = ;
	
	notepadMode = 0
	txt := getPklInfo( "DetecDK_" .  "MSGBOX_TITLE" )
	tx2 := getPklInfo( "DetecDK_" .  "MSGBOX" )
	MsgBox 51, %txt%, %tx2%
	IfMsgBox Cancel
		return
	IfMsgBox Yes
	{
		notepadMode = 1
		Run Notepad
		Sleep 2000
		txt := getPklInfo( "DetecDK_" .  "EDITOR" )
		SendInput {Raw}%txt%
		Send {Enter}
	} else {
		Send `n{Space}+{Home}{Del}
	}
	
	ord = 33
	; eD TODO: Detect AltGr+key hotkeys as well?! But then we'd have to send keys and not just characters.
	Loop
	{
		clipboard = ;
		cha := Chr( ord )
		Send {%cha%}{space}+{Left}^{Ins}
		ClipWait
		ifNotEqual clipboard, %A_Space%
			DeadKeysInCurrentLayout = %DeadKeysInCurrentLayout%%ch%
		++ord
		if ( ord >= 0x80 )
			break
	}
	Send {Ctrl Up}{Shift Up}
	Send +{Home}{Del}
	txt := getPklInfo( "DetecDK_" . "DEADKEYS" )
	Send {RAW}%txt%:%A_Space%
	Send {RAW}%DeadKeysInCurrentLayout%
	Send {Enter}
	
	txt := getPklInfo( "DetecDK_" . "LAYOUT_CODE" )
	Send {Raw}%txt%:%A_Space%
	WinLayoutID := getWinLocaleID() ; eD
	Send %WinLayoutID%
	Send {Enter}
	
	if ( notepadMode )
		Send !{F4}
		Send {Right}				; Select "Don't save"
	
	return DeadKeysInCurrentLayout
}
