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

	Clone() {
		if (status := DllCall("Gdiplus\GdipCloneBrush", "Ptr", this.Ptr, "Ptr*", pBrush := 0, "Int")) {
			throw (Exception(FormatStatus(status)))
		}

		return ({"Ptr": pBrush
			, "Base": this.Base})
	}

	Color[] {
		Get {
			return (this.GetColor())
		}

		Set {
			return (value, this.SetColor(value))
		}
	}

	GetColor() {
		Local

		if (status := DllCall("Gdiplus\GdipGetSolidFillColor", "Ptr", this.Ptr, "UInt*", color := 0, "Int")) {
			throw (Exception(FormatStatus(status)))
		}

		return (Format("0x{:X}", color))  ;! Format("{:#X}", color)
	}

	SetColor(color := 0xFFFFFFFF) {
		Local

		if (status := DllCall("Gdiplus\GdipSetSolidFillColor", "Ptr", this.Ptr, "UInt", color, "Int")) {
			throw (Exception(FormatStatus(status)))
		}

		return (True)
	}


	;* brush.GetBrushType()
	;* Return:
		;* brushType: ;: https://docs.microsoft.com/en-us/windows/win32/api/gdiplusenums/ne-gdiplusenums-brushtype
			;? 0: BrushTypeSolidColor
			;? 1: BrushTypeHatchFill
			;? 2: BrushTypeTextureFill
			;? 3: BrushTypePathGradient
			;? 4: BrushTypeLinearGradient
	GetBrushType() {
		Local

		if (status := DllCall("Gdiplus\GdipGetBrushType", "Ptr", this.Ptr, "Int*", brushType := 0, "Int")) {
			throw (Exception(FormatStatus(status)))
		}

		return (brushType)
	}
}

;------------- Hatchbrush -----------------------------------------------------;

;* GDIp.CreateHatchBrush(frontColor, backColor[, hatchStyle])
;* Parameter:
	;* hatchStyle:  ;: https://docs.microsoft.com/en-us/windows/win32/api/gdiplusenums/ne-gdiplusenums-hatchstyle
		;? 00: HatchStyleHorizontal || HatchStyleMin
		;? 01: HatchStyleVertical
		;? 02: HatchStyleForwardDiagonal
		;? 03: HatchStyleBackwardDiagonal
		;? 04: HatchStyleCross || HatchStyleLargeGrid
		;? 05: HatchStyleDiagonalCross
		;? 06: HatchStyle05Percent
		;? 07: HatchStyle10Percent
		;? 08: HatchStyle20Percent
		;? 09: HatchStyle25Percent
		;? 10: HatchStyle30Percent
		;? 11: HatchStyle40Percent
		;? 12: HatchStyle50Percent
		;? 13: HatchStyle60Percent
		;? 14: HatchStyle70Percent
		;? 15: HatchStyle75Percent
		;? 16: HatchStyle80Percent
		;? 17: HatchStyle90Percent
		;? 18: HatchStyleLightDownwardDiagonal
		;? 19: HatchStyleLightUpwardDiagonal
		;? 20: HatchStyleDarkDownwardDiagonal
		;? 21: HatchStyleDarkUpwardDiagonal
		;? 22: HatchStyleWideDownwardDiagonal
		;? 23: HatchStyleWideUpwardDiagonal
		;? 24: HatchStyleLightVertical
		;? 25: HatchStyleLightHorizontal
		;? 26: HatchStyleNarrowVertical
		;? 27: HatchStyleNarrowHorizontal
		;? 28: HatchStyleDarkVertical
		;? 29: HatchStyleDarkHorizontal
		;? 30: HatchStyleDashedDownwardDiagonal
		;? 31: HatchStyleDashedUpwardDiagonal
		;? 32: HatchStyleDashedHorizontal
		;? 33: HatchStyleDashedVertical
		;? 34: HatchStyleSmallConfetti
		;? 35: HatchStyleLargeConfetti
		;? 36: HatchStyleZigZag
		;? 37: HatchStyleWave
		;? 38: HatchStyleDiagonalBrick
		;? 39: HatchStyleHorizontalBrick
		;? 40: HatchStyleWeave
		;? 41: HatchStylePlaid
		;? 42: HatchStyleDivot
		;? 43: HatchStyleDottedGrid
		;? 44: HatchStyleDottedDiamond
		;? 45: HatchStyleShingle
		;? 46: HatchStyleTrellis
		;? 47: HatchStyleSphere
		;? 48: HatchStyleSmallGrid
		;? 49: HatchStyleSmallCheckerBoard
		;? 50: HatchStyleLargeCheckerBoard
		;? 51: HatchStyleOutlinedDiamond
		;? 52: HatchStyleSolidDiamond || HatchStyleMax
		;? 53: HatchStyleTotal
