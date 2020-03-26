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

;;  eD TOFIX/WIP:
;		- 
;		- WIP: Similar codes in layout.ini as in PKL Settings.ini for @K (and @C@E) ?
;			- Use a KbdType entry in the (base)layout.ini file too, and a @K syntax? That'd make the files easier to maintain for ANS/ISO. Use another char than @ since it's common in layouts? § maybe?
;			- The HIG should read the KbdType from layout.ini instead of the EPKL_Layouts file.
;			- Maybe layout files could have (in their information section?) all the layout info? So that the Settings mainly point to a file and the LayStack actually sets the KbdType/ErgoMod/etc where needed?
;		- Send help image on/off at startup? Could fix both the rogue Co icon window on first minimize, and the non-image if not present at first issues?
;		- Rework the modifier Up/Down routine? A function pklSetMods( set = 0, mods = [ "mod1", "mod2", ... (can be just "all")], side = [ "L", "R" ] ) could be nice? pkl_keypress, pkl_deadkey, in pkl_utility
;		- TOFIX: {Ext+S,<key>} rapidly sends a kaomoji. After this, Shift is stuck. Same with {Ext+T}! Is this the solution to the stuck Ctrl riddle?!? Unrelated to Sticky Mods.
;			- It doesn't happen with an Ext Mod mapping, but with MoDK and ToM Ext
;			- Key History: Looks like the mod is released but then re-presssed? Why?
;			- The rapidly pressed key interrupts the Extend routine, so the mod Up is never sent.
;		- TOFIX: AltGr+Spc, in Messenger at least, sends Home or something that jumps to the start of the line?! The first time only, and then normal Space? Related to the NBSP mapping.
;		- TOFIX: LCtrl gets stuck when using AltGr (typically for me, typing 'å'), and the timer can't release it because it's "physically" down.
;			- Tried diagnosing it with Key History. LCtrl is down both in GetKeyState( now ) and Hook's Logical/Physical states.
;		- TOFIX: First Extend after a refresh is slow, won't always take until the second key press. Prepare it somehow?
;		- TOFIX: If starting without Help Image, showing it later doesn't work
;		- TOFIX: On the first help img minimizing, a taskbar icon sometimes appears on-screen or in tray. Showing the image once before resizing solved it... not...
;		- TOFIX: DK+DK releases both versions of the base glyphs. Is this desirable?
;		- TOFIX: Remapping to LAlt doesn't quite work? Should we make it recognizeable as a modifier? Trying 'SC038 = LAlt VK' also disabled Extend?
;		- WIP: Maintenance timer every 2-3 s or so
;			- Check if no keys are held and no sticky timers counting, then send Up for those that aren't in use. If checking for inactivity first, it's easier.
;			- Update the OS dead keys etc as necessary.
;			- Replace activityPing() etc with A_TimeIdlePhysical in the maintenance loop? Or put it in the Janitor! The activityTimer goes every 20 s now.
;			- Combine w/ other housekeeping...?
;			- Clear out the old inactivity timer stuff and all its refreshes, and replace it with a check in the new maintenance timer. Make sure to check for both keys and mouse?
;		- WIP: Mother-of-DKs (MoDK), e.g., on Extend tap! Near endless possibilities, especially if dead keys can chain.
;			- Since these extra DKs won't show up in the normal layout, for now make a list of extra DKs for the HIG? Or, the HIG should use a DK list now instead of registering!
;			- Made the "onlyOneDK" of HIG settings into a CSV list so we can render a subset of DKs at will.
;			- MoDK plan: Tap Ext for DK layer (e.g., {Ext,a,e} for e acute – é?). But how best to organize them? Mnemonically is easily remembered but not so ergonomic.
;		- WIP: Dual-role modifiers. Allow home row modifiers like for instance Dusty from Discord uses: ARST and OIEN can be Alt/Win/Shift/Ctrl when held. Define both KeyDn/Up.
;			- In EPKL_Settings.ini, set a tapOrModTapTime. In layout, use SC### = VK/ModName first entries. The key works normally when tapped, and the Mod is stored separately.
;			- Redefine the dual-role Extend key as a generic tapOrMod key. Treating Extend fully as a mod, it can also be ToM (or sticky?).
;			- TOFIX: ToM-tap gets transposed when typing fast, the key is sluggish. But if the tap time is set too low, the key can't be tapped instead.
;				- To fix this, registered interruption. So if something is hit before the mod timer the ToM tap is handled immediately.
;				- However, Spc isn't handled correctly!? It still gets transposed.
;			- Make a stack of active ToM keys? Ensuring that they get popped correctly. Nah...?
;			- Should I support multi-ToM or not? Maybe two, but would need another timer then like with OSM.
;;  eD TONEXT:
;		- TODO: Instead of CompactMode, allow the Layouts_Default (or _Override) to define a whole layout if desired. Specify LayType "Here" or suchlike?
;			- At any rate, all those mappings common to eD and VK layouts could just be in the Layouts_Default.ini file. That's all from the modifiers onwards.
;		- TODO: Mapping aliases for SC### codes. These are too technical for newcomers. Allow any Remap type like Co/QW/etc, e.g., CoTAB or Co_1 or CoRSH. Also QW_S (=Co_R) etc?
;			- Or the VK codes in PKL_Tables.ini (split off that table then)? But those vary greatly in length which is uglyish.
;			- Could detect Upper(SubStr(key,1,2)) != "SC" ) and remap if so. Must have entries like Co_A then. Or use Co_A_ to pad to 5 chars? But is, e.g., CoMN_ nice?
;			- DONE: Expanded the Co table to include the right-hand block, and made a QW counterpart for the QWERTY people.
;		- TODO: Dialog GUI to produce EPKL_Layouts_Override.ini and EPKL_Settings_Override.ini files.
;		- TODO: Replace today's handling of AltGr with an AltGr modifier. So you'd have to map typically RAlt = AltGr Modifier, but then all the song-and-dance of today would be gone.
;			- Note that we both need to handle the AltGr EPKL modifier and whether the OS layout has an AltGr key producing LCtrl+RAlt on a RAlt press.
;			- Also allow Sticky AltGr. Very nice since the AltGr mappings are usually one-shot.
;		- TODO: Make a matrix image template, and use it for the Curl variants w/o Angle. Maybe that could be a separate KbdType, but we also need ANS/ISO info for the VK conversions. ASM/ISM?
;		- TODO: Sensible aliases for OEM_# VK codes! They are confusing for the users. E.g., OEM_GR, OEM_CM, OEM_DT etc. This allows using one common BaseLayout.
;			- Must be ISO/ANSI aware then. Use the KbdType setting (default ANS) which may be moved to the layout.ini itself for robustness.
;			- Use a lookup table? In the Tables file?
;			- Or simply use the Co## KLM codes as with SC, but translate to VK? This seems more robust.
;		- TODO: Make the Help Img Generator aware of prefix notation. But limit entry length.
;		- Try out <one Shift>+<other Shift> = Caps? How to do that? Some kind of ToM, where the Shift is Shift when held but Caps when (Shift-)tapped?
;		- WIP: Import KLC. Use a layout header template.
;			- Could have a section of RegEx ccnversions with name tags in the template, which gets used and then cut out.
;			- Each such entry could have a tagName = ## SplitBy JoinBy <regex>
;				- Allow both RegExReplace and RegExMatch entries? The latter should use O) match objects?
;				-  The ## denotes how many numbered entries should be run on this string. This could have sublevels, like ##-##-##.
;				- SplitBy loops through elements of the string, recursively if subentries also split. Then it's rejoined with JoinBy (necessary, or just regex that?).
;				- Can we SplitBy words, like \nDEADKEY\t ?
;			- Then in the template there's something like $$tagName$$ where the result is to be inserted.
;			- For DK full names, the KEYNAME_DEAD entries could be converted (cut out ACCENT/SIGN, _ for spaces?, cut away parentheses, title case). Update my names accordingly?
;		- Make pklParseSend() work for DK chaining (one DK releases another)!
;			- Today, a special DK entry will set the PVDK (DK queue) to ""; to chain dead keys this should this happen for @ entries?
;			- Removing that isn't enough though? And actually, should a dk chaining start anew? So, replicate the state and effect of a normal layout DK press.
;			- Chaining DKs opens up for interesting possibilities, like a Mother-of-Dead-Keys key (MoDK)! Could that be on Extend-tap, possibly with a timeout? Or on Backspace?
;				- See Jaroslaw's MoDK topic in the Forum: https://forum.colemak.com/topic/2501-my-current-programming-symbols-layout/#p22527
;				- Placing all my DKs on MoDK sequences will fill up a layer. So maybe only the most interesting ones? But how to make it mnemonic?
;				- Example: Tap-dance {Ext,t,n} -> ñ; {Ext,a,A} -> Á; {Ext,0-9} IPA DKs.
;				- For good measure, could have different @MD# on different states of the same key! Wow. The ToM formalism should support this actually!
;		- Implement SGCaps, allowing Shift State +8 for a total of 16 possible states - or 4 more states than the current 4, disregarding Ctrl.
;			- The states themselves are already implemented? So what remains is a sensible switch. "St8|SGCap Modifier"? Can translate in _checkModName()
;			- This should be the ideal way of implementing mirrored typing? (On the Lenovo Thinkpad there's even a thumb PrtSc key that could serve as switch.)
;			- For fun, could make a mirror layout for playing the crazy game Textorcist: Typing with one hand, mirroring plus arrowing with the other!
;		- TOFIX: I messed up Gui Show for the images earlier, redoing it for each control with new img titles each time. Maybe now I could make transparent color work? No...?
;		- TOFIX: If a layout have fewer states (e.g., missing state2) the BaseLayout fills in empty mappings in the last state! Hard to help? Mark the states right in the layout.
;		- TODO: The key processing timers generate autorepeat? Is this desirable? It messes with the ToM keys? Change it so the hard down sends only down and not down/up keys?
;;  eD TODO:
;		- For Jap layout etc, allow dk tables in the main layout.ini as well as the dk file. Let layout.ini tables overwrite dk file ones. (Same with Extend mappings.)
;		- AHK2Exe update from AutoHotKey v1.1.26.1 to v1.1.30.03 (released April 5, 2019) or whatever is current now. 	;eD WIP: Problem w/ AltGr?
;			- New Text send mode for PowerStrings, if desired. Should handle line breaks without the brkMode setting.
;		- A proper Compose method, allowing IME-like behavior and much more?!
;			- This would allow "proper" Vietnamese, phonetic Kyrillic etc layouts instead of dead keys which work "the wrong way around".
;			- Must keep track of previous entries in a buffer then. Clear the buffer on special entries.
;			- To ensure it's fast, only check when the last typed glyph is the release glyph of a compose? E.g., you type a^ and the ^ triggers a search producing â.
;			- Ideally it should be able to take the same input format as Linux Compose more or less, so people we could import (parts of) its rich Compose tables.
;		- Could make the Japanese layout now, since dead keys support literals/ligatures!
;		- Hebrew layout. Eventually, Arabic too.
;		- Mirrored one-hand typing as Remap, Extend or other layer?
;			- For Extend, would need a separate Ext modifier for it? E.g., NumPad0 or Down for foot or right-arm switching. But is that too clunky?
;			- SGCaps could work, but would require each layout to have SGC mappings to allow mirroring then. And a separate SGC modifier.
;			- Layout switching is usually done by restarting EPKL which is too clunky. But if we could have a switch modifier that temporarily activates the next layout...?
;			- This would require preloading more than one layout which takes a bit of reworking. Possibly... Allow an alt-set of the remap only, remapping on the fly w/ a mod?
;			- Mirroring as a remap can now use minicycles of many two-key loops. For instance, |  QU |  SC /  MN |  SL | for two separate swaps.
;		- Settings GUI panels instead of editing EPKL_Settings and EPKL_Layout .ini files. It could generate an override file so the default one is untouched.
;		- A set of IPA dk, maybe on AltGr+Shift symbol keys? Could also be chained from a MoDK?
;		- Lose CompactMode, StartSuspended etc? They seem to clutter up the settings file and I don't think people actually use them? The LayStack can do CompactMode...
;;  eD ONHOLD:
;		- Shift sensitive multi-Extend? When mapping for the NumPad layer, it'd be nice to have $/¢, €/£ etc. This allows many more potential mappings! 4×4-level Extend?!
;			- In most cases though, that'd be useful mostly for releasing more different glyphs. This is better done with dead keys, as these avoid heavy chording.
;		- Idea: Repeat key!? Type a key and then any key to get a double letter. Implement as a dead key releasing aa for a etc. Doesn't have to be active by default.
;		- Do we need underlying vs wanted KbdType? I have an ISO board and want an ISO layout for it, but my MS layout is ANSI... (Likely, this won't happen to many...?)
;			- For now, I have a little hack that I hope doesn't bother anyone: The VK QWERTY ISO-AWide layout has its ANS2ISO remap commented out for my benefit.
;		- Allow escaped semicolons (`;) in iniRead?
;		- Remove the Layouts submenu? Make it optional by .ini?
;		- Greek polytonic accents? U1F00-1FFE for circumflex(perispomeni), grave(varia), macron, breve. Not in all fonts! Don't use oxia here, as it's equivalent to tonos?
;		- Extend lock? E.g., LShift+Mod2+Ext locks Ext2. Maybe too confusing. But for, say, protracted numeric entry it could be useful?
;		- Some kaomoji have non-rendering glyphs, particularly eyes. Kawaii (Messenger), Joy face, Donger (Discord on phone). Just document and leave it at that.
;		- Implement the ANS2ISO VKEY maps in all layouts to have only one full base layout? Or keep both? For now, keep both eD BaseLayout at least.
;			- ISO is a more international standard, but ANSI has more logical key names for the US-based Cmk[eD] layouts (e.g., OEM_MINUS/OEM_PLUS).
;		- Go back on the Paste Extend key vs Ext1/2? It's ugly and a bit illogical since the layers are otherwise positional. But I get confused using Ext+D for Ctrl+V.
;		- Allow assigning several keys as Extend Modifier?
;		- An EPKL sample layout.ini next to the original PKL one, to illustrate the diffs? Or, let the contents of the main README be enough?
;;  eD DONE:
;	- PKL[eD] v0.4.2: AHK v1.1; menu icons; array pdics (instead of HashTable); Unicode Send; UTF-8 compatible iniRead(); layered help images.
;	- PKL[eD] v0.4.3: Key remaps, allowing ergo and other mods to be played over a few existing base layouts.
;	- PKL[eD] v0.4.4: Help Image Generator that uses Inkscape to create a set of help images from the current layout.
;	- PKL[eD] v0.4.5: Common prefix-entry syntax for keypress/deadkey/extend. Allows, e.g., literal/deadkey release from Extend.
;	- PKL[eD] v0.4.6: The base layout can hold default settings. Layout entries are now any-whitespace delimited.
;	- PKL[eD] v0.4.7: Multi-Extend w/ 4 layers selectable by modifiers+Ext. Extend-tap-release. One-shot Extend layers.
;	- PKL[eD] v0.4.8: Sticky/One-shot modifiers. Tap the modifier(s), then within a certain time hit the key to modify. Prefix-entry syntax in PowerStrings too.
;	- EPKL v1.0.0: Name change to EPiKaL PKL. ./PKL_eD -> ./Files folder. Languages are now under Files.
;	- EPKL v1.1.0: Some layout format changes. Minor fixes/additions. And kaomoji!  d( ^◇^)b
;	- EPKL v1.1.1: Some format changes. Minor fixes/additions. Tap-or-Mod keys (WIP).
;	- EPKL v1.1.2: Multifunction Tap-or-Mod Extend with dead keys on tap. Janitor inactivity timer.
;	- EPKL v1.1.3: The LayStack, separating & overriding layout settings. Bugfixes. More kaomoji.
;	- EPKL v1.1.4α: (Re)mapping tweaks
;		- Remap cycles can consist of minicycles separated by slashes, like this: | a | b / c | d | e | to remap a-b and c-d-e separately.
;		- Instead of special '_ExtDV' remaps for Extend Ctrl+V to follow V under CurlDH, now prepend the mapSC_extend remap with 'V-B,'.
;		- Keys can now be disabled by '--' or VK mapped to themselves by VK(ey) as their first layout entry.
;		- Key state and dead key mappings can be disabled using '--' or '-1' entries. Thus an entry can be removed in the LayStack.
;		- Three Sym mod variants: Improving quote/apostrophe (Qu), Minus/hyphen (Mn) or both (QuMn). Choose between them in the Remap file.
;		- Added Dvorak layouts, with suitable Curl/Angle/Wide ergo mods. These are my suggestions and not "official" variants for now.



setPklInfo( "pklName", "EPiKaL Portable Keyboard Layout" ) 					; PKL[edition DreymaR] -> EPKL
setPklInfo( "pklVers", "1.1.4α" ) 											; EPKL Version (was PKL[eD] until v0.4.8)
setPklInfo( "pklComp", "DreymaR" ) 											; Compilation info, if used
setPklInfo( "pkl_URL", "https://github.com/DreymaR/BigBagKbdTrixPKL" ) 		; http://pkl.sourceforge.net/

SendMode Event
SetKeyDelay 3 												; The Send key delay wasn't set in PKL, defaulted to 10
SetBatchLines, -1
Process, Priority, , H 										; High process priority
Process, Priority, , R 										; Real-time process priority
SetWorkingDir, %A_ScriptDir%

; Global variables are largely replaced by the get/set info framework
setKeyInfo( "CurrNumOfDKs", 0 ) 				; How many dead keys were pressed 	(was 'CurrentDeadKeys')
setKeyInfo( "CurrNameOfDK", 0 ) 				; Current dead key's name 			(was 'CurrentDeadKeyName')
setKeyInfo( "CurrBaseKey_", 0 ) 				; Current base key 					(was 'CurrentBaseKey')
;setKeyInfo( "HotKeyBuffer", 0 ) 				; Hotkey buffer for pkl_keypress 	(was 'HotkeysBuffer')
setPklInfo( "File_PklSet", "EPKL_Settings"          ) 		; Used globally  		(was in 'pkl.ini')
setPklInfo( "File_PklLay", "EPKL_Layouts"           ) 		; Used globally  		(was in 'pkl.ini')
setPklInfo( "LayFileName", "layout.ini"             ) 		; --"--
setPklInfo( "File_PklDic", "Files\EPKL_Tables.ini"  ) 		; Info dictionary file, mostly from internal tables

arg = %1% ; Layout from command line parameter
initPklIni( arg ) 											; Read settings from pkl.ini (now PklSet and PklLay)
initLayIni() 												; Read settings from layout.ini and layout part files
activatePKL()
Return  	; end main

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
	processKeyPress(    SubStr( A_ThisHotkey, 2     ) ) 	; SubStr removes leading '*'
Return

keyReleased:			; *SC### UP
	activity_ping()
	Critical
	processKeyPress(    SubStr( A_ThisHotkey, 2, -3 ) ) 	; Also remove trailing ' UP'
Return

modifierDown:			; *SC###    (call fn as HKey to translate to VK name)
;	activity_ping()
	Critical
	setModifierState(   getVKey( SubStr( A_ThisHotkey, 2     ) ), 1 )
Return

modifierUp:
	activity_ping()
	Critical
	setModifierState(   getVKey( SubStr( A_ThisHotkey, 2, -3 ) ), 0 )
Return

tapOrModDown: 			; *SC###
	Critical
	setTapOrModState(   SubStr( A_ThisHotkey, 2     ), 1 )
Return

tapOrModUp:
	activity_ping()
	Critical
	setTapOrModState(   SubStr( A_ThisHotkey, 2, -3 ), 0 )
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
	activeLay   := getLayInfo( "active" ) 				; Layout code (path) of the active layout
	numLayouts  := getLayInfo( "numOfLayouts" ) 		; The number of listed layouts
	Loop % numLayouts {
		theLayout   := getLayInfo( "layout" . A_Index . "code", theCode )
		actLayNum   := ( theLayout == activeLay ) ? A_Index : actLayNum
	}
	changeLayout( "UseLayPos_" . actLayNum ) 			; Rerun the same layout, telling pkl_init to use position.
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

epklDebugWIP:
	pklDebug( "Running WIP routine specified in PKL_main", 1 )
	importLayouts() 									; eD WIP/DEBUG: This entry is activated by the Debug hotkey
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
#Include pkl_import.ahk 	; Import module, converting MSKLC layouts to EPKL format
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
