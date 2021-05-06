CreatePen(color := 0xFFFFFFFF, width := 1) {
	Local

	if (status := DllCall("Gdiplus\GdipCreatePen1", "UInt", color, "Float", width, "Int", 2, "Ptr*", pPen := 0, "Int")) {
		throw (Exception(FormatStatus(status)))
	}

	return ({"Ptr": pPen
		, "Base": this.__Pen})
}

;* GDIp.CreatePenFromBrush(brush[, width, unit])
;* Parameter:
	;* unit:
		;? 0: World coordinates, a non-physical unit.
		;? 1: Display units
		;? 2: A unit is 1 pixel
		;? 3: A unit is 1 point or 1/72 inch
		;? 4: A unit is 1 inch
		;? 5: A unit is 1/300 inch
		;? 6: A unit is 1 millimeter
CreatePenFromBrush(brush, width := 1, unit := 2) {
	Local

	if (status := DllCall("Gdiplus\GdipCreatePen2", "Ptr", brush.Ptr, "Float", width, "Int", 2, "Ptr*", pPen := 0, "Int", unit, "Int")) {
		throw (Exception(FormatStatus(status)))
	}

	return ({"Ptr": pPen
		, "Base": this.__Pen})
}

Class __Pen {

	__Delete() {
		if (!this.Ptr) {
			MsgBox("Pen.__Delete()")
		}

		DllCall("Gdiplus\GdipDeletePen", "Ptr", this.Ptr)
	}

	Clone() {
		Local

		if (status := DllCall("Gdiplus\GdipClonePen", "Ptr", this.Ptr, "Ptr*", pPen, "Int")) {
			throw (Exception(FormatStatus(status)))
		}

		return ({"Ptr": pPen
			, "Base": this.Base})
	}

	BrushFill[] {
		Get {
			return (this.GetBrushFill())
		}

		Set {
			return (value, this.SetBrushFill(value))
		}
	}

	GetBrushFill() {  ;* Gets the pBrush object that is currently set for the pPen object.
		Local

		if (status := DllCall("Gdiplus\GdipGetPenBrushFill", "Ptr", this.Ptr, "Int*", pBrush, "Int")) {
			throw (Exception(FormatStatus(status)))
		}

		return (True)
	}

	SetBrushFill(brush) {
		Local

		if (status := DllCall("Gdiplus\GdipSetPenBrushFill", "Ptr", this.Ptr, "Ptr", brush.Ptr, "Int")) {
			throw (Exception(FormatStatus(status)))
		}

		return (True)
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

		if (status := DllCall("Gdiplus\GdipGetPenColor", "Ptr", this.Ptr, "UInt*", color := 0, "Int")) {  ;* `GetColor()` throws an exception if the Pen object inherited it's color from a LineBrush object.
			throw (Exception(FormatStatus(status)))
		}

		return (Format("0x{:X}", color))
	}

	SetColor(color := 0xFFFFFFFF) {
		Local

		if (status := DllCall("Gdiplus\GdipSetPenColor", "Ptr", this.Ptr, "UInt", color, "Int")) {
			throw (Exception(FormatStatus(status)))
		}

		return (True)
	}

	FillType[] {
		Get {
			return (this.GetFillType())
		}
	}

	;* GDIp.CreatePenFromBrush(brush[, width])
	;* Return:
		;? 0: The pen draws with a solid color
		;? 1: The pen draws with a hatch pattern that is specified by a HatchBrush object
		;? 2: The pen draws with a texture that is specified by a TextureBrush object
		;? 3: The pen draws with a color gradient that is specified by a PathGradientBrush object
		;? 4: The pen draws with a color gradient that is specified by a LinearGradientBrush object
		;? -1: The pen type is unknown
		;? -2: Error
	GetFillType() {
		Local

		if (status := DllCall("Gdiplus\GdipGetPenFillType", "Ptr", this.Ptr, "Int*", result := 0, "Int")) {
			throw (Exception(FormatStatus(status)))
		}

		return (result)
	}

	Width[] {
		Get {
			return (this.GetWidth())
		}

		Set {
			return (value, this.SetWidth(value))
		}
	}

	GetWidth() {
		Local

		if (status := DllCall("Gdiplus\GdipGetPenWidth", "Ptr", this.Ptr, "Float*", width := 0, "Int")) {
			throw (Exception(FormatStatus(status)))
		}

		return (~~width)
	}

	SetWidth(width := 1) {
		Local

		if (status := DllCall("Gdiplus\GdipSetPenWidth", "Ptr", this.Ptr, "Float", width, "Int")) {
			throw (Exception(FormatStatus(status)))
		}

		return (True)
	}
}