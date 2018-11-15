DreymaR's Big Bag Of Keyboard Tricks - PKL[eD]
==============================================

### For [PortableKeyboardLayout][PKLGit] on Windows
#### ([Written By Farkas Máté in 2008][PKLSFo] using [AutoHotkey][PKLAHK])
#### ([PKL[edition DreymaR]][CmkPKL] by DreymaR, 2017-)

Documentation
-------------

Info about DreymaR's Big Bag of keyboard trickery is mainly found on the Colemak forum:
* The [Big Bag main topic][CmkBBT] with better explanations and links.
* Daughter topics for implementations, including the [Big Bag for PKL/Windows][CmkPKL] one.
  
* This repo implements most of my Big Bag for PKL, as layout and PKL .ini files.
* It also adds my own PKL - edition DreymaR (PKL[eD]) with several improvements.
* Big thanks to Farkas Máté, the AutoHotkey people, Vortex(vVv) and all other contributors.

Getting PKL up and running
--------------------------

* Download a copy of this repo, for instance with its GitHub Download/Clone button (and then unzip the file you got).
* The simplest way of running PKL is to just put the main folder somewhere and run PKL.exe any way you like!
* PKL, being portable, doesn't need an install with admin rights to work. You must still be allowed to run programs.
  
* I usually put a shortcut to PKL_eD.exe in my Start Menu "Startup" folder so it starts on logon, per user.
* PKL can also easily be used with the [PortableApps.com][PrtApp] menu by putting its folder in a C:\PortableApps folder.
* If the PortableApps menu is started on logon it can start up PKL for you too.
  
* Choose a layout with your ISO/ANS(I) keyboard type, locale and Curl/Angle/Wide preferences, by shorthand or full name.
* In PKL_Settings.ini, activate the layout(s) you want by uncommenting (remove initial semicolon) and/or editing.
    * My shortcuts use the KbdType (@K) etc values but you could also type the path to a layout folder out in full
    * The format is: layout = ‹1st layout folder name›:‹name you want in menu›,‹2nd layout folder›:‹2nd menu entry› etc

More Know-How-To
----------------

* This repo contains executables for the original PKL as well as PKL[eD], and source code for both.
* The layouts are updated to PKL[eD] format though, so they'd need a little reconstruction for old PKL.
* The PKL_Settings.ini file holds layout choices. The layout.ini files hold layout settings and mappings.
  
The files may take a little tweaking to get what you want. Remember, there are several parameters:
* ISO (European/World) vs ANSI (US) vs other keyboard types
    * ISO boards have a `VK_102` key between `Z` and `LShift`, and some OEM_ key codes differ from ANSI ones
    * JIS (Japanese) etc are not supported so far - sorry!
* Colemak vs QWERTY vs what-have-you, obviously. Choose wisely!
* Extend mappings, using for instance CapsLock as a modifier for nav/edit/multimedia/etc keys. It's awesome!!!
* Curl(DH), Angle and/or Wide ergonomic mods, moving some keys to more comfortable positions
    * Angle/Wide affect the "hard" key positions in the layout.ini file, usually both for Layout and Extend
    * Curl(DH) is Colemak/Tarmak specific and for the most part should not affect Extend
* Full/VK mappings: I've provided my own Colemak[eD] as well as 'VirtualKey' versions
    * The 'VK' layouts just move the keys of your installed OS layout around, without other changes
    * The [eD] layouts have their own Shift/AltGr mappings specified. You may mix types if you want.
* In PKL_Settings.ini you can use shorthand for KbdType, CurlMod and ErgoMod, or use the layout folder path directly.
* In the layout folder(s) you've chosen, you may edit the layout.ini files further if required. See below.
    * Mod remaps, help image specifications, Extend key, key mappings etc are set in the layout.ini file.
    * Many layouts use a base layout. Most mappings may be there, so the top layout.ini only has to change a few keys.
* If you need to tweak some Extend mappings, they're now in a separate file usually found in the PKL_eD folder.
* Similarly, there's a PKL_eD file for named literals/powerstrings. These are useable by layouts, Extend and dead keys.
* To learn more about remaps, see the PKL_eD\_eD_Remap.ini file. They can even turn Colemak into QWERTY (oh no...!).
* Help images aren't always available with the right ergo mod and keyboard type, since there are many combos. See below.
  
