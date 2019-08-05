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
	, vPoints := 60
	, vCanvas := new Canvas("-Caption +AlwaysOnTop +ToolWindow +OwnDialogs +E0x20", A_ScreenWidth - vRadius*2.5 - 5, vRadius*.5 - 5, vDiameter + 10, vDiameter + 10)
	, Circles := [{"x": 5
			, "y": 5
			, "w": vDiameter
			, "h": vDiameter
			, "center": {"x": vRadius + 5  ;Circles[A_Index].center := Geometry_Center({"x": Circles[A_Index].x, "y": Circles[A_Index].y}, {"x": Circles[A_Index].x + Circles[A_Index].w, "y": Circles[A_Index].y + Circles[A_Index].h})
				, "y": vRadius + 5}
			, "radius": vRadius}  ;Circles[A_Index].radius := Geometry_Distance({"x": Circles[A_Index].x, "y": Circles[A_Index].y + Circles[A_Index].w/2}, {"x": Circles[A_Index].center.x, "y": Circles[A_Index].center.y})
		, {"x": vRadius*0.75 + 5
			, "y": vRadius*0.75 + 5
			, "w": vRadius*0.5
			, "h": vRadius*0.5
			, "center": {"x": vRadius + 5
				, "y": vRadius + 5}
			, "radius": vRadius*0.25}]
	, Color := {}
	, Balls := []
	, Count := [0, 0, 0]
	, vDegrees := 0

Loop, % vPoints {
	If (A_Index <= 10)
		Balls[A_Index] := []

	a := (360/vPoints)*(A_Index - 1)

	Color[a] := Count[3] += Count[3] = 3 ? -2 : 1
}

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
	vDegrees += vDegrees = 360 ? -359.5 : .5
		, Count[1] += Count[1] = 10 ? -9 : 1

	Loop, 2
		Gdip_DrawEllipse(vCanvas.G, vCanvas.pPen, Circles[A_Index].x, Circles[A_Index].y, Circles[A_Index].w, Circles[A_Index].h)

	Gdip_TranslateWorldTransform(vCanvas.G, Circles[1].center.x, Circles[1].center.y), Gdip_RotateWorldTransform(vCanvas.G, vDegrees), Gdip_TranslateWorldTransform(vCanvas.G, -Circles[1].center.x, -Circles[1].center.y)


	For i, v in Balls
		For i, v in v
			v.UpDate()

	If (Count[1] = 1) {
		Count[2] += Count[2] = 10 ? -9 : 1

		For i, v in Balls[Count[2] != 1 ? Count[2] - 1 : 10]
			v.Inert := 0

		For i, v in Balls[Count[2] != 10 ? Count[2] + 1 : 1]
			v.Inert := 1

		Loop, % vPoints {
			a := (360/vPoints)*(A_Index - 1)

			Balls[Count[2]][A_Index] := new Ball(Geometry_Circle_PerimeterPoint(Circles[1], a), Geometry_Circle_PerimeterPoint(Circles[2], a), a)
		}
	}

	UpdateLayeredWindow(vCanvas.hwnd, vCanvas.hdc), Gdip_GraphicsClear(vCanvas.G), Gdip_ResetWorldTransform(vCanvas.G)

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
		this.Layered.pBrush := [Gdip_BrushCreateSolid("0xFFFF0000")
			, Gdip_BrushCreateSolid("0xFF00FF00")
			, Gdip_BrushCreateSolid("0xFF0000FF")]

		Gui, New, % _options . " +LastFound +E0x80000"
		Gui, Show, % " x" . _x . " y" . _y . " w" . _w " h" . _h . " NA"
		this.Layered.hwnd := WinExist()

		Return (this.Layered)
	}

	ShutDown() {
		Gdip_DeletePen(this.Layered.pPen)
		For i, v in this.Layered.pBrush
			Gdip_DeletePen(v)

		SelectObject(this.Layered.hdc, this.Layered.obm), DeleteObject(this.Layered.hbm), DeleteDC(this.Layered.hdc), Gdip_DeleteGraphics(this.Layered.G)
		Gdip_Shutdown(this.Layered.pToken)
	}
}

Class Ball {
	__New(_outer, _inner, _angle) {
		this.Cx := this.Ox := _outer.x, this.Cy := this.Oy  := _outer.y
			, this.Dx := (_outer.x - _inner.x)/81, this.Dy := (_outer.y - _inner.y)/81

		this.Inert := 1
		this.C := (Color[_angle] += Color[_angle] = 3 ? -2 : 1)

		Return (this)
	}

	Update() {
		If (!this.Inert)
			this.Cx -= this.Dx, this.Cy -= this.Dy

		Gdip_FillEllipse(vCanvas.G, vCanvas.pBrush[this.C], this.Cx - 2.5, this.Cy - 2.5, 5, 5)
	}
}

Geometry_Circle_PerimeterPoint(_circle, _angle) {
	a := ((_angle >= 0) ? Mod(_angle, 360) : 360 - Mod(-_angle, -360))*0.01745329251994329576923690768489
		, c := Cos(a), s := Sin(a)

	Return ({"x": _circle.center.x + _circle.radius*c
		, "y": _circle.center.y + _circle.radius*s})
}