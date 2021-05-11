/*
;* FillMode enumeration (https://docs.microsoft.com/en-us/windows/win32/api/gdiplusenums/ne-gdiplusenums-fillmode)
	;? 0 = FillModeAlternate
	;? 1 = FillModeWinding
*/

;* GDIp.CreatePath([fillMode])
;* Parameter:
	;* fillMode - See FillMode enumeration.
CreatePath(fillMode := 0) {
	Local

	if (status := DllCall("Gdiplus\GdipCreatePath", "Int", fillMode, "Ptr*", pPath := 0, "Int")) {
		throw (Exception(FormatStatus(status)))
	}

	return ({"Ptr": pPath
		, "Base": this.__Path})
}

Class __Path {

	__Delete() {
		if (!this.HasKey("Ptr")) {
			MsgBox("Path.__Delete()")
		}

		DllCall("Gdiplus\GdipDeletePath", "Ptr", this.Ptr)
	}

	;-------------- Property ------------------------------------------------------;

	FillMode[] {
		Get {
			return (this.GetFillMode())
		}

		Set {
			this.SetFillMode(value)

			return (value)
		}
	}

	;* path.GetFillMode()
	;* Return:
		;* * - See FillMode enumeration.
	GetFillMode() {
		Local

		if (status := DllCall("Gdiplus\GdipGetPathFillMode", "Ptr", this.Ptr, "Int*", fillMode := 0, "Int")) {
			throw (Exception(FormatStatus(status)))
		}

		return (fillMode)
	}

	;* path.SetFillMode()
	;* Parameter:
		;* fillMode - See FillMode enumeration.
	SetFillMode(fillMode) {
		Local

		if (status := DllCall("Gdiplus\GdipSetPathFillMode", "Ptr", this.Ptr, "Int", fillMode, "Int")) {
			throw (Exception(FormatStatus(status)))
		}

		return (True)
	}

	LastPoint[] {
		Get {
			return (this.GetLastPoint())
		}
	}

	;* path.GetLastPoint()
	GetLastPoint() {
		Local

		Static point := CreatePoint(0, 0, "Float")

		if (status := DllCall("Gdiplus\GdipGetPathLastPoint", "Ptr", this.Ptr, "Ptr", point.Ptr, "Int")) {
			throw (Exception(FormatStatus(status)))
		}

		return ({"x": point.NumGet(0, "Float"), "y": point.NumGet(4, "Float")})
	}

	PointCount[] {
		Get {
			return (this.GetPointCount())
		}
	}

	;* path.GetPointCount()
	GetPointCount() {
		Local

		if (status := DllCall("Gdiplus\GdipGetPointCount", "Ptr", this.Ptr, "Int*", count := 0, "Int")) {
			throw (Exception(FormatStatus(status)))
		}

		return (count)
	}

	Points[] {
		Get {
			return (this.GetPoints())
		}
	}

	;* path.GetPoints()
	GetPoints() {
		Local count, struct, status, array, offset

		count := this.GetPointCount()
			, struct := new Structure(count*8)

		if (status := DllCall("Gdiplus\GdipGetPathPoints", "Ptr", this.Ptr, "Ptr", struct.Ptr, "Int*", count, "Int")) {
			throw (Exception(FormatStatus(status)))
		}

		loop, % (count, array := []) {
			offset := (A_Index - 1)*8
				, array.Push({"x": struct.NumGet(offset, "Float"), "y": struct.NumGet(offset + 4, "Float")})
		}

		return (array)
	}

	;--------------- Method -------------------------------------------------------;
	;------------------------------------------------------  Control  --------------;

	Flatten(flatness, matrix := 0) {
		Local

		if (status := DllCall("Gdiplus\GdipFlattenPath", "Ptr", this.Ptr, "Ptr", matrix.Ptr, "Float", flatness, "Int")) {
			throw (Exception(FormatStatus(status)))
		}

		return (True)
	}

	Reverse() {
		Local

		if (status := DllCall("Gdiplus\GdipReversePath", "Ptr", this.Ptr, "Int")) {
			throw (Exception(FormatStatus(status)))
		}

		return (True)
	}

	Widen(pen, matrix := 0, flatness := 1.0) {
		Local

		if (status := DllCall("Gdiplus\GdipWidenPath", "Ptr", this.Ptr, "Ptr", pen.Ptr, "Ptr", matrix.Ptr, "Float", flatness, "Int")) {
			throw (Exception(FormatStatus(status)))
		}

		return (True)
	}

	Reset() {
		Local

		if (status := DllCall("Gdiplus\GdipResetPath", "Ptr", this.Ptr, "Int")) {
			throw (Exception(FormatStatus(status)))
		}

		return (True)
	}

	;--------------------------------------------------------  Add  ----------------;

	;* path.AddClosedCurve([__Vec2] objects*[, tension])
	;* Parameter:
		;* tension - Non-negative real number that specifies how tightly the spline bends as it passes through the points.
	AddClosedCurve(objects*) {
		Local index, object, points, status

		if (objects[index := objects.MaxIndex()].IsNumber()) {
			Local tension := objects.Remove(index)
		}

		for index, object in (objects, points := new Structure(objects.Length()*8)) {
			points.NumPut((index - 1)*8, "Float", object.x, "Float", object.y)
		}

		if (status := (tension)
			? (DllCall("Gdiplus\GdipAddPathClosedCurve2", "Ptr", this.Ptr, "Ptr", points.Ptr, "UInt", index, "Float", tension, "Int"))
			: (DllCall("Gdiplus\GdipAddPathClosedCurve", "Ptr", this.Ptr, "Ptr", points.Ptr, "UInt", index, "Int"))) {
			throw (Exception(FormatStatus(status)))
		}

		return (True)
	}

	;* path.AddCurve([__Vec2] objects*[, tension])
	;* Parameter:
		;* tension - Non-negative real number that specifies how tightly the spline bends as it passes through the points.
	AddCurve(objects*) {
		Local index, object, points, status

		if (objects[index := objects.MaxIndex()].IsNumber()) {
			Local tension := objects.Remove(index)
		}

		for index, object in (objects, points := new Structure(objects.Length()*8)) {
			points.NumPut((index - 1)*8, "Float", object.x, "Float", object.y)
		}

		if (status := (tension)
			? (DllCall("Gdiplus\GdipAddPathCurve2", "Ptr", this.Ptr, "Ptr", points.Ptr, "UInt", index, "Float", tension, "Int"))
			: (DllCall("Gdiplus\GdipAddPathCurve", "Ptr", this.Ptr, "Ptr", points.Ptr, "UInt", index, "Int"))) {
			throw (Exception(FormatStatus(status)))
		}

		return (True)
	}

	AddEllipse(object) {
		Local

		if (status := DllCall("Gdiplus\GdipAddPathEllipse", "Ptr", this.Ptr, "Float", object.x, "Float", object.y, "Float", object.width, "Float", object.height, "Int")) {
			throw (Exception(FormatStatus(status)))
		}

		return (True)
	}

	AddPolygon(objects*) {
		Local index, object, points, status

		for index, object in (objects, points := new Structure(objects.Length()*8)) {
			points.NumPut((index - 1)*8, "Float", object.x, "Float", object.y)
		}

		if (status := DllCall("Gdiplus\GdipAddPathPolygon", "Ptr", this.Ptr, "Ptr", points.Ptr, "Int", index, "Int")) {
			throw (Exception(FormatStatus(status)))
		}

		return (True)
	}

	AddRectangle(object) {
		Local

		if (status := DllCall("Gdiplus\GdipAddPathRectangle", "Ptr", this.Ptr, "Float", object.x, "Float", object.y, "Float", object.width, "Float", object.height, "Int")) {
			throw (Exception(FormatStatus(status)))
		}

		return (True)
	}
}