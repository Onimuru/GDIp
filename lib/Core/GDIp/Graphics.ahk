/*
;* CompositingMode enumeration (https://docs.microsoft.com/en-us/windows/win32/api/gdiplusenums/ne-gdiplusenums-compositingmode)
	;? 0 = CompositingModeSourceOver - Specifies that when a color is rendered, it overwrites the background color.
	;? 1 = CompositingModeSourceCopy - Specifies that when a color is rendered, it is blended with the background color. The blend is determined by the alpha component of the color being rendered.

;* CompositingQuality enumeration (https://docs.microsoft.com/en-us/windows/win32/api/gdiplusenums/ne-gdiplusenums-compositingquality)
	;? 0 = CompositingQualityDefault
	;? 1 = CompositingQualityHighSpeed
	;? 2 = CompositingQualityHighQuality
	;? 3 = CompositingQualityGammaCorrected
	;? 4 = CompositingQualityAssumeLinear

;* FillMode enumeration (https://docs.microsoft.com/en-us/windows/win32/api/gdiplusenums/ne-gdiplusenums-fillmode)
	;? 0 = FillModeAlternate
	;? 1 = FillModeWinding

;* FlushIntention enumeration (https://docs.microsoft.com/en-us/windows/win32/api/gdiplusenums/ne-gdiplusenums-flushintention)
	;? 0 = FlushIntentionFlush - Flush all batched rendering operations and return immediately.
	;? 1 = FlushIntentionSync - Flush all batched rendering operations and wait for them to complete.

;* InterpolationMode enumeration (https://docs.microsoft.com/en-us/windows/win32/api/gdiplusenums/ne-gdiplusenums-interpolationmode)
	;? 0 = InterpolationModeDefault
	;? 1 = InterpolationModeLowQuality
	;? 2 = InterpolationModeHighQuality
	;? 3 = InterpolationModeBilinear
	;? 4 = InterpolationModeBicubic
	;? 5 = InterpolationModeNearestNeighbor
	;? 6 = InterpolationModeHighQualityBilinear
	;? 7 = InterpolationModeHighQualityBicubic

;* MatrixOrder enumeration (https://docs.microsoft.com/en-us/windows/win32/api/gdiplusenums/ne-gdiplusenums-matrixorder)
	;? 0 = MatrixOrderPrepend
	;? 1 = MatrixOrderAppend

;* SmoothingMode enumeration (https://docs.microsoft.com/en-us/windows/win32/api/gdiplusenums/ne-gdiplusenums-smoothingmode)
	;? 0 = SmoothingModeDefault
	;? 1 = SmoothingModeHighSpeed
	;? 2 = SmoothingModeHighQuality
	;? 3 = SmoothingModeNone
	;? 4 = SmoothingModeAntiAlias

;* TextRenderingHint enumeration (https://docs.microsoft.com/en-us/windows/win32/api/gdiplusenums/ne-gdiplusenums-textrenderinghint)
	;? 0 = TextRenderingHintSystemDefault
	;? 1 = TextRenderingHintSingleBitPerPixelGridFit
	;? 2 = TextRenderingHintSingleBitPerPixel
	;? 3 = TextRenderingHintAntiAliasGridFit
	;? 4 = TextRenderingHintAntiAlias
	;? 5 = TextRenderingHintClearTypeGridFit

;* Unit enumeration (https://docs.microsoft.com/en-us/windows/win32/api/gdiplusenums/ne-gdiplusenums-unit)
	;? 0 = UnitWorld - World coordinate (non-physical unit).
	;? 1 = UnitDisplay - Variable (only for PageTransform).
	;? 2 = UnitPixel - Each unit is one device pixel.
	;? 3 = UnitPoint - Each unit is a printer's point, or 1/72 inch.
	;? 4 = UnitInch
	;? 5 = UnitDocument - Each unit is 1/300 inch.
	;? 6 = UnitMillimeter
*/

CreateGraphicsFromDC(DC) {
	Local

	if (status := DllCall("Gdiplus\GdipCreateFromHDC", "Ptr", DC.Handle, "Ptr*", pGraphics := 0, "Int")) {
		throw (Exception(FormatStatus(status)))
	}

	return ({"Ptr": pGraphics
		, "Base": this.__Graphics})
}

