WARNING: HARD HAT AREA!
=======================

PKL[edition DreymaR] is a Work-In-Progress, so all of it may not be working perfectly ... yet. ;-)

~ Øystein B "DreymaR" Gadmar, 2018


DONE:
-----

**GENERAL/SETTINGS**
* Renamings and file mergings to make the code more compact and streamlined.
* Removed MenuIcons and HashTables code, replacing them with AHK v1.1+ native code.
* Unicode native AHK now works. SendU and changeNonASCIIMode removed.
* New iniRead functions that support the UTF-8 Unicode file format.
  
* Made a PKL_Tables.ini file for info tables that were formerly internal. This way, the user can make additions as necessary.
* If using a layout from the command line, the notation "UseLayPos_#" will run layout # in the layout list set in PKL_Settings.
	- This also makes Refresh robust against layout changes in PKL_Settings.
* Base layout: Specify in layout.ini a basis file (layout section only). Just need to list changes in layout.ini now. Nice for variants.
* Shorthand notation in PKL .ini layouts, allowing the KbdType/CurlMod/ErgoMod settings to be referred to as @K/@C/@E resp. (@T for all at once).
* Path shortcut for layout.ini entries, allowing ".\" instead of full path from PKL root.
  
**MENUS/IMAGES**
* Edited menus and the About... dialog.
* Added a KeyHistory shortcut for debugging etc. Make it configurable in pkl_eD.ini (eD_DebugInfo).
* Added a Refresh hotkey. Reruns PKL in case something got stuck or similar.
* You can specify in PKL_eD.ini which tray menu item is the default (i.e., activated by double-clicking the tray icon)
* Would tray menu shortcuts work? E.g., &About. Answer: The menu shows it, but unselectable by key(?).

* Multilayered help images so fingering can be in one image and letters/symbols in another (saves file space, adds options).
	- Shift/AltGr indicators on separate images in a specified directory instead of in the state#.png (and dk) images.
	- Allow pushing the help image horizontally if mouse x pos. is in the R/L ~20% zone.
	- Settings in layout.ini: Size/scaling, background/extend images, background color, shift indicator, icons and dead key dirs.
	- Settings in settings.ini: Overall transparency/opacity, top/bottom gutter distances, horizonal activation zone.
	- If settings are missing, may default to backgr.png, extend.png, on/off.ico and ModStateImg\ in the layout dir.
	- Instead of many lines of image sizes, introduced a scaling factor 'img_scale' (in percent).
* Help Image Generator, using my KLD format in an SVG image template. With search/replace this is turned into a key glyph image.
	- You'll need an Inkscape (Scalable Vector Graphics program) install. A good option is portable Inkscape from PortableApps.com.
	- You can choose whether to make shift state images only or a full image set with all shift states for all deadkeys. The latter takes time!
	- The HIG can be used from the menu when Advanced Mode is set. Its settings file is in PKL_eD\ImgGenerator.
	- In the HIG settings file you can control replacement characters used in a marking layer; anything written to it will show in bold yellow.
	- The SVG image template file is in the same location. You could use another template and specify it in the HIG settings file.
	- If you don't want the dead keys marked in yellow for instance, you could save the SVG template with that layer hidden.
	- You can make full layout images showing keys as well, by combining with a PKL_eD\ImgBackground image of choice. I use the GIMP for that.
  
**MAPPINGS**
* Removed explicit Cut/Copy/Paste keys (in pkl_keypress.ahk); use +{Del} / ^{Ins} / +{Ins} (or as I have used in my Extend mappings, }^{X/C/V ).
* Made an _eD_Extend.ini file for Extend mappings that were formerly in pkl.ini (or layout.ini). The old way should still work though.
* Made Extend substitutes for Launch_Media/Search/App1/App2, as AHK multimedia launcher keys aren't working in Win 10.
* Scan code modular remapping, making ergo and other variants much easier. Separate key permutation cycles, and remaps combining/translating them.
	- In layout.ini, specify any remap combinations using the names (and syntax) found in the [remaps] section of the Remap.ini file.
	- The _layout remap specifies a full remapping, while the _extend remap is only for those keys you want to move for Extend ("hard" remaps).
	- Uses my KeyLayoutDefinition (KLD) mapping format.
	- KLD is good for remaps, but too compact for main layout or Extend definitions. (Besides, Aldo Gunsing has a conversion tool for those.)
	- Unfortunately though, I can't make that work for the help images directly. New images need to be generated then.
	- Should I have a cycle merge syntax, e.g., "Angle_ISO105 = TC<  |L0LG  | ^Angle_ANSI-Z"? Probably unnecessary.
