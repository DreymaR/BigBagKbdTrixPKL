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
	static pdic     := {}
	if ( set == 1 )
		pdic[key]   := value
	else
		return pdic[key]
}

getLayInfo( key, value = "", set = 0 )
{
	static pdic     := {}
	if ( set == 1 )
		pdic[key]   := value
	else
		return pdic[key]
}

getPklInfo( key, value = "", set = 0 )
{
	static pdic     := {}
	if ( set == 1 )
		pdic[key]   := value
	else
		return pdic[key]
}
