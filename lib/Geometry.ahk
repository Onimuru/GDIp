;=====           Function           =========================;

__Validate(vN, ByRef vNumber1 := "", ByRef vNumber2 := "", ByRef vNumber3 := "", ByRef vNumber4 := "") {
	Loop, % vN {
		If (!Math.IsNumeric(vNumber%A_Index%)) {
			vNumber%A_Index% := Round(vNumber%A_Index%)
		}
	}
}

;=====             Class            =========================;

Class Point2 {

	;-----          Constructor         -------------------------;

	;* new Point2(x, y)
	__New(vX, vY) {
		Return, ({"x": vX
			, "y": vY

			, "Base": this.__Point2})
	}

	;-----            Method            -------------------------;
	;-------------------------            General           -----;

	;* Point2.Angle(PointObject, PointObject)
	;* Description:
		;* Calculate the angle from `oPoint21` to `oPoint22`.
	Angle(oPoint21, oPoint22) {
		Return, (Math.ToDegrees(((x := -Math.ATan2({"x": oPoint22.x - oPoint21.x, "y": oPoint22.y - oPoint21.y})) < 0) ? (-x) : (Math.Tau - x)))
	}

	;* Point2.Distance(PointObject, PointObject)
	Distance(oPoint21, oPoint22) {
		Return, (Sqrt((oPoint22.x - oPoint21.x)**2 + (oPoint22.y - oPoint21.y)**2))
	}

	;* Point2.Equals(PointObject, PointObject)
	Equals(oPoint21, oPoint22) {
		Return, (oPoint21.x == oPoint22.x && oPoint21.y == oPoint22.y)
	}

	;* Point2.Slope(PointObject, PointObject)
	;* Note:
		;* Two lines are parallel if their slopes are the same.
		;* Two lines are perpendicular if their slopes are negative reciprocals of each other.
	Slope(oPoint21, oPoint22) {
		Return, ((oPoint22.y - oPoint21.y)/(oPoint22.x - oPoint21.x))
	}

	;* Point2.MidPoint(PointObject, PointObject)
	MidPoint(oPoint21, oPoint22) {
		Return, (new Point2((oPoint21.x + oPoint22.x)/2, (oPoint21.y + oPoint22.y)/2))
	}

	;* Point2.Rotate(PointObject, PointObject, Degrees)
	;* Description:
		;* Calculate the coordinates of `oPoint21` rotated around `oPoint22`.
	Rotate(oPoint21, oPoint22, vTheta) {
		a := -Math.ToRadians((vTheta >= 0) ? (Mod(vTheta, 360)) : (360 - Mod(-vTheta, -360)))
			, c := Math.Cos(a), s := Math.Sin(a)

		x := oPoint21.x - oPoint22.x, y := oPoint21.y - oPoint22.y

		Return, (new Point2(x*c - y*s + oPoint22.x, x*s + y*c + oPoint22.y))
	}

	;-------------------------           Triangle           -----;

	;* Point2.Circumcenter(PointObject, PointObject, PointObject)
	Circumcenter(oPoint21, oPoint22, oPoint23) {
		m := [this.MidPoint(oPoint21, oPoint22), this.MidPoint(oPoint22, oPoint23)]
			, s := [(oPoint22.x - oPoint21.x)/(oPoint21.y - oPoint22.y), (oPoint23.x - oPoint22.x)/(oPoint22.y - oPoint23.y)]
			, p := [m[0].y - s[0]*m[0].x, m[1].y - s[1]*m[1].x]

		Return, (s[0] == s[1] ? 0 : oPoint21.y == oPoint22.y ? new Point2(m[0].x, s[1]*m[0].x + p[1]) : oPoint22.y == oPoint23.y ? new Point2(m[1].x, s[0]*m[1].x + p[0]) : new Point2((p[1] - p[0])/(s[0] - s[1]), s[0]*(p[1] - p[0])/(s[0] - s[1]) + p[0]))
	}

	;-------------------------            Ellipse           -----;

	;* Point2.Foci(EllipseObject)
	Foci(oEllipse) {
		o := [(oEllipse.Radius.a > oEllipse.Radius.b)*(o := oEllipse.FocalLength), (oEllipse.Radius.a < oEllipse.Radius.b)*o]

		Return, ([new Point2(oEllipse.h - o[0], oEllipse.k - o[1]), new Point2(oEllipse.h + o[0], oEllipse.k + o[1])])
	}

	;* Point2.Epicycloid(EllipseObject1, EllipseObject2, Degrees)
	Epicycloid(oEllipse1, oEllipse2, vTheta := 0) {
		a := Math.ToRadians((vTheta >= 0) ? (Mod(vTheta, 360)) : (360 - Mod(-vTheta, -360)))

		Return, (new Point2(oEllipse1.h + (oEllipse1.Radius + oEllipse2.Radius)*Math.Cos(a) - oEllipse2.Radius*Math.Cos((oEllipse1.Radius/oEllipse2.Radius + 1)*a), oEllipse.k - o[2], oEllipse1.k + (oEllipse1.Radius + oEllipse2.Radius)*Math.Sin(a) - oEllipse2.Radius*Math.Sin((oEllipse1.Radius/oEllipse2.Radius + 1)*a)))
	}

	;* Point2.Hypocycloid([EllipseObject1, EllipseObject2], Degrees)
	Hypocycloid(oEllipses, vTheta := 0) {
		a := Math.ToRadians((vTheta >= 0) ? (Mod(vTheta, 360)) : (360 - Mod(-vTheta, -360)))

		Return, (new Point2(oEllipse1.h + (oEllipse1.Radius - oEllipse2.Radius)*Math.Cos(a) + oEllipse2.Radius*Math.Cos((oEllipse1.Radius/oEllipse2.Radius - 1)*a), oEllipse1.k + (oEllipse1.Radius - oEllipse2.Radius)*Math.Sin(a) - oEllipse2.Radius*Math.Sin((oEllipse1.Radius/oEllipse2.Radius - 1)*a)))
	}

	;* Point2.OnEllipse(EllipseObject, Degrees)
	;* Description:
		;* Calculate the coordinates of a point on the circumference of an ellipse.
	OnEllipse(oEllipse, vTheta := 0) {
		a := -(Math.ToRadians((vTheta >= 0) ? (Mod(vTheta, 360)) : (360 - Mod(-vTheta, -360))))

		If (IsObject(oEllipse.Radius)) {
			t := Math.Tan(a), o := [oEllipse.Radius.a*oEllipse.Radius.b, Sqrt(oEllipse.Radius.b**2 + oEllipse.Radius.a**2*t**2)], s := (90 < vTheta && vTheta <= 270) ? (-1) : (1)

			Return, (new Point2(oEllipse.h + (o[0]/o[1])*s, oEllipse.k + ((o[0]*t)/o[1])*s))
		}
		Return, (new Point2(oEllipse.h + oEllipse.Radius*Math.Cos(a), oEllipse.k + oEllipse.Radius*Math.Sin(a)))
	}

	;-----         Nested Class         -------------------------;

	Class __Point2 extends __Object {

		Clone() {
			Return, (new Point2(this.x, this.y))
		}
	}
}

