;
; AutoHotkey Version: 1.x
; Language:       English
; Platform:       Win9x/NT
; Author:         1st ver.: oldbug & PhiLho (Philippe Lhoste), 2006-03-03
;                 2nd ver.: r0lZ 2011-09-10
;
; Script Function:
;	MsgBox generator
;   http://www.autohotkey.com/forum/viewtopic.php?t=1631&p=9742#9742 
;

#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

/*
;#################### Form 

Gui Add, Text, x16 y7 w60 h15, Title 
Gui Add, Text, x16 y50 w60 h15, Message 

Gui Add, Edit, vtitle x16 y27 w390 h20, 
Gui Add, Edit, vmessage x16 y67 w390 h50, 

Gui Add, GroupBox, x16 y127 w190 h145, Buttons 
Gui Add, Radio, vbuttonOK Checked x26 y147 w170 h20, OK 
Gui Add, Radio, vbuttonOK_Cancel x26 y167 w170 h20, OK/Cancel 
Gui Add, Radio, vbuttonAbort_Retry_Ignore x26 y187 w170 h20, Abort/Retry/Ignore 
Gui Add, Radio, vbuttonYes_No_Cancel x26 y207 w170 h20, Yes/No/Cancel 
Gui Add, Radio, vbuttonYes_No x26 y227 w170 h20, Yes/No 
Gui Add, Radio, vbuttonRetry_Cancel x26 y247 w170 h20, Retry/Cancel 

Gui Add, GroupBox, x16 y277 w190 h70, Modal 
Gui Add, Radio, vmodalTask Checked x26 y297 w170 h20, Task 
Gui Add, Radio, vmodalSystem x26 y317 w170 h20, System 

Gui Add, GroupBox, x16 y353 w190 h40, Default Button 
Gui Add, Radio, vdefault1st Checked x26 y367 w40 h20, 1st 
Gui Add, Radio, vdefault2nd x96 y367 w40 h20, 2nd 
Gui Add, Radio, vdefault3rd x164 y367 w40 h20, 3rd 

Gui Add, GroupBox, x226 y127 w180 h220, Icon 
Gui Add, Radio, viconNone Checked x236 y147 w110 h20, None 
Gui Add, Radio, viconHand x236 y187 w110 h20, Error 
Gui Add, Radio, viconQuestion x236 y227 w110 h20, Question 
Gui Add, Radio, viconExclamation x236 y267 w110 h20, Exclamation 
Gui Add, Radio, viconAsterisk x236 y307 w110 h20, Asterisk 

If A_OSType = WIN32_WINDOWS 
{ 
   ; Win98 
   Gui Add, Picture, icon6 x356 y140 w32 h32, user.exe 
   Gui Add, Picture, icon4 x356 y177 w32 h32, user.exe 
   Gui Add, Picture, icon3 x356 y217 w32 h32, user.exe 
   Gui Add, Picture, icon2 x356 y257 w32 h32, user.exe 
   Gui Add, Picture, icon5 x356 y297 w32 h32, user.exe 
} 
Else 
{ 
   ; WinXP 
;~    Gui Add, Picture, icon50 x356 y140 w32 h32, shell32.dll 
   Gui Add, Picture, icon4 x356 y177 w32 h32, user32.dll 
   Gui Add, Picture, icon3 x356 y217 w32 h32, user32.dll 
   Gui Add, Picture, icon2 x356 y257 w32 h32, user32.dll 
   Gui Add, Picture, icon5 x356 y297 w32 h32, user32.dll 
} 

Gui Add, Button, gTestAndCopy Default x226 y360 w80 h33, Clipboard 
Gui Add, Button, gGuiClose x326 y360 w80 h33, Close 

Gui Show, x148 y10 h410 w425, MsgBox Code Generator (for AHK) 
Return 

;#################### Main 

TestAndCopy: 
   Gui Submit, NoHide 

;#################### Radio buttons 

options = 
( Join| 
buttonOK=0 
buttonOK_Cancel=1 
buttonAbort_Retry_Ignore=2 
buttonYes_No_Cancel=3 
buttonYes_No=4 
buttonRetry_Cancel=5 
iconNone=0 
iconHand=16 
iconQuestion=32 
iconExclamation=48 
iconAsterisk=64 
default1st=0 
default2nd=256 
default3rd=512 
modalSystem=4096 
modalTask=8192 
) 

option = 0 
; Check for each radio button if it is set, looping on the variable names 
Loop, Parse, options, | 
{ 
   StringSplit option, A_LoopField, = 
   If (%option1% = 1) 
   { 
      option += option2 
   } 
} 

;#################### Message 

If (InStr(message, "`n")) 
{ 
   ; Multiline 
   If (StrLen(message) > 78) 
   { 
      ; Long message: use a continuation section 
      message = `n(`n%message%`n) 
   } 
   Else 
   { 
      ; Replace newlines by the corresponding AHK escape sequence 
      StringReplace message, message, `n, ``n, All 
   } 
} 

;#################### Output 

output = MsgBox %option%`, %title%`, %message% 
Clipboard = %output% 
; Test 
FileAppend %output%, %A_ScriptDir%\~msg.tmp 
RunWait %A_AhkPath% "%A_ScriptDir%\~msg.tmp" 
FileDelete %A_ScriptDir%\~msg.tmp 
Return 

;#################### Close 
GuiClose: 
GuiEscape: 
FileDelete %A_ScriptDir%\~msg.tmp 
ExitApp
*/

