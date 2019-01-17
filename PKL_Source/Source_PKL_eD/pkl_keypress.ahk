;-------------------------------------------------------------------------------------
;
; PKL key press
;     Process various key presses. Called from hotkey event labels in PKL_main.
;

processKeyPress( ThisHotkey )									; Called from the PKL_main keyPressed/Released labels
{
	Critical
	global PklHotKeyBuffer
	PklHotKeyBuffer .= ThisHotkey . "¤" 						; Add this hotkey to the hotkey buffer, ¤ delimited
	
	static timerCount = 0 										; # of keys waiting for processing (0-29)
	++timerCount
	if ( timerCount >= 30 )
		timerCount = 0
	setTimer, processKeyPress%timerCount%, -1 					; Set a processKeyPress# timer (key buffer)
}

runKeyPress() 													; Called from the PKL_main processKeyPress# labels
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

AltGrIsPressed() 												; Used in pkl_keypress and pkl_gui_image
{
	static altGrEqualsAltCtrl := -1
	if ( altGrEqualsAltCtrl == -1 ) {
		altGrEqualsAltCtrl := getPklInfo( "altGrEqualsAltCtrl" ) || getPklInfo( "RAltAsAltGrLocale" )	; eD
	}
	Return getKeyState( "RAlt" ) || ( altGrEqualsAltCtrl && getKeyState( "Ctrl" ) && getKeyState( "Alt" ) )
}

