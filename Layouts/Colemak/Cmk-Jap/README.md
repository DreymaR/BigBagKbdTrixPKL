DreymaR's Big Bag Of Keyboard Tricks - EPKL
===========================================
<br>

![EPKL help image for Colemak on an ANSI board](/Layouts/Colemak/Colemak-ANS_s0_EPKL.png)

_The unmodified Colemak layout on an ANSI keyboard_

<br><br>

Colemak-Jap Hiragana/Katakana/Kanji (Japanese) locale layout variants?
----------------------------------------------------------------------
Sorry, but there are none at present. ごめんなさい.  &nbsp;&nbsp; ᏊᵕꈊᵕᏊ
- EPKL is not quite equipped to handle the complexity of being a full IME for Kanji input.
- Without Kanji, it's not useful enough to be able to input kana (single letters).
- If you have an IME such as the standard Windows one, you can already type kana using latin letters.
- Fortunately, with EPKL you can use the (QWERTY-based) Windows Japanese IME accompanied by an EPKL Colemak layout.
- (I did have an idea of using consonant keys as dead keys to produce kana, but for the above reasons it hasn't been developed further.)
- The JIS keyboard type is technically supported by EPKL, in addition to ISO and ANSI. But the function of special keys is still up to the OS layout.
<br><br>

Using an IME with installed Colemak
-----------------------------------
The most familiar and useful way for many to type Japanese is probably the standard Windows IME.
- Unfortunately, that's not trivial since the standard Windows IMEs are linked to language – which means the QWERTY layout.
- There is a way of relinking which layout is the default for a language. It involves Registry editing, so it's rather high-tech.
- It's described in the Reddit post "[How to: Colemak for ... IMEs][IMEreg]". The Japanese language has the ID `00000411`.
- That way, you could use an installed Colemak such as the one in the [EPKL Other\MSKLC][PklKLC] folder or from the [Colemak site][CmkCom].
- Relevant Registry keys are in these locations:
```
Computer\HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Keyboard Layouts\00000411
Computer\HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\i8042prt\Parameters
```
- Also, see this [Colemak Forum post][JapCmk] on the topic.

[IMEreg]: https://www.reddit.com/r/Colemak/comments/9rq7vv/how_to_colemak_for_japanese_chinese_and_other/ (Reddit – How to: Colemak for ... IMEs)
[CmkCom]: https://www.colemak.com (The Colemak official site)
[PklKLC]: ../../../Other/MSKLC     (EPKL's Microsoft Keyboard Layout Creator folder)
[JapCmk]: https://forum.colemak.com/topic/2630-japanese-colemak-keyboard-windows/#p25027 (Colemak Forum post on Japanese Colemak IME by registry, 2023-08-20)
