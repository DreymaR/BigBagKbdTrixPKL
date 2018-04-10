keyPressed( HK )
{
	static extendKeyStroke := 0
	static extendKey := "--"
	modif = ; modifiers to send
	state = 0

	if ( extendKey == "--" )
		extendKey := getLayInfo( "extendKey" )
	cap := getKeyInfo( HK . "c" )
	
	if ( extendKey && getKeyState( extendKey, "P" ) ) {
		extendKeyStroke = 1
		_extendKeyPressed( HK )
		return
	} else if ( HK == extendKey && extendKeyStroke ) {
		extendKeyStroke = 0
		Send {RShift Up}{LCtrl Up}{LAlt Up}{LWin Up}
		return
	} else if ( cap == -1 ) {
		t := getKeyInfo( HK . "v" )
		t = {VK%t%}
		Send {Blind}%t%
		return
	}
	extendKeyStroke = 0
	; eD TODO: Remove hasAltGr & altGrEqualsAltCtrl from pkl.ini and here? Enforce <^>! (if a laptop hasn't got >!, they'll have to remap something)
	if ( getLayInfo("hasAltGr") ) {
		if ( AltGrIsPressed() ) {
			sh := getKeyState("Shift")
			if ( (cap & 4) && getKeyState("CapsLock", "T") )
				sh := 1 - sh
			state := 6 + sh
		} else {
			if ( getKeyState("LAlt")) {
				modif .= "!"
				if ( getKeyState("RCtrl"))
					modif .= "^"
				state := _pkl_ShiftState( cap )
			} else { ; not Alt
				_pkl_CtrlState( HK, cap, state, modif )
			}
		}
	} else {
		if ( getKeyState("Alt")) {
			modif .= "!"
			if ( getKeyState("RCtrl") || ( getKeyState("LCtrl") && !getKeyState("RAlt") ) )
				modif .= "^"
			state := _pkl_ShiftState( cap )
		} else { ; not Alt
			_pkl_CtrlState( HK, cap, state, modif )
		}
	}
	if ( getKeyState("LWin") || getKeyState("RWin") )
		modif .= "#"


	ch := getKeyInfo( HK . state )
	if ( ch == "" ) {
		return
	} else if ( state == "v" ) { ; VirtualKey
		pkl_SendThis( modif, "{VK" . ch . "}" )
	} else if ( ch == 32 && HK == "SC039" ) {
		Send, {Blind}{Space}
	} else if ( ( ch + 0 ) > 0 ) {
		pkl_Send( ch, modif )
	} else if ( ch == "*" || ch == "="  ) {		; Special
		if ( ch == "=" )
			modif = {Blind}
		else
			modif := ""
		
		ch := getKeyInfo( HK . state . "s" )
		if ( ch == "{CapsLock}" ) {
			toggleCapsLock()
		} else {
			toSend = ;
			if ( ch != "" ) {
				toSend = %modif%%ch%
			} else {
				ch := getKeyInfo( HK . "0s" )
				if ( ch != "" )
					toSend = %modif%%ch%
			}
			pkl_SendThis( "", toSend )
		}
	} else if ( ch == "%" ) {
		SendU_utf8_string( getKeyInfo( HK . state . "s" ) )
	} else if ( ch == "dk" ) {	; < 0 ) {
		DeadKey( getKeyInfo( HK . state . "s" ) )	; -1 * ch )
;	} else {
;		MsgBox, Trapped input: '%ch%'
	}
	
}

