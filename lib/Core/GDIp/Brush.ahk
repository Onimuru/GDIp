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

CreateBrush(color := 0xFFFFFFFF)  {
	Local

	if (status := DllCall("Gdiplus\GdipCreateSolidFill", "UInt", color, "Ptr*", pBrush := 0, "Int")) {
		throw (Exception(FormatStatus(status)))
	}

	return ({"Ptr": pBrush
		, "Base": this.__Brush})
}

Class __Brush {

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
		;* type: BrushType enumeration.
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

;------------- Hatchbrush -----------------------------------------------------;

;* GDIp.CreateHatchBrush(frontColor, backColor[, style])
;* Parameter:
	;* style: HatchStyle enumeration.
CreateHatchBrush(frontColor, backColor, style := 0) {
	Local

	if (status := DllCall("Gdiplus\GdipCreateHatchBrush", "Int", style, "UInt", frontColor, "UInt", backColor, "UPtr*", pBrush := 0, "Int")) {
		throw (Exception(FormatStatus(status)))
	}

	return ({"Ptr": pBrush
		, "Base": this.__HatchBrush})
}

Class __HatchBrush extends GDIp.__Brush {

	Color[which] {
		Get {
			return (this.GetColor(which))
		}
	}

	GetColor(which) {  ;? which = "Foreground" || "Background"
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
		;* style: HatchStyle enumeration.
	GetHatchStyle() {
		Local

		if (status := DllCall("Gdiplus\GdipGetHatchStyle", Ptr, this.Ptr, "Int*", style := 0, "Int")) {
			throw (Exception(FormatStatus(status)))
		}

		return (style)
	}
}

;-------------  Linebrush  -----------------------------------------------------;

;* GDIp.CreateLineBrush(x1, y1, x2, y2, color1, color2[, wrapMode])
;* Parameter:
	;* wrapMode: WrapMode enumeration.
CreateLineBrush(x1, y1, x2, y2, color1, color2, wrapMode := 0) {
	Static point1 := CreatePoint(0, 0, "Float"), point2 := CreatePoint(0, 0, "Float")

	point1.NumPut(0, "Float", x1, "Float", y1), point2.NumPut(0, "Float", x2, "Float", y2)

	if (status := DllCall("Gdiplus\GdipCreateLineBrush", "Ptr", point1.Ptr, "Ptr", point2.Ptr, "UInt", color1, "UInt", color2, "UInt", wrapMode, "Ptr*", pBrush := 0, "Int")) {
		throw (Exception(FormatStatus(status)))
	}

	return ({"Ptr": pBrush
		, "Base": this.__LineBrush})
}

;* GDIp.CreateLineBrushFromRect(x, y, width, height, color1, color2[, gradientMode, wrapMode])
;* Parameter:
	;* wrapMode: WrapMode enumeration.
CreateLineBrushFromRect(x, y, width, height, color1, color2, gradientMode := 0, wrapMode := 0) {
	Static rect := CreateRect(0, 0, 0, 0, "Float")

	rect.NumPut(0, "Float", x, "Float", y, "Float", width, "Float", height)

	if (status := DllCall("Gdiplus\GdipCreateLineBrushFromRect", "Ptr", rect.Ptr, "UInt", color1, "UInt", color2, "UInt", gradientMode, "UInt", wrapMode, "Ptr*", pBrush := 0, "Int")) {
		throw (Exception(FormatStatus(status)))
	}

	return ({"Ptr": pBrush
		, "Base": this.__LineBrush})
}

;* GDIp.CreateLineBrushFromRectWithAngle(x, y, width, height, color1, color2[, angle, wrapMode])
;* Parameter:
	;* wrapMode: WrapMode enumeration.
CreateLineBrushFromRectWithAngle(x, y, width, height, color1, color2, angle := 0, wrapMode := 0) {
	Static rect := CreateRect(0, 0, 0, 0, "Float")

	rect.NumPut(0, "Float", x, "Float", y, "Float", width, "Float", height)

	if (status := DllCall("Gdiplus\GdipCreateLineBrushFromRectWithAngle", "Ptr", rect.Ptr, "UInt", color1, "UInt", color2, "Float", angle, "UInt", 0, "UInt", wrapMode, "Ptr*", pBrush := 0, "Int")) {
		throw (Exception(FormatStatus(status)))
	}

	return ({"Ptr": pBrush
		, "Base": this.__LineBrush})
}

Class __LineBrush extends GDIp.__Brush {

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

	SetColor(color1 := 0xFFFFFFFF, color2 := 0xFFFFFFFF) {
		Local

		if (status := DllCall("Gdiplus\GdipSetLineColors", "Ptr", this.Ptr, "UInt", color1, "UInt", color2, "Int")) {
			throw (Exception(FormatStatus(status)))
		}

		return (True)
	}
}