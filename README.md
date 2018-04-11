DreymaR's Big Bag Of Keyboard Tricks - PKL[eD]
==============================================

### For [PortableKeyboardLayout][PKLSFo] on Windows
#### (Written By Farkas Máté [(2008)][PKLAHK] using [AutoHotkey][AHKHom])

Documentation
-------------

Info about DreymaR's Big Bag of keyboard trickery is mainly found on the Colemak forum:

* The [Big Bag main topic][CmkBBT] with better explanations and links.
* Daughter topics for implementations, including the [Big Bag for PKL/Windows][CmkPKL] one.

* This repo implements most of my Big Bag for PKL, as layout and pkl.ini files.
* It also adds my own PKL - edition DreymaR (PKL[eD]) with some improvements (hopefully!).
* Big thanks to Farkas Máté, the AutoHotkey people, Vortex(vVv) and all other contributors.

Some Know-How-To
----------------

* The repo contains executables for the original PKL as well as PKL[eD], and source code for both.
* PKL is easily run by putting its folder in a C:\PortableApps folder and using the [PortableApps.com][PrtApp] menu
* Also, I usually put a shortcut to pkl.exe in my Start Menu "Startup" folder so it starts on logon
* Alternatively, if the PortableApps menu is started on logon it can start up PKL for you too
* Such a shortcut works per user; otherwise you could also set PKL to start suspended by editing the pkl.ini file
* If you don't want any of that, just put the folder somewhere and run pkl.exe any way you like!
* **NOTE:** To get the PKL_eD changes working, your layout folder must contain a DreymaR_layout.ini file.
    * A copy of this file should be visible from the PKL_eD folder, but it may actually reside in a layout folder.
* **NOTE:** Running PKL with other AutoHotkey key mapping scripts may get confusing if there is "hook competition".

These PKL files may take a little tweaking to get what you want. Remember, there are several parameters:

* ISO (European/World) vs ANSI (US) vs other keyboard types
	* These differ notably in the VK_102 key at the lower left, and some of the OEM_ key codes
	* I haven't supported JIS (Japanese) etc so far - sorry
* QWERTY vs Colemak vs what-have-you, obviously (choose wisely!)
* AltGr mappings: I've provided my own Colemak[eD] as well as 'VirtualKey' versions
	* These 'vk_' layouts just move the keys of your installed OS layout around, without other changes
	* Thus, the [eD] layouts will have their own AltGr mappings, but the vk_ ones have only the OS layout mappings
* Angle and/or Wide ergonomic mods, moving the ZXCVB and right-hand keys to more comfortable positions
	* Such mods affect the "hard" key positions in both the layout.ini file and pkl.ini
	* In pkl.ini there are some snippets at the end to copy/paste in place further up
	* Also, there are wide and nonwide pkl.ini template files to choose from; copy/rename to 'pkl.ini' to use
* Colemak-Curl(DH) ergonomic mods, a further tweak to get the D and H keys to more comfortable positions
* Extend mappings, using for instance CapsLock as a modifier
	* I use these to get arrow/editing and multimedia keys on the main block, and much more! It's awesome!!!

Setup:
------
1. Select a pkl_<ErgoMod>.ini file that suits your Curl/Angle/Wide preferences and keyboard type (ANSI/ISO), and rename it to pkl.ini
2. In this pkl.ini file, activate the layout(s) you want by uncommenting (remove initial semicolon) and/or editing.
    * The format is: layout = <1st layout folder name>:<name you want in menu>,<2nd layout folder>:<2nd menu entry> etc
3. If you need to tweak some Extend mappings, they're below in this file.
    * For [Scan Codes (SC###)][SCMSDN] and [Virtual Key names (VK##)][VKCAHK] see below.
4. In the layout folder(s) you've chosen, you may edit further if required.
    * Locale variants are available in the colemak-eD_ISO folder at least, by renaming and editing a layout_#.ini file.
    * ISO/ANSI OEM_# key numbers are different. So check out that they're right for your needs in your layout.ini file.
    * Help image sizes, Extend key, key mappings etc are in the layout.ini file.
5. Layout help images aren't always available with the right ergo mod and keyboard type. Sorry, I'm working on that.

Here are the columns of a full key mapping together with a sample key – semicolon (QWERTY P) from one of my layout.ini files:
```
SC01a = OEM_3   0   ;   :   --  dk13    …   ; QWERTY pP - dk_umlaut
SC    = VK      SS  L0  L1  L2  L3      L4  ; comments
```

Where:
* SC & VK: [Scan code ("hard code")][SCMSDN] & [Virtual Key Code ("key name")][VKCAHK]; see my [Key Code Table][KeyTab].
* SS: Shift state (0 by default; +1 if L0/L1 are non-/shifted versions of the same letter; +4 for L3/L4)
* L0-L4: Standard modifier levels for the key: Unmodified, Shift, Ctrl (not often used), AltGr, Shift+AltGr

Look in the pkl.ini file if you're interested! Much is explained there.

Some of the hotkeys I've set in my pkl.ini file are:
* Ctrl+Shift+` – suspend PKL
* Ctrl+Shift+1 – display/hide help image (these may not be updated for all layouts!)
* Ctrl+Shift+2 – switch layout between the ones specified in the pkl.ini file
* Ctrl+Shift+4 – exit PKL


**NOTES:**
---------
Do you have a traditional layout without a Wide/Angle modification and get the wrong Extend mappings on the right hand?
* If so, you should use a renamed copy of a pkl_###-NoErgoMods.ini as your pkl.ini
* If on the other hand you _do_ use a (Curl)AngleWide mod, base your pkl.ini file on a pkl_###-AngleWide.ini file
* In the [extend] section of pkl.ini there are some places you can paste code snippets copied from further down in the file
* Use/edit those snippets if you wish to use for instance an Angle mod but not a Wide mod or vice versa

Anti-madness tips for PKL file editing:
* Don't use end-of-line comments in the .ini files. It's OK in layout.ini only [for now].
* In layout.ini:
    - Always use tabs as separators.
    - After 'VirtualKey' always include a tab.
    - The CapsLock key should have scan code 'CapsLock' instead of SC03A?
* In the pkl.ini Extend section: Don't have empty mappings in the Extend section; comment these out.
* PKL uses .ini files that may be UTF-8 encoded, unlike the source code files which must be ANSI encoded [for now].

DONE:
-----
These changes are now implemented in [PKL_eD]:
* Help image opacity, background color and gutter size settings
* Separate help image background, so the keys/fingering can be in one image and the glyphs in another (saves file space, adds options)
* Various menu and language file improvements and additions.
* A Refresh menu option with a hotkey (default Ctrl+Shift+5) in case the program hangs up in some way (stuck modifiers etc).
* DebugInfo setting that shows 'Key history...' and 'Refresh program' menu items and OS layout/deadkey info in the About... dialog.
* A PKL_Tables.ini file for info tables that were formerly internal. This way, the user can make additions as necessary.
* Sensible dead key names for images and entries (e.g., dk14 -> tilde) in a central doc that layouts can point to.

TODO:
-----
I have several [PKL_eD] changes on my wishlist, including:
* Unicode mode, like PKL-Vortex by vVv
* Scan and virtual code remapping, adding modularity. Making one layout for every ISO-ANSI/Angle/Curl/Wide/locale/etc variant is murder!
* A timer that checks whether the underlaying Windows layout has changed (affects dead keys) - and fixes any stuck modifiers?
* Multiple Extend layers
  
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