CreateGraphicsFromBitmap(bitmap) {
	Local

	if (status := DllCall("Gdiplus\GdipGetImageGraphicsContext", "Ptr", bitmap.Ptr, "Ptr*", pGraphics := 0, "Int")) {
		throw (Exception(FormatStatus(status)))
	}

	return ({"Ptr": pGraphics
		, "Base": this.__Graphics})
}

CreateGraphicsFromWindow(hWnd, useICM := False) {
	Local

	if (status := (useICM)
		? (DllCall("Gdiplus\GdipCreateFromHWNDICM", "Ptr", hWnd, "Ptr*", pGraphics := 0, "Int"))
		: (DllCall("Gdiplus\GdipCreateFromHWND", "Ptr", hWnd, "Ptr*", pGraphics := 0, "Int"))) {
		throw (Exception(FormatStatus(status)))
	}

	return ({"Ptr": pGraphics
		, "Base": this.__Graphics})
}

Class __Graphics {

	__Delete() {
		if (!this.HasKey("Ptr")) {
			MsgBox("Graphics.__Delete()")
		}

		DllCall("Gdiplus\GdipDeleteGraphics", "Ptr", this.Ptr)
	}

	;-------------- Property ------------------------------------------------------;

	CompositingMode[] {
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
		;* * - See CompositingMode enumeration.
	GetCompositingMode() {
		Local

		if (status := DllCall("Gdiplus\GdipGetCompositingMode", "Ptr", this.Ptr, "UInt*", compositingMode := 0, "Int")) {
			throw (Exception(FormatStatus(status)))
		}

		return (compositingMode)
	}

	;* graphics.SetCompositingMode(compositingMode)
	;* Parameter:
		;* compositingMode - See CompositingMode enumeration.
	SetCompositingMode(compositingMode) {
		Local

		if (status := DllCall("Gdiplus\GdipSetCompositingMode", "Ptr", this.Ptr, "UInt", compositingMode, "Int")) {
			throw (Exception(FormatStatus(status)))
		}

		return (True)
	}

	CompositingQuality[] {
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
		;* * - See CompositingQuality enumeration.
	GetCompositingQuality() {
		Local

		if (status := DllCall("Gdiplus\GdipGetCompositingQuality", "Ptr", this.Ptr, "UInt*", compositingQuality := 0, "Int")) {
			throw (Exception(FormatStatus(status)))
		}

		return (compositingQuality)
	}

	;* graphics.SetCompositingQuality(compositingQuality)
	;* Parameter:
		;* compositingQuality - See CompositingQuality enumeration.
	SetCompositingQuality(compositingQuality) {
		Local

		if (status := DllCall("Gdiplus\GdipSetCompositingQuality", "Ptr", this.Ptr, "UInt", compositingQuality, "Int")) {
			throw (Exception(FormatStatus(status)))
		}

		return (True)
	}

	InterpolationMode[] {
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
		;* * - See InterpolationMode enumeration.
	GetInterpolationMode() {
		Local

		if (status := DllCall("Gdiplus\GdipGetInterpolationMode", "Ptr", this.Ptr, "UInt*", interpolationMode := 0, "Int")) {
			throw (Exception(FormatStatus(status)))
		}

		return (interpolationMode)
	}

	;* graphics.SetInterpolationMode(interpolationMode)
	;* Parameter:
		;* interpolationMode - See InterpolationMode enumeration.
	SetInterpolationMode(interpolationMode) {
		Local

		if (status := DllCall("Gdiplus\GdipSetInterpolationMode", "Ptr", this.Ptr, "UInt", interpolationMode, "Int")) {
			throw (Exception(FormatStatus(status)))
		}

		return (True)
	}

	PageScale[] {
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
		;* * - The scaling factor for the page transformation of this graphics object.
	GetPageScale() {
		Local

		if (status := DllCall("Gdiplus\GdipGetPageScale", "Ptr", this.Ptr, "Float*", scale := 0, "Int")) {
			throw (Exception(FormatStatus(status)))
		}

		return (scale)
	}

	;* graphics.SetPageScale(scale)
	;* Parameter:
		;* scale - Sets the scaling factor for the page transformation of this graphics object.
	SetPageScale(scale) {
		Local

		if (status := DllCall("Gdiplus\GdipSetPageScale", "Ptr", this.Ptr, "Float", scale, "Int")) {
			throw (Exception(FormatStatus(status)))
		}

		return (True)
	}

	PageUnit[] {
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
		;* * - See Unit enumeration.
	GetPageUnit() {
		Local

		if (status := DllCall("Gdiplus\GdipGetPageUnit", "Ptr", this.Ptr, "Int*", unit := 0, "Int")) {
			throw (Exception(FormatStatus(status)))
		}

		return (unit)
	}

	;* graphics.SetPageUnit(unit)
	;* Parameter:
		;* unit - See Unit enumeration.
	SetPageUnit(unit) {
		Local

		if (status := DllCall("Gdiplus\GdipSetPageUnit", "Ptr", this.Ptr, "Int", unit, "Int")) {
			throw (Exception(FormatStatus(status)))
		}

		return (True)
	}

	SmoothingMode[] {
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
		;* * - See SmoothingMode enumeration.
	GetSmoothingMode() {
		Local

		if (status := DllCall("Gdiplus\GdipGetSmoothingMode", "Ptr", this.Ptr, "UInt*", smoothingMode := 0, "Int")) {
			throw (Exception(FormatStatus(status)))
		}

		return (smoothingMode)
	}

	;* graphics.SetSmoothingMode(smoothingMode)
	;* Parameter:
		;* smoothingMode - See SmoothingMode enumeration.
	SetSmoothingMode(smoothingMode) {
		Local

		if (status := DllCall("Gdiplus\GdipSetSmoothingMode", "Ptr", this.Ptr, "UInt", smoothingMode, "Int")) {
			throw (Exception(FormatStatus(status)))
		}

		return (True)
	}

	TextContrast[] {
		Get {
			return (this.GetTextContrast())
		}

		Set {
			this.SetTextContrast(value)

			return (value)
		}
	}

	;* graphics.GetTextContrast()
	GetTextContrast() {
		Local

		if (status := DllCall("Gdiplus\GdipGetTextContrast", "Ptr", this.Ptr, "UInt*", contrast := 0, "Int")) {
			throw (Exception(FormatStatus(status)))
		}

		return (contrast)
	}

	;* graphics.SetTextContrast(contrast)
	;* Parameter:
		;* contrast - A number between 0 and 12, which defines the value of contrast used for antialiasing text.
	SetTextContrast(contrast) {
		Local

		if (status := DllCall("Gdiplus\GdipSetTextContrast", "Ptr", this.Ptr, "UInt", contrast, "Int")) {
			throw (Exception(FormatStatus(status)))
		}

		return (True)
	}

	TextRenderingHint[] {
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
		;* * - See TextRenderingHint enumeration.
	GetTextRenderingHint() {
		Local

		if (status := DllCall("Gdiplus\GdipGetTextRenderingHint", "Ptr", this.Ptr, "UInt*", hint := 0, "Int")) {
			throw (Exception(FormatStatus(status)))
		}

		return (hint)
	}

	;* graphics.SetTextRenderingHint(hint)
	;* Parameter:
		;* hint - See TextRenderingHint enumeration.
	SetTextRenderingHint(hint) {
		Local

		if (status := DllCall("Gdiplus\GdipSetTextRenderingHint", "Ptr", this.Ptr, "UInt", hint, "Int")) {
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

		if (status := DllCall("Gdiplus\GdipGetWorldTransform", "Ptr", this.Ptr, "Ptr*", pMatrix := 0, "Int")) {
			throw (Exception(FormatStatus(status)))
		}

		return ({"Ptr": pMatrix
			, "Base": GDIp.__Matrix})
	}

	SetTransform(matrix) {
		Local

		if (status := DllCall("Gdiplus\GdipSetWorldTransform", "Ptr", this.Ptr, "Ptr", matrix.Ptr, "Int")) {
			throw (Exception(FormatStatus(status)))
		}

		return (True)
	}

	;--------------- Method -------------------------------------------------------;
	;------------------------------------------------------  Control  --------------;

	Restore(state := 0) {
		Local

		if (status := DllCall("Gdiplus\GdipRestoreGraphics", "Ptr", this.Ptr, "UInt", (state) ? (state) : (this.Remove("LastState")), "Int")) {
			throw (Exception(FormatStatus(status)))
		}

		return (state)
	}

	Save() {
		Local

		if (status := DllCall("Gdiplus\GdipSaveGraphics", "Ptr", this.Ptr, "UInt*", state := 0, "Int")) {
			throw (Exception(FormatStatus(status)))
		}

		return (this.LastState := state)
	}

	;* graphics.Flush(intention)
	;* Parameter:
		;* intention - See FlushIntention enumeration.
	Flush(intention) {
		Local

		if (status := DllCall("Gdiplus\GdipFlush", "Ptr", this.Ptr, "Int", intention, "Int")) {
			throw (Exception(FormatStatus(status)))
		}

		return (True)
	}

	Clear(color := 0x00000000) {
		Local

		if (status := DllCall("Gdiplus\GdipGraphicsClear", "Ptr", this.Ptr, "UInt", color, "Int")) {
			throw (Exception(FormatStatus(status)))
		}

		return (True)
	}

	;-----------------------------------------------------  Transform  -------------;

	;* graphics.TranslateTransform(x, y[, matrixOrder])
	;* Parameter:
		;* matrixOrder - See MatrixOrder enumeration.
	TranslateTransform(x, y, matrixOrder := 0) {
		Local

		if (status := DllCall("Gdiplus\GdipTranslateWorldTransform", "Ptr", this.Ptr, "Float", x, "Float", y, "Int", matrixOrder, "Int")) {
			throw (Exception(FormatStatus(status)))
		}

		return (True)
	}

	;* graphics.RotateTransform(angle[, matrixOrder])
	;* Parameter:
		;* angle - Angle of rotation in degrees.
		;* matrixOrder - See MatrixOrder enumeration.
	RotateTransform(angle, matrixOrder := 0) {
		Local

		if (status := DllCall("Gdiplus\GdipRotateWorldTransform", "Ptr", this.Ptr, "Float", angle, "Int", matrixOrder, "Int")) {
			throw (Exception(FormatStatus(status)))
		}

		return (True)
	}

	;* graphics.MultiplyTransform([__Matrix] matrix[, matrixOrder])
	;* Parameter:
		;* matrixOrder - See MatrixOrder enumeration.
	MultiplyTransform(matrix, matrixOrder := 0) {
		Local

		if (status := DllCall("Gdiplus\GdipMultiplyWorldTransform", "Ptr", this.Ptr, "Ptr", matrix.Ptr, "Int", matrixOrder, "Int")) {
			throw (Exception(FormatStatus(status)))
		}

		return (True)
	}

	;* graphics.ScaleTransform(x, y[, matrixOrder])
	;* Parameter:
		;* matrixOrder - See MatrixOrder enumeration.
	ScaleTransform(x, y, matrixOrder := 0) {
		Local

		if (status := DllCall("Gdiplus\GdipScaleWorldTransform", "Ptr", this.Ptr, "Float", x, "Float", y, "Int", matrixOrder, "Int")) {
			throw (Exception(FormatStatus(status)))
		}

		return (True)
	}

	ResetTransform() {
		Local

		if (status := DllCall("Gdiplus\GdipResetWorldTransform", "Ptr", this.Ptr, "Int")) {
			throw (Exception(FormatStatus(status)))
		}

		return (True)
	}

	;------------------------------------------------------- Bitmap ---------------;

	;* graphics.DrawBitmap([__Bitmap] bitmap[, [__Rect] destinationObject, [__Rect] sourceObject, unit, [__ImageAttributes] imageAttributes])
	;* Parameter:
		;* unit - See Unit enumeration.
	DrawBitmap(bitmap, destinationObject := "", sourceObject := "", unit := 2, imageAttributes := "") {
		Local

		if (status := (sourceObject)
			? (DllCall("Gdiplus\GdipDrawImageRectRect", "Ptr", this.Ptr, "Ptr", bitmap.Ptr, "Float", destinationObject.x, "Float", destinationObject.y, "Float", destinationObject.Width, "Float", destinationObject.Height, "Float", sourceObject.x, "Float", sourceObject.y, "Float", sourceObject.Width, "Float", sourceObject.Height, "Int", unit, "Ptr", imageAttributes.Ptr, "Ptr", 0, "Ptr", 0, "Int"))
			: ((destinationObject)
				? (DllCall("Gdiplus\GdipDrawImageRect", "Ptr", this.Ptr, "Ptr", bitmap.Ptr, "Float", destinationObject.x, "Float", destinationObject.y, "Float", destinationObject.Width, "Float", destinationObject.Height, "Int"))
				: (DllCall("Gdiplus\GdipDrawImage", "Ptr", this.Ptr, "Ptr", bitmap.Ptr, "Float", 0, "Float", 0, "Int")))) {
			throw (Exception(FormatStatus(status)))
		}

		return (True)
	}

	;* graphics.DrawCachedBitmap([__CachedBitmap] bitmap[, [__Vec2] object])
	DrawCachedBitmap(bitmap, object := "") {
		Local

		if (status := DllCall("Gdiplus\GdipDrawCachedBitmap", "Ptr", this.Ptr, "Ptr", bitmap.Ptr, "Int", object.x, "Int", object.y, "Int")) {
			throw (Exception(FormatStatus(status)))
		}

		return (True)
	}

	;-------------------------------------------------------- Fill ----------------;

	;* graphics.FillClosedCurve([__Pen] brush, [__Vec2] objects*[, tension, mode])
	;* Parameter:
		;* tension - Non-negative real number that specifies how tightly the spline bends as it passes through the points.
		;* mode - See FillMode enumeration.
	FillClosedCurve(brush, objects*) {
		Local index, object, points, status

		if (objects[index := objects.MaxIndex()].IsNumber()) {
			if (objects[index - 1].IsNumber()) {
				Local mode := objects.Remove(index)
					, tension := objects.Remove(index - 1)
			}
			else {
				Local tension := objects.Remove(index)
			}
		}

		for index, object in (objects, points := new Structure(objects.Length()*8)) {
			points.NumPut((index - 1)*8, "Float", object.x, "Float", object.y)
		}

		if (status := (tension)
			? (DllCall("Gdiplus\GdipFillClosedCurve2", "Ptr", this.Ptr, "Ptr", brush.Ptr, "Ptr", points.Ptr, "UInt", index, "Float", tension, "UInt", mode, "Int"))
			: (DllCall("Gdiplus\GdipFillClosedCurve", "Ptr", this.Ptr, "Ptr", brush.Ptr, "Ptr", points.Ptr, "UInt", index, "Int"))) {
			throw (Exception(FormatStatus(status)))
		}

		return (True)
	}

	;* graphics.FillEllipse([__Brush] brush, [__Rect] object)
	FillEllipse(brush, object) {
		Local

		if (status := DllCall("Gdiplus\GdipFillEllipse", "Ptr", this.Ptr, "Ptr", brush.Ptr, "Float", object.x, "Float", object.y, "Float", object.Width, "Float", object.Height, "Int")) {
			throw (Exception(FormatStatus(status)))
		}

		return (True)
	}

	;* graphics.FillPath([__Brush] brush, [__Path] path)
	FillPath(brush, object) {
		Local

		if (status := DllCall("Gdiplus\GdipFillPath", "Ptr", this.Ptr, "Ptr", brush.Ptr, "Ptr", path.Ptr, "Int")) {
			throw (Exception(FormatStatus(status)))
		}

		return (True)
	}

	;* graphics.FillPie([__Brush] brush, [__Rect] object, startAngle, sweepAngle)
	FillPie(brush, object, startAngle, sweepAngle) {
		Local

		if (status := DllCall("Gdiplus\GdipFillPie", "Ptr", this.Ptr, "Ptr", brush.Ptr, "Float", object.x, "Float", object.y, "Float", object.Width, "Float", object.Height, "Float", startAngle, "Float", sweepAngle, "Int")) {
			throw (Exception(FormatStatus(status)))
		}

		return (True)
	}

	;* graphics.FillPolygon([__Brush] brush, [__Vec2] objects*[, mode])
	;* Parameter:
		;* mode - See FillMode enumeration.
	FillPolygon(brush, objects*) {
		Local index, object, points, status

		if (objects[index := objects.MaxIndex()].IsNumber()) {
			Local mode := objects.Remove(index)
		}

		for index, object in (objects, points := new Structure(objects.Length()*8)) {
			points.NumPut((index - 1)*8, "Float", object.x, "Float", object.y)
		}

		if (status := DllCall("Gdiplus\GdipFillPolygon", "Ptr", this.Ptr, "Ptr", brush.Ptr, "Ptr", points.Ptr, "Int", index, "UInt", mode, "Int")) {
			throw (Exception(FormatStatus(status)))
		}

		return (True)
	}

	;* graphics.FillRectangle([__Brush] brush, [__Rect] object)
	FillRectangle(brush, object) {
		Local

		if (status := DllCall("Gdiplus\GdipFillRectangle", "Ptr", this.Ptr, "Ptr", brush.Ptr, "Float", object.x, "Float", object.y, "Float", object.Width, "Float", object.Height, "Int")) {
			throw (Exception(FormatStatus(status)))
		}

		return (True)
	}

	;* graphics.FillRegion([__Brush] brush, [__Region] region)
	FillRegion(brush, object) {
		Local

		if (status := DllCall("Gdiplus\GdipFillRegion", "Ptr", this.Ptr, "Ptr", brush.Ptr, "Ptr", region.Ptr, "Int")) {
			throw (Exception(FormatStatus(status)))
		}

		return (True)
	}

	;-------------------------------------------------------- Draw ----------------;

	;* graphics.DrawArc([__Pen] pen, [__Rect] object, startAngle, sweepAngle)
	DrawArc(pen, object, startAngle, sweepAngle) {
		Local

		if (status := DllCall("Gdiplus\GdipDrawArc", "Ptr", this.Ptr, "Ptr", pen.Ptr, "Float", object.x, "Float", object.y, "Float", object.Width - (width := pen.Width), "Float", object.Height - width, "Float", startAngle, "Float", sweepAngle, "Int")) {
			throw (Exception(FormatStatus(status)))
		}

		return (True)
	}

	;* graphics.DrawBezier([__Pen] pen, [__Vec2] object1, [__Vec2] object2, [__Vec2] object3, [__Vec2] object4)
	DrawBezier(pen, object1, object2, object3, object4) {
		Local

		if (status := DllCall("gdiplus\GdipDrawBezier", "Ptr", this.Ptr, "Ptr", pen.Ptr, "Float", object1.x, "Float", object1.y, "Float", object2.x, "Float", object2.y, "Float", object3.x, "Float", object3.y, "Float", object4.x, "Float", object4.y, "Int")) {
			throw (Exception(FormatStatus(status)))
		}

		return (True)
	}

	;* graphics.DrawBeziers([__Pen] pen, [__Vec2] objects*)
	DrawBeziers(pen, objects*) {
		Local index, object, points, status

		for index, object in (objects, points := new Structure(objects.Length()*8)) {
			points.NumPut((index - 1)*8, "Float", object.x, "Float", object.y)
		}

		if (status := DllCall("Gdiplus\GdipDrawBeziers", "Ptr", this.Ptr, "Ptr", pen.Ptr, "Ptr", points.Ptr, "UInt", index, "Int")) {  ;* The start point for any bezier after the first is implicit, therefore the points array would have the following structure: 4 + 3 + 3...
			throw (Exception(FormatStatus(status)))
		}

		return (True)
	}

	;* graphics.DrawClosedCurve([__Pen] pen, [__Vec2] objects*[, tension])
	;* Parameter:
		;* tension - Non-negative real number that specifies how tightly the spline bends as it passes through the points.
	DrawClosedCurve(pen, objects*) {
		Local index, object, points, status

		if (objects[index := objects.MaxIndex()].IsNumber()) {
			Local tension := objects.Remove(index)
		}

		for index, object in (objects, points := new Structure(objects.Length()*8)) {
			points.NumPut((index - 1)*8, "Float", object.x, "Float", object.y)
		}

		if (status := (tension)
			? (DllCall("Gdiplus\GdipDrawClosedCurve2", "Ptr", this.Ptr, "Ptr", pen.Ptr, "Ptr", points.Ptr, "UInt", index, "Float", tension, "Int"))
			: (DllCall("Gdiplus\GdipDrawClosedCurve", "Ptr", this.Ptr, "Ptr", pen.Ptr, "Ptr", points.Ptr, "UInt", index, "Int"))) {
			throw (Exception(FormatStatus(status)))
		}

		return (True)
	}

	;* graphics.DrawCurve([__Pen] pen, [__Vec2] objects*[, tension])
	;* Parameter:
		;* tension - Non-negative real number that specifies how tightly the spline bends as it passes through the points.
	DrawCurve(pen, objects*) {
		Local index, object, points, status

		if (objects[index := objects.MaxIndex()].IsNumber()) {
			Local tension := objects.Remove(index)
		}

		for index, object in (objects, points := new Structure(objects.Length()*8)) {
			points.NumPut((index - 1)*8, "Float", object.x, "Float", object.y)
		}

		if (status := (tension)
			? (DllCall("Gdiplus\GdipDrawCurve2", "Ptr", this.Ptr, "Ptr", pen.Ptr, "Ptr", points.Ptr, "UInt", index, "Float", tension, "Int"))
			: (DllCall("Gdiplus\GdipDrawCurve", "Ptr", this.Ptr, "Ptr", pen.Ptr, "Ptr", points.Ptr, "UInt", index, "Int"))) {
			throw (Exception(FormatStatus(status)))
		}

		return (True)
	}

	;* graphics.DrawEllipse([__Pen] pen, [__Rect] object)
	DrawEllipse(pen, object) {
		Local

		if (status := DllCall("Gdiplus\GdipDrawEllipse", "Ptr", this.Ptr, "Ptr", pen.Ptr, "Float", object.x, "Float", object.y, "Float", object.Width - (width := pen.Width), "Float", object.Height - width, "Int")) {
			throw (Exception(FormatStatus(status)))
		}

		return (True)
	}

	;* graphics.DrawLine([__Pen] pen, [__Vec2] object1, [__Vec2] object2)
	DrawLine(pen, object1, object2) {
		Local

		if (status := DllCall("Gdiplus\GdipDrawLine", "Ptr", this.Ptr, "Ptr", pen.Ptr, "Float", object1.x, "Float", object1.y, "Float", object2.x, "Float", object2.y, "Int")) {
			throw (Exception(FormatStatus(status)))
		}

		return (True)
	}

	;* graphics.DrawLine([__Pen] pen, [__Vec2] objects*)
	DrawLines(pen, objects*) {
		Local index, object, points, status

		for index, object in (objects, points := new Structure(objects.Length()*8)) {
			points.NumPut((index - 1)*8, "Float", object.x, "Float", object.y)
		}

		if (status := DllCall("Gdiplus\GdipDrawLines", "Ptr", this.Ptr, "Ptr", pen.Ptr, "Ptr", points.Ptr, "UInt", index, "Int")) {
			throw (Exception(FormatStatus(status)))
		}

		return (True)
	}

	;* graphics.DrawPie([__Pen] pen, [__Rect] object, startAngle, sweepAngle)
	DrawPie(pen, object, startAngle, sweepAngle) {
		Local

		if (status := DllCall("Gdiplus\GdipDrawPie", "Ptr", this.Ptr, "Ptr", pen.Ptr, "Float", object.x, "Float", object.y, "Float", object.Width - (width := pen.Width), "Float", object.Height - width, "Float", startAngle, "Float", sweepAngle, "Int")) {
			throw (Exception(FormatStatus(status)))
		}

		return (True)
	}

	;* graphics.DrawPolygon([__Pen] pen, [__Vec2] objects*)
	DrawPolygon(pen, objects*) {
		Local index, object, points, status

		for index, object in (objects, points := new Structure(objects.Length()*8)) {
			points.NumPut((index - 1)*8, "Float", object.x, "Float", object.y)
		}

		if (status := DllCall("Gdiplus\GdipDrawPolygon", "Ptr", this.Ptr, "Ptr", pen.Ptr, "Ptr", points.Ptr, "UInt", index, "Int")) {
			throw (Exception(FormatStatus(status)))
		}

		return (True)
	}

	;* graphics.DrawRectangle([__Pen] pen, [__Rect] object)
	DrawRectangle(pen, object) {
		Local

		if (status := DllCall("Gdiplus\GdipDrawRectangle", "Ptr", this.Ptr, "Ptr", pen.Ptr, "Float", object.x, "Float", object.y, "Float", object.Width - (width := pen.Width), "Float", object.Height - width, "Int")) {
			throw (Exception(FormatStatus(status)))
		}

		return (True)
	}
}