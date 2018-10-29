_keyPressed( HK )										; Process a HotKey press
{
	static extendKeyStroke := 0
	static extendKey := "--"
	modif := ""
	state := 0
	
	if ( extendKey == "--" )
		extendKey := getLayInfo( "extendKey" )
	cap := getKeyInfo( HK . "capSt" )					; Caps state (0-5 as MSKLC; -1 for vk; -2 for mod)
	
	if ( extendKey && getKeyState( extendKey, "P" ) ) {	; If there is an Extend modifier and it's pressed...
		extendKeyStroke = 1
		_extendKeyPressed( HK )							; ...process the Extend key press.
		Return
	} else if ( HK == extendKey && extendKeyStroke ) {	; If the Extend is alone...
		extendKeyStroke = 0
		Send {RShift Up}{LCtrl Up}{LAlt Up}{LWin Up}	; ...remove mods to clean up.
		Return
	} else if ( cap == -1 ) {							; The key is VK mapped, so just send its VK code
		t := getKeyInfo( HK . "vkey" )
		t = {VK%t%}
		Send {Blind}%t%
		Return
	}	; end if extendKey
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
				state := _pkl_CapsState( cap )
			} else {
				_pkl_CtrlState( HK, cap, state, modif )
			}
		}
	} else {
		if ( getKeyState("Alt")) {								; Alt
			modif .= "!"
			if ( getKeyState("RCtrl") || ( getKeyState("LCtrl") && !getKeyState("RAlt") ) )
				modif .= "^"
			state := _pkl_CapsState( cap )						; CapsLock
		} else {
			_pkl_CtrlState( HK, cap, state, modif )				; Ctrl
		}
	}	; end if hasAltGr
	if ( getKeyState("LWin") || getKeyState("RWin") )			; Win
		modif .= "#"
	
	Pri := getKeyInfo( HK . state ) 							; Primary entry by state; may be a prefix
	Ent := getKeyInfo( HK . state . "s" )						; Actual entry by state, if using a prefix
	if ( Pri == "" ) {
		Return
	} else if ( state == "vkey" ) { 							; VirtualKey
		pkl_SendThis( modif, "{VK" . Pri . "}" )
;	} else if ( Pri == 32 && HK == "SC039" ) {					; Space bar		; eD WIP: pkl_Send already handles Space?!?
;		Send, {Blind}{Space}
	} else if ( ( Pri + 0 ) > 0 ) { 							; Normal numeric Unicode entry
		pkl_Send( Pri, modif )
	} else {
		Ent := ( Ent == "" ) ? getKeyInfo( HK . "0s" ) : Ent	; Default to state 0 if state # entry is empty
		if ( not pkl_ParseSend( Pri . Ent ), "SendThis" ) { 	; eD WIP: Unified parse/send fn
;			pklWarning( "Trapped input:`n'" . Pri . "'`n" . Ent )	; eD DEBUG
		}
	}	; end if Pri
}

_extendKeyPressed( HK )
{
	static modPressed   := { Shift : ""      , Ctrl : ""     , Alt : ""    , Win : ""     }	; Array of Extend mod keys pressed
	static modKey       := { Shift : "RShift", Ctrl : "LCtrl", Alt : "LAlt", Win : "LWin" }	; Array of keys to press for mods
	
	xVal := getKeyInfo( HK . "ext1" )						; The Extend entry/value for this key
	if ( xVal == "" )
		Return
	for mod, theKey in modPressed { 						; Scan through mods. If one is active, send its keypress.
		if ( xVal == mod ) {
			modPressed[mod] := HK
			Send % "{" . modKey[mod] . " Down}"
			Return
		}
		if ( theKey && !getKeyState( theKey, "P" ) ) {
			Send % "{" . modKey[mod] . " Up}"
			modPressed[mod] := ""
		}
	}
	if ( !modPressed["Alt"] && getKeyState( "RAlt", "P" ) ) {
		Send {LAlt Down}
		modPressed["Alt"] := "RAlt"
	}
	if ( not pkl_ParseSend( xVal ) )						; eD WIP Unified parse/send fn
		Send {Blind}{%xVal%}								; By default, take mods into account
}

_pkl_CtrlState( HK, capState, ByRef state, ByRef modif )	; Handle state/modif vs Ctrl(+Shift)
{
	if ( getKeyState("Ctrl") ) {
		state = 2
		if ( getKeyState("Shift") ) {
			state++
			if ( !getKeyInfo( HK . state ) ) {
				state--
				modif .= "+"
				if ( !getKeyInfo( HK . state ) ) {			; If no state entry, send as VirtualKey
					state := "vkey"
					modif .= "^"
				}
			}
		} else if ( !getKeyInfo( HK . state ) ) {			; --"--
			state := "vkey"
			modif .= "^"
		}
	} else {
		state := _pkl_CapsState( capState )
	}
}

_pkl_CapsState( capState )								; Handle capState vs Shift/Caps/SGCaps
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
	Return res
}

AltGrIsPressed()										; Used above and in pkl_gui_image
{
	static altGrEqualsAltCtrl := -1
	if ( altGrEqualsAltCtrl == -1 ) {
		altGrEqualsAltCtrl := getPklInfo( "altGrEqualsAltCtrl" ) || getPklInfo( "RAltAsAltGrLocale" )	; eD
	}
	Return getKeyState( "RAlt" ) || ( altGrEqualsAltCtrl && getKeyState( "Ctrl" ) && getKeyState( "Alt" ) )
}

processKeyPress( ThisHotkey )							; Called from PKL_main, from the *SC### [UP] triggers
{
	Critical
	global PklHotKeyBuffer	; eD: Was 'HotkeysBuffer'
	PklHotKeyBuffer .= ThisHotkey . "¤"
	
	static timerCount = 0								; # of keys waiting for processing (0-29)
	++timerCount
	if ( timerCount >= 30 )
		timerCount = 0
	setTimer, processKeyPress%timerCount%, -1
}

runKeyPress()											; Called from PKL_main, from the processKeyPress# timers
{
	Critical
	global PklHotKeyBuffer
	pos := InStr( PklHotKeyBuffer, "¤" )
	if ( pos <= 0 )
		Return
	ThisHotkey := SubStr( PklHotKeyBuffer, 1, pos - 1 )
	StringTrimLeft, PklHotKeyBuffer, PklHotKeyBuffer, %pos%
	Critical, Off

	_keyPressed( ThisHotkey )
}
