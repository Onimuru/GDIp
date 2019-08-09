#KeyHistory 0
#NoEnv
#Persistent
#SingleInstance Force

#Include, %A_ScriptDir%\..\..\..\lib\GDIp.ahk

ListLines, Off
Process, Priority, , R
SetBatchLines, -1
SetControlDelay, -1

Global vRadius := 150, vDiameter := vRadius*2
	, vCanvas := new Canvas("-Caption +AlwaysOnTop +ToolWindow +OwnDialogs +E0x20", A_ScreenWidth - vRadius*2.5 + 5, vRadius*.5 + 5, vDiameter + 10, vDiameter + 10)
	, Date := 0  ;, Date := [Date := Floor(JulianDate(A_YYYY . SubStr("0" . A_MM, -1) . SubStr("0" . A_DD, -1))), Date]
	, SolarSystem := {"x": 5
		, "y": 5
		, "h": vCanvas.width/2
		, "k": vCanvas.height/2}
	, Planets := []
	, Depth := []

Planets.Push(new Planet("Sun", 0, 0, 0, vRadius/5))
Loop, % Random(1, 7) {
	Planets.Push(new Planet(A_Index, Random(0, 360), Random(Planets[1].diameter, vRadius), Random(50, 2000), Random(5, Planets[1].diameter*1.35)))  ;(_name, _orbitangle, _orbitradius, _orbitrevolution (days), _diameter)
	Loop, % Random(0, 2)
		Planets[Planets.Length()].Child(new Planet(A_Index, Random(0, 360), Random(Planets[Planets.Length()].diameter, Planets[Planets.Length()].diameter*2), Random(35, 800), Random(1, Planets[Planets.Length()].diameter*.5)))
	Planets[Planets.Length()].Update(0, Planets.Length())
}

Commet := (Planets.Length() = 2)

DllCall("QueryPerformanceFrequency", "Int64*", QPF)
DllCall("QueryPerformanceCounter", "Int64*", QPC_then)

SetTimer, Update, -1

OnExit, Exit

Exit

;/*
;	===== Hotkeys ================================================================================
;*/

~$^s::
	Critical
	SetTitleMatchMode, 2

	If (WinActive(A_ScriptName)) {
		Sleep, 200
		Reload
	}
	Return

~$Esc::
	KeyWait, Esc, T0.5
	If (ErrorLevel)
		Gosub, Exit

	Return

;/*
;	===== Labels ================================================================================
;*/

Update:
	DllCall("QueryPerformanceCounter", "Int64*", QPC_now)
	QPC_delta := (QPC_now - QPC_then)/QPF*1000

	If (QPC_delta > 50) {  ;1000/20 (~20 FPS)
		QPC_then := QPC_now - Mod(QPC_delta, 50)
			, ++Date

		Gdip_TextToGraphics(vCanvas.G, Date . " days `n`nRevolutions:", "cFFFFFFFF r4 s12 Bold", "Arial")
		For i, v in Planets
			(i > 1) ? Gdip_TextToGraphics(vCanvas.G, v.name . ": " Round(Date/v.orbitrevolution, 2), "y" . 13*(i + 1) . "cFFFFFFFF r4 s12 Bold", "Arial")

		c := ""
		Loop, % Planets.Length() {
			d := vRadius + 1

			For i, v in Planets {
				(InStr(c, i) ? Continue : (d > v.depth ? (d := v.depth, index := i)))
			}
			c .= (A_Index > 1 ? "|" : "") . index

			Planets[index].UpDate(Date, index)
		}

		If (Debug) {
			c := StrSplit(c, "|")
			For i, v in c
				c .= (i > 1 ? "|" : "") . (v = 1 ? "Sun" : v - 1)

			ToolTip, % c
		}

		If (!Commet && Date > 5000) {
			If (Random(0, 50000) = 50000) {
				Commet := Random(2, Planets.Length())

;				Planets[Commet].end := "nigh"
				MsgBox, % "Commet"

				vCanvas.pBrush.RemoveAt(Commet)
				Planets.RemoveAt(Commet)
				For i, v in Planets
					If (i >= Commet)
						v.name -= 1
			}

		}

		UpdateLayeredWindow(vCanvas.hwnd, vCanvas.hdc), Gdip_GraphicsClear(vCanvas.G)
	}

	SetTimer, Update, -1

	Return

Exit:
	SetTimer, Update, Delete

	vCanvas.ShutDown()

	ExitApp
	Return