_keyPressed( HK )										; Process a HotKey press
{
	static extendKey    := "--"
	if ( extendKey == "--" ) 							; Initialize the extendKey static variable
		extendKey := getLayInfo( "extendKey" )
	
	modif := ""
	state := 0
	capHK := getKeyInfo( HK . "capSt" )					; Caps state (0-5 as MSKLC; -1 for vk; -2 for mod)
	
	if ( extendKey && getKeyState( extendKey, "P" ) ) {	; If there is an Extend mod and it's pressed...
		_extendKeyPress( HK ) 							; ...process the Extend key press.
		Return
	}	; end if extendKey
	
	if ( capHK == -1 ) {								; The key is VK mapped, so just send its VK code.
		t := getKeyInfo( HK . "vkey" )
		t = {VK%t%}
		Send {Blind}%t%
		Return
	}	; end if VK
	
	; eD TODO: Remove hasAltGr & altGrEqualsAltCtrl from pkl.ini and here, enforcing <^>! (if a laptop hasn't got >!, they'll have to remap something)?
	if ( getLayInfo("hasAltGr") ) {
		if ( AltGrIsPressed() ) {								; AltGr
			sh := getKeyState("Shift")
			if ( (capHK & 4) && getKeyState("CapsLock", "T") )
				sh := 1 - sh
			state := 6 + sh
		} else {
			if ( getKeyState("LAlt")) {							; LAlt on AltGr layout
				modif .= "!"
				if ( getKeyState("RCtrl"))
					modif .= "^"
				state := _pkl_CapsState( capHK )
			} else {
				_pkl_CtrlState( HK, capHK, state, modif )
			}
		}
	} else {
		if ( getKeyState("Alt")) {								; Alt
			modif .= "!"
			if ( getKeyState("RCtrl") || ( getKeyState("LCtrl") && !getKeyState("RAlt") ) )
				modif .= "^"
			state := _pkl_CapsState( capHK )					; CapsLock
		} else {
			_pkl_CtrlState( HK, capHK, state, modif )			; Ctrl
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
		if ( not pkl_ParseSend( Pri . Ent ), "SendThis" ) { 	; Unified prefix-entry syntax
;			pklDebug( "Trapped input:`n'" . Pri . "'`n" . Ent )	; eD DEBUG
		}
	}	; end if Pri
	Loop % getPklInfo( "osmMax" )
	{
	if ( getPklInfo( "osmKeyN" . A_Index ) )
			_osmClear( A_Index ) 								; If another key is pressed while a OSM is active, cancel the OSM	; eD WIP: Should it be used more places above?
	}
}	; end fn _KeyPressed

_extendKeyPress( HK )											; Process an Extend modified key press
{
	static modPressed   := { Shift : ""      , Ctrl : ""     , Alt : ""    , Win : ""     }	; Array of Extend mod keys pressed
	static modKey       := { Shift : "RShift", Ctrl : "LCtrl", Alt : "LAlt", Win : "LWin" }	; Array of keys to press for mods
	static returnTo     := "--"
	if ( returnTo == "--" ) {
		returnTo := StrSplit( getPklInfo( "extReturnTo" ), "/", " " )						; Array of layers to return to
	}
	xLvl := getPklInfo( "extLvl" )
	xVal := getKeyInfo( HK . "ext" . xLvl ) 					; The Extend entry/value for this key
	if ( xVal == "" )
		Return
	for mod, theKey in modPressed { 							; Scan through mods. If one is active, send its keypress.
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
	_setExtendInfo( returnTo[ xLvl ], false ) 					; Mark this Extend Down press as used for Extend
	if ( not pkl_ParseSend( xVal ) ) 							; Unified prefix-entry syntax
		Send {Blind}{%xVal%} 									; By default, take modifiers into account
}

_setExtendInfo( xLvl = 1, unUsed = true ) 						; Update PKL info about the Extend layer
{
	setPklInfo( "extLvl", xLvl )
	setLayInfo( "extendImg", getLayInfo( "extImg" . xLvl ) )
	setPklInfo( "extUnused", unUsed ) 							; Keep track of whether Ext is used yet
}

;-------------------------------------------------------------------------------------
;
; Set/get modifier key states
;     Process states of mods. Used in PKL_main; #etAltGrState() also in PKL_send.
;

setModifierState( theMod, isDown = 0 )
{
	static osmKeys      := "--"
	static osmTime      := 0
;	static tapTime      := 0 	; eD WIP
	static osmN         := 1 								; OSM number switch
	
	if ( osmKeys == "--" ) {
		osmKeys := getPklInfo( "stickyMods" ) 				; One-Shot mods (CSV)
		osmTime := getPklInfo( "stickyTime" ) 				; StickyMod/OSM wait time
		setPklInfo( "osmMax", 3 ) 							; Allow 3 concurrent OSM
	}
	
	if ( theMod == "AltGr" ) 								; NOTE: For now, AltGr can't be sticky.
			Return setAltGrState( isDown )
	
	if ( isDown == 1 ) {
		if ( InStr( osmKeys, theMod ) && theMod != getPklInfo( "osmKeyN" . osmN ) ) {	; eD WIP: Avoid the OSM if already held?
			osmN := Mod( osmN, getPklInfo( "osmMax" ) )+1 	; Switch between the OSM timers
			setPklInfo( "osmKeyN" . osmN, theMod ) 			; Marks the OSM as active
			SetTimer, osmTimer%osmN%, %osmTime% 			; A timer to turn the OSM off again
;			tapTime := A_TickCount + osmTime 				; eD WIP: Do we need both a tick count and a timer? ( A_TickCount < tapTime )
		}
		setKeyInfo( "ModState_" . theMod, 1 )
		Send {%theMod% Down} 								; NOTE: This autorepeats. Is that desirable?
	} else {
		if ( theMod == getPklInfo( "osmKeyN" . osmN ) ) 	; If an active OSM...
			Return 											; ...don't release it yet.
		setKeyInfo( "ModState_" . theMod, 0 )
		Send {%theMod% Up}
	}
}

;getModifierState( theMod )
;{
;	if ( theMod == "AltGr" )
;		Return getAltGrState()
;	Return getKeyInfo( "ModState_" . theMod )
;}

osmTimer1: 													; Timer label for the sticky mods
	_osmClear( 1 )
Return

osmTimer2: 													; Timer label for the sticky mods
	_osmClear( 2 )
Return

osmTimer3: 													; Timer label for the sticky mods
	_osmClear( 3 )
Return

_osmClear( osmN ) 											; Clear a specified sticky mod
{
	SetTimer, osmTimer%osmN%, Off
	theMod := getPklInfo( "osmKeyN" . osmN )
	setPklInfo( "osmKeyN" . osmN , "" )
	if ( theMod )
		setModifierState( theMod, 0 ) 						; Release the mod state
}

setAltGrState( isDown ) 									; The set fn calls get to reuse the static var.
{
	getAltGrState( isDown, 1 )
}

getAltGrState( isDown = 0, set = 0 )
{
	static AltGrState   := 0
	if ( set == 1 ) {
		if ( isDown == 1 ) {
			AltGrState = 1
			Send {LCtrl Down}{RAlt Down}
		} else {
			AltGrState = 0
			Send {RAlt Up}{LCtrl Up}
		}
	} else {
		Return AltGrState
	}
}

setExtendState( set = 0 )									; Called from the PKL_main  ExtendDown/Up labels
{
	static extendKey    := "--"
	static extMod1      := ""
	static extMod2      := ""
	static extTime      := 0
	static extSend      := ""
	static extHeld      := 0
	static tapTime      := 0
	
	if ( extendKey == "--" ) { 								; Initialize the extendKey static variables
		extendKey       := getLayInfo( "extendKey" )
		extMod1         := getPklInfo( "extendMod1" )
		extMod2         := getPklInfo( "extendMod2" )
		extTime         := getPklInfo( "extendTime" )
		extSend         := getPklInfo( "extendTaps" )
	}
	
	if ( set == 1 && extHeld == 0 ) { 						; Determine multi-Extend layer w/ extMods
		extHeld := 1 										; Guards against Extend key autorepeat
		xLvl  := ( getKeyState( extMod1, "P" ) ) ? 2 : 1 	; ExtMod1 -> ExtLvl +1
		xLvl  += ( getKeyState( extMod2, "P" ) ) ? 2 : 0 	; ExtMod2 -> ExtLvl +2
		_setExtendInfo( xLvl, true ) 						; Update Extend layer info
		tapTime := A_TickCount + extTime
	} else if ( set == 0 ) { 								; When the Extend key is released...
		extHeld := 0
		Send {RShift Up}{LCtrl Up}{LAlt Up}{LWin Up} 		; ...remove modifiers to clean up.
		if ( A_TickCount < tapTime && getPklInfo( "extUnused" ) ) 	; If the Extend key is tapped...
			Send {Blind}{%extSend%} 						; ...send its release entry.
	}	; end if
}	; end fn

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

_pkl_CapsState( capState ) 									; Handle caps state vs Shift/Caps/SGCaps
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
