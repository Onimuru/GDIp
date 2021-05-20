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

static CreateGraphicsFromDC(DC) {
	if (status := DllCall("Gdiplus\GdipCreateFromHDC", "Ptr", DC.Handle, "Ptr*", &(pGraphics := 0), "Int")) {
		throw (ErrorFromStatus(status))
	}

	(instance := this.Graphics()).Ptr := pGraphics
	return (instance)
}

static CreateGraphicsFromBitmap(bitmap) {
	if (status := DllCall("Gdiplus\GdipGetImageGraphicsContext", "Ptr", bitmap.Ptr, "Ptr*", &(pGraphics := 0), "Int")) {
		throw (ErrorFromStatus(status))
	}

	(instance := this.Graphics()).Ptr := pGraphics
	return (instance)
}

static CreateGraphicsFromWindow(hWnd, useICM := False) {
	if (status := (useICM)
		? (DllCall("Gdiplus\GdipCreateFromHWNDICM", "Ptr", hWnd, "Ptr*", &(pGraphics := 0), "Int"))
		: (DllCall("Gdiplus\GdipCreateFromHWND", "Ptr", hWnd, "Ptr*", &(pGraphics := 0), "Int"))) {
		throw (ErrorFromStatus(status))
	}

	(instance := this.Graphics()).Ptr := pGraphics
	return (instance)
}

class Graphics {
	Class := "Graphics"

	__Delete() {
		if (status := DllCall("Gdiplus\GdipDeleteGraphics", "Ptr", this.Ptr, "Int")) {
			throw (ErrorFromStatus(status))
		}
	}

	;-------------- Property ------------------------------------------------------;

