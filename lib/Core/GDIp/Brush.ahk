/*
;* BrushType enumeration (https://docs.microsoft.com/en-us/windows/win32/api/gdiplusenums/ne-gdiplusenums-brushtype)
	;? 0 = BrushTypeSolidColor
	;? 1 = BrushTypeHatchFill
	;? 2 = BrushTypeTextureFill
	;? 3 = BrushTypePathGradient
	;? 4 = BrushTypeLinearGradient

;* HatchStyle enumeration (https://docs.microsoft.com/en-us/windows/win32/api/gdiplusenums/ne-gdiplusenums-hatchstyle)
	;? 0 = HatchStyleHorizontal || HatchStyleMin
	;? 1 = HatchStyleVertical
	;? 2 = HatchStyleForwardDiagonal
	;? 3 = HatchStyleBackwardDiagonal
	;? 4 = HatchStyleCross || HatchStyleLargeGrid
	;? 5 = HatchStyleDiagonalCross
	;? 6 = HatchStyle05Percent
	;? 7 = HatchStyle10Percent
	;? 8 = HatchStyle20Percent
	;? 9 = HatchStyle25Percent
	;? 10 = HatchStyle30Percent
	;? 11 = HatchStyle40Percent
	;? 12 = HatchStyle50Percent
	;? 13 = HatchStyle60Percent
	;? 14 = HatchStyle70Percent
	;? 15 = HatchStyle75Percent
	;? 16 = HatchStyle80Percent
	;? 17 = HatchStyle90Percent
	;? 18 = HatchStyleLightDownwardDiagonal
	;? 19 = HatchStyleLightUpwardDiagonal
	;? 20 = HatchStyleDarkDownwardDiagonal
	;? 21 = HatchStyleDarkUpwardDiagonal
	;? 22 = HatchStyleWideDownwardDiagonal
	;? 23 = HatchStyleWideUpwardDiagonal
	;? 24 = HatchStyleLightVertical
	;? 25 = HatchStyleLightHorizontal
	;? 26 = HatchStyleNarrowVertical
	;? 27 = HatchStyleNarrowHorizontal
	;? 28 = HatchStyleDarkVertical
	;? 29 = HatchStyleDarkHorizontal
	;? 30 = HatchStyleDashedDownwardDiagonal
	;? 31 = HatchStyleDashedUpwardDiagonal
	;? 32 = HatchStyleDashedHorizontal
	;? 33 = HatchStyleDashedVertical
	;? 34 = HatchStyleSmallConfetti
	;? 35 = HatchStyleLargeConfetti
	;? 36 = HatchStyleZigZag
	;? 37 = HatchStyleWave
	;? 38 = HatchStyleDiagonalBrick
	;? 39 = HatchStyleHorizontalBrick
	;? 40 = HatchStyleWeave
	;? 41 = HatchStylePlaid
	;? 42 = HatchStyleDivot
	;? 43 = HatchStyleDottedGrid
	;? 44 = HatchStyleDottedDiamond
	;? 45 = HatchStyleShingle
	;? 46 = HatchStyleTrellis
	;? 47 = HatchStyleSphere
	;? 48 = HatchStyleSmallGrid
	;? 49 = HatchStyleSmallCheckerBoard
	;? 50 = HatchStyleLargeCheckerBoard
	;? 51 = HatchStyleOutlinedDiamond
	;? 52 = HatchStyleSolidDiamond || HatchStyleMax
	;? 53 = HatchStyleTotal

;* WrapMode enumeration (https://docs.microsoft.com/en-us/windows/win32/api/gdiplusenums/ne-gdiplusenums-wrapmode)
	;? 0 = WrapModeTile - Tiling without flipping.
	;? 1 = WrapModeTileFlipX - Tiles are flipped horizontally as you move from one tile to the next in a row.
	;? 2 = WrapModeTileFlipY - Tiles are flipped vertically as you move from one tile to the next in a column.
	;? 3 = WrapModeTileFlipXY - Tiles are flipped horizontally as you move along a row and flipped vertically as you move along a column.
	;? 4 = WrapModeClamp - No tiling takes place.
*/

;------------- SolidBrush -----------------------------------------------------;

CreateSolidBrush(color)  {
	Local

	if (status := DllCall("Gdiplus\GdipCreateSolidFill", "UInt", color, "Ptr*", pBrush := 0, "Int")) {
		throw (Exception(FormatStatus(status)))
	}

	return ({"Ptr": pBrush
		, "Base": this.__SolidBrush})
}

