;;  -----------------------------------------------------------------------------------------------
;;
;;  EPKL key press
;;      Process various key presses, mostly called from hotkey event labels in PKL_main.
;

processKeyPress( ThisHotkey ) 									; Called from the PKL_main keyPressed/Released labels
{
	Critical
	global PklHotKeyBuffer
	static timerCount = 0 										; # of keys queued for processing (0-29)? Or a counter?
	
;	tomKey := getPklInfo( "tomKey" ) 							; If interrupting an active Tap-or-Mod timer... 	; eD WIP! Interrupt seems necessary, but it's hard to get right
;	if ( tomKey ) 												; ...handle that first
;		setTapOrModState( tomKey, -1 )
	PklHotKeyBuffer .= ThisHotkey . "¤" 						; Add this hotkey to the hotkey buffer, ¤ delimited
	if ( ++timerCount >= 30 )
		timerCount = 0
	SetTimer, processKeyPress%timerCount%, -1 					; Set a 1 ms run-once processKeyPress# timer (key buffer)
}

runKeyPress() 													; Called from the PKL_main processKeyPress# labels
{
	Critical
	global PklHotKeyBuffer
	
	pos := InStr( PklHotKeyBuffer, "¤" )
	if ( pos <= 0 ) 	; <=
		Return
	ThisHotkey := SubStr( PklHotKeyBuffer, 1, pos - 1 )
	StringTrimLeft, PklHotKeyBuffer, PklHotKeyBuffer, %pos%
	Critical, Off
	_keyPressed( ThisHotkey ) 									; Pops one HKey from the buffer
}

AltGrIsPressed() 												; Used in pkl_keypress and pkl_gui_image
{
;;  The following was removed from EPKL_Settings.ini for clarity. The functionality is still here, for now.
;;  ONHOLD: Remove altGrEqualsAltCtrl, enforcing <^>! (if laptops don't have >!, they'd have to remap to it)?
;;  
;;  Windows internally translates the AltGr (right Alt) key to LEFT Ctrl + RIGHT Alt.
;;  If you enable this option, EPKL detects AltGr as (one of) Ctrl + (one of) Alt.
;;  This is useful for notebook keyboards that do not have a right alt or AltGr key.
;;  It is usually not recommended, because fortunately many programs know the
;;  difference between AltGr and Alt+Ctrl.
;ctrlAltIsAltGr  = no
	static altGrEqualsAltCtrl := -1
	if ( altGrEqualsAltCtrl == -1 ) {
		altGrEqualsAltCtrl := getPklInfo( "altGrEqualsAltCtrl" ) || getPklInfo( "RAltAsAltGrLocale" )
	}
	Return getKeyState( "RAlt" ) || ( altGrEqualsAltCtrl && getKeyState( "Ctrl" ) && getKeyState( "Alt" ) )
}

