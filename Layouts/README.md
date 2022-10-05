DreymaR's Big Bag Of Keyboard Tricks - EPKL
===========================================
<br>

![EPKL help image, for the Colemak-CAWS layout](./Colemak/Colemak-ISO-CAWS_s0_EPKL.png)

<br><br>

Layouts info
------------
This is where EPKL keeps its layout files.
* Layout folders can be organized by main layout, variants and mods. But they don't have to be.
* The folder name describes its features.
	- It starts with a three-letter abbreviation (`3LA`) for the main layout.
	- Next (preceded with a hyphen) follows the layout type, such as `VK` (VirtualKey) or `eD` (my state mappings).
	- Next comes the variant. These may be anything really, but they're often locales such as `BrPt` for Brazil/Portugal.
	- The names of the layout folders themselves then contain the keyboard type (`ISO`/`ANS`), flanked with underscores.
	- The last part is the mod. Again, anything's possible but mine are generally of the `CurlA(ngle)WideSym` type.
* Every actual layout variant/mod folder must contain a `layout.ini` file. This file defines the layout.
	- A `layout.ini` file may point at a `BaseLayout` file that defines common features for the main layout.
	- Default common features for all layouts are in the `EPKL_Layouts` files in the main folder.
	- This file hierarchy is known as the `LayStack`. There's a mini-stack for general settings too. See the [main EPKL Readme][EPKLgh].
<br><br>

Available layouts
-----------------
I don't try to provide all possible layouts with EPKL, obviously. The ones you will find here are in these categories:
* Useful and recommended, such as Colemak(!)
* Of historical interest, such as Dvorak or QWERTY
* Interesting to me and of some promise (Boo, Canary, ISRT, MTGAP, Semimak etc)
* Just for fun! (Foalmak, QUARTZ)
<br>

If you want me to add a layout of your choice, the answer may be no. Even if you made the files for it. Especially if that layout is Workman, Norman, Minimak or another one of those layouts I feel are poor and oversold choices (and the AltKeyboardLayout community largely agree with me). Sorry, but that's how it goes.<br>

But you're free to ask! Who knows, maybe you pique my interest with a new and promising development in layout design.
<br><br>

Key mappings
------------
Most of my layouts have a base layout defined; their layout section may then change some keys. You can add key definitions following this pattern.

Here are some full shift-state mappings with a legend:
```
; SC  = VK      CS    S0    S1    S2    S6    S7    ; comments
QW_O  = Y       1     y     Y     --    ›     »     ; SC018: QW oO
QW_P  = vc_SC   0     ;     :     --    @0a8  …     ; SC019: QW pP - dk_umlaut (ANS/ISO_1/3)
```
Where:
* SC & VK: [Scan code ("hard code")][SCMSDN] & Virtual Key Code [("key name")][VKCAHK]; also see my [Key Code Table][KeyTab].
    - For SC, you could use an AHK key name instead. For VK you need Windows VK names/codes.
    - Instead of the technical SC or VK you may use my more intuitive KLM codes. See the [Remap file][MapIni].
    - _Example:_ The above SC are for the <kbd>O</kbd> and <kbd>P</kbd> keys; these are mapped to their Colemak equivalents <kbd>Y</kbd> and <kbd>;</kbd>.
    - The `OEM_#` VK names are ISO/ANSI keyboard type specific. For these, it's much better to use KLM `vc_##` codes.
    - _Example:_ The KLM code `vc_SC` is the <kbd>;</kbd> key, which is VK `OEM_1` for ANSI but `OEM_3` for ISO keyboards.
    - If the VK entry is VK/ModName, that key is Tap-or-Mod. If tapped it's the VKey, if held down it's the modifier.
    - The VK code may be an AHK key name. For modifiers you may use only the first letters, so `LSh` -> `LShift` etc.
* CS: Cap state. Default 0; +1 if S1 is the capitalized version of S0 (that is, CapsLock acts as Shift for it); +4 for S6/S7.
    - _Example:_ For the <kbd>Y</kbd> key above, CS = 1 because `Y` is a capital `y`. For `OEM_1`, CS = 0 because `:` isn't a capital `;`.
* S#: Modifier states for the key. S0/S1:Unmodified/+Shift, S2:Ctrl (rarely used), S6/S7:AltGr/+Shift.
    - _Example:_ <kbd>Shift</kbd>+<kbd>AltGr</kbd>+<kbd>Y</kbd> sends the `»` glyph. <kbd>AltGr</kbd>AltGr+<kbd>;</kbd> has the special entry `@0a8` (umlaut deadkey).
