﻿/*
* MIT License
*
* Copyright (c) 2021 Onimuru
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in all
* copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
* SOFTWARE.
*/

/*
;* enum DashCap  ;: https://docs.microsoft.com/en-us/windows/win32/api/gdiplusenums/ne-gdiplusenums-dashcap
	0 = DashCapFlat
	2 = DashCapRound
	3 = DashCapTriangle

;* enum DashStyle  ;: https://docs.microsoft.com/en-us/windows/win32/api/gdiplusenums/ne-gdiplusenums-dashstyle
	0 = DashStyleSolid
	1 = DashStyleDash
	2 = DashStyleDot
	3 = DashStyleDashDot
	4 = DashStyleDashDotDot
	5 = DashStyleCustom

;* enum LineCap  ;: https://docs.microsoft.com/en-us/windows/win32/api/gdiplusenums/ne-gdiplusenums-linecap
	0x00 = LineCapFlat
	0x01 = LineCapSquare
	0x02 = LineCapRound
	0x03 = LineCapTriangle
	0x10 = LineCapNoAnchor
	0x11 = LineCapSquareAnchor
	0x12 = LineCapRoundAnchor
	0x13 = LineCapDiamondAnchor
	0x14 = LineCapArrowAnchor
	0xFF = LineCapCustom
	0xF0 = LineCapAnchorMask

;* enum PenAlignment  ;: https://docs.microsoft.com/en-us/windows/win32/api/gdiplusenums/ne-gdiplusenums-penalignment
	0 = PenAlignmentCenter - Specifies that the pen is aligned on the center of the line that is drawn.
	1 = PenAlignmentInset - Specifies, when drawing a polygon, that the pen is aligned on the inside of the edge of the polygon.

;* enum PenType  ;: https://docs.microsoft.com/en-us/windows/win32/api/gdiplusenums/ne-gdiplusenums-pentype
	0 = PenTypeSolidColor
	1 = PenTypeHatchFill
	2 = PenTypeTextureFill
	3 = PenTypePathGradient
	4 = PenTypeLinearGradient
	-1 = PenTypeUnknown

;* enum Unit  ;: https://docs.microsoft.com/en-us/windows/win32/api/gdiplusenums/ne-gdiplusenums-unit
	0 = UnitWorld - World coordinate (non-physical unit).
	1 = UnitDisplay - Variable (only for PageTransform).
	2 = UnitPixel - Each unit is one device pixel.
	3 = UnitPoint - Each unit is a printer's point, or 1/72 inch.
	4 = UnitInch
	5 = UnitDocument - Each unit is 1/300 inch.
*/

;* GDIp.CreatePen(color[, width, unit])
;* Parameter:
	;* [Integer] color
	;* [Float] width
	;* [Integer] unit - See Unit enumeration.
;* Return:
	;* [Pen]
static CreatePen(color, width := 1, unit := 2) {
	if (status := DllCall("Gdiplus\GdipCreatePen1", "UInt", color, "Float", width, "Int", unit, "Ptr*", &(pPen := 0), "Int")) {
		throw (ErrorFromStatus(status))
	}

	return (this.Pen(pPen))
}

;* GDIp.CreatePenFromBrush(brush[, width, unit])
;* Parameter:
	;* [Brush] brush
	;* [Float] width
	;* [Integer] unit - See Unit enumeration.
;* Return:
	;* [Pen]
static CreatePenFromBrush(brush, width := 1, unit := 2) {
	if (status := DllCall("Gdiplus\GdipCreatePen2", "Ptr", brush, "Float", width, "Int", 2, "Ptr*", &(pPen := 0), "Int", unit, "Int")) {
		throw (ErrorFromStatus(status))
	}

	return (this.Pen(pPen))
}

class Pen {
	Class := "Pen"

	__New(pPen) {
		this.Ptr := pPen
	}

	;* pen.Clone()
	;* Return:
		;* [Pen]
	Clone() {
		if (status := DllCall("Gdiplus\GdipClonePen", "Ptr", this.Ptr, "Ptr*", &(pPen := 0), "Int")) {
			throw (ErrorFromStatus(status))
		}

		return (GDIp.Pen(pPen))
	}

	__Delete() {
		if (status := DllCall("Gdiplus\GdipDeletePen", "Ptr", this.Ptr, "Int")) {
			throw (ErrorFromStatus(status))
		}
	}

	;-------------- Property ------------------------------------------------------;

	Type {
		Get {
			return (this.GetType())
		}
	}

