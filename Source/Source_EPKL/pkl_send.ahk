pkl_Send( ch, modif = "" )		; Process a single char/str with mods for send, w/ OS DK & special char handling
{
	if pkl_CheckForDKs( ch )
		Return
	
	if ( 32 < ch ) {			;&& ch < 128 (using pre-Unicode AHK)
		char := "{" . Chr(ch) . "}"
		if ( inStr( getDeadKeysInCurrentLayout(), Chr(ch) ) )
			char .= "{Space}"
	} else if ( ch == 32 ) {
		char = {Space}
	} else if ( ch == 9 ) {
		char = {Tab}
	} else if ( ch > 0 && ch <= 26 ) {
		; http://en.wikipedia.org/wiki/Control_character#How_control_characters_map_to_keyboards
		char := "^" . Chr( ch + 64 )	; Send Ctrl char
	} else if ( ch == 27 ) {
		char = ^{VKDB}	; Ctrl + [ (OEM_4) alias Escape				; eD TODO: Is this robust with ANSI/ISO VK?
	} else if ( ch == 28 ) {
		char = ^{VKDC}	; Ctrl + \ (OEM_5) alias File Separator(?)
	} else if ( ch == 29 ) {
		char = ^{VKDD}	; Ctrl + ] (OEM_6) alias Group Separator(?)
;	} else {			; Unicode character
;		sendU(ch)
;		Return
	}
	pkl_SendThis( modif, char )
}

pkl_SendThis( modif, toSend )	; Actually send a char/string, processing Alt/AltGr states
{
	toggleAltGr := getAltGrState()
	if ( toggleAltGr )
		setAltGrState( 0 )		; Release LCtrl+RAlt temporarily if applicable
	; Alt + F to File menu doesn't work without Blind if the Alt button is pressed:
	prefix := ( inStr( modif, "!" ) && getKeyState("Alt") ) ? "{Blind}" : ""
	Send %prefix%%modif%%toSend%
	if ( toggleAltGr )
		setAltGrState( 1 )
}

pkl_CheckForDKs( ch )
{
	static SpaceWasSentForSystemDKs = 0
	
	if ( getKeyInfo( "CurrNumOfDKs" ) == 0 ) {		; No active DKs
		SpaceWasSentForSystemDKs = 0
		Return false
	} else { 	; eD TOFIX: Why doesn't a Space key press get sent here? Because the ={Space} gets sent to pklParseSend()!
		setKeyInfo( "CurrBaseKey_", ch )			; DK(s) active, so record the pressed key as Base key
		if ( SpaceWasSentForSystemDKs == 0 )		; If there is an OS dead key that needs a Spc sent, do it
			Send {Space}
		SpaceWasSentForSystemDKs = 1
		Return true
	}
}

pkl_ParseSend( entry, mode = "Input" )							; Parse/Send Keypress/Extend/DKs/Strings w/ prefix
{
;	static parse := { "%" : "{Raw}" , "=" : "{Blind}" , "*" : "" }
	prf := SubStr( entry, 1, 1 )
	if ( not InStr( "%$*=@&", prf ) )
		Return false											; Not a recognized prefix-entry form
	sendPref := -1
	ent := SubStr( entry, 2 )
	if        ( prf == "%" ) {									; Literal/string by SendInput {Raw}
		SendInput %   "{Raw}" . ent
	} else if ( prf == "$" ) {									; Literal/string by SendMessage
		pkl_SendMessage( ent )
	} else if ( ent == "{CapsLock}" ) {							; CapsLock toggle
		togCap := ( getKeyState("CapsLock", "T") ) ? "Off" : "On"
		SetCapsLockState % togCap
	} else if ( prf == "*" ) {									; * : Omit {Raw} etc; use special !+^#{} AHK syntax
		sendPref := ""
	} else if ( prf == "=" ) {									; = : Send {Blind} - as above w/ current mod state
		sendPref := "{Blind}"
	} else if ( prf == "@" ) {									; Named dead key (may vary between layouts!)
		pkl_DeadKey( ent )
	} else if ( prf == "&" ) {									; Named literal/powerstring (may vary between layouts!)
		pkl_PwrString( ent )
	}
	if ( sendPref != -1 ) {
		if ( mode == "SendThis" && ent ) { 						; eD WIP: Used pkl_SendThis(), now pkl_Send()
			pkl_Send( "", sendPref . ent ) 						; Used by _keyPressed()
		} else {
			SendInput %       sendPref . ent
		}
	}
	Return % prf												; Return the recognized prefix
}

pkl_SendMessage( string )										; Send a string robustly by char messages, so that mods don't get stuck etc
{																; SendInput/PostMessage don't wait for the send to finish; SendMessage does
	Critical													; Source: https://autohotkey.com/boards/viewtopic.php?f=5&t=36973
	WinGet, hWnd, ID, A 										; Note: Seems to be faster than SendInput for long strings only?
	ControlGetFocus, vClsN, ahk_id%hWnd% 	; "If this line doesn't work, try omitting vCtlClsN to send directly to the window"
	Loop, Parse, string
		SendMessage, 0x102, % Ord( A_LoopField ), 1, %vClsN%, ahk_id%hWnd%	; 0x100 = WM_CHAR sends a character input message
}

