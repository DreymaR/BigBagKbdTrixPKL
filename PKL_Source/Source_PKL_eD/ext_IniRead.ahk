; eD: Renamed this file from Ini.ahk to ext_IniRead.ahk, and renamed all functions to the iniSomething syntax for consistency with iniReadBoolean (as vVv did).

; Title:		Ini
;				*Set of functions for ini-like handling of strings*
;
; 
;
;				This set of functions allows you to handle strings that comply to the ini section format. It makes ini section abstract, allowing
;				you to store query and change related information as a whole instead having to take care about big number of variables.
;				You can create section string from real ini file or you can make it yourself.
;
;				The functions are designed to work with "worst possible" ini definition in mind, that is, white space in section or key definition may be present as much as
;				empty sections, comments, empty lines etc. 
;
;				There are 2 differences between this module and OS related functions. First is that key values are not returned trimmed, 
;				so you can have values starting with white space. The other one is that module generally doesn't consider position of key
;				in the section string as important or position of section in the ini file, and will not retain to change the position for 
;				the sake of speed.

;-------------------------------------------------------------------------------------
; 
; Function: LoadSection
;			Load one or all sections from the ini file.
;  
; Parameters: 
;			iniFile	-	Ini file path 
;			section	-	Section to be returned by the function. By default "", which means all sections 
;						will be returned in array with the base name %prefix%. Variable names will be constructed
;						as %prefix%%sectionName%. If section name contains characters illegal for AHK variable
;						names, those will be removed. If after removal of illegal characters section name is empty string
;						it will be skipped.
;			prefix	-	Base name of the array to be used for global variables, by default  "inis_"
;
; Returns: 
;			If section = "" list of sections separated by new lines otherwise requested section
;
iniReadSection( pIniFile, pSection="", pPrefix="inis_") {
	local sIni,v,v1,v2,j,s,res
	static x = ",,, ,	,``,¬,¦,!,"",£,%,^,&,*,(,),=,+,{,},;,:,',~,,,<,.,>,/,\,|,-"
	
	
 ;the fastest way to get single section
	if pSection !=
	{
		Loop, %pIniFile%, 0								; Expand relative paths, since GetPrivateProfileSection only searches %A_WinDir%. 
			pIniFile := A_LoopFileLongPath
		
		
		VarSetCapacity( res, 0x7FFF, 0 ),  s := DllCall( "GetPrivateProfileSection" , "str", pSection, "str", res, "uint", 0x7FFF, "str", pIniFile )
		
		Loop, % s-1
			if !NumGet( res, A_Index-1, "UChar" )			; Each line within the section is terminated with a null character.  Replace each delimiting null char with a newline
				NumPut( 10, res, A_Index-1, "UChar" )		; \0 -> \n 
		
		if A_OSVersion in WIN_ME,WIN_98,WIN_95										; Windows Me/98/95: The returned string includes comments.
			res := RegExReplace(res, "m`n)^[ `t]*(?:;.*`n?|`n)|^[ `t]+|[ `t]+$")	; This removes comments. Also, I'm not sure if leading/trailing space is automatically removed on Win9x, so the regex removes that too. 
		
		return res
	}
	
 ;if loading entire ini, use regex; its fast and allows for dumb ini definitions (white space before/after section/key, empty lines, empty sections etc..)
	FileRead, sIni, *t %pIniFile%
	
	;remove comments & empty Lines
	sIni := RegExReplace( RegExReplace( sIni, "`nm)^;.+\R" ), "`nm)^\n" )	"`n["

	j := 0
	if pSection=
	Loop{
		j := RegExMatch( sIni, "(?<=^|\n)\s*\[([^\n]+?)\]\n\s*([^[].*?)(?=\n\s*\[)", v, j+StrLen(v)+1 )
		if !j
			break

		if v1 contains %x%
		{
			 v1 := RegExReplace( v1, "[" x "]" )
			 ifEqual, v1, , continue
		}


		%pPrefix%%v1% := v2
		res .= v1 "`n"
	}
	return SubStr( res, 1, -1 )
}

