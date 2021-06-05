/*
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
;* enum CompositingMode  ;: https://docs.microsoft.com/en-us/windows/win32/api/gdiplusenums/ne-gdiplusenums-compositingmode
	0 = CompositingModeSourceOver - Specifies that when a color is rendered, it overwrites the background color.
	1 = CompositingModeSourceCopy - Specifies that when a color is rendered, it is blended with the background color. The blend is determined by the alpha component of the color being rendered.

;* enum CompositingQuality  ;: https://docs.microsoft.com/en-us/windows/win32/api/gdiplusenums/ne-gdiplusenums-compositingquality
	0 = CompositingQualityDefault
	1 = CompositingQualityHighSpeed
	2 = CompositingQualityHighQuality
	3 = CompositingQualityGammaCorrected
	4 = CompositingQualityAssumeLinear

;* enum FillMode  ;: https://docs.microsoft.com/en-us/windows/win32/api/gdiplusenums/ne-gdiplusenums-fillmode
	0 = FillModeAlternate
	1 = FillModeWinding

;* enum FlushIntention  ;: https://docs.microsoft.com/en-us/windows/win32/api/gdiplusenums/ne-gdiplusenums-flushintention
	0 = FlushIntentionFlush - Flush all batched rendering operations and return immediately.
	1 = FlushIntentionSync - Flush all batched rendering operations and wait for them to complete.

;* enum InterpolationMode  ;: https://docs.microsoft.com/en-us/windows/win32/api/gdiplusenums/ne-gdiplusenums-interpolationmode
	0 = InterpolationModeDefault
	1 = InterpolationModeLowQuality
	2 = InterpolationModeHighQuality
	3 = InterpolationModeBilinear
	4 = InterpolationModeBicubic
	5 = InterpolationModeNearestNeighbor
	6 = InterpolationModeHighQualityBilinear
	7 = InterpolationModeHighQualityBicubic

;* enum MatrixOrder  ;: https://docs.microsoft.com/en-us/windows/win32/api/gdiplusenums/ne-gdiplusenums-matrixorder
	0 = MatrixOrderPrepend
	1 = MatrixOrderAppend

;* enum PixelOffsetMode  ;: https://docs.microsoft.com/en-us/windows/win32/api/gdiplusenums/ne-gdiplusenums-pixeloffsetmode
	-1 = PixelOffsetModeInvalid
	0 = PixelOffsetModeDefault - Equivalent to `PixelOffsetModeNone`.
	1 = PixelOffsetModeHighSpeed - Equivalent to `PixelOffsetModeNone`.
	2 = PixelOffsetModeHighQuality - Equivalent to `PixelOffsetModeHalf`.
	3 = PixelOffsetModeNone - Indicates that pixel centers have integer coordinates.
	4 = PixelOffsetModeHalf - Indicates that pixel centers have coordinates that are half way between integer values.

;* enum SmoothingMode  ;: https://docs.microsoft.com/en-us/windows/win32/api/gdiplusenums/ne-gdiplusenums-smoothingmode
	0 = SmoothingModeDefault
	1 = SmoothingModeHighSpeed
	2 = SmoothingModeHighQuality
	3 = SmoothingModeNone
	4 = SmoothingModeAntiAlias

;* enum TextRenderingHint  ;: https://docs.microsoft.com/en-us/windows/win32/api/gdiplusenums/ne-gdiplusenums-textrenderinghint
	0 = TextRenderingHintSystemDefault
	1 = TextRenderingHintSingleBitPerPixelGridFit
	2 = TextRenderingHintSingleBitPerPixel
	3 = TextRenderingHintAntiAliasGridFit
	4 = TextRenderingHintAntiAlias
	5 = TextRenderingHintClearTypeGridFit

;* enum Unit  ;: https://docs.microsoft.com/en-us/windows/win32/api/gdiplusenums/ne-gdiplusenums-unit
	0 = UnitWorld - World coordinate (non-physical unit).
	1 = UnitDisplay - Variable (only for PageTransform).
	2 = UnitPixel - Each unit is one device pixel.
	3 = UnitPoint - Each unit is a printer's point, or 1/72 inch.
	4 = UnitInch
	5 = UnitDocument - Each unit is 1/300 inch.
	6 = UnitMillimeter
*/

;* GDIp.CreateGraphicsFromDC(DC)
;* Parameter:
	;* [DC] DC
;* Return:
	;* [Graphics]
static CreateGraphicsFromDC(DC) {
	if (status := DllCall("Gdiplus\GdipCreateFromHDC", "Ptr", DC.Handle, "Ptr*", &(pGraphics := 0), "Int")) {
		throw (ErrorFromStatus(status))
	}

	return (this.Graphics(pGraphics))
}

;* GDIp.CreateGraphicsFromBitmap(bitmap)
;* Parameter:
	;* [Bitmap] bitmap
;* Return:
	;* [Graphics]
static CreateGraphicsFromBitmap(bitmap) {
	if (status := DllCall("Gdiplus\GdipGetImageGraphicsContext", "Ptr", bitmap, "Ptr*", &(pGraphics := 0), "Int")) {
		throw (ErrorFromStatus(status))
	}

	return (this.Graphics(pGraphics))
}

;* GDIp.CreateGraphicsFromWindow(hWnd[, useICM])
;* Parameter:
	;* [Integer] hWnd
	;* [Integer] useICM
;* Return:
	;* [Graphics]
