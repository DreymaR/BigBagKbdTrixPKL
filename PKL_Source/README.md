DreymaR's Big Bag Of Keyboard Tricks - PKL[eD]
==============================================

### For [PortableKeyboardLayout][PKLSFo] on Windows
#### (Written By Farkas Máté [(2008)][PKLAHK] using [AutoHotkey][AHKHom])

Source code info
----------------

Info about DreymaR's Big Bag of keyboard trickery is mainly found on the Colemak forum:

* The [Big Bag main topic][CmkBBT] with better explanations and links.
* Daughter topics for implementations, including the [Big Bag for PKL/Windows][CmkPKL] one.

* The [PKL_eD] source code is based on a decompiled PKL v0.4preview (formerly v0.3r85).

Compiling
---------

* For standard non-Unicode PKL versions, use the Ahk2Exe compiler from the [AHK download page][AHKDld].
* AHK compiler v1.1 Unicode is needed for PKL_eD now; v1.0 and v1.1 in ANSI mode work for original PKL.
* There's a folder in PKL_Source that contains the v1.1 AHK compiler.
* Choose the right PKL_Source\PKL_#.ahk file, eD or orig.
* Choose to compile into your main PKL folder.
* You may choose any name for the .exe and run it afterwards.
* Choose PKL_Source\Resources\Main.ico as the custom icon file.

Setup:
------

1. Just compile right into your main PKL folder, or move the resulting .exe file there.
2. For PKL[eD], adjust any extra settings in the layout.ini file in your layout folder.
   There's a sample [eD] layout.ini file in the Colemak-eD_ISO_CurlAWide layout folder.
3. For generic PKL[eD] settings, look in the PKL_eD folder, and the PKL.ini file.
  
  
_Best of luck!_
_Øystein "DreymaR" Gadmar, 2018-03_


[PKLSFo]: http://pkl.sourceforge.net/ (PortableKeyboardLayout on SourceForge)
[PKLAHK]: https://autohotkey.com/board/topic/25991-portable-keyboard-layout/ (PKL on the AutoHotkey forums)
[AHKHom]: https://autohotkey.com/ (AutoHotkey main page)
[AHKDld]: https://autohotkey.com/download/ (AutoHotkey download page)
[CmkBBT]: https://forum.colemak.com/topic/2315-dreymars-big-bag-of-keyboard-tricks-main-topic/ (BigBagOfKbdTrix on the Colemak forums)
[CmkPKL]: https://forum.colemak.com/topic/1467-dreymars-big-bag-of-keyboard-tricks-pklwindows-edition/ (BigBag-PKL on the Colemak forums)
[PKL_eD]: ./PKL_eD/ (PKL[eD] folder/README)