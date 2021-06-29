DreymaR's Big Bag Of Keyboard Tricks - EPKL
===========================================

![EPKL help image for Colemak-eD-QI on an ANSI board](./Colemak-QI_ANS-CAS_EPKL.png)

_The "bleeding-edge" Nyfee mod Colemak-QI_
<br><br>


Colemak Discord user Nyfee's "bleeding-edge" Colemak-Q mods
-----------------------------------------------------------
- Colemak design philosophy keeps ZXCV in place, and tries to avoid keys swapping hands.
- These variants don't, with the purpose of squeezing out some more analyzer points and maybe layout quality.
- The newest mods have scored quite well in analysis, possibly(!) beating Colemak-DH by a bit.
- Cmk-QI releases the Cmk constraint of keys changing hands. ZXCV didn't need moving.
- It was inspired by and takes some ideas from the [IndyRad/ISRT layout by NotGate][NotGte].
- Cmk-QI;x is the "extra mile" variant. More changes, lower SFB% but uncertain gains.
    - QI;x adds SL-CM & Q-SC swaps to get SFB% down, and the purely subjective C-W swap.
    - It still ends up at about the same Colemakmods analysis score as Cmk-DH, no more.
- Cmk-QI supports the standard Sym and Wide mods. Cmk-QI;x has its own Sym and no Wide mod.
- ColemaQ is a slightly older variant that consists of 3–4 simple key swaps. See below.
- There were some predecessor mods named Hirou and XCept; these likely aren't in use anymore.


#### Colemak-QI by Nyfee, 2021-03:
```
---------------------------
 1 2 3 4 5  6 7 8 9 0  = [ 
 q L W M K  j F u y '  - ] 
 a r s t g  P n e i o  ; \ 
 z x c d v  B h , . /      
---------------------------
Remaps from Cmk-DH-Sym:
        / W > F > L / P ⇔ M / B ⇔ K /
```

#### Colemak-QI;x by Nyfee, 2021-03:
```
---------------------------
 1 2 3 4 5  6 7 8 9 0  = [ 
 ; L C M K  j F u y Q  - ] 
 a r s t g  P n e i o  ' \ 
 z x W d v  B h / . ,      
---------------------------
Remaps from Cmk-DH-Sym:
/ W ⇔ C / W > F > L / P ⇔ M / B ⇔ K / CM ⇔ SL / Q > QU > SC /
```

#### ColemaQ(-F) by Nyfee, 2021-01/03:
```
---------------------------
 1 2 3 4 5  6 7 8 9 0  = [ 
 ; w f p b  j l u y Q  - ] 
 a r s t g  m n e i o  ' \ 
 z x c d K  V h / . ,      
---------------------------
Remaps from Cmk-DH-Sym:
                    / V ⇔ K / CM ⇔ SL / Q > QU > SC / / F ⇔ G /
```
<br><br>


![EPKL help image for Colemak-eD-QI;x on an ANSI board](./Colemak-QIx_ANS-CAS_EPKL.png)

_The "bleeding-edge" Nyfee mod Colemak-QI;x_
<br><br>


Colemakmods analysis of several "bleeding-edge" Colemak mods and more
---------------------------------------------------------------------

- Analysis from https://colemakmods.github.io/mod-dh/analyze.html adding changes separately.
- These steps are from the Colemak-QI mod by Nyfee, and proposed additions thereto.
- ColemakMods analysis by ~Renato, 2021-04-03, on a 3×10 matrix.
- Changes in base, SFB and total (which also includes "near-finger" bigram effort) were reported as Δ rel. to Colemak-DH.
<br>

```
Cmk-DH+swaps/loops: bas.ef. sfb-ef. nfb-ef. tot.ef. SFB%      Δbas.e  Δsfb-e  Δtot.e
=========================================================    ========================
Cmk-DH            : 1.630   0.047   0.010   1.687   1.521      0       0       0
             +Q;  : 1.630   0.047   0.010   1.687   1.515      0.000   0.000   0.000  ???
      +WFL   +Q;  : 1.633   0.046   0.016   1.695   1.489     +0.003  -0.001  +0.008  ...
   +BK+WFL   +Q;  : 1.631   0.042   0.016   1.689   1.361     +0.001  -0.005  +0.002  ...
+PM+BK+WFL   +Q;  : 1.624   0.039   0.017   1.681   1.268     -0.006  -0.008  -0.006  !!!
+PM+BK+WFL+/,+Q;  : 1.639   0.029   0.020   1.689   0.938     +0.009  -0.018  +0.002  ?!?
```

ColemakMods analysis by DreymaR, 2021-04-06, as above:
```
+PM               : 1.623   0.053   0.011   1.687   1.729     -0.007  +0.008   0.000  ...
+PM+BK            : 1.621   0.054   0.011   1.686   1.671     -0.009  +0.007  -0.001  ...
+PM+BK+WFL        : 1.624   0.040   0.017   1.681   1.275     -0.006  -0.007  -0.006  !!!
+PM+BK+WFL+/,     : 1.639   0.030   0.019   1.688   0.943     +0.009  -0.017  +0.001  ?!?
+PM+BK+WFL+/,+Q;  : 1.639   0.029   0.020   1.689   0.938     +0.009  -0.018  +0.002  ???
+PM+BK+WFL+/,+WC  : 1.640   0.030   0.019   1.688   0.938     +0.010  -0.017  +0.001  ???
   +BK            : 1.628   0.052   0.009   1.690   1.597     -0.002  +0.005  +0.003
   +BK+WFL        : 1.631   0.042   1.689   0.016   1.367     +0.001  -0.005  +0.002
+PM   +WFL        : 1.626   0.047   0.017   1.690   1.536     -0.004   0.000  +0.003
      +WFL        : 1.633   0.046   0.016   1.695   1.495     +0.003  -0.001  +0.008
```

