Class Angle {
	Angle(oPoints) {
		Return, (Math.ToDegrees(ACos((oPoints[0].x*oPoints[1].x + oPoints[0].y*oPoints[1].y)/(Sqrt(oPoints[0].x**2 + oPoints[0].y**2)*Sqrt(oPoints[1].x**2 + oPoints[1].y**2)))))
	}
}

Class Arc {
	Area(oEllipse, vDegrees := 0) {
		a := ((vDegrees >= 0) ? Mod(vDegrees, 360) : 360 - Mod(-vDegrees, -360))

		If (IsObject(oEllipse.radius)) {
		}
		Return, ((a/360)*oEllipse.radius**2*Math.Pi)
	}

	Length(oEllipse, vDegrees := 0) {
		a := Math.ToRadians((vDegrees >= 0) ? Mod(vDegrees, 360) : 360 - Mod(-vDegrees, -360))

		If (IsObject(oEllipse.radius)) {
		}
		Return, (oEllipse.radius*a)
	}
}

Class Point2D {
	__New(oData) {
		Return, ({"x": (oData[0]) ? (oData[0]) : (0)
			, "y": (oData[1]) ? (oData[1]) : (0)

			, "Base": this.__Point2D})
	}

	;===== General
	Distance(_point1, _point2) {
		Return, (Sqrt((_point1.x - _point2.x)**2 + (_point1.y - _point2.y)**2))
	}

	Equals(_point1, _point2) {
		Return, (_point1.x == _point2.x && _point1.y == _point2.y)
	}

	Slope(_point1, _point2) {
		Return, ((_point2.y - _point1.y)/(_point2.x - _point1.x))
	}

	MidPoint(_point1, _point2) {
		Return, (new Point2D((_point1.x + _point2.x)/2, (_point1.y + _point2.y)/2))
	}

	;===== Triangle
	Circumcenter(_point1, _point2, _point3) {
		m := [Point2D.MidPoint(_point1, _point2), Point2D.MidPoint(_point2, _point3)], s := [(_point2.x - _point1.x)/(_point1.y - _point2.y), (_point3.x - _point2.x)/(_point2.y - _point3.y)], p := [m[1].y - s[1]*m[1].x, m[2].y - s[2]*m[2].x]

		Return, (s[1] == s[2] ? 0 : _point1.y == _point2.y ? new Point2D(m[1].x, s[2]*m[1].x + p[2]) : _point2.y == _point3.y ? new Point2D(m[2].x, s[1]*m[2].x + p[1]) : new Point2D((p[2] - p[1])/(s[1] - s[2]), s[1]*(p[2] - p[1])/(s[1] - s[2]) + p[1]))
	}

	;===== Ellipse
	Foci(oEllipse) {
		o := [(oEllipse.radius.a > oEllipse.radius.b)*(o := oEllipse.FocalLength), (oEllipse.radius.a < oEllipse.radius.b)*o]

		Return, ([new Point2D(oEllipse.h - o[1], oEllipse.k - o[2]), new Point2D(oEllipse.h + o[1], oEllipse.k + o[2])])
	}

	Epicycloid(oEllipse1, oEllipse2, vDegrees := 0) {
		a := Math.ToRadians((vDegrees >= 0) ? Mod(vDegrees, 360) : 360 - Mod(-vDegrees, -360))

		Return, (new Point2D(oEllipse1.h + (oEllipse1.radius + oEllipse2.radius)*Cos(a) - oEllipse2.radius*Cos((oEllipse1.radius/oEllipse2.radius + 1)*a), oEllipse.k - o[2], oEllipse1.k + (oEllipse1.radius + oEllipse2.radius)*Sin(a) - oEllipse2.radius*Sin((oEllipse1.radius/oEllipse2.radius + 1)*a)))
	}

	Hypocycloid(oEllipse1, oEllipse2, vDegrees := 0) {
		a := Math.ToRadians((vDegrees >= 0) ? Mod(vDegrees, 360) : 360 - Mod(-vDegrees, -360))

		Return, (new Point2D(oEllipse1.h + (oEllipse1.radius - oEllipse2.radius)*Cos(a) + oEllipse2.radius*Cos((oEllipse1.radius/oEllipse2.radius - 1)*a), oEllipse1.k + (oEllipse1.radius - oEllipse2.radius)*Sin(a) - oEllipse2.radius*Sin((oEllipse1.radius/oEllipse2.radius - 1)*a)))
	}

	OnEllipse(oEllipse, vDegrees := 0) {
		a := -(Math.ToRadians((vDegrees >= 0) ? Mod(vDegrees, 360) : 360 - Mod(-vDegrees, -360)))

		If (IsObject(oEllipse.radius)) {
			t := Math.Tan(a), o := [oEllipse.radius.a*oEllipse.radius.b, Sqrt(oEllipse.radius.b**2 + oEllipse.radius.a**2*t**2)], s := (90 < vDegrees && vDegrees <= 270) ? -1 : 1

			Return, (new Point2D([oEllipse.h + (o[0]/o[1])*s, oEllipse.k + ((o[0]*t)/o[1])*s]))
		}
		Return, (new Point2D([oEllipse.h + oEllipse.radius*Cos(a), oEllipse.k + oEllipse.radius*Sin(a)]))
	}

	Class __Point2D {
		Clone() {
			Return, (new Point2D(this.x, this.y))
		}

		Rotate(vDegrees) {
			a := Math.ToRadians((vDegrees >= 0) ? (Mod(vDegrees, 360)) : (360 - Mod(-vDegrees, -360)))
				, c := Cos(a), s := Sin(a)

			Return, (new Point2D(c*this.x - s*this.y, s*this.x + c*this.y))
		}
	}
}

