/*
;* DashCap enum (https://docs.microsoft.com/en-us/windows/win32/api/gdiplusenums/ne-gdiplusenums-dashcap)
	;? 0 = DashCapFlat
	;? 2 = DashCapRound
	;? 3 = DashCapTriangle

;* DashStyle enum (https://docs.microsoft.com/en-us/windows/win32/api/gdiplusenums/ne-gdiplusenums-dashstyle)
	;? 0 = DashStyleSolid
	;? 1 = DashStyleDash
	;? 2 = DashStyleDot
	;? 3 = DashStyleDashDot
	;? 4 = DashStyleDashDotDot
	;? 5 = DashStyleCustom

;* LineCap enumeration (https://docs.microsoft.com/en-us/windows/win32/api/gdiplusenums/ne-gdiplusenums-linecap)
	;? 0x00 = LineCapFlat
	;? 0x01 = LineCapSquare
	;? 0x02 = LineCapRound
	;? 0x03 = LineCapTriangle
	;? 0x10 = LineCapNoAnchor
	;? 0x11 = LineCapSquareAnchor
	;? 0x12 = LineCapRoundAnchor
	;? 0x13 = LineCapDiamondAnchor
	;? 0x14 = LineCapArrowAnchor
	;? 0xFF = LineCapCustom
	;? 0xF0 = LineCapAnchorMask

;* PenAlignment enumeration (https://docs.microsoft.com/en-us/windows/win32/api/gdiplusenums/ne-gdiplusenums-penalignment)
	;? 0 = PenAlignmentCenter - Specifies that the pen is aligned on the center of the line that is drawn.
	;? 1 = PenAlignmentInset - Specifies, when drawing a polygon, that the pen is aligned on the inside of the edge of the polygon.

;* PenType enumeration (https://docs.microsoft.com/en-us/windows/win32/api/gdiplusenums/ne-gdiplusenums-pentype)
	;? 0 = PenTypeSolidColor
	;? 1 = PenTypeHatchFill
	;? 2 = PenTypeTextureFill
	;? 3 = PenTypePathGradient
	;? 4 = PenTypeLinearGradient
	;? -1 = PenTypeUnknown

;* Unit enumeration (https://docs.microsoft.com/en-us/windows/win32/api/gdiplusenums/ne-gdiplusenums-unit)
	;? 0 = UnitWorld - World coordinate (non-physical unit).
	;? 1 = UnitDisplay - Variable (only for PageTransform).
	;? 2 = UnitPixel - Each unit is one device pixel.
	;? 3 = UnitPoint - Each unit is a printer's point, or 1/72 inch.
	;? 4 = UnitInch
	;? 5 = UnitDocument - Each unit is 1/300 inch.
*/

;* GDIp.CreatePen(color[, width, unit])
;* Parameter:
	;* unit - See Unit enumeration.
CreatePen(color, width := 1, unit := 2) {
	Local

	if (status := DllCall("Gdiplus\GdipCreatePen1", "UInt", color, "Float", width, "Int", unit, "Ptr*", pPen := 0, "Int")) {
		throw (Exception(FormatStatus(status)))
	}

	return ({"Ptr": pPen
		, "Base": this.__Pen})
}

