;;  ========================================================================================================================================================
;;  EPKL Remap module
;;  - Functions to read and parse remap cycles for ergo mods and suchlike
;;  - Used primarily in pkl_init.ahk
;

ReadRemaps( mapList, mapStck ) { 								; Parse a remap string to a CSV list of cycles (used in pkl_init)
	mapCycList  := "" 											; Name -> actual list, or literal list
	For ix, alist in pklIniCSVs( mapList, mapList, mapStck, "Remaps" ) { 	; mapFile
		tmpCycle    := "" 							; Above, mapList is default to use a map unless it refers to another
		For ix, list in StrSplit( alist, "+", " `t" ) { 		; Parse merges by plus sign
			If ( SubStr( list, 1, 1 ) == "^" ) { 				; A cycle reference...
				theMap  := SubStr( list, 2 ) 					; ...adds the cycle the list refers to directly
			} else if ( alist != mapList ) { 					; This should safeguard against infinite loops
				theMap  := ReadRemaps( list, mapStck ) 			; Refers to another map -> Self recursion
			} else {
				theMap  := ""
			}
			tmpCycle    := tmpCycle . ( ( tmpCycle ) ? ( " + " ) : ( "" ) ) . theMap 	; re-attach by +
		}	; end For list
		mapCycList  := mapCycList . ( ( mapCycList ) ? ( ", " ) : ( "" ) ) . tmpCycle 	; re-attach by CSV
	}	; end For alist
	Return mapCycList
}	; end fn

ReadCycles( mapType, mapList, mapStck ) { 			; Parse a remap string to a dict. of remaps (used in pkl_init)
	mapFile := IsObject( mapStck ) ? mapStck[mapStck.Length()] : mapStck 		; Use a file stack, or just one file
	mapType := upCase( SubStr( mapType, 1, 2 ) ) 				; MapTypes: (sc|vk)map(Lay|Ext|Mec) => SC|VK
	pdic    := {}
	If ( mapType == "SC" )										; Create a fresh SC pdic from mapFile KeyLayMap
		pdic := ReadKeyLayMapPDic( "SC", "SC", mapFile )
	rdic    := pdic.Clone()										; Reverse dictionary (instead of if loop)?
	tdic	:= {}												; Temporary dictionary used while mapping loops
	For ix, clist in StrSplit( mapList, ",", " `t" ) { 			; Parse cycle list by comma
		fullCycle := ""
		For ix, plist in StrSplit( clist, "+", " `t" ) { 		; Parse and merge composite cycles by plus sign
			thisCycle := pklIniRead( plist , "", mapStck, "RemapCycles" ) 	; mapFile
			If ( not thisCycle )
				pklWarning( "Remap element '" . plist . "' not found", 3 )
			thisType  := SubStr( thisCycle, 1, 2 )				; KLM map type, such as TC for TMK-like Colemak
;			rorl      := ( SubStr( thisCycle, 3, 1 ) == "<" ) ? -1 : 1		; eD TODO: R(>) or L(<) cycle?
			thisCycle := RegExReplace( thisCycle, "^.*?\|(.*)\|$", "$1" )	; Strip defs and wrapping pipes
			fullCycle := fullCycle . ( ( fullCycle ) ? ( " | " ) : ( "" ) ) . thisCycle	; Merge cycles
		}	; end For plist
		If ( mapType == "SC" )									; Remap pdic from thisType to SC
			mapDic  := ReadKeyLayMapPDic( thisType, "SC", mapFile )
		For ix, minCycl in StrSplit( fullCycle, "/", " `t" ) { 	; Parse cycle to minicycles:  | a | b / c | d | e |
			thisCycle   := StrSplit( minCycl, "|", " `t" ) 		; Parse cycle by pipe, and create mapping pdic
			numSteps    := thisCycle.Length()
			Loop % numSteps { 									; Loop to get proper key codes
				this := thisCycle[ A_Index ]
				If ( mapType == "SC" ) { 						; Remap from thisType to SC
					thisCycle[ A_Index ] := mapDic[ this ]
				} else if ( mapType == "VK" )  { 				; Remap from VK name/code to VK code
					thisCycle[ A_Index ] := getVKnrFromName( this ) 	; VK maps use VK## format codes
				}	; end if
			}	; end loop
			Loop % numSteps { 									; Loop to (re)write remap pdic
				this := thisCycle[ A_Index ] 					; This key's code gets remapped to...
				this := ( mapType == "SC" ) ? rdic[ this ] : this 	; When chaining maps, map the remapped key ( a→b→c )
				that := ( A_Index == numSteps ) ? thisCycle[ 1 ] : thisCycle[ A_Index + 1 ]	; ...next code
				pdic[ this ] := that 							; Map the (remapped?) code to the next one
				tdic[ that ] := this 							; Keep the reverse mapping for later cycles
			}	; end Loop (remap one full cycle)
			For key, val in tdic 
				rdic[ key ] := val 								; Activate the lookup dict for the next cycle
		}	; end For minicycle
	}	; end For clist (parse CSV)
;; eD remapping cycle notes:
;; Need this:    ( a | b | c , b | d )                           => 2>:[ a:b:d, b:c, c:a, d:b   ]
;; With rdic: 1<:[ b:a, c:b, a:c, d:d ] => 2>:[ r[b]:d, r[d]:b ] => 2>:[ a:d  , b:c, c:a, d:b   ]
;; Note that:    ( b | d , a | b | c )                           => 2>:[ a:b  , b:d, c:a, d:b:c ] - so order matters!
	Return pdic
}	; end fn

