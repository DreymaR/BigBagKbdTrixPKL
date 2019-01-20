DreymaR's Big Bag Of Keyboard Tricks - EPKL
===========================================

### For [PortableKeyboardLayout][PKLGit] on Windows
#### ([Written By Farkas Máté in 2008][PKLSFo] using [AutoHotkey][PKLAHK])
#### ([EPiKaL PKL, formerly [edition DreymaR]][CmkPKL] by DreymaR, 2017-)

Documentation
-------------

Info about DreymaR's Big Bag of keyboard trickery is mainly found on the Colemak forum:
* The [Big Bag main topic][CmkBBT] with better explanations and links.
* Daughter topics for implementations, including the [Big Bag for PKL/Windows][CmkPKL] one.
  
* This repo implements most of my Big Bag for PKL, as layout and PKL .ini files.
* It also adds my own EPiKaL PKL [EPKL] with several improvements.
* Big thanks to Farkas Máté, the AutoHotkey people, Vortex(vVv) and all other contributors.

Getting EPKL up and running
---------------------------

* Download a copy of this repo, for instance with its GitHub Download/Clone button (and then unzip the file you got).
* The simplest way of running EPKL is to just put the main folder somewhere and run EPKL.exe any way you like!
* EPKL, being portable, doesn't need an install with admin rights to work. You must still be allowed to run programs.
  
* I usually put a shortcut to EPKL.exe in my Start Menu "Startup" folder so it starts on logon, per user.
* EPKL can also easily be used with the [PortableApps.com][PrtApp] menu by putting its folder in a C:\PortableApps folder.
* If the PortableApps menu is started on logon it can start up EPKL for you too.
  
* Choose a layout with your ISO/ANS(I) keyboard type, locale and Curl/Angle/Wide preferences, by shorthand or full name.
* In EPKL_Settings.ini, activate the layout(s) you want by uncommenting (remove initial semicolon) and/or editing.
    - My shortcuts use the KbdType (@K) etc values but you could also type the path to a layout folder out in full
    - The format is: layout = ‹1st layout folder name›:‹name you want in menu›,‹2nd layout folder›:‹2nd menu entry› etc

More Know-How-To
----------------

* This repo contains executables for EPKL as well as the original PKL, and source code for both.
* The layouts are updated to EPKL format though, so they'd need a little reconstruction for old PKL.
* The EPKL_Settings.ini file holds layout choices and general program settings.
* The layout.ini files hold layout settings and mappings. They may point to and augment a baseLayout.ini file.
  
The files may take a little tweaking to get what you want. There are several parameters:
* ISO (European/World) vs ANSI (US) vs other keyboard types
    - ISO boards have a `VK_102` key between `Z` and `LShift`. Some `OEM_` key codes differ from ANSI ones.
    - JIS (Japanese) etc are not supported so far - sorry.
* Colemak vs QWERTY vs what-have-you, obviously. Choose wisely!
    - This repo by default contains mainly Colemak(-DH) and Tarmak layouts, with QWERTY included.
* Extend mappings, using for instance CapsLock as a modifier for nav/edit/multimedia/etc keys. It's awesome!!!
* Curl(DH), Angle and/or Wide ergonomic mods, moving some keys to more comfortable positions
    - Angle/Wide affect the "hard" key positions in the layout.ini file, usually both for Layout and Extend
    - Curl(DH) is Colemak/Tarmak specific and for the most part should not affect Extend
* Full/VK mappings: I've provided my own Colemak[eD] as well as 'VirtualKey' versions
    - The 'VK' layouts just move the keys of your installed OS layout around, without other changes
    - The [eD] layouts have their own Shift/AltGr mappings specified. You may mix types if you want.
* In EPKL_Settings.ini you can use shorthand for KbdType, CurlMod and ErgoMod, or use the layout folder path directly.
* In the layout folder(s) you've chosen, you may edit the layout.ini files further if required. See below.
    - Mod remaps, help image specifications, Extend key, key mappings etc are set in the layout.ini file.
    - Many layouts use a base layout. Most mappings may be there, so the top layout.ini only has to change a few keys.
