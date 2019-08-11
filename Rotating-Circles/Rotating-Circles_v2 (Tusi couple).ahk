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

Loop, % (vCanvas.points[0] := 8)
	vCanvas.points.Push(new Point(5, A_Index - 1, (180/vCanvas.points[0]*(A_Index - 1))*0.01745329251994329576923690768489)), vCanvas.NewBrush("FF", Format("{:02X}{:02X}{:02X}", Round((c := HSV(Mod(360/vCanvas.points[0]*(A_Index - 1), 360)/360))[1]*255), Round(c[2]*255), Round(c[3]*255)))

SetTimer, Update, -1

OnExit, Exit

Return

;===== Hotkeys

~$^s::
	Critical
	SetTitleMatchMode, 2

	If (WinActive(A_ScriptName)) {
		Sleep, 200
		Reload
	}
	Return

~$Left::
	vCanvas.speedratio /= 2

	KeyWait, Left
	Return

~$Right::
	vCanvas.speedratio *= 2

	KeyWait, Right
	Return

~$Esc::
	KeyWait, Esc, T0.5
	If (ErrorLevel)
		Gosub, Exit

	Return

;===== Labels

Exit:
	SetTimer, Update, Delete

	vCanvas.ShutDown()

	ExitApp
	Return

Update:
	If (QPC(50)) {
		vCanvas.degrees := Mod(vCanvas.degrees + 3*vCanvas.speedratio, 360)

		If (vCanvas.speedratio != 1)
			Gdip_TextToGraphics(vCanvas.G, RegExReplace(vCanvas.speedratio, "\.?0*$") . "x", "x" . vCanvas.width - 35 . " cFFFFFFFF Bold r4 s10", "Arial")
		Gdip_DrawEllipse(vCanvas.G, vCanvas.pPen[1], vCanvas.circles[1].x, vCanvas.circles[1].y, vCanvas.circles[1].diameter, vCanvas.circles[1].diameter)

		For i, v in vCanvas.points
			If (i)
				Gdip_DrawLine(vCanvas.G, vCanvas.pPen[2], v.line.x1, v.line.y1, v.line.x2, v.line.y2)

		For i, v in vCanvas.points
			If (i)
				v.Draw(vCanvas.degrees)

		UpdateLayeredWindow(vCanvas.hwnd, vCanvas.hdc), Gdip_GraphicsClear(vCanvas.G)
	}

	SetTimer, Update, -1

	Return

;===== Functions

HSV(_hue := 0, _saturation := 1, _value := 1) {
	f := (h := (_hue = 1 ? 0.0 : _hue)*6.0) - (i := Floor(h)), p := (v := _value)*(1.0 - (s := _saturation)), q := v*(1.0 - s*f), t := v*(1.0 - s*(1.0 - f))

	Return (s = 0 ? 0 : i = 0 ? [v, t, p] : i = 1 ? [q, v, p] : i = 2 ? [p, v, t] : i = 3 ? [p, q, v] : i = 4 ? [t, p, v] : [v, p, q])
}

QPC(_time := 50) {
	Static f := 0, d := !DllCall("QueryPerformanceFrequency", "Int64P", f), n := 0, b := 0

	Return (!DllCall("QueryPerformanceCounter", "Int64P", n) + (b ? ((d := (n - b)/f*1000) > _time ? !(b := n - Mod(d, _time)) + 1 : 0) : !(b := n) - 1))  ;First call returns -1 but still passes a true/false check.
}

;===== Classes

Class Canvas {
	__New(_name, _options, _x, _y, _width, _height, _smoothing := 4, _interpolation := 7, _hide := 0) {
		this.x := _x, this.y := _y, this.width := _width, this.height := _height

		this.pToken := Gdip_Startup()
		this.hbm := CreateDIBSection(_width, _height), this.hdc := CreateCompatibleDC(), this.obm := SelectObject(this.hdc, this.hbm)
		this.G := Gdip_GraphicsFromHDC(this.hdc), Gdip_SetSmoothingMode(this.G, _smoothing), Gdip_SetInterpolationMode(this.G, _interpolation)

		this.pBrush := [], 	this.pPen := [Gdip_CreatePen("0xCCFFFFFF", 1), Gdip_CreatePen("0x80FFFFFF", 1)]

		Gui, % _name ": New", % _options . " +LastFound +E0x80000"
		Gui, % _name ": Show", % " x" . _x . " y" . _y . " w" . _width . " h" . _height . (_hide ? " Hide" : " NA")
		this.hwnd := WinExist()

		this.circles := [{"x": 5
				, "y": 5
				, "h": _width/2 - 5
				, "k": _height/2 - 5

				, "radius": _width/2 - 10
				, "diameter": _width - 20}]
		this.points := []

		this.degrees := 0
		this.speedratio := 1

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

Class Point {
	__New(_radius, _index, _radians) {
		this.radius := _radius, this.diameter := _radius*2

		this.index := _index

		this.line := {"x1": vCanvas.circles[1].h + vCanvas.circles[1].radius*Cos(_radians), "y1": vCanvas.circles[1].k + vCanvas.circles[1].radius*Sin(_radians), "x2": vCanvas.circles[1].h - vCanvas.circles[1].radius*Cos(_radians), "y2": vCanvas.circles[1].k - vCanvas.circles[1].radius*Sin(_radians)}

		Return (this)
	}

	Draw(_frame) {
		a := (180/vCanvas.points[0]*this.index)*0.01745329251994329576923690768489, r := (vCanvas.circles[1].radius)*Cos((6.283185307179586476925286766559/360*_frame) + ((this.index*3.1415926535897932384626433832795)/vCanvas.points[0]))

		Gdip_FillEllipse(vCanvas.G, vCanvas.pBrush[A_Index - 1], vCanvas.circles[1].h + r*Cos(a) - this.radius, vCanvas.circles[1].k + r*Sin(a) - this.radius, this.diameter, this.diameter)
	}
}