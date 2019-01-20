DeadKeyValue( dkName, base )								; NOTE: 'dk' was just a number, but it's a name now
{															; NOTE: Entries 0-31 are named "s#", as pklIniRead can't read a "0" key
	val := getKeyInfo( "DKval_" . dkName . "_" . base )
	if ( not val ) {
		val :=                 pklIniRead(                   base ,  0, getLayInfo( "dkFile" ), "dk_" . dkName )	; Key as decimal number
		val := ( val ) ? val : pklIniRead( Format("0x{:04X}",base), -1, getLayInfo( "dkFile" ), "dk_" . dkName )	; As U+#### code point
		setKeyInfo( "DKval_" . dkName . "_" . base, val)	; The DK info pdic is filled in gradually with use
	}
	val := ( val == -1 ) ? 0 : val							; Store an empty entry as -1 so it isn't reread, but return it as 0
	Return val
}

pkl_DeadKey( DK )
{
	;CurrNumOfDKs    := getKeyInfo( "CurrNumOfDKs" )		; Current # of dead keys active	; eD NOTE: Revert to global? No, because it's used in many files?
	CurrNameOfDK    := getKeyInfo( "CurrNameOfDK" )			; Current dead key's name
	CurrBaseKey_    := getKeyInfo( "CurrBaseKey_" )			; Current base/release key, set by pkl_Send()
	DK              := getKeyInfo( "@" . DK )				; Find the dk's full name
	static PVDK     := "" 									; Pressed Dead Key Values queue?
	DeadKeyChar     := DeadKeyValue( DK, "s0" ) 			; Base release char for this DK
	DeadKeyChr1     := DeadKeyValue( DK, "s1" ) 			; eD WIP: The "1" entry gives alternative release char, if defined
	DeadKeyChr1     := ( DeadKeyChr1 ) ? DeadKeyChr1 : DeadKeyChar
	
	if ( getKeyInfo( "CurrNumOfDKs" ) > 0 && DK == getKeyInfo( "CurrNameOfDK" ) )	; Pressed the deadkey twice - release DK base char
	{
		pkl_Send( DeadKeyChr1 )								; eD WIP: Pressing the dead key twice now releases entry 1 (or does it?)
		Return
	}

	setKeyInfo( "CurrNumOfDKs", getKeyInfo( "CurrNumOfDKs" ) + 1 )	;++CurrNumOfDKs )	; CurrNumOfDKs++
	setKeyInfo( "CurrNameOfDK", DK )
	Input, nk, L1, {F1}{F2}{F3}{F4}{F5}{F6}{F7}{F8}{F9}{F10}{F11}{F12}{Left}{Right}{Up}{Down}{Home}{End}{PgUp}{PgDn}{Del}{Ins}{BS}{Esc}	; eD: Added {Esc}
	IfInString, ErrorLevel, EndKey							; Test for "forbidden" keys
	{
		setKeyInfo( "CurrNumOfDKs", 0 )
		setKeyInfo( "CurrBaseKey_", 0 )
;		endk := "{" . Substr(ErrorLevel,8) . "}"			; eD: I found it strange that Esc and others shouldn't just cancel the dead key.
;		pkl_Send( DeadKeyChar )								; Forbidden keys would both release entry 0 and...
;		if ( not InStr( "{Backspace}{Delete}{Escape}{F", endk ) )
;			Send %endk%										; ...do their thing, so beware!
		Return
	}
	
	if ( getKeyInfo( "CurrNumOfDKs" ) == 0 ) {
		pkl_Send( DeadKeyChar )								; If queue is empty, release entry 0 and return
		Return
	}
	if ( getKeyInfo( "CurrBaseKey_" ) != 0 ) {
		hx := getKeyInfo( "CurrBaseKey_" )
		nk := Chr( hx )										; The chr symbol for the current base key (e.g., 65 = A)
	} else {
		hx := Ord( nk )										; The ASCII/Unicode ordinal number for the pressed key; was Asc()
	}
	
	setKeyInfo( "CurrNumOfDKs", getKeyInfo( "CurrNumOfDKs" ) - 1 )	; Pop one DK from the DK chain
	setKeyInfo( "CurrBaseKey_", 0 )
	dkEnt   := DeadKeyValue( DK, hx )						; Get the DK value/entry for this base key
	
	if ( dkEnt && (dkEnt + 0) == "" ) {						; Entry is a special string, like {Home}+{End} or prefix-entry
		prefix := pkl_ParseSend( dkEnt )
		if ( not prefix )				 					; If not a recognized prefix-entry...
			SendInput {Raw}%dkEnt%							; ...just send the entry by default.
		if ( PVDK && prefix != "@" ) {						; eD WIP: Allow chained DKs too! This means not erasing PVDK?
			PVDK := ""
			setKeyInfo( "CurrNumOfDKs", 0 )							; But that's not enough. It gets stuck in pkl_ParseSend()
		}
;		setKeyInfo( "CurrNumOfDKs", 0 ) 	; eD WIP - doesn't prevent stuckness (nor does "CurrBaseKey_", 0 ?)
		pkl_Send( 0 )	; eD WIP: This somehow prevents the dead key from being stuck (pkl_SendThis doesn't).
	} else if ( dkEnt && PVDK == "" ) {
		pkl_Send( dkEnt )									; Send the normal single-character final entry
	} else {
		if ( getKeyInfo( "CurrNumOfDKs" ) == 0 ) {			; No more active dead keys, so release...
			pkl_Send( DeadKeyChar ) 						; ...this DKs base char, then...
			if ( PVDK ) {
				StringTrimRight, PVDK, PVDK, 1
				Loop, Parse, PVDK, %A_Space%
				{
					pkl_Send( A_LoopField )					; ...send all chars in PVDK queue and delete it.
				}
				PVDK := ""
			}
		} else {
			PVDK := DeadKeyChar  . " " . PVDK				; Add DK base char to space separated PVDK queue
		}
		pkl_Send( hx )										; Send the release key's char
	}
}