static CreateGraphicsFromWindow(hWnd, useICM := False) {
	if (status := (useICM)
		? (DllCall("Gdiplus\GdipCreateFromHWNDICM", "Ptr", hWnd, "Ptr*", &(pGraphics := 0), "Int"))
		: (DllCall("Gdiplus\GdipCreateFromHWND", "Ptr", hWnd, "Ptr*", &(pGraphics := 0), "Int"))) {
		throw (ErrorFromStatus(status))
	}

	return (this.Graphics(pGraphics))
}

class Graphics {
	Class := "Graphics", States := []

	__New(pGraphics) {
		this.Ptr := pGraphics
	}

	__Delete() {
		if (status := DllCall("Gdiplus\GdipDeleteGraphics", "Ptr", this.Ptr, "Int")) {
			throw (ErrorFromStatus(status))
		}
	}

	;-------------- Property ------------------------------------------------------;

	;* graphics.IsVisiblePoint[x, y]
	;* Parameter:
		;* [Float] x
		;* [Float] y
	;* Return:
		;* [Integer]
	IsVisiblePoint[x, y] {
		Get {
			if (status := DllCall("Gdiplus\GdipIsVisiblePoint", "Ptr", this.Ptr, "Float", x, "Float", y, "Int*", &(bool := 0), "Int")) {
				throw (ErrorFromStatus(status))
			}

			return (bool)
		}
	}

	;* graphics.IsVisibleRect[x, y, width, height]
		;* [Float] x
		;* [Float] y
		;* [Float] width
		;* [Float] height
	;* Return:
		;* [Integer]
	IsVisibleRect[x, y, width, height] {
		Get {
			if (status := DllCall("Gdiplus\GdipIsVisibleRect", "Ptr", this.Ptr, "Float", x, "Float", y, "Float", width, "Float", height, "UInt*", &(bool := 0), "Int")) {
				throw (ErrorFromStatus(status))
			}

			return (bool)
		}
	}

	;* graphics.IsClipEmpty
	;* Return:
		;* [Integer]
	IsClipEmpty {
		Get {
			if (status := DllCall("Gdiplus\GdipIsClipEmpty", "Ptr", this.Ptr, "UInt*", &(bool := 0), "Int")) {
				throw (ErrorFromStatus(status))
			}

			return (bool)
		}
	}

	;* graphics.IsVisibleClipEmpty
	;* Return:
		;* [Integer]
	IsVisibleClipEmpty {
		Get {
			if (status := DllCall("Gdiplus\GdipIsVisibleClipEmpty", "Ptr", this.Ptr, "UInt*", &(bool := 0), "Int")) {
				throw (ErrorFromStatus(status))
			}

			return (bool)
		}
	}

	CompositingMode {
		Get {
			return (this.GetCompositingMode())
		}

		Set {
			this.SetCompositingMode(value)

			return (value)
		}
	}

	;* graphics.GetCompositingMode()
	;* Return:
		;* [Integer] - See CompositingMode enumeration.
	GetCompositingMode() {
		if (status := DllCall("Gdiplus\GdipGetCompositingMode", "Ptr", this.Ptr, "UInt*", &(compositingMode := 0), "Int")) {
			throw (ErrorFromStatus(status))
		}

		return (compositingMode)
	}

	;* graphics.SetCompositingMode(compositingMode)
	;* Parameter:
		;* [Integer] compositingMode - See CompositingMode enumeration.
	SetCompositingMode(compositingMode) {
		if (status := DllCall("Gdiplus\GdipSetCompositingMode", "Ptr", this.Ptr, "UInt", compositingMode, "Int")) {
			throw (ErrorFromStatus(status))
		}
	}

	CompositingQuality {
		Get {
			return (this.GetCompositingQuality())
		}

		Set {
			this.SetCompositingQuality(value)

			return (value)
		}
	}

	;* graphics.GetCompositingQuality()
	;* Return:
		;* [Integer] - See CompositingQuality enumeration.
	GetCompositingQuality() {
		if (status := DllCall("Gdiplus\GdipGetCompositingQuality", "Ptr", this.Ptr, "UInt*", &(compositingQuality := 0), "Int")) {
			throw (ErrorFromStatus(status))
		}

		return (compositingQuality)
	}

	;* graphics.SetCompositingQuality(compositingQuality)
	;* Parameter:
		;* [Integer] compositingQuality - See CompositingQuality enumeration.
	SetCompositingQuality(compositingQuality) {
		if (status := DllCall("Gdiplus\GdipSetCompositingQuality", "Ptr", this.Ptr, "UInt", compositingQuality, "Int")) {
			throw (ErrorFromStatus(status))
		}
	}

	InterpolationMode {
		Get {
			return (this.GetInterpolationMode())
		}

		Set {
			this.SetInterpolationMode(value)

			return (value)
		}
	}

	;* graphics.GetInterpolationMode()
	;* Return:
		;* [Integer] - See InterpolationMode enumeration.
	GetInterpolationMode() {
		if (status := DllCall("Gdiplus\GdipGetInterpolationMode", "Ptr", this.Ptr, "UInt*", &(interpolationMode := 0), "Int")) {
			throw (ErrorFromStatus(status))
		}

		return (interpolationMode)
	}

	;* graphics.SetInterpolationMode(interpolationMode)
	;* Parameter:
		;* [Integer] interpolationMode - See InterpolationMode enumeration.
	SetInterpolationMode(interpolationMode) {
		if (status := DllCall("Gdiplus\GdipSetInterpolationMode", "Ptr", this.Ptr, "UInt", interpolationMode, "Int")) {
			throw (ErrorFromStatus(status))
		}
	}

	PageScale {
		Get {
			return (this.GetPageScale())
		}

		Set {
			this.SetPageScale(value)

			return (value)
		}
	}