Class __SolidBrush {

	__Delete() {
		if (!this.Ptr) {
			MsgBox("Brush.__Delete()")
		}

		DllCall("Gdiplus\GdipDeleteBrush", "Ptr", this.Ptr)
	}

	;-------------- Property ------------------------------------------------------;

	Color[] {
		Get {
			return (this.GetColor())
		}

		Set {
			this.SetColor(value)

			return (value)
		}
	}

	GetColor() {
		Local

		if (status := DllCall("Gdiplus\GdipGetSolidFillColor", "Ptr", this.Ptr, "UInt*", color := 0, "Int")) {
			throw (Exception(FormatStatus(status)))
		}

		return (Format("0x{:08X}", color))
	}

	SetColor(color := 0xFFFFFFFF) {
		Local

		if (status := DllCall("Gdiplus\GdipSetSolidFillColor", "Ptr", this.Ptr, "UInt", color, "Int")) {
			throw (Exception(FormatStatus(status)))
		}

		return (True)
	}

	Type[] {
		Get {
			return (this.GetType())
		}
	}

	;* brush.GetType()
	;* Return:
		;* type - BrushType enumeration.
	GetType() {
		Local

		if (status := DllCall("Gdiplus\GdipGetBrushType", "Ptr", this.Ptr, "Int*", type := 0, "Int")) {
			throw (Exception(FormatStatus(status)))
		}

		return (type)
	}

	;--------------- Method -------------------------------------------------------;

	Clone() {
		if (status := DllCall("Gdiplus\GdipCloneBrush", "Ptr", this.Ptr, "Ptr*", pBrush := 0, "Int")) {
			throw (Exception(FormatStatus(status)))
		}

		return ({"Ptr": pBrush
			, "Base": this.Base})
	}
}

;------------- HatchBrush -----------------------------------------------------;

;* GDIp.CreateHatchBrush(foregroundColor, backgroundColor[, style])
;* Parameter:
	;* style - HatchStyle enumeration.
CreateHatchBrush(foregroundColor, backgroundColor, style := 0) {
	Local

	if (status := DllCall("Gdiplus\GdipCreateHatchBrush", "Int", style, "UInt", foregroundColor, "UInt", backgroundColor, "UPtr*", pBrush := 0, "Int")) {
		throw (Exception(FormatStatus(status)))
	}

	return ({"Ptr": pBrush
		, "Base": this.__HatchBrush})
}

Class __HatchBrush extends GDIp.__SolidBrush {

	Color[which] {
		Get {
			return (this.GetColor(which))
		}
	}

	;* GDIp.GetColor(which)
	;* Parameter:
		;* which - Must be either `"Foreground"` or `"Background"`.
	GetColor(which) {
		Local

		if (status := DllCall("Gdiplus\GdipGetHatch" . which . "Color", "Ptr", this.Ptr, "UInt*", color := 0, "Int")) {
			throw (Exception(FormatStatus(status)))
		}

		return (Format("0x{:08X}", color))
	}

	HatchStyle[which] {
		Get {
			return (this.GetHatchStyle())
		}
	}

	;* hatchBrush.GetHatchStyle():
	;* Return:
		;* style - HatchStyle enumeration.
	GetHatchStyle() {
		Local

		if (status := DllCall("Gdiplus\GdipGetHatchStyle", Ptr, this.Ptr, "Int*", style := 0, "Int")) {
			throw (Exception(FormatStatus(status)))
		}

		return (style)
	}
}

;------------ TextureBrush ----------------------------------------------------;

;* GDIp.CreateTextureBrush([__Bitmap] bitmap[, wrapMode, x, y, width, height, [__ImageAttributes] imageAttributes])
;* Parameter:
	;* wrapMode - WrapMode enumeration.
