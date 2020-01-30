#KeyHistory 0
#NoEnv
#SingleInstance Force

#Include, %A_ScriptDir%\..\..\..\lib\Array.Prototype.ahk
#Include, %A_ScriptDir%\..\..\..\lib\GDIp.ahk
#Include, %A_ScriptDir%\..\..\..\lib\GDIp_Canvas.ahk
#Include, %A_ScriptDir%\..\..\..\lib\Geometry.ahk
#Include, %A_ScriptDir%\..\..\..\lib\Functions.ahk
#Include, %A_ScriptDir%\..\..\..\lib\Math.ahk

ListLines, Off
Process, Priority, , R
SetBatchLines, -1
SetFormat, FloatFast, 0.15

vCanvas := 150
Global vCanvas := new Canvas("gCanvas", "-Caption +AlwaysOnTop +ToolWindow +OwnDialogs +E0x20", A_ScreenWidth - vCanvas*2.5 + 5, vCanvas*.5 + 5, vCanvas*2 + 10, vCanvas*2 + 10)
vCircle := New Ellipse(5, 5, vCanvas.Width - 10, vCanvas.Height - 10)

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

~$F10::
	If (WinActive(A_ScriptName))
		ListVars
	Return

~$Left::
	vCanvas.SpeedRatio /= 2

	KeyWait, Left
	Return

~$Right::
	vCanvas.SpeedRatio *= 2

	KeyWait, Right
	Return

~$Esc::
	KeyWait, Esc, T0.5
	If (ErrorLevel)
		Gosub, Exit

	Return

;===== Labels ==========;

Exit:
	Critical

	SetTimer, Update, Delete
	vCanvas.ShutDown()

	ExitApp

Update:
	If (QPC()) {
		vCanvas.Time := Mod(vCanvas.Time, 360) + (1*vCanvas.SpeedRatio)

		If (vCanvas.SpeedRatio != 1)
			Gdip_TextToGraphics(vCanvas.G, (v := Round(vCanvas.SpeedRatio)) . "x", "x" . vCanvas.Width - (20 + 5.75*StrLen(v)) . "y10" . " CFFFFFFFF Bold R4 S10", "Arial")

		Gdip_DrawRectangle(vCanvas.G, vCanvas.pPen[0], 5, 5, vCanvas.Width - 10, vCanvas.Height - 10)

		vCanvas.Update(1, 1)
	}

	SetTimer, Update, -1
	Return

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

;===== Functions ==========;

QPC(_Time := 50) {
	Static f := 0, b := !DllCall("QueryPerformanceFrequency", "Int64P", f)

	Return (!DllCall("QueryPerformanceCounter", "Int64P", n) + (b ? (((d := (n - b)/f*1000) > _Time) ? !(b := n - Mod(d, _Time)) + 1 : 0) : !(b := n) - 1))
}
