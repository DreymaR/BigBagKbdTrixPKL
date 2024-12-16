DreymaR's Big Bag Of Keyboard Tricks - EPKL
===========================================
<br>

EXTRAS, EXTRAS – READ ALL ABOUT IT!
-----------------------------------
This folder isn't so interesting for most, but you never know...  `￣(=⌒ᆺ⌒=)￣`

It contains some AHK scripts that I found useful, and other source-related stuff that didn't fit elsewhere.

Also, below are some tidbits of information that I've decided to keep around in this corner of the repo.
<br>

INFO: Some documentation notes
------------------------------
* Virtual key code links:
    http://www.kbdedit.com/manual/low_level_vk_list.html
    https://msdn.microsoft.com/en-us/library/ms927178.aspx
    https://msdn.microsoft.com/en-us/library/windows/desktop/dd375731(v=vs.85).aspx
  
* Unicode/icon search links:
    https://www.compart.com/en/unicode/
    https://www.amp-what.com/unicode/search/
  
* "Anti-madness tips" for EPKL vs old PKL (by user Eraicos and me):
    - PKL using AHK v1.0: Script files need to be ANSI encoded. They don't support special letters well.
        - EPKL using AHK v1.1-Unicode: Supports scripts in UTF-8 w/ BOM.
    - EPKL .ini files may be UTF-8 encoded, with or without BOM. Source .ahk files should be UTF-8-BOM?
        - PKL: Don't use end-of-line comments in the .ini files. OK in Layout.ini because of tab parsing.
        - EPKL: End-of-line comments are now safe.
    - In Layout.ini, for old PKL:
        - Always use single tabs as separators in Layout.ini, also between a VK code and the word 'VirtualKey'.
        - The CapsLock key should have scan code 'CapsLock' instead of SC03A, if using 'extend_key = CapsLock'.
        - The Extend key should be mapped or it won't work, e.g., 'CapsLock = CAPITAL	VirtualKey'.
        - EPKL changes all of the above: Any whitespace delimits, and Extend is mapped as 'Extend Modifier'.
    - In the Extend section:
        - Don't have empty mappings in the Extend section. Comment these out.
        - By default {} is added to send keys by name. To escape these, use a prefix-entry or }‹any string›{.
<br>

**AHK key remapping syntax**
AHK direct key mapping works with games, unlike the PKL way of using the Send command to send (KeyDown followed by a KeyUp)

The classic remapping of the form `a::b` actually consists of:
```
*a::
SetKeyDelay -1
Send {Blind}{b DownR}
Return

*a up::
SetKeyDelay -1
Send {Blind}{b Up}
Return
```

The `DownR` format replaced `DownTemp` with AHK v1.1.27. It tells other Send command to ignore this key's down state.
<br>

**AHK hotstrings**
AHK can also use hotstrings, replacing any string with another automagically. I haven't gotten that to work in EPKL yet.
```
;;  eD TOFIX: Can't define hotkeys/-strings before the rest of the code, as it prevents EPKL from working! Where, then?
; :*:'3o::https://www.colemak.org 	; eD WIP: Hotstring (replace text with other)
; #c::MsgBox % "EPKL hotkey test:`n'" . A_ThisHotkey . "'"
```
<br>

**Entry format info from Farkas' sample.ini layout file:** (Note that EPKL now uses '@' for 'dk' entries etc)
```
Scan code =
	Virtual key code (like in MS KLC)
	CapsState (like in MS KLC):
		If CapsState == vk or VirtualKey
			When you press this key, it sends only the virtual key.
			It is very useful, if you install your special layout, and you 
			would like to extend it. (See extend_* layouts)
		Else If CapsState == modifier
			You can use this key as a modifier, like Shift, RAlt (== AltGr)
		Else If CapsState & 1 (first bit set)
			Shift + Key == CapsLock + Key
		Else If CapsState & 4 (third bit set)
			AltGr + Shift + Key == CapsLock + AltGr + Key
	Output for each shift state (see http://www.autohotkey.com/docs/commands/Send.htm):
		#       send utf-8 characters (one or more)
		*####   send without {Text} – that is, interpret key names (and ^+1#{} ?) in AHK style
		=####   send {Blind} – that is, keep the modifier state intact
		%####   utf ligature
		--      disabled key/state entry
		dk##    deadkey (EPKL: @## is used instead, w/ ## from a DeadKeyNames section)
		&###    EPKL: PowerString name (named strings that are sent by the chosen method)
NOTE: Use tabs as separator for these entries!!!

;scan = VK	CapStat	0Norm	1Sh	2Ctrl	6AGr	7AGrSh	Caps	CapsSh
SC002 = 1	1	1	!			; QWERTY 1!
SC003 = 2	0	2	={Left}		; QWERTY 2@
SC004 = 3	0	3	*{Right}	; QWERTY 3#
SC005 = rshift	modifier		; QWERTY 4$
SC006 = 5	0	dk1	dk2			; QWERTY 5% (EPKL: DKs are named for instance @0b4 or @060)

[deadkey1]
; 0 = unicode number of the "accent"
0    =  126	; ~
; [Unicode number of the base letter] = [Unicode number of the new letter] ‹tab› ; comments
97   =  227	; a -> ã
```
