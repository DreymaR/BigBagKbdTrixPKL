DreymaR's Big Bag Of Keyboard Tricks - EPKL
===========================================
<br>

|![Changed keys for Colemak-eD-Vi on an ANSI board](./Cmk-eD-Vi_ANS/Cmk-eD-Vi_ANS_ChangedKeys.png)|
|   :---:   |
|_A diagram over the keys affected by Colemak-eD-Vi_|

<br><br>

Colemak[eD] locale layouts
--------------------------
Most of the Cmk-eD locale variants use ISO keyboards with an AngleWide configuration to allow index finger access to the bracket and ISO_102 keys where I mostly put the needed locale letters.

This may be supplemented with Curl(DH) and Sym mods to provide Colemak-CAW(S) with locale letters. You could remove the Wide mod if desired, but then the right hand pinky may get overworked.

Some locales traditionally use ANSI keyboards though, and some prefer to use the AltGr key instead of dead keys. So there may be other variants available.
<br><br>

Colemak-Vi Tiếng Việt (Vietnam) locale layout variant
-----------------------------------------------------
This layout variant aims to provide a Vietnamese Colemak that works well with EPKL and Colemak[eD].
- Special letters are on AltGr(RAlt) plus letters D A W E O I U → đ â ă ê ô ơ ư
- Accents ´`?~. are on bracket keys as well as AltGr plus R S T.
- This layout was designed to work with a standard US-type ANSI system (Windows) layout with RAlt key not predefined as AltGr.
- This type of system layout is typical for US and Vietnamese keyboards. This layout also works on ISO keyboards though!
<br>

|![EPKL help image for Colemak-eD-Vi on an ANSI board, AltGr state](./Cmk-eD-Vi_ANS/state6.png)|
|   :---:   |
|_Colemak-eD-Vi_ANS, AltGr state_|

|![EPKL help image for Colemak-eD-Vi on an ANSI board, Shift+AltGr state](./Cmk-eD-Vi_ANS/state7.png)|
|   :---:   |
|_Colemak-eD-Vi_ANS, Shift+AltGr state_|
<br><br>

Use an IME instead?
-------------------
Many users are accustomed to their Input Method for languages like Vietnamese, and want to keep using it with Colemak.
- Unfortunately, that's not trivial since the standard Windows IMEs are linked to language – which means the QWERTY layout.
- There is a way of relinking which layout is the default for a language. It involves Registry editing, so it's rather high-tech.
- It's described in the Reddit post "[How to: Colemak for ... IMEs][IMEreg]". The Vietnamese language has the ID `0000042a`.
- That way, you could use an installed Colemak such as the one in the [EPKL Other\MSKLC][PklKLC] folder or from the [Colemak site][CmkCom].
- Relevant Registry keys are in these locations:
```
Computer\HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Keyboard Layouts\0000042a
Computer\HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\i8042prt\Parameters
```

[IMEreg]: https://www.reddit.com/r/Colemak/comments/9rq7vv/how_to_colemak_for_japanese_chinese_and_other/ (Reddit – How to: Colemak for ... IMEs)
[CmkCom]: https://www.colemak.com (The Colemak official site)
[PklKLC]: ../../../Other/MSKLC     (EPKL's Microsoft Keyboard Layout Creator folder)
