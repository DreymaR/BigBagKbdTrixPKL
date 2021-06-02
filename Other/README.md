DreymaR's Big Bag Of Keyboard Tricks - EPKL
===========================================
  
Other files info
----------------
In this folder are some files that aren't used by EPKL but may still be interesting.
  
- The Key code table is a list of keys and their various names. See the [Remap file][MapIni] for what EPKL uses.
- To see what keys are pressed and what output results, you can use the EPKL "AHK Key History..." menu.
	- The AutoHotkey Key History menu item is shown only if advancedMode is set to yes in the EPKL_Settings.
	- Even more info is seen on the [Keyboard Event Viewer][KbdEvt] page. It's a very informative tool.
- There's a Registry Editor folder that may be used to change Windows low-level settings. Do this only with great care!
	- It contains .reg files that should run with the MS RegEdit system program to modify the Windows Registry.
	- RegEdit files that remap keys, do so at the lowest level possible which will work everywhere such as in games.
	- Remappings can happen at the HKEY_LOCAL_MACHINE\SYSTEM level (for all users) or HKEY_CURRENT_USER only.
	- Only one such remap script will take effect at a time, so if you want to do two things you have to edit your .reg file.
	- Instead of using RegEdit scripts, you could use the [SharpKeys program][ShrpKy] which does most of the same more safely.
	- The SetWinApp script may be used to set what "App1" and "App2" refers to, e.g., for the Extend1 layer.
- There's a MSKLC folder, that's about the Microsoft Keyboard Layout Creator program. With it you can make installable layouts.
	- For a good guide to getting and using MSKLC, see [Henri's MSKLC Guide][MSKLCg].
	- You'll need to install MSKLC from Microsoft's site. With it you can look at existing Win layouts and make new ones.
	- If you do dabble in layout editing with MSKLC, you may have to edit your .klc file directly to get VK codes right.
	- In Henri's guide you'll also learn to do advanced stuff like swapping system keys (e.g., CapsLock-to-Backspace).
	- The original PKL was able to import .klc files to layout.ini files; in the future EPKL may also do that.
- Also worth mentioning to the keyboard modder, is the KbdEdit program which is commercial but quite powerful.
	- KbdEdit has a nice [online manual][KbdEdt] too. There's a VK code table there and much more.

[MapIni]: ../Files/_eD_Remap.ini (EPKL Remap file)
[KbdEvt]: https://w3c.github.io/uievents/tools/key-event-viewer.html (Keyboard Event Viewer on GitHub Pages)
[ShrpKy]: https://www.randyrants.com/category/sharpkeys/ (RandyRants' SharpKeys program)
[MSKLCg]: https://msklc-guide.github.io/ (Henri's MSKLC Guide)
[KbdEdt]: http://www.kbdedit.com/manual/manual_index.html (KbdEdit online manual)
