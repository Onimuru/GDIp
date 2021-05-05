;==============  Include  ======================================================;

#Include, %A_LineFile%\..\Core.ahk

#Include, %A_LineFile%\..\Math\Math.ahk

;============== Function ======================================================;

__Validate(n, ByRef number1 := "", ByRef number2 := "", ByRef number3 := "", ByRef number4 := "") {
	Loop, % n {
		if (!Math.IsNumeric(number%A_Index%)) {
			number%A_Index% := Round(number%A_Index%)
		}
	}
}

;===============  Class  =======================================================;

Class Point2 {

	;--------------- Method -------------------------------------------------------;
	;-------------------------            General           -----;

	;* Point2.Angle(point1 [Point2], point2 [Point2])
	;* Description:
		;* Calculate the angle from `point1` to `point2`.
	Angle(point1, point2) {
		Local
		Global Math

		x := -Math.ATan2({"x": point2.x - point1.x, "y": point2.y - point1.y})

		return ((x < 0) ? (-x) : (Math.Tau - x))
	}

	;* Point2.Distance(point1 [Point2], point2 [Point2])
	Distance(point1, point2) {
		Local

		return (Sqrt((point2.x - point1.x)**2 + (point2.y - point1.y)**2))
	}

	;* Point2.Equals(point1 [Point2], point2 [Point2])
	Equals(point1, point2) {
		Local

		return (point1.x == point2.x && point1.y == point2.y)
	}

	;* Point2.Slope(point1 [Point2], point2 [Point2])
	;* Note:
		;* Two lines are parallel if their slopes are the same.
		;* Two lines are perpendicular if their slopes are negative reciprocals of each other.
	Slope(point1, point2) {
		Local

		return ((point2.y - point1.y)/(point2.x - point1.x))
	}

	;* Point2.MidPoint(point1 [Point2], point2 [Point2])
	MidPoint(point1, point2) {
		Local

		return (new this((point1.x + point2.x)/2, (point1.y + point2.y)/2))
	}

	;* Point2.Rotate(point1 [Point2], point2 [Point2], theta [Radians])
	;* Description:
		;* Calculate the coordinates of `point1` rotated around `point2`.
	Rotate(point1, point2, theta) {
		Local

		c := Cos(theta), s := Sin(theta)
			, x := point1.x - point2.x, y := point1.y - point2.y

		return (new this(x*c - y*s + point2.x, x*s + y*c + point2.y))
	}

	;-------------------------           Triangle           -----;  ;*** https://hratliff.com/files/curvature_calculations_and_circle_fitting.pdf || https://www.onlinemath4all.com/circumcenter-of-a-triangle.html

	;* Point2.Circumcenter(point1 [Point2], point2 [Point2], point3 [Point2])
	;* Description:
		;* Calculate the circumcenter for three 2D points.
	Circumcenter(point1, point2, point3) {
		Local

		x1 := point1.x, y1 := point1.y, x2 := point2.x, y2 := point2.y, x3 := point3.x, y3 := point3.y
			, a := 0.5*((x2 - x1)*(y3 - y2) - (y2 - y1)*(x3 - x2))

		if (a != 0) {
			x := (((y3 - y1)*(y2 - y1)*(y3 - y2)) - ((x2**2 - x1**2)*(y3 - y2)) + ((x3**2 - x2**2)*(y2 - y1)))/(-4*a), y := (-1*(x2 - x1)/(y2 - y1))*(x - 0.5*(x1 + x2)) + 0.5*(y1 + y2)

			return (new this(x, y))
		}

		MsgBox("Failed: points are either collinear or not distinct")
	}

	;* Point2.Circumradius(point1 [Point2], point2 [Point2], point3 [Point2])
	;* Description:
		;* Calculate the circumradius for three 2D points.
	Circumradius(point1, point2, point3) {
		Local

		x1 := point1.x, y1 := point1.y, x2 := point2.x, y2 := point2.y, x3 := point3.x, y3 := point3.y
			, d := 2*((x2 - x1)*(y3 - y2) - (y2 - y1)*(x3 - x2))

		if (d != 0) {
			n := ((((x2 - x1)**2) + ((y2 - y1)**2))*((( x3 - x2)**2) + ((y3 - y2)**2))*(((x1 - x3)**2) + ((y1 - y3)**2)))**(0.5)

			return (Abs(n/d))
		}

		MsgBox("Failed: points are either collinear or not distinct")
	}

	;-------------------------            Ellipse           -----;

	;* Point2.Foci(EllipseObject)
	Foci(ellipse) {
		Local

		f := ellipse.FocalLength
			, o1 := (ellipse.Radius.a > ellipse.Radius.b)*f, o2 := (ellipse.Radius.a < ellipse.Radius.b)*f

		return ([new this(ellipse.h - o1, ellipse.k - o2), new this(ellipse.h + o1, ellipse.k + o2)])
	}

	;* Point2.Epicycloid(EllipseObject1, EllipseObject2, (theta [Radians]))   ;*** Bad reference (oEllipse). Check formula
	Epicycloid(ellipse1, ellipse2, theta := 0) {
		return (new this(ellipse1.h + (ellipse1.Radius + ellipse2.Radius)*Math.Cos(theta) - ellipse2.Radius*Math.Cos((ellipse1.Radius/ellipse2.Radius + 1)*theta), oEllipse.k - o[2], ellipse1.k + (ellipse1.Radius + ellipse2.Radius)*Math.Sin(theta) - ellipse2.Radius*Math.Sin((ellipse1.Radius/ellipse2.Radius + 1)*theta)))
	}

	;* Point2.Hypocycloid([EllipseObject1, EllipseObject2], (theta [Radians]))
	Hypocycloid(ellipse1, ellipse2, theta := 0) {
		return (new this(ellipse1.h + (ellipse1.Radius - ellipse2.Radius)*Math.Cos(theta) + ellipse2.Radius*Math.Cos((ellipse1.Radius/ellipse2.Radius - 1)*theta), ellipse1.k + (ellipse1.Radius - ellipse2.Radius)*Math.Sin(theta) - ellipse2.Radius*Math.Sin((ellipse1.Radius/ellipse2.Radius - 1)*theta)))
	}

	;* Point2.OnEllipse(EllipseObject, (theta [Radians]))
	;* Description:
		;* Calculate the coordinates of a point on the circumference of an ellipse.
	OnEllipse(ellipse, theta := 0) {
		if (IsObject(ellipse.Radius)) {
			t := Math.Tan(theta), o := [ellipse.Radius.a*ellipse.Radius.b, Sqrt(ellipse.Radius.b**2 + ellipse.Radius.theta**2*t**2)], s := (90 < theta && theta <= 270) ? (-1) : (1)

			return (new this(ellipse.h + (o[0]/o[1])*s, ellipse.k + ((o[0]*t)/o[1])*s))
		}
		return (new this(ellipse.h + ellipse.Radius*Math.Cos(theta), ellipse.k + ellipse.Radius*Math.Sin(theta)))
	}
}