	;* pen.GetType()
	;* Return:
		;* [Integer] - See PenType enumeration.
	GetType() {
		if (status := DllCall("Gdiplus\GdipGetPenFillType", "Ptr", this.Ptr, "Int*", &(type := 0), "Int")) {
			throw (ErrorFromStatus(status))
		}

		return (type)
	}

	Color {
		Get {
			return (this.GetColor())
		}

		Set {
			this.SetColor(value)

			return (value)
		}
	}

	;* pen.GetColor()
	;* Return:
		;* [Integer]
	GetColor() {
		if (status := DllCall("Gdiplus\GdipGetPenColor", "Ptr", this.Ptr, "UInt*", &(color := 0), "Int")) {  ;* `GetColor()` throws an exception if the Pen object inherited it's color from a LineBrush object.
			throw (ErrorFromStatus(status))
		}

		return (color)
	}

	;* pen.SetColor(color)
	;* Parameter:
		;* [Integer] color
	SetColor(color) {
		if (status := DllCall("Gdiplus\GdipSetPenColor", "Ptr", this.Ptr, "UInt", color, "Int")) {
			throw (ErrorFromStatus(status))
		}
	}

	Width {
		Get {
			return (this.GetWidth())
		}

		Set {
			this.SetWidth(value)

			return (value)
		}
	}

	;* pen.GetWidth()
	;* Return:
		;* [Float]
	GetWidth() {
		if (status := DllCall("Gdiplus\GdipGetPenWidth", "Ptr", this.Ptr, "Float*", &(width := 0), "Int")) {
			throw (ErrorFromStatus(status))
		}

		return (width)
	}

	;* pen.SetWidth(width)
	;* Parameter:
		;* [Float] width
	SetWidth(width) {
		if (status := DllCall("Gdiplus\GdipSetPenWidth", "Ptr", this.Ptr, "Float", width, "Int")) {
			throw (ErrorFromStatus(status))
		}
	}