ReadKeyLayMapPDic( keyType, valType, mapFile ) { 	; Create a pdic from a pair of KLMaps in a remap.ini file
	pdic    := {}
	Loop % 5 {  												; Loop through KLM rows 0-4
		keyRow := pklIniCSVs( keyType . ( A_Index - 1 ), "", mapFile, "KeyLayoutMap", "|" ) 	; Split by pipe
		valRow := pklIniCSVs( valType . ( A_Index - 1 ), "", mapFile, "KeyLayoutMap", "|" ) 	; --"--
		For ix, key in keyRow { 								; (Robust against keyRow shorter than valRow)
			If ( ix > valRow.Length() ) 						; End of val row
				Break
			If ( not key )  									; Empty key entry (e.g., double pipes)
				Continue
			key := ( keyType == "SC" ) ? upCase( key ) : key 	; ensure caps for SC### key
			key := ( keyType == "VK" ) ? getVKnrFromName( key ) : key
			val := upCase( valRow[ ix ] )
			val := ( valType == "VK" ) ? getVKnrFromName( val ) : val
			pdic[ key ] := val  								; e.g., pdic[ "SC001" ] := "VK1B"
		}	; end For key
	}	; end Loop KLM rows
	Return pdic
}	; end fn

;;  ========================================================================================================================================================
;;  EPKL janitor/activity module
;;      Check for idleness (no clicks/keypresses), suspend EPKL by time/app, perform cleanup etc.
;

pklJanitorTic:
	_pklSuspendByApp()
	_pklSuspendByLID()
	_pklJanitorActivity()
	_pklJanitorLocaleVK()
;	_pklJanitorCleanup() 	; eD WIP: Testing EPKL without the idle keyups
Return

_pklSuspendByApp() { 											; Suspend EPKL if certain windows are active
	static suspendedByApp := false  							; (Their attributes are in the Settings file)
	
	matchMode   := getPklInfo("suspendingMode")
	If ( matchMode )
		SetTitleMatchMode % getPklInfo("suspendingMode") 		; A custom window TitleMatchMode may be specified
	If WinActive( "ahk_group SuspendingApps" ) { 				; If a window specified in the group is active...
		If ( not suspendedByApp ) { 							; ...and not already A_IsSuspended,...
			suspendedByApp := true  							; ...then auto-suspend that window.
			Gosub suspendOn
		}
	} else if ( suspendedByApp ) {
		suspendedByApp := false
		Gosub suspendOff
	}
	SetTitleMatchMode % getPklInfo("WinMatchDef")   			; Return to EPKL's default TitleMatchMode
}

