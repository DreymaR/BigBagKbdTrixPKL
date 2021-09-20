DreymaR's Big Bag Of Keyboard Tricks - EPKL
===========================================
<br>

Microsoft Keyboard Layout Creator, alias MSKLC
----------------------------------------------
In this folder are some files that aren't used by EPKL but MSKLC-related. This is another way of implementing layouts.
- I actually use both a KLC layout (see the enclosed [.KLC file][MyCAWS]) and EPKL when typing.
- This is because EPKL, while very powerful and versatile, doesn't always play well with low-level keyboard things.
	- These include command interpreters such as the WSL Bash one and Windows PowerShell, and many games.
	- To keep things smooth, EPKL can auto-suspend itself whenever these programs are active. See the `EPKL_Settings` file.
- You'll need to install MSKLC from Microsoft's site. With it you can look at existing Win layouts and make new ones.
- MSKLC is Microsoft's tool for generating installable layouts. It was made chiefly for creating QWERTY locale variants.
- As such, it's a bit limited in what it can do. Actually, the underlying code can do a lot more but the GUI has limits.
- One such limit is that VK (VirtualKey) codes aren't shown in the GUI. These affect system shortcuts such as `Ctrl+<letter>`.
- For a good guide to getting and using MSKLC, see [Henri's MSKLC Guide][MSKLCg].
- If you do dabble in layout editing with MSKLC, you may have to edit your .klc file directly to get VK codes right.
	- In Henri's guide you'll also learn to do advanced stuff like swapping system keys (e.g., CapsLock-to-Backspace).
	- If you're eager to map CapsLock to Backspace though, please do consider that EPKL's Extend is so very much better!!!

Uninstalling a MSKLC layout
---------------------------
Sometimes a KLC install can go wrong. That can even [mess up your computer][KLCtec], so beware.
- First of all, to activate an install you need to restart your computer. Do that immediately after installing.
- Secondly, system updates have been known to mess things up with KLC layouts. Again, various tech problems have been reported.
- Here's how to uninstall an installed Windows layout in case you should need to do so:
	- First, make sure it isn't added anywhere in the locale settings:
	- Hit the Win key → type `Settings` → select `Time & Language` → `Language` → `English (US)` or whatever it used → `Options`
	- Under `Colemak`-Something, press the `Remove` button. This deactivates the layout but doesn't actually uninstall it.
	- Next, uninstall it:
	- `Settings` → `Apps` & Features → `Colemak`-Something → Press `Uninstall`
- Restart Windows.


[MyCAWS]: ./Cmk-CAWS-eD-WIP.klc (my Work-In-Progress MSKLC Colemak-CAWS layout file)
[MSKLCg]: https://msklc-guide.github.io/ (Henri's MSKLC Guide)
[KLCtec]: https://forum.colemak.com/topic/2785-techinal-issues-after-using-colemak/#p24299 (A case of technical trouble with MSKLC)
