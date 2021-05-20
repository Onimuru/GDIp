/*
;* enum FillMode  ;: https://docs.microsoft.com/en-us/windows/win32/api/gdiplusenums/ne-gdiplusenums-fillmode
	0 = FillModeAlternate
	1 = FillModeWinding
*/

;* GDIp.CreatePath([fillMode])
;* Parameter:
	;* [Integer] fillMode - See FillMode enumeration.
static CreatePath(fillMode := 0) {
	if (status := DllCall("Gdiplus\GdipCreatePath", "Int", fillMode, "Ptr*", &(pPath := 0), "Int")) {
		throw (ErrorFromStatus(status))
	}

	(instance := GDIp.Path()).Ptr := pPath
	return (instance)
}

class Path {

	;* path.Clone()
	Clone() {
		if (status := DllCall("Gdiplus\GdipClonePath", "Ptr", this.Ptr, "Ptr*", &(pPath := 0), "Int")) {
			throw (ErrorFromStatus(status))
		}

		(instance := GDIp.Path()).Ptr := pPath
		return (instance)
	}

	__Delete() {
		if (status := DllCall("Gdiplus\GdipDeletePath", "Ptr", this.Ptr, "Int")) {
			throw (ErrorFromStatus(status))
		}
	}

	;-------------- Property ------------------------------------------------------;

