/*
------------------------------------------------------------------------

HashTable (Associative array) module
http://www.autohotkey.com

------------------------------------------------------------------------

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

#include CoHelper.ahk
