; A simple hack for integer type OS version
; Because AHK currently doesn't support 'at least WIN_VISTA'
; See http://www.autohotkey.com/forum/viewtopic.php?p=254663#254663
A_OSMajorVersion := DllCall("GetVersion") & 0xff
A_OSMinorVersion := DllCall("GetVersion") >> 8 & 0xff
