﻿#KeyHistory 0
#NoEnv
#Persistent
#SingleInstance Force

ListLines, Off
Process, Priority, , R
SetBatchLines, -1
SetControlDelay, -1

Global vRadius := 150, vDiameter := vRadius*2
	, vCanvas := new LayeredWindow("gCanvas", "-Caption +AlwaysOnTop +ToolWindow +OwnDialogs +E0x20", A_ScreenWidth - vRadius*2.5, vRadius*.5, vDiameter*1.5, vDiameter*1.5)
	, vDegrees := 0

SetTimer, Update, 5

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
Exit:
	SetTimer, Update, Delete

	vCanvas.ShutDown()

	ExitApp
	Return

/*
	===== Functions ================================================================================
*/

Update() {
	vDegrees := vDegrees >= 360 ? 0 : ++vDegrees
	vRadians := vDegrees*0.01745329251994329576923690768489

	if (vDegrees <= 90)
		vOffset_x := vDiameter*Sin(vRadians)
			, vOffset_y := 0

	else if (vDegrees <= 180)
		vOffset_x := (vDiameter*Sin(vRadians)) - (vDiameter*Cos(vRadians))
			, vOffset_y := -vDiameter*Cos(vRadians)

	else if (vDegrees <= 270)
		vOffset_x := -(vDiameter*Cos(vRadians))
			, vOffset_y := -(vDiameter*Cos(vRadians)) - (vDiameter*Sin(vRadians))

	else
		vOffset_x := 0
			, vOffset_y := -vDiameter*Sin(vRadians)

	vOffset := (Ceil(Abs(vDiameter*Cos(vRadians)) + Abs(vDiameter*Sin(vRadians))) - vDiameter)/2
	Gdip_TranslateWorldTransform(vCanvas.G, vOffset_x - vOffset, vOffset_y - vOffset), Gdip_RotateWorldTransform(vCanvas.G, vDegrees)

	vCanvas.pPen := Gdip_CreatePen("0x05" . Format("{:06X}", DllCall("shlwapi\ColorHLSToRGB", UInt, vDegrees/360*240, UInt, 120, UInt, 120)), 1)
	vOffset_h := vDiameter*Sin(vDegrees)
		, vOffset_y := (vDiameter - vOffset_h)/2
	Gdip_DrawEllipse(vCanvas.G, vCanvas.pPen_null, 0, vOffset_y, vDiameter, vOffset_h), Gdip_DrawEllipse(vCanvas.G, vCanvas.pPen, 0, vOffset_y, vDiameter, vOffset_h), Gdip_DeletePen(vCanvas.pPen)

	UpdateLayeredWindow(vCanvas.hwnd, vCanvas.hdc), Gdip_ResetWorldTransform(vCanvas.G)
}

Class LayeredWindow {
	__New(_name, _options, _x, _y, _w, _h, _smoothing := 4, _interpolation := 7) {
		this.Layered := {"Name": _name
			, "x": _x
			, "y": _y
			, "w": _w
			, "h": _h}

		this.Layered.pToken := Gdip_Startup()
		this.Layered.hbm := CreateDIBSection(_w, _h), this.Layered.hdc := CreateCompatibleDC(), this.Layered.obm := SelectObject(this.Layered.hdc, this.Layered.hbm)
		this.Layered.G := Gdip_GraphicsFromHDC(this.Layered.hdc), Gdip_SetSmoothingMode(this.Layered.G, _smoothing), Gdip_SetInterpolationMode(this.Layered.G, _interpolation)

		this.Layered.pPen_null := Gdip_CreatePen("0x05000000", 2)  ;*** Only works on a dark backround.

		Gui, % _name . ": New", % _options . " +LastFound +E0x80000"
		Gui, % _name . ": Show", % " x" . _x . " y" . _y . " w" . _w " h" . _h . " NA"
		this.Layered.hwnd := WinExist()

		Return (this.Layered)
	}

	ShutDown() {
		Gdip_DeletePen(this.Layered.pPen), Gdip_DeletePen(this.Layered.pPen_null)

		SelectObject(this.Layered.hdc, this.Layered.obm), DeleteObject(this.Layered.hbm), DeleteDC(this.Layered.hdc), Gdip_DeleteGraphics(this.Layered.G)
		Gdip_Shutdown(this.Layered.pToken)
	}
}