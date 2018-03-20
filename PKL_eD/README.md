WARNING: HARD HAT AREA!
=======================

PKL[edition DreymaR] is a Work-In-Progress, so don't expect all of it to be working perfectly ... yet. ;-)

~ Øystein B "DreymaR" Gadmar, 2017


DONE:
-----

* Renamings and file mergings to make the code more compact and streamlined. Removed set/getGlobal as it was used only once.
* Edited menus and the About... dialog.
* Add a KeyHistory shortcut for debugging etc. Make it configurable in pkl_eD.ini (eD_DebugInfo).
* Add a Refresh hotkey. Reruns PKL in case something got stuck or similar.
* Multilayered help images, so the fingering can be in one image and the keys in another (saves file space, adds options).
    - Also, the ability to set background color, overall transparency and top/bottom gutter distance.
* Removed OSVersion < VISTA fix for WheelLeft/WheelRight, as even Win Vista is no longer supported by MS.
* Removed explicit Cut/Copy/Paste keys (in pkl_keypress.ahk); use +{Del} / ^{Ins} / +{Ins} (or as I have used in my Extend mappings, }^{X/C/V ).
* Made a PKL_Tables.ini file for info tables that were formerly internal. This way, the user can make additions as necessary.
* Sensible dead key names for images and entries (e.g., dk14 -> tilde) in a central doc that layouts can point to.
    - Dead key list and file path in DreymaR_layout (but use dk## in the layout itself, for compatibility!)
    - If no lookup is specified, PKL defaults to the local file as before
    - This way, one change in a DK will affect all layouts using that DK
    - DK images may still be kept in the layout dir (or a subdir to avoid clutter), as they are layout dependent
    - DK imgs named <name>_dk<#> for state <#> (add s6/7 where applicable?!)
* You can specify in PKL_eD.ini which tray menu item is the default (i.e., activated by double-clicking the tray icon)


TODO:
-----

* Alternative mapping format, like TMK or my own KLD? But keep backwards compatibility.
    - Overmuch for layouts?! Besides, there are conversion tools like the one by Aldo Gunsing.
    - Neat idea for scancode and virtual key remapping! Make it possible to leave entries open.

* Would it be possible to make single-key images so that they may be remapped?
    - But that'd require some sort of position map, maybe KLD-based.
    - Also, not sure whether rendering would be smooth enough?

* Truly transparent image background without the image frame. Overall transparency (but not transparent color?) works.
    - Transparent foreground images for all states and dead keys.
    - Also for dead key state 6/7

* Generate key mapping images from layout files and my .svg by scripting InkScape?

* Scan code remapping, adding modularity. Making one layout for every ISO-ANSI/Angle/Curl/Wide/etc variant is murder!
	- Unfortunately though, I don't think I can make that work for the help images?
	- Separate for instance Curl, Angle and Wide. Even Wide-main and Wide-specific(Slash/brackets/backslash/apostrophe)?
    - VK are better documented than SC on the net? BUT: Problem with VK_OEM_# for different keyboard types! So we're using SC.
	- ANSI/ISO is actually VK remapping, not SC! So that needs to be addressed. Use separate, similar tables for SC and VK.
	- Curl is somewhat VK (affects letters and AltGr only), while (Curl)AngleWide is SC (affects Extend too; Ctrl+V for Curl)
	- Remap AltGr modularly too? E.g., only rewrite the necessary keys for a Locale layout. Maybe overmuch, as it'd take a new format.
    - For both Extend and layout.ini, SC### will get translated in the code before actual mapping.
    - Allow modular mapping of ZXCVB_, upper left side, right side and mods/etc.

* Virtual Key remapping.
    - I'd like to make only ISO layouts, and leave the ISO-ANSI VK issue to a simple remap routine.
    - In pkl-eD.ini there's the variable 'eD_KbdType'. Maybe a KbdType in layout-eD.ini to compare with this?
    - If remapping between layout and keyboard is needed, use an array of VK translations.

* Multi-Extend! E.g., LAlt+Caps triggers NumPad Extend layer; Caps (or LAlt?) holds it. (LAlt+Shift+Caps locks/unlocks it?)
	- Others: Ctrl+Caps(only good w/ RCtrl), AltGr+Caps(good!)..., Alt+AltGr+Caps (fancy)
	- Wanted: NumPad layer, coding layer (brackets/templates), hotstring layer...
	- Extend layers defined in a separate file; possibility of separate scan code remaps for these (e.g., AngleWide but mostly not Curl)
	- Extend "hold": Any of the keys involved in selecting an extend layer could be held to keep that layer?

* More generic dead key output: Ligatures (important for my Jap layout! Also for combining accents and hotstrings)
	- Selectable mode per key: By Unicode characters, hex or dec (default today).
	- Prefixes: Nothing – decimal; x – hex (or U+/u for standard Unicode Point notation?); '-' - Unicode glyph (or use '•', '.', 'α', '//' ?)
	- Quotes '' enclose a ligature (so -'hello' is a Unicode string, and so is x'00d4 00d5'); a literal '' would be -''''-?
	- Example:	"102  =  402	; f -> ƒ" – could become "-f = -ƒ"
	- Example:	"77   = 11374	; M -> ?" – Meng not shown properly; to avoid trouble, use for instance "-M = x2C6E"
	- Keep it easy to import MSKLC dead key tables of the form '006e	0144	// n -> ń' by script (here, simply use "u$1 = u$2 ; $3")
    - Simplest and best: Allow for AHK literals?!

* Ligature/hotstrings:
    - In addition to ligatures/strings in dead keys, we need direct ligatures. For Jap etc. and for string layers.
    - Specify a loc/filename, then use §### or &### in the layout, where ### can be any 1–3 glyphs (a number or tag)?
    - Example: §g01, §g02... for greetings; §MHd for default mail header etc.
    - Could these simply be AHK literals? Then, you could send anything AHK can send!

* Some more dead key mappings: Greek with accents; ?
	- Need chainable accents, e.g., iota with diaeresis and tonos

* Sticky/latch Shift (faster and better?). Windows Sticky Keys don't work with PKL as it is.
    - Windows way: Shift×5 turns it on/off (use ×6 for PKL?!). When turned on, Modifier×2 locks.
    - Should have a deactivation timer, e.g., 0.5 s (config adjustable).
    - For Shift only, or Shift+Ctrl? (Alt and Win shouldn't be sticky, as they already have semi-sticky mappings.)
    - Probably best w/ one for Shift and one for Ctrl then. Or config it.

* Option to have layouts on the main menu like vVv has: "Layout submenu if more than..." setting (in Pkl_eD.ini).


**TODO: From DreymaR_layout.ini.**
* Extend layer lists (extend# = ext_sensiblename) in my layout file
    - Keep all extend layers in ..\..\PKL_DreymaR\extend.ini ?
    - Also keep Extend help images centrally!? One folder for each scanmap "model".
* Keyboard "models", that is, modular key-to-key remappings
    - They could be selected in my layout file, and kept in PKL_Dreymar\scanmaps.ini
    - Example: 'scanmap_layout = pc105 angle-iso wide-sl curl-dh' produces CurlAngleWide
    - A scanmap may be TMK-style, mapping one intuitive map layout (including blanks) to another
    - Separate scanmap for layout and extends!? E.g., layout has CurlAngleWide, extends AngleWide.
    - And/or virtualmap in addition, for remapping Curl etc without affecting Extend?
    - The main use for vkmaps could be ISO-ANSI conversion! A worthy cause!
    - Could in theory use a scanmap/vkmap to rearrange one layout to another (Colemak-QWERTY-whatever)!?
    - So, just by changing maps I could convert my Colemak[eD] to Angle, CurlAngleWide, QWERTY...
* Ligature tables for longer strings etc, using, e.g., &### layout entries and a table (link) in DreymaR_layout
* Literal AHK output? The {Raw} send mode is on by default.
    - PKL already supports multi-codepoint output by default! But not modified stuff.
    - A ## entry will become Send {Raw}{##}?
    - A *{##} should be sent without {Raw}? If so, utilize this! And document the possibilities!
    - Might treat any entries starting/ending with {} as Send {##} instead of Send {Raw}{##} (literal mode)?
    - Or is it better to just keep today's style in which }^{z for instance sends Ctrl+Z ? For compatibility.
    - We don't really need the %#### 'utf ligature' notation then, do we? It's a leftover from MS-KLC.
* Ligature output from deadkeys (dead strings - necessary for, e.g., Cmk[eD]-Jp which uses digraphs)
    - Could do all DK and ligature tables with literals!?
* Allow non-Tab whitespace in layout entries?! (Strip whitespace. To preserve it use {# } or }{# }{ in entries)
    - Today, tab+; comments are stripped in layout.ini but not in pkl.ini? Make this consistent!
    - Important: Leave escaped semicolon (`;) alone, even after whitespace! And document the need for escaping it!


INFO: Some documentation notes
------------------------------

* Virtual key code links:
    http://www.kbdedit.com/manual/low_level_vk_list.html
    https://msdn.microsoft.com/en-us/library/ms927178.aspx
    https://msdn.microsoft.com/en-us/library/windows/desktop/dd375731(v=vs.85).aspx
* "Anti-madness tips" for PKL (by user Eraicos and me):
    - AHK script files (AHK v1.0) need to be ANSI encoded?! What to do with special letters then?
        - Seems that AHK v1.1 ("Unicode AHK") supports UTF-8 with BOM (not without!?) scripts.
    - PKL .ini files may be UTF-8 encoded. With or without BOM?
        - For safety, don't use end-of-line comments in the .ini files? OK in layout.ini (because of tab separator?).
    - In layout.ini:
        - Always use tabs as separators in layout.ini
        - After 'VirtualKey' always include a tab.
        - The CapsLock key should have scan code 'CapsLock' instead of SC03A?
    - In the pkl.ini Extend section:
        - Don't have empty mappings in the Extend section. Comment these out.


**INFO: From Farkas' sample.ini layout file**
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
		*{####} send without {Raw}(?) – that is, interpret key names (and ^+1#{} ?) in AHK style
		={####} send {Blind} – that is, keep the modifier state intact
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
; [Unicode number of the base letter] = [Unicode number of the new letter] <tab> ; comments
97   =  227	; a -> ã
```
