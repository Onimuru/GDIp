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

	Clone() {
		Local

		if (status := DllCall("Gdiplus\GdipClonePath", "Ptr", this.Ptr, "Ptr*", pPath := 0, "Int")) {
			throw (Exception(FormatStatus(status)))
		}

		return ({"Ptr": pPath
			, "Base": this.Base})
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
		Local count := this.GetPointCount()
			, struct := new Structure(count*8), status, array, offset

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

	Transform(matrix) {
		Local

		if (status := DllCall("gdiplus\GdipTransformPath", "Ptr", this.Ptr, "Ptr", matrix.Ptr, "Int")) {
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

	;------------------------------------------------------- Figure ---------------;

	;* path.StartFigure() - Starts a new figure without closing the current figure. Subsequent points added to this path are added to the new figure.
	StartFigure() {
		Local

		if (status := DllCall("Gdiplus\GdipStartPathFigure", "Ptr", this.Ptr, "Int")) {
			throw (Exception(FormatStatus(status)))
		}

		return (True)
	}

	;* path.CloseFigure([all])
	CloseFigure(all := False) {
		Local

		if (status := (all)
			? (DllCall("Gdiplus\GdipClosePathFigures", "Ptr", this.Ptr, "Int"))
			: (DllCall("Gdiplus\GdipStartPathFigure", "Ptr", this.Ptr, "Int"))) {
			throw (Exception(FormatStatus(status)))
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

	;* path.AddArc([__Rect] object, startAngle, sweepAngle)
	AddArc(object, startAngle, sweepAngle) {
		Local

		if (status := DllCall("Gdiplus\GdipAddPathArc", "Ptr", this.Ptr, "Float", object.x, "Float", object.y, "Float", object.Width, "Float", object.Height, "Float", startAngle, "Float", sweepAngle, "Int")) {
			throw (Exception(FormatStatus(status)))
		}

		return (True)
	}

	;* path.AddBezier([__Vec2] object1, [__Vec2] object2, [__Vec2] object3, [__Vec2] object4)
	AddBezier(object1, object2, object3, object4) {
		Local

		if (status := DllCall("Gdiplus\GdipAddPathBezier", "Ptr", this.Ptr, "Float", object1.x, "Float", object1.y, "Float", object2.x, "Float", object2.y, "Float", object3.x, "Float", object3.y, "Float", object4.x, "Float", object4.y, "Int")) {
			throw (Exception(FormatStatus(status)))
		}

		return (True)
	}

	;* path.AddBeziers([__Vec2] objects*)
	;* Note:
		;* The first spline is constructed from the first point through the fourth point in the array and uses the second and third points as control points. Each subsequent spline in the sequence needs exactly three more points: the ending point of the previous spline is used as the starting point, the next two points in the sequence are control points, and the third point is the ending point.
	AddBeziers(objects*) {
		Local index, object, points, status

		for index, object in (objects, points := new Structure(objects.Length()*8)) {
			points.NumPut((index - 1)*8, "Float", object.x, "Float", object.y)
		}

		if (status := DllCall("Gdiplus\GdipAddPathBeziers", "Ptr", this.Ptr, "Ptr", points.Ptr, "UInt", index, "Int")) {
			throw (Exception(FormatStatus(status)))
		}

		return (True)
	}

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

	;* path.AddEllipse([__Rect] object)
	AddEllipse(object) {
		Local

		if (status := DllCall("Gdiplus\GdipAddPathEllipse", "Ptr", this.Ptr, "Float", object.x, "Float", object.y, "Float", object.width, "Float", object.height, "Int")) {
			throw (Exception(FormatStatus(status)))
		}

		return (True)
	}

	;* path.AddLine([__Vec2] object1, [__Vec2] object2)
	AddLine(object1, object2) {
		Local

		if (status := DllCall("Gdiplus\GdipAddPathLine", "Ptr", this.Ptr, "Float", object1.x, "Float", object1.y, "Float", object2.x, "Float", object2.y, "Int")) {
			throw (Exception(FormatStatus(status)))
		}

		return (True)
	}

	;* path.AddLines([__Vec2] objects*)
	AddLines(objects*) {
		Local index, object, points, status

		for index, object in (objects, points := new Structure(objects.Length()*8)) {
			points.NumPut((index - 1)*8, "Float", object.x, "Float", object.y)
		}

		if (status := DllCall("Gdiplus\GdipAddPathLine2", "Ptr", this.Ptr, "Ptr", points.Ptr, "UInt", index, "Int")) {
			throw (Exception(FormatStatus(status)))
		}

		return (True)
	}

	;* path.AddPie([__Rect] object, startAngle, sweepAngle)
	AddPie(object, startAngle, sweepAngle) {
		Local

		if (status := DllCall("Gdiplus\GdipAddPathPie", "Ptr", this.Ptr, "Float", object.x, "Float", object.y, "Float", object.Width, "Float", object.Height, "Float", startAngle, "Float", sweepAngle, "Int")) {
			throw (Exception(FormatStatus(status)))
		}

		return (True)
	}

	;* path.AddPolygon([__Vec2] objects*)
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

	;* path.AddRectangle([__Rect] object)
	AddRectangle(object) {
		Local

		if (status := DllCall("Gdiplus\GdipAddPathRectangle", "Ptr", this.Ptr, "Float", object.x, "Float", object.y, "Float", object.width, "Float", object.height, "Int")) {
			throw (Exception(FormatStatus(status)))
		}

		return (True)
	}

	;* path.AddRoundedRectangle([__Rect] object, radius)
	;* Parameter:
		;* object - Object with `x`, `y`, `Width` and `Height` properties that defines the rectangle to be rounded.
		;* radius - Radius of the rounded corners.
	AddRoundedRectangle(object, radius) {
		Local

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