setDeadKeysInCurrentLayout( deadkeys )
{
	getDeadKeysInCurrentLayout( deadkeys, 1 )
}

getDeadKeysInCurrentLayout( newDeadkeys = "", set = 0 )
{				; eD TODO: Make PKL sensitive to a change of underlying Windows LocaleID?! Use SetTimer?
	static deadkeys := 0
	DKsOfSysLayout := pklIniRead( getWinLocaleID(), "", "PklDic", "DeadKeysFromLocID" )
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
		Return
	}
	if ( deadkeys == 0 )
		Return DKsOfSysLayout 			; eD: replaced getDeadKeysOfSystemsActiveLayout()
	else
		Return deadkeys
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
	DeadKeysInCurrentLayout := ""
	
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
		Sleep 2000
		txt := getPklInfo( "DetecDK_" .  "EDITOR" )
		SendInput {Raw}%txt%
		Send {Enter}
	} else {
		Send `n{Space}+{Home}{Del}
	}
	
	ordinal = 33
	Loop	; eD TODO: Detect AltGr+key hotkeys as well?! But then we'd have to send keys and not just characters. Or... just continue a ways past 0x80? To 0xFF?
	{
		clipboard := ""
		cha := Chr( ordinal )
		Send {%cha%}{space}+{Left}^{Ins}
		ClipWait
		ifNotEqual clipboard, %A_Space%
			DeadKeysInCurrentLayout = %DeadKeysInCurrentLayout%%ch%
		++ordinal
		if ( ordinal >= 0x80 )
			break
	}
	Send {Ctrl Up}{Shift Up}
	Send +{Home}{Del}
	txt := getPklInfo( "DetecDK_" . "DEADKEYS" )
	Send {Raw}%txt%:%A_Space%
	Send {Raw}%DeadKeysInCurrentLayout%
	Send {Enter}
	
	txt := getPklInfo( "DetecDK_" . "LAYOUT_CODE" )
	Send {Raw}%txt%:%A_Space%
	WinLayoutID := getWinLocaleID() ; eD
	Send %WinLayoutID%
	Send {Enter}
	
	if ( notepadMode )
		Send !{F4}
		Send {Right}				; Select "Don't save"
	
	Return DeadKeysInCurrentLayout
}