	;* graphics.GetPageScale()
	;* Return:
		;* [Float] - The scaling factor for the page transformation of this graphics object.
	GetPageScale() {
		if (status := DllCall("Gdiplus\GdipGetPageScale", "Ptr", this.Ptr, "Float*", &(scale := 0), "Int")) {
			throw (ErrorFromStatus(status))
		}

		return (scale)
	}

	;* graphics.SetPageScale(scale)
	;* Parameter:
		;* [Float] scale - Sets the scaling factor for the page transformation of this graphics object.
	SetPageScale(scale) {
		if (status := DllCall("Gdiplus\GdipSetPageScale", "Ptr", this.Ptr, "Float", scale, "Int")) {
			throw (ErrorFromStatus(status))
		}
	}

	PageUnit {
		Get {
			return (this.GetPageUnit())
		}

		Set {
			this.SetPageUnit(value)

			return (value)
		}
	}

	;* graphics.GetPageUnit()
	;* Return:
		;* [Integer] - See Unit enumeration.
	GetPageUnit() {
		if (status := DllCall("Gdiplus\GdipGetPageUnit", "Ptr", this.Ptr, "Int*", &(unit := 0), "Int")) {
			throw (ErrorFromStatus(status))
		}

		return (unit)
	}

	;* graphics.SetPageUnit(unit)
	;* Parameter:
		;* [Integer] unit - See Unit enumeration.
	SetPageUnit(unit) {
		if (status := DllCall("Gdiplus\GdipSetPageUnit", "Ptr", this.Ptr, "Int", unit, "Int")) {
			throw (ErrorFromStatus(status))
		}
	}

	PixelOffsetMode {
		Get {
			return (this.GetPixelOffsetMode())
		}

		Set {
			this.SetPixelOffsetMode(value)

			return (value)
		}
	}

	;* graphics.GetPixelOffsetMode()
	;* Return:
		;* [Integer] - See PixelOffsetMode enumeration.
	GetPixelOffsetMode() {
		if (status := DllCall("Gdiplus\GdipGetPixelOffsetMode", "Ptr", this.Ptr, "Int*", &(pixelOffsetMode := 0), "Int")) {
			throw (ErrorFromStatus(status))
		}

		return (pixelOffsetMode)
	}

	;* graphics.SetPixelOffsetMode(unit)
	;* Parameter:
		;* [Integer] pixelOffsetMode - See PixelOffsetMode enumeration.
	SetPixelOffsetMode(unit) {
		if (status := DllCall("Gdiplus\GdipSetPixelOffsetMode", "Ptr", this.Ptr, "Int", unit, "Int")) {
			throw (ErrorFromStatus(status))
		}
	}

	RenderingOrigin {
		Get {
			return (this.GetRenderingOrigin())
		}

		Set {
			this.SetRenderingOrigin(value*)

			return (value)
		}
	}

	;* graphics.GetRenderingOrigin()
	;* Return:
		;* [Array]
	GetRenderingOrigin() {
		if (status := DllCall("Gdiplus\GdipGetRenderingOrigin", "Ptr", this.Ptr, "Int*", &(x := 0), "Int*", &(y := 0), "Int")) {
			throw (ErrorFromStatus(status))
		}

		return (Vec2(x, y))
	}

	;* graphics.SetRenderingOrigin(x, y)
	;* Parameter:
		;* [Integer] x
		;* [Integer] y
	SetRenderingOrigin(x, y) {
		if (status := DllCall("Gdiplus\GdipSetRenderingOrigin", "Ptr", this.Ptr, "Int", x, "Int", y, "Int")) {
			throw (ErrorFromStatus(status))
		}
	}

	SmoothingMode {
		Get {
			return (this.GetSmoothingMode())
		}

		Set {
			this.SetSmoothingMode(value)

			return (value)
		}
	}

	;* graphics.GetSmoothingMode()
	;* Return:
		;* [Integer] - See SmoothingMode enumeration.
	GetSmoothingMode() {
		if (status := DllCall("Gdiplus\GdipGetSmoothingMode", "Ptr", this.Ptr, "UInt*", &(smoothingMode := 0), "Int")) {
			throw (ErrorFromStatus(status))
		}

		return (smoothingMode)
	}

	;* graphics.SetSmoothingMode(smoothingMode)
	;* Parameter:
		;* [Integer] smoothingMode - See SmoothingMode enumeration.
	SetSmoothingMode(smoothingMode) {
		if (status := DllCall("Gdiplus\GdipSetSmoothingMode", "Ptr", this.Ptr, "UInt", smoothingMode, "Int")) {
			throw (ErrorFromStatus(status))
		}
	}

	TextContrast {
		Get {
			return (this.GetTextContrast())
		}

		Set {
			this.SetTextContrast(value)

			return (value)
		}
	}

	;* graphics.GetTextContrast()
	;* Return:
		;* [Integer] - A number between 0 and 12, which defines the value of contrast used for antialiasing text.
	GetTextContrast() {
		if (status := DllCall("Gdiplus\GdipGetTextContrast", "Ptr", this.Ptr, "UInt*", &(contrast := 0), "Int")) {
			throw (ErrorFromStatus(status))
		}

		return (contrast)
	}

	;* graphics.SetTextContrast(contrast)
	;* Parameter:
		;* [Integer] contrast - A number between 0 and 12, which defines the value of contrast used for antialiasing text.
	SetTextContrast(contrast) {
		if (status := DllCall("Gdiplus\GdipSetTextContrast", "Ptr", this.Ptr, "UInt", contrast, "Int")) {
			throw (ErrorFromStatus(status))
		}
	}

	TextRenderingHint {
		Get {
			return (this.GetTextRenderingHint())
		}

		Set {
			this.SetTextRenderingHint(value)

			return (value)
		}
	}

