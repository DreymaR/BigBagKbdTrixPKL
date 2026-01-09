<h1 align=center line-height=1.6>Canary</h1><br><br>

<div align=center ><img src="./Canary_ANS-A_EPKL.png" 
                        alt="The Canary layout w/ the Angle mod on an ANSI keyboard"></div><br>

## Canary Appendix
This page is for stuff that I consider too chonky for the main layout page.
<br><br>

## Canarda
Cycling `j z q x` from Canary-Ortho leads to very minor changes in efficiency – maybe even slightly on the positive side overall?

#### The Canarda layout variant:
```
+----------------------------+
| w l y p b   j f o u '  [ ] |
| c r s t g   m n e i a  ; \ |
| z x v d k   q h / , .      |
+----------------------------+
```
<br>

Here's a simple [cmini][Acmini] analysis of my Canarda variant vs standard Canary-Ortho:
```
canary-ortho (Eve)
  w l y p b  z f o u '
  c r s t g  m n e i a
  q j v d k  x h / , .

canarda (Dreymar)
  w l y p b  j f o u '
  c r s t g  m n e i a
  z x v d k  q h / , .

canarda(new) - canary-ortho(old)
  w l y p b  ~ f o u '
  c r s t g  m n e i a      swap `jzqx`
  ~ ~ v d k  ~ h / , .

SHAI:
0   Alt:  0.01%
0   Rol:  0.02%   (In/Out: -0.09% |  0.11%)
+   One:  0.05%   (In/Out: -0.00% |  0.05%)
+   Rtl:  0.07%   (In/Out: -0.09% |  0.16%)
+   Red: -0.04%   (Bad:     0.00%)
0   SFB:  0.01%
+   SFS: -0.06%   (Red/Alt: -0.02% | -0.04%)
0   LH/RH: 0.04% | -0.04%
```
<br>

- I consider the smaller differences (marked 0) certainly statistically insignificant. The others, I don't know.
- Given this, Canarda scores practically the same as Canary-Ortho on alternation, SFBs and hand balance.
- It may actually have a little more rolls and fewer skipgrams, but that may not be significant.
- Also, its rolls are more outward which is considered worse than inrolls by many.
- Very similar results were found using the `MT-QUOTES` corpus instead of `SHAI`.

- A `k q` swap for even more familiarity looks tempting, but it'd take SFB up from 0.9% to 1.0% which I think is overmuch.
<br>

<h1 align=center>⌨&nbsp;&nbsp;&nbsp;⌨&nbsp;&nbsp;&nbsp;⌨&nbsp;&nbsp;&nbsp;⌨&nbsp;&nbsp;&nbsp;⌨</h1>


[Acmini]: https://github.com/Apsu/cmini                                         (Apsu's cmini layout analyzer)
