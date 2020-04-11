ValidateData(ByRef oData, vN) {
	If (!IsObject(oData)) {
		oData := []
	}
	oData.Length := vN

	For i, v in oData {
		If (!Math.IsNumeric(v)) {
			oData[i] := Round(v)
		}
	}
}

Class Point2D {

	;-----         Constructor          -------------------------;

	;* new Point2D([x, y])
	__New(oData := "") {
		ValidateData(oData, 2)

		Return, ({"x": oData[0]
			, "y": oData[1]

			, "Base": this.__Point2D})
	}

	;-----            Method            -------------------------;
	;-------------------------           General            -----;

	;* Point2D.Angle([PointObj1, PointObj2])
	;* Description:
		;* Calculate the angle from PointObj1 to PointObj2.
	Angle(oPoints) {
		Return, Math.ToDegrees(((x := -Math.Atan2({"x": oPoints[1].x - oPoints[0].x, "y": oPoints[1].y - oPoints[0].y})) < 0) ? (Math.Tau + x) : (x))
	}

	;* Point2D.Distance([PointObj1, PointObj2])
	Distance(oPoints) {
		Return, (Sqrt((oPoints[0].x - oPoints[1].x)**2 + (oPoints[0].y - oPoints[1].y)**2))
	}

	;* Point2D.Equals([PointObj1, PointObj2])
	Equals(oPoints) {
		Return, (oPoints[0].x == oPoints[1].x && oPoints[0].y == oPoints[1].y)
	}

	;* Point2D.Slope([PointObj1, PointObj2])
	Slope(oPoints) {
		Return, ((oPoints[1].y - oPoints[0].y)/(oPoints[1].x - oPoints[0].x))
	}

	;* Point2D.MidPoint([PointObj1, PointObj2])
	MidPoint(oPoints) {
		Return, (new Point2D([(oPoints[0].x + oPoints[1].x)/2, (oPoints[0].y + oPoints[1].y)/2]))
	}

	;* Point2D.Rotate([PointObj1, PointObj2], Degrees)
	;* Description:
		;* Calculate the coordinates of PointObj1 rotated around PointObj2.
	Rotate(oPoints, vTheta) {
		a := -Math.ToRadians((vTheta >= 0) ? (Mod(vTheta, 360)) : (360 - Mod(-vTheta, -360)))
			, c := Math.Cos(a), s := Math.Sin(a)

		x := oPoints[0].x - oPoints[1].x, y := oPoints[0].y - oPoints[1].y

		Return, (new Point2D([x*c - y*s + oPoints[1].x, x*s + y*c + oPoints[1].y]))
	}

	;-------------------------           Triangle           -----;

	;* Point2D.Circumcenter([PointObj1, PointObj2, PointObj3])
	Circumcenter(oPoints) {
		m := [this.MidPoint([oPoints[0], oPoints[1]]), this.MidPoint([oPoints[1], oPoints[2]])]
			, s := [(oPoints[1].x - oPoints[0].x)/(oPoints[0].y - oPoints[1].y), (oPoints[2].x - oPoints[1].x)/(oPoints[1].y - oPoints[2].y)]
			, p := [m[0].y - s[0]*m[0].x, m[1].y - s[1]*m[1].x]

		Return, (s[0] == s[1] ? 0 : oPoints[0].y == oPoints[1].y ? new Point2D([m[0].x, s[1]*m[0].x + p[1]]) : oPoints[1].y == oPoints[2].y ? new Point2D([m[1].x, s[0]*m[1].x + p[0]]) : new Point2D([(p[1] - p[0])/(s[0] - s[1]), s[0]*(p[1] - p[0])/(s[0] - s[1]) + p[0]]))
	}

	;-------------------------           Ellipse            -----;

	;* Point2D.Foci(EllipseObj)
	Foci(oEllipse) {
		o := [(oEllipse.Radius.a > oEllipse.Radius.b)*(o := oEllipse.FocalLength), (oEllipse.Radius.a < oEllipse.Radius.b)*o]

		Return, ([new Point2D([oEllipse.h - o[0], oEllipse.k - o[1]]), new Point2D([oEllipse.h + o[0], oEllipse.k + o[1]])])
	}

	;* Point2D.Epicycloid([EllipseObj1, EllipseObj2], Degrees)
	Epicycloid(oEllipses, vTheta := 0) {
		a := Math.ToRadians((vTheta >= 0) ? Mod(vTheta, 360) : 360 - Mod(-vTheta, -360))

		Return, (new Point2D([oEllipses[0].h + (oEllipses[0].Radius + oEllipses[1].Radius)*Math.Cos(a) - oEllipses[1].Radius*Math.Cos((oEllipses[0].Radius/oEllipses[1].Radius + 1)*a), oEllipse.k - o[2], oEllipses[0].k + (oEllipses[0].Radius + oEllipses[1].Radius)*Math.Sin(a) - oEllipses[1].Radius*Math.Sin((oEllipses[0].Radius/oEllipses[1].Radius + 1)*a)]))
	}

	;* Point2D.Hypocycloid([EllipseObj1, EllipseObj2], Degrees)
	Hypocycloid(oEllipses, vTheta := 0) {
		a := Math.ToRadians((vTheta >= 0) ? Mod(vTheta, 360) : 360 - Mod(-vTheta, -360))

		Return, (new Point2D([oEllipses[0].h + (oEllipses[0].Radius - oEllipses[1].Radius)*Math.Cos(a) + oEllipses[1].Radius*Math.Cos((oEllipses[0].Radius/oEllipses[1].Radius - 1)*a), oEllipses[0].k + (oEllipses[0].Radius - oEllipses[1].Radius)*Math.Sin(a) - oEllipses[1].Radius*Math.Sin((oEllipses[0].Radius/oEllipses[1].Radius - 1)*a)]))
	}

	;* Point2D.OnEllipse(EllipseObj, Degrees)
	;* Description:
		;* Calculate the coordinates of a point on the circumference of EllipseObj.
	OnEllipse(oEllipse, vTheta := 0) {
		a := -(Math.ToRadians((vTheta >= 0) ? Mod(vTheta, 360) : 360 - Mod(-vTheta, -360)))

		If (IsObject(oEllipse.Radius)) {
			t := Math.Tan(a), o := [oEllipse.Radius.a*oEllipse.Radius.b, Sqrt(oEllipse.Radius.b**2 + oEllipse.Radius.a**2*t**2)], s := (90 < vTheta && vTheta <= 270) ? -1 : 1

			Return, (new Point2D([oEllipse.h + (o[0]/o[1])*s, oEllipse.k + ((o[0]*t)/o[1])*s]))
		}
		Return, (new Point2D([oEllipse.h + oEllipse.Radius*Math.Cos(a), oEllipse.k + oEllipse.Radius*Math.Sin(a)]))
	}

	;-----         Nested Class         -------------------------;

	Class __Point2D Extends __Object {
		Clone() {
			Return, (new Point2D([this.x, this.y]))
		}
	}
}