	;* graphics.GetTextRenderingHint()
	;* Return:
		;* [Integer] - See TextRenderingHint enumeration.
	GetTextRenderingHint() {
		if (status := DllCall("Gdiplus\GdipGetTextRenderingHint", "Ptr", this.Ptr, "UInt*", &(hint := 0), "Int")) {
			throw (ErrorFromStatus(status))
		}

		return (hint)
	}

	;* graphics.SetTextRenderingHint(hint)
	;* Parameter:
		;* [Integer] hint - See TextRenderingHint enumeration.
	SetTextRenderingHint(hint) {
		if (status := DllCall("Gdiplus\GdipSetTextRenderingHint", "Ptr", this.Ptr, "UInt", hint, "Int")) {
			throw (ErrorFromStatus(status))
		}
	}

	;--------------- Method -------------------------------------------------------;
	;-----------------------------------------------------  Transform  -------------;

	;* graphics.GetTransform()
	;* Return:
		;* [Matrix]
	GetTransform() {
		if (status := DllCall("Gdiplus\GdipGetWorldTransform", "Ptr", this.Ptr, "Ptr*", &(pMatrix := 0), "Int")) {
			throw (ErrorFromStatus(status))
		}

		return (GDIp.Matrix(pMatrix))
	}

	;* graphics.SetTransform(matrix)
	;* Parameter:
		;* [Matrix] matrix
	SetTransform(matrix) {
		if (status := DllCall("Gdiplus\GdipSetWorldTransform", "Ptr", this.Ptr, "Ptr", matrix, "Int")) {
			throw (ErrorFromStatus(status))
		}
	}

	;* graphics.TranslateTransform(x, y[, matrixOrder])
	;* Parameter:
		;* [Float] x
		;* [Float] y
		;* [Integer] matrixOrder - See MatrixOrder enumeration.
	TranslateTransform(x, y, matrixOrder := 0) {
		if (status := DllCall("Gdiplus\GdipTranslateWorldTransform", "Ptr", this.Ptr, "Float", x, "Float", y, "Int", matrixOrder, "Int")) {
			throw (ErrorFromStatus(status))
		}
	}

	;* graphics.RotateTransform(angle[, matrixOrder])
	;* Parameter:
		;* [Float] angle - Angle of rotation (in degrees).
		;* [Integer] matrixOrder - See MatrixOrder enumeration.
	RotateTransform(angle, matrixOrder := 0) {
		if (status := DllCall("Gdiplus\GdipRotateWorldTransform", "Ptr", this.Ptr, "Float", angle, "Int", matrixOrder, "Int")) {
			throw (ErrorFromStatus(status))
		}
	}

	;* graphics.MultiplyTransform(matrix[, matrixOrder])
	;* Parameter:
		;* [Matrix] matrix
		;* [Integer] matrixOrder - See MatrixOrder enumeration.
	MultiplyTransform(matrix, matrixOrder := 0) {
		if (status := DllCall("Gdiplus\GdipMultiplyWorldTransform", "Ptr", this.Ptr, "Ptr", matrix, "Int", matrixOrder, "Int")) {
			throw (ErrorFromStatus(status))
		}
	}

	;* graphics.ScaleTransform(x, y[, matrixOrder])
	;* Parameter:
		;* [Float] x
		;* [Float] y
		;* [Integer] matrixOrder - See MatrixOrder enumeration.
	ScaleTransform(x, y, matrixOrder := 0) {
		if (status := DllCall("Gdiplus\GdipScaleWorldTransform", "Ptr", this.Ptr, "Float", x, "Float", y, "Int", matrixOrder, "Int")) {
			throw (ErrorFromStatus(status))
		}
	}

	;* graphics.ResetTransform()
	ResetTransform() {
		if (status := DllCall("Gdiplus\GdipResetWorldTransform", "Ptr", this.Ptr, "Int")) {
			throw (ErrorFromStatus(status))
		}
	}

	;* graphics.ResetPageTransform()
	ResetPageTransform() {
		if (status := DllCall("Gdiplus\GdipResetPageTransform", "Ptr", this.Ptr, "Int")) {
			throw (ErrorFromStatus(status))
		}
	}

	;------------------------------------------------------  Control  --------------;

	;* graphics.Flush(intention)
	;* Parameter:
		;* [Integer] intention - Element that specifies whether pending operations are flushed immediately (not executed) or executed as soon as possible. See FlushIntention enumeration.
	Flush(intention) {
		if (status := DllCall("Gdiplus\GdipFlush", "Ptr", this.Ptr, "Int", intention, "Int")) {
			throw (ErrorFromStatus(status))
		}
	}

	;* Note:
		;~ When you call GdipEndContainer, all information blocks placed on the stack (by GdipSaveGraphics or by GdipBeginContainer) after the corresponding call to GdipBeginContainerare removed from the stack. Likewise, when you call GdipRestoreGraphics, all information blocks placed on the stack (by GdipSaveGraphics or by GdipBeginContainer) after the corresponding call to GdipSaveGraphics are removed from the stack.
	Begin(dstRect := unset, srcRect := unset, unit := 2) {
		if (IsSet(dstRect) && IsSet(srcRect)) {
			if (status := DllCall("Gdiplus\GdipBeginContainer", "Ptr", this.Ptr, "Ptr", dstRect, "Ptr", srcRect, "Int", unit, "UInt*", &(state := 0), "Int")) {
				throw (ErrorFromStatus(status))
			}
		}
		else if (status := DllCall("Gdiplus\GdipBeginContainer2", "Ptr", this.Ptr, "UInt*", &(state := 0), "Int")) {
			throw (ErrorFromStatus(status))
		}

		return (state)
	}

