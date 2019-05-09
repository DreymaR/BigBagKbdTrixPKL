DreymaR's Big Bag Of Keyboard Tricks - EPKL
===========================================

### [EPiKaL PortableKeyboardLayout][CmkPKL] for Windows, with layouts
#### ~ The original [PKL][PKLGit] written by [Farkas Máté in 2008][PKLSFo] using [AutoHotkey][PKLAHK]
#### ~ [EPKL][CmkPKL], formerly PKL[edition DreymaR] by DreymaR, 2017-

[Θώθ][ThothW] – What Is This?
-----------------------------

Info about DreymaR's Big Bag of keyboard trickery is mainly found on the Colemak forum:
* The [Big Bag main topic][CmkBBT] with better explanations and links.
* Daughter topics for implementations, including the [Big Bag for PKL/Windows][CmkPKL] one.
  
* This repo implements most of my Big Bag for (E)PKL, as layout and other .ini files.
* It also contains **EPiKaL PKL** (**[EPKL][EPKLRM]**) with several improvements over PKL.
* Big thanks to Farkas Máté, the AutoHotkey people, Vortex(vVv) and all other contributors.

Getting EPKL up and running
---------------------------

* Download a copy of this repo. For instance, press the GitHub Download/Clone button and then unzip the file you got.
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
* The layout.ini files hold layout settings and mappings. They often point to and augment a BaseLayout.ini file.
  
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
* In EPKL_Settings.ini you can use shorthand for KbdType, CurlMod and ErgoMod, or set the layout folder path directly.
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
* Ctrl+Shift+6 – Zoom the help image in/out, to see it better or get it out of the way
* Ctrl+Shift+7 – Move the help image between positions, as by mouseover
  
**Techy tips for EPKL:**
* Look in the various .ini files under Files and Layouts if you're interested! Much is explained there.
* See my examples in the Extend file for some advanced mappings! These may be used in layouts and dead keys too.
* EPKL uses both .ini and source files that may be UTF-8 Unicode encoded.
* EPKL allows end-of-line comments (whitespace-semicolon) in .ini files, but the original PKL only allows them in layout entries.
* Running EPKL with other (AutoHotkey) key mapping scripts may get confusing if there is so-called _hook competition_.

Layout variant tutorial
-----------------------

You can make your own version of, say, a locale layout with a certain (non-)ergonomic variant:
* Determine which keyboard type (ISO/ANS), ergo mod and if applicable, existing locale you want to start from.
* Determine whether you want to just move keys around by VirtualKey mappings or map all their shift states like Colemak-eD does.
* Copy/Paste a promising layout folder and rename the result to what you want.
    - In this example we'll make a German (De) Colemak[eD] with only the ISO-Angle mod instead of the provided CurlAngleWide.
    - Thus, copy `Cmk-eD-De_ISO_CurlAWide` in the `Layouts/Colemak-eD` folder and rename the copy to `Cmk-eD-De_ISO_Angle`.
    - Instead of 'De' you could choose any locale tag you like such as 'MyCoolDe' to set it apart.
* In that folder's layout.ini file, edit the remap fields to represent the new settings.
    - Here, change `mapSC_layout = CmkCAW_ISO` to `mapSC_layout = Angle_ISO`.
    - Some Extend layers like the main one use "hard" or positional remaps, which observe most ergo mods but not letter placements.
    - Here, `mapSC_extend = Angle_ISO` too since Angle is a "hard" ergo mod. (If using Curl-DH, you can move Ctrl+V by adding _ExtDV.)
* Change any key mappings you want to tweak.
    - The keys are mapped by their native Scan Codes (SC), so, e.g., SC02C is the QWERTY/Colemak Z key even if it's moved around later.
    - See the next section to learn more about key mapping syntax.
    - The mappings in the De layout are okay as they are, but let's say we want to swap V and Ö (OEM_102) for the sake of example.
    - In the `[layout]` section of layout.ini are the keys that are changed from the BaseLayout. OEM_102 is there, state 0/1 mapped to ö/Ö.
    - To find the V key, see the `baseLayout = Colemak-eD\BaseLayout_Cmk-eD_ISO` line and open that file. There's the V key, SC02f.
    - Now, copy the V key to your layout.ini `[layout]` section so it'll override the baseLayout, and swap the SC### codes of V and OEM_102.
    - Alternatively, you could just edit the mappings for the affected shift states of the two keys. Use any white space between entries.
