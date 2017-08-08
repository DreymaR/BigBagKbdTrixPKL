Keyboard Layout definitions for
Portable Keyboard Layout 
http://pkl.sourceforge.net

Colemak: Website - colemak.com . Public Domain. 2006-01-01 Shai Coleman
Tarmak topic: http://forum.colemak.com/viewtopic.php?pid=8786#p8786
2014-04-09 Øystein Bech Gadmar. Public Domain.


NOTES FOR 'PKL VIRTUALKEY TARMAK' LAYOUTS BY DREYMAR

• Implementation as PKL 'VirtualKey' layouts (non-Wide)
• Keeps the OS mappings for each key (AltGr etc), just moving them around.
• These mappings allow the use of Extend mode if desirable (see the pkl.ini file).
• See the PKL documentation on how to use these files if necessary.
• All the vk_Tarmak layout folders go in the 'layouts' folder.
• Then you can edit the 'layout = ' line in pkl.ini to the layout folder name.
	* Just comment any other active lines with a semicolon, and uncomment the Tarmak line
	* ";layout = vk_Tarmak1-E:Tarmak1(E),vk_Tarmak0-QWERTY:VirtualKey-QWERTY"
	* Then edit that line to whichever Tarmak you're using at the moment
	* The default choices are 'Tarmak1-E' through 'Tarmak4-ETRO', and 'Tarmak5-Colemak'
• The OEM_ keys that are different on ANSI(US) and ISO(Euro) boards may be commented out in layout.ini
	* These are only necessary if you want to use them for Extend keys with Tarmak
	* Commented out, these keys just "pass through" and are treated as normal

• There are alternative ways of sorting the steps; see the forum topics.
• ETOIR is the old default, ETROI the new one.
• Tarmak3(ETR) moves RSD first. ETO had JYO instead to prepare for LUI.
• Tarmak4(ETRO) finalizes the big loop early, leaving only the LUI loop.
• The now default ETROI maps RS early, misplaces only the J and does one loop at a time.
• (If you want a more effective first step you might do a T>F>E>K loop instead of J>E>K>N. Included as alt.)
• Choose between going for vanilla Colemak, or the Curl(DH)Angle ergo mod (deprioritize middle columns).


THE LAYOUTS (see the Tarmak forum topic for better presentations):

*** Tarmak(ETROI): ***
1) The E>K>N>(J) "most essential" loop, fixing the important E (and N)
 q  w {J} r  t  y  u  i  o  p 
   a  s  d  f  g  h {N}{E} l  ;     The "Tarmak1(E)" transitional layout (E>K>N>J)
     z  x  c  v  b {K} m 

2) The (J)>G>T>F loop, bringing the important T into place
 q  w {F} r {G} y  u  i  o  p 
   a  s  d {T}{J} h  N  E  l  ;     The "Tarmak2(ET)" transitional layout (G>T>F>E>K>N>J)
     z  x  c  v  b  K  m 

3) The (J)>R>S>D loop, getting RSD into place – all of which are relatively frequent!
 q  w  F {J} G  y  u  i  o  p 
   a {R}{S} T {D} h  N  E  l  ;     The "Tarmak3(ETR)" transitional layout (R>S>D>G>T>F>E>K>N>J)
     z  x  c  v  b  K  m 

4) The J>Y>O>;>P loop, getting O in place and finalizing the big loop
 q  w  F {P} G {J} u  i {Y}{;}
   a  R  S  T  D  h  N  E  l {O}    The "Tarmak4(ETRO)" transitional layout (Y>O>;>P>R>S>D>G>T>F>E>K>N>J)
     z  x  c  v  b  K  m 

5) The L>U>I self-contained loop - step 5 is simply the full Colemak!
 q  w  F  P  G  J {L}{U} Y  ; 
   a  R  S  T  D  h  N  E {I} O     The Colemak layout (Y>O>;>P>R>S>D>G>T>F>E>K>N>J & L>U>I)
     z  x  c  v  b  K  m Q W J 


*** Tarmak(ETROI)-Curl(DbgHk)Angle: ***
1) The E>K>H>N>(J) "most essential" loop, fixing the important E (and N) – with the Curl(Hk) mod
 q  w {J} r  t  y  u  i  o  p 
   a  s  d  f  g {K}{N}{E} l  ;     The "Tarmak1(E)-Curl(Hk)" transitional layout (E>K>H>N>J)
 _  z  x  c  v  b {H} m 

2) The (J)>B>T>F loop, bringing the important T into place – with the Angle (V>C>X>Z>_) and Curl(Dbg) mods
 q  w {F} r {B} y  u  i  o  p 
  a  s  d {T} g  K  N  E  l  ;     The "Tarmak2(ET)-Curl(DbgHk)" transitional layout (V-_>B>T>F>E>K>H>N>J)
{z}{x}{c}{v}{J}{_} H  m 

3) The (J)>R>S>D loop, getting RSD into place – all of which are relatively frequent!
 q  w  F {J} B  y  u  i  o  p 
   a {R}{S} T  g  K  N  E  l  ;     The "Tarmak3(ETR)-Curl(DbgHk)" transitional layout (R>S>D>V-_>B>T>F>E>K>H>N>J)
 z  x  c  v {D} _  H  m 

4) The J>Y>O>;>P loop, getting O in place and finalizing the big loop
 q  w  F {P} B {J} u  i {Y}{;}
  a  R  S  T  g  K  N  E  l {O}    The "Tarmak4(ETRO)-Curl(DbgHk)" transitional layout (Y>O>;>P>R>S>D>V-_>B>T>F>E>K>H>N>J)
 z  x  c  v  D  _  H  m 

5) The L>U>I self-contained loop - step 5 is simply the full Colemak!
 q  w  F  P  B  J {L}{U} Y  ; 
  a  R  S  T  g  K  N  E {I} O     The Colemak-Curl(DbgHk) layout (Y>O>;>P>R>S>D>V-_>B>T>F>E>K>H>N>J & L>U>I)
 z  x  c  v  D  _  H  m 



2015, Øystein Bech "DreymaR" Gadmar