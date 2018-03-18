; eD: Renamed this file from MI.ahk to MenuIcons.ahk; removed MI_SetMenuItemBitmap() as PKL didn't use it

;
;  Menu Icons v2
;   by Lexikos
;


; Associates an icon with a menu item.
; NOTE: On versions of Windows other than Vista, the menu MUST be shown with
;       MI_ShowMenu() for the icons to appear.
;
;   MenuNameOrHandle
;       The name or handle of a menu. When setting icons for multiple items,
;       it is more efficient to use a handle returned by MI_GetMenuHandle("menuname").
;   ItemPos
;       The position of the menu item, where 1 is the first item.
;   FilenameOrHICON
;       The filename or handle of an icon.
;       SUPPORTS EXECUTABLE FILES ONLY (EXE/DLL/ICL/CPL/etc.)
;   IconNumber
;       The icon group to use (if omitted, it defaults to 1.)
;       This is not used if FilenameOrHICON specifies an icon handle.
;   IconSize
;       The desired width and height of the icon. If omitted, the system's small icon size is used.
;   h_bitmap
;   h_icon
;       These are set to the bitmap or icon resources which are used.
;       Bitmaps and icons can be deleted as follows:
;           DllCall("DeleteObject", "uint", h_bitmap)
;           DllCall("DestroyIcon", "uint", h_icon)
;       This is only necessary if the menu item displaying these resources
;       is manually removed.
;       Usually only one of h_icon or h_bitmap will be used, and the other will be 0 (NULL).
;
; OPERATING SYSTEM NOTES:
;
; Windows 2000 and above:
;   PrivateExtractIcons() is used to extract the icon.
;
; Older versions of Windows:
;   PrivateExtractIcons() is not available, so ExtractIconEx() is used.
;   As a result, a 16x16 or 32x32 icon will be loaded. If a size is specified,
;   the icon may be stretched to fit. If no size is specified, 16x16 is used.
;
MI_SetMenuItemIcon(MenuNameOrHandle, ItemPos, FilenameOrHICON, IconNumber=1, IconSize=0, ByRef h_bitmap="", ByRef h_icon="")
{
    h_icon = 0
    h_bitmap = 0

    if MenuNameOrHandle is integer
        h_menu := MenuNameOrHandle
    else
        h_menu := MI_GetMenuHandle(MenuNameOrHandle)
    
    if !h_menu
        return false
    
    loaded_icon := false
    
    if FilenameOrHICON is not integer
    {   ; Load icon from file.
        h_icon := MI_ExtractIcon(FilenameOrHICON, IconNumber, IconSize)
        ; Remember to clean up this icon if we end up using a bitmap.
        loaded_icon := true
    } else
        h_icon := FilenameOrHICON
    
    if !h_icon
        return false
    
    
    if A_OSVersion = WIN_VISTA
    {   ; Windows Vista supports 32-bit alpha-blended bitmaps in menus.
        ; NOTE: The A_OSVersion check won't work if AHK is running in
        ;       compatibility mode for another version of Windows.
        h_bitmap := MI_GetBitmapFromIcon32Bit(h_icon, IconSize, IconSize)
        
        ; If we loaded an icon, delete it now as it is unnecessary.
        if (loaded_icon)
            DllCall("DestroyIcon","uint",h_icon), h_icon:=0
        
        if !h_bitmap
            return false
        
        VarSetCapacity(mii,48,0), NumPut(48,mii), NumPut(0x80,mii,4), NumPut(h_bitmap,mii,44)
        return DllCall("SetMenuItemInfo","uint",h_menu,"uint",ItemPos-1,"uint",1,"uint",&mii)
    }

    ; To get nice icons on other versions of Windows, we need to owner-draw.
    ; NOTE: This requires the menu to be opened using MI_ShowMenu().
    
    ; If an IconSize was specified, ensure the icon is the correct size.
    if IconSize
    {   ; LR_COPYRETURNORG=4    Return the original image if it is the right size.
        ; LR_COPYDELETEORG=8    If a copy was made, delete the original.
        h_icon := DllCall("CopyImage","uint",h_icon,"uint",1,"int",IconSize
                            ,"int",IconSize,"uint",loaded_icon ? 4|8 : 4)
    }
    
    ; Associate the icon with the menu item.
    ; This overwrites any data that might be in dwItemData.
    ; (Only an issue if set by some other script.)
    VarSetCapacity(mii,48,0), NumPut(48,mii), NumPut(0xA0,mii,4)
    NumPut(h_icon,  mii,32) ; mii.dwItemData = h_icon;
    NumPut(-1,      mii,44) ; mii.hbmpItem = HBMMENU_CALLBACK;
    if DllCall("SetMenuItemInfo","uint",h_menu,"uint",ItemPos-1,"uint",1,"uint",&mii)
        return true
    
    if loaded_icon
        DllCall("DestroyIcon","uint",h_icon), h_icon:=0
    return false
}

