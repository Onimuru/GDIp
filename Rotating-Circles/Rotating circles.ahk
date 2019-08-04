#KeyHistory 0
#NoEnv
#Persistent
#SingleInstance Force

ListLines, Off
Process, Priority, , R
SetBatchLines, -1
SetControlDelay, -1

Global vRadius := 150, vDiameter := vRadius*2
	, vSectors := 20
	, vClockwise := 1  ;1 || -1
	, vCanvas := new LayeredWindow("gCanvas", "-Caption +AlwaysOnTop +ToolWindow +OwnDialogs +E0x20", A_ScreenWidth - vRadius*2.5, vRadius*.5, vDiameter*1.5, vDiameter*1.5)
	, Balls := []

SetTimer, Update, 25

Loop, % vSectors {
	a := (vClockwise*(180/vSectors)*0.01745329251994329576923690768489)*(A_Index - 1)

	Balls.Push(new Ball(vRadius*Cos(a), vRadius*Sin(a), vRadius, vRadius/10, a*57.295779513082320876798154814105))

	Sleep, % 325
}

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

/*
	===== Labels ================================================================================
*/

Update:
	Gdip_DrawEllipse(vCanvas.G, vCanvas.pPen, vRadius*0.95, vRadius*0.95, vRadius/10, vRadius/10)
	Gdip_DrawEllipse(vCanvas.G, vCanvas.pPen, 0, 0, vDiameter, vDiameter)

	For i, v in Balls
		v.UpDate()

	UpdateLayeredWindow(vCanvas.hwnd, vCanvas.hdc), Gdip_GraphicsClear(vCanvas.G)

	Return

~$Esc::
	KeyWait, Esc, T0.5
	If (!ErrorLevel)
		Return
Exit:
	SetTimer, Update, Delete

	For i, v in Balls
		For i, v in v.B
			Gdip_DeleteBrush(v)

	vCanvas.ShutDown()
	ExitApp
	Return

/*
	===== Functions ================================================================================
*/

Class LayeredWindow {
	__New(_name, _options, _x, _y, _w, _h, _smoothing := 4, _interpolation := 7) {
		this.Layered := {"Name": _name
			, "Options": _options
			, "x": _x
			, "y": _y
			, "w": _w
			, "h": _h}

		this.Layered.pToken := Gdip_Startup()
		this.Layered.hbm := CreateDIBSection(_w, _h), this.Layered.hdc := CreateCompatibleDC(), this.Layered.obm := SelectObject(this.Layered.hdc, this.Layered.hbm)
		this.Layered.G := Gdip_GraphicsFromHDC(this.Layered.hdc), Gdip_SetSmoothingMode(this.Layered.G, _smoothing), Gdip_SetInterpolationMode(this.Layered.G, _interpolation)

		this.Layered.pPen := Gdip_CreatePen("0x80FFFFFF", 1)

		Gui, % this.Layered.Name . ": New", % this.Layered.Options . " +LastFound +E0x80000"
		Gui, % this.Layered.Name . ": Show", % " x" . this.Layered.x . " y" . this.Layered.y . " w" . this.Layered.w " h" . this.Layered.h " NA"
		this.Layered.hwnd := WinExist()

		Return (this.Layered)
	}

	ShutDown() {
		Gdip_DeletePen(this.Layered.pPen)

		SelectObject(this.Layered.hdc, this.Layered.obm), DeleteObject(this.Layered.hbm), DeleteDC(this.Layered.hdc), Gdip_DeleteGraphics(this.Layered.G)
		Gdip_Shutdown(this.Layered.pToken)
	}
}

Class Ball {
	__New(_x, _y, _o, _s, _a) {
		C := Format("{:02X}{:02X}{:02X}", Round((C := HSV_Convert2RGB(Abs(_a/360)))[1]*255), Round(C[2]*255), Round(C[3]*255))

		this.Cx := this.Ox := _x + _o, this.Cy := this.Oy := _y + _o, this.Dx := (-_x*2)/vDiameter, this.Dy := (-_y*2)/vDiameter
			, this.S := _s, this.P := [], this.B := [Gdip_BrushCreateSolid("0xFF" . C), Gdip_BrushCreateSolid("0xCC" . C), Gdip_BrushCreateSolid("0x99" . C), Gdip_BrushCreateSolid("0x66" . C), Gdip_BrushCreateSolid("0x33" . C)]
			, this.M := -3.5
			, this.E := (Abs(this.A := _a) < 180)
	}

	Update() {
		D := Sqrt((this.Cx - this.Ox)**2 + (this.Cy - this.Oy)**2)
		If (D >= vRadius*0.95 - 1) {
			this.M *= -1

			If (this.E)
				Balls.Push(new Ball(-(this.Ox - vRadius), -(this.Oy - vRadius), vRadius, vRadius/10, this.A + 180*vClockwise)), this.E := 0
		}

		Else If (D <= 1)
			this.M *= -1

		this.P.RemoveAt(5)
		this.P.InsertAt(1, [this.Cx += this.Dx*this.M, this.Cy += this.Dy*this.M])

		For i, v in this.P {
			s := this.S - this.S*i/10

			Gdip_FillEllipse(vCanvas.G, this.B[i], v[1] - s/2, v[2] - s/2, s, s)
		}
	}
}

HSV_Convert2RGB(h := 0, s := 1, v := 1) {  ;Credit: jeeswg (https://www.autohotkey.com/boards/viewtopic.php?t=44375)
	If (s = 0)
		Return [r, g, b]

	h := (h = 1 ? 0.0 : h) * 6.0, i := Floor(h)

	f := h - i, p := v*(1.0 - s), q := v*(1.0 - s*f), t := v*(1.0 - s*(1.0 - f))

	If (i = 0)
		r := v, g := t, b := p

	Else If (i = 1)
		r := q, g := v, b := p

	Else If (i = 2)
		r := p, g := v, b := t

	Else If (i = 3)
		r := p, g := q, b := v

	Else If (i = 4)
		r := t, g := p, b := v

	Else
		r := v, g := p, b := q

	Return [r, g, b]
}