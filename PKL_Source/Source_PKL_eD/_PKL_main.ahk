#NoEnv
#Persistent
#NoTrayIcon
#InstallKeybdHook
#SingleInstance force
#MaxThreadsBuffer
#MaxThreadsPerHotkey  3
#MaxHotkeysPerInterval 300
#MaxThreads 20

; eD TODO: 	- Transition to AHK1.1+ like PKL-vVv. 
;				- Need to make menu icons work first!
;				- Make iniRead functions similar to the vVv ones, able to read keys robustly from UTF-8 files
;				- Transition to AHK 1.1+ Unicode Send (re vVv)
;			- Key remaps, allowing ergo and other mods to be played over a few existing base layouts.
;				- As LayoutInfo dics?
;				- The best way may be to define them as swap loops? Should these be compoundable?
;				- Likely, several types:
;				- pk_ for "physical" key movements like the AngleWide mod
;				- vk_ for "virtual" movements like the ISO/ANSI OEM_ switches?
;				- lk_ for "layout" movements like the Curl(DH) mod (or can these simply be vk_ switches?)
;			- A timer that checks for an OS layout change, updating the OS dead keys etc as necessary
;			- Separate deadkey tables (but a fallback for backwards compatibility)
;			- Ligature tables both for keys and dead keys. Short ligatures may be specified directly as %{<lig>}?
;			- Expand the key definition possibilities, allowing dec/hex/glyph/ligature for dead keys etc.
; eD WIP:	- Move several internal tables to an .ini file so they may be edited by users

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
; eD TODO: Make global "personal" dictionaries (requires AHK 1.1+): gdicPklVar, gdicLayVar (& gdicKeyVar?)
; eD TODO:     - Eventually, want something like gPv[Lay_eD__File] := "Dreymar_Layout.ini".
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
gP_ShowMoreInfo := pklIniBool( "eD_DebugInfo", false, "Pkl_eD_", "pkl" )
;gP_ShowMoreInfo ? setPklInfo( "DebugMode", "yes" ) :  setPklInfo( "DebugMode", "no" )
	

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
	ThisHotkey := A_ThisHotkey
	processKeyPress( ThisHotkey )
return

keyPressed: ; *SC025
	activity_ping()
	Critical
	ThisHotkey := SubStr( A_ThisHotkey, 2 )
	processKeyPress( ThisHotkey )
return

upToDownKeyPress: ; *SC025 UP
	activity_ping()
	Critical
	ThisHotkey := A_ThisHotkey
	ThisHotkey := SubStr( ThisHotkey, 2 )
	ThisHotkey := SubStr( ThisHotkey, 1, -3 )
	processKeyPress( ThisHotkey )
return

modifierDown:  ; *SC025
	activity_ping()
	Critical
	ThisHotkey := SubStr( A_ThisHotkey, 2 )
	setModifierState( getLayoutItem( ThisHotkey . "v" ), 1 )
return

modifierUp: ; *SC025 UP
	activity_ping()
	Critical
	ThisHotkey := A_ThisHotkey
	ThisHotkey := SubStr( ThisHotkey, 2 )
	ThisHotkey := SubStr( ThisHotkey, 1, -3 )
	setModifierState( getLayoutItem( ThisHotkey . "v" ), 0 )
return

showAbout:
	pkl_about()
return

displayHelpImage:
	pkl_displayHelpImage()
return

showHelpImageToggle:
	pkl_displayHelpImage( 2 )
return

changeActiveLayout:
	changeLayout( getLayoutInfo( "nextLayout" ) )
return

rerunWithSameLayout:
	changeLayout( getLayoutInfo( "active" ) )
return

changeLayoutMenu:
	changeLayout( getLayoutInfo( "layout" . A_ThisMenuItemPos . "code" ) )
return

doNothing:
return

ToggleSuspend:
	Suspend
	goto afterSuspend
return

afterSuspend:
	if ( A_IsSuspended ) {
		pkl_displayHelpImage( 3 )
		Menu, Tray, Icon, % getTrayIconInfo( "FileOff" ), % getTrayIconInfo( "NumOff" )
	} else {
		activity_ping( 1 )
		activity_ping( 2 )
		pkl_displayHelpImage( 4 )
		Menu, Tray, Icon, % getTrayIconInfo( "FileOn" ), % getTrayIconInfo( "NumOn" )
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

; ####################### (external) modules #######################

#Include ext_Uni2Hex.ahk ; HexUC by Laszlo Hars ; eD: Renamed from HexUC.ahk
#Include ext_MenuIcons.ahk ; http://www.autohotkey.com/forum/viewtopic.php?t=21991 ; eD: Renamed from MI.ahk
#Include ext_SendUni.ahk ; eD: SendU by Farkas et al - using Unicode AHK (v1.1+) will obviate this!
#Include ext_HashTable.ahk ; eD: Moved all HashTable files into this one to reduce clutter
#Include getWindowsDeadKeys.ahk ; eD: Renamed from detectDeadKeysInCurrentLayout.ahk
; eD: #Include getVKeyCodeFromName.ahk ; (was VirtualKeyCodeFromName) - replaced w/ read from tables .ini file
; eD: #Include getLangStrFromDigits.ahk ; http://www.autohotkey.com/docs/misc/Languages.htm - replaced w/ .ini
; eD: #Include ext_IniRead.ahk ; http://www.autohotkey.net/~majkinetor/Ini/Ini.ahk - replaced with pkl_iniRead
; eD: #Include getDeadKeysOfSystemsActiveLayout.ahk - replaced w/ read from tables .ini file
; eD: #Include A_OSVersion.ahk - moved into this file then removed as OSVersion <= VISTA are no longer supported
; eD: #Include getGlobal.ahk - moved into pkl_getset.ahk then removed as it was only used for one global var.
; eD: #Include iniReadBoolean.ahk - moved into pkl_iniRead and tweaked
