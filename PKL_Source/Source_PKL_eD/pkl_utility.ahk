;-------------------------------------------------------------------------------------
;
; Remap module (PKL_eD)
;     Functions to read and parse remap cycles for ergo mods and suchlike
;     Used primarily in pkl_init.ahk
;
ReadRemaps( mapList, mapFile )				; Parse a remap string to a CSV list of cycles (used in pkl_init)
{
	mapList     := pklIniRead( mapList, mapList, mapFile, "remaps" )	; Name -> actual list, or literal list
	mapCycList  := ""
	Loop, Parse, mapList, CSV, %A_Space%%A_Tab%						; Parse lists by comma/CSV
	{
		tmpCycle    := ""
		Loop, Parse, A_LoopField , +, %A_Space%%A_Tab%				; Parse merges by plus sign
		{
			if ( SubStr( A_LoopField , 1, 1 ) == "^" ) {			; Cycle reference
				theMap  := SubStr( A_LoopField , 2 )
			} else {
				theMap  := ReadRemaps( A_LoopField , mapFile )		; Ref. to another map -> Self recursion
			}
			tmpCycle    := tmpCycle . ( ( tmpCycle ) ? ( " + " ) : ( "" ) ) . theMap	; re-attach by +
		}	; end loop
		mapCycList  := mapCycList . ( ( mapCycList ) ? ( ", " ) : ( "" ) ) . tmpCycle	; re-attach by CSV
	}	; end loop
	Return mapCycList
}	; end fn

