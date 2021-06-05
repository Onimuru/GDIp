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
;* enum FillMode  ;: https://docs.microsoft.com/en-us/windows/win32/api/gdiplusenums/ne-gdiplusenums-fillmode
	0 = FillModeAlternate
	1 = FillModeWinding
*/

;* GDIp.CreatePath([fillMode])
;* Parameter:
	;* [Integer] fillMode - See FillMode enumeration.
;* Return:
	;* [Path]
static CreatePath(fillMode := 0) {
	if (status := DllCall("Gdiplus\GdipCreatePath", "Int", fillMode, "Ptr*", &(pPath := 0), "Int")) {
		throw (ErrorFromStatus(status))
	}

	return (this.Path(pPath))
}

class Path {
	Class := "Path"

	__New(pPath) {
		this.Ptr := pPath
	}

	;* path.Clone()
	;* Return:
		;* [Path]
	Clone() {
		if (status := DllCall("Gdiplus\GdipClonePath", "Ptr", this.Ptr, "Ptr*", &(pPath := 0), "Int")) {
			throw (ErrorFromStatus(status))
		}

		return (GDIp.Path(pPath))
	}

	__Delete() {
		if (status := DllCall("Gdiplus\GdipDeletePath", "Ptr", this.Ptr, "Int")) {
			throw (ErrorFromStatus(status))
		}
	}

	;-------------- Property ------------------------------------------------------;

	Rect {
		Get {
			return (this.GetRect())
		}
	}

	;* path.GetRect()
	;* Return:
		;* [Object]
	GetRect() {
		static rect := Structure.CreateRect(0, 0, "Float")

		if (status := DllCall("gdiplus\GdipGetPathWorldBounds", "Ptr", this.Ptr, "Ptr", rect.Ptr, "Int")) {
			throw (ErrorFromStatus(status))
		}

		return ({x: rect.NumGet(0, "Float"), y: rect.NumGet(4, "Float"), Width: rect.NumGet(8, "Float"), Height: rect.NumGet(12, "Float")})
	}

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

	;* path.SetFillMode(fillMode)
	;* Parameter:
		;* [Integer] fillMode - See FillMode enumeration.
	SetFillMode(fillMode) {
		if (status := DllCall("Gdiplus\GdipSetPathFillMode", "Ptr", this.Ptr, "Int", fillMode, "Int")) {
			throw (ErrorFromStatus(status))
		}
	}

	LastPoint {
		Get {
			return (this.GetLastPoint())
		}
	}

	;* path.GetLastPoint()
	;* Return:
		;* [Array]
	GetLastPoint() {
		static point := Structure.CreatePoint(0, 0, "Float")

		if (status := DllCall("Gdiplus\GdipGetPathLastPoint", "Ptr", this.Ptr, "Ptr", point.Ptr, "Int")) {
			throw (ErrorFromStatus(status))
		}

		return (Vec2(point.NumGet(0, "Float"), point.NumGet(4, "Float")))
	}

	PointCount {
		Get {
			return (this.GetPointCount())
		}
	}

	;* path.GetPointCount()
	;* Return:
		;* [Integer]
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
	;* Return:
		;* [Array]
	GetPoints() {
		if (status := DllCall("Gdiplus\GdipGetPathPoints", "Ptr", this.Ptr, "Ptr", (struct := Structure((count := this.GetPointCount())*8)).Ptr, "Int*", &count, "Int")) {
			throw (ErrorFromStatus(status))
		}

		loop (array := [], count) {
			offset := (A_Index - 1)*8
				, array.Push(Vec2(struct.NumGet(offset, "Float"), struct.NumGet(offset + 4, "Float")))
		}

		return (array)
	}

	;--------------- Method -------------------------------------------------------;
	;------------------------------------------------------  Control  --------------;

	;* path.Flatten(flatness[, matrix])
	;* Parameter:
		;* [Float] flatness
		;* [Matrix] matrix
	Flatten(flatness, matrix := 0) {
		if (status := DllCall("Gdiplus\GdipFlattenPath", "Ptr", this.Ptr, "Ptr", matrix, "Float", flatness, "Int")) {
			throw (ErrorFromStatus(status))
		}
	}

	;* path.Reverse()
	Reverse() {
		if (status := DllCall("Gdiplus\GdipReversePath", "Ptr", this.Ptr, "Int")) {
			throw (ErrorFromStatus(status))
		}
	}

	;* path.Widen(pen[, flatness, matrix])
	;* Parameter:
		;* [Pen] pen
		;* [Float] flatness
		;* [Matrix] matrix
	Widen(pen, flatness := 1.0, matrix := 0) {
		if (status := DllCall("Gdiplus\GdipWidenPath", "Ptr", this.Ptr, "Ptr", pen, "Ptr", matrix, "Float", flatness, "Int")) {
			throw (ErrorFromStatus(status))
		}
	}

