pkl_Send( ch, modif = "" ) 				; Process a single char/str with mods for send, w/ OS DK & special char handling
{
	if pkl_CheckForDKs( ch )
		Return
	
	blind   := false 					; Send {Blind}?
	char    := Chr(ch)
	if ( ch > 32 ) { 					; ch > 128 works with Unicode AHK
		this    := AltGrIsPressed() ? "{Text}" . char 	; Send as Text for AltGr layers. Doesn't work with the Win key.
		                            : "{" . char . "}" 	; Normal char
	if InStr( getCurrentWinLayDeadKeys(), char )
		this    .= "{Space}" 			; Send an extra space to release OS dead keys
	} else if ( ch == 32 ) {
		blind   := true
		this    := "{Space}"
	} else if ( ch == 9 ) {
		this    := "{Tab}"
	} else if ( ch > 0 && ch <= 26 ) {
		; http://en.wikipedia.org/wiki/Control_character#How_control_characters_map_to_keyboards
		this    := "^" . Chr( ch + 64 )	; Send Ctrl char
	} else if ( ch == 27 ) {
		this    := "^{VKDB}" 			; Ctrl + [ (OEM_4) alias Escape				; eD TODO: Is this robust with ANSI/ISO VK?
	} else if ( ch == 28 ) {
		this    := "^{VKDC}" 			; Ctrl + \ (OEM_5) alias File Separator(?)
	} else if ( ch == 29 ) {
		this    := "^{VKDD}" 			; Ctrl + ] (OEM_6) alias Group Separator(?)
	}
	blind   := ( InStr( modif, "!" ) && getKeyState("Alt") ) ? true : blind 	; Send Blind for Alt key presses
	prefix  := ( blind ) ? "{Blind}" : ""
;	( prefix != "" ) ? pklDebug( "`nPrefix: '" . prefix . "'`nThis: '" . this . "'", .6 )  ; eD DEBUG
	Send %prefix%%modif%%this% 			; pkl_SendThis( modif, this ) 	; Modif is only used for explicit mod mappings. 	; eD WIP: This is what leads to sending of unnecessary modifiers?! It's Send itself that does it.
}

pkl_SendThis( modif, this ) 			; Actually send a char/string
{
;	toggleAltGr := ( getAltGrState() ) ? true : false 	; eD WIP:  && SubStr( A_ThisHotkey , -3 ) != " Up"  	; eD WIP: Test EPKL without this
;	if ( toggleAltGr ) 	; eD WIP: Is this ever active?!? Does it just lead to a lot of unneccesary sends?
;		setAltGrState( 0 )		; Release LCtrl+RAlt temporarily if applicable
	; Alt + F to File menu doesn't work without Blind if the Alt button is pressed. Also, Space entries need to be sent {Blind}
	prefix := ( InStr( modif, "!" ) && getKeyState("Alt") ) ? "{Blind}" : ""
;	prefix := ( this == "{Space}" ) ? "{Blind}" : prefix 		; eD WIP: Allow Shift+Spc to work - messes with Shift?!
	Send %prefix%%modif%%this%
;	if ( toggleAltGr )
;		setAltGrState( 1 )
}

pkl_CheckForDKs( ch )
{
	static SpaceWasSentForSystemDKs = 0
	
	if ( getKeyInfo( "CurrNumOfDKs" ) == 0 ) {		; No active DKs
		SpaceWasSentForSystemDKs = 0
		Return false
	} else {
		setKeyInfo( "CurrBaseKey_", ch )			; DK(s) active, so record the pressed key as Base key
		if ( SpaceWasSentForSystemDKs == 0 )		; If there is an OS dead key that needs a Spc sent, do it
			Send {Space}
		SpaceWasSentForSystemDKs = 1
		Return true
	}
}

