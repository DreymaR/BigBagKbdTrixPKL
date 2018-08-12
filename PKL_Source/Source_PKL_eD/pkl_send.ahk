pkl_Send( ch, modif = "" )
{
	static SpaceWasSentForDeadkeys = 0
	
	if ( getKeyInfo( "CurrNumOfDKs" ) == 0 ) {
		SpaceWasSentForDeadkeys = 0
	} else {
		setKeyInfo( "CurrBaseKey_", ch )
		if ( SpaceWasSentForDeadkeys == 0 )
			Send {Space}
		SpaceWasSentForDeadkeys = 1
		return
	}
	
	if ( 32 < ch ) {			;&& ch < 128 ) {
		char := "{" . chr(ch) . "}"
		if ( inStr( getDeadKeysInCurrentLayout(), chr(ch) ) )
			char .= "{Space}"
	} else if ( ch == 32 ) {
		char = {Space}
	} else if ( ch == 9 ) {
		char = {Tab}
	} else if ( ch > 0 && ch <= 26 ) {
		; http://en.wikipedia.org/wiki/Control_character#How_control_characters_map_to_keyboards
		char := "^" . chr( ch + 64 )	; Send Ctrl char
	} else if ( ch == 27 ) {
		char = ^{VKDB}	; Ctrl + [ (OEM_4) alias Escape				; eD TODO: Is this robust with ANSI/ISO VK?
	} else if ( ch == 28 ) {
		char = ^{VKDC}	; Ctrl + \ (OEM_5) alias File Separator(?)
	} else if ( ch == 29 ) {
		char = ^{VKDD}	; Ctrl + ] (OEM_6) alias Group Separator(?)
;	} else {
;		Unicode
;		sendU(ch)
;		return
	}
	pkl_SendThis( modif, char )
}

pkl_SendThis( modif, toSend )
{
	toggleAltgr := _getAltGrState()
	prefix := ""

	if ( toggleAltgr )
		_setAltGrState( 0 )

	if ( inStr( modif, "!" ) && getKeyState("Alt") )
		prefix = {Blind}

	Send, %prefix%%modif%%toSend%

	if ( toggleAltgr )
		_setAltGrState( 1 )
}

;-------------------------------------------------------------------------------------
;
; Set/get key states 
;     Process states of modifiers. Used by Send, and in PKL_main.
;

setModifierState( modifier, isdown )
{
	getModifierState( modifier, isdown, 1 )
}

getModifierState( modifier, isdown = 0, set = 0 )
{
	if ( modifier == "AltGr" )
		return _getAltGrState( isdown, set ) ; For better performance
	
	if ( set == 1 ) {
		if ( isdown == 1 ) {
			setKeyInfo( "ModState_" . modifier, 1 )
			Send {%modifier% Down}
		} else {
			setKeyInfo( "ModState_" . modifier, 0 )
			Send {%modifier% Up}
		}
	} else {
		return getKeyInfo( "ModState_" . modifier )
	}
}

_setAltGrState( isdown )
{
	_getAltGrState( isdown, 1 )
}

_getAltGrState( isdown = 0, set = 0 )
{
	static AltGr := 0
	if ( set == 1 ) {
		if ( isdown == 1 ) {
			AltGr = 1
			Send {LCtrl Down}{RAlt Down}
		} else {
			AltGr = 0
			Send {RAlt Up}{LCtrl Up}
		}
	} else {
		return AltGr
	}
}