ReadCycles( mapType, mapList, mapFile )		; Parse a remap string to a dictionary of remaps (used in pkl_init)
{
;	test0 := mapType										; eD DEBUG
	mapType := Format( "{:U}", SubStr( mapType, 1, 2 ) )	; MapTypes: (sc|vk)map(Lay|Ext|Mec) => SC|VK
	pdic    := {}
	if ( mapType == "SC" )									; Create a fresh SC pdic from mapFile KeyLayMap
		pdic := ReadKeyLayMapPDic( "SC", "SC", mapFile )
	rdic    := pdic.Clone()									; Reverse dictionary (instead of if loop)?
	tdic	:= {}											; Temporary dictionary used while mapping loops
	Loop, Parse, mapList, CSV, %A_Space%%A_Tab%				; Parse cycle list by comma
	{
		fullCycle := ""
		Loop, Parse, A_LoopField , +, %A_Space%%A_Tab%		; Parse and merge composite cycles by plus sign
		{
			thisCycle := pklIniRead( A_LoopField , "", mapFile, "RemapCycles" )
			if ( not thisCycle )
				pklWarning( "Remap element '" . A_LoopField . "' not found", 3 )
			thisType  := SubStr( thisCycle, 1, 2 )			; KLM map type, such as TC for TMK-like Colemak
;			rorl      := ( SubStr( thisCycle, 3, 1 ) == "<" ) ? -1 : 1		; eD TODO: R(>) or L(<) cycle?
			thisCycle := RegExReplace( thisCycle, "^.*?\|(.*)\|$", "$1" )	; Strip defs and extra pipes
			fullCycle := fullCycle . ( ( fullCycle ) ? ( " | " ) : ( "" ) ) . thisCycle	; Merge cycles
		}	; end loop
		if ( mapType == "SC" )								; Remap pdic from thisType to SC
			mapDic := ReadKeyLayMapPDic( thisType, "SC", mapFile )
		thisCycle := StrSplit( fullCycle, "|", " `t" )		; Parse cycle by pipe, and create mapping pdic
		numSteps  := thisCycle.MaxIndex()
		Loop % numSteps {									; Loop to get proper key codes
			this := thisCycle[ A_Index ]
			if ( mapType == "SC" ) {						; Remap from thisType to SC
				thisCycle[ A_Index ] := mapDic[ this ]
			} else if ( mapType == "VK" )  {				; Remap from VK name/code to VK code
				thisCycle[ A_Index ] := getVKeyCodeFromName( this )
			}	; end if
		}	; end loop
;		test3 := test3 . ( ( test3 ) ? ( "`n" ) : ( "" ) ) . "|" . fullCycle	; DEBUG
		Loop % numSteps {									; Loop to (re)write remap pdic
			this := thisCycle[ A_Index ]					; This key's code gets remapped to...
			this := ( mapType == "SC" ) ? rdic[ this ] : this	; When chaining maps, map the remapped key ( a→b→c )
			that := ( A_Index == numSteps ) ? thisCycle[ 1 ] : thisCycle[ A_Index + 1 ]	; ...next code
			pdic[ this ] := that							; Map the (remapped?) code to the next one
			tdic[ that ] := this							; Keep the reverse mapping for later cycles
		}	; end loop (remap one full cycle)
		for key, val in tdic 
			rdic[ key ] := val								; Activate the lookup dict for the next cycle
	}	; end loop (parse CSV)
;; eD remapping cycle notes:
;; Need this:    ( a | b | c , b | d )                           => 2>:[ a:b:d, b:c, c:a, d:b   ]
;; With rdic: 1<:[ b:a, c:b, a:c, d:d ] => 2>:[ r[b]:d, r[d]:b ] => 2>:[ a:d  , b:c, c:a, d:b   ]
;; Note that:    ( b | d , a | b | c )                           => 2>:[ a:b  , b:d, c:a, d:b:c ] - so order matters!
;; Lay(CAW): 022(Cmk-D) -> 02E(Cmk-C); 023(Cmk-H) -> 033(Cmk-,); 024(Cmk-N) -> 025(Cmk-E)
;; Ext(AWi): 022(Cmk-D) -> 022(Cmk-D); 023(Cmk-H) -> 024(Cmk-N); 030(Cmk-B) -> 02F(Cmk-V) -> 02E(Cmk-C) -> 02D(Cmk-X)
;	if ( test0 == "" . "scMapLay" ) {		; DEBUG
;	test1 := pdic[ "SC012" ] . " " . pdic[ "SC022" ] . " " . pdic[ "SC02F" ] . " " . pdic[ "SC02E" ] . " " . pdic[ "SC023" ] . " " . pdic[ "SC032" ]
;	test2 := rdic[ "SC012" ] . " " . rdic[ "SC022" ] . " " . rdic[ "SC02F" ] . " " . rdic[ "SC02E" ] . " " . rdic[ "SC023" ] . " " . rdic[ "SC032" ]
;	MsgBox, Debug %test0%:`n SC012 SC022 SC02F SC02E SC023 SC032 `n __E/F___G/D____V_____C_____H_____M___ `n %test1% `n %test2% `n`n%test3%
;	}		; end DEBUG
	Return pdic
}	; end fn

ReadKeyLayMapPDic( keyType, valType, mapFile )	; Create a pdic from a pair of KLMaps in a remap.ini file
{
	pdic := {}
	Loop % 5 {											; Loop through KLM rows 0-4
		keyRow := pklIniRead( keyType . ( A_Index - 1 ), "", mapFile, "KeyLayoutMap" )
		valRow := pklIniRead( valType . ( A_Index - 1 ), "", mapFile, "KeyLayoutMap" )
		valRow := StrSplit( valRow, "|", " `t" )
		Loop, Parse, keyRow, |, %A_Space%%A_Tab%	; (Robust against keyRow shorter than valRow)
		{
			if ( A_Index > valRow.MaxIndex() )		; End of val row
				Break
			if ( not A_LoopField )					; Empty key entry (e.g., double pipes)
				Continue
			key := A_LoopField
			val := valRow[ A_Index ]
			if ( keyType == "SC" )					; ensure upper case for SC###
				key := Format( "{:U}", key )
			pdic[ key ] := Format( "{:U}", val )	; e.g., pdic[ "SC001" ] := "SC001"
		}	; end loop
	}	; end loop
	Return pdic
}	; end fn

