DreymaR's Big Bag Of Keyboard Tricks - PKL[eD]
==============================================

### For [PortableKeyboardLayout][PKLSFo] on Windows
#### (Written By Farkas Máté [(2008)][PKLAHK] using [AutoHotkey][AHKHom])

Documentation
-------------

Info about DreymaR's Big Bag of keyboard trickery is mainly found on the Colemak forum:

* The [Big Bag main topic][CmkBBT] with better explanations and links.
* Daughter topics for implementations, including the [Big Bag for PKL/Windows][CmkPKL] one.

* This repo implements most of my Big Bag for PKL, as layout and PKL .ini files.
* It also adds my own PKL - edition DreymaR (PKL[eD]) with several improvements.
* Big thanks to Farkas Máté, the AutoHotkey people, Vortex(vVv) and all other contributors.

Some Know-How-To
----------------

* The repo contains executables for the original PKL as well as PKL[eD], and source code for both.
* PKL is easily run by putting its folder in a C:\PortableApps folder and using the [PortableApps.com][PrtApp] menu
* Also, I usually put a shortcut to PKL.exe in my Start Menu "Startup" folder so it starts on logon, per user
* Alternatively, if the PortableApps menu is started on logon it can start up PKL for you too
* If you don't want any of that, just put the folder somewhere and run PKL.exe any way you like!
* **NOTE:** To make many PKL_eD changes work, your PKL settings .ini and layout.ini files need extra settings.
* **NOTE:** Running PKL with other AutoHotkey key mapping scripts may get confusing if there is hook competition.

These PKL files may take a little tweaking to get what you want. Remember, there are several parameters:

* The PKL_Settings.ini file holds layout choices. The layout.ini files hold layout settings and mappings.
* ISO (European/World) vs ANSI (US) vs other keyboard types
	* These differ notably in the VK_102 key at the lower left, and some of the OEM_ key codes
	* I haven't supported JIS (Japanese) etc so far - sorry
* QWERTY vs Colemak vs what-have-you, obviously. Choose wisely!
* Full/VK mappings: I've provided my own Colemak[eD] as well as 'VirtualKey' versions
	* The 'VK' layouts just move the keys of your installed OS layout around, without other changes
	* The [eD] layouts have their own Shift/AltGr mappings specified. You may mix types if you want.
* Curl(DH), Angle and/or Wide ergonomic mods, moving some keys to more comfortable positions
	* Angle/Wide affect the "hard" key positions in the layout.ini file, usually both for Layout and Extend
	* Curl(DH) is Colemak/Tarmak specific and for the most part should not affect Extend
* Extend mappings, using for instance CapsLock as a modifier for nav/edit/multimedia/etc keys. It's awesome!!!
* In PKL .ini you can use a shorthand specifying KbdType, CurlMod and ErgoMod, or use the layout folder name directly.
* In layout.ini you can specify in the [eD_info] section some remaps that turn one layout into a modded one, and more.

Setup:
------
0. Set your Curl/Angle/Wide preferences and keyboard type (ANSI/ISO), and then a layout shorthand or full name:
1. In PKL_Settings.ini, activate the layout(s) you want by uncommenting (remove initial semicolon) and/or editing.
    * The format is: layout = <1st layout folder name>:<name you want in menu>,<2nd layout folder>:<2nd menu entry> etc