;* GDIp.CreatePenFromBrush([__Brush] brush[, width, unit])
;* Parameter:
	;* unit - See Unit enumeration.
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
		if (!this.HasKey("Ptr")) {
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

	SetColor(color) {
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

	SetWidth(width) {
		Local

		if (status := DllCall("Gdiplus\GdipSetPenWidth", "Ptr", this.Ptr, "Float", width, "Int")) {
			throw (Exception(FormatStatus(status)))
		}

		return (True)
	}

	Unit[] {
		Get {
			return (this.GetUnit())
		}

		Set {
			this.SetUnit(value)

			return (value)
		}
	}

	;* pen.GetUnit()
	;* Return:
		;* * - See Unit enumeration.
	GetUnit() {
		Local

		if (status := DllCall("Gdiplus\GdipGetPenUnit", "Ptr", this.Ptr, "Int*", unit := 0, "Int")) {
			throw (Exception(FormatStatus(status)))
		}

		return (unit)
	}

	;* pen.SetUnit()
	;* Parameter:
		;* unit - See Unit enumeration.
	SetUnit(unit) {
		Local

		if (status := DllCall("Gdiplus\GdipSetPenUnit", "Ptr", this.Ptr, "Int", unit, "Int")) {
			throw (Exception(FormatStatus(status)))
		}

		return (True)
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

		if (status := DllCall("Gdiplus\GdipGetBrushType", "Ptr", pBrush, "Int*", type := 0, "Int")) {
			throw (Exception(FormatStatus(status)))
		}

		return ({"Ptr": pBrush
			, "Base": (type == 0) ? (GDIp.__SolidBrush) : ((type == 1) ? (GDIp.__HatchBrush) : ((type == 2) ? (GDIp.__TextureBrush) : ((type == 3) ? (GDIp.__PathBrush) : (GDIp.__LinearBrush))))})

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

	Type[] {
		Get {
			return (this.GetType())
		}
	}

	;* pen.GetType()
	;* Return:
		;* * - See PenType enumeration.
	GetType() {
		Local

		if (status := DllCall("Gdiplus\GdipGetPenFillType", "Ptr", this.Ptr, "Int*", type := 0, "Int")) {
			throw (Exception(FormatStatus(status)))
		}

		return (type)
	}

	Alignment[] {
		Get {
			return (this.GetAlignment())
		}

		Set {
			this.SetAlignment(value)

			return (value)
		}
	}

	;* pen.GetAlignment()
	;* Return:
		;* * - See PenAlignment enumeration.
	GetAlignment() {
		Local

		if (status := DllCall("Gdiplus\GdipGetPenMode", "Ptr", this.Ptr, "Int*", alignment := 0, "Int")) {  ;* If you set the alignment of a Pen object to Inset, you cannot use that pen to draw compound lines or triangular dash caps.
			throw (Exception(FormatStatus(status)))
		}

		return (alignment)
	}

	;* pen.SetAlignment()
	;* Parameter:
		;* alignment - See PenAlignment enumeration.
	SetAlignment(alignment) {
		Local

		if (status := DllCall("Gdiplus\GdipSetPenMode", "Ptr", this.Ptr, "Int", alignment, "Int")) {
			throw (Exception(FormatStatus(status)))
		}

		return (True)
	}

	SetCompoundArray(compoundArray) {
		s := compoundArray.Length

		for i, v in (compoundArray, compunds := new Structure(s*4)) {
			compunds.NumPut(i*4, "Float", v)
		}

		if (status := DllCall("Gdiplus\GdipSetPenCompoundArray", "Ptr", this.Ptr, "Ptr", compunds.Ptr, "Int", s, "Int")) {  ;* If you set the alignment of a Pen object to PenAlignmentInset, you cannot use that pen to draw compound lines.
			throw (Exception(FormatStatus(status)))
		}

		return (True)
	}

	CompoundCount[] {
		Get {
			return (this.GetCompoundCount())
		}
	}

	GetCompoundCount() {
		Local

		if (status := DllCall("Gdiplus\GdipGetPenCompoundCount", "Ptr", this.Ptr, "Int*", compoundCount := 0, "Int")) {
			throw (Exception(FormatStatus(status)))
		}

		return (compoundCount)
	}

	StartCap[] {
		Get {
			return (this.GetStartCap())
		}

		Set {
			this.SetStartCap(value)

			return (value)
		}
	}

	;* pen.GetStartCap()
	;* Return:
		;* * - See LineCap enumeration.
	GetStartCap() {
		Local

		if (status := DllCall("Gdiplus\GdipGetPenStartCap", "Ptr", this.Ptr, "UInt*", lineCap := 0, "Int")) {
			throw (Exception(FormatStatus(status)))
		}

		return (Format("0x{:02X}", lineCap))
	}

	;* pen.SetStartCap(lineCap)
	;* Parameter:
		;* lineCap - See LineCap enumeration.
	SetStartCap(lineCap) {
		Local

		if (status := DllCall("Gdiplus\GdipSetPenStartCap", "Ptr", this.Ptr, "UInt", lineCap, "Int")) {
			throw (Exception(FormatStatus(status)))
		}

		return (True)
	}

	EndCap[] {
		Get {
			return (this.GetEndCap())
		}

		Set {
			this.SetEndCap(value)

			return (value)
		}
	}

	;* pen.GetEndCap()
	;* Return:
		;* * - See LineCap enumeration.
	GetEndCap() {
		Local

		if (status := DllCall("Gdiplus\GdipGetPenEndCap", "Ptr", this.Ptr, "UInt*", lineCap := 0, "Int")) {
			throw (Exception(FormatStatus(status)))
		}

		return (Format("0x{:02X}", lineCap))
	}

	;* pen.SetEndCap(lineCap)
	;* Parameter:
		;* lineCap - See LineCap enumeration.
	SetEndCap(lineCap) {
		Local

		if (status := DllCall("Gdiplus\GdipSetPenEndCap", "Ptr", this.Ptr, "UInt", lineCap, "Int")) {
			throw (Exception(FormatStatus(status)))
		}

		return (True)
	}

	DashCap[] {
		Get {
			return (this.GetDashCap())
		}

		Set {
			this.SetDashCap(value)

			return (value)
		}
	}

	;* pen.GetDashCap()
	;* Return:
		;* * - See DashCap enumeration.
	GetDashCap() {
		Local

		if (status := DllCall("Gdiplus\GdipGetPenDashCap197819", "Ptr", this.Ptr, "Int*", dashCap := 0, "Int")) {
			throw (Exception(FormatStatus(status)))
		}

		return (dashCap)
	}

	;* pen.SetDashCap(dashCap)
	;* Parameter:
		;* dashCap - See DashCap enumeration.
	SetDashCap(dashCap) {
		Local

		if (status := DllCall("Gdiplus\GdipSetPenDashCap197819", "Ptr", this.Ptr, "Int", dashCap, "Int")) {  ;* If you set the alignment of a Pen object to Pen Alignment Inset, you cannot use that pen to draw triangular dash caps.
			throw (Exception(FormatStatus(status)))
		}

		return (True)
	}

	;* pen.SetLineCap(startCap, endCap, dashCap)
	;* Parameter:
		;* startCap - See LineCap enumeration.
		;* endCap - See LineCap enumeration.
		;* dashCap - See DashCap enumeration.
	SetLineCap(startCap, endCap, dashCap) {
		Local

		if (status := DllCall("Gdiplus\GdipSetPenLineCap197819", "Ptr", this.Ptr, "Int", startCap, "Int", endCap, "Int", dashCap, "Int")) {
			throw (Exception(FormatStatus(status)))
		}

		return (True)
	}

	DashOffset[] {
		Get {
			return (this.GetDashOffset())
		}

		Set {
			this.SetDashOffset(value)

			return (value)
		}
	}

	GetDashOffset() {
		Local

		if (status := DllCall("Gdiplus\GdipGetPenDashOffset", "Ptr", this.Ptr, "Float*", offset := 0, "Int")) {
			throw (Exception(FormatStatus(status)))
		}

		return (offset)
	}

	SetDashOffset(offset) {
		Local

		if (status := DllCall("Gdiplus\GdipSetPenDashOffset", "Ptr", this.Ptr, "Float", offset, "Int")) {
			throw (Exception(FormatStatus(status)))
		}

		return (True)
	}

	DashStyle[] {
		Get {
			return (this.GetDashStyle())
		}

		Set {
			this.SetDashStyle(value)

			return (value)
		}
	}

	;* pen.GetDashStyle()
	;* Return:
		;* * - See DashStyle enumeration.
	GetDashStyle() {
		Local

		if (status := DllCall("Gdiplus\GdipGetPenDashStyle", "Ptr", this.Ptr, "Int*", style := 0, "Int")) {
			throw (Exception(FormatStatus(status)))
		}

		return (style)
	}

	;* pen.SetDashStyle()
	;* Parameter:
		;* style - See DashStyle enumeration.
	SetDashStyle(style) {
		Local

		if (status := DllCall("Gdiplus\GdipSetPenDashStyle", "Ptr", this.Ptr, "Int", style, "Int")) {
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

		if (status := DllCall("Gdiplus\GdipGetPenTransform", "Ptr", this.Ptr, "Ptr*", pMatrix := 0, "Int")) {
			throw (Exception(FormatStatus(status)))
		}

		return ({"Ptr": pMatrix
			, "Base": GDIp.__Matrix})
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

		if (status := DllCall("Gdiplus\GdipMultiplyPenTransform", "Ptr", this.Ptr, "Ptr", matrix.Ptr, "Int", matrixOrder, "Int")) {
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