;-------------------------------------------------------------------------------------
; Function: GetSectionNames
;			Gets the names of all sections in the ini file. 
;
; Parameters:
;			iniFile		-	Ini file name
;
; Returns:	
;			List of section names, each on new line
;
iniGetSectionNames(pIniFile) {
	Loop, %pIniFile%, 0								; Expand relative paths, since GetPrivateProfileSectionNames only searches %A_WinDir%. 
        pIniFile := A_LoopFileLongPath
    
    VarSetCapacity(text, 0x1000), len := DllCall("GetPrivateProfileSectionNames", "str", text, "uint", 0x1000, "str", pIniFile)
    Loop, % len-1
        if (NumGet(text, A_Index-1, "UChar") = 0)	; Replace each delimiting null char with a newline
            NumPut(10, text, A_Index-1, "UChar")	; \0 -> \n 
    
    return text
}

;---------------------------------------------------------------------------------------------
;   Function:	LoadKeys
;				Loads one or all keys from one or all sections.
;				Each key will be loaded into the global array with base name equal to its section name.
;    
;   Parameters: 
;				pIniFile -	Ini file path. If you set "" here, next parameter will be seen as section string.
;				section -	By default "", means to load keys for all sections. This will create array of global variables
;							with the name %prefix%%section%_%key%.
;							If section is not empty, the function load keys only for that section. 
;							If section is not empty and pIniFile is empty this parameter contains section string and since section name 
;							is not available, globals are created as %prefix%_%key%
;				prefix  -	Prefix for global variables created, or key/value delimiter when pInfo != 0
;				pInfo	-	Flag determining what to return. See return values of the function for details.
;				filter	-   Only key names starting with this word will be retrieved. For instance, if the
;							section contain keys name1, def1, name2, def2, name3, def3.... you can set filter
;							to "name" or to "def" for function to see only those keys.
;							To use regular expression, specify new line as first char, for instance "`ni)^abc"
;				reverse	-	Reverse filter operation, get only key names NOT fitting the filter.
;							   
;   Returns: 
;				pInfo=0 or pInfo=""		-	number of variables created (default). 
;				pInfo=1 or pInfo="keys" -   function returns key names separated by prefix string (by default `n)
;				pInfo>1 or pInfo="vals" -	function returns key values separated by prefix string (by default `n)
;    
;	Examples:
;>      iniLoadKeys("settings.ini")					; load all keys from all sections, return number of vars
;>      iniLoadKeys("application.ini", "window")		; load all keys under 'window' section, return number of vars
;>      iniLoadKeys("test.ini", "", "", "cfg_")		; load all keys, use "cfg_" prefix
;>		iniLoadKeys("test.ini, "Config", 1)			; return key names from "Config" section
;>		iniLoadKeys("test.ini, "Config", "keys")		; the same as above
;>		iniLoadKeys("test.ini, "Config", "vals")		; return key values from "Config" section 
;>		iniLoadKeys("", section, "", "cfg_")			; load section from string, use "cfg_" as base name
;>		iniLoadKeys("", Presets, 2, "", "name")		; get only key values of keys that start with "name" word from Presets section string.
;>		iniLoadKeys("", Presets, 2, "", "name", true)	; the same as above, but reverse filter.
;>		iniLoadKeys("", Presets, 2, "", "`ni)^k")		; regular expression filter - get all keys starting with character "k" or "K"
;
iniLoadKeys(pIniFile, section = "", pInfo=0, prefix = "", filter="", reverse = false){
	local s, p, v1, v2, res, at, l, re, f, fl
	static x = ",,, ,	,``,¬,¦,!,"",£,%,^,&,*,(,),=,+,{,},;,:,',~,,,<,.,>,/,\,|,-"
	at = %A_AutoTrim%
	AutoTrim, On

	if pInfo is not Integer
	   pInfo := pInfo = "vals" ? 2 : pinfo="keys" ? 1 : 0

	if (pIniFile = "")
			pIniFile := section
	else if section !=
		 pIniFile := "[" section "]`n" iniReadSection(pIniFile, section)
	else  {
		FileRead, pIniFile, *t %pIniFile%
		pIniFile := RegExReplace(RegExReplace(pIniFile, "`nm)^;.+\R" ), "`nm)^\n" )	"`n["	   ;remove comments and empty lines
	}

	if pInfo
		 prefix .= prefix="" ? "`n" : ""
	else res := 0

	f := filter != "", fl := StrLen(filter)
	if (re := *&filter = 10)
		filter := SubStr(filter, 2)


	Loop, parse, pIniFile, `n, `r`n
	{
  		l = %A_LoopField%
		If InStr(l, "[") = 1 {
			StringMid, s, l, 2, InStr(l, "]") - 2
			If s contains %x%
 				s := RegExReplace(s, "[" x "]")				;next section name
		}
		Else If p := InStr(l, "=")
		{
			StringLeft, v1, l, p-1
			v1 = %v1%

			if f
				if re {
					if !RegExMatch( v1, filter ) {
						  IfEqual, reverse, 0, continue
					}else IfEqual, reverse, 1, continue
				}else if SubStr(v1, 1, fl) != filter {
						  IfEqual, reverse, 0, continue
					}else IfEqual, reverse, 1, continue

			If v1 contains %x%
			{
 				 v1 := RegExReplace(v1, "[" x "]")
				 IfEqual, v1, , continue
			}

			StringTrimLeft, v2, l, p

			if !pInfo
				%prefix%%s%_%v1% := v2,  res++
			else res .= (pInfo=1 ? v1 : v2) prefix
		}
   }
   AutoTrim, %at%
   Return, pInfo ? SubStr(res, 1, -StrLen(prefix)) : res
}

;-------------------------------------------------------------------------------------
; Function:		MakeSection
;				Makes the section string using user global variables
;
; Parameters:								
;				prefix	- Common prefix that all global variables have in their name.
;
; Returns:
;				Section string 
;
; Remarks:
;				If you defined more then around 16,350 variables (in entire script), this function may provide unreliable results.
;
; Example:
;>				a_key1          = my key
;>				a_SomeOtherKey  = 1
;>				a_configuration = bla bla
;>				somevar         = dumy
;>
;>				s := iniMakeSection("a_")
;>				iniReplaceSection("test.ini", "config", s)
;
iniMakeSection( prefix ) {
    static hwndEdit, pSFW, pSW, bkpSFW, bkpSW
	static header="Global Variables (alphabetical)`r`n--------------------------------------------------`r`n"

    if !hwndEdit
    {
        dhw := A_DetectHiddenWindows
        DetectHiddenWindows, On
        Process, Exist
        ControlGet, hwndEdit, Hwnd,, Edit1, ahk_class AutoHotkey ahk_pid %ErrorLevel%
        DetectHiddenWindows, %dhw%
		
        hmod := DllCall("GetModuleHandle", "str", "user32.dll")
        pSFW := DllCall("GetProcAddress", "uint", hmod, "str", "SetForegroundWindow")
        pSW := DllCall("GetProcAddress", "uint", hmod, "str", "ShowWindow")
        DllCall("VirtualProtect", "uint", pSFW, "uint", 8, "uint", 0x40, "uint*", 0)
        DllCall("VirtualProtect", "uint", pSW, "uint", 8, "uint", 0x40, "uint*", 0)
        bkpSFW := NumGet(pSFW+0, 0, "int64")
        bkpSW := NumGet(pSW+0, 0, "int64")
    }


	critical 1000000000
		NumPut(0x0004C200000001B8, pSFW+0, 0, "int64")  ; return TRUE 
		NumPut(0x0008C200000001B8, pSW+0, 0, "int64")   ; return TRUE 
		ListVars
		NumPut(bkpSFW, pSFW+0, 0, "int64"),  NumPut(bkpSW, pSW+0, 0, "int64")
	critical off
	
    ControlGetText, text,, ahk_id %hwndEdit%
	text := SubStr( text, InStr(text, header)+85 )


  ;-----------------------------------------------------------------------------------------

	len := StrLen(prefix)
	loop, parse, text, `n, `r`n
	{
		j := InStr(A_LoopField, ":")
		if !j						; line doesn't have ":" it isn't variable
			continue
		k := SubStr( A_LoopField, 1, j-1)
		j := InStr(k, "[", 0, 0)
		if !j
			continue
		k := SubStr( k, 1, j-1)
		if (k < prefix)				; its alphabetical so I can compare
			continue
		if (SubStr(k, 1, len) != prefix)
			break

		k1 := SubStr( k, len+1), res .= k1 "=" %k% "`n"
	}
	return SubStr(res, 1, -1)
}


;-------------------------------------------------------------------------------------
; Function:		ReplaceSection
;				Replace entire section in ini file.
;
; Parameters:
;				pIniFile	- Ini file name														
;				section		- Section name
;				data		- Reference to the section data
;
iniReplaceSection( pIniFile, section, ByRef data=""){
	IniDelete, %pIniFile%, %section%					;this way much faster then using System API, the only side effect is that changed section will be moved to the end of file
	FileAppend, [%section%]`n%data%, %pIniFile%
}

;-------------------------------------------------------------------------------------
; Function:		UpdateSection
;				Update section with new key values.
;
; Parameters:
;				sSection -	Reference to the section string
;				data	 -	Reference to the new section data
;
; Returns:
;				Updated section string
;
iniUpdateSection( ByRef sSection, ByRef data){
	return, data (data !="" ? "`n" :) iniDelKeys(sSection, iniLoadKeys("", data, 2, ","))
}


;-------------------------------------------------------------------------------------
; Function:		GetVal
;				Get key value
;
; Parameters:
;				sSection	- Reference to the section string.
;				name		- name of the key
;				def			- default value
;
; Returns:
;				Key value if key is found or def 
;
iniGetVal(ByRef sSection, name, def="") {
	return RegExMatch(sSection, "`aim)^\s*\Q" name "\E\s*=(.+)$", out) ? out1 : def
}

;-------------------------------------------------------------------------------------
; Function:		SetVal
;				Set the key value
;
; Parameters:
;				sSection	- Reference to the section string.
;				name		- Name of the key
;				val			- Value. New line char ("`n") is not removed from the value.
;
iniSetVal(ByRef sSection, name, val="") {
	sSection := RegExReplace(sSection, "`aim)^\s*\Q" name "\E\s*=(.+)$", name "=" val )
}


;-------------------------------------------------------------------------------------
; Function:		GetKeyName
;				Get name of the first key with given value
;
; Parameters:
;				sSection	- Reference to the section string.
;				val			- Key value
;
; Returns:
;				Key name if value is found or empty string
;
iniGetKeyName(ByRef sSection, val){
	return RegExMatch(sSection, "`aim)^\s*(.+?)\s*=\Q" val "\E$", out) ? out1 : ""
}

;-------------------------------------------------------------------------------------
; Function:		DelKeys
;				Delete one or more keys from the section
;
; Parameters:								
;				sSection	- Reference to the section string
;				keys		- List of keys to be deleted, separated by sep character
;				rev			- Reverse mode - keys in the list stay, all other keys are deleted
;				sep			- Key separator, by default ","
;
; Returns:
;				New section string
;
iniDelKeys( ByRef sSection, keys, rev=false, sep=",") {
	at = %A_AutoTrim%
	AutoTrim, On

	keys := sep keys sep
	loop, parse, sSection, `n, `n`r
	{
 		l = %A_LoopField%
		If !(p := InStr(l, "="))
			continue
		StringLeft, k, l, p-1
		k = %k%
		
		if InStr(keys, sep k sep) {
			   IfEqual, rev, 0, continue
		} else IfEqual, rev, 1, continue
		res .= l "`n"
	}
	AutoTrim, %at%

	return SubStr(res, 1, -1)
}

;-------------------------------------------------------------------------------------
; Function:		DelKeysRe
;				Delete keys from the section using regular expression
;
; Parameters:								
;				sSection	- Reference to the section string
;				re			- Regular expression specifying key names. You can use any valid AHK RE, including options and anchors.
;
; Returns:
;				New section string
;
; Example:
;>				s=
;>				( 
;>				Evocation=1
;>				levitation=2
;>				somekey=blah
;>				)
;>				
;>				iniDelKeysRe( s, "i)^ev")		;remove only "Evocation" key
;>
iniDelKeysRe( ByRef sSection, re) {
	k := InStr(re, ")"), j := InStr(re, "(")
	re := "m" ( k && (!j || j>k) ? "" : ")") re						;add m option among user options

	k := RegExReplace( iniLoadKeys("", sSection, "keys"), re )
	return iniDelKeys( sSection, k, true, "`n")

}

;-------------------------------------------------------------------------------------
; Function:		AddMRU
;				Add most recently used (MRU) item in the section string
;
; Parameters:								
;				sSection	- Section string
;				pLine		- Line to be added
;				pMax		- Maximum lines in the MRU list, by default 10
;				prefix		- Prefix to use for key name generation. By default "m"
;
; Returns:
;				If "line" was already in the MRU list, its previous MRU number, otherwise 1.
;
; Remarks:
;				This will create array of keys, by default m1, m2... mN. Each key represents one MRU line.
;				"Line" will be added to the top of the MRU list. If it is already in the list, it will first 
;				be moved to top and its old position will be returned.
;
iniAddMRU(ByRef sSection, pLine, pMax=10, prefix="m") {

	res := prefix "1=" pLine, j:=1, ret:=1
	loop, parse, sSection, `n, `r
	{
		if (A_Index >= pMax)
			break

		if (A_LoopField = "m" A_Index "=" pLine) {
			if A_Index = 1
				return 0
			j:=0, pMax++, ret := A_Index
			continue
		}
		else res .= "`n" prefix (A_Index+j) "=" SubStr( A_LoopField, InStr(A_LoopField, "=")+1)
	}

	sSection := res
	return ret
}

;---------------------------------------------------------------------------------------
;Group: About
;		- Version 1.0 b2 by majkinetor. See: <http://www.autohotkey.com/forum/topic22495.html>
;		- Creative Commons Attribution 3.0 Unported <http://creativecommons.org/licenses/by/3.0/>

;-------------------------------------------------------------------------------------
;
; eD--> Moved iniReadBoolean.ahk into this file
iniReadBoolean( file, group, key, default = "" )
{
	IniRead, val, %file%, %group%, %key%, %default%
	if ( val == "1" || val == "yes" || val == "y" || val == "true" )
		return true
	else
		return false
}
; <--eD

/*
; eD--> eD TODO: Add a function for handling .ini keys (as this was repeated in the code)
;		eD TODO: Make a function that reads a section and returns a pdic of (key,value) pairs!
;		eD TODO: Remove end-of-line comments. That is, any [%A_Space%|%A_Tab%];.*$ RegEx.
;			In compensation, add 'StringReplace, val, val, \;, `;, A' below?
;			How to "save" existing layout files?! Answer: Exclude `t;`t sequences!
;			That way, the only problem would be any ligatures starting with ; (rare!)
;			However, these should properly be preceded by a % anyway!?
iniGetKeyVal( line, ByRef key, ByRef val, escapes = 0 )
{
	pos := InStr( line, "=" )
	key := Trim( SubStr( line, 1, pos-1 ))
	val := Trim( SubStr( line, pos+1 ))
	if ( escapes != 0 ) {
		StringReplace, val, val, \n, `n, A
		StringReplace, val, val, \\, \, A
	}
} ; <--eD
*/
