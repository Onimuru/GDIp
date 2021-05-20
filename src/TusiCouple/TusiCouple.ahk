;============ Auto-execute ====================================================;
;=======================================================  Admin  ===============;

if (!A_IsAdmin || !(DllCall("GetCommandLine", "Str") ~= " /restart(?!\S)")) {
	try {
		Run, % Format("*RunAs {}", (A_IsCompiled) ? (A_ScriptFullPath . " /restart") : (A_AhkPath . " /restart " . A_ScriptFullPath))
	}

	ExitApp
}

;======================================================  Setting  ==============;

#KeyHistory, 0
#NoEnv
;#NoTrayIcon
;#Persistent
#SingleInstance, Force
#Warn, ClassOverwrite, MsgBox

;CoordMode, Mouse, Screen
;CoordMode, ToolTip, Screen
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

Menu, Tray, Icon, % A_WorkingDir . "\res\Image\Icon\10.ico"

;=======================================================  Group  ===============;

for i, v in [A_ScriptName, "Core.ahk", "User32.ahk", "GDI.ahk", "GDIp.ahk", "Canvas.ahk", "Bitmap.ahk", "Graphics.ahk", "Brush.ahk", "Pen.ahk", "Path.ahk"
		, "Assert.ahk", "Console.ahk", "String.ahk", "General.ahk", "Color.ahk", "Math.ahk", "Geometry.ahk"] {
	GroupAdd, % "Editing", % v
}

;====================================================== Variable ==============;

Global Debug := Settings.Debug
	, WindowMessage := DllCall("RegisterWindowMessage", "Str", "WindowMessage", "UInt")

;======================================================== GDIp ================;

GDIp.Startup()

Global Canvas := GDIp.CreateCanvas(A_ScreenWidth - (150*2 + 50 + 10), 50, 150*2, 150*2, "+AlwaysOnTop -Caption +ToolWindow +E0x20", "NA", "Canvas", 4, 7)
	, Brush := [GDIp.CreateSolidBrush(Color.Random(0xFF)), GDIp.CreateLinearBrushFromRect(0, 0, Canvas.Width, Canvas.Height, 0xFF << 24 | Color.Honeydew, 0xFF << 24 | Color.Sienna, 2, 0)]
	, Pen := [GDIp.CreatePenFromBrush(Brush[0]), GDIp.CreatePenFromBrush(Brush[1])]

	, SolarSystem := {"h": Canvas.Width/2
		, "k": Canvas.Height/2

		, "Ratio": 1
		, "Depth": 0

		, "Planets": []

		, "Date": 0
		, "Border": new Rect(0, 0, Canvas.Width, Canvas.Height)
		, "SpeedRatio": 1}

	, Started := False
	, Running := False

SolarSystem.Planets.Push(new PlanetTemplate("Sun", Min(Canvas.Width, Canvas.Height)/10, 0, 0, 0, SolarSystem))  ;? (Name, Diameter, OrbitAngle, OrbitRadius, OrbitRevolution (in days), Parent)
loop, % Math.Random.Normal(1, 5) {
	SolarSystem.Planets.Push(new PlanetTemplate(A_Index, Math.Random.Normal(10, SolarSystem.Planets[0].Diameter[0]*1.35), Math.Random.Uniform(0, 360), Math.Random.Uniform(SolarSystem.Planets[0].Diameter[0], Min(Canvas.Width/2, Canvas.Height/2)), Math.Random.Uniform(250, 2500), SolarSystem.Planets[0]))

	loop, % Math.Random.Normal(-5, 3) {
		SolarSystem.Planets.Push(new PlanetTemplate(Round(SolarSystem.Planets[SolarSystem.Planets.Length - A_Index].Name + A_Index/10, 1), Math.Random.Normal(5, SolarSystem.Planets[SolarSystem.Planets.Length - A_Index].Diameter[0]*.5), Math.Random.Uniform(0, 360), Math.Random.Uniform(SolarSystem.Planets[SolarSystem.Planets.Length - A_Index].Diameter[0]*1.25, SolarSystem.Planets[SolarSystem.Planets.Length - A_Index].Diameter[0]*1.75), Math.Random.Uniform(35, 800), SolarSystem.Planets[SolarSystem.Planets.Length - A_Index]))
	}
}

;======================================================== Hook ================;

OnMessage(WindowMessage, "WindowMessage")

OnExit("Exit")

;=======================================================  Other  ===============;

Start()

exit

