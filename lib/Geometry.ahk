;=====           Function           =========================;

__Validate(vN, ByRef vNumber1 := "", ByRef vNumber2 := "", ByRef vNumber3 := "", ByRef vNumber4 := "") {
	Loop, % vN {
		If (!Math.IsNumeric(vNumber%A_Index%)) {
			vNumber%A_Index% := Round(vNumber%A_Index%)
		}
	}
}

;=====             Class            =========================;

Class Point2D {

	;-----          Constructor         -------------------------;

	;* new Point2D(x, y)
	__New(x, y) {
		Return, ({"x": x
			, "y": y

			, "Base": this.__Point2D})
	}

	;-----            Method            -------------------------;
	;-------------------------            General           -----;

	;* Point2D.Angle(PointObject, PointObject)
	;* Description:
		;* Calculate the angle from `oPoint2D1` to `oPoint2D2`.
	Angle(oPoint2D1, oPoint2D2) {
		Return, (Math.ToDegrees(((x := -Math.ATan2({"x": oPoint2D2.x - oPoint2D1.x, "y": oPoint2D2.y - oPoint2D1.y})) < 0) ? (-x) : (Math.Tau - x)))
	}

	;* Point2D.Distance(PointObject, PointObject)
	Distance(oPoint2D1, oPoint2D2) {
		Return, (Sqrt((oPoint2D2.x - oPoint2D1.x)**2 + (oPoint2D2.y - oPoint2D1.y)**2))
	}

	;* Point2D.Equals(PointObject, PointObject)
	Equals(oPoint2D1, oPoint2D2) {
		Return, (oPoint2D1.x == oPoint2D2.x && oPoint2D1.y == oPoint2D2.y)
	}

	;* Point2D.Slope(PointObject, PointObject)
	;* Note:
		;* Two lines are parallel if their slopes are the same.
		;* Two lines are perpendicular if their slopes are negative reciprocals of each other.
	Slope(oPoint2D1, oPoint2D2) {
		Return, ((oPoint2D2.y - oPoint2D1.y)/(oPoint2D2.x - oPoint2D1.x))
	}

	;* Point2D.MidPoint(PointObject, PointObject)
	MidPoint(oPoint2D1, oPoint2D2) {
		Return, (new Point2D((oPoint2D1.x + oPoint2D2.x)/2, (oPoint2D1.y + oPoint2D2.y)/2))
	}

	;* Point2D.Rotate(PointObject, PointObject, Degrees)
	;* Description:
		;* Calculate the coordinates of `oPoint2D1` rotated around `oPoint2D2`.
	Rotate(oPoint2D1, oPoint2D2, vTheta) {
		a := -Math.ToRadians((vTheta >= 0) ? (Mod(vTheta, 360)) : (360 - Mod(-vTheta, -360)))
			, c := Math.Cos(a), s := Math.Sin(a)

		x := oPoint2D1.x - oPoint2D2.x, y := oPoint2D1.y - oPoint2D2.y

		Return, (new Point2D(x*c - y*s + oPoint2D2.x, x*s + y*c + oPoint2D2.y))
	}

	;-------------------------           Triangle           -----;

	;* Point2D.Circumcenter(PointObject, PointObject, PointObject)
	Circumcenter(oPoint2D1, oPoint2D2, oPoint2D3) {
		m := [this.MidPoint(oPoint2D1, oPoint2D2), this.MidPoint(oPoint2D2, oPoint2D3)]
			, s := [(oPoint2D2.x - oPoint2D1.x)/(oPoint2D1.y - oPoint2D2.y), (oPoint2D3.x - oPoint2D2.x)/(oPoint2D2.y - oPoint2D3.y)]
			, p := [m[0].y - s[0]*m[0].x, m[1].y - s[1]*m[1].x]

		Return, (s[0] == s[1] ? 0 : oPoint2D1.y == oPoint2D2.y ? new Point2D(m[0].x, s[1]*m[0].x + p[1]) : oPoint2D2.y == oPoint2D3.y ? new Point2D(m[1].x, s[0]*m[1].x + p[0]) : new Point2D((p[1] - p[0])/(s[0] - s[1]), s[0]*(p[1] - p[0])/(s[0] - s[1]) + p[0]))
	}

	;-------------------------            Ellipse           -----;

	;* Point2D.Foci(EllipseObject)
	Foci(oEllipse) {
		o := [(oEllipse.Radius.a > oEllipse.Radius.b)*(o := oEllipse.FocalLength), (oEllipse.Radius.a < oEllipse.Radius.b)*o]

		Return, ([new Point2D(oEllipse.h - o[0], oEllipse.k - o[1]), new Point2D(oEllipse.h + o[0], oEllipse.k + o[1])])
	}

	;* Point2D.Epicycloid(EllipseObject1, EllipseObject2, Degrees)
	Epicycloid(oEllipse1, oEllipse2, vTheta := 0) {
		a := Math.ToRadians((vTheta >= 0) ? (Mod(vTheta, 360)) : (360 - Mod(-vTheta, -360)))

		Return, (new Point2D(oEllipse1.h + (oEllipse1.Radius + oEllipse2.Radius)*Math.Cos(a) - oEllipse2.Radius*Math.Cos((oEllipse1.Radius/oEllipse2.Radius + 1)*a), oEllipse.k - o[2], oEllipse1.k + (oEllipse1.Radius + oEllipse2.Radius)*Math.Sin(a) - oEllipse2.Radius*Math.Sin((oEllipse1.Radius/oEllipse2.Radius + 1)*a)))
	}

	;* Point2D.Hypocycloid([EllipseObject1, EllipseObject2], Degrees)
	Hypocycloid(oEllipses, vTheta := 0) {
		a := Math.ToRadians((vTheta >= 0) ? (Mod(vTheta, 360)) : (360 - Mod(-vTheta, -360)))

		Return, (new Point2D(oEllipse1.h + (oEllipse1.Radius - oEllipse2.Radius)*Math.Cos(a) + oEllipse2.Radius*Math.Cos((oEllipse1.Radius/oEllipse2.Radius - 1)*a), oEllipse1.k + (oEllipse1.Radius - oEllipse2.Radius)*Math.Sin(a) - oEllipse2.Radius*Math.Sin((oEllipse1.Radius/oEllipse2.Radius - 1)*a)))
	}

	;* Point2D.OnEllipse(EllipseObject, Degrees)
	;* Description:
		;* Calculate the coordinates of a point on the circumference of an ellipse.
	OnEllipse(oEllipse, vTheta := 0) {
		a := -(Math.ToRadians((vTheta >= 0) ? (Mod(vTheta, 360)) : (360 - Mod(-vTheta, -360))))

		If (IsObject(oEllipse.Radius)) {
			t := Math.Tan(a), o := [oEllipse.Radius.a*oEllipse.Radius.b, Sqrt(oEllipse.Radius.b**2 + oEllipse.Radius.a**2*t**2)], s := (90 < vTheta && vTheta <= 270) ? (-1) : (1)

			Return, (new Point2D(oEllipse.h + (o[0]/o[1])*s, oEllipse.k + ((o[0]*t)/o[1])*s))
		}
		Return, (new Point2D(oEllipse.h + oEllipse.Radius*Math.Cos(a), oEllipse.k + oEllipse.Radius*Math.Sin(a)))
	}

	;-----         Nested Class         -------------------------;

	Class __Point2D Extends __Object {

		Clone() {
			Return, (new Point2D(this.x, this.y))
		}
	}
}

