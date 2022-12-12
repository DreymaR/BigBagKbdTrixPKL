DreymaR's Big Bag Of Keyboard Tricks - EPKL
===========================================
<br>

![EPKL help image for Colemak-eD-Ara Angle-ISO](./Cmk-Ara_ISO-Angle_s0_EPKL.png)

<br><br>

Colemak[eD] locale layouts
--------------------------
Most of the Cmk-eD locale variants use ISO keyboards with an AngleWide configuration to allow index finger access to the bracket and ISO_102 keys where I mostly put the needed locale letters.

This may be supplemented with Curl(DH) and Sym mods to provide Colemak-CAW(S) with locale letters. You could remove the Wide mod if desired, but then the right hand pinky may get overworked.

Some locales traditionally use ANSI keyboards though, and some prefer to use the AltGr key instead of dead keys. So there may be other variants available.
<br><br>

Colemak-Ara Arabic phonetic layout variant
------------------------------------------
- This is a semi-phonetic Arabic layout with some novel ideas, constructed mainly by Komi and DreymaR.
- It is intended for Colemak typists who want to type Arabic too. It is not really optimized for any Arabic language as such.
- It should provide a simple way of typing everyday Arabic while also allowing for diacritics.
- For more info, see the [Ara BaseLayout file][AraLay].
<br>

Briefly:
- Arabic letters on base/Shift states, Latin letters on AltGr states. Normal Latin/Arabic punctuation kept in both cases.
- There are a few Arabic composes for Madda and Hamza, as for Linux XKB.
<br>

|![EPKL help image for Colemak-eD-Ara CAWS on an ISO board, unshifted state](./Cmk-eD-Ara_ISO_CurlAWideSym/state0.png)|
|   :---:   |
|_Colemak-eD-Ara_ISO_CAWS, unshifted state_|

|![EPKL help image for Colemak-eD-Ara CAWS on an ISO board, shifted state](./Cmk-eD-Ara_ISO_CurlAWideSym/state1.png)|
|   :---:   |
|_Colemak-eD-Ara_ISO_CAWS, shifted state_|

|![EPKL help image for Colemak-eD-Ara CAWS on an ISO board, AltGr state](./Cmk-eD-Ara_ISO_CurlAWideSym/state6.png)|
|   :---:   |
|_Colemak-eD-Ara_ISO_CAWS, AltGr state_|

<br>

- Special dead keys on <kbd>???</kbd> ("???") and <kbd>O</kbd> ("???").
    - The two DKs provide Ḥarakāt vowel signs together with the <kbd>A</kbd><kbd>E</kbd><kbd>I</kbd><kbd>O</kbd><kbd>U</kbd> keys.
    - Both have a set of common non-vowel releases, covering special signs. Again, see the [BaseLayout file][AraLay].
<br>

|![EPKL help image for the "??? etc" DK on Colemak-eD-Ara CAWS-ISO, unshifted state](./Cmk-eD-Ara_ISO_CurlAWideSym/DeadkeyImg/Ara-DK-O_s0.png)|
|   :---:   |
|_The "???" dead key on Colemak-eD-Ara_ISO_CAWS, unshifted state_|

<br><br>

Design notes
------------
Here are Komi's notes on the layout, originally posted on the Colemak Discord:
```
It's far from perfectly phonetic. I had to sacrifice some phonetics for the layout to be actually type-able without putting all letters on shift.

COLEMAK, (SEMI-)PHONETIC ARABIC VERSION:
Q - ق, q
W - و, w (Shift = ؤ which is the letter with a hamza on top.)
F - ف, f
P - ط, ṭ (Shift = ظ which is phonetically assosiated with the ẓ sound, these letters are commonly assosiated with eachother as they are both emphatic) NOTE: ARABIC HAS NO P SOUND.
B - ب, b (Shift = پ, which is phonetically assosiated with the p sound) NOTE: IT IS AN URDU LETTER THAT IS USED SOMETIMES BY ARABS
J - غ, gh 
L - ل, l
U - ض, ḍ NOTE : THERE IS NO LETTER PHONETICALLY ASSOSIATED WITH "U" IN THE ARABIC LANGUAGE
Y - ي, y (Shift = ئ, which is the letter with a hamza on top.)
A - ا, ʾ (Shift = أ, which is the letter with a hamza on top.)
R - ر, r
S - س, s
T - ت, t (Shift = ة, which is also called "ta marbota" or "bound ta" with "ta" being the name of the letter we assigned to T)
G - ج, j
M - م, m
N - ن, n
E - ع, ʿ NOTE: ARABIC LANGUAGE HAS NO LETTER PHONETICALLY ASSOSIATED WITH E, AND THIS LETTER IS ASSIGNED TO E ON PHONETIC LAYOUTS
I - إ, well it's ʾ but any glottal stop in arabic is represented with that in the abjadi sequence (Shift = ء, which is THE hamza)
O - ص, ṣ
X - خ, kh
C - ش, sh
D - د, d
Z - ز, z
V - ذ, dh NOTE : THERE IS NO LETTER PHONETICALLY ASSOSIATED WITH "V" IN THE ARABIC LANGUAGE
K - ك, k
H - ح, ḥ (Shift : ه which is phonetically assosiated with h)


Modifications :
1- Why did I swap the gh and j sound?

The letter Ghayn in Arabic is wayy less used, so it felt better to put the more used letter (BY A LONGSHOT) on the homerow, this is why j has غ while g has ج here.

2- Why are P, O, U, V not mapped to the correct phonetical spelling in Arabic?

None of these letters exist in the arabic language, and while we could've put helpful symbols on them instead of putting letters that are not simmilar to them on them, if I do this then I would have to use a lot of shifted letters in the layout and it would be pretty painful to type. so I tried to do the best decision based on the most frequent letters.
``` 


More Arabic script resources
----------------------------
Letter frequencies according to [Simia][AraSim]:
ا ل ي م و ن ر ت ب ة ع د س ف ه ك ق أ ح ج ش ط ص ، ى خ إ ز ث 1 ذ ض 0 غ ئ 2 9 ء ...

[AraLay]: ./BaseLayout_Cmk-eD-Ara.ini (the Colemak-eD-Ara EPKL BaseLayout file)
[AraKbd]: https://en.wikipedia.org/wiki/Arabic_keyboard (Wikipedia's "Arabic keyboard" article)
[AraSim]: http://simia.net/letters/ (Arabic letter frequencies)
