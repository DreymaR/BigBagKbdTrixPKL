/*
------------------------------------------------------------------------

Get VirtualKey hex code from name
http://www.autohotkey.com

------------------------------------------------------------------------

Version: 0.0.1 2007-12-10 first release
License: GNU General Public License
Author: FARKAS Máté <http://fmate14.try.hu> (My given name is Máté)

Tested Platform:  Windows XP/Vista
Tested AutoHotkey Version: 1.0.47.04

------------------------------------------------------------------------

TODO: This version is safe, but not optimized.

------------------------------------------------------------------------
*/

getVirtualKeyCodeFromName( name ) ; eD: renamed VirtualKeyCodeFromName for consistency
{
	if ( name == "0")
		return "30"
	if ( name == "1")
		return "31"
	if ( name == "2")
		return "32"
	if ( name == "3")
		return "33"
	if ( name == "4")
		return "34"
	if ( name == "5")
		return "35"
	if ( name == "6")
		return "36"
	if ( name == "7")
		return "37"
	if ( name == "8")
		return "38"
	if ( name == "9")
		return "39"
	if ( name == "A")
		return "41"
	if ( name == "B")
		return "42"
	if ( name == "C")
		return "43"
	if ( name == "D")
		return "44"
	if ( name == "E")
		return "45"
	if ( name == "F")
		return "46"
	if ( name == "G")
		return "47"
	if ( name == "H")
		return "48"
	if ( name == "I")
		return "49"
	if ( name == "J")
		return "4A"
	if ( name == "K")
		return "4B"
	if ( name == "L")
		return "4C"
	if ( name == "M")
		return "4D"
	if ( name == "N")
		return "4E"
	if ( name == "O")
		return "4F"
	if ( name == "P")
		return "50"
	if ( name == "Q")
		return "51"
	if ( name == "R")
		return "52"
	if ( name == "S")
		return "53"
	if ( name == "T")
		return "54"
	if ( name == "U")
		return "55"
	if ( name == "V")
		return "56"
	if ( name == "W")
		return "57"
	if ( name == "X")
		return "58"
	if ( name == "Y")
		return "59"
	if ( name == "Z")
		return "5A"
	if ( name == "OEM_1")
		return "BA"
	if ( name == "OEM_PLUS")
		return "BB"
	if ( name == "OEM_COMMA")
		return "BC"
	if ( name == "OEM_MINUS")
		return "BD"
	if ( name == "OEM_PERIOD")
		return "BE"
	if ( name == "OEM_2")
		return "BF"
	if ( name == "OEM_3")
		return "C0"
	if ( name == "OEM_4")
		return "DB"
	if ( name == "OEM_5")
		return "DC"
	if ( name == "OEM_6")
		return "DD"
	if ( name == "OEM_7")
		return "DE"
	if ( name == "OEM_8")
		return "DF"
	if ( name == "OEM_102")
		return "E2"



	if ( name == "LBUTTON")
		return "01"
	if ( name == "RBUTTON")
		return "02"
	if ( name == "CANCEL")
		return "03"
	if ( name == "MBUTTON")
		return "04"
	if ( name == "XBUTTON1")
		return "05"
	if ( name == "XBUTTON2")
		return "06"
	if ( name == "BACK")
		return "08"
	if ( name == "TAB")
		return "09"
	if ( name == "CLEAR")
		return "0C"
	if ( name == "RETURN")
		return "0D"
	if ( name == "SHIFT")
		return "10"
	if ( name == "CONTROL")
		return "11"
	if ( name == "MENU")
		return "12"
	if ( name == "PAUSE")
		return "13"
	if ( name == "CAPITAL")
		return "14"
	if ( name == "KANA")
		return "15"
	if ( name == "HANGUEL")
		return "15"
	if ( name == "HANGUL")
		return "15"
	if ( name == "JUNJA")
		return "17"
	if ( name == "FINAL")
		return "18"
	if ( name == "HANJA")
		return "19"
	if ( name == "KANJI")
		return "19"
	if ( name == "ESCAPE")
		return "1B"
	if ( name == "CONVERT")
		return "1C"
	if ( name == "NONCONVERT")
		return "1D"
	if ( name == "ACCEPT")
		return "1E"
	if ( name == "MODECHANGE")
		return "1F"
	if ( name == "SPACE")
		return "20"
	if ( name == "PRIOR")
		return "21"
	if ( name == "NEXT")
		return "22"
	if ( name == "END")
		return "23"
	if ( name == "HOME")
		return "24"
	if ( name == "LEFT")
		return "25"
	if ( name == "UP")
		return "26"
	if ( name == "RIGHT")
		return "27"
	if ( name == "DOWN")
		return "28"
	if ( name == "SELECT")
		return "29"
	if ( name == "PRINT")
		return "2A"
	if ( name == "EXECUTE")
		return "2B"
	if ( name == "SNAPSHOT")
		return "2C"
	if ( name == "INSERT")
		return "2D"
	if ( name == "DELETE")
		return "2E"
	if ( name == "HELP")
		return "2F"
	if ( name == "LWIN")
		return "5B"
	if ( name == "RWIN")
		return "5C"
	if ( name == "APPS")
		return "5D"
	if ( name == "SLEEP")
		return "5F"
	if ( name == "NUMPAD0")
		return "60"
	if ( name == "NUMPAD1")
		return "61"
	if ( name == "NUMPAD2")
		return "62"
	if ( name == "NUMPAD3")
		return "63"
	if ( name == "NUMPAD4")
		return "64"
	if ( name == "NUMPAD5")
		return "65"
	if ( name == "NUMPAD6")
		return "66"
	if ( name == "NUMPAD7")
		return "67"
	if ( name == "NUMPAD8")
		return "68"
	if ( name == "NUMPAD9")
		return "69"
	if ( name == "MULTIPLY")
		return "6A"
	if ( name == "ADD")
		return "6B"
	if ( name == "SEPARATOR")
		return "6C"
	if ( name == "SUBTRACT")
		return "6D"
	if ( name == "DECIMAL")
		return "6E"
	if ( name == "DIVIDE")
		return "6F"
	if ( name == "F1")
		return "70"
	if ( name == "F2")
		return "71"
	if ( name == "F3")
		return "72"
	if ( name == "F4")
		return "73"
	if ( name == "F5")
		return "74"
	if ( name == "F6")
		return "75"
	if ( name == "F7")
		return "76"
	if ( name == "F8")
		return "77"
	if ( name == "F9")
		return "78"
	if ( name == "F10")
		return "79"
	if ( name == "F11")
		return "7A"
	if ( name == "F12")
		return "7B"
	if ( name == "F13")
		return "7C"
	if ( name == "F14")
		return "7D"
	if ( name == "F15")
		return "7E"
	if ( name == "F16")
		return "7F"
	if ( name == "F17")
		return "80"
	if ( name == "F18")
		return "81"
	if ( name == "F19")
		return "82"
	if ( name == "F20")
		return "83"
	if ( name == "F21")
		return "84"
	if ( name == "F22")
		return "85"
	if ( name == "F23")
		return "86"
	if ( name == "F24")
		return "87"
	if ( name == "NUMLOCK")
		return "90"
	if ( name == "SCROLL")
		return "91"
	if ( name == "OEM_NEC_EQUAL")
		return "92"
	if ( name == "OEM_FJ_JISHO")
		return "92"
	if ( name == "OEM_FJ_MASSHOU")
		return "93"
	if ( name == "OEM_FJ_TOUROKU")
		return "94"
	if ( name == "OEM_FJ_LOYA")
		return "95"
	if ( name == "OEM_FJ_ROYA")
		return "96"
	if ( name == "LSHIFT")
		return "A0"
	if ( name == "RSHIFT")
		return "A1"
	if ( name == "LCONTROL")
		return "A2"
	if ( name == "RCONTROL")
		return "A3"
	if ( name == "LMENU")
		return "A4"
	if ( name == "RMENU")
		return "A5"
	if ( name == "BROWSER_BACK")
		return "A6"
	if ( name == "BROWSER_FORWARD")
		return "A7"
	if ( name == "BROWSER_REFRESH")
		return "A8"
	if ( name == "BROWSER_STOP")
		return "A9"
	if ( name == "BROWSER_SEARCH")
		return "AA"
	if ( name == "BROWSER_FAVORITES")
		return "AB"
	if ( name == "BROWSER_HOME")
		return "AC"
	if ( name == "VOLUME_MUTE")
		return "AD"
	if ( name == "VOLUME_DOWN")
		return "AE"
	if ( name == "VOLUME_UP")
		return "AF"
	if ( name == "MEDIA_NEXT_TRACK")
		return "B0"
	if ( name == "MEDIA_PREV_TRACK")
		return "B1"
	if ( name == "MEDIA_STOP")
		return "B2"
	if ( name == "MEDIA_PLAY_PAUSE")
		return "B3"
	if ( name == "LAUNCH_MAIL")
		return "B4"
	if ( name == "LAUNCH_MEDIA_SELECT")
		return "B5"
	if ( name == "LAUNCH_APP1")
		return "B6"
	if ( name == "LAUNCH_APP2")
		return "B7"
	if ( name == "PROCESSKEY")
		return "E5"
	if ( name == "PACKET")
		return "E7"
	if ( name == "OEM_RESET")
		return "E9"
	if ( name == "OEM_JUMP")
		return "EA"
	if ( name == "OEM_PA1")
		return "EB"
	if ( name == "OEM_PA2")
		return "EC"
	if ( name == "OEM_PA3")
		return "ED"
	if ( name == "OEM_WSCTRL")
		return "EE"
	if ( name == "OEM_CUSEL")
		return "EF"
	if ( name == "OEM_ATTN")
		return "F0"
	if ( name == "OEM_FINNISH")
		return "F1"
	if ( name == "OEM_COPY")
		return "F2"
	if ( name == "OEM_AUTO")
		return "F3"
	if ( name == "OEM_ENLW")
		return "F4"
	if ( name == "OEM_BACKTAB")
		return "F5"
	if ( name == "ATTN")
		return "F6"
	if ( name == "CRSEL")
		return "F7"
	if ( name == "EXSEL")
		return "F8"
	if ( name == "EREOF")
		return "F9"
	if ( name == "PLAY")
		return "FA"
	if ( name == "ZOOM")
		return "FB"
	if ( name == "NONAME")
		return "FC"
	if ( name == "PA1")
		return "FD"
	if ( name == "OEM_CLEAR")
		return "FE"
	return "00"
}
