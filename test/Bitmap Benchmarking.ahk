;============ Auto-execute ====================================================;
;======================================================  Setting  ==============;

#InstallKeybdHook
#InstallMouseHook
#KeyHistory, 0
#NoEnv
;#NoTrayIcon
;#Persistent
#SingleInstance, Force
#Warn, ClassOverwrite, MsgBox
#WinActivateForce

CoordMode, Mouse, Screen
CoordMode, ToolTip, Screen
;DetectHiddenWindows, On
ListLines, Off
Process, Priority, , High
SendMode, Input
SetBatchLines, -1
SetKeyDelay, -1, -1
SetTitleMatchMode, 2
SetWinDelay, -1
SetWorkingDir, % A_ScriptDir . "\.."

;====================================================== Variable ==============;

bitmapWidth := A_ScreenWidth
bitmapHeight := A_ScreenHeight

;======================================================== Test ================;

DllCall("Kernel32\LoadLibrary", "Str", "Gdiplus", "Ptr")

VarSetCapacity(input, 8 + A_PtrSize*2)
	, NumPut(0x1, &input + 0, "UInt")

DllCall("Gdiplus\GdiplusStartup", "Ptr*", pToken := 0, "Ptr", &input, "Ptr", 0, "Int")

;* ** Bitmap Benchmark Setup **
DllCall("Gdiplus\GdipCreateBitmapFromScan0", "UInt", bitmapWidth, "UInt", bitmapHeight, "UInt", 0, "UInt", 0x26200A, "Ptr", 0, "Ptr*", pBitmap := 0, "Int")

GdipBitmapSetPixel := DllCall("Kernel32\GetProcAddress", "Ptr", DllCall("Kernel32\GetModuleHandle", "Str", "Gdiplus", "Ptr"), "AStr", "GdipBitmapSetPixel", "Ptr")

DllCall("Gdiplus\GdipGetImageWidth", "Ptr", pBitmap, "UInt*", width := 0, "Int")
DllCall("Gdiplus\GdipGetImageHeight", "Ptr", pBitmap, "UInt*", height := 0, "Int")

;* 0 - SetPixel() (so that the bitmap has initial color values):
loop, % height {
    loop, % (width, x := 0) {
        DllCall(GdipBitmapSetPixel, "Ptr", pBitmap, "Int", x++, "Int", y, "Int", 0xFFFF0000)  ;* AARRGGBB for red.
    }

    y++
}

;* 1 - GetPixel():
reset := 0
    , y := 0

QueryPerformanceCounter(0)

loop, % (height) {
    loop, % (width, x := reset) {
		DllCall("Gdiplus\GdipBitmapGetPixel", "Ptr", pBitmap, "Int", x++, "Int", y, "UInt*", color)

;		MsgBox(Format("0x{:08X}", color))
    }

    y++
}

result .= "[1] " . Format("{:.2f}", compare1 := QueryPerformanceCounter(1)) . "ms.`n"

;* 2 - GetPixel() with GetProcAddress:
GdipBitmapGetPixel := DllCall("Kernel32\GetProcAddress", "Ptr", DllCall("Kernel32\GetModuleHandle", "Str", "Gdiplus", "Ptr"), "AStr", "GdipBitmapGetPixel", "Ptr")

reset := 0
    , y := 0

QueryPerformanceCounter(0)

loop, % (height) {
    loop, % (width, x := reset) {
		DllCall(GdipBitmapGetPixel, "Ptr", pBitmap, "Int", x++, "Int", y, "UInt*", color)

;		MsgBox(Format("0x{:08X}", color))
    }

    y++
}

result .= "[2] " . Format("{:.2f}", compare2 := QueryPerformanceCounter(1)) . "ms.`n"

;* 3 - GetLockBitPixel():
VarSetCapacity(rect, 16, 0)  ;* Rect structure.
    , NumPut(width, &rect + 8, "UInt"), NumPut(height, &rect + 12, "UInt")

VarSetCapacity(bitmapData, 16 + A_PtrSize*2, 0)  ;* BitmapData structure.

DllCall("Gdiplus\GdipBitmapLockBits", "Ptr", pBitmap, "Ptr", &rect, "UInt", 0x0003, "UInt", 0x26200A, "Ptr", &bitmapData, "Int")

reset := 0
    , y := 0, width := NumGet(&bitmapData + 0, "UInt"), height := NumGet(&bitmapData + 4, "UInt")

stride := NumGet(&bitmapData + 8, "Int"), scan0 := NumGet(&bitmapData + 16, "Ptr")

QueryPerformanceCounter(0)

loop, % height {
    loop, % (width, x := reset) {
        color := NumGet(scan0 + x*4 + y*stride, "UInt")

;		MsgBox(Format("0x{:08X}", color))
    }

    y++
}

result .= "[3] " . Format("{:.2f}", compare3 := QueryPerformanceCounter(1)) . "ms.`n"

DllCall("Gdiplus\GdipBitmapUnlockBits", "Ptr", pBitmap, "Ptr", &bitmapData, "Int")

;* 4 - Cleanup:
DllCall("Gdiplus\GdipDisposeImage", "Ptr", pBitmap)

DllCall("Gdiplus\GdiplusShutdown", "Ptr", pToken)
DllCall("Kernel32\FreeLibrary", "Ptr", DllCall("Kernel32\GetModuleHandle", "Str", "Gdiplus", "Ptr"), "UInt")

;* Result:
MsgBox, % result . "`nLockBits is " . Format("{:.2f}", compare2/compare3) " times faster than the GetProcAddress method."

exit

;=============== Hotkey =======================================================;

#If (WinActive(A_ScriptName))

	$F10::
		ListVars
		return

	~$^s::
		Critical, On

		Sleep, 200
		Reload

		return

#If

;============== Function ======================================================;

MsgBox(message := "", options := 0, title := "Beep Boop", timeOut := 0) {
	MsgBox, % options, % title, % (message == "") ? ("""""") : ((message.Base.HasKey("Print")) ? (message.Print()) : (message)), % timeOut
}

QueryPerformanceCounter(mode := 0) {
    Static frequency,  previous := !DllCall("QueryPerformanceFrequency", "Int64*", frequency)  ;: https://msdn.microsoft.com/en-us/library/ms644905.aspx

    DllCall("QueryPerformanceCounter", "Int64*", current)

    return (((mode) ? (current - previous) : (previous := current))/10000)  ;: https://msdn.microsoft.com/en-us/library/ms644904.aspx
}