* EPKL prefix-entry syntax is useable in layout state mappings, Extend, Compose, PowerString and dead key entries.
    - There are two equivalent prefix characters for each entry type: One ASCII (easy to type), one from the eD Shift+AltGr layer.
    - If the mapping starts with `«#»` where # is one or more characters, these are used for Help Images.
    - `→ | % ‹entry›` : Send a literal string/ligature by the SendInput {Text}‹entry› method
    - `§ | $ ‹entry›` : Send a literal string/ligature by the SendMessage ‹entry› method
    - `α | * ‹entry›` : Send entry as AHK syntax in which !+^# are modifiers, and {} contain key names
    - `β | = ‹entry›` : Send {Blind}‹entry›, keeping the current modifier state
    - `† | ~ ‹entry›` : Send the 4-digit hex Unicode point U+<entry>
    - `Ð | @ ‹entry›` : Send the current layout's dead key named ‹entry› (often a 3-character code)
    - `¶ | & ‹entry›` : Send the current layout's powerstring named ‹entry›; some are abbreviations like &Esc, &Tab…
* A `®®` mapping repeats the previous character. Nice for avoiding same-finger bigrams. May work best as a thumb key?
    - A state mapping of `®#` where `#` is a hex number, repeats the last key # times.
* A `©<name>` mapping uses a Linux/X11-type Compose method, replacing the last written characters with something else.
    - See below and in the [EPKL Compose file][CmpIni] for more info. Compose tables are defined and described in that file.
* A `##` state mapping sends the key's VK code "blind", so whatever is on the underlying system layout shines through.
    - Note that since EPKL can't know what this produces, a `##` mapped key state can't be used in, e.g., compose sequences.
<br>

Here are some VirtualKey/VKey and Modifier/Mod mappings. Any layout may contain all types of mappings.
```
QW_J    = N         VKey            ; QW jJ  -> nN, a simple VK remapping
RWin    = BACK      VirtualKey      ; RWin   -> Backspace (VKey)
RShift  = LShift    Modifier        ; RShift -> LShift, so it works with LShift hotkeys
SC149   = NEXT      VKey            ; PgUp   -> PgDn, using ScanCode and VK name (the old/MSKLC way)
QWPGU   = vcPGD     VKey            ; PgUp   -> PgDn, this time with my more intuitive KLM codes
QWPGU   = qwPGD     SKey            ; PgUp   -> PgDn, this time with KLM scan code (SC) mapping
QW_U    = System                    ; System mapped key. Uses whatever is on the system layout.
```
Entries are any-whitespace delimited.
<br><br>

Layout variant tutorial
-----------------------
You can make your own version of, say, a locale layout variant – for instance, using an ergonomic mod combo that isn't provided out-of-the-box:
* Determine which keyboard type (ISO/ANS), ergo mod and if applicable, existing locale variant you want to start from.
* Determine whether you want to just move keys around by VirtualKey/ScanCode mappings or map all their shift states like Colemak-eD does.
* Copy/Paste a promising layout folder and rename the result to what you want.
    - In this example we'll make a German (De) Colemak[eD] with only the ISO-Angle mod instead of the provided CurlAngleWide.
    - Thus, copy `Cmk-eD-De_ISO_CurlAWide` in the [Colemak\Cmk-eD-De](../Layouts/Colemak/Cmk-eD-De) folder and rename the copy to `Cmk-eD-De_ISO_Angle`.
    - Instead of 'De' you could choose any locale tag you like such as 'MeinDe' to set it apart.
* In that folder's layout.ini file, edit the remap and/or other relevant fields to represent the new settings.
    - Here, change `mapSC_layout = Cmk-CAW-_@K` to `mapSC_layout = Angle_@K` (`@K` is shorthand for ISO/ANS).
    - Some Extend layers like the main one use "hard" or positional remaps, which observe most ergo mods but not letter placements.
    - Here, `mapSC_extend = Angle_@K` too since Angle is a "hard" ergo mod. If using Curl-DH, you can move <kbd>Ctrl</kbd>+<kbd>V</kbd> with `Ext-CA--`.
    - The geometric ergo mods Angle and Wide alone are named `Angle` and `Wide`; `AWide` for both. For the Curl mods, use C/A/W/S letter abbreviations.
    - If you don't know the name of your desired mod combo, look in a `layout.ini` file using that combo. Or in the [Remap file][MapIni] itself.
