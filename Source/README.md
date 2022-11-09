DreymaR's Big Bag Of Keyboard Tricks - EPKL
===========================================
<br>

### [EPiKaL PKL][CmkPKL] for Windows
#### Formerly PKL[edition DreymaR] by DreymaR, 2017-, based on [PortableKeyboardLayout][PKLGit]
#### ([Written By Máté Farkas in 2008][PKLSFo] using [AutoHotkey][PKLAHK])

![EPKL help image, for the Colemak-CAWS layout](/Layouts/Colemak/Cmk-ISO-CAWS_s3_EPKL.png)

<br>

EPKL versions
-------------
EPKL was based on a decompiled PKL v0.4preview from 2010 (formerly v0.3r85) by Máté Farkas.

I started development in 2014, and since then EPKL has come a long way.

A comprehensive EPKL version history is found in the actual [EPKL Source folder][EPKLsc].
<br>

Source code info
----------------
This is the source code README, briefly explaining how to compile PKL/EPKL with AHK2EXE.

To this purpose, there's a [Compile_EPKL.bat][MakExe] file that makes and runs EPKL.exe.
<br>

Compiling manually
------------------
* To compile the (E)PKL source code, use the Ahk2Exe compiler from the [AHK download page][AHKDld].
* AHK compiler v1.1 Unicode is needed for EPKL; v1.0 and v1.1 in ANSI mode work for the original PKL.
* There's a folder in Source that contains the v1.1 AHK compiler. You may need that version.
* Choose the Source\EPKL.ahk file.
* Choose to compile into your main EPKL folder.
* You may choose any name for the .exe and run it afterwards.
* Choose Source\EPKL_Resources\Main.ico as the custom icon file.  
<br>

Setup:
------
1. Just compile right into your main EPKL folder, or move the resulting .exe file there.
2. Adjust any extra settings in the layout.ini file in your layout folder.
   See the Colemak-eD_ISO layout.ini and baseLayout.ini files as examples.
3. For generic EPKL settings, look in the Files folder, and the EPKL_Settings .ini file(s).
   Or, you can use the EPKL Layout/Settings menu to change stuff.
4. Changes should ideally go in `_Override.ini` files instead of the Default files.
  

_Best of luck!_
_Øystein "DreymaR" Bech-Aase, 2018-_

[PKLGit]: https://github.com/Portable-Keyboard-Layout/Portable-Keyboard-Layout/ (PKL on GitHub)
[PKLSFo]: https://sourceforge.net/projects/pkl/ (PKL on SourceForge)
[PKLAHK]: https://autohotkey.com/board/topic/25991-portable-keyboard-layout/ (PKL on the AutoHotkey forums)
[AHKHom]: https://autohotkey.com/ (AutoHotkey main page)
[AHKDld]: https://autohotkey.com/download/ (AutoHotkey download page)
[MakExe]: /Compile_EPKL.bat (Compile_EPKL batch file)
[BBTind]: https://dreymar.colemak.org/ (DreymaR's Big Bag of Keyboard Tricks)
[CmkPKL]: https://forum.colemak.com/topic/1467-dreymars-big-bag-of-keyboard-tricks-pklwindows-edition/ (BigBag-PKL on the Colemak forums)
[EPKLsc]: /Source/EPKL_Source/  (EPKL_Source folder/README)