;=============== Hotkey =======================================================;

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

~$Space::
	If (KeyWait("Space", "T0.5")) {
		if (SolarSystem.IsVisible := !SolarSystem.IsVisible) {
			Canvas.Hide()
		}
		else {
			Canvas.Show()
		}
	}

	KeyWait, Space
	return

~$Left::
	SolarSystem.SpeedRatio /= 2

	KeyWait("Left")
	return

~$Right::
	SolarSystem.SpeedRatio *= 2

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

			return (False)
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

;		Draw()

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
		, timeStep := 1000/Settings.TargetFPS, slowStep := timeStep*slow  ;* The amount of time (in milliseconds) to simulate each time `Update()` is called.

		, maxFPS := 1000/Settings.TargetFPS  ;* Used to throttle the frame rate.
		, previous  ;* The timestamp of the last time the main loop was run. Used to compute the time elapsed between frames.
		, delta := 0  ;* The cumulative amount of time that hasn't been simulated yet.

	if (reset) {
		previous := GetTime()
	}

	if ((elapsed := ((current := GetTime()) - previous)/10000) < maxFPS) {
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
		, averageTicks := Settings.TargetFPS, averageFrames := averageTicks/2

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

;Update:
;	If (QueryPerformanceCounter_Passive()) {
;		p := [0]
;
;		SolarSystem.Date += 1*SolarSystem.SpeedRatio
;		Canvas.DrawString(Brush[0], Round(SolarSystem.Date) . " days", "Bold r4 s10")
;
;		If (SolarSystem.SpeedRatio != 1) {
;			v := Round(SolarSystem.SpeedRatio, 1)
;
;			Canvas.DrawString(Brush[0], v . "x", "x" . Canvas.Width - (15 + 6*StrLen(v)) . "Bold r4 s10")
;		}
;
;
;		If (Debug) {
;			ToolTip, % (GetKeyState("q", "P") ? p[""] : "")
;		}
;	}
;
;	SetTimer, Update, -1
;
;	Return

Update(delta) {
	for i, planet in SolarSystem.Planets {
		planet.Update(delta)
	}
}

Draw(interp := 0) {  ;* A function that draws things on the screen.
	Canvas.Clear()

	Canvas.Graphics.DrawRectangle(Pen[0], SolarSystem.Border)

	loop, % (planets := SolarSystem.Planets.Clone()).Length {
		for i, planet in (planets, min := A_ScreenWidth*2.25 + 1) {  ;* Find the planet with the lowest depth ("furthest" away).
			if (min > planet.Depth) {
				min := planet.Depth
					, index := i
			}
		}

		if (Debug) {
			string .= (A_Index > 1 ? "|" : "") . planets[index].Name
		}

		planets.RemoveAt(index).Draw(SolarSystem.Date)  ;* Draw the "furthest" planet and delete it from the temporary array so that "closer" planets will be drawn over it.
	}

	for i, planet in (SolarSystem.Planets, pGraphics := Canvas.Graphics.Ptr, pPen := Pen[0].Ptr) {
		if (status := DllCall("Gdiplus\GdipDrawLine", "Ptr", pGraphics, "Ptr", pPen, "Float", planet.h, "Float", planet.k, "Float", planet.Parent.h, "Float", planet.Parent.k, "Int")) {
			throw (Exception(FormatStatus(status)))
		}
	}

	Canvas.Update()

	if (Debug) {
		ToolTip, % (GetKeyState("Ctrl", "P") ? string : "")
	}
}

End(averageFrames, averageTicks, panic) {
	if (panic) {
		Console.Clear()
		Console.Write("Panic!")

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
			IniRead, v, % A_WorkingDir . "\cfg\Settings.ini", Debug, Debug
			ObjRawSet(this, "Debug", v)

			return (v)
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

Class PlanetTemplate {
	__New(name, diameter, orbitAngle, orbitRadius, orbitRevolution, parent) {
		radians := Math.ToRadians((orbitAngle >= 0) ? Mod(orbitAngle, 360) : 360 - Mod(-orbitAngle, -360))

		this.Name := name
		this.Diameter := [diameter]
		this.Orbit := {"x": orbitRadius*Math.Cos(radians)
			, "y": orbitRadius*Math.Sin(radians)

			, "Angle": orbitAngle
			, "Radius": orbitRadius
			, "Revolution": 1000/Settings.TargetFPS*orbitRevolution}
		this.Parent := parent

		this.Brush := (name == "Sun")
			? (GDIp.CreateSolidBrush(Color.Random(0xFF)))
			: (GDIp.CreateLinearBrushFromRectWithAngle(orbitRadius/4, orbitRadius/4, orbitRadius/2, orbitRadius/2, Color.Random(0xFF), Color.Random(0xFF), orbitAngle, 3))
	}

	Update(date) {
		radians := Math.ToRadians((date/this.Orbit.Revolution)*360)

		this.Ratio := (this.Diameter[1] := (this.Diameter[0] + this.Diameter[0]*Math.Sin(radians)/2)*this.Parent.Ratio)/this.Diameter[0]
		this.Depth := this.Parent.Depth + (this.Ratio - 1)*this.Orbit.Radius*2

		this.h := this.Parent.h + this.Orbit.x*Math.Cos(radians)*this.Parent.Ratio, this.k := this.Parent.k + this.Orbit.y*Math.Sin(radians + 1.5707963267948966192313216916398)*this.Parent.Ratio
	}

	Draw(date) {
		Local status

		if (status := DllCall("Gdiplus\GdipFillEllipse", "Ptr", Canvas.Graphics.Ptr, "Ptr", this.Brush.Ptr, "Float", this.h - this.Diameter[1]/2, "Float", this.k - this.Diameter[1]/2, "Float", this.Diameter[1], "Float", this.Diameter[1], "Int")) {
			throw (Exception(FormatStatus(status)))
		}

;		Canvas.DrawString(Brush[0], this.Name . ((this.Parent.Name == "Sun") ? (" (" . Round(Mod((date/this.Orbit.Revolution)*360, 360)) . "°)") : ("")), "x" . this.h + this.Diameter[1]/2 . "y" . this.k - this.Diameter[1]/2 . "r4 s10")
	}
}














































Global oCanvas := new GDIp.Canvas([A_ScreenWidth - 150*2.5 + 5, 150*.5 + 5, 150*2 + 10, 150*2 + 10], "-Caption +AlwaysOnTop +ToolWindow +OwnDialogs +E0x20")
	, oPen := [new GDIp.Pen(), new GDIp.Pen("0x40FFFFFF")]

	, oEllipse := new Ellipse([5, 5, oCanvas.Size.Width - 20, oCanvas.Size.Height - 20])

(oCanvas.Points := []).Length := 8

Loop, % oCanvas.Points.Length {
	i := A_Index - 1
		, v := Color.ToHSB(Mod(360/oCanvas.Points.Length*i, 360)/360, 1, 1)

	oCanvas.Points[i] := (new Point(i, 5, Math.ToRadians(180/oCanvas.Points.Length*i), new GDIp.Brush(Format("0xFF{:02X}{:02X}{:02X}", Round(v[0]*255), Round(v[1]*255), Round(v[2]*255)))))
}

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
	Static __Theta := 0

	If (QueryPerformanceCounter_Passive()) {
		__Theta := Mod(__Theta + 3, 360)

		oCanvas.DrawEllipse(oPen[0], oEllipse)

		For i, v in oCanvas.Points {  ;* Draw the lines first so that the ellipses are drawn over them.
			oCanvas.DrawLine(oPen[1], v.Points)
		}

		For i, v in oCanvas.Points {
			v.Draw(__Theta)
		}

		oCanvas.Update()
	}

	SetTimer, Update, -1
}

;=====            Class             =========================;

Class Point {
	__New(vIndex, vRadius, vTheta, oBrush) {
		this.Index := vIndex
		this.Radius := vRadius
			, this.Diameter := vRadius*2
		this.Angle := vTheta

		c := Math.Cos(vTheta), s := Math.Sin(vTheta)

		;* Points of the radius at this angle:
		this.Points := [new Point2D([oEllipse.h + oEllipse.Radius*c, oEllipse.k + oEllipse.Radius*s]), new Point2D([oEllipse.h - oEllipse.Radius*c, oEllipse.k - oEllipse.Radius*s])]

		this.Brush := oBrush
	}

	Draw(vTheta) {
		r := (oEllipse.Radius)*Math.Cos((Math.Tau/360*vTheta) + ((this.Index*Math.Pi)/oCanvas.Points.Length))

		oCanvas.FillEllipse(this.Brush, {"x": oEllipse.h + r*Math.Cos(this.Angle) - this.Radius, "y": oEllipse.k + r*Math.Sin(this.Angle) - this.Radius, "Width": this.Diameter, "Height": this.Diameter})
	}
}