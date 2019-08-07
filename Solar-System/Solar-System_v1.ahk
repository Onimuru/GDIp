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
	, Circle := {"x": vRadius*.75 + 5
		, "y": vRadius*.75 + 5
		, "h": vRadius + 5
		, "k": vRadius + 5
		, "diameter": vRadius/2
		, "radius": vRadius/4}
	, Balls := []
	, Count := [0, -1, 0]
	, vDegrees := 0

Balls[1] := new Ball(Circle.h, Circle.k, Circle.diameter*1.25, 45, 1, 20)
Balls[2] := new Ball(Circle.h, Circle.k, Circle.diameter*1.5, 100, 1, 25)
Balls[3] := new Ball(Circle.h, Circle.k, Circle.diameter*1.75, 190, 1, 25)

SetTimer, Update, 100

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

~$Esc::
	KeyWait, Esc, T0.5
	If (ErrorLevel)
		Gosub, Exit

	Return

/*
	===== Labels ================================================================================
*/

Update:
	vDegrees += vDegrees = 360 ? -359 : 1
	If (Count[1] = 0 || Count[1] = 500)
		Count[2] *= -1

	Count[1] += Count[2]

	Gdip_DrawEllipse(vCanvas.G, vCanvas.pPen, Circle.x, Circle.y, Circle.diameter, Circle.diameter)
	Gdip_DrawLine(vCanvas.G, vCanvas.pPen, Circle.h, Circle.k - Circle.diameter*2, Circle.h, Circle.k + Circle.diameter*2)
	Gdip_DrawLine(vCanvas.G, vCanvas.pPen, Circle.h - Circle.diameter*2, Circle.k, Circle.h + Circle.diameter*2, Circle.k)

	;Gdip_TranslateWorldTransform(vCanvas.G, Ellipse[1].Center.x, Ellipse[1].Center.y), Gdip_RotateWorldTransform(vCanvas.G, vDegrees), Gdip_TranslateWorldTransform(vCanvas.G, -Ellipse[1].Center.x, -Ellipse[1].Center.y)

	For i, v in Balls
		v.UpDate()

	UpdateLayeredWindow(vCanvas.hwnd, vCanvas.hdc), Gdip_GraphicsClear(vCanvas.G)	;, Gdip_ResetWorldTransform(vCanvas.G)

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
	__New(_options, _x, _y, _w, _h, _smoothing := 4, _interpolation := 7) {
		this.Layered := {"x": _x
			, "y": _y
			, "w": _w
			, "h": _h}

		this.Layered.pToken := Gdip_Startup()
		this.Layered.hbm := CreateDIBSection(_w, _h), this.Layered.hdc := CreateCompatibleDC(), this.Layered.obm := SelectObject(this.Layered.hdc, this.Layered.hbm)
		this.Layered.G := Gdip_GraphicsFromHDC(this.Layered.hdc), Gdip_SetSmoothingMode(this.Layered.G, _smoothing), Gdip_SetInterpolationMode(this.Layered.G, _interpolation), Gdip_SetCompositingMode(this.Layered.G, 0)

		this.Layered.pPen := Gdip_CreatePen("0x80FFFFFF", 1)
		this.Layered.pBrush := [Gdip_BrushCreateSolid("0xFFFFFFFF")
			, Gdip_BrushCreateSolid("0xFF00FFFF")]

		Gui, New, % _options . " +LastFound +E0x80000"
		Gui, Show, % " x" . _x . " y" . _y . " w" . _w " h" . _h . " NA"
		this.Layered.hwnd := WinExist()

		Return (this.Layered)
	}

	ShutDown() {
		Gdip_DeletePen(this.Layered.pPen)
		For i, v in this.Layered.pBrush
			Gdip_DeleteBrush(v)

		SelectObject(this.Layered.hdc, this.Layered.obm), DeleteObject(this.Layered.hbm), DeleteDC(this.Layered.hdc), Gdip_DeleteGraphics(this.Layered.G)
		Gdip_Shutdown(this.Layered.pToken)
	}
}

Class Ball {
	__New(_h, _k, _orbit, _angle, _speed, _diameter) {
		a := ((_angle >= 0) ? Mod(_angle, 360) : 360 - Mod(-_angle, -360))*0.01745329251994329576923690768489

		this.h := _h, this.Ox := _orbit*Cos(a), this.k := _k, this.Oy := _orbit*Sin(a)

		this.angle := _angle
		this.diameter := _diameter

		Return (this)
	}

	Update() {
		a := vDegrees*0.01745329251994329576923690768489
		d := this.diameter + this.diameter*Sin(a)*.5

		this.x := this.h + this.Ox*Cos(a) - d/2, this.y := this.k + this.Oy*Sin(a + 1.5707963267948966192313216916398) - d/2
		If (vDebug)
			ToolTip, % this.x " = " this.h " + " (this.Ox)*Cos(a) "`n" this.y " = " this.k " + " this.Oy*Sin(a + 1.5707963267948966192313216916398)

		Gdip_FillEllipse(vCanvas.G, vCanvas.pBrush[1], this.x, this.y, d, d)
	}
}










Geometry_Circle_PerimeterPoint(_circle, _angle) {
	a := ((_angle >= 0) ? Mod(_angle, 360) : 360 - Mod(-_angle, -360))*0.01745329251994329576923690768489
		, c := Cos(a), s := Sin(a)

	Return ({"x": _circle.h + _circle.radius*c
		, "y": _circle.k + _circle.radius*s})
}