* Now, if the EPKL_Settings.ini Kbd/Curl/Ergo/Locale settings are right you should get the variant you wanted.
    - Here, set KbdType/CurlMod/ErgoMod/LocalID to ISO/--/Angle/De respectively (or 'MyCoolDe' if you really went with that!).
    - If you used a VK layout or anything else than Colemak-eD as your path, comment out the `layout = ` line with `;` and activate another.
    - If you prefer, write the `layout = LayoutFolder:DisplayedName` entry directly instead, using the folder path from `Layouts\`.
* After making layout changes, refresh EPKL with the Ctrl+Shift+5 hotkey. If that doesn't work, quit and restart EPKL.
* To get updated help images, see the next point if you want to generate them using Inkscape.
    - First though, check around in the eD layout folders. Maybe there's something that works for you there despite a few minor differences?
    - Here, you might either keep the current De_ISO_CurlAWide settings to see the German special signs without making new images, or...
    - ...edit the image settings, replacing AWide/CAWide/CAngle with 'Angle' to get normal ISO_Angle images without German letters, or...
    - ...edit the help images in an image editor, combining the ones you need. I use Gimp for such tasks.
* If you do want to generate a set of help images from your layout you must get Inkscape and run the EPKL Help Image Generator (HIG).
    - To see the "Create help images..." menu option, advancedMode must be on in EPKL_Settings.
    - The HIG will make images for the currently active layout.
    - You can download Inkscape for instance from PortableApps.com, and point to it in the `Files\ImgGenerator\EPKL_ImgGen_Settings.ini` file.
    - By default, the HIG looks for Inkscape in `C:\PortableApps\InkscapePortable\InkscapePortable.exe`, so you could just put it there.
    - I recommend making state images only at first, since a full set of about 80 dead key images takes a _long_ time!

Key mappings
------------

Most of my layouts have a base layout defined; their layout section then changes some keys. You can add key definitions following this pattern.
  
Here are some full key mappings followed by a legend:
```
SC018 = Y       1     y     Y     --    ›     »     ; QWERTY oO
SC019 = OEM_1   0     ;     :     --    @0a8  …     ; QWERTY pP - dk_umlaut (ANS/ISO_1/3)
;SC   = VK      CS    S0    S1    S2    S6    S7    ; comments
```
Where:
* SC & VK: [Scan code ("hard code")][SCMSDN] & Virtual Key Code [("key name")][VKCAHK]; also see my [Key Code Table][KeyTab].
    - For SC, you can use an AHK key name instead. For full mappings I think you need the real VK name in the VK entry.
    - _Example:_ The above SC are for the `O` and `P` keys; these are mapped to their Colemak equivalents `Y` and `;`.
    - Check out that the ISO/ANSI specific `OEM_#` key numbers are right for you, or remapped with a VK remap.
    - _Example:_ `OEM_1` above is the semicolon key for ANSI, but ISO names the semicolon key `OEM_3`.
    - If the VK entry is VK/ModName, that key is Tap-or-Mod. If tapped it works as stated, if held down it's the modifier.
    - The VK code may be an AHK key name. For modifiers you may use only the first letters, so LSh -> LShift etc.
* CS: Cap state. Default 0; +1 if S1 is the capitalized version of S0 (that is, CapsLock acts as Shift for it); +4 for S6/S7.
    - _Example:_ For the `Y` key above, CS = 1 because `Y` is a capital `y`. For `OEM_1`, CS = 0 because `:` isn't a capital `;`.
* S#: Modifier states for the key. S0/S1:Unmodified/+Shift, S2:Ctrl (rarely used), S6/S7:AltGr/+Shift.
    - _Example:_ Shift+AltGr+`y` sends the `»` glyph. AltGr+`;` has the special entry `@13` (umlaut DK).