_keyPressed( HKey ) 											; Process a HotKey press
{
	modif := ""
	state := 0
	capHK := getKeyInfo( HKey . "capSt" ) 						; Caps state (0-5 as MSKLC; -1 VK; -2 Mod)
	
	if ( ExtendIsPressed() ) { 									; If there is an Extend key and it's pressed...
		_osmClearAll() 											; ...clear any sticky mods, then...
		_extendKeyPress( HKey ) 								; ...process the Extend key press.
		Return
	}	; end if extendKey
	
	if ( capHK == -1 ) {										; The key is VK mapped, so just send its VK code.
		Send % "{Blind}{VK" . getKeyInfo( HKey . "vkey" ) . "}"
		Return
	}	; end if VK
	
	if ( getLayInfo("hasAltGr") ) { 							; For AltGr layouts...
		if ( AltGrIsPressed() ) { 								; AltGr is down
			sh := getKeyState("Shift")
			if ( (capHK & 4) && getKeyState("CapsLock", "T") )
				sh := 1 - sh
			state := 6 + sh 									; eD WIP: The state calc. is a mess. Prepare for SGCaps in the mix by simplifying this mess?
		} else {
			if ( getKeyState("LAlt")) { 						; LAlt on AltGr layout
				modif .= "!"
				if ( getKeyState("RCtrl"))
					modif .= "^"
				state := _pkl_CapsState( capHK )
			} else {
				_pkl_CtrlState( HKey, capHK, state, modif )
			}
		}
	} else { 													; For non-AltGr layouts...
		if ( getKeyState("Alt")) {								; Alt is down
			modif .= "!"
			if ( getKeyState("RCtrl") || ( getKeyState("LCtrl") && !getKeyState("RAlt") ) )
				modif .= "^"
			state := _pkl_CapsState( capHK )					; CapsLock on?
		} else {
			_pkl_CtrlState( HKey, capHK, state, modif )			; Ctrl is down
		}
	}	; end if hasAltGr
	if ( getKeyState("LWin") || getKeyState("RWin") )			; Win is down
		modif .= "#"
	
	Pri := getKeyInfo( HKey . state ) 							; Primary entry by state; may be a prefix
	Ent := getKeyInfo( HKey . state . "s" )						; Actual entry by state, if using a prefix
	if ( Pri == "" ) {
		Return
	} else if ( state == "vkey" ) { 							; VirtualKey. <key>vkey is set to Modifier or VK name.
		pkl_SendThis( modif, "{VK" . Pri . "}" ) 				; (Without this, Ctrl+Shift+# keys are broken.)
	} else if ( ( Pri + 0 ) > 0 ) { 							; Normal numeric Unicode entry
		pkl_Send( Pri, modif )
	} else {
		Ent := ( Ent == "" ) ? getKeyInfo( HKey . "0s" ) : Ent	; Default to state 0 if state # entry is empty
		if ( not pkl_ParseSend( Pri . Ent ), "SendThis" ) { 	; Unified prefix-entry syntax
;			pklDebug( "Trapped input:`n'" . Pri . "'`n" . Ent, 0.5 )	; eD DEBUG
		}
	}	; end if Pri
	_osmClearAll() 												; If another key is pressed while a OSM is active, cancel the OSM
}	; end fn _KeyPressed										; eD WIP: Should _osmClearAll() be used more places above?

_extendKeyPress( HKey )											; Process an Extend modified key press
{
	static modPressed   := { Shift : ""      , Ctrl : ""     , Alt : ""    , Win : ""     }	; Array of Extend mod keys pressed
	static modKey       := { Shift : "RShift", Ctrl : "LCtrl", Alt : "LAlt", Win : "LWin" }	; Array of keys to send for mods
	static returnTo     := -1
	if ( returnTo == -1 )
		returnTo := StrSplit( getPklInfo( "extReturnTo" ), "/", " " )						; Array of layers to return to
	
	xLvl := getPklInfo( "extLvl" )
	xVal := getKeyInfo( HKey . "ext" . xLvl ) 					; The Extend entry/value for this key
	if ( xVal == "" )
		Return
	for mod, theKey in modPressed { 							; Scan through mods. If one is active, send its keypress.
		if ( xVal == mod ) {
			modPressed[mod] := HKey
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
	setLayInfo( "extendUsed", true ) 							; Mark the Extend press as used (to avoid dual-use as ToM key etc)
}

_setExtendInfo( xLvl = 1, unUsed = true ) 						; Update PKL info about the Extend layer
{
	setPklInfo( "extLvl", xLvl )
	setLayInfo( "extendImg", getLayInfo( "extImg" . xLvl ) )
;	setPklInfo( "extUnused", unUsed ) 							; Keep track of whether Ext is used yet; for Tap-Or-Mod
}

;;  -----------------------------------------------------------------------------------------------
;;
;;  Set/get modifier key states
;;      Process states of mods. Used in PKL_main; #etAltGrState() also in PKL_send.
;

setModifierState( theMod, isDown = 0 ) 						; Can be called from a hotkey or with an AHK mod key name
{
	static osmKeys      := -1
	static osmTime      := 0
	static osmN         := 1 								; OSM number switch
	
	if ( osmKeys == -1 ) {
		osmKeys := getPklInfo( "stickyMods" ) 				; One-Shot mods (CSV)
		osmTime := getPklInfo( "stickyTime" ) 				; StickyMod/OSM wait time
		setPklInfo( "osmMax", 3 ) 							; Allow 3 concurrent OSM
	}

	if ( isDown == 1 ) {
		if ( InStr( osmKeys, theMod ) && theMod != getPklInfo( "osmKeyN" . osmN ) ) {	; eD WIP: Avoid the OSM if already held?
			osmN := Mod( osmN, getPklInfo( "osmMax" ) )+1 	; Switch between the OSM timers
			
			setPklInfo( "osmKeyN" . osmN, theMod ) 			; Marks the OSM as active
			SetTimer, osmTimer%osmN%, %osmTime% 			; A timer to turn the OSM off again
		}
		_setModState( theMod, 1 )
	} else {
		if ( theMod == getPklInfo( "osmKeyN" . osmN ) ) 	; If an active OSM...
			Return 											; ...don't release it yet.
		_setModState( theMod, 0 )
	}
}

getVKey( HKey )
{
	return % getKeyInfo( HKey . "vkey" )
}

_setModState( theMod, isDown = 1 )
{
	if ( theMod == "Extend" ) { 							; Extend
		_setExtendState( isDown )
	} else if ( theMod == "AltGr" ) {
		setAltGrState( isDown ) 							; AltGr 	; eD NOTE: For now, AltGr can't be sticky?
	} else {
		UD := ( isDown ) ? "Down" : "Up"
		setKeyInfo( "ModState_" . theMod, isDown ) 			; Standard modifier
		Send {%theMod% %UD%} 								; NOTE: This autorepeats. Is that desirable?
	}
}

;_getModState( theMod )
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
{ 															; A -%time% one-shot timer could be used instead...
	SetTimer, osmTimer%osmN%, Off 							; ...but this is also called from elsewhere.
	theMod := getPklInfo( "osmKeyN" . osmN )
	setPklInfo( "osmKeyN" . osmN , "" )
	if ( theMod )
		setModifierState( theMod, 0 ) 						; Release the mod state
}

_osmClearAll() 												; Clear all active sticky mods
{
	Loop % getPklInfo( "osmMax" )
	{
	if ( getPklInfo( "osmKeyN" . A_Index ) )
			_osmClear( A_Index )
	}
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
;	( 1 ) ? pklDebug( "getAltGrState " . isDown . " " . set )  ; eD DEBUG
;	return	; eD DEBUG – When is this used?!? Only if there's no real AltGr in the OS layout?
}

_setExtendState( set = 0 )									; Called from setModState
{ 															; This function handles Extend key tap or hold
	static extendKey    := -1
	static extMod1      := ""
	static extMod2      := ""
	static extHeld      := 0
	
	if ( extendKey == -1 ) { 								; Initialize the extendKey static variables
		extendKey       := getLayInfo( "extendKey" )
		extMod1         := getPklInfo( "extendMod1" )
		extMod2         := getPklInfo( "extendMod2" )
	}
	
	if ( set == 1 ) && ( ! extHeld ) { 						; Determine multi-Extend layer w/ extMods
		xLvl  := getKeyState( extMod1, "P" ) ? 2 : 1 		; ExtMod1 -> ExtLvl +1
		xLvl  += getKeyState( extMod2, "P" ) ? 2 : 0 		; ExtMod2 -> ExtLvl +2
		_setExtendInfo( xLvl, true ) 						; Update Extend layer info
		extHeld := 1 										; Guards against Extend key autorepeat
	} else if ( set == 0 ) { 								; When the Extend key is released...
		Send {RShift Up}{LCtrl Up}{LAlt Up}{LWin Up} 		; ...remove modifiers to clean up.
		extHeld := 0
	}	; end if
	setLayInfo( "extendUsed", false ) 						; Mark this as a fresh Extend key press (for ToM etc)
}	; end fn

ExtendIsPressed() 											; Determine whether the Extend key is pressed
{
	ext := getLayInfo( "extendKey" )
	Return % ( ext && getKeyState( ext, "P" ) ) ? true : false
}

setTapOrModState( HKey, set = 0 ) 							; Called from the PKL_main tapOrModDown/Up labels
{ 															; This function handles tap-or-mod (ToM) aka dual-role modifier (DRM) keys
	static tapTime  := {} 									; We'll handle tap times for each key SC
	static tomHeld  := {} 									; Is this key held down? Or check key state instead?
													; eD WIP: Make tomHeld a push-pop array of held keys? To allow multiple concurrent ToM.
	tomMod  := getKeyInfo( HKey . "ToM" ) 					; Modifier name for this key
	tomTime := getPklInfo( "tapModTime" )
	
	if ( set == 1 ) { 										; * If the key is pressed (or autorepeated)...
		if ( ! tomHeld[HKey] ) { 							; Set only once per press
			tomHeld[HKey] := 1 								; Mark key as held to guard against autorepeat
			SetTimer, tomTimer, -%tomTime% 					; A run-once timer is more robust than checking the time...
			tapTime[HKey] := A_TickCount + tomTime 			; ...but the time check is handy for key release? Or is release the default?
			setPklInfo( "tomKey", HKey ) 					; The key is marked as active
			setPklInfo( "tomMod", tomMod ) 					; The Mod is marked as "todo"
		}
		Return
	} else if ( set == -1 ) { 								; If the key is interrupted by another...
		SetTimer, tomTimer, Off
		setPklInfo( "tomKey", "" )
;		pklDebug( "caught ToM!", 0.5 ) 	; ED DEBUG
		if ( getKeyState( HKey, "P" ) ) {
			_setModState( tomMod, 1 ) 				; eD WIP: This is fishy! Keys get transposed, sometime also wrongly shifted (st -> Ts).
			setPklInfo( "tomMod", -1 )
		} else {
			processKeyPress( HKey )
			tomHeld[HKey] := 0
		}
	} else { 												; If the key is released (unless interrupted first)...
		SetTimer, tomTimer, Off
		setPklInfo( "tomKey", "" )
		tomHeld[HKey] := 0
		extUsed := ( HKey == getLayInfo( "extendKey" ) && getLayInfo( "extendUsed" ) ) 	; Is this not a used Extend key press?
		if ( A_TickCount < tapTime[HKey] ) && ! extUsed 	; If the key was tapped (and not used as Extend mod)...
			processKeyPress( HKey )
		if ( getPklInfo( "tomMod" ) == -1 ) 				; If the mod was set... 	; eD WIP: Or unset the mod anyway? What if the real mod key is being held?
			_setModState( tomMod, 0 )
		setLayInfo( "extendUsed", false )
	}
}	; end fn

tomTimer: 													; There's only one timer as you won't be activating several ToM at once
;	pklDebug( "ToM: " HKey " > " getPklInfo( "tomMod" ) ) 	; eD DEBUG
	_setModState( getPklInfo( "tomMod" ), 1 ) 				; When the timer goes off, set the mod state for the ToM key
	setPklInfo( "tomKey", "" ) 								; This is used by the ToM interrupt 	; eD WIP
	setPklInfo( "tomMod", -1 ) 								; Turn off this ToM key's todo status
Return

_pkl_CtrlState( HKey, capState, ByRef state, ByRef modif ) 	; Handle state/modif vs Ctrl(+Shift)
{
	if ( getKeyState("Ctrl") ) {
		state = 2
		if ( getKeyState("Shift") ) {
			state++
			if ( !getKeyInfo( HKey . state ) ) {
				state--
				modif .= "+"
				if ( !getKeyInfo( HKey . state ) ) { 		; If no state entry, send as VirtualKey
					state := "vkey"
					modif .= "^"
				}
			}
		} else if ( !getKeyInfo( HKey . state ) ) { 		; --"--
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