Class Vec2 {

	;------------  Constructor  ----------------------------------------------------;

	;* new Vec2((x), (y))
	;* new Vec2([Array || Object|| Vec2 || Vec3] point)
	__New(params*) {
		switch (Type(params[1])) {
			case "Integer, Float": {
				return ({"x": params[1], "y": (Math.IsNumeric(params[2])) ? (params[2]) : (params[1])

					, "Base": this.__Vec2})
			}
			case "Vec2", "Vec3": {
				return ({"x": params[1].x, "y": params[1].y

					, "Base": this.__Vec2})
			}
			case "Array": {
				return ({"x": params[1][0], "y": params[1][1]

					, "Base": this.__Vec2})
			}
			Default: {
				if ((x := params[1].x) != "" && (y := params[1].y) != "") {
					return ({"x": x, "y": y

						, "Base": this.__Vec2})
				}

				return ({"x": 0, "y": 0

					, "Base": this.__Vec2})
			}
		}
	}

	;* Vec2.Divide(vector [Vec2], scalar [Vec2 || Number])
	;* Description:
		;* Divide a vector by another vector or a scalar.
	Divide(vector, scalar) {
		switch (Type(scalar)) {
			case "Integer, Float": {
				return (new this(vector.x/scalar, vector.y/scalar))
			}
			case "Vec2", "Vec3": {
				return (new this(vector.x/scalar.x, vector.y/scalar.y))
			}
			case "Array": {
				return (new this(vector.x/scalar[0], vector.y/scalar[1]))
			}
			Default: {
				if ((x := scalar.x) != "" && (y := scalar.y) != "") {
					return (new this(vector.x/x, vector.y/y))
				}

				throw (Exception("ArgumentException", -1, "This parameter must be of type: Object, Vec2, Vec3 or Integer, Float."))
			}
		}
	}

	;* Vec2.Multiply(vector [Vec2], scalar [Vec2 || Number])
	;* Description:
		;* Multiply a vector by another vector or a scalar.
	Multiply(vector, scalar) {
		switch (Type(scalar)) {
			case "Integer, Float": {
				return (new this(vector.x*scalar, vector.y*scalar))
			}
			case "Vec2", "Vec3": {
				return (new this(vector.x*scalar.x, vector.y*scalar.y))
			}
			case "Array": {
				return (new this(vector.x*scalar[0], vector.y*scalar[1]))
			}
			Default: {
				if ((x := scalar.x) != "" && (y := scalar.y) != "") {
					return (new this(vector.x*x, vector.y*y))
				}

				throw (Exception("ArgumentException", -1, "This parameter must be of type: Object, Vec2, Vec3 or Integer, Float."))
			}
		}
	}

	;* Vec2.Add(vector [Vec2], scalar [Vec2 || Number])
	;* Description:
		;* Add to a vector another vector or a scalar.
	Add(vector, scalar) {
		switch (Type(scalar)) {
			case "Integer, Float": {
				return (new this(vector.x + scalar, vector.y + scalar))
			}
			case "Vec2", "Vec3": {
				return (new this(vector.x + scalar.x, vector.y + scalar.y))
			}
			case "Array": {
				return (new this(vector.x + scalar[0], vector.y + scalar[1]))
			}
			Default: {
				if ((x := scalar.x) != "" && (y := scalar.y) != "") {
					return (new this(vector.x + x, vector.y + y))
				}

				throw (Exception("ArgumentException", -1, "This parameter must be of type: Object, Vec2, Vec3 or Integer, Float."))
			}
		}
	}

	;* Vec2.Subtract(vector [Vec2], scalar [Vec2 || Number])
	;* Description:
		;* Subtract from a vector another vector or scalar.
	Subtract(vector, scalar) {
		switch (Type(scalar)) {
			case "Integer, Float": {
				return (new this(vector.x - scalar, vector.y - scalar))
			}
			case "Vec2", "Vec3": {
				return (new this(vector.x - scalar.x, vector.y - scalar.y))
			}
			case "Array": {
				return (new this(vector.x - scalar[0], vector.y - scalar[1]))
			}
			Default: {
				if ((x := scalar.x) != "" && (y := scalar.y) != "") {
					return (new this(vector.x - x, vector.y - y))
				}

				throw (Exception("ArgumentException", -1, "This parameter must be of type: Object, Vec2, Vec3 or Integer, Float."))
			}
		}
	}

	;! AngleBetween() — find the angle between two vectors

	;* Vec2.Clamp(vector1 [Vec2], vector2 [Vec2 || Number], vector3 [Vec2 || Number])
	;* Description:
		;* Clamp a vector to the given minimum and maximum vectors or values.
	;* Note:
		;* Assumes `vector2 < vector3`.
	;* Parameters:
		;* vector1:
			;* Input vector.
		;* vector2:
			;* Minimum vector or number.
		;* vector3:
			;* Maximum vector or number.
	Clamp(vector1, vector2, vector3) {
		if (IsObject(vector2) && IsObject(vector3)) {
			return (new this(Max(vector2.x, Min(vector3.x, vector1.x)), Max(vector2.y, Min(vector3.y, vector1.y))))
		}

		return (new this(Max(vector2, Min(vector3, vector1.x)), Max(vector2, Min(vector3, vector1.y))))
	}

	;* Vec2.Cross(vector1 [Vec2], vector2 [Vec2])
	;* Description:
		;* Calculate the cross product (vector) of two vectors (greatest yield for perpendicular vectors).
	Cross(vector1, vector2) {
		return (vector1.x*vector2.y - vector1.y*vector2.x)
	}

	;* Vec2.Distance(vector1 [Vec2], vector2 [Vec2])
	;* Description:
		;* Calculate the distance between two vectors.
	Distance(vector1, vector2) {
		return (Sqrt((vector1.x - vector2.x)**2 + (vector1.y - vector2.y)**2))
	}

	;* Vec2.DistanceSquared(vector1 [Vec2], vector2 [Vec2])
	DistanceSquared(vector1, vector2) {
		return ((vector1.x - vector2.x)**2 + (vector1.y - vector2.y)**2)
	}

	;* Vec2.Dot(vector1 [Vec2], vector2 [Vec2])
	;* Description:
		;* Calculate the dot product (scalar) of two vectors (greatest yield for parallel vectors).
	Dot(vector1, vector2) {
		return (vector1.x*vector2.x + vector1.y*vector2.y)
	}

	;* Vec2.Equals(vector1 [Vec2], vector2 [Vec2])
	;* Description:
		;* Indicates whether two vectors are equal.
	Equals(vector1, vector2) {
		return (vector1.x == vector2.x && vector1.y == vector2.y)
	}

	;* Vec2.Lerp(vector1 [Vec2], vector2 [Vec2], alpha [Number])
	;* Description:
		;* Returns a new vector that is the linear blend of the two given vectors.
	;* Parameters:
		;* vector1:
			;* The starting vector.
		;* vector2:
			;* The vector to interpolate towards.
		;* alpha:
			;* Interpolation factor, typically in the closed interval [0, 1].
	Lerp(vector1, vector2, alpha) {
		return (new this(vector1.x + (vector2.x - vector1.x)*alpha, vector1.y + (vector2.y - vector1.y)*alpha))
	}

	;* Vec2.Min(vector1 [Vec2], vector2 [Vec2])
	Min(vector1, vector2) {
		return (new this(Min(vector1.x, vector2.x), Min(vector1.y, vector2.y)))
	}

	;* Vec2.Max(vector1 [Vec2], vector2 [Vec2])
	Max(vector1, vector2) {
		return (new this(Max(vector1.x, vector2.x), Max(vector1.y, vector2.y)))
	}

	;* Vec2.Transform(vector [Vec2], matrix [Matrix3])
	Transform(vector, matrix) {
		Local

		x := vector.x, y := vector.y
			, m := matrix.Elements

		return (new this(m[0]*x + m[3]*y + m[6], m[1]*x + m[4]*y + m[7]))
	}

	Class __Vec2 extends __Object {

		;* vector[n]
		__Get(n) {
			switch (n) {
				case 0: {
					return (this.x)
				}
				case 1: {
					return (this.y)
				}
			}
		}

		;* vector[n] := value
		__Set(n) {
			switch (n) {
				case 0: {
					return (this.x := value)
				}
				case 1: {
					return (this.y := value)
				}
			}
		}

		Length[] {

			;* vector.Length
			;* Description:
				;* Calculates the length (magnitude) of the vector.
			Get {
				return (Sqrt(this.x**2 + this.y**2))
			}

			;* vector.Length := value
			Set {
				this.Normalize().Multiply(value)

				return (value)
			}
		}

		LengthSquared[] {

			;* vector.LengthSquared
			Get {
				return (this.x**2 + this.y**2)
			}
		}

        Divide(scalar) {
			switch (Type(scalar)) {
				case "Integer, Float": {
					this.x /= scalar, this.y /= scalar
				}
				case "Vec2", "Vec3": {
					this.x /= scalar.x, this.y /= scalar.y
				}
				case "Array": {
					this.x /= scalar[0], this.y /= scalar[1]
				}
				Default: {
					if ((x := scalar.x) != "" && (y := scalar.y) != "") {
						this.x /= x, this.y /= y

						return (this)
					}

					throw (Exception("ArgumentException", -1, "This parameter must be of type: Object, Vec2, Vec3 or Integer, Float."))
				}
			}

			return (this)
        }

        Multiply(scalar) {
			switch (Type(scalar)) {
				case "Integer, Float": {
					this.x *= scalar, this.y *= scalar
				}
				case "Vec2", "Vec3": {
					this.x *= scalar.x, this.y *= scalar.y
				}
				case "Array": {
					this.x *= scalar[0], this.y *= scalar[1]
				}
				Default: {
					if ((x := scalar.x) != "" && (y := scalar.y) != "") {
						this.x *= x, this.y *= y

						return (this)
					}

					throw (Exception("ArgumentException", -1, "This parameter must be of type: Object, Vec2, Vec3 or Integer, Float."))
				}
			}

			return (this)
        }

        Add(scalar) {
			switch (Type(scalar)) {
				case "Integer, Float": {
					this.x += scalar, this.y += scalar
				}
				case "Vec2", "Vec3": {
					this.x += scalar.x, this.y += scalar.y
				}
				case "Array": {
					this.x += scalar[0], this.y += scalar[1]
				}
				Default: {
					if ((x := scalar.x) != "" && (y := scalar.y) != "") {
						this.x += x, this.y += y

						return (this)
					}

					throw (Exception("ArgumentException", -1, "This parameter must be of type: Object, Vec2, Vec3 or Integer, Float."))
				}
			}

			return (this)
        }

        Subtract(scalar) {
			switch (Type(scalar)) {
				case "Integer, Float": {
					this.x -= scalar, this.y -= scalar
				}
				case "Vec2", "Vec3": {
					this.x -= scalar.x, this.y -= scalar.y
				}
				case "Array": {
					this.x -= scalar[0], this.y -= scalar[1]
				}
				Default: {
					if ((x := scalar.x) != "" && (y := scalar.y) != "") {
						this.x -= x, this.y -= y

						return (this)
					}

					throw (Exception("ArgumentException", -1, "This parameter must be of type: Object, Vec2, Vec3 or Integer, Float."))
				}
			}

			return (this)
        }

		Clamp(vector1, vector2) {
			if (IsObject(vector1) && IsObject(vector2)) {
				this.x := Max(vector1.x, Min(vector2.x, this.x)), this.y := Max(vector1.y, Min(vector2.y, this.y))
			}
			else {
				this.x := Max(vector1, Min(vector2, this.x)), this.y := Max(vector1, Min(vector2, this.y))
			}

			return (this)
		}

		Limit(vector) {
			if (IsObject(vector)) {
				this.x := Min(this.x, vector.x), this.y := Min(this.y, vector.y)
			}
			else {
				this.x := Min(this.x, vector), this.y := Min(this.y, vector)
			}

			return (this)
		}

		;! Limit() — limit the magnitude of a vector

		;! Heading() — the 2D heading of a vector expressed as an angle

		;! Rotate() — rotate a 2D vector by an angle

		;* vector.Lerp()
		;* Description:
			;* Linear interpolate to another vector.
		Lerp(vector, alpha) {
			this.x += (vector.x - this.x)*alpha, this.y += (vector.y - this.y)*alpha

			return (this)
		}

		;* vector.Negate()
		;* Description:
			;* Inverts this vector.
		Negate() {
			this.x *= -1, this.y *= -1

			return (this)
		}

		;* vector.Normalize()
		;* Description:
			;* Normalize the vector to a unit length of 1.
        Normalize() {
			if (s := this.Length) {
				this.x /= s, this.y /= s
			}

			return (this)
        }

		Transform(matrix) {
			x := this.x, y := this.y
				, m := matrix.Elements

			this.x := m[0]*x + m[3]*y + m[6], this.y := m[1]*x + m[4]*y + m[7]

			return (this)
		}

		Copy(vector) {
			this.x := vector.x, this.y := vector.y

			return (this)
		}

		Clone() {
			return (new Vec2(this))
		}
	}
}

