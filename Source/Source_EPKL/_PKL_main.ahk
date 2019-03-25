#NoEnv
#Persistent
#NoTrayIcon
#InstallKeybdHook
#SingleInstance force
#MaxThreadsBuffer
#MaxThreadsPerHotkey  3
#MaxHotkeysPerInterval 300
#MaxThreads 20

;;
;;  Portable Keyboard Layout by Farkas Máté   [https://github.com/Portable-Keyboard-Layout]
;;  edition DreymaR (Øystein B Gadmar, 2015-) [https://github.com/DreymaR/BigBagKbdTrixPKL]
;;

; eD TOFIX/WIP:
;			- 
;			- TOFIX: HIG makes a state8 image of the semicolons...  (つ_〃*)
;			- TOFIX: pkl_Send() -> pkl_SendChr() - make sure space and others that should release DK get sent right.
;			- TOFIX: DK+Space or DK+DK don't release the accent anymore?!? The DK is kept active. Was broken in or before PKL_eD v0-4-7, possibly in v0-4-5 w/ parseSend()?
;				- So the problem may be that parseSend() uses pkl_SendThis() in some places where it should've done the DK thing that pkl_Send() uses! Make that a sep. fn()?
;				- Or is it something about CurrNumOfDKs (used to be a global, now KeyInfo)?
;			- TOFIX: If a layout have fewer states (e.g., missing state2) the BaseLayout fills in empty mappings in the last state!
;			- WIP: Dual-role modifiers. Allow home row modifiers like for instance Dusty from Discord uses: ARST and OIEN can be Alt/Win/Shift/Ctrl when held. Define both KeyDn/Up.
;				- In EPKL_Settings.ini, set a dualRoleModTapTime. In layout, use SC### = A|Alt DualRoleModifier entries. Can we allow multi-state mapping? If VK contains | then...?
;				- Redefine the dual-role Extend key as a generic dualRoleMod then?
;			- TEST: Is this necessary any more: 'img_DKeyDir     = ..\Cmk-eD_ANS\DeadkeyImg'? Or will the setting from the baseLayout just carry over? Maybe for the ergomodded variants?
;			- TEST: Layouts can now unmap keys and dead keys(?) by using a '-1' or 'vk' entry. Tested. Document it!
;				- Augmenting/overriding dead key defs in layout.ini (and baseLayout.ini?). Entries of -1 should remove a mapping.
;			- TOFIX: I messed up Gui Show for the images earlier, redoing it for each control with new img titles each time. Maybe now I could make transparent color work? No...?
; eD TODO:
;			- Idea: Repeat key!? Type a key and then any key to get a double letter. Implement as a dead key releasing aa for a etc.
;			- A proper Compose method, allowing IME-like behavior and much more?!
;				- This would allow "proper" Vietnamese, phonetic Kyrillic etc layouts instead of dead keys which work "the wrong way around".
;				- Must keep track of previous entries in a buffer then. Clear the buffer on special entries.
;				- To ensure it's fast, only check when the last typed glyph is the release glyph of a compose? E.g., you type a^ and the ^ triggers a search producing â.
;				- Ideally it should be able to take the same input format as Linux Compose more or less, so people we could import (parts of) its rich Compose tables.
;			- For Jap layout etc, allow dk tables in the main layout.ini as well as the dk file. Let layout.ini tables overwrite dk file ones.
;			- Make pklParseSend() work for DK chaining (one DK releases another)!
;				- Today, a special DK entry will set the PVDK (DK queue) to ""; to chain dead keys this should this happen for @ entries?
;				- Removing that isn't enough though? And actually, should a dk chaining start anew? So, replicate the state and effect of a normal layout DK press.
;			- Maintenance timer. Every 6 s(?)
;				- Check if no keys are held and no sticky timers counting, then send Up for those that aren't in use.
;				- Update the OS dead keys etc as necessary.
;				- Replace activityPing() etc with A_TimeIdlePhysical in the maintenance loop?
;				- Combine w/ other housekeeping...?
;			- Shift sensitive Extend? When mapping for the NumPad layer, it'd be nice to have $/¢, €/£ etc. This allows many more potential mappings! 4×4-level Extend?!
;			- Could make the Japanese layout now, since dead keys support literals/ligatures!
;			- Hebrew layout. Eventually, Arabic too.
;			- Mirrored one-hand typing as an Extend layer? Would need a separate Extend modifier for it I suppose? E.g., NumPad0 or Down for foot or right-arm switching.
;				- Mirroring is hard to implement as a remap, since it'd mostly consist of many two-key loops. Extend looks promising though, except it hogs the Ext key.
;			- A settings panel instead of editing .ini files.
;			- A set of IPA dk, maybe on AltGr+Shift symbol keys?
;			- Lose CompactMode, StartSuspended etc? They seem to clutter up the settings file and I don't think people actually use them?
; eD ONHOLD:
;			- Do we need underlying vs wanted KbdType? I have an ISO board and want an ISO layout for it, but my MS layout is ANSI... (Likely, this won't happen to many...?)
;				- For now, I have a little hack that I hope doesn't bother anyone: The VK QWERTY ISO-AWide layout has its ANS2ISO remap commented out for my benefit.
;			- Allow escaped semicolons (`;) in iniRead?
;			- Similar codes in layout.ini as in PKL Settings.ini for @K@C@E ? Maybe too arcane and unnecessary.
;			- Remove the Layouts submenu? Make it optional by .ini?
;			- Greek polytonic accents? U1F00-1FFE for circumflex(perispomeni), grave(varia), macron, breve. Not in all fonts! Don't use oxia here, as it's equivalent to tonos?
;			- Extend lock? E.g., LShift+Mod2+Ext locks Ext2. Maybe too confusing. But for, say, protracted numeric entry it could be useful?
;			- Some kaomoji have non-rendering glyphs, particularly eyes. Kawaii (Messenger), Joy face, Donger (Discord on phone). Just document and leave it at that.
;			- Implement the ANS2ISO VKEY maps in all layouts to have only one full base layout? Or keep both? For now, keep both eD BaseLayout at least.
;				- ISO is a more international standard, but ANSI has more logical key names for the US-based Cmk[eD] layouts (e.g., OEM_MINUS/OEM_PLUS).
;			- Go back on the Paste Extend key vs Ext1/2? It's ugly and a bit illogical since the layers are otherwise positional. But I get confused using Ext+D for Ctrl+V.
; eD DONE/FIXED:
;			- PKL[eD] v0.4.2: AHK v1.1; menu icons; array pdics (instead of HashTable); Unicode Send; UTF-8 compatible iniRead(); layered help images.
; 			- PKL[eD] v0.4.3: Key remaps, allowing ergo and other mods to be played over a few existing base layouts.
;			- PKL[eD] v0.4.4: Help Image Generator that uses Inkscape to create a set of help images from the current layout.
;			- PKL[eD] v0.4.5: Common prefix-entry syntax for keypress/deadkey/extend. Allows, e.g., literal/deadkey release from Extend.
;			- PKL[eD] v0.4.6: The base layout can hold default settings. Layout entries are now any-whitespace delimited.
;			- PKL[eD] v0.4.7: Multi-Extend w/ 4 layers selectable by modifiers+Ext. Extend-tap-release. One-shot Extend layers.
;			- PKL[eD] v0.4.8: Sticky/One-shot modifiers. Tap the modifier(s), then within a certain time hit the key to modify. Prefix-entry syntax in PowerStrings too.
;			- EPKL v1.0.0: Name change to EPiKaL PKL. ./PKL_eD -> ./Files folder. Languages are now under Files.
;			- EPKL v1.1.0: Some layout format changes. Minor fixes/additions. And kaomoji!  d( ^◇^)b
;				- Fixed: DK images were gone due to an error in EPKL_Settings.ini. DK images also didn't work for some layouts.
;				- Fixed: Sticky/One-Shot mods stayed active when selecting Extend, affecting strings if sent within the OSM timer even when sent with %.
;				- New: A set of Kaomoji text faces in the Strings Extend layer. Help images included.  ♪～└[∵┌]└[･▥･]┘[┐∵]┘～♪
;				- New: Hungarian Cmk[eD] locale variant.
;				- New: Zoom and Move hotkeys for the help image, cycling between image sizes and positions. Set e.g., imgZoom = 60,100,150 (%) in EPKL_Settings.
;				- Tutorial on making a layout variant in README. How to make and activate a layout, changing locale, remaps and a keys mappings.
;				- Moved the BaseLayout files up one tree level. In layout.ini, use its file path from Layouts w/o extension, e.g., Colemak-VK\BaseLayout_Cmk-VK-ISO
;				- 'Spc' and 'Tab' layout mappings, sending {Blind}{Key}. Makes for compact layout entries for the delimiting whitespace characters.
;				- Direct Extend key mapping, e.g., for CapsLock use 'SC03A = Extend Modifier' rather than the extend_key setting with a mapped key as before.
;				- Extend layers can be set as hard/soft in the _Extend file. Soft layers follow mnemonic letter mappings, hard ones are positional (like my Ext1/2).
;					- The Curl(DH) Ext+V may still be mnemonic/soft instead of positional/hard (^V on Ext+D). Use _ExtDV with AWide/Angle mods for mapSC_extend then.


setPklInfo( "pklName", "EPiKaL Portable Keyboard Layout" ) 					; PKL[edition DreymaR]
setPklInfo( "pklVers", "1.1.0" ) 											; EPKL Version (was PKL[eD] v0.4.8)
setPklInfo( "pklComp", "DreymaR" ) 											; Compilation info, if used
setPklInfo( "pkl_URL", "https://github.com/DreymaR/BigBagKbdTrixPKL" )		; http://pkl.sourceforge.net/

SendMode Event
SetKeyDelay 3								; eD NOTE: The Send key delay was not set, defaulted to 10
SetBatchLines, -1
Process, Priority, , H
Process, Priority, , R
SetWorkingDir, %A_ScriptDir%

; Global variables are largely replaced by the get/set info framework
setKeyInfo( "CurrNumOfDKs", 0 ) 			; How many dead keys were pressed	(was 'CurrentDeadKeys')
setKeyInfo( "CurrNameOfDK", 0 ) 			; Current dead key's name			(was 'CurrentDeadKeyName')
setKeyInfo( "CurrBaseKey_", 0 ) 			; Current base key					(was 'CurrentBaseKey')
;setKeyInfo( "HotKeyBuffer", 0 ) 			; Hotkey buffer for pkl_keypress	(was 'HotkeysBuffer')
setPklInfo( "File_PklIni", "EPKL_Settings.ini"      ) 	; Defined globally  	(was 'pkl.ini')
setPklInfo( "LayFileName", "layout.ini"             ) 	; --"--
setPklInfo( "File_PklDic", "Files\PKL_Tables.ini"   ) 	; Info dictionary file, mostly from internal tables
setPklInfo( "AdvancedMode", pklIniBool( "advancedMode", false ) )	; Extra debug info etc

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
;	Critical
;	processKeyPress( A_ThisHotkey )
;Return

keyPressed: 			; *SC###
;	activity_ping()
	Critical
	processKeyPress( SubStr( A_ThisHotkey, 2 ) )
Return

keyReleased:			; *SC### UP
	activity_ping()
	Critical
	processKeyPress( SubStr( A_ThisHotkey, 2, -3 ) )
Return

modifierDown:			; *SC###    (translate to VK name)
;	activity_ping()
	Critical
	setModifierState( getKeyInfo( SubStr( A_ThisHotkey, 2 ) . "vkey" ), 1 )
Return

modifierUp: 			; *SC### UP (translate to VK name)
	activity_ping()
	Critical
	setModifierState( getKeyInfo( SubStr( A_ThisHotkey, 2, -3 ) . "vkey" ), 0 )
Return

;dualRoleModDown:
;	Critical
;	setDualRoleModState( getKeyInfo( SubStr( A_ThisHotkey, 2 ) . "vkey" ), 1 )
;Return

;dualRoleModUp:
;	activity_ping()
;	Critical
;	setDualRoleModState( getKeyInfo( SubStr( A_ThisHotkey, 2, -3 ) . "vkey" ), 0 )
;Return

extendDown: 			; *SC###
;	activity_ping()
	Critical
	setExtendState( 1 )
Return

extendUp:   			; *SC### UP
	activity_ping()
	Critical
	setExtendState( 0 )
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

zoomHelpImage:
	pkl_showHelpImage( 5 )
Return

moveHelpImage:
	pkl_showHelpImage( 6 )
Return

changeActiveLayout:
	changeLayout( getLayInfo( "nextLayout" ) )
Return

rerunWithSameLayout:	; eD: Use the layout number instead of its code, to reflect any PKL Settings list changes
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
#Include pkl_gui_image.ahk	; pkl_gui was too long; it's been split into help image and menu/about parts
#Include pkl_gui_menu.ahk
#Include pkl_keypress.ahk
#Include pkl_send.ahk
#Include pkl_deadkey.ahk
#Include pkl_utility.ahk	; Various functions such as pkl_activity.ahk were merged into this file
#Include pkl_get_set.ahk
#Include pkl_ini_read.ahk
#Include pkl_make_img.ahk	; Help image generator, calling Inkscape with an SVG template

; #######################  modules  #######################

; #Include ext_Uni2Hex.ahk ; HexUC by Laszlo Hars - moved into pkl_init.ahk
; #Include ext_MenuIcons.ahk ; MI.ahk (http://www.autohotkey.com/forum/viewtopic.php?t=21991) - obviated
; #Include ext_SendUni.ahk ; SendU by Farkas et al - obviated by Unicode AHK v1.1
; #Include ext_HashTable.ahk ; Merged w/ CoHelper then obviated by AHK v1.1 associative arrays
; #Include getVKeyCodeFromName.ahk ; (was VirtualKeyCodeFromName) - replaced w/ read from tables .ini file
; #Include getLangStrFromDigits.ahk ; http://www.autohotkey.com/docs/misc/Languages.htm - replaced w/ .ini
; #Include ext_IniRead.ahk ; http://www.autohotkey.net/~majkinetor/Ini/Ini.ahk - replaced with pkl_iniRead
; #Include getDeadKeysOfSystemsActiveLayout.ahk - replaced w/ read from tables .ini file
; #Include A_OSVersion.ahk - moved into this file then removed as OSVersion <= VISTA are no longer supported
; #Include getGlobal.ahk - moved into pkl_getset.ahk then removed as it was only used for one variable
; #Include iniReadBoolean.ahk - moved into pkl_iniRead and tweaked
; #Include detectDeadKeysInCurrentLayout.ahk - moved into pkl_deadkey.ahk
; #Include pkl_locale.ahk - moved into pkl_get_set.ahk