2. If you need to tweak some Extend mappings, they're now in a separate file usually found in the PKL_eD folder.
    * For [Scan Codes (SC###)][SCMSDN] and [Virtual Key names (VK##)][VKCAHK] see below.
3. In the layout folder(s) you've chosen, you may edit further if required.
    * Locale variants are available in some colemak-eD_ISO folders, by un-/commenting lines of a layout_#.ini file.
    * Check out that the ISO/ANSI OEM_# key numbers in your layout.ini are right for you, or remapped with a VK remap.
    * Help image sizes, Extend key, key mappings etc are in the layout.ini file.
4. Layout help images aren't always available with the right ergo mod and keyboard type. Sorry, I'm working on that.

Here are the columns of a full key mapping together with a sample key – semicolon (QWERTY P) from one of my layout.ini files:
```
SC01a = OEM_3   0   ;   :   --  dk13    …   ; QWERTY pP - dk_umlaut
SC    = VK      SS  L0  L1  L2  L3      L4  ; comments
```

Where:
* SC & VK: [Scan code ("hard code")][SCMSDN] & [Virtual Key Code ("key name")][VKCAHK]; see my [Key Code Table][KeyTab].
* SS: Shift state (0 by default; +1 if L0/L1 are non-/shifted versions of the same letter; +4 for L3/L4)
* L0-L4: Standard modifier levels for the key: Unmodified, Shift, Ctrl (not often used), AltGr, Shift+AltGr

Look in the PKL .ini files if you're interested! Much is explained there.

Some of the hotkeys I've set in my PKL settings file are:
* Ctrl+Shift+1 – Display/hide help image (these may not be updated for all layouts!)
* Ctrl+Shift+2 – Switch layout between the ones specified in the settings file
* Ctrl+Shift+3 – Suspend PKL (hit again to re-activate)
* Ctrl+Shift+4 – Exit PKL
* Ctrl+Shift+5 – Refresh PKL (if it gets stuck or something)


**NOTES:**
---------
Do you have a traditional layout without a Wide/Angle modification and get the wrong Extend mappings on the right hand?
* If so, you should set a PKL .ini layout that fits your preferred mod or lack of it.
* Maybe all the layout files aren't quite updated with remaps yet. Check out a base one like Colemak-eD_ISO.

Anti-madness tips for PKL file editing:
* In layout.ini:
    - Always use tabs as separators.
    - After 'VirtualKey' always append a tab.
    - The CapsLock key should have scan code 'CapsLock' instead of SC03A?
* In Extend sections: Don't use empty mappings; comment these out. See my examples for advanced mappings like hotstrings!
* PKL_eD uses both .ini and source files that may be UTF-8 Unicode encoded.
* Don't use end-of-line comments in the original PKL's .ini files, except layout.ini. PKL_eD allows them in all .ini files.

DONE:
-----
These changes are now implemented in [PKL_eD]:
* Help image opacity, scaling, background color and gutter size settings. Help images can be pushed horizontally too.
* Separate help image background/overlay, so keys/fingering, letters/glyphs and Shift/AltGr indicators can be in different images.
* Various menu and language file improvements and additions.
* A Refresh menu option with a hotkey (default Ctrl+Shift+5) in case the program hangs up in some way (stuck modifiers etc).
* DebugInfo setting that shows 'Key history...' and 'Refresh program' menu items and OS layout/deadkey info in the About... dialog.
* A PKL_Tables.ini file for info tables that were formerly internal. This way, the user can make additions as necessary.
* Sensible dead key names for images and entries (e.g., dk14 -> tilde) in a central file that layouts can point to.
* A base layout file can be specified, allowing layout.ini to only contain entries that should override the base layout.
* Scan and virtual code modular remapping for layouts and Extend, making ergo and other variants much easier.
* The settings/layout and Extend parts of PKL.ini are now split into separate files.
* There's a shorthand notation in PKL_Settings.ini to specify KbdType (ISO/ANSI), CurlMod and ErgoMod with the layout(s).


TODO:
-----
I have several [PKL_eD] changes on my wishlist, including:
* A timer that checks whether the underlaying Windows layout has changed (affects dead keys) - and fixes any stuck modifiers?
* Multiple Extend layers
* Automatic help image generation based on layouts
* A settings panel instead of editing .ini files.
  
_Best of luck!_
_Øystein "DreymaR" Gadmar, 2018-03_


[PKLSFo]: http://pkl.sourceforge.net/ (PortableKeyboardLayout on SourceForge)
[PKLAHK]: https://autohotkey.com/board/topic/25991-portable-keyboard-layout/ (PKL on the AutoHotkey forums)
[AHKHom]: https://autohotkey.com/ (AutoHotkey main page)
[CmkBBT]: https://forum.colemak.com/topic/2315-dreymars-big-bag-of-keyboard-tricks-main-topic/ (BigBagOfKbdTrix on the Colemak forums)
[CmkPKL]: https://forum.colemak.com/topic/1467-dreymars-big-bag-of-keyboard-tricks-pklwindows-edition/ (BigBag-PKL on the Colemak forums)
[PrtApp]: https://portableapps.com/ (PortableApps.com)
[SCMSDN]: https://msdn.microsoft.com/en-us/library/aa299374(v=vs.60).aspx (Scan code list at MSDN)
[VKCAHK]: https://autohotkey.com/docs/KeyList.htm (Virtual key list in the AHK docs)
[KeyTab]: ./Other/KeyCodeTable.txt (./Other/KeyCodeTable.txt)
[PKL_eD]: ./PKL_eD/ (PKL[eD] folder/README)