#NoEnv
kys := [ "q", "w", "e", "r", "t", "a", "s", "d", "f", "g" ]
mod := [ "Alt", "Ctrl" ]
txt := "Key ToAscii:`n"
For ix, key in kys
	txt .= "`n" . key . " - " . ToAscii( key, mod )
MsgBox, 0, Test ToAscii, %txt%
ExitApp

;;  https://www.autohotkey.com/boards/viewtopic.php?t=1040
;;  This only handles Ascii (or ASCII-versionable) character output
ToAscii( Key, Modifiers = "" ) {
	VK_MOD := { "Shift": 0x10, "Ctrl": 0x11, "Alt": 0x12 }
	VK := GetKeyVK( Key )
	SC := GetKeySC( Key )
	VarSetCapacity( ModStates, 256, 0 )
	For Each, Modifier In Modifiers
		If VK_MOD.HasKey( Modifier )
			NumPut( 0x80, ModStates, VK_MOD[Modifier], "UChar" )
	Result := DllCall( "USer32.dll\ToAscii", "UInt", VK, "UInt", SC, "Ptr", &ModStates, "UIntP", Ascii, "UInt", 0, "Int" )
	Return Chr( Ascii )
}
