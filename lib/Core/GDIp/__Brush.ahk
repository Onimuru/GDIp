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


	;* brush.GetType()
	;* Return:
		;? 0: Brush
		;? 1: HatchBrush
		;? 2: TextureBrush
		;? 3: Path gradient
		;? 4: Linear gradient
		;? -1: Error
	GetType() {
		Local

		if (status := DllCall("Gdiplus\GdipGetBrushType", "Ptr", this.Ptr, "Int*", result := 0, "Int")) {
			throw (Exception(FormatStatus(status)))
		}

		return (result)
	}
}

;------------- Hatchbrush -----------------------------------------------------;

;* GDIp.CreateHatchBrush(frontColor, backColor[, hatchStyle])
;* Parameter:
	;* hatchStyle:
		;? 0: Horizontal
		;? 1: Vertical
		;? 2: ForwardDiagonal
		;? 3: BackwardDiagonal
		;? 4: Cross
		;? 5: DiagonalCross
		;? 6: 05Percent
		;? 7: 10Percent
		;? 8: 20Percent
		;? 9: 25Percent
		;? 10: 30Percent
		;? 11: 40Percent
		;? 12: 50Percent
		;? 13: 60Percent
		;? 14: 70Percent
		;? 15: 75Percent
		;? 16: 80Percent
		;? 17: 90Percent
		;? 18: LightDownwardDiagonal
		;? 19: LightUpwardDiagonal
		;? 20: DarkDownwardDiagonal
		;? 21: DarkUpwardDiagonal
		;? 22: WideDownwardDiagonal
		;? 23: WideUpwardDiagonal
		;? 24: LightVertical
		;? 25: LightHorizontal
		;? 26: NarrowVertical
		;? 27: NarrowHorizontal
		;? 28: DarkVertical
		;? 29: DarkHorizontal
		;? 30: DashedDownwardDiagonal
		;? 31: DashedUpwardDiagonal
		;? 32: DashedHorizontal
		;? 33: DashedVertical
		;? 34: SmallConfetti
		;? 35: LargeConfetti
		;? 36: ZigZag
		;? 37: Wave
		;? 38: DiagonalBrick
		;? 39: HorizontalBrick
		;? 40: Weave
		;? 41: Plaid
		;? 42: Divot
		;? 43: DottedGrid
		;? 44: DottedDiamond
		;? 45: Shingle
		;? 46: Trellis
		;? 47: Sphere
		;? 48: SmallGrid
		;? 49: SmallCheckerBoard
		;? 50: LargeCheckerBoard
		;? 51: OutlinedDiamond
		;? 52: SolidDiamond
		;? 53: Total
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
	;* wrapMode:
		;? 0: Tiling without flipping.
		;? 1: Tiles are flipped horizontally as you move from one tile to the next in a row.
		;? 2: Tiles are flipped vertically as you move from one tile to the next in a column.
		;? 3: Tiles are flipped horizontally as you move along a row and flipped vertically as you move along a column.
		;? 4: No tiling takes place.
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