	End(state) {
		if (status := DllCall("Gdiplus\GdipEndContainer", "Ptr", this.Ptr, "UInt", state, "Int")) {
			throw (ErrorFromStatus(status))
		}
	}

	;* graphics.Save()
	;* Return:
		;* [Integer]
	Save() {
		if (status := DllCall("Gdiplus\GdipSaveGraphics", "Ptr", this.Ptr, "UInt*", &(state := 0), "Int")) {
			throw (ErrorFromStatus(status))
		}

		this.States.Push(state)
		return (state)
	}

	;* graphics.Restore([state])
	;* Parameter:
		;* [Integer] state
	;* Return:
		;* [Integer]
	Restore(state := unset) {
		if (status := DllCall("Gdiplus\GdipRestoreGraphics", "Ptr", this.Ptr, "UInt", (IsSet(state)) ? (this.States.RemoveAt(this.States.IndexOf(state))) : (this.States.Shift()), "Int")) {
			throw (ErrorFromStatus(status))
		}

		return (state)
	}

	;* graphics.Clear([color])
	;* Parameter:
		;* [Integer] color
	Clear(color := 0x00000000) {
		if (status := DllCall("Gdiplus\GdipGraphicsClear", "Ptr", this.Ptr, "UInt", color, "Int")) {
			throw (ErrorFromStatus(status))
		}
	}

	;-------------------------------------------------------  Image  ---------------;

	;* graphics.DrawImage(bitmap[, x, y])
	;* Parameter:
		;* [Bitmap] bitmap
		;* [Float] x
		;* [Float] y
	DrawImage(bitmap, x := 0, y := 0) {
		if (status := DllCall("Gdiplus\GdipDrawImage", "Ptr", this.Ptr, "Ptr", bitmap, "Float", x, "Float", y, "Int")) {
			throw (ErrorFromStatus(status))
		}
	}

	;* graphics.DrawImageFX(bitmap, matrix, effect[, x, y, width, height, imageAttributes, unit])
	;* Parameter:
		;* [Bitmap] bitmap
		;* [Matrix] matrix
		;* [Effect] effect
		;* [Float] x
		;* [Float] y
		;* [Float] width
		;* [Float] height
		;* [Imageattributes] imageAttributes
		;* [Integer] unit - See Unit enumeration.
	DrawImageFX(bitmap, matrix, effect, x := unset, y := unset, width := unset, height := unset, imageAttributes := 0, unit := 2) {
		if (IsSet(x) && IsSet(y) && IsSet(width) && IsSet(height)) {
			static rect := Structure.CreateRect(0, 0, 0, 0, "Float")

			rect.NumPut(0, "Float", x, "Float", y, "Float", width, "Float", height)

			if (status := DllCall("Gdiplus\GdipDrawImageFX", "Ptr", this.Ptr, "Ptr", bitmap, "Ptr", rect, "Ptr", matrix, "Ptr", effect, "Ptr", imageAttributes, "Int", unit, "Int")) {
				throw (ErrorFromStatus(status))
			}
		}
		else if (status := DllCall("Gdiplus\GdipDrawImageFX", "Ptr", this.Ptr, "Ptr", bitmap, "Ptr", 0, "Ptr", matrix, "Ptr", effect, "Ptr", imageAttributes, "Int", unit, "Int")) {
			throw (ErrorFromStatus(status))
		}
	}

	;* graphics.DrawImageRect(bitmap, x, y, width, height)
	;* Parameter:
		;* [Bitmap] bitmap
		;* [Float] x
		;* [Float] y
		;* [Float] width
		;* [Float] height
	DrawImageRect(bitmap, x, y, width, height) {
		if (status := DllCall("Gdiplus\GdipDrawImageRect", "Ptr", this.Ptr, "Ptr", bitmap, "Float", x, "Float", y, "Float", width, "Float", height, "Int")) {
			throw (ErrorFromStatus(status))
		}
	}

	;* graphics.DrawImageRectRect(bitmap, dx, dy, dWidth, dHeight, sx, sy, sWidth, sHeight[, imageAttributes, unit])
	;* Parameter:
		;* [Bitmap] bitmap
		;* [Float] dx
		;* [Float] dy
		;* [Float] dWidth
		;* [Float] dHeight
		;* [Float] sx
		;* [Float] sy
		;* [Float] sWidth
		;* [Float] sHeight
		;* [ImageAttributes] imageAttributes
		;* [Integer] unit - See Unit enumeration.
	DrawImageRectRect(bitmap, dx, dy, dWidth, dHeight, sx, sy, sWidth, sHeight, imageAttributes := 0, unit := 2) {
		if (status := DllCall("Gdiplus\GdipDrawImageRectRect", "Ptr", this.Ptr, "Ptr", bitmap, "Float", dx, "Float", dy, "Float", dWidth, "Float", dHeight, "Float", sx, "Float", sy, "Float", sWidth, "Float", sHeight, "Int", unit, "Ptr", imageAttributes, "Ptr", 0, "Ptr", 0, "Int")) {
			throw (ErrorFromStatus(status))
		}
	}

	;------------------------------------------------------- Bitmap ---------------;

	;* graphics.DrawCachedBitmap(bitmap[, x, y])
	;* Parameter:
		;* [CachedBitmap] bitmap
		;* [Integer] x
		;* [Integer] y
	DrawCachedBitmap(bitmap, x := 0, y := 0) {
		if (status := DllCall("Gdiplus\GdipDrawCachedBitmap", "Ptr", this.Ptr, "Ptr", bitmap, "Int", x, "Int", y, "Int")) {
			throw (ErrorFromStatus(status))
		}
	}