;
; General Functions
;

; Gets a menu handle from a menu name.
; Adapted from Shimanov's Menu_AssignBitmap()
;   http://www.autohotkey.com/forum/topic7526.html
MI_GetMenuHandle(menu_name)
{
    static   h_menuDummy
    If h_menuDummy=
    {
        Menu, menuDummy, Add
        Menu, menuDummy, DeleteAll

        Gui, 99:Menu, menuDummy
        Gui, 99:Show, Hide, guiDummy

        old_DetectHiddenWindows := A_DetectHiddenWindows
        DetectHiddenWindows, on

        Process, Exist
        h_menuDummy := DllCall( "GetMenu", "uint", WinExist( "guiDummy ahk_class AutoHotkeyGUI ahk_pid " ErrorLevel ) )
        If ErrorLevel or h_menuDummy=0
            return 0

        DetectHiddenWindows, %old_DetectHiddenWindows%

        Gui, 99:Menu
        Gui, 99:Destroy
    }

    Menu, menuDummy, Add, :%menu_name%
    h_menu := DllCall( "GetSubMenu", "uint", h_menuDummy, "int", 0 )
    DllCall( "RemoveMenu", "uint", h_menuDummy, "uint", 0, "uint", 0x400 )
    Menu, menuDummy, Delete, :%menu_name%
    
    return h_menu
}

; Valid (and safe to use) styles:
;   MNS_AUTODISMISS  0x10000000
;   MNS_CHECKORBMP   0x04000000  The same space is reserved for the check mark and the bitmap.
;   MNS_NOCHECK      0x80000000  No space is reserved to the left of an item for a check mark.
MI_SetMenuStyle(h_menu, style)
{
    VarSetCapacity(mi,28,0), NumPut(28,mi)
    NumPut(0x10,mi,4) ; fMask=MIM_STYLE
    NumPut(style,mi,8)
    DllCall("SetMenuInfo","uint",h_menu,"uint",&mi)
}

; Extract an icon from an executable, DLL or icon file.
MI_ExtractIcon(Filename, IconNumber, IconSize)
{
    ; LoadImage is not used..
    ; ..with exe/dll files because:
    ;   it only works with modules loaded by the current process,
    ;   it needs the resource ordinal (which is not the same as an icon index), and
    ; ..with ico files because:
    ;   it can only load the first icon (of size %IconSize%) from an .ico file.
    
    ; If possible, use PrivateExtractIcons, which supports any size of icon.
    if A_OSVersion in WIN_VISTA,WIN_2003,WIN_XP,WIN_2000
    {
        DllCall("PrivateExtractIcons"
            ,"str",Filename,"int",IconNumber-1,"int",IconSize,"int",IconSize
            ,"uint*",h_icon,"uint*",0,"uint",1,"uint",0,"int")
        if !ErrorLevel
            return h_icon
    }
    ; Use ExtractIconEx, which only returns 16x16 or 32x32 icons.
    if DllCall("shell32.dll\ExtractIconExA","str",Filename,"int",IconNumber-1
                ,"uint*",h_icon,"uint*",h_icon_small,"uint",1)
    {
        SysGet, SmallIconSize, 49
        
        ; Use the best-fit size; delete the other. Defaults to small icon.
        if (IconSize <= SmallIconSize) {
            DllCall("DestroyIcon","uint",h_icon)
            h_icon := h_icon_small
        } else
            DllCall("DestroyIcon","uint",h_icon_small)
        
        ; I think PrivateExtractIcons resizes icons automatically,
        ; so resize icons returned by ExtractIconEx for consistency.
        if (h_icon && IconSize)
            h_icon := DllCall("CopyImage","uint",h_icon,"uint",1,"int",IconSize
                                ,"int",IconSize,"uint",4|8)
    }

    return h_icon ? h_icon : 0
}

;
; Owner-Drawn Menu Functions
;

