keyPressed( HK )
{
	static extendKeyStroke := 0
	static extendKey := "--"
	modif = ; modifiers to send
	state = 0
	
	if ( extendKey == "--" )
		extendKey := getLayInfo( "extendKey" )
	cap := getKeyInfo( HK . "capSt" )					; Caps state (0-5 as MSKLC; -1 for vk; -2 for mod)
	
	if ( extendKey && getKeyState( extendKey, "P" ) ) {	; If there is an Extend modifier and it's pressed...
		extendKeyStroke = 1
		_extendKeyPressed( HK )							; ...process the Extend key press.
		return
	} else if ( HK == extendKey && extendKeyStroke ) {	; If the Extend is alone...
		extendKeyStroke = 0
		Send {RShift Up}{LCtrl Up}{LAlt Up}{LWin Up}	; ...remove mods to clean up.
		return
	} else if ( cap == -1 ) {							; The key is VK mapped, so just send its VK code
		t := getKeyInfo( HK . "vkey" )
		t = {VK%t%}
		Send {Blind}%t%
		return
	}
	extendKeyStroke = 0
	; eD TODO: Remove hasAltGr & altGrEqualsAltCtrl from pkl.ini and here, enforcing <^>! (if a laptop hasn't got >!, they'll have to remap something)?
	if ( getLayInfo("hasAltGr") ) {
		if ( AltGrIsPressed() ) {								; AltGr
			sh := getKeyState("Shift")
			if ( (cap & 4) && getKeyState("CapsLock", "T") )
				sh := 1 - sh
			state := 6 + sh
		} else {
			if ( getKeyState("LAlt")) {							; LAlt on AltGr layout
				modif .= "!"
				if ( getKeyState("RCtrl"))
					modif .= "^"
				state := _pkl_ShiftState( cap )
			} else {
				_pkl_CtrlState( HK, cap, state, modif )
			}
		}
	} else {
		if ( getKeyState("Alt")) {								; Alt
			modif .= "!"
			if ( getKeyState("RCtrl") || ( getKeyState("LCtrl") && !getKeyState("RAlt") ) )
				modif .= "^"
			state := _pkl_ShiftState( cap )
		} else {
			_pkl_CtrlState( HK, cap, state, modif )
		}
	}
	if ( getKeyState("LWin") || getKeyState("RWin") )
		modif .= "#"
	
	ch := getKeyInfo( HK . state )
	if ( ch == "" ) {
		return
	} else if ( state == "vkey" ) { 							; VirtualKey
		pkl_SendThis( modif, "{VK" . ch . "}" )
	} else if ( ch == 32 && HK == "SC039" ) {					; Space
		Send, {Blind}{Space}
	} else if ( ( ch + 0 ) > 0 ) {								; Normal numeric Unicode entry
		pkl_Send( ch, modif )
	} else if ( ch == "*" || ch == "="  ) {						; Special input * or =
		if ( ch == "=" )
			modif = {Blind}										; Blind input uses the current modifier state
		else
			modif := ""											; *{} = not {Raw}{} (so use AHK syntax like ^!+#)
		
		ch := getKeyInfo( HK . state . "s" )
		if ( ch == "{CapsLock}" ) {
			_toggleCapsLock()
		} else {
			toSend = ;
			if ( ch != "" ) {
				toSend = %modif%%ch%
			} else {
				ch := getKeyInfo( HK . "0s" )					; Default to state 0
				if ( ch != "" )
					toSend = %modif%%ch%
			}
			pkl_SendThis( "", toSend )
		}
	} else if ( ch == "%" ) {									; Ligature
		SendInput, getKeyInfo( HK . state . "s" )
	} else if ( ch == "dk" ) {	; < 0 ) {						; Dead key
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

	ch := getKeyInfo( HK . "ext1" )
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
	if ( shiftPressed && !getKeyState( shiftPressed, "P" ) ) {
		Send {RShift Up}
		shiftPressed := ""
	}
	if ( ctrlPressed && !getKeyState( ctrlPressed, "P" ) ) {
		Send {LCtrl Up}
		ctrlPressed := ""
	}
	if ( altPressed && !getKeyState( altPressed, "P" ) ) {
		Send {LAlt Up}
		altPressed := ""
	}
	if ( WinPressed && !getKeyState( WinPressed, "P" ) ) {
		Send {LWin Up}
		WinPressed := ""
	}
	if ( !altPressed && getKeyState( "RAlt", "P" ) ) {
		Send {LAlt Down}
		altPressed = RAlt
	}
	Send {Blind}{%ch%}		; By default, Extend keys are sent so that other modifiers are taken into account
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
					state := "vkey" 							; VirtualKey
					modif .= "^"
				}
			}
		} else if ( !getKeyInfo( HK . state ) ) {
			state := "vkey"										; VirtualKey
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

_toggleCapsLock()
{
	if ( getKeyState("CapsLock", "T") )
	{
		SetCapsLockState, Off
	} else {
		SetCapsLockState, on
	}
}

AltGrIsPressed()
{
	static altGrEqualsAltCtrl := -1
	if ( altGrEqualsAltCtrl == -1 ) {
		altGrEqualsAltCtrl := getPklInfo( "altGrEqualsAltCtrl" ) || getPklInfo( "RAltAsAltGrLocale" )	; eD
	}
	return getKeyState( "RAlt" ) || ( altGrEqualsAltCtrl && getKeyState( "Ctrl" ) && getKeyState( "Alt" ) )
}

processKeyPress( ThisHotkey )
{
	Critical
	global PklHotKeyBuffer	; eD: Was 'HotkeysBuffer'
	PklHotKeyBuffer .= ThisHotkey . "¤"
	
	static timerCount = 0
	++timerCount
	if ( timerCount >= 30 )
		timerCount = 0
	setTimer, processKeyPress%timerCount%, -1
}

runKeyPress()
{
	Critical
	global PklHotKeyBuffer
	pos := InStr( PklHotKeyBuffer, "¤" )
	if ( pos <= 0 )
		return
	ThisHotkey := SubStr( PklHotKeyBuffer, 1, pos - 1 )
	StringTrimLeft, PklHotKeyBuffer, PklHotKeyBuffer, %pos%
	Critical, Off

	keyPressed( ThisHotkey )
}
