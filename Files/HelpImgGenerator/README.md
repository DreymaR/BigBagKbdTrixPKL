DreymaR's Big Bag Of Keyboard Tricks - EPKL
===========================================
<br>

![A template image for the EPKL HIG](./Example_KLM-Co_Template_ISO.png)

<br><br>

HIG – The EPKL Help Image Generator
-----------------------------------
- The HIG is called from the `Create help images...` menu option (requires the `advancedMode` setting to be on).
- It uses the open-source [Inkscape][InkScp] vector graphics program together with an editable template file.
- From this, it produces a set of transparent `state#.png` images for use as EPKL help images (over a background).
- It can make a quick set of state images (usually four, for the `0/1/6/7` states corresponding to Shift and/or AltGr).
- It can also make a full help image set including deadkey state images in a subfolder, which may take a while to do.
<br>

- Unfortunately, I haven't found the time to write a full documentation for the HIG. I hope you can still make it work.
- Take a look at the HIG section of the [`EPKL_Settings`](/EPKL_Settings_Default.ini) file to learn more about the possible HIG settings.
- One common trip-up is that the default `Efficiency` setting of `1` moves your images to the layout folder, but _only if those images aren't there already_.
	- If you wonder where your generated images went, either set `Efficiency` to `2` to allow overwriting, or put any existing state images in a tmp folder first.
	- At a setting of `0`, the images will remain where they were generated, in a time-stamped temporary folder. You can then move them manually up one folder.
<br><br>

InkScape
--------
- [**Inkscape**][InkScp] is a brilliant vector graphics program that I've used for years. I've made my keyboard images by hand with it.
- The EPKL HIG calls Inkscape from the location set in the Settings file, by a command-line call for batch file export.
- Inkscape can be installed to your computer normally (affecting the system Registry), or portably/standalone which is what I prefer.
- Portable/Standalone InkScape can be downloaded either via the brilliant [PortableApps][PrtApp] platform, or via the InkScape site.
<br>

- **NOTE**: In Inkscape v1.3 there is a bug that affects batch export. Instead, please use any version between v1.0 and v1.2.1.
- Here's a link to a [Inkscape v1.2.1 Standalone installer][Ink121], for this purpose.
	- Put it anywhere you like, and edit the EPKL `InkscapePath` setting accordingly.


[InkScp]: https://inkscape.org/                                             (The Inkscape vector graphics program)
[PrtApp]: https://portableapps.com/                                         (The PortableApps platform)
[Ink121]: https://inkscape.org/~GordCaswell/%E2%98%85inkscape-portable-121  (standalone/portable installer for Inkscape v1.2.1)