	;-------------------------------------------------------- Fill ----------------;

	;FillClosedCurve
	;FillEllipse
	;FillPath
	;FillPie
	;FillPolygon
	;FillRectangle
	;FillRoundedRectangle
	;FillRegion

	;* graphics.FillClosedCurve(brush, points*[, tension, fillMode])
	;* Parameter:
		;* [Brush] brush
		;* [Array]* points
		;* [Float] tension - Non-negative real number that specifies how tightly the spline bends as it passes through the points.
		;* [Integer] fillMode - See FillMode enumeration.
	FillClosedCurve(brush, points*) {
		if (IsNumber(points[-1])) {
			fillMode := (IsNumber(points[-2])) ? (points.Pop()) : (0), tension := points.Pop()
		}

		for index, point in (struct := Structure((length := points.Length)*8), points) {
			struct.NumPut(index*8, "Float", point[0], "Float", point[1])
		}

		if (status := (tension)
			? (DllCall("Gdiplus\GdipFillClosedCurve2", "Ptr", this.Ptr, "Ptr", brush, "Ptr", struct.Ptr, "UInt", length, "Float", tension, "UInt", fillMode, "Int"))
			: (DllCall("Gdiplus\GdipFillClosedCurve", "Ptr", this.Ptr, "Ptr", brush, "Ptr", struct.Ptr, "UInt", length, "Int"))) {
			throw (ErrorFromStatus(status))
		}
	}

	;* graphics.FillEllipse(brush, x, y, width, height)
	;* Parameter:
		;* [Brush] brush
		;* [Float] x
		;* [Float] y
		;* [Float] width
		;* [Float] height
	FillEllipse(brush, x, y, width, height) {
		if (status := DllCall("Gdiplus\GdipFillEllipse", "Ptr", this.Ptr, "Ptr", brush, "Float", x, "Float", y, "Float", width, "Float", height, "Int")) {
			throw (ErrorFromStatus(status))
		}
	}

	;* graphics.FillPath(brush, path)
	;* Parameter:
		;* [Brush] brush
		;* [Path] path
	FillPath(brush, path) {
		if (status := DllCall("Gdiplus\GdipFillPath", "Ptr", this.Ptr, "Ptr", brush, "Ptr", path, "Int")) {
			throw (ErrorFromStatus(status))
		}
	}

	;* graphics.FillPie(brush, x, y, width, height, startAngle, sweepAngle)
	;* Parameter:
		;* [Brush] brush
		;* [Float] x
		;* [Float] y
		;* [Float] width
		;* [Float] height
		;* [Float] startAngle
		;* [Float] sweepAngle
	FillPie(brush, x, y, width, height, startAngle, sweepAngle) {
		if (status := DllCall("Gdiplus\GdipFillPie", "Ptr", this.Ptr, "Ptr", brush, "Float", x, "Float", y, "Float", width, "Float", height, "Float", startAngle, "Float", sweepAngle, "Int")) {
			throw (ErrorFromStatus(status))
		}
	}

	;* graphics.FillPolygon(brush, points*[, fillMode])
	;* Parameter:
		;* [Brush] brush
		;* [Array]* points
		;* [Integer] fillMode - See FillMode enumeration.
	FillPolygon(brush, points*) {
		fillMode := (IsNumber(points[-1])) ? (points.Pop()) : (0)

		for index, point in (struct := Structure((length := points.Length)*8), points) {
			struct.NumPut(index*8, "Float", point[0], "Float", point[1])
		}

		if (status := DllCall("Gdiplus\GdipFillPolygon", "Ptr", this.Ptr, "Ptr", brush, "Ptr", struct.Ptr, "Int", length, "UInt", fillMode, "Int")) {
			throw (ErrorFromStatus(status))
		}
	}

	;* graphics.FillRectangle(brush, x, y, width, height)
	;* Parameter:
		;* [Brush] brush
		;* [Float] x
		;* [Float] y
		;* [Float] width
		;* [Float] height
	FillRectangle(brush, x, y, width, height) {
		if (status := DllCall("Gdiplus\GdipFillRectangle", "Ptr", this.Ptr, "Ptr", brush, "Float", x, "Float", y, "Float", width, "Float", height, "Int")) {
			throw (ErrorFromStatus(status))
		}
	}

	;* graphics.FillRoundedRectangle(brush, x, y, width, height, radius)
	;* Parameter:
		;* [Brush] brush
		;* [Float] x
		;* [Float] y
		;* [Float] width
		;* [Float] height
		;* [Float] radius - Radius of the rounded corners.
	FillRoundedRectangle(brush, x, y, width, height, radius) {
		state := this.Save()
			, pGraphics := this.Ptr

		DllCall("Gdiplus\GdipSetPixelOffsetMode", "Ptr", pGraphics, "Int", 2)

		(path := GDIp.CreatePath()).AddRoundedRectangle(x, y, width, height, radius)

		if (status := DllCall("Gdiplus\GdipFillPath", "Ptr", pGraphics, "Ptr", brush, "Ptr", path.Ptr, "Int")) {
			throw (ErrorFromStatus(status))
		}

		this.Restore(state)
	}

	;* graphics.FillRegion(brush, region)
	;* Parameter:
		;* [Brush] brush
		;* [Region] region
	FillRegion(brush, region) {
		if (status := DllCall("Gdiplus\GdipFillRegion", "Ptr", this.Ptr, "Ptr", brush, "Ptr", region, "Int")) {
			throw (ErrorFromStatus(status))
		}
	}

	;-------------------------------------------------------- Draw ----------------;

