WARNING: HARD HAT AREA! PROCEED WITH CAUTION!

This is a Work-In-Progress, so don't expect any of it to be working ... yet. ;-)

Øystein B "DreymaR" Gadmar


TODO:
• Alternative mapping format? Like TMK? But keep backwards compatibility?
	- Probably overmuch. Besides, there are conversion tools like the one by Aldo Gunsing.

• Multilayered help images, so the fingering can be in one image and the keys in another (saves file space, adds options)
	- Truly transparent background without the image frame. Can transparent color work? Yes, seems so.
    - Generate key mapping images from layout files by script?

• Scan code remapping, adding modularity. Making one layout for every ISO-ANSI/Angle/Curl/Wide/etc variant is murder!
	- Unfortunately though, I don't think I can make that work for the help images... [script InkScape?!?]
	- Could for instance Curl, Angle and Wide be separated? Even Wide-main and Wide-specific(Slash/brackets/backslash/apostrophe)?
    - VK are better documented than SC on the net. BUT: Problem with VK_OEM_# for different keyboard types! So we're using SC.
	- ANSI/ISO is actually VK remapping, not SC! So that needs to be addressed. Use separate, similar tables for SC and VK.
	- Curl is somewhat VK (affects letters and AltGr only), while (Curl)AngleWide is SC (affects Extend too; Ctrl+V for Curl)
	- Remap AltGr modularly too? E.g., only rewrite the necessary keys for a Locale layout. Maybe overmuch, as it'd take a new format.
    - For both Extend and layout.ini, SC### will get translated in the code before actual mapping.
    - Allow modular mapping of ZXCVB_, upper left side, right side and mods/etc.

• Virtual Key remapping.
    - I'd like to make only ISO layouts, and leave the ISO-ANSI VK issue to a simple remap routine.
    - In pkl-eD.ini there's the variable 'eD_KbdType'. Maybe a KbdType in layout-eD.ini to compare with this?
    - If remapping between layout and keyboard is needed, use an array of VK translations.

• Multi-Extend! E.g., Alt+Caps triggers NumPad Extend layer; Caps holds it (Alt+Shift+Caps locks/unlocks it?).
	- Others: Ctrl+Caps(only good w/ RCtrl), AltGr+Caps(good!)..., Alt+AltGr+Caps (fancy)
	- Wanted: NumPad layer, coding layer (brackets/templates), hotstring layer...
	- Extend layers defined in a separate file; possibility of separate scan code remaps for these (e.g., AngleWide but mostly not Curl)

• Generic dead key names for images (dk_tilde instead of, e.g., dk13)
	- Also generic definitions in a central doc! Many layouts can point to the same ones.
	- lookup table and dir spec in layout_eD (may use proper names or dk## in the layout itself, for compatibility!)
    - Make PKL code so that if no other lookup is specified, it defaults to local file (backwards compatible)

• More generic dead key output: Ligatures (important for my Jap layout! Also for combining accents and hotstrings)
	- Selectable mode per key: By Unicode characters, hex or dec (default today).
	- Prefixes: Nothing – decimal; x – hex (or U+/u for standard Unicode Point notation?); '-' - Unicode glyph (or use '.', '<>' '//' ?)
	- Quotes '' enclose a ligature (so -'hello' is a Unicode string, and so is x'00d4 00d5'); a literal '' would be -''''-?
	- Example:	"102  =  402	; f -> ƒ" – could become "-f = -ƒ"
	- Example:	"77   = 11374	; M -> ?" – Meng not shown properly; to avoid trouble, use for instance "-M = x2C6E"
	- Keep it easy to import MSKLC dead key tables of the form '006e	0144	// n -> ń' by script (here, simply use "u$1 = u$2 ; $3")

• Ligature/hotstrings: Specify a loc/filename, then use §## in the layout, where ## can be any two glyphs (a number or tag).
    - Example: §g1, §g2... for greetings; §hd for default header etc.
    - Alternative: Simply allow ligatures in dead keys! If strings are allowed, it'll be flexible.

• Some more dead key mappings: Greek with accents; ?
	- Need chainable accents, e.g., iota with diaeresis and tonos

• Sticky/latch Shift (faster and better?). Windows Sticky Keys don't work with PKL as it is.
    - Windows way: Shift×5 turns it on/off (use ×6 for PKL?!). When turned on, Modifier×2 locks.
    - Should have a deactivation timer, e.g., 0.5 s (config adjustable).
    - For Shift only, or Shift+Ctrl? (Alt and Win shouldn't be sticky, as they already have semi-sticky mappings.)
    - Probably best w/ one for Shift and one for Ctrl then. Or config it.

• Add a KeyHistory shortcut for debugging etc: Ctrl & F5::KeyHistory.