Class Ellipse {

	;* new Ellipse(vX, vY, Width, Height, Eccentricity)
	;* Note:
		;* Eccentricity can compensate for `Width` or `Height` but 2 of the 3 values must be provided to calculate a valid radius.
	__New(vX := "", vY := "", vWidth := "", vHeight := "", vEccentricity := 0) {
		e := Sqrt(1 - vEccentricity**2), r := [(vWidth != "") ? (vWidth/2) : ((vHeight != "") ? ((vHeight/2)*e) : (0)), (vHeight != "") ? (vHeight/2) : ((vWidth != "") ? ((vWidth/2)*e) : (0))]

		If (r[0] == r[1]) {
			Return, ({"x": vX
				, "y": vY
				, "__Radius": Max(r[0], r[1])

				, "Base": this.__Circle})
		}

		Return, ({"x": vX
			, "y": vY
			, "__Radius": r

			, "Base": this.__Ellipse})
	}

	;*Note:
		;* To determine radius given N: vRadius := (oEllipse.Radius/(Math.Sin(Math.Pi/N) + 1))*Math.Sin(Math.Pi/N).
	InscribeEllipse(oEllipse, vRadius, vDegrees := 0, vOffset := 0) {
		a := Math.ToRadians((vDegrees >= 0) ? (Mod(vDegrees, 360)) : (360 - Mod(-vDegrees, -360)))
			, c := oEllipse.h + (oEllipse.Radius - vRadius - vOffset)*Math.Cos(a), s := oEllipse.k + (oEllipse.Radius - vRadius - vOffset)*Math.Sin(a)

		Return, (new Ellipse(c - vRadius, s - vRadius, vRadius*2, vRadius*2))
	}

	Class __Circle Extends __Object {

		__Get(vKey) {
			Switch (vKey) {
				Case "h":
					Return, (this.X + this.__Radius)
				Case "k":
					Return, (this.Y + this.__Radius)
				Case "Radius":
					Return, (this.__Radius)
				Case "Diameter":
					Return, (this.__Radius*2)

				Case "SemiMajor_Axis":
					Return, (this.__Radius)
				Case "SemiMinor_Axis":
					Return, (this.__Radius)
				Case "Area":
					Return, (this.__Radius**2*Math.Pi)
				Case "Circumference":
					Return, (this.__Radius*Math.Tau)
				Case "Eccentricity":
					Return, (0)
				Case "FocalLength":
					Return, (0)
				Case "Apoapsis":
					Return, (this.__Radius)
				Case "Periapsis":
					Return, (this.__Radius)
				Case "SemiLatus_Rectum":
					Return, (0)

				Case "Width":
					Return, (this.__Radius*2)  ;* Make an EllipseObject compatible with a RectangleObject variant for GDIp methods.
				Case "Height":
					Return, (this.__Radius*2)
			}
		}

		__Set(vKey, vValue) {
			Switch (vKey) {
				Case "h":
					ObjRawSet(this, "x", vValue - this.__Radius)
				Case "k":
					ObjRawSet(this, "y", vValue - this.__Radius)
				Case "Radius":
					If (IsObject(vValue)) {
						ObjRawSet(this, "__Radius", [vValue.a, vValue.b]), ObjSetBase(this, Ellipse.__Ellipse)
					}
					Else {
						ObjRawSet(this, "__Radius", vValue)
					}
				Case "Diameter":
					If (IsObject(vValue)) {
						ObjRawSet(this, "__Radius", [vValue.a/2, vValue.b/2]), ObjSetBase(this, Ellipse.__Ellipse)
					}
					Else {
						ObjRawSet(this, "__Radius", vValue/2)
					}
			}
		}
	}

	Class __Ellipse Extends __Object {

		__Get(vKey) {
			Switch (vKey) {
				Case "h":
					Return, (this.X + this.__Radius[0])
				Case "k":
					Return, (this.Y + this.__Radius[1])
				Case "Radius":
					Return, ({"a": this.__Radius[0]
						, "b": this.__Radius[1]})
				Case "Diameter":
					Return, ({"a": this.__Radius[0]*2
						, "b": this.__Radius[1]*2})

				Case "SemiMajor_Axis":
					Return, (Max(this.__Radius[0], this.__Radius[1]))
				Case "SemiMinor_Axis":
					Return, (Min(this.__Radius[0], this.__Radius[1]))
				Case "Area":
					Return, (this.__Radius[0]*this.__Radius[1]*Math.PI)
				Case "Circumference":  ;* Approximation by Srinivasa Ramanujan.
					Return, ((3*(this.__Radius[0] + this.__Radius[1]) - Sqrt((3*this.__Radius[0] + this.__Radius[1])*(this.__Radius[0] + 3*this.__Radius[1])))*Math.Pi)
				Case "Eccentricity":
					Return, (this.FocalLength/this.SemiMajor_Axis)
				Case "FocalLength":
					Return, (Sqrt(this.SemiMajor_Axis**2 - this.SemiMinor_Axis**2))
				Case "Apoapsis":
					Return, (this.SemiMajor_Axis*(1 + this.Eccentricity))
				Case "Periapsis":
					Return, (this.SemiMajor_Axis*(1 - this.Eccentricity))
				Case "SemiLatus_Rectum":
					Return, (this.SemiMajor_Axis*(1 - this.Eccentricity**2))

				Case "Width":
					Return, (this.__Radius[0]*2)
				Case "Height":
					Return, (this.__Radius[1]*2)
			}
		}

		__Set(vKey, vValue) {
			Switch (vKey) {
				Case "h":
					ObjRawSet(this, "x", vValue - this.__Radius[0])
				Case "k":
					ObjRawSet(this, "y", vValue - this.__Radius[1])
				Case "Radius":
					If (IsObject(vValue)) {
						ObjRawSet(this, "__Radius", [vValue.a, vValue.b])
					}
					Else {
						ObjRawSet(this, "__Radius", vValue), ObjSetBase(this, Ellipse.__Circle)
					}
				Case "Diameter":
					If (IsObject(vValue)) {
						ObjRawSet(this, "__Radius", [vValue.a/2, vValue.b/2])
					}
					Else {
						ObjRawSet(this, "__Radius", vValue/2), ObjSetBase(this, Ellipse.__Circle)
					}
			}
		}
	}
}

Class Rectangle {

	;* new Rectangle(x, y, Width, Height)
	__New(vX, vY, vWidth, vHeight) {
		Return, {"x": vX
			, "y": vY
			, "Width": vWidth
			, "Height": vHeight

			, "Base": this.__Rectangle}
	}

	Scale(oRectangle1, oRectangle2) {
		r1 := oRectangle2.Width/oRectangle1.Width, r2 := oRectangle2.Height/oRectangle1.Height

		If (r1 > r2) {
			h := oRectangle2.Height//r1

			Return, (new Rectangle(0, (oRectangle1.Height - h)//2, oRectangle1.Width, h))
		}
		Else {
			w := oRectangle2.Width//r2

			Return, (new Rectangle((oRectangle1.Width - w)//2, 0, 2, oRectangle1.Height))
		}
	}

	Class __Rectangle Extends __Object {

		Clone() {
			Return, (new Rectangle(this.x, this.y, this.Width, this.Height))
		}
	}
}
