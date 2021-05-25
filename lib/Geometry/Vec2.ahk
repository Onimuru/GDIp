class Vec2 {

	;* Vec2([x, y])
	__New(param1 := 0, param2 := 0) {
		this.x := param1, this.y := param2
	}

	Clone() {
		return (Vec2(this.x, this.y))
	}

	;* Vec2.Equals(vector1, vector2)
	static Equals(vector1, vector2) {
		return (vector1 is Vec2 && vector2 is Vec2 && vector1.x == vector2.x && vector1.y == vector2.y)
	}

	;* Vec2.Divide(vector1, vector2)
	static Divide(vector1, vector2) {
		try {
			return (this(vector1.x/vector2.x, vector1.y/vector2.y))
		}
		catch PropertyError {
			throw ((IsObject(vector1) && vector1.HasProp("x") && vector1.HasProp("y"))
				? (TypeError("``vector2`` is invalid.", -1, "This parameter must be an Object with x and y properties."))
				: (TypeError("``vector1`` is invalid.", -1, "This parameter must be an Object with x and y properties.")))
		}
		;* Use the default ZeroDivisionError.
	}

	static DivideScalar(vector, scalar) {
		try {
			return (this(vector.x/scalar, vector.y/scalar))
		}
		catch TypeError {
			throw (TypeError("``scalar`` is invalid.", -1, "This parameter must be a Number."))
		}
		catch PropertyError {
			throw (TypeError("``vector`` is invalid.", -1, "This parameter must be an Object with x and y properties."))
		}
	}

	;* Vec2.Multiply(vector1, vector2)
	static Multiply(vector1, vector2) {
		try {
			return (this(vector1.x*vector2.x, vector1.y*vector2.y))
		}
		catch PropertyError {
			throw ((IsObject(vector1) && vector1.HasProp("x") && vector1.HasProp("y"))
				? (TypeError("``vector2`` is invalid.", -1, "This parameter must be an Object with x and y properties."))
				: (TypeError("``vector1`` is invalid.", -1, "This parameter must be an Object with x and y properties.")))
		}
	}

	static MultiplyScalar(vector, scalar) {
		try {
			return (this(vector.x*scalar, vector.y*scalar))
		}
		catch TypeError {
			throw (TypeError("``scalar`` is invalid.", -1, "This parameter must be a Number."))
		}
		catch PropertyError {
			throw (TypeError("``vector`` is invalid.", -1, "This parameter must be an Object with x and y properties."))
		}
	}

	;* Vec2.Add(vector1, vector2)
	static Add(vector1, vector2) {
		try {
			return (this(vector1.x + vector2.x, vector1.y + vector2.y))
		}
		catch PropertyError {
			throw ((IsObject(vector1) && vector1.HasProp("x") && vector1.HasProp("y"))
				? (TypeError("``vector2`` is invalid.", -1, "This parameter must be an Object with x and y properties."))
				: (TypeError("``vector1`` is invalid.", -1, "This parameter must be an Object with x and y properties.")))
		}
	}

	static AddScalar(vector, scalar) {
		try {
			return (this(vector.x + scalar, vector.y + scalar))
		}
		catch TypeError {
			throw (TypeError("``scalar`` is invalid.", -1, "This parameter must be a Number."))
		}
		catch PropertyError {
			throw (TypeError("``vector`` is invalid.", -1, "This parameter must be an Object with x and y properties."))
		}
	}

	;* Vec2.Subtract(vector1, vector2)
	static Subtract(vector1, vector2) {
		try {
			return (this(vector1.x - vector2.x, vector1.y - vector2.y))
		}
		catch PropertyError {
			throw ((IsObject(vector1) && vector1.HasProp("x") && vector1.HasProp("y"))
				? (TypeError("``vector2`` is invalid.", -1, "This parameter must be an Object with x and y properties."))
				: (TypeError("``vector1`` is invalid.", -1, "This parameter must be an Object with x and y properties.")))
		}
	}

	static SubtractScalar(vector, scalar) {
		try {
			return (this(vector.x - scalar, vector.y - scalar))
		}
		catch TypeError {
			throw (TypeError("``scalar`` is invalid.", -1, "This parameter must be a Number."))
		}
		catch PropertyError {
			throw (TypeError("``vector`` is invalid.", -1, "This parameter must be an Object with x and y properties."))
		}
	}

	;* Vec2.Distance(vector1, vector2)
	static Distance(vector1, vector2) {
		try {
			return (Sqrt((vector1.x - vector2.x)**2 + (vector1.y - vector2.y)**2))
		}
		catch PropertyError {
			throw ((IsObject(vector1) && vector1.HasProp("x") && vector1.HasProp("y"))
				? (TypeError("``vector2`` is invalid.", -1, "This parameter must be an Object with x and y properties."))
				: (TypeError("``vector1`` is invalid.", -1, "This parameter must be an Object with x and y properties.")))
		}
	}

	;* Vec2.DistanceSquared(vector1, vector2)
	static DistanceSquared(vector1, vector2) {
		try {
			return ((vector1.x - vector2.x)**2 + (vector1.y - vector2.y)**2)
		}
		catch PropertyError {
			throw ((IsObject(vector1) && vector1.HasProp("x") && vector1.HasProp("y"))
				? (TypeError("``vector2`` is invalid.", -1, "This parameter must be an Object with x and y properties."))
				: (TypeError("``vector1`` is invalid.", -1, "This parameter must be an Object with x and y properties.")))
		}
	}

	;* Vec2.Dot(vector1, vector2)
	static Dot(vector1, vector2) {
		try {
			return (vector1.x*vector2.x + vector1.y*vector2.y)
		}
		catch PropertyError {
			throw ((IsObject(vector1) && vector1.HasProp("x") && vector1.HasProp("y"))
				? (TypeError("``vector2`` is invalid.", -1, "This parameter must be an Object with x and y properties."))
				: (TypeError("``vector1`` is invalid.", -1, "This parameter must be an Object with x and y properties.")))
		}
	}

	;* Vec2.Cross(vector1, vector2)
	static Cross(vector1, vector2) {
		try {
			return (vector1.x*vector2.y - vector1.y*vector2.x)
		}
		catch PropertyError {
			throw ((IsObject(vector1) && vector1.HasProp("x") && vector1.HasProp("y"))
				? (TypeError("``vector2`` is invalid.", -1, "This parameter must be an Object with x and y properties."))
				: (TypeError("``vector1`` is invalid.", -1, "This parameter must be an Object with x and y properties.")))
		}
	}

	;* Vec2.Transform(vector, matrix)
	static Transform(vector, matrix) {
		try {
			x := vector.x, y := vector.y

			switch (Type(matrix)) {
				case "TransformMatrix":
					return (this(matrix[0]*x + matrix[3]*y + matrix[6], matrix[1]*x + matrix[4]*y + matrix[7]))
				case "Matrix3", "RotationMatrix":
					return (this(matrix[0]*x + matrix[3]*y + matrix[2], matrix[1]*x + matrix[4]*y + matrix[5]))
			}

			return (this(matrix[0]*x + matrix[3]*y + matrix[6], matrix[1]*x + matrix[4]*y + matrix[7]))
		}
		catch PropertyError {
			throw (TypeError("``vector`` is invalid.", -1, "This parameter must be an Object with x and y properties."))
		}
		catch IndexError {
			throw (TypeError("``matrix`` is invalid.", -1, "This parameter must be an Array."))
		}
	}

	;* Vec2.Lerp(vector1, vector2, alpha)
	static Lerp(vector1, vector2, alpha) {
		try {
			return (this(vector1.x + (vector2.x - vector1.x)*alpha, vector1.y + (vector2.y - vector1.y)*alpha))
		}
		catch PropertyError {
			throw ((IsObject(vector1) && vector1.HasProp("x") && vector1.HasProp("y"))
				? (TypeError("``vector2`` is invalid.", -1, "This parameter must be an Object with x and y properties."))
				: (TypeError("``vector1`` is invalid.", -1, "This parameter must be an Object with x and y properties.")))
		}
		catch TypeError {
			throw (TypeError("``alpha`` is invalid.", -1, "This parameter must be a Number."))
		}
	}

	;* Vec2.Clamp(vector, lower, upper)
	static Clamp(vector, lower, upper) {
		try {
			return (this(Max(lower.x, Min(upper.x, vector.x)), Max(lower.y, Min(upper.y, vector.y))))
		}
		catch PropertyError {
			throw ((IsObject(vector) && vector.HasProp("x") && vector.HasProp("y"))
				? ((IsObject(lower) && lower.HasProp("x") && lower.HasProp("y"))
					? (TypeError("``upper`` is invalid.", -1, "This parameter must be an Object with x and y properties."))
					: (TypeError("``lower`` is invalid.", -1, "This parameter must be an Object with x and y properties.")))
				: (TypeError("``vector`` is invalid.", -1, "This parameter must be an Object with x and y properties.")))
		}
	}

	;* Vec2.Min(vector1, vector2)
	static Min(vector1, vector2) {
		try {
			return (this(Min(vector1.x, vector2.x), Min(vector1.y, vector2.y)))
		}
		catch PropertyError {
			throw ((IsObject(vector1) && vector1.HasProp("x") && vector1.HasProp("y"))
				? (TypeError("``vector2`` is invalid.", -1, "This parameter must be an Object with x and y properties."))
				: (TypeError("``vector1`` is invalid.", -1, "This parameter must be an Object with x and y properties.")))
		}
	}

	;* Vec2.Max(vector1, vector2)
	static Max(vector1, vector2) {
		try {
			return (this(Max(vector1.x, vector2.x), Max(vector1.y, vector2.y)))
		}
		catch PropertyError {
			throw ((IsObject(vector1) && vector1.HasProp("x") && vector1.HasProp("y"))
				? (TypeError("``vector2`` is invalid.", -1, "This parameter must be an Object with x and y properties."))
				: (TypeError("``vector1`` is invalid.", -1, "This parameter must be an Object with x and y properties.")))
		}
	}

	;* vector.Length[ := value]
	;* Description:
		;* Calculates the length (magnitude) of the vector.
	Length {
		Get {
			return (Sqrt(this.x**2 + this.y**2))
		}

		Set {
			this.Normalize().MultiplyScalar(value)

			return (value)
		}
	}

	;* vector.LengthSquared
	LengthSquared {
		Get {
			return (this.x**2 + this.y**2)
		}
	}

	Copy(vector) {
		try {
			return (this.Set(vector.x, vector.y))
		}
		catch PropertyError {
			throw (TypeError("``vector`` is invalid.", -1, "This parameter must be an Object with x and y properties."))
		}
	}

	Set(x, y) {
		this.x := x, this.y := y
		return (this)
	}

	SetScalar(scalar) {
		this.x := scalar, this.y := scalar
		return (this)
	}

	;* vector.Negate()
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

	Divide(vector) {
		try {
			this.x /= vector.x, this.y /= vector.y
			return (this)
		}
		catch PropertyError {
			throw (TypeError("``vector`` is invalid.", -1, "This parameter must be an Object with x and y properties."))
		}
		;* Use the default ZeroDivisionError.
	}

	DivideScalar(scalar) {
		try {
			this.x /= scalar, this.y /= scalar
			return (this)
		}
		catch TypeError {
			throw (TypeError("``scalar`` is invalid.", -1, "This parameter must be a Number."))
		}
		;* Use the default ZeroDivisionError.
	}

	Multiply(vector) {
		try {
			this.x *= vector.x, this.y *= vector.y
			return (this)
		}
		catch PropertyError {
			throw (TypeError("``vector`` is invalid.", -1, "This parameter must be an Object with x and y properties."))
		}
	}

	MultiplyScalar(scalar) {
		try {
			this.x *= scalar, this.y *= scalar
			return (this)
		}
		catch TypeError {
			throw (TypeError("``scalar`` is invalid.", -1, "This parameter must be a Number."))
		}
	}

	Add(vector) {
		try {
			this.x += vector.x, this.y += vector.y
			return (this)
		}
		catch PropertyError {
			throw (TypeError("``vector`` is invalid.", -1, "This parameter must be an Object with x and y properties."))
		}
	}

	AddScalar(scalar) {
		try {
			this.x += scalar, this.y += scalar
			return (this)
		}
		catch TypeError {
			throw (TypeError("``scalar`` is invalid.", -1, "This parameter must be a Number."))
		}
	}

	Subtract(vector) {
		try {
			this.x -= vector.x, this.y -= vector.y
			return (this)
		}
		catch PropertyError {
			throw (TypeError("``vector`` is invalid.", -1, "This parameter must be an Object with x and y properties."))
		}
	}

	SubtractScalar(scalar) {
		try {
			this.x -= scalar, this.y -= scalar
			return (this)
		}
		catch TypeError {
			throw (TypeError("``scalar`` is invalid.", -1, "This parameter must be a Number."))
		}
	}

	Transform(matrix) {
		try {
			x := this.x, y := this.y

			switch (Type(matrix)) {
				case "TransformMatrix":
					return (this.Set(matrix[0]*x + matrix[3]*y + matrix[6], matrix[1]*x + matrix[4]*y + matrix[7]))
				case "Matrix3", "RotationMatrix":
					return (this.Set(matrix[0]*x + matrix[3]*y + matrix[2], matrix[1]*x + matrix[4]*y + matrix[5]))
			}
		}
		catch IndexError {
			throw (TypeError("``matrix`` is invalid.", -1, "This parameter must be an Array."))
		}
	}

	;* vector.Lerp()
	Lerp(vector, alpha) {
		try {
			this.x += (vector.x - this.x)*alpha, this.y += (vector.y - this.y)*alpha
			return (this)
		}
		catch PropertyError {
			throw (TypeError("``vector`` is invalid.", -1, "This parameter must be an Object with x and y properties."))
		}
		catch TypeError {
			throw (TypeError("``alpha`` is invalid.", -1, "This parameter must be a Number."))
		}
	}

	Clamp(lower, upper) {
		try {
			return (this.Set(Max(lower.x, Min(upper.x, this.x)), Max(lower.y, Min(upper.y, this.y))))
		}
		catch PropertyError {
			throw ((IsObject(lower) && lower.HasProp("x") && lower.HasProp("y"))
				? (TypeError("``upper`` is invalid.", -1, "This parameter must be an Object with x and y properties."))
				: (TypeError("``lower`` is invalid.", -1, "This parameter must be an Object with x and y properties.")))
		}
	}

	ClampScalar(lower, upper) {
		try {
			return (this.Set(Max(lower, Min(upper, this.x)), Max(lower, Min(upper, this.y))))
		}
		catch TypeError {
			throw ((lower is Number)
				? (TypeError("``upper`` is invalid.", -1, "This parameter must be a Number."))
				: (TypeError("``lower`` is invalid.", -1, "This parameter must be a Number.")))
		}
	}

	ClampLength(lower, upper) {
		if (length := this.Length) {
			this.DivideScalar(length)
		}

		try {
			return (this.MultiplyScalar(Max(lower, Min(upper, length))))
		}
		catch TypeError {
			throw ((lower is Number)
				? (TypeError("``upper`` is invalid.", -1, "This parameter must be a Number."))
				: (TypeError("``lower`` is invalid.", -1, "This parameter must be a Number.")))
		}
	}

	Ceil(decimalPlace := False) {
		try {
			if (decimalPlace) {
				p := 10**decimalPlace

				return (this.Set(Round(Ceil(this.x*p)/p, decimalPlace), Round(Ceil(this.y*p)/p, decimalPlace)))
			}

			return (this.Set(Ceil(this.x), Ceil(this.y)))
		}
		catch TypeError {
			throw (TypeError("``decimalPlace`` is invalid.", -1, "This parameter must be a Number."))
		}
	}

	Floor(decimalPlace := False) {
		try {
			if (decimalPlace) {
				p := 10**decimalPlace

				return (this.Set(Round(Floor(this.x*p)/p, decimalPlace), Round(Floor(this.y*p)/p, decimalPlace)))
			}

			return (this.Set(Floor(this.x), Floor(this.y)))
		}
		catch TypeError {
			throw (TypeError("``decimalPlace`` is invalid.", -1, "This parameter must be a Number."))
		}
	}

	Fix(decimalPlace := False) {
		try {
			x := this.x, y := this.y

			if (decimalPlace) {
				p := 10**decimalPlace

				return (this.Set(Round((x < 0) ? (Ceil(x*p)/p) : (Floor(x*p)/p), decimalPlace), Round((y < 0) ? (Ceil(y*p)/p) : (Floor(y*p)/p), decimalPlace)))
			}

			return (this.Set((x < 0) ? (Ceil(x)) : (Floor(x)), (y < 0) ? (Ceil(y)) : (Floor(y))))
		}
		catch TypeError {
			throw (TypeError("``decimalPlace`` is invalid.", -1, "This parameter must be a Number."))
		}
	}

	Round(decimalPlace := False) {
		try {
			return ((decimalPlace)
				? (this.Set(Round(this.x, decimalPlace), Round(this.y, decimalPlace)))
				: (this.Set(Round(this.x), Round(this.y))))
		}
		catch TypeError {
			throw (TypeError("``decimalPlace`` is invalid.", -1, "This parameter must be a Number."))
		}
	}

	Min(vector) {
		try {
			return (this.Set(Min(this.x, vector.x), Min(this.y, vector.y)))
		}
		catch PropertyError {
			throw (TypeError("``vector`` is invalid.", -1, "This parameter must be an Object with x and y properties."))
		}
	}

	Max(vector) {
		try {
			return (this.Set(Max(this.x, vector.x), Max(this.y, vector.y)))
		}
		catch PropertyError {
			throw (TypeError("``vector`` is invalid.", -1, "This parameter must be an Object with x and y properties."))
		}
	}
}