**Hotkeys found in the PKL settings file:**
* Ctrl+Shift+1 – Display/hide help image
* Ctrl+Shift+2 – Switch layout between the ones specified in the settings file
* Ctrl+Shift+3 – Suspend PKL; hit again to re-activate (it may be Ctrl+Shift+` instead)
* Ctrl+Shift+4 – Exit PKL
* Ctrl+Shift+5 – Refresh PKL, if it gets stuck or something
  
**Techy tips for PKL:**
* Look in the various .ini files if you're interested! Much is explained there.
* See my examples in the Extend file for some advanced mappings! These may be used in layouts and dead keys too.
* PKL_eD uses both .ini and source files that may be UTF-8 Unicode encoded.
* PKL_eD allows end-of-line comments (whitespace-semicolon) in .ini files, but the original PKL only allows them in layout entries.
* Running PKL with other AutoHotkey key mapping scripts may get confusing if there is so-called _hook competition_.

Layout variants
---------------

You can quite easily make your preferred (non-)ergonomic variant of, say, a locale layout:
* Copy-Paste the layout folder and rename the result to what you want, such as 'Cmk-eD-De_ISO_Angle' for German with only the ISO-Angle mod.
* In that folder's layout.ini file, edit the remap fields to represent the new setting. In this case, 'CmkCAW_ISO' → 'Angle_ISO'.
    - For non-DH layouts, Extend uses the same remap as the layout; for Curl(DH)/CAW you need an _ext remap for Extend.
* Now, if the PKL_Settings.ini Kbd/Curl/Ergo/Locale settings are right – in this case, ISO/--/Angle/De – you should get the variant you wanted.
    - After making layout changes, I refresh PKL with the Ctrl+Shift+5 hotkey. If that doesn't work, quit and restart PKL.
* If you want updated help images you must get Inkscape and run the "Create help images..." option.
    - First, check around in the eD layout folders. Maybe there's something that works for you there despite a few minor differences?
    - You can download Inkscape for instance from PortableApps.com, and point to it in the PKL_eD\ImgGenerator\PKL_ImgGen_Settings.ini file.
    - By default, the HIG looks for Inkscape in C:\PortableApps\InkscapePortable\InkscapePortable.exe, so you could just put it there and go.
    - To see the menu option you must have advancedMode active (in PKL_Settings.ini). The HIG will make images for the currently active layout.
    - I recommend making state images only at first, since a full set of about 80 dead key images takes a _long_ time!

Key mappings
------------

Most of my layouts have a base layout defined; their layout section then changes some keys. You can add key definitions following this pattern.
  
Here are some sample full key mappings followed by a legend:
```
SC018 = Y       1   y   Y   --  ›    »   ; QWERTY oO
SC019 = OEM_1   0   ;   :   --  @13  …   ; QWERTY pP - dk_umlaut (ANS_1 ISO_3)
;SC   = VK      CS  S0  S1  S2  S6   S7  ; comments
```
Where:
* SC & VK: [Scan code ("hard code")][SCMSDN] & Virtual Key Code [("key name")][VKCAHK]; also see my [Key Code Table][KeyTab].
    - For SC, you can use an AHK key name instead. For full mappings I think you need the real VK name in the VK entry.
    - _Example:_ The above keys are the SC for the `O` and `P` keys; these are then mapped to their Colemak equivalents `Y` and `;`.
    - Check out that the ISO/ANSI specific `OEM_#` key numbers are right for you, or remapped with a VK remap.
    - _Example:_ `OEM_1` above is the semicolon key for ANSI, but ISO names it `OEM_3`.
* CS: Cap state. Default 0; +1 if S1 is the capitalized version of S0 (that is, CapsLock acts as Shift for it); +4 for S6/S7.
    - _Example:_ For the `Y` key above, CS = 1 because `Y` is a capital `y`. For `OEM_1`, CS = 0 because `:` isn't a capital `;`.
* S#: Modifier states for the key. S0:Unmodified, S1:+Shift, S2:+Ctrl (rarely used), S6:+AltGr, S7:+Shift+AltGr.
    - _Example:_ Shift+AltGr+`y` gives the `»` glyph. AltGr+`;` has the special entry `@13` (dk_umlaut).
* Special prefix-entry syntax (can be used for layouts, Extend and dead key entries):
    - %‹entry› : Send a literal string/ligature by the SendInput {Raw}‹entry› method (default)
    - $‹entry› : Send a literal string/ligature by the SendMessage ‹entry› method
    - *‹entry› : Send ‹entry› directly, allowing AHK syntax (!+^# mods, {} key names)
    - =‹entry› : Send {Blind}‹entry›, keeping the state of any held modifier keys
    - @‹entry› : Send the current layout's dead key named ‹entry›
    - &‹entry› : Send the current layout's powerstring named ‹entry›
  
Here are some sample VirtualKey (VK) and Modifier mappings. Any layout may contain all types of mappings.
```
RWin    = Back      VirtualKey      ; RWin   -> Backspace
RShift  = LShift    Modifier        ; RShift -> LShift, so it works with LShift hotkeys
SC149   = NEXT      VirtualKey      ; PgUp   -> PgDn (needed the VKEY name here)
SC151   = PRIOR     VirtualKey      ; PgDn   -> PgUp (--"--)
```
Entries need to be tab-separated and except for the VK name entry, not padded with other whitespace.


DONE:
-----
These are some of the changes in [PKL_eD]:
* v0.4.0: Transition to AHK v1.1
	* A Refresh menu option with a hotkey (default Ctrl+Shift+5) in case the program hangs up in some way (stuck modifiers etc).
	* Advanced Mode setting that shows 'Key history...' and other menu options, plus more info in the About... dialog.
	* Sensible dead key names for images and entries (e.g., @14 -> tilde) in a central file that layouts can point to.
	* A PKL_Tables.ini file for info tables that were formerly internal. This way, the user can make additions as necessary.
* v0.4.1: Transition to AHK v1.1 Unicode, using native Unicode Send and UTF-8 compatible files.
	* A base layout file can be specified, allowing layout.ini to only contain entries that should override the base layout.
* v0.4.2: Help image opacity, scaling, background color and gutter size settings. Help images can be pushed horizontally too.
	* Separate help image background/overlay, so keys/fingering, letters/glyphs and Shift/AltGr marks can be in different images.
* v0.4.3: Scan and virtual code modular remapping for layouts and Extend, making ergo and other variants much more accessible.
* v0.4.4: A Help Image Generator that uses Inkscape (separate download) to generate a set of help images from the current layout.
	* A shorthand notation in PKL_Settings.ini to specify KbdType (ISO/ANSI), CurlMod and ErgoMod with the layouts.
* v0.4.5: Layouts, Extend and dead keys now support the same prefix-entry syntax, parsing "%$*=@&" as first character specially.
	* The "&" prefix denotes literals/powerstrings found in a separate PKL_eD file. These may span more than one line.


TODO:
-----
I have many more [PKL_eD] changes on my wishlist, including:
* A timer that checks whether the underlying Windows layout has changed (affects dead keys) - and fixes any stuck modifiers?
* Multiple Extend layers (NumPad, hotstring...).
* Sticky a.k.a. One-Shot modifiers: Press-release modifier, then within a certain time hit the key to modify.
* A settings panel instead of editing .ini files.
  
_Best of luck!_
_Øystein "DreymaR" Gadmar, 2018-11_


[PKLGit]: https://github.com/Portable-Keyboard-Layout/Portable-Keyboard-Layout/ (PKL on GitHub)
[PKLSFo]: https://sourceforge.net/projects/pkl/ (PKL on SourceForge)
[PKLAHK]: https://autohotkey.com/board/topic/25991-portable-keyboard-layout/ (PKL on the AutoHotkey forums)
[AHKHom]: https://autohotkey.com/ (AutoHotkey main page)
[CmkBBT]: https://forum.colemak.com/topic/2315-dreymars-big-bag-of-keyboard-tricks-main-topic/ (BigBagOfKbdTrix on the Colemak forums)
[CmkPKL]: https://forum.colemak.com/topic/1467-dreymars-big-bag-of-keyboard-tricks-pklwindows-edition/ (BigBag-PKL on the Colemak forums)
[PrtApp]: https://portableapps.com/ (PortableApps.com)
[SCMSDN]: https://msdn.microsoft.com/en-us/library/aa299374(v=vs.60).aspx (Scan code list at MSDN)
[VKCAHK]: https://autohotkey.com/docs/KeyList.htm (Virtual key list in the AHK docs)
[KeyTab]: ./Other/KeyCodeTable.txt (./Other/KeyCodeTable.txt)
[PKL_eD]: ./PKL_eD/ (PKL[eD] folder/README)