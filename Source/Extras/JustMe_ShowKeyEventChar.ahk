;;  - Use a ToUnicodeEx DLL call to determine the actual character output from the OS keyboard layout.
;;  - Show the result as a ToolTip, with the event's VK and SC codes and other info as desired.
;;  - Taken from https://www.autohotkey.com/boards/viewtopic.php?t=1040
;

#SingleInstance Force
#Persistent
#NoEnv
Process, Priority, , High
SetBatchLines, -1

hDriver := DllCall( "GetModuleHandle", "uint", 0 )  	; can be the good solution if dead key header and other...
;;  KbdLayerDescriptor() GetKeyboardLayoutName()
;;  HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Keyboard Layouts\%KeyboardLayoutName%
hKbdHook := DllCall( "SetWindowsHookEx", "int", 0x0D, "uint", RegisterCallback("LowLevelKeyboardProc"), "uint", hDriver, "uint", 0 )
OnExit, UnhookKeyboardAndExit
Return

;;  if ( A_CaretX=0 && A_CaretY=0 ) ; I don't want a Keylogger , but a CharLogger, I want real hotstring comparison, not multisequencedHotKey
;;  but disrupt menu key ( alt, F10 )
;;  It's useful to call GetKeyBoardLayout often since it may change (Alt+Shift language change etc)
LowLevelKeyboardProc(nCode, wParam, lParam) {
	;;  The lParam is a KBDLLHOOKSTRUCT (https://learn.microsoft.com/en-us/windows/win32/api/winuser/ns-winuser-kbdllhookstruct): VK;SC;flags/time.
	;
	VK      := NumGet(lParam+0)
	SC      := NumGet(lParam+4)
	flag    := NumGet(lParam+8)
	keyUp   := ( flag & 0x80 ) ? true : false   										; Was the event a KeyUp  (or KeyDown)?
	isInj   := ( flag & 0x20 ) ? true : false   										; Was the event injected (or physical)?
	fStr    := ( keyUp ) ? " Up"  : " Down"
	fStr    .= ( flag & 0x01 ) ? " Ext" : "" , fStr .= ( isInj ) ? " Inj" : "" , fStr .= ( flag & 0x20 ) ? " Alt" : ""
	log := "" ; "lParam " Format( "{:X}", lParam ) "`n" ; "code " nCode " | event " wParam "`n"
	log .= "VK " VK "`n"
	log .= "SC " SC fStr
	if !( isInj ) { 																	; Only physical input (Injected flag is zero)
		theChar := ToUnicodeEx( VK, SC )
		if ( ( theChar ) && !( keyUp ) ) {  											; If there is a char and it's a KeyDown event...
			log .= "`nChar [" theChar "]"   											; ...log it.
			Tooltip % log
		}
	} 	; end if physical input
	
	Return DllCall("CallNextHookEx", "uint", hKbdHook, "int", nCode, "uint", wParam, "uint", lParam)
}

;;  Need to intercept translate (WM_KEYDOWN TO WM_CHAR) because ToUnicodeEx creates a translation: Dead key are double ^ -> ^^
;;  (DllCall("MapVirtualKey", "uint", VK, "uint", 2)>0) prevents it with its deadkey detection, but creates another problem ê -> e.
;;  ...but theChar "are good and depend where MapVirtualKey are in the code... or use sendU with {BS} ><" (?)
ToUnicodeEx( VK, SC ) { 																; Call the OS layout to translate VK/SC to a character, if possible
	TID := DllCall( "GetWindowThreadProcessId", "Int", WinExist("A"), "Int", 0 ) 		; TID: Window  Thread Process ID
	ID0 := DllCall( "GetCurrentThreadId", "UInt", 0 )   								; TI0: Current Thread Process ID
	DllCall( "AttachThreadInput", "UInt", ID0, "UInt", TID, "Int", 1 ) 					; Attach TID input to the TI0 process. Needed to detect AltGr etc.
	HKL := DllCall( "GetKeyboardLayout", "Int", TID )   								; Refresh GetKeyboardLayout
	VarSetCapacity( KeyState, 256 )
	DllCall( "GetKeyboardState", "uint", &KeyState ) 									; Get Keyboard State -> &KeyState (256 bytes)
;	DllCall( "AttachThreadInput", "UInt", ID0, "UInt", TID, "Int", 0 )
	VarSetCapacity( theChar, 32 )   													; The result may be a buffer with several chars (if so, these are not good here)
	DK  := DllCall( "ToUnicodeEx", "UInt", VK, "UInt", SC, "UInt", &KeyState, "Str", theChar, "UInt", 64, "UInt", 1, "UInt", HKL)
	Map := DllCall( "MapVirtualKey", "uint", VK, "uint", 2 ) 							; MapVirtualKey translates/maps VK into SC (0) or char (2), or SC to VK (1/3)
	if ( DK == 1 ) && ( Map > 0 )   													; Is it the same as AHK's GetKeyName() fn, for this purpose? Used here to detect DKs.
		Return theChar  																; DK: -1 for DeadKey, 0 for none, 1 for a char, 2+ for several
}

esc::
UnhookKeyboardAndExit:
DllCall("UnhookWindowsHookEx", "uint", hKbdHook)
ExitApp
