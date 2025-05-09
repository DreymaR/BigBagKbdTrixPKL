;;  ================================================================================================================================================
;;  AHK v1 --> v2 Transition
;;      The transition from AHK v1 to v2 seems very promising, but needs some work.
;;      One thing that may ease it, would be to make some deprecated commands into temporary functions.
;;      https://www.autohotkey.com/docs/v2/v2-changes.htm
;
;;  Blow-by-blow:
;;    - All `var = value` assignments have to go (replace with `:=`). Also ` = ` in conditions (replace with `==`).
;;    - Normal variable references are never enclosed in percent signs (%variable%)
;;    - All old `if` are gone; `if expression` stays
;;    - Super-globals are gone
;;    - Gosub is gone. What to use for it? Functions all the way, it seems.
;;    - How is SetTimer handled in AHK v2? Can a wrapper fn() work for the transition?
;;    - Sleep: No changes necessary? They say that all commands have become functions but the old syntax is still described on its help page for v2.
;;        - It's because functions can be called without parentheses if the return value is not needed (except when called within an expression).
;
;;  Labels were found here: gui_settings (several), keypress (_osmClear, setTapOrModState), make_img (ChangeButtonNamesHIG), utility (4), main (several).
;;  Gosubs were found here: gui_menu (ToggleSuspend), gui_settings (5), init (afterSuspend, plkJanitorTic), utility (7), main (setUIGlobals, if necessary?).
;;  SetTimer is found here: deadkey/gui_image (showHelpImage), init (JanitorTic), keypress (osm, tom), make_img (ButtonNames), utility (KillSplash)
;;  Global  was found here: gui_settings (several), utility (iconFile). Fixed the latter using pklSet/Get.
;
;;  The pkl_gui_settings may be the hardest part? It contains both globals, labels and Gosub. Need to study AHK v2 GUI design.
;

Sleep( delay ) {    																	; Wrapper function, pending AHK v2 transition: Sleep
	Sleep % delay
}

IniRead( Filename, Section := "", Key := "", Default := "ERROR" ) { 					; Wrapper function, pending AHK v2 transition: IniRead
	IniRead, val, % Filename, % Section, % Key, % Default   							; Reading only a section (list) should work with this one
	Return val
}


;;  ================================================================================================================================================
;;  Gosub labels, previously located in other files
;

;;  ################        labels - PKL_main       ################

