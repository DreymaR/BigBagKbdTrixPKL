HexUC(utf8) {                    ; Return 4 hex Unicode digits of UTF-8 input CHAR
; Written by Laszlo Hars
   format = %A_FormatInteger%    ; save original integer format
   SetFormat Integer, Hex        ; for converting bytes to hex
   VarSetCapacity(U, 2)
   DllCall("MultiByteToWideChar", UInt,65001, UInt,0, Str,utf8, Int,-1, UInt,&U, Int,1)
   h := 0x10000 + (*(&U+1)<<8) + *(&U)
   StringTrimLeft h, h, 3
   SetFormat Integer, %format%   ; restore original format
   Return h
}

