#KeyHistory 0
#NoEnv
#Persistent
#SingleInstance Force

#Include, %A_ScriptDir%\..\..\..\lib\GDIp.ahk

ListLines, Off
Process, Priority, , R
SetBatchLines, -1
SetControlDelay, -1

vCanvas := 150
Global vCanvas := new Canvas("gCanvas", "-Caption +AlwaysOnTop +ToolWindow +OwnDialogs +E0x20", A_ScreenWidth - vCanvas*2.5 + 5, vCanvas*.5 + 5, vCanvas*2 + 10, vCanvas*2 + 10)
	, vSolarSystem := {"h": vCanvas.width/2
		, "k": vCanvas.height/2

		, "ratio": 1
		, "depth": 0

		, "date": 0
		, "planets": []

		, "speedratio": 1}

vSolarSystem.planets.Push(new Planet("Sun", Min(vCanvas.width, vCanvas.height)/10, 0, 0, 0, vSolarSystem))  ;(_name, _diameter, _orbitangle, _orbitradius, _orbitrevolution (days), _parent)
Loop, % Random(1, 6) {
	vSolarSystem.planets.Push(new Planet(A_Index, Random(10, vSolarSystem.planets[1].diameter[1]*1.35), Random(0, 360), Random(vSolarSystem.planets[1].diameter[1], Min(vCanvas.width/2, vCanvas.height/2)), Random(250, 2500), vSolarSystem.planets[1]))
	Loop, % Random(-2, 3)
		vSolarSystem.planets.Push(new Planet(Round(vSolarSystem.planets[vSolarSystem.planets.Length() - (A_Index - 1)].name + A_Index/10, 1), Random(5, vSolarSystem.planets[vSolarSystem.planets.Length() - (A_Index - 1)].diameter[1]*.5), Random(0, 360), Random(vSolarSystem.planets[vSolarSystem.planets.Length() - (A_Index - 1)].diameter[1]*1.25, vSolarSystem.planets[vSolarSystem.planets.Length() - (A_Index - 1)].diameter[1]*1.75), Random(35, 800), vSolarSystem.planets[vSolarSystem.planets.Length() - (A_Index - 1)]))
}

DllCall("QueryPerformanceFrequency", "Int64*", QPF)
DllCall("QueryPerformanceCounter", "Int64*", QPC_before)

SetTimer, Update, -1

OnExit, Exit

Exit

/*
	===== Hotkeys ================================================================================
*/

~$^s::
	Critical
	SetTitleMatchMode, 2

	If (WinActive(A_ScriptName)) {
		Sleep, 200
		Reload
	}
	Return

~$Left::
	vSolarSystem.speedratio /= 2

	KeyWait, Left
	Return

~$Right::
	vSolarSystem.speedratio *= 2

	KeyWait, Right
	Return

~$Space::
	KeyWait, Space, T0.5
	If (ErrorLevel) {
		Gui, gCanvas: Show, NA
		If (vCanvas.visible := !vCanvas.visible)
			Gui, gCanvas: Hide
	}

	KeyWait, Space
	Return

~$Esc::
	KeyWait, Esc, T0.5
	If (ErrorLevel)
		Gosub, Exit

	Return

/*
	===== Labels ================================================================================
*/

