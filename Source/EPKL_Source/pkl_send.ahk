﻿;;  ================================================================================================================================================
;;  EPKL Send functions
;;  - Parse and send key presses and strings
;

pkl_Send( ch, modif := "" ) {   								; Process a single char/str with mods for send, w/ OS DK & special char handling
	If pkl_CheckForDKs( ch ) {  								; Check for OS dead keys that require sending a space. Also, somehow necessary for DK sequencing.
		Return
	}
	char    := Chr(ch)
	If ( ch > 32 ) { 											; ch > 128 works with Unicode AHK
		this    := "{" . char . "}" 							; Normal char
	If InStr( getCurrentWinLayDeadKeys(), char ) 	; eD WIP: Improve this with real DK detection?! How does that work, really? A char may be both a DK release and not...!
		this    .= "{Space}" 									; Send an extra space to release OS dead keys
	} else if ( ch == 32 ) {
		this    := "{Space}"
		modif   := "{Blind}" 									; Space needs to be sent blind for Shift+Space to scroll up in browsers, etc.
	} else if ( ch == 9 ) {
		this    := "{Tab}"
	} else if ( ch > 0 && ch <= 26 ) {
		; http://en.wikipedia.org/wiki/Control_character#How_control_characters_map_to_keyboards
		this    := "^" . Chr( ch + 64 ) 						; Send Ctrl char
	} else if ( ch == 27 ) {
		this    := "^{VKDB}" 					; Ctrl + [ (OEM_4) alias Escape 	; eD TODO: Is this robust with ANSI/ISO VK?
	} else if ( ch == 28 ) {
		this    := "^{VKDC}" 					; Ctrl + \ (OEM_5) alias File Separator(?)
	} else if ( ch == 29 ) {
		this    := "^{VKDD}" 					; Ctrl + ] (OEM_6) alias Group Separator(?)
	}
	If AltGrIsPressed()
		this    := "{Text}" . char  							; Send as Text for AltGr layers to avoid a stuck LCtrl. Doesn't work with the Win key.
	pkl_SendThis( this, modif ) 								; Modif is only used for explicit mod mappings.
}

pkl_SendThis( this, modif := "" ) {     						; Actually send a char/string. Also log the last sent character for Compose.
	tht := RegExReplace( this, "\{Space\}|\{Blind\}" )  		; Strip off any spaces sent to release OS deadkeys, and other such stuff
	If        ( this == "{Space}" ) {   						; Replace space so it's recognizeable for LastKeys
		tht := "{ }"
	} else if ( RegExMatch( this, "P)\{Text\}|\{Raw\}", len ) == 1 ) {
		tht := "{" . SubStr( this, len+1 ) . "}"
	}
	thtLen  := StrLen( tht )
	If ( thtLen == 3 )  										; Single-char keys are on the form "{¤}"
		lastKeys( "push", SubStr( tht, 2, 1 ) )
;	If ( SubStr( tht, 0 ) == "}" ) { 							; Is this test ever necessary, or is everything on {] form?
;		tht := SubStr( tht, 1, -1 ) . " DownR}" 				; eD WIP: Send characters too with DownR !? Nope, the KeyUp is still sent. Why?
;		pklToolTip( "tht: " . tht ) 	; eD DEBUG
;	} 	; eD WIP: Send w/ Down?
;	toggleAltGr := ( getAltGrState() ) ? true : false 	; && SubStr( A_ThisHotkey , -3 ) != " Up"  	; eD WIP: Test EPKL without this
;	If ( toggleAltGr ) 	; eD WIP: Is this ever active?!? Does it just lead to a lot of unneccesary sends?
;		setAltGrState( 0 )  									; Release LCtrl+RAlt temporarily if applicable
	Send %modif%%this%  						; eD WIP: This Send is what leads to unnecessary/stuck modifiers with AltGr! Workaround: Send AltGr presses as Text.
;	If ( toggleAltGr )
;		setAltGrState( 1 )
}