* If you need to tweak some Extend mappings, they're now in a separate file usually found in the Files folder.
* Similarly, there's a file for named literals/powerstrings. These are useable by layouts, Extend and dead keys.
* To learn more about remaps, see the _eD_Remap.ini file. They can even turn Colemak into QWERTY (oh no...!).
* Help images aren't always available with the right ergo mod and keyboard type, since there are many combos. See below.
  
**Hotkeys found in the EPKL settings file:**
* Ctrl+Shift+1 – Display/hide help image
* Ctrl+Shift+2 – Switch layout between the ones specified in the settings file
* Ctrl+Shift+3 – Suspend EPKL; hit again to re-activate (it may be Ctrl+Shift+` instead)
* Ctrl+Shift+4 – Exit EPKL
* Ctrl+Shift+5 – Refresh EPKL, if it gets stuck or something
  
**Techy tips for EPKL:**
* Look in the various .ini files if you're interested! Much is explained there.
* See my examples in the Extend file for some advanced mappings! These may be used in layouts and dead keys too.
* EPKL uses both .ini and source files that may be UTF-8 Unicode encoded.
* EPKL allows end-of-line comments (whitespace-semicolon) in .ini files, but the original PKL only allows them in layout entries.
* Running EPKL with other AutoHotkey key mapping scripts may get confusing if there is so-called _hook competition_.

Layout variants
---------------

You can quite easily make your preferred (non-)ergonomic variant of, say, a locale layout:
* Copy-Paste the layout folder and rename the result to what you want, such as 'Cmk-eD-De_ISO_Angle' for German with only the ISO-Angle mod.
* In that folder's layout.ini file, edit the remap fields to represent the new setting. In this case, 'CmkCAW_ISO' → 'Angle_ISO'.
    - For non-DH layouts, Extend uses the same remap as the layout; for Curl(DH)/CAW you need an _ext remap for Extend.
* Now, if the EPKL_Settings.ini Kbd/Curl/Ergo/Locale settings are right – in this case, ISO/--/Angle/De – you should get the variant you wanted.
    - After making layout changes, I refresh EPKL with the Ctrl+Shift+5 hotkey. If that doesn't work, quit and restart EPKL.
* If you want updated help images you must get Inkscape and run the "Create help images..." option.
    - First, check around in the eD layout folders. Maybe there's something that works for you there despite a few minor differences?
    - You can download Inkscape for instance from PortableApps.com, and point to it in the Files\ImgGenerator\EPKL_ImgGen_Settings.ini file.
    - By default, the HIG looks for Inkscape in C:\PortableApps\InkscapePortable\InkscapePortable.exe, so you could just put it there and go.
    - To see the menu option you must have advancedMode active (in EPKL_Settings.ini). The HIG will make images for the currently active layout.
    - I recommend making state images only at first, since a full set of about 80 dead key images takes a _long_ time!

Key mappings
------------

Most of my layouts have a base layout defined; their layout section then changes some keys. You can add key definitions following this pattern.
  
Here are some sample full key mappings followed by a legend:
```
SC018 = Y       1   y   Y   --      ›    »   ; QWERTY oO
SC019 = OEM_1   0   ;   :   --      @13  …   ; QWERTY pP - dk_umlaut (ANS_1 ISO_3)
;SC   = VK      CS  S0  S1  S2      S6   S7  ; comments
```
Where:
* SC & VK: [Scan code ("hard code")][SCMSDN] & Virtual Key Code [("key name")][VKCAHK]; also see my [Key Code Table][KeyTab].
    - For SC, you can use an AHK key name instead. For full mappings I think you need the real VK name in the VK entry.
    - _Example:_ The above SC are for the `O` and `P` keys; these are mapped to their Colemak equivalents `Y` and `;`.
    - Check out that the ISO/ANSI specific `OEM_#` key numbers are right for you, or remapped with a VK remap.
    - _Example:_ `OEM_1` above is the semicolon key for ANSI, but ISO names the semicolon key `OEM_3`.
* CS: Cap state. Default 0; +1 if S1 is the capitalized version of S0 (that is, CapsLock acts as Shift for it); +4 for S6/S7.
    - _Example:_ For the `Y` key above, CS = 1 because `Y` is a capital `y`. For `OEM_1`, CS = 0 because `:` isn't a capital `;`.
* S#: Modifier states for the key. S0/S1:Unmodified/+Shift, S2:Ctrl (rarely used), S6/S7:AltGr/+Shift.
    - _Example:_ Shift+AltGr+`y` sends the `»` glyph. AltGr+`;` has the special entry `@13` (dk_umlaut).
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
Entries are any-whitespace delimited since v0.4.6 (PKL used to strictly require a single Tab character between entries).


DONE:
-----
These are some of the changes in PKL[eD]/[EPKL]:
* v0.4.0: Transition to AHK v1.1
	- A Refresh menu option with a hotkey (default Ctrl+Shift+5) in case the program hangs up in some way (stuck modifiers etc).
	- Advanced Mode setting that shows 'AHK key history' and other menu options, plus more info in the About... dialog.
	- Sensible dead key names for images and entries (e.g., @14 -> tilde) in a central file that layouts can point to.
	- A PKL_Tables.ini file for info tables that were formerly internal. This way, the user can make additions as necessary.
* v0.4.1: Transition to AHK v1.1 Unicode, using native Unicode Send and UTF-8 compatible files.
	- A base layout file can be specified, allowing layout.ini to only contain entries that should override the base layout.
* v0.4.2: Help image opacity, scaling, background color and gutter size settings. Help images can be pushed horizontally too.
	- Separate help image background/overlay, so keys/fingering, letters/glyphs and Shift/AltGr marks can be in different images.
* v0.4.3: Scan and virtual code modular remapping for layouts and Extend, making ergo and other variants much more accessible.
* v0.4.4: A Help Image Generator that uses Inkscape (separate download) to generate a set of help images from the current layout.
	- A shorthand notation in EPKL_Settings.ini to specify KbdType (ISO/ANSI), CurlMod and ErgoMod with the layouts.
* v0.4.5: Layouts, Extend and dead keys now support the same prefix-entry syntax, parsing "%$*=@&" as first character specially.
	- The "&" prefix denotes literals/powerstrings found in a separate file. These may span more than one line.
* v0.4.6: The base layout can hold default settings. Layout entries are now any-whitespace delimited.
	- Read most layout settings apart from remaps from the base layout if not found in the main layout.
	- Requiring Tab delimited layout entries was too harsh. Now, any combination of Space/Tab is allowed. For Space, use ={Space}.
* v0.4.7: Multi-Extend w/ 4 layers selectable by modifiers+Ext. Extend-tap-release. One-shot Extend layers.
	- Multi-Extend, allowing one Extend key with 2 modifiers (e.g., RAlt/RShift) to select up to 4 different layers. Ext+Mod{2/3/2+3} -> Ext2/3/4.
	- Ext2 is a NumPad/nav layer w/ some useful symbols. Ext3/Ext4 are one-shot string layers but mostly to be filled by the user.
	- Dual-role tap-release Extend key. Works as Back on tap within a certain time and Ext on hold. Set the time to 0 ms to disable it.
	- ExtReturnTo setting to allow one-shot Extend, e.g., for strings. Can for instance return from Ext3 to Ext1.
* v0.4.8: Sticky/One-shot modifiers. Tap the modifier(s), then within a certain time hit the key to modify.
	- Settings for which keys are OSM and the wait time. Stacking OSMs works (e.g., tap RShift, RCtrl, Left).
	- NOTE: Mapping LCtrl or RAlt as a Modifier causes trouble w/ AltGr. So they shouldn't be used as sticky mods or w/ Extend if using AltGr.
	- Powerstrings can have prefix-entry syntax too now. Lets you, e.g., have long AHK command strings referenced by name tags in layouts.
* v1.0.0: EPKL full release.


TODO:
-----
I have more [EPKL] changes on my wishlist, including:
* A timer that checks whether the underlying Windows layout has changed (affects dead keys) - and fixes any stuck modifiers?
* Sticky a.k.a. One-Shot modifiers: Press-release modifier, then within a certain time hit the key to modify.
* A settings panel instead of editing .ini files.
  
_Best of luck!_
_Øystein "DreymaR" Gadmar, 2019-01_


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
[EPKL]:   ./Files/ (EPKL Files folder/README)
