<h1 align=center line-height=1.6>Gralmak</h1><br><br>

<div align=center ><img src="./Gralmak_Orth-Cpt_EPKL.png" 
                        alt="The Gralmak layout on an Ortho keyboard"></div><br>

The Gralmak layout
------------------
- This layout was made by DreymaR (that's me!), 2024-11.
- It is a variant of [Graphite][GraGit] by StronglyTyped and [Gallium][GalGit] by GalileoBlues. These layouts are very similar.
- Gallium/Graphite are in turn related to other recent layouts, like [Sturdy][StrPKL] by Oxey and [Nerps][NrpGra] by Smudge.
- Gralmak may be said to use the [**Curl**][ErgCrl] principle, by reducing lateral stretches to the middle home row positions.
- An [**Angle**][ErgAWi] ergo mod is recommended for this layout on row-staggered boards.
- For more info, see [the Gralmak repository on GitHub][GrlGit].
<br>

![Gralmak Angle-ANSI help image](./Gralmak_ANS-A_EPKL.png)

_The Gralmak layout (using the Angle mod) on an ANSI keyboard_

<br>

- I wanted to make a Graphite-Gallium variant with traditional symbol/punctuation placements.
- Like most other layouts (and Graphite-HB), I didn't want to change the Shift states of keys.
- Thus came about the Gralmak variant that's easily ergo modified like, e.g., Colemak-CAWS.
- Like the [Gallium][GalPKL] and [Colemak(-Sym)][CmkPKL] layouts, I want J in the middle and a symbol (Quote) on pinky.
- Eventually, I also brought Z back to its familiar spot where QWERTY and Colemak has it.
- The name is a play on Graphite-Gallium-Colemak, and our quest for the mythical "Holy Grail" of layouts!
<br>

#### Gralmak on an ortho board (w/ trad. punctuation):
```
+----------------------------+
| 1 2 3 4 5   6 7 8 9 0  - = |
| b l d w q   j f o u '  [ ] |
| n r t s g   y h a e i  ; \ |
| z x m c v   k p , . /      |
+----------------------------+
```

#### The Gralmak layout on an ANSI board, with an Angle(Z) ergo mod:
```
+-----------------------------+
| b l d w q   j f o u ' [ ] \ |
| n r t s g   y h a e i ;     |
|  x m c v z   k p , . /      |
+-----------------------------+
```
<br>

- It's easier to learn for someone coming from QWERTY, Colemak, and other layouts that leave the symbol keys unchanged.
- In this capacity, it can also be a stepping-stone to full Graphite or Gallium! Learn Gralmak first, then decide whether to proceed.
- This incurs some worse punctuation bigrams. Since I use my thumb [CoDeKey][CoDeKy] for most punctuation, I don't care.
- If you don't use punctuation solutions, you may modify Gralmak with a Sym ergo mod instead; see below.
<br>

- This layout manages to satisfy newer analyzers and still keep some similarity to well-known layouts like Colemak.
- For instance, only `L N M` and `F A E` swap hands from QWERTY; `L N M` and `F A P` from Colemak.
- The familiar `QW RT ZX CV` bigrams are (semi-)preserved in Gralmak, also aiding learning and recognition.
- Also see the README for the similar [Galliard][Gallrd] Gallium variant.
<br>

|![EPKL help image for Gralmak-eD on an ANSI board, unshifted layer](./Gra-eD-Gralmak_ANS/state0.png)|
|   :---:   |
|_The Gralmak-eD layout on an ANSI board, unshifted layer_|

|![EPKL help image for Gralmak-eD on an ANSI board, AltGr+Shift layer](./Gra-eD-Gralmak_ANS/state7.png)|
|   :---:   |
|_The Gralmak-eD layout on an ANSI board, AltGr+Shift layer_|

<br><br>

GralmakS
--------
- Standard Gralmak keeps punctuation unmoved from QWERTY, like Colemak and some other layouts do. This makes it easier to learn and transition to.
- Another reason for it, as mentioned above, is that I can use a special thumb [CoDeKey][CoDeKy] for most punctuation.
- However, if you type text with punctuation with Gralmak and don't have access to such a special key, there will be some issues.
- The main issues according to Cyanophage's analyzer are the `E.` SFB (0.14%) and the `O_,` skip-1-gram (0.07%).
- Thus, Gralmak-Sym or simply "GralmakS" is a variant that simply remaps the `. / ,` keys while keeping other punctuation unchanged as before.
- GralmakS thus uses Graphite's period on the OA column. Both Gallium and Graphite have comma placed with I on the pinky.
- You'll have to decide whether that's useful though. You could also use either Gallium or Graphite punctuation, should you wish to.
    - Gallium punctuation has lower SFB% according to cmini analysis. The period is literally the key to that.
    - At the same time, Gallium achieves that by loading the pinky with both comma and period. Maybe some dislike that?
- Moving the hyphen to a better position is also recommended for all my Sym mods. It deserves that. The brackets go up, as on Graphite.
- Unfortunately, this sym mod doesn't play well with a Wide ergo configuration, since that'd displace the comma. You have to choose one.

```
Gralmak:
+----------------------------+
| 1 2 3 4 5   6 7 8 9 0  - = |
| b l d w q   j f o u '  [ ] |
| n r t s g   y h a e i  ; \ |
| z x m c v   k p , . /      |
+----------------------------+

GralmakS:
+----------------------------+
| · · · · ·   · · · · ·  [ ] |
| · · · · ·   · · · · '  - = |
| · · · · ·   · · · · ·  ; \ |
| · · · · ·   · · . / ,      |
+----------------------------+

Graphite:
+----------------------------+
| · · · · ·   · · · · ·  [ ] |
| · · · · ·   ' · · · ·  ; = |
| · · · · ·   · · · · ·  , \ |
| · · · · ·   · · . - /      |
+----------------------------+

Gallium:
+----------------------------+
| · · · · ·   · · · · ·  - = |
| · · · · ·   · · · · ,  [ ] |
| · · · · ·   · · · · ·  /   |
| · · · · ·   · · ' ; .      |
+----------------------------+
```

<br>

Gralmak WideSym
---------------
- [**W**ide][ErgAWi] ergo mods (moving right-hand keys one position to the right) usually place the two bracket keys in the middle.
- Wide/Sym modded Gralmak variants are fairly straightforward from base Gralmak, as it doesn't change any symbol keys apart from the apostrophe/semicolon.
<br>

- [**S**ym(bol)][ErgSym] mods usually prioritize the common <kbd>'"</kbd> (Apostrophe/Quote) and <kbd>-_</kbd> (Hyphen/Underscore) keys.
- For Wide variants, a Sym mod is beneficial. I've implemented Gralmak WideSym variants.
- I prefer the hyphen on the upper row instead of the lower row. Seems this is a matter of individual preference.
<br>

#### Gralmak AWS-ANSI:
```
+----------------------------+
| 1 2 3 4 5 6 \ 7 8 9 0 =    |
|  b l d w q [ j f o u ' - ; |
|  n r t s g ] y h a e i     |
|   z x m c v / k p , .      |
+----------------------------+
```

#### Gralmak AWS-ISO:
```
+----------------------------+
| 1 2 3 4 5 6 \ 7 8 9 0 =    |
|  b l d w q [ j f o u ' -   |
|  n r t s g ] y h a e i ;   |
| z x m c v   / k p , .      |
+----------------------------+
```

<br><br>

![Gralmak-WS help image](./Gralmak_Orth-WS_EPKL.png)

_Gralmak-WideSym on an Ortho keyboard._

<br>

<h1 align=center>⌨&nbsp;&nbsp;&nbsp;⌨&nbsp;&nbsp;&nbsp;⌨&nbsp;&nbsp;&nbsp;⌨&nbsp;&nbsp;&nbsp;⌨</h1>

<br><br>

![Gralmak ISO help image](./Gralmak_ISO-AWS_EPKL.png)

_Gralmak-AWS-ISO. The © key can be a Compose key, or whatever you wish._


[GraGit]: https://github.com/rdavison/graphite-layout#graphite-keyboard-layout          (The Graphite layout on GitHub)
[GalGit]: https://github.com/GalileoBlues/Gallium#gallium                               (The Gallium layout on GitHub)
[GrlGit]: https://github.com/DreymaR/Gralmak#gralmak                                    (The Gralmak layout on GitHub)
[NrpRed]: https://www.reddit.com/r/KeyboardLayouts/comments/tpwyjc/                     (The Nerps layout on Reddit)
[NrpGra]: https://www.reddit.com/r/KeyboardLayouts/comments/tpwyjc/comment/jck98z6/     (Graphite comment in the Nerps post on Reddit)
[GraSci]: https://github.com/rdavison/graphite-layout/blob/main/README.md#on-scissors   (The Graphite README on Scissors)
[CmkPKL]: /Layouts/Colemak/                                                             (The Colemak layout in EPKL)
[StrPKL]: /Layouts/Sturdy/                                                              (The Sturdy layout in EPKL)
[GalPKL]: /Layouts/Gallium/                                                             (The Gallium layout in EPKL)
[Gallrd]: /Layouts/Gallium/README.md#galliard                                           (The Galliard Gallium layout variant)
[GraPKL]: /Layouts/Graphite/                                                            (The Graphite layout in EPKL)
[Gralmk]: #gralmak                                                                      (The Gralmak Graphite layout variant)
[Galite]: https://github.com/almk-dev/galite/                                           (The Galite variant, nearly equal to Gralmak - now removed)
[ErgAWi]: https://dreymar.colemak.org/ergo-mods.html#angle-wide                         (DreymaR's BigBag on Angle+Wide ergo mods)
[ErgCrl]: https://dreymar.colemak.org/ergo-mods.html#curl-dh                            (DreymaR's BigBag on the Curl-DH ergo mod)
[ErgSym]: https://dreymar.colemak.org/ergo-mods.html#symbols                            (DreymaR's BigBag on the Symbols ergo mod)
[BBTseq]: https://dreymar.colemak.org/layers-main.html#sequences                        (DreymaR's BigBag on sequencing)
[BBTtmk]: https://dreymar.colemak.org/tarmak-intro.html                                 (DreymaR's Big Bag on Tarmak transitions)
[CoDeKy]: https://github.com/DreymaR/BigBagKbdTrixPKL/blob/master/README.md#advanced-composecodekey  (The EPKL README on the CoDeKey)
[Gal-QZ]: https://github.com/GalileoBlues/Gallium/issues/6#issuecomment-2665066910      (Discussing a Q-Z swap w/ almk on the Gallium repo)
[GraPct]: https://github.com/rdavison/graphite-layout/issues/2#issuecomment-2787752575  (Discussing Graphite punctuation and Wide mods on its repo)