	;DrawArc
	;DrawBezier
	;DrawBeziers
	;DrawClosedCurve
	;DrawCurve
	;DrawEllipse
	;DrawLine
	;DrawLines
	;DrawPath
	;DrawPie
	;DrawPolygon
	;DrawRectangle
	;DrawRoundedRectangle

	;* graphics.DrawArc(pen, x, y, width, height, startAngle, sweepAngle)
	;* Parameter:
		;* [Pen] pen
		;* [Float] x
		;* [Float] y
		;* [Float] width
		;* [Float] height
		;* [Float] startAngle
		;* [Float] sweepAngle
	DrawArc(pen, x, y, width, height, startAngle, sweepAngle) {
		try {
			offset := pen.Width
		}
		catch {
			if (status := DllCall("Gdiplus\GdipGetPenWidth", "Ptr", pen, "Float*", &(offset := 0), "Int")) {
				throw (ErrorFromStatus(status))
			}
		}

		if (status := DllCall("Gdiplus\GdipDrawArc", "Ptr", this.Ptr, "Ptr", pen, "Float", x, "Float", y, "Float", width - offset, "Float", height - offset, "Float", startAngle, "Float", sweepAngle, "Int")) {
			throw (ErrorFromStatus(status))
		}
	}

	;* graphics.DrawBezier(pen, point1, point2, point3, point4)
	;* Parameter:
		;* [Pen] pen
		;* [Array] point1
		;* [Array] point2
		;* [Array] point3
		;* [Array] point4
	DrawBezier(pen, point1, point2, point3, point4) {
		if (status := DllCall("Gdiplus\GdipDrawBezier", "Ptr", this.Ptr, "Ptr", pen, "Float", point1[0], "Float", point1[1], "Float", point2[0], "Float", point2[1], "Float", point3[0], "Float", point3[1], "Float", point4[0], "Float", point4[1], "Int")) {
			throw (ErrorFromStatus(status))
		}
	}

	;* graphics.DrawBeziers(pen, points*)
	;* Parameter:
		;* [Pen] pen
		;* [Array]* points
	;* Note:
		;~ The first spline is constructed from the first point through the fourth point in the array and uses the second and third points as control points. Each subsequent spline in the sequence needs exactly three more points: the ending point of the previous spline is used as the starting point, the next two points in the sequence are control points, and the third point is the ending point.
	DrawBeziers(pen, points*) {
		for index, point in (struct := Structure((length := points.Length)*8), points) {
			struct.NumPut(index*8, "Float", point[0], "Float", point[1])
		}

		if (status := DllCall("Gdiplus\GdipDrawBeziers", "Ptr", this.Ptr, "Ptr", pen, "Ptr", struct.Ptr, "UInt", length, "Int")) {
			throw (ErrorFromStatus(status))
		}
	}

	;* graphics.DrawClosedCurve(pen, points*[, tension])
	;* Parameter:
		;* [Pen] pen
		;* [Array]* points
		;* [Float] tension - Non-negative real number that specifies how tightly the spline bends as it passes through the points.
	DrawClosedCurve(pen, points*) {
		if (IsNumber(points[-1])) {
			tension := points.Pop()
		}

		for index, point in (struct := Structure((length := points.Length)*8), points) {
			struct.NumPut(index*8, "Float", point[0], "Float", point[1])
		}

		if (status := (tension)
			? (DllCall("Gdiplus\GdipDrawClosedCurve2", "Ptr", this.Ptr, "Ptr", pen, "Ptr", struct.Ptr, "UInt", length, "Float", tension, "Int"))
			: (DllCall("Gdiplus\GdipDrawClosedCurve", "Ptr", this.Ptr, "Ptr", pen, "Ptr", struct.Ptr, "UInt", length, "Int"))) {
			throw (ErrorFromStatus(status))
		}
	}

	;* graphics.DrawCurve(pen, points*[, tension])
	;* Parameter:
		;* [Pen] pen
		;* [Array]* points
		;* [Float] tension - Non-negative real number that specifies how tightly the spline bends as it passes through the points.
	DrawCurve(pen, points*) {
		if (IsNumber(points[-1])) {
			tension := points.Pop()
		}

		for index, point in (struct := Structure((length := points.Length)*8), points) {
			struct.NumPut(index*8, "Float", point[0], "Float", point[1])
		}

		if (status := (tension)
			? (DllCall("Gdiplus\GdipDrawCurve2", "Ptr", this.Ptr, "Ptr", pen, "Ptr", struct.Ptr, "UInt", length, "Float", tension, "Int"))
			: (DllCall("Gdiplus\GdipDrawCurve", "Ptr", this.Ptr, "Ptr", pen, "Ptr", struct.Ptr, "UInt", length, "Int"))) {
			throw (ErrorFromStatus(status))
		}
	}

	;* graphics.DrawEllipse(pen, x, y, width, height)
	;* Parameter:
		;* [Pen] pen
		;* [Float] x
		;* [Float] y
		;* [Float] width
		;* [Float] height
	DrawEllipse(pen, x, y, width, height) {
		try {
			offset := pen.Width
		}
		catch {
			if (status := DllCall("Gdiplus\GdipGetPenWidth", "Ptr", pen, "Float*", &(offset := 0), "Int")) {
				throw (ErrorFromStatus(status))
			}
		}

		if (status := DllCall("Gdiplus\GdipDrawEllipse", "Ptr", this.Ptr, "Ptr", pen, "Float", x, "Float", y, "Float", width - offset, "Float", height - offset, "Int")) {
			throw (ErrorFromStatus(status))
		}
	}

