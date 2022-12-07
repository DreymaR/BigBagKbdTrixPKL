;; ================================================================================================
;;  EPKL key press functions
;;  - Process various key presses, mostly called from hotkey event labels in PKL_main.
;

; Timer/buffer removed - CSGO

; processKeyPress( ThisHotkey ) { 								; Called from the PKL_main keyPressed/Released labels
; 	Critical
; 	global HotKeyBuffer                							; Keeps track of the buffer queue of up to 32 pressesd keys in ###KeyPress() fns
; 	static keyTimerCounter  := 0    							; Counter for keys queued with timers (0-31 then 0 again).
	
; ;	tomKey := getPklInfo( "tomKey" ) 							; If interrupting an active Tap-or-Mod timer... 	; eD WIP! Interrupt seems necessary, but it's hard to get right
; ;	if ( tomKey ) 												; ...handle that first
; ;		setTapOrModState( tomKey, -1 )
; 	if ( HotKeyBuffer.Length() > 24 )   						; If the hotkey buffer is growing too long (such as when holding down Extend-mousing keys)...
; 		Return  												; ...refuse further buffering. The processKeyPress timers will reduce the buffer again.
; 	HotKeyBuffer.Push( ThisHotKey ) 							; Add this hotkey to the hotkey buffer
;     pklTooltip(ThisHotKey)
; 	if ( ++keyTimerCounter > 28 )   							; Resets the timer count on overflow. 	; eD WIP: What's the optimal size for the buffer? Related to #MaxThreads?
; 		keyTimerCounter = 0 									; This doesn't affect the HotKeyBuffer size, only the number of concurrent timers.
; 	SetTimer, processKeyPress%keyTimerCounter%, -1  			; Set a 1 ms(!) run-once processKeyPress# timer (key buffer)
; }

; runKeyPress() { 												; Called from the PKL_main processKeyPress# timer labels
; 	Critical
; 	global HotKeyBuffer 										; Keeps track of the buffer queue of up to 32 pressesd keys in ###KeyPress() fns
	
; 	if HotKeyBuffer.Length() == 0
; 		Return
; 	ThisHotkey := HotKeyBuffer[ 1 ] 							; Chomp the buffer from the left
; 	HotKeyBuffer.RemoveAt( 1 )
; 	Critical, Off   											; eD WIP: Where should I turn off Critical priority? Moving it below _keyPressed() caused hard hangs.
; 	_keyPressed( ThisHotkey )   								; Pops one HKey from the buffer
; }

