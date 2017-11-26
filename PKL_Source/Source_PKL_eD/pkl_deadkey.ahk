DeadKeyValue( dk, base )
{
	global gPv_LayIniFil	; eD: "layout.ini"
	
	static file := ""
	static pdic := 0
	if ( file == "" ) {
		file := getLayoutInfo( "dir" ) . "\" . gPv_LayIniFil
		pdic := HashTable_New()
	}
	
	res := HashTable_Get( pdic, dk . "_" . base )
	if ( res ) {
		if ( res == -1 )
			res = 0
		return res
	}
	IniRead, res, %file%, deadkey%dk%, %base%, -1`t;
	tmp := InStr( res, A_Tab )
	res := SubStr( res, 1, tmp - 1 )
	HashTable_Set( pdic, dk . "_" . base, res)
	if ( res == -1 )
		res = 0
	return res
}

DeadKey(DK)
{
	global gPv_CurDKsNum	; eD: Current # of dead keys active
	global gPv_CurBasKey	; eD: Current base key
	global gPv_CurDKName	; eD: Current dead key's name
	static PVDK := "" ; Pressed dead keys
	DeadKeyChar := DeadKeyValue( DK, 0 )

	; Pressed a deadkey twice
	if ( gPv_CurDKsNum > 0 && DK == gPv_CurDKName )
	{
		pkl_Send( DeadKeyChar )
		return
	}

	gPv_CurDKName := DK
	gPv_CurDKsNum++
	Input, nk, L1, {F1}{F2}{F3}{F4}{F5}{F6}{F7}{F8}{F9}{F10}{F11}{F12}{Left}{Right}{Up}{Down}{Home}{End}{PgUp}{PgDn}{Del}{Ins}{BS}
	IfInString, ErrorLevel, EndKey
	{
		endk := "{" . Substr(ErrorLevel,8) . "}"
		gPv_CurDKsNum = 0
		gPv_CurBasKey = 0
		pkl_Send( DeadKeyChar )
		Send %endk%
		return
	}

	if ( gPv_CurDKsNum == 0 ) {
		pkl_Send( DeadKeyChar )
		return
	}
	if ( gPv_CurBasKey != 0 ) {
		hx := gPv_CurBasKey
		nk := chr(hx)
	} else {
		hx := asc(nk)
	}
	gPv_CurDKsNum--
	gPv_CurBasKey = 0
	newkey := DeadKeyValue( DK, hx )

	if ( newkey && (newkey + 0) == "" ) {
		; New key (value) is a special string, like {Home}+{End}
		if ( PVDK ) {
			PVDK := ""
			gPv_CurDKsNum = 0
		}
		SendInput %newkey%
	} else if ( newkey && PVDK == "" ) {
		pkl_Send( newkey )
	} else {
		if ( gPv_CurDKsNum == 0 ) {
			pkl_Send( DeadKeyChar )
			if ( PVDK ) {
				StringTrimRight, PVDK, PVDK, 1
				StringSplit, DKS, PVDK, " "
				Loop %DKS0% {
					pkl_Send( DKS%A_Index% )
				}
				PVDK := ""
			}
		} else {
			PVDK := DeadKeyChar  . " " . PVDK
		}
		pkl_Send( hx )
	}
}

setDeadKeysInCurrentLayout( deadkeys )
{
	getDeadKeysInCurrentLayout( deadkeys, 1 )
}

getDeadKeysInCurrentLayout( newDeadkeys = "", set = 0 )
{
	; eD TODO: Make PKL sensitive to a change of underlying Windows LocaleID?! Use SetTimer?
	static deadkeys := 0
	if ( set == 1 ) {
		if ( newDeadkeys == "auto" )
			deadkeys := getDeadKeysOfSystemsActiveLayout()
		else if ( newDeadkeys == "dynamic" )
			deadkeys := 0
		else
			deadkeys := newDeadkeys
		return
	}
	if ( deadkeys == 0 )
		return getDeadKeysOfSystemsActiveLayout()
	else
		return deadkeys
}
