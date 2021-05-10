;* GDIp.CreatePen([color, width, unit])
;* Parameter:
	;* unit:  ;: https://docs.microsoft.com/en-us/windows/win32/api/gdiplusenums/ne-gdiplusenums-unit
		;? 0: UnitWorld - World coordinate (non-physical unit).
		;? 1: UnitDisplay - Variable (only for PageTransform).
		;? 2: UnitPixel - Each unit is one device pixel.
		;? 3: UnitPoint - Each unit is a printer's point, or 1/72 inch.
		;? 4: UnitInch
		;? 5: UnitDocument - Each unit is 1/300 inch.
		;? 6: UnitMillimeter
CreatePen(color := 0xFFFFFFFF, width := 1, unit := 2) {
	Local

	if (status := DllCall("Gdiplus\GdipCreatePen1", "UInt", color, "Float", width, "Int", unit, "Ptr*", pPen := 0, "Int")) {
		throw (Exception(FormatStatus(status)))
	}

	return ({"Ptr": pPen
		, "Base": this.__Pen})
}

;* GDIp.CreatePenFromBrush([__Brush] brush[, width, unit])
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

		if (status := DllCall("Gdiplus\GdipGetPenColor", "Ptr", this.Ptr, "UInt*", color := 0, "Int")) {  ;* `GetColor()` throws an exception if the Pen object inherited it's color from a LineBrush object.
			throw (Exception(FormatStatus(status)))
		}

		return (Format("0x{:08X}", color))
	}

	SetColor(color := 0xFFFFFFFF) {
		Local

		if (status := DllCall("Gdiplus\GdipSetPenColor", "Ptr", this.Ptr, "UInt", color, "Int")) {
			throw (Exception(FormatStatus(status)))
		}

		return (True)
	}

	Width[] {
		Get {
			return (this.GetWidth())
		}

		Set {
			this.SetWidth(value)

			return (value)
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

	Alignment[] {
		Get {
			return (this.GetAlignment())
		}
	}

	;* pen.GetAlignment()
	;* Return:
		;* penAlignment:  ;: https://docs.microsoft.com/en-us/windows/win32/api/gdiplusenums/ne-gdiplusenums-penalignment
			;? 0: PenAlignmentCenter
			;? 1: PenAlignmentInset
	GetAlignment() {
		Local

		if (status := DllCall("Gdiplus\GdipGetPenMode", "Ptr", this.Ptr, "Int*", penAlignment := 0, "Int")) {
			throw (Exception(FormatStatus(status)))
		}

		return (penAlignment)
	}

	Brush[] {
		Get {
			return (this.GetBrush())
		}

		Set {
			this.SetBrush(value)

			return (value)
		}
	}

	GetBrush() {  ;* Gets the pBrush object that is currently set for this pen object.
		Local

		if (status := DllCall("Gdiplus\GdipGetPenBrushFill", "Ptr", this.Ptr, "Ptr*", pBrush := 0, "Int")) {
			throw (Exception(FormatStatus(status)))
		}

		return (pBrush)
	}

	;* pen.SetBrush([__Brush] brush)
	SetBrush(brush) {
		Local

		if (status := DllCall("Gdiplus\GdipSetPenBrushFill", "Ptr", this.Ptr, "Ptr", brush.Ptr, "Int")) {
			throw (Exception(FormatStatus(status)))
		}

		return (True)
	}

	DashCaps[] {
		Get {
			return (this.GetDashCaps())
		}
	}

	GetDashCaps() {
		Local

		if (status := DllCall("Gdiplus\GdipGetPenDashCap197819", "Ptr", this.Ptr, "Int*", dashCaps := 0, "Int")) {
			throw (Exception(FormatStatus(status)))
		}

		return (dashCaps)
	}

	DashStyle[] {
		Get {
			return (this.GetDashStyle())
		}
	}

	;* pen.GetDashStyle()
	;* Return:
		;* dashStyle:  ;: https://docs.microsoft.com/en-us/windows/win32/api/gdiplusenums/ne-gdiplusenums-dashstyle
			;? 0: DashStyleSolid
			;? 1: DashStyleDash
			;? 2: DashStyleDot
			;? 3: DashStyleDashDot
			;? 4: DashStyleDashDotDot
			;? 5: DashStyleCustom
	GetDashStyle() {
		Local

		if (status := DllCall("Gdiplus\GdipGetPenDashStyle", "Ptr", this.Ptr, "Float*", dashStyle := 0, "Int")) {
			throw (Exception(FormatStatus(status)))
		}

		return (dashStyle)
	}

	PenType[] {
		Get {
			return (this.GetPenType())
		}
	}

	;* pen.GetPenType()
	;* Return:
		;* penType:  ;: https://docs.microsoft.com/en-us/windows/win32/api/gdiplusenums/ne-gdiplusenums-pentype
			;? 0: PenTypeSolidColor
			;? 1: PenTypeHatchFill
			;? 2: PenTypeTextureFill
			;? 3: PenTypePathGradient
			;? 4: PenTypeLinearGradient
			;? -1: PenTypeUnknown
	GetPenType() {
		Local

		if (status := DllCall("Gdiplus\GdipGetPenFillType", "Ptr", this.Ptr, "Int*", penType := 0, "Int")) {
			throw (Exception(FormatStatus(status)))
		}

		return (penType)
	}

	StartCap[] {
		Get {
			return (this.GetStartCap())
		}
	}

	;* pen.GetStartCap()
	;* Return:
		;* lineCap:  ;: https://docs.microsoft.com/en-us/windows/win32/api/gdiplusenums/ne-gdiplusenums-linecap
			;? 0x00: LineCapFlat
			;? 0x01: LineCapSquare
			;? 0x02: LineCapRound
			;? 0x03: LineCapTriangle
			;? 0x10: LineCapNoAnchor
			;? 0x11: LineCapSquareAnchor
			;? 0x12: LineCapRoundAnchor
			;? 0x13: LineCapDiamondAnchor
			;? 0x14: LineCapArrowAnchor
			;? 0xFF: LineCapCustom
			;? 0xF0: LineCapAnchorMask
	GetStartCap() {
		Local

		if (status := DllCall("Gdiplus\GdipGetPenStartCap", "Ptr", this.Ptr, "UInt*", lineCap := 0, "Int")) {
			throw (Exception(FormatStatus(status)))
		}

		return (Format("0x{:02X}", lineCap))
	}

	EndCap[] {
		Get {
			return (this.GetEndCap())
		}
	}

	GetEndCap() {
		Local

		if (status := DllCall("Gdiplus\GdipGetPenEndCap", "Ptr", this.Ptr, "UInt*", lineCap := 0, "Int")) {
			throw (Exception(FormatStatus(status)))
		}

		return (Format("0x{:02X}", lineCap))
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

		if (status := DllCall("Gdiplus\GdipGetPenTransform", "Ptr", this.Ptr, "Ptr*", pMatrix := 0, "Int")) {
			throw (Exception(FormatStatus(status)))
		}

		return (pMatrix)
	}

	SetTransform(matrix) {
		Local

		if (status := DllCall("Gdiplus\GdipSetPenTransform", "Ptr", this.Ptr, "Ptr", matrix.Ptr, "Int")) {
			throw (Exception(FormatStatus(status)))
		}

		return (True)
	}

	;--------------- Method -------------------------------------------------------;

	Clone() {
		Local

		if (status := DllCall("Gdiplus\GdipClonePen", "Ptr", this.Ptr, "Ptr*", pPen := 0, "Int")) {
			throw (Exception(FormatStatus(status)))
		}

		return ({"Ptr": pPen
			, "Base": this.Base})
	}

	;-----------------------------------------------------  Transform  -------------;

	TranslateTransform(x, y, matrixOrder := 0) {
		Local

		if (status := DllCall("Gdiplus\GdipTranslatePenTransform", "Ptr", this.Ptr, "Float", x, "Float", y, "Int", matrixOrder, "Int")) {
			throw (Exception(FormatStatus(status)))
		}

		return (True)
	}

	RotateTransform(angle, matrixOrder := 0) {
		Local

		if (status := DllCall("Gdiplus\GdipRotatePenTransform", "Ptr", this.Ptr, "Float", angle, "Int", matrixOrder, "Int")) {
			throw (Exception(FormatStatus(status)))
		}

		return (True)
	}

	MultiplyTransform(matrix, matrixOrder := 0) {
		Local

		if (status := DllCall("Gdiplus\GdipMultiplyPenTransform", "Ptr", this.Ptr, "Ptr", matrix.Handle, "Int", matrixOrder, "Int")) {
			throw (Exception(FormatStatus(status)))
		}

		return (True)
	}

	ScaleTransform(x, y, matrixOrder := 0) {
		Local

		if (status := DllCall("Gdiplus\GdipScalePenTransform", "Ptr", this.Ptr, "Float", x, "Float", y, "Int", matrixOrder, "Int")) {
			throw (Exception(FormatStatus(status)))
		}

		return (True)
	}

	ResetTransform() {
		Local

		if (status := DllCall("Gdiplus\GdipResetPenTransform", "Ptr", this.Ptr, "Int")) {
			throw (Exception(FormatStatus(status)))
		}

		return (True)
	}
}