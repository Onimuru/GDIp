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
SetWorkingDir, % A_ScriptDir . "\..\.."

;===============           Variable           ===============;

IniRead, vDebug, % A_WorkingDir . "\..\AutoHotkey\cfg\Settings.ini", Debug, Debug
Global vDebug

Global oCanvas := new GDIp.Canvas([A_ScreenWidth - 150*2.5 + 5, 150*.5 + 5, 150*2 + 10, 150*2 + 10], "-Caption +AlwaysOnTop +ToolWindow +OwnDialogs +E0x20")
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

		oCanvas.DrawString(oBrush[0], Round(__Time) . "°", "Bold r4 s10 x10 y10")
		If (oCanvas.SpeedRatio != 1) {
			v := Round(oCanvas.SpeedRatio, 2), oCanvas.DrawString(oBrush[0], v . "x", "Bold r4 s10" . "x" . oCanvas.Size.Width - (15 + 6*StrLen(v)) . "y10")
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