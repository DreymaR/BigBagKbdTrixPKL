DreymaR's Big Bag Of Keyboard Tricks - EPKL
===========================================

![EPKL help image, for the Extend1 layer](./ImgExtend/ISO_Ext1.png)  
  
  
Files info
----------
This is where EPKL keeps non-layout files it needs. Unless you're an advanced user, you may not need to change anything in these files.
  
On the other hand, looking inside some of them should be useful if you want to understand more about how EPKL works!
  
  
Examples From The EPKL Files
----------------------------
Some of the mappings for my tap-Extend Kaomoji layer in the `_eD_DeadKeys.ini` file:
```
<q>     = → (✿◠‿◠)                 		; q -†Kawaii qute "Flower girl" (eyes may show as boxes)
<Q>+    = → (❁°‿°)                  		; Q - --"-- - alt. (❁´◡`)
<w>     = → ( のvの) c[_]            		; w - Wise owl w/ coffee mug
<W>+    = → ლ( ʘ▽ʘ)ლ～ORLY         		; W - ORLY owl
<f>     = → ( ╯°□°）╯︵ ┻━┻            		; f - Flip table
<F>+    = → /( .□.)＼ ︵╰(°益°)╯︵ /(.□. /) 	; F - Flip people
<p>     = → ┬─┬ ノ( °‿°ノ)           		; p - Put back table
<P>+    = → ✌(  ￣▽￣ )             		; P - Peace sign
<g>     = → ♪～╰(＊°▽°＊)╯～♪        		; g - Giddy Celebration
<G>+    = → ☆＊✧:.｡. o(⁎≧▽≦)o .｡.:✧＊☆ 	; G - --"--
<j>     = → ∩(◕‿◕｡)∩～♪             		; j -†Joyful (eyes may show as boxes)
<J>+    = → ∩(●'‿'●)∩               		; J - --"--
<l>     = → ( ͡° ͜ʖ ͡°)             		; l - Lennyface (uses non-spacing glyphs)
<L>+    = → ( ͡~  ͜ʖ ͡°)            		; L - --"--
<u>     = → ʕ ͡° ʖ̯ ͡°ʔ              		; u - Unhappy Lenny (--"--)
<U>+    = → ( ͠° ͟ʖ ͠°)             		; U - --"--
<y>     = → ლ(ಠ益ಠ ლ)              		; y - Why?! Confusion, worry
<Y>+    = → ⊂(;⊙д⊙)つ               		; Y - --"-- - alt. (๑ΘдΘ)
<;>     = → (ʘ言ʘ╬)                 		; ; - Shock
<:>     = → (ʘ_ʘ;)                  		; : - --"--
```
  
Extend1 mappings for the upper and home rows, from the `_eD_Extend.ini` file:
```
QW_Q  = Esc
QW_W  = WheelUp 2
Co_F  = Browser_Back
Co_P  = Browser_Forward
Co_G  = Click Rel 0,-17,0
Co_J  = PgUp
Co_L  = Home
Co_U  = Up
Co_Y  = End
Co_SC = Del
Co_LB = Esc 	;WheelLeft
Co_RB = Ins

Co_A  = Alt
Co_R  = WheelDown 2
Co_S  = Shift
Co_T  = Ctrl
Co_D  = Click Rel 0,17,0
Co_H  = PgDn
Co_N  = Left
Co_E  = Down
Co_I  = Right
Co_O  = BackSpace
Co_QU = AppsKey
Co_BS = Browser_Favorites
```
  
The crazy "PowerString 666" from the `_eD_PwrStrings.ini` file:
```
;;  The purpose of this power(!)string is to improve Colemak's daemon summoning capabilities. \m/
;;  See https://forum.colemak.com/topic/2460-improving-colemaks-demon-summoning-abilities/
666-01  = "\n             ______             \n"
666-02  =   " Col    .d$$$******$$$$c.  mak  \n"
666-03  =   " \e/ .d$P"            "$$c \-/  \n"
666-04  =   "    $$$$$.     C     .$$$*$.    \n"
666-05  =   "  .$$ 4$L*$$.     .$$Pd$  '$b   \n"
666-06  =   "  $F   *$. "$$e.e$$" 4$F   ^$b  \n"
666-07  =   " d$     $$   z$$$e   $$     '$. \n"
666-08  =   " $P  m  `$L$$P` `"$$d$"   k  $$ \n"
666-09  =   " $$     e$$F   C   4$$b.     $$ \n"
666-10  =   " $b  .$$" $$   o  .$$ "4$b.  $$ \n"
666-11  =   " $$e$P"    $b     d$`    "$$c$F \n"
666-12  =   " '$P$$$$$$$$$$$$$$$$$$$$$$$$$$  \n"
666-13  =   "  "$c.      4$.  $$       .$$   \n"
666-14  =   "   ^$$.  DH  $$ d$"  AW  d$P    \n"
666-15  =   "     "$$c.   `$b$F    .d$P"     \n"
666-16  =   " CAW   `4$$$c.$$$..e$$P"   [eD] \n"
666-17  =   "           `^^^^^^^`            \n"
```
  
KLM remapping codes used in the `_eD_Remap` file:
```
;;  This is a table of KeyLayoutMap (KLM) codes from the _eD_Remap.ini file. You can use QW### or Co### for EPKL Scan Code (SC) and Virtual Key (VK) names.
;;  KLM codes are intuitive and make no difference between ANSI & ISO board types. Examples: QW_E, Co_F, QW_CM, QWSPC. For VK, vc=QW codes make the most sense.
;;  XX======+======+======+======+======+======+======+======+======+======+======+======+======XX======+======XX======+======+======XX======+======+======+======XX
;;  ||Esc   |F1    |F2    |F3    |F4    |F5    |F6    |F7    |F8    |F9    |F10   |F11   |F12   ||Back  |Menu  ||PrtSc |ScrLk |Pause ||NumLk |KP /  |KP *  |KP -  ||
;QW || ESC  | _F1  | _F2  | _F3  | _F4  | _F5  | _F6  | _F7  | _F8  | _F9  | F10  | F11  | F12  || BSP  | APP  || PSC  | SLK  | PAU  || NLK  | PDV  | PMU  | PMN  ||
;;  XX======+======+======+======+======+======+======+======+======+======+======+======+======XX======+======XX======+======+======XX------+------+------+------XX
;;  ||`     |1     |2     |3     |4     |5     |6     |7     |8     |9     |0     |-     |=     ||LShft |RShft ||Ins   |Home  |PgUp  ||KP 7  |KP 8  |KP 9  |KP +  ||
;QW || _GR  | _1   | _2   | _3   | _4   | _5   | _6   | _7   | _8   | _9   | _0   | _MN  | _PL  || LSH  | RSH  || INS  | HOM  | PGU  || P_7  | P_8  | P_9  | PPL  ||
;;  XX------+------+------+------+------+------+------+------+------+------+------+------+------XX------+------XX------+------+------XX------+------+------+------XX
;;  ||Tab   |Q     |W     |E     |R     |T     |Y     |U     |I     |O     |P     |[     |]     ||LCtrl |RCtrl ||Del   |End   |PgDn  ||KP 4  |KP 5  |KP 6  |KPEnt ||
;QW || TAB  | _Q   | _W   | _E   | _R   | _T   | _Y   | _U   | _I   | _O   | _P   | _LB  | _RB  || LCT  | RCT  || DEL  | END  | PGD  || P_4  | P_5  | P_6  | PEN  ||
;Co || TAB  | _Q   | _W   | _F   | _P   | _G   | _J   | _L   | _U   | _Y   | _SC  | _LB  | _RB  || LCT  | RCT  || DEL  | END  | PGD  || P_4  | P_5  | P_6  | PEN  ||
;;  XX------+------+------+------+------+------+------+------+------+------+------+------+------XX------+------XX======+======+======XX------+------+------+------XX
;;  ||Caps  |A     |S     |D     |F     |G     |H     |J     |K     |L     |;     |'     |\     ||LWin  |RWin  ||VolDn |Up    |VolUp ||KP 1  |KP 2  |KP 3  |Mute  ||
;QW || CLK  | _A   | _S   | _D   | _F   | _G   | _H   | _J   | _K   | _L   | _SC  | _QU  | _BS  || LWI  | RWI  || VLD  | _UP  | VLU  || P_1  | P_2  | P_3  | MUT  ||
;Co || CLK  | _A   | _R   | _S   | _T   | _D   | _H   | _N   | _E   | _I   | _O   | _QU  | _BS  || LWI  | RWI  || VLD  | _UP  | VLU  || P_1  | P_2  | P_3  | MUT  ||
;;  XX------+------+------+------+------+------+------+------+------+------+------+------+------XX------+------XX------+------+------XX------+------+------+------XX
;;  ||LS/GT |Z     |X     |C     |V     |B     |N     |M     |,     |.     |/     |Enter |Space ||LAlt  |RAlt  ||Left  |Down  |Right ||KP 0  |KP .  |Power |Sleep ||
;QW || _LG  | _Z   | _X   | _C   | _V   | _B   | _N   | _M   | _CM  | _PD  | _SL  | ENT  | SPC  || LAL  | RAL  || _LE  | _DN  | _RI  || P_0  | PDC  | PWR  | SLP  ||
;Co || _LG  | _Z   | _X   | _C   | _V   | _B   | _K   | _M   | _CM  | _PD  | _SL  | ENT  | SPC  || LAL  | RAL  || _LE  | _DN  | _RI  || P_0  | PDC  | PWR  | SLP  ||
;;  XX======+======+======+======+======+======+======+======+======+======+======+======+======XX======+======XX======+======+======XX======+======+======+======XX
```
  