DreymaR's Big Bag Of Keyboard Tricks - EPKL
===========================================
<br>

Other files info
----------------
In this folder are some files that aren't used by EPKL but may still be interesting.

- The Key code table is a list of keys and their various names. See the [Remap file][MapIni] for what EPKL uses.
	- To see what keys are pressed and what output results, you can use the EPKL "AHK Key History..." menu.
	- This AutoHotkey Key History menu item is shown only if advancedMode is set to yes in the EPKL_Settings.
	- Even more info is seen on the [Keyboard Event Viewer][KbdEvt] page. It's a very informative tool.
- There's a Registry Editor folder that may be used to change Windows low-level settings. Do this only with great care!
	- It contains .reg files that should run with the MS RegEdit system program to modify the Windows Registry.
	- RegEdit files that remap keys, do so at the lowest level possible which will work everywhere such as in games.
	- Remappings can happen at the HKEY_LOCAL_MACHINE\SYSTEM level (for all users) or HKEY_CURRENT_USER only.
	- Only one such remap script will take effect at a time, so if you want to do two things you have to edit your .reg file.
	- The SetWinApp script may be used to set what apps the labels "App1" and "App2" refer to, e.g., for the Extend1 layer.
- Instead of using RegEdit scripts, you can use the [SharpKeys][ShrpKy] program which does most of the same more safely.
	- I warmly recommend SharpKeys. It is available at the [Microsoft Store][ShrpMS] too, so it's quite official.
	- It's hard to remap modifiers like the Alt keys well using EPKL. SharpKeys complements EPKL excellently in this respect.
	- I use a combo of EPKL+SharpKeys to implement my BigBag [Modifier Modness][BBTMod] thumb keys. I'm very happy with that.
- There's a MSKLC folder, that's about the Microsoft Keyboard Layout Creator program. With it you can make installable layouts.
	- For a good guide to getting and using MSKLC, see [Henri's MSKLC Guide][MSKLCg].
	- You'll need to install MSKLC from Microsoft's site. With it you can look at existing Win layouts and make new ones.
	- If you do dabble in layout editing with MSKLC, you may have to edit your .klc file directly to get VK codes right.
	- In Henri's guide you'll also learn to do advanced stuff like swapping system keys (e.g., CapsLock-to-Backspace).
	- The original PKL was able to import .klc files to Layout.ini files; in the future EPKL may also do that.
- Other remap tools exist, such as the [Microsoft PowerToys Keyboard Manager][MSPTKM]. It looks like a quite powerful utility.
	- However, it uses a low-level keyboard hook like EPKL does, and so the two should not be used together. Too bad.
	- Also, like EPKL it doesn't perform so well with games according to Microsoft's page.
- The [KMonad][KMonad] program is interesting: It's cross-platform, for Windows/Mac/Linux.
	- Note that this is a purely key mapping program, much like having a programmable keyboard.
	- This means that while it's really good at key press emulation, it can't natively send characters and strings.
	- As with programmable keyboards using for instance the [QMK firmware][QMKdoc], there are workarounds but they're clunky.
	- However, key mapping is often really good for key combos, home row mods and such stuff which can be hard to do in EPKL.
- Also worth mentioning to the keyboard modder, is the KbdEdit program which is commercial but quite powerful.
	- KbdEdit has a nice [online manual][KbdEdt] too. There's a VK code table there and much more.

[MapIni]: ../Files/_eD_Remap.ini (EPKL Remap file)
[KbdEvt]: https://w3c.github.io/uievents/tools/key-event-viewer.html (Keyboard Event Viewer on GitHub Pages)
[ShrpKy]: https://www.randyrants.com/category/sharpkeys/ (RandyRants' SharpKeys program)
[ShrpMS]: https://apps.microsoft.com/store/detail/sharpkeys/XPFFCG7M673D4F (SharpKeys at the Microsoft Store)
[MSPTKM]: https://learn.microsoft.com/en-us/windows/powertoys/keyboard-manager (info on Microsoft PowerToys Keyboard Manager)
[MSKLCg]: https://msklc-guide.github.io/ (Henri's MSKLC Guide)
[KMonad]: https://github.com/kmonad/kmonad
[QMKdoc]: https://docs.qmk.fm
[KbdEdt]: http://www.kbdedit.com/manual/manual_index.html (KbdEdit online manual)
[BBTMod]: https://dreymar.colemak.org/ergo-mods.html#modifiers
