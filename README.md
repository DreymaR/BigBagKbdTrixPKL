DreymaR's Big Bag Of Keyboard Tricks - EPKL
===========================================

### [EPiKaL PortableKeyboardLayout][CmkPKL] for Windows, with layouts

![EPKL help image, for the Colemak-CAWS layout](./Layouts/Colemak/Cmk-eD_ISO_CurlAWideSym/Cmk-ISO-CAWS_s0_EPKL.png)

[Θώθ][ThothW] – What Is This?
-----------------------------
This is my Big Bag Of Tricks, obviously! That is, my many mods and tweaks and bells and whistles. 
It's mostly centered around the brilliant Colemak keyboard layout, and the incredibly useful Extend layers which work with any layout.
* This repo is home to the **EPiKaL PKL** (**EPKL**) layout program, with several improvements over the old PKL.
* It also implements most of my Big Bag "tricks" for EPKL, as layouts and other files.
* Info about DreymaR's Big Bag of keyboard trickery is mainly found on the Colemak forum:
	- The [Big Bag main topic][CmkBBT] with better explanations and links.
	- Daughter topics for implementations, including the [Big Bag for EPKL/Windows][CmkPKL] one.
  
These Aren't The Guides You're Looking For?
-------------------------------------------
EPKL can be complex and confusing for the newbie. So we're very happy to present to you:
**[EPKL For Dummies][EPKL4D]**, by master [TorbenGB](https://github.com/torbengb). Help me, Obi-Torben, you're my only hope!
If you find my info below and on the Big Bag pages too daunting and massive, do try it out.  ( のvの) c[_]  
  
Getting EPKL up and running
---------------------------
* Download a full copy of this repository or just its executable resources.
    - Under **[Release][GitRel] Assets**, there's a .ZIP file with the files needed to run EPKL. Unzip and run!
    - For the latest commit (say, for a bugfix) with source code, instead `Download ZIP` by the green `Code` button.
    - For releases, the `EPKL.exe` binary is included. For commits, you must run `Compile_EPKL.bat` to produce it.
    - Note that some virus protection programs overreact to Autohotkey (AHK) code, especially using keyboard hooks.
* **FAST LANE:** If you simply want "vanilla Colemak" on a US/ANSI keyboard, just run EPKL.exe and type!
    - If you insist on having the Caps key as Backspace instead of the superior and wonderful Extend key...
    - ...in the [Layouts Default file][LayDef] find the `;QWCLK = BACK` etc line and remove that semicolon.
* Run EPKL.exe inside its main folder in any way you like! Check its tray menu in the bottom right-hand corner.
* To choose a layout variant, select the Layouts/Settings menu option. The EPKL Settings User Interface pops up.
* Choose a layout with your keyboard type, variant/locale and Curl/Angle/Wide etc preferences.
    - There are two main layout types: VK which only moves your keys, and eD which maps each shift state.
    - There are several premade Locale variants, if you need to type in other languages. Check out which variants exist.
    - There are several ergonomic variants, which you can read about in the Big Bag: Curl(DH), Angle, Wide, Sym etc.
* If you want to choose layouts manually instead, rename the Override_Example file to `EPKL_Layouts_Override.ini`.
    - There can be a [Layouts_Default][LayDef] and a [Layouts_Override][LayOvr] file. Override entries take precedence.
* In your `EPKL_Layouts_Override.ini`, activate the layout(s) you want by editing and/or uncommenting (remove initial semicolon).
    - There are KbdType (@K) etc shortcuts, but you could also type the path to a layout folder out in full.
    - The format is: `layout = ‹layout folder›:‹menu entry›,‹2nd layout folder›:‹2nd menu entry›` etc.
* To use the chosen layout(s) and settings, select the Refresh EPKL menu option.
  
More Know-How
-------------
* This repo contains executables and source code for EPKL. Earlier, it also included the original PKL.
* The layouts are updated to EPKL format, so they'd need some reconstruction for the old PKL.
* The `EPKL_Layouts` .ini files hold layout choices. [EPKL_Settings.ini][PklIni] holds general program settings.
* The `layout.ini` files hold layout settings and mappings. They often point to and augment a `BaseLayout` file.
* There's a "LayStack" for layout info priority. Mappings/settings at higher levels will take precedence:
    - The [EPKL_Layouts_Default][LayDef] holds default and common settings/mappings
    - The [EPKL_Layouts_Override][LayOvr], if present, can contain overriding layout choices etc
    - The `BaseLayout` .ini file usually found under each layout type may define most of the layout
    - The `layout.ini` file in the chosen Layout folder gets the last word about remaps etc
    - Beyond this, specialized files may hold settings, info, Extend or DeadKey mappings etc. See below.
* In theory, you could put all the info needed for a whole layout into any one of the layout stack files.
  
**Tweakable parameters:**
The files may take a little tweaking to get what you want. There are several parameters:
* Colemak vs QWERTY vs what-have-you, obviously. Choose wisely!
    - This repo by default contains mainly Colemak(-DH) and Tarmak layouts, with QWERTY and Dvorak included.
* Full/VK mappings: I've provided my own Colemak[eD] as well as 'VirtualKey' versions
    - The _VK_ layouts just move the keys of your installed OS layout around, without other changes
    - The _[eD]_ layouts have their own Shift/AltGr state mappings specified.
    - You may actually mix mapping types freely in any layout.
* ISO (European/World) vs ANSI (US) vs other keyboard types
    - ISO boards have a `VK_102` key between `Z` and `LShift`. Some `OEM_` key codes differ from ANSI ones.
    - Brazilian ABNT boards are like ISO, but have two more keys. These can be remapped by their scan codes.
    - JIS (Japanese) etc are not supported so far. Sorry. Gomen-nasai. ごめんなさい.    ᏊᵕꈊᵕᏊ
* Curl(DH), Angle and/or Wide ergonomic mods, moving some keys to more comfortable positions
    - Angle/Wide affect the "hard" key positions in the layout.ini file, usually both for Layout and Extend
    - Curl(DH) is Colemak/Tarmak/Dvorak specific and for the most part should not affect Extend
    - The Curl(DH) mod does insert D between C and V though. There's a remap to let Extend+V still be Paste
* Extend mappings, using for instance CapsLock as a modifier for nav/edit/multimedia/etc keys. It's awesome!!!
    - The Extend modifier may even double as a Tap-or-Mod key so that when you tap it, something else happens.
    - The most advanced way of using this may be the Mother-of-DeadKeys which allows really fancy "tap dances"!
    - Holding down Shift and/or AltGr while first holding or while tapping the Ext key affects which layer is used.
* In EPKL_Layouts you can use shorthand (@#) for KbdType/CurlMod/ErgoMod etc, or set the layout folder path directly.
    - For Extend set an Extend file and a working Extend modifier. The latter needs to be mapped to a key.
    - My _eD_Extend mappings file is in the Files folder. Look inside it to learn more.
* In the layout folder(s) you've chosen, you may edit the layout.ini files further if required. See below.
    - Mod remaps, help image specifications, Extend key, key mappings etc can be set in the LayStack .ini files.
    - Many layouts use a BaseLayout. Most mappings may be there, so the top layout.ini only has to change a few keys.
* To learn more about remaps, see the [_eD_Remap.ini][MapIni] file. They can even turn Colemak into QWERTY (oh no...!).
* There's a file for named literals/PowerStrings. These are useable by layouts, Extend and dead keys.
* Also, a Dead Key file. DKs are mapped as @###. Pressing the key then a release glyph may produce something new!
    - There are help images for DKs, these can be very useful as they show what releases are in different shift states.
    - I haven't made images for all variants though, so there may be minor discrepancies.
* Layout folders aren't premade for every variant, board and mod combo, as there are so many of them. See below.
  
**Hotkeys found in the EPKL_Settings file:**
* Ctrl+Shift+1 – Display/hide the help image
* Ctrl+Shift+2 – Switch between the layouts specified in the Layouts file(s)
* Ctrl+Shift+3 – Suspend EPKL; hit again to re-activate. It may be Ctrl+Shift+` instead
* Ctrl+Shift+4 – Exit EPKL
* Ctrl+Shift+5 – Refresh EPKL, if it gets stuck or something
* Ctrl+Shift+6 – Show the About... dialog, with layout and other info
* Ctrl+Shift+7 – Zoom the help image in/out, to see it better or get it out of the way
* Ctrl+Shift+8 – Move the help image between positions, as by mouseover
* Ctrl+Shift+9 – Toggle help image transparency
* Ctrl+Shift+0 – Show info about the active window; useful for setting suspending apps
  
**Short EPKL Glossary**
* **Extend** is a layer switch, by default the CapsLock key, giving easy access to navigation and NumPad etc layers
* **Multi-Extend** means you'll get another Extend layer if you hold down, say, RShift and/or RAlt when pressing Extend
    - After selecting an Extend layer this way, keep only the Extend key pressed down to maintain it
* A sticky modifier or **OSM** (One-Shot Mod) is when you can tap a mod and then another key shortly thereafter
    - There's a setting in the Settings file for how quickly the OSM times out, in milliseconds
* **ToM** (Tap-or-Mod) is a dual-role key, working as a mod when held down and a normal key when tapped
* **DK** is a dead key. You tap it then another key, there's no timer. Most of my DKs are on `{AltGr+‹symbol›}`.
    - DK sequence: You can tap several DKs to get new symbols (example: `{AltGr+=,=}` gives `≡`; `AltGr+{/,=}` then `=` gives `≢`)
    - DK chaining: One DK can release to another. This is not implemented in EPKL yet
    - **MoDK** (Mother-of-DKs) is a ToM key (here, on **tap-Extend**) that leads to lots of cool DKs
* The **LayStack** is a stack of files that may hold layout definitions: Layouts_Default, Layouts_Override, BaseLayout and Layout.
* **PowerStrings** are shortcuts to text strings. These may be multiline, and may contain AutoHotKey syntax.
    - As an Example, try Extend+End in a text editor. It should produce an editable 'Yours truly' message footer.
* **Remaps** are cycles of keys swapping places. This allows you turn one layout definition into another.
    - These can be in the LayStack files for quick layout tweaks, or in a dedicated [Remap file][MapIni].
  
**Techy tips for EPKL:**
* EPKL, being portable, doesn't need an install with admin rights to work. You must still be allowed to run programs.  
* I usually put a shortcut to EPKL.exe in my [Start Menu "Startup" folder][StrtUp] so it starts on logon, per user.
* EPKL can also easily be used with the [PortableApps.com][PrtApp] menu by putting its folder in a `C:\PortableApps` folder.
    - If the PortableApps menu is run on logon it can start up EPKL for you too.
* Look in the various .ini files under Files and Layouts if you're interested! Much is explained there.
* See my examples in the Extend file for some advanced mappings! These may be used in layouts and dead keys too.
* EPKL uses both .ini and source files that may be UTF-8 Unicode encoded.
* EPKL allows end-of-line comments (whitespace-semicolon) in .ini files, the old PKL only allowed them in layout entries.
* Running EPKL with other (AutoHotkey) key mapping scripts may get confusing if there is so-called _hook competition_.
  
Key mappings
------------
Most of my layouts have a base layout defined; their layout section may then change some keys. You can add key definitions following this pattern.
  
Here are some full shiftstate mappings with a legend:
```
; SC  = VK      CS    S0    S1    S2    S6    S7    ; comments
QW_O  = Y       1     y     Y     --    ›     »     ; SC018: QW oO
QW_P  = vc_SC   0     ;     :     --    @0a8  …     ; SC019: QW pP - dk_umlaut (ANS/ISO_1/3)
```
Where:
* SC & VK: [Scan code ("hard code")][SCMSDN] & Virtual Key Code [("key name")][VKCAHK]; also see my [Key Code Table][KeyTab].
    - For SC, you could use an AHK key name instead. For VK you need the Windows VK names (or KLM codes).
    - Instead of the technical SC or VK you may use my more intuitive KLM codes. See the [Remap file][MapIni].
    - _Example:_ The above SC are for the `O` and `P` keys; these are mapped to their Colemak equivalents `Y` and `;`.
    - The `OEM_#` VK names are ISO/ANSI keyboard type specific. For these, it's much better to use KLM vc_## codes.
    - _Example:_ The KLM code `vc_SC` is the semicolon key, which is VK `OEM_1` for ANSI but `OEM_3` for ISO keyboards.
    - If the VK entry is VK/ModName, that key is Tap-or-Mod. If tapped it's the VKey, if held down it's the modifier.
    - The VK code may be an AHK key name. For modifiers you may use only the first letters, so LSh -> LShift etc.
* CS: Cap state. Default 0; +1 if S1 is the capitalized version of S0 (that is, CapsLock acts as Shift for it); +4 for S6/S7.
    - _Example:_ For the `Y` key above, CS = 1 because `Y` is a capital `y`. For `OEM_1`, CS = 0 because `:` isn't a capital `;`.
* S#: Modifier states for the key. S0/S1:Unmodified/+Shift, S2:Ctrl (rarely used), S6/S7:AltGr/+Shift.
    - _Example:_ Shift+AltGr+`y` sends the `»` glyph. AltGr+`;` has the special entry `@0a8` (umlaut deadkey).
* Special prefix-entry syntax (can be used for layouts, Extend and dead key entries; two possibilities for each prefix):
    - → | %‹entry› : Send a literal string/ligature by the SendInput {Raw}‹entry› method (default)
    - § | $‹entry› : Send a literal string/ligature by the SendMessage ‹entry› method
    - α | *‹entry› : Send ‹entry› directly, allowing AHK syntax (!+^# are modifiers, {} key names)
    - β | =‹entry› : Send {Blind}‹entry›, keeping the current modifier state
    - « | ~‹entry› : Send the 4-digit hex Unicode point U+<entry>
    - Ð | @‹entry› : Send the current layout's dead key named ‹entry›
    - ¶ | &‹entry› : Send the current layout's powerstring named ‹entry›; some are abbreviations like &Esc, &Tab...
  
Here are some VirtualKey/VKey and Modifier/Mod mappings. Any layout may contain all types of mappings.
```
QW_J    = N         VKey            ; QW jJ  -> nN, a simple VK remapping
RWin    = BACK      VirtualKey      ; RWin   -> Backspace
RShift  = LShift    Modifier        ; RShift -> LShift, so it works with LShift hotkeys
SC149   = NEXT      VKey            ; PgUp   -> PgDn, using ScanCode and VK name (the old way)
QWPGU   = vcPGD     VKey            ; PgUp   -> PgDn, this time with my more intuitive KLM codes
```
Entries are any-whitespace delimited.
  
Advanced Extending
------------------
Here are some sample Extend key mappings:
```
QWCLK   = Extend    Modifier        ; Caps   -> The Extend modifier (see the Big Bag)
QWCLK   = BACK/Ext  VirtualKey      ; Caps   -> Tap-or-Mod: Backspace if tapped, Extend if held
QWCLK   = BACK/Ext  0   @ex0 @ex1 *#. @ex6 @ex7 ; Mother-of-DeadKeys (MoDK) on tap, Extend on hold
```
* These mappings merit explanation. Extend is a most marvelous beast, so don't be daunted now! ฅ(=ʘᆽʘ=)ฅ
* The above Extend modifier mappings may be in any LayStack .ini file, such as [Layouts_Default][LayDef]
* Holding designated modifiers, RShift and/or RAlt by default (specified in the [Settings][PklIni]), chooses Extend layers.
    - So, e.g., holding the Ext1 mod (RAlt) then the Ext key (Caps) activates the Extend2 layer (NumPad).
* After selecting your Extend layer, you hold down only the Extend key (Caps by default) and start using Extend!
* Extend layers (like Ext3/Ext4) can be set as one-shot so they fall back to another layer after each use.
    - This lets you for instance release a string then keep editing. But dead keys are better for that, see below.
* Setting the Extend key as a Tap-or-Mod (ToM) key as above lets you tap it for, e.g., Backspace or hold for Extend.
* Mother-of-DeadKeys (MoDK) is the most powerful option. Tapping Extend activates a dead key depending on shift state!
    - Tapping Ext alone or with Shift/AltGr activates the dead keys "ex0/1/6/7". See the DeadKeys.ini file!
    - In my default example, Ext-tap alone lets you activate symbols and commands easily.
    - Shift+Ext-tap activates a kaomoji DK, similar to Ext3 but you don't have to hold down the Ext key! d( ^◇^)b
    - Another advantage of DK layers over Extend layers is that you can make entries for any release char.
    - So, e.g., Ext3 has one kitty kaomoji (=^･ω･^=)丿 but dk_Ext_Kaomoji has one for k and one for K. (=ΦωΦ=)ʃ
    - "Tap-dance" {Shift,Ext,<key>} quickly using Sticky Shift, for a kaomoji. Wait before <key> for another.
    - Holding Ctrl then tapping Ext sends Win+Period, opening the Emoji picker.
    - AltGr+Ext-tap holds some commands to avoid hand contortion. Example: {AltGr+Ext,T} for Task Manager.
  
Layout variant tutorial
-----------------------
You can make your own version of, say, a locale layout with a certain (non-)ergonomic variant:
* Determine which keyboard type (ISO/ANS), ergo mod and if applicable, existing locale you want to start from.
* Determine whether you want to just move keys around by VirtualKey mappings or map all their shift states like Colemak-eD does.
* Copy/Paste a promising layout folder and rename the result to what you want.
    - In this example we'll make a German (De) Colemak[eD] with only the ISO-Angle mod instead of the provided CurlAngleWide.
    - Thus, copy `Cmk-eD-De_ISO_CurlAWide` in the [Colemak](./Layouts/Colemak) folder and rename the copy to `Cmk-eD-De_ISO_Angle`.
    - Instead of 'De' you could choose any locale tag you like such as 'MeinDe' to set it apart.
* In that folder's layout.ini file, edit the remap fields to represent the new settings.
    - Here, change `mapSC_layout = Cmk-CAW_@K` to `mapSC_layout = Angle_@K` (`@K` is shorthand for ISO/ANS).
    - Some Extend layers like the main one use "hard" or positional remaps, which observe most ergo mods but not letter placements.
    - Here, `mapSC_extend = Angle_@K` too since Angle is a "hard" ergo mod. If using Curl-DH, you can move Ctrl+V by adding 'V-B,' in front.
* Change any key mappings you want to tweak.
    - The keys are mapped by their native Scan Codes (SC), so, e.g., SC02C is the QWERTY/Colemak Z key even if it's moved around later.
    - See the next section to learn more about key mapping syntax.
    - The mappings in the De layout are okay as they are, but let's say we want to swap V and Ö (OEM_102) for the sake of example.
    - In the `[layout]` section of layout.ini are the keys that are changed from the BaseLayout. OEM_102 is there, state 0/1 mapped to ö/Ö.
    - To find the V key, see the `baseLayout = Colemak\BaseLayout_Cmk-eD` line and open that file. There's the V key, SC02f.
    - Now, copy the V and OEM_102 keys to your layout.ini `[layout]` section so they'll override the baseLayout, and swap their SC### codes.
    - Alternatively, you could just edit the mappings for the affected shift states of the two keys. Use any white space between entries.
* Now, if your `EPKL_Layouts` .ini Type/Locale/Kbd/Curl/Ergo/Other settings are right you should get the variant you wanted.
    - Here, set LayType/LayVari/KbdType/CurlMod/ErgoMod/OthrMod to eD/De/ISO/--/Angle/-- respectively (or use 'MeinDe' if you went with that).
    - If you prefer to use another existing layout line in the file, comment out the `layout = ` line with `;` and activate another.
    - You can also write the `layout = LayoutFolder:DisplayedName` entry directly instead, using the folder path starting from `Layouts\`.
* After making layout changes, refresh EPKL with the Ctrl+Shift+5 hotkey. If that doesn't work, quit and restart EPKL.
* To get relevant help images without generating them with Inkscape:
    - Check around in the eD layout folders. Maybe there's something that works for you there despite a few minor differences?
    - Here, you might either keep the current De_ISO_CurlAWide settings to see the German special signs without making new images, or...
    - ...edit the image settings, replacing AWide/CAWide/CAngle with 'Angle' to get normal ISO_Angle images without German letters, or...
    - ...make new help images in an image editor by copying and combining from the ones you need. I use Gimp for such tasks.
* If you do want to generate a set of help images from your layout you must get Inkscape and run the EPKL Help Image Generator (HIG).
    - To see the "Create help images..." menu option, advancedMode must be on in [EPKL_Settings][PklIni].
    - The HIG will make images for the currently active layout.
    - You can download Inkscape for instance from PortableApps.com, and point to it in the [ImgGen_Settings](./Files/ImgGenerator/EPKL_ImgGen_Settings.ini) file.
    - By default, the HIG looks for Inkscape in `C:\PortableApps\InkscapePortable\InkscapePortable.exe`, so you could just put it there.
    - I recommend making state images only at first, since a full set of about 80 dead key images takes a _long_ time!
  
  
DONE:
-----
These are some of the changes in [EPKL] (PKL[eD] up to v1):
* v0.4.0: Transition to AHK v1.1
	- A Refresh menu option with a hotkey (default Ctrl+Shift+5) in case the program hangs up in some way (stuck modifiers etc).
	- Advanced Mode setting that shows 'AHK key history' and other menu options, plus more info in the About... dialog.
	- Sensible dead key names for images and entries (e.g., @14 -> tilde) in a central file that layouts can point to.
	- A PKL_Tables.ini file for info tables that were formerly internal. This way, the user can make additions as necessary.
* v0.4.1: Transition to AHK v1.1 Unicode, using native Unicode Send and UTF-8 compatible files.
	- A base layout file can be specified, allowing layout.ini to only contain entries that should override the base layout.
* v0.4.2: Help image opacity, scaling, background color and gutter size settings. Help images can be pushed horizontally too.
	- Separate help image background/overlay, so keys/fingering, letters/glyphs and Shift/AltGr marks can be in different images.
* v0.4.3: Scan and virtual code modular remapping for layouts and Extend, making ergo and other variants much more accessible.
* v0.4.4: A Help Image Generator that uses Inkscape (separate download) to generate a set of help images from the current layout.
	- A shorthand notation in EPKL_Layouts.ini to specify KbdType (ISO/ANSI), CurlMod and ErgoMod with the layouts.
* v0.4.5: Layouts, Extend and dead keys now support the same prefix-entry syntax, parsing "%$*=@&" as first character specially.
	- The "&" prefix denotes literals/powerstrings found in a separate file. These may span more than one line.
* v0.4.6: The base layout can hold default settings. Layout entries are now any-whitespace delimited.
	- Read most layout settings apart from remaps from the base layout if not found in the main layout.
	- Requiring Tab delimited layout entries was too harsh. Now, any combination of Space/Tab is allowed.
* v0.4.7: Multi-Extend w/ 4 layers selectable by modifiers+Ext. Extend-tap-release. One-shot Extend layers.
	- Multi-Extend, allowing one Extend key with 2 modifiers (e.g., RAlt/RShift) to select up to 4 different layers. Ext+Mod{2/3/2+3} -> Ext2/3/4.
	- Ext2 is a NumPad/nav layer w/ some useful symbols. Ext3/Ext4 are one-shot string layers but mostly to be filled by the user.
	- Dual-role tap-release Extend key. Works as Back on tap within a certain time and Ext on hold. Set the time to 0 ms to disable it.
	- ExtReturnTo setting to allow one-shot Extend, e.g., for strings. Can for instance return from Ext3 to Ext1.
* v0.4.8: Sticky/One-shot modifiers. Tap the modifier(s), then within a certain time hit the key to modify.
	- Settings for which keys are OSM and the wait time. Stacking OSMs works (e.g., tap RShift, RCtrl, Left).
	- NOTE: Mapping LCtrl or RAlt as a Modifier causes trouble w/ AltGr. So they shouldn't be used as sticky mods or w/ Extend if using AltGr.
	- Powerstrings can have prefix-entry syntax too now. Lets you, e.g., have long AHK command strings referenced by name tags in layouts.
* v1.0.0: EPKL full release.
* v1.1.0: Some layout format changes. Minor fixes/additions. And kaomoji!  ♪～└[∵┌]└[･▥･]┘[┐∵]┘～♪
	- A set of 30+ Kaomoji text faces were added to the Strings Extend3 layer, with help images.  d( ^◇^)b
	- Extend layers can now be marked as hard/positional or soft/mnemonic. Extend1/2 are mostly hard, the kaomoji layer soft.
	- Direct Extend key mapping, e.g., for CapsLock use 'SC03A = Extend Modifier' instead of the old extend_key setting.
	- BaseLayout files are now at the same tree level as layout folders instead of inside one of them.
* v1.1.1: Some format changes. Minor fixes/additions. Tap-or-Mod keys (WIP).
	- New: Tap-or-Modifier a.k.a. Dual-Role Modifier keys. Work-in-progress, not working well for rapidly typed keys yet.
		- To make a ToM key, specify its VK layout entry as VK/Mod, where 'Mod' is a modifier name. The rest of the line can be any valid entry.
	- The Extend key can be set the old way as extend_key in [pkl] (but no layout entry is needed anymore!), as 'Ext Mod' or as ToM, e.g., 'VK/EXT VKey'
	- Modifiers can be referred to by the first letters of their name so, e.g., 'LS' and 'LSh' both point to LShift. Also, VK or VKey = VirtualKey.
	- Unicode points can be sent by the ~ prefix; a ~#### entry sends the U+#### character as used in MSKLC file entries.
	- The shiftStates layout entry is now in the [layouts] section of layout.ini, spaced out so entries have more room and are clearer.
	- Since Space/Tab are used to delimit layout entries, there are now special '&Spc' and '&Tab' PowerString entries for them.
	- Dead key abbreviations are now by code point instead of numbered, as in MSKLC. Example: The .klc entry 02c7@ is a caron DK; in EPKL it becomes @2c7.
* v1.1.2: Multifunction Tap-or-Mod Extend with dead keys on tap. Janitor inactivity timer.
	- Dead keys on Extend key tap. Examples: Tap {Extend, n} for parentheses with positioning. {Ext, z/Z} Undo/Redo. {Shift, Ext, letter} for kaomoji.
	- Sticky Shift works to select Extend dead keys, and stays active. If you want the shift-P kaomoji tap {Shift, Ext} then P quickly. If not, wait.
	- For InputRaw/Send/AHK/Blind/Unicode/DeadKey/PowerString entry prefixes, both the old %$*=~@& or →§αβ«Ð¶ (AltGr+Shift+ISABUDP) work now.
	- Direct dead key entries in the format <#> = <entry> work too. If the char is an uppercase version, append a plus (<#>+).
	- "Janitor" inactivity timeout setting (e.g., 2 s) to release any stuck modifiers. These can happen with advanced usage.
* v1.1.3: The LayStack, separating & overriding layout settings. Bugfixes. More kaomoji.
	- The downloadable release asset .zip file now contains all files needed to run EPKL. No Source/Other/Data nor .bat/.git. files.
	- The Kaomoji dead key now holds a related entry for each shifted letter/symbol, e.g., d( ^◇^)b vs (b￣◇￣)b.
	- An EPKL_Layouts_Default .ini file has been split off from EPKL_Settings.ini so the layout definitions have a file of their own.
	- If present, an EPKL_Layouts_Override.ini file will take precedence. In the future, this may be generated by a GUI panel.
	- Several mappings and settings common to most layouts are now in the Layouts_Default file. This includes the Extend modifier mapping.
	- The LayStack [ mainLay, baseLay, LayOver, LayDef ] can be used for most mappings and layout info, including Extend and DeadKey overrides.
	- Added Layout Type (eD or VK) and Other Mod (e.g., Sym) shortcuts to the Layouts.ini file.
	- Added eD/VK Colemak Curl(DHm) only layouts. Used CurlM/DHm here, to support ortho boards. Ortho help images are on the TODO list.
	- Fixed: DeadKey+Spc didn't release the base accent as it should.
* v1.1.4: Sym mod and Dvorak layouts. HIG updated for new Inkscape. Unified VK codes for layouts. Mapping/setting tweaks.
	- Three Sym(bol) mod variants: Improving quote/apostrophe (Qu), Minus/hyphen (Mn) or both (QuMn). ANSI uses both. Choose between them in the Remap file.
		- Premade Sym(QuMn) variants for VK/eD Colemak vanilla and CAW.
	- Dvorak layouts, with suitable Curl/Angle/Wide ergo mods. These are my suggestions and not "official" variants for now.
	- The HIG (Help Image Generator) has been updated for Inkscape v1.0 that's finally out! All images are now created in one call, a lot faster.
		- Also tweaked the HIG for Co_## KLM key codes since the image template doesn't have the underscore for these codes.
	- My KLM QW_## codes found in the Remap file may replace VK codes in layouts.
		- All BaseLayout files are now unified for KbdType by replacing ANS/ISO specific OEM_# VK codes with KLM ones.
		- KbdType @K codes for ANS/ISO in LayStack files, further simplifying ISO/ANSI conversion.
	- Key state and dead key mappings can be disabled using '--' or '-1' entries. Thus an entry can be removed in the LayStack.
* v1.1.5: Tarmak Curl(DHm) w/ ortho images. Suspending apps. Language tweaks, fixes.
	- The EPKL_Layouts_Override file is no longer tracked. Instead, there's an Override_Example file you can copy/rename/edit. Thus, your changes are kept over updates.
	- Added Tarmak-DH(m) alias Curl(M) for Ortho boards. There's a line in the EPKL_Layouts files for the Tarmak steps with DHm, but you can also use the shortcut syntax.
	- You can now list "suspendingApps" in Settings that automatically suspend EPKL when active. Specify by exe (X), window class (C) or any other AHK title match method.
	- To see the AHK window class and other info about the currently active window, there's now a hotkey (default Ctrl+Shift+0).
	- Image opacity hotkey (default Ctrl+Shift+8), toggling between opaque and transparent (by setting) help images.
	- Multi-ID locale variants can be addressed by their component. So for French, either Be Ca or Fr would point to the BeCaFr variant. Specified in the Tables file.
	- Added the Cmk-eD-Pl ANSI CAW Polish variant designed by Kuba Wiecheć, Colemak forum user Wiechciu. It swaps Z and V from ANSI Cmk-CAW, and adds żŻ to the Z key.
	- Added the QUARTZ pangram layout (Quartz/glyph [job];vex'd cwm,finks.), as a joke! I used a Wide mod for it, but beware that this is NOT a good layout!  ╭(๑•﹏•)╮
	- Fixed: Sticky Shift didn't get reset by the next typed key on VK layouts, leading to MULtiple SHifted characters.
* EPKL v1.1.6: New Curl-DH standard! EPKL For Dummies. KLM key codes. Extend fixes. AltGr layouts for Es/It, and Pan-Germanic locale variants.
	- Colemak-DH(m) (M on the home row) is now the Curl(DH) standard. The 2017 DH standard (K on the home row) is now named DHk in the Remap file. Files are updated.
	- Added a link to the useful "EPKL For Dummies!" guide by Torben Gundtofte-Bruun in the README. Also some images and text updates, and a new README for the Files.
	- Like VK codes, SC### scan codes in layouts & Extend can be replaced by the KLM Co or QW codes found in the Remap file. These are more intuitive and user friendly.
		- For VK entries, vc### is a synonym for the QW### KLM code. I felt that it makes sense to distinguish between SC and VK this way.
	- Fixed: Shift+Spc didn't send a shifted space, which should scroll up in most browser windows. Now, Spc is sent Blind.
	- Fixed: Extend mods such as `{Ext+S} = Shift` pressed quickly w/ ToM Ext often led to stuck mods. Now they're only depressed/released for each Extended key press.
	- Added EsAlt and ItAlt for users who prefer AltGr to DKs. Es/It have áéíóú/àèìòù on AltGr+aoeiu, and some tweaks to fit in other symbols. Es_ANS has ñ on AltGr+n.
	- Made the German and Scandinavian (De, DkNo & FiSe) Pan-Germanic, with easier access to each others' letters (De has ÆØÅ on AltGr+AOU; DkNo has ÄÖÜ etc).
	- Help Image Generator reworked. It can now take non-numeric entries. For DKs, it marks strings as ellipses and prefix syntax as for instance '·¶·'.
	- Currency dead key reworked. Several symbols added, most duplicates removed.
	- Fixed: Help images didn't always show on rapid dead key activation. Added a help image refresh (if the image is active) whenever a DK is activated.
	- Tip: Help images can be shown on other monitors using an extended workspace, by adjusting the margins to negative values. See the Settings file.
* EPKL v1.2.0α: Layout/Settings UI. Work-In-Progress.
	- Layout/Settings GUI panel. Only the Layout Picker is finished for now. Key Mapping and General Settings tabs are planned.
		- The Layout Picker can be used to select any existing layout variant combo in the Layouts folder.
		- When a Main Layout, Layout Type and Keyboard Type are chosen, existing Variants and Mods for that combo are shown.
		- Upon submitting, if a Layouts_Override file isn't found one can be created based on the _Example file.
		- A layout line is then written to the top of the `[pkl]` section of the Override file. This line will take precedence on the next Refresh.
		- Old UI generated lines will get commented out and if there are many of them (>4) the oldest ones get deleted.
	- Remaps and RemapCycle sections are now allowed in the LayStack. See the `_Test\Cmk-eD-Nyfee_ANS_CurlAngle` layout for an example.
	- Switching Slash and Backslash for Wide modded Extend brings the WheelLeft/Right keys together. Used it for Colemak-CAWS-ISO. Less intuitive for (C)AWide Ext2.
  
  
TODO:
-----
I have many more **[EPKL][EPKLRM]** improvements on my wishlist, including:
* A timer that checks whether the underlying Windows layout has changed (affects dead keys)
* Generic dual-role keys and/or modifiers. For instance, home row keys might act as modifiers when held and letters when tapped.
* Chainable dead keys, allowing for instance a Mother-of-DKs key for Compose-like "tap dance" sequences like {MoDK,t,n}->ñ.
* GUI panels for settings and layout choices instead of editing .ini files.
* An import module for MSKLC layout files and other formats.
  
  
Credits/sources
---------------
#### ~ The original [PKL][PKLGit] written by [Farkas Máté in 2008][PKLSFo] using [AutoHotkey][PKLAHK]
#### ~ [EPKL][CmkPKL], formerly PKL[edition DreymaR] by DreymaR, 2017-
#### ~ Big thanks to the AutoHotkey people, Vortex(vVv), the Colemak Forum crowd and all other contributors.
  
_Finally, to all of you: Best of luck using EPKL!_
_Øystein "DreymaR" Gadmar, 2020_

[PKLGit]: https://github.com/Portable-Keyboard-Layout/Portable-Keyboard-Layout/ (Old PKL on GitHub)
[PKLSFo]: https://sourceforge.net/projects/pkl/ (Old PKL on SourceForge)
[PKLAHK]: https://autohotkey.com/board/topic/25991-portable-keyboard-layout/ (Old PKL on the AutoHotkey forums)
[AHKHom]: https://autohotkey.com/ (AutoHotkey main page)
[CmkBBT]: https://forum.colemak.com/topic/2315-dreymars-big-bag-of-keyboard-tricks-main-topic/ (BigBagOfKbdTrix on the Colemak forums)
[CmkPKL]: https://forum.colemak.com/topic/1467-dreymars-big-bag-of-keyboard-tricks-pklwindows-edition/ (BigBag-PKL on the Colemak forums)
[StrtUp]: https://support.microsoft.com/en-us/help/4558286/windows-10-add-an-app-to-run-automatically-at-startup (Windows Startup folder)
[PrtApp]: https://portableapps.com/ (PortableApps.com)
[SCMSDN]: https://msdn.microsoft.com/en-us/library/aa299374(v=vs.60).aspx (Scan code list at MSDN)
[VKCAHK]: https://autohotkey.com/docs/KeyList.htm (Virtual key list in the AHK docs)
[GitRel]: https://github.com/DreymaR/BigBagKbdTrixPKL/releases/latest (Latest EPKL release)
[EPKL4D]: https://docs.google.com/document/d/1G0chfgAwdf8cF-uoPEUw0CWwKXW9-uuQiNLbYlnYurs (EPKL For Dummies, by Torben G.B.)
[ThothW]: https://en.wikipedia.org/wiki/Thoth (Thoth: Egyptian god of wisdom and writing)
[KeyTab]: ./Other/KeyCodeTable.txt (./Other/KeyCodeTable.txt)
[EPKLRM]: ./Files/ (EPKL Files folder/README)
[LayOvr]: ./EPKL_Layouts_Override_Example.ini (Layouts_Override example file)
[LayDef]: ./EPKL_Layouts_Default.ini (Layouts_Default file)
[PklIni]: ./EPKL_Settings.ini (Settings file)
[MapIni]: ./Files/_eD_Remap.ini (Remap file)