	FillMode {
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
		;* [Integer] - See FillMode enumeration.
	GetFillMode() {
		if (status := DllCall("Gdiplus\GdipGetPathFillMode", "Ptr", this.Ptr, "Int*", &(fillMode := 0), "Int")) {
			throw (ErrorFromStatus(status))
		}

		return (fillMode)
	}

	;* path.SetFillMode()
	;* Parameter:
		;* [Integer] fillMode - See FillMode enumeration.
	SetFillMode(fillMode) {
		if (status := DllCall("Gdiplus\GdipSetPathFillMode", "Ptr", this.Ptr, "Int", fillMode, "Int")) {
			throw (ErrorFromStatus(status))
		}

		return (True)
	}

	LastPoint {
		Get {
			return (this.GetLastPoint())
		}
	}

	;* path.GetLastPoint()
	GetLastPoint() {
		static point := Structure.CreatePoint(0, 0, "Float")

		if (status := DllCall("Gdiplus\GdipGetPathLastPoint", "Ptr", this.Ptr, "Ptr", point.Ptr, "Int")) {
			throw (ErrorFromStatus(status))
		}

		return ({x: point.NumGet(0, "Float"), y: point.NumGet(4, "Float")})
	}

	PointCount {
		Get {
			return (this.GetPointCount())
		}
	}

	;* path.GetPointCount()
	GetPointCount() {
		if (status := DllCall("Gdiplus\GdipGetPointCount", "Ptr", this.Ptr, "Int*", &(count := 0), "Int")) {
			throw (ErrorFromStatus(status))
		}

		return (count)
	}

	Points {
		Get {
			return (this.GetPoints())
		}
	}

	;* path.GetPoints()
	GetPoints() {
		if (status := DllCall("Gdiplus\GdipGetPathPoints", "Ptr", this.Ptr, "Ptr", (struct := Structure(count*8)).Ptr, "Int*", &(count := this.GetPointCount()), "Int")) {
			throw (ErrorFromStatus(status))
		}

		loop (array := [], count) {
			offset := (A_Index - 1)*8
				, array.Push({x: struct.NumGet(offset, "Float"), y: struct.NumGet(offset + 4, "Float")})
		}

		return (array)
	}

	;--------------- Method -------------------------------------------------------;
	;------------------------------------------------------  Control  --------------;

	;* path.SetFillMode(flatness[, matrix])
	;* Parameter:
		;* [Float] flatness
		;* [Matrix] matrix
	Flatten(flatness, matrix := 0) {
		if (status := DllCall("Gdiplus\GdipFlattenPath", "Ptr", this.Ptr, "Ptr", matrix.Ptr, "Float", flatness, "Int")) {
			throw (ErrorFromStatus(status))
		}

		return (True)
	}

	;* path.Reverse()
	Reverse() {
		if (status := DllCall("Gdiplus\GdipReversePath", "Ptr", this.Ptr, "Int")) {
			throw (ErrorFromStatus(status))
		}

		return (True)
	}

	;* path.Widen(pen[, flatness, matrix])
	;* Parameter:
		;* [Pen] pen
		;* [Float] flatness
		;* [Matrix] matrix
	Widen(pen, flatness := 1.0, matrix := 0) {
		if (status := DllCall("Gdiplus\GdipWidenPath", "Ptr", this.Ptr, "Ptr", pen.Ptr, "Ptr", matrix.Ptr, "Float", flatness, "Int")) {
			throw (ErrorFromStatus(status))
		}

		return (True)
	}

	;* path.Widen(matrix)
	;* Parameter:
		;* [Matrix] matrix
	Transform(matrix) {
		if (status := DllCall("gdiplus\GdipTransformPath", "Ptr", this.Ptr, "Ptr", matrix.Ptr, "Int")) {
			throw (ErrorFromStatus(status))
		}

		return (True)
	}

	;* path.Reset()
	Reset() {
		if (status := DllCall("Gdiplus\GdipResetPath", "Ptr", this.Ptr, "Int")) {
			throw (ErrorFromStatus(status))
		}

		return (True)
	}

	;------------------------------------------------------- Figure ---------------;

	;* path.StartFigure() - Starts a new figure without closing the current figure. Subsequent points added to this path are added to the new figure.
	StartFigure() {
		if (status := DllCall("Gdiplus\GdipStartPathFigure", "Ptr", this.Ptr, "Int")) {
			throw (ErrorFromStatus(status))
		}

		return (True)
	}

	;* path.CloseFigure([all])
	;* Parameter:
		;* [Integer] all
	CloseFigure(all := False) {
		if (status := (all)
			? (DllCall("Gdiplus\GdipClosePathFigures", "Ptr", this.Ptr, "Int"))
			: (DllCall("Gdiplus\GdipStartPathFigure", "Ptr", this.Ptr, "Int"))) {
			throw (ErrorFromStatus(status))
		}

		return (True)
	}

	;--------------------------------------------------------  Add  ----------------;

	;AddArc
	;AddBezier
	;AddBeziers
	;AddClosedCurve
	;AddCurve
	;AddEllipse
	;AddLine
	;AddLines
	;AddPie
	;AddPolygon
	;AddRectangle
	;AddRoundedRectangle

	;* path.AddArc(object, startAngle, sweepAngle)
	;* Parameter:
		;* [Object] object - An object with `x`, `y`, `Width` and `Height` properties.
		;* [Float] startAngle
		;* [Float] sweepAngle
	AddArc(object, startAngle, sweepAngle) {
		if (status := DllCall("Gdiplus\GdipAddPathArc", "Ptr", this.Ptr, "Float", object.x, "Float", object.y, "Float", object.Width, "Float", object.Height, "Float", startAngle, "Float", sweepAngle, "Int")) {
			throw (ErrorFromStatus(status))
		}

		return (True)
	}

	;* path.AddBezier(object1, object2, object3, object4)
	;* Parameter:
		;* [Object] object1 - An object with `x` and `y` properties.
		;* [Object] object2 - An object with `x` and `y` properties.
		;* [Object] object3 - An object with `x` and `y` properties.
		;* [Object] object4 - An object with `x` and `y` properties.
	AddBezier(object1, object2, object3, object4) {
		if (status := DllCall("Gdiplus\GdipAddPathBezier", "Ptr", this.Ptr, "Float", object1.x, "Float", object1.y, "Float", object2.x, "Float", object2.y, "Float", object3.x, "Float", object3.y, "Float", object4.x, "Float", object4.y, "Int")) {
			throw (ErrorFromStatus(status))
		}

		return (True)
	}

	;* path.AddBeziers(objects*)
	;* Parameter:
		;* [Object] objects - Any number of objects with `x` and `y` properties.
	;* Note:
		;~ The first spline is constructed from the first point through the fourth point in the array and uses the second and third points as control points. Each subsequent spline in the sequence needs exactly three more points: the ending point of the previous spline is used as the starting point, the next two points in the sequence are control points, and the third point is the ending point.
	AddBeziers(objects*) {
		for index, object in (objects, points := Structure((length := objects.Length)*8)) {
			points.NumPut(index*8, "Float", object.x, "Float", object.y)
		}

		if (status := DllCall("Gdiplus\GdipAddPathBeziers", "Ptr", this.Ptr, "Ptr", points.Ptr, "UInt", length, "Int")) {
			throw (ErrorFromStatus(status))
		}

		return (True)
	}

	;* path.AddClosedCurve(objects*[, tension])
	;* Parameter:
		;* [Object] objects - Any number of objects with `x` and `y` properties.
		;* [Float] tension - Non-negative real number that specifies how tightly the spline bends as it passes through the points.
	AddClosedCurve(objects*) {
		if (IsNumber(objects[(length := objects.Length) - 1])) {
			tension := objects.Pop(), length--
		}

		for index, object in (points := Structure(length*8), objects) {
			points.NumPut(index*8, "Float", object.x, "Float", object.y)
		}

		if (status := (tension)
			? (DllCall("Gdiplus\GdipAddPathClosedCurve2", "Ptr", this.Ptr, "Ptr", points.Ptr, "UInt", length, "Float", tension, "Int"))
			: (DllCall("Gdiplus\GdipAddPathClosedCurve", "Ptr", this.Ptr, "Ptr", points.Ptr, "UInt", length, "Int"))) {
			throw (ErrorFromStatus(status))
		}

		return (True)
	}

	;* path.AddCurve(objects*[, tension])
	;* Parameter:
		;* [Object] objects - Any number of objects with `x` and `y` properties.
		;* [Float] tension - Non-negative real number that specifies how tightly the spline bends as it passes through the points.
	AddCurve(objects*) {
		if (IsNumber(objects[(length := objects.Length) - 1])) {
			tension := objects.Pop(), length--
		}

		for index, object in (points := Structure(length*8), objects) {
			points.NumPut(index*8, "Float", object.x, "Float", object.y)
		}

		if (status := (tension)
			? (DllCall("Gdiplus\GdipAddPathCurve2", "Ptr", this.Ptr, "Ptr", points.Ptr, "UInt", length, "Float", tension, "Int"))
			: (DllCall("Gdiplus\GdipAddPathCurve", "Ptr", this.Ptr, "Ptr", points.Ptr, "UInt", length, "Int"))) {
			throw (ErrorFromStatus(status))
		}

		return (True)
	}

	;* path.AddEllipse(object)
	;* Parameter:
		;* [Object] object - An object with `x`, `y`, `Width` and `Height` properties.
	AddEllipse(object) {
		if (status := DllCall("Gdiplus\GdipAddPathEllipse", "Ptr", this.Ptr, "Float", object.x, "Float", object.y, "Float", object.width, "Float", object.height, "Int")) {
			throw (ErrorFromStatus(status))
		}

		return (True)
	}

	;* path.AddLine(object1, object2)
	;* Parameter:
		;* [Object] object1 - An object with `x` and `y` properties.
		;* [Object] object2 - An object with `x` and `y` properties.
	AddLine(object1, object2) {
		if (status := DllCall("Gdiplus\GdipAddPathLine", "Ptr", this.Ptr, "Float", object1.x, "Float", object1.y, "Float", object2.x, "Float", object2.y, "Int")) {
			throw (ErrorFromStatus(status))
		}

		return (True)
	}

	;* path.AddLines(objects*)
	;* Parameter:
		;* [Object] objects - Any number of objects with `x` and `y` properties.
	AddLines(objects*) {
		for index, object in (points := Structure((length := objects.Length)*8), objects) {
			points.NumPut(index*8, "Float", object.x, "Float", object.y)
		}

		if (status := DllCall("Gdiplus\GdipAddPathLine2", "Ptr", this.Ptr, "Ptr", points.Ptr, "UInt", length, "Int")) {
			throw (ErrorFromStatus(status))
		}

		return (True)
	}

	;* path.AddPie(object, startAngle, sweepAngle)
	;* Parameter:
		;* [Object] object - An object with `x`, `y`, `Width` and `Height` properties.
		;* [Float] startAngle
		;* [Float] sweepAngle
	AddPie(object, startAngle, sweepAngle) {
		if (status := DllCall("Gdiplus\GdipAddPathPie", "Ptr", this.Ptr, "Float", object.x, "Float", object.y, "Float", object.Width, "Float", object.Height, "Float", startAngle, "Float", sweepAngle, "Int")) {
			throw (ErrorFromStatus(status))
		}

		return (True)
	}

	;* path.AddPolygon(objects*)
	;* Parameter:
		;* [Object] objects - Any number of objects with `x` and `y` properties.
	;* Note:
		;~ The `"Gdiplus\GdipAddPathPolygon"` function is similar to the `"Gdiplus\GdipAddPathLine2"` function. The difference is that a polygon is an intrinsically closed figure, but a sequence of lines is not a closed figure unless you call `"Gdiplus\GdipClosePathFigure"`. When Microsoft Windows GDI+ renders a path, each polygon in that path is closed; that is, the last vertex of the polygon is connected to the first vertex by a straight line.
	AddPolygon(objects*) {
		for index, object in (points := Structure((length := objects.Length)*8), objects) {
			points.NumPut(index*8, "Float", object.x, "Float", object.y)
		}

		if (status := DllCall("Gdiplus\GdipAddPathPolygon", "Ptr", this.Ptr, "Ptr", points.Ptr, "Int", length, "Int")) {
			throw (ErrorFromStatus(status))
		}

		return (True)
	}

	;* path.AddRectangle(object)
	;* Parameter:
		;* [Object] object - An object with `x`, `y`, `Width` and `Height` properties.
	AddRectangle(object) {
		if (status := DllCall("Gdiplus\GdipAddPathRectangle", "Ptr", this.Ptr, "Float", object.x, "Float", object.y, "Float", object.width, "Float", object.height, "Int")) {
			throw (ErrorFromStatus(status))
		}

		return (True)
	}

	;* path.AddRoundedRectangle(object, radius)
	;* Parameter:
		;* [Object] object - An object with `x`, `y`, `Width` and `Height` properties.
		;* [Float] radius - Radius of the rounded corners.
	AddRoundedRectangle(object, radius) {
		diameter := radius*2
			x := object.x, y := object.y, width := object.Width - diameter, height := object.Height - diameter

		pPath := this.Ptr

		DllCall("Gdiplus\GdipAddPathArc", "Ptr", pPath, "Float", x, "Float", y, "Float", diameter, "Float", diameter, "Float", 180, "Float", 90)
		DllCall("Gdiplus\GdipAddPathArc", "Ptr", pPath, "Float", x + width, "Float", y, "Float", diameter, "Float", diameter, "Float", 270, "Float", 90)
		DllCall("Gdiplus\GdipAddPathArc", "Ptr", pPath, "Float", x + width, "Float", y + height, "Float", diameter, "Float", diameter, "Float", 0, "Float", 90)
		DllCall("Gdiplus\GdipAddPathArc", "Ptr", pPath, "Float", x, "Float", y + height, "Float", diameter, "Float", diameter, "Float", 90, "Float", 90)
		DllCall("Gdiplus\GdipClosePathFigure", "Ptr", pPath)

		return (True)
	}
}