Class Point3D {

	;* new Point3D([x, y, z])
	__New(oData := "") {
		ValidateData(oData, 3)

		Return, ({"x": oData[0]
			, "y": oData[1]
			, "z": oData[2]

			, "Base": this.__Point3D})
	}

	Class __Point3D Extends __Object {
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

					a := Math.ToRadians((vDegrees >= 0) ? Mod(vDegrees, 360) : 360 - Mod(-vDegrees, -360))
						, c := Math.Cos(a), s := Math.Sin(a)

					Return, (new Point3D([this.x, this.y*c + this.z*s, this.y*-s + this.z*c]))
				Case "y":
					;? [ cos(a)   0    sin(a)]
					;? [   0      1      0   ]
					;? [-sin(a)   0    cos(a)]

					a := Math.ToRadians((vDegrees >= 0) ? Mod(vDegrees, 360) : 360 - Mod(-vDegrees, -360))
						, c := Math.Cos(a), s := Math.Sin(a)

					Return, (new Point3D([this.x*c + this.z*s, this.y, this.x*-s + this.z*c]))
				Case "z":
					;? [ cos(a)   sin(a)   0]
					;? [-sin(a)   cos(a)   0]
					;? [    0       0      1]

					a := Math.ToRadians((vDegrees >= 0) ? Mod(vDegrees, 360) : 360 - Mod(-vDegrees, -360))
						, c := Math.Cos(a), s := Math.Sin(a)

					Return, (new Point3D([this.x*c + this.y*s, this.x*-s + this.y*c, this.z]))
			}
		}

		Clone() {
			Return, (new Point3D([this.x, this.y, this.z]))
		}
	}
}

