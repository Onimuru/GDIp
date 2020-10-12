;=====         Auto-execute         =========================;
;===============           Setting            ===============;

#Include, %A_ScriptDir%\..\..\..\lib\Color.ahk
#Include, %A_ScriptDir%\..\..\..\lib\General.ahk
#Include, %A_ScriptDir%\..\..\..\lib\ObjectOriented.ahk
#Include, %A_ScriptDir%\..\..\..\lib\Math.ahk
#Include, %A_ScriptDir%\..\..\..\lib\GDIp.ahk
#Include, %A_ScriptDir%\..\..\..\lib\Geometry.ahk

#KeyHistory 0
#NoEnv
#Persistent
#SingleInstance, Force

ListLines, Off
Process, Priority, , R
SetBatchLines, -1
SetWorkingDir, % A_ScriptDir . "\..\..\.."

;===============           Variable           ===============;

IniRead, vDebug, % A_WorkingDir . "\cfg\Settings.ini", Debug, Debug
Global vDebug
	, oCanvas := new GDIp.Canvas({"x": A_ScreenWidth - (150*2 + 50 + 10 + 1), "y": 50, "Width": 150*2 + 10, "Height": 150*2 + 10}, "-Caption +AlwaysOnTop +ToolWindow +OwnDialogs +E0x20")
		, oBrush := [new GDIp.Brush(), new GDIp.LineBrush(new Rectangle(5, 5, oCanvas.Rectangle.Width - 10, oCanvas.Rectangle.Height - 10), [Color.Random(), Color.Random()])]
		, oPen := [new GDIp.Pen(), new GDIp.Pen(oBrush[1])]

	, oObject := {"Rectangle": new Rectangle(5, 5, oCanvas.Rectangle.Width - 10, oCanvas.Rectangle.Height - 10)
		, "SpeedRatio": 1}

;===============            Other             ===============;

OnExit("Exit"), Update()

Exit

;=====            Hotkey            =========================;

#If (WinActive(A_ScriptName) || WinActive("GDIp.ahk") || WinActive("Geometry.ahk"))

	~$^s::
		Critical

		Sleep, 200
		Reload
		Return

	$F10::ListVars

#If

~$Left::
	oObject.SpeedRatio /= 2

	KeyWait("Left")
	Return

~$Right::
	oObject.SpeedRatio *= 2

	KeyWait("Right")
	Return

~$Esc::
	If (KeyWait("Esc", "T1")) {
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
		__Time := Mod(__Time + 1*oObject.SpeedRatio, 360)

		oCanvas.DrawString(oBrush[0], Round(__Time) . "°", "Bold r4 s10 x10 y10")
		If (oObject.SpeedRatio != 1) {
			v := Round(oObject.SpeedRatio, 2), oCanvas.DrawString(oBrush[0], v . "x", Format("Bold r4 s10 x{} y10", oCanvas.Rectangle.Width - (15 + 6*StrLen(v))))
		}

		oCanvas.DrawRectangle(oPen[0], oObject.Rectangle)

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
