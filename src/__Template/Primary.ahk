;============ Auto-execute ====================================================;
;======================================================  Setting  ==============;

;#NoTrayIcon
#SingleInstance
#Warn All, MsgBox
#Warn LocalSameAsGlobal, Off
#WinActivateForce

CoordMode("Mouse", "Screen")
CoordMode("ToolTip", "Screen")
;DetectHiddenWindows(True)
InstallKeybdHook(True)
InstallMouseHook(True)
ListLines(False)
Persistent(True)
ProcessSetPriority("High")
SetKeyDelay(-1, -1)
SetWinDelay(-1)
SetWorkingDir(A_ScriptDir . "\..\..")

;==============  Include  ======================================================;

#Include %A_ScriptDir%\..\..\lib\Core.ahk

#Include %A_ScriptDir%\..\..\lib\Console\Console.ahk
#Include %A_ScriptDir%\..\..\lib\General\General.ahk

#Include %A_ScriptDir%\..\..\lib\Color\Color.ahk
#Include %A_ScriptDir%\..\..\lib\Math\Math.ahk
;#Include %A_ScriptDir%\..\..\lib\Geometry.ahk

;======================================================== Menu ================;

TraySetIcon(A_WorkingDir . "\res\Image\Icon\1.ico")

;=======================================================  Group  ===============;

for i, v in ["Core.ahk", "GDI.ahk", "GDIp.ahk", "Canvas.ahk", "Bitmap.ahk", "Graphics.ahk", "Brush.ahk", "Pen.ahk", "Path.ahk", "Matrix.ahk",
		"Assert.ahk", "Console.ahk", "General.ahk",
		"Color.ahk", "Math.ahk", "Geometry.ahk"] {
	GroupAdd("Library", v)
}

;====================================================== Variable ==============;

global A_Debug := IniRead(A_WorkingDir . "\cfg\Settings.ini", "Debug", "Debug")
	, A_WindowMessage := DllCall("RegisterWindowMessage", "Str", "WindowMessage", "UInt")

;======================================================== GDIp ================;

GDIp.Startup()

global Canvas := GDIp.CreateCanvas(A_ScreenWidth - (150*2 + 50 + 10), 50, 150*2, 150*2, "", "Canvas", 0, "Title", 0, 0, 4, 7)
	, Brush := [GDIp.CreateSolidBrush(Color("AliceBlue")), GDIp.CreateLinearBrushFromRect(0, 0, Canvas.Width, Canvas.Height, Color("Honeydew"), Color("Sienna"), 2, 0)]
	, Pen := [GDIp.CreatePenFromBrush(Brush[0]), GDIp.CreatePenFromBrush(Brush[1])]

;	, ScriptObject := {Border: Rect(0, 0, 300, 300)
	, ScriptObject := {Border: {x: 0, y: 0, Width: 300, Height: 300}
		, SpeedRatio: 1.0}

	, Started := False, Running := False

;======================================================== Hook ================;

OnMessage(A_WindowMessage, __WindowMessage)

OnExit(__Exit)

;========================================================  Run  ================;

Run(A_ScriptDir . "\Secondary.ahk")

;======================================================== Test ================;

;=======================================================  Other  ===============;

Start()

exit

;=============== Hotkey =======================================================;
;=======================================================  Mouse  ===============;

;====================================================== Keyboard ==============;

#HotIf (WinActive(A_ScriptName) || WinActive("ahk_group Library"))

	$F10:: {
		ListVars
	}

	~$^s:: {
		Critical(True)

		Sleep(200)
		Reload
	}

#HotIf

#HotIf (A_Debug)

	~*$RShift:: {
		if (!(Running)) {
			Update(1000/Settings.TargetFPS)
			Draw()
		}

		KeyWait("RShift")
	}

	$#:: {
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
			Send("{#}")
		}
	}

#HotIf

~$Left:: {
	ScriptObject.SpeedRatio /= 2

	KeyWait("Left")
}

~$Right:: {
	ScriptObject.SpeedRatio *= 2

	KeyWait("Right")
}

;===============  Label  =======================================================;

;============== Function ======================================================;
;======================================================== Hook ================;

__WindowMessage(wParam := 0, lParam := 0, msg := 0, hWnd := 0) {
	switch (wParam) {
		case 0xCE00:
		case 0x1000:
			if (!(A_Debug := IniRead(A_WorkingDir . "\cfg\Settings.ini", "Debug", "Debug"))) {
				ToolTip("", , , 20)
			}

			return (True)
	}

	return (-1)
}

__Exit(exitReason, exitCode) {
	Critical(True)

;	GDIp.Shutdown()

	ExitApp
}

;=======================================================  Other  ===============;