Class Point3 {

	;* new Point3([x, y, z])
	__New(oData := "") {
		Return, ({"x": oData[0]
			, "y": oData[1]
			, "z": oData[2]

			, "Base": this.__Point3})
	}

	Rotate(vDegrees, vMode) {
		;* Here we use Euler's matrix formula for rotating a 3D point x degrees around the x-axis:

		;? [ a  b  c ] [ x ]   [ x*a + y*b + z*c ]
		;? [ d  e  f ] [ y ] = [ x*d + y*e + z*f ]
		;? [ g  h  i ] [ z ]   [ x*g + y*h + z*i ]

		Switch (vMode) {
			Case "x":
				;? [1      0         0  ]
				;? [0    cos(a)   sin(a)]
				;? [0   -sin(a)   cos(a)]

				a := Math.ToRadians((vDegrees >= 0) ? (Mod(vDegrees, 360)) : (360 - Mod(-vDegrees, -360)))
					, c := Math.Cos(a), s := Math.Sin(a)

				Return, (new Point3([this.x, this.y*c + this.z*s, this.y*-s + this.z*c]))
			Case "y":
				;? [ cos(a)   0    sin(a)]
				;? [   0      1      0   ]
				;? [-sin(a)   0    cos(a)]

				a := Math.ToRadians((vDegrees >= 0) ? (Mod(vDegrees, 360)) : (360 - Mod(-vDegrees, -360)))
					, c := Math.Cos(a), s := Math.Sin(a)

				Return, (new Point3([this.x*c + this.z*s, this.y, this.x*-s + this.z*c]))
			Case "z":
				;? [ cos(a)   sin(a)   0]
				;? [-sin(a)   cos(a)   0]
				;? [    0       0      1]

				a := Math.ToRadians((vDegrees >= 0) ? (Mod(vDegrees, 360)) : (360 - Mod(-vDegrees, -360)))
					, c := Math.Cos(a), s := Math.Sin(a)

				Return, (new Point3([this.x*c + this.y*s, this.x*-s + this.y*c, this.z]))
		}
	}

	Class __Point3 extends __Object {

		Clone() {
			Return, (new Point3([this.x, this.y, this.z]))
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
				, "__Radius": r[0]

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

	Class __Circle extends __Object {

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

	Class __Ellipse extends __Object {

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
			switch (vKey) {
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

	Class __Rectangle extends __Object {

		Clone() {
			Return, (new Rectangle(this.x, this.y, this.Width, this.Height))
		}
	}
}

Class Vector2 {

	;* new Vector2(x [Number || Vector2], (y))
	__New(vX := 0, vY := "") {
		If (Math.IsNumeric(vX)) {
			If (Math.IsNumeric(vY)) {
				Return, ({"x": vX
					, "y": vY

					, "Base": this.__Vector2})
			}

			Return, ({"x": vX
				, "y": vX

				, "Base": this.__Vector2})
		}

		Return, ({"x": vX.x
			, "y": vX.y

			, "Base": this.__Vector2})
	}

	;* Vector2.Multiply(v1 [Vector2], v2 [Vector2 || Number])
	;* Description:
		;* Multiply a vector by another vector or a scalar.
	Multiply(oVector2a, oVector2b) {
		If (IsObject(oVector2b)) {
			Return, (new Vector2(oVector2a.x*oVector2b.x, oVector2a.y*oVector2b.y))
		}

		Return, (new Vector2(oVector2a.x*oVector2b, oVector2a.y*oVector2b))
	}

	;* Vector2.Divide(v1 [Vector2], v2 [Vector2 || Number])
	;* Description:
		;* Divide a vector by another vector or a scalar.
	Divide(oVector2a, oVector2b) {
		If (IsObject(oVector2b)) {
			Return, (new Vector2(oVector2a.x/oVector2b.x, oVector2a.y/oVector2b.y))
		}

		Return, (new Vector2(oVector2a.x/oVector2b, oVector2a.y/oVector2b))
	}

	;* Vector2.Add(v1 [Vector2], v2 [Vector2 || Number])
	;* Description:
		;* Add to a vector another vector or a scalar.
	Add(oVector2a, oVector2b) {
		If (IsObject(oVector2b)) {
			Return, (new Vector2(oVector2a.x + oVector2b.x, oVector2a.y + oVector2b.y))
		}

		Return, (new Vector2(oVector2a.x + oVector2b, oVector2a.y + oVector2b))
	}

	;* Vector2.Subtract(v1 [Vector2], v2 [Vector2 || Number])
	;* Description:
		;* Subtract from a vector another vector or scalar.
	Subtract(oVector2a, oVector2b) {
		If (IsObject(oVector2b)) {
			Return, (new Vector2(oVector2a.x - oVector2b.x, oVector2a.y - oVector2b.y))
		}

		Return, (new Vector2(oVector2a.x - oVector2b, oVector2a.y - oVector2b))
	}

	;* Vector2.Clamp(v1 [Vector2], v2 [Vector2 || Number], v3 [Vector2 || Number])
	;* Description:
		;* Clamp a vector to the given minimum and maximum vectors or values.
	;* Note:
		;* Assumes `v2 < v3`.
	;* Parameters:
		;* v1:
			;* Input vector.
		;* v2:
			;* Minimum vector or number.
		;* v3:
			;* Maximum vector or number.
	Clamp(oVector2, oMinimum, oMaximum) {
		If (IsObject(oMinimum) && IsObject(oMaximum)) {
			Return, (new Vector2(Math.Max(oMinimum.x, Math.Min(oMaximum.x, oVector2.x)), Math.Max(oMinimum.y, Math.Min(oMaximum.y, oVector2.y))))
		}

		Return, (new Vector2(Math.Max(oMinimum, Math.Min(oMaximum, oVector2.x)), Math.Max(oMinimum, Math.Min(oMaximum, oVector2.y))))
	}

	;* Vector2.Cross(v1 [Vector2], v2 [Vector2])
	;* Description:
		;* Calculate the cross product of two vectors.
	Cross(oVector2a, oVector2b) {
		Return, (oVector2a.x*oVector2b.y - oVector2a.y*oVector2b.x)
	}

	;* Vector2.Distance(v1 [Vector2], v2 [Vector2])
	;* Description:
		;* Calculate the distance between two vectors.
	Distance(oVector2a, oVector2b) {
		Return, (Sqrt((oVector2a.x - oVector2b.x)**2 + (oVector2a.y - oVector2b.y)**2))
	}

	;* Vector2.DistanceSquared(v1 [Vector2], v2 [Vector2])
	DistanceSquared(oVector2a, oVector2b) {
		Return, ((oVector2a.x - oVector2b.x)**2 + (oVector2a.y - oVector2b.y)**2)
	}

	;* Vector2.Dot(v1 [Vector2], v2 [Vector2])
	;* Description:
		;* Calculate the dot product of two vectors.
	Dot(oVector2a, oVector2b) {
		Return, (oVector2a.x*oVector2b.x + oVector2a.y*oVector2b.y)
	}

	;* Vector2.Equals(v1 [Vector2], v2 [Vector2])
	;* Description:
		;* Indicates whether two vectors are equal.
	Equals(oVector2a, oVector2b) {
		Return, (oVector2a.x == oVector2b.x && oVector2a.y == oVector2b.y)
	}

	;* Vector2.Lerp(v1 [Vector2], v2 [Vector2], a [Number])
	;* Description:
		;* Returns a new vector that is the linear blend of the two given vectors.
	;* Parameters:
		;* v1:
			;* The starting vector.
		;* v2:
			;* The vector to interpolate towards.
		;* a:
			;* Interpolation factor, typically in the closed interval [0, 1].
	Lerp(oVector2a, oVector2b, vAlpha) {
		Return, (new Vector2(oVector2a.x + (oVector2b.x - oVector2a.x)*vAlpha, oVector2a.y + (oVector2b.y - oVector2a.y)*vAlpha))
	}

	;* Vector2.Min(v1 [Vector2], v2 [Vector2])
	Min(oVector2a, oVector2b) {
		Return, (new Vector2(Math.Min(oVector2a.x, oVector2b.x), Math.Min(oVector2a.y, oVector2b.y)))
	}

	;* Vector2.Max(v1 [Vector2], v2 [Vector2])
	Max(oVector2a, oVector2b) {
		Return, (new Vector2(Math.Max(oVector2a.x, oVector2b.x), Math.Max(oVector2a.y, oVector2b.y)))
	}

	;* Vector2.Transform(v [Vector2], m [Matrix3])
	Transform(oVector2, oMatrix3) {
		x := oVector2.x, y := oVector2.y
			, m := oMatrix3.Elements

		Return, (new Vector2(m[0]*x + m[3]*y + m[6], m[1]*x + m[4]*y + m[7]))
	}

	Class __Vector2 extends __Object {

		__Get(vKey) {
			Switch (vKey) {

				;* Vector2.Length
				;* Description:
					;* Calculates the length (magnitude) of the vector.
				Case "Length":
					Return, (Sqrt(this.x**2 + this.y**2))

				;* Vector2.LengthSquared
				Case "LengthSquared":
					Return, (this.x**2 + this.y**2)

				;* 2DVectorObject[0 || 1]
				Default:
					If (Math.IsInteger(vKey)) {
						Return, ([this.x, this.y][vKey])
					}
			}
		}

		__Set(vKey, vValue) {
			Switch (vKey) {

				;* Vector2.Length := Number
				Case "Length":
					Return, (this.normalize().multiply(vValue))

				;* Vector2[0 || 1] := Number
				Default:
					switch (vKey) {
						Case 0:
							this.x := vValue
						Case 1:
							this.y := vValue
					}
					Return
			}
		}

        Multiply(oVector2) {
			If (IsObject(oVector2)) {
				this.x *= oVector2.x, this.y *= oVector2.y
			}
			Else {
				this.x *= oVector2, this.y *= oVector2
			}

			Return, (this)
        }

        Divide(oVector2) {
			If (IsObject(oVector2)) {
				this.x /= oVector2.x, this.y /= oVector2.y
			}
			Else {
				this.x /= oVector2, this.y /= oVector2
			}

			Return, (this)
        }

		Add(oVector2) {
			If (IsObject(oVector2)) {
				this.x += oVector2.x, this.y += oVector2.y
			}
			Else {
				this.x += oVector2, this.y += oVector2
			}

			Return, (this)
		}

		Subtract(oVector2) {
			If (IsObject(oVector2)) {
				this.x -= oVector2.x, this.y -= oVector2.y
			}
			Else {
				this.x -= oVector2, this.y -= oVector2
			}

			Return, (this)
		}

		Clamp(oMinimum, oMaximum) {
			If (IsObject(oMinimum) && IsObject(oMaximum)) {
				this.x := Math.Max(oMinimum.x, Math.Min(oMaximum.x, this.x)), this.y := Math.Max(oMinimum.y, Math.Min(oMaximum.y, this.y))
			}
			Else {
				this.x := Math.Max(oMinimum, Math.Min(oMaximum, this.x)), this.y := Math.Max(oMinimum, Math.Min(oMaximum, this.y))
			}

			Return, (this)
		}

		;* Vector2.Negate()
		;* Description:
			;* Inverts this vector.
		Negate() {
			this.x *= -1, this.y *= -1

			Return, (this)
		}

		;* Vector2.Normalize()
		;* Description:
			;* This method normalises the vector such that it's length/magnitude is 1. The result is called a unit vector.
        Normalize() {
			m := this.Length

			If (m) {
				this.x /= m, this.y /= m
			}

			Return, (this)
        }

		Transform(oMatrix3) {
			x := this.x, y := this.y
				, m := oMatrix3.Elements

			this.x := m[0]*x + m[3]*y + m[6], this.y := m[1]*x + m[4]*y + m[7]

			Return, (this)
		}

		Copy(oVector2) {
			this.x := oVector2.x, this.y := oVector2.y
		}

		Clone() {
			Return, (new Vector2(this))
		}
	}
}

Class Vector3 {

	;* new Vector3(x [Number || Vector2 || Vector3], (y), (z))
	__New(vX := 0, vY := "", vZ := "") {
		If (Math.IsNumeric(vX)) {
			If (Math.IsNumeric(vY)) {
				Return, ({"x": vX
					, "y": vY
					, "z": vZ

					, "Base": this.__Vector3})
			}

			Return, ({"x": vX
				, "y": vX
				, "z": vX

				, "Base": this.__Vector3})
		}

		Return, ({"x": vX.x
			, "y": vX.y
			, "z": vX.z

			, "Base": this.__Vector3})
	}

	;* Vector3.Multiply(v1 [Vector3], v2 [Vector3 || Number])
	;* Description:
		;* Multiply a vector by another vector or a scalar.
	Multiply(oVector3a, oVector3b) {
		If (IsObject(oVector3b)) {
			Return, (new Vector3(oVector3a.x*oVector3b.x, oVector3a.y*oVector3b.y, oVector3a.z*oVector3b.z))
		}

		Return, (new Vector3(oVector3a.x*oVector3b, oVector3a.y*oVector3b, oVector3a.z*oVector3b))
	}

	;* Vector3.Divide(v1 [Vector3], v2 [Vector3 || Number])
	;* Description:
		;* Divide a vector by another vector or a scalar.
	Divide(oVector3a, oVector3b) {
		If (IsObject(oVector3b)) {
			Return, (new Vector3(oVector3a.x/oVector3b.x, oVector3a.y/oVector3b.y, oVector3a.z/oVector3b.z))
		}

		Return, (new Vector3(oVector3a.x/oVector3b, oVector3a.y/oVector3b, oVector3a.z/oVector3b))
	}

	;* Vector3.Add(v1 [Vector3], v2 [Vector3 || Number])
	;* Description:
		;* Add to a vector another vector or a scalar.
	Add(oVector3a, oVector3b) {
		If (IsObject(oVector3b)) {
			Return, (new Vector3(oVector3a.x + oVector3b.x, oVector3a.y + oVector3b.y, oVector3a.z + oVector3b.z))
		}

		Return, (new Vector3(oVector3a.x + oVector3b, oVector3a.y + oVector3b, oVector3a.z + oVector3b))
	}

	;* Vector3.Subtract(v1 [Vector3], v2 [Vector3 || Number])
	;* Description:
		;* Subtract from a vector another vector or scalar.
	Subtract(oVector3a, oVector3b) {
		If (IsObject(oVector3b)) {
			Return, (new Vector3(oVector3a.x - oVector3b.x, oVector3a.y - oVector3b.y, oVector3a.z - oVector3b.z))
		}

		Return, (new Vector3(oVector3a.x - oVector3b, oVector3a.y - oVector3b, oVector3a.z - oVector3b))
	}

	;* Vector3.Clamp(v1 [Vector3], v2 [Vector3 || Number], v3 [Vector3 || Number])
	;* Description:
		;* Clamp a vector to the given minimum and maximum vectors or values.
	;* Note:
		;* Assumes `v2 < v3`.
	;* Parameters:
		;* v1:
			;* Input vector.
		;* v2:
			;* Minimum vector or number.
		;* v3:
			;* Maximum vector or number.
	Clamp(oVector3, oMinimum, oMaximum) {
		If (IsObject(oMinimum) && IsObject(oMaximum)) {
			Return, (new Vector3(Math.Max(oMinimum.x, Math.Min(oMaximum.x, oVector3.x)), Math.Max(oMinimum.y, Math.Min(oMaximum.y, oVector3.y)), Math.Max(oMinimum.z, Math.Min(oMaximum.z, oVector3.z))))
		}

		Return, (new Vector3(Math.Max(oMinimum, Math.Min(oMaximum, oVector3.x)), Math.Max(oMinimum, Math.Min(oMaximum, oVector3.y)), Math.Max(oMinimum, Math.Min(oMaximum, oVector3.z))))
	}

	;* Vector3.Cross(v1 [Vector3], v2 [Vector3])
	;* Description:
		;* Calculate the cross product (vector) of two vectors (greatest yield for perpendicular vectors).
	Cross(oVector3a, oVector3b) {
		a := oVector3a, a1 := a.x, a2 := a.y, a3 := a.z
			, b := oVector3b, b1 := b.x, b2 := b.y, b3 := b.z

		;[a2*b3 - a3*b2]
		;[a3*b1 - a1*b3]
		;[a1*b2 - a2*b1]

		Return, (new Vector3(a2*b3 - a3*b2, a3*b1 - a1*b3, a1*b2 - a2*b1))
	}

	;* Vector3.Distance(v1 [Vector3], v2 [Vector3])
	;* Description:
		;* Calculate the distance between two vectors.
	Distance(oVector3a, oVector3b) {
		Return, (Sqrt((oVector3a.x - oVector3b.x)**2 + (oVector3a.y - oVector3b.y)**2 + (oVector3a.z - oVector3b.z)**2))
	}

	;* Vector3.DistanceSquared(v1 [Vector3], v2 [Vector3])
	DistanceSquared(oVector3a, oVector3b) {
		Return, ((oVector3a.x - oVector3b.x)**2 + (oVector3a.y - oVector3b.y)**2 + (oVector3a.z - oVector3b.z)**2)
	}

	;* Vector3.Dot(v1 [Vector3], v2 [Vector3])
	;* Description:
		;* Calculate the dot product (scalar) of two vectors (greatest yield for parallel vectors).
	Dot(oVector3a, oVector3b) {
		Return, (oVector3a.x*oVector3b.x + oVector3a.y*oVector3b.y + oVector3a.z*oVector3b.z)  ;? Math.Abs(a.Length)*Math.Abs(b.Length)*Math.Cos(AOB)
	}

	;* Vector3.Equals(v1 [Vector3], v2 [Vector3])
	;* Description:
		;* Indicates whether two vectors are equal.
	Equals(oVector3a, oVector3b) {
		Return, (oVector3a.x == oVector3b.x && oVector3a.y == oVector3b.y && oVector3a.z == oVector3b.z)
	}

	;* Vector3.Lerp(v1 [Vector3], v2 [Vector3], a [Number])
	;* Description:
		;* Returns a new vector that is the linear blend of the two given vectors.
	;* Parameters:
		;* v1:[]
			;* The starting vector.
		;* v2:
			;* The vector to interpolate towards.
		;* a:
			;* Interpolation factor, typically in the closed interval [0, 1].
	Lerp(oVector3a, oVector3b, vAlpha) {
		Return, (new Vector3(oVector3a.x + (oVector3b.x - oVector3a.x)*vAlpha, oVector3a.y + (oVector3b.y - oVector3a.y)*vAlpha, oVector3a.z + (oVector3b.z - oVector3a.z)*vAlpha))
	}

	;* Vector3.Min(v1 [Vector3], v2 [Vector3])
	Min(oVector3a, oVector3b) {
		Return, (new Vector3(Math.Min(oVector3a.x, oVector3b.x), Math.Min(oVector3a.y, oVector3b.y), Math.Min(oVector3a.z, oVector3b.z)))
	}

	;* Vector3.Max(v1 [Vector3], v2 [Vector3])
	Max(oVector3a, oVector3b) {
		Return, (new Vector3(Math.Max(oVector3a.x, oVector3b.x), Math.Max(oVector3a.y, oVector3b.y), Math.Max(oVector3a.z, oVector3b.z)))
	}

	;* Vector3.Transform(v [Vector3], m [Matrix3])
	Transform(oVector3, oMatrix3) {
		x := oVector3.x, y := oVector3.y, z := oVector3.z
			, m := oMatrix3.Elements

		Return, (new Vector3(m[0]*x + m[3]*y + m[6]*z, m[1]*x + m[4]*y + m[7]*z, m[2]*x + m[5]*y + m[8]*z))
	}

	Class __Vector3 extends __Object {

		__Get(vKey) {
			Switch (vKey) {

				;* Vector3.Length
				;* Description:
					;* Calculates the length (magnitude) of the vector.
				Case "Length":
					Return, (Sqrt(this.x**2 + this.y**2 + this.z**2))

				;* Vector3.LengthSquared
				Case "LengthSquared":
					Return, (this.x**2 + this.y**2 + this.z**2)

				;* Vector3[0 || 1 || 2]
				Default:
					If (Math.IsInteger(vKey)) {
						Return, ([this.x, this.y, this.z][vKey])
					}
			}
		}

		__Set(vKey, vValue) {
			Switch (vKey) {

				;* Vector3.Length := Number
				Case "Length":
					Return, (this.normalize().multiply(vValue))

				;* Vector3[0 || 1 || 2] := Number
				Default:
					switch (vKey) {
						Case 0:
							this.x := vValue
						Case 1:
							this.y := vValue
						Case 2:
							this.z := vValue
					}
					Return
			}
		}

        Multiply(oVector3) {
			If (IsObject(oVector3)) {
				this.x *= oVector3.x, this.y *= oVector3.y, this.z *= oVector3.z
			}
			Else {
				this.x *= oVector3, this.y *= oVector3, this.z *= oVector3
			}

			Return, (this)
        }

        Divide(oVector3) {
			If (IsObject(oVector3)) {
				this.x /= oVector3.x, this.y /= oVector3.y, this.z /= oVector3.z
			}
			Else {
				this.x /= oVector3, this.y /= oVector3, this.z /= oVector3
			}

			Return, (this)
        }

		Add(oVector3) {
			If (IsObject(oVector3)) {
				this.x += oVector3.x, this.y += oVector3.y, this.z += oVector3.z
			}
			Else {
				this.x += oVector3, this.y += oVector3, this.z += oVector3
			}

			Return, (this)
		}

		Subtract(oVector3) {
			If (IsObject(oVector3)) {
				this.x -= oVector3.x, this.y -= oVector3.y, this.z -= oVector3.z
			}
			Else {
				this.x -= oVector3, this.y -= oVector3, this.z -= oVector3
			}

			Return, (this)
		}

		Clamp(oMinimum, oMaximum) {
			If (IsObject(oMinimum) && IsObject(oMaximum)) {
				this.x := Math.Max(oMinimum.x, Math.Min(oMaximum.x, this.x)), this.y := Math.Max(oMinimum.y, Math.Min(oMaximum.y, this.y)), this.z := Math.Max(oMinimum.z, Math.Min(oMaximum.z, this.z))
			}
			Else {
				this.x := Math.Max(oMinimum, Math.Min(oMaximum, this.x)), this.y := Math.Max(oMinimum, Math.Min(oMaximum, this.y)), this.z := Math.Max(oMinimum, Math.Min(oMaximum, this.z))
			}

			Return, (this)
		}

		;* Vector3.Negate()
		;* Description:
			;* Inverts this vector.
		Negate() {
			this.x *= -1, this.y *= -1, this.z *= -1

			Return, (this)
		}

		;* Vector3.Normalize()
		;* Description:
			;* This method normalises the vector such that it's length/magnitude is 1. The result is called a unit vector.
        Normalize() {
			m := this.Length

			If (m) {
				this.x /= m, this.y /= m, this.z /= m
			}

			Return, (this)
        }

		Transform(oMatrix3) {
			x := this.x, y := this.y, z := this.z
				, m := oMatrix3.Elements

			this.x := m[0]*x + m[3]*y + m[6]*z, this.y := m[1]*x + m[4]*y + m[7]*z, this.z := m[2]*x + m[5]*y + m[8]*z

			Return, (this)
		}

		Copy(oVector3) {
			this.x := oVector3.x, this.y := oVector3.y, this.z := oVector3.z
		}

		Clone() {
			Return, (new Vector3(this))
		}
	}
}

Class Matrix3 {

	__New() {
		Return, ({"Elements": [1, 0, 0, 0, 1, 0, 0, 0, 1]
			, "Base": this.__Matrix3})
	}

	Multiply(oMatrix3a, oMatrix3b) {
		a := oMatrix3a.Elements, a11 := a[0], a12 := a[1], a13 := a[2], a21 := a[3], a22 := a[4], a23 := a[5], a31 := a[6], a32 := a[7], a33 := a[8]
			, b := oMatrix3b.Elements, b11 := b[0], b12 := b[1], b13 := b[2], b21 := b[3], b22 := b[4], b23 := b[5], b31 := b[6], b32 := b[7], b33 := b[8]

		;[a11*b11 + a12*b21 + a13*b31   a11*b12 + a12*b22 + a13*b32   a11*b13 + a12*b23 + a13*b33]
		;[a21*b11 + a22*b21 + a23*b31   a21*b12 + a22*b22 + a23*b32   a21*b13 + a22*b23 + a23*b33]
		;[a31*b11 + a32*b21 + a33*b31   a31*b12 + a32*b22 + a33*b32   a31*b13 + a32*b23 + a33*b33]

		Return, ({"Elements": [a11*b11 + a12*b21 + a13*b31, a11*b12 + a12*b22 + a13*b32, a11*b13 + a12*b23 + a13*b33
							 , a21*b11 + a22*b21 + a23*b31, a21*b12 + a22*b22 + a23*b32, a21*b13 + a22*b23 + a23*b33
							 , a31*b11 + a32*b21 + a33*b31, a31*b12 + a32*b22 + a33*b32, a31*b13 + a32*b23 + a33*b33]

			, "Base": this.__Matrix3})
	}

	RotateX(vTheta) {
		c := Math.Cos(vTheta), s := Math.Sin(vTheta)

		;[1      0         0  ]
		;[0    cos(a)   sin(a)]
		;[0   -sin(a)   cos(a)]

		Return, ({"Elements": [1, 0, 0, 0, c, s, 0, -s, c]
			, "Base": this.__Matrix3})
	}

	RotateY(vTheta) {
		c := Math.Cos(vTheta), s := Math.Sin(vTheta)

		;[cos(a)   0   -sin(a)]
		;[  0      1      0   ]
		;[sin(a)   0    cos(a)]

		Return, ({"Elements": [c, 0, -s, 0, 1, 0, s, 0, c]
			, "Base": this.__Matrix3})
	}

	RotateZ(vTheta) {
		c := Cos(vTheta), s := Sin(vTheta)

		;[ cos(a)   sin(a)   0]
		;[-sin(a)   cos(a)   0]
		;[    0       0      1]

		Return, ({"Elements": [c, s, 0, -s, c, 0, 0, 0, 1]
			, "Base": this.__Matrix3})
	}

	Class __Matrix3 {

		Set(oElements) {
			this.elements := oElements

			Return, (this)

		}

		RotateX(vTheta) {
			c := Math.Cos(vTheta), s := Math.Sin(vTheta)

			this.Elements := [1.0, 0.0, 0.0, 0.0, c, s, 0.0, -s, c]

			Return, (this)
		}

		RotateY(vTheta) {
			c := Cos(vTheta), s := Sin(vTheta)

			this.Elements := [c, 0.0, -s, 0.0, 1.0, 0.0, s, 0.0, c]

			Return, (this)
		}

		RotateZ(vTheta) {
			c := Cos(vTheta), s := Sin(vTheta)

			this.Elements := [c, s, 0.0, -s, c, 0.0, 0.0, 0.0, 1.0]

			Return, (this)
		}

		Print() {
			e := this.Elements

			Loop, % 9 {
				i := A_Index - 1
					, r .= ((A_Index == 1) ? ("[") : (["`n "][Mod(i, 3)])) . [" "][!(e[i] >= 0)] . e[i] . ((i < 8) ? (", ") : (" ]"))
			}

			Return, (r)
		}
	}
}