;;  Just to have a larger choice :
;;  MsgBox Generator v1.3 from r0lZ Posted: Sat Sep 10, 2011 5:54 pm

; MsgBoxGenerator.ahk: AutoHotkey script by r0lZ, September 2011 
; Generates the AutoHotkey code to build easily a nice-looking MsgBox. 
; Developed vith AutoHotkey_L v1.1.02.01 Unicode X64 under Win7 X64 SP1 
; Discussion thread: http://www.autohotkey.com/forum/topic76419.html 
; 
; Version history: 
; v1.0: 
; - First release 
; v1.1: 
; - Bug: The default button numbers that cannot be selected due to the current 
;   buttons type selection are now disabled. 
; - Added the currently selected icon in the status bar. 
; - Test button: When the "Help" button option is selected, clicking the Help 
;   button of the messagebox displays now a dummy help message. 
; - Added the possibility to input an options number to modify the GUI accordingly. 
; - Added the Right-To-Left alignment option. 
; - Added the "Default Desktop" (undocumented?) window type option. 
; v1.2: 
; - Bug: Right-to-left was "Left-to-right" 
; - Some modifications inspired by the mod version released by Drugwash: 
; - Changed the Icon listbox to a listview to show the icons in the GUI. 
; - The Timeout value combobox is now disabled when the Timeout checkbox is not ticked. 
; - The option value is now in hexadecimal format. 
; - GUI somewhat reorganised. 

VERSION = 1.2 

#NoTrayIcon 
#NoEnv 
#SingleInstance force 
#UseHook off 
#Persistent 
DetectHiddenWindows, on 

SplitPath, A_ScriptName, , , , APPTITLE 

IncludeBrackets = 1 

Menu, OptionsMenu, Add, Always on top, ToggleAlwaysOnTop 
Menu, OptionsMenu, add, Show tray tips, ToggleTrayTips 
Menu, OptionsMenu, Add, Enable Ctrl-Shift-M hotkey, ToggleSuspend 
Menu, OptionsMenu, Check, Enable Ctrl-Shift-M hotkey 
Menu, OptionsMenu, Add, Include brackets in code, ToggleBrackets 
Menu, OptionsMenu, Check, Include brackets in code 

Menu, Tray, NoStandard 
Menu, Tray, Add, Open GUI, OpenMainGui 
Menu, Tray, Default, Open GUI 
Menu, Tray, Add 
Menu, Tray, Add, Options, :OptionsMenu 
Menu, Tray, Add 
Menu, Tray, Add, Exit, Exit 
Menu, Tray, Click, 1 
Menu, Tray, Tip, AHK MsgBox generator`nBy r0lZ`, September 2011 

if (! A_IsCompiled) { 
    tmp = %A_ScriptDir%\%APPTITLE%.ico 
    if (FileExist(tmp)) 
        Menu, Tray, Icon, %tmp% 
    else 
        Menu, Tray, Icon 
    tmp = 
} else 
    Menu, Tray, Icon 

BuildMainGUI() 

OnExit, CleanExit 


Return 


Exit: 
    OnExit 
CleanExit: 
    FileDelete, %A_Temp%\MsgBoxTest.ahk 
    ExitApp 
return 


; **************************** Main GUI *********************** 
OpenMainGui: 
    Gui, Show 
return 

