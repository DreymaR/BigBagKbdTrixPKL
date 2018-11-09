#NoEnv
#Persistent
#NoTrayIcon
#InstallKeybdHook
#SingleInstance force
#MaxThreadsBuffer
#MaxThreadsPerHotkey  3
#MaxHotkeysPerInterval 300
#MaxThreads 20

;
; Portable Keyboard Layout by Farkas Máté   [https://github.com/Portable-Keyboard-Layout]
; edition DreymaR (Øystein B Gadmar, 2015-) [https://github.com/DreymaR/BigBagKbdTrixPKL]
;

; eD TOFIX/WIP:
;			- 
;			- Set a "Bas_ini" parameter to point to the base layout file, if used.
;			- Read {remapsFile, extendFile, dkListFile, stringFile} from base layout if not found in top layout?! Other info too? img_width/height/scale - nah...
;				- A function to read from one file with an alternative file, or default value?
;			- Make pklParseSend() work for DK chaining (one DK releases another)!
;				- Today, a special DK entry will set the PVDK (DK queue) to ""; to chain dead keys this must not happen for @ entries?
;				- That alone isn't enough though?
; eD TODO:
;			- Implement the ANS2ISO VKEY maps in layouts, thus needing only one full base layout. ANSI has the most logical key names for an [eD] base (e.g., OEM_MINUS).
;			- Layouts can now unmap keys and dead keys by using a -1 entry. Test and document it!
;				- Overriding dead key defs in layout.ini (and another file?). Do -1 entries remove a mapping?
;			- A timer that checks for an OS layout change, updating the OS dead keys etc as necessary.
;			- Multi-Extend, allowing one Extend key with modifiers to select up to 4 different layers.
;			- Could make the Japanese layout now, since dead keys support literals/ligatures!
;			- Greek polytonic accents? U1F00-1FFE for circumflex(perispomeni), grave(varia), macron, breve. Not in all fonts! Don't use oxia here, as it's equivalent to tonos?
;			- Hebrew layout. Eventually, Arabic too.
;			
;			- Do we need underlying vs wanted KbdType? I have an ISO board and want an ISO layout for it, but my MS layout is ANSI... (Likely, this won't happen to many...?)
;				- For now, I have a little hack that I hope doesn't bother anyone: The VK QWERTY ISO-AWide layout has its ANS2ISO remap commented out for my benefit.
;			- Allow escaped semicolons (`;) in iniRead?
;			- Reading layout files, replace four or more spaces [ ]{4,} with a tab (allows space-tabbing between layout entries)?
;			- Similar codes in layout.ini as in PKL_Settings.ini for @K@C@E ? Maybe too arcane and unnecessary
;			- Remove the Layouts submenu? Make it optional by .ini?
; eD DONE/FIXED:
;			- PKL[eD] v0.4.2: AHK v1.1; menu icons; array pdics (instead of HashTable); Unicode Send; UTF-8 compatible iniRead(); layered help images.
; 			- PKL[eD] v0.4.3: Key remaps, allowing ergo and other mods to be played over a few existing base layouts.
;			- PKL[eD] v0.4.4: Help Image Generator that uses Inkscape to create a set of help images from the current layout.
;			- PKL[eD] v0.4.5: Common prefix-entry syntax for keypress/deadkey/extend. Allows, e.g., literal/deadkey release from Extend. DK chaining doesn't work yet though.


setPklInfo( "pklName", "Portable Keyboard Layout" )							; PKL[edition DreymaR]
setPklInfo( "pklVers", "0.4.5_eD" ) 										; Version
setPklInfo( "pklComp", "ed. DreymaR" )										; Compilation info, if used
setPklInfo( "pkl_URL", "https://github.com/DreymaR/BigBagKbdTrixPKL" )		; http://pkl.sourceforge.net/

SendMode Event
SetKeyDelay 3								; eD: The Send key delay was not set, defaulted to 10
SetBatchLines, -1
Process, Priority, , H
Process, Priority, , R
SetWorkingDir, %A_ScriptDir%

; Global variables are largely replaced by the get/set info framework
setKeyInfo( "CurrNumOfDKs", 0 )				; eD: How many dead keys were pressed	(was 'CurrentDeadKeys')
setKeyInfo( "CurrNameOfDK", 0 )				; eD: Current dead key's name			(was 'CurrentDeadKeyName')
setKeyInfo( "CurrBaseKey_", 0 )				; eD: Current base key					(was 'CurrentBaseKey')
;setKeyInfo( "HotKeyBuffer", 0 )			; eD: Hotkey buffer for pkl_keypress	(was 'HotkeysBuffer')
setPklInfo( "File_Pkl_Ini", "PKL_Settings.ini"		)	; eD: Define this globally  (was 'pkl.ini')
setPklInfo( "File_Lay_Nam", "layout.ini"			)	; eD: --"--
setPklInfo( "File_Pkl_Dic", "PKL_eD\PKL_Tables.ini" )	; eD: My info dictionary file (from internal tables)
setPklInfo( "AdvancedMode", pklIniBool( "advancedMode", false ) )	; eD: Extra debug info etc

arg = %1% ; Layout from command line parameter
pkl_init( arg )
pkl_activate()
Return

; ####################### labels #######################

exitPKL:
	ExitApp
Return

keyHistory:
	KeyHistory
Return

detectDeadKeysInCurrentLayout:
	setDeadKeysInCurrentLayout( detectDeadKeysInCurrentLayout() )
Return

processKeyPress0:
processKeyPress1:
processKeyPress2:
processKeyPress3:
processKeyPress4:
processKeyPress5:
processKeyPress6:
processKeyPress7:
processKeyPress8:
processKeyPress9:
processKeyPress10:
processKeyPress11:
processKeyPress12:
processKeyPress13:
processKeyPress14:
processKeyPress15:
processKeyPress16:
processKeyPress17:
processKeyPress18:
processKeyPress19:
processKeyPress20:
processKeyPress21:
processKeyPress22:
processKeyPress23:
processKeyPress24:
processKeyPress25:
processKeyPress26:
processKeyPress27:
processKeyPress28:
processKeyPress29:
	runKeyPress()
Return

;keyPressedWoStar:		; SC###
;	activity_ping()
;	Critical
;	processKeyPress( A_ThisHotkey )
;Return

keyPressed: 			; *SC###
	activity_ping()
	Critical
	processKeyPress( SubStr( A_ThisHotkey, 2 ) )
Return

keyReleased:			; *SC### UP
;	activity_ping()
	Critical
	processKeyPress( SubStr( A_ThisHotkey, 2, -3 ) )
Return

modifierDown:			; *SC###
	activity_ping()
	Critical
	setModifierState( getKeyInfo( SubStr( A_ThisHotkey, 2 ) . "vkey" ), 1 )
Return

modifierUp: 			; *SC### UP
	activity_ping()
	Critical
	setModifierState( getKeyInfo( SubStr( A_ThisHotkey, 2, -3 ) . "vkey" ), 0 )
Return

showAbout:
	pkl_about()
Return

showHelpImage:
	pkl_showHelpImage()
Return

showHelpImageToggle:
	pkl_showHelpImage( 2 )
Return

changeActiveLayout:
	changeLayout( getLayInfo( "nextLayout" ) )
Return

rerunWithSameLayout:	; eD: Use the layout number instead of its code, to reflect any PKL_Settings list changes
	activeLay   := getLayInfo( "active" )			; Layout code (path) of the active layout
	numLayouts  := getLayInfo( "numOfLayouts" )		; The number of listed layouts
	Loop % numLayouts {
		theLayout   := getLayInfo( "layout" . A_Index . "code", theCode )
		actLayNum   := ( theLayout == activeLay ) ? A_Index : actLayNum
	}
	changeLayout( "UseLayPos_" . actLayNum )		; Rerun the same layout, telling pkl_init to use position.
Return

changeLayoutMenu:
	changeLayout( getLayInfo( "layout" . A_ThisMenuItemPos . "code" ) )
Return

doNothing:
Return

ToggleSuspend:
	Suspend
	goto afterSuspend
Return

afterSuspend:
	if ( A_IsSuspended ) {
		pkl_showHelpImage( 3 )
		Menu, Tray, Icon, % getLayInfo( "Ico_OffFile" ), % getLayInfo( "Ico_OffNum_" )
	} else {
		activity_ping( 1 )
		activity_ping( 2 )
		pkl_showHelpImage( 4 )
		Menu, Tray, Icon, % getLayInfo( "Ico_On_File" ), % getLayInfo( "Ico_On_Num_" )
	}
Return

; ####################### functions #######################

#Include pkl_init.ahk
#Include pkl_gui_image.ahk	; eD: pkl_gui was too long; it's been split into a help image and a menu/about part
#Include pkl_gui_menu.ahk
#Include pkl_keypress.ahk
#Include pkl_send.ahk
#Include pkl_deadkey.ahk
#Include pkl_utility.ahk	; eD: Various functions such as pkl_activity.ahk were merged into this file
#Include pkl_get_set.ahk
#Include pkl_ini_read.ahk
#Include pkl_make_img.ahk	; eD: Help image generator, calling Inkscape with an SVG template

; ####################### (external) modules #######################

; eD: #Include ext_Uni2Hex.ahk ; HexUC by Laszlo Hars - moved into pkl_init.ahk
; eD: #Include ext_MenuIcons.ahk ; MI.ahk (http://www.autohotkey.com/forum/viewtopic.php?t=21991) - obviated
; eD: #Include ext_SendUni.ahk ; SendU by Farkas et al - obviated by Unicode AHK v1.1
; eD: #Include ext_HashTable.ahk ; Merged w/ CoHelper then obviated by AHK v1.1 associative arrays
; eD: #Include getVKeyCodeFromName.ahk ; (was VirtualKeyCodeFromName) - replaced w/ read from tables .ini file
; eD: #Include getLangStrFromDigits.ahk ; http://www.autohotkey.com/docs/misc/Languages.htm - replaced w/ .ini
; eD: #Include ext_IniRead.ahk ; http://www.autohotkey.net/~majkinetor/Ini/Ini.ahk - replaced with pkl_iniRead
; eD: #Include getDeadKeysOfSystemsActiveLayout.ahk - replaced w/ read from tables .ini file
; eD: #Include A_OSVersion.ahk - moved into this file then removed as OSVersion <= VISTA are no longer supported
; eD: #Include getGlobal.ahk - moved into pkl_getset.ahk then removed as it was only used for one variable
; eD: #Include iniReadBoolean.ahk - moved into pkl_iniRead and tweaked
; eD: #Include detectDeadKeysInCurrentLayout.ahk - moved into pkl_deadkey.ahk
; eD: #Include pkl_locale.ahk - moved into pkl_get_set.ahk
