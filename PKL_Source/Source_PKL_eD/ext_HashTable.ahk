; eD: Removed the unused HashTable files. Merged Sean's CoHelper file into this one.

; HashTable (aka Associative array)
; Available functions:
; 	pdic := HashTable_New() ; Create a new array
; 	HashTable_Set( key, value ) ; store a value
; 	value == HashTable_Get( key ) ; get a value
; Key is case insensitive!
;

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
	pKey := CoH_SysAllocStr(sKey)
	VarSetCapacity(var1, 8 * 2, 0)
	CoH_EncodeInt(&var1 + 0, 8)
	CoH_EncodeInt(&var1 + 8, pKey)
	pItm := CoH_SysAllocStr(sItm)
	VarSetCapacity(var2, 8 * 2, 0)
	CoH_EncodeInt(&var2 + 0, 8)
	CoH_EncodeInt(&var2 + 8, pItm)
	DllCall(CoH_VTable(pdic, 8), "Uint", pdic, "Uint", &var1, "Uint", &var2)
	CoH_SysFreeStr(pKey)
	CoH_SysFreeStr(pItm)
}

HashTable_Get( pdic, sKey )
{
	pKey := CoH_SysAllocStr(sKey)
	VarSetCapacity(var1, 8 * 2, 0)
	CoH_EncodeInt(&var1 + 0, 8)
	CoH_EncodeInt(&var1 + 8, pKey)
	DllCall(CoH_VTable(pdic, 12), "Uint", pdic, "Uint", &var1, "intP", bExist)
	If bExist
	{
		VarSetCapacity(var2, 8 * 2, 0)
		DllCall(CoH_VTable(pdic, 9), "Uint", pdic, "Uint", &var1, "Uint", &var2)
		pItm := CoH_DecodeInt(&var2 + 8)
		CoH_Unic2Ansi(pItm, sItm)
		CoH_SysFreeStr(pItm)
	}
	CoH_SysFreeStr(pKey)
	Return sItm
}

HashTable_New()
{
	CoH_Initialize()
	CLSID_Dictionary := "{EE09B103-97E0-11CF-978F-00A02463E06F}"
	IID_IDictionary := "{42C642C1-97E1-11CF-978F-00A02463E06F}"
	pdic := CoH_CreateObj(CLSID_Dictionary, IID_IDictionary)
	DllCall(CoH_VTable(pdic, 18), "Uint", pdic, "int", 1) ; Set text mode, i.e., Case of Key is ignored. Otherwise case-sensitive defaultly.
	return pdic
}

/*
------------------------------------------------------------------------

CoHelper module (partial)

File: CoHelper.ahk
License: GNU General Public License
Author: Sean 

eD: This is a condensed version of Sean's CoHelper module, used above.
	 http://www.autohotkey.net/~Sean/Scripts/CoHelper.zip

; CoHelper functions used in PKL:
;	Function				Used by
;	--------------------------------------------------------------
;	CoH_VTable				HashTable
;	CoH_SysAllocStr			HashTable
;	CoH_SysFreeStr			HashTable
;	CoH_EncodeInt			HashTable
;	CoH_DecodeInt			HashTable
;	CoH_Initialize			HashTable
;	CoH_CreateObj			HashTable
;	CoH_Unic2Ansi			HashTable
;	CoH_Ansi2Unic			<CoHelp> (SysAllocString)
;	CoH_GUID4Str			<CoHelp> (CreateObject)
;	CoH_Unic4Ansi			<CoHelp> (GUID4String)

------------------------------------------------------------------------
*/

CoH_VTable(ppv, idx)
{
	Return	NumGet(NumGet(1*ppv)+4*idx)
}

CoH_SysAllocStr(sString)
{
	Return	DllCall("oleaut32\SysAllocString", "Uint", CoH_Ansi2Unic(sString,wString))
}

CoH_SysFreeStr(bstr)
{
	Return	DllCall("oleaut32\SysFreeString", "Uint", bstr)
}