_pklSuspendByLID() { 											; Suspend EPKL if certain layouts are active
	static suspendedByLID := false 								; (They're specified by LID as seen in About...)

	suspendingLIDs := getPklInfo( "suspendingLIDs" )
	If InStr( suspendingLIDs, getWinLocaleID() ) { 				; If a specified layout is active...
		If ( not suspendedByLID ) { 							; ...and not already A_IsSuspended...
			suspendedByLID := true
			Gosub suspendOn
		}
	} else if ( suspendedByLID ) {
		suspendedByLID := false
		Gosub suspendOff
	}
}

_pklJanitorActivity() { 										; Suspend/exit EPKL after a certain time of inactivity, if set
	suspTime := getPklInfo( "suspendTimeOut" ) * 60000 			; Convert from min to ms
	exitTime := getPklInfo( "exitAppTimeOut" ) * 60000 			; Convert from min to ms
	idleTime := A_TimeIdle 										; eD WIP: Use TimeIdlePhysical instead?
	If ( exitTime && idleTime > exitTime ) {
		Gosub exitPKL
	} else if ( suspTime && not A_IsSuspended && idleTime > suspTime ) {
		Gosub suspendOn
	}
}

_pklJanitorLocaleVK( force := false ) {     					; Renew VK codes: OEM key VKs vary by locale for ISO system layouts
	If ( not force && A_TimeIdle < 2000 )   					; Don't do this if the comp isn't unused for at least 2 s
		Return
	oldLID  := getPklInfo( "previousLocaleID" )
	newLID  := getWinLocaleID()
	If ( oldLID != newLid ) {
;		( 1 ) ? pklDebug( "System layout LID change: " . oldLID . "->" . newLID, 1 )  ; eD DEBUG
		getWinLayVKs()
		getWinLayDKs()  										; Get the Windows Layout's DKs  	; eD WIP
		; eD WIP: Renew the OEM VK mappings here! Rethink strategy? Need to map based on the values you want, based on KLM/SC codes.
	}
	setPklInfo( "previousLocaleID", newLID )
}

_pklJanitorCleanup() {
	timeOut := getPklInfo( "cleanupTimeOut" ) * 1000 			; The timeout in s is converted to ms
	If ( A_TimeIdle > timeOut ) { 					 			; eD WIP: Use TimeIdlePhysical w/ mouse hook as well?
		If getPklInfo( "cleanupDone" ) 							; Avoid repeating this every timer interval 	; eD WIP: Or use a one-shot timer instead?
			Return
		If not ExtendIsPressed()
			extendKeyPress( -1 ) 								; Clean up any loose Ext mods
		For ix, mod in [ "LShift", "LCtrl", "LAlt", "LWin" 			; "Shift", "Ctrl", "Alt", "Win" are just the L# mods
					   , "RShift", "RCtrl", "RAlt", "RWin" ] { 		; eD WIP: What does it take to ensure no stuck mods?
			If getKeyState( mod ) {
				Return 											; If the key is being held down, leave it be, otherwise...
			} else {
				Send % "{" . mod . " Up}" 						; ...send key up in case it's stuck (doesn't help if it's registered as physically down)
			}
		}	; end For mod 	; eD WIP: Try to do without the keyup spam now, as stuck mods aren't prevalent after the Extend mod rework? But I've still had it happen.
		setPklInfo( "cleanupDone", true )
	} else if ( A_TimeIdlePhysical < timeOut ) { 				; Sending the up mods above resets TimeIdle but not TimeIdlePhysical
		setPklInfo( "cleanupDone", false ) 						; Recent keyboard activity reactivates the cleanup timer
	}
}

;;  ========================================================================================================================================================
;;  Utility functions
;;      These are minor utility functions used by other parts of EPKL
;

pklMsgBox( msg, s := "", p := "", q := "", r := "" ) {  		; Seems this is only used once in pkl_init now?
	msg := getPklInfo( "LocStr_" . msg )
	For ix, it in [ "s", "p", "q", "r" ] {
		msg := ( %it% == "" ) ? msg : StrReplace( msg, "#" . it . "#", %it% )
	}
	MsgBox % msg
}

pklErrorMsg( text ) {
	MsgBox, 0x10, EPKL ERROR, %text%`n`nError # %A_LastError% 	; Error type message box
}

pklWarning( text, time := 5 ) {
	MsgBox, 0x30, EPKL WARNING, %text%, %time%					; Warning type message box
}

pklInfo( text, time := 4 ) {
	MsgBox, 0x40, EPKL INFO: , %text%, %time%					; Info type message box (asterisk)
}

pklDebug( text, time := 2 ) {
	MsgBox, 0x40, EPKL DEBUG: , %text%, %time%					; Info type message box (asterisk)
}

pklSetHotkey( hkIniName, gotoLabel, pklInfoTag ) { 				; Set a menu hotkey (used in pkl_init)
	For ix, hkey in pklIniCSVs( hkIniName ) {
		If ( hkey == "" || hkey == "--" )
			Break
		Hotkey, %hkey%, %gotoLabel%
		If ( ix == 1 )
			setPklInfo( pklInfoTag, hkey )
	}	; end For hkey
}	; end fn

getWinInfo() { 												; Get match info for the active window
	WinGetClass, awClass, A 								; This info is useful for setting SuspendingApps
	WinGet,      awProcs, ProcessName, A 					; Alternatives: ProcessName, ProcessPath
	WinGetTitle, awTitle, A
	pklDebug( "Active window properties:`n" 				; Add ID? PID? Probably not necessary.
			. "`nClass: "   . awClass 						; Use w/ ahk_class match
			. "`nExe:    "  . awProcs 						; Use w/ ahk_exe match
			. "`nTitle:   " . awTitle 						; Use w/ direct title match
			. "`n" , 10 )
}

getWinLayVKs() {    										; Find the VK values for the current Win layout's (OEM) keys, in case there's a weird ISO remapping or something
;	scMap   := getPklInfo( "scMapLay" ) 					; The pdic used to remap SC for the active layout
	qSCdic  := getPklInfo( "QWSCdic" )  					; SC from QW_##  	; eD WIP: Keep track of remappings. Must not remap, e.g., Angle Z on QW_LG to its underlying VK##!
	qVKdic  := getPklInfo( "QWVKdic" )  					; VK from QW_## = vc_## (KLM_QW-2-Win_VK)
	oemDic  := {}  ;[ "029","00c","00d","01a","01b","02b","027","028","056","033","034","035" ] 	; "SC" . SCs[ix]
	For ix, key in  [ "_GR","_MN","_PL","_LB","_RB","_BS","_SC","_QU","_LG","_CM","_PD","_SL" ] { 	; eD WIP: Run through the whole SCdic instead?
		qsc := qSCdic[ key ]
;	For key, qsc in qSCdic { 								; Run through all mappable ScanCodes 	; eD WIP: This goes wrong! Why?
		qvk := qVKdic[ key ] 								; Map from a KLM (ANSI) VK## code
		ovk := Format( "VK{:02X}", GetKeyVK( qsc ) ) 		; VK## format
		oemDic[qvk]  := ovk 								; GetKey##(key) gets current Name/VK/SC from a SC or VK
;	( key == "_GR" ) ? pklDebug( "OEM: " . key . "`nSC: " . qSCdic[key] . "`nQVK: " . qvk . "`nOVK: " . oemDic[qvk], 6 )  ; eD DEBUG
	} 	; end for key
	setPklInfo( "oemVKdic", oemDic )
	Return oemDic 											; eD WIP: Map from SC instead, so we can keep track of how OEM keys should be mapped? Also, VK aren't as robust.
}

getVKnrFromName( name ) { 									; Get the 4-digit hex VK## code from a VK name
	name := upCase( name )
	If ( not RegExMatch( name, "^VK[0-9A-F]{2}$" ) == 1 ) {	; Check if the name is already VK##
		name := "VK" . pklIniRead( "VK_" . name, "00", "PklDic", "VKeyCodeFromName" )
	}
	Return name
}

getWinLocaleID() {  										; Actual Win LocID; for LangID use A_Language.
	WinGet, WinID,, A   									; The ID of the active window
	WinThreadID := DllCall("GetWindowThreadProcessId", "Int", WinID, "Int", 0)
	WinLocaleID := DllCall("GetKeyboardLayout", "Int", WinThreadID)
	WinLocaleID := ( WinLocaleID & 0xFFFFFFFF )>>16 		; Only use the last four xdigits
	Return Format( "{:04x}", WinLocaleID )  				; Return as 4-xdigit; used to be decimal
}

thisMinute() { 												; Use A_Now (local time) for a folder or other time stamp
	FormatTime, theNow,, yyyy-MM-dd_HH-mm
	Return theNow
}

fileOrAlt( file, altFile, errMsg := "", errDur := 2 ) { 	; Find a file/dir, or use the alternative
	file := atKbdType( file )   							; Replace '@K' w/ KbdType
	If FileExist( file )
		Return file
	If ( errMsg ) && ( not FileExist( altFile ) ) 			; Issue a warning if neither file is found and errMsg is set
		pklWarning( errMsg, errDur )
	Return altFile
}

atKbdType( str ) { 							; Replace '@K' in layout file entries with the proper KbdType (ANS/ISO...)
	Return StrReplace( str, "@K", getLayInfo( "Ini_KbdType" ) )
}

pklSplash( title, text, dur := 4.0 ) {  	; Default display duration in seconds
	SetTimer, KillSplash, Off 				; TrayTip and SplashText are hard to kill? SplashText is also deprecated.
	Gui, pklSp:New, ToolWindow -SysMenu, %title% 	; GUI window w/ title, no buttons
	Gui, pklSp:Margin, 24 					; Horizontal margin to allow the whole window title to be shown
	Gui, pklSp:Font, s12 w500 				; Font size and weight (400 normal, 700 bold)
	Gui, pklSp:Add, Text,, %text%
	Gui, pklSp:Show 		;	TrayTip %title%, `n%text%, dur, 0x11 	;SplashTextOn, 300, 100, %title%, `n%text%
	SetTimer, KillSplash, % -1000 * dur
}

KillSplash:
	Gui, pklSp: Destroy 					;TrayTip 	;SplashTextOff
Return

pklTooltip( text, dur := 4.0 ) {    		; Default display duration in seconds
	ToolTip % text
	SetTimer, KillToolTip, % -1000 * dur
}

KillToolTip:
	ToolTip
Return

getPriority( procName := "" ) { 			; Utility function to get process priority, by SKAN from the AHK forums
	;;  https://autohotkey.com/board/topic/7984-ahk-functions-incache-cache-list-of-recent-items/page-3#entry75675
	procList := { 16384 : "BelowNorm",    32 : "Normal"   , 32768 : "AboveNorm"
				,    64 : "Low"      ,   128 : "High"     ,   256 : "Realtime"  }
	Process, Exist, %procName%
	thePID := ErrorLevel
	IfLessOrEqual, thePID, 0, Return, "Error!"
	hProcess := DllCall( "OpenProcess", Int, 1024, Int, 0, Int, thePID )
	Priority := DllCall( "GetPriorityClass", Int, hProcess )
	DllCall( "CloseHandle", Int, hProcess )
	Return procList[ Priority ]
}

loCase( str ) {
	Return Format( "{:L}", str )
}

upCase( str ) {
	Return Format( "{:U}", str )
}

isInt( this ) { 											; AHK cannot use "is <type>" in expressions...
	If this is integer  									; ...so use this wrapper function instead.
		Return true 										; [This includes hex numbers starting with "0x"]
	Return false 											; Else. May not be strictly necessary in AHK syntax.
}

isHex( this ) { 											; AHK cannot use "is <type>" in expressions...
	If this is xdigit   									; ...so use this wrapper function instead.
		Return true
	Return false
}

bool( val ) { 												; Convert an entry to true or false (default)
	val := loCase( val )
	Return ( val == "1" || val == "yes" || val == "y" || val == "true" ) ? true : false
}

convertToANSI( str ) { 										; Use IniRead() w/ UTF-8 keys 	; eD WIP
	dum := "--" 											; The string is written as ANSI/CP0
	VarSetCapacity( dum, StrPut( str, "UTF-8" ) ) 			; Ensure var capacity
; 		* ((codePg=="utf-16"||codePg=="cp1200") ? 2 : 1) ) 	;     ...in bytes (StrPut returns chars)
	len := StrPut( str, &dum, "UTF-8" ) 					; Copy/convert string (returns length in chars)
	Return StrGet( &dum, "CP0" ) 							; Return str as UTF-8
}

convertToUTF8( str ) { 										; Use IniRead() w/ UTF-8 instead of UTF-16 	; eD WIP
	dum := "--" 											; The string is read as ANSI/CP0
	VarSetCapacity( dum, StrPut( str, "CP0" ) ) 			; Ensure var capacity
; 		* ((codePg=="utf-16"||codePg=="cp1200") ? 2 : 1) ) 	;     ...in bytes (StrPut returns chars)
	len := StrPut( str, &dum, "CP0" ) 						; Copy/convert string (returns length in chars)
	Return StrGet( &dum, "UTF-8" ) 							; Return str as UTF-8
}