/*
	===== Functions ================================================================================
*/
Class Canvas {
	__New(_options, _x, _y, _width, _height, _smoothing := 4, _interpolation := 7) {
		this.x := _x, this.y := _y
		this.width := _width, this.height := _height

		this.zoom := 1
		this.speedratio := 1

		this.pToken := Gdip_Startup()
		this.hbm := CreateDIBSection(_width, _height), this.hdc := CreateCompatibleDC(), this.obm := SelectObject(this.hdc, this.hbm)
		this.G := Gdip_GraphicsFromHDC(this.hdc), Gdip_SetSmoothingMode(this.G, _smoothing), Gdip_SetInterpolationMode(this.G, _interpolation)

		this.pPen := Gdip_CreatePen("0x80FFFFFF", 1), this.pBrush := []

		Gui, New, % _options . " +LastFound +E0x80000"
		Gui, Show, % " x" . _x . " y" . _y . " w" . _width " h" . _height . " NA"
		this.hwnd := WinExist()

		Return (this)
	}

	ZoomIn() {
		this.zoom /= 2
	}

	ZoomOut() {
		this.zoom *= 2
	}

	SpeedUp() {
		this.speedratio *= 2
	}

	SpeedDown() {
		this.speedratio /= 2
	}

	ShutDown() {
		Gdip_DeletePen(this.pPen)
		For i, v in this.pBrush {
			Gdip_DeleteBrush(v)
		}

		SelectObject(this.hdc, this.obm), DeleteObject(this.hbm), DeleteDC(this.hdc), Gdip_DeleteGraphics(this.G)
		Gdip_Shutdown(this.pToken)
	}
}

Class Planet {
	__New(_name, _orbitangle, _orbitradius, _orbitrevolution, _diameter) {
		a := Angle_Radians((_orbitangle >= 0) ? Mod(_orbitangle, 360) : 360 - Mod(-_orbitangle, -360))

		this.name := _name

		this.orbitradius := _orbitradius
		this.orbitrevolution := _orbitrevolution
		this.diameter := _diameter

		this.orbit := {"x": _orbitradius*Cos(a)
			, "y": _orbitradius*Sin(a)}

		this.children := []

		vCanvas.pBrush.Push(_name = "Sun" ? Gdip_BrushCreateSolid({1: "0xFFFFFF00", 2: "0xFF00FFFF", 3: "0xFFFFFFFF"}[Random(1, 3)]) : Gdip_BrushCreateSolid("0xFF" . Random_Color()))

		Return (this)
	}

	Child(_child) {
		this.children.Push(_child)
	}

	Update(_date, _index) {
		a := Angle_Radians((_date/this.orbitrevolution)*360)
			, r := (d := this.diameter + this.diameter*Sin(a)/2)/this.diameter

		this.depth := (r > 1 ? 1 : -1)*this.orbitradius

		Gdip_FillEllipse(vCanvas.G, vCanvas.pBrush[_index], (this.x := (this.h := SolarSystem.h + this.orbit.x*Cos(a)) - d/2), (this.y := (this.k := SolarSystem.k + this.orbit.y*Sin(a + 1.5707963267948966192313216916398)) - d/2), d, d)
		Gdip_DrawLine(vCanvas.G, vCanvas.pPen, this.h, this.k, SolarSystem.h, SolarSystem.k), Gdip_TextToGraphics(vCanvas.G, this.name, "x" . this.x + d . " y" . this.y . "cFFFFFFFF r4 s12 Bold", "Arial")

		For i, v in this.children {
			a := Angle_Radians((_date/v.orbitrevolution)*360)
				, d := (v.diameter + v.diameter*Sin(a)/2)*r

			v.depth := d/v.diameter - 1

			Gdip_FillEllipse(vCanvas.G, vCanvas.pBrush[i + 1], (v.x := this.h + v.orbit.x*Cos(a) - d/2), (v.y := this.k + v.orbit.y*Sin(a + 1.5707963267948966192313216916398) - d/2), d, d)
			Gdip_DrawLine(vCanvas.G, vCanvas.pPen, v.x + d/2, v.y + d/2, this.h, this.k)
		}

	}
}

Random(_min := 0, _max := 100) {
	Random, r, _min, _max

	Return (r)
}

Random_Color() {
	Loop, 6
		c .= StrSplit("0123456789ABCDEF")[Random(1, 16)]

    return (c)
}

Angle_Radians(_degrees){
	Return (_degrees*0.01745329251994329576923690768489)
}

Geometry_Circle_PerimeterPoint(_circle, _angle := 0) {
	a := Angle_Radians((_angle >= 0) ? Mod(_angle, 360) : 360 - Mod(-_angle, -360))

	Return ({"x": _circle.h + _circle.radius*Cos(a)
		, "y": _circle.k + _circle.radius*Sin(a)})
}

Geometry_Ellipse_PerimeterPoint(_ellipse, _angle := 0) {
	a := (_angle >= 0) ? Mod(_angle, 360) : 360 - Mod(-_angle, -360)
		, t := Tan(Angle_Radians(a)), o := Sqrt(_ellipse.radius.b**2 + _ellipse.radius.a**2*t**2)

	If (90 < a && a <= 270)
		x := _ellipse.h - _ellipse.radius.a*_ellipse.radius.b/o, y := _ellipse.k - _ellipse.radius.a*_ellipse.radius.b*t/o

	Else
		x := _ellipse.h + _ellipse.radius.a*_ellipse.radius.b/o, y := _ellipse.k + _ellipse.radius.a*_ellipse.radius.b*t/o

	Return ({"x": x
		, "y": y})
}