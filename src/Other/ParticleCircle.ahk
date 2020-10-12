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
		, oPen := [new GDIp.Pen("0xFFFFFFFF", 2), new GDIp.Pen("0x80FFFFFF")]

	, oEllipse := {"Ellipse": new Ellipse(5, 5, oCanvas.Rectangle.Width - 10, oCanvas.Rectangle.Height - 10)
		, "SpeedRatio": 1}
	, oParticle := []

;* Precompile all the points as its allot of data to calculate all the time:
Loop, 1800 {  ;? 1800 = 360*5
	oParticle.Push(new Particle(A_Index))
}

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
	oEllipse.SpeedRatio /= 2

	KeyWait("Left")
	Return

~$Right::
	oEllipse.SpeedRatio *= 2

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
	Static __Time := 99
		, __Alpha := [["FF", "E6", "CC", "B3", "99", "80", "66", "4D", "33", "1A"], ["1A", "33", "4D", "66", "80", "99", "B3", "CC", "E6", "FF"]]

	If (QueryPerformanceCounter_Passive()) {
		__Time := Mod(__Time + (1 - .5*(__Time >= 50))*oEllipse.SpeedRatio, 101)

		oCanvas.DrawString(oBrush[0], Round(__Time), "Bold r4 s10 x10 y10")
		If (oEllipse.SpeedRatio != 1) {
			v := Round(oEllipse.SpeedRatio, 2), oCanvas.DrawString(oBrush[0], v . "x", Format("Bold r4 s10 x{} y10", oCanvas.Rectangle.Width - (15 + 6*StrLen(v))))
		}

		If (__Time >= 50) {
			r := __Time/100
				, o := new Ellipse(oEllipse.Ellipse.h - (o := oEllipse.Ellipse.Diameter*r)/2, oEllipse.Ellipse.h - o/2, o, o)  ;* Scale the primary ellipse.

			If (__Time < 60) {
				oPen[0].Color := Format("0x{}FFFFFF", __Alpha[0][Round(60 - __Time) - 1])
			}

			oCanvas.DrawEllipse(oPen[0], o)
		}
		Else If (__Time < 10) {
			oPen[0].Color := Format("0x{}FFFFFF", __Alpha[1][Round(10 - __Time) - 1])

			oCanvas.DrawEllipse(oPen[0], oEllipse.Ellipse)
		}

		For i, v in oParticle {
			If (__Time + (i := Max(0, Round(__Time - v.Delay))) < 100) {  ;* Account for delayed particles to stop drawing them as they come into contact with the primary ellipse.
				oCanvas.DrawEllipse(oPen[1], {"x": (p := v.Step[i]).x, "y": p.y, "Width": 2, "Height": 2})
			}
		}

		oCanvas.Update()
	}

	SetTimer, Update, -1
}

;=====            Class             =========================;

Class Particle {

	__New(vTheta) {
		this.Step := []
		this.Delay := Abs(Math.RandomNormal(-1, 2))/6*50  ;? Math.RandomNormal(Mean, Deviation)

		;* Create an array with a coresponding point for the particle at any give `__Time` between 0 and 50:
		Loop, 50 {
			r := 1 - A_Index/100  ;* Scale the primary ellipse by this ratio to get a point on the circumference at `vTheta`.
				, o := new Ellipse(oEllipse.Ellipse.h - (o := oEllipse.Ellipse.Diameter*r)/2, oEllipse.Ellipse.h - o/2, o, o)

			this.Step.Push(Point2D.OnEllipse(o, vTheta))
		}
	}
}