Update:
	DllCall("QueryPerformanceCounter", "Int64*", QPC_now)
	QPC_delta := (QPC_now - QPC_before)/QPF*1000

	If (QPC_delta > 50) {  ;1000/20 (~20 FPS)
		QPC_before := QPC_now - Mod(QPC_delta, 50)
			, p := [0]

		Gdip_TextToGraphics(vCanvas.G, Round(vSolarSystem.date += 1*vSolarSystem.speedratio) . " days`n`nRevolutions:", "cFFFFFFFF Bold r4 s12", "Arial")
		For i, v in vSolarSystem.planets {
			v.Update(vSolarSystem.date)

			If (v.parent.name == "Sun")
				Gdip_TextToGraphics(vCanvas.G, v.name . ": " Round(vSolarSystem.date/v.orbit.revolution, 2), "y" . 13*(++p[1] + 2) . " cFFFFFFFF Bold r4 s12", "Arial")
		}

		If (vSolarSystem.speedratio != 1)
			Gdip_TextToGraphics(vCanvas.G, Round(vSolarSystem.speedratio, 1) . "x", "x" . vCanvas.width - 35 . " cFFFFFFFF Bold r4 s12", "Arial")

		Loop, % (p[1] := vSolarSystem.planets.Clone()).Length() {
			p[3] := A_ScreenWidth*2.25 + 1  ;Should be greater than any potential orbit.radius*parent.ratio (min 0.5, max 1.5*1.5 (unless you have have moons with moons. In that case it would be 1.5*1.5*1.5 but it shouldn't matter that much since it'll be a smaller and smaller orbit at each level down.)).

			For i, v in p[1]  ;Finds the planet with the lowest depth ("furthest" away).
				If (p[3] > v.depth)
					p[3] := v.depth, p[2] := i

			If (vCanvas.debug)
				p[0] .= (A_Index > 1 ? "|" : "") . p[1][p[2]].name

			p[1].RemoveAt(p[2]).Draw(vSolarSystem.date)  ;Draw the "furthest" planet and remove it from the temp array so that "closer" planets will be drawn over it.
		}

		For i, v in vSolarSystem.planets
			Gdip_DrawLine(vCanvas.G, vCanvas.pPen[1], v.h, v.k, v.parent.h, v.parent.k)

		UpdateLayeredWindow(vCanvas.hwnd, vCanvas.hdc), Gdip_GraphicsClear(vCanvas.G)

		If (vCanvas.debug)
			ToolTip, % (GetKeyState("q", "P") ? p[0] : "")
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

Angle_Radians(_degrees){
	Return (_degrees*0.01745329251994329576923690768489)
}

Between(_number, _low, _high) {
	Return (_number >= _low && _number <= _high)
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

Class Canvas {
	__New(_name, _options, _x, _y, _width, _height, _smoothing := 4, _interpolation := 7, _hide := 0) {
		this.x := _x, this.y := _y
		this.width := _width, this.height := _height

		this.pToken := Gdip_Startup()
		this.hbm := CreateDIBSection(_width, _height), this.hdc := CreateCompatibleDC(), this.obm := SelectObject(this.hdc, this.hbm)
		this.G := Gdip_GraphicsFromHDC(this.hdc), Gdip_SetSmoothingMode(this.G, _smoothing), Gdip_SetInterpolationMode(this.G, _interpolation)

		this.pBrush := [], 	this.pPen := [Gdip_CreatePen("0x80FFFFFF", 1)]

		Gui, % _name ": New", % _options . " +LastFound +E0x80000"
		Gui, % _name ": Show", % " x" . _x . " y" . _y . " w" . _width . " h" . _height . (_hide ? " Hide" : " NA")
		this.hwnd := WinExist()

		this.debug := 1

		Return (this)
	}

	NewBrush(_alpha := "FF", _colour := "000000") {
		this.pBrush.Push(Gdip_BrushCreateSolid("0x" . _alpha . _colour))

		Return (this.pBrush[this.pBrush.Length()])
	}

	NewLineBrush(_x, _y, _width, _height, _alpha1 := "FF", _colour1 := "000000", _alpha2 := "FF", _colour2 := "000000", _lineargradientmode := 1, _wrapmode := 1) {
		this.pBrush.Push(Gdip_CreateLineBrushFromRect(_x, _y, _width, _height, "0x" . _alpha1 . _colour1, "0x" . _alpha2 . _colour2, _lineargradientmode, _wrapmode))

		Return (this.pBrush[this.pBrush.Length()])
	}

	NewPen(_alpha := "FF", _colour := "000000", _width := 1) {
		this.pPen.Push(Gdip_CreatePen("0x" . _alpha . _colour, _width))

		Return (this.pPen[this.pPen.Length()])
	}

	ShutDown() {
		For i, v in this.pPen
			Gdip_DeletePen(v)
		For i, v in this.pBrush
			Gdip_DeleteBrush(v)

		SelectObject(this.hdc, this.obm), DeleteObject(this.hbm), DeleteDC(this.hdc), Gdip_DeleteGraphics(this.G)
		Gdip_Shutdown(this.pToken)
	}
}

Class Planet {
	__New(_name, _diameter, _orbitangle, _orbitradius, _orbitrevolution, _parent) {
		a := Angle_Radians((_orbitangle >= 0) ? Mod(_orbitangle, 360) : 360 - Mod(-_orbitangle, -360))

		this.name := _name

		this.diameter := [_diameter]

		this.orbit := {"x": _orbitradius*Cos(a)
			, "y": _orbitradius*Sin(a)
			, "radius": _orbitradius
			, "revolution": _orbitrevolution}

		this.parent := _parent

		this.pBrush := (_name == "Sun" ? vCanvas.NewBrush("FF", {1: "FFFF00", 2: "00FFFF", 3: "FFFFFF"}[Random(1, 3)]) : vCanvas.NewLineBrush(_diameter/2, _diameter/2, _diameter, _diameter, "FF", Random_Color(), "FF", Random_Color(), ((Between(_orbitangle, 67.5, 112.5) || Between(_orbitangle, 247.5, 292.5)) ? 1 : (Between(_orbitangle, 202.5, 247.5) || Between(_orbitangle, 22.5, 67.5)) ? 2 : (Between(_orbitangle, 112.5, 157.5) || Between(_orbitangle, 292.5, 337.5)) ? 3 : 0)))  ;Horizontal: (67.5 -> 112.5 || 247.5 -> 292.5), ForwardDiagonal: (202.5 -> 247.5 || 22.5 -> 67.5), Backward Diagonal: (112.5 -> 157.5 || 292.5 -> 337.5), Vertical: (157.5 -> 202.5 || 337.5 -> 22.5).

		Return (this)
	}

	Update(_date) {
		a := Angle_Radians((_date/this.orbit.revolution)*360)

		this.ratio := (this.diameter[2] := (this.diameter[1] + this.diameter[1]*Sin(a)/2)*this.parent.ratio)/this.diameter[1]
		this.depth := this.parent.depth + (this.ratio - 1)*this.orbit.radius*2

		this.h := this.parent.h + this.orbit.x*Cos(a)*this.parent.ratio, this.k := this.parent.k + this.orbit.y*Sin(a + 1.5707963267948966192313216916398)*this.parent.ratio
	}

	Draw(_date) {
		Gdip_FillEllipse(vCanvas.G, this.pBrush, this.h - this.diameter[2]/2, this.k - this.diameter[2]/2, this.diameter[2], this.diameter[2])
		If (this.parent.name != "Sun")
			Gdip_TextToGraphics(vCanvas.G, this.name, "x" . this.h + this.diameter[2]/2 . " y" . this.k - this.diameter[2]/2 . " cFFFFFFFF Bold r4 s10", "Arial")
		Else
			Gdip_TextToGraphics(vCanvas.G, this.name . "`n" . Round(Mod((_date/this.orbit.revolution)*360, 360)), "x" . this.h + this.diameter[2]/2 . " y" . this.k - this.diameter[2]/2 . " cFFFFFFFF Bold r4 s12", "Arial")
	}
}
