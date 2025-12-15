;;  ================================================================================================================================================
;;  EPiKaL PKL - EPKL
;;  Portable Keyboard Layout (Máté Farkas, -2010)   [https://github.com/Portable-Keyboard-Layout]
;;  edition DreymaR    (Øystein Bech-Aase, 2015-)   [https://github.com/DreymaR/BigBagKbdTrixPKL]
;;  ================================================================================================================================================
;

/*
;;  ########################   TODO  »-->   ########################

WIPs: Recent and/or ongoing issues and projects
2FIX: Unresolved issues and bugs
NEXT: Improvements I'd really like to get around to soon
TODO: Improvements that are deemed worthy and useful, sometime
HOLD: Thoughts and suggestions that weren't that good after all, or currently infeasible

;;  ================================================================================================================================================
;;  eD WIPs/2FIX:

TODO: Find a neat something to put between the end of a layout readme and the final picture (layout or symbol). Just a line, maybe? Or a keyboard graphic of sorts?
	- `⌨ ⌨ ⌨ ⌨ ⌨ ⌨ ⌨` maybe? But centered.

WIPs: On the CoDeKey layers, I've found room for number row symbols, except for two: `* +`. However, I do have both backtick and ~.
	- Would the missing symbols be more natural and maybe useful? I'll also have to keep it intuitive, for low mental load.
	- Could do one on CDK,g? I don't think the bullet point is seeing much use, but on the other hand the OneShotShift needs speed.
		- Could that be on Ext-tap instead? Then, both backtick and tilde might be on the `g` key. No, timing is still too inferior.
	- Plus on Gralmak `p` is kind of cool. On Colemak, `*` would be more intuitive. But that's also nice on `,` (same finger as `8`).

WIPs: Repurpose the Ext-tap `h/n` mapping! A lonely `!` on that layer is just out of place. And put ``` on Ext-tap `;`.
		- Also the delete-word Ext-tap `i/o` mapping. Not used, nor useful. Bring the `#i` one down from `'`.
		- Move select line around to a more intuitive/consistent spot then? Cmk Ext-tap A (Ctrl+A) vs I.
		- What to put on `'` now, then?

TODO: Make a separate Github repo for Gralmak.
	- It'll look more serious than having it tucked away in corners of the EPKL repo.
	- Add .klc files, images and descriptions.
	- Get it linked to from MonkeyType, Cyanophage, AKL disco, ???
	- It's also time to add it as a separate layout in EPKL.
		- It would still point to the Graphite BaseLayout, but from its own folder.
		- Not necessary for Galliard, I think, as I don't use/recommend that one as strongly now.
	- Make a Gralmak-PCT (Period/Comma Thumbless – or just Punctuation) mod for optimal punctuation without a thumb key.
		- I suppose Gallium's or Graphite's punctuation is fine then? They both have awkward quirks while solving the period+comma issues.
		- Main issues according to Cyanophage are the `E.` SFB (0.14%) and the `O_,` s1-SFB (0.07%).
		- Gralmak-pct uses Graphite's period on the OA column. Both Gallium and Graphite have comma placed with I on the pinky.
		- The big question is whether it's useful though. Might instead recommend using either Gallium or Graphite punctuation.
			- Gallium punctuation has lower SFB% according to cmini. People will care about that. The period is the key to that.
			- At the same time, Gallium achieves that by loading the pinky with both comma and period. Maybe some dislike that?
		Graphite:
		           ' f o u j ;
		           y h a e i ,
		           k p . - /
		
		Gallium:
		           j f o u , 
		           y h a e i 
		           k p ' ; .
		
		Gralmak:
		b l d w q  j f o u ' -
		n r t s g  y h a e i ;
		z x m c v  k p , . /
		
		Gralmak-pct:
		b l d w q  j f o u ' -
		n r t s g  y h a e i ;
		z x m c v  k p . / ,
		Remap: . , /
		
		Gralmak-thumb:
		b l d w q  j f o u '
		n r t s g  y h a e i
		z x m c v  k p     /
		           ! , . ; -
		
	- Analyzeable layout at Cyanophage, with `, . /` unmodified:
		https://cyanophage.github.io/playground.html?layout=bldwqjfou%27-nrtsgyhaei%3Bzxmcvkp%2C.%2F%5C%3D&mode=ergo&lan=english&thumb=l
		bldwqjfou'-nrtsgyhaei;zxmcvkp,./
	- Analyzeable layout at Cyanophage (link then import string), with `\ =` for the `, .` keys to avoid bad analysis:
		https://cyanophage.github.io/playground.html?layout=bldwqjfou%27-nrtsgyhaei%2Czxmcvkp%5C%3D%2F%3B.&mode=ergo&lan=english&thumb=l
		bldwqjfou'-nrtsgyhaei,zxmcvkp\=/;.

TODO: Add the Canarda variant
		canary-ortho (Eve)
		  w l y p b  z f o u '
		  c r s t g  m n e i a
		  q j v d k  x h / , .
		
		canarda (Dreymar)
		  w l y p b  j f o u '
		  c r s t g  m n e i a
		  z x v d k  q h / , .
		It cycles j z q x, leading to very minor changes in efficiency – maybe even slightly on the positive side overall?
		
		canarda(new) - canary-ortho(old)
		  w l y p b  ~ f o u '
		  c r s t g  m n e i a
		  ~ ~ v d k  ~ h / , .
		
		SHAI:
		+   Alt:  0.01%
		+   Rol:  0.02%   (In/Out: -0.09% |  0.11%)
		+   One:  0.05%   (In/Out: -0.00% |  0.05%)
		+   Rtl:  0.07%   (In/Out: -0.09% |  0.16%)
		+   Red: -0.04%   (Bad:     0.00%)
		-   SFB:  0.01%
		+   SFS: -0.06%   (Red/Alt: -0.02% | -0.04%)
		0   LH/RH: 0.04% | -0.04%
		
		Note: A further k-q swap looks tempting, but it'd take SFB up from 0.9% to 1.0% which is overmuch.
	
	- Name: Canarda (Porta Canarda is a place in Ventimiglia, Italy)? Canardy? Candory?
	- Should also add Canary-Ortho Sym

2FIX: Unmapped DK entries shouldn't produce an unprintable char on layout images.

2FIX: The base1 entry ought to be used when double-tapping a DK. Instead, the entry for space takes precedence.
	- Something is very fishy about the DK code. It does detect a double tap, but somehow loops back and sends the space entry instead?
		- Is it related to pkl_CheckForDKs() somehow? Is it because a space is sent there, causing the release char to become a space?
	- Ext-tap twice outputs four spaces (the output for Spc). It might be better to make it cancel the DK.
	- The CoDeKey sends repeated space entries when held down. Is this desirable? Could we specify no output by default for a DK?

WIPs: Could the CoDeKey cancel itself when pressed again? Or something else?
	- Making the Space entry nothing (or clear OSM or whatever) is a temporary fix.

2FIX: U#### doesn't compose Unicode points anymore? How come?
	- Checked: I wasn't using a VK-number BaseLayout at the time. Also, the compose key `1234` composes fine.

WIPs: When I've got ortho images and Kyrillic variant updates in place, I could make a new, self-signed(?!?) release 1-4-3.

NEXT: Bg update according to Kharlamov: Lose duplicate ъ (one on y and one on =+)
	- I think the bulgarian =+ position should house Ѝ ѝ
	- It's a precomposed letter used for homophone distinctions and is present on newer bulgarian layouts
	- Also, there seems to be no ё in bulmak (for russian), even though there's still the russian ы э
	- (The ё could be on `AltGr+/`, since that only houses a duplicate slash and the non-cyrillic ¿)? No, breaks the Latin layer?
NEXT: Belarus/Ukrainia variants? Kharlamov in Mods-n-Layers (messID 961236439591432222 ff):
	- Belarusian can use russian with И и changed to І і, Щ щ changed to Ў ў, and Ъ ъ changed to Ґ ґ
		(not used in the official orthography, but used in the still-popular 1918 orthography)
	- Russian letters should also be accessible seeing how belarus is officially bilingual
	- The ’ [Cmk-eD AltGr+F] apostrophe too, it's a letter in belarusian
	- The national layout uses `'` so the current mapping may suffice
	- Maybe put ’ on the iso key instead of double acute?
	- For better phonetic mapping, Ў ў should be mapped to W w due to making the same sound
WIPs: Ukromak revision?
	- Kharlamov: ’₴ on `~, їЇ on =+, and ґҐ on AltGr+7 looks good to me.

WIPs: Learn to digitally sign the release .exe, if that can help with OS warnings.
	- You can use the MS SignTool program, part of their Visual Studio SDK, to sign an app. It requires a certificate to sign with.
	- The certificate should be a "code signing" (purpose) one.
	- You can get an EV (Electronically Verified) certificate; this costs money but trusted verification makes things simpler.
	- You can instead use a self-signed local certificate. This gives no other trust than people's confidence in you already did.
		- This, apparently, is often used for test purposes. But it's possible to distribute a self-signed certificate.
	- The certificate will be generated in my cert store. It can then be exported as a .PFX file.
		- The certificate needs to be installed by users, from your web page? I could do that, from dreymar.colemak.org.
		- Can people install the certificate on their machine once it's in the program? Check this with testers!
		- Keep the certificate in the EPKL repo, and point to it from the page? No, then people could misuse the certificate I think.
	- https://stackoverflow.com/questions/252226/signing-a-windows-exe-file
		- https://www.pantaray.com/signcode.html (download link didn't work, but good explanation)
		- https://learn.microsoft.com/en-us/powershell/module/pki/new-selfsignedcertificate?view=windowsserver2025-ps
	- Running (#r) `certmgr.exe` lets you view certificates.

TODO: QMK's repeat key can repeat actions such as Ctrl+Shift+Left to select multiple words. Would that be useful in EPKL?

TODO: In addition to OSM, OWS: One-Word Shift. It's seemingly quite popular with the QMK/ZMK crowd.
	- This one's not on a timer but sets a state that's annulled by Esc or any end-of-word key.
	- This means whitespace (Space, Enter, Tab etc) and punctuation – which needs to be de-shifted in time, too.
	- It's a one-shot kind of thing. Make it a special output? Would need a special function/state to keep it on until the next space.
	- E.g., `¢[Cap()]¢`? (Specify # of words to cap? Nah.)
	- What should negate it? Space, Esc, Shift?

NEXT: Send fn() antics study. Can we make a SendInput call separate of the Key event, or at least specifying KeyDown only?
	- https://discord.com/channels/115993023636176902/653362249687105536/1326675189353943050
	- Second example:
		b := Buffer(16 + A_PtrSize * 3, 0)
		NumPut(
		  "UInt" ,  1,      ; type = INPUT_KEYBOARD
		  "UInt" ,  0,      ; padding
		  "Short",  0,      ; wVK
		  "Short",  0x03B1, ; wSC
		  "UInt" ,  4,      ; dwFlags = KEYEVENTF_UNICODE
		  "UInt" ,  0,      ; time
		  "UPtr" ,  0,      ; dwExtraInfo = NULL
		  b
		)
		DllCall("SendInput", "UInt", 1, "Ptr", b, "Int", 16 + A_PtrSize*3)
		
	- https://discord.com/channels/115993023636176902/653362249687105536/1327235887553314838
	- Example:
		MySendInput() {
			INPUT_KEYBOARD  := 1
			KEYEVENTF_KEYUP := 0x02
			cbSize          := 40
			cInputs         := 80
			inputs          := Buffer(cbSize * cInputs, 0)
			loop cInputs {
				NumPut(
					"UInt"  ,   INPUT_KEYBOARD, ; type
					"UInt"  ,   0,              ; padd
					"UShort",   0x41,           ; wVk (VK_A)
					"UShort",   0,              ; wScan
					"UInt"  ,   Mod(A_Index, 2) == 0 ? KEYEVENTF_KEYUP : 0, ; dwFlags
					inputs,
					(A_Index-1) * cbSize) ; offset
			}
			DllCall("SendInput", "UInt", cInputs, "Ptr", inputs, "Int", cbSize)
		}

NEXT: Check out Keyman. It used to cost money but is now open-source and free, and owned by SIL?!
	- https://keyman.com/developer/
	- https://superuser.com/questions/527349/cross-operating-system-custom-keyboard-layouts
	- https://help.keyman.com/keyboard/sil_ipa/

2FIX: HIG: Yellow marks for combining accents etc aren't working anymore?

2FIX: The Shift key was often lost for a time, forcing a refresh? Only for Ext-Shift?
	- Could it be because some key combos change system layout now? (How?)
	- I also keep losing Ext Ctrl+Tab? What gives?

2FIX: PowerString name capitalization?
	- Composing, say, `say'pkl` and `say'Pkl` both output the ¶saypkl PowerString. Case should matter.
	- Checked whether a ¶sayPkl entry on the former sequence would work; it doesn't?
	- This may be another case of needing to make PklIniRead generally case sensitive, as with DKs?!
	- Only Composer respects case now, since it uses pklIniSect()?
	- For now, circumvented the problem by renaming the capitalized PowerString like `¶say-Pkl`.

NEXT: Detect OS VK codes for all keys instead of just a select subset, so OS layouts like AZERTY and Colemak-CAWS work as they should.

NEXT: With SC remaps, can we now actually remap the System layout? For instance, passthrough the OS layout but add AngleWideSym to it?!?
	- No, doesn't work; the SC don't get remapped at all. Ah well.
	- Consider which System mods to support. It may not make sense to add Curl there? But I want the right Extend etc when using mods.

WIPs: Ensure PrtScn is sent right for the CoDeKey and other DKs. Need PrtScn (all active windows), Alt+PrtScn (active window) and Win+PrtScn (full screen)

WIPs: Check out https://www.autohotkey.com/boards/viewtopic.php?f=6&t=77668&sid=15853dc42db4a0cc45ec7f6ce059c2dc about image flicker.
	- "Reduce Flicker dramatically (Double Buffer)" for constant GUI updates, like the EPKL help images.
	- May not work with WinSet, Transparent? I'm using that with the Help Images now.

WIPs: Introduce the marvelous Compose key in the README! Need more documentation on its merits. Also the new CoDeKey (dual-role Compose/Dead Key).
	- Become a Great Composer!

WIPs: In the Janitor timer: Update the OS dead keys and OEM VKs as necessary. Register current LID and check for changes.

WIPs: Revisit the ISO key for several locale variants as the new Compose key is so powerful. Spanish? Probably not Scandi/German? Or?

WIPs: Make README.md for the main layout and layout variant folders, so they may be showcased on the GitHub site.
	- This way, people may read, e.g., IndyRad/QI analysis on the GitHub page in Markdown rather than the unattractive comment-in-file format.
	- Update correspondence between the Locale Forum topic and these pages: Link to EPKL in the topic, get info from the topic.

WIPs: Mother-of-DKs (MoDK), e.g., on Extend tap, has near endless possibilities – especially if dead keys can chain.
	- MoDK idea: Tap Ext for chaining DK layer (e.g., {Ext,a,e} for e acute – é?). But how best to organize them? Mnemonically is not so ergonomic.

WIPs: Dual-role modifiers, continued.
	- Allow home row modifiers like for instance Dusty from Discord uses: ARST and OIEN can be Alt/Win/Shift/Ctrl when held. Define both KeyDn/Up.
	- In EPKL_Settings, set a tapOrModTapTime. In layout, use SC### = VK/ModName first entries.
		- The key works normally when tapped, and the Mod is stored separately.
	- Redefine the dual-role Extend key as a generic tapOrMod key. Treating Extend fully as a mod, it can also be ToM (or sticky?).
	- 2FIX: ToM-tap gets transposed when typing fast, the key is sluggish. But if the tap time is set too low, the key can't be tapped instead.
		- To fix this, registered interruption. So if something is hit before the mod timer the ToM tap is handled immediately.
		- However, Spc isn't handled correctly!? It still gets transposed.
	- Make a stack of active ToM keys? Ensuring that they get popped correctly. Nah...?
	- Should I support multi-ToM or not? Maybe two, but would need another timer then like with OSM.

;;  ================================================================================================================================================
;;  eD 2FIX:

2FIX: Repeat/Compose don't work on DK output?
	- Example: Typing {CoDeKey, [, Repeat} outputs`å[`.
	- Repeat works after composes. Not from OS DKs: Repeats the last non-DK press w/ Cmk-eD2VK. `ää` `áá` as it should w/ Cmk-eD.
	- Could be solved by adding DK output to the Compose queue. Might cause some trouble w/ how Back handles the queue then, but that's minor?

2FIX: SwiSh/FliCK modifiers don't stay active while held but effectivly become one-shot. And AltGr messes w/ them. Happened both on QW_LG and QWRCT.
	- The vmods don't need to be sticky for this to happen.
	- Are they turned off somewhere on release? That'd account for them working only once.

2FIX: Composes with apostrophe not working with eD2VK?!?
	- `^a` produces â but `'e` not é, etc. The culprit is the ' not being accessible from the underlying layout (registers as `o`).

2FIX: Holding MoDK-Ext then releasing it activates @ext0 even though Ext was held for > 1 s (over tapModTime = 200 ms).
	- If the Ext-hold is used w/ another key, it goes back as it should.
	- It'd be nice to make an Extend key KeyUp deactivate any MoDK layers. But how to deactivate DK layers like that?

2FIX: The `Ctrl+Shift+3` shortcut doesn't always suspend EPKL.
	- Seems it works after the first suspension.
	- Try to suspend/unsuspend EPKL once at startup then? Is that possible?
	- But WHY would this be the case?

2FIX: Releasing an Ext# layer leaves it active for a ToM timer duration.
	- With a dual-function Ext key, activate first Ext2 then quickly Ext1. Ext2 will stay active for one ToM timer.
	- https://github.com/DreymaR/BigBagKbdTrixPKL/issues/65
	- When I tried setting a high ToM Timer duration to test it, I couldn't activate Ext2 before the timer expired.
		- This is because of the tap (MoDK) getting registered, understandably. Would a working ToM interrupt help?
		- It is as it should be, I guess?

2FIX: DK detection works for my eD2VK layout, but not its pure VK counterpart. What gives?!
	- Is the BaseLayout wrong somehow? No, copying a key mapping from the Colemak-VK BaseLayout to the eD(2VK) Layout_Override preserves DK functionality.
	- Also, do DK detection when it's set to auto, and the old way otherwise? Then, what about when there is a table entry?
	- Call getWinLayDKs() (in pkl_deadkey) more robustly? No, it's the test for "śķιᶈForDK" in pkl_keypress that matters.
		- But keyPressed( HKey ) in pkl_keypress handles eD2VK and VK keys the same? So why then is the DK ruined by one and not the other?

2FIX: For the NNO WinLay, it registers SC00D as "1" and SC01B as "0:6"; they should be "1:6" (àá) and "0:1:6" (äâã), resp.?! How come some states get lost?!
	- Both are missing their state 6 dead key, acute and tilde respectively. There are no other dead keys in the layout. The Cmk-eD layout gets state 6 registered.
	- Might using ToUnicodeEx make a difference?
	- Reverting to listing DKs in the settings sounds like a defeat now...
	- Test it on the Colemak-eD MSKLC, since it has a ton of DKs? Only on levels 0:1 or 6 though.

2FIX: pkl_init runs through the layout twice. Is that really necessary, or does it simply double startup time?! Why does it even do this, again?!

2FIX: A ToM Caps/Ext key stops working as CapsLock after a while.
	- Initially, both work fine but after a while only the Extend-on-hold functions as it should.
	- Ext+Esc still toggles CapsLock as expected, and Caps-tap will turn that off. But not on, once it stops working.
	- https://www.reddit.com/r/Colemak/comments/14tmlvj/how_do_i_change_epkls_ext_key_to_say_lshcaps/
	- Could the mod-up sent on Extend key release be involved?

2FIX: When holding Extend-mousing for long with Timerless EPKL, there is still a hotkey queue. Probably the AHK hotkey buffer itself.
	- Problem: Once the queue is full, normal keypresses/letters start to occur. Occurs after ~2 s of Extend-mousing holding down the keys.
	- Is there a way of purging the actual AHK hotkey buffer? Or could changing its settings help?

2FIX: Somehow, the MSKLC Colemak-eD does ð but not Đ? Others are okay it appears.
	- Affects key mapped (eD2VK, System…) layouts. All other mappings seem okay.
	- The similar Gralmak-eD .klc doesn't have this problem?

2FIX: System mapping the QWP_# keys makes them ignore NumLock state?! Not sure how that works, but it's a tricky issue when one SC caters to two VK codes.

2FIX: The findWinLayVKs() fn is doing something wrong now? Trying to use the whole SCVKdic produces lots of strange entries...?!
	- Maybe I'm thinking all wrong about this though! There are two different issues at play: Where the OEM keys actually are, and how to remap keys.
	- Therefore, OEM keys should probably be treated differently from remapped keys (AZERTY, Cmk-CAWS etc). In some cases, a key can be both! Char-to-VK?
2FIX: SC remap the OEMdic, or layouts with ergo remaps will get it wrong. Example: Ctrl+Z on Angle stopped working when remapping QW_LG VK by SC.
	- In pkl_init, make a pdic[SC] = VK where SC is the remapped SC codes for the OEM keys, and VK what VK they're mapped to (or -1 if VKey mapped)
	- And/or a VK(ANSI)-to-VK(OS-layout) remap pdic?
	- Just detect every single VK code from the OS layout: It'd fix all our VK troubles, and account for such things as my CAWS OS layout.

2FIX: Hiding a DK image triggered by an AltGr+<key> DK fails: The AltGr help image gets stuck instead if it happens too fast. Affects hiding 'DKs'.
	- To avoid DK images stuck in the AltGr state, use a slight delay before showing the image if it's DK? It's a dirty hack, but could it help?
	- Would destroying the GUI on DK activation help at all?
	- If a DK is selected very fast, the AltGr DK state image may get stuck until release. This happened after adding the DK img refresh-once timer?
	- Renamed any state6 DK images that contained only a base key release on Spc, to miminize this issue. DKs like Ogonek still have it.

2FIX: Some new DK sequences don't work, like `~22A2   =  ~22AC	; ⊢ ⇒ ⊬` {DK_/,DK_=,g}. Others like `~2228   =  ~22BD	; ∨ ⇒ ⊽` {DK_/,DK_=,v} work. What gives?
	- Also iota/upsilon with dialytika and tonos don't work...?

2FIX: When selecting downwards with Extend and then using Extend-copy, sometimes an 'EXT' character (?) is made instead.

2FIX: Win+V can't paste when using ergo-modded layouts like AWide. However, with CAWS and Vanilla it works.
	- Is this because of the VK detection making an error? The ones that work both have V in its old place.

2FIX: Every now and then (while using Extend?) EPKL becomes unresponsive to hotkeys and, e.g., changing tabs. Sometimes needs a menu Refresh/Restart.
	- No good ideas what causes this! It's annoying and happens too often.
2FIX: There are many composes with apostrophe; these may cause trouble for the CoDeKey when typing, e.g., `pow'r`. Move all acutes to, e.g., `''r`?
2FIX: Help images show 3–4× at startup with a slightly longer Sleep to hopefully avoid a minimize-to-taskbar bug on the first hide image.
	- It still doesn't work as it should, but the problem is hard to reproduce.
2FIX: Looks like there are multiple EPKL instances in the Tray now? Is that true? Can it be GUI windows? Can it be refresh related? Mouseover removes them.
2FIX: Ext-Shift may get stuck until Ext is released. Not sure exactly how.
2FIX: Help images for Colemak-Mirror don't show the apostrophe on AltGr even though it's functional and defined equivalently to the base state one.
	- Debug on 6_BS doesn't show any differences; looks like &quot; is still generated.
FIXED: Removed pressing LCtrl for AltGr (as in pkl_keypress.ahk now!). And changed to {Text} send.
	- Does it fix the problem with upgrading to a newer AHK version?!? No! LCtrl still gets stuck upon AltGr in AHK v1.1.28+.
2FIX: Setting a hotkey to, e.g., <^<+6 (LeftCtrl & LeftShift & 6) doesn't work.
2FIX: The ToM MoDK Ext doesn't always take when tapped quickly. Say I have period on {Ext-tap,i}. I'll sometimes get i and/or a space instead.
	- Seems that {tap-Ext,i} very fast doesn't take (producing i or nothing instead of ing)? Unrelated to the ToM term.
2FIX: Mapping a key to a modifier makes it one-shot?!
2FIX: Redo the AltGr implementation.
	- Make a mapping for LCtrl & RAlt, with the layout alias AltGr?! That'd pick up the OS AltGr, and we can then do what we like with it.
	- Treat EPKL AltGr as a normal mod, just that it sends <^>! - shouldn't that work? Maybe an alias mapping AltGr = <^>!
2FIX: The NBSP mapping (AltGr+Spc), in Messenger at least, sends Home or something that jumps to the start of the line?! The first time only, and then normal Space?
2FIX: Remapping to LAlt doesn't quite work? Should we make it recognizeable as a modifier? Trying 'SC038 = LAlt VK' also disabled Extend?
TEST: ToM Ctrl on a letter key? Shift may be too hard to get in flow, but Ctrl on some rare keys like Q or D/H would be much better than awkward pinky chording.
	- It works well! But then after a while it stops working?

2FIX: The HIG doesn't make space between dual accents anymore? They coalesce on AltGr+8 now.
	- Sort of fixed it by making the new disp0 entry that can display any string on the DK's key in the help image.
2FIX: I messed up Gui Show for the images earlier, redoing it for each control with new img titles each time. Maybe now I could make transparent color work? No...?
2FIX: If a layout have fewer states (e.g., missing state2) the BaseLayout fills in empty mappings in the last state! Hard to help? Mark the states right in the layout.
2FIX: Pressing a DK twice should release basechar1 (s1) but basechar0 (s0) is still released. Not sure why.

;;  ================================================================================================================================================
;;  eD TONEXT:

NEXT: CancelState key mapping, removing all Ext/Caps/DK/etc states.
	- Talking with Casuanoob at the Cmk Discord, about layer keys and QMK/ZMK implementations.
	- https://discord.com/channels/409502982246236160/548799170765389834/1371832911182958683
	- Could use a `¢[Release()]¢` formalism?

NEXT: Instead of doing the atKbdType() this-and-that routine, make a fn to interpret all @ codes and add it as a switch for pklIniRead()?
	- This would allow the use of all @ codes in all LayStack files

NEXT: Sort out layout img_ entries for easier mod combo generation, without manually editing their individual names?
	- Settings for Soft/Hard image versions? Extend(@X - `CAWS`)/Geometric(@H - `AWide`)?
	- Example: `Files\ImgExtend\@K-CAWS_Ext#.png` files could be `Files\ImgExtend\@K@X_Ext#.png`.

NEXT: Try to emulate AHK Send in such a way that it doesn't send KeyUp even for state-mapped layouts!
	- Just adding " DownR}" to the normal pkl_SendThis() didn't work; the KeyUp events are still sent.
	- Ask around at the AHK forums as to what Send really does, and whether there's an existing workaround for KeyUp. Or at the AHK Discord!
	- One possibility might be to send keys for simple letters, but that's not robust vis-a-vis the OS layout? There's the ## mappings for that, too.

NEXT: Arabic phonetic layout! Also, check the Hebrew one.
	- Hebmak: https://forum.colemak.com/topic/1458-locale-colemak-variants-for-several-countries-the-edreymar-way/#p19971
	- Arabic: ./Layouts/Colemak/Cmk-eD-Ara
	- Write in each ReadMe about the benefits of special DKs - even if you don't care about niqqud/dagesh/etc.

NEXT: Files override?!
	- Maybe just one file to override all files in Files? Maybe place it in root? Have supersections to separate the files.
	- Each supersection could have an entry specifying which file it overrides: _eD_Compose, _eD_DeadKeys, _eD_Extend, _eD_PwrStrings.
	- Not _eD_Remap in this file, as it is already taken care of in the LayStack files?

NEXT: Instead of *etLayInfo("ExtendKey"), an array of mod keys?
	- In the case of more than one, say, SwiSh or Ext keys, could number them? Have each mod entry be an array.
	- { "Extend" : [ "SC###", "SC###" ], "SwiSh" : [ "SC###" ] }, for instance
	- Next up, maybe specify which layer(s) goes which which key so you can have different Extend keys? A dedicated Ext2 key if you want.

NEXT: Update to newer AHK! v1.1.28.00 worked mostly but not for AltGr which sends Alt and gets Ctrl stuck. v1.1.27.07 works fully.
	- AHK version history: "Optimised detection of AltGr on Unicode builds. This fixes a delay which occurred at startup (v1.1.27) or the first Send call (earlier)."
	- After update past v1.1.28, we can use StrSplit() with MaxParts to allow layout variant names with hyphens in them!
	- Should then be able to go to v1.1.30.03 right away, but check for v1.1.31? That version has added an actual switch command, though!!!

NEXT: Add the Canaria variant of Canary, which is said to be much better for Spanish/Spanglish.
	- Compared to standard Canary, it has a J-X swap, AltGr mappings like EsAlt, and grave/tilde DKs (already in eD).
	- https://github.com/christoofar/canaria

NEXT: Rework Extend mappings so they use normal state mapping syntax. The current state of affairs just confuses people.
	- This means that many current mappings that are just `<key>` must be changed to `β{<key>}`.
	- The magic happens in extendKeyPress() in pkl_keypress.ahk, under `if not pkl_ParseSend()`.
	- Here, `Send {Blind}%pref%{%xVal%}` is used after checking for ExtMods.

NEXT: Toggle-type modifiers.
	- Navigating web pages, I'd like to press a lot of PgUp/Dn and arrows without holding the Ext modifier which gets tiresome.
	- I'd also like to stay in the NumPad layer for protracted number entry sessions, without holding down the Ext key.
	- It might be good to have the lock within the layer. Say, Ext+` locks whatever Ext layer is active.
		- For the current Ext+` mapping, it's enough to have that on Ext-tap+`.
		- Or is double-tapping the modifier better, as it doesn't use up a mapping? That, however, would be a problem for ToM keys.
	- But how to make it easy to get out of the layer again? Actually, just tapping the normal modifier should do the trick!
	- Leave lockable layers out of Janitor cleanup? Or just use a long enough Janitor idle timer that it won't be an issue? Configurable?
		- The _pklJanitorCleanup() fn is currently not active, seemingly without any negative impact. So that's okay?

NEXT: Actual settings shown in the Layout Picker and Special Keys tabs.
	- https://github.com/DreymaR/BigBagKbdTrixPKL/issues/80
NEXT: Add a Help button with a more generic help screen for the first Settings UI panel?
NEXT: Move the text for the Settings UI help text to the language files?!
	- Make a separate .ini file section for it. Then read in the whole section and process it?
NEXT: Flesh out menu entries in the Settings UI? For instance, ANS ⇒ ANS(I), AWide ⇒ AWide (Angle+Wide) etc. Use a dictionary of string replacements?
NEXT: In preparation of AHK v2, rework the Gosub-based routines in the pkl_gui_settings.ahk file.

TODO: Auto-hide help images!? Set a timer for idle time with the Janitor. Inspired by the on-screen keyboard app OverKeys.

TODO: Update the X11 Compose table to a newer version.
	- Must re-import it, and then make a 3-way diff to include all my custom changes to the old one.

TODO: As a `##` state map entry maps to a VK send, maybe add a `#<VK>` syntax to send another VK by its one-letter code or `0x##` code? `#A` for the `A` key, etc.
	- That would encroach upon the AHK syntax, which we've mostly avoided thus far. But `Win+a` could still be easily enough sent by `α#a`, etc.

NEXT: Further getWinLayDKs() development
	- What to do w/ the detect/get/setCurrentWinLayDeadKeys() fns?
	- Get rid of the systemDeadKeys setting, and update setCurrentWinLayDeadKeys() accordingly... unless it's still needed for pkl_Send()?!?
	- Get rid of [DefaultLocaleTxt] and [DeadKeysFromLocID] in EPKL_Tables.ini and all language files?
	- getCurrentWinLayDeadKeys() is checked in pkl_Send(). It's chr based though. Make another dic based on chars, in getWinLayDKs()? But ToAscii doesn't give them?
	- What about pkl_CheckForDKs() in pkl_send.ahk?

NEXT: A debug hotkey to generate a set of help images on the fly using default settings? Just call the make image fn() then sleep 600 then hit Enter, basically.

NEXT: Since Compose tables can be case sensitive now, do the same for DKs? Then scrap the silly `<K>+`-type DK entry syntax - keep <#> syntax?
	- Read in all DK tables in use at startup instead of each entry as needed then? Faster use, slower startup, more memory usage. Acceptable?

NEXT: Move all override (and settings?) files to the Data folder? More compatible w/ the PortableApps format (backup++), but less clear?

NEXT: User working dir: All user files can be under a specified user root dir.
	- https://github.com/DreymaR/BigBagKbdTrixPKL/issues/34
	- Make a userDir setting in Settings with `Data` as its default value, and read it in during early pkl_init.
		- The Settings_Override specifying where to find user root would have to be at program root.
			- Or? Could use Data as default? Then read it twice, to see if Data holds a Settings_Override. The Data dir could also hold templates?
	- Any file read should look first under user root, and then if not found there program root.
		- Keep tabs in a global array after first access attempt, to avoid looking for files so much?
	- Keep Layout_Override.ini files in their correct layout folder paths but under user root then.
	- Make and look for overrides in the working dir, and defaults in the script dir only?
	- Can also have overriding help images this way. Make the HIG able to generate these under user root?
		- This would make sense, letting a user set individual settings in their working dir and getting images there too.
	- By default, the working dir root can be Data which is the right place for it in the PortableApps standard (for backup).
	- Special syntax? `User\` or `~\` could point to working dir, and `.\` continue to point to script dir? Make all file-reading operations aware of this!?
	- Might use a switch of working dir for some operations? Or, should things like the HIG just assume working dir and anyone wishing to use it must adjust?
		- For users having their EPKL install in a non-writable area, the HIG would need to use the working dir as its work area anyway.

TODO: A layout array to switch layouts, instead of reloading EPKL each time?!
	- The longish delay between full EPKL restarts makes multi-layout usage a challenge
	- Would have to use multi-dimensional dead key etc arrays too, then

TODO: Modifier lock. For which modifiers?
	- Extend lock? Maybe too confusing. But for, say, protracted numeric entry with Ext2 it could be useful?
		- E.g., LShift+Mod2+Ext locks Ext2? Or, have a mapping within the Extend layer that locks it? And one that unlocks all Extend states.
	- Make a more generic lockable modifier type, for SwiSh/FliCK etc (but hardly for Ctrl-lock?).
		- For instance, RCtrl+SwiSh could lock/unlock SwiSh: Hold RCtrl, then tap SwiSh to lock/unlock.
		- There could be a setting for mod-locking pairs? Like this: `SwiSh/RCtrl,LShift/RShift`.
	- Could be a "lock the next modifier" mapping. Especially if we could make that dual-function on, say, the LCtrl key with a ToM timer?
		- If, say, LShift is a mod-lock ToM, then it shouldn't be able to lock itself. Could it be both a sticky Shift and a mod-lock?

TODO: Layout preview image for the layout chooser. Could just change the normal help image temporarily?
	- Show the help image of the chosen layout, with the right background. Allow any state image by pressing modifiers.

TODO: Try to fix AltGr so we can move beyond AHK v1.1.27 which is old now. Ask at the AHK forums!

TODO: Like SteveP's Seniply has it, make Ext-mods Sticky by default? Allow a Parse-Entry syntax for it, or a setting?
	- It's already started in the {Shift OSM} syntax, but not sure that'll work fully with the Ext-mods? They need to be dual-function.

TODO: The newLID pklJanitor routine doesn't quite work, since the locale gets preloaded on EPKL startup or smth. Need to restart EPKL then? Or just re-read parts?

TODO: A layout2/3/4 setting in layout files that can define Swish/Flick layers. Allows for instance a Greek layout added as Swish/Flick layers.

TODO: More GUI settings?
	- A Hotkeys settings panel?
	- Menu language choice (on the Settings tab), with a dropdown choice of the actual language files present?

TODO: If we get Timerless EPKL working, maybe ToM can have better timing at last? Enabling exciting projects like HomeRowMods and a Shift+CoDeKey ToM.
TODO: Once ToUnicode() and DetectDK() are working, it should be possible to generate help images from VK/SC layouts too?!
TODO: SwiSh/FliCK should be the ideal way of implementing mirrored typing?
	- Need to solve them being effectivly one-shot now, then. They should be able to be held down reliably.
	- For fun, could make a mirror layout for playing the crazy game Textorcist: Typing with one hand, mirroring plus arrowing with the other!
TODO: OS DK detection sucks.
	- Go through all SC### and send their four states? (Only if the OS layout has AltGr; can we detect that by DLL?)
	- Or detect through the ToUnicodeEx() DLL? Seems much better.
	- Also store the DK characters in a better format? Just a string like ´¨`^~ is unclear and tricky.
TODO: Ext layers by app/window? Like auto-Suspend. Could be handy for ppl w/ apps using odd shortcuts.
TODO: Look into this Github README template? https://github.com/Louis3797/awesome-readme-template
TODO: Make key presses involving the Win key send VK codes. This'll preserve Win+‹key› shortcuts without using ## mappings.
TODO: Rework the GUI submit to allow multi-submit/reset on tabs that have more than one submit. 
	- Maybe make the submit routine callable with arrays so it loops before asking for a restart?
TODO: A set of IPA dk, maybe on AltGr+Shift symbol keys? Based on my old IPA DK ideas. Could be chained from a MoDK? Or solved as composes.
		- IPA Compose sequences? Vowels with numbers according to position?
		- The Keyman solution, for inspiration: https://help.keyman.com/keyboard/sil_ipa/2.0.2/sil_ipa
		- Vowel DKs: Front/mid/back, with capitalisation distinguishing unrounded vs rounded?
		- Consonant DKs: Bilabial/labiodental/dental/alveolar/postalveolar, retroflex/palatal, velar/uvular, pharyngeal/glottal?
			- If composing, use these letters then: `b l d a (pa) r p v u f g` for consonants, 1–6 for vowels?
TODO: Make a "base compose output" that a Compose key releases whenever no sequence is recognized? Like the Basechar of a DK. Useful for locale layouts?
TODO: Personal override files for extend, compose, powerstrings etc? One override file with sections? Some overrides (remaps, DKs) in layouts.
TODO: Is the main README still too long? Put the layout tutorial in a Layouts README? Also make a tutorial for simply using the CkAWS remap or something.
TODO: Add QWERTZ and AZERTY layouts? There are now remaps for them, and the rest should be doable with OEM VK detection.
TODO: Provide a swap-LAlt-n-Caps RegEdit script, and a reversal one. Maybe add some more codes in the comments, see my old RegEdit scripts.
TODO: Harmonize Ext and folder mod names? And/or make a shorthand for the @E=@C@H@O battery in addition to @K in layout files? And also the short variant like CAW(S)?
	- Could expand, e.g., CurlAWide to CurlAngleWide for the layout name only? Or use long names like CurlAWideSym consistently?
	- Make long names more consistent? Like 4 letters per mod, CurlAnglWideSyms ? Nah, too anal. Better to keep with CurlAWideSym, and that's long enough really.
	- Use CAngle or CA--, etc? CAngle is more intuitive, but CA more consistent with CAW(S). 

;;  ================================================================================================================================================
;;  eD TODO:

TODO: Could the [layout] section be composed from includes of other sections? Such as [Numbers], [Symbols], [Letters], [Others]?
	- That'd be more similar to the modularity of my XKB-data files.
	- This would facilitate hybrid layout types such as VK-numbers (to allow Win+Number shortcuts), VK-letters/eD-symbols...

TODO: Improve GUI responsiveness further.
	- GUI startup is slow. Where are the bottlenecks? Try to tic-toc GUI startup?
	- Globals initialization including folder scanning has been added to a function called at init time.
	- Could also make GUI startup more responsive by pre-initializing the GUI at init. As it is now, it's made from scratch each time.
	- Candidate: Layout selection. Premake the list of eligible layouts (and LayType? KbdType? Variants? Mods?) beforehand.
TODO: Use the off-Space thumb key as a Shift/CoDeKey ToM!
	- Preserves SteveP's thumb Shift for compact boards, while allowing the fancy CoDeKey shift combos too.
	- It's a sweet idea! But again, it requires better ToM timing than EPKL can currently deliver. So it'll have to wait, for now...
TODO: Make the CoDeKey follow the StickyTime timer? So you'll only use it as CoDeKey in flow. No, it'd need its own timer.
TODO: Could I turn around the Compose method, to be leader key after all? But how to input then? Without looking sucks. In a pop-up box?
TODO: Color markings for keys in HIG images! Could have a layer of bold key overlays and mark the keys we want with colors through entries in the HIG settings file.
	- markColors = #c00:_E/_N/_K, #990:_B/_T/_F, #009:_J     ; Tarmak2 colors
	- markColors = <CSV of marking specs>, similar to the remaps. Could have Tarmak1,Tarmak2,Tarmak3,#009:_J ?
	- See https://forum.colemak.com/topic/1858-learn-colemak-in-steps-with-the-tarmak-layouts/p4/#p23659
	- Allow a section in Layout.ini too!
	- Mark differently by state, as in the Tarmak images
TODO: Make state images and DK image dirs ISO/ANSI aware?! Generate both in the HIG each time (plus Ortho?). Make layouts that can handle both. 
	- How to handle special mappings? Could have [layout_###] sections.
TODO: I never use the SendMessage parse prefix. Cannibalize it for a strEsc() send? Or add that as €\ prefix instead?
Mod ensemble: For lr in [ "", "L", "R" ], For mod in [ "Shift", "Ctrl", "Alt", "Win" ] ? May not always need the empties? Also add [ "CapsLock", "Extend", "SGCaps" ] ?
TODO: Redo the @Ʃ_@Ç formalism, adding @K to @E(@C@H@O) by a hyphen instead of an underscore? Would that be a benefit in any way? Or just a lot of work?
TODO: Hotstrings? May have to wait for AHK v1.1.28 to use the Hotstring() fn? Or is there somewhere in this script we could insert definitions?
TODO: Consider a remap for each Ext layer? Would make things messier, but allows separate Ext1 and Ext2 maps, e.g., for the SL-BS switch.
	- Allow mapSC_extend2 etc entries in the LayStack. If not specified, use the _extend one for all.
TODO: Add ABNT keys to the HIG template?
TODO: Record macro? Or just a way to set entries for a certain DK layer in the Settings UI? Say, the Ext-tap layer(s). Could have backup DK layers and a Reset button.
TODO: Make EPKL able to hold more than one layout in memory at once?! This would make dual layouts smoother, and using layouts as layers (Greek, mirroring etc) possible.
	- With SGCaps modifier layers, the need for this may be alleviated?
TODO: Since no hotkeys are set for normal key Up, Ext release and Ext mod release won't be registered? Should this be remedied?
TODO: Rework the modifier Up/Down routine? 
	- A function pklSetMods( set = 0, mods = [ "mod1", "mod2", ... (can be just "all")], side = [ "L", "R" ] ) could be nice? pkl_keypress, pkl_deadkey, in pkl_utility
TODO: Replace today's AltGr handling with an AltGr modifier. You'd have to map, e.g., RAlt = AltGr Modifier, but then all the song-and-dance of today would be gone.
	- Note that we both need to handle the AltGr EPKL modifier and whether the OS layout has an AltGr key producing LCtrl+RAlt on a RAlt press.
	- Also allow ToM/Sticky AltGr. Very very nice since AltGr mappings are usually one-shot.
	- Define a separate AHK hotkey for LCtrl+RAlt (=AltGr in Windows)? That might make things simpler.
TODO: VK mappings don't happen on normal keys. Simple VK code states don't get translated to VK##. Only used when the key is VK mapped.
TODO: Instead of CompactMode, allow the Layouts_Default (or _Override) to define a whole layout if desired. Specify LayType "Here" or suchlike?
	- At any rate, all those mappings common to eD and VK layouts could just be in the Layouts_Default.ini file. That's all from the modifiers onwards.
TODO: Import KLC. Use a layout header template.
	- Could have a section of RegEx conversions with name tags in the template, which gets used and then cut out.
	- Each such entry could have a tagName = ## SplitBy JoinBy <regex>
		- Allow both RegExReplace and RegExMatch entries? The latter should use O) match objects?
		-  The ## denotes how many numbered entries should be run on this string. This could have sublevels, like ##-##-##.
		- SplitBy loops through elements of the string, recursively if subentries also split. Then it's rejoined with JoinBy (necessary, or just regex that?).
		- Can we SplitBy words, like \nDEADKEY\t ?
	- Then in the template there's something like $$tagName$$ where the result is to be inserted.
	- For DK full names, the KEYNAME_DEAD entries could be converted (cut out ACCENT/SIGN, _ for spaces?, cut away parentheses, title case). Update my names accordingly?
	- In addition to MSKLC format, allow Aldo Gunsing's KLFC! https://github.com/39aldo39/klfc And maybe Keyboard Layout Editor's KLE (or do that via KLFC).
TODO: Make pklParseSend() work for DK chaining (one DK releases another)!
	- Today, a special DK entry will set the PVDK (DK queue) to ""; to chain dead keys this should this happen for @ entries?
	- Removing that isn't enough though? And actually, should a dk chaining start anew? So, replicate the state and effect of a normal layout DK press.
	- Chaining DKs opens up for interesting possibilities, like a Mother-of-Dead-Keys key (MoDK)! Could that be on Extend-tap, possibly with a timeout? Or on Backspace?
		- See Jaroslaw's MoDK topic in the Forum: https://forum.colemak.com/topic/2501-my-current-programming-symbols-layout/#p22527
		- Placing all my DKs on MoDK sequences will fill up a layer. So maybe only the most interesting ones? But how to make it mnemonic?
		- Example: Tap-dance {Ext,t,n} -> ñ; {Ext,a,A} -> Á; {Ext,0-9} IPA DKs.
		- For good measure, could have different DKs on different states of the same key! Wow. The ToM formalism should support this actually!
TODO: With the Compose method, look into IME-like behavior?
	- This would allow "proper" Vietnamese, phonetic Kyrillic etc layouts instead of dead keys which work "the wrong way around".
	- Could make special compose keys for accents? E.g., you type a^ and the ^ key is a Compose key producing â.
TODO: Make EPKL work with the .exe outside a .zip file? 
	- You could then download the release .zip, put the .exe outside, change then rezip any settings you want to, then the .exe will use the archive.
	- This may be desirable for people running EPKL from an URL. It's easier to handle two files than several folders.
TODO: Try out <one Shift>+<other Shift> = Caps? How to do that? Some kind of ToM, where the Shift is Shift when held but Caps when (Shift-)tapped?
TODO: The key processing timers generate autorepeat? Is this desirable? It messes with the ToM keys? Change it so the hard down sends only down and not down/up keys?
TODO: Keylogging for gathering typing stats. Which stats? 1-2-3-grams, characters-before-backspace...
TODO: A help fn to make layout images? Make the image large and opaque, then make a screenshot w/ GIMP and crop it. Or can I use the Windows Snipping Tool (Win+Shift+S)?
TODO: AHK2Exe update from AutoHotKey v1.1.26.1 to v1.1.30.03 (released April 5, 2019) or whatever is current now. 	;eD WIP: Problem w/ AltGr?
	- New Text send mode for PowerStrings, if desired. Should handle line breaks without the brkMode setting.
TODO: Make the Japanese layout now, since dead keys support literals/ligatures and DK tables in Layout.ini are possible.
TODO: Mirrored one-hand typing as Remap, Extend or other layer?
	- For Extend, would need a separate Ext modifier for it? E.g., NumPad0 or Down for foot or right-arm switching. But is that too clunky?
	- SGCaps could work, but would require each layout to have SGC mappings to allow mirroring then. And a separate SGC modifier.
	- Layout switching is usually done by restarting EPKL which is too clunky. But if we could have a switch modifier that temporarily activates the next layout...?
	- This would require preloading more than one layout which takes a bit of reworking. Possibly... Allow an alt-set of the remap only, remapping on the fly w/ a mod?
	- Mirroring as a remap can now use minicycles of many two-key loops. For instance, |  QU |  SC /  MN |  SL | for two separate swaps.
TODO: Lose CompactMode from the Settings file. The LayStack should do it.
	- Instead of a setting in Settings, allow all of the layout to reside in EPKL_Layouts_Default (or Override). If detected, use root images if available.
	- If no Layout.ini is found, give a short Debug message on startup explaining that the root level default/override layout, if defined, will be used. Or just do it?

;;  ================================================================================================================================================
;;  eD ONHOLD:

HOLD: Pre-hoc Compose instead of post-hoc?
	- This could help the CoDeKey avoid misunderstandings whenever accidentally typing a composeable sequence beforehand.
		- However, how would the CoDeKey distinguish between composes and dead keys then?
		- It'd probably need a "Compose-This" key: A mapping to the actual © key? But that'd be less smooth and efficient.

HOLD: Should a stickyTime of 0 make sticky keys work like on Windows, without a timer?
	- Can just use a long timer instead, for simplicity but also robustness (Shift isn't stuck on forever).

HOLD: Unmapped and Disabled keys produce weird output, unless a « » prefix is used. Fix this?
	- Problem: These keys are simply skipped in pkl_init. They'd need some kind of tag for the HIG to mark them specifically.
	- What to use? Nothing, or some marking? For now, it's probably okay to leave this issue to the «» HIG tag.
	- There's a similar issue with DK entries unmapped with `--`.

HOLD: Now that we have ortho layout images, how about a really compact version?
	- Technically, it'd be easily to use the existing ortho template and just use a smaller export area for "OrthCpt" GeoType.
	- Could forgo the Ext/Shf/AGr indicators. Also misses the ISO key then; OK? But saving only one column isn't it.
	- With or without num row? I think the num row's probably integral to EPKL goodness and complexity. But so are symbols?
	- So either make it barebones 3×10u and save a lot of space at the cost of useful info, or drop it. Dropping it for now.

HOLD: Could @K cover geo as well? Should it? Nah for now, as there aren't that many Ortho files to handle.

HOLD: Further developments for the BaseLayout stack: Variant,Options/Script,Base....?
	- Make BaseVariants for all locales? Their Layout.ini files could mostly hold ergo remaps.
	- Use just the Variant/Top level, for now? Or could more levels be nice? E.g., one locale plus one with, e.g., extra composes?

HOLD: More `¢[]¢` syntax?
	- Use Eval() on arg; will that allow for instance "str" to be read as a string without the quotes?
		- No, eval() doesn't exist, and its principle is regarded evil in the AHK/coding communities.
	- Add  RunWait()? No: That waits until the program exits, which we don't want.
	- With the new power of Run(), add more handy Ext-tap mappings? Which would be most handy?
	- https://superuser.com/questions/217504/is-there-a-list-of-windows-special-directories-shortcuts-like-temp
	- https://www.autohotkey.com/docs/v1/misc/CLSID-List.htm
	- Could I use dynamic fn calling for wrapper functions in exec()? The original AHK example uses Goto labels (bad), but dynamic fn() could work?
		- https://www.autohotkey.com/boards/viewtopic.php?t=75956

HOLD: Default positional special DK mappings are messed up for non-Cmk layouts. Should there be a DK remap possibility?
	- This affects primarily the CoDeKey (@co0) and Ext-tap (@ex0/1) layers.
	- This issue is layout-based, making (Base-)Layout files the right place to override the mappings - for now.
	- At some point, a proper Remap option for positional DK layers would be neat.

HOLD: For the System layout having state help images makes no sense. Remedy this?
	- Use LayInfo("shiftStates")? But atm, not having the shift states active ruins OS DKs.
	- Cool idea: Make the Vim Help Sheet for Colemak available as a state image? Have it, e.g., on state1 to show it whenever Shift is pressed.
	- Did this, using my colemak-vim-helpsheet.svg files.
	- Ideally, should have different images depending on ergo mods. At least, ISO/ANS -(A)-- + CA-- + CAWS.
	- Problem: The smallest text on the help image doesn't render well at the standard help image resolution.

HOLD: Make WideSym into a separate remap now? Simpler? Less confusing, or not?
	- The Wide mod is already split by row (except RB and BS) which is quite instructive and consistent.
	- Made WS remaps for alt layouts like Sturdy that shouldn't do pure Wide mods as they have stuff on the Slash key.
	- We already have `SymMnW_@K` (no Cmk-QU remap) for alt layouts (vs `SymQuMnW_ANS`, for Cmk etc.).
	- An 'UnSym' remap is a good way of resetting symkey mappings for some layouts (like Graphite) before proceeding.

HOLD: Even More Modern Alt Keyboard Layouts?
	- We already have Semimak-JQ (2021) and Canary (2022), so consider adding some other "best candidates".
		- https://getreuer.info/posts/keyboards/alt-layouts/index.html#which-alt-keyboard-layout-should-i-learn
		- APT, Nerps, Sturdy and maybe Engram look good in Getreuer's comparison. [Also, Gallium and Graphite now, ++.]
	- APTv3 by Apsu (2021; the currently stable version) has been added.  https://github.com/Apsu/APT
		- Also add Aptmak? It uses a thumb key; EPKL could handle that (maybe w/ help from SharpKeys).
	- Graphite (2022-12) by RDavison was also added after favorable mentions.  https://github.com/rdavison/graphite-layout
	- Sturdy by Oxey (2022)?  https://o-x-e-y.github.io/layouts/sturdy/index.html
		- Oxey has several candidates, but I'd focus on one. It has high rolls but still low redirects.
		- Oxey said that Sturdy has a "decent amount of users" but "people are dropping it" so not worth it now?
		- https://discord.com/channels/409502982246236160/1002128319770271834/1129455798368612484
		- Con: Like Nerps, it has a too common key – CM – in the SL position. However, Oxey had some ideas for Wide.
			- https://www.reddit.com/r/KeyboardLayouts/comments/15zu2rn/comment/jysbcn8/?context=2
		- Possibly also Magic Sturdy by Ikcelaks, which EPKL could do...? It's what Getreuer uses.
		- https://github.com/Ikcelaks/keyboard_layouts/blob/main/magic_sturdy/magic_sturdy.md
	- Nerps by Smudge (2022)? I don't like its PD(.<) in the SL(/?) key position: Messes with the Wide mod, and just feels odd.
		- Also, it seems unstable. According to Oxey, it's been "superseded by Nerbs and Gallium" in some respects. No home page.
	- Engram?  https://engram.dev/  by Arno Klein (2021) is also neat, and some recommended adding it. Higher SFB% than CMK though (corpus dependent)!?
	- Dwarf/Whorf? ("Parented to CMini"?). No home pages?

	- Allow a mapping like Modifier(#), to add # to the modifier level? Use it as single-argument mapping entry. Modifier(8) would be SwiSh.
	- Instead of having to make special literal entries (`→` or similar) for unshifted characters in shifted states, make all character sends use Unicode/Text?
		- Issue: With Sticky Shift, the 2nd state mapping is sent shifted which is wrong if it was mapped to be something unshifted. Normal Shift does not.
		- Sticky Shift just holds down the Shift key which leads to this effect. Should I make sure the state map is sent unblind?
		- Only happens for single-character mappings. Mappings that aren't a key name aren't sent as "keys" by AHK.
		- Conclusion: Not a good idea to send as text categorically, as non-"key" sending breaks Win+‹key› shortcuts.
	- Try out a swap-side layout instead of the mirrored one? More strain on weak fingers, but fewer SFBs I should think.
		- Is the brain equally good at side-swapping and mirroring?
	- Hardcode Tab instead of using &Tab after all? It's consistent to have both the whitespace characters Spc & Tab hardcoded this way.
	- A dynamic key press indicator for help images, showing not just modifier layer but every press. Will it be fast enough? Needs a position table for each KbdForm.
	- Make a Setting for which fn to run as Debug, so I don't have to recompile to switch debug fn()? Maybe overmuch, as the debug fn often needs recompiling anyway?
	- Allow Remaps to use @K so that the layouts don't have to?!? Too confusing?
	- Remove all the CtrlAltIsAltGr stuff? If laptops don't have RAlt (>!), they can just map a key to AltGr Mod instead? Won't allow using <^<! as AltGr (<^>!) though...
	- Shift sensitive multi-Extend? When mapping for the NumPad layer, it'd be nice to have $/¢, €/£ etc. This allows many more potential mappings! 4×4-level Extend?!
		- In most cases though, that'd be useful mostly for releasing more different glyphs. This is better done with dead keys, as these avoid heavy chording.
	- Allow escaped semicolons (`;) in iniRead?
	- Remove the Layouts submenu? Make it optional by .ini?
	- Greek polytonic accents? U1F00-1FFE for circumflex(perispomeni), grave(varia), macron, breve. Not in all fonts! Don't use oxia here, as it's equivalent to tonos?
	- Some kaomoji have non-rendering glyphs, particularly eyes. Kawaii (Messenger), Joy face, Donger (Discord on phone). Just document and leave it at that.
	- Go back on the Paste Extend key vs Ext1/2? It's ugly and a bit illogical since the layers are otherwise positional. But I get confused using Ext+D for Ctrl+V.
	- Allow assigning several keys as Extend Modifier?
	- An EPKL sample Layout.ini next to the original PKL one, to illustrate the diffs? Or, let the contents of the main README be enough?
	- Auto language detection doesn't follow keyboard setup but system language. If you use a Non-English keyboard but Windows uses English, the auto language is English.
	- Someone used CapsLock on double-tap Shift. Neat idea! Except for the double-tap SFB, of course. If you have both Shift keys, a chord could do it?!

;;  ########################   <--«  TODO   ########################
*/

;;  ########################    main code   ########################

;#Requires AutoHotkey 1.1.27     							; This will be important when transitioning to AHK v2 in the future. At that point, use `2.0+` here.
;#Warn                   									; This AHK directive is handy for spotting global/local variable conflicts etc. May give a lot of warnings.
#NoEnv
#Persistent
#NoTrayIcon
#InstallKeybdHook
#SingleInstance         Force   							; eD WIP: Is something wonky with this now? I get lots of apparent EPKL instances in the System Tray...?
#MaxThreadsPerHotkey    3
#MaxThreadsBuffer       Off 								; We'll turn it on later in pkl_init, so it's off for program hotkeys and on for key press ones.
#MaxHotkeysPerInterval  300
#MaxThreads             32
#MaxMem                 128 								; Default 64 Mb. We need more than that for HIG image generation in its search-n-replace loop.
#KeyHistory             24  								; NOTE: If you're concerned about the security risk of the AHK KeyHistory log, set this to 0 and recompile.

SendMode Event
SetKeyDelay,    -1  										; The Send key delay wasn't set in PKL, defaulted to 10. AHK direct key remapping uses -1. What's most robust?
SetBatchLines,  -1  										; This script never sleeps (default is every 10 ms)
Process, Priority, , R  									; Real-time process priority (default is N for Normal; H for High in old PKL; R for Realtime is max)
SetWorkingDir,  %A_ScriptDir%   							; Should "ensure consistency" 	; eD WIP: A separate user working dir, so user settings can be kept elsewhere?
StringCaseSense, On 										; All string comparisons are case sensitive (AHK default is Off) 	; eD WIP: InStr() still starts caseless?!

setPklInfo( "pklName", "EPiKaL Portable Keyboard Layout" )  				; EPKL Name
setPklInfo( "pklVers", "1.4.2" )        									; EPKL Version
setPklInfo( "pklHome", "https://github.com/DreymaR/BigBagKbdTrixPKL" )  	; EPKL URL
setPklInfo( "pklHdrA", ";`r`n;;  " )    									; A header used when generating EPKL files  	; eD WIP: Make an Import Module
setPklInfo( "pklHdrB", "`r`n"
		. ";;  for EPiKaL Portable Keyboard Layout (EPKL) by Øystein ""DreymaR"" Bech-Aase (2015-), based on PKL by Máté Farkas (2008-2010).`r`n"
		. ";`r`n" )

setPklInfo( "initStart", A_TickCount )  					; eD DEBUG: Time EPKL startup
;;  Global variables are now largely replaced by the get/set info framework, and initialized in the init fns
;global UIsel   											; Variable for UI selection (use Control names to see which one) 	; NOTE: Can't use an object variable for UI (yet)
Gosub setUIGlobals  										; Set the globals needed for the settings UI (is this necessary?)
initPklIni( A_Args[1] ) 									; Read settings from pkl.ini (now PklSet and PklLay). Get layout from command line parameter (legacy %1%), if any.
initLayIni()    											; Read settings from Layout.ini and layout part files
activatePKL()
;pklDebug( "Time since init start: " . A_TickCount - getPklInfo( "initStart" ) . " ms", 1 ) 	; eD DEBUG
Return  													; <--«  main code

;;  ########################    includes    ########################

#Include pkl_init.ahk           	; Program/layout initalisation
#Include pkl_ahk_v1.ahk         	; Labels and suchlike are kept in a separate file pending an upgrade to AHK v2
#Include pkl_gui_image.ahk      	; GUI: On-screen help images
#Include pkl_gui_menu.ahk       	; GUI: Tray menu and About dialog
#Include pkl_gui_settings.ahk   	; GUI: Layout/Settings panel
#Include pkl_keypress.ahk       	; Handle key presses
#Include pkl_deadkey.ahk        	; Handle dead key presses
#Include pkl_send.ahk           	; Send output
#Include pkl_utility.ahk        	; Various functions such as pkl_activity.ahk were merged into this file
#Include pkl_get_set.ahk        	; Get and set global settings
#Include pkl_ini_read.ahk       	; Read from .ini data files
#Include pkl_import.ahk         	; Module: Import, converting MSKLC layouts to EPKL format, and other import/conversion
#Include pkl_make_img.ahk       	; Module: Help image generator, calling Inkscape with an SVG template

;;  ########################    functions   ########################

;;  Functions and subroutines are defined in the included files.