CreateHatchBrush(frontColor, backColor, hatchStyle := 0) {
	Local

	if (status := DllCall("Gdiplus\GdipCreateHatchBrush", "Int", hatchStyle, "UInt", frontColor, "UInt", backColor, "UPtr*", pBrush := 0, "Int")) {
		throw (Exception(FormatStatus(status)))
	}

	return ({"Ptr": pBrush
		, "Base": this.__LineBrush})
}

Class __Hatchbrush extends GDIp.__Brush {

	Color[which] {
		Get {
			return (this.GetColor(which))
		}
	}

	GetColor(which) {
		Local

		switch (which) {
			case "Background":{
				if (status := DllCall("Gdiplus\GdipGetHatchBackgroundColor", "Ptr", this.Ptr, "UInt*", color := 0, "Int")) {
					throw (Exception(FormatStatus(status)))
				}
			}
			case "Foreground":{
				if (status := DllCall("Gdiplus\GdipGetHatchForegroundColor", "Ptr", this.Ptr, "UInt*", color := 0, "Int")) {
					throw (Exception(FormatStatus(status)))
				}
			}
			Default: {
				return (False)
			}
		}

		return (Format("0x{:X}", color))
	}

	HatchStyle[which] {
		Get {
			return (this.GetHatchStyle())
		}
	}

	GetHatchStyle() {

		if (status := DllCall("Gdiplus\GdipGetHatchStyle", Ptr, this.Ptr, "Int*", result := 0, "Int")) {
			throw (Exception(FormatStatus(status)))
		}

		return (result)
	}
}

;-------------  Linebrush  -----------------------------------------------------;

;* GDIp.CreateLineBrush(x1, y1, x2, y2, color1, color2[, wrapMode])
;* Parameter:
	;* wrapMode:  ;: https://docs.microsoft.com/en-us/windows/win32/api/gdiplusenums/ne-gdiplusenums-wrapmode
		;? 0: WrapModeTile - Tiling without flipping.
		;? 1: WrapModeTileFlipX - Tiles are flipped horizontally as you move from one tile to the next in a row.
		;? 2: WrapModeTileFlipY - Tiles are flipped vertically as you move from one tile to the next in a column.
		;? 3: WrapModeTileFlipXY - Tiles are flipped horizontally as you move along a row and flipped vertically as you move along a column.
		;? 4: WrapModeClamp - No tiling takes place.
CreateLineBrush(x1, y1, x2, y2, color1, color2, wrapMode := 0) {
	Static point1 := CreatePoint(0, 0, "Float"), point2 := CreatePoint(0, 0, "Float")

	point1.NumPut(0, "Float", x1, "Float", y1), point2.NumPut(0, "Float", x2, "Float", y2)

	if (status := DllCall("Gdiplus\GdipCreateLineBrush", "Ptr", point1.Ptr, "Ptr", point2.Ptr, "UInt", color1, "UInt", color2, "UInt", wrapMode, "Ptr*", pBrush := 0, "Int")) {
		throw (Exception(FormatStatus(status)))
	}

	return ({"Ptr": pBrush
		, "Base": this.__LineBrush})
}

CreateLineBrushFromRect(x, y, width, height, color1, color2, gradientMode := 0, wrapMode := 0) {
	Static rect := CreateRect(0, 0, 0, 0, "Float")

	rect.NumPut(0, "Float", x, "Float", y, "Float", width, "Float", height)

	if (status := DllCall("Gdiplus\GdipCreateLineBrushFromRect", "Ptr", rect.Ptr, "UInt", color1, "UInt", color2, "UInt", gradientMode, "UInt", wrapMode, "Ptr*", pBrush := 0, "Int")) {
		throw (Exception(FormatStatus(status)))
	}

	return ({"Ptr": pBrush
		, "Base": this.__LineBrush})
}

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
			return (value, this.SetColor(value[0], value[1]))
		}
	}

	GetColor() {
		Static colors := new Structure(8)

		if (status := DllCall("Gdiplus\GdipGetLineColors", "Ptr", this.Ptr, "Ptr", colors.Ptr, "Int")) {
			throw (Exception(FormatStatus(status)))
		}

		return ([Format("0x{:X}", colors.NumGet(0, "UInt")), Format("0x{:X}", colors.NumGet(4, "UInt"))])
	}

	SetColor(color1 := 0xFFFFFFFF, color2 := 0xFFFFFFFF) {
		Local

		if (status := DllCall("Gdiplus\GdipSetLineColors", "Ptr", this.Ptr, "UInt", color1, "UInt", color2, "Int")) {
			throw (Exception(FormatStatus(status)))
		}

		return (True)
	}
}