CoH_EncodeInt(ref, val = 0, nSize = 4)
{
	DllCall("RtlMoveMemory", "Uint", ref, "int64P", val, "Uint", nSize)
}

CoH_DecodeInt(ref, nSize = 4)
{
	DllCall("RtlMoveMemory", "int64P", val, "Uint", ref, "Uint", nSize)
	Return	val
}

CoH_Initialize()
{
	Return	DllCall("ole32\CoInitialize", "Uint", 0)
}

CoH_CreateObj(ByRef CLSID, ByRef IID, CLSCTX = 5)
{
	If	StrLen(CLSID)=38
		CoH_GUID4Str(CLSID,CLSID)
	If	StrLen(IID)=38
		CoH_GUID4Str(IID,IID)
	DllCall("ole32\CoCreateInstance", "str", CLSID, "Uint", 0, "Uint", CLSCTX, "str", IID, "UintP", ppv)
	Return	ppv
}

CoH_Unic4Ansi(ByRef wString, sString, nSize = "")
{
	If (nSize = "")
	    nSize:=DllCall("kernel32\MultiByteToWideChar", "Uint", 0, "Uint", 0, "Uint", &sString, "int", -1, "Uint", 0, "int", 0)
	VarSetCapacity(wString, nSize * 2 + 1)
	DllCall("kernel32\MultiByteToWideChar", "Uint", 0, "Uint", 0, "Uint", &sString, "int", -1, "Uint", &wString, "int", nSize + 1)
	Return	&wString
}

CoH_Ansi2Unic(ByRef sString, ByRef wString, nSize = "")
{
	If (nSize = "")
	    nSize:=DllCall("kernel32\MultiByteToWideChar", "Uint", 0, "Uint", 0, "Uint", &sString, "int", -1, "Uint", 0, "int", 0)
	VarSetCapacity(wString, nSize * 2 + 1)
	DllCall("kernel32\MultiByteToWideChar", "Uint", 0, "Uint", 0, "Uint", &sString, "int", -1, "Uint", &wString, "int", nSize + 1)
	Return	&wString
}

CoH_Unic2Ansi(ByRef wString, ByRef sString, nSize = "")
{
	pString := wString + 0 > 65535 ? wString : &wString
	If (nSize = "")
	    nSize:=DllCall("kernel32\WideCharToMultiByte", "Uint", 0, "Uint", 0, "Uint", pString, "int", -1, "Uint", 0, "int",  0, "Uint", 0, "Uint", 0)
	VarSetCapacity(sString, nSize)
	DllCall("kernel32\WideCharToMultiByte", "Uint", 0, "Uint", 0, "Uint", pString, "int", -1, "str", sString, "int", nSize + 1, "Uint", 0, "Uint", 0)
	Return	&sString
}

CoH_GUID4Str(ByRef CLSID, String)
{
	VarSetCapacity(CLSID, 16)
	DllCall("ole32\CLSIDFromString", "Uint", CoH_Unic4Ansi(String,String,38), "Uint", &CLSID)
	Return	&CLSID
}

; eD: Functions used just in CoHelper.ahk and therefore removed:
;	QueryInterface			<CoHelp> (AtlAx functions)
;	AddRef					<CoHelp> --
;	Release					<CoHelp> (DispInterface, AtlAx fns, ScriptControl)
;	QueryService			<CoHelp> --
;	FindConnectionPoint		<CoHelp> (ConnectObject)
;	GetConnectionInterface	<CoHelp> (ConnectObject)
;	Advise					<CoHelp> (ConnectObject)
;	UnAdvise				<CoHelp> (DispInterface)
;	Invoke/Invoke_			<CoHelp> (ScriptControl/--)
;	...
;	DispInterface			<CoHelp> --
;	AtlAx...				<CoHelp> --
;	ConnectObject			<CoHelp> --
;	ScriptControl			<CoHelp> --
