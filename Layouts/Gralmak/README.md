DreymaR's Big Bag Of Keyboard Tricks - EPKL
===========================================

![Gralmak Ortho help image](./Gralmak_Orth-Cpt_EPKL.png)

_The Gralmak layout on an Ortho keyboard_

<br>

The Gralmak layout
------------------
- This layout was made by me (DreymaR), 2024-11.
- I consider it a variant of [Graphite][GraGit] and [Gallium (by GalileoBlues)][GalGit]. These layouts are very similar.
- Gralmak is also similar to other recent layouts, like [Nerps (by Smudge)][NrpGra] and [Sturdy][StrPKL].
- It may be said to use the [**Curl**][ErgCrl] principle, by reducing lateral stretches to the middle home row positions.
- An [**Angle**][ErgAWi] ergo mod is recommended for this layout on row-staggered boards.
- For more info, see [the Gralmak repository on GitHub][GrlGit].
<br>

![Gralmak Angle-ANSI help image](./Gralmak_ANS-A_EPKL.png)

_The Gralmak layout (using the Angle mod) on an ANSI keyboard_

<br>

- I wanted to make a Graphite-Gallium variant with traditional symbol/punctuation placements.
- Like most other layouts (and Graphite-HB), I didn't want to change the Shift states of keys.
- Thus came about the Gralmak variant that's easily ergo modified like, e.g., Colemak-CAWS.
- Like the [Gallium][GalPKL] and [Colemak][CmkPKL] layouts, I want J in the middle and a symbol (Quote) on pinky.
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

Gralmak Wide and Sym variants
------------------------------

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
|   z x m c v / k p . ,      |
+----------------------------+
```

#### Gralmak AWS-ISO:
```
+----------------------------+
| 1 2 3 4 5 6 \ 7 8 9 0 =    |
|  b l d w q [ j f o u ' -   |
|  n r t s g ] y h a e i ;   |
| z x m c v   / k p . ,      |
+----------------------------+
```

<br><br>


#### Gralmak-Pct, lower row only ( , . / swaps):
```
+----------------------------+
| z x m c v   k p . / ,      |
+----------------------------+
```

#### Gralmak AWS-ISO:
```
+----------------------------+
| 1 2 3 4 5 6 \ 7 8 9 0 =    |
|  b l d w q [ j f o u ' -   |
|  n r t s g ] y h a e i ;   |
| z x m c v _ / k p , .      |
+----------------------------+
```
<br>


![Gralmak-WS help image](./Gralmak_Orth-WS_EPKL.png)

_Gralmak-WideSym on an Ortho keyboard._

<br>

Gralmak Analysis
----------------
- Below is a comparison of the Graphite layout and the Gralmak variant, disregarding most punctuation.
- It's made by the 'cmini' analyzer at the AKL Discord, with thumb-key for common punctuation.
- As shown, the differences consist of swapping `J` and `QU`, and swapping `Z` and `Q`.
- All overall stat differences are so small that I don't think they can be considered significant.

- The J-QU swap makes 2-key rolls more outwards by 0.4%; this is okay with me.
- One-hand 3-key rolls are not significantly affected.
- The [Q-Z swap][Gal-QZ] retains a little more QWERTY/Colemak familiarity, at a very low stat cost.
- There is a small increase in alternating same-finger skipgrams, which I think is okay.
- Non-SFS alternation, accordingly, goes down by an insignificant amount (from 33.85% to 33.80%).

```
gralmak-thumb(new) - graphite-thumb(old)
  b l d w ~  ~ f o u ~
  n r t s g  y h a e i
  ~ x m c v  k p     /
               ! , . ; -

SHAI:
  Alter: -0.05%
  Rolls: -0.02%   (In/Out: -0.42% |  0.39%)
  One-h:  0.03%   (In/Out: -0.04% |  0.07%)
  Redir: -0.02%   (Bad:    -0.03%)

  SFB:    0.00%
  SFS:    0.06%   (Red/Alt: 0.01% | 0.05%)
