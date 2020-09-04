;;  -----------------------------------------------------------------------------------------------
;;
;;  Remap module
;;      Functions to read and parse remap cycles for ergo mods and suchlike
;;      Used primarily in pkl_init.ahk
;
ReadRemaps( mapList, mapFile )				; Parse a remap string to a CSV list of cycles (used in pkl_init)
{
	mapCycList  := ""
	For ix, alist in pklIniCSVs( mapList, mapList, mapFile, "remaps" ) { 	; Name -> actual list, or literal list
		tmpCycle    := ""
		For ix, list in StrSplit( alist, "+", " `t" ) { 		; Parse merges by plus sign
			if ( SubStr( list, 1, 1 ) == "^" ) { 				; Cycle reference
				theMap  := SubStr( list, 2 )
			} else {
				theMap  := ReadRemaps( list, mapFile ) 			; Ref. to another map -> Self recursion
			}
			tmpCycle    := tmpCycle . ( ( tmpCycle ) ? ( " + " ) : ( "" ) ) . theMap 	; re-attach by +
		}	; end For list
		mapCycList  := mapCycList . ( ( mapCycList ) ? ( ", " ) : ( "" ) ) . tmpCycle 	; re-attach by CSV
	}	; end For alist
	Return mapCycList
}	; end fn