Class Point3D {
	__New(oData) {
		Return, ({"x": (oData[0]) ? (oData[0]) : (0)
			, "y": (oData[1]) ? (oData[1]) : (0)
			, "Z": (oData[2]) ? (oData[2]) : (0)

			, "Base": this.__Point3D})
	}

	Class __Point3D {
		RotateX(vDegrees) {
			;Here we use Euler's matrix formula for rotating a 3D point x degrees around the x-axis

			;[ a  b  c ] [ x ]   [ x*a + y*b + z*c ]
			;[ d  e  f ] [ y ] = [ x*d + y*e + z*f ]
			;[ g  h  i ] [ z ]   [ x*g + y*h + z*i ]

			;[1      0         0  ]
			;[0    cos(a)   sin(a)]
			;[0   -sin(a)   cos(a)]

			a := ((vDegrees >= 0) ? Mod(vDegrees, 360) : 360 - Mod(-vDegrees, -360))*0.017453292519943295769236907684886127134428718885417254560971914
				, c := Cos(a), s := Sin(a)

			Return, (new Point3D(this.x, this.y*c + this.z*s, this.y*-s + this.z*c))
		}

		RotateY(vDegrees) {
			;Y-axis

			;[ cos(a)   0    sin(a)]
			;[   0      1      0   ]
			;[-sin(a)   0    cos(a)]

			a := ((vDegrees >= 0) ? Mod(vDegrees, 360) : 360 - Mod(-vDegrees, -360))*0.017453292519943295769236907684886127134428718885417254560971914
				, c := Cos(a), s := Sin(a)

			Return, (new Point3D(this.x*c + this.z*s, this.y, this.x*-s + this.z*c))
		}

		RotateZ(vDegrees) {
			;Z-axis

			;[ cos(a)   sin(a)   0]
			;[-sin(a)   cos(a)   0]
			;[    0       0      1]

			a := ((vDegrees >= 0) ? Mod(vDegrees, 360) : 360 - Mod(-vDegrees, -360))*0.017453292519943295769236907684886127134428718885417254560971914
				, c := Cos(a), s := Sin(a)

			Return, (new Point3D(this.x*c + this.y*s, this.x*-s + this.y*c, this.z))
		}

		Clone() {
			Return, (new Point3D(this.x, this.y, this.z))
		}
	}
}