; Shows a menu, allowing owner-drawn icons to be drawn.
MI_ShowMenu(MenuNameOrHandle, x="", y="")
{
    static hInstance, hwnd, ClassName := "OwnerDrawnMenuMsgWin"

    if MenuNameOrHandle is integer
        h_menu := MenuNameOrHandle
    else
        h_menu := MI_GetMenuHandle(MenuNameOrHandle)
    
    if !h_menu
        return false
    
    if !hwnd
    {   ; Create a message window to receive owner-draw messages from the menu.
        ; Only one window is created per instance of the script.
    
        if !hInstance
            hInstance := DllCall("GetModuleHandle", "UInt", 0)

        ; Register a window class to associate OwnerDrawnMenuItemWndProc()
        ; with the window we will create.
        wndProc := RegisterCallback("MI_OwnerDrawnMenuItemWndProc")
        if !wndProc {
            ErrorLevel = RegisterCallback
            return false
        }
    
        ; Create a new window class.
        VarSetCapacity(wc, 40, 0)   ; WNDCLASS wc
        NumPut(wndProc,   wc, 4)   ; lpfnWndProc
        NumPut(hInstance, wc,16)   ; hInstance
        NumPut(&ClassName,wc,36)   ; lpszClassname

        ; Register the class.        
        if !DllCall("RegisterClass","uint",&wc)
        {   ; failed, free the callback.
            DllCall("GlobalFree","uint",wndProc)
            ErrorLevel = RegisterClass
            return false
        }
        
        ;
        ; Create the message window.
        ;
        if A_OSVersion in WIN_XP,WIN_VISTA
            hwndParent = -3 ; HWND_MESSAGE (message-only window)
        else
            hwndParent = 0  ; un-owned
        
        hwnd := DllCall("CreateWindowExA","uint",0,"str",ClassName,"str",ClassName
                        ,"uint",0,"int",0,"int",0,"int",0,"int",0,"uint",hwndParent
                        ,"uint",0,"uint",hInstance,"uint",0)
        if !hwnd {
            ErrorLevel = CreateWindowEx
            return false
        }
    }

    prev_hwnd := DllCall("GetForegroundWindow")

    ; Required for the menu to initially have focus.
    DllCall("SetForegroundWindow","uint",hwnd)
    
    if (x="" or y="") {
        CoordMode, Mouse, Screen
        MouseGetPos, x, y
    }

    ; returns non-zero on success.
    ret := DllCall("TrackPopupMenu","uint",h_menu,"uint",0,"int",x,"int",y
                    ,"int",0,"uint",hwnd,"uint",0)
    
    if WinExist("ahk_id " prev_hwnd)
        DllCall("SetForegroundWindow","uint",prev_hwnd)
    
    ; Required to let AutoHotkey process WM_COMMAND messages we may have
    ; sent as a result of clicking a menu item. (Without this, the item-click
    ; won't register if there is an 'ExitApp' after ShowOwnerDrawnMenu returns.)
    Sleep, 1
    
    return ret
}

MI_OwnerDrawnMenuItemWndProc(hwnd, Msg, wParam, lParam)
{
    static WM_DRAWITEM = 0x002B, WM_MEASUREITEM = 0x002C, WM_COMMAND = 0x111
    static ScriptHwnd
    
    if (Msg = WM_MEASUREITEM) ; && wParam = 0)
    {   ; MSDN: wParam - If the value is zero, the message was sent by a menu.
        h_icon := NumGet(lParam+20)
        if !h_icon
            return false
        
        ; Measure icon and put results into lParam.
        VarSetCapacity(buf,24)
        if DllCall("GetIconInfo","uint",h_icon,"uint",&buf)
        {
            hbmColor := NumGet(buf,16)
            hbmMask  := NumGet(buf,12)
            x := DllCall("GetObject","uint",hbmColor,"int",24,"uint",&buf)
            DllCall("DeleteObject","uint",hbmColor)
            DllCall("DeleteObject","uint",hbmMask)
            if !x
                return false
            NumPut(NumGet(buf,4,"int")+2, lParam+12) ; width
            NumPut(NumGet(buf,8,"int")  , lParam+16) ; height
            return true
        }
        return false
    }
    else if (Msg = WM_DRAWITEM) ; && wParam = 0)
    {
        hdcDest := NumGet(lParam+24)
        x       := NumGet(lParam+28)
        y       := NumGet(lParam+32)
        h_icon  := NumGet(lParam+44)
        if !(h_icon && hdcDest)
            return false

        return DllCall("DrawIconEx","uint",hdcDest,"int",x,"int",y,"uint",h_icon
                        ,"uint",0,"uint",0,"uint",0,"uint",0,"uint",3)
    }
    else if (Msg = WM_COMMAND) ; (clicked a menu item)
    {
        DetectHiddenWindows, On
        if !ScriptHwnd {
            Process, Exist
            ScriptHwnd := WinExist("ahk_class AutoHotkey ahk_pid " ErrorLevel)
        }
        ; Forward this message to the AutoHotkey main window.
        SendMessage, Msg, wParam, lParam,, ahk_id %ScriptHwnd%
        return ErrorLevel
    }
    ; Let the default window procedure handle all other messages.
    return DllCall("DefWindowProc","uint",hwnd,"uint",Msg,"uint",wParam,"uint",lParam)
}