ColemakMods 3×10 matrix analysis comparing different layouts/mods to Colemak-DH, 2021-04:
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
```
  

- The Cmk-QI PM/BK/WFL combo is most important in reducing both effort and SFBs at the same time.
- The proposed Q-SC and W-C swaps show no analysis benefits here; their benefit is perceived.
- The SL-CM swap reduces SFB% quite a lot, but base+near-bigram efforts increase just as much.
- The analysis of near-bigram effort is probably well worth further study and debate!
- In this analysis, simply swapping V and K and nothing else outperforms everything except ISRT!
    - In effect though, it creates an awkward non-SFB CK bigram which the analyzer doesn't pick up on.
    - VE/EV are also 3× more common than KE/EK and not too comfortable without alt-fingering.
- For more analysis and comparison, see the [Test folder README][TestRM].
<br><br>


![EPKL help image for ColemaQ on an ANSI board](./ColemaQ_ANS-CAS_EPKL.png)

_The older "bleeding-edge" ColemaQ mod. Adding an optional G-F swap, it becomes ColemaQ-F._
<br><br>


My personal take on the ColemaQ mod(s)
--------------------------------------
**Note:** This was originally posted on the Colemak Discord, where unfortunately an unfinished version of it created a heated conflict with some of the mods' defenders. My intention with it was an is just to discuss the claims that these mod elements are "objectively" better than Colemak-DH, claims that were made in the server channels on several occasions. I have nothing against these mods _per se_ but at the end of the day I do not see any real benefits with them either in sum. Caveat emptor.

I've been analyzing Nyfee's and other mods with the [Colemakmods analyzer][CM-Ana] as it's easy to use and yet provides some useful insights, trying to find out what's behind the enthusiasm. This analyzer has a base effort score based on positions and travel, a same-finger bigram (SFB) effort and a near-finger bigram effort that punishes rolls between weak fingers. It's a fairly simple model and its end totals may well be debated, but as mentioned it gives some good insights and pointers.

The ColemaQ mod consists of 3–4 simple key swaps from Colemak-DH and these aren't directly connected so it's easy to discuss and analyze them separately to gain some idea of their individual effects.

I had a big A-ha! moment when I tried the V-K swap in ColemaQ (the only part of it that the analyzer actually liked, thus it made sense to test it out) and it created at least as many problems as it solved, given that I view the KN SFB as a zero-problem because I find it extremely easy to alt-finger. I also alt-finger LK easily enough, so I didn't find the V-K swap useful in sum since it creates other issues in turn that the analyzer didn't pick up on. I noticed the VE and CK bigrams, which aren't same-finger bigrams nor weak-finger near-bigrams but involve stretches that felt unpleasant to me from middle to index fingers. Their Colemak-DH counterparts, VK and CE, are less frequent.

The Q; swap seems entirely subjective to me at this point. I know its fans find it good somehow. Neither the analyzer nor I see any point in it, beyond a very minute reduction in SFB%. It's said that the QU roll is nice, but the QU bigram isn't at all bad without the swap and it isn't common either.

The Comma-Slash swap reduces SFB% like nobody's business, but it too comes with problems of its own: It overloads the right-hand pinky which puts the analyzer off it. And it makes further modding like Wide and Sym much more tricky, as trying to find a good home for comma on a Wide config isn't easy at all. Whether the analyzer is right in claiming that the increase in other effort nullifies the benefit of less SFBs, is open for discussion. I think it may be onto something, but it will depend on how strong and agile your pinkies are. Experienced typists and players of instruments like the piano may have very well-trained pinkies indeed, while people coming straight from typing on the QWERTY layout typically have underused and weak right-hand pinkies and have been known to complain about Colemak's higher pinky usage even without any mods added to further increase pinky load.

So, that's my personal impression. Other people's experience will vary – for instance, they may have a system that reduces their pinky symbol usage with layers so the pinky won't get too taxed, and they may not mind losing mod modularity.

But: We've had people advertising this and similar mods as "objectively better" and I don't think that's warranted at all. So I wanted to address such claims with a caveat based on my observations. I hope beginners don't get mired down in a bunch of advanced, unclear choices that are too hard to make for them. That may put some newcomers off Colemak entirely, which would be very sad.
<br><br>

|![EPKL help image for Colemak-eD-QI CurlAngleWideSym on an ISO board, unshifted state](./Cmk-eD-QI_ISO_CurlAWideSym/state0.png)|
|   :---:   |
|_Colemak-eD-QI_ISO_CurlAWideSym, unshifted state. Note the <kbd>Compose/Completion</kbd> key in the middle._|


[CM-Ana]: http://colemakmods.github.io/mod-dh/analyze.html (Colemakmods Layout Analysis Tool)
[NotGte]: https://notgate.github.io/layout/ (NotGate's layout page, home of the ISRT layout)
[TestRM]: ../README.md (EPKL _Test folder README)