* Special prefix-entry syntax (can be used for layouts, Extend and dead key entries):
    - %‹entry› : Send a literal string/ligature by the SendInput {Raw}‹entry› method (default)
    - $‹entry› : Send a literal string/ligature by the SendMessage ‹entry› method
    - *‹entry› : Send ‹entry› directly, allowing AHK syntax (!+^# mods, {} key names)
    - =‹entry› : Send {Blind}‹entry›, keeping the current modifier state
    - ~‹entry› : Send the 4-digit hex Unicode point U+<entry>
    - @‹entry› : Send the current layout's dead key named ‹entry›
    - &‹entry› : Send the current layout's powerstring named ‹entry›
    - Spc/Tab  : Send a blind Space or Tab; these have special entries since they also delimit columns
  
Here are some VirtualKey (VK) and Modifier mappings. Any layout may contain all types of mappings.
```
RWin    = Back      VirtualKey      ; RWin   -> Backspace
RShift  = LShift    Modifier        ; RShift -> LShift, so it works with LShift hotkeys
SC149   = NEXT      VirtualKey      ; PgUp   -> PgDn (needed the VKEY name here)
SC151   = PRIOR     VirtualKey      ; PgDn   -> PgUp (--"--)
SC03A   = Extend    Modifier        ; Caps   -> The Extend modifier (see the Big Bag)
SC03A   = BACK/Ext  VirtualKey      ; Caps   -> Tap-or-Mod (a.k.a. Dual-Role Mod): Backspace if tapped, Extend if held
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
	- Requiring Tab delimited layout entries was too harsh. Now, any combination of Space/Tab is allowed.
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
* v1.1.0: Some layout format changes. Minor fixes/additions. And kaomoji!  ♪～└[∵┌]└[･▥･]┘[┐∵]┘～♪
	- A set of 30+ Kaomoji text faces were added to the Strings Extend3 layer, with help images.  d( ^◇^)b
	- Extend layers can now be marked as hard/positional or soft/mnemonic. Extend1/2 are mostly hard, the kaomoji layer soft.
	- Direct Extend key mapping, e.g., for CapsLock use 'SC03A = Extend Modifier' instead of the old extend_key setting.
	- BaseLayout files are now at the same tree level as layout folders instead of inside one of them.
* v1.1.1: Some format changes. Minor fixes/additions. Tap-or-Mod keys (WIP).
	- New: Tap-or-Modifier a.k.a. Dual-Role Modifier keys. Work-in-progress, not working well for rapidly typed keys yet.
		- To make a ToM key, specify its VK layout entry as VK/Mod, where 'Mod' is a modifier name. The rest of the line can be any valid entry.
	- The Extend key can be set the old way as extend_key in [pkl] (but no layout entry is needed anymore!), as 'Ext Mod' or as ToM, e.g., 'VK/EXT VKey'
	- Modifiers can be referred to by the first letters of their name so, e.g., 'LS' and 'LSh' both point to LShift. Also, VK or VKey = VirtualKey.
	- Unicode points can be sent by the ~ prefix; a ~#### entry sends the U+#### character as used in MSKLC file entries.
	- The shiftStates layout entry is now in the [layouts] section of layout.ini, spaced out so entries have more room and are clearer.
	- Since Space/Tab are used to delimit layout entries, there are now special '&Spc' and '&Tab' PowerString entries for them.
	- Dead key abbreviations are now by code point instead of numbered, as in MSKLC. Example: The .klc entry 02c7@ is a caron DK; in EPKL it becomes @2c7.


TODO:
-----
I have more [EPKL] changes on my wishlist, including:
* A timer that checks whether the underlying Windows layout has changed (affects dead keys) - and fixes any stuck modifiers?
* Generic dual-role keys and/or modifiers. For instance, home row keys might act as modifiers when held and letters when tapped.
* Chainable dead keys, allowing for instance a Mother-of-DKs key for Compose-like "tap dance" sequences like {MoDK,t,n}->ñ.
* A settings panel instead of editing .ini files.
* An import module for MSKLC layout files.
  
_Best of luck!_
_Øystein "DreymaR" Gadmar, 2019-03_


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
[EPKLRM]: ./Files/ (EPKL Files folder/README)
[ThothW]: https://en.wikipedia.org/wiki/Thoth (Thoth: Egyptian god of wisdom and writing)
