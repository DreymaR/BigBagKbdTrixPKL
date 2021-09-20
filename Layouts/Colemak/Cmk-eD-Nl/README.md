DreymaR's Big Bag Of Keyboard Tricks - EPKL
===========================================
<br>

![EPKL help image for Colemak-eD-Nl-CAWS on an ISO board](./Cmk-eD-Nl_ISO-CAWS_s0_EPKL.png)

<br><br>

Colemak[eD] locale layouts
--------------------------
Most of the Cmk-eD locale variants use ISO keyboards with an AngleWide configuration to allow index finger access to the bracket and ISO_102 keys where I mostly put the needed locale letters.

This may be supplemented with Curl(DH) and Sym mods to provide Colemak-CAW(S) with locale letters. You could remove the Wide mod if desired, but then the right hand pinky may get overworked.

Some locales traditionally use ANSI keyboards though, and some prefer to use the AltGr key instead of dead keys. So there may be other variants available.
<br><br>

Colemak-Nl Dutch (Netherlands/Belgium) locale layout variant
------------------------------------------------------------
For Dutch locale Colemak, at the least we need accents easily accessible. There's also the ĳ digraph, but it's often written as a bigram (ij) instead. However, the J position in Colemak is not ideal since J is significantly more common in Dutch than in English.
- **Cmk-eD-Nl** has accents on the bracket keys. The ĳ digraph may go on the ISO key if you have it, and there's also an ij bigram on AltGr+i.
- The digraph is mostly used typographically and [even though it exists in Unicode its use is somewhat discouraged][WikiIJ].
- Therefore, by default it may be better to keep the immensely useful Compose key on the ISO key by default!
- With the Compose key, you can always type ij/IJ followed by Compose to produce an ĳ/Ĳ digraph.
- I've added Dutch specific completion to the Compose key so that i/I plus Compose complete to ij/IJ as well.
- If you decide that you do want the digraph ligature ĳ on your ISO key after all, uncomment it in your [layout.ini file][layini].
<br>

|![EPKL help image for Colemak-eD-Nl AngleWide on an ISO board, unshifted state](./Cmk-eD-Nl_ISO_AWide/state0.png)|
|   :---:   |
|_Colemak-eD-Nl_ISO_AWide, unshifted state. <br>The `ĳ` digraph on the ISO key may represent a Compose key._|

|![EPKL help image for Colemak-eD-Nl AngleWide on an ISO board, shifted state](./Cmk-eD-Nl_ISO_AWide/state1.png)|
|   :---:   |
|_Colemak-eD-Nl_ISO_AWide, shifted state._|

|![EPKL help image for Colemak-eD-Nl AngleWide on an ISO board, AltGr state](./Cmk-eD-Nl_ISO_AWide/state6.png)|
|   :---:   |
|_Colemak-eD-Nl_ISO_AWide, AltGr state. Note the `ij` bigram on `AltGr+i`._|


[WikiIJ]: https://en.wikipedia.org/wiki/IJ_(digraph)#Encoding (Wikipedia on encoding the IJ digraph)
[layini]: ./Cmk-eD-Nl_ISO_CurlAWideSym/layout.ini#L62
