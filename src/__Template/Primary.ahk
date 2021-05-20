;============ Auto-execute ====================================================;
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
SetWorkingDir, % A_ScriptDir . "\..\..\.."

;==============  Include  ======================================================;

#Include, %A_ScriptDir%\..\lib\Core.ahk
;#Include, %A_ScriptDir%\..\lib\Assert\Assert.ahk

#Include, %A_ScriptDir%\..\lib\Console\Console.ahk
#Include, %A_ScriptDir%\..\lib\String\String.ahk
#Include, %A_ScriptDir%\..\lib\General\General.ahk

#Include, %A_ScriptDir%\..\lib\Color\Color.ahk
#Include, %A_ScriptDir%\..\lib\Math\Math.ahk
#Include, %A_ScriptDir%\..\lib\Geometry.ahk

;======================================================== Menu ================;

Menu, Tray, Icon, % A_WorkingDir . "\res\Image\Icon\___.ico"

;====================================================== Variable ==============;

Global Debug := Setting.Debug
	, WindowMessage := DllCall("RegisterWindowMessage", "Str", "WindowMessage", "UInt")

;======================================================== GDIp ================;

GDIp.Startup()

Global Canvas := GDIp.CreateCanvas(A_ScreenWidth - (150*2 + 50 + 10), 50, 150*2, 150*2, "+AlwaysOnTop -Caption +ToolWindow +E0x20", "NA", "Canvas", 4, 7)
	, Brush := [GDIp.CreateSolidBrush(Color.Random(0xFF)), GDIp.CreateLinearBrushFromRect(0, 0, Canvas.Width, Canvas.Height, 0xFF << 24 | Color.Honeydew, 0xFF << 24 | Color.Sienna, 2, 0)]
	, Pen := [GDIp.CreatePenFromBrush(Brush[0]), GDIp.CreatePenFromBrush(Brush[1])]

	, ScriptObject := {"Border": new Rect(0, 0, Canvas.Width, Canvas.Height)
		, "SpeedRatio": 1.0}

	, Started := False
	, Running := False

;=======================================================  Group  ===============;

for i, v in [A_ScriptName, "Secondary.ahk", "Color.ahk", "Math.ahk", "GDIp.ahk", "Geometry.ahk"] {
	GroupAdd, % "Editing", % v
}

;======================================================== Hook ================;

OnMessage(WindowMessage, "WindowMessage")

OnExit("Exit")

;========================================================  Run  ================;

for i, v in ["Secondary"] {
	Run, % A_ScriptDir . "\" . v . ".ahk"
}

;=======================================================  Other  ===============;

Start()

exit

;=============== Hotkey =======================================================;
;=======================================================  Mouse  ===============;

;====================================================== Keyboard ==============;

#If (WinActive("ahk_group Editing"))

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

~$Esc::
	if (KeyWait("Esc", "T1")) {
		Exit()
	}

	return

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
	DllCall("QueryPerformanceCounter", "Int64*", current)

	return (current)
}

;======================================================== GDIp ================;

Start() {
	if (!Started) {
		Started := True

		Draw()

		Running := True

		SetTimer(Func("Main").Bind(True), -1)
	}
}

Stop() {
	Running := Started := False

	SetTimer("Main", "Delete")
}

Main(reset := 0) {
	Static slow := 1  ;* Slow motion scaling factor.
		, timeStep := 1000/Setting("TargetFPS"), slowStep := timeStep*slow  ;* The amount of time (in milliseconds) to simulate each time `Update()` is called.

		, maxFPS := 1000/Setting("TargetFPS")  ;* Used to throttle the frame rate.
		, previous  ;* The timestamp of the last time the main loop was run. Used to compute the time elapsed between frames.
		, delta := 0  ;* The cumulative amount of time that hasn't been simulated yet.

	if (reset) {
		previous := GetTime()
	}

	current := GetTime()

	if ((elapsed := (current - previous)/10000) < maxFPS) {
		SetTimer("Main", -elapsed)

		return
	}

	Begin()

	previous := current
		, delta += Math.Min(1000, elapsed)  ;* Track the accumulated time that hasn't been simulated yet. This approach avoids inconsistent rounding errors and ensures that there are no giant leaps between frames.

	Static ticks := 0, frames := 0

	numUpdateSteps := 0  ;* The number of times `Update()` is called in a given frame.
	while (delta >= slowStep) {
		++ticks
		Update(timeStep)

		delta -= slowStep

		if (++numUpdateSteps >= 240) {
			panic := True  ;* Whether the simulation has fallen too far behind real time.

			break
		}
	}

	++frames
	Draw(delta/timeStep)  ;* Pass the interpolation percentage.

	;----------------  FPS  --------------------------------------------------------;

	Static previousFpsUpdate := A_TickCount
		, averageTicks := Setting("TargetFPS"), averageFrames := averageTicks/2

	if ((A_TickCount - previousFpsUpdate) >= 1000) {
		previousFpsUpdate += 1000

		averageTicks := averageTicks*0.75 + ticks*0.25, ticks := 0  ;* Exponential moving average.
			, averageFrames := averageFrames*0.75 + frames*0.25, frames := 0

		if (Debug) {
			ToolTip, % averageFrames ", " averageTicks, 50, 50, 20
		}
	}

	;----------------  End  --------------------------------------------------------;

	End(averageFrames, averageTicks, panic)  ;* Run any updates that are not dependent on time in the simulation.

	SetTimer("Main", -1)
}

Begin() {  ;* The `Begin()` function is typically used to process input before the updates run. Processing input here (in chunks) can reduce the running time of event handlers, which is useful because long-running event handlers can sometimes delay frames.

}

Update(delta) {  ;* A function that runs updates (i.e. AI and physics).
	mouse := new Vec2(MouseGet("Pos")).Subtract(Canvas)

	for i, particle in Particles {
		particle.Update(mouse, delta)

		particle.CheckEdges()
	}
}

Draw(interp := 0) {  ;* A function that draws things on the screen.
	Canvas.Clear()

	Canvas.Graphics.DrawRectangle(Pen[0], ScriptObject.Border)

	for i, particle in Particles {
		particle.Draw(interp)
	}

	Canvas.Update()
}

End(averageFrames, averageTicks, panic) {
	if (panic) {
		Console.Clear()
		Console.Write("Panick!")

		Stop()
	}

	if (!Debug) {
		if (averageFrames < 25) {
			ToolTip, % averageFrames ", " averageTicks, 50, 50, 20
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
			IniRead, d, % A_WorkingDir . "\cfg\Settings.ini", Debug, Debug

			return (d)
		}
	}
	TargetFPS[] {  ;* An exponential moving average of the frames per second.
		Get {
			return (60)
		}
	}

	FPSAlpha[] {  ;* A factor that affects how heavily to weigh more recent seconds' performance when calculating the average frames per second. Valid values range from zero to one inclusive. Higher values result in weighting more recent seconds more heavily.
		Get {
			return (0.9)
		}
	}
}

Class _____ {
	__New() {

	}

	Update() {

	}

	Draw() {

	}
}