CreateTextureBrush(bitmap, wrapMode := 0, x := "", y := "", width := "", height := "", imageAttributes := 0) {
	Local

	if (x == "" || y == "" || width == "" || height == "") {
		if (status := DllCall("Gdiplus\GdipCreateTexture", "Ptr", bitmap.Ptr, "UInt", wrapMode, "Ptr*", pBrush := 0, "Int")) {
			throw (Exception(FormatStatus(status)))
		}
	}
	else {
		if (imageAttributes) {
			if (status := DllCall("Gdiplus\GdipCreateTextureIA", "Ptr", bitmap.Ptr, "Ptr", imageAttributes.Ptr, "Float", x, "Float", y, "Float", width, "Float", height, "Ptr*", pBrush := 0, "Int")) {
				throw (Exception(FormatStatus(status)))
			}

			if (status := DllCall("Gdiplus\GdipSetTextureWrapMode", "Ptr", pBrush, "Int", wrapMode, "Int")) {
				throw (Exception(FormatStatus(status)))
			}
		}
		else {
			if (status := DllCall("Gdiplus\GdipCreateTexture2", "Ptr", bitmap.Ptr, "UInt", wrapMode, "Float", x, "Float", y, "Float", width, "Float", height, "Ptr*", pBrush := 0, "Int")) {
				throw (Exception(FormatStatus(status)))
			}
		}
	}

	return ({"Ptr": pBrush
		, "Base": this.__TextureBrush})
}

Class __TextureBrush extends GDIp.__SolidBrush {

	;-------------- Property ------------------------------------------------------;

	Bitmap[] {
		Get {
			return (this.GetBitmap())
		}
	}

	GetBitmap() {
		Local

		if (status := DllCall("Gdiplus\GdipGetTextureImage", "Ptr", this.Ptr, "Ptr*", pBitmap := 0, "Int")) {
			throw (Exception(FormatStatus(status)))
		}

		return ({"Ptr": pBitmap
			, "Base": GDIp.__Bitmap})
	}

	WrapMode[] {
		Get {
			return (this.GetWrapMode())
		}

		Set {
			this.SetWrapMode(value)

			return (value)
		}
	}

	GetWrapMode() {
		Local

		if (status := DllCall("Gdiplus\GdipGetTextureWrapMode", "Ptr", this.Ptr, "Int*", mode := 0, "Int")) {
			throw (Exception(FormatStatus(status)))
		}

		return (mode)
	}

	SetWrapMode(mode) {
		Local

		if (status := DllCall("Gdiplus\GdipSetTextureWrapMode", "Ptr", this.Ptr, "Int", mode, "Int")) {
			throw (Exception(FormatStatus(status)))
		}

		return (True)
	}

	Transform[] {
		Get {
			return (this.GetTransform())
		}

		Set {
			this.SetTransform(value)

			return (value)
		}
	}

	GetTransform() {
		Local

		if (status := DllCall("Gdiplus\GdipGetTextureTransform", "Ptr", this.Ptr, "Ptr*", pMatrix := 0, "Int")) {
			throw (Exception(FormatStatus(status)))
		}

		return (pMatrix)
	}

	SetTransform(matrix) {
		Local

		if (status := DllCall("Gdiplus\GdipSetTextureTransform", "Ptr", this.Ptr, "Ptr", matrix.Ptr, "Int")) {
			throw (Exception(FormatStatus(status)))
		}

		return (True)
	}

	;--------------- Method -------------------------------------------------------;
	;-----------------------------------------------------  Transform  -------------;

	RotateTransform(angle, matrixOrder := 0) {
		Local

		if (status := DllCall("Gdiplus\GdipRotateTextureTransform", "Ptr", this.Ptr, "Float", angle, "Int", matrixOrder, "Int")) {
			throw (Exception(FormatStatus(status)))
		}

		return (True)
	}

	TranslateTransform(x, y, matrixOrder := 0) {
		Local

		if (status := DllCall("Gdiplus\GdipTranslateTextureTransform", "Ptr", this.Ptr, "Float", x, "Float", y, "Int", matrixOrder, "Int")) {
			throw (Exception(FormatStatus(status)))
		}

		return (True)
	}

	MultiplyTransform(matrix, matrixOrder := 0) {
		Local

		if (status := DllCall("Gdiplus\GdipMultiplyTextureTransform", "Ptr", this.Ptr, "Ptr", matrix.Ptr, "Int", matrixOrder, "Int")) {
			throw (Exception(FormatStatus(status)))
		}

		return (True)
	}

	ScaleTransform(x, y, matrixOrder := 0) {
		Local

		if (status := DllCall("Gdiplus\GdipScaleTextureTransform", "Ptr", this.Ptr, "Float", x, "Float", y, "Int", matrixOrder, "Int")) {
			throw (Exception(FormatStatus(status)))
		}

		return (True)
	}

	ResetTransform() {
		Local

		if (status := DllCall("Gdiplus\GdipResetTextureTransform", "Ptr", this.Ptr, "Int")) {
			throw (Exception(FormatStatus(status)))
		}

		return (True)
	}
}

