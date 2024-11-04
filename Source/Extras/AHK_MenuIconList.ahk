;
; AutoHotkey Version: 1.x
; Language:       English
; Platform:       Win9x/NT
; Author:         Script from online documentation modified by Jack Dunning
;                 https://autohotkey.com/docs/commands/ListView.htm#IL
; Script Function:
;   Explore and select icons from any Windows file which embeds icon images (.exe, .dll, etc.)
;
/*
This icon selection tool uses the ImageList in the ListView command to create an icon selection box.
I added the FileSelectFile command to make exploring various files easier.
Double-click on any image to save the file path and name plus the icon number to the Windows clipboard.
Both C:\Windows\System32\shell32.dll and C:\Windows\System32\imageres.dll contain hundreds of icons.
*/

#SingleInstance	; Replace on rerun
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

;;  Author: Jack Dunning, modified from online documentation at
;;          https://autohotkey.com/docs/commands/ListView.htm#IL
;;  Script Function:
;;          Explore and select icons from any Windows file which embeds icon images (.exe, .dll, etc.)
defIconPath := "C:\Windows\System32\shell32.dll"
FileSelectFile, iconFile, 32,%defIconPath%, Pick a file to check icons., *.*
if not iconFile
	Return

;iconFile := "C:\Windows\System32\shell32.dll"
GUI, MIL:font, s20
GUI, MIL:Add, ListView, h415 w150 gMenuIconNum, Icon 	; Uses a ListView GUI (https://www.autohotkey.com/docs/v1/lib/ListView.htm)
ImageListID := IL_Create(10,1,1)    					; Create an ImageList to hold 10 small icons.
LV_SetImageList(ImageListID,1)      					; Assign the above ImageList to the current ListView.
Loop {                              					; Load the ImageList with a series of icons from the DLL.
     Count := Image                 					; Number of icons found
     Image := IL_Add(ImageListID, iconFile, A_Index) 	; Omits the DLL's path so that it works on Windows 9x too.
     If (Image = 0)                 					; When we run out of icons
       Break
   }
Loop % Count {                      					; Add rows to the ListView (for demonstration purposes, one for each icon).
    LV_Add("Icon" . A_Index, "     " . A_Index)
}
LV_ModifyCol("Hdr")                 					; Auto-adjust the column widths.
GUI, MIL:Show
Return

MenuIconNum:
  Clipboard := iconFile . ", " . A_EventInfo
  Msgbox % Clipboard . "`r     added to Clipboard!"
Return

GuiClose:                           					; Exit the script when the user closes the ListView's GUI window.
ExitApp