	States {
		Get {
			this.DefineProp("States", {Value: object := []})  ;* Only initialize this object as needed.

			return (object)
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
		;* [UInt] - See CompositingMode enumeration.
	GetCompositingMode() {
		if (status := DllCall("Gdiplus\GdipGetCompositingMode", "Ptr", this.Ptr, "UInt*", &(compositingMode := 0), "Int")) {
			throw (ErrorFromStatus(status))
		}

		return (compositingMode)
	}

	;* graphics.SetCompositingMode(compositingMode)
	;* Parameter:
		;* [UInt] compositingMode - See CompositingMode enumeration.
	SetCompositingMode(compositingMode) {
		if (status := DllCall("Gdiplus\GdipSetCompositingMode", "Ptr", this.Ptr, "UInt", compositingMode, "Int")) {
			throw (ErrorFromStatus(status))
		}

		return (True)
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
		;* [UInt] - See CompositingQuality enumeration.
	GetCompositingQuality() {
		if (status := DllCall("Gdiplus\GdipGetCompositingQuality", "Ptr", this.Ptr, "UInt*", &(compositingQuality := 0), "Int")) {
			throw (ErrorFromStatus(status))
		}

		return (compositingQuality)
	}

	;* graphics.SetCompositingQuality(compositingQuality)
	;* Parameter:
		;* [UInt] compositingQuality - See CompositingQuality enumeration.
	SetCompositingQuality(compositingQuality) {
		if (status := DllCall("Gdiplus\GdipSetCompositingQuality", "Ptr", this.Ptr, "UInt", compositingQuality, "Int")) {
			throw (ErrorFromStatus(status))
		}

		return (True)
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
		;* [UInt] - See InterpolationMode enumeration.
	GetInterpolationMode() {
		if (status := DllCall("Gdiplus\GdipGetInterpolationMode", "Ptr", this.Ptr, "UInt*", &(interpolationMode := 0), "Int")) {
			throw (ErrorFromStatus(status))
		}

		return (interpolationMode)
	}

	;* graphics.SetInterpolationMode(interpolationMode)
	;* Parameter:
		;* [UInt] interpolationMode - See InterpolationMode enumeration.
	SetInterpolationMode(interpolationMode) {
		if (status := DllCall("Gdiplus\GdipSetInterpolationMode", "Ptr", this.Ptr, "UInt", interpolationMode, "Int")) {
			throw (ErrorFromStatus(status))
		}

		return (True)
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

		return (True)
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
		;* [Int] - See Unit enumeration.
	GetPageUnit() {
		if (status := DllCall("Gdiplus\GdipGetPageUnit", "Ptr", this.Ptr, "Int*", &(unit := 0), "Int")) {
			throw (ErrorFromStatus(status))
		}

		return (unit)
	}

	;* graphics.SetPageUnit(unit)
	;* Parameter:
		;* [Int] unit - See Unit enumeration.
	SetPageUnit(unit) {
		if (status := DllCall("Gdiplus\GdipSetPageUnit", "Ptr", this.Ptr, "Int", unit, "Int")) {
			throw (ErrorFromStatus(status))
		}

		return (True)
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
		;* [UInt] - See SmoothingMode enumeration.
	GetSmoothingMode() {
		if (status := DllCall("Gdiplus\GdipGetSmoothingMode", "Ptr", this.Ptr, "UInt*", &(smoothingMode := 0), "Int")) {
			throw (ErrorFromStatus(status))
		}

		return (smoothingMode)
	}

	;* graphics.SetSmoothingMode(smoothingMode)
	;* Parameter:
		;* [UInt] smoothingMode - See SmoothingMode enumeration.
	SetSmoothingMode(smoothingMode) {
		if (status := DllCall("Gdiplus\GdipSetSmoothingMode", "Ptr", this.Ptr, "UInt", smoothingMode, "Int")) {
			throw (ErrorFromStatus(status))
		}

		return (True)
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
		;* [UInt] - A number between 0 and 12, which defines the value of contrast used for antialiasing text.
	GetTextContrast() {
		if (status := DllCall("Gdiplus\GdipGetTextContrast", "Ptr", this.Ptr, "UInt*", &(contrast := 0), "Int")) {
			throw (ErrorFromStatus(status))
		}

		return (contrast)
	}

	;* graphics.SetTextContrast(contrast)
	;* Parameter:
		;* [UInt] contrast - A number between 0 and 12, which defines the value of contrast used for antialiasing text.
	SetTextContrast(contrast) {
		if (status := DllCall("Gdiplus\GdipSetTextContrast", "Ptr", this.Ptr, "UInt", contrast, "Int")) {
			throw (ErrorFromStatus(status))
		}

		return (True)
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
		;* [UInt] - See TextRenderingHint enumeration.
	GetTextRenderingHint() {
		if (status := DllCall("Gdiplus\GdipGetTextRenderingHint", "Ptr", this.Ptr, "UInt*", &(hint := 0), "Int")) {
			throw (ErrorFromStatus(status))
		}

		return (hint)
	}

	;* graphics.SetTextRenderingHint(hint)
	;* Parameter:
		;* [UInt] hint - See TextRenderingHint enumeration.
	SetTextRenderingHint(hint) {
		if (status := DllCall("Gdiplus\GdipSetTextRenderingHint", "Ptr", this.Ptr, "UInt", hint, "Int")) {
			throw (ErrorFromStatus(status))
		}

		return (True)
	}

	Transform {
		Get {
			return (this.GetTransform())
		}

		Set {
			this.SetTransform(value)

			return (value)
		}
	}

	GetTransform() {
		if (status := DllCall("Gdiplus\GdipGetWorldTransform", "Ptr", this.Ptr, "Ptr*", &(pMatrix := 0), "Int")) {
			throw (ErrorFromStatus(status))
		}

		(instance := GDIp.Matrix()).Ptr := pMatrix
		return (instance)
	}

	SetTransform(matrix) {
		if (status := DllCall("Gdiplus\GdipSetWorldTransform", "Ptr", this.Ptr, "Ptr", matrix.Ptr, "Int")) {
			throw (ErrorFromStatus(status))
		}

		return (True)
	}

	;--------------- Method -------------------------------------------------------;
	;-----------------------------------------------------  Transform  -------------;

	;* graphics.TranslateTransform(x, y[, matrixOrder])
	;* Parameter:
		;* [Int] matrixOrder - See MatrixOrder enumeration.
	TranslateTransform(x, y, matrixOrder := 0) {
		if (status := DllCall("Gdiplus\GdipTranslateWorldTransform", "Ptr", this.Ptr, "Float", x, "Float", y, "Int", matrixOrder, "Int")) {
			throw (ErrorFromStatus(status))
		}

		return (True)
	}

	;* graphics.RotateTransform(angle[, matrixOrder])
	;* Parameter:
		;* [Float] angle - Angle of rotation in degrees.
		;* [Int] matrixOrder - See MatrixOrder enumeration.
	RotateTransform(angle, matrixOrder := 0) {
		if (status := DllCall("Gdiplus\GdipRotateWorldTransform", "Ptr", this.Ptr, "Float", angle, "Int", matrixOrder, "Int")) {
			throw (ErrorFromStatus(status))
		}

		return (True)
	}

	;* graphics.MultiplyTransform([__Matrix] matrix[, matrixOrder])
	;* Parameter:
		;* [Int] matrixOrder - See MatrixOrder enumeration.
	MultiplyTransform(matrix, matrixOrder := 0) {
		if (status := DllCall("Gdiplus\GdipMultiplyWorldTransform", "Ptr", this.Ptr, "Ptr", matrix.Ptr, "Int", matrixOrder, "Int")) {
			throw (ErrorFromStatus(status))
		}

		return (True)
	}

	;* graphics.ScaleTransform(x, y[, matrixOrder])
	;* Parameter:
		;* [Int] matrixOrder - See MatrixOrder enumeration.
	ScaleTransform(x, y, matrixOrder := 0) {
		if (status := DllCall("Gdiplus\GdipScaleWorldTransform", "Ptr", this.Ptr, "Float", x, "Float", y, "Int", matrixOrder, "Int")) {
			throw (ErrorFromStatus(status))
		}

		return (True)
	}

	ResetTransform() {
		if (status := DllCall("Gdiplus\GdipResetWorldTransform", "Ptr", this.Ptr, "Int")) {
			throw (ErrorFromStatus(status))
		}

		return (True)
	}

	;------------------------------------------------------  Control  --------------;

	;* graphics.Flush(intention)
	;* Parameter:
		;* [Int] intention - See FlushIntention enumeration.
	Flush(intention) {

		if (status := DllCall("Gdiplus\GdipFlush", "Ptr", this.Ptr, "Int", intention, "Int")) {
			throw (ErrorFromStatus(status))
		}

		return (True)
	}

	Save() {
		if (status := DllCall("Gdiplus\GdipSaveGraphics", "Ptr", this.Ptr, "UInt*", &(state := 0), "Int")) {
			throw (ErrorFromStatus(status))
		}

		this.States.Push(state)

		return (state)
	}

	Restore(state := 0) {
		if (status := DllCall("Gdiplus\GdipRestoreGraphics", "Ptr", this.Ptr, "UInt", (state) ? (this.States.RemoveAt(this.States.IndexOf(state))) : (this.States.Shift()), "Int")) {
			throw (ErrorFromStatus(status))
		}

		return (state)
	}

	Clear(color := 0x00000000) {
		if (status := DllCall("Gdiplus\GdipGraphicsClear", "Ptr", this.Ptr, "UInt", color, "Int")) {
			throw (ErrorFromStatus(status))
		}

		return (True)
	}

	;------------------------------------------------------- Bitmap ---------------;

	;* graphics.DrawBitmap([__Bitmap] bitmap[, [__Rect] destinationObject, [__Rect] sourceObject, unit, [__ImageAttributes] imageAttributes])
	;* Parameter:
		;* [Int] unit - See Unit enumeration.
	DrawBitmap(bitmap, destinationObject := "", sourceObject := "", unit := 2, imageAttributes := "") {
		if (status := (sourceObject)
			? (DllCall("Gdiplus\GdipDrawImageRectRect", "Ptr", this.Ptr, "Ptr", bitmap.Ptr, "Float", destinationObject.x, "Float", destinationObject.y, "Float", destinationObject.Width, "Float", destinationObject.Height, "Float", sourceObject.x, "Float", sourceObject.y, "Float", sourceObject.Width, "Float", sourceObject.Height, "Int", unit, "Ptr", imageAttributes.Ptr, "Ptr", 0, "Ptr", 0, "Int"))
			: ((destinationObject)
				? (DllCall("Gdiplus\GdipDrawImageRect", "Ptr", this.Ptr, "Ptr", bitmap.Ptr, "Float", destinationObject.x, "Float", destinationObject.y, "Float", destinationObject.Width, "Float", destinationObject.Height, "Int"))
				: (DllCall("Gdiplus\GdipDrawImage", "Ptr", this.Ptr, "Ptr", bitmap.Ptr, "Float", 0, "Float", 0, "Int")))) {
			throw (ErrorFromStatus(status))
		}

		return (True)
	}

	;* graphics.DrawCachedBitmap([__CachedBitmap] bitmap[, [__Vec2] object])
	DrawCachedBitmap(bitmap, object := "") {
		if (status := DllCall("Gdiplus\GdipDrawCachedBitmap", "Ptr", this.Ptr, "Ptr", bitmap.Ptr, "Int", object.x, "Int", object.y, "Int")) {
			throw (ErrorFromStatus(status))
		}

		return (True)
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

	;* graphics.FillClosedCurve(brush, objects*[, tension, fillMode])
	;* Parameter:
		;* [Brush] brush
		;* [Object] objects*
		;* [Float] tension - Non-negative real number that specifies how tightly the spline bends as it passes through the points.
		;* [UInt] fillMode - See FillMode enumeration.
	FillClosedCurve(brush, objects*) {
		if (IsNumber(objects[index := (length := objects.Length) - 1])) {
			if (IsNumber(objects[index - 1])) {
				fillMode := objects.Pop(), tension := objects.Pop(), length -= 2
			}
			else {
				tension := objects.Pop(), length--
			}
		}

		for index, object in (points := Structure(length*8), objects) {
			points.NumPut(index*8, "Float", object.x, "Float", object.y)
		}

		if (status := (tension)
			? (DllCall("Gdiplus\GdipFillClosedCurve2", "Ptr", this.Ptr, "Ptr", brush.Ptr, "Ptr", points.Ptr, "UInt", length, "Float", tension, "UInt", fillMode, "Int"))
			: (DllCall("Gdiplus\GdipFillClosedCurve", "Ptr", this.Ptr, "Ptr", brush.Ptr, "Ptr", points.Ptr, "UInt", length, "Int"))) {
			throw (ErrorFromStatus(status))
		}

		return (True)
	}

	;* graphics.FillEllipse(brush, object)
	;* Parameter:
		;* [Brush] brush
		;* [Object] objects
	FillEllipse(brush, object) {
		if (status := DllCall("Gdiplus\GdipFillEllipse", "Ptr", this.Ptr, "Ptr", brush.Ptr, "Float", object.x, "Float", object.y, "Float", object.Width, "Float", object.Height, "Int")) {
			throw (ErrorFromStatus(status))
		}

		return (True)
	}

	;* graphics.FillPath(brush, path)
	;* Parameter:
		;* [Brush] brush
		;* [Path] path
	FillPath(brush, path) {
		if (status := DllCall("Gdiplus\GdipFillPath", "Ptr", this.Ptr, "Ptr", brush.Ptr, "Ptr", path.Ptr, "Int")) {
			throw (ErrorFromStatus(status))
		}

		return (True)
	}

	;* graphics.FillPie(brush, object, startAngle, sweepAngle)
	;* Parameter:
		;* [Brush] brush
		;* [Object] object
		;* [Float] startAngle
		;* [Float] sweepAngle
	FillPie(brush, object, startAngle, sweepAngle) {
		if (status := DllCall("Gdiplus\GdipFillPie", "Ptr", this.Ptr, "Ptr", brush.Ptr, "Float", object.x, "Float", object.y, "Float", object.Width, "Float", object.Height, "Float", startAngle, "Float", sweepAngle, "Int")) {
			throw (ErrorFromStatus(status))
		}

		return (True)
	}

	;* graphics.FillPolygon(brush, [__Vec2] objects*[, fillMode])
	;* Parameter:
		;* [Brush] brush
		;* [Object] objects
		;* [UInt] fillMode - See FillMode enumeration.
	FillPolygon(brush, objects*) {
		if (IsNumber(objects[(length := objects.Length) - 1])) {
			fillMode := objects.Pop(), length--
		}

		for index, object in (points := Structure(length*8), objects) {
			points.NumPut(index*8, "Float", object.x, "Float", object.y)
		}

		if (status := DllCall("Gdiplus\GdipFillPolygon", "Ptr", this.Ptr, "Ptr", brush.Ptr, "Ptr", points.Ptr, "Int", length, "UInt", fillMode, "Int")) {
			throw (ErrorFromStatus(status))
		}

		return (True)
	}

	;* graphics.FillRectangle(brush, object)
	;* Parameter:
		;* [Brush] brush
		;* [Object] object
	FillRectangle(brush, object) {
		if (status := DllCall("Gdiplus\GdipFillRectangle", "Ptr", this.Ptr, "Ptr", brush.Ptr, "Float", object.x, "Float", object.y, "Float", object.Width, "Float", object.Height, "Int")) {
			throw (ErrorFromStatus(status))
		}

		return (True)
	}

	;* graphics.FillRoundedRectangle(brush, object, radius)
	;* Parameter:
		;* [Brush] brush
		;* [Object] object - Object with `x`, `y`, `Width` and `Height` properties that defines the rectangle to be rounded.
		;* radius - Radius of the rounded corners.
	FillRoundedRectangle(brush, object, radius) {
		state := this.Save()
			, pGraphics := this.Ptr

		DllCall("Gdiplus\GdipSetPixelOffsetMode", "Ptr", pGraphics, "Int", 2), DllCall("Gdiplus\GdipSetCompositingMode", "Ptr", pGraphics, "Int", 1), DllCall("Gdiplus\GdipSetCompositingQuality", "Ptr", pGraphics, "Int", 0), DllCall("Gdiplus\GdipSetSmoothingMode", "Ptr", pGraphics, "Int", 0), DllCall("Gdiplus\GdipSetInterpolationMode", "Ptr", pGraphics, "Int", 7)

		(path := GDIp.CreatePath()).AddRoundedRectangle(object, radius)

		if (status := DllCall("Gdiplus\GdipFillPath", "Ptr", pGraphics, "Ptr", brush.Ptr, "Ptr", path.Ptr, "Int")) {
			throw (ErrorFromStatus(status))
		}

		this.Restore(state)

		return (True)
	}

	;* graphics.FillRegion(brush, region)
	;* Parameter:
		;* [Brush] brush
		;* [Region] region
	FillRegion(brush, region) {
		if (status := DllCall("Gdiplus\GdipFillRegion", "Ptr", this.Ptr, "Ptr", brush.Ptr, "Ptr", region.Ptr, "Int")) {
			throw (ErrorFromStatus(status))
		}

		return (True)
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

	;* graphics.DrawArc([__Pen] pen, [__Rect] object, startAngle, sweepAngle)
	DrawArc(pen, object, startAngle, sweepAngle) {
		if (status := DllCall("Gdiplus\GdipDrawArc", "Ptr", this.Ptr, "Ptr", pen.Ptr, "Float", object.x, "Float", object.y, "Float", object.Width - (offset := pen.Width), "Float", object.Height - offset, "Float", startAngle, "Float", sweepAngle, "Int")) {
			throw (ErrorFromStatus(status))
		}

		return (True)
	}

	;* graphics.DrawBezier([__Pen] pen, [__Vec2] object1, [__Vec2] object2, [__Vec2] object3, [__Vec2] object4)
	DrawBezier(pen, object1, object2, object3, object4) {
		if (status := DllCall("Gdiplus\GdipDrawBezier", "Ptr", this.Ptr, "Ptr", pen.Ptr, "Float", object1.x, "Float", object1.y, "Float", object2.x, "Float", object2.y, "Float", object3.x, "Float", object3.y, "Float", object4.x, "Float", object4.y, "Int")) {
			throw (ErrorFromStatus(status))
		}

		return (True)
	}

	;* graphics.DrawBeziers([__Pen] pen, [__Vec2] objects*)
	;* Note:
		;* The first spline is constructed from the first point through the fourth point in the array and uses the second and third points as control points. Each subsequent spline in the sequence needs exactly three more points: the ending point of the previous spline is used as the starting point, the next two points in the sequence are control points, and the third point is the ending point.
	DrawBeziers(pen, objects*) {
		for index, object in (points := Structure((length := objects.Length)*8), objects) {
			points.NumPut(index*8, "Float", object.x, "Float", object.y)
		}

		if (status := DllCall("Gdiplus\GdipDrawBeziers", "Ptr", this.Ptr, "Ptr", pen.Ptr, "Ptr", points.Ptr, "UInt", length, "Int")) {
			throw (ErrorFromStatus(status))
		}

		return (True)
	}

	;* graphics.DrawClosedCurve([__Pen] pen, [__Vec2] objects*[, tension])
	;* Parameter:
		;* tension - Non-negative real number that specifies how tightly the spline bends as it passes through the points.
	DrawClosedCurve(pen, objects*) {
		if (IsNumber(objects[(length := objects.Length) - 1])) {
			tension := objects.Pop(), length--
		}

		for index, object in (points := Structure(length*8), objects) {
			points.NumPut(index*8, "Float", object.x, "Float", object.y)
		}

		if (status := (tension)
			? (DllCall("Gdiplus\GdipDrawClosedCurve2", "Ptr", this.Ptr, "Ptr", pen.Ptr, "Ptr", points.Ptr, "UInt", length, "Float", tension, "Int"))
			: (DllCall("Gdiplus\GdipDrawClosedCurve", "Ptr", this.Ptr, "Ptr", pen.Ptr, "Ptr", points.Ptr, "UInt", length, "Int"))) {
			throw (ErrorFromStatus(status))
		}

		return (True)
	}

	;* graphics.DrawCurve([__Pen] pen, [__Vec2] objects*[, tension])
	;* Parameter:
		;* tension - Non-negative real number that specifies how tightly the spline bends as it passes through the points.
	DrawCurve(pen, objects*) {
		if (IsNumber(objects[(length := objects.Length) - 1])) {
			tension := objects.Pop(), length--
		}

		for index, object in (points := Structure(length*8), objects) {
			points.NumPut(index*8, "Float", object.x, "Float", object.y)
		}

		if (status := (tension)
			? (DllCall("Gdiplus\GdipDrawCurve2", "Ptr", this.Ptr, "Ptr", pen.Ptr, "Ptr", points.Ptr, "UInt", length, "Float", tension, "Int"))
			: (DllCall("Gdiplus\GdipDrawCurve", "Ptr", this.Ptr, "Ptr", pen.Ptr, "Ptr", points.Ptr, "UInt", length, "Int"))) {
			throw (ErrorFromStatus(status))
		}

		return (True)
	}

	;* graphics.DrawEllipse([__Pen] pen, [__Rect] object)
	DrawEllipse(pen, object) {
		if (status := DllCall("Gdiplus\GdipDrawEllipse", "Ptr", this.Ptr, "Ptr", pen.Ptr, "Float", object.x, "Float", object.y, "Float", object.Width - (offset := pen.Width), "Float", object.Height - offset, "Int")) {
			throw (ErrorFromStatus(status))
		}

		return (True)
	}

	;* graphics.DrawLine([__Pen] pen, [__Vec2] object1, [__Vec2] object2)
	DrawLine(pen, object1, object2) {
		if (status := DllCall("Gdiplus\GdipDrawLine", "Ptr", this.Ptr, "Ptr", pen.Ptr, "Float", object1.x, "Float", object1.y, "Float", object2.x, "Float", object2.y, "Int")) {
			throw (ErrorFromStatus(status))
		}

		return (True)
	}

	;* graphics.DrawLines([__Pen] pen, [__Vec2] objects*)
	DrawLines(pen, objects*) {
		for index, object in (points := Structure((length := objects.Length)*8), objects) {
			points.NumPut(index*8, "Float", object.x, "Float", object.y)
		}

		if (status := DllCall("Gdiplus\GdipDrawLines", "Ptr", this.Ptr, "Ptr", pen.Ptr, "Ptr", points.Ptr, "UInt", length, "Int")) {
			throw (ErrorFromStatus(status))
		}

		return (True)
	}

	;* graphics.DrawPath([__Pen] pen, [__Path] path)
	DrawPath(pen, path) {
		if (status := DllCall("Gdiplus\GdipDrawPath", "Ptr", this.Ptr, "Ptr", pen.Ptr, "Ptr", path.Ptr, "Int")) {
			throw (ErrorFromStatus(status))
		}

		return (True)
	}

	;* graphics.DrawPie([__Pen] pen, [__Rect] object, startAngle, sweepAngle)
	DrawPie(pen, object, startAngle, sweepAngle) {
		if (status := DllCall("Gdiplus\GdipDrawPie", "Ptr", this.Ptr, "Ptr", pen.Ptr, "Float", object.x, "Float", object.y, "Float", object.Width - (offset := pen.Width), "Float", object.Height - offset, "Float", startAngle, "Float", sweepAngle, "Int")) {
			throw (ErrorFromStatus(status))
		}

		return (True)
	}

	;* graphics.DrawPolygon([__Pen] pen, [__Vec2] objects*)
	DrawPolygon(pen, objects*) {
		for index, object in (points := Structure((length := objects.Length)*8), objects) {
			points.NumPut(index*8, "Float", object.x, "Float", object.y)
		}

		if (status := DllCall("Gdiplus\GdipDrawPolygon", "Ptr", this.Ptr, "Ptr", pen.Ptr, "Ptr", points.Ptr, "UInt", length, "Int")) {
			throw (ErrorFromStatus(status))
		}

		return (True)
	}

	;* graphics.DrawRectangle([__Pen] pen, [__Rect] object)
	DrawRectangle(pen, object) {
		if (status := DllCall("Gdiplus\GdipDrawRectangle", "Ptr", this.Ptr, "Ptr", pen.Ptr, "Float", object.x, "Float", object.y, "Float", object.Width - (offset := pen.Width), "Float", object.Height - offset, "Int")) {
			throw (ErrorFromStatus(status))
		}

		return (True)
	}

	;* graphics.DrawRoundedRectangle([__Pen] pen, [__Rect] object, radius)
	;* Parameter:
		;* object - Object with `x`, `y`, `Width` and `Height` properties that defines the rectangle to be rounded.
		;* radius - Radius of the rounded corners.
	DrawRoundedRectangle(pen, object, radius) {
		state := this.Save()
			, pGraphics := this.Ptr

		DllCall("Gdiplus\GdipSetPixelOffsetMode", "Ptr", pGraphics, "Int", 2), DllCall("Gdiplus\GdipSetCompositingMode", "Ptr", pGraphics, "Int", 1), DllCall("Gdiplus\GdipSetCompositingQuality", "Ptr", pGraphics, "Int", 0), DllCall("Gdiplus\GdipSetSmoothingMode", "Ptr", pGraphics, "Int", 0), DllCall("Gdiplus\GdipSetInterpolationMode", "Ptr", pGraphics, "Int", 7)

		diameter := radius*2, offset := pen.Width
			, width := object.Width - diameter - offset, height := object.Height - diameter - offset, x := object.x + (offset := (offset + 1)//2), y := object.y + offset

		DllCall("Gdiplus\GdipCreatePath", "UInt", 0, "Ptr*", &(pPath := 0))

		DllCall("Gdiplus\GdipAddPathArc", "Ptr", pPath, "Float", x, "Float", y, "Float", diameter, "Float", diameter, "Float", 180, "Float", 90)
		DllCall("Gdiplus\GdipAddPathArc", "Ptr", pPath, "Float", x + width, "Float", y, "Float", diameter, "Float", diameter, "Float", 270, "Float", 90)
		DllCall("Gdiplus\GdipAddPathArc", "Ptr", pPath, "Float", x + width, "Float", y + height, "Float", diameter, "Float", diameter, "Float", 0, "Float", 90)
		DllCall("Gdiplus\GdipAddPathArc", "Ptr", pPath, "Float", x, "Float", y + height, "Float", diameter, "Float", diameter, "Float", 90, "Float", 90)
		DllCall("Gdiplus\GdipClosePathFigure", "Ptr", pPath)

		if (status := DllCall("Gdiplus\GdipDrawPath", "Ptr", pGraphics, "Ptr", pen.Ptr, "Ptr", pPath, "Int")) {
			throw (ErrorFromStatus(status))
		}

		this.Restore(state)

		DllCall("Gdiplus\GdipDeletePath", "Ptr", pPath)

		return (True)
	}
}