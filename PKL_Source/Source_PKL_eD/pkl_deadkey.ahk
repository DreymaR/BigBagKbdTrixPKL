DeadKeyValue( dkName, base )	; eD: 'dk' was just a number; translate it to a full DK name.
{
	static dkFile := ""	; eD
	dkFile := ( dkFile ) ? dkFile : getLayInfo( "dkFile" )
	
	res := getKeyInfo( "DKval_" . dkName . "_" . base )	; HashTable_Get( pdic, 
	if ( res ) {
		res := ( res == -1 ) ? 0 : res
		return res
	}
	IniRead, res, %dkFile%, dk_%dkName%, %base%, -1`t;	; deadkey%dk%, %base%, -1`t;
	tmp := InStr( res, A_Tab )
	res := SubStr( res, 1, tmp - 1 )
	setKeyInfo( "DKval_" . dkName . "_" . base, res)
	res := ( res == -1 ) ? 0 : res
	return res
}

DeadKey(DK)
{
	global gP_CurrNumOfDKs	; eD: Current # of dead keys active
	global gP_CurrBaseKey_	; eD: Current base key
	global gP_CurrNameOfDK	; eD: Current dead key's name
	static PVDK := "" ; Pressed dead keys
	DK := getKeyInfo( "dk" . DK )	; eD
	DeadKeyChar := DeadKeyValue( DK, 0 )
	
	; Pressed a deadkey twice
	if ( gP_CurrNumOfDKs > 0 && DK == gP_CurrNameOfDK )
	{
		pkl_Send( DeadKeyChar )
		return
	}

	gP_CurrNameOfDK := DK
	gP_CurrNumOfDKs++
	Input, nk, L1, {F1}{F2}{F3}{F4}{F5}{F6}{F7}{F8}{F9}{F10}{F11}{F12}{Left}{Right}{Up}{Down}{Home}{End}{PgUp}{PgDn}{Del}{Ins}{BS}
	IfInString, ErrorLevel, EndKey
	{
		endk := "{" . Substr(ErrorLevel,8) . "}"
		gP_CurrNumOfDKs = 0
		gP_CurrBaseKey_ = 0
		pkl_Send( DeadKeyChar )
		Send %endk%
		return
	}

	if ( gP_CurrNumOfDKs == 0 ) {
		pkl_Send( DeadKeyChar )
		return
	}
	if ( gP_CurrBaseKey_ != 0 ) {
		hx := gP_CurrBaseKey_
		nk := chr(hx)
	} else {
		hx := asc(nk)
	}
	gP_CurrNumOfDKs--
	gP_CurrBaseKey_ = 0
	newkey := DeadKeyValue( DK, hx )	; eD TODO: Here's where it sets the DK based on number

	if ( newkey && (newkey + 0) == "" ) {
		; New key (value) is a special string, like {Home}+{End}
		if ( PVDK ) {
			PVDK := ""
			gP_CurrNumOfDKs = 0
		}
		SendInput %newkey%
	} else if ( newkey && PVDK == "" ) {
		pkl_Send( newkey )
	} else {
		if ( gP_CurrNumOfDKs == 0 ) {
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
	DKsOfSysLayout := pklIniRead( getWinLocaleID(), "", "Pkl_Dic", "DeadKeysFromLocID" ) ; eD
	DKsOfSysLayout := ( DKsOfSysLayout == "-1" ) ? "" : DKsOfSysLayout	; eD
	if ( set == 1 ) {
		if ( newDeadkeys == "auto" )
			deadkeys := DKsOfSysLayout 	; eD: replaced getDeadKeysOfSystemsActiveLayout()
		else if ( newDeadkeys == "dynamic" )
			deadkeys := 0
		else
			deadkeys := newDeadkeys
		return
	}
	if ( deadkeys == 0 )
		return DKsOfSysLayout 			; eD: replaced getDeadKeysOfSystemsActiveLayout()
	else
		return deadkeys
}
