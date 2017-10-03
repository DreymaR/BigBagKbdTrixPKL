; HashTable (aka Associative array)
; Available functions:
; 	pdic := HashTable_New() ; Create a new array
; 	HashTable_Set( key, value ) ; store a value
; 	value == HashTable_Get( key ) ; get a value
; Key is case insensitive!
;
; There are some different implementations, uncomment your favorite!
;

;#Include HashTableGlobalVars.ahk ; For DEBUG mode
;#Include HashTableStaticVars.ahk
#Include HashTableSystemCalls.ahk
