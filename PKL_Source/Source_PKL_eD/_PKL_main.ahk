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
; Portable Keyboard Layout by Farkas Máté   [http://pkl.sourceforge.net]
; edition DreymaR (Øystein B Gadmar, 2015-) [https://github.com/DreymaR/BigBagKbdTrixPKL]
;

; eD TODO: 	- Transition to AHK1.1 like PKL-vVv.
;				- Make iniRead functions similar to the vVv ones, able to read keys robustly from UTF-8 files
;				- Transition to AHK v1.1 pdic arrays instead of Farkas' HashTable implementations.
;				- Instead of VKeyCodeFromName, use the AHK v1.1 GetKeyVK() - if it works with VK names...?
;				- Transition to AHK v1.1 Unicode Send (re vVv): Need to fix some variable%ref% problems (see vVv?)
;			- Key remaps, allowing ergo and other mods to be played over a few existing base layouts.
;				- As LayoutInfo dics?
;				- The best way may be to define them as swap loops? Should these be compoundable?
;				- Likely, several types:
;				- pk_ for "physical" key movements like the AngleWide mod
;				- vk_ for "virtual" movements like the ISO/ANSI OEM_ switches?
;				- lk_ for "layout" movements like the Curl(DH) mod (or can these simply be vk_ switches?)
;				- Make sure they are case insensitive (so both SC### and sc### work, both ways)
;			- A timer that checks for an OS layout change, updating the OS dead keys etc as necessary
;			- Ligature tables both for keys and dead keys. Short ligatures may be specified directly as %{<lig>}?
;			- Expand the key definition possibilities, allowing dec/hex/glyph/ligature for dead keys etc.
;			- Remove the Layouts submenu? Make it optional by .ini?
;			- Reading layout files, replace four or more spaces [ ]{4,} with a tab (allows space-tabbing).
; eD DONE:	- Menu icons now work with AHK v1.1
; eD DONE:	- Test out whether tray menu shortcuts would work? E.g., &About. Answer: The menu shows it, but unselectable by key.

setPklInfo( "pklName", "Portable Keyboard Layout" )
setPklInfo( "pklVers", "0.4-eD" ) ; eD: PKL[edition DreymaR]
setPklInfo( "pklComp", "ed. DreymaR" )
setPklInfo( "pkl_URL", "https://github.com/DreymaR/BigBagKbdTrixPKL" ) ; http://pkl.sourceforge.net/

SendMode Event
SetBatchLines, -1
Process, Priority, , H
Process, Priority, , R
SetWorkingDir, %A_ScriptDir%

; Global variables
; eD TODO: Make global "personal" associative array dictionaries (AHK v1.1): gDicPkl, gDicLay (& gDicKey?)?
; eD TODO:     - Eventually, want something like gPkl[Lay_eD__File] := "Dreymar_Layout.ini".
; eD TODO:     - For now, declare the globals below separately in functions as needed.
gP_CurrNumOfDKs := 0						; eD: How many dead keys were pressed	(was 'CurrentDeadKeys')
gP_CurrNameOfDK := 0						; eD: Current dead key's name			(was 'CurrentDeadKeyName')
gP_CurrBaseKey_ := 0						; eD: Current base key					(was 'CurrentBaseKey')
;gP_HotKeyBuffer := 0						; eD: Hotkey buffer						(was 'HotkeysBuffer')
gP_Pkl_Ini_File := "pkl.ini"				; eD: Defined this globally. Declare in needed functions.
gP_Lay_Ini_File := "layout.ini" 			; eD: --"--
gP_Pkl_eD__File := "PKL_eD\PKL_eD.ini"		; eD: My extra pkl.ini file
gP_Lay_eD__File := "DreymaR_Layout.ini"		; eD: My extra layout.ini file
gP_Pkl_Dic_File := "PKL_eD\PKL_Tables.ini"	; eD: My extra info dictionary file (from internal tables)
setPklInfo( "eD_ShowMoreInfo", pklIniBool( "eD_DebugInfo", false, "Pkl_eD_", "pkl" ) )
	

arg = %1% ; Layout from command line parameter
pkl_init( arg )
pkl_activate()
return

; ####################### labels #######################

exitPKL:
	ExitApp
return

keyHistory:
	KeyHistory
return

detectDeadKeysInCurrentLayout:
	setDeadKeysInCurrentLayout( detectDeadKeysInCurrentLayout() )
return

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
return

keyPressedwoStar: ; SC025
	activity_ping()
	Critical
	processKeyPress( A_ThisHotkey )
return

keyPressed: ; *SC025
	activity_ping()
	Critical
	processKeyPress( SubStr( A_ThisHotkey, 2 ) )
return

upToDownKeyPress: ; *SC025 UP
	activity_ping()
	Critical
	processKeyPress( SubStr( A_ThisHotkey, 2, -3 ) )
return

modifierDown:  ; *SC025
	activity_ping()
	Critical
	setModifierState( getKeyInfo( SubStr( A_ThisHotkey, 2 ) . "vkey" ), 1 )
return

modifierUp: ; *SC025 UP
	activity_ping()
	Critical
	setModifierState( getKeyInfo( SubStr( A_ThisHotkey, 2, -3 ) . "vkey" ), 0 )
return

showAbout:
	pkl_about()
return

showHelpImage:
	pkl_showHelpImage()
return

showHelpImageToggle:
	pkl_showHelpImage( 2 )
return

changeActiveLayout:
	changeLayout( getLayInfo( "nextLayout" ) )
return

rerunWithSameLayout:
	changeLayout( getLayInfo( "active" ) )
return

changeLayoutMenu:
	changeLayout( getLayInfo( "layout" . A_ThisMenuItemPos . "code" ) )
return

doNothing:
return

ToggleSuspend:
	Suspend
	goto afterSuspend
return

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
return

; ####################### functions #######################

#Include pkl_deadkey.ahk
#Include pkl_getset.ahk
#Include pkl_gui.ahk
#Include pkl_init.ahk
#Include pkl_keypress.ahk
#Include pkl_locale.ahk
#Include pkl_send.ahk
#Include pkl_activity.ahk
#Include pkl_iniRead.ahk
#Include pkl_getWinDKs.ahk ; eD: Renamed from detectDeadKeysInCurrentLayout.ahk

; ####################### (external) modules #######################

; eD: #Include ext_Uni2Hex.ahk ; HexUC by Laszlo Hars - moved into pkl_init.ahk
; eD: #Include ext_MenuIcons.ahk ; http://www.autohotkey.com/forum/viewtopic.php?t=21991 - Renamed from MI.ahk
#Include ext_SendUni.ahk ; eD: SendU by Farkas et al - using Unicode AHK v1.1 will obviate this!
#Include ext_HashTable.ahk ; eD: Moved CoHelper into this file and removed unused sections
; eD: #Include getVKeyCodeFromName.ahk ; (was VirtualKeyCodeFromName) - replaced w/ read from tables .ini file
; eD: #Include getLangStrFromDigits.ahk ; http://www.autohotkey.com/docs/misc/Languages.htm - replaced w/ .ini
; eD: #Include ext_IniRead.ahk ; http://www.autohotkey.net/~majkinetor/Ini/Ini.ahk - replaced with pkl_iniRead
; eD: #Include getDeadKeysOfSystemsActiveLayout.ahk - replaced w/ read from tables .ini file
; eD: #Include A_OSVersion.ahk - moved into this file then removed as OSVersion <= VISTA are no longer supported
; eD: #Include getGlobal.ahk - moved into pkl_getset.ahk then removed as it was only used for one global var.
; eD: #Include iniReadBoolean.ahk - moved into pkl_iniRead and tweaked