* Virtual Key remapping, similarly to SC. I'd like to make only ANSI or ISO layouts, and leave the ISO-ANSI VK issue to a simple remap routine.
* Sensible dead key names for images and entries (e.g., @14 -> tilde) in a central doc that layouts can point to.
	- Dead key list and file path in layout (but use dk## in the layout itself, for compatibility!)
	- If no lookup is specified, PKL defaults to the local file as before
	- This way, one change in a DK will affect all layouts using that DK
	- DK images may still be kept in the layout dir (or a subdir to avoid clutter), as they are layout dependent
	- DK imgs named ‹name›_dk‹#› for state ‹#› (add s6/7 where applicable?!)
* Greek layout w/ tonos/dialytika in the acute/umlaut dead keys.
* In the OS deadkey table ([DeadKeysFromLocID] in PKL_Tables.ini) a -2 entry means no dead keys and RAlt may be used as AltGr (altGrEqualsAltCtrl).
* Special keys such as Back/Del/Esc/F# used to release a dead key's base char and also do their normal action. Now they just cancel the dead key(s).
* A single layout entry of VK or -1 will set that key to itself as a VirtualKey (if it was set in the base layout and you don't want it remapped).
* Ligature/literals/hotstrings are specified by the '&‹entry›' syntax for layouts/Extend/deadkey entries.
	- There's a string file specified in the layout.ini, by default it's PKL_eD\_eD_Ligatures.ini
	- The ligature name can be any text string. In layout entries, two-digit names are prettiest.
	- Note that programs handle line breaks differently! In some apps, \r\n is needed but that creates a double break in others.
* More generic dead key output: Same prefix-entry syntax as layout/Extend, parsing "%$*=@&" entries.
	- Dead key base/release entries can be in 0x#### Unicode format in addition to the old decimal format. For base keys, the syntax must be exact.
	- Examples: "102 = ƒ" is possible instead of "102 = 402". For a glyph not shown in your font such as Meng, "77 = 0x2C6E" (or 11374 still).
	- Should be easy to import MSKLC dead key tables of the form '006e	0144	// n -> ń' by script (e.g., RegExp "0x$1 = 0x$2	; $3")
* In layout.ini, the VK name entry may be white space padded now to create more readable entry tables. The other entries should not be padded.


TODO:
-----

* Dead key chaining (one DK may release another). PKL_eD allows the @## syntax but it doesn't work as it should yet. Because it resets PVDK?

* Multi-Extend! E.g., LAlt+Caps triggers NumPad Extend layer; Caps (or LAlt?) holds it. (LAlt+Shift+Caps locks/unlocks it?)
	- Others: Ctrl+Caps(only good w/ RCtrl), AltGr+Caps(good!)..., Alt+AltGr+Caps (fancy)
	- Wanted: NumPad layer, coding layer (brackets/templates), hotstring layer...
	- Extend layers defined in a separate file; possibility of separate scan code remaps for these (e.g., AngleWide but mostly not Curl)
	- Extend "hold": Any of the keys involved in selecting an extend layer could be held to keep that layer?

* Sticky/latch Shift (faster and better?). Windows Sticky Keys don't work with PKL as it is.
    - Windows way: Shift×5 turns it on/off (use ×6 for PKL?!). When turned on, Modifier×2 locks.
    - Should have a deactivation timer, e.g., 0.5 s (config adjustable).
    - For Shift only, or Shift+Ctrl? (Alt and Win shouldn't be sticky, as they already have semi-sticky mappings.)
    - Probably best w/ one for Shift and one for Ctrl then. Or config it.

* Check whether Ralt (SC138 without LCtrl) will be AltGr consistently in layouts with state 6-7.

* Add to unmapped dead key functionality
	- Specify release for unmapped sequences. Today's practice of leaving an accent then the next character is often bad.
	- That way, one could for instance use the Vietnamese Telex method with aou dead keys (aw ow uw make â ô ư) etc.
	- One catch would be that the dead key wouldn't release until next key press, but that may be acceptable.
	- Specify, e.g., the entry for s1 similar to today's s0 entry. (U+0000–U+001F are just ‹control› chars.)
	- That'd be backwards compatible with existing PKL tables, and one can choose behavior.

* Truly transparent image background without the image frame. Overall transparency (but not transparent color?) works.
	- Transparent foreground images for all states and dead keys.

* Some more dead key mappings:
	- Greek polytonic accents? Need nestable accents, e.g., iota with diaeresis and tonos. See https://en.wikipedia.org/wiki/Greek_diacritics for tables.
	- Kyrillic special letters like ёЁ (for Bulmak) җ ӆ ҭ ң қ ӎ (tailed); see the Rulemak topic
	- IPA on AltGr+Shift symbol keys?

* Define Mirror layouts as remap cycles
	- Should be able to mirror any layout then?
	- Make sure to apply mirroring last?

* Option to have layouts on the main menu like vVv has: "Layout submenu if more than..." setting (in Pkl_eD.ini)?

* Allow non-Tab whitespace in layout entries? (Strip whitespace. To preserve it use {# } or }{# }{ in entries?)
    - Today, tab+; comments are stripped in layout.ini but not in PKL .ini. Make this consistent?
    - Important: Leave escaped semicolon (`;) alone, even after whitespace! And document the need for escaping it!
    - Probably not a big deal. It works well enough as it is.


INFO: Some documentation notes
------------------------------

* Virtual key code links:
    http://www.kbdedit.com/manual/low_level_vk_list.html
    https://msdn.microsoft.com/en-us/library/ms927178.aspx
    https://msdn.microsoft.com/en-us/library/windows/desktop/dd375731(v=vs.85).aspx
  
* "Anti-madness tips" for PKL (by user Eraicos and me):
    - AHK v1.0 script files need to be ANSI encoded. They don't support special letters well.
        - The current PKL_eD AHK v1.1-Unicode supports scripts in UTF-8 w/ BOM (but not without BOM!?).
    - PKL .ini files may be UTF-8 encoded, with or without BOM. Source .ahk files should be UTF-8-BOM?
        - For safety, don't use end-of-line comments in the .ini files? OK in layout.ini (because of tab parsing).
        - With PKL_eD end-of-line comments are safe!
    - In layout.ini:
        - Always use tabs as separators in layout.ini, including between a VK code and 'VirtualKey'.
        - The CapsLock key should have scan code 'CapsLock' instead of SC03A? Why?
    - In the Extend section:
        - Don't use empty mappings in the Extend section. Comment these out.
        - The default format includes {} to send keys by name. To escape these, use my }‹any string›{ trick.
  

**Entry format info from Farkas' sample.ini layout file:** (Note that I now use '@' for 'dk' entries, ++)
```
Scan code =
	Virtual key code (like in MS KLC)
	CapsState (like in MS KLC):
		If CapsState == vk or VirtualKey
			When you press this key, it sends only the virtual key.
			It is very useful, if you install your special layout, and you 
			would like to extend it. (See extend_* layouts)
		Else If CapsState == modifier
			You can use this key as a modifier, like Shift, RAlt (== AltGr)
			See DDvorak or ENTI-key++ layouts
		Else If CapsState & 1 (first bit set)
			Shift + Key == CapsLock + Key
		Else If CapsState & 4 (third bit set)
			AltGr + Shift + Key == CapsLock + AltGr + Key
	Output for each shift state (see http://www.autohotkey.com/docs/commands/Send.htm):
		#       send utf-8 characters (one or more)
		*####   send without {Raw} – that is, interpret key names (and ^+1#{} ?) in AHK style
		=####   send {Blind} – that is, keep the modifier state intact
		%####   utf ligature
		--      disabled
		dk##    deadkey
NOTE: Use tabs as separator for these entries!!!

;scan = VK	CapStat	0Norm	1Sh	2Ctrl	6AGr	7AGrSh	Caps	CapsSh
SC002 = 1	1	1	!			; QWERTY 1!
SC003 = 2	0	2	={Left}		; QWERTY 2@
SC004 = 3	0	3	*{Right}	; QWERTY 3#
SC005 = rshift	modifier		; QWERTY 4$
SC006 = 5	0	dk1	dk2			; QWERTY 5%

[deadkey1]
; 0 = unicode number of the "accent"
0    =  126	; ~
; [Unicode number of the base letter] = [Unicode number of the new letter] ‹tab› ; comments
97   =  227	; a -> ã
```