_keyPressed( HKey ) {   										; Process a HotKey press
	if ExtendIsPressed() {  									; If there is an Extend key and it's pressed...
		_osmClearAll()  										; ...clear any sticky mods, then...
		extendKeyPress( HKey )  								; ...process the Extend key press.
		Return
	}	; end if ExtPressed
	
	modif := ""
	state := 0
	vk_HK := getKeyInfo( HKey . "ent1" ) 						; Key "VK_" info; usually VK/SC code.
	capHK := getKeyInfo( HKey . "ent2" ) 						; CapsState (0-5 as MSKLC; -1 Mod; -2 VK; -3 SC)
	
	if ( capHK < -1 ) { 										; The key is VK or SC mapped, so just send its VK## and/or SC### code.
		if ( capHK == -2 ) && inArray( [ "VK2D", "VK2E"  		; [PgUp,PgDn,End ,Home,Left,Up ,Right,Down,Ins ,Del ] are sent as their NumPad versions by AHK, as...
				, "VK21", "VK22", "VK23", "VK24"    			; [VK21,VK22,VK23,VK24,VK25,VK26,VK27,VK28,VK2D,VK2E] are degenerate VK codes for both versions
				, "VK25", "VK26", "VK27", "VK28" ], vk_HK ) { 	; [049 ,051 ,04F ,047 ,04B ,048 ,04D ,050 ,052 ,053 ] are the NumPad SCs for the keys
			SC  := GetKeySC(vk_HK) | 0x100  					; [149 ,151 ,14F ,147 ,14B ,148 ,14D ,150 ,152 ,153 ] are the normal SCs for the keys
			vk_HK .= Format( "SC{:03X}", SC )   				; Send {vk##sc###} ensures that the normal key version is sent
		} 	; end if capHK == VK
		if        InStr( "VK08SC00E", vk_HK ) { 				; Backspace was pressed, so...
			lastKeys( "pop1" )  								; ...remove the last entry in the Composer LastKeys queue
		} else if InStr( "VK0DSC01C", vk_HK ) { 				; Enter     was pressed, so...
			lastKeys( "null" )  								; ...delete the Composer LastKeys queue 	; eD WIP: Any others?
		} else {
			_composeVK( HKey, vk_HK )   						; If the output is a single, printable character, add it to the Compose queue
		}
;		if inArray( [ "SC002","SC003","SC004" ], HKey )
;			pklTooltip( HKey . " " . capHK ), Return 	; eD DEBUG
		Send {Blind}{%vk_HK% DownR} 							; Send the down press as DownR so other Send won't be affected, like AHK remaps.
		_osmClearAll()  										; Clear any sticky mods after sending
		Return
	}	; end if VK/SC
	
	if getLayInfo("LayHasAltGr") { 								; For AltGr layouts...
		if AltGrIsPressed() { 									; If AltGr is down...
			sh := getKeyState("Shift")
			if ( (capHK & 4) && getKeyState("CapsLock", "T") ) 	; The CapState property of a key determines whether CapsLock affects Shift
				sh := 1 - sh
			state := 6 + sh 									; eD WIP: The ShiftState calc. is a mess. Prepare for SGCaps in the mix by simplifying this mess?
		} else {
			if getKeyState("LAlt") { 							; LAlt on AltGr layout
				modif .= "!"
				if getKeyState("RCtrl")
					modif .= "^"
				state := _pkl_CapsState( capHK )
			} else {
				_pkl_CtrlState( HKey, capHK, state, modif )
			}
		}
	} else { 													; For non-AltGr layouts...
		if getKeyState("Alt") { 								; Alt is down
			modif .= "!"
			if ( ( getKeyState("RCtrl") || ( getKeyState("LCtrl") ) && !getKeyState("RAlt") ) )
				modif .= "^"
			state := _pkl_CapsState( capHK )					; CapsLock on?
		} else {
			_pkl_CtrlState( HKey, capHK, state, modif )			; Ctrl is down
		}
	}	; end if LayHasAltGr
	if ( getKeyState("LWin") || getKeyState("RWin") ) 			; Win is down
		modif .= "#"
;	if ( getKeyState("LShift") || getKeyState("RShift") ) 		; Shift is down 	; eD WIP: Get Shift+keys working. Would it mess with anything else?
;		modif .= "+"
	modif := InStr( modif, "!" ) ? "{Blind}" . modif : modif 	; Alt+F to File menu etc doesn't work without Blind if the Alt button is pressed.
	state += getModState( "SwiSh" ) ? 0x08 : 0  				; SwiSh (SGCaps, state+08) modifier
	state += getModState( "FliCK" ) ? 0x10 : 0  				; FliCK (Custom, state+16) modifier
	
	Pri := getKeyInfo( HKey . state )   						; Primary entry by state; may be a prefix
	Ent := getKeyInfo( HKey . state . "s" ) 					; Actual entry by state, if using a prefix
	if ( Pri == "" ) {
		Return
	} else if ( state == "ent1" ) { 							; VirtualKey. <key>vkey is set to Modifier or VK name.  	; eD WIP: Tried "VKey" here but then Ctrl+<key> fails?!
		pkl_SendThis( "{" . Pri . "}", modif ) 					; (Without this, Ctrl+Shift+# keys are broken. Why?)
	} else if ( Pri == -2 ) {   								; This state is sent as a VKey
		_composeVK( HKey, Ent )     							; If the output is a single, printable character, add it to the Compose queue
		Send % "{Blind}{" . Ent . "}"
	} else if ( ( Pri + 0 ) > 0 ) { 							; Normal numeric Unicode entry
		pkl_Send( Pri, modif )
	} else {
		Ent := ( Ent == "" ) ? getKeyInfo( HKey . "0s" ) : Ent	; Default to ShiftState 0 if entry is empty
		if pkl_ParseSend( Pri . Ent, "SendThis" )   			; Unified prefix-entry syntax
			Return  											; Skip osmClearAll in this case
	}	; end if Pri
	_osmClearAll()  											; If another key is pressed while a OSM is active, cancel the OSM
}	; end fn _KeyPressed										; eD WIP: Should _osmClearAll() be used more places above?

extendKeyPress( HKey ) { 										; Process an Extend modified key press
	Critical
	static extMods  := {}
	static modList := { "" 										; Dictionary of modifiers vs their AHK codes
		.  "LShift" : "<+"  , "LCtrl" : "<^"  , "LAlt" : "<!"  , "LWin" : "<#"
		,  "RShift" : ">+"  , "RCtrl" : ">^"  , "RAlt" : ">!"  , "RWin" : ">#"
		,   "Shift" :  "+"  ,  "Ctrl" :  "^"  ,  "Alt" :  "!"  ,  "Win" :  "#" }
	
	if ( HKey == -1 ) { 										; Special call to reset the extMods
		extMods := {} 											; Which Extend mods are in use
		Return
	}
	xLvl := getPklInfo( "extLvl" )
	xVal := getKeyInfo( HKey . "ext" . xLvl ) 					; The Extend entry/value for this key
	if ( xVal == "" )
		Return
	if ( RegExMatch( xVal, "i)^([LR]?(?:Shift|Alt|Ctrl|Win))$", mod ) == 1 ) {
		if ( getKeyState( HKey, "P" ) ) { 						; Mark the extMod as pressed
			extMods[HKey] := mod
;		} else { 												; eD WIP: This doesn't get triggered unless as Up hotkey is set!
;			extMods.Delete( HKey )
		}
		setLayInfo( "extendUsed", true ) 						; Mark the Extend press as used (to avoid dual-use as ToM key etc)
		Return
	}
	returnTo := getPklInfo( "extReturnTo" ) 					; Array of Ext layers to return to from the current one
	setExtendInfo( returnTo[ xLvl ] )
	pref := ""
	if not pkl_ParseSend( xVal ) { 								; Unified prefix-entry syntax
		if ( loCase( xVal ) == "backspace" )
			lastKeys( "pop1" )
		For HKey, mod in extMods { 								; Which Extend mods are depressed?
			if getKeyState( HKey, "P" ) {
				pref .= modList[mod]
			}
		} 	; end For
		Send {Blind}%pref%{%xVal%} 								; By default, take modifiers into account
	} 	; end if
	For HKey, mod in extMods {
		if ( not getKeyState( HKey, "P" ) )
			extMods.Delete( HKey )
	} 	; end For
	Critical, Off
	setLayInfo( "extendUsed", true ) 							; Mark the Extend press as used (to avoid dual-use as ToM key etc)
}

setExtendInfo( xLvl = 1 ) { 									; Update PKL info about the current Extend layer
	setPklInfo( "extLvl", xLvl )
	setLayInfo( "extendImg", getLayInfo( "extImg" . xLvl ) )
}

_composeVK( HKey, vk_HK ) { 									; If the output is a single, printable character, add it to the Compose queue
	static skipForDK    := false
	if skipForDK {  											; If the previous key press was an OS DK, skip the next press too to allow its release.
		skipForDK       := false
		Return
	}
	iVK := Format( "{:i}", "0x" . SubStr( vk_HK, 3, 2 ) )   	; VK as int. This should be robust for vk##sc### mappings too. GetKeyName/VK messes w/ OS DKs; avoid that.
	key := dllMapVK( iVK, "chr" )   							; GetKeyName() returns the base (unshifted) key name. We use a DLL call to avoid it here.
	if ( StrLen(key) == 1 ) {   								; Normal letters/numbers/symbols are single-character
		iSC := Format( "{:i}", "0x" . SubStr( HKey, 3 ) )   	; This should be okay, as KeyUp events don't get processed here? Just pure SC###.
		chr := dllToUni( iVK, iSC ) 							; Get the actual char (using a ToUnicode DLL call)
;		pklTooltip( "VK: " iVK "`nSC: " iSC "`nkey: [" key "]`nchr: [" chr "]`nord: " formatUnicode(chr), 2 )   	; eD DEBUG
		skipForDK   := ( chr == "śķιᶈForDK" ) ? true : false
		if ( StrLen(chr) == 1 ) 								; If the output from the OS layout is a printable single character...
			lastKeys( "push", chr ) 							; ...push it to the Compose queue
	}
}

;; ================================================================================================
;;  Set/get modifier key ShiftStates
;;      Process states of mods. Used in PKL_main; #etAltGrState() also in PKL_send.
;

setModifierState( theMod, keyDown = 0 ) {   				; Can be called from a hotkey or with an AHK mod key name. Handles OneShotMods (OSM) too.
	osmKeys := getPklInfo( "stickyMods" )   				; One-Shot mods (CSV, but stored as a string)
	osmLast := getPklInfo( "osmKeyN" . getPklInfo("osmN") ) ; The last set OSM
	if ( keyDown ) { 																	; eD WIP: Avoid the OSM if already held?
		if ( InStr( osmKeys, theMod ) && theMod != osmLast && ! ExtendIsPressed() ) { 	; eD WIP: Don't use Sticky mods when Ext is down?
			setOneShotMod( theMod ) 						; Activate the OSM
		} else {
			_setModState( theMod, 1 )
		}
	} else {
		if ( theMod == osmLast ) 							; If an active OSM...
			Return 											; ...don't release it yet.
		_setModState( theMod, 0 )
	}
}

_setModState( theMod, keyDown = 1 ) {   					; Using 1/0 for true/false here.
	if ( theMod == "Extend" ) { 							; Extend
		_setExtendState( keyDown )
;	} else if ( theMod == "AltGr" ) {
;		setAltGrState( keyDown ) 							; AltGr (not used now)  	; eD NOTE: For now, AltGr can't be sticky?
	} else {
		setKeyInfo( "ModState_" . theMod, keyDown ) 		; Standard modifier
		UD := ( keyDown ) ? "Down" : "Up"   				; If a physical mod, send KeyDown/Up
		if not inArray( [ "AltGr", "SwiSh", "FliCK" ], theMod )
			Send {%theMod% %UD%} 							; NOTE: This autorepeats. Is that desirable?
	}
}

getModState( theMod ) { 									; This is needed for virtual modifiers. Returns 1/0 (true/false).
;	if ( theMod == "AltGr" )
;		Return getAltGrState()
	Return getKeyInfo( "ModState_" . theMod )   			; Physical ones are simply depressed in _setModState().
}

setOneShotMod( theMod ) {   								; Activate a One-Shot Mod (OSM).
;	( theMod == "Shift" ) ? pklDebug( "OSM " . theMod, 0.3 )  ; eD DEBUG 	; eD WIP
	static osmN := 0 										; OSM number counter
	
	osmTime := getPklInfo( "stickyTime" )   				; StickyMod/OSM wait time
	osmN    := Mod( osmN, getPklInfo("osmMax") )+1  		; Switch between the OSM timers to allow multiple concurrent OSMs
	setPklInfo( "osmN"          , osmN   )
	setPklInfo( "osmKeyN" . osmN, theMod )  				; Marks the OSM as active
	SetTimer, osmTimer%osmN%, -%osmTime% 					; A timer to turn the OSM off again if unused (-time timers run once)
	_setModState( theMod, 1 )
;	( theMod == "Shift" ) ? pklDebug( "OSM " . osmN . " set:`n" . theMod . "`n`n" . osmTime . " ms", 0.5 )  ; eD DEBUG
}

osmTimer1:  												; Timer label for the sticky mods
	_osmClear( 1 )
Return

osmTimer2:  												; Timer label for the sticky mods
	_osmClear( 2 )
Return

osmTimer3:  												; Timer label for the sticky mods
	_osmClear( 3 )
Return

_osmClear( osmN ) { 										; Clear a specified sticky mod
	SetTimer, osmTimer%osmN%, Off   						; A -%time% one-shot timer could be used instead...
	theMod := getPklInfo( "osmKeyN" . osmN ) 				; ...but this is also called from elsewhere.
	setPklInfo( "osmKeyN" . osmN , "" )
	if ( theMod )
		setModifierState( theMod, 0 ) 						; Release the modifier
}

_osmClearAll() { 											; Clear all active sticky mods
	Loop % getPklInfo( "osmMax" )
	{
	if ( getPklInfo( "osmKeyN" . A_Index ) != "" )
		_osmClear( A_Index )
	}
;	( 1 ) ? pklDebug( "OSMs cleared", 0.3 )  ; eD DEBUG  	; eD WIP: Doesn't this get called after all?
}

AltGrIsPressed() {  										; Used in pkl_keypress and pkl_gui_image
;;  The following was removed from the Settings .ini for clarity. The functionality is still here, for now.
;;  ONHOLD: Remove CtrlAltlIsAltGr, enforcing <^>! (if laptops don't have >!, they'd have to remap to it)?
;;  
;;  Windows internally translates the AltGr (right Alt) key to LEFT Ctrl + RIGHT Alt.
;;  If you enable this option, EPKL detects AltGr as (one of) Ctrl + (one of) Alt.
;;  This is useful for notebook keyboards that do not have a right alt or AltGr key.
;;  It is usually not recommended, because fortunately many programs know the
;;  difference between AltGr and Alt+Ctrl.
;ctrlAltIsAltGr  = no
;	static CtrlAltlIsAltGr := -1
;	if ( CtrlAltlIsAltGr == -1 ) {
;		CtrlAltlIsAltGr := getKeyInfo( "RAltAsAltGrLocale" ) || getKeyInfo( "CtrlAltIsAltGr" )
;	}
	Return getKeyState( "RAlt" ) ; eD WIP AltGr: Removed || ( CtrlAltlIsAltGr && getKeyState( "Ctrl" ) && getKeyState( "Alt" ) )
}

;setAltGrState( keyDown ) {  								; The set fn calls get to reuse the static var. 	; eD WIP: Can we just use the normal _setModState() now?
;	getAltGrState( keyDown, 1 )
;}

;getAltGrState( keyDown = 0, set = 0 ) {
;	static AltGrState   := 0
;	if ( set == 1 ) {
;		AltGrState := ( keyDown ) ? 1 : 0
; ;		if ( keyDown == 1 ) {
; ;			AltGrState = 1
; ;			Send {LCtrl Down}{RAlt Down}
; ;		} else {
; ;			AltGrState = 0
; ;			Send {RAlt Up}{LCtrl Up}
; ;		}
;	} else {
;		Return AltGrState
;	}
; ;	( 1 ) ? pklDebug( "getAltGrState " . keyDown . " " . set )  ; eD DEBUG – When exactly is this used? Only if there's no real AltGr in the OS layout?
;}

ExtendIsPressed() { 										; Determine whether the Extend key is pressed. Used in _keyPressed() and pkl_gui_image
	ext := getLayInfo( "ExtendKey" )
	Return ( ext && getKeyState( ext, "P" ) ) ? true : false
}	; end fn

_setExtendState( set = 0 ) { 							; Called from setModState. This function handles Extend key tap or hold.
	static extendKey    := -1
	static extMod1      := ""
	static extMod2      := ""
	static extHeld      := 0
	static initialized  := false
	
	if ( not initialized ) {
		extendKey       := getLayInfo( "ExtendKey" )
		extMod1         := getPklInfo( "extendMod1" )
		extMod2         := getPklInfo( "extendMod2" )
		initialized     := true
	}
	
;	_osmClearAll() 											; eD WIP: Don't mix ToM and Extend? Nope, this didn't work and landed us with a stuck Caps key!
	if ( set == 1 ) && ( ! extHeld ) { 						; Determine multi-Extend layer w/ extMods
		xLvl  := getKeyState( extMod1, "P" ) ? 2 : 1 		; ExtMod1 -> ExtLvl +1
		xLvl  += getKeyState( extMod2, "P" ) ? 2 : 0 		; ExtMod2 -> ExtLvl +2
		setExtendInfo( xLvl ) 								; Update Extend layer info
		extHeld := 1 										; Guards against Extend key autorepeat
	} else if ( set == 0 ) { 								; When the Extend key is released...
		extendKeyPress( -1 ) 								; ...remove any Ext modifiers, and also...
		Send {Shift Up}{Ctrl Up}{Alt Up} 					; ...remove physical modifiers to clean up. 	; eD WIP: Extend Up can get interrupted if it's a ToM key, so this doesn't get done
		extHeld := 0
	}	; end if
	setLayInfo( "extendUsed", false ) 						; Mark this as a fresh Extend key press (for ToM etc)
}	; end fn _setExtendState

setTapOrModState( HKey, set = 0 ) { 						; Called from the PKL_main tapOrModDown/Up labels. Handles tap-or-mod (ToM) aka dual-role modifier (DRM) keys.
	static tapTime  := {} 									; We'll handle tap times for each key SC
	static tomHeld  := {} 									; Is this key held down? Or check KeyState instead?
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
		pklDebug( "caught interrupted ToM!", 0.5 ) 	; ED DEBUG: This isn't happening atm, as the lines that call it in processKeyPress() above are commented out
		if getKeyState( HKey, "P" ) {
			_setModState( tomMod, 1 ) 				; eD WIP: This is fishy! Keys get transposed, sometime also wrongly shifted (st -> Ts).
			setPklInfo( "tomMod", -1 )
		} else {
			_keyPressed( HKey )
			tomHeld[HKey] := 0
		}
	} else { 												; If the key is released (unless interrupted first)...
		SetTimer, tomTimer, Off
		setPklInfo( "tomKey", "" )
		tomHeld[HKey] := 0
		extUsed := ( HKey == getLayInfo( "ExtendKey" ) && getLayInfo( "extendUsed" ) ) 	; Is this not a used Extend key press?
		if ( A_TickCount < tapTime[HKey] ) && ! extUsed 	; If the key was tapped (and not used as Extend mod)...
			_keyPressed( HKey )
		if ( getPklInfo( "tomMod" ) == -1 ) 				; If the mod was set... 	; eD WIP: Or unset the mod anyway? What if the real mod key is being held?
			_setModState( tomMod, 0 )
		setLayInfo( "extendUsed", false )
	}
}	; end fn

tomTimer: 													; There's only one timer as you won't be activating several ToM at once
;	pklDebug( "ToM: " HKey " > " getPklInfo( "tomMod" ) ) 	; eD DEBUG
	_setModState( getPklInfo( "tomMod" ), 1 ) 				; When the timer goes off, set the ModState for the ToM key
	setPklInfo( "tomKey", "" ) 								; This is used by the ToM interrupt 	; eD WIP
	setPklInfo( "tomMod", -1 ) 								; Turn off this ToM key's todo status
Return

_pkl_CtrlState( HKey, capState, ByRef state, ByRef modif ) { 	; Handle ShiftState/modif vs Ctrl(+Shift)
	if getKeyState("Ctrl") {
		state = 2
		if getKeyState("Shift") {
			state++
			if !getKeyInfo( HKey . state ) {
				state--
				modif .= "+"
				if !getKeyInfo( HKey . state ) { 			; If no ShiftState entry, send as virtual key
					state := "ent1" 	; "VKey"
					modif .= "^"
				}
			}
		} else if !getKeyInfo( HKey . state ) {  			; --"--
			state := "ent1" 			; "VKey"
			modif .= "^"
		}
	} else {
		state := _pkl_CapsState( capState )
	}
}

_pkl_CapsState( capState ) { 								; Handle CapsState vs Shift/Caps/SGCaps
	res = 0
	if ( capState == 8 ) {
		if getKeyState("CapsLock", "T")
			res = 8
		if getKeyState("Shift")
			res++
	} else {
		res := getKeyState("Shift")
		if ( (capState & 1) && getKeyState("CapsLock", "T") )
			res := 1 - res
	}
	Return res
}
