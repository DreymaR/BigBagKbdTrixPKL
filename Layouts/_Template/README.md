DreymaR's Big Bag Of Keyboard Tricks - EPKL
===========================================
<br><br>

The `NewLayout` subfolder in here contains a template for creating new EPKL layouts.
There's a BaseLayout (using eD-type shift state mappings), and some ergo mod combos.

The layout in this template is meant as an example. If you're curious, it's the [Canary layout][CanPKL].
<br>

Layout generation
-----------------
- For best results, just copy-paste the `NewLayout` folder over to the Layouts folder.
	- Rename it to your layout's name (one word, nothing too fancy for file names please).
	- Obviously, just remove any ergo-mod subfolders you don't want to use.
	- Then rename the ergo-mod subfolders' `New` part to your layout's first three letters.
	- If you want other ergo mod combos, copy folders for them and try to name them right.
	- If you have on/off icons, put them in the `_Res` folder and name them as by the examples.
- Replace `<Layout> <Creator> <Lay>`, the date etc. in all `Layout.ini` files (and BaseLayout).
- Edit the key mappings. The simplest way is swapping their scan codes (before the `=` sign).
- Consider if you need any special remaps for ergo mods; that can be tricky though...
<br>

Help images
-----------
- To generate help images you'll need to run the EPKL HelpImageGenerator (HIG).
	- For this you have to have the Inkscape program (installed, or a PortableApps version).
	- There are settings for it in the `EPKL_Settings` file; have a look.
<br>

Screenshots
-----------
- The images in the main folder are just example screenshots – you can make new ones if you wish:
	- Use the EPKL hotkeys (or menu) to make the help image opaque and large
	- Start the Windows Snipping Tool by pressing `Win+Shift+S`
	- Quickly get the help image in the desired shift state using modifiers
	- Capture the whole help window with the Snipping Tool once it activates
<br>

[CanPKL]:  /Layouts/Canary/ (The Canary layout for EPKL)