;;  eD WIP: Map AltGr to RAlt to prevent trouble?!
;;  The order of AltGr is always LCtrl then RAlt. Custom combos always have the * (wildcard) mod so they obey any mod state.
;;  In order to make a combo hotkey for LCtrl&RAlt, we also need to handle the first key on its own (https://www.autohotkey.com/docs/Hotkeys.htm#combo)
;;  "For standard modifier keys, normal hotkeys typically work as well or better than "custom" combinations. For example, <+s:: is recommended over LShift & s::."
;;  Possible issue: These hotkeys are generated after the others, since initPklIni() is already run. Should this part be handled in the init part? What about any LCtrl hotkey in the layout?
;#if GetKeyState( "LCtrl", "P" )
;RAlt::
;#if
;LControl & RAlt:: 	; This works but mapping to RAlt produces "Invalid hotkey", why!? Also, it repeats.
;<^>!:: 				; eD WIP: This isn't working?! Maybe an #if GetKeyState( "RAlt", "P" ) will do the trick?
;	pklDebug( "Gotcha, AltGr!", 0.5 )
;Return
;LControl & RAlt::Send {RAlt Down} 	; This alone gets AltGr stuck
;LControl Up & RAlt Up::Send {RAlt Up} 	; This doesn't work!?

keypressDown:   		; *SC###    hotkeys
	Critical
	keyPressed(         SubStr( A_ThisHotkey, 2     ) ) 	; SubStr removes leading '*'
Return

keypressUp:     		; *SC### UP
	Critical
	Send % "{Blind}{" . getKeyInfo( SubStr( A_ThisHotkey, 2, -3 ) . "ent1" ) . "  UP}"  	; Send the remapped key up
Return

modifierDown:   		; *SC###    (call fn as HKey to translate to modifier name)
	Critical
	setModifierState( getKeyInfo( SubStr( A_ThisHotkey, 2     ) . "ent1" ), 1 )
Return

modifierUp:
	Critical
	setModifierState( getKeyInfo( SubStr( A_ThisHotkey, 2, -3 ) . "ent1" ), 0 )
Return

tapOrModDown:   		; *SC###
	Critical
	setTapOrModState(   SubStr( A_ThisHotkey, 2     ), 1 )
Return

tapOrModUp:
	Critical
	setTapOrModState(   SubStr( A_ThisHotkey, 2, -3 ), 0 )
Return

showAbout:      											; Menu "About..."
	pkl_about()
Return

changeSettings: 											; Menu "Layout/Settings..."
	pklSetUI()
Return

keyHistory:     											; Menu "AHK Key History..."
	KeyHistory
Return

;detectCurrentWinLayDeadKeys:    							; Menu "Detect dead keys..."
;	setCurrentWinLayDeadKeys( detectCurrentWinLayDeadKeys() )
;Return

showHelpImage:
	pkl_showHelpImage()
Return

showHelpImageOnce:  										; Used as a one-time refresh when necessary
	pkl_showHelpImage()
Return

toggleHelpImage:    										; Menu "Display help image"
	pkl_showHelpImage( 2 )
Return

zoomHelpImage:      										; Menu "Zoom help image"
	pkl_showHelpImage( 5 )
Return

moveHelpImage:      										; Hotkey "Move help image"
	pkl_showHelpImage( 6 )
Return

opaqHelpImage:      										; Hotkey "Opaque/Transparent image"
	pkl_showHelpImage( 7 )
Return

rerunNextLayout:    										; Menu "Change layout"
	changeLayout( getLayInfo( "NextLayout" ) )
Return

rerunSameLayout:    										; Menu "Refresh EPKL"
	activeLay   := getLayInfo( "ActiveLay" )    			; Layout code (path) of the active layout
	numLayouts  := getLayInfo( "NumOfLayouts" ) 			; The number of listed layouts
	Loop % numLayouts { 									; Use the layout # instead of its code, to reflect any PKL Settings list changes
		theLayout   := getLayInfo( "layout" . A_Index . "code", theCode )
		actLayNum   := ( theLayout == activeLay ) ? A_Index : actLayNum
	}
	changeLayout( "UseLayPos_" . actLayNum )    			; Rerun the same layout, telling pkl_init to use position.
Return

changeLayoutMenu:   										; Menu "Layouts"
	changeLayout( getLayInfo( "layout" . A_ThisMenuItemPos . "code" ) )
Return

suspendOn:
	Suspend, On
	Goto afterSuspend
Return

suspendOff:
	Suspend, Off
	Goto afterSuspend
Return

toggleSuspend:  											; Menu "Suspend"
	Suspend
	Goto afterSuspend
Return

afterSuspend:
	If ( A_IsSuspended ) {
		pkl_showHelpImage(  3 )
		Menu, Tray, Icon, % getLayInfo( "Ico_OffFile" ), % getLayInfo( "Ico_OffNum_" )
	} else {
		pkl_showHelpImage( -3 )
		Menu, Tray, Icon, % getLayInfo( "Ico_On_File" ), % getLayInfo( "Ico_On_Num_" )
	}
Return

exitPKL:    												; Menu "Exit"
	ExitApp
Return

doNothing:
Return

openTarget:
	runTarget( getPklInfo( "openMenuTarget" ) ) 		; Open the chosen target (default A_ScriptDir, in File Explorer)
Return

getWinInfo:
	getWinInfo()    									; Show the active window's title/process(exe)/class
Return

epklDebugUtil:  										; eD DEBUG/UTILITY/WIP: This entry is activated by the Debug hotkey
	nr  := pklIniRead( "whichUtility", 1 )
	pklToolTip( "Running Debug/Utility routine " . nr . "`n(specified in Settings)", 1.5 )
	debug%nr%() 										; Run the specified debug# routine
Return

  debug1() {
	KeyHistory  										; Show AHK Key History      as by the View -> Key history menu  (shown)
} debug2() {
	ListHotkeys 										; Show AHK hotkeys          as by the View -> Hotkeys     menu  (hidden)
} debug3() {
	ListVars    										; Show AHK global variables as by the View -> Variables   menu  (hidden)
} debug4() {
	ListLines   										; Show AHK script (flow relevant) line execution history        (hidden)
} debug5() {
	getWinInfo() 										; Show the active window's title/process(exe)/class             (EPKL)
} debug6() {
	menuIconList()  									; List menu icons in a specified file
} debug7() {
	pklDebugCustomRoutine() 							; eD DEBUG – usually: Show OS & EPKL VK codes for the OEM keys
} debug8() {
	detectCurrentWinLayDeadKeys()   					; The old PKL DeadKey detection routine                         (hidden)
} debug9() {
	getWinLayDKs()  									; eD WIP: Improved WinLayDK detection
	pklDebug( "getWinLayDKs:`n" . getPklInfo("WinLayDKs")[0x10], 2 )  ; eD DEBUG
;	importLayouts()  									; eD TODO: Import a MSKLC layout file to EPKL format
;	importComposer() 									; eD DONE: Import an X11 Compose file to EPKL format
}   ; <-- debug#

;;  ################    labels - pkl_keypress       ################

tomTimer:   												; There's only one timer as you won't be activating several ToM at once
	_setModState( getPklInfo( "tomMod" ), 1 )   			; When the timer goes off, set the ModState for the ToM key
	setTapOrModState( -1 )  								; Clear any ToM key settings
Return

osmTimer1:  												; Timer label for the sticky mods
	_osmClear( 1 )
Return

osmTimer2:  												; Timer label for the sticky mods
	_osmClear( 2 )
Return

osmTimer3:  												; Timer label for the sticky mods
	_osmClear( 3 )
Return

osmTimer4:  												; Timer label for the sticky mods 	; eD WIP: Should we use this, or is 3 enough?
	_osmClear( 4 )
Return

;;  ################    labels - pkl_make_img       ################

ChangeButtonNamesHIG:   										; For the MsgBox asking whether to make full or state images
	IfWinNotExist, Make Help Images?
		Return  												; Keep waiting for the message box if it isn't ready
	SetTimer, ChangeButtonNamesHIG, Off
	WinActivate
	ControlSetText, Button1, &Full
	ControlSetText, Button2, &Main
Return

;;  ################    labels - pkl_utility        ################

pklJanitorTic:
	_pklSuspendByApp()
	_pklSuspendByLID()
	_pklJanitorActivity()
	_pklJanitorLocaleVK()
;	_pklJanitorCleanup() 	; eD WIP: Testing EPKL without the idle keyups
Return

KillSplash:
	Gui, pklSp: Destroy 					;TrayTip 	;SplashTextOff
Return

KillToolTip:
	ToolTip
Return

MenuIconNum:
	Clipboard := getPklInfo( "iconListFile" ) . ", " . A_EventInfo
	pklInfo( "'" . Clipboard . "'`n     added to Clipboard!", 8 )   	; Msgbox % 
Return

;;  ################    labels - end                ################
