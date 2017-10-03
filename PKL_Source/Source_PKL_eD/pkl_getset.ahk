; eD--> Moved getGlobal.ahk into pkl_getset.ahk (idea from vVv)
getGlobal( var )
{
	global
	return %var% . ""
}

setGlobal( var, value )
{
	global
	%var% := value
}
; <--eD (vVv)

setLayoutItem( key, value )
{
	return getLayoutItem( key, value, 1 )
}

getLayoutItem( key, value = "", set = 0 )
{
	static pdic := 0
	if ( pdic == 0 )
	{
		pdic := HashTable_New()
	}
	if ( set == 1 )
		HashTable_Set( pdic, key, value )
	else
		return HashTable_Get( pdic, key )
}

setTrayIconInfo( var, val )
{
	return getTrayIconInfo( var, val, 1 )
}

getTrayIconInfo( var, val = "", set = 0 )
{
	static FileOn := ""
	static NumOn := -1
	static FileOff := ""
	static NumOff := -1
	if ( set == 1 )
		%var% := val
	return  %var% . ""
}

setLayoutInfo( var, val )
{
	return getLayoutInfo( var, val, 1 )
}

getLayoutInfo( key, value = "", set = 0 )
{
	/*
	active    := "" ; The active layout
	dir       := "" ; The directory of the active layout
	hasAltGr  := 0  ; Did work Right alt as altGr in the layout?
	extendKey := "" ; With this you can use qwerty's ijkl as arrows, etc.
	
	nextLayout := "" ; If you set multiple layouts, this is the next one.
	                 ; see the "changeTheActiveLayout:" label!
	countOfLayouts := 0 ; Array size
	; See the layout setting in the ini file
	LayoutsXcode = layout code
	LayoutsXname = layout name
	*/
	static pdic := 0
	if ( pdic == 0 )
	{
		pdic := HashTable_New()
	}
	if ( set == 1 )
		HashTable_Set( pdic, key, value )
	else
		return HashTable_Get( pdic, key )
}

setPklInfo( key, value )
{
	getPklInfo( key, value, 1 )
}

getPklInfo( key, value = "", set = 0 )
{
	static pdic := 0
	if ( pdic == 0 )
	{
		pdic := HashTable_New()
	}
	if ( set == 1 )
		HashTable_Set( pdic, key, value )
	else
		return HashTable_Get( pdic, key )
}
