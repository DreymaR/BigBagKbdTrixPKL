DreymaR's Big Bag Of Keyboard Tricks - EPKL
===========================================
<br><br>

![Graphite Angle-ANSI help image](./Graphite_ANS-A_EPKL.png)

_The default Graphite layout (using the Angle mod) on an ANSI keyboard_

<br><br>

The Graphite layout
--------------------
- This layout was made by Richard Davison alias 'stronglytyped', 2022-12, as a development from [Sturdy][StrPKL].
- It may be said to use the [**Curl**][ErgCrl] principle, by reducing lateral stretches to the middle home row positions.
- An [**Angle**][ErgAWi] ergo mod is recommended for this layout on row-staggered boards.
- For more info, see [the Graphite repo on GitHub][GraGit].
- Graphite is similar to other recent layouts, like [Nerps (by Smudge)][NrpGra] and [Gallium (by GalileoBlues)][GalGit].
- It is, in fact, amazing how Graphite and [Gallium][GalPKL] are virtually the same layout, albeit developed independently!
<br>

- Fun quote on why it's called Graphite: "...because it is a rock used for writing, and also rock beats [scissors][GraSci]".
- Its standard variant changes some shifted mappings; see below.
<br>

#### The Graphite layout on a ortho/matrix board, showing base and shifted mappings:
```
+----------------------------+
| 1 2 3 4 5   6 7 8 9 0  [ ] |
| b l d w z   ' f o u j  ; = |
| n r t s g   y h a e i  , \ |
| q x m c v   k p . - /      |
+----------------------------+
| ! @ # $ %   ^ & * ( )  { } |
| B L D W Z   _ F O U J  : + |
| N R T S G   Y H A E I  ? | |
| Q X M C V   K P > " <      |
+----------------------------+
```

#### The Graphite layout on an ANSI board, with an Angle(Q) ergo mod:
```
+-----------------------------+
| b l d w z   ' f o u j ; = \ |
| n r t s g   y h a e i ,     |
|  x m c v q   k p . - /      |
+-----------------------------+
```
<br>

|![EPKL help image for Graphite-eD on an ANSI board, unshifted layer](./Gra-eD_ANS_Angle/state0.png)|
|   :---:   |
|_The Graphite-eD layout on an ANSI board, unshifted layer_|

|![EPKL help image for Graphite-eD on an ANSI board, AltGr+Shift layer](./Gra-eD_ANS_Angle/state7.png)|
|   :---:   |
|_The Graphite-eD layout on an ANSI board, AltGr+Shift layer_|

<br><br>

Graphite-HB
-----------
- Graphite has four non-standard shift level mappings, see the figure below.
- This affects the Quote (QU), Minus (MN), Comma (CM) and Slash (SL) keys.
- This makes the double quote and question mark more accessible; not a bad idea in and of itself.
- In my opinion though, that's not quite worth it, making key remapping (VK maps, programmable boards/devices using HID protocol) a lot harder.
- Consequently, I added a keymap-friendly variant, the `Graphite-HB` ("**HB**" for "Hardware Bound" – and for fun!).
- You can select your preferred variant using the `Variant/Locale` setting in the `Layout Selector` GUI.
- The `HB` variant does make the common double quote hard to reach on this layout, especially on row-staggered boards.
- However, with EPKL it's possible to get around such problems elegantly by using a [CoDeKey][CoDeKy] or other [sequencing][BBTSeq] options.
- Another option for quote key fans, is to use a [Gallium][GalPKL] variant instead, or [Gralmak][gralmk]. These, like Colemak, relegate the `J` key to that awkward position.
<br>

#### Graphite's altered shift state mappings, from its [web page][GraGit]:
```
+----------------------------+
| b l d w z   ' f o u j  ; = |
| n r t s g   y h a e i  , \ |
| q x m c v   k p . - /      |
+----------------------------+
| • • • • •   _ • • • •  • • |
| • • • • •   • • • • •  ? • |
| • • • • •   • • • " <      |
+----------------------------+
```
<br><br>

Graphite Wide and Sym variants
------------------------------

- [**W**ide][ErgAWi] ergo mods (moving right-hand keys one position to the right) usually place the two bracket keys in the middle.
- For a Wide modded Graphite variant, some special remaps from standard key positions are necessary.
- The base Graphite layout already moves its bracket keys to the top row, putting SC(;) and PL(=) in their places.
<br>

- [**S**ym(bol)][ErgSym] mods usually prioritize the common <kbd>'"</kbd> (Apostrophe/Quote) and <kbd>-_</kbd> (Hyphen/Underscore) keys.
- Graphite already moves most of the symbol keys around in its own fashion, so not everyone may want a further Sym mod.
- As seen below though, the [Gralmak][gralmk] variant is in itself a Sym (UnSym) mod, making for familiar AngleWideSym combos.
- I advise moving the Quote key to be even more accessible. Especially if using the `HB` (keymap friendly) variant!
- For Wide variants, a Sym mod is beneficial. I've proposed Graphite WideSym variants similar to my other WideSym layout variants.
- I prefer the hyphen on the upper row instead of the lower row. Seems this is a matter of individual preference.
- For ISO that's easily achievable, but for ANSI you have no extra key to the right of Quote (Graphite Comma).
- The solution for ANSI seems to be to bring Comma back to the lower row, and with that the `E,` same-finger bigram. Let me know if you have a better suggestion.
<br>

#### Graphite AWS-ISO proposal:
```
+----------------------------+
| 1 2 3 4 5 6 \ 7 8 9 0 =    |
|  b l d w z [ ' f o u j -   |
|  n r t s g ] y h a e i ,   |
| q x m c v _ / k p . ;      |
+----------------------------+
```

