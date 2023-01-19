DreymaR's Big Bag Of Keyboard Tricks - EPKL
===========================================
<br>

![EPKL help image for Colemak-eD-EsLat AWide on an ISO board](./Cmk-eD-EsLat_ISO-AWi_s0_EPKL.png)

<br><br>

Colemak[eD] locale layouts
--------------------------
Most of the Cmk-eD locale variants use ISO keyboards with an AngleWide configuration to allow index finger access to the bracket and ISO_102 keys where I mostly put the needed locale letters.

This may be supplemented with Curl(DH) and Sym mods to provide Colemak-CAW(S) with locale letters. You could remove the Wide mod if desired, but then the right hand pinky may get overworked.

Some locales traditionally use ANSI keyboards though, and some prefer to use the AltGr key instead of dead keys. So there may be other variants available.
<br><br>

Spanish Colemak locale layout variants
--------------------------------------
For Spanish/Latin locale Colemak, at the least we need the letters áéíóú and ñ easily accessible.
- Actually, ñ isn't all that common so if you're adventurous you might use a Compose key to produce it.
- In this case, composing `nn` to ñ may feel like one key stroke too many and you can make `n` plus Compose produce ñ.
- Another neat trick for Spanish is making !/? plus Compose produce ¡/¿.
- If you're an advanced enough user that you use a CoDeKey, it's perfect for this kind of thing.
<br>

There are two main locale variant solutions, depending on your preferences:
- **Cmk-eD-EsLat**: This is good both for Spanish and other languages, using dead keys on brackets for the main accents.
<br>

|![EPKL help image for Colemak-eD-EsLat CurlAngleWideSym on an ISO board, unshifted state](../Cmk-eD-Es/Cmk-eD-EsLat_ISO_CurlAWideSym/state0.png)|
|   :---:   |
|_Colemak-eD-EsLat_ISO_CAWS, unshifted state. Accent DKs in the middle. For ANSI boards, ñ is on AltGr+n._|

<br>

- **Cmk-eD-EsAlt**: An alternative for those who prefer using AltGr. The letters áéíóú are easy to remember on AltGr+aeiou; ñ gets AltGr+n (on ISO boards, the ISO key).
<br>

|![EPKL help image for Colemak-eD-EsAlt on an ANSI board, the AltGr state](./Cmk-eD-EsAlt_ANS_CurlAngle/state6.png)|
|   :---:   |
|_Colemak-eD-EsAlt_ANS_CurlAngle, AltGr state_|
<br><br>

Issues with using Colemak for Spanish
-------------------------------------
Obviously, Colemak was developed for English but that's generally okay since the Latin languages have mostly similar frequencies for the most common letters.
- In particular, the <kbd>H</kbd> key may actually have a slightly too good place for English – but that's just perfect for Spanish!
- <kbd>A</kbd> is common in Spanish and you may worry about Colemak leaving it on the left pinky. But as long as the pinky doesn't move too much, that's fine.
- Since most of us write in English too, learning one layout that works okay for both should be enough. Colemak is such a layout.

However, [there are still some real issues][RedCmkEs].
- The <kbd>Z</kbd> key creates same-finger bigrams with <kbd>A</kbd>, and the `UE` SFB is quite common in Spanish.
- You may use the Angle-Z (ANSI Angle) mod, so <kbd>Z</kbd> moves to the left index finger. This will solve the `AZ`/`ZA` SFB.
- To alleviate the `UE` bigram (and `ÑO` if you put <kbd>Ñ</kbd> on a bracket and don't use the Wide mod), some suggest a `O-U` swap.
- I'm really not sure, myself. I'd probably just use AngleWide or CAWS mods and "tank" the rest, like I do when typing my own language.
- However, if you're convinced and adventurous, EPKL does support a `O-U` swap:
    - Prepend the `mapSC_layout` entry in your `Layout.ini` file with `O-U,`, so it reads `mapSC_layout    = O-U,` etc.
    - Then refresh EPKL. The help images will not be updated; you can generate new ones if you have the Inkscape program.


[RedCmkEs]: https://www.reddit.com/r/Colemak/comments/v7jzj4/colemak_in_spanish_dh_mod/ (A Reddit topic on issues with using Colemak for Spanish)