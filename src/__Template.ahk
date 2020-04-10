;=====         Auto-execute         =========================;
;===============           Setting            ===============;

#Include, %A_ScriptDir%\..\..\..\AutoHotkey\lib\Color.ahk
#Include, %A_ScriptDir%\..\..\..\AutoHotkey\lib\General.ahk
#Include, %A_ScriptDir%\..\..\..\AutoHotkey\lib\ObjectOriented.ahk
#Include, %A_ScriptDir%\..\..\..\AutoHotkey\lib\Math.ahk
#Include, %A_ScriptDir%\..\..\lib\GDIp.ahk
#Include, %A_ScriptDir%\..\..\lib\Geometry.ahk

#KeyHistory 0
#NoEnv
#Persistent
#SingleInstance, Force

CoordMode, Mouse, Screen
ListLines, Off
Process, Priority, , R
SetBatchLines, -1
SetWorkingDir, % A_ScriptDir . "\.."

;===============           Variable           ===============;

IniRead, vDebug, % A_WorkingDir . "\..\AutoHotkey\cfg\Settings.ini", Debug, Debug
Global vDebug

v := 150
Global oCanvas := new GDIp.Canvas([A_ScreenWidth - v*3.5 + 5, v*.5 + 5, v*2 + 10, v*2 + 10], "-Caption +AlwaysOnTop +ToolWindow +OwnDialogs +E0x20")
	, oBrush := [new GDIp.Brush(), new GDIp.LinearGradientBrush([5, 5, oCanvas.Size.Width - 10, oCanvas.Size.Height - 10], [Color.Random(), Color.Random()])], oPen := [new GDIp.Pen(), new GDIp.Pen(oBrush[1])]

	, oBorder := new Rectangle([5, 5, oCanvas.Size.Width - 10, oCanvas.Size.Height - 10])

oCanvas.SpeedRatio := 1.0

;===============            Timer             ===============;

SetTimer, Update, -1

;===============            Other             ===============;

OnExit("Exit")

Exit

;=====            Hotkey            =========================;

#If (WinActive(A_ScriptName) || WinActive("GDIp.ahk") || WinActive("Geometry.ahk"))

	~$^s::
		Critical
		SetTitleMatchMode, 2

		Sleep, 200
		Reload
		Return

	$F10::ListVars

#IF

~$Left::
	oCanvas.SpeedRatio /= 2

	KeyWait("Left")
	Return

~$Right::
	oCanvas.SpeedRatio *= 2

	KeyWait("Right")
	Return

~$Esc::
	If (KeyWait("Esc", "T0.5")) {
		Exit()
	}
	Return

;=====           Function           =========================;

Exit() {
	Critical

	GDIp.Shutdown()
	ExitApp
}

Update() {
	Static __Time := 0

	If (QueryPerformanceCounter_Passive()) {
		__Time := Mod(__Time + 1*oCanvas.SpeedRatio, 360)

		oCanvas.DrawString(oBrush[0], Round(__Time) . "°", "x10 y10 Bold r4 s10")
		If (oCanvas.SpeedRatio != 1) {
			v := Round(oCanvas.SpeedRatio, 1)

			oCanvas.DrawString(oBrush[0], v . "x", "x" . oCanvas.Size.Width - (15 + 6*StrLen(v)) . "y10 Bold r4 s10")
		}

		oCanvas.DrawRectangle(oPen[0], oBorder)

		oCanvas.Update()
	}

	SetTimer, Update, -1
}

;=====            Class             =========================;

Class __Class {
	__New() {

	}

	Update() {

	}

	Draw() {

	}
}