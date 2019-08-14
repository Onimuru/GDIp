Class Canvas {
	__New(_name, _options, _x, _y, _width, _height, _smoothing := 4, _interpolation := 7, _hide := 0) {
		this.x := _x, this.y := _y, this.width := _width, this.height := _height

		this.pToken := Gdip_Startup()
		this.hbm := CreateDIBSection(_width, _height), this.hdc := CreateCompatibleDC(), this.obm := SelectObject(this.hdc, this.hbm)
		this.G := Gdip_GraphicsFromHDC(this.hdc), Gdip_SetSmoothingMode(this.G, _smoothing), Gdip_SetInterpolationMode(this.G, _interpolation)

		(this.pBrush := [])[0] := Gdip_BrushCreateSolid("0xFFFFFFFF"), 	(this.pPen := [])[0] := Gdip_CreatePen("0xFFFFFFFF", 1)

		Gui, % _name ": New", % _options . " +LastFound +E0x80000"
		Gui, % _name ": Show", % " x" . _x . " y" . _y . " w" . _width . " h" . _height . (_hide ? " Hide" : " NA")
		this.hwnd := WinExist()

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

	Clear() {
		Gdip_GraphicsClear(this.G)
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