Class Vec3 {

	;* new Vec3(x [Number || Vec3], (y [Number]), (z [Number]))
	__New(x := 0, y := "", z := "") {
		Local
		Global Math

		if (Math.IsNumeric(x)) {
			if (Math.IsNumeric(y)) {
				return ({"x": x
					, "y": y
					, "z": z

					, "Base": this.__Vec3})
			}

			return ({"x": x
				, "y": x
				, "z": x

				, "Base": this.__Vec3})
		}

		return ({"x": x.x
			, "y": x.y
			, "z": x.z

			, "Base": this.__Vec3})
	}

	;* Vec3.Multiply(vector1 [Vec3], vector2 [Vec3 || Number])
	;* Description:
		;* Multiply a vector by another vector or a scalar.
	Multiply(vector1, vector2) {
		Local

		if (IsObject(vector2)) {
			return (new this(vector1.x*vector2.x, vector1.y*vector2.y, vector1.z*vector2.z))
		}

		return (new this(vector1.x*vector2, vector1.y*vector2, vector1.z*vector2))
	}

	;* Vec3.Divide(vector1 [Vec3], vector2 [Vec3 || Number])
	;* Description:
		;* Divide a vector by another vector or a scalar.
	Divide(vector1, vector2) {
		Local

		if (IsObject(vector2)) {
			return (new this(vector1.x/vector2.x, vector1.y/vector2.y, vector1.z/vector2.z))
		}

		return (new this(vector1.x/vector2, vector1.y/vector2, vector1.z/vector2))
	}

	;* Vec3.Add(vector1 [Vec3], vector2 [Vec3 || Number])
	;* Description:
		;* Add to a vector another vector or a scalar.
	Add(vector1, vector2) {
		if (IsObject(vector2)) {
			return (new this(vector1.x + vector2.x, vector1.y + vector2.y, vector1.z + vector2.z))
		}

		return (new this(vector1.x + vector2, vector1.y + vector2, vector1.z + vector2))
	}

	;* Vec3.Subtract(vector1 [Vec3], vector2 [Vec3 || Number])
	;* Description:
		;* Subtract from a vector another vector or scalar.
	Subtract(vector1, vector2) {
		Local

		if (IsObject(vector2)) {
			return (new this(vector1.x - vector2.x, vector1.y - vector2.y, vector1.z - vector2.z))
		}

		return (new this(vector1.x - vector2, vector1.y - vector2, vector1.z - vector2))
	}

	;* Vec3.Clamp(vector1 [Vec3], vector2 [Vec3 || Number], vector3 [Vec3 || Number])
	;* Description:
		;* Clamp a vector to the given minimum and maximum vectors or values.
	;* Note:
		;* Assumes `vector2 < vector3`.
	;* Parameters:
		;* vector1:
			;* Input vector.
		;* vector2:
			;* Minimum vector or number.
		;* vector3:
			;* Maximum vector or number.
	Clamp(vector1, vector2, vector3) {
		Local

		if (IsObject(vector2) && IsObject(vector3)) {
			return (new this(Max(vector2.x, Min(vector3.x, vector1.x)), Max(vector2.y, Min(vector3.y, vector1.y)), Max(vector2.z, Min(vector3.z, vector1.z))))
		}

		return (new this(Max(vector2, Min(vector3, vector1.x)), Max(vector2, Min(vector3, vector1.y)), Max(vector2, Min(vector3, vector1.z))))
	}

	;* Vec3.Cross(vector1 [Vec3], vector2 [Vec3])
	;* Description:
		;* Calculate the cross product (vector) of two vectors (greatest yield for perpendicular vectors).
	Cross(vector1, vector2) {
		Local

		a1 := vector1.x, a2 := vector1.y, a3 := vector1.z
			, b1 := vector2.x, b2 := vector2.y, b3 := vector2.z

		;[a2*b3 - a3*b2]
		;[a3*b1 - a1*b3]
		;[a1*b2 - a2*b1]

		return (new this(a2*b3 - a3*b2, a3*b1 - a1*b3, a1*b2 - a2*b1))
	}

	;* Vec3.Distance(vector1 [Vec3], vector2 [Vec3])
	;* Description:
		;* Calculate the distance between two vectors.
	Distance(vector1, vector2) {
		return (Sqrt((vector1.x - vector2.x)**2 + (vector1.y - vector2.y)**2 + (vector1.z - vector2.z)**2))
	}

	;* Vec3.DistanceSquared(vector1 [Vec3], vector2 [Vec3])
	DistanceSquared(vector1, vector2) {
		return ((vector1.x - vector2.x)**2 + (vector1.y - vector2.y)**2 + (vector1.z - vector2.z)**2)
	}

	;* Vec3.Dot(vector1 [Vec3], vector2 [Vec3])
	;* Description:
		;* Calculate the dot product (scalar) of two vectors (greatest yield for parallel vectors).
	Dot(vector1, vector2) {
		return (vector1.x*vector2.x + vector1.y*vector2.y + vector1.z*vector2.z)  ;? Math.Abs(a.Length)*Math.Abs(b.Length)*Math.Cos(AOB)
	}

	;* Vec3.Equals(vector1 [Vec3], vector2 [Vec3])
	;* Description:
		;* Indicates whether two vectors are equal.
	Equals(vector1, vector2) {
		return (vector1.x == vector2.x && vector1.y == vector2.y && vector1.z == vector2.z)
	}

	;* Vec3.Lerp(vector1 [Vec3], vector2 [Vec3], alpha [Number])
	;* Description:
		;* Returns a new vector that is the linear blend of the two given vectors.
	;* Parameters:
		;* vector1:
			;* The starting vector.
		;* vector2:
			;* The vector to interpolate towards.
		;* alpha:
			;* Interpolation factor, typically in the closed interval [0, 1].
	Lerp(vector1, vector2, alpha) {
		Local

		return (new this(vector1.x + (vector2.x - vector1.x)*alpha, vector1.y + (vector2.y - vector1.y)*alpha, vector1.z + (vector2.z - vector1.z)*alpha))
	}

	;* Vec3.Min(vector1 [Vec3], vector2 [Vec3])
	Min(vector1, vector2) {
		Local

		return (new this(Min(vector1.x, vector2.x), Min(vector1.y, vector2.y), Min(vector1.z, vector2.z)))
	}

	;* Vec3.Max(vector1 [Vec3], vector2 [Vec3])
	Max(vector1, vector2) {
		Local

		return (new this(Max(vector1.x, vector2.x), Max(vector1.y, vector2.y), Max(vector1.z, vector2.z)))
	}

	;* Vec3.Transform(vector [Vec3], matrix [Matrix3])
	Transform(vector, matrix) {
		Local

		;! MsgBox("T: " vector.Print() ", " matrix.Print())

		x := vector.x, y := vector.y, z := vector.z
			, m := matrix.Elements

		return (new this(m[0]*x + m[3]*y + m[6]*z, m[1]*x + m[4]*y + m[7]*z, m[2]*x + m[5]*y + m[8]*z))
	}

	Class __Vec3 extends __Object {

		__Get(key) {
			Switch (key) {

				;* Vec3.Length
				;* Description:
					;* Calculates the length (magnitude) of the vector.
				Case "Length":
					return (Sqrt(this.x**2 + this.y**2 + this.z**2))

				;* Vec3.LengthSquared
				Case "LengthSquared":
					return (this.x**2 + this.y**2 + this.z**2)

				;* Vec3[n]
				Default:
					if (Math.IsInteger(key)) {
						return ([this.x, this.y, this.z][key])
					}
			}
		}

		__Set(key, value) {
			Switch (key) {

				;* Vec3.Length := n
				Case "Length":
					return (this.Normalize().Multiply(value))

				;* Vec3[n] := n
				Default:
					switch (key) {
						Case 0:
							this.x := value
						Case 1:
							this.y := value
						Case 2:
							this.z := value
					}
					Return
			}
		}

        Multiply(vector) {
			Local

			if (IsObject(vector)) {
				this.x *= vector.x, this.y *= vector.y, this.z *= vector.z
			}
			else {
				this.x *= vector, this.y *= vector, this.z *= vector
			}

			return (this)
        }

        Divide(vector) {
			Local

			if (IsObject(vector)) {
				this.x /= vector.x, this.y /= vector.y, this.z /= vector.z
			}
			else {
				this.x /= vector, this.y /= vector, this.z /= vector
			}

			return (this)
        }

		Add(vector) {
			Local

			if (IsObject(vector)) {
				this.x += vector.x, this.y += vector.y, this.z += vector.z
			}
			else {
				this.x += vector, this.y += vector, this.z += vector
			}

			return (this)
		}

		Subtract(vector) {
			Local

			if (IsObject(vector)) {
				this.x -= vector.x, this.y -= vector.y, this.z -= vector.z
			}
			else {
				this.x -= vector, this.y -= vector, this.z -= vector
			}

			return (this)
		}

		Clamp(vector1, vector2) {
			Local

			if (IsObject(vector1) && IsObject(vector2)) {
				this.x := Max(vector1.x, Min(vector2.x, this.x)), this.y := Max(vector1.y, Min(vector2.y, this.y)), this.z := Max(vector1.z, Min(vector2.z, this.z))
			}
			else {
				this.x := Max(vector1, Min(vector2, this.x)), this.y := Max(vector1, Min(vector2, this.y)), this.z := Max(vector1, Min(vector2, this.z))
			}

			return (this)
		}

		Lerp(vector, alpha) {
			Local

			this.x += (vector.x - this.x)*alpha, this.y += (vector.y - this.y)*alpha, this.z += (vector.z - this.z)*alpha

			return (this)
		}

		;* Vec3.Negate()
		;* Description:
			;* Inverts this vector.
		Negate() {
			Local

			this.x *= -1, this.y *= -1, this.z *= -1

			return (this)
		}

		;* Vec3.Normalize()
		;* Description:
			;* This method normalises the vector such that it's length/magnitude is 1. The result is called a unit vector.
        Normalize() {
			Local

			m := this.Length

			if (m) {
				this.x /= m, this.y /= m, this.z /= m
			}

			return (this)
        }

		Transform(matrix) {
			Local

			x := this.x, y := this.y, z := this.z
				, m := matrix.Elements

			this.x := m[0]*x + m[3]*y + m[6]*z, this.y := m[1]*x + m[4]*y + m[7]*z, this.z := m[2]*x + m[5]*y + m[8]*z

			return (this)
		}

		Copy(vector) {
			Local

			this.x := vector.x, this.y := vector.y, this.z := vector.z

			return (this)
		}

		Clone() {
			Local
			Global Vec3

			return (new Vec3(this))
		}
	}
}