;
; Windows Vista Menu Icons
;

; Note: 32-bit alpha-blended menu item bitmaps are supported only on Windows Vista.
; Article on menu icons in Vista:
; http://shellrevealed.com/blogs/shellblog/archive/2007/02/06/Vista-Style-Menus_2C00_-Part-1-_2D00_-Adding-icons-to-standard-menus.aspx
MI_GetBitmapFromIcon32Bit(h_icon, width=0, height=0)
{
    VarSetCapacity(buf,40) ; used as ICONINFO (20), BITMAP (24), BITMAPINFO (40)
    if DllCall("GetIconInfo","uint",h_icon,"uint",&buf) {
        hbmColor := NumGet(buf,16)  ; used to measure the icon
        hbmMask  := NumGet(buf,12)  ; used to generate alpha data (if necessary)
    }

    if !(width && height) {
        if !hbmColor or !DllCall("GetObject","uint",hbmColor,"int",24,"uint",&buf)
            return 0
        width := NumGet(buf,4,"int"),  height := NumGet(buf,8,"int")
    }

    ; Create a device context compatible with the screen.        
    if (hdcDest := DllCall("CreateCompatibleDC","uint",0))
    {
        ; Create a 32-bit bitmap to draw the icon onto.
        VarSetCapacity(buf,40,0), NumPut(40,buf), NumPut(1,buf,12,"ushort")
        NumPut(width,buf,4), NumPut(height,buf,8), NumPut(32,buf,14,"ushort")
        
        if (bm := DllCall("CreateDIBSection","uint",hdcDest,"uint",&buf,"uint",0
                            ,"uint*",pBits,"uint",0,"uint",0))
        {
            ; SelectObject -- use hdcDest to draw onto bm
            if (bmOld := DllCall("SelectObject","uint",hdcDest,"uint",bm))
            {
                ; Draw the icon onto the 32-bit bitmap.
                DllCall("DrawIconEx","uint",hdcDest,"int",0,"int",0,"uint",h_icon
                        ,"uint",width,"uint",height,"uint",0,"uint",0,"uint",3)

                DllCall("SelectObject","uint",hdcDest,"uint",bmOld)
            }
        
            ; Check for alpha data.
            has_alpha_data := false
            Loop, % height*width
                if NumGet(pBits+0,(A_Index-1)*4) & 0xFF000000 {
                    has_alpha_data := true
                    break
                }
            if !has_alpha_data
            {
                ; Ensure the mask is the right size.
                hbmMask := DllCall("CopyImage","uint",hbmMask,"uint",0
                                    ,"int",width,"int",height,"uint",4|8)
                
                VarSetCapacity(mask_bits, width*height*4, 0)
                if DllCall("GetDIBits","uint",hdcDest,"uint",hbmMask,"uint",0
                            ,"uint",height,"uint",&mask_bits,"uint",&buf,"uint",0)
                {   ; Use icon mask to generate alpha data.
                    Loop, % height*width
                        if (NumGet(mask_bits, (A_Index-1)*4))
                            NumPut(0, pBits+(A_Index-1)*4)
                        else
                            NumPut(NumGet(pBits+(A_Index-1)*4) | 0xFF000000, pBits+(A_Index-1)*4)
                } else {   ; Make the bitmap entirely opaque.
                    Loop, % height*width
                        NumPut(NumGet(pBits+(A_Index-1)*4) | 0xFF000000, pBits+(A_Index-1)*4)
                }
            }
        }
    
        ; Done using the device context.
        DllCall("DeleteDC","uint",hdcDest)
    }

    if hbmColor
        DllCall("DestroyObject","uint",hbmColor)
    if hbmMask
        DllCall("DestroyObject","uint",hbmMask)
    return bm
}