```
<br>

![Gralmak ISO help image](./Gralmak_ISO-AWS_EPKL.png)

_Gralmak-AWS-ISO. The © key can be a Compose key, or whatever you wish._

<br><br>

GralQwest Transitions
---------------------
- Some [Colemak][CmkPKL] learners have used my [Tarmak][BBTtmk] transitional layouts to learn the layout in smaller steps.
- Some even said they couldn't have done it all at once. Others strongly prefer going all the way at once, cold turkey.
- Learning Gralmak from QWERTY is a longer way since Colemak(-DH) moves only 17(18) keys and Gralmak 24.
- It's still possible to construct learning loops for users who want to learn 3–6 keys at a time.

Here's a way of splitting up a QWERTY-to-Gralmak transition into five steps, roughly sorted by key frequencies:
```
Big loop of 18 keys:
    S → F → U → O → I → ; → 
    P → M → C → V → B → Q → 
    T → D → E → L → W → R

Miniloops of 3 keys:
    A → K → N
    Y → H → J

Not moved – 3 keys:
    G   Z   X
```

- It makes sense to misplace less common keys during the big loop steps: `;` in step 1, `Q` in step 2.
- The rationale for postponing the common `E` and `T` is to avoid misplacing the common `R`.
- It's up to the user whether miniloops should go before or after the big loop. The `Y` miniloop gives less benefit.
- the semicolon can be swapped with the apostrophe in the 2nd part of the big loop, when it finds its place.
- For now, I'm doing this mostly as a mental exercise. 
- If someone really wants to use such a set of transitional layouts, I could help implement them.

Thus, five "GralQwest" QWERTY-to-Gralmak transitional layouts might look as follows:
```
GralQwest 0, alias QWERTY:
q w e r t    y u i o p
a s d f g    h j k l ; '
z x c v b    n m , . /

GralQwest 1 (big loop 1/3):
q w e r t    y F O U p
a ; d S g    h j k l I '                S → F → U → O → I → (;)
z x c v b    n m

GralQwest 2 (big loop 2/3):
B w e r t    y f o u '
a q d s g    h j k l i ;                P → M → C → V → B → (Q)
z x M C V    n P

GralQwest 3 (big loop 3/3):
b L D W Q    y f o u '
a R T s g    h j k E i ;                T → D → E → L → W → R
z x m c v    n p

GralQwest 4 (A miniloop):
b l d w q    y f o u '
N r t s g    h j A e i ;                A → K → N
z x m c v    K p

GralQwest 5 (Y miniloop), alias Gralmak:
b l d w q    J f o u '
n r t s g    Y H a e i ;                Y → H → J
z x m c v    k p , . /
```

This progression prioritizes getting the big loop over with, to avoid "limbo" keys in neither-QWERTY-nor-Gralmak positions.

Alternatively, here are five "GralQwest" QWERTY-to-Gralmak transitional layouts with miniloops first:
```
GralQwest 0, alias QWERTY:
q w e r t    y u i o p
a s d f g    h j k l ;
z x c v b    n m , . /

GralQwest 1 (A miniloop):
q w e r t    y u i o p
N s d f g    h j A l ;                  A → K → N
z x c v b    K m

GralQwest 2 (Y miniloop):
q w e r t    J u i o p
n s d f g    Y H a l ;                  Y → H → J
z x c v b    k m

GralQwest 3 (big loop 1/3):
q w e r t    j F O U p
n ; d S g    y h a l I                  S → F → U → O → I → (;)
z x c v b    k m

GralQwest 4 (big loop 2/3):
B w e r t    j f o u '
n q d s g    y h a l i ;                P → M → C → V → B → (Q)
z x M C V    k P

GralQwest 5 (big loop 3/3), alias Gralmak:
b L D W Q    j f o u '
n R T s g    y h a E i ;                T → D → E → L → W → R
z x m c v    k p , . /
```

This progression might be useful if you wish to practice some smaller loops first. After step 3, you may want to jump to the finish.


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