Class Vector2D {
	__New(oData) {
		Return, ({"x": (oData[0]) ? (oData[0]) : (0)
			, "y": (oData[1]) ? (oData[1]) : ((oData[0]) ? (oData[0]) : (0))

			, "Base": this.__Vector2D})
	}

	CrossProduct(_vector1, _vector2) {
		Return, (_vector1.x*_vector2.y - _vector2.x*_vector1.y)  ;A*B = |A|.|B|.Sin([angle AOB])
	}

	Distance(_vector1, _vector2) {
		Return, (Sqrt((_vector1.x - _vector2.x)**2 + (_vector1.y - _vector2.y)**2))
	}

	DotProduct(_vector1, _vector2) {
		Return, (_vector1.x*_vector2.x + _vector2.y*_vector1.y)  ;A.B = |A|.|B|.Cos([angle AOB])
	}

	Equals(_vector1, _vector2) {
		Return, (_vector1.x == _vector2.x && _vector1.y == _vector2.y)
	}

	Class __Vector2D {
		Magnitude[] {
			Get {
				Return, (Sqrt(this.x**2 + this.y**2))
			}
		}

		Add(_vector) {
			If (!IsObject(_vector))
				this.x += _vector, this.y += _vector

			Else
				this.x += _vector.x, this.y += _vector.y

			Return, (this)
		}

		Clone() {
			Return, (new Vector2D(this.x, this.y))
		}

		Conjugate() {
			this.x *= -1, this.y *= -1

			Return, (this)
		}

        Divide(_vector) {
			If (!IsObject(_vector))
				this.x /= _vector, this.y /= _vector

			Else
				this.x /= _vector.x, this.y /= _vector.y

			Return, (this)
        }

        Multiply(_vector) {
			If (!IsObject(_vector))
				this.x *= _vector, this.y *= _vector

			Else
				this.x *= _vector.x, this.y *= _vector.y

			Return, (this)
        }

        Normalise() {
			m = this.Magnitude

			If (m > 0.001)
				this.x /= m, this.y /= m

			Return, (this)
        }


		Reset() {
			this.x := 0.0, this.y := 0.0

			Return, (this)
		}

		Rotate(vDegrees) {
			a := ((vDegrees >= 0) ? Mod(vDegrees, 360) : 360 - Mod(-vDegrees, -360))*0.017453292519943295769236907684886127134428718885417254560971914
				, s := Sin(a), c := Cos(a)

			this.x := this.x*c - this.y*s, this.y := this.x*s + this.y*c

			Return, (this)
		}

		Subtract(_vector) {
			If (!IsObject(_vector))
				this.x -= _vector, this.y -= _vector

			Else
				this.x -= _vector.x, this.y -= _vector.y

			Return, (this)
		}
	}
}

