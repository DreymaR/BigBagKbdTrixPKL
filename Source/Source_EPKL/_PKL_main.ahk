;
;;  EPiKaL PKL - EPKL
;;  Portable Keyboard Layout by Farkas Máté   [https://github.com/Portable-Keyboard-Layout]
;;  edition DreymaR (Øystein B Gadmar, 2015-) [https://github.com/DreymaR/BigBagKbdTrixPKL]
;

;;  ####################### user area #######################
;;  eD TOFIX: Can't define hotkeys/-strings here, as it prevents EPKL from working! Where, then?
; :*:'3o::https://www.colemak.org 	; eD WIP: Hotstring (replace text with other)
; #c::MsgBox % "EPKL hotkey test:`n'" . A_ThisHotkey . "'"

;;  eD TOFIX/WIP:
;		- WIP: 

;		- WIP: Can we have a separate user working dir, so users have their settings elsewhere? Very nice idea!
;			- https://github.com/DreymaR/BigBagKbdTrixPKL/issues/34
;			- Make and look for overrides in the working dir, and defaults in the script dir.
;			- Add a syntax or setting that lets the user specify using a layout dir (and BaseLayout?) in the working dir. Or just look for it there first, if different?
;				- `User\` could point to working dir, and `.\` continue to point to script dir? Need to make all file-reading operations aware of this!?
;			- Might use a switch of working dir for some operations? Or, should things like the HIG just assume working dir and anyone wishing to use it must adjust?
;				- This would make sense, in letting a user set individual settings in their working dir and getting images there too.

;		- TODO: Allow a BaseLayout stack: Variant,Options/Script,Base... ?
;			- Make BaseVariants so we don't have to repeat ourselves for locales. The layout.ini could just hold the ergo remaps.
;			- The Cmk-Kyr BaseLayout could for instance base itself on the Cmk-eD BaseLayout and then Cmk-Ru-CAWS on Cmk-Kyr w/ remaps; Bg with its own variant.
;			- Guard against infinite recursion. Limit LayStack depth to a few more layers? Two more could be nice, for instance one locale plus one with extra composes?
;			- Figure out a way to sort out the img_ entries too, without manually editing all of them? Soft/hard? Extend(@X)/Geometric(@H)?

;		- WIP: Implement SGCaps, allowing Shift State +8 for a total of 16 possible states - in effect 4 more states than the current 4, disregarding Ctrl.
;			- Kindly sponsored by Rasta at the Colemak Discord!
;			- The states themselves are already implemented? So what remains is a sensible switch. "Lvl8|SGCap Modifier"? Can translate in _checkModName()
;			- May have to clean up the state calculation in _keyPressed()
;			- This should be the ideal way of implementing mirrored typing? (On the Lenovo Thinkpad there's even a thumb PrtSc/SC137 key that could serve as switch.)
;			- For fun, could make a mirror layout for playing the crazy game Textorcist: Typing with one hand, mirroring plus arrowing with the other!
;			- Make a lock variant of the modifier

;		- WIP: Since I can now read Compose tables case sensitive, do the same for DKs? Then scrap the silly `<K>+`-type DK entry syntax, but keep <#> syntax?
;			- Read in all DK tables in use at startup instead of each entry as needed then? Faster use, slower startup, more memory usage. Acceptable?

;		- WIP: Instead of doing the atKbdType() this-and-that routine, make a fn to interpret all @ codes and add it as a switch for pklIniRead()?
;			- This allows the use of more @ codes in the LayStack files

;		- WIP: "Add Layout" functionality in GUI.
;			- Use the ComboBox functionality, that lets you have a DDL with a manually editable field on top.
;			- Use an Add button? The button adds layout, line becomes <lay1>, then add is grayed out until something's changed. Could I avoid an extra button?
;			- Or... a cheeky Join button that uses RegExReplace to merge the topmost two GUI override entries?! Too risky and error-prone for newbs.

;		- WIP: In the Janitor timer: Update the OS dead keys and OEM VKs as necessary. Register current LID and check for changes.
;		- TOFIX: The detectCurrentWinLayVKs() fn is doing something wrong now? Trying to use the whole SCVKdic produces lots of strange entries...?
;		- TOFIX: Need to SC remap the OEMdic or layouts with ergo remaps will get it wrong. Example: Ctrl+Z on Angle stopped working when remapping QW_LG VK by SC.
;			- In pkl_init, make a pdic[SC] = VK where SC is the remapped SC codes for the OEM keys, and VK what VK they're mapped to (or -1 if VKey mapped)
;			- And/or a VK(ANSI)-to-VK(OS-layout) remap pdic?
;			- Just detect every single VK code from the OS layout: It'd fix all our VK troubles, and account for such things as my CAWS OS layout.
;		- TOFIX: System layout is faulty? OEMs are wrong.
;			- If I get it working, add a section to the README with "I don't want Colemak"? For people who just want Extend on top of their OS layout

;		- WIP: Revisit the ISO key for several locale variants as the new Compose key is so powerful. Spanish? Probably not Scandi/German? Or?

;		- WIP: Make README.md for the main layout and layout variant folders, so they may be showcased on the GitHub site.
;			- This way, people may read, e.g., IndyRad/QI analysis on the GitHub page in Markdown rather than the unattractive comment format.
;			- Update correspondence between the Locale Forum topic and these pages: Link to EPKL in the topic, get info from the topic.

;		- WIP: Mother-of-DKs (MoDK), e.g., on Extend tap! Near endless possibilities, especially if dead keys can chain.
;			- MoDK idea: Tap Ext for chaining DK layer (e.g., {Ext,a,e} for e acute – é?). But how best to organize them? Mnemonically is not so ergonomic.

;		- WIP: Dual-role modifiers. Allow home row modifiers like for instance Dusty from Discord uses: ARST and OIEN can be Alt/Win/Shift/Ctrl when held. Define both KeyDn/Up.
;			- In the EPKL_Settings .ini, set a tapOrModTapTime. In layout, use SC### = VK/ModName first entries. The key works normally when tapped, and the Mod is stored separately.
;			- Redefine the dual-role Extend key as a generic tapOrMod key. Treating Extend fully as a mod, it can also be ToM (or sticky?).
;			- TOFIX: ToM-tap gets transposed when typing fast, the key is sluggish. But if the tap time is set too low, the key can't be tapped instead.
;				- To fix this, registered interruption. So if something is hit before the mod timer the ToM tap is handled immediately.
;				- However, Spc isn't handled correctly!? It still gets transposed.
;			- Make a stack of active ToM keys? Ensuring that they get popped correctly. Nah...?
;			- Should I support multi-ToM or not? Maybe two, but would need another timer then like with OSM.

;		- TOFIX: Help images show 3–4× at startup with a slightly longer Sleep to hopefully avoid a minimize-to-taskbar bug on the first hide image.
;			- It still doesn't work as it should, but the problem is hard to reproduce.
;		- TOFIX: Looks like there are multiple EPKL instances in the Tray now? Is that true? Can it be GUI windows? Refresh related?
;		- TOFIX: Ext-Shift often gets stuck until Ext is released. Not sure exactly how.
;		- TOFIX: Help images for Colemak-Mirror don't show the apostrophe on AltGr even though it's functional and defined equivalently to the base state one.
;			- Debug on 6_BS doesn't show any differences; looks like &quot; is still generated.
;		- FIXED: Removed pressing LCtrl for AltGr (as in pkl_keypress.ahk now!). And changed to {Text} send.
;			- Does it fix the problem with upgrading to a newer AHK version?!? No! LCtrl still gets stuck upon AltGr in AHK v1.1.28+.
;		- TOFIX: Update to newer AHK! v1.1.28.00 worked mostly but not for AltGr which sends Alt and gets Ctrl stuck. v1.1.27.07 works fully.
;			- AHK version history: "Optimised detection of AltGr on Unicode builds. This fixes a delay which occurred at startup (v1.1.27) or the first Send call (earlier)."
;			- After update past v1.1.28, we can use StrSplit() with MaxParts to allow layout variant names with hyphens in them!
;			- Should then be able to go to v1.1.30.03 right away, but check for v1.1.31? That version has added an actual switch command, though!!!
;		- TEST: Use the laptop PrtScr key for something? It's thumb accessible w/ the Wide mod. Corresponds to the Menu key on many other boards. Compose key!!!
;			- Try Alt as thumb-Ext, Caps as Alt? AltGr as Shift, PrtScr as AltGr?
;		- TEST: ToM Ctrl on a letter key? Shift may be too hard to get in flow, but Ctrl on some rare keys like Q or D/H would be much better than awkward pinky chording.
;			- It works well! But then after a while it stops working?
;		- TOFIX: Setting a hotkey to, e.g., <^<+6 (LeftCtrl & LeftShift & 6) doesn't work.
;		- TOFIX: If a DK is selected very fast, the AltGr DK state image may get stuck until release. This happened after adding the DK img refresh-once timer?
;			- Renamed any state6 DK images that contained only a base key release on Spc, to miminize this issue. DKs like Ogonek still have it.
;		- TOFIX: The ToM MoDK Ext doesn't always take when tapped quickly. Say I have period on {Ext-tap,i}. I'll sometimes get i and/or a space instead.
;			- Seems that {tap-Ext,i} very fast doesn't take (producing i or nothing instead of ing)? Unrelated to the ToM term.
;		- TOFIX: Mapping a key to a modifier makes it one-shot?!
;		- TOFIX: -- remap mapping settings in layout.ini fail.
;		- TOFIX: Redo the AltGr implementation.
;			- Make a mapping for LCtrl & RAlt, with the layout alias AltGr?! That'd pick up the OS AltGr, and we can then do what we like with it.
;			- Treat EPKL AltGr as a normal mod, just that it sends <^>! - shouldn't that work? Maybe an alias mapping AltGr = <^>!
;		- TOFIX: The NBSP mapping (AltGr+Spc), in Messenger at least, sends Home or something that jumps to the start of the line?! The first time only, and then normal Space?
;		- TOFIX: Remapping to LAlt doesn't quite work? Should we make it recognizeable as a modifier? Trying 'SC038 = LAlt VK' also disabled Extend?

;;  eD TONEXT:
;		- TODO: Make a "base compose output" that a Compose key releases whenever no sequence is recognized? Like the Basechar of a DK. Useful for locale layouts?
;		- TODO: UI Idea: Show the state0 (and state3 if available) image of the chosen layout, in the picker?! Preferably with the right background. 
;			- Possible to extract the pic from pkl_gui_image?
;		- TODO: Personal override files for extend, compose, powerstrings etc? One override file with sections? Some overrides (remaps, DKs) in layouts.
;		- TODO: Lose the ANS2ISO VKEY maps in all layouts and the Remap file since they're based on flawed logic?
;		- TODO: Rewrite the Tarmak layouts with remaps instead of explicit mappings. As of today, Extend isn't remapped correctly for all CurlAngle steps.
;		- TODO: Is the main README still too long? Put the layout tutorial in a Layouts README? Also make a tutorial for simply using the CkAWS remap or something.
;		- TODO: A Wide mod that supports the QI;x or CTGAP bottom-right-half-row. Where he has `_B _H SL PD CM`, make the Wide mod `SL _B _H PD` and move CM up.
;			- Or... Would that suck? It replaces the safe E-SL SFB with E-B which is much worse?
;		- TODO: Add QWERTZ and AZERTY layouts? There are now remaps for them, and the rest should be doable with OEM VK detection.
;		- TODO: Provide a swap-LAlt-n-Caps RegEdit script, and a reversal one. Maybe add some more codes in the comments, see my old RegEdit scripts.
;		- TODO: Harmonize Ext and folder mod names? And/or make a shorthand for the @E=@C@H@O battery in addition to @K in layout files? And also the short variant like CAW(S)?
;			- Could expand, e.g., CurlAWide to CurlAngleWide for the layout name only? Or use long names like CurlAWideSym consistently?
;			- Make long names more consistent? Like 4 letters per mod, CurlAnglWideSyms ? Nah, too anal. Better to keep with CurlAWideSym, and that's long enough really.
;			- Use CAngle or CA--, etc? CAngle is more intuitive, but CA more consistent with CAW(S). 
;		- TODO: Make a matrix image template, and use it for the Curl variants w/o Angle. 
;			- Maybe that should be a separate KbdType, but we also need ANS/ISO info for the VK conversions. ASM/ISM KbdTypes?
;		- TOFIX: I messed up Gui Show for the images earlier, redoing it for each control with new img titles each time. Maybe now I could make transparent color work? No...?
;		- TOFIX: If a layout have fewer states (e.g., missing state2) the BaseLayout fills in empty mappings in the last state! Hard to help? Mark the states right in the layout.
;		- TOFIX: Pressing a DK twice should release basechar1 (s1) but basechar0 (s0) is still released. Not sure why.

;;  eD TODO:
;		- TODO: Offer VK layouts based on the eD ones! Use only the state0/1 images then.
;			- Let the Layout Picker show VK if VK or other kinds are available. With the LayType setting, use a VK if the layout is present but if not, look for eD.
;			- Let the generated VK layout convert to VK in BaseLayout only! That way, we could have state mapped overrides in layout.ini, and thus locale VK variants!
;			- With this, we could reduce the number of folders and more or less duplicate files a lot.
;		- TODO: Color markings for keys in HIG images! Could have a layer of bold key overlays and mark the keys we want with colors through entries in the HIG settings file.
;			- markColors = #c00:_E/_N/_K, #990:_B/_T/_F, #009:_J     ; Tarmak2 colors
;			- markColors = <CSV of marking specs>, similar to the remaps. Could have Tarmak1,Tarmak2,Tarmak3,#009:_J ?
;			- See https://forum.colemak.com/topic/1858-learn-colemak-in-steps-with-the-tarmak-layouts/p4/#p23659
;			- Allow a section in layout.ini too!
;			- Mark differently by state, as in the Tarmak images
;		- TODO: Make state images and DK image dirs ISO/ANSI aware?! Generate both in the HIG each time. Make layouts that can handle both. 
;			- How to handle special mappings? Could have [layout_###] sections.
;		- TODO: I never use the SendMessage parse prefix. Cannibalize it for a strEsc() send? Or add that as €\ prefix instead?
;		- Mod ensemble: For lr in [ "", "L", "R" ], For mod in [ "Shift", "Ctrl", "Alt", "Win" ] ? May not always need the empties? Also add [ "CapsLock", "Extend", "SGCaps" ] ?
;		- TODO: Redo the @Ʃ_@Ç formalism, adding @K to @E(@C@H@O) by a hyphen instead of an underscore? Would that be a benefit in any way? Or just a lot of work?
;		- TODO: Hotstrings? May have to wait for AHK v1.1.28 to use the Hotstring() fn? Or is there somewhere in this script we could insert definitions?
;		- TODO: Consider a remap for each Ext layer? Would make things messier, but allows separate Ext1 and Ext2 maps, e.g., for the SL-BS switch.
;			- Allow mapSC_extend2 etc entries in the LayStack. If not specified, use the _extend one for all.
;		- TODO: Add ABNT keys to the HIG template?
;		- TODO: Record macro? Or just a way to set entries for a certain DK layer in the Settings UI? Say, the Ext-tap layer(s). Could have backup DK layers and a Reset button.
;		- TODO: Make EPKL able to hold more than one layout in memory at once?! This would make dual layouts smoother, and using layouts as layers (Greek, mirroring etc) possible.
;			- With SGCaps modifier layers, the need for this may be alleviated?
;		- TODO: Since no hotkeys are set for normal key Up, Ext release and Ext mod release won't be registered? Should this be remedied?
;		- TODO: Rework the modifier Up/Down routine? 
;			- A function pklSetMods( set = 0, mods = [ "mod1", "mod2", ... (can be just "all")], side = [ "L", "R" ] ) could be nice? pkl_keypress, pkl_deadkey, in pkl_utility
;		- TODO: Replace today's AltGr handling with an AltGr modifier. You'd have to map, e.g., RAlt = AltGr Modifier, but then all the song-and-dance of today would be gone.
;			- Note that we both need to handle the AltGr EPKL modifier and whether the OS layout has an AltGr key producing LCtrl+RAlt on a RAlt press.
;			- Also allow ToM/Sticky AltGr. Very very nice since AltGr mappings are usually one-shot.
;			- Define a separate AHK hotkey for LCtrl+RAlt (=AltGr in Windows)? That might make things simpler.
;		- TODO: VK mappings don't happen on normal keys. Simple VK code states don't get translated to VK##. Only used when the key is VK mapped.
;		- TODO: Instead of CompactMode, allow the Layouts_Default (or _Override) to define a whole layout if desired. Specify LayType "Here" or suchlike?
;			- At any rate, all those mappings common to eD and VK layouts could just be in the Layouts_Default.ini file. That's all from the modifiers onwards.
;		- TODO: Import KLC. Use a layout header template.
;			- Could have a section of RegEx conversions with name tags in the template, which gets used and then cut out.
;			- Each such entry could have a tagName = ## SplitBy JoinBy <regex>
;				- Allow both RegExReplace and RegExMatch entries? The latter should use O) match objects?
;				-  The ## denotes how many numbered entries should be run on this string. This could have sublevels, like ##-##-##.
;				- SplitBy loops through elements of the string, recursively if subentries also split. Then it's rejoined with JoinBy (necessary, or just regex that?).
;				- Can we SplitBy words, like \nDEADKEY\t ?
;			- Then in the template there's something like $$tagName$$ where the result is to be inserted.
;			- For DK full names, the KEYNAME_DEAD entries could be converted (cut out ACCENT/SIGN, _ for spaces?, cut away parentheses, title case). Update my names accordingly?
;			- In addition to MSKLC format, allow Aldo Gunsing's KLFC! https://github.com/39aldo39/klfc And maybe Keyboard Layout Editor's KLE (or do that via KLFC).
;		- TODO: Make pklParseSend() work for DK chaining (one DK releases another)!
;			- Today, a special DK entry will set the PVDK (DK queue) to ""; to chain dead keys this should this happen for @ entries?
;			- Removing that isn't enough though? And actually, should a dk chaining start anew? So, replicate the state and effect of a normal layout DK press.
;			- Chaining DKs opens up for interesting possibilities, like a Mother-of-Dead-Keys key (MoDK)! Could that be on Extend-tap, possibly with a timeout? Or on Backspace?
;				- See Jaroslaw's MoDK topic in the Forum: https://forum.colemak.com/topic/2501-my-current-programming-symbols-layout/#p22527
;				- Placing all my DKs on MoDK sequences will fill up a layer. So maybe only the most interesting ones? But how to make it mnemonic?
;				- Example: Tap-dance {Ext,t,n} -> ñ; {Ext,a,A} -> Á; {Ext,0-9} IPA DKs.
;				- For good measure, could have different DKs on different states of the same key! Wow. The ToM formalism should support this actually!
;		- TODO: With the Compose method, look into IME-like behavior?
;			- This would allow "proper" Vietnamese, phonetic Kyrillic etc layouts instead of dead keys which work "the wrong way around".
;			- Could make special compose keys for accents? E.g., you type a^ and the ^ key is a Compose key producing â.
;		- TODO: Make EPKL work with the .exe outside a .zip file? 
;			- You could then download the release .zip, put the .exe outside, change then rezip any settings you want to, then the .exe will use the archive.
;			- This may be desirable for people running EPKL from an URL. It's easier to handle two files than several folders.
;		- TODO: Try out <one Shift>+<other Shift> = Caps? How to do that? Some kind of ToM, where the Shift is Shift when held but Caps when (Shift-)tapped?
;		- TODO: The key processing timers generate autorepeat? Is this desirable? It messes with the ToM keys? Change it so the hard down sends only down and not down/up keys?
;		- TODO: Keylogging for gathering typing stats. Which stats? 1-2-3-grams, characters-before-backspace...
;		- TODO: A help fn to make layout images? Make the image large and opaque, then make a screenshot w/ GIMP and crop it. Or can I use the Windows Snipping Tool (Win+Shift+S)?
;		- TODO: AHK2Exe update from AutoHotKey v1.1.26.1 to v1.1.30.03 (released April 5, 2019) or whatever is current now. 	;eD WIP: Problem w/ AltGr?
;			- New Text send mode for PowerStrings, if desired. Should handle line breaks without the brkMode setting.
;		- TODO: Make the Japanese layout now, since dead keys support literals/ligatures and DK tables in layout.ini are possible.
;		- TODO: Hebrew layout. Eventually, Arabic too.
;		- TODO: Mirrored one-hand typing as Remap, Extend or other layer?
;			- For Extend, would need a separate Ext modifier for it? E.g., NumPad0 or Down for foot or right-arm switching. But is that too clunky?
;			- SGCaps could work, but would require each layout to have SGC mappings to allow mirroring then. And a separate SGC modifier.
;			- Layout switching is usually done by restarting EPKL which is too clunky. But if we could have a switch modifier that temporarily activates the next layout...?
;			- This would require preloading more than one layout which takes a bit of reworking. Possibly... Allow an alt-set of the remap only, remapping on the fly w/ a mod?
;			- Mirroring as a remap can now use minicycles of many two-key loops. For instance, |  QU |  SC /  MN |  SL | for two separate swaps.
;		- TODO: A set of IPA dk, maybe on AltGr+Shift symbol keys? Could also be chained from a MoDK?
;		- TODO: Lose CompactMode from the Settings file. The LayStack should do it.
;			- Instead of a setting in Settings, allow all of the layout to reside in EPKL_Layouts_Default (or Override). If detected, use root images if available.
;			- If no layout.ini is found, give a short Debug message on startup explaining that the root level default/override layout, if defined, will be used. Or just do it?

;;  eD ONHOLD:
;		- Try out a swap-side layout instead of the mirrored one? More strain on weak fingers, but fewer SFBs I should think.
;			- Is the brain equally good at side-swapping and mirroring?
;		- Make it so that if the hotkey queue overflows it's reset and you lose, say, the last 10 keys in it? Is that actually safer? No, don't think so?
;			- Need a way to count the hotkeys then, without spending much resources. The size of pklHotKeyBuffer should be an indication, as it's usually 'SC###¤' repeated.
;			- Only necessary to intervene on hotkey #31? Then stop the first 16 or so timers and flush the corresponding pklHotKeyBuffer entries.
;		- Make @K a compound (ANS/ISO-Trad/Orth/Splt/etc)? ANS/ISO is needed for VK codes, and the form factor for images and layout subvariants. kbdType vs kbdForm?
;			- Could keep everything in kbdType and adjust the reading of it to use the first and second substring.
;			- However, it may not be necessary at all. Using a kbdType like ANS-Orth seems to work just fine for now. The VK-related kbdType is in layout.ini anyway.
;		- Hardcode Tab instead of using &Tab after all? It's consistent to have both the whitespace characters Spc & Tab hardcoded this way.
;		- A dynamic key press indicator for help images, showing not just modifier layer but every press. Will it be fast enough? Needs a position table for each KbdForm.
;		- Make a Setting for which fn to run as Debug, so I don't have to recompile to switch debug fn()? Maybe overmuch, as the debug fn often needs recompiling anyway?
;		- Allow Remaps to use @K so that the layouts don't have to?!? Too confusing?
;		- Remove all the CtrlAltIsAltGr stuff? If laptops don't have RAlt (>!), they can just map a key to AltGr Mod instead? Won't allow using <^<! as AltGr (<^>!) though...
;		- Shift sensitive multi-Extend? When mapping for the NumPad layer, it'd be nice to have $/¢, €/£ etc. This allows many more potential mappings! 4×4-level Extend?!
;			- In most cases though, that'd be useful mostly for releasing more different glyphs. This is better done with dead keys, as these avoid heavy chording.
;		- Allow escaped semicolons (`;) in iniRead?
;		- Remove the Layouts submenu? Make it optional by .ini?
;		- Greek polytonic accents? U1F00-1FFE for circumflex(perispomeni), grave(varia), macron, breve. Not in all fonts! Don't use oxia here, as it's equivalent to tonos?
;		- Extend lock? E.g., LShift+Mod2+Ext locks Ext2. Maybe too confusing. But for, say, protracted numeric entry it could be useful?
;		- Some kaomoji have non-rendering glyphs, particularly eyes. Kawaii (Messenger), Joy face, Donger (Discord on phone). Just document and leave it at that.
;		- Go back on the Paste Extend key vs Ext1/2? It's ugly and a bit illogical since the layers are otherwise positional. But I get confused using Ext+D for Ctrl+V.
;		- Allow assigning several keys as Extend Modifier?
;		- An EPKL sample layout.ini next to the original PKL one, to illustrate the diffs? Or, let the contents of the main README be enough?
;		- Auto language detection doesn't follow keyboard setup but system language. If you use a Non-English keyboard but Windows uses English, the auto language is English.

;;  eD DONE:
;	* EPKL v1.0.0: Name change to EPiKaL PKL. ./PKL_eD -> ./Files folder. Languages are now under Files.
;	* EPKL v1.1.0: Some layout format changes. Minor fixes/additions. And kaomoji!  d( ^◇^)b
;	* EPKL v1.1.1: Some format changes. Minor fixes/additions. Tap-or-Mod keys (WIP).
;	* EPKL v1.1.2: Multifunction Tap-or-Mod Extend with dead keys on tap. Janitor inactivity timer.
;	* EPKL v1.1.3: The LayStack, separating & overriding layout settings. Bugfixes. More kaomoji.
;	* EPKL v1.1.4: Sym mod and Dvorak layouts. HIG updated for new Inkscape. Unified VK codes for layouts. Mapping/setting tweaks.
;	* EPKL v1.1.5: Tarmak Curl(DHm) w/ ortho images. Suspending apps. Language tweaks, fixes.
;	* EPKL v1.1.6: New Curl-DH standard! EPKL For Dummies. KLM key codes. Extend fixes. AltGr layouts for Es/It, and Pan-Germanic locale variants.
;	* EPKL v1.2.0: Layout/Settings UI.
;	* EPKL v1.3.0: Compose/Completion and Repeat keys.
;	* EPKL v1.3.1: Compose/Completion developments. Folder/file restructuring. Cmk Heb/Epo/BrPt/Nl variants, Ortho kbd types, Boo layout, Dvk-Sym.
;		- Prefix-syntax Repeat and Compose/Completion mappings. In addition to key states, you can now map Extend or DK mappings to ®®/®# or ©###.
;			- If mapping a ©### key to a DK release, it must be preloaded elsewhere. Map it to an unused state or Extend mapping to achieve this.
;		- Mapping a state to `®#` where # is a hex number will repeat the previous key # times. This is affected by modifiers, but not sticky ones.
;		- The Repeat key now resends the last character, not the last key. Repeat used to be affected by modifiers and prone to errors.
;		- Single-char Compose output is pushed to the LastKeys queue, thereby allowing some compose chaining. Example: `g'a` → `α` then `'` → `ά`.
;		- Composing `U####[#]` where `#` are hex digits, sends the corresponding Unicode character
;		- Compose table entries in the LayStack files override those in the Compose file. Use sections for existing tables like `[compose_adding]`.
;	
;		- Remapped dead key combining accents to `© ø Ø` to account for the Compose key taking the place of `œ` in many cases, and NBSP being iffy.
;		- Tidied up the Tarmak folders with icon and Extend image links to a `_Res` folder instead of local files
;		- The img_HideStates setting can hide the `ext` layer image too, and even DK shift states specified as `dk#`; # is a shift state (0,1,6,7).
;		- The BaseLayout setting in layout.ini can now take a `..\` syntax.
;		- Added ANS-Orth/ISO-Orth Colemak-eD. Images are still row-staggered, but this should clarify which ergo mods are for which board types.
;			- The bracket-lift Sym mod (Sym-Br) looks better on ortho boards than the standard (Sym-LBr). Images were made for both mod variants.
;		- Suspend by layout Locale ID. Should make EPKL work better for users of IMEs such as Korean, as they may conflict with non-QWERTY layouts.
;			- The suspendingLIDs setting uses 4-xdigit LID codes as found in the About... menu. Use the Locale ID, not the Language one.
;		- An `--` entry allows disabling EPKL hotkeys in the `EPKL_Settings_Override` file. Earlier, you'd have to use an unused key like `Sleep`.
;		- Added homing-nubbed help image ModState overlays. For now, there's a "GreenBlob" set for non-Wide and Wide homing, some with FShui colors.
;			- Usage: In layout.ini, change the `img_ModsDir = Files\ImgModStates\GrnBlob` setting by appending `-HomeNubs[Wide][-FShui]`.
;		- Allowed links for layout images, so layouts that use the same images as others don't need to keep their own copies.
;		- Made DK images in a local `DeadkeyImg` dir work with the ones set in `img_DKeyDir`. This also alleviates the need to declare a DeadkeyImg dir.
;	
;		- Added the Boo (Dvorak-like modern) layout.
;		- Added a Programmer Dvorak Symbol mod, affecting the Number row plus remapping <kbd>]}</kbd> → <kbd>@^</kbd> and swapping <kbd>'"</kbd> ↔ <kbd>;:</kbd>.
;			- Disclaimer: This is a Dvorak Sym mod inspired by the Programmer Dvorak layout by Roland Kaufmann. It does not claim to be that layout.
;		- For the Nl locale, the ISO key was reclaimed as Compose! Kept <kbd>ij</kbd> on the images. Note that composing ij/IJ makes the ĳ/Ĳ ligature.
;			-  Also, a Compose completion was added so that <kbd>i</kbd>,<kbd>©</kbd> → `ij`.
;		- Esperanto variant, based on Compose. Like the normal Colemak-eD but with composes for ĉĝĵŝŭ added.
;			- Compose key on <kbd>X</kbd> for ANSI, since X isn't used in Esperanto. To type X, hit <kbd>K</kbd>, <kbd>X</kbd> or <kbd>AltGr</kbd><kbd>X</kbd>.
;		- Added Hebrew layouts. See the `Cmk-eD-Heb` layout folder and the Forum Locale post.
;	
;		- Fixed: A CapsLock off is sent at startup to avoid CapsLock being stuck on after an EPKL refresh.
;		- Fixed: Using relative paths for icon files, multiple layout selections wouldn't show the correct icons.
;		- Fixed: Setting any mod in the EPKL_Layouts file would make layout shortcuts that don't use mods fail.
;		- Fixed: Subfolder structure added to the MainLay parameter the Colemak and Tarmak layouts. Consistent naming scheme for all such subfolders.
;		- Fixed: The Layout Selector would show non-existing mod combos for, e.g., ANS if there was a KbdType like ANS-Orth present
;		- Fixed: Capitalized sequences didn't compose if followed by a lowercase version in the table. Example: `LJ Lj lj → Ǉ ǉ ǉ`; `ǈ` didn't happen.
;		- Fixed: Pressing a DK twice released both its base characters instead of just one. Now only base char 0 (the s0 DK entry) is released.

;;  ####################### main      #######################
#NoEnv
#Persistent
#NoTrayIcon
#InstallKeybdHook
#SingleInstance force
#MaxThreadsBuffer
#MaxThreadsPerHotkey  3
#MaxHotkeysPerInterval 300
#MaxThreads 30

SendMode Event
SetKeyDelay 0 												; The Send key delay wasn't set in PKL, defaulted to 10.
SetBatchLines, -1 	; eD WIP: What is the actual possible lowest SetKeyDelay value, and what's most robust? How about -1 vs 0 vs 1?
Process, Priority, , H  									; High process priority
Process, Priority, , R  									; Real-time process priority
SetWorkingDir, %A_ScriptDir% 								; Should "ensure consistency" 	; eD WIP: Can we have a separate user working dir, so users have their settings elsewhere?
StringCaseSense, On 										; All string comparisons are case sensitive (AHK default is Off)

setPklInfo( "pklName", "EPiKaL Portable Keyboard Layout" ) 					; EPKL Name
setPklInfo( "pklVers", "1.3.1" ) 											; EPKL Version
setPklInfo( "pklComp", "AHK v1.1.27.07" ) 									; Compilation info
setPklInfo( "pklHome", "https://github.com/DreymaR/BigBagKbdTrixPKL" ) 		; URL used to be http://pkl.sourceforge.net/
setPklInfo( "pklHdrA", ";`r`n;;  " ) 										; A header used when generating EPKL files
setPklInfo( "pklHdrB", "`r`n"
		. ";;  for Portable Keyboard Layout by Farkas Máté [https://github.com/Portable-Keyboard-Layout]" . "`r`n"
		. ";;  edition DreymaR (Øystein B Gadmar, 2015-)   [https://github.com/DreymaR/BigBagKbdTrixPKL]" . "`r`n;`r`n" )

;;  Global variables are now largely replaced by the get/set info framework, and initialized in the init fns
	global HotKeyBuffer = [] 								; Keeps track of the buffer of up to 30 pressesd keys in ###KeyPress() fns
;	global UIsel 											; Variable for UI selection (use Control names to see which one) 	; NOTE: Can't use an object variable for UI (yet)
Gosub setUIGlobals 											; Set the globals needed for the settings UI (is this necessary?)

arg = %1% 													; Layout from command line parameter, if any
initPklIni( arg ) 											; Read settings from pkl.ini (now PklSet and PklLay)
initLayIni() 												; Read settings from layout.ini and layout part files
activatePKL()

Return  													; end of main

;;  ####################### labels    #######################

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
processKeyPress24: 	; eD WIP: What's the ideal size of this cycle? Does #MaxThreads apply?
processKeyPress25:
processKeyPress26:
processKeyPress27:
processKeyPress28:
processKeyPress29:
processKeyPress30:
processKeyPress31:
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

modifierDown:			; *SC###    (call fn as HKey to translate to modifier name)
	Critical
	setModifierState( getKeyInfo( SubStr( A_ThisHotkey, 2     ) . "vkey" ), 1 ) 	; eD WIP: Use "vmod" instead of "vkey" for modifiers?
Return

modifierUp:
	Critical
	setModifierState( getKeyInfo( SubStr( A_ThisHotkey, 2, -3 ) . "vkey" ), 0 ) 	; eD WIP: --"--
Return

tapOrModDown: 			; *SC###
	Critical
	setTapOrModState(   SubStr( A_ThisHotkey, 2     ), 1 )
Return

tapOrModUp:
	Critical
	setTapOrModState(   SubStr( A_ThisHotkey, 2, -3 ), 0 )
Return

showAbout: 													; Menu "About..."
	pkl_about()
Return

changeSettings: 											; Menu "Layout/Settings..."
	pklSetUI()
Return

keyHistory: 												; Menu "AHK Key History..."
	KeyHistory
Return

detectCurrentWinLayDeadKeys: 								; Menu "Detect dead keys..."
	setCurrentWinLayDeadKeys( detectCurrentWinLayDeadKeys() )
Return

showHelpImage:
	pkl_showHelpImage()
Return

showHelpImageOnce: 											; Used as a one-time refresh when necessary
	pkl_showHelpImage()
Return

showHelpImageToggle: 										; Menu "Display help image"
	pkl_showHelpImage( 2 )
Return

zoomHelpImage: 												; Menu "Zoom help image"
	pkl_showHelpImage( 5 )
Return

moveHelpImage: 												; Hotkey "Move help image"
	pkl_showHelpImage( 6 )
Return

opaqHelpImage: 												; Hotkey "Opaque/Transparent image"
	pkl_showHelpImage( 7 )
Return

changeActiveLayout: 										; Menu "Change layout"
	changeLayout( getLayInfo( "NextLayout" ) )
Return

rerunWithSameLayout: 										; Use the layout # instead of its code, to reflect any PKL Settings list changes
	activeLay   := getLayInfo( "ActiveLay" ) 				; Layout code (path) of the active layout
	numLayouts  := getLayInfo( "NumOfLayouts" ) 			; The number of listed layouts
	Loop % numLayouts {
		theLayout   := getLayInfo( "layout" . A_Index . "code", theCode )
		actLayNum   := ( theLayout == activeLay ) ? A_Index : actLayNum
	}
	changeLayout( "UseLayPos_" . actLayNum ) 				; Rerun the same layout, telling pkl_init to use position.
Return

changeLayoutMenu: 											; Menu "Layouts"
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

suspendToggle: 												; Menu "Suspend"
	Suspend
	Goto afterSuspend
Return

afterSuspend:
	if ( A_IsSuspended ) {
		pkl_showHelpImage(  3 )
		Menu, Tray, Icon, % getLayInfo( "Ico_OffFile" ), % getLayInfo( "Ico_OffNum_" )
	} else {
		pkl_showHelpImage( -3 )
		Menu, Tray, Icon, % getLayInfo( "Ico_On_File" ), % getLayInfo( "Ico_On_Num_" )
	}
Return

exitPKL: 													; Menu "Exit"
	ExitApp
Return

doNothing:
Return

getWinInfo:
	getWinInfo() 										; Show the active window's title/process(exe)/class
Return

epklDebugWIP: 											; eD WIP/DEBUG: This entry is activated by the Debug hotkey
	pklDebug( "Running Debug/WIP routine`n(specified in _PKL_main)", .6 )
;	importLayouts() 									; eD TODO: Import a MSKLC layout file to EPKL format
;	importComposer() 									; eD DONE: Import an X11 Compose file to EPKL format
	debugShowCurrentWinLayOEMs() 						; eD DEBUG: Show OS & EPKL VK codes for the OEM keys
;	ListHotkeys 										; Show AHK hotkeys as by the View -> Hotkeys menu item
Return

;;  ####################### functions #######################

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
#Include pkl_import.ahk 	; Import module, converting MSKLC layouts to EPKL format, and other import/conversion
#Include pkl_make_img.ahk	; Help image generator, calling Inkscape with an SVG template

;;  #######################  modules  #######################

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