* Change any key mappings you want to tweak.
    - The keys are mapped by their native Scan Codes (SC), so, e.g., SC02C is the QWERTY/Colemak Z key even if it's moved around later.
    - However, I've also provided a more intuitive syntax, like `QW_Z` for the QWERTY Z key. See the next section to learn more about key mapping syntax.
    - The mappings in the De layout are okay as they are, but let's say we want to swap <kbd>V</kbd> and <kbd>Ö</kbd> (`QW_LG`) for the sake of example.
    - In the `[layout]` section of layout.ini are the keys that are changed from the BaseLayout. `QW_LG` is there, state 0/1 mapped to ö/Ö.
    - To find the <kbd>V</kbd> key, see the `baseLayout = Colemak\BaseLayout_Cmk-eD` line and open that file. 
    - There's the <kbd>V</kbd> key, with the KLM code `QW_V` (scan code `SC02f`).
    - Now, copy the `QW_V` key line from the BaseLayout file to your layout.ini `[layout]` section so it'll override the baseLayout.
    - Make sure the `QW_LG` line you want is also active and not commented out with a `;`, and then swap the key names (scan codes) for the two lines.
    - Alternatively, you could just edit the mappings for the affected shift states of the two keys in the `layout.ini` file.
    - The main shift state mappings are `0/1` for unshifted/shifted, and `6/7` for the AltGr states. See above for more info.
* Now, if your `EPKL_Layouts_Override.ini` layout selection setting is right, you should get the variant you just made.
    - From the Layout/Settings menu, you should be able to see and select it using the right options. Then you can let EPKL restart itself.
    - Or, in the file set LayType/LayVari/KbdType/CurlMod/HardMod/OthrMod to eD/De/ISO/--/Angle/-- respectively (or use 'MeinDe' if you went with that).
    - If you prefer to use another existing layout line in the file, comment out the old `layout = ` line with `;` and activate another.
    - You can also write the `layout = LayoutFolder:DisplayedName` entry directly instead, using the folder path starting from `Layouts\`.
* After making layout changes, refresh EPKL with the <kbd>Ctrl</kbd>+<kbd>Shift</kbd>+<kbd>5</kbd> hotkey.
    - If that somehow doesn't work, just quit and restart EPKL.
* To get relevant help images without generating them with Inkscape:
    - Check around in the eD layout folders. Maybe there's something that works for you there despite a few minor differences?
    - Here, you might either keep the current De_ISO_CurlAWide settings to see the German special signs without making new images, or…
    - … edit the image settings, replacing AWide/CAWide/CAngle with 'Angle' to get normal ISO_Angle images without German letters, or…
    - … make new help images in an image editor by copying and combining from the ones you need. I use Gimp for such tasks.
* If you do want to generate a set of help images from your layout you must get Inkscape and run the EPKL Help Image Generator (HIG).
    - You can download Inkscape for instance from [PortableApps.com]{InkPrt], or install it properly. Make sure it's version 1.0 or newer.
    - Point to your Inkscape in the `InkscapePath` setting in the [EPKL_Settings][PklIni] file.
    - By default, the HIG looks for Inkscape in `C:\PortableApps\InkscapePortable\InkscapePortable.exe`, so you could just put it there.
    - To see the "Create help images…" menu option, `advancedMode` must be on in [EPKL_Settings][PklIni].
    - The HIG will make images for the currently active layout.
    - I recommend making state images only at first, since a full set of about 80 dead key images takes a _long_ time!
<br>


[EPKLgh]: https://github.com/DreymaR/BigBagKbdTrixPKL/ (EPKL on GitHub)
[SCMSDN]: https://msdn.microsoft.com/en-us/library/aa299374(v=vs.60).aspx (Scan code list at MSDN)
[VKCAHK]: https://autohotkey.com/docs/KeyList.htm (Virtual key list in the AHK docs)
[InkPrt]: https://portableapps.com/apps/graphics_pictures/inkscape_portable (Inkscape v1.0 at PortableApps.com)
[ISOANS]: https://deskthority.net/wiki/ANSI_vs_ISO (Deskthority on ANSI vs ISO keyboard models)
[KeyTab]: ../Other/KeyCodeTable.txt (KeyCodeTable.txt)
[LayOvr]: ../EPKL_Layouts_Override_Example.ini (EPKL_Layouts_Override example file)
[LayDef]: ../EPKL_Layouts_Default.ini (EPKL_Layouts_Default file)
[PklIni]: ../EPKL_Settings_Default.ini (EPKL Settings file)
[MapIni]: ../Files/_eD_Remap.ini (EPKL Remap file)
[DKsIni]: ../Files/_eD_DeadKeys.ini (EPKL DeadKeys file)
[CmpIni]: ../Files/_eD_Compose.ini (EPKL Compose file)