GetTime() {
	DllCall("QueryPerformanceCounter", "Int64*", &(current := 0))

	return (current)
}

;======================================================== GDIp ================;  ;* All of the following code is based on this amazing tutorial: https://www.isaacsukin.com/news/2015/01/detailed-explanation-javascript-game-loops-and-timing.

Start() {
	global Started
	if (!(Started)) {
		Started := True

		Draw()

		Running := True

		SetTimer(MainLoop.Bind(True), -1)
	}
}

Stop() {
	Running := False, Started := False

	SetTimer(MainLoop, 0)
}

MainLoop(reset := unset) {
	static previous := 0  ;* The timestamp of the last time the main loop was run. Used to compute the time elapsed between frames.

	if (IsSet(reset)) {
		current := GetTime()
			, elapsed := 0
	}
	else {
		current := GetTime()

		static throttle := 1000/Settings.MaxFPS

		if ((elapsed := (current - previous)/10000) < throttle) {  ;* Throttle the frame rate.
			return (SetTimer(MainLoop, -elapsed))
		}
	}

	previous := current

	;---------------  Begin  -------------------------------------------------------;

	Begin()

	;--------------- Update -------------------------------------------------------;

	static delta := 0  ;* The cumulative amount of time that hasn't been simulated yet.

	delta += elapsed  ;* Track the accumulated time that hasn't been simulated yet. This approach avoids inconsistent rounding errors and ensures that there are no giant leaps between frames.

	static slowFactor := 1  ;* Slow motion scaling factor.
		, timeStep := 1000/Settings.TargetFPS, slowStep := timeStep*slowFactor  ;* The amount of time (in milliseconds) to simulate each time `Update()` is called.

	static ticks := 0

	updateCount := 0  ;* The number of times `Update()` is called in a given frame.
		, panic := False

	while (delta >= slowStep) {
		++ticks, Update(timeStep)

		delta -= slowStep

		if (++updateCount == 240) {
			panic := True  ;* Indicates too many updates have taken place because the simulation has fallen too far behind real time.

			break
		}
	}

	;----------------  FPS  --------------------------------------------------------;

	static previousFpsUpdate := A_TickCount

	static averageTicks := Settings.TargetFPS
		, averageFrames := averageTicks/2, alpha := Settings.FPSAlpha

	if ((A_TickCount - previousFpsUpdate) >= 1000) {
		previousFpsUpdate += 1000

		averageTicks := averageTicks*alpha + ticks*(1 - alpha), ticks := 0
			, averageFrames := averageFrames*alpha + frames*(1 - alpha), frames := 0  ;* An exponential moving average of the frames per second.

		if (A_Debug) {
			ToolTip(averageTicks . ", " . averageFrames, 50, 50, 20)
		}
	}

	ToolTip("RUNNING")

	;--------------- Render -------------------------------------------------------;

	static frames := 0

	++frames, Draw(delta/timeStep)  ;* Render the screen. We do this regardless of whether `Update()` has run during this frame because it is possible to interpolate between updates to make the frame rate appear faster than updates are actually happening.

	;----------------  End  --------------------------------------------------------;

	End(panic, averageTicks, averageFrames)  ;* Run any updates that are not dependent on time in the simulation.

	SetTimer(MainLoop, -1)
}

Begin() {  ;* Typically used to process input before the updates run. Processing input here (in chunks) can reduce the running time of event handlers, which is useful because long-running event handlers can sometimes delay frames.

}

Update(delta) {  ;* Simulates everything that is affected by time. It can be called zero or more times per frame depending on the frame rate.

}

Draw(interpolation := 0) {  ;* A function that draws things on the screen.
	Canvas.Clear()

	Canvas.Graphics.DrawRectangle(Pen[0], ScriptObject.Border)

	Canvas.Update()
}

End(panic, averageTicks, averageFrames) {  ;* Handles any updates that are not dependent on time in the simulation since it is always called exactly once at the end of every frame.
	if (panic) {
		Console.Clear()
		Console.Log("Panic!")

		Stop()
	}

	if (!(A_Debug)) {
		if (averageFrames < 25) {
			ToolTip(averageTicks . ", " . averageFrames, 50, 50, 20)
		}
		else if (averageFrames > 30) {
			ToolTip("", , , 20)
		}
	}
}

;===============  Class  =======================================================;

Class Settings {

	static TargetFPS {  ;* Generally, 60 is a good choice because most monitors run at 60 Hz.
		Get {
			return (60)
		}
	}

	static MaxFPS {
		Get {
			return (60)
		}
	}

	static FPSAlpha {  ;* A factor that affects how heavily to weigh more recent seconds' performance when calculating the average frames per second in the range (0.0, 1.0). Higher values result in weighting more recent seconds more heavily.
		Get {
			return (0.85)
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