	;* graphics.DrawLine(pen, point1, point2)
	;* Parameter:
		;* [Pen] pen
		;* [Array] point1
		;* [Array] point2
	DrawLine(pen, point1, point2) {
		if (status := DllCall("Gdiplus\GdipDrawLine", "Ptr", this.Ptr, "Ptr", pen, "Float", point1[0], "Float", point1[1], "Float", point2[0], "Float", point2[1], "Int")) {
			throw (ErrorFromStatus(status))
		}
	}

	;* graphics.DrawLines(pen, points*)
	;* Parameter:
		;* [Pen] pen
		;* [Array]* points
	DrawLines(pen, points*) {
		for index, point in (struct := Structure((length := points.Length)*8), points) {
			struct.NumPut(index*8, "Float", point[0], "Float", point[1])
		}

		if (status := DllCall("Gdiplus\GdipDrawLines", "Ptr", this.Ptr, "Ptr", pen, "Ptr", struct.Ptr, "UInt", length, "Int")) {
			throw (ErrorFromStatus(status))
		}
	}

	;* graphics.DrawPath(pen, path)
	;* Parameter:
		;* [Pen] pen
		;* [Path] path
	DrawPath(pen, path) {
		if (status := DllCall("Gdiplus\GdipDrawPath", "Ptr", this.Ptr, "Ptr", pen, "Ptr", path.Ptr, "Int")) {
			throw (ErrorFromStatus(status))
		}
	}

	;* graphics.DrawPie(pen, x, y, width, height, startAngle, startAngle, sweepAngle)
	;* Parameter:
		;* [Pen] pen
		;* [Float] x
		;* [Float] y
		;* [Float] width
		;* [Float] height
		;* [Float] startAngle
		;* [Float] sweepAngle
	DrawPie(pen, x, y, width, height, startAngle, sweepAngle) {
		try {
			offset := pen.Width
		}
		catch {
			if (status := DllCall("Gdiplus\GdipGetPenWidth", "Ptr", pen, "Float*", &(offset := 0), "Int")) {
				throw (ErrorFromStatus(status))
			}
		}

		if (status := DllCall("Gdiplus\GdipDrawPie", "Ptr", this.Ptr, "Ptr", pen, "Float", x, "Float", y, "Float", width - offset, "Float", height - offset, "Float", startAngle, "Float", sweepAngle, "Int")) {
			throw (ErrorFromStatus(status))
		}
	}

	;* graphics.DrawPolygon(pen, points*)
	;* Parameter:
		;* [Pen] pen
		;* [Array]* points
	DrawPolygon(pen, points*) {
		for index, point in (struct := Structure((length := points.Length)*8), points) {
			struct.NumPut(index*8, "Float", point[0], "Float", point[1])
		}

		if (status := DllCall("Gdiplus\GdipDrawPolygon", "Ptr", this.Ptr, "Ptr", pen, "Ptr", struct.Ptr, "UInt", length, "Int")) {
			throw (ErrorFromStatus(status))
		}
	}

	;* graphics.DrawRectangle(pen, x, y, width, height)
	;* Parameter:
		;* [Pen] pen
		;* [Float] x
		;* [Float] y
		;* [Float] width
		;* [Float] height
	DrawRectangle(pen, x, y, width, height) {
		try {
			offset := pen.Width
		}
		catch {
			if (status := DllCall("Gdiplus\GdipGetPenWidth", "Ptr", pen, "Float*", &(offset := 0), "Int")) {
				throw (ErrorFromStatus(status))
			}
		}

		if (status := DllCall("Gdiplus\GdipDrawRectangle", "Ptr", this.Ptr, "Ptr", pen, "Float", x, "Float", y, "Float", width - offset, "Float", height - offset, "Int")) {
			throw (ErrorFromStatus(status))
		}
	}

	;* graphics.DrawRoundedRectangle(pen, x, y, width, height, radius)
	;* Parameter:
		;* [Pen] pen
		;* [Float] x
		;* [Float] y
		;* [Float] width
		;* [Float] height
		;* [Float] radius - Radius of the rounded corners.
	DrawRoundedRectangle(pen, x, y, width, height, radius) {
		try {
			offset := pen.Width
		}
		catch {
			if (status := DllCall("Gdiplus\GdipGetPenWidth", "Ptr", pen, "Float*", &(offset := 0), "Int")) {
				throw (ErrorFromStatus(status))
			}
		}

		diameter := radius*2
			, width -= diameter + offset, height -= diameter + offset

		DllCall("Gdiplus\GdipCreatePath", "UInt", 0, "Ptr*", &(pPath := 0))

		DllCall("Gdiplus\GdipAddPathArc", "Ptr", pPath, "Float", x, "Float", y, "Float", diameter, "Float", diameter, "Float", 180, "Float", 90)
		DllCall("Gdiplus\GdipAddPathArc", "Ptr", pPath, "Float", x + width, "Float", y, "Float", diameter, "Float", diameter, "Float", 270, "Float", 90)
		DllCall("Gdiplus\GdipAddPathArc", "Ptr", pPath, "Float", x + width, "Float", y + height, "Float", diameter, "Float", diameter, "Float", 0, "Float", 90)
		DllCall("Gdiplus\GdipAddPathArc", "Ptr", pPath, "Float", x, "Float", y + height, "Float", diameter, "Float", diameter, "Float", 90, "Float", 90)
		DllCall("Gdiplus\GdipClosePathFigure", "Ptr", pPath)

		if (status := DllCall("Gdiplus\GdipDrawPath", "Ptr", this.Ptr, "Ptr", pen, "Ptr", pPath, "Int")) {
			throw (ErrorFromStatus(status))
		}

		DllCall("Gdiplus\GdipDeletePath", "Ptr", pPath)
	}
}