BuildMainGUI() 
{ 
    Global VERSION 
    Global ButtonsVal, DefaultButtonVal, HelpButton, IconVal, WindowVal, RightJustify, RightToLeft, Title, Text, TimeoutOn, Timeout, TimeoutS 

    Menu, GuiMenu, add, Exit, Exit 
    Menu, GuiMenu, Add, Options, :OptionsMenu 
    Menu, GuiMenu, add, Input#, InputNumber 
    Gui, Menu, GuiMenu 

    Gui, Margin, 4, 4 
    Gui, Font, S8, Tahoma 


    Gui, Add, Text, X4 Y4 Section, Buttons scheme: 
    Gui, Add, ListBox, XS vButtonsVal r7 w200 gGuiChanged AltSubmit, OK|OK / Cancel|Abort / Retry / Ignore|Yes / No / Cancel|Yes / No|Retry / Cancel|Cancel / Try Again / Continue [WinXP+] 
    GuiControl, Choose, ButtonsVal, 1 

    Gui, Add, Text, XS Section, Default Button: 
    Gui, Add, Radio, YS vDefaultButtonVal Checked gGuiChanged, &1 
    Gui, Add, Radio, YS gGuiChanged, &2 
    Gui, Add, Radio, YS gGuiChanged, &3 
    
    Gui, Add, Text, XS W202 H0 Section 0x10 

    Gui, Add, Checkbox, XS Section vHelpButton gGuiChanged, Add '&Help' button 
    Gui, Font, s7, Tahoma 
    Gui, Add, Text, XS+16 Disabled, Requires: Gui +OwnDialogs  and`nOnMessage(0x53, "WM_HELP") 
    Gui, Font, S8, Tahoma 

    Gui, Add, Text, XS W202 H2 Section 0x10 

    Gui, Add, Text, XS Section, Text: 
    Gui, Add, Checkbox, YS vRightJustify gGuiChanged, &Right-justify 
    Gui, Add, Checkbox, YS vRightToLeft  gGuiChanged, Right-to-&left 

    Gui, Add, Text, XS W288 H6 Section 0x10 

    Gui, Add, Text, X208 Y4 Section, Icon and sound: 
    Gui, Add, ListView, XS vIconVal r5 w83 Count5 -hdr -Multi -WantF2 gGuiChanged AltSubmit +0x8, Type   ; 0x8 = LVS_SHOWSELALWAYS 
    hIL := IL_Create(5) 
    IL_Add(hIL, "user32.dll", 1), IL_Add(hIL, "user32.dll", 5), IL_Add(hIL, "user32.dll", 2), IL_Add(hIL, "user32.dll", 3), IL_Add(hIL, "user32.dll", 4), 
    LV_SetImageList(hIL) 
    LV_Add("Icon99", "No icon"), LV_Add("Icon2", "Info"), LV_Add("Icon3", "Warning"), LV_Add("Icon4", "Question"), LV_Add("Icon5", "Error") 
    LV_ModifyCol(0, "AutoHdr") 
    LV_Modify(1, "Select Focus") 

    Gui, Add, Text, XS Section, Window type: 
    Gui, Add, ListBox, XS vWindowVal r5 w83 gGuiChanged AltSubmit, Normal|Task modal|System modal|Always on top|Default desktop 
    GuiControl, Choose, WindowVal, 1 


    Gui, Add, Text, X4 Section W30, Title: 
    Gui, Add, Edit, YS-4 w253 vTitle gGuiChanged -WantReturn, `%A_ScriptName`% 

    Gui, Add, Edit, XS Section w287 vText r4 gGuiChanged +WantReturn, Text 

    Gui, Add, Text, XS W288 H4 Section 0x10 

    Gui, Add, Checkbox, XS Section vTimeoutOn gGuiChanged, Ti&meout: 
    Gui, Add, Edit, w65 YS-3 Number Limit7 gGuiChanged vTimeout Disabled -WantReturn 
    Gui, Add, UpDown, vTimeoutS Range1-60 gGuiChanged Disabled, 10 
    Gui, Add, Text, YS, seconds  (Max 2147483 secs.) 

    Gui, Add, Text, XS W288 H0 Section 0x10 

    Gui, Add, Text, XS Section, Control-Shift-M inserts the code in the current application. 
    Gui, Add, Button, XS w93 gCopyNum Section, Copy &option # 
    Gui, Add, Button, YS w93 gCopyCode, Copy &code 
    Gui, Add, Button, YS w93 gTest Default, &Test 

    Gui, Add, StatusBar 

    GoSub, GuiChanged 

    SysGet, Mon, MonitorWorkArea 
    posx := MonLeft + 20 
    posy := MonTop + 20 
    Gui, Show, X%posx% Y%posy%, AHK MsgBox generator v%VERSION% 
} 

GuiChanged: 
    Gui, Submit, NoHide 
    val := ButtonsVal -1 
    if (val == 0) { 
        GuiControl, Disable, &2 
        GuiControl, Disable, &3 
        DefaultButtonVal = 1 
        GuiControl, , DefaultButtonVal, 1 
    } 
    else if (val == 1 || val == 4) { 
        GuiControl, Enable, &2 
        GuiControl, Disable, &3 
        if (DefaultButtonVal > 2) { 
            DefaultButtonVal = 2 
            GuiControl, , &2, 1 
        } 
    } else { 
        GuiControl, Enable, &2 
        GuiControl, Enable, &3 
    } 
    val += (DefaultButtonVal - 1) * 256 
    val += HelpButton ? 16384 : 0 

    IconVal := LV_GetNext() 
    if (IconVal != 1) { 
        val += (6 - IconVal) * 16 
        if (iconval == 2) 
            iconnum = 5 
        else if (iconval == 3) 
            iconnum = 2 
        else if (iconval == 4) 
            iconnum = 3 
        else 
            iconnum = 4 
    } else 
        iconnum = 0 


    if (WindowVal == 2) 
        val += 8192 
    else if (WindowVal == 3) 
        val += 4096 
    else if (WindowVal == 4) 
        val += 262144 
    if RightJustify 
        val += 524288 
    if RightToLeft 
        val += 1048576 

    ; convert options value to hex 
    SetFormat, Integer, H 
    val+=0 
    SetFormat, Integer, D 

    StringReplace, Title, Title, `, , ```, , 1 
    StringReplace, Message, Text, `, , ```, , 1 
    StringReplace, Message, Message, `n, ``n, 1 
    st = MsgBox, %val%, %Title%, %Message% 

    if (TimeoutOn && Timeout <= 0) { 
        TimeoutOn = 0 
        GuiControl, , TimeoutOn, 0 
        GuiControl, , Timeout, 1 
        soundbeep 
    } 
    if (TimeoutOn) { 
        GuiControl, Enable, Timeout 
        GuiControl, Enable, TimeoutS 
        st = %st%, %Timeout% 
    } else { 
        Timeout = 0 
        GuiControl, Disable, Timeout 
        GuiControl, Disable, TimeoutS 
    } 

    if (iconnum && FileExist(A_WinDir . "\system32\user32.dll")) { 
        SB_SetParts(22) 
        SB_SetIcon("user32.dll", iconnum) 
    } else { 
        SB_SetParts(0) 
    } 
    SB_SetText(st, 2) 
    if (ShowTrayTips) { 
        GoSub, GenCode 
        TrayTip, MsgBox code:, %code%, 10, 1 
    } 
return 

CopyNum: 
    GoSub, GuiChanged 
    Clipboard = %val% 
return 

CopyCode: 
    GoSub, GuiChanged 
    GoSub, GenCode 
    clipboard = %code% 
return 

GenCode: 
    code = MsgBox, %val%, %Title%, %Message% 
    if (IncludeBrackets) 
        s = `n{`n`n} 
    else 
        s = `n 
    if (TimeoutOn) 
        code = %code%, %Timeout% 
    if (ButtonsVal == 1 && TimeoutOn) 
        code = %code%`nIfMsgBox, OK%s% 
    if (ButtonsVal == 2) 
        code = %code%`nIfMsgBox, OK%s%`nIfMsgBox, Cancel%s% 
    if (ButtonsVal == 3) 
        code = %code%`nIfMsgBox, Abort%s%`nIfMsgBox, Retry%s%`nIfMsgBox, Ignore%s% 
    if (ButtonsVal == 4) 
        code = %code%`nIfMsgBox, Yes%s%`nIfMsgBox, No%s%`nIfMsgBox, Cancel%s% 
    if (ButtonsVal == 5) 
        code = %code%`nIfMsgBox, Yes%s%`nIfMsgBox, No%s% 
    if (ButtonsVal == 6) 
        code = %code%`nIfMsgBox, Retry%s%`nIfMsgBox, Cancel%s% 
    if (ButtonsVal == 7) 
        code = %code%`nIfMsgBox, Cancel%s%`nIfMsgBox, Try Again%s%`nIfMsgBox, Continue%s% 
    if (TimeoutOn) 
        code = %code%`nIfMsgBox, Timeout%s% 
    code = %code%`n 
return 

Test: 
    GoSub, GuiChanged 
    cmd = MsgBox, %val%, %Title%, %Message% 
    if TimeoutOn 
        cmd = %cmd%, %Timeout% 
    FileDelete, %A_Temp%\MsgBoxTest.ahk 
    if (HelpButton) { 
        code = Gui, Show, Hide, %Title%`nGui, +OwnDialogs`nOnMessage(0x53, "WM_HELP")`n%cmd%`nexitapp`nWM_HELP()`n{`n MsgBox, 64, Help - %Title%, This is a dummy help message., 3`n}`n 
        FileAppend, %code%`n, %A_Temp%\MsgBoxTest.ahk 
        code = 
    } else { 
        FileAppend, %cmd%`n, %A_Temp%\MsgBoxTest.ahk 
    }    
    Run, "%A_Temp%\MsgBoxTest.ahk", %A_Temp%, UseErrorLevel 
return 

GuiClose: 
GuiEscape: 
    GoSub, GuiChanged 
    Gui, Hide 
return 

ToggleAlwaysOnTop: 
    alwaysontop := ! alwaysontop 
    Menu, OptionsMenu, ToggleCheck, Always on top 
    if (alwaysontop) 
        Gui, +AlwaysOnTop 
    else 
        Gui, -AlwaysOnTop 
return 

ToggleSuspend: 
    Suspend, Toggle 
    Menu, OptionsMenu, ToggleCheck, Enable Ctrl-Shift-M hotkey 
return 

ToggleTrayTips: 
    ShowTrayTips := ! ShowTrayTips 
    Menu, OptionsMenu, ToggleCheck, Show tray tips 
    if (ShowTrayTips) 
        GoSub, GuiChanged 
    else 
        TrayTip 
return 

ToggleBrackets: 
    IncludeBrackets := ! IncludeBrackets 
    Menu, OptionsMenu, ToggleCheck, Include brackets in code 
    if (ShowTrayTips) 
        GoSub, GuiChanged 
return 

^+m:: 
    GoSub, GuiChanged 
    GoSub, GenCode 
    SetKeyDelay, 0 
    SendRaw, %code% 
return 

; **************** GUI 2: Input an option number ************************** 

InputNumber: 
    GoSub, GuiChanged 
    num := InputNumber(val) 
return 

InputNumber(defaultnum) 
{ 
    Global InputNum 

    Gui, 1:+Disabled 
    Gui, 2:Default 
    Gui, +Owner1 

    Gui, -MinimizeBox -MaximizeBox 

    Gui, Add, Text, Section, MsgBox Options value: 

    Gui, Add, Edit, Limit7 Number vInputNum Section w110 -WantReturn, %defaultnum% 

    Gui, Add, Button, XS w50 g2GuiOK Section Default, &OK 
    Gui, Add, Button, YS w50 g2GuiClose, &Cancel 
    
    Gui, 1:+LastFound 
    WinGetPos, posx, posy 
    posx += 80 
    posy += 50 
    Gui, Show, X%posx% Y%posy%, Input# 
} 

2GuiOK: 
    Gui, 2:Submit, NoHide 
    Gui, 1:Default 

    GuiControl, Enable, &2 
    GuiControl, Enable, &3 
    GuiControl, Choose, ButtonsVal, 3 
    val := round((InputNum & 0x300) / 0x100) + 1 
    GuiControl, , &%val%, 1 

    val := (InputNum & 7) + 1 
    if (val > 7) { 
        val = 1 
        soundbeep 
    } 
    GuiControl, Choose, ButtonsVal, %val% 

    GuiControl, , HelpButton, % round((InputNum & 0x4000) / 0x4000) 

    val := round((InputNum & 0x70) / 0x10) 
    if (val == 0) 
        LV_Modify(1, "Select Focus") 
    else 
        LV_Modify(6 - val, "Select Focus") 

    val := InputNum & 0x63000 
    if (val == 0) 
        GuiControl, Choose, WindowVal, 1 
    else if (val == 0x1000) 
        GuiControl, Choose, WindowVal, 3 
    else if (val == 0x2000) 
        GuiControl, Choose, WindowVal, 2 
    else if (val == 0x40000) 
        GuiControl, Choose, WindowVal, 4 
    else if (val == 0x20000) 
        GuiControl, Choose, WindowVal, 5 
    else { 
        Soundbeep 
        GuiControl, Choose, WindowVal, 1 
    } 

    GuiControl, , RightJustify, % round((InputNum & 0x80000) / 0x80000) 
    GuiControl, , RightToLeft,  % round((InputNum & 0x100000) / 0x100000) 

    GoSub, 2GuiClose 
    GoSub, GuiChanged 
return 

2GuiEscape: 
2GuiClose: 
    Gui, 2:Destroy 
    Gui, 1:-Disabled 
    Gui, 1:Default 
    Gui, 1:+LastFound 
    WinActivate 
return