ReadCycles( mapType, mapList, mapFile )		; Parse a remap string to a dictionary of remaps (used in pkl_init)
{
	mapType := upCase( SubStr( mapType, 1, 2 ) ) 				; MapTypes: (sc|vk)map(Lay|Ext|Mec) => SC|VK
	pdic    := {}
	if ( mapType == "SC" )										; Create a fresh SC pdic from mapFile KeyLayMap
		pdic := ReadKeyLayMapPDic( "SC", "SC", mapFile )
	rdic    := pdic.Clone()										; Reverse dictionary (instead of if loop)?
	tdic	:= {}												; Temporary dictionary used while mapping loops
	For ix, clist in StrSplit( mapList, ",", " `t" ) { 			; Parse cycle list by comma
		fullCycle := ""
		For ix, plist in StrSplit( clist, "+", " `t" ) { 		; Parse and merge composite cycles by plus sign
			thisCycle := pklIniRead( plist , "", mapFile, "RemapCycles" )
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
					thisCycle[ A_Index ] := getVKeyCodeFromName( this ) 	; VK maps use VK## format codes
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

ReadKeyLayMapPDic( keyType, valType, mapFile )	; Create a pdic from a pair of KLMaps in a remap.ini file
{
	pdic := {}
	Loop % 5 {													; Loop through KLM rows 0-4
		keyRow := pklIniCSVs( keyType . ( A_Index - 1 ), "", mapFile, "KeyLayoutMap", "|" ) 	; Split by pipe
		valRow := pklIniCSVs( valType . ( A_Index - 1 ), "", mapFile, "KeyLayoutMap", "|" ) 	; --"--
		For ix, key in keyRow { 								; (Robust against keyRow shorter than valRow)
			if ( ix > valRow.MaxIndex() ) 						; End of val row
				Break
			if ( not key ) 										; Empty key entry (e.g., double pipes)
				Continue
			key := ( keyType == "SC" ) ? upCase( key ) : key 	; ensure caps for SC###
			pdic[ key ] := upCase( valRow[ ix ] ) 				; e.g., pdic[ "SC001" ] := "SC001"
		}	; end For key
	}	; end Loop KLM rows
	Return pdic
}	; end fn

;;  -----------------------------------------------------------------------------------------------
;;
;;  EPKL janitor/activity module
;;      Check for idleness (no clicks/keypresses), suspend EPKL by time/app
;

pklJanitorTic:
	_pklSuspendByApp()
	_pklActivity()
	_pklCleanup()
Return

_pklSuspendByApp() { 								; Suspend EPKL if certain windows are active
	static suspendedByApp := false 					; (Their attributes are in the Settings file)
	
	if WinActive( "ahk_group SuspendingApps" ) { 	; If a specified window is active...
		if ( not suspendedByApp ) { 				; ...and not already A_IsSuspended...
			suspendedByApp := true
			gosub suspendOn
		}
	} else if ( suspendedByApp ) {
		suspendedByApp := false
		gosub suspendOff
	}
}

_pklActivity() {
	suspTime := getPklInfo( "suspendTimeOut" ) * 60000 	; Convert from min to ms
	exitTime := getPklInfo( "exitAppTimeOut" ) * 60000 	; Convert from min to ms
	idleTime := A_TimeIdle 								; eD WIP: Use TimeIdlePhysical instead?
	if ( exitTime && idleTime > exitTime ) {
		gosub exitPKL
	} else if ( suspTime && not A_IsSuspended && idleTime > suspTime ) {
		gosub suspendOn
	}
}

_pklCleanup() {
	timeOut := getPklInfo( "cleanupTimeOut" ) * 1000 	; The timeout in s is converted to ms
	if ( A_TimeIdle > timeOut ) { 					 	; eD WIP: Use TimeIdlePhysical w/ mouse hook as well?
		if getPklInfo( "cleanupDone" ) 					; Avoid repeating this every timer interval 	; eD WIP: Or use a one-shot timer instead?
			Return
		For ix, mod in [ "LShift", "LCtrl", "LAlt", "LWin" 			; "Shift", "Ctrl", "Alt", "Win" are just the L# mods
					   , "RShift", "RCtrl", "RAlt", "RWin" ] { 		; eD WIP: What does it take to ensure no stuck mods?
			if getKeyState( mod ) {
				Return 									; If the key is being held down, leave it be
			} else {
				Send % "{" . mod . " Up}" 				; eD TOFIX: This doesn't help with Extend mods etc!?
			}
		}	; end For mod
		setPklInfo( "cleanupDone", true )
	} else if ( A_TimeIdlePhysical < timeOut ) { 		; Sending the up mods above resets TimeIdle but not TimeIdlePhysical
		setPklInfo( "cleanupDone", false ) 				; Recent keyboard activity reactivates the cleanup timer
	}
}

;;  -----------------------------------------------------------------------------------------------
;;
;;  Utility functions
;;      These are minor utility functions used by other parts of EPKL
;

pklMsgBox( msg, s = "", p = "", q = "", r = "" ) 		; Seems this is only used once in pkl_init now?
{
	msg := getPklInfo( "LocStr_" . msg )
	For ix, it in [ "s", "p", "q", "r" ] {
		msg := ( %it% == "" ) ? msg : StrReplace( msg, "#" . it . "#", %it% )
	}
	MsgBox % msg
}

pklErrorMsg( text )
{
	MsgBox, 0x10, EPKL ERROR, %text%`n`nError # %A_LastError%	; Error type message box
}

pklWarning( text, time = 5 )
{
	MsgBox, 0x30, EPKL WARNING, %text%, %time%					; Warning type message box
}

pklDebug( text, time = 2 )
{
	MsgBox, 0x40, EPKL DEBUG: , %text%, %time%					; Info type message box (asterisk)
}

pklSetHotkey( hkIniName, gotoLabel, pklInfoTag ) 				; Set a menu hotkey (used in pkl_init)
{
	For ix, hkey in pklIniCSVs( hkIniName ) {
		if ( hkey == "" )
			Break
		Hotkey, %hkey%, %gotoLabel%
		if ( ix == 1 )
			setPklInfo( pklInfoTag, hkey )
	}	; end For hkey
}	; end fn

getWinInfo() 												; Get match info for the active window
{ 															; This info is useful for setting SuspendingApps
	WinGetClass, awClass, A
	WinGet,      awProcs, ProcessName, A 					; Alternatives: ProcessName, ProcessPath
	WinGetTitle, awTitle, A
	pklDebug( "Active window properties:`n" 				; Add ID? PID? Probably not necessary.
			. "`nClass: "   . awClass 						; Use w/ ahk_class match
			. "`nExe:    "  . awProcs 						; Use w/ ahk_exe match
			. "`nTitle:   " . awTitle 						; Use w/ direct title match
			. "`n" , 10 )
}

getVKeyCodeFromName( name ) 								; Get the two-digit hex VK## code from a VK name
{
	name := upCase( name )
	if ( RegExMatch( name, "^VK[0-9A-F]{2}$" ) == 1 ) {		; Check if the name is already VK##
		name := SubStr( name, 3 )							; Keep only the ## here
	} else {
		name := pklIniRead( "VK_" . name, "00", "PklDic", "VKeyCodeFromName" )
	}
	Return name
}

getWinLocaleID() 											; Win LID; for Language use A_Language.
{
	WinGet, WinID,, A
	WinThreadID := DllCall("GetWindowThreadProcessId", "Int", WinID, "Int", 0)
	WinLocaleID := DllCall("GetKeyboardLayout", "Int", WinThreadID)
	WinLocaleID := ( WinLocaleID & 0xFFFFFFFF )>>16
	Return WinLocaleID
}

isInt( this ) { 	; AHK cannot use "is <type>" in expressions so use a wrapper function
	if this is integer
		Return true
}

fileOrAlt( file, default, errMsg = "", errDur = 2 ) 		; Find a file/dir, or use the alternative
{
	file := atKbdType( file ) 								; Replace '@K' w/ KbdType
	if FileExist( file )
		Return file
	if ( errMsg ) && ( not FileExist( default ) ) 			; Issue a warning if neither file is found
		pklWarning( errMsg, errDur )
	Return default
}

atKbdType( str ) 	; Replace '@K' in layout file entries with the proper KbdType (ANS/ISO...)
{
	Return StrReplace( str, "@K", getLayInfo( "Ini_KbdType" ) )
}

pklSplash( title, text, dur = 6 ) { 	; Default display duration is in seconds
	SplashTextOff
	SetTimer, KillSplash, Off
	SplashTextOn, 300, 100, %title%, `n%text%
	SetTimer, KillSplash, % -1000 * dur
}

KillSplash:
	SplashTextOff
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
