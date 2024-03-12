DreymaR's Big Bag Of Keyboard Tricks - EPKL
===========================================
<br>

Microsoft Keyboard Layout Creator, alias MSKLC
----------------------------------------------
The files in this folder aren't for EPKL but for Microsoft's MSKLC program.
- MSKLC setup packages is the standard Windows way of implementing and installing system keyboard layouts.
- I actually use both a MSKLC layout (see the enclosed [.KLC file][MyCAWS]) and EPKL on my computer.
- This is because EPKL, while very powerful and versatile, doesn't always play well with low-level keyboard things.
	- These include command interpreters such as the WSL Bash one and Windows PowerShell, and many games.
	- EPKL sends state mapped glyphs as Key Down-then-Up events, so repeats will contain Up events which may mess up gaming.
	- To keep things smooth, EPKL can auto-suspend itself whenever these programs are active. See the `EPKL_Settings` file.
<br>

- MSKLC can be installed from [Microsoft's Download Center][MSKLCd]. With it you can look at existing Win layouts and make new ones.
- This is Microsoft's own tool for generating installable layouts. It was made chiefly for creating QWERTY locale variants.
- As such, it's a bit limited and confusing. Actually, the underlying code can do a lot more but the user interface has limits.
- One such limit is that VK (VirtualKey) codes aren't shown in the GUI. These affect system shortcuts such as `Ctrl+<letter>`.
- If you dabble in layout editing with MSKLC, you may have to edit your .klc file directly to get VK codes right.
- For a good guide to basic and advanced MSKLC usage, see [Henri's MSKLC Guide][MSKLCg].
	- In Henri's guide you'll also learn to do advanced stuff like swapping system keys (e.g., CapsLock-to-Backspace).
	- If you're eager to map CapsLock to Backspace though, please do consider that EPKL's Extend is so very much better!!!
<br>

- **NB: RESTART REQUIRED!!!**
- I apologize for shouting, but even though I've mentioned this further down the page, it's still the most common MSKLC beginner's mistake.
- So please: Before you go and ask what's wrong with your file or something, make sure you did a full system restart after installing.
- If it still doesn't work after a restart, consult the rest of this page and Henri's guide for more info.
<br>

Colemak-eD for MSKLC
--------------------
Included are MSKLC installs for my Colemak-eD mappings, both for vanilla Colemak and the Cmk-CAWS ergonomic layout variant.
- What you'll get is Colemak with most of the [Colemak[eD] AltGr/deadkey][BBeDdk] layer mappings.
- The CAWS variant uses the [**C**url(DH), **A**ngle**W**ide and **S**ym][BBergo] ergonomic mods.
- The Angle mod used is the simple ISO-Angle mod for the ISO install, and the most common ANSI-Angle(Z) mod for the ANSI install.
- I cannot add all possible ergo mod and variant combinations as easily as with EPKL, since KLC layouts aren't modular in nature.
- If you wish another variant you could move the keys around in the relevant `.klc` file and compile it as described above.
	- For that, I'd recommend changing the SC codes at the start of the mapping lines for moving keys around. Avoid duplicates.
<br>

- [Link to the vanilla Cmk-eD installer archive][CmkeDi]
- [Link to the Cmk-CAWS-eD-ANS installer archive][CAWSAi]
- [Link to the Cmk-CAWS-eD-ISO installer archive][CAWSIi]
<br>

![Colemak-CurlAWideSym on an ISO board, ground state](/Layouts/Colemak/Cmk-ISO-CAWS_s0_EPKL.png)

_Colemak-CurlAngleWideSym layout, alias Cmk-CAWS, on an ISO keyboard._<br>_Ground state. The `œ` key is ISO-only; on an ANSI board that positions holds `Z`._

<br>

![Colemak-CurlAWideSym on an ISO board, AltGr state](/Layouts/Colemak/Cmk-ISO-CAWS_s6_EPKL.png)

_Colemak-CurlAngleWideSym layout, alias Cmk-CAWS, on an ISO keyboard._<br>_AltGr state. Dead keys marked in yellow._

<br>

Installing a MSKLC Layout
-------------------------
- To install a layout from a `.klc` file, it must first be compiled using the `Build DLL and Setup Package` menu option in MSKLC.
- To install a compiled layout, run the `setup.exe` program in its folder. Setup will choose the right `.msi` and `.dll` for you.
- The keyboard verify log may well give a lot of warnings about glyphs being defined twice etc; these don't matter.
- If you have the layout already on your system – let's say you've edited it a little – you must **uninstall** it before compiling.
- **NOTE: You have to restart your computer** before you can choose the newly installed layout! Really!
<br>

- Now you can select the new layout from `Language preferences` (in the tray menu if you have the Language Bar active)
- To see the settings for keyboard layouts in Windows 10, go to the `Settings -> Time & Language -> Language` settings screen.
	- To activate the language bar: `Language -> Keyboard [icon] -> Language bar options` (depending on Win version)
	- To see an installed layout: `Language -> <your layout's language, such as English (United States)> -> Options -> Keyboards`.
- To easily switch between active layouts: Hit Win+Space.
<br>

Uninstalling a MSKLC layout
---------------------------
Sometimes a KLC install can go wrong. That can even [mess up your computer][KLCtec], so beware.
- First of all, to activate an install you need to restart your computer. Do that immediately after installing.
- Secondly, system updates have been known to mess things up with KLC layouts. Again, various tech problems have been reported.
- Here's how to uninstall an installed Windows layout in case you should need to do so:
	- First, make sure it isn't added anywhere in the locale settings:
	- Hit the Win key → type `Settings` → select `Time & Language` → `Language` → `English (US)` or whatever it used → `Options`
	- Under `Colemak`-Something, press the `Remove` button. This deactivates the layout but doesn't actually uninstall it.
	- Next, uninstall it as you would any other program:
	- `Settings` → `Apps` & Features → `Colemak`-Something → Press `Uninstall`
- Restart Windows
<br>

Technicalities
--------------
- If you have trouble using a `.klc` file from GitHub with MSKLC, make sure it contains [Windows line endings (CRLF)][WinLin].
- Also, the encoding of the file must be `UTF-16LE-BOM`. GitHub's native format is UTF-8 which is different.
- To get a workable file without downloading the whole repo:
	- Right-click and `Save Link As...` from the `Raw` link on the repo page, or the links below.
	- [Link to the raw Cmk-eD.klc file in this repo][CmkeDr]
	- [Link to the raw Cmk-CAWS-eD-ANS.klc file in this repo][CAWSAr]
	- [Link to the raw Cmk-CAWS-eD-ISO.klc file in this repo][CAWSIr]
	- Make sure the line endings and encoding are right.
	- If you get `UTF-8` encoding and Linux endings as is native for GitHub, set them right using, e.g., the Notepad++ program.
- By downloading the repo as a .zip file you should get the right `.klc` file formats, with correct encoding and line endings.


[MyCAWS]: ./Cmk-CAWS-eD-ISO.klc (DreymaR's MSKLC Colemak-CAWS layout file)
[MSKLCd]: https://www.microsoft.com/en-us/download/details.aspx?id=102134 (MSKLC download at the Microsoft Download Center)
[MSKLCg]: https://msklc-guide.github.io/ (Henri's MSKLC Guide)
[BBergo]: https://dreymar.colemak.org/ergo-mods.html (DreymaR's Big Bag of Keyboard Tricks, on ergo mods)
[BBeDdk]: https://dreymar.colemak.org/layers-colemaked.html (DreymaR's Big Bag of Keyboard Tricks, on Colemak[eD])
[CmkeDi]: https://github.com/DreymaR/BigBagKbdTrixPKL/raw/master/Other/MSKLC/Cmk-eD.zip          (MSKLC installer for vanilla Cmk-eD)
[CAWSAi]: https://github.com/DreymaR/BigBagKbdTrixPKL/raw/master/Other/MSKLC/Cmk-CAWS-eD-ANS.zip (MSKLC installer for Cmk-CAWS-eD-ANSI)
[CAWSIi]: https://github.com/DreymaR/BigBagKbdTrixPKL/raw/master/Other/MSKLC/Cmk-CAWS-eD-ISO.zip (MSKLC installer for Cmk-CAWS-eD-ISO)
[KLCtec]: https://forum.colemak.com/topic/2785-techinal-issues-after-using-colemak/#p24299 (A case of technical trouble with MSKLC)
[WinLin]: https://stackoverflow.com/questions/32255747/on-windows-how-would-i-detect-the-line-ending-of-a-file (StackOverflow on line endings for Windows)
[CmkeDr]: https://github.com/DreymaR/BigBagKbdTrixPKL/raw/master/Other/MSKLC/Cmk-eD.klc          (KLC file for vanilla Colemak-eD)
[CAWSAr]: https://github.com/DreymaR/BigBagKbdTrixPKL/raw/master/Other/MSKLC/Cmk-CAWS-eD-ANS.klc (KLC file for Colemak-CAWS-eD-ANSI)
[CAWSIr]: https://github.com/DreymaR/BigBagKbdTrixPKL/raw/master/Other/MSKLC/Cmk-CAWS-eD-ISO.klc (KLC file for Colemak-CAWS-eD-ISO)