pkl_Composer( compKey := "" ) { 								; A post-hoc Compose method: Press a key mapped with ©###, and the preceding sequence will be composed
	compKeys    := getLayInfo( "composeKeys" )  				; Array of the compose tables for each ©-key in use
	tables      := compKeys[ compKey ]  						; Array of the compose tables in use for this compKey
	If ( tables[1] == "" ) { 									; Is this ©-key empty?
		pklWarning( "An empty/undefined Compose key was pressed:`n`n©" . compKey )
		Return
	}
	lastKeys    := getKeyInfo( "LastKeys" ) 					; Example: ["¤","¤","¤","¤"]
	seqLengths  := getLayInfo( "composeLength" ) 				; Example: [ 4,3,2,1 ]
	compTables  := getLayInfo( "composeTables" ) 				; Associative array of whether to send Backspaces or not for any given table
	CoDeKeys    := getLayInfo( "CoDeKeys" ) 					; Array of which Compose keys are advanced CoDeKeys as well
	key     := ""
	For ix, chr in lastKeys {   								; Build a n-char key from LastKeys to match the Compose table
;		ch  := SubStr( chr, 2, 1 )
		chs .= chr
		kys .= "_U" . formatUnicode( chr )  					; Format n single-char keys as a n×[_U####] hex string (4+ digits).
;		debug   .= " , " . chr
	}   ; <-- for chr in lastKeys
	uni := false
	If ( SubStr( chs, -5, 1 ) == "U" ) { 						; U####[#] where # are hex digits composes to the corresponding Uniocde point
		uni := 5
	} else if ( SubStr( chs, -4, 1 ) == "U" ) {
		uni := 4
	}
	If ( uni ) {
		chs := SubStr( chs, 1 - uni )
		If isHex( chs ) {
			chr := chr( "0x" . chs )
			uni += 1
			SendInput {Backspace %uni%}
			SendInput {Text}%chr%
			lastKeys( "push", chr )
			Return
		}
	}
	For ix, len in seqLengths { 								; Normally we compose up to 4+ characters, in a specified priority - usually longer first
		For ix, sct in tables {
			keyArr  := getLayInfo( "comps_" . sct . len )   	; Key arrays are marked both by ©-key names and lengths
			key     := SubStr( kys
				, 1 + InStr( kys, "_", , 0, len ) ) 			; The rightmost len chars of kys
			If ( keyArr.HasKey(key) ) {
				val := keyArr[key]
				bsp := len * compTables[ sct ]  				; The first char of the entry is whether to send Backs (eating patterns)
				SendInput {Backspace %bsp%} 					; Send Back according to key length. Undo won't work as it may remove several characters per press.
				ent := val
				If not pkl_ParseSend( ent ) { 					; Unified prefix-entry syntax
					ent := strEsc( ent ) 						; Escape special chars with backslashes (not necessary for a single \ )
					SendInput {Text}%ent% 						; Send the entry as {Text} by default
				}
				If ( StrLen( ent ) == 1 ) {
					lastKeys( "push", ent ) 					; Push single-char Compose releases to the queue for further composing
				} else {
				lastKeys( "null" )  							; Reset the last-keys-pressed buffer 	; eD WIP: If the output is single-char, push it instead!
				}
				Return  										; If a longer match is found, don't look for shorter ones
			}   ; <-- if keyArr
		}   ; <-- for sections
	}   ; <-- for seqLengths
	If inArray( CoDeKeys, compKey ) { 							; If this Compose key is a CoDeKey...
		pkl_DeadKey( "co0" )    								; ...use it whenever a sequence isn't recognized.
	}
;		( len == 2 && sct == "x11" ) ? pklDebug( "LastKeys: " . debug . "`nkys: " . kys . "`nlen: '" . len . "`n`nval: '" . val, 3 )  ; eD DEBUG
}

pkl_CheckForDKs( ch ) {
	static SpaceWasSentForSystemDKs := false
	
	If ( getKeyInfo( "CurrNumOfDKs" ) == 0 ) {  				; No active DKs 	; eD WIP: Hang on... Are we talking about system or EPKL DKs here?!?
		SpaceWasSentForSystemDKs := false   					; eD WIP: Because "CurrNumOfDKs" is for EPKL DKs, but this is for OS DKs?!?
	} else {
		setKeyInfo( "CurrBaseKey" , ch ) 						; DK(s) active, so record the pressed key as Base key
		If ( not SpaceWasSentForSystemDKs ) 					; If there is an OS dead key that needs a Spc sent, do it
			Send {Space}
		SpaceWasSentForSystemDKs := true
	}
	Return SpaceWasSentForSystemDKs
}

pkl_ParseSend( entry, mode := "Input" ) {   					; Parse & Send Keypress/Extend/DKs/Strings w/ prefix
;	Critical    												; eD WIP: Causes hangs after DKs etc?
	higMode := ( mode == "HIG" ) ? true : false 				; "HIG" Parse Only mode returns prefixes without sending
	psp     := SubStr( entry, 1, 1 )    						; Look for a Parse syntax prefix
	If not InStr( "%→$§*α=β~†@Ð&¶®©", psp )     				; eD WIP: Could use pos := InStr( etc, then if pos ==  1 etc – faster? But less readable.
		Return false
	If ( StrLen( entry ) < 2 )  								; The entry must have at least a prefix plus something to qualify
		Return false
	pfix    := -1   											; Prefix for the Send commands, such as {Blind}
	enty    := SubStr( entry, 2 )
	If        ( psp == "%" || psp == "→" ) { 					; %→ : Literal/string by SendInput {Text}
		mode    := "Input"
		pfix    := "{Text}"
	} else if ( psp == "$" || psp == "§" ) { 					; $§ : Literal/string by EPKL SendMessage
		mode    := "SendMess"
		pfix    := ""
	} else if ( enty == "{CapsLock}" ) { 						; CapsLock toggle. Stops further entries from misusing Caps?
		togCap  := getKeyState("CapsLock", "T") ? "Off" : "On"
		SetCapsLockState % togCap
	} else if ( psp == "*" || psp == "α" ) { 					; *α : AHK special +^!#{} syntax, omitting {Text}
		lastKeys( "null" )  									; Delete the Composer LastKeys queue
		pfix    := ""
		If pkl_ParseAHK( enty, pfix, higMode )  				;      Special EPKL-AHK syntax additions (only performed if not higMode)
			Return psp
	} else if ( psp == "=" || psp == "β" ) { 					; =β : Send {Blind} - as above w/ current mod state
		lastKeys( "null" )  									; Delete the Composer LastKeys queue
		pfix    := "{Blind}"
		If pkl_ParseAHK( enty, pfix, higMode )
			Return psp
	} else if ( psp == "~" || psp == "†" ) { 					; ~† : Hex Unicode point U+####
		pfix    := ""
		enty    := "{U+" . enty . "}"
	} else if ( psp == "@" || psp == "Ð" ) { 					; @Ð : Named dead key (may vary between layouts!)
		mode    := "DeadKey"
		pfix    := ""
	} else if ( psp == "&" || psp == "¶" ) { 					; &¶ : Named literal/powerstring (may vary between layouts!)
		mode    := "PwrString"
		pfix    := ""
	} else if ( psp == "®" ) {  								; ®® or ®# [# is hex] : Repeat previous key once or # times
		pkl_RepeatKey( enty )
	} else if ( psp == "©" ) {  								; ©### : Named Compose/Completion key – compose previous key(s)
		pkl_Composer( enty )
	}
	If ( pfix != -1 && ! higMode ) {    						; Send if recognized and not ParseOnly/HIG
		If ( enty && mode == "SendThis" ) { 
			pkl_Send( "", pfix . enty ) 						; Used by keyPressed()
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
	Return psp  												; Return the recognized prefix
}

pkl_ParseAHK( ByRef enty, pfix := "", abort := false ) {    	; Special EPKL-AHK syntax additions. Allows even more fancy stuff in α/β entries.
	Critical 													; eD WIP: Try to improve timing for OSMs
	If ( abort == true )
		Return true
	OSM := false , OSMs  := []
	While InStr( enty, " OSM}" ) {  							; OneShotMod syntax: `{<mod> OSM}` activates <mod> as OSM once.
		OSM := true
		mod := "i)\{([LR]?(?:Shift|Alt|Ctrl|Win)) OSM\}" 		; RegEx capture pattern for a OneShotMod
		RegExMatch( enty, mod, mod ) 							; RegExMatch mode O) stores the match object in the mod variable.
		mod := mod1 											; Simple way to get the first subpattern
		enty := StrReplace( enty, "{" . mod . " OSM}" ) 		; Remove the special syntax, replacing `{<mod> OSM}` with nothing.
		OSMs.Push( mod )
	}
	If ( OSM ) {
		SendInput % pfix . enty 								; Send the entry before activating the OSM
		Sleep % 50
		For ix, mod in OSMs {
			setOneShotMod( mod )
		}
		Return true
	}   ; <-- if osm
	If (     cmdIn := InStr( enty, "¢[" ) ) {   				; Special send-command syntax. Only for Sleep and Run so far.
		If ( cmdUt := InStr( enty, "]¢" ) ) {
			If ( cmdIn > 1 )    								; Send any partial entry up to the command
				pkl_Send( "", pfix . SubStr( enty, 1, cmdIn-1 ) )
			cmdStr  := SubStr( enty, cmdIn+2, cmdUt-cmdIn-2 )
			pkl_exec( cmdStr )  								; Execute the command
			enty := SubStr( enty, cmdUt+2 ) 					; Because of ByRef, this changes enty
			pkl_ParseAHK( enty, pfix )  						; Iterate in case of multiple commands in one entry
		}
	}   ; <-- if Cmd()
	Return false
}

pkl_SendMessage( string ) { 									; Send a string robustly by char messages, so that mods don't get stuck etc
																; SendInput/PostMessage don't wait for the send to finish; SendMessage does
	Critical 													; Source: https://autohotkey.com/boards/viewtopic.php?f=5&t=36973
	WinGet, hWnd, ID, A 										; Note: Seems to be faster than SendInput for long strings only?
	ControlGetFocus, vClsN, ahk_id%hWnd% 	; "If this line doesn't work, try omitting vCtlClsN to send directly to the window"
	Loop, Parse, string
		SendMessage, 0x102, % Ord( A_LoopField ), 1, %vClsN%, ahk_id%hWnd% 	; 0x100 = WM_CHAR sends a character input message
;		SendMessage, 0x100, 0x0D, 0, %vClsN%, ahk_id%hWnd% 		; 0x100 = WM_KEYDOWN. Sends a Windows key input message.
;		SendMessage, 0x101, 0x0D, 0, %vClsN%, ahk_id%hWnd% 		; 0x100 = WM_KEYUP, 0x0D = VK_RETURN = {Enter}.
;		ControlSend, %vClsN%, +{Enter} 							; Try ControlSend instead. 
;		Control, EditPaste, +{Enter}, %vClsN% 					; Try Control, EditPaste instead.
}

pkl_SendClipboard( string ) { 									; Send a string quickly via the Clipboard (may fail if the clipboard is big)
	Critical
	clipSaved := ClipboardAll 									; Save the entire contents of the clipboard to a variable
;	Clipboard := Clipboard 										; Cast the clipboard content as text (use expression to avoid trimming)
	Clipboard := string
	ClipWait 1  												; Wait some seconds for the clipboard to contain text
	If ( ErrorLevel ) {
		Content := ( Clipboard ) ? Clipboard : "<empty>"
		pklDebug( "Clipboard not ready! Content:`n" . Content )
	}
	Send ^v 													; Wait 50-250 ms(?) after pasting before changing clipboard.
	Sleep % 250 												; See https://autohotkey.com/board/topic/10412-paste-plain-text-and-copycut/
	Clipboard := clipSaved
	VarSetCapacity( clipSaved, 0 )  							; Could probably just use := "" here, especially for large contents.
}

_strSendMode( string, strMode ) {
	If ( not string )
		Return true
	If        ( strMode == "Input"     ) {  			; Send by the standard SendInput method. Used to be {Raw}.
		SendInput {Text}%string% 						; - May take time, and any modifiers released meanwhile will get stuck!
	} else if ( strMode == "Text"      ) {  			; Send by the SendInput {Text} method (AHK v1.1.27+)
		SendInput {Text}%string% 						; - More reliable? Only backtick characters are translated.
	} else if ( strMode == "Message"   ) {  			; Send by SendMessage WM_CHAR system calls
		pkl_SendMessage( string ) 						; - Robust as it waits for sending to finish, but a little slow.
	} else if ( strMode == "Paste" ) {  				; Send by pasting from the Clipboard, preserving its content.
		pkl_SendClipboard( string ) 					; - Quick, but may fail if the timing is off. Best for non-parsed send.
	} else {
		pklWarning( "Send mode '" . strMode . "' unknown.`nString '" . string . "' not sent." )
		Return false
	}   ; <-- if strMode
	Return true
}

pkl_PwrString( strName ) {  									; Send named literal/ligature/powerstring from a file
	static strFile
	static strMode
	static brkMode
	static strDic       := {}
	static initialized  := false
	
	If ( not initialized ) {
		strFile := getPklInfo( "StringFile" )   				; The file containing named string tables
		strMode := pklIniRead( "strMode", "Message", strFile ) 	; Mode for sending strings: "Input", "Message", "Paste"
		brkMode := pklIniRead( "brkMode", "+Enter" , strFile ) 	; Mode for handling line breaks: "+Enter", "n", "rn"
		strSect := pklIniSect( strFile, "strings", true )   	; The actual PwrString section (limited to 65533 characters?)
		For ix, line in strSect {   							; Note: IniRead is a bit faster than pklIniRead() (1-2 s on a 34 line str)
			pklIniKeyVal( line, key, val, 1, 1, 1 )     		; Replace escapes, remove comments and trim quotes
			if ( key == "<NoKey>" )
				Continue
			strDic[key] := hig_deTag( val )
		}
		initialized := true
	}
	
	Critical    												; eD WIP: Is Critical right here?
	theString := strDic[ strName ]  							; PowerStrings are preread above, at first fn() init
	If pkl_ParseSend( theString )   							; Unified prefix-entry syntax; only for single line entries
		Return
	If ( SubStr( theString, 1, 11 ) == "<Multiline>" ) { 		; Multiline string entry
		Loop % SubStr( theString, 13 ) {    					; The <MultiLine> tag is followed by the number of lines
			mltString .= strDic[ strName . "-" . Format( "{:02}", A_Index ) ]
		}
		theString := mltString
	}
	If ( strMode == "Text" ) {
		SendInput {Text}%theString%
	} else if ( brkMode == "+Enter" ) {
		Loop, Parse, theString, `n, `r  						; Parse by lines, sending Enter key presses between them
		{   													; - This is more robust since apps use different breaks
			If ( A_Index > 1 )
				SendInput +{Enter}  							; Send Shift+Enter, which should be robust for msg boards.
				Sleep % 50  									; Wait so the Enter gets time to work. Need ~50 ms?
			If ( not _strSendMode( A_LoopField , strMode ) ) 	; Try to send by the chosen method
				Break
		}   ; <-- Loop Parse
	} else {    												; Send string as a single block with line break characters
		StrReplace( theString, "`r`n", "`n" )   				; Ensure that any existing `r`n are kept as single line breaks
		If ( brkMode == "rn" )
			StrReplace( theString, "`n", "`r`n" )
		_strSendMode( theString , strMode ) 					; Try to send by the chosen method
	}   ; <-- if brkMode
}

pkl_RepeatKey( num ) {  										; Repeat the last key a specified number of times, for the ®# key
	lks := getKeyInfo( "LastKeys" ) 							; The LastKeys array for the Compose method
	lky := lks[lks.Length()] 									; The last entry in LastKeys is the previous key.
	num := ( num == "®" ) ? 1 : Round( "0x" . num ) 			; # of repeats may be any hex number without "0x", or just ® for num=1
	Loop % num {
		SendInput {Text}%lky%   	;keyPressed( getKeyInfo( "LastKey" ) ) ; NOTE: Holding down modifiers affect this. Sticky mods won't.
		lastKeys( "push", lky ) 								; Repeated keys are counted in the LastKeys queue
	}
}