	;* path.Transform(matrix)
	;* Parameter:
		;* [Matrix] matrix
	Transform(matrix) {
		if (status := DllCall("gdiplus\GdipTransformPath", "Ptr", this.Ptr, "Ptr", matrix, "Int")) {
			throw (ErrorFromStatus(status))
		}
	}

	;* path.Reset()
	Reset() {
		if (status := DllCall("Gdiplus\GdipResetPath", "Ptr", this.Ptr, "Int")) {
			throw (ErrorFromStatus(status))
		}
	}

	;------------------------------------------------------- Figure ---------------;

	;* path.StartFigure() - Starts a new figure without closing the current figure. Subsequent points added to this path are added to the new figure.
	StartFigure() {
		if (status := DllCall("Gdiplus\GdipStartPathFigure", "Ptr", this.Ptr, "Int")) {
			throw (ErrorFromStatus(status))
		}
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

	;* path.AddArc(x, y, width, height, startAngle, sweepAngle)
	;* Parameter:
		;* [Float] x
		;* [Float] y
		;* [Float] width
		;* [Float] height
		;* [Float] startAngle
		;* [Float] sweepAngle
	AddArc(x, y, width, height, startAngle, sweepAngle) {
		if (status := DllCall("Gdiplus\GdipAddPathArc", "Ptr", this.Ptr, "Float", x, "Float", y, "Float", width, "Float", height, "Float", startAngle, "Float", sweepAngle, "Int")) {
			throw (ErrorFromStatus(status))
		}
	}

	;* path.AddBezier(point1, point2, point3, point4)
	;* Parameter:
		;* [Array] point1
		;* [Array] point2
		;* [Array] point3
		;* [Array] point4
	AddBezier(point1, point2, point3, point4) {
		if (status := DllCall("Gdiplus\GdipAddPathBezier", "Ptr", this.Ptr, "Float", point1[0], "Float", point1[1], "Float", point2[0], "Float", point2[1], "Float", point3[0], "Float", point3[1], "Float", point4[0], "Float", point4[1], "Int")) {
			throw (ErrorFromStatus(status))
		}
	}

	;* path.AddBeziers(points*)
	;* Parameter:
		;* [Array]* points - Any number of Arrays with values at index 0 and 1 to be used as x and y coordinates respectively.
	;* Note:
		;~ The first spline is constructed from the first point through the fourth point in the array and uses the second and third points as control points. Each subsequent spline in the sequence needs exactly three more points: the ending point of the previous spline is used as the starting point, the next two points in the sequence are control points, and the third point is the ending point.
	AddBeziers(points*) {
		for index, point in (struct := Structure((length := points.Length)*8), points) {
			struct.NumPut(index*8, "Float", point[0], "Float", point[1])
		}

		if (status := DllCall("Gdiplus\GdipAddPathBeziers", "Ptr", this.Ptr, "Ptr", struct.Ptr, "UInt", length, "Int")) {
			throw (ErrorFromStatus(status))
		}
	}

	;* path.AddClosedCurve(points*[, tension])
	;* Parameter:
		;* [Array]* points - Any number of Arrays with values at index 0 and 1 to be used as x and y coordinates respectively.
		;* [Float] tension - Non-negative real number that specifies how tightly the spline bends as it passes through the points.
	AddClosedCurve(points*) {
		if (IsNumber(points[-1])) {
			tension := points.Pop()
		}

		for index, point in (struct := Structure((length := points.Length)*8), points) {
			struct.NumPut(index*8, "Float", point[0], "Float", point[1])
		}

		if (status := (tension)
			? (DllCall("Gdiplus\GdipAddPathClosedCurve2", "Ptr", this.Ptr, "Ptr", struct.Ptr, "UInt", length, "Float", tension, "Int"))
			: (DllCall("Gdiplus\GdipAddPathClosedCurve", "Ptr", this.Ptr, "Ptr", struct.Ptr, "UInt", length, "Int"))) {
			throw (ErrorFromStatus(status))
		}
	}

	;* path.AddCurve(points*[, tension])
	;* Parameter:
		;* [Array]* points - Any number of Arrays with values at index 0 and 1 to be used as x and y coordinates respectively.
		;* [Float] tension - Non-negative real number that specifies how tightly the spline bends as it passes through the points.
	AddCurve(points*) {
		if (IsNumber(points[-1])) {
			tension := points.Pop()
		}

		for index, point in (struct := Structure((length := points.Length)*8), points) {
			struct.NumPut(index*8, "Float", point[0], "Float", point[1])
		}

		if (status := (tension)
			? (DllCall("Gdiplus\GdipAddPathCurve2", "Ptr", this.Ptr, "Ptr", struct.Ptr, "UInt", length, "Float", tension, "Int"))
			: (DllCall("Gdiplus\GdipAddPathCurve", "Ptr", this.Ptr, "Ptr", struct.Ptr, "UInt", length, "Int"))) {
			throw (ErrorFromStatus(status))
		}
	}

	;* path.AddEllipse(x, y, width, height)
	;* Parameter:
		;* [Float] x
		;* [Float] y
		;* [Float] width
		;* [Float] height
	AddEllipse(x, y, width, height) {
		if (status := DllCall("Gdiplus\GdipAddPathEllipse", "Ptr", this.Ptr, "Float", x, "Float", y, "Float", width, "Float", height, "Int")) {
			throw (ErrorFromStatus(status))
		}
	}

	;* path.AddLine(point1, point2)
	;* Parameter:
		;* [Array] point1 - An Array with values at index 0 and 1 to be used as x and y coordinates respectively.
		;* [Array] point2 - An Array with values at index 0 and 1 to be used as x and y coordinates respectively.
	AddLine(point1, point2) {
		if (status := DllCall("Gdiplus\GdipAddPathLine", "Ptr", this.Ptr, "Float", point1[0], "Float", point1[1], "Float", point2[0], "Float", point2[1], "Int")) {
			throw (ErrorFromStatus(status))
		}
	}

	;* path.AddLines(points*)
	;* Parameter:
		;* [Array]* points - Any number of Arrays with values at index 0 and 1 to be used as x and y coordinates respectively.
	AddLines(points*) {
		for index, point in (struct := Structure((length := points.Length)*8), points) {
			struct.NumPut(index*8, "Float", point[0], "Float", point[1])
		}

		if (status := DllCall("Gdiplus\GdipAddPathLine2", "Ptr", this.Ptr, "Ptr", struct.Ptr, "UInt", length, "Int")) {
			throw (ErrorFromStatus(status))
		}
	}

	;* path.AddPie(x, y, width, height, startAngle, sweepAngle)
	;* Parameter:
		;* [Float] x
		;* [Float] y
		;* [Float] width
		;* [Float] height
		;* [Float] startAngle
		;* [Float] sweepAngle
	AddPie(x, y, width, height, startAngle, sweepAngle) {
		if (status := DllCall("Gdiplus\GdipAddPathPie", "Ptr", this.Ptr, "Float", x, "Float", y, "Float", width, "Float", height, "Float", startAngle, "Float", sweepAngle, "Int")) {
			throw (ErrorFromStatus(status))
		}
	}

	;* path.AddPolygon(points*)
	;* Parameter:
		;* [Array]* points - Any number of Arrays with values at index 0 and 1 to be used as x and y coordinates respectively.
	;* Note:
		;~ The `"Gdiplus\GdipAddPathPolygon"` function is similar to the `"Gdiplus\GdipAddPathLine2"` function. The difference is that a polygon is an intrinsically closed figure, but a sequence of lines is not a closed figure unless you call `"Gdiplus\GdipClosePathFigure"`. When Microsoft Windows GDI+ renders a path, each polygon in that path is closed; that is, the last vertex of the polygon is connected to the first vertex by a straight line.
	AddPolygon(points*) {
		for index, point in (struct := Structure((length := points.Length)*8), points) {
			struct.NumPut(index*8, "Float", point[0], "Float", point[1])
		}

		if (status := DllCall("Gdiplus\GdipAddPathPolygon", "Ptr", this.Ptr, "Ptr", struct.Ptr, "Int", length, "Int")) {
			throw (ErrorFromStatus(status))
		}
	}

	;* path.AddRectangle(x, y, width, height)
	;* Parameter:
		;* [Float] x
		;* [Float] y
		;* [Float] width
		;* [Float] height
	AddRectangle(x, y, width, height) {
		if (status := DllCall("Gdiplus\GdipAddPathRectangle", "Ptr", this.Ptr, "Float", x, "Float", y, "Float", width, "Float", height, "Int")) {
			throw (ErrorFromStatus(status))
		}
	}

	;* path.AddRoundedRectangle(x, y, width, height, radius)
	;* Parameter:
		;* [Float] x
		;* [Float] y
		;* [Float] width
		;* [Float] height
		;* [Float] radius - Radius of the rounded corners.
	AddRoundedRectangle(x, y, width, height, radius) {
		diameter := radius*2
			, width -= diameter, height -= diameter

		pPath := this.Ptr

		DllCall("Gdiplus\GdipAddPathArc", "Ptr", pPath, "Float", x, "Float", y, "Float", diameter, "Float", diameter, "Float", 180, "Float", 90)
		DllCall("Gdiplus\GdipAddPathArc", "Ptr", pPath, "Float", x + width, "Float", y, "Float", diameter, "Float", diameter, "Float", 270, "Float", 90)
		DllCall("Gdiplus\GdipAddPathArc", "Ptr", pPath, "Float", x + width, "Float", y + height, "Float", diameter, "Float", diameter, "Float", 0, "Float", 90)
		DllCall("Gdiplus\GdipAddPathArc", "Ptr", pPath, "Float", x, "Float", y + height, "Float", diameter, "Float", diameter, "Float", 90, "Float", 90)
		DllCall("Gdiplus\GdipClosePathFigure", "Ptr", pPath)
	}
}