#### Graphite AWS-ANSI proposal, with the comma under UE:
```
+----------------------------+
| 1 2 3 4 5 6 \ 7 8 9 0 =    |
|  b l d w z [ ' f o u j - ; |
|  n r t s g ] y h a e i     |
|   x m c v q / k p . ,      |
+----------------------------+
```
<br>

The details of Graphite WideSym modding aren't up to me alone, of course. I've asked Richard Davison for his thoughts on it.
<br>

![Graphite (C)AWS-ISO help image](./Graphite_ISO-AWS_EPKL.png)

_The Graphite-(C)AWS-ISO layout. The © key can be a Compose key, or whatever you wish._

<br><br>

Gralmak
-------
- Out of interest, I wanted to make a mod variant with traditional symbol/punctuation placements.
- Thus came about the "Gralmak" variant that's easily ergo modified like, e.g., Colemak-CAWS.
- Eventually, I also brought Z back to its familiar spot where QWERTY and Colemak has it.
- The name is a play on Graphite-Gallium-Colemak, and our quest for the mythical "Holy Grail" of layouts!
<br>

- It's easier to learn for someone coming from QWERTY, Colemak, and other layouts that leave the symbol keys unchanged.
- In this capacity, it can be a stepping-stone to full Graphite! Learn Gralmak first, then decide whether to proceed.
- This incurs some worse punctuation bigrams. Since I use my thumb [CoDeKey][CoDeKy] for most punctuation, I don't care.
<br>

- Like the [Gallium][GalPKL] layout and Colemak, I want the J in the middle and a symbol (Quote) on pinky.
- Like most other layouts (and Graphite-HB), I don't want to change the Shift states of keys.
- Note that there are others who have reached nearly the same variant as this one, such as [Galite][Galite].
- Also see the README for the similar [Galliard][Gallrd] Gallium variant.

#### Graphite AWS-ISO "Gralmak":
```
+----------------------------+
| 1 2 3 4 5 6 \ 7 8 9 0 =    |
|  b l d w q [ j f o u ' -   |
|  n r t s g ] y h a e i ;   |
| z x m c v _ / k p , .      |
+----------------------------+
```
<br>

![Gralmak ISO help image](./Gralmak_ISO-AWS_EPKL.png)

_The Gralmak (Graphite-AWS-ISO) layout. The © key can be a Compose key, or whatever you wish._

<br>

- Below is a comparison of the Graphite layout and the Gralmak variant.
- It's made by the 'cmini' analyzer at the AKL Discord, with thumb-key for common punctuation.
- As shown, the differences consist of swapping J and QU, and swapping Z and Q.
- All overall stat differences are so small that I don't think they can be considered significant.
- The J-QU swap makes 2-key rolls more outwards; this is okay with me. One-hand 3-key rolls are less affected.
- The Q-Z swap keeps a little more QWERTY/Colemak familiarity, at a very low stat cost but with no other benefits.
- There is a small increase in same-finger skipgrams, but only for alternating ones which I think is okay.
- Non-SFS alternation, accordingly, goes down by a fairly insignificant amount (from 33.85% to 33.80%).

```
gralmak-thumb(new) - graphite-thumb(old)
  b l d w ~  ~ f o u ~
  n r t s g  y h a e i
  ~ x m c v  k p     /
                 , . ;

SHAI:
  Alter: -0.05%
  Rolls: -0.02%   (In/Out: -0.42% |  0.39%)
  One-h:  0.03%   (In/Out: -0.04% |  0.07%)
  Redir: -0.02%   (Bad:    -0.03%)

  SFB:    0.00%
  SFS:    0.06%   (Red/Alt: 0.01% | 0.05%)
```

<br><br>

![Graphite image from its web site](./_Res/Graphite_Web.png)

_The Graphite layout. Image taken from its own [web page][GraGit]._


[GraGit]: https://github.com/rdavison/graphite-layout               (The Graphite layout on GitHub)
[GalGit]: https://github.com/GalileoBlues/Gallium                   (The Gallium layout on GitHub)
[NrpRed]: https://www.reddit.com/r/KeyboardLayouts/comments/tpwyjc/ (The Nerps layout on Reddit)
[NrpGra]: https://www.reddit.com/r/KeyboardLayouts/comments/tpwyjc/comment/jck98z6/ (Graphite comment in the Nerps post on Reddit)
[GraSci]: https://github.com/rdavison/graphite-layout/blob/main/README.md#on-scissors (The Graphite README on Scissors)
[StrPKL]: ../Sturdy/                                                (The Sturdy layout in EPKL)
[GalPKL]: ../Gallium/                                               (The Gallium layout in EPKL)
[Gallrd]: ../Gallium/README.md#galliard                             (The Galliard Gallium layout variant)
[Gralmk]: #gralmak                                                  (The Gralmak Graphite layout variant)
[Galite]: https://github.com/almk-dev/galite/                       (The Galite layout variant, nearly equal to Gralmak)
[ErgAWi]: https://dreymar.colemak.org/ergo-mods.html#angle-wide     (DreymaR's BigBag on Angle+Wide ergo mods)
[ErgCrl]: https://dreymar.colemak.org/ergo-mods.html#curl-dh        (DreymaR's BigBag on the Curl-DH ergo mod)
[ErgSym]: https://dreymar.colemak.org/ergo-mods.html#symbols        (DreymaR's BigBag on the Symbols ergo mod)
[BBTSeq]: https://dreymar.colemak.org/layers-main.html#sequences    (DreymaR's BigBag on sequencing)
[CoDeKy]: https://github.com/DreymaR/BigBagKbdTrixPKL/blob/master/README.md#advanced-composecodekey  (The EPKL README on the CoDeKey)