Class Quaternion {
	__New(_w := 1, _x := 0, _y := 0, _z := 0) {
		Return, ({"Base": this.__Quaternion
			, "w": _w
			, "x": _x
			, "y": _y
			, "z": _z})
	}

	Equals(_quaternion1, _quaternion2) {
		Return, (_quaternion1.w == _quaternion2.w && _quaternion1.x == _quaternion2.x && _quaternion1.y == _quaternion2.y && _quaternion1.z == _quaternion2.z)
	}

	DotProduct(_quaternion1, _quaternion2) {
        Return, (_quaternion1.w*_quaternion2.w + _quaternion1.x*_quaternion2.x + _quaternion1.y*_quaternion2.y + _quaternion1.z*_quaternion2.z)
	}

	Class __Quaternion {
		Magnitude[] {
			Get {
				Return, (Sqrt(this.w**2 + this.x**2 + this.y**2 + this.z**2))
			}
		}

        Normalise() {
			m := this.w**2 + this.x**2 + this.y**2 + this.z**2

			If (m > 0.001) {
				m := Sqrt(m)

				this.w /= m, this.x /= m, this.y /= m, this.z /= m
			}

			Else
				this.w := 1, this.x := this.y := this.z := 0
        }

        Multiply(_quaternion) {
			this.w := this.w*_quaternion.w - this.x*_quaternion.x - this.y*_quaternion.y - this.z*_quaternion.z
			, this.x := this.w*_quaternion.x + this.x*_quaternion.w + this.y*_quaternion.z - this.z*_quaternion.y
			, this.y := this.w*_quaternion.y + this.y*_quaternion.w + this.z*_quaternion.x - this.x*_quaternion.z
			, this.z := this.w*_quaternion.z + this.z*_quaternion.w + this.x*_quaternion.y - this.y*_quaternion.x
        }

		Add(_quaternion) {
			this.w += _quaternion.w, this.x += _quaternion.x, this.y += _quaternion.y, this.z += _quaternion.z
		}

		Subtract(_quaternion) {
			this.w -= _quaternion.w, this.x -= _quaternion.x, this.y -= _quaternion.y, this.z -= _quaternion.z
		}

		Conjugate() {
			this.x *= -1, this.y *= -1, this.z *= -1
		}

		Rotate(vDegrees) {
			a := ((vDegrees >= 0) ? Mod(vDegrees, 360) : 360 - Mod(-vDegrees, -360))*0.017453292519943295769236907684886127134428718885417254560971914
				, s := Sin(a), c := Cos(a)

			this.Normalise(), (q := this.Clone()).Conjugate()

			this.x := this.x*c - this.y*s, this.y := this.x*s + this.y*c
		}

		Clone() {
			Return, (new Quaternion(this.w, this.x, this.y, this.z))
		}
	}
}

Class Rectangle {
	__New(oData) {
		Return, {"X": oData[0]
			, "Y": oData[1]
			, "Width": oData[2]
			, "Height": oData[3]

			, "Base": this.__Rectangle}
	}

	Class __Rectangle {
	}
}

Class Ellipse {
	__New(oData, vEccentricity := 0) {
		e := Sqrt(1 - vEccentricity**2), r := [(oData[2] != "") ? (oData[2]/2) : ((oData[3]/2)*e), (oData[3] != "") ? (oData[3]/2) : ((oData[2]/2)*e)]

		If (r[0] == r[1]) {
			Return, ({"X": oData[0]
				, "Y": oData[1]
				, "__Radius": r[0]

				, "Base": this.__Circle})
		}

		Return, ({"X": oData[0]
			, "Y": oData[1]
			, "__Radius": r

			, "Base": this.__Ellipse})
	}

	InscribeEllipse(oEllipse, vRadius, vDegrees := 0) {
		a := Math.ToRadians((vDegrees >= 0) ? Mod(vDegrees, 360) : 360 - Mod(-vDegrees, -360))
			, c := oEllipse.h + (oEllipse.Radius - vRadius)*Cos(a), s := oEllipse.k + (oEllipse.Radius - vRadius)*Sin(a)

		Return, (new Ellipse([c - vRadius, s - vRadius, vRadius*2, vRadius*2]))
	}

	Class __Circle {
		__Get(vKey) {
			Switch (vKey) {
				Case "H":
					Return, (this.X + this.__Radius)
				Case "K":
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
				Case "H":
					ObjRawSet(this, "X", vValue - this.__Radius)
				Case "K":
					ObjRawSet(this, "Y", vValue - this.__Radius)
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
			Return
		}
	}

	Class __Ellipse {
		__Get(vKey) {
			Switch (vKey) {
				Case "H":
					Return, (this.X + this.__Radius[0])
				Case "K":
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
				Case "H":
					ObjRawSet(this, "X", vValue - this.__Radius[0])
				Case "K":
					ObjRawSet(this, "Y", vValue - this.__Radius[1])
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
			Return
		}
	}
}