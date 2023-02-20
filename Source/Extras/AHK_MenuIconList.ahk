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

defPath = C:\Windows\System32\shell32.dll
FileSelectFile, file, 32,%defPath%, Pick a file to check icons., *.*
if file =
    return


Gui, font, s20
Gui, Add, ListView, h415 w150 gIconNum, Icon 
ImageListID := IL_Create(10,1,1)  ; Create an ImageList to hold 10 small icons.
LV_SetImageList(ImageListID,1)    ; Assign the above ImageList to the current ListView.
Loop {                            ; Load the ImageList with a series of icons from the DLL.
     Count := Image               ; Number of icons found
     Image := IL_Add(ImageListID, file, A_Index)  ; Omits the DLL's path so that it works on Windows 9x too.

     If (Image = 0)               ; When we run out of icons
       Break
   }
Loop % Count {                    ; Add rows to the ListView (for demonstration purposes, one for each icon).
    LV_Add("Icon" . A_Index, "     " . A_Index)
}
LV_ModifyCol("Hdr")  ; Auto-adjust the column widths.
Gui Show
Return

IconNum:
  Clipboard := file . ", " . A_EventInfo
  Msgbox %Clipboard% `r     added to Clipboard!
Return


GuiClose:  ; Exit the script when the user closes the ListView's GUI window.
ExitApp