_extendKeyPressed( HK )
{
	static shiftPressed := ""
	static ctrlPressed := ""
	static altPressed := ""
	static winPressed := ""

	ch := getKeyInfo( HK . "e" )
	if ( ch == "") {
		return
	} else if ( ch == "Shift" ) {
		shiftPressed := HK
		Send {RShift Down}
		return
	} else if ( ch == "Ctrl" ) {
		ctrlPressed := HK
		Send {LCtrl Down}
		return
	} else if ( ch == "Alt" ) {
		altPressed := HK
		Send {LAlt Down}
		return
	} else if ( ch == "Win" ) {
		winPressed := HK
		Send {LWin Down}
		return
	}
	
	if ( SubStr( ch, 1, 1 ) == "!" ) {
		ch := SubStr( ch, 2 )
		SendInput, {RAW}%ch%
		return
	} else if ( SubStr( ch, 1, 1 ) == "*" ) {
		ch := SubStr( ch, 2 )
		SendInput, %ch%
		return
	}
	if ( ShiftPressed && !getKeyState( ShiftPressed, "P" ) ) {
		Send {RShift Up}
		ShiftPressed := ""
	}
	if ( CtrlPressed && !getKeyState( CtrlPressed, "P" ) ) {
		Send {LCtrl Up}
		CtrlPressed := ""
	}
	if ( AltPressed && !getKeyState( AltPressed, "P" ) ) {
		Send {LAlt Up}
		AltPressed := ""
	}
	if ( WinPressed && !getKeyState( WinPressed, "P" ) ) {
		Send {LWin Up}
		WinPressed := ""
	}
	if ( !AltPressed && getKeyState( "RAlt", "P" ) ) {
		Send {LAlt Down}
		altPressed = RAlt
	}
	Send {Blind}{%ch%}
}

_pkl_CtrlState( HK, capState, ByRef state, ByRef modif )
{
	if ( getKeyState("Ctrl") ) {
		state = 2
		if ( getKeyState("Shift") ) {
			state++
			if ( !getKeyInfo( HK . state ) ) {
				state--
				modif .= "+"
				if ( !getKeyInfo( HK . state ) ) {
					state := "v" ; VirtualKey
					modif .= "^"
				}
			}
		} else if ( !getKeyInfo( HK . state ) ) {
			state := "v" ; VirtualKey
			modif .= "^"
		}
	} else {
		state := _pkl_ShiftState( capState )
	}
}

_pkl_ShiftState( capState )
{
	res = 0
	if ( capState == 8 ) {
		if ( getKeyState("CapsLock", "T") )
			res = 8
		if ( getKeyState("Shift") )
			res++
	} else {
		res := getKeyState("Shift")
		if ( (capState & 1) && getKeyState("CapsLock", "T") )
			res := 1 - res
	}
	return res
}

setAltGrState( isdown )
{
	getAltGrState( isdown, 1 )
}

getAltGrState( isdown = 0, set = 0 )
{
	static AltGr := 0
	if ( set == 1 ) {
		if ( isdown == 1 ) {
			AltGr = 1
			Send {LCtrl Down}{RAlt Down}
		} else {
			AltGr = 0
			Send {RAlt Up}{LCtrl Up}
		}
	} else {
		return AltGr
	}
}

setModifierState( modifier, isdown )
{
	getModifierState( modifier, isdown, 1 )
}

getModifierState( modifier, isdown = 0, set = 0 )
{
	if ( modifier == "AltGr" )
		return getAltGrState( isdown, set ) ; For better performance
	
	if ( set == 1 ) {
		if ( isdown == 1 ) {
			setKeyInfo( "ModSt_" . modifier, 1 )	; HashTable_Set( pdic,
			Send {%modifier% Down}
		} else {
			setKeyInfo( "ModSt_" . modifier, 0 )
			Send {%modifier% Up}
		}
	} else {
		return getKeyInfo( "ModSt_" . modifier )
	}
}

AltGrIsPressed()
{
	static altGrEqualsAltCtrl := -1
	if ( altGrEqualsAltCtrl == -1 )
		altGrEqualsAltCtrl := getPklInfo( "AltGrEqualsAltCtrl" )
	return getKeyState( "RAlt" ) || ( altGrEqualsAltCtrl && getKeyState( "Ctrl" ) && getKeyState( "Alt" ) )
}


processKeyPress( ThisHotkey )
{
	Critical
	global gP_HotKeyBuffer	; eD: Was 'HotkeysBuffer'
	gP_HotKeyBuffer .= ThisHotkey . "¤"
	
	static timerCount = 0
	++timerCount
	if ( timerCount >= 30 )
		timerCount = 0
	setTimer, processKeyPress%timerCount%, -1
}

runKeyPress()
{
	Critical
	global gP_HotKeyBuffer	; eD: Was 'HotkeysBuffer'
	pos := InStr( gP_HotKeyBuffer, "¤" )
	if ( pos <= 0 )
		return
	ThisHotkey := SubStr( gP_HotKeyBuffer, 1, pos - 1 )
	StringTrimLeft, gP_HotKeyBuffer, gP_HotKeyBuffer, %pos%
	Critical, Off

	keyPressed( ThisHotkey )
}
