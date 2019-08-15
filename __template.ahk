#KeyHistory 0
#NoEnv
#Persistent
#SingleInstance Force

#Include, %A_ScriptDir%\..\..\lib\Array.Prototype.ahk
#Include, %A_ScriptDir%\..\..\lib\GDIp.ahk
#Include, %A_ScriptDir%\..\..\lib\GDIp_Canvas.ahk
#Include, %A_ScriptDir%\..\..\lib\Geometry.ahk

ListLines, Off
Process, Priority, , R
SetBatchLines, -1

vCanvas := 150
Global vCanvas := new Canvas("gCanvas", "-Caption +AlwaysOnTop +ToolWindow +OwnDialogs +E0x20", A_ScreenWidth - vCanvas*2.5 + 5, vCanvas*.5 + 5, vCanvas*2 + 10, vCanvas*2 + 10)

SetTimer, Update, -1

OnExit, Exit

Return

;===== Hotkeys ==========;

~$^s::
	Critical
	SetTitleMatchMode, 2

	If (WinActive(A_ScriptName)) {
		Sleep, 200
		Reload
	}
	Return

~$Left::
	vCanvas.speedratio /= 2

	KeyWait, Left
	Return

~$Right::
	vCanvas.speedratio *= 2

	KeyWait, Right
	Return

~$Esc::
	KeyWait, Esc, T0.5
	If (ErrorLevel)
		Gosub, Exit

	Return

;===== Labels ==========;

Exit:
	SetTimer, Update, Delete

	vCanvas.ShutDown()

	ExitApp
	Return

Update:
	If (QPC(50)) {
		vCanvas.degrees := Mod(vCanvas.degrees + 1*vCanvas.speedratio, 360)

		If (vCanvas.speedratio != 1)
			Gdip_TextToGraphics(vCanvas.G, TrimTrailingZeros(vCanvas.speedratio) . "x", "x" . vCanvas.width - 35 . " cFFFFFFFF Bold r4 s10", "Arial")



		Gdip_DrawRectangle(vCanvas.G, vCanvas.pPen[0], 0, 0, vCanvas.width - 1, vCanvas.height - 1)
		vCanvas.Update()
	}

	SetTimer, Update, -1

	Return

;===== Functions ==========;

QPC(_time := 50) {
	Static f := 0, d := !DllCall("QueryPerformanceFrequency", "Int64P", f), n := 0, b := 0

	Return (!DllCall("QueryPerformanceCounter", "Int64P", n) + (b ? ((d := (n - b)/f*1000) > _time ? !(b := n - Mod(d, _time)) + 1 : 0) : !(b := n) - 1))
}

;===== Classes ==========;

Class __Class {
	__New() {
		Return (this)
	}

	Update() {
	}

	Draw() {
	}
}