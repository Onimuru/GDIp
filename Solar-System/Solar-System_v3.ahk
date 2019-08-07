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
	, Date := 0
	, SolarSystem := {"x": 5
		, "y": 5
		, "h": vRadius + 5
		, "k": vRadius + 5}
	, Planets := []
	, Index := []

Planets.Push(new Planet("Sun", 0, 0, 0, vRadius/5))
Loop, % Random(1, 6) {
	Planets.Push(new Planet(A_Index, Random(0, 360), Random(Planets[1].diameter, vRadius), Random(50, 2000), Random(5, Planets[1].diameter*1.35)))  ;(_name, _orbitangle, _orbitradius, _orbitrevolution (days), _diameter)
	Loop, % Random(0, 3)
		Planets[Planets.Length()].Child(new Planet(A_Index, Random(0, 360), Random(Planets[Planets.Length()].diameter*1.25, Planets[Planets.Length()].diameter*1.75), Random(35, 800), Random(2, Planets[Planets.Length()].diameter*.5)))
}

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

~$Left::
	vCanvas.SpeedDown()

	KeyWait, Left
	Return

~$Right::
	vCanvas.SpeedUp()

	KeyWait, Right
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

		Index := []

		Gdip_TextToGraphics(vCanvas.G, Round(Date += 1*vCanvas.speedratio) . " days`n`nRevolutions:", "cFFFFFFFF r4 s12 Bold", "Arial")
		If (vCanvas.speedratio != 1)
			Gdip_TextToGraphics(vCanvas.G, Round(vCanvas.speedratio, 1) . "x", "x" . vCanvas.width - 35 . "cFFFFFFFF r4 s12 Bold", "Arial")
		For i, v in Planets
			(i > 1) ? Gdip_TextToGraphics(vCanvas.G, v.name . ": " Round(Date/v.orbitrevolution, 2), "y" . 13*(i + 1) . "cFFFFFFFF r4 s12 Bold", "Arial")

		Loop, % Planets.Length() {
			d := vDiameter  ;Greater than the greatest possible orbitradius.

			For i, v in Planets {
				(!InStr(Index[1], i)) ? (d > v.depth ? (d := v.depth, Index[2] := i))
			}
			Index[1] .= (A_Index > 1 ? "|" : "") . Index[2]

			If (Index[2] = 1) {
				Gdip_FillEllipse(vCanvas.G, Planets[1].pBrush, SolarSystem.h - Planets[1].diameter/2, SolarSystem.k - Planets[1].diameter/2, Planets[1].diameter, Planets[1].diameter)
				Gdip_TextToGraphics(vCanvas.G, "Sun", "x" . SolarSystem.h + Planets[1].diameter/2 . " y" . SolarSystem.k - Planets[1].diameter/2 . "cFFFFFFFF r4 s12 Bold", "Arial")
			}

			Else
				Planets[Index[2]].UpDate(Date)
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

		this.pPen := Gdip_CreatePen("0x80FFFFFF", 1)

		Gui, New, % _options . " +LastFound +E0x80000"
		Gui, Show, % " x" . _x . " y" . _y . " w" . _width " h" . _height . " NA"
		this.hwnd := WinExist()

		Return (this)
	}

	SpeedUp() {
		this.speedratio *= 2
	}

	SpeedDown() {
		this.speedratio /= 2
	}

	ShutDown() {
		Gdip_DeletePen(this.pPen)
		For i, v in Planets {
			Gdip_DeleteBrush(v.pBrush)
			For i, v in v.children
				Gdip_DeleteBrush(v.pBrush)
		}

		SelectObject(this.hdc, this.obm), DeleteObject(this.hbm), DeleteDC(this.hdc), Gdip_DeleteGraphics(this.G)
		Gdip_Shutdown(this.pToken)
	}
}

Class Planet {
	__New(_name, _orbitangle, _orbitradius, _orbitrevolution, _diameter) {
		a := Angle_Radians((_orbitangle >= 0) ? Mod(_orbitangle, 360) : 360 - Mod(-_orbitangle, -360))

		this.name := _name

		this.pBrush := ((_name = "Sun" ? Gdip_BrushCreateSolid({1: "0xFFFFFF00", 2: "0xFF00FFFF", 3: "0xFFFFFFFF"}[Random(1, 3)]) : Gdip_BrushCreateSolid("0xFF" . Random_Color())))

		this.orbitradius := _orbitradius
		this.orbitrevolution := _orbitrevolution
		this.diameter := _diameter

		this.depth := 0

		this.orbit := {"x": _orbitradius*Cos(a)
			, "y": _orbitradius*Sin(a)}

		this.children := []

		Return (this)
	}

	Child(_child) {
		this.children.Push(_child)
	}

	Update(_date) {
		a := Angle_Radians((_date/this.orbitrevolution)*360)
			, p := [], c := "", m := 0

		this.ratio := (this.diameteroffset := this.diameter + this.diameter*Sin(a)/2)/this.diameter, this.depth := (this.ratio - 1)*this.orbitradius*2
		this.x := (this.h := SolarSystem.h + this.orbit.x*Cos(a)) - this.diameteroffset/2, this.y := (this.k := SolarSystem.k + this.orbit.y*Sin(a + 1.5707963267948966192313216916398)) - this.diameteroffset/2

		p.Push(this)

		For i, v in this.children {
			a := Angle_Radians((_date/v.orbitrevolution)*360)

			v.diameteroffset := (v.diameter + v.diameter*Sin(a)/2)*this.ratio, v.depth := this.depth + (v.diameteroffset/v.diameter - 1)*v.orbitradius*2
			v.x := this.h + v.orbit.x*Cos(a)*this.ratio - v.diameteroffset/2, v.y := this.k + v.orbit.y*Sin(a + 1.5707963267948966192313216916398)*this.ratio - v.diameteroffset/2

			p.Push(v)
		}

		Loop, % p.Length() {
			d := vDiameter

			For i, v in p {
				(!InStr(c, i)) ? (d > v.depth ? (d := v.depth, m := i))
			}
			c .= (A_Index > 1 ? "|" : "") . m

			If (m = 1) {
				Gdip_FillEllipse(vCanvas.G, this.pBrush, this.x, this.y, this.diameteroffset, this.diameteroffset)
				Gdip_DrawLine(vCanvas.G, vCanvas.pPen, this.h, this.k, SolarSystem.h, SolarSystem.k), Gdip_TextToGraphics(vCanvas.G, this.name "`n" Round(Mod((_date/this.orbitrevolution)*360, 360)), "x" . this.x + this.diameteroffset . " y" . this.y . "cFFFFFFFF r4 s12 Bold", "Arial")
			}

			Else {
				Gdip_FillEllipse(vCanvas.G, p[m].pBrush, p[m].x, p[m].y, p[m].diameteroffset, p[m].diameteroffset)
				Gdip_DrawLine(vCanvas.G, vCanvas.pPen, p[m].x + p[m].diameteroffset/2, p[m].y + p[m].diameteroffset/2, this.h, this.k)
			}
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