﻿;============ Auto-execute ====================================================;
;=======================================================  Admin  ===============;

if (!A_IsAdmin || !(DllCall("GetCommandLine", "Str") ~= " /restart(?!\S)")) {
	try {
		Run, % Format("*RunAs {}", (A_IsCompiled) ? (A_ScriptFullPath . " /restart") : (A_AhkPath . " /restart " . A_ScriptFullPath))
	}

	ExitApp
}

;======================================================  Setting  ==============;

#InstallKeybdHook
#InstallMouseHook
#KeyHistory, 0
#NoEnv
;#NoTrayIcon
;#Persistent
#SingleInstance, Force
#Warn, ClassOverwrite, MsgBox

CoordMode, Mouse, Screen
CoordMode, ToolTip, Screen
;DetectHiddenWindows, On
ListLines, Off
Process, Priority, , High
SendMode, Input
SetBatchLines, -1
SetTitleMatchMode, 2
SetWorkingDir, % A_ScriptDir . "\..\.."

;==============  Include  ======================================================;

#Include, %A_ScriptDir%\..\..\lib\Core.ahk

#Include, %A_ScriptDir%\..\..\lib\General\General.ahk

#Include, %A_ScriptDir%\..\..\lib\Color\Color.ahk
#Include, %A_ScriptDir%\..\..\lib\Math\Math.ahk
#Include, %A_ScriptDir%\..\..\lib\Geometry.ahk

;======================================================== Menu ================;

Menu, Tray, Icon, % A_WorkingDir . "\res\Image\Icon\1.ico"

;=======================================================  Group  ===============;

for i, v in [A_ScriptName, "Core.ahk", "User32.ahk", "GDI.ahk", "GDIp.ahk", "Canvas.ahk", "Bitmap.ahk", "Graphics.ahk", "Brush.ahk", "Pen.ahk", "Path.ahk"
		, "Assert.ahk", "Console.ahk", "String.ahk", "General.ahk", "Color.ahk", "Math.ahk", "Geometry.ahk"] {
	GroupAdd, % "Group", % v
}

;====================================================== Variable ==============;

Global Debug := Settings.Debug
	, WindowMessage := DllCall("RegisterWindowMessage", "Str", "WindowMessage", "UInt")

;======================================================== GDIp ================;

GDIp.Startup()

Global Canvas := GDIp.CreateCanvas(A_ScreenWidth - (150*2 + 50 + 10), 50, 150*2, 150*2, "+AlwaysOnTop -Caption +ToolWindow +E0x20", "NA", "Canvas", 4, 7)
	, Pen := GDIp.CreatePen(0x80FFFFFF)

	, ScriptObject := new Ellipse(0, 0, 300, 300)
	, Points := []

	, Started := False
	, Running := False

loop, % number := 8 {
	i := A_Index - 1
		, v := Color.ToRGB(Mod(360/number*i, 360)/360)

	Points.Push(new PointTemplate(i, 5, Math.ToRadians(180/number*i), GDIp.CreateSolidBrush(Color.ToRGB(Mod(360/number*i, 360)/360))))
}

;======================================================== Hook ================;

OnMessage(WindowMessage, "WindowMessage")

OnExit("Exit")

;======================================================== Test ================;

;=======================================================  Other  ===============;

Start()

exit

;=============== Hotkey =======================================================;
;=======================================================  Mouse  ===============;

;====================================================== Keyboard ==============;

#If (WinActive("ahk_group Group"))

	$F10::
		ListVars
		return

	~$^s::
		Critical, On

		Sleep, 200
		Reload

		return

#If

