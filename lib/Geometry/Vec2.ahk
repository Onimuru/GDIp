class Vec2 extends Array {

;	;* Vec2([x, y])
	__New(x := 0, y := 0) {
		this.Push(x, y)
	}

	Clone() {
		return (Vec2(this*))
	}

	;* Vec2.Equals(vector1, vector2)
	static Equals(vector1, vector2) {
		return (vector1 is Vec2 && vector2 is Vec2 && vector1.Every((element, index, *) => (element == vector2[index])))
	}

	;* Vec2.Divide(vector1, vector2)
	static Divide(vector1, vector2) {
		try {
			return (this(vector1[0]/vector2[0], vector1[1]/vector2[1]))
		}
		catch IndexError {
			throw ((vector1 is Array && vector1.Length == 2)
				? (TypeError("``vector2`` is invalid.", -1, "This parameter must be an Array with two elements."))
				: (TypeError("``vector1`` is invalid.", -1, "This parameter must be an Array with two elements.")))
		}
		;* Use the default ZeroDivisionError.
	}

	static DivideScalar(vector, scalar) {
		try {
			return (this(vector[0]/scalar, vector[1]/scalar))
		}
		catch IndexError {
			throw (TypeError("``vector`` is invalid.", -1, "This parameter must be an Array with two elements."))
		}
		catch TypeError {
			throw (TypeError("``scalar`` is invalid.", -1, "This parameter must be a Number."))
		}
	}

	;* Vec2.Multiply(vector1, vector2)
	static Multiply(vector1, vector2) {
		try {
			return (this(vector1[0]*vector2[0], vector1[1]*vector2[1]))
		}
		catch IndexError {
			throw ((vector1 is Array && vector1.Length == 2)
				? (TypeError("``vector2`` is invalid.", -1, "This parameter must be an Array with two elements."))
				: (TypeError("``vector1`` is invalid.", -1, "This parameter must be an Array with two elements.")))
		}
	}

	static MultiplyScalar(vector, scalar) {
		try {
			return (this(vector[0]*scalar, vector[1]*scalar))
		}
		catch IndexError {
			throw (TypeError("``vector`` is invalid.", -1, "This parameter must be an Array with two elements."))
		}
		catch TypeError {
			throw (TypeError("``scalar`` is invalid.", -1, "This parameter must be a Number."))
		}
	}

	;* Vec2.Add(vector1, vector2)
	static Add(vector1, vector2) {
		try {
			return (this(vector1[0] + vector2[0], vector1[1] + vector2[1]))
		}
		catch IndexError {
			throw ((vector1 is Array && vector1.Length == 2)
				? (TypeError("``vector2`` is invalid.", -1, "This parameter must be an Array with two elements."))
				: (TypeError("``vector1`` is invalid.", -1, "This parameter must be an Array with two elements.")))
		}
	}

	static AddScalar(vector, scalar) {
		try {
			return (this(vector[0] + scalar, vector[1] + scalar))
		}
		catch IndexError {
			throw (TypeError("``vector`` is invalid.", -1, "This parameter must be an Array with two elements."))
		}
		catch TypeError {
			throw (TypeError("``scalar`` is invalid.", -1, "This parameter must be a Number."))
		}
	}

	;* Vec2.Subtract(vector1, vector2)
	static Subtract(vector1, vector2) {
		try {
			return (this(vector1[0] - vector2[0], vector1[1] - vector2[1]))
		}
		catch IndexError {
			throw ((vector1 is Array && vector1.Length == 2)
				? (TypeError("``vector2`` is invalid.", -1, "This parameter must be an Array with two elements."))
				: (TypeError("``vector1`` is invalid.", -1, "This parameter must be an Array with two elements.")))
		}
	}

	static SubtractScalar(vector, scalar) {
		try {
			return (this(vector[0] - scalar, vector[1] - scalar))
		}
		catch IndexError {
			throw (TypeError("``vector`` is invalid.", -1, "This parameter must be an Array with two elements."))
		}
		catch TypeError {
			throw (TypeError("``scalar`` is invalid.", -1, "This parameter must be a Number."))
		}
	}

	;* Vec2.Distance(vector1, vector2)
	static Distance(vector1, vector2) {
		try {
			return (Sqrt((vector1[0] - vector2[0])**2 + (vector1[1] - vector2[1])**2))
		}
		catch IndexError {
			throw ((vector1 is Array && vector1.Length == 2)
				? (TypeError("``vector2`` is invalid.", -1, "This parameter must be an Array with two elements."))
				: (TypeError("``vector1`` is invalid.", -1, "This parameter must be an Array with two elements.")))
		}
	}

	;* Vec2.DistanceSquared(vector1, vector2)
	static DistanceSquared(vector1, vector2) {
		try {
			return ((vector1[0] - vector2[0])**2 + (vector1[1] - vector2[1])**2)
		}
		catch IndexError {
			throw ((vector1 is Array && vector1.Length == 2)
				? (TypeError("``vector2`` is invalid.", -1, "This parameter must be an Array with two elements."))
				: (TypeError("``vector1`` is invalid.", -1, "This parameter must be an Array with two elements.")))
		}
	}

	;* Vec2.Dot(vector1, vector2)
	static Dot(vector1, vector2) {
		try {
			return (vector1[0]*vector2[0] + vector1[1]*vector2[1])
		}
		catch IndexError {
			throw ((vector1 is Array && vector1.Length == 2)
				? (TypeError("``vector2`` is invalid.", -1, "This parameter must be an Array with two elements."))
				: (TypeError("``vector1`` is invalid.", -1, "This parameter must be an Array with two elements.")))
		}
	}

	;* Vec2.Cross(vector1, vector2)
	static Cross(vector1, vector2) {
		try {
			return (vector1[0]*vector2[1] - vector1[1]*vector2[0])
		}
		catch IndexError {
			throw ((vector1 is Array && vector1.Length == 2)
				? (TypeError("``vector2`` is invalid.", -1, "This parameter must be an Array with two elements."))
				: (TypeError("``vector1`` is invalid.", -1, "This parameter must be an Array with two elements.")))
		}
	}

	;* Vec2.Transform(vector, matrix)
	static Transform(vector, matrix) {
		try {
			x := vector[0], y := vector[1]

			switch (Type(matrix)) {
				case "TransformMatrix":
					return (this(matrix[0]*x + matrix[3]*y + matrix[6], matrix[1]*x + matrix[4]*y + matrix[7]))
				case "Matrix3", "RotationMatrix":
					return (this(matrix[0]*x + matrix[3]*y + matrix[2], matrix[1]*x + matrix[4]*y + matrix[5]))
			}

			return (this(matrix[0]*x + matrix[3]*y + matrix[6], matrix[1]*x + matrix[4]*y + matrix[7]))
		}
		catch IndexError {
			throw ((vector is Array && vector.Length == 2)
				? (TypeError("``matrix`` is invalid.", -1, "This parameter must be an Array."))
				: (TypeError("``vector`` is invalid.", -1, "This parameter must be an Array with two elements.")))
		}
	}

	;* Vec2.Lerp(vector1, vector2, alpha)
	static Lerp(vector1, vector2, alpha) {
		try {
			return (this(vector1[0] + (vector2[0] - vector1[0])*alpha, vector1[1] + (vector2[1] - vector1[1])*alpha))
		}
		catch IndexError {
			throw ((vector1 is Array && vector1.Length == 2)
				? (TypeError("``vector2`` is invalid.", -1, "This parameter must be an Array with two elements."))
				: (TypeError("``vector1`` is invalid.", -1, "This parameter must be an Array with two elements.")))
		}
		catch TypeError {
			throw (TypeError("``alpha`` is invalid.", -1, "This parameter must be a Number."))
		}
	}

	;* Vec2.Clamp(vector, lower, upper)
	static Clamp(vector, lower, upper) {
		try {
			return (this(Max(lower[0], Min(upper[0], vector[0])), Max(lower[1], Min(upper[1], vector[1]))))
		}
		catch IndexError {
			throw ((vector is Array && vector.Length == 2)
				? ((lower is Array && lower.Length == 2)
					? (TypeError("``upper`` is invalid.", -1, "This parameter must be an Array with two elements."))
					: (TypeError("``lower`` is invalid.", -1, "This parameter must be an Array with two elements.")))
				: (TypeError("``vector`` is invalid.", -1, "This parameter must be an Array with two elements.")))
		}
	}

	;* Vec2.Min(vector1, vector2)
	static Min(vector1, vector2) {
		try {
			return (this(Min(vector1[0], vector2[0]), Min(vector1[1], vector2[1])))
		}
		catch IndexError {
			throw ((vector1 is Array && vector1.Length == 2)
				? (TypeError("``vector2`` is invalid.", -1, "This parameter must be an Array with two elements."))
				: (TypeError("``vector1`` is invalid.", -1, "This parameter must be an Array with two elements.")))
		}
	}

	;* Vec2.Max(vector1, vector2)
	static Max(vector1, vector2) {
		try {
			return (this(Max(vector1[0], vector2[0]), Max(vector1[1], vector2[1])))
		}
		catch IndexError {
			throw ((vector1 is Array && vector1.Length == 2)
				? (TypeError("``vector2`` is invalid.", -1, "This parameter must be an Array with two elements."))
				: (TypeError("``vector1`` is invalid.", -1, "This parameter must be an Array with two elements.")))
		}
	}

	x {
		Get {
			return (this[0])
		}
	}

	y {
		Get {
			return (this[1])
		}
	}

	;* vector.Magnitude[ := value]
	;* Description:
		;* Calculates the length (magnitude) of the vector.
	Magnitude {
		Get {
			return (Sqrt(this[0]**2 + this[1]**2))
		}

		Set {
			this.Normalize().MultiplyScalar(value)

			return (value)
		}
	}

	;* vector.MagnitudeSquared
	MagnitudeSquared {
		Get {
			return (this[0]**2 + this[1]**2)
		}
	}

	Copy(vector) {
		try {
			return (this.Set(vector[0], vector[1]))
		}
		catch IndexError {
			throw (TypeError("``vector`` is invalid.", -1, "This parameter must be an Array with two elements."))
		}
	}

	Set(x, y) {
		this[0] := x, this[1] := y
		return (this)
	}

	SetScalar(scalar) {
		this[0] := scalar, this[1] := scalar
		return (this)
	}

	;* vector.Negate()
	Negate() {
		this[0] *= -1, this[1] *= -1
		return (this)
	}

	;* vector.Normalize()
	;* Description:
		;* Normalize the vector to a unit length of 1.
	Normalize() {
		if (s := this.Magnitude) {
			this[0] /= s, this[1] /= s
		}

		return (this)
	}

	Divide(vector) {
		try {
			this[0] /= vector[0], this[1] /= vector[1]
			return (this)
		}
		catch IndexError {
			throw (TypeError("``vector`` is invalid.", -1, "This parameter must be an Array with two elements."))
		}
		;* Use the default ZeroDivisionError.
	}

	DivideScalar(scalar) {
		try {
			this[0] /= scalar, this[1] /= scalar
			return (this)
		}
		catch TypeError {
			throw (TypeError("``scalar`` is invalid.", -1, "This parameter must be a Number."))
		}
		;* Use the default ZeroDivisionError.
	}

	Multiply(vector) {
		try {
			this[0] *= vector[0], this[1] *= vector[1]
			return (this)
		}
		catch IndexError {
			throw (TypeError("``vector`` is invalid.", -1, "This parameter must be an Array with two elements."))
		}
	}

	MultiplyScalar(scalar) {
		try {
			this[0] *= scalar, this[1] *= scalar
			return (this)
		}
		catch TypeError {
			throw (TypeError("``scalar`` is invalid.", -1, "This parameter must be a Number."))
		}
	}

	Add(vector) {
		try {
			this[0] += vector[0], this[1] += vector[1]
			return (this)
		}
		catch IndexError {
			throw (TypeError("``vector`` is invalid.", -1, "This parameter must be an Array with two elements."))
		}
	}

	AddScalar(scalar) {
		try {
			this[0] += scalar, this[1] += scalar
			return (this)
		}
		catch TypeError {
			throw (TypeError("``scalar`` is invalid.", -1, "This parameter must be a Number."))
		}
	}

	Subtract(vector) {
		try {
			this[0] -= vector[0], this[1] -= vector[1]
			return (this)
		}
		catch IndexError {
			throw (TypeError("``vector`` is invalid.", -1, "This parameter must be an Array with two elements."))
		}
	}

	SubtractScalar(scalar) {
		try {
			this[0] -= scalar, this[1] -= scalar
			return (this)
		}
		catch TypeError {
			throw (TypeError("``scalar`` is invalid.", -1, "This parameter must be a Number."))
		}
	}

	Transform(matrix) {
		try {
			x := this[0], y := this[1]

			switch (Type(matrix)) {
				case "TransformMatrix":
					;             [m11   m12   0]
					; [x   y   1] [m21   m22   0] = [x*m11 + y*m21 + 1*m31   x*m12 + y*m22 + 1*m32]
					;             [m31   m32   1]

					return (this.Set(x*matrix[0] + y*matrix[3] + matrix[6], x*matrix[1] + y*matrix[4] + matrix[7]))
				case "Matrix3", "RotationMatrix":
					return (this.Set(x*matrix[0] + y*matrix[3] + matrix[6], x*matrix[1] + y*matrix[4] + matrix[7]))
			}
		}
		catch IndexError {
			throw (TypeError("``matrix`` is invalid.", -1, "This parameter must be an Array."))
		}
	}

	;* vector.Lerp()
	Lerp(vector, alpha) {
		try {
			this[0] += (vector[0] - this[0])*alpha, this[1] += (vector[1] - this[1])*alpha
			return (this)
		}
		catch IndexError {
			throw (TypeError("``vector`` is invalid.", -1, "This parameter must be an Array with two elements."))
		}
		catch TypeError {
			throw (TypeError("``alpha`` is invalid.", -1, "This parameter must be a Number."))
		}
	}

	Clamp(lower, upper) {
		try {
			return (this.Set(Max(lower[0], Min(upper[0], this[0])), Max(lower[1], Min(upper[1], this[1]))))
		}
		catch IndexError {
			throw ((lower is Array && lower.Length == 2)
				? (TypeError("``upper`` is invalid.", -1, "This parameter must be an Array with two elements."))
				: (TypeError("``lower`` is invalid.", -1, "This parameter must be an Array with two elements.")))
		}
	}

	ClampScalar(lower, upper) {
		try {
			return (this.Set(Max(lower, Min(upper, this[0])), Max(lower, Min(upper, this[1]))))
		}
		catch TypeError {
			throw ((lower is Number)
				? (TypeError("``upper`` is invalid.", -1, "This parameter must be a Number."))
				: (TypeError("``lower`` is invalid.", -1, "This parameter must be a Number.")))
		}
	}

	ClampMagnitude(lower, upper) {
		if (magnitude := this.Magnitude) {
			this.DivideScalar(magnitude)
		}

		try {
			return (this.MultiplyScalar(Max(lower, Min(upper, magnitude))))
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

				return (this.Set(Round(Ceil(this[0]*p)/p, decimalPlace), Round(Ceil(this[1]*p)/p, decimalPlace)))
			}

			return (this.Set(Ceil(this[0]), Ceil(this[1])))
		}
		catch TypeError {
			throw (TypeError("``decimalPlace`` is invalid.", -1, "This parameter must be a Number."))
		}
	}

	Floor(decimalPlace := False) {
		try {
			if (decimalPlace) {
				p := 10**decimalPlace

				return (this.Set(Round(Floor(this[0]*p)/p, decimalPlace), Round(Floor(this[1]*p)/p, decimalPlace)))
			}

			return (this.Set(Floor(this[0]), Floor(this[1])))
		}
		catch TypeError {
			throw (TypeError("``decimalPlace`` is invalid.", -1, "This parameter must be a Number."))
		}
	}

	Fix(decimalPlace := False) {
		try {
			x := this[0], y := this[1]

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
				? (this.Set(Round(this[0], decimalPlace), Round(this[1], decimalPlace)))
				: (this.Set(Round(this[0]), Round(this[1]))))
		}
		catch TypeError {
			throw (TypeError("``decimalPlace`` is invalid.", -1, "This parameter must be a Number."))
		}
	}

	Min(vector) {
		try {
			return (this.Set(Min(this[0], vector[0]), Min(this[1], vector[1])))
		}
		catch IndexError {
			throw (TypeError("``vector`` is invalid.", -1, "This parameter must be an Array with two elements."))
		}
	}

	Max(vector) {
		try {
			return (this.Set(Max(this[0], vector[0]), Max(this[1], vector[1])))
		}
		catch IndexError {
			throw (TypeError("``vector`` is invalid.", -1, "This parameter must be an Array with two elements."))
		}
	}
}