;------------  LinearBrush  ----------------------------------------------------;

;* GDIp.CreateLinearBrush(x1, y1, x2, y2, color1, color2[, wrapMode])
;* Parameter:
	;* wrapMode - WrapMode enumeration.
CreateLinearBrush(x1, y1, x2, y2, color1, color2, wrapMode := 0) {
	Static point1 := CreatePoint(0, 0, "Float"), point2 := CreatePoint(0, 0, "Float")

	point1.NumPut(0, "Float", x1, "Float", y1), point2.NumPut(0, "Float", x2, "Float", y2)

	if (status := DllCall("Gdiplus\GdipCreateLineBrush", "Ptr", point1.Ptr, "Ptr", point2.Ptr, "UInt", color1, "UInt", color2, "UInt", wrapMode, "Ptr*", pBrush := 0, "Int")) {
		throw (Exception(FormatStatus(status)))
	}

	return ({"Ptr": pBrush
		, "Base": this.__LinearBrush})
}

;* GDIp.CreateLinearBrushFromRect(x, y, width, height, color1, color2[, gradientMode, wrapMode])
;* Parameter:
	;* wrapMode - WrapMode enumeration.
CreateLinearBrushFromRect(x, y, width, height, color1, color2, gradientMode := 0, wrapMode := 0) {
	Static rect := CreateRect(0, 0, 0, 0, "Float")

	rect.NumPut(0, "Float", x, "Float", y, "Float", width, "Float", height)

	if (status := DllCall("Gdiplus\GdipCreateLineBrushFromRect", "Ptr", rect.Ptr, "UInt", color1, "UInt", color2, "UInt", gradientMode, "UInt", wrapMode, "Ptr*", pBrush := 0, "Int")) {
		throw (Exception(FormatStatus(status)))
	}

	return ({"Ptr": pBrush
		, "Base": this.__LinearBrush})
}

;* GDIp.CreateLinearBrushFromRectWithAngle(x, y, width, height, color1, color2[, angle, wrapMode])
;* Parameter:
	;* wrapMode - WrapMode enumeration.
CreateLinearBrushFromRectWithAngle(x, y, width, height, color1, color2, angle := 0, wrapMode := 0) {
	Static rect := CreateRect(0, 0, 0, 0, "Float")

	rect.NumPut(0, "Float", x, "Float", y, "Float", width, "Float", height)

	if (status := DllCall("Gdiplus\GdipCreateLineBrushFromRectWithAngle", "Ptr", rect.Ptr, "UInt", color1, "UInt", color2, "Float", angle, "UInt", 0, "UInt", wrapMode, "Ptr*", pBrush := 0, "Int")) {
		throw (Exception(FormatStatus(status)))
	}

	return ({"Ptr": pBrush
		, "Base": this.__LinearBrush})
}

