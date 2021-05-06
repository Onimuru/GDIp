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

	;* graphics.CreatePtr(width, height)
	CreatePtr(width, height) {
		Local

		if (status := DllCall("Gdiplus\GdipCreateBitmapFromGraphics", "Int", width, "Int", height, "Ptr", this.Ptr, "Ptr*", pBitmap := 0, "Int")) {
			throw (Exception(FormatStatus(status)))
		}

		return (pBitmap)
	}

	;-------------- Property ------------------------------------------------------;

	CompositingMode[] {
		Set {
			return (value, this.SetCompositingMode(value))
		}
	}

	;* graphics.SetCompositingMode(mode)
	;* Parameter:
		;* mode:
			;? 0: SourceOver (blend)
			;? 1: SourceCopy (overwrite)
	SetCompositingMode(mode := 0) {
		Local

		if (status := DllCall("Gdiplus\GdipSetCompositingMode", "Ptr", this.Ptr, "Int", mode, "Int")) {
			throw (Exception(FormatStatus(status)))
		}

		return (True)
	}

	InterpolationMode[] {
		Set {
			return (value, this.SetInterpolationMode(value))
		}
	}

	;* graphics.SetInterpolationMode(mode)
	;* Parameter:
		;* mode:
			;? 0: Default
			;? 1: LowQuality
			;? 2: HighQuality
			;? 3: Bilinear
			;? 4: Bicubic
			;? 5: NearestNeighbor
			;? 6: HighQualityBilinear
			;? 7: HighQualityBicubic
	SetInterpolationMode(mode := 0) {
		Local

		if (status := DllCall("Gdiplus\GdipSetInterpolationMode", "Ptr", this.Ptr, "Int", mode, "Int")) {
			throw (Exception(FormatStatus(status)))
		}

		return (True)
	}

	SmoothingMode[] {
		Set {
			return (value, this.SetSmoothingMode(value))
		}
	}

	;* graphics.SetSmoothingMode(mode)
	;* Parameter:
		;* mode:
			;? 0: Default
			;? 1: HighSpeed
			;? 2: HighQuality
			;? 3: None
			;? 4: AntiAlias
	SetSmoothingMode(mode := 0) {
		Local

		if (status := DllCall("Gdiplus\GdipSetSmoothingMode", "Ptr", this.Ptr, "Int", mode, "Int")) {
			throw (Exception(FormatStatus(status)))
		}

		return (True)
	}

	TextRenderingHint[] {
		Set {
			return (value, this.SetTextRenderingHint(value))
		}
	}

	;* graphics.SetTextRenderingHint(hint)
	;* Parameter:
		;* hint:
			;? 0: SystemDefault
			;? 1: SingleBitPerPixelGridFit
			;? 2: SingleBitPerPixel
			;? 3: AntiAliasGridFit
			;? 4: AntiAlias
			;? 5: ClearTypeGridFit
	SetTextRenderingHint(hint := 0) {
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

	;* graphics.SetTextRenderingHint(hint)
	;* Parameter:
		;* intent:
			;? 0: Flush all batched rendering operations and return immediately
			;? 1: Flush all batched rendering operations and wait for them to complete
	Flush(intent) {
		Local

		if (status := DllCall("Gdiplus\GdipFlush", "Ptr", this.Ptr, "Int", intent, "Int")) {
			throw (Exception(FormatStatus(status)))
		}

		return (True)
	}

	;--------------------------------------------------  World Transform  ----------;

	;* graphics.Translate(x, y)
	Translate(x, y) {
		Local

		if (status := DllCall("Gdiplus\GdipTranslateWorldTransform", "Ptr", this.Ptr, "Float", x, "Float", y, "Int", 1, "Int")) {
			throw (Exception(FormatStatus(status)))
		}

		return (True)
	}

	;* graphics.Rotate(angle[, x, y]))
	Rotate(angle, x := "", y := "") {
		if (x == "" || y == "") {
			if (status := DllCall("Gdiplus\GdipRotateWorldTransform", "Ptr", this.Ptr, "Float", angle, "Int", 1, "Int")) {
				throw (Exception(FormatStatus(status)))
			}
		}
		else {
			if (status := DllCall("Gdiplus\GdipTranslateWorldTransform", "Ptr", this.Ptr, "Float", -x, "Float", -y, "Int", 1, "Int")) {
				throw (Exception(FormatStatus(status)))
			}

			if (status := DllCall("Gdiplus\GdipRotateWorldTransform", "Ptr", this.Ptr, "Float", angle, "Int", 1, "Int")) {
				throw (Exception(FormatStatus(status)))
			}

			if (status := DllCall("Gdiplus\GdipTranslateWorldTransform", "Ptr", this.Ptr, "Float", x, "Float", y, "Int", 1, "Int")) {
				throw (Exception(FormatStatus(status)))
			}
		}

		return (True)
	}

	Reset() {
		if (status := DllCall("Gdiplus\GdipResetWorldTransform", "Ptr", this.Ptr, "Int")) {
			throw (Exception(FormatStatus(status)))
		}

		return (True)
	}

	Scale(x, y) {
		if (status := DllCall("Gdiplus\GdipScaleWorldTransform", "Ptr", this.Ptr, "Float", x, "Float", y, "Int", 1, "Int")) {
			throw (Exception(FormatStatus(status)))
		}

		return (True)
	}

	;------------------------------------------------------- Bitmap ---------------;

	DrawBitmap(bitmap, destinationRect := "", sourceRect := "", unit := 2, imageAttributes := "") {
		Local

		if (status := (sourceRect)
			? (DllCall("Gdiplus\GdipDrawImageRectRect", "Ptr", this.Ptr, "Ptr", bitmap.Ptr, "Float", destinationRect.x, "Float", destinationRect.y, "Float", destinationRect.Width, "Float", destinationRect.Height, "Float", sourceRect.x, "Float", sourceRect.y, "Float", sourceRect.Width, "Float", sourceRect.Height, "Int", unit, "Ptr", imageAttributes.Ptr, "Ptr", 0, "Ptr", 0, "Int"))
			: ((destinationRect)
				? (DllCall("Gdiplus\GdipDrawImageRect", "Ptr", this.Ptr, "Ptr", bitmap.Ptr, "Float", destinationRect.x, "Float", destinationRect.y, "Float", destinationRect.Width, "Float", destinationRect.Height, "Int"))
				: (DllCall("Gdiplus\GdipDrawImageRect", "Ptr", this.Ptr, "Ptr", bitmap.Ptr, "Float", 0, "Float", 0, "Float", bitmap.Width, "Float", bitmap.Height, "Int")))) {
			throw (Exception(FormatStatus(status)))
		}

		return (True)
	}

	;-------------------------------------------------------- Fill ----------------;

	;* graphics.FillEllipse([Brush] brush, [Rect] object)
	FillEllipse(brush, object) {
		Local

		if (status := DllCall("Gdiplus\GdipFillEllipse", "Ptr", this.Ptr, "Ptr", brush.Ptr, "Float", object.x, "Float", object.y, "Float", object.Width, "Float", object.Height, "Int")) {
			throw (Exception(FormatStatus(status)))
		}

		return (True)
	}

	;* graphics.FillPie([Brush] brush, [Rect] object, startAngle, sweepAngle)
	FillPie(brush, object, startAngle, sweepAngle) {
		Local

		if (status := DllCall("Gdiplus\GdipFillPie", "Ptr", this.Ptr, "Ptr", brush.Ptr, "Float", object.x, "Float", object.y, "Float", object.Width, "Float", object.Height, "Float", startAngle, "Float", sweepAngle, "Int")) {
			throw (Exception(FormatStatus(status)))
		}

		return (True)
	}

	;* graphics.FillRectangle([Brush] brush, [Rect] object)
	FillRectangle(brush, object) {
		Local

		if (status := DllCall("Gdiplus\GdipFillRectangle", "Ptr", this.Ptr, "Ptr", brush.Ptr, "Float", object.x, "Float", object.y, "Float", object.Width, "Float", object.Height, "Int")) {
			throw (Exception(FormatStatus(status)))
		}

		return (True)
	}

	;-------------------------------------------------------- Draw ----------------;

	DrawArc(pen, object, startAngle, sweepAngle) {
		Local

		if (status := DllCall("Gdiplus\GdipDrawArc", "Ptr", this.Ptr, "Ptr", pen.Ptr, "Float", object.x, "Float", object.y, "Float", object.Width - (width := pen.Width), "Float", object.Height - width, "Float", startAngle, "Float", sweepAngle, "Int")) {
			throw (Exception(FormatStatus(status)))
		}

		return (True)
	}

	DrawBezier(pen, objects1, objects2, objects3, objects4) {
		Local

		if (status := DllCall("gdiplus\GdipDrawBezier", "Ptr", this.Ptr, "Ptr", pen.Ptr, "Float", objects1.x, "Float", objects1.y, "Float", objects2.x, "Float", objects2.y, "Float", objects3.x, "Float", objects3.y, "Float", objects4.x, "Float", objects4.y, "Int")) {
			throw (Exception(FormatStatus(status)))
		}

		return (True)
	}

	;* graphics.DrawEllipse(([Pen] pen, [Rect] object)
	DrawEllipse(pen, object) {
		Local

		if (status := DllCall("Gdiplus\GdipDrawEllipse", "Ptr", this.Ptr, "Ptr", pen.Ptr, "Float", object.x, "Float", object.y, "Float", object.Width - (width := pen.Width), "Float", object.Height - width, "Int")) {
			throw (Exception(FormatStatus(status)))
		}

		return (True)
	}

	;* graphics.DrawRectangle([Pen] pen, [Rect] object)
	DrawRectangle(pen, object) {
		Local

		if (status := DllCall("Gdiplus\GdipDrawRectangle", "Ptr", this.Ptr, "Ptr", pen.Ptr, "Float", object.x, "Float", object.y, "Float", object.Width - (width := pen.Width), "Float", object.Height - width, "Int")) {
			throw (Exception(FormatStatus(status)))
		}

		return (True)
	}

	;* graphics.DrawLine([Pen] pen, [Vec2] object1, [Vec2] object2)
	DrawLine(pen, object1, object2) {
		Local

		if (status := DllCall("Gdiplus\GdipDrawLine", "Ptr", this.Ptr, "Ptr", pen.Ptr, "Float", object1.x, "Float", object1.y, "Float", object2.x, "Float", object2.y, "Int")) {
			throw (Exception(FormatStatus(status)))
		}

		return (True)
	}
}