; eD: Merged all the HashTable files into this one. Comment the active version and uncomment another to switch versions.

; HashTable (aka Associative array)
; Available functions:
; 	pdic := HashTable_New() ; Create a new array
; 	HashTable_Set( key, value ) ; store a value
; 	value == HashTable_Get( key ) ; get a value
; Key is case insensitive!
;
; There are some different implementations, uncomment your favorite!
;

;#Include HashTableGlobalVars.ahk ; For DEBUG mode
;#Include HashTableStaticVars.ahk
;#Include HashTableSystemCalls.ahk ; eD: This is used by PKL - now included directly here

/*
------------------------------------------------------------------------

HashTable (Associative array) module

File: HashTableSystemCalls.ahk
Version: 0.0.1 2008-05
License: GNU General Public License
Author: Sean 

This is a simplified version of Sean's Associative Array.
	 http://www.autohotkey.com/forum/viewtopic.php?t=17838

Tested Platform:  Windows Vista
Tested AutoHotkey Version: 1.0.47.04

Requires:
	* CoHelper.ahk http://www.autohotkey.net/~Sean/Scripts/CoHelper.zip

------------------------------------------------------------------------
*/

HashTable_Set( pdic, sKey, sItm )
{
	pKey := SysAllocString(sKey)
	VarSetCapacity(var1, 8 * 2, 0)
	EncodeInteger(&var1 + 0, 8)
	EncodeInteger(&var1 + 8, pKey)
	pItm := SysAllocString(sItm)
	VarSetCapacity(var2, 8 * 2, 0)
	EncodeInteger(&var2 + 0, 8)
	EncodeInteger(&var2 + 8, pItm)
	DllCall(VTable(pdic, 8), "Uint", pdic, "Uint", &var1, "Uint", &var2)
	SysFreeString(pKey)
	SysFreeString(pItm)
}

HashTable_Get( pdic, sKey )
{
	pKey := SysAllocString(sKey)
	VarSetCapacity(var1, 8 * 2, 0)
	EncodeInteger(&var1 + 0, 8)
	EncodeInteger(&var1 + 8, pKey)
	DllCall(VTable(pdic, 12), "Uint", pdic, "Uint", &var1, "intP", bExist)
	If bExist
	{
		VarSetCapacity(var2, 8 * 2, 0)
		DllCall(VTable(pdic, 9), "Uint", pdic, "Uint", &var1, "Uint", &var2)
		pItm := DecodeInteger(&var2 + 8)
		Unicode2Ansi(pItm, sItm)
		SysFreeString(pItm)
	}
	SysFreeString(pKey)
	Return sItm
}

HashTable_New()
{
	CoInitialize()
	CLSID_Dictionary := "{EE09B103-97E0-11CF-978F-00A02463E06F}"
	IID_IDictionary := "{42C642C1-97E1-11CF-978F-00A02463E06F}"
	pdic := CreateObject(CLSID_Dictionary, IID_IDictionary)
	DllCall(VTable(pdic, 18), "Uint", pdic, "int", 1) ; Set text mode, i.e., Case of Key is ignored. Otherwise case-sensitive defaultly.
	return pdic
}

#include ext_CoHelper.ahk ; eD: Renamed from CoHelper.ahk


/*
------------------------------------------------------------------------

HashTable (Associative array) module

File: HashTableStaticVars.ahk
Version: 0.0.1 2009-03
License: GNU General Public License
Author: FARKAS, Mate

A simple implementation of HashTable, using static vars

------------------------------------------------------------------------
*/
/* ; eD: Commented out. To use this version, switch comments with the active one
HashTable_Set( pdic, sKey, sItm )
{
	return HashTable_Get( pdic, sKey, sItm, 1 )
}

HashTable_Get( pdic, sKey, sItm = "", set = 0 )
{
	static
	sKey := _HashTable_ConvertToVariableName( sKey )
	if ( set == 1 ) {
		[%pdic%]%sKey% := sItm
	}
	return [%pdic%]%sKey% . ""
}

HashTable_New()
{
	static count := 0
	return ++count
}

_HashTable_ConvertToVariableName( str )
{
	res := ""
	Loop, Parse, str
	{
		as := Asc( A_LoopField )
		ch := A_LoopField 
		If ( ( as >= 65 && as <= 90 ) || ( as >= 97 && as <=122 ) ) 
			res .= ch ; Letter
		Else If ( ch >= 0 && ch <= 9 )
			res .= ch ; Number
		Else If ( ch == "?" || ch == "[" || ch == "]" || ch == "_" || ch == "$" )
			res .= ch ; Other legal character except "#" and "@"
		Else If ( ch == " " )
			res .= "@_"
		Else If ( ch == "." )
			res .= "@$"
		Else If ( ch == "@" )
			res .= "@@"
		Else
			res .= "#" . as
	}
	return res
}
*/ ; eD: Commented out this version


/*
------------------------------------------------------------------------

HashTable (Associative array) module

File: HashTableGlobalVars.ahk
Version: 0.0.1 2008-05
License: GNU General Public License
Author: FARKAS, Mate

A simple implementation of HashTable, using global vars

------------------------------------------------------------------------
*/
/* ; eD: Commented out. To use this version, switch comments with the active one
HashTable_Set( pdic, sKey, sItm )
{
	global
	sKey := _HashTable_ConvertToVariableName( sKey )
	[%pdic%]%sKey% := sItm
}

HashTable_Get( pdic, sKey )
{
	global
	sKey := _HashTable_ConvertToVariableName( sKey )
	return [%pdic%]%sKey% . ""
}

HashTable_New()
{
	static count := 0
	return ++count
}

_HashTable_ConvertToVariableName( str )
{
	res := ""
	Loop, Parse, str
	{
		as := Asc( A_LoopField )
		ch := A_LoopField 
		If ( ( as >= 65 && as <= 90 ) || ( as >= 97 && as <=122 ) ) 
			res .= ch ; Letter
		Else If ( ch >= 0 && ch <= 9 )
			res .= ch ; Number
		Else If ( ch == "?" || ch == "[" || ch == "]" || ch == "_" || ch == "$" )
			res .= ch ; Other legal character except "#" and "@"
		Else If ( ch == " " )
			res .= "@_"
		Else If ( ch == "." )
			res .= "@$"
		Else If ( ch == "@" )
			res .= "@@"
		Else
			res .= "#" . as
	}
	return res
}
*/ ; eD: Commented out this version