Class Rect {

	;------------  Constructor  ----------------------------------------------------;

	;* new Rect(x, y, width, height)
	;* new Rect([Vec2 || Vec3] point, width, height)
	;* new Rect([Object] rect)
	__New(params*) {
		switch (Type(params[1])) {
			case "Integer", "Float": {
				switch (params.Count()) {
					case 4: {
						return {"x": params[1], "y": params[2]
							, "Width": params[3], "Height": params[4]

							, "Base": this.__Rect}
					}
					Default: {
						throw (Exception("ArgumentException", -1, "Too many parameters passed to this function."))
					}
				}
			}
			case "Vec2", "Vec3": {
				return {"x": params[1].x, "y": params[1].y
					, "Width": params[2], "Height": params[3]

					, "Base": this.__Rect}
			}
			case "Array": {  ;* Array is only included here to support legacy scripts as I don't intend to account for arrays of length 2/4 (`[x, y]` vs `[x, y, width, height]`).
				return ({"x": params[1][0], "y": params[1][1]
					, "Width": params[2], "Height": params[3]

					, "Base": this.__Rect})
			}
			Default: {
				if ((x := params[1].x) != "" && (y := params[1].y) != "" && (width := params[1].Width) != "" && (height := params[1].Height) != "") {
					return {"x": x, "y": y
						, "Width": width, "Height": height

						, "Base": this.__Rect}
				}

				throw (Exception("ArgumentException", -1, Format("{} is invalid. This object must be constructed from type:`n`tInteger, Array, Object, Vec2, Vec3 or Rect.", Type(x))))
			}
		}
	}

	IsIntersect(rect1, rect2) {
		x1 := rect1.x, y1 := rect1.y
			, x2 := rect2.x, y2 := rect2.y

		return (!(x2 > rect1.Width + x1 || x1 > rect2.Width + x2 || y2 > rect1.Height + y1 || y1 > rect2.Height + y2))
	}

	Scale(rectangle1, rectangle2) {
		r1 := rectangle2.Width/rectangle1.Width, r2 := rectangle2.Height/rectangle1.Height

		if (r1 > r2) {
			h := rectangle2.Height//r1

			return (new Rect(0, (rectangle1.Height - h)//2, rectangle1.Width, h))
		}
		else {
			w := rectangle2.Width//r2

			return (new Rect((rectangle1.Width - w)//2, 0, 2, rectangle1.Height))
		}
	}

	Class __Rect extends Vec2.__Vec2 {

		IsIntersect(rect) {
			Local

			x1 := this.x, y1 := this.y
				, x2 := rect.x, y2 := rect.y

			return (!(x1 > rect.Width + x2 || x2 > this.Width + x1 || y1 > rect.Height + y2 || y2 > this.Height + y1))
		}

		Clone() {
			return (new Rect(this.x, this.y, this.Width, this.Height))
		}
	}
}

Class Ellipse {

	;------------  Constructor  ----------------------------------------------------;

	;* new Ellipse(x, y, radius)
	;* new Ellipse(x, y, width, height)
	;* new Ellipse([Vec2 || Vec3 || Array] point, radius)
	;* new Ellipse([Vec2 || Vec3 || Array] point, width, height)
	__New(params*) {
		Local

		switch (Type(params[1])) {
			case "Integer, Float": {
				switch (params.Count()) {
					case 4: {
						width := params[3], height := params[4]
							, r1 := (width < 1 && width > 0 && height >= 1) ? ((height/2)*Sqrt(1 - width**2)) : (width/2), r2 := (height < 1 && height > 0 && width >= 1) ? ((width/2)*Sqrt(1 - height**2)) : (height/2)

						if (r1 == r2) {
							return ({"x": params[1], "y": params[2]
								, "__Radius": r1

								, "Base": this.__Circle})
						}

						return ({"x": params[1], "y": params[2]
							, "__Radius": [r1, r2]

							, "Base": this.__Ellipse})
					}
					case 3: {
						return {"x": params[1], "y": params[2]
							, "__Radius": params[3]

							, "Base": this.__Circle}
					}
					Default: {
						throw (Exception("ArgumentException", -1, "Too many parameters passed to this function."))
					}
				}
			}
			case "Vec2", "Vec3": {
				switch (params.Count()) {
					case 3: {
						width := params[2], height := params[3]
							, r1 := (width < 1 && width > 0 && height >= 1) ? ((height/2)*Sqrt(1 - width**2)) : (width/2), r2 := (height < 1 && height > 0 && width >= 1) ? ((width/2)*Sqrt(1 - height**2)) : (height/2)

						if (r1 == r2) {
							return ({"x": params[1].x, "y": params[1].y
								, "__Radius": r1

								, "Base": this.__Circle})
						}

						return ({"x": params[1].x, "y": params[1].y
							, "__Radius": [r1, r2]

							, "Base": this.__Ellipse})
					}
					case 2: {
						return {"x": params[1].x, "y": params[1].y
							, "__Radius": params[2]

							, "Base": this.__Circle}
					}
					Default: {
						throw (Exception("ArgumentException", -1, "Too many parameters passed to this function."))
					}
				}
			}
			case "Array": {
				switch (params.Count()) {
					case 3: {
						width := params[2], height := params[3]
							, r1 := (width < 1 && width > 0 && height >= 1) ? ((height/2)*Sqrt(1 - width**2)) : (width/2), r2 := (height < 1 && height > 0 && width >= 1) ? ((width/2)*Sqrt(1 - height**2)) : (height/2)

						if (r1 == r2) {
							return ({"x": params[1][0], "y": params[1][1]
								, "__Radius": r1

								, "Base": this.__Circle})
						}

						return ({"x": params[1][0], "y": params[1][1]
							, "__Radius": [r1, r2]

							, "Base": this.__Ellipse})
					}
					case 2: {
						return {"x": params[1][0], "y": params[1][1]
							, "__Radius": params[2]

							, "Base": this.__Circle}
					}
					Default: {
						throw (Exception("ArgumentException", -1, "Too many parameters passed to this function."))
					}
				}
			}
			Default: {
				if ((x := params[1].x) != "" && (y := params[1].y) != "") {
					if ((width := params[1].Width) != "" && (height := params[1].Height) != "") {
						r1 := (width < 1 && width > 0 && height >= 1) ? ((height/2)*Sqrt(1 - width**2)) : (width/2), r2 := (height < 1 && height > 0 && width >= 1) ? ((width/2)*Sqrt(1 - height**2)) : (height/2)

						if (r1 == r2) {
							return ({"x": x, "y": y
								, "__Radius": r1

								, "Base": this.__Circle})
						}

						return ({"x": x, "y": y
							, "__Radius": [r1, r2]

							, "Base": this.__Ellipse})
					}
					else if ((radius := params[1].Radius) != "") {
						return {"x": x, "y": y
							, "__Radius": radius

							, "Base": this.__Circle}
					}
				}

				throw (Exception("ArgumentException", -1, Format("{} is invalid. This object must be constructed from type:`n`tInteger, Float, Array, Vec2, Vec3 or Rect.", Type(x))))
			}
		}
	}

	;--------------- Method -------------------------------------------------------;

	IsIntersectCircle(circle1, circle2) {
		return ((circle1.x - circle2.x)**2 + (circle1.y - circle2.y)**2 <= (circle1.Radius + circle2.Radius)**2)
	}

	;* Note:
		;* To determine radius given n: `radius := (ellipse.Radius/(Math.Sin(Math.Pi/n) + 1))*Math.Sin(Math.Pi/n)`.
	InscribeEllipse(ellipse, radius, theta := 0, offset := 0) {
		c := ellipse.h + (ellipse.Radius - radius - offset)*Math.Cos(theta), s := ellipse.k + (ellipse.Radius - radius - offset)*Math.Sin(theta)

		return (new Ellipse(c - radius, s - radius, radius*2, radius*2))
	}

	;------------ Nested Class ----------------------------------------------------;

	Class __Circle extends Vec2.__Vec2 {

		Width[] {
			Get {
				return (this.__Radius*2)
			}
		}

		Height[] {
			Get {
				return (this.__Radius*2)
			}
		}

		h[] {
			Get {
				return (this.x + this.__Radius)
			}

			Set {
				ObjRawSet(this, "x", value - this.__Radius)

				return (value)
			}
		}

		k[] {
			Get {
				return (this.y + this.__Radius)
			}

			Set {
				ObjRawSet(this, "y", value - this.__Radius)

				return (value)
			}
		}

		Radius[] {
			Get {
				return (this.__Radius)
			}

			Set {
				switch (Type(value)) {
					case "Integer, Float": {
						ObjRawSet(this, "__Radius", value)
					}
					case "Object": {
						ObjRawSet(this, "__Radius", [value.a, value.b]), ObjSetBase(this, Ellipse.__Ellipse)
					}
					Default: {
						throw (Exception("ArgumentException", -1, "Incorrect type."))
					}
				}

				return (value)
			}
		}

		Diameter[] {
			Get {
				return (this.__Radius*2)
			}
		}

		Eccentricity[] {
			Get {
				return (0)
			}
		}

		FocalLength[] {
			Get {
				return (0)
			}
		}

		Apoapsis[] {
			Get {
				return (this.__Radius)
			}
		}

		Periapsis[] {
			Get {
				return (this.__Radius)
			}
		}

		SemiMajorAxis[] {
			Get {
				return (this.__Radius)
			}
		}

		SemiMinorAxis[] {
			Get {
				return (this.__Radius)
			}
		}

		SemiLatusRectum[] {
			Get {
				return (0)
			}
		}

		Area[] {
			Get {
				return (this.__Radius**2*Math.Pi)
			}
		}

		Circumference[] {
			Get {
				return (this.__Radius*Math.Tau)
			}
		}
	}

	Class __Ellipse extends Vec2.__Vec2 {

		Width[] {
			Get {
				return (this.__Radius[0]*2)
			}
		}

		Height[] {
			Get {
				return (this.__Radius[1]*2)
			}
		}

		h[] {
			Get {
				return (this.x + this.__Radius[0])
			}

			Set {
				ObjRawSet(this, "x", value - this.__Radius[0])

				return (value)
			}
		}

		k[] {
			Get {
				return (this.y + this.__Radius[1])
			}

			Set {
				ObjRawSet(this, "y", value - this.__Radius[1])

				return (value)
			}
		}

		Radius[] {
			Get {
				return ({"a": this.__Radius[0], "b": this.__Radius[1]})
			}

			Set {
				switch (Type(value)) {
					case "Integer, Float": {
						ObjRawSet(this, "__Radius", value), ObjSetBase(this, Ellipse.__Circle)
					}
					case "Object": {
						ObjRawSet(this, "__Radius", [value.a, value.b])
					}
					Default: {
						throw (Exception("ArgumentException", -1, "Incorrect type."))
					}
				}

				return (value)
			}
		}

		Diameter[] {
			Get {
				return ({"a": this.__Radius[0]*2, "b": this.__Radius[1]*2})
			}
		}

		Eccentricity[] {
			Get {
				return (this.FocalLength/this.SemiMajorAxis)
			}
		}

		FocalLength[] {
			Get {
				return (Sqrt(this.SemiMajorAxis**2 - this.SemiMinorAxis**2))
			}
		}

		Apoapsis[] {
			Get {
				return (this.SemiMajorAxis*(1 + this.Eccentricity))
			}
		}

		Periapsis[] {
			Get {
				return (this.SemiMajorAxis*(1 - this.Eccentricity))
			}
		}

		SemiMajorAxis[] {
			Get {
				return (Max(this.__Radius[0], this.__Radius[1]))
			}
		}

		SemiMinorAxis[] {
			Get {
				return (Min(this.__Radius[0], this.__Radius[1]))
			}
		}

		SemiLatusRectum[] {
			Get {
				return (this.SemiMajorAxis*(1 - this.Eccentricity**2))
			}
		}

		Area[] {
			Get {
				return (this.__Radius[0]*this.__Radius[1]*Math.Pi)
			}
		}

		Circumference[] {
			Get {
				return ((3*(this.__Radius[0] + this.__Radius[1]) - Sqrt((3*this.__Radius[0] + this.__Radius[1])*(this.__Radius[0] + 3*this.__Radius[1])))*Math.Pi)  ;* Approximation by Srinivasa Ramanujan.
			}
		}
	}
}

Class Matrix3 {

	__New() {
		Local

		return ({"Elements": [1, 0, 0, 0, 1, 0, 0, 0, 1]
			, "Base": this.__Matrix3})
	}

	;* Matrix3.Equals(matrix1 [Matrix3], matrix2 [Matrix3])
	;* Description:
		;* Indicates whether two matrices are the same.
	Equals(matrix1, matrix2) {
		Local

		m1 := matrix1.Elements
			, m2 := matrix2.Elements

		While (A_Index < 9) {
			i := A_Index - 1

			if (m1[i] != m2[i]) {
				return (0)
			}
		}

		return (1)
	}

	Multiply(matrix1, matrix2) {
		Local

		m1 := matrix1.Elements, a11 := m1[0], a12 := m1[1], a13 := m1[2], a21 := m1[3], a22 := m1[4], a23 := m1[5], a31 := m1[6], a32 := m1[7], a33 := m1[8]
			, m2 := matrix2.Elements, b11 := m2[0], b12 := m2[1], b13 := m2[2], b21 := m2[3], b22 := m2[4], b23 := m2[5], b31 := m2[6], b32 := m2[7], b33 := m2[8]

		;[a11*b11 + a12*b21 + a13*b31   a11*b12 + a12*b22 + a13*b32   a11*b13 + a12*b23 + a13*b33]
		;[a21*b11 + a22*b21 + a23*b31   a21*b12 + a22*b22 + a23*b32   a21*b13 + a22*b23 + a23*b33]
		;[a31*b11 + a32*b21 + a33*b31   a31*b12 + a32*b22 + a33*b32   a31*b13 + a32*b23 + a33*b33]

		return ({"Elements": [a11*b11 + a12*b21 + a13*b31, a11*b12 + a12*b22 + a13*b32, a11*b13 + a12*b23 + a13*b33
							 , a21*b11 + a22*b21 + a23*b31, a21*b12 + a22*b22 + a23*b32, a21*b13 + a22*b23 + a23*b33
							 , a31*b11 + a32*b21 + a33*b31, a31*b12 + a32*b22 + a33*b32, a31*b13 + a32*b23 + a33*b33]

			, "Base": this.__Matrix3})
	}

	;* Matrix3.RotateX(theta [Radians])
	;* Description:
		;* Creates a x-rotation matrix.
	RotateX(theta) {
		Local

		c := Cos(theta), s := Sin(theta)

		;[1      0         0  ]
		;[0    cos(θ)   sin(θ)]
		;[0   -sin(θ)   cos(θ)]

		return ({"Elements": [1, 0, 0, 0, c, s, 0, -s, c]
			, "Base": this.__Matrix3})
	}

	;* Matrix3.RotateY(theta [Radians])
	;* Description:
		;* Creates a y-rotation matrix.
	RotateY(theta) {
		Local

		c := Cos(theta), s := Sin(theta)

		;[cos(θ)   0   -sin(θ)]
		;[  0      1      0   ]
		;[sin(θ)   0    cos(θ)]

		return ({"Elements": [c, 0, -s, 0, 1, 0, s, 0, c]
			, "Base": this.__Matrix3})
	}

	;* Matrix3.RotateZ(theta [Radians])
	;* Description:
		;* Creates a z-rotation matrix.
	RotateZ(theta) {
		Local

		c := Cos(theta), s := Sin(theta)

		;[ cos(θ)   sin(θ)   0]
		;[-sin(θ)   cos(θ)   0]
		;[    0       0      1]

		return ({"Elements": [c, s, 0, -s, c, 0, 0, 0, 1]
			, "Base": this.__Matrix3})
	}

	Class __Matrix3 extends __Object {

		Set(elements) {
			Local

			this.Elements := elements

			return (this)

		}

		RotateX(theta) {
			Local

			c := Cos(theta), s := Sin(theta)
				, m := this.Elements, m12 := m[1], m13 := m[2], m22 := m[4], m23 := m[5], m32 := m[7], m33 := m[8]

			this.Elements[1] := m12*c + m13*-s, this.Elements[2] := m12*s + m13*c, this.Elements[4] := m22*c + m23*-s, this.Elements[5] := m22*s + m23*c, this.Elements[7] := m32*c + m33*-s, this.Elements[8] := m32*s + m33*c

			return (this)
		}

		RotateY(theta) {
			Local

			c := Cos(theta), s := Sin(theta)
				, m := this.Elements, m11 := m[0], m13 := m[2], m21 := m[3], m23 := m[5], m31 := m[6], m33 := m[8]

			this.Elements[0] := m11*c + m13*s, this.Elements[2] := m11*-s + m13*c, this.Elements[3] := m21*c + m23*s, this.Elements[5] := m21*-s + m23*c, this.Elements[6] := m31*c + m33*s, this.Elements[8] := m31*-s + m33*c

			return (this)
		}

		RotateZ(theta) {
			Local

			c := Cos(theta), s := Sin(theta)
				, m := this.Elements, m11 := m[0], m12 := m[1], m21 := m[3], m22 := m[4], m31 := m[6], m32 := m[7]

			this.Elements[0] := m11*c + m12*-s, this.Elements[1] := m11*s + m12*c, this.Elements[3] := m21*c + m22*-s, this.Elements[4] := m21*s + m22*c, this.Elements[6] := m31*c + m32*-s, this.Elements[7] := m31*s + m32*c

			return (this)
		}

;		Print() {
;			Local
;
;			e := this.Elements
;
;			Loop, % 9 {
;				i := A_Index - 1
;					, r .= ((A_Index == 1) ? ("[") : (["`n "][Mod(i, 3)])) . [" "][!(e[i] >= 0)] . e[i] . ((i < 8) ? (", ") : (" ]"))
;			}
;
;			return (r)
;		}
	}
}











;Calculate distance and bearing between two Latitude/Longitude points using haversine formula in JavaScript
;http://www.movable-type.co.uk/scripts/latlong.html
;algorithm - Calculate distance between two latitude-longitude points? (Haversine formula) - Stack Overflow
;https://stackoverflow.com/questions/27928/calculate-distance-between-two-latitude-longitude-points-haversine-formula
;Haversine formula - Wikipedia
;https://en.wikipedia.org/wiki/Haversine_formula
;Haversine formula - Rosetta Code
;https://rosettacode.org/wiki/Haversine_formula
;Wolfram|Alpha Examples: Geodesy & Navigation
;https://www.wolframalpha.com/examples/science-and-technology/earth-sciences/geodesy-and-navigation/
;51.51N 0.13W to 41.29S 174.78E km - Wolfram|Alpha
;https://www.wolframalpha.com/input/?i=51.51N+0.13W+to+41.29S+174.78E+km
;51.51N 0.13W to 35.28S 149.13E km - Wolfram|Alpha
;https://www.wolframalpha.com/input/?i=51.51N+0.13W+to+35.28S+149.13E+km
;41.29S 174.78E to 35.28S 149.13E km - Wolfram|Alpha
;https://www.wolframalpha.com/input/?i=41.29S+174.78E+to+35.28S+149.13E+km

oCoordA := [51.51, -0.13] ;London
oCoordB := [-41.29, -174.78] ;Wellington
oCoordC := [-35.28, -149.13] ;Canberra
;MsgBox % LatLonGetDist(oCoordA.1, oCoordA.2, oCoordB.1, oCoordB.2) ;18807.714928
;MsgBox % LatLonGetDist(oCoordA.1, oCoordA.2, oCoordC.1, oCoordC.2) ;16965.064315
;MsgBox % LatLonGetDist(oCoordB.1, oCoordB.2, oCoordC.1, oCoordC.2) ;2326.586058

;distance between two points on a sphere (e.g. Earth, the globe)
;note: radians = degrees * (pi/180) = degrees * 0.01745329252
;note: radius of Earth is 6371 km = 3958.8 miles
LatLonGetDist(vLat1, vLon1, vLat2, vLon2, vRadius:=6371)
{
	local
	vLat1R := vLat1*0.01745329252
	vLat2R := vLat2*0.01745329252
	vLatDiffR := (vLat2-vLat1)*0.01745329252
	vLonDiffR := (vLon2-vLon1)*0.01745329252
	vA := Sin(vLatDiffR/2) * Sin(vLatDiffR/2) + Cos(vLat1R) * Cos(vLat2R) * Sin(vLonDiffR/2) * Sin(vLonDiffR/2)
	return vRadius * 2 * DllCall("msvcrt\atan2", "Double",Sqrt(vA), "Double",Sqrt(1-vA), "Cdecl Double")
}