pkl_SendClipboard( string ) 									; Send a string quickly via the Clipboard (may fail if the clipboard is big)
{
	Critical
	clipSaved := ClipboardAll									; Save the entire contents of the clipboard to a variable
;	Clipboard := Clipboard										; Cast the clipboard content as text (use expression to avoid trimming)
	Clipboard := string
	ClipWait 1													; Wait some seconds for the clipboard to contain text
	if ( ErrorLevel ) {
		Content := ( Clipboard ) ? Clipboard : "<empty>"
		pklDebug( "Clipboard not ready! Content:`n" . Content )
	}
	Send ^v 													; Wait 50-250 ms(?) after pasting before changing clipboard.
	Sleep 250													; See https://autohotkey.com/board/topic/10412-paste-plain-text-and-copycut/
	Clipboard := clipSaved
	VarSetCapacity( clipSaved, 0 )								; Could probably just use := "" here, especially for large contents.
}

_strSendMode( string, strMode )
{
	if ( not string )
		Return true
	if        ( strMode == "Input"     ) {				; Send by the standard SendInput {Raw} method
		SendInput {Raw}%string%							; - May take time, and any modifiers released meanwhile will get stuck!
	} else if ( strMode == "Message"   ) {				; Send by SendMessage WM_CHAR system calls
		pkl_SendMessage( string )						; - Robust as it waits for sending to finish, but a little slow.
	} else if ( strMode == "Paste" ) {					; Send by pasting from the Clipboard, preserving its content.
		pkl_SendClipboard( string )						; - Quick, but may fail if the timing is off. Best for non-parsed send.
	} else {
		pklWarning( "Send mode '" . strMode . "' unknown.`nString '" . string . "' not sent." )
		Return false
	}	; end if strMode
	Return true
}

pkl_PwrString( strName )											; Send named literal/ligature/powerstring from a file
{
	Critical
	strFile := getLayInfo( "strFile" )							; The file containing named string tables
	strMode := pklIniRead( "strMode", "Message", strFile )		; Mode for sending strings: "Input", "Message", "Paste"
	brkMode := pklIniRead( "brkMode", "+Enter" , strFile )		; Mode for handling line breaks: "+Enter", "n", "rn"
	theString := pklIniRead( strName, , strFile, "strings" )	; Read the named string's entry (w/ comment stripping)
	if ( pkl_ParseSend( theString ) ) 							; Unified prefix-entry syntax; only for single line entries
		Return
	if ( SubStr( theString, 1, 11 ) == "<Multiline>" ) {		; Multiline string entry
		Loop % SubStr( theString, 13 ) {
			IniRead, val, %strFile%, strings, % strName . "-" . Format( "{:02}", A_Index )
			mltString .= val									; IniRead is a bit faster than pklIniRead() (1-2 s on a 34 line str)
		}
		theString := mltString
	}
	theString := strEsc( theString )							; Replace \# escapes
	if ( brkMode == "+Enter" ) {
		Loop, Parse, theString, `n, `r							; Parse by lines, sending Enter key presses between them
		{														; - This is more robust since apps use different breaks
			if ( A_Index > 1 )
				SendInput +{Enter}								; Send Shift+Enter, which should be robust for msg boards.
;				WinGet, hWnd, ID, A 							; eD TRY: Use SendMessage to send Enter then wait for it to happen.
;				ControlGetFocus, vClsN, ahk_id%hWnd%
;				SendMessage, 0x100, 0x0D, 0, %vClsN%, ahk_id%hWnd%	; 0x100 = WM_KEYDOWN. Sends a Windows key input message.
;				SendMessage, 0x101, 0x0D, 0, %vClsN%, ahk_id%hWnd%	; 0x100 = WM_KEYUP, 0x0D = VK_RETURN = {Enter}.
;				ControlSend, %vClsN%, +{Enter}					; Try ControlSend instead.
;				Control, EditPaste, +{Enter}, %vClsN%			; Try Control, EditPaste instead.
				Sleep 50										; Wait so the Enter gets time to work. Need ~50 ms?
			if ( not _strSendMode( A_LoopField , strMode ) )	; Try to send by the chosen method
				Break
		}	; end Loop Parse
	} else {													; Send string as a single block with line break characters
		StrReplace( theString, "`r`n", "`n" )					; Ensure that any existing `r`n are kept as single line breaks
		if ( brkMode == "rn" )
			StrReplace( theString, "`n", "`r`n" )
		_strSendMode( theString , strMode ) 					; Try to send by the chosen method
	}	; end if brkMode
;	Send {LShift Up}{LCtrl Up}{LAlt Up}{LWin Up}{RShift Up}{RCtrl Up}{RAlt Up}{RWin Up}	; Remove mods to clean up?
}
