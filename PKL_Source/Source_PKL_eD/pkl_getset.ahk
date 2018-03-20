; eD TODO: Replace the get and set global info functions with pdic lookup tables, e.g., PklVar[key] (req. AHK v1.1).
;			- Instead of the different functions below, could have one pair of setInfo( pdic, key, val )/getInfo( pdic, key ) functions?
;			- Then it'd be easier to make one ( A_AhkVersion < "1.1" ) w/ HashTable and one with pdic := {}

/*
	LayoutInfo entries:
	-------------------
	active         := "" ; The active layout
	dir            := "" ; The directory of the active layout
	hasAltGr       := 0  ; Should Right Alt work as AltGr in the layout?
	extendKey      := "" ; Extend modifier for navigation, editing, etc.
	
	nextLayout     := "" ; If you set multiple layouts, this is the next one.
	                     ; see the "changeActiveLayout:" label!
	countOfLayouts := 0  ; Array size
	LayoutsXcode         ; layout code
	LayoutsXname         ; layout name
	Ico_On_File          ; Icon for On  (file)
	Ico_On_Num_          ; --"--        (# in file)
	Ico_OffFile          ; Icon for Off (file)
	Ico_OffNum_          ; --"--        (# in file)
*/
	
setKeyInfo( key, value )
{
	return getKeyInfo( key, value, 1 )
}

setLayInfo( var, val )
{
	return getLayInfo( var, val, 1 )
}

setPklInfo( key, value )
{
	getPklInfo( key, value, 1 )
}

getKeyInfo( key, value = "", set = 0 )
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

getLayInfo( key, value = "", set = 0 )
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