;-------------------------------------------------------------------------------------
;
; PKL activity module
;     Check for inactivity (no clicks/keypresses) in a given period
;
activity_ping(mode = 1) {
	activity_main(mode, 1)
}

activity_setTimeout(mode, timeout) {
	activity_main(mode, 2, timeout)
}

activity_main(mode = 1, ping = 1, value = 0) {
	static mode1ping := 0
	static mode2ping := 0
	static mode1timeout := 0
	static mode2timeout := 0
	if ( ping == 1 ) {
		mode%mode%ping := A_TickCount
	} else if ( ping == 2 ) {
		mode%mode%timeout := value
	}
	Return

	activityTimer:
	if ( mode1timeout > 0 && A_TickCount - mode1ping > mode1timeout * 60000 ) {
		if ( not A_IsSuspended ) {
			gosub toggleSuspend
			activity_ping( 2 )
			Return
		}
	}
	if ( mode2timeout > 0 && A_TickCount - mode2ping > mode2timeout * 60000 ) {
		gosub ExitPKL
		Return
	}
	Return
}

;-------------------------------------------------------------------------------------
;
; Utility functions
;     These are minor utility functions used by other parts of PKL
;

pklMsgBox( msg, s = "", p = "", q = "", r = "" )
{
	msg := getPklInfo( "LocStr_" . msg )
	Loop, Parse, % "spqr"
	{
		it := A_LoopField
		msg := ( %it% == "" ) ? msg : StrReplace( msg, "#" . it . "#", %it% )
	}
	MsgBox % msg
}

pklErrorMsg( text )
{
	MsgBox, 0x10, PKL ERROR, %text%`n`nError # %A_LastError%	; PKL Error type message box
}

pklWarning( text, time = 5 )
{
	MsgBox, 0x30, PKL WARNING, %text%, %time%					; PKL Warning type message box
}

pklSetHotkey( hkStr, gotoLabel, pklInfoTag )					; Set a PKL menu hotkey (used in pkl_init)
{
	if ( hkStr <> "" ) {
		Loop, Parse, hkStr, `,
		{
			Hotkey, %A_LoopField%, %gotoLabel%
			if ( A_Index == 1 )
				setPklInfo( pklInfoTag, A_LoopField )
		}	; end loop
	}	; end if
}	; end fn

getVKeyCodeFromName( name )	; Get the two-digit hex VK## code from a VK name
{
	name := Format( "{:U}", name )
	if ( RegExMatch( name, "^VK[0-9A-F]{2}$" ) == 1 ) {		; Check if the name is already VK##
		name := SubStr( name, 3 )							; Keep only the ## here
	} else {
		name := pklIniRead( "VK_" . name, "00", "Pkl_Dic", "VKeyCodeFromName" )
	}
	Return name
}

getWinLocaleID()			; This was in the detect/get functions
{
	WinGet, WinID,, A
	WinThreadID := DllCall("GetWindowThreadProcessId", "Int", WinID, "Int", 0)
	WinLocaleID := DllCall("GetKeyboardLayout", "Int", WinThreadID)
	WinLocaleID := ( WinLocaleID & 0xFFFFFFFF )>>16
	Return WinLocaleID
}

isInt( this ) {		; AHK cannot use "is <type>" in expressions so use a wrapper function
	if this is integer
		Return true
}

fileOrAlt( file, default, errMsg = "", errDur = 2 )		; Find a file/dir, or use the alternative
{
	if FileExist( file )
		Return file
	if ( errMsg ) && ( not FileExist( default ) )		; Issue a warning if neither file is found
		pklWarning( errMsg, errDur )
	Return default
}

pklSplash( title, text, dur = 8 ) {		; Default display duration is in seconds
	SplashTextOff
	SetTimer, KillSplash, Off
	SplashTextOn, 300, 100, %title%, `n%text%
	SetTimer, KillSplash, % -1000 * dur
}

KillSplash:
	SplashTextOff
Return

getPriority(procName="") {				; Utility function to get process priority, by SKAN from the AHK forums
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