pkl_ParseSend( entry, mode = "Input" )							; Parse/Send Keypress/Extend/DKs/Strings w/ prefix
{
	psp     := SubStr( entry, 1, 1 ) 							; Look for a Parse syntax prefix
	if not InStr( "%→$§*α=β~«@Ð&¶", psp ) 						; eD WIP: Could use pos := InStr( etc, then if pos ==  1 etc – faster? But it's far less clear to read here
		Return false
	sendIt  := ( mode == "ParseOnly" ) ? false : true 			; Parse Only mode returns prefixes without sending
	pfix    := -1 												; Prefix for the Send commands, such as {Blind}
	enty    := SubStr( entry, 2 )
	if        ( psp == "%" || psp == "→" ) { 					; %→ : Literal/string by SendInput {Raw}
		mode    := "Input"
		pfix    := "{Raw}"
	} else if ( psp == "$" || psp == "§" ) { 					; $§ : Literal/string by EPKL SendMessage
		mode    := "SendMess"
		pfix    := ""
	} else if ( enty == "{CapsLock}" ) {						; CapsLock toggle. Stops further entries from misusing Caps?
		togCap  := getKeyState("CapsLock", "T") ? "Off" : "On"
		SetCapsLockState % togCap
	} else if ( psp == "*" || psp == "α" ) { 					; *α : AHK special !+^#{} syntax, omitting {Raw}
		pfix    := ""
	} else if ( psp == "=" || psp == "β" ) { 					; =β : Send {Blind} - as above w/ current mod state
		pfix    := "{Blind}"
	} else if ( psp == "~" || psp == "«" ) { 					; ~« : Hex Unicode point U+####
		pfix    := ""
		enty    := "{U+" . enty . "}"
	} else if ( psp == "@" || psp == "Ð" ) { 					; @Ð : Named dead key (may vary between layouts!)
		mode    := "DeadKey"
		pfix    := ""
	} else if ( psp == "&" || psp == "¶" ) { 					; &¶ : Named literal/powerstring (may vary between layouts!)
		mode    := "PwrString"
		pfix    := ""
	}
	if ( sendIt && pfix != -1 ) { 								; Send if recognized and not ParseOnly
		if ( enty && mode == "SendThis" ) { 
			pkl_Send( "", pfix . enty ) 						; Used by _keyPressed()
		} else if ( mode == "SendMess"  ) {
			pkl_SendMessage( enty )
		} else if ( mode == "DeadKey"   ) {
			pkl_DeadKey( enty )
		} else if ( mode == "PwrString" ) {
			pkl_PwrString( enty )
		} else {
			SendInput % pfix . enty
		}
	}
	Return % psp												; Return the recognized prefix
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
	if        ( strMode == "Input"     ) { 				; Send by the standard SendInput {Raw} method
		SendInput {Raw}%string% 						; - May take time, and any modifiers released meanwhile will get stuck!
	} else if ( strMode == "Text"      ) { 				; Send by the SendInput {Text} method (AHK v1.1.27+)
		SendInput {Text}%string% 						; - More reliable? Only backtick characters are translated.
	} else if ( strMode == "Message"   ) { 				; Send by SendMessage WM_CHAR system calls
		pkl_SendMessage( string ) 						; - Robust as it waits for sending to finish, but a little slow.
	} else if ( strMode == "Paste" ) { 					; Send by pasting from the Clipboard, preserving its content.
		pkl_SendClipboard( string ) 					; - Quick, but may fail if the timing is off. Best for non-parsed send.
	} else {
		pklWarning( "Send mode '" . strMode . "' unknown.`nString '" . string . "' not sent." )
		Return false
	}	; end if strMode
	Return true
}

pkl_PwrString( strName )											; Send named literal/ligature/powerstring from a file
{
	static strFile := -1
	static strMode
	static brkMode
	
	Critical
	if ( StrFile == -1 ) {
		strFile := getLayInfo( "strFile" )						; The file containing named string tables
		strMode := pklIniRead( "strMode", "Message", strFile )	; Mode for sending strings: "Input", "Message", "Paste"
		brkMode := pklIniRead( "brkMode", "+Enter" , strFile )	; Mode for handling line breaks: "+Enter", "n", "rn"
	}
	
	theString := pklIniRead( strName, , strFile, "strings" )	; Read the named string's entry (w/ comment stripping)
	if pkl_ParseSend( theString ) 								; Unified prefix-entry syntax; only for single line entries
		Return
	if ( SubStr( theString, 1, 11 ) == "<Multiline>" ) {		; Multiline string entry
		Loop % SubStr( theString, 13 ) {
			IniRead, val, %strFile%, strings, % strName . "-" . Format( "{:02}", A_Index )
			mltString .= val									; IniRead is a bit faster than pklIniRead() (1-2 s on a 34 line str)
		}
		theString := mltString
	}
	theString := strEsc( theString )							; Replace \# escapes
	if ( strMode == "Text" ) {
		SendInput {Text}%theString%
	} else if ( brkMode == "+Enter" ) {
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
}