#If (Debug)

	~*$RShift::
		if (!Running) {
			Update(1000/Settings.TargetFPS)
			Draw()
		}

		KeyWait("RShift")
		return

	$#::
		if (KeyWait("#", "T1")) {
			if (Started) {
				Stop()
			}
			else {
				Start()
			}

			KeyWait("#")
		}
		else {
			Send, {#}
		}

		return

#If

~$Left::
	ScriptObject.SpeedRatio /= 2

	KeyWait("Left")
	return

~$Right::
	ScriptObject.SpeedRatio *= 2

	KeyWait("Right")
	return

;===============  Label  =======================================================;

;============== Function ======================================================;
;======================================================== Hook ================;

WindowMessage(wParam := 0, lParam := 0) {
	switch (wParam) {
		case 0xCE00: {

		}
		case 0x1000: {
			IniRead, Debug, % A_WorkingDir . "\cfg\Settings.ini", Debug, Debug

			if (!Debug) {
				ToolTip, , , , 20
			}

			return (0)
		}
	}

	return (-1)
}

Exit() {
	Critical, On

	GDIp.Shutdown()

	ExitApp
}

;=======================================================  Other  ===============;

GetTime() {
	Local

	DllCall("QueryPerformanceCounter", "Int64*", current := 0)

	return (current)
}

;======================================================== GDIp ================;  ;* All of the following code is based on this amazing tutorial: https://www.isaacsukin.com/news/2015/01/detailed-explanation-javascript-game-loops-and-timing.

Start() {
	if (!Started) {
		Started := True

		Draw()

		Running := True

		SetTimer(Func("MainLoop").Bind(True), -1)
	}
}

Stop() {
	Running := False, Started := False

	SetTimer("MainLoop", "Delete")
}

MainLoop(reset := 0) {
	Local updateCount, panic

	Static slowFactor := 1  ;* Slow motion scaling factor.
		, timeStep := 1000/Settings.TargetFPS, slowStep := timeStep*slowFactor  ;* The amount of time (in milliseconds) to simulate each time `Update()` is called.

	Static previous  ;* The timestamp of the last time the main loop was run. Used to compute the time elapsed between frames.
		, delta := 0  ;* The cumulative amount of time that hasn't been simulated yet.

	if (reset) {
		previous := GetTime()
	}

	current := GetTime()

	Static throttle := 1000/Settings.MaxFPS

	if ((elapsed := (current - previous)/10000) < throttle) {  ;* Throttle the frame rate.
		return (SetTimer("MainLoop", -elapsed))
	}

	;---------------  Begin  -------------------------------------------------------;

	Begin()

	;--------------- Update -------------------------------------------------------;

	previous := current
		, delta += Math.Min(1000, elapsed)  ;* Track the accumulated time that hasn't been simulated yet. This approach avoids inconsistent rounding errors and ensures that there are no giant leaps between frames.

	Static ticks := 0, frames := 0

	updateCount := 0  ;* The number of times `Update()` is called in a given frame.

	while (delta >= slowStep) {
		++ticks, Update(timeStep)

		delta -= slowStep

		if (++updateCount >= 240) {
			panic := True  ;* Indicates too many updates have taken place because the simulation has fallen too far behind real time.

			break
		}
	}

	;----------------  FPS  --------------------------------------------------------;

	Static previousFpsUpdate := A_TickCount
		, averageTicks := Settings.TargetFPS, averageFrames := averageTicks/2, alpha := Settings.FPSAlpha

	if ((A_TickCount - previousFpsUpdate) >= 1000) {
		previousFpsUpdate += 1000

		averageTicks := averageTicks*alpha + ticks*(1 - alpha), ticks := 0
			, averageFrames := averageFrames*0.75 + frames*0.25, frames := 0  ;* An exponential moving average of the frames per second.

		if (Debug) {
			ToolTip, % averageFrames ", " averageTicks, 50, 50, 20
		}
	}

	;--------------- Render -------------------------------------------------------;

	++frames, Draw(delta/timeStep)  ;* Render the screen. We do this regardless of whether `Update()` has run during this frame because it is possible to interpolate between updates to make the frame rate appear faster than updates are actually happening.

	;----------------  End  --------------------------------------------------------;

	End(panic, averageFrames)  ;* Run any updates that are not dependent on time in the simulation.

	SetTimer("MainLoop", -1)
}

Begin() {  ;* Typically used to process input before the updates run. Processing input here (in chunks) can reduce the running time of event handlers, which is useful because long-running event handlers can sometimes delay frames.

}

Update(delta) {  ;* Simulates everything that is affected by time. It can be called zero or more times per frame depending on the frame rate.
	Local point

	Static theta := 0
	theta := Mod(theta + delta, 6000)  ;? delta = 16.666667, delta*360 = 6000.000000

	for i, point in Points {
		point.Update(theta)
	}
}

Draw(interpolation := 0) {  ;* A function that draws things on the screen.
	Local point

	Canvas.Clear()

	Canvas.Graphics.DrawEllipse(Pen, ScriptObject)

	for i, point in Points {
		Canvas.Graphics.DrawLine(Pen, point.Start, point.End)  ;* Draw the lines first so that the ellipses are drawn over them.
	}

	for i, point in Points {
		point.Draw(interpolation)
	}

	Canvas.Update()
}

End(panic, averageFrames) {  ;* Handles any updates that are not dependent on time in the simulation since it is always called exactly once at the end of every frame.
	if (panic) {
		Console.Clear()
		Console.Write("Panic!")

		Stop()
	}

	if (!Debug) {
		if (averageFrames < 25) {
			ToolTip, % averageFrames . ", " . averageTicks, 50, 50, 20
		}
		else if (averageFrames > 30) {
			ToolTip, , , , 20
		}
	}
}

;===============  Class  =======================================================;

Class Settings {
	Debug[] {
		Get {
			Local

			IniRead, debug, % A_ScriptDir . "\..\cfg\Settings.ini", Debug, Debug
			ObjRawSet(this, "Debug", debug)

			return (debug)
		}
	}

	TargetFPS[] {  ;* Generally, 60 is a good choice because most monitors run at 60 Hz.
		Get {
			return (60)
		}
	}

	MaxFPS[] {
		Get {
			return (60)
		}
	}

	FPSAlpha[] {  ;* A factor that affects how heavily to weigh more recent seconds' performance when calculating the average frames per second in the range `(0.0, 1.0)`. Higher values result in weighting more recent seconds more heavily.
		Get {
			return (0.85)
		}
	}
}

Class PointTemplate {
	__New(index, radius, theta, brush) {
		this.Index := index*Math.Pi
		this.Radius := radius

		this.Width := this.Height := radius*2

		this.Cos := Math.Cos(theta)
		this.Sin := Math.Sin(theta)

		radius := ScriptObject.Radius
			, cos := radius*Math.Cos(theta), sin := radius*Math.Sin(theta)

		;* Points of the radius at this angle:
		this.Start := new Vec2(ScriptObject.h + cos, ScriptObject.k + sin)
		this.End := new Vec2(ScriptObject.h - cos, ScriptObject.k - sin)

		this.Brush := brush
	}

	Update(theta) {
		Static step := Math.Tau/6000

		r := ScriptObject.Radius*Math.Cos(step*theta + this.Index/Points.Length)
			, this.x := ScriptObject.h + r*this.Cos - this.Radius, this.y := ScriptObject.k + r*this.Sin - this.Radius
	}

	Draw(interpolation) {
		Canvas.Graphics.FillEllipse(this.Brush, this)
	}
}