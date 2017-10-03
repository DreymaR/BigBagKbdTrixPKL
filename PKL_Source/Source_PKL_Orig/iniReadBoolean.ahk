iniReadBoolean( file, group, key, default = "" )
{
	IniRead, t, %file%, %group%, %key%, %default%
	if ( t == "1" || t == "yes" || t == "y" || t == "true" )
		return true
	else
		return false
}