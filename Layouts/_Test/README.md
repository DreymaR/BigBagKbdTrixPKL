DreymaR's Big Bag Of Keyboard Tricks - EPKL
===========================================

![EPKL help image for the experimental mod Colemak-QI;x](../Colemak/Cmk-eD-Qmods/Colemak-QIx_ANS-CAS_EPKL.png)
<br><br>

_Test folder info
-----------------
This is where EPKL holds layouts that aren't fully tested as part of the BigBag, and/or don't quite belong in there ... yet?

If I wish to tuck something away because in my opinion it'd cause more confusion than necessary in one of the other folders, it may spend time in this folder. 
Some layouts require more testing, or their compatibility with my other mods and variants may be on the problematic side. There's already a lot of Colemak variants in the Colemak folder, for instance.

Some strange layouts are still out in the main folder for fun, such as the joke layouts QUARTZ (Perfect Pangram layout) and Foalmak (April's Foals layout). I should hope it's easy enough for users to get those jokes.
<br>

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
<br>

Simple Layout Analysis
----------------------
I've run some simple analysis, using the [ColemakMods Analyzer][CmmAna] with comparable settings:
- ColemakMods analysis was done on a 3×10 matrix with the upper right symbol kept as a semicolon if relevant, for fairness.
- Changes in base, SFB and total (which also includes "near-finger" bigram effort) were reported as Δ rel. to Colemak-DH.
- More analysis and observations regarding Nyfee's "Q" mods is found in the QI;x folder README.
<br>

```
Layout            : bas.ef. sfb-ef. nfb-ef. tot.ef. SFB%      Δbas.e  Δsfb-e  Δtot.e
=========================================================    ========================
Cmk-DH            : 1.630   0.047   0.010   1.687   1.521      0       0       0
ColemaQ           : 1.645   0.031   0.011   1.687   0.974     +0.015  -0.016   0.000 (VK      + /, + Q;)
ColemaQ-F         : 1.646   0.034   0.011   1.692   1.107     +0.016  -0.014  +0.005 (VK + FG + /, + Q;)
Colemak-QI   noQU : 1.624   0.040   0.017   1.681   1.275     -0.006  -0.007  -0.006 (PM + BK + WFL)
Colemak-QI;x      : 1.640   0.029   0.019   1.688   0.938     +0.010  -0.018  +0.001 (Cmk-QI  + /, + Q; + WC)
Cmk-DH +VK only   : 1.630   0.041   0.009   1.679   1.311      0.000  -0.006  -0.008 !!?
ISRT/IndyRad noQU : 1.625   0.024   0.010   1.659   0.777     -0.005  -0.023  -0.028 !!!
SIND              : 1.707   0.018   0.039   1.763   0.598     +0.077  -0.029  +0.076 ?!?
Shai's Cmk-DpH    : 1.657   0.047   0.010   1.714   1.521     +0.027   0.000  +0.027 (DP instead of DvBG)
Shai's 2nd mod    : 1.622   0.054   0.010   1.686   1.671     -0.008  +0.007  -0.001 (PM + VBK)
"IndyPendant"     : 1.643   0.024   0.028   1.696   0.777     +0.013  -0.023  +0.009 ?!?
HandsDown noQU-SC : 1.689   0.039  -0.002   1.725   1.255     +0.059  -0.008  +0.038 ???
```

Some layout links:
- NotGate's ISRT: https://notgate.github.io/layout/
- NotGate's SIND: https://notgate.github.io/layout/experimental#sind
- Shai's Cmk mods: https://forum.colemak.com/topic/2644-shais-colemak-mod/
- HandsDown layout: https://sites.google.com/alanreiser.com/handsdown
<br>

In this analysis, simply swapping V and K and nothing else outperforms everything except ISRT!
- In effect though, it creates an awkward non-SFB CK bigram which the analyzer doesn't pick up on.
- VE/EV are also 3× more common than KE/EK and not too comfortable without alt-fingering.
<br>

**NotGate's ISRT/IndyRad layout** (QU -> SC for analysis; use w/ Sym mod)
```
    | Y C L M K  Z F U , ; |
    | I S R t g  P n e A o |
    | Q V W d J  B h / . x |

ISRT (homepage)   : 1.614   0.021   0.027   1.662   0.800     -0.016  -0.026  -0.025 !!! (6 swaps, 1 7-loop)
That analysis was done on an earlier version of the Colemakmods analyzer. The one in the table above is up-to-date.
```

Testing a column-swap: Cmk home row, ISRT upper/lower mappings ("**IndyPendant**")
```
    | , L C M K  Z F u y ; |
    | a r s t g  P n e i o | (PM + Q, + WX.ZJVCFL)
    | . W V d J  B h / Q X |

"IndyPendant" loses on base/near-bigram effort in this analysis. Hard to assess its real qualities.
```

**NotGate's experimental SIND layout** (standard Sym mod not available)
```
    | y , h w f  q k o u x |
    | s i n d c  v t a e r |
    | j . l p b  g m ; / z |

This layout is a screwball: It may be good, but according to this analysis base+nfb efforts destroy the SFB benefit.
The ER/RE pinky bigrams contribute to the poor NFB score. The strongest fingers have the highest base efforts.
```

**Shai's 2nd mod**
```
    | q w f M V  j l u y ; |
    | a r s t g  P n e i o | (PM + VBK)
    | z x c d K  B h , . / |
```


[CmmAna]: https://colemakmods.github.io/mod-dh/analyze.html (Colemakmods Analyzer)