Class __LinearBrush extends GDIp.__SolidBrush {

	;-------------- Property ------------------------------------------------------;

	Color[] {
		Get {
			return (this.GetColor())
		}

		Set {
			this.SetColor(value[0], value[1])

			return (value)
		}
	}

	GetColor() {
		Static colors := new Structure(8)

		if (status := DllCall("Gdiplus\GdipGetLineColors", "Ptr", this.Ptr, "Ptr", colors.Ptr, "Int")) {
			throw (Exception(FormatStatus(status)))
		}

		return ([Format("0x{:08X}", colors.NumGet(0, "UInt")), Format("0x{:08X}", colors.NumGet(4, "UInt"))])
	}

	SetColor(color1, color2) {
		Local

		if (status := DllCall("Gdiplus\GdipSetLineColors", "Ptr", this.Ptr, "UInt", color1, "UInt", color2, "Int")) {
			throw (Exception(FormatStatus(status)))
		}

		return (True)
	}

	WrapMode[] {
		Get {
			return (this.GetWrapMode())
		}

		Set {
			this.SetWrapMode(value)

			return (value)
		}
	}

	GetWrapMode() {
		Local

		if (status := DllCall("Gdiplus\GdipGetLineWrapMode", "Ptr", this.Ptr, "Int*", mode := 0, "Int")) {
			throw (Exception(FormatStatus(status)))
		}

		return (mode)
	}

	SetWrapMode(mode) {
		Local

		if (status := DllCall("Gdiplus\GdipSetLineWrapMode", "Ptr", this.Ptr, "Int", mode, "Int")) {
			throw (Exception(FormatStatus(status)))
		}

		return (True)
	}

	Rect[] {
		Get {
			return (this.GetRect())
		}
	}

	GetRect() {
		Local status

		Static rect := CreateRect(0, 0, 0, 0, "Float")

		if (status := DllCall("Gdiplus\GdipGetLineRect", "Ptr", this.Ptr, "Ptr", rect.Ptr, "Int")) {
			throw (Exception(FormatStatus(status)))
		}

		return ({"x": rect.NumGet(0, "Float"), "y": rect.NumGet(4, "Float"), "Width": rect.NumGet(8, "Float"), "Height": rect.NumGet(12, "Float")})
	}

	GammaCorrection[] {
		Get {
			return (this.GetGammaCorrection())
		}

		Set {
			this.SetGammaCorrection(value)

			return (value)
		}
	}

	;* lineBrush.GetGammaCorrection():
	;* Return:
		;* enabled - If gamma correction is enabled, this method returns True; otherwise, it returns False.
	GetGammaCorrection() {
		Local

		if (status := DllCall("Gdiplus\GdipGetLineGammaCorrection", "Ptr", this.Ptr, "Int*", enabled := 0, "Int")) {
			throw (Exception(FormatStatus(status)))
		}

		return (enabled)
	}

	SetGammaCorrection(useGammaCorrection) {
		Local

		if (status := DllCall("Gdiplus\GdipSetLineGammaCorrection", "Ptr", this.Ptr, "Int", useGammaCorrection, "Int")) {
			throw (Exception(FormatStatus(status)))
		}

		return (True)
	}

	Transform[] {
		Get {
			return (this.GetTransform())
		}

		Set {
			this.SetTransform(value)

			return (value)
		}
	}

	GetTransform() {
		Local

		if (status := DllCall("Gdiplus\GdipGetLineTransform", "Ptr", this.Ptr, "Ptr*", pMatrix := 0, "Int")) {
			throw (Exception(FormatStatus(status)))
		}

		return (pMatrix)
	}

	SetTransform(matrix) {
		Local

		if (status := DllCall("Gdiplus\GdipSetLineTransform", "Ptr", this.Ptr, "Ptr", matrix.Ptr, "Int")) {
			throw (Exception(FormatStatus(status)))
		}

		return (True)
	}

	;--------------- Method -------------------------------------------------------;
	;-----------------------------------------------------  Transform  -------------;

	TranslateTransform(x, y, matrixOrder := 0) {
		Local

		if (status := DllCall("Gdiplus\GdipTranslateLineTransform", "Ptr", this.Ptr, "Float", x, "Float", y, "Int", matrixOrder, "Int")) {
			throw (Exception(FormatStatus(status)))
		}

		return (True)
	}

	RotateTransform(angle, matrixOrder := 0) {
		Local

		if (status := DllCall("Gdiplus\GdipRotateLineTransform", "Ptr", this.Ptr, "Float", angle, "Int", matrixOrder, "Int")) {
			throw (Exception(FormatStatus(status)))
		}

		return (True)
	}

	MultiplyTransform(matrix, matrixOrder := 0) {
		Local

		if (status := DllCall("Gdiplus\GdipMultiplyLineTransform", "Ptr", this.Ptr, "Ptr", matrix.Ptr, "Int", matrixOrder, "Int")) {
			throw (Exception(FormatStatus(status)))
		}

		return (True)
	}

	ScaleTransform(x, y, matrixOrder := 0) {
		Local

		if (status := DllCall("Gdiplus\GdipScaleLineTransform", "Ptr", this.Ptr, "Float", x, "Float", y, "Int", matrixOrder, "Int")) {
			throw (Exception(FormatStatus(status)))
		}

		return (True)
	}

	ResetTransform() {
		Local

		if (status := DllCall("Gdiplus\GdipResetLineTransform", "Ptr", this.Ptr, "Int")) {
			throw (Exception(FormatStatus(status)))
		}

		return (True)
	}
}