	Unit {
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
		;* [Integer] - See Unit enumeration.
	GetUnit() {
		if (status := DllCall("Gdiplus\GdipGetPenUnit", "Ptr", this.Ptr, "Int*", &(unit := 0), "Int")) {
			throw (ErrorFromStatus(status))
		}

		return (unit)
	}

	;* pen.SetUnit(unit)
	;* Parameter:
		;* [Integer] unit - See Unit enumeration.
	SetUnit(unit) {
		if (status := DllCall("Gdiplus\GdipSetPenUnit", "Ptr", this.Ptr, "Int", unit, "Int")) {
			throw (ErrorFromStatus(status))
		}
	}

	Brush {
		Get {
			return (this.GetBrush())
		}

		Set {
			this.SetBrush(value)

			return (value)
		}
	}

	;* pen.GetBrush()
	;* Description:
		;* Gets the brush object that is currently set for this pen object.
	;* Return:
		;* [Brush]
	GetBrush() {
		if (status := DllCall("Gdiplus\GdipGetPenBrushFill", "Ptr", this.Ptr, "Ptr*", &(pBrush := 0), "Int")) {
			throw (ErrorFromStatus(status))
		}

		if (status := DllCall("Gdiplus\GdipGetBrushType", "Ptr", pBrush, "Int*", &(type := 0), "Int")) {
			throw (ErrorFromStatus(status))
		}

		switch (type) {
			case 0: instance := GDIp.SolidBrush(pBrush)
			case 1: instance := GDIp.HatchBrush(pBrush)
			case 2: instance := GDIp.TextureBrush(pBrush)
			case 3: instance := GDIp.PathBrush(pBrush)
			case 4: instance := GDIp.LinearBrush(pBrush)
		}

		return (instance)
	}

	;* pen.SetBrush(brush)
	;* Parameter:
		;* [Brush] brush
	SetBrush(brush) {
		if (status := DllCall("Gdiplus\GdipSetPenBrushFill", "Ptr", this.Ptr, "Ptr", brush, "Int")) {
			throw (ErrorFromStatus(status))
		}
	}

	Alignment {
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
		;* [Integer] - See PenAlignment enumeration.
	GetAlignment() {
		if (status := DllCall("Gdiplus\GdipGetPenMode", "Ptr", this.Ptr, "Int*", &(alignment := 0), "Int")) {
			throw (ErrorFromStatus(status))
		}

		return (alignment)
	}

	;* pen.SetAlignment(alignment)
	;* Parameter:
		;* [Integer] alignment - See PenAlignment enumeration.
	;* Note:
		  ;~ If you set the alignment to `PenAlignmentInset`, you cannot use that pen to draw compound lines or triangular dash caps.
	SetAlignment(alignment) {
		if (status := DllCall("Gdiplus\GdipSetPenMode", "Ptr", this.Ptr, "Int", alignment, "Int")) {
			throw (ErrorFromStatus(status))
		}
	}

	;* pen.SetCompoundArray(compoundArray)
	;* Parameter:
		;* [Array] compoundArray
	;* Note:
		;~ If you set the alignment to `PenAlignmentInset`, you cannot use that pen to draw compound lines.
	SetCompoundArray(compoundArray) {
		for index, number in (compounds := Structure((length := compoundArray.Length)*4), compoundArray) {
			compounds.NumPut(index*4, "Float", number)
		}

		if (status := DllCall("Gdiplus\GdipSetPenCompoundArray", "Ptr", this.Ptr, "Ptr", compounds.Ptr, "Int", length, "Int")) {
			throw (ErrorFromStatus(status))
		}
	}

	CompoundCount {
		Get {
			return (this.GetCompoundCount())
		}
	}

	;* pen.GetCompoundCount()
	;* Return:
		;* [Integer]
	GetCompoundCount() {
		if (status := DllCall("Gdiplus\GdipGetPenCompoundCount", "Ptr", this.Ptr, "Int*", &(compoundCount := 0), "Int")) {
			throw (ErrorFromStatus(status))
		}

		return (compoundCount)
	}

	StartCap {
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
		;* [Integer] - See LineCap enumeration.
	GetStartCap() {
		if (status := DllCall("Gdiplus\GdipGetPenStartCap", "Ptr", this.Ptr, "UInt*", &(lineCap := 0), "Int")) {
			throw (ErrorFromStatus(status))
		}

		return (Format("0x{:02X}", lineCap))
	}

	;* pen.SetStartCap(lineCap)
	;* Parameter:
		;* [Integer] lineCap - See LineCap enumeration.
	SetStartCap(lineCap) {
		if (status := DllCall("Gdiplus\GdipSetPenStartCap", "Ptr", this.Ptr, "UInt", lineCap, "Int")) {
			throw (ErrorFromStatus(status))
		}
	}

	EndCap {
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
		;* [Integer] - See LineCap enumeration.
	GetEndCap() {
		if (status := DllCall("Gdiplus\GdipGetPenEndCap", "Ptr", this.Ptr, "UInt*", &(lineCap := 0), "Int")) {
			throw (ErrorFromStatus(status))
		}

		return (Format("0x{:02X}", lineCap))
	}

	;* pen.SetEndCap(lineCap)
	;* Parameter:
		;* [Integer] lineCap - See LineCap enumeration.
	SetEndCap(lineCap) {
		if (status := DllCall("Gdiplus\GdipSetPenEndCap", "Ptr", this.Ptr, "UInt", lineCap, "Int")) {
			throw (ErrorFromStatus(status))
		}
	}

	DashCap {
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
		;* [Integer] - See DashCap enumeration.
	GetDashCap() {
		if (status := DllCall("Gdiplus\GdipGetPenDashCap197819", "Ptr", this.Ptr, "Int*", &(dashCap := 0), "Int")) {
			throw (ErrorFromStatus(status))
		}

		return (dashCap)
	}

	;* pen.SetDashCap(dashCap)
	;* Parameter:
		;* [Integer] dashCap - See DashCap enumeration.
	;* Note:
		;~ If you set the alignment to `PenAlignmentInset`, you cannot use that pen to draw triangular dash caps.
	SetDashCap(dashCap) {
		if (status := DllCall("Gdiplus\GdipSetPenDashCap197819", "Ptr", this.Ptr, "Int", dashCap, "Int")) {
			throw (ErrorFromStatus(status))
		}
	}

	;* pen.SetLineCap(startCap, endCap, dashCap)
	;* Parameter:
		;* [Integer] startCap - See LineCap enumeration.
		;* [Integer] endCap - See LineCap enumeration.
		;* [Integer] dashCap - See DashCap enumeration.
	SetLineCap(startCap, endCap, dashCap) {
		if (status := DllCall("Gdiplus\GdipSetPenLineCap197819", "Ptr", this.Ptr, "Int", startCap, "Int", endCap, "Int", dashCap, "Int")) {
			throw (ErrorFromStatus(status))
		}
	}

	DashOffset {
		Get {
			return (this.GetDashOffset())
		}

		Set {
			this.SetDashOffset(value)

			return (value)
		}
	}

	;* pen.GetDashOffset()
	;* Return:
		;* [Float]
	GetDashOffset() {
		if (status := DllCall("Gdiplus\GdipGetPenDashOffset", "Ptr", this.Ptr, "Float*", &(dashOffset := 0), "Int")) {
			throw (ErrorFromStatus(status))
		}

		return (dashOffset)
	}

	;* pen.SetDashOffset(dashOffset)
	;* Parameter:
		;* [Float] dashOffset
	SetDashOffset(dashOffset) {
		if (status := DllCall("Gdiplus\GdipSetPenDashOffset", "Ptr", this.Ptr, "Float", dashOffset, "Int")) {
			throw (ErrorFromStatus(status))
		}
	}

	DashStyle {
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
		;* [Integer] - See DashStyle enumeration.
	GetDashStyle() {
		if (status := DllCall("Gdiplus\GdipGetPenDashStyle", "Ptr", this.Ptr, "Int*", &(dashStyle := 0), "Int")) {
			throw (ErrorFromStatus(status))
		}

		return (dashStyle)
	}

	;* pen.SetDashStyle(dashStyle)
	;* Parameter:
		;* [Integer] dashStyle - See DashStyle enumeration.
	SetDashStyle(dashStyle) {
		if (status := DllCall("Gdiplus\GdipSetPenDashStyle", "Ptr", this.Ptr, "Int", dashStyle, "Int")) {
			throw (ErrorFromStatus(status))
		}
	}

	;--------------- Method -------------------------------------------------------;
	;-----------------------------------------------------  Transform  -------------;

	;* pen.GetTransform()
	;* Return:
		;* [Matrix]
	GetTransform() {
		if (status := DllCall("Gdiplus\GdipGetPenTransform", "Ptr", this.Ptr, "Ptr*", &(pMatrix := 0), "Int")) {
			throw (ErrorFromStatus(status))
		}

		return (GDIp.Matrix(pMatrix))
	}

	;* pen.SetTransform(matrix)
	;* Parameter:
		;* [Matrix] matrix
	SetTransform(matrix) {
		if (status := DllCall("Gdiplus\GdipSetPenTransform", "Ptr", this.Ptr, "Ptr", matrix, "Int")) {
			throw (ErrorFromStatus(status))
		}
	}

	;* pen.TranslateTransform(x, y[, matrixOrder])
	;* Parameter:
		;* [Float] x
		;* [Float] y
		;* [Integer] matrixOrder
	TranslateTransform(x, y, matrixOrder := 0) {
		if (status := DllCall("Gdiplus\GdipTranslatePenTransform", "Ptr", this.Ptr, "Float", x, "Float", y, "Int", matrixOrder, "Int")) {
			throw (ErrorFromStatus(status))
		}
	}

	;* pen.RotateTransform(angle[, matrixOrder])
	;* Parameter:
		;* [Float] angle
		;* [Integer] matrixOrder
	RotateTransform(angle, matrixOrder := 0) {
		if (status := DllCall("Gdiplus\GdipRotatePenTransform", "Ptr", this.Ptr, "Float", angle, "Int", matrixOrder, "Int")) {
			throw (ErrorFromStatus(status))
		}
	}

	;* pen.MultiplyTransform(matrix[, matrixOrder])
	;* Parameter:
		;* [Matrix] matrix
		;* [Integer] matrixOrder
	MultiplyTransform(matrix, matrixOrder := 0) {
		if (status := DllCall("Gdiplus\GdipMultiplyPenTransform", "Ptr", this.Ptr, "Ptr", matrix, "Int", matrixOrder, "Int")) {
			throw (ErrorFromStatus(status))
		}
	}

	;* pen.ScaleTransform(x, y[, matrixOrder])
	;* Parameter:
		;* [Float] x
		;* [Float] y
		;* [Integer] matrixOrder
	ScaleTransform(x, y, matrixOrder := 0) {
		if (status := DllCall("Gdiplus\GdipScalePenTransform", "Ptr", this.Ptr, "Float", x, "Float", y, "Int", matrixOrder, "Int")) {
			throw (ErrorFromStatus(status))
		}
	}

	;* pen.ResetTransform()
	ResetTransform() {
		if (status := DllCall("Gdiplus\GdipResetPenTransform", "Ptr", this.Ptr, "Int")) {
			throw (ErrorFromStatus(status))
		}
	}
}