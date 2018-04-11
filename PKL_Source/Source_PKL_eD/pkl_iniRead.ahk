; eD: Renamed this file from Ini.ahk to ext_IniRead.ahk, and renamed all functions to the iniSomething syntax.
; eD: Removed unused functions in this file (all except iniReadSection!) in preparation for moving on to new iniRead functions.
; eD TODO: Figure out encoding for non-ANSI accents (see vVv's iniReadUtf8!)

;---------------------------------------------------------------------------------------
;		- About Ini.ahk:
;		- Version 1.0 b2 by majkinetor. See: <http://www.autohotkey.com/forum/topic22495.html>
;		- Creative Commons Attribution 3.0 Unported <http://creativecommons.org/licenses/by/3.0/>

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
; Function: LoadSection/ReadSection
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
;
; eD: Read a (pkl).ini value
;     Usage: val := pklIniRead( <key>, [default], [inifile(shortstr)], [section] )
;     Note: IniRead trims off white space and one pair of quotes if present, but not comments.
pklIniRead( key, default = "", inifile = "Pkl_Ini", section = "pkl", strip = 1 )
{
	global gP_Pkl_Ini_File				; eD:    "pkl.ini" -	will eventually be stored in a pdic
	global gP_Lay_Ini_File				; eD:    "layout.ini" 	--"--
	global gP_Pkl_eD__File				; eD: My "pkl.ini" 		--"--
	global gP_Lay_eD__File				; eD: My "layout.ini" 	--"--
	global gP_Pkl_Dic_File				; eD: My "tables.ini" 	--"--
	if ( ( not inStr( inifile, "." ) ) and FileExist( gP_%inifile%_File ) )
		inifile := gP_%inifile%_File
	default := ( default == "" ) ? A_Space : default		; IniRead requires A_Space for a blank default
	IniRead, val, %inifile%, %section%, %key%, %default%
	val := ( strip ) ? strCom( val ) : val								; Strip end-of-line comments
;	MsgBox, '%val%', '%inifile%', '%section%', '%key%', '%default%'		; eD: Debug
	return val
}

pklIniBool( key, default = "", inifile = "Pkl_Ini", section = "pkl" )
{
	val := pklIniRead( key, default, inifile, section )		;IniRead, val, %inifile%, %section%, %key%, %default%
	val := ( val == "1" || val == "yes" || val == "y" || val == "true" ) ? true : false
	return val
}

pklIniKeyVal( iniLine, ByRef key, ByRef val, esc=0, com=1 )		; Because PKL doesn't always use IniRead? Why though?
{
	pos := InStr( iniLine, "=" )
	key := Trim( SubStr( iniLine, 1, pos-1 ))
	val := Trim( SubStr( iniLine,    pos+1 ))
	val := ( com ) ? strCom( val ) : val
	val := ( esc ) ? strEsc( val ) : val
	key := ( pos == 0 ) ? "<NoKey>" : key
}

strCom( str )												; Remove end-of-line comments (whitespace then semicolon)
{
	str := RegExReplace( str, "[ `t]+;.*`n?$" )
	return str
}

strEsc( str )												; Replace \n and \\ escapes
{
	StringReplace, str, str, \n, `n, A
	StringReplace, str, str, \\, \, A
	return str
}

/*
; eD TODO: Make a function that reads a section and returns a pdic of (key,value) pairs?
;			- Better than it is today in, say, locale.ahk!
;			- How to "save" existing layout files?! Exclude `t;`t sequences?
;			- Today's solution of parsing layout.ini by column should be sufficient though!
;			- Alternatively, may the v1.1 IniRead() work well for PKL now? Or only for UTF16?
*/