formatUnicode( chr ) { 										; Format a character as a hex string, without the "0x"/"U"/"~"
	chr     := Ord( chr ) 									; Unicode ordinal value
	pad     := ( chr > 0x10000 ) ? "" : "04" 				; Pad with zeros iff ord < 0x10000, as done in X11 keysymdef.h
	Return  Format( "{:" . pad . "x}", chr ) 				; Format as a Unicode hex string [0x]#### (4+ digits)
}

inArray( haystack, needle, case := true ) {     			; Check if an array object has a certain value, and return its index
	If !(IsObject(haystack)) || ( haystack.Length() == 0 )  ; (For associative arrays, you can use Array.HasKey() to find a key.)
		Return false
	needle      := ( case ) ? needle : loCase( needle ) 	; If desired, use caseless comparison
	For ix, value in haystack {
		value   := ( case ) ? value  : loCase( value  )
		If ( value == needle )
			Return ix
	}
	Return false
}

array2Str( array, sep := "`r`n" ) { 						; Join an array by a separator to a string
	For ix, el in array
		out .= sep . el
	Return SubStr( out, 1+StrLen(sep) ) 					; Lop off the initial separator (faster than checking in the loop)
}

dllToUni( iVK, iSC ) {  																; Call the OS layout to translate VK/SC to a character, if possible. NB: VK/SC are int.
	;;  ToUnicodeEx distinguishes between left and right versions of keys. ToUnicode doesn't.
	;;  Regarding problem w/ ToUnicode(Ex) and WinLay/OS DKs: See the warning in Remarks at...
	;;  https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-tounicodeex?redirectedfrom=MSDN
	;;  " As ToUnicodeEx translates the virtual-key code, it also changes the state of the kernel-mode keyboard buffer. 
	;;    This state-change affects dead keys, ligatures, alt+numpad key entry, and so on. 
	;;    It might also cause undesired side-effects if used in conjunction with TranslateMessage..."  [So, that's why OS DKs got messed up.]
;	pklTooltip( "VK " . Format("{:X}",iVK) . "`n" . Format("SC{:03X}",iSC) . "`nchr [" . dllMapVK(iVK) . "]`nAGr " . GetKeyState("RAlt"), 2 )  ; eD DEBUG
	state   := pklGetState() 															; GetKeyState() calls are OS-DK safe (and pklModState() calls too).
	winDKs  := getPklInfo( "WinLayDKs" ) 												; Couldn't run getWinLayDKs() here, as it messes up OS-DKs. Leave it to pklJanitor.
	sSC     := Format( "SC{:03X}", iSC ) 												; Reformat int SC to scMap's "SC###" notation
;	pklTooltip( "SC: " . sSC . "  DKs: " . winDKs[sSC] . "  ShSt: " . state, 1 ) 		; eD DEBUG: Use remapped SC
	If winDKs.HasKey( sSC ) ;{   														; If this key holds an OS DK ...
		If InStr( winDKs[sSC], "" . state ) 											; ... and the shift state matches, ...
			Return % "śķιᶈForDK" 														; ... don't proceed to the DLL call (twice) to avoid disturbing the DK.
	map := dllMapVK( iVK, "ord" )   													; Get ordinal of VK's (base keyname) mapping; (map>0) tests isNoDK? No, it doesn't.
	TID := DllCall( "GetWindowThreadProcessId", "Int", WinExist("A"), "Int", 0 ) 		; TID: Window  Thread Process ID
	ID0 := DllCall( "GetCurrentThreadId", "UInt", 0 )   								; TI0: Current Thread Process ID
	DllCall( "AttachThreadInput", "UInt", ID0, "UInt", TID, "Int", 1 ) 					; Attach TID input to the TI0 process. Needed to detect AltGr etc.
	HKL := DllCall( "GetKeyboardLayout", "Int", TID )   								; Refresh GetKeyboardLayout (the user may change it, e.g., with Win+Space). Used for Ex.
	VarSetCapacity( theChar, 32 )   													; The result may be a buffer with several chars (if so, these are not good here)
	DK  := DllCall( "ToUnicodeEx",  "UInt", iVK, "UInt", iSC, "UInt", dllKbdState() 	; The call needs a 256-byte &KeyState array (or, is just the ModState needed?).
		          , "Str", theChar, "UInt", 64, "UInt",  1, "UInt", HKL )   			; DK: -1 for DeadKey, 0 for none, 1 for a char, 2+ for several
	If ( map > 0 ) && ( DK == 1 ) && ( Ord(theChar) > 0x1F ) 							; Avoid returning multi-char results and Ctrl chars (0x00–0x1F)
		Return theChar  																; https://www.autohotkey.com/boards/viewtopic.php?t=1040
}

dllKbdState() { 																		; Get a &KeyState 256-byte array of the state of each key on the keyboard
	VarSetCapacity( KeyState, 256, 0 )
	DllCall( "GetKeyboardState", "uint", &KeyState ) 									; Get Keyboard State -> &KeyState (256 bytes)
	Return &KeyState
}

pklModState( mode := "get", ShSt := 0 ) {   											; Get/Set a &ModState 256-byte array like KeyState, of the main three state mods
	static VK_MODS  := { "Shift" : 0x10  , "Ctrl" : 0x11  , "Alt" : 0x12   } 			; This works w/ AltGr = Ctrl + Alt
	setMods         := { "Shift" : 0     , "Ctrl" : 0     , "Alt" : 0      }
	If ( ShSt & 4 ) ;{   																; AltGr
		setMods["Ctrl"] := 1 , setMods["Alt"] := 1
	If ( ShSt & 1 ) ;{   																; Shift
		setMods["Shift"] := 1
	VarSetCapacity( ModState, 256, 0 )  												; A 256-byte string array prefilled with zeros
	For mod, modVK in VK_MODS {
		modDown := ( mode == "set" ) ? setMods[ mod ] : GetKeyState( mod )  			; Either set the mods' states from an array, or get it from key states
		If ( modDown )  																; The modifier is pressed (if using GetKeyState(), "P" is for physical)
			NumPut( 0x80, ModState, modVK + 0, "UChar" )
;		( ShSt == 6 ) ? pklDebug( "mod: " . mod . " (" . modVK . ")`nShSt: " . ShSt . "`nmodDn: " . modDown , 2 )  ; eD DEBUG
	} 	; end for
;	VarSetCapacity( ModState, 256, 0 ), NumPut( 0x80, ModState, 0x11, "UChar" ), NumPut( 0x80, ModState, 0x12, "UChar" ) 	; eD DEBUG
	Return &ModState
}

dllMapVK( VK, mode := "chr" ) { 														; Call the MapVirtualKey DLL to determine SC/VK/ord/chr based on VK or SC (int) input
	static mapModes :=  { "SC"  : 0 , "VK"  : 1 , "ord" : 2 , "chr" : 2 
					    , "VKx" : 3 , "SCx" : 4 }   									; Similar to the GetKeyName/SC/VK AHK fns, but those mess w/ OS DKs etc.
	mod := mapModes[ mode ] 															; The "Ex" mappings distinguish between left/right versions of keys; normal ones do not.
	map := DllCall( "MapVirtualKey", "uint", VK, "uint", mod )  						; MapVirtualKey translates/maps VK into SC (0/4) or char ordinal (2), or SC to VK (1/3)
	map := ( mode := "chr" ) ? Chr( map ) : map     									; Return the actual chr instead of its ordinal. Letter keys will be shifted (Win bug).
	Return map
}

runTarget( target := "." ) {    							; Run/open a target (default: This program's folder, in File Explorer)
	Run % target    										; Run the target in its default way - e.g., File Explorer - or focus on it if already open
}

pklDebugCustomRoutine() {   								; eD DEBUG: debugShowCurrentWinLayKeys() – Display the VK values for the current Win layout's OEM keys
	lin := "`n————" . "————" . "————"   					; Just a line of dashes for formatting
	str := "For layout LID: " . getWinLocaleID() . lin  	; The active Windows layout's Locale ID
;	qwSCdic := getPklInfo( "QWSCdic" )  					; KLM-2-SC dic
;	str .= "`nKLM`tSC`tkey" . lin
;	For klm, sc in qwSCdic { 
;		str .= Format( "`n{}`t{}`t{}", klm, SubStr(sc,3), GetKeyName(sc) )
;	}
	
	mapFile := getPklInfo( "RemapsFile" )   				; Note: OEM_8 (VKDF) is on UK QW_GR, but not ANS nor many other.
	VKQWdic := ReadKeyLayMapPDic( "VK", "QW", mapFile ) 	; KLM VK-2-QW code translation dictionary
;	SCQWdic := ReadKeyLayMapPDic( "SC", "QW", mapFile ) 	; KLM SC-2-QW code translation dictionary
	str .= "`nKLM`tqVK`tVK" . lin
	oemDic  := getWinLayVKs()   							;[ "GR","MN","PL","LB","RB","BS","SC","QU","LG","CM","PD","SL" ] 	; QW_## 	; eD WIP: Try w/ the whole SC dic!
	For oem, ovk in oemDic { 								;[ "C0","BD","BB","DB","DD","DC","BA","DE","E2","BC","BE","BF" ] 	;  VK##
		klm := VKQWdic[ oem ]   							;[ "29","0c","0d","1a","1b","2b","27","28","56","33","34","35" ] 	; SC0##
		str .= Format( "`n{}`t{}`t{}", klm, SubStr(oem,3), SubStr(ovk,3) ) 	; GetKeyName(sc), GetKeyVK(sc), SubStr(sc,3) )
		str .= InStr( "_GR|_LG", VKQWdic[oem] ) ? lin : "" 	; "VKC0|VKE2" "VKBD|VKDB|VKE2"
	}
	pklDebug( str, 60 )
}

menuIconList() {    										; Taken from the AHK_MenuIconList.ahk script
	;;  Author: Jack Dunning, modified from online documentation at
	;;          https://autohotkey.com/docs/commands/ListView.htm#IL
	;;  Script Function:
	;;          Explore and select icons from any Windows file which embeds icon images (.exe, .dll, etc.)
	global iconFile                     					; Global so MenuIconNum can see it
	iconFile    := ""                   					; Needs to be reset each run
	defIcoPath  := "C:\Windows\System32\shell32.dll"
	FileSelectFile, iconFile, 32, %defIcoPath%, Pick a file to check icons., *.*
	If ( iconFile == "" )
		Return
	GUI, MIL:Font, s20
	GUI, MIL:Add, ListView, h415 w150 gMenuIconNum, Icons 	; Uses a ListView GUI (https://www.autohotkey.com/docs/v1/lib/ListView.htm)
	GUI, MIL:Default                    					; Necessary for LV_ commands, it seems
	ImageListID := IL_Create(10,1,1)    					; Create a LV ImageList to hold 10 small icons
	LV_SetImageList(ImageListID,1)      					; Assign the above ImageList to the current ListView
	Loop {                              					; Load the ImageList with a series of icons from the DLL
		 IconCount := Image             					; Number of icons found
		 Image := IL_Add(ImageListID, iconFile, A_Index) 	; Omits the DLL's path so that it works on Windows 9x too
		 If (Image == 0)                					; When we run out of icons
		   Break
	   }
	Loop % IconCount {                  					; Add rows to the ListView (for demonstration purposes, one for each icon)
		LV_Add("Icon" . A_Index, "     " . A_Index)
	}
	LV_ModifyCol("Hdr")                 					; Auto-adjust the column widths
	GUI, MIL:Show
	Return
}

MenuIconNum:
	Clipboard := iconFile . ", " . A_EventInfo
	Msgbox % "'" . Clipboard . "'`n     added to Clipboard!"
Return

;;  ========================================================================================================================================================
;;  AHK v1 --> v2 Transition
;;      The transition from AHK v1 to v2 seems very promising, but needs some work.
;;      One thing that may ease it, would be to make some deprecated commands into temporary functions.
;;      https://www.autohotkey.com/docs/v2/v2-changes.htm
;
;;  Blow-by-blow:
;;    - All `var = value` assignments have to go (replace with `:=`). Also ` = ` in conditions (replace with `==`).
;;    - Normal variable references are never enclosed in percent signs (%variable%)
;;    - All old `if` are gone; `if expression` stays
;;    - Super-globals are gone
;;    - Gosub is gone. What to use for it?
;;    - Sleep: No changes necessary? They say that all commands have become functions but the old syntax is still described on its help page for v2.
;;        - It's because functions can be called without parentheses if the return value is not needed (except when called within an expression).
;

Sleep( delay ) {    																	; Wrapper function, pending AHK v2 transition: Sleep
	Sleep % delay
}

IniRead( Filename, Section := "", Key := "", Default := "ERROR" ) { 					; Wrapper function, pending AHK v2 transition: IniRead
	IniRead, val, % Filename, % Section, % Key, % Default   							; Reading only a section (list) should work with this one
	Return val
}
