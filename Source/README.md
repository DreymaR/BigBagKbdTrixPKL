DreymaR's Big Bag Of Keyboard Tricks - EPKL
===========================================

### For [PortableKeyboardLayout][PKLGit] on Windows
#### ([Written By Farkas Máté in 2008][PKLSFo] using [AutoHotkey][PKLAHK])
#### ([EPiKaL PKL][CmkPKL], formerly PKL[edition DreymaR] by DreymaR, 2017-)

Source code info
----------------

This is the source code README, briefly explaining how to compile PKL/EPKL with AHK.

Info about DreymaR's Big Bag of keyboard trickery is mainly found on the Colemak forum:

* The [Big Bag main topic][CmkBBT] with better explanations and links.
* Daughter topics for implementations, including the [Big Bag for PKL/Windows][CmkPKL] one.

* The [EPKL][EPKLRM] source code is based on a decompiled PKL v0.4preview (formerly v0.3r85).

Compiling
---------

* To compile the (E)PKL source code, use the Ahk2Exe compiler from the [AHK download page][AHKDld].
* AHK compiler v1.1 Unicode is needed for EPKL; v1.0 and v1.1 in ANSI mode work for the original PKL.
* There's a folder in Source that contains the v1.1 AHK compiler.
* Choose the right Source\#.ahk file, EPKL or PKL_Orig.
* Choose to compile into your main PKL folder.
* You may choose any name for the .exe and run it afterwards.
* Choose Source\Resources\Main.ico as the custom icon file.

Setup:
------

1. Just compile right into your main PKL folder, or move the resulting .exe file there.
2. Adjust any extra settings in the layout.ini file in your layout folder.
   See the Colemak-eD_ISO layout.ini and baseLayout.ini files as examples.
3. For generic EPKL settings, look in the Files folder, and the EPKL_Settings.ini file.
  
  
_Best of luck!_
_Øystein "DreymaR" Gadmar, 2018-_


[PKLGit]: https://github.com/Portable-Keyboard-Layout/Portable-Keyboard-Layout/ (PKL on GitHub)
[PKLSFo]: https://sourceforge.net/projects/pkl/ (PKL on SourceForge)
[PKLAHK]: https://autohotkey.com/board/topic/25991-portable-keyboard-layout/ (PKL on the AutoHotkey forums)
[AHKHom]: https://autohotkey.com/ (AutoHotkey main page)
[AHKDld]: https://autohotkey.com/download/ (AutoHotkey download page)
[CmkBBT]: https://forum.colemak.com/topic/2315-dreymars-big-bag-of-keyboard-tricks-main-topic/ (BigBagOfKbdTrix on the Colemak forums)
[CmkPKL]: https://forum.colemak.com/topic/1467-dreymars-big-bag-of-keyboard-tricks-pklwindows-edition/ (BigBag-PKL on the Colemak forums)
[EPKLRM]: ./Files/ (EPKL Files folder/README)
