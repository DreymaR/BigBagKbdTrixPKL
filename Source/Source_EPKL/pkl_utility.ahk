;; ================================================================================================
;;  Remap module
;;      Functions to read and parse remap cycles for ergo mods and suchlike
;;      Used primarily in pkl_init.ahk
;
ReadRemaps( mapList, mapStck ) { 					; Parse a remap string to a CSV list of cycles (used in pkl_init)
	mapCycList  := "" 											; Name -> actual list, or literal list
	For ix, alist in pklIniCSVs( mapList, mapList, mapStck, "Remaps" ) { 	; mapFile
		tmpCycle    := "" 							; Above, mapList is default to use a map unless it refers to another
		For ix, list in StrSplit( alist, "+", " `t" ) { 		; Parse merges by plus sign
			if ( SubStr( list, 1, 1 ) == "^" ) { 				; A cycle reference...
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
	mapFile := IsObject( mapStck ) ? mapStck[mapStck.MaxIndex()] : mapStck 		; Use a file stack, or just one file
	mapType := upCase( SubStr( mapType, 1, 2 ) ) 				; MapTypes: (sc|vk)map(Lay|Ext|Mec) => SC|VK
	pdic    := {}
	if ( mapType == "SC" )										; Create a fresh SC pdic from mapFile KeyLayMap
		pdic := ReadKeyLayMapPDic( "SC", "SC", mapFile )
	rdic    := pdic.Clone()										; Reverse dictionary (instead of if loop)?
	tdic	:= {}												; Temporary dictionary used while mapping loops
	For ix, clist in StrSplit( mapList, ",", " `t" ) { 			; Parse cycle list by comma
		fullCycle := ""
		For ix, plist in StrSplit( clist, "+", " `t" ) { 		; Parse and merge composite cycles by plus sign
			thisCycle := pklIniRead( plist , "", mapStck, "RemapCycles" ) 	; mapFile
			if ( not thisCycle )
				pklWarning( "Remap element '" . plist . "' not found", 3 )
			thisType  := SubStr( thisCycle, 1, 2 )				; KLM map type, such as TC for TMK-like Colemak
;			rorl      := ( SubStr( thisCycle, 3, 1 ) == "<" ) ? -1 : 1		; eD TODO: R(>) or L(<) cycle?
			thisCycle := RegExReplace( thisCycle, "^.*?\|(.*)\|$", "$1" )	; Strip defs and wrapping pipes
			fullCycle := fullCycle . ( ( fullCycle ) ? ( " | " ) : ( "" ) ) . thisCycle	; Merge cycles
		}	; end For plist
		if ( mapType == "SC" )									; Remap pdic from thisType to SC
			mapDic  := ReadKeyLayMapPDic( thisType, "SC", mapFile )
		For ix, minCycl in StrSplit( fullCycle, "/", " `t" ) { 	; Parse cycle to minicycles:  | a | b / c | d | e |
			thisCycle   := StrSplit( minCycl, "|", " `t" ) 		; Parse cycle by pipe, and create mapping pdic
			numSteps    := thisCycle.MaxIndex()
			Loop % numSteps { 									; Loop to get proper key codes
				this := thisCycle[ A_Index ]
				if ( mapType == "SC" ) { 						; Remap from thisType to SC
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
	Loop % 5 {													; Loop through KLM rows 0-4
		keyRow := pklIniCSVs( keyType . ( A_Index - 1 ), "", mapFile, "KeyLayoutMap", "|" ) 	; Split by pipe
		valRow := pklIniCSVs( valType . ( A_Index - 1 ), "", mapFile, "KeyLayoutMap", "|" ) 	; --"--
		For ix, key in keyRow { 								; (Robust against keyRow shorter than valRow)
			if ( ix > valRow.MaxIndex() ) 						; End of val row
				Break
			if ( not key ) 										; Empty key entry (e.g., double pipes)
				Continue
			key := ( keyType == "SC" ) ? upCase( key ) : key 	; ensure caps for SC### key
			key := ( keyType == "VK" ) ? getVKnrFromName( key ) : key
			val := upCase( valRow[ ix ] )
			val := ( valType == "VK" ) ? getVKnrFromName( val ) : val
			pdic[ key ] := val 									; e.g., pdic[ "SC001" ] := "VK1B"
		}	; end For key
	}	; end Loop KLM rows
	Return pdic
}	; end fn

;; ================================================================================================
;;  EPKL janitor/activity module
;;      Check for idleness (no clicks/keypresses), suspend EPKL by time/app, perform cleanup etc.
;

pklJanitorTic:
	_pklSuspendByApp()
	_pklJanitorActivity()
	_pklJanitorLocaleVK()
;	_pklJanitorCleanup() 	; eD WIP: Testing EPKL without the idle keyups
Return

_pklSuspendByApp() { 											; Suspend EPKL if certain windows are active
	static suspendedByApp := false 								; (Their attributes are in the Settings file)
	
	if WinActive( "ahk_group SuspendingApps" ) { 				; If a specified window is active...
		if ( not suspendedByApp ) { 							; ...and not already A_IsSuspended...
			suspendedByApp := true
			Gosub suspendOn
		}
	} else if ( suspendedByApp ) {
		suspendedByApp := false
		Gosub suspendOff
	}
}

_pklJanitorActivity() {
	suspTime := getPklInfo( "suspendTimeOut" ) * 60000 			; Convert from min to ms
	exitTime := getPklInfo( "exitAppTimeOut" ) * 60000 			; Convert from min to ms
	idleTime := A_TimeIdle 										; eD WIP: Use TimeIdlePhysical instead?
	if ( exitTime && idleTime > exitTime ) {
		Gosub exitPKL
	} else if ( suspTime && not A_IsSuspended && idleTime > suspTime ) {
		Gosub suspendOn
	}
}

_pklJanitorLocaleVK() { 										; Renew VK codes: OEM key VKs vary by locale for ISO system layouts
	if ( A_TimeIdle < 2000 ) 									; Don't do this if the comp isn't unused for at least 2 s
		Return
	oldLID  := getPklInfo( "previousLocaleID" )
	newLID  := getWinLocaleID()
	if ( oldLID != newLid ) {
;		( 1 ) ? pklDebug( "System layout LID change: " . oldLID . "->" . newLID, 1 )  ; eD DEBUG
		setPklInfo( "oemVKdic", detectCurrentWinLayOEMs() )
		; eD WIP: Renew the OEM VK mappings here! Rethink strategy? Need to map based on the values you want, based on KLM/SC codes.
	}
	setPklInfo( "previousLocaleID", newLID )
}

_pklJanitorCleanup() {
	timeOut := getPklInfo( "cleanupTimeOut" ) * 1000 			; The timeout in s is converted to ms
	if ( A_TimeIdle > timeOut ) { 					 			; eD WIP: Use TimeIdlePhysical w/ mouse hook as well?
		if getPklInfo( "cleanupDone" ) 							; Avoid repeating this every timer interval 	; eD WIP: Or use a one-shot timer instead?
			Return
		if not ExtendIsPressed()
			extendKeyPress( -1 ) 								; Clean up any loose Ext mods
		For ix, mod in [ "LShift", "LCtrl", "LAlt", "LWin" 			; "Shift", "Ctrl", "Alt", "Win" are just the L# mods
					   , "RShift", "RCtrl", "RAlt", "RWin" ] { 		; eD WIP: What does it take to ensure no stuck mods?
			if getKeyState( mod ) {
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

;; ================================================================================================
;;  Utility functions
;;      These are minor utility functions used by other parts of EPKL
;

pklMsgBox( msg, s = "", p = "", q = "", r = "" ) { 				; Seems this is only used once in pkl_init now?
	msg := getPklInfo( "LocStr_" . msg )
	For ix, it in [ "s", "p", "q", "r" ] {
		msg := ( %it% == "" ) ? msg : StrReplace( msg, "#" . it . "#", %it% )
	}
	MsgBox % msg
}

pklErrorMsg( text ) {
	MsgBox, 0x10, EPKL ERROR, %text%`n`nError # %A_LastError% 	; Error type message box
}

pklWarning( text, time = 5 ) {
	MsgBox, 0x30, EPKL WARNING, %text%, %time%					; Warning type message box
}

pklInfo( text, time = 4 ) {
	MsgBox, 0x40, EPKL INFO: , %text%, %time%					; Info type message box (asterisk)
}

pklDebug( text, time = 2 ) {
	MsgBox, 0x40, EPKL DEBUG: , %text%, %time%					; Info type message box (asterisk)
}

pklSetHotkey( hkIniName, gotoLabel, pklInfoTag ) { 				; Set a menu hotkey (used in pkl_init)
	For ix, hkey in pklIniCSVs( hkIniName ) {
		if ( hkey == "" )
			Break
		Hotkey, %hkey%, %gotoLabel%
		if ( ix == 1 )
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

detectCurrentWinLayOEMs() { 								; Find the VK values for the current Win layout's OEM keys 	; eD WIP: Map from SC, so we can keep track of how OEM keys should be mapped.
	scMap   := getPklInfo( "scMapLay" ) 					; The pdic used to remap SC for the layout
;		( 1 ) ? pklDebug( "`nSC remap for MN: " . scMap["SC00C"] . "`nSC remap for GR: " . scMap["SC029"], 1 )  ; eD DEBUG
	qSCdic  := getPklInfo( "QWSCdic" ) 						; SC QW_## 							; NOTE: Must keep track of remappings. Must not remap, e.g., Angle Z on QW_LG to its underlying VK##!
	qVKdic  := getPklInfo( "QWVKdic" ) 						; VK QW_## = vc_##
	oemDic  := {}  ;[ "29","0c","0d","1a","1b","2b","27","28","56","33","34","35" ] 	; "SC0" . SCs[ix]
	For ix, oem in  [ "GR","MN","PL","LB","RB","BS","SC","QU","LG","CM","PD","SL" ] { 	; eD WIP: Run through the whole SCdic instead?
		oem := "_" . oem
		qsc := qSCdic[ oem ]
		qvk := qVKdic[ oem ] 								; Map from a KLM (ANSI) VK## code
		ovk := Format( "VK{:X}", GetKeyVK( qsc ) ) 			; VK## format
		oemDic[qvk]  := ovk 								; GetKey##(key) gets current Name/VK/SC from a SC or VK
;	( oem == "_GR" ) ? pklDebug( "OEM: " . oem . "`nSC: " . qSCdic[oem] . "`nQVK: " . qvk . "`nOVK: " . oemDic[qvk], 6 )  ; eD DEBUG
	}
	Return oemDic
}

getVKnrFromName( name ) { 									; Get the 4-digit hex VK## code from a VK name
	name := upCase( name )
	if ( not RegExMatch( name, "^VK[0-9A-F]{2}$" ) == 1 ) {	; Check if the name is already VK##
;		Return name 	; name := SubStr( name, 3 ) 		; Used to keep only the ## here
;	} else {
		name := "VK" . pklIniRead( "VK_" . name, "00", "PklDic", "VKeyCodeFromName" )
	}
	Return name
}

getWinLocaleID() { 											; Win LID; for Language use A_Language.
	WinGet, WinID,, A
	WinThreadID := DllCall("GetWindowThreadProcessId", "Int", WinID, "Int", 0)
	WinLocaleID := DllCall("GetKeyboardLayout", "Int", WinThreadID)
	WinLocaleID := ( WinLocaleID & 0xFFFFFFFF )>>16
	Return WinLocaleID
}

fileOrAlt( file, altFile, errMsg = "", errDur = 2 ) { 		; Find a file/dir, or use the alternative
	file := atKbdType( file ) 								; Replace '@K' w/ KbdType
	if FileExist( file )
		Return file
	if ( errMsg ) && ( not FileExist( altFile ) ) 			; Issue a warning if neither file is found
		pklWarning( errMsg, errDur )
	Return altFile
}

atKbdType( str ) { 							; Replace '@K' in layout file entries with the proper KbdType (ANS/ISO...)
	Return StrReplace( str, "@K", getLayInfo( "Ini_KbdType" ) )
}

pklSplash( title, text, dur = 4.0 ) { 		; Default display duration is in seconds
	SetTimer, KillSplash, Off 				; TrayTip and SplashText are hard to kill? SplashText is also deprecated.
	Gui, pklSp:New, ToolWindow -SysMenu, %title% 	; GUI window w/ title, no buttons
	Gui, pklSp:Margin, 24 					; Horizontal margin to allow the whole window title to be shown
	Gui, PklSp:Font, s12 w500 				; Font size and weight (400 normal, 700 bold)
	Gui, pklSp:Add, Text,, %text%
	Gui, pklSp:Show 		;	TrayTip %title%, `n%text%, dur, 0x11 	;SplashTextOn, 300, 100, %title%, `n%text%
	SetTimer, KillSplash, % -1000 * dur
}

KillSplash:
	Gui, pklSp: Destroy 					;TrayTip 	;SplashTextOff
Return

getPriority(procName="") { 					; Utility function to get process priority, by SKAN from the AHK forums
	;;  https://autohotkey.com/board/topic/7984-ahk-functions-incache-cache-list-of-recent-items/page-3#entry75675
	procList := { 16384 : "BelowNorm",    32 : "Normal"   , 32768 : "AboveNorm"
				,    64 : "Low"      ,   128 : "High"     ,   256 : "Realtime"  }
	Process, Exist, %procName%
	thePID := ErrorLevel
	IfLessOrEqual, thePID, 0, Return, "Error!"
	hProcess := DllCall( "OpenProcess", Int, 1024, Int, 0, Int, thePID )
	Priority := DllCall( "GetPriorityClass", Int, hProcess )
	DllCall( "CloseHandle", Int, hProcess )
	Return % procList[ Priority ]
}

loCase( str ) {
	Return % Format( "{:L}", str )
}

upCase( str ) {
	Return % Format( "{:U}", str )
}

isInt( this ) { 											; AHK cannot use "is <type>" in expressions,
	if this is integer 										;   so use this wrapper function instead
		Return true
}

bool( val ) { 												; Convert an entry to true or false (default)
	val := loCase( val )
	Return ( val == "1" || val == "yes" || val == "y" || val == "true" ) ? true : false
}

convertToANSI( str ) { 										; Use IniRead() w/ UTF-8 keys 	; eD WIP
	dum := "--" 											; The string is written as ANSI/CP0
	VarSetCapacity( dum, StrPut( str, "UTF-8" ) ) 			; Ensure var capacity
; 		* ((codePg="utf-16"||codePg="cp1200") ? 2 : 1) ) 	;     ...in bytes (StrPut returns chars)
	len := StrPut( str, &dum, "UTF-8" ) 					; Copy/convert string (returns length in chars)
	Return StrGet( &dum, "CP0" ) 							; Return str as UTF-8
}

convertToUTF8( str ) { 										; Use IniRead() w/ UTF-8 instead of UTF-16 	; eD WIP
	dum := "--" 											; The string is read as ANSI/CP0
	VarSetCapacity( dum, StrPut( str, "CP0" ) ) 			; Ensure var capacity
; 		* ((codePg="utf-16"||codePg="cp1200") ? 2 : 1) ) 	;     ...in bytes (StrPut returns chars)
	len := StrPut( str, &dum, "CP0" ) 						; Copy/convert string (returns length in chars)
	Return StrGet( &dum, "UTF-8" ) 							; Return str as UTF-8
}

formatUni( chr ) { 											; Format a character as a hex string
	chr     := Ord( chr ) 									; Unicode ordinal value
	pad     := ( chr > 0x10000 ) ? "" : "04" 				; Pad with zeros iff ord < 0x10000, as done in X11 keysymdef.h
	Return  Format( "0x{:" . pad . "x}", chr ) 				; Format as a Unicode hex string 0x#### (4+ digits)
}

pklFileRead( file, name = "" ) { 							; Read a file
	name := ( name ) ? name : file
	try { 													; eD NOTE: Use Loop, Read, ? Nah, 160 kB or so isn't big.
		FileRead, content, *P65001 %file% 					; "*P65001 " is a way to read UTF-8 files
	} catch {
		pklErrorMsg( "Failed to read `n  " . name )
		Return false
	}
	Return content
}

pklFileWrite( content, file, name = "" ) { 					; Write/Append to a file
	name := ( name ) ? name : file
	try {
		FileAppend, %content%, %file%, UTF-8
	} catch {
		pklErrorMsg( "Failed writing to `n  " . file )
		Return false
	}
	Return true
}

thisMinute() { 												; Use A_Now (local time) for a folder or other time stamp
	FormatTime, theNow,, yyyy-MM-dd_HH-mm
	Return theNow
}

hasValue( haystack, needle ) { 								; Check if an array object has a certain value
	if !(IsObject(haystack)) || ( haystack.Length() == 0 )
		Return false
	For ix, value in haystack {
		if ( value == needle )
			Return ix
	}
	Return false
}

joinArr( array, sep = "`r`n" ) { 							; Join an array by a separator to a string
	For ix, el in array
		out .= sep . el
	Return SubStr( out, 1+StrLen(sep) ) 					; Lop off the initial separator (faster than checking in the loop)
}

debugShowCurrentWinLayOEMs() { 								; eD DEBUG: Display the VK values for the current Win layout's OEM keys
;	qwSCdic := getPklInfo( "QWSCdic" ) 						; detectCurrentWinLayOEMs maps KLM OEM VK## values to current layout ones.
	mapFile := getPklInfo( "RemapFile" )
	VKQWdic := ReadKeyLayMapPDic( "VK", "QW", mapFile ) 	; KLM VK-2-QW code translation dictionary
;	SCQWdic := ReadKeyLayMapPDic( "SC", "QW", mapFile ) 	; KLM SC-2-QW code translation dictionary
	lin := "`n————" . "————" . "————" 						; Note: OEM_8 (VKDF) is on UK QW_GR, but not ANS nor many other.
	str := "For layout LID: " . getWinLocaleID() . lin . "`nKLM`tqVK`tVK" . lin
	oemDic  := detectCurrentWinLayOEMs() 					;[ "GR","MN","PL","LB","RB","BS","SC","QU","LG","CM","PD","SL" ] 	; QW_##
	For oem, ovk in oemDic { 								;[ "C0","BD","BB","DB","DD","DC","BA","DE","E2","BC","BE","BF" ] 	;  VK##
		klm := SubStr( VKQWdic[ oem ], 2) 					;[ "29","0c","0d","1a","1b","2b","27","28","56","33","34","35" ] 	; SC0##
		str .= Format( "`n{}`t{}`t{}", klm, SubStr(oem,3), SubStr(ovk,3) ) 	; GetKeyName(sc), GetKeyVK(sc), SubStr(sc,3) )
		str .= InStr( "_GR|_LG", VKQWdic[oem] ) ? lin : "" 	; "VKC0|VKE2" "VKBD|VKDB|VKE2"
	}
	pklDebug( str, 60 )
}
