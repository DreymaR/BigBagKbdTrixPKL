#NoEnv
key := "´"
txt := "Is " . key . " a DK in the active kbd layout?`n"
txt .= isDeadKey( key ) ? "Yes" : "No"
MsgBox, %txt%
ExitApp

isDeadKey( Key, Shift = 0 , AltGr = 1 ) {
	Static VK_SHIFT      := 0x10
	Static VK_CONTROL    := 0x11
	Static VK_MENU       := 0x12
	VK  := GetKeyVK( Key )
	SC  := GetKeySC( Key )
	VarSetCapacity( ModStates, 256, 0 )
	If ( Shift ) {
		NumPut( 0x80, ModStates, VK_SHIFT  , "UChar" )
	} 	; end if Shift
	If ( AltGr ) {
		NumPut( 0x80, ModStates, VK_CONTROL, "UChar" )  	; WIP: Should it be LCONTROL here?
		NumPut( 0x80, ModStates, VK_MENU   , "UChar" )  	; WIP: Should it be RMENU    here?
	} 	; end if AltGr
	toAscii := DllCall( "USer32.dll\ToAscii", "UInt", VK, "UInt", SC, "Ptr", &ModStates, "UIntP", Ascii, "UInt", 0, "Int" )
	Return ( toAscii = -1 ? true : false )
}
