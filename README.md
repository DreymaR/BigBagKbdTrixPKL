DreymaR's Big Bag Of Keyboard Tricks
====================================

### For [PortableKeyboardLayout][PKLS] on Windows
#### (Written By Farkas Máté [(2008)][PKLA] using [AutoHotKey][AHKP])

Documentation
-------------

The info about DreymaR's Big Bag of keyboard trickery is mainly found on the Colemak forum:

* The [main Big Bag topic][CXKB] with better explanations and files for Linux using [XKB][XKBA].
* A [daughter topic][CPKL] with files for PKL/Windows.


Some Know-How-To
----------------

* PKL is easily run by putting its folder in a C:\PortableApps folder and using the [PortableApps.com][PORT] menu
* Also, I usually put a shortcut to pkl.exe in my Start Menu "Startup" folder so it starts on logon
* Alternatively, if the PortableApps menu is started on logon it can start up PKL for you too
* Such a shortcut works per user; otherwise you could also set PKL to start suspended by editing the pkl.ini file
* If you don't want any of that, just put the folder somewhere and run pkl.exe any way you like!
* **NOTE:** Running PKL with other AutoHotKey key mapping scripts may get confusing if there is "hook competition".

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
    * For [Scan Codes (SC###)][SCMS] and [Virtual Key names (VK##)][VKAH] see below.
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

* SC & VK: [Scan code ("hard code")][SCMS] & [Virtual Key Code ("key name")][VKAH]
* SS: Shift state (0 by default; +1 if L0/L1 are non-/shifted versions of the same letter; +4 for L3/L4)
* L0-L4: Standard modifier levels for the key: Unmodified, Shift, Ctrl (not often used), AltGr, Shift+AltGr

Look in the pkl.ini file if you're interested! Much is explained there.

The hotkeys I've set in my pkl.ini file are:

* Ctrl+Shift+` – suspend PKL
* Ctrl+Shift+1 – display/hide help image (these may not be updated for all layouts!)
* Ctrl+Shift+2 – switch layout between the ones specified in the pkl.ini file

**NOTE:**
---------
Do you have a traditional layout without a Wide/Angle modification and get the wrong Extend mappings on the right hand?

* If so, you should use a renamed copy of a pkl_###-NoErgoMods.ini as your pkl.ini
* If on the other hand you _do_ use a (Curl)AngleWide mod, base your pkl.ini file on a pkl_###-AngleWide.ini file
* In the [extend] section of pkl.ini there are some places you can paste code snippets copied from further down in the file
* Use/edit those snippets if you wish to use for instance an Angle mod but not a Wide mod or vice versa

TODO:
-----
I have several changes to PKL on my wishlist, but they require tweaking/recompiling the program. See 'PKL_DreymaR'.

* Next up: Multilayered help images, so the fingering can be in one image and the keys in another (saves file space, adds options)
* Scan and virtual code remapping, adding modularity. Making one layout for every ISO-ANSI/Angle/Curl/Wide/locale/etc variant is murder!
  
  
_Best of luck!_
_Øystein "DreymaR" Gadmar, 2017-08_


[PKLS]: http://pkl.sourceforge.net/ (PortableKeyboardLayout on SourceForge)
[PKLA]: https://autohotkey.com/board/topic/25991-portable-keyboard-layout/ (PKL on the AutoHotKey forums)
[AHKP]: https://autohotkey.com/ (AutoHotKey main page)
[CXKB]: http://forum.colemak.com/viewtopic.php?id=1438 (BigBagXKB on the Colemak forums)
[CPKL]: http://forum.colemak.com/viewtopic.php?id=1467 (BigBagPKL on the Colemak forums)
[XKBA]: https://wiki.archlinux.org/index.php/X_KeyBoard_extension (XKB info on the ArchLinux site)
[PORT]: https://portableapps.com/ (PortableApps.com)
[SCMS]: https://msdn.microsoft.com/en-us/library/aa299374(v=vs.60).aspx (Scan code list at MSDN)
[VKAH]: https://autohotkey.com/docs/KeyList.htm (Virtual key list in the AHK docs)