Class Vector2D {

	;* new Vector2D([x, y])
	__New(oData := "") {
		ValidateData(oData, 2)

		Return, ({"x": oData[0]
			, "y": (oData[1]) ? (oData[1]) : (oData[0])

			, "Base": this.__Vector2D})
	}

	CrossProduct(oVectors) {
		Return, (oVectors[0].x*oVectors[1].y - oVectors[1].x*oVectors[0].y)  ;A*B = |A|.|B|.Sin([angle AOB])
	}

	Distance(oVectors) {
		Return, (Sqrt((oVectors[0].x - oVectors[1].x)**2 + (oVectors[0].y - oVectors[1].y)**2))
	}

	DotProduct(oVectors) {
		Return, (oVectors[0].x*oVectors[1].x + oVectors[1].y*oVectors[0].y)  ;A.B = |A|.|B|.Cos([angle AOB])
	}

	Equals(oVectors) {
		Return, (oVectors[0].x == oVectors[1].x && oVectors[0].y == oVectors[1].y)
	}

	Class __Vector2D Extends __Object {

		__Get(vKey) {
			Switch (vKey) {
				Case "Magnitude":
					Return, (Sqrt(this.x**2 + this.y**2))
			}
		}

		Add(oVector) {
			If (!IsObject(oVector)) {
				this.x += oVector, this.y += oVector
			}
			Else {
				this.x += oVector.x, this.y += oVector.y
			}

			Return, (this)
		}

		Subtract(oVector) {
			If (!IsObject(oVector))
				this.x -= oVector, this.y -= oVector

			Else
				this.x -= oVector.x, this.y -= oVector.y

			Return, (this)
		}

        Divide(oVector) {
			If (!IsObject(oVector)) {
				this.x /= oVector, this.y /= oVector
			}
			Else {
				this.x /= oVector.x, this.y /= oVector.y
			}

			Return, (this)
        }

        Multiply(oVector) {
			If (!IsObject(oVector)) {
				this.x *= oVector, this.y *= oVector
			}
			Else {
				this.x *= oVector.x, this.y *= oVector.y
			}

			Return, (this)
        }

		Conjugate() {
			this.x *= -1, this.y *= -1

			Return, (this)
		}

        Normalise() {
			m := this.Magnitude

			If (m > Math.Epsilon) {
				this.x /= m, this.y /= m
			}

			Return, (this)
        }

		Rotate(vDegrees) {
			a := Math.ToRadians((vDegrees >= 0) ? Mod(vDegrees, 360) : 360 - Mod(-vDegrees, -360))
				, s := Math.Sin(a), c := Math.Cos(a)

			this.x := this.x*c - this.y*s, this.y := this.x*s + this.y*c

			Return, (this)
		}

		Reset() {
			this.x := this.y := 0

			Return, (this)
		}

		Clone() {
			Return, (new Vector2D([this.x, this.y]))
		}
	}
}

Class Rectangle {

	;* new Rectangle([x, y, Width, Height])
	__New(oData := "") {
		ValidateData(oData, 4)

		Return, {"x": oData[0]
			, "y": oData[1]
			, "Width": oData[2]
			, "Height": oData[3]

			, "Base": this.__Rectangle}
	}

	Class __Rectangle Extends __Object {
		Clone() {
			Return, (new Rectangle([this.x, this.y, this.Width, this.Height]))
		}
	}
}

Class Ellipse {

	;* new Ellipse([x, y, Width, Height], Eccentricity)
	;* Note:
		;* Eccentricity can compensate for Width or Height but 2 of the 3 values must be provided to calculate a valid radius.
	__New(oData := "", vEccentricity := 0) {
		e := Sqrt(1 - vEccentricity**2), r := [(oData[2] != "") ? (oData[2]/2) : ((oData[3] != "") ? ((oData[3]/2)*e) : (0)), (oData[3] != "") ? (oData[3]/2) : ((oData[2] != "") ? ((oData[2]/2)*e) : (0))]

		ValidateData(oData, 2)  ;* Default just x and y to 0.

		If (r[0] == r[1]) {
			Return, ({"x": oData[0]
				, "y": oData[1]
				, "__Radius": r[0]

				, "Base": this.__Circle})
		}

		Return, ({"x": oData[0]
			, "y": oData[1]
			, "__Radius": r

			, "Base": this.__Ellipse})
	}

	InscribeEllipse(oEllipse, vRadius, vDegrees := 0) {
		a := Math.ToRadians((vDegrees >= 0) ? Mod(vDegrees, 360) : 360 - Mod(-vDegrees, -360))
			, c := oEllipse.h + (oEllipse.Radius - vRadius)*Math.Cos(a), s := oEllipse.k + (oEllipse.Radius - vRadius)*Math.Sin(a)

		Return, (new Ellipse([c - vRadius, s - vRadius, vRadius*2, vRadius*2]))
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
					Return, (this.__Radius*2)  ;* Make Ellipse compatible with Rectangle for GDIp methods.
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