DreymaR's Big Bag Of Keyboard Tricks - EPKL
===========================================

![EPKL help image for the test layout Colemak-QI;x](Cmk-eD-QIx/Colemak-QIx_ANS-CAS_EPKL.png)  
  
  
_Test folder info
-----------------
This is where EPKL holds layouts that aren't fully tested as part of the BigBag, and/or don't quite belong in there ... yet?
  
If I wish to tuck something away because in my opinion it'd cause more confusion than necessary in one of the other folders, it may spend time in this folder. 
Some layouts require more testing, or their compatibility with my other mods and variants may be on the problematic side. There's already a lot of Colemak variants in the Colemak folder, for instance.
  
Some strange layouts are still out in the main folder for fun, such as the joke layouts QUARTZ (Perfect Pangram layout) and Foalmak (April's Foals layout). I should hope it's easy enough for users to get those jokes.
  
  
Implementation
--------------
To use any of these layouts, there are two main ways you can go:
- If you want to see the layout in the Layout/Settings menu, copy it over to a fitting main `Layouts\` folder.
    - Keep in mind that normally the first three letters of the MainLayout and layout variant folder must match.
    - Thus, if you put a variant inside the Colemak folder its folder name should begin with `Cmk` to be seen. 
    - In any folder without a special abbreviation, just use the first three letters of its name.
- You could also point to it in an active `layout = ` line in your `EPKL_Layouts_Override.ini` file under the `[pkl]` section. 
    - If you haven't got one, copy-paste one from the `EPKL_Layouts_Override_Example` file.
    - Example: `layout = _Test\Cmk-eD-QIx\Cmk-eD-QIx_ANS_CurlAngleSym:Cmk-TestLayout` for the Colemak-QI;x ANSI mod.
