/*
;* CompositingMode enumeration (https://docs.microsoft.com/en-us/windows/win32/api/gdiplusenums/ne-gdiplusenums-compositingmode)
	;? 0 = CompositingModeSourceOver - Specifies that when a color is rendered, it overwrites the background color.
	;? 1 = CompositingModeSourceCopy - Specifies that when a color is rendered, it is blended with the background color. The blend is determined by the alpha component of the color being rendered.

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

CreateGraphicsFromHWND(hWnd, useICM := 0) {
	Local

	if (status := DllCall("Gdiplus\" . (useICM) ? ("GdipCreateFromHWNDICM") : ("GdipCreateFromHWND"), "Ptr", hWnd, "Ptr*", pGraphics := 0, "Int")) {
		throw (Exception(FormatStatus(status)))
	}

	return ({"Ptr": pGraphics
		, "Base": this.__Graphics})
}

Class __Graphics {

	__Delete() {
		if (!this.Ptr) {
			MsgBox("Graphics.__Delete()")
		}

		DllCall("Gdiplus\GdipDeleteGraphics", "Ptr", this.Ptr)
	}

	;-------------- Property ------------------------------------------------------;

	CompositingMode[] {
		Set {
			this.SetCompositingMode(value)

			return (value)
		}
	}

	;* graphics.SetCompositingMode(mode)
	;* Parameter:
		;* mode - See CompositingMode enumeration.
	SetCompositingMode(mode) {
		Local

		if (status := DllCall("Gdiplus\GdipSetCompositingMode", "Ptr", this.Ptr, "UInt", mode, "Int")) {
			throw (Exception(FormatStatus(status)))
		}

		return (True)
	}

	InterpolationMode[] {
		Set {
			this.SetInterpolationMode(value)

			return (value)
		}
	}

	;* graphics.SetInterpolationMode(mode)
	;* Parameter:
		;* mode - See InterpolationMode enumeration.
	SetInterpolationMode(mode) {
		Local

		if (status := DllCall("Gdiplus\GdipSetInterpolationMode", "Ptr", this.Ptr, "UInt", mode, "Int")) {
			throw (Exception(FormatStatus(status)))
		}

		return (True)
	}

	SmoothingMode[] {
		Set {
			this.SetSmoothingMode(value)

			return (value)
		}
	}

	;* graphics.SetSmoothingMode(mode)
	;* Parameter:
		;* mode - See SmoothingMode enumeration.
	SetSmoothingMode(mode) {
		Local

		if (status := DllCall("Gdiplus\GdipSetSmoothingMode", "Ptr", this.Ptr, "UInt", mode, "Int")) {
			throw (Exception(FormatStatus(status)))
		}

		return (True)
	}

	TextRenderingHint[] {
		Set {
			this.SetTextRenderingHint(value)

			return (value)
		}
	}

	;* graphics.SetTextRenderingHint(hint)
	;* Parameter:
		;* hint - See TextRenderingHint enumeration.
	SetTextRenderingHint(hint) {
		Local

		if (status := DllCall("Gdiplus\GdipSetTextRenderingHint", "Ptr", this.Ptr, "Int", hint, "Int")) {
			throw (Exception(FormatStatus(status)))
		}

		return (True)
	}

	;--------------- Method -------------------------------------------------------;
	;------------------------------------------------------  Control  --------------;

	Clear(color := 0x00000000) {
		Local

		if (status := DllCall("Gdiplus\GdipGraphicsClear", "Ptr", this.Ptr, "UInt", color, "Int")) {
			throw (Exception(FormatStatus(status)))
		}

		return (True)
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

	;------------------------------------------------------- Bitmap ---------------;

	;* graphics.DrawBitmap([__Bitmap] bitmap[, [__Rect] destinationRect, [__Rect] sourceRect, unit, imageAttributes])
	;* Parameter:
		;* unit - See Unit enumeration.
	DrawBitmap(bitmap, destinationRect := "", sourceRect := "", unit := 2, imageAttributes := "") {
		Local

		if (status := (sourceRect)
			? (DllCall("Gdiplus\GdipDrawImageRectRect", "Ptr", this.Ptr, "Ptr", bitmap.Ptr, "Float", destinationRect.x, "Float", destinationRect.y, "Float", destinationRect.Width, "Float", destinationRect.Height, "Float", sourceRect.x, "Float", sourceRect.y, "Float", sourceRect.Width, "Float", sourceRect.Height, "Int", unit, "Ptr", imageAttributes.Ptr, "Ptr", 0, "Ptr", 0, "Int"))
			: ((destinationRect)
				? (DllCall("Gdiplus\GdipDrawImageRect", "Ptr", this.Ptr, "Ptr", bitmap.Ptr, "Float", destinationRect.x, "Float", destinationRect.y, "Float", destinationRect.Width, "Float", destinationRect.Height, "Int"))
				: (DllCall("Gdiplus\GdipDrawImage", "Ptr", this.Ptr, "Ptr", bitmap.Ptr, "Float", 0, "Float", 0, "Int")))) {
			throw (Exception(FormatStatus(status)))
		}

		return (True)
	}

	;* graphics.DrawCachedBitmap([__CachedBitmap] cachedBitmap[, [__Vec2] object])
	DrawCachedBitmap(cachedBitmap, object := "") {
		Local

		if (status := DllCall("Gdiplus\GdipDrawCachedBitmap", "Ptr", this.Ptr, "Ptr", cachedBitmap.Ptr, "Int", object.x, "Int", object.y, "Int")) {
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

	;-----------------------------------------------------  Transform  -------------;

	;* graphics.TranslateTransform(x, y)
	TranslateTransform(x, y) {
		Local

		if (status := DllCall("Gdiplus\GdipTranslateWorldTransform", "Ptr", this.Ptr, "Float", x, "Float", y, "Int", 1, "Int")) {
			throw (Exception(FormatStatus(status)))
		}

		return (True)
	}

	;* graphics.RotateTransform(angle[, x, y]))
	RotateTransform(angle, x := "", y := "") {
		Local

		if (x == "" || y == "") {
			if (status := DllCall("Gdiplus\GdipRotateWorldTransform", "Ptr", this.Ptr, "Float", angle, "Int", 1, "Int")) {
				throw (Exception(FormatStatus(status)))
			}
		}
		else {
			this.TranslateTransform(x, y)

			if (status := DllCall("Gdiplus\GdipRotateWorldTransform", "Ptr", this.Ptr, "Float", angle, "Int", 1, "Int")) {
				throw (Exception(FormatStatus(status)))
			}

			this.TranslateTransform(-x, -y)
		}

		return (True)
	}

	ScaleTransform(x, y) {
		Local

		if (status := DllCall("Gdiplus\GdipScaleWorldTransform", "Ptr", this.Ptr, "Float", x, "Float", y, "Int", 1, "Int")) {
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
}