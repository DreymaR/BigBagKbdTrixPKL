/*
------------------------------------------------------------------------

HashTable (Associative array) module
http://www.autohotkey.com

------------------------------------------------------------------------

Version: 0.0.1 2009-03
License: GNU General Public License
Author: FARKAS, Mate

A simple implementation of HashTable, using static vars

------------------------------------------------------------------------
*/

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
