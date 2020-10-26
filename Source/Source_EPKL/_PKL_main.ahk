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
;;  EPiKaL PKL - EPKL
;;  Portable Keyboard Layout by Farkas Máté   [https://github.com/Portable-Keyboard-Layout]
;;  edition DreymaR (Øystein B Gadmar, 2015-) [https://github.com/DreymaR/BigBagKbdTrixPKL]
;;

;;  eD TOFIX/WIP:
;		- 
;		- WIP: Transition to Cmk-DH(m) as the standard? Oh my... Do it in remaps, so the layout files use the same DH names as now. Rework images. Make new DK images too (they need an update anyway).
;			- Keep the old state6:7 Curl images in folders, in case someone wants to keep using them.
;			- Also check that the 6-on-the-left Wide mod is used for row-staggered boards and 6-on-the-right for matrix. I have no images with it, but in the files maybe? No, no Wide modded matrix boards.
;		- 
;		- TOFIX: Ext-Shift after rework sometimes doesn't take? How to reproduce?
;		- WIP: Multi-BaseLayout stack! Use for, e.g., Ru/Bg.
;		- TOFIX: After reworking the Ext-mods, spamming modded Ext presses leads to a stuckness of some kind. Afterwards, Extend is wonky.
;			- Make it so that if the hotkey queue overflows it's reset and you lose, say, the last 10 keys in it? Maybe that's actually safer?
;		- TODO: GUI layout settings panel. Use a 'layGUI =' setting that overrides any 'layout =' ones.
;			- Write a layGUI = ... line with the settings from the GUI directly below [pkl], skirting the @# shortcuts. If such a line is present, overwrite it. Date tag in a comment, and explain in a ';;  ' comment before.
;			- For the layGUI line, use the existing Layout_Override file if present, or create one.
;		- Add @M for MainLay? Colemak, Tarmak, Dvorak, QWERTY (,QUARTZ). Make sure it can look for both @M-@T and @M folders.
;			- Use a table in Tables like shortLays = Colemak/Cmk, Dvorak/Dvk, Tarmak/Tm# etc. As a default if not found, use the three first letters.
;			- Use a CSV format for Tarmak,1 = Tm1 thus replacing Tm# with Tm1 etc.? Too clunky maybe, and won't cover having multiple Tarmak layouts selected.
;			- Maybe instead reorganize a bit, making Colemak-eD/VK subdirs under Colemak?
;		-
;		- TOFIX: The ToM MoDK Ext doesn't always take when tapped quickly. Say I have period on {Ext-tap,i}. I'll sometimes get i and/or a space instead.
;			- Seems that {tap-Ext,i} very fast doesn't take (producing i or nothing instead of ing)? Unrelated to the ToM term.
;		- WIP: Use CurlMod = DH instead of Curl? It's shorter, more in touch with what people use etc. Then, maybe call the layouts, e.g., 'Cmk-eD_ANS_DH-AWide' instead of CurlAWide. Or just DHAWide?
;			- Or make names more consistent? Like 4 letters per mod, Angl/CurlAnglWide/etc?
;			- Possibly... even eradicate the CurlMod altogether, only using ErgoMod for the whole thing? Is that better? After all, Curl/DH _is_ an ergo mod!
;		- WIP: Make @K a compound (ANS/ISO-Trad/Orth/Splt/etc)? ANS/ISO is needed for VK codes, and the form factor for images and layout subvariants. kbdType vs kbdForm?
;			- Or, keep everything in kdbType, and adjust the reading of it to use the first and second substring? Why though...?
;		- TODO: EPKL_Settings_Override, in preparation for GUI settings. Make the settings file a [ Override, Default ] couplet like the Layouts files.
;		- TOFIX: Mapping a key to a modifier makes it one-shot?!
;		- TOFIX: -- remap mapping settings in layout.ini fail.
;		- TOFIX: The kaomoji DK image doesn't appear most of the time, instead the Extend image is shown. (The kaomoji still work.)
;		- WIP/TOFIX: Redo the AltGr implementation.
;			- Make a mapping for LCtrl & RAlt, with the layout alias AltGr?! That'd pick up the OS AltGr, and we can then do what we like with it.
;			- Treat EPKL AltGr as a normal mod, just that it sends <^>! - shouldn't that work? Maybe an alias mapping AltGr = <^>!
;		- TOFIX: AltGr+Spc, in Messenger at least, sends Home or something that jumps to the start of the line?! The first time only, and then normal Space? Related to the NBSP mapping.
;		- TOFIX: LCtrl gets stuck when using AltGr (typically for me, typing 'å'), and the timer can't release it because it's "physically" down.
;			- Tried diagnosing it with Key History. LCtrl is down both in GetKeyState( now ) and Hook's Logical/Physical states.
;			- Maybe it's solved with the new Ext-mod implementation?
;		- TOFIX: First Extend after a refresh is slow, won't always take until the second key press. Prepare it somehow? Also, Ext+T+<key> after refresh sends only Ext+<key>?
;		- TOFIX: Remapping to LAlt doesn't quite work? Should we make it recognizeable as a modifier? Trying 'SC038 = LAlt VK' also disabled Extend?
;		- WIP: Rework the modifier Up/Down routine? A function pklSetMods( set = 0, mods = [ "mod1", "mod2", ... (can be just "all")], side = [ "L", "R" ] ) could be nice? pkl_keypress, pkl_deadkey, in pkl_utility
;		- WIP: Maintenance timer every 2-3 s or so
;			- Check if no keys are held and no sticky timers counting, then send Up for those that aren't in use. If checking for inactivity first, it's easier.
;			- Update the OS dead keys etc as necessary.
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
;		- TODO: Since no hotkeys are set for normal key Up, Ext release and Ext mod release won't be registered? Should this be remedied?
;		- Mod ensemple: For lr in [ "", "L", "R" ], For mod in [ "Shift", "Ctrl", "Alt", "Win" ] ? May not always need the empties? Also add [ "CapsLock", "Extend", "SGCaps" ] ?
;		- TODO: Rewrite the Tarmak layouts with remaps instead of explicit mappings. As of today, Extend isn't remapped correctly for all CurlAngle steps.
;		- TODO: Allow the user to choose which monitor to display help images on? If you have a second monitor it may be less crowded and thus ideal for the help image. But how?
;		- TOFIX: Does BaseLayout require an absolute path? Why?
;		- TOFIX: DK+DK releases both versions of the base glyphs. Is this desirable?
;		- TODO: Replace today's handling of AltGr with an AltGr modifier. So you'd have to map typically RAlt = AltGr Modifier, but then all the song-and-dance of today would be gone.
;			- Note that we both need to handle the AltGr EPKL modifier and whether the OS layout has an AltGr key producing LCtrl+RAlt on a RAlt press.
;			- Also allow ToM/Sticky AltGr. Very very nice since AltGr mappings are usually one-shot.
;			- Define a separate AHK hotkey for LCtrl+RAlt (=AltGr in Windows)? That might make things simpler.
;		- TODO: VK mappings don't happen on normal keys. Simple VK code states don't get translated to VK##. Only used when the key is VK mapped.
;		- TODO: Make EPKL work with the .exe outside a .zip file? So you could download the release .zip, put the .exe outside, change then rezip any settings you want to, then the .exe will use the archive.
;			- This may be desirable for people running EPKL from an URL. It's easier to handle two files than several folders.
;		- TODO: Instead of CompactMode, allow the Layouts_Default (or _Override) to define a whole layout if desired. Specify LayType "Here" or suchlike?
;			- At any rate, all those mappings common to eD and VK layouts could just be in the Layouts_Default.ini file. That's all from the modifiers onwards.
;		- TODO: Dialog GUI to produce EPKL_Layouts_Override.ini and EPKL_Settings_Override.ini files.
;		- TODO: Make a matrix image template, and use it for the Curl variants w/o Angle. Maybe that could be a separate KbdType, but we also need ANS/ISO info for the VK conversions. ASM/ISM?
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
;		- TODO: A help fn to make layout images? Make the image large and opaque, then make a screenshot w/ GIMP and crop it. Or can I use the Windows Snipping Tool (Win+Shift+S)?
;		- Settings GUI panels instead of editing EPKL_Settings and EPKL_Layout .ini files. It could generate an override file so the default one is untouched.
;			- First one out: Layout selector? A set of choice panels, every time checking against a list of which layouts are present. Read in the list when a folder like Colemak-eD is chosen.
;		- Allow a BaseLayout stack, Base1,Base2,... ? Then for instance Cmk-Ru could base itself on the Cmk-eD BaseLayout and Cmk-Ru-CAW on Cmk-Ru w/ remaps.
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
;		- A set of IPA dk, maybe on AltGr+Shift symbol keys? Could also be chained from a MoDK?
;		- Lose CompactMode from the Settings file. The LayStack should do it.
;			- Instead of a setting in Settings, allow all of the layout to reside in EPKL_Layouts_Default (or Override). If detected, use root images if available.
;			- If no layout.ini is found, give a short Debug message on startup explaining that the root level default/override layout, if defined, will be used. Or just do it?
;;  eD ONHOLD:
;		- Hardcode Tab instead of using &Tab after all? It's consistent to have both the whitespace characters Spc & Tab hardcoded this way.
;		- A dynamic key press indicator for the help images? Showing not just the modifier layer but every press. Will it be fast enough? Would need a position table for each KbdForm.
;		- Make a Setting for which fn to run as Debug, so I don't have to recompile to switch debug fn()? Maybe overmuch, as the debug fn often needs recompiling anyway?
;		- Allow Remaps to use @K so that the layouts don't have to?!? Too confusing?
;		- Remove all the CtrlAltIsAltGr stuff? If laptops don't have RAlt (>!), they can just map a key to AltGr Mod instead? Won't allow using <^<! as AltGr (<^>!) though...
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
;		- Auto language detection doesn't follow keyboard setup but system language. If you use a Non-English keyboard but Windows uses English, the auto language is English.
;;  eD DONE:
;	* PKL[eD] v0.4.2: AHK v1.1; menu icons; array pdics (instead of HashTable); Unicode Send; UTF-8 compatible iniRead(); layered help images.
;	* PKL[eD] v0.4.3: Key remaps, allowing ergo and other mods to be played over a few existing base layouts.
;	* PKL[eD] v0.4.4: Help Image Generator that uses Inkscape to create a set of help images from the current layout.
;	* PKL[eD] v0.4.5: Common prefix-entry syntax for keypress/deadkey/extend. Allows, e.g., literal/deadkey release from Extend.
;	* PKL[eD] v0.4.6: The base layout can hold default settings. Layout entries are now any-whitespace delimited.
;	* PKL[eD] v0.4.7: Multi-Extend w/ 4 layers selectable by modifiers+Ext. Extend-tap-release. One-shot Extend layers.
;	* PKL[eD] v0.4.8: Sticky/One-shot modifiers. Tap the modifier(s), then within a certain time hit the key to modify. Prefix-entry syntax in PowerStrings too.
;	* EPKL v1.0.0: Name change to EPiKaL PKL. ./PKL_eD -> ./Files folder. Languages are now under Files.
;	* EPKL v1.1.0: Some layout format changes. Minor fixes/additions. And kaomoji!  d( ^◇^)b
;	* EPKL v1.1.1: Some format changes. Minor fixes/additions. Tap-or-Mod keys (WIP).
;	* EPKL v1.1.2: Multifunction Tap-or-Mod Extend with dead keys on tap. Janitor inactivity timer.
;	* EPKL v1.1.3: The LayStack, separating & overriding layout settings. Bugfixes. More kaomoji.
;	* EPKL v1.1.4: Sym mod and Dvorak layouts. HIG updated for new Inkscape. Unified VK codes for layouts. Mapping/setting tweaks.
;	* EPKL v1.1.5: Tarmak Curl(DHm) w/ ortho images. Suspending apps. Language tweaks, fixes.
;	* EPKL v1.1.6: KLM scan codes. EPKL For Dummies. Extend fixes. AltGr layouts for Es/It locales.
;		- Like VK codes, SC### scan codes in layouts & Extend can be replaced by the KLM Co or QW codes found in the Remap file. These are more intuitive and user friendly.
;			- For VK entries, vc### is a synonym for the QW### KLM code. I felt that it makes sense to distinguish between SC and VK this way.
;		- Added a link to the useful "EPKL For Dummies!" guide by Torben Gundtofte-Bruun in the README. Also some images and text updates, and a new README for the Files.
;		- Fixed: The first Tap-or-Mod Extend key press didn't take if within the ToM timer term. An initializing call to setExtendInfo() solved the problem.
;		- Fixed: Shift+Spc didn't send a shifted space, which should scroll up in most browser windows. Now, Spc is sent Blind.
;		- Fixed: Extend mods such as `{Ext+S} = Shift` pressed quickly w/ ToM Ext often led to stuck mods. Now they're only depressed/released for each Extended key press.
;		- Replaced some Loop Parse commands with more modern For loops, and made pklIniSect() return a row array for For loops. Let pklIniCSVs() take a specified separator.
;		- Added EsAlt and ItAlt for users who prefer AltGr to DKs. Es/It have áéíóú/àèìòù on AltGr+aoeiu, and some tweaks to fit in other symbols. Es_ANS has ñ on AltGr+n.
;		- Made the German and Scandinavian (De, DkNo & FiSe) Pan-Germanic, with easier access to each others' letters (De has ÆØÅ on AltGr+AOU; DkNo has ÄÖÜ etc).
;		- Tweaked a few AltGr mappings in the Vi and Hu laoyuts to better take care of lost symbol mappings.
;		- Added a setting that makes HIG delete its temporary files dir after generation. The options are 0=no, 1=paperbin, 2=delete.


setPklInfo( "pklName", "EPiKaL Portable Keyboard Layout" ) 					; PKL[edition DreymaR] -> EPKL
setPklInfo( "pklVers", "1.1.6" ) 											; EPKL Version (was PKL[eD] until v0.4.8)
setPklInfo( "pklComp", "DreymaR" ) 											; Compilation info, if used
setPklInfo( "pkl_URL", "https://github.com/DreymaR/BigBagKbdTrixPKL" ) 		; http://pkl.sourceforge.net/

SendMode Event
SetKeyDelay 3 												; The Send key delay wasn't set in PKL, defaulted to 10
SetBatchLines, -1
Process, Priority, , H 										; High process priority
Process, Priority, , R 										; Real-time process priority
SetWorkingDir, %A_ScriptDir%

; Global variables are largely replaced by the get/set info framework
	global PklHotKeyBuffer 						; Keeps track of the buffer of up to 30 pressesd keys in ###KeyPress() fns
;	global UIsel 								; Variable for UI selection (use Control names to see which one) 	; eD WIP
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
	pklDebug( "Gotcha, AltGr!", 0.5 )
Return
;LControl & RAlt::Send {RAlt Down} 	; This alone gets AltGr stuck
;LControl Up & RAlt Up::Send {RAlt Up} 	; This doesn't work!?

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
	Critical
	processKeyPress(    SubStr( A_ThisHotkey, 2     ) ) 	; SubStr removes leading '*'
Return

keyReleased:			; *SC### UP
	Critical
	processKeyPress(    SubStr( A_ThisHotkey, 2, -3 ) ) 	; Also remove trailing ' UP'
Return

modifierDown:			; *SC###    (call fn as HKey to translate to VK name)
	Critical
	setModifierState(   getVKey( SubStr( A_ThisHotkey, 2     ) ), 1 )
Return

modifierUp:
	Critical
	setModifierState(   getVKey( SubStr( A_ThisHotkey, 2, -3 ) ), 0 )
Return

tapOrModDown: 			; *SC###
	Critical
	setTapOrModState(   SubStr( A_ThisHotkey, 2     ), 1 )
Return

tapOrModUp:
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

opaqHelpImage:
	pkl_showHelpImage( 7 )
Return

changeActiveLayout:
	changeLayout( getLayInfo( "NextLayout" ) )
Return

rerunWithSameLayout:	; eD: Use the layout number instead of its code, to reflect any PKL Settings list changes
	activeLay   := getLayInfo( "ActiveLay" ) 			; Layout code (path) of the active layout
	numLayouts  := getLayInfo( "NumOfLayouts" ) 		; The number of listed layouts
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

suspendOn:
	Suspend, On
	goto afterSuspend
Return

suspendOff:
	Suspend, Off
	goto afterSuspend
Return

suspendToggle:
	Suspend
	goto afterSuspend
Return

afterSuspend:
	if ( A_IsSuspended ) {
		pkl_showHelpImage( 3 )
		Menu, Tray, Icon, % getLayInfo( "Ico_OffFile" ), % getLayInfo( "Ico_OffNum_" )
	} else {
		pkl_showHelpImage( 4 )
		Menu, Tray, Icon, % getLayInfo( "Ico_On_File" ), % getLayInfo( "Ico_On_Num_" )
	}
Return

getWinInfo:
	getWinInfo() 										; Show the active window's title/process(exe)/class
Return

epklDebugWIP:
;	pklDebug( "Running experimental/WIP routine`n(specified in _PKL_main)", .8 )
	pklSetUI() 											; eD WIP/DEBUG: This entry is activated by the Debug hotkey
;	importLayouts() 									; eD WIP/DEBUG: This entry is activated by the Debug hotkey
Return

; ####################### functions #######################

#Include pkl_init.ahk
#Include pkl_gui_image.ahk	; pkl_gui was too long; it's been split into help image and menu/about parts
#Include pkl_gui_menu.ahk
#Include pkl_gui_settings.ahk
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
