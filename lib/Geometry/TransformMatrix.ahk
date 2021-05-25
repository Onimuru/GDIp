class TransformMatrix extends Array {

	__New(m11 := 1, m12 := 0, m21 := 0, m22 := 1, m31 := 0, m32 := 0) {
		this.Push(m11, m12, 0, m21, m22, 0, m31, m32, 1)
	}

	Clone() {
		return (TransformMatrix(this[0], this[1], this[3], this[4], this[6], this[7]))
	}

	static Equals(matrix1, matrix2) {
		return (matrix1 is TransformMatrix && matrix2 is TransformMatrix && matrix1.Every((element, index, *) => (element == matrix2[index])))
	}

	static Multiply(matrix1, matrix2) {
		try {
			a11 := matrix1[0], a12 := matrix1[1], a21 := matrix1[3], a22 := matrix1[4], a31 := matrix1[6], a32 := matrix1[7]
		  , b11 := matrix2[0], b12 := matrix2[1], b21 := matrix2[3], b22 := matrix2[4], b31 := matrix2[6], b32 := matrix2[7]

			return (this(a11*b11 + a12*b21, a11*b12 + a12*b22, a21*b11 + a22*b21, a21*b12 + a22*b22, a31*b11 + a32*b21 + b31, a31*b12 + a32*b22 + b32))
		}
		catch IndexError {
			throw ((matrix1 is Array && matrix1.Length == 9)
				? (TypeError("``matrix2`` is invalid.", -1, "This parameter must be an Array."))
				: (TypeError("``matrix1`` is invalid.", -1, "This parameter must be an Array.")))
		}
	}

	;* Description:
		;* See https://en.wikipedia.org/wiki/Determinant.
	;* Note:
		;* If the determinant is zero, the matrix is singular as its vector components have the same slope and they're either parallel or they're on the same line.
	static Determinant(matrix) {
		try {
			return (matrix[0]*matrix[4] - matrix[3]*matrix[1])
		}
		catch IndexError {
			throw (TypeError("``matrix`` is invalid.", -1, "This parameter must be an Array."))
		}
	}

	static Invert(matrix) {
		try {
			m11 := matrix[0], m12 := matrix[1], m21 := matrix[3], m22 := matrix[4]

			if ((d := m11*m22 - m21*m12) == 0) {
				return (False)
			}

			m31 := matrix[6], m32 := matrix[7]

			return (this(m22/d, -m12/d, -m21/d, m11/d, (m21*m32 - m22*m31)/d, -(m11*m32 - m12*m31)/d))
		}
		catch IndexError {
			throw (TypeError("``matrix`` is invalid.", -1, "This parameter must be an Array."))
		}
	}

	static Rotate(matrix, theta, matrixOrder := 0) {
		try {
			c := Cos(theta), s := Sin(theta)

			if (matrixOrder) {
				a11 := matrix[0], a12 := matrix[1], a21 := matrix[3], a22 := matrix[4], a31 := matrix[6], a32 := matrix[7]

				return (this(a11*c + a12*-s, a11*s + a12*c, a21*c + a22*-s, a21*s + a22*c, a31*c + a32*-s, a31*s + a32*c))
			}
			else {
				b11 := matrix[0], b12 := matrix[1], b21 := matrix[3], b22 := matrix[4]

				return (this(c*b11 + s*b21, c*b12 + s*b22, -s*b11 + c*b21, -s*b12 + c*b22, matrix[6], matrix[7]))
			}
		}
		catch IndexError {
			throw (TypeError("``matrix`` is invalid.", -1, "This parameter must be an Array."))
		}
	}

	static RotateWithTranslation() {

	}

	static Scale(matrix, x, y, matrixOrder := 0) {
		try {
			if (matrixOrder) {
				return (this(matrix[0]*x, matrix[1]*y, matrix[3]*x, matrix[4]*y, matrix[6]*x, matrix[7]*y))
			}
			else {
				return (this(matrix[0]*x, matrix[1]*x, matrix[3]*y, matrix[4]*y, matrix[6], matrix[7]))
			}
		}
		catch IndexError {
			throw (TypeError("``matrix`` is invalid.", -1, "This parameter must be an Array."))
		}
	}

	static ScaleWithTranslation() {

	}

	static Shear(matrix, x, y, matrixOrder := 0) {
		try {
			if (matrixOrder) {
				a11 := matrix[0], a12 := matrix[1], a21 := matrix[3], a22 := matrix[4], a31 := matrix[6], a32 := matrix[7]

				return (this(a11 + a12*x, a11*y + a12, a21 + a22*x, a21*y + a22, a31 + a32*x, a31*y + a32))
			}
			else {
				b11 := matrix[0], b12 := matrix[1], b21 := matrix[3], b22 := matrix[4]

				return (this(b11 + y*b21, b12 + y*b22, x*b11 + b21, x*b12 + b22, matrix[6], matrix[7]))
			}
		}
		catch IndexError {
			throw (TypeError("``matrix`` is invalid.", -1, "This parameter must be an Array."))
		}
	}

	static Translate(matrix, x, y, matrixOrder := 0) {
		try {
			if (matrixOrder) {
				return (this(matrix[0], matrix[1], matrix[3], matrix[4], matrix[6] + x, matrix[7] + y))
			}
			else {
				b11 := matrix[0], b12 := matrix[1], b21 := matrix[3], b22 := matrix[4]

				return (this(b11, b12, b21, b22, x*b11 + y*b21 + matrix[6], x*b12 + y*b22 + matrix[7]))
			}
		}
		catch IndexError {
			throw (TypeError("``matrix`` is invalid.", -1, "This parameter must be an Array."))
		}
	}

	IsIdentity {
		Get {
			return (this[0] == 1 && this[1] == 0 && this[3] == 0 && this[4] == 1 && this[6] == 0 && this[7] == 0)
		}
	}

	IsInvertible {
		Get {
			return ((this[0]*this[4] - this[3]*this[1]) != 0)
		}
	}

	Copy(matrix) {
		switch (Type(matrix)) {
			case "TransformMatrix":
				return (this.Set(matrix[0], matrix[1], matrix[3], matrix[4], matrix[6], matrix[7]))
		}
	}

	Set(m11, m12, m21, m22, m31, m32) {
		this[0] := m11, this[1] := m12, this[3] := m21, this[4] := m22, this[6] := m31, this[7] := m32
		return (this)
	}

	SetIdentity() {
		return (this.Set(1, 0, 0, 1, 0, 0))
	}

	SetRotate(theta) {
		c := Cos(theta), s := Sin(theta)

		this[0] := c, this[1] := s, this[3] := -s, this[4] := c
		return (this)
	}

	SetRotateWithTranslation(theta, x, y) {
		c := Cos(theta), s := Sin(theta)

		return (this.Set(c, s, -s, c, x - x*c + y*s, y - x*s - y*c))
	}

	SetScale(x, y) {
		this[0] := x, this[4] := y
		return (this)
	}

	SetScaleWithTranslation(sx, sy, dx, dy) {
		this[0] := sx, this[4] := sy, this[6] := dx*(1 - sx), this[7] := dy*(1 - sy)
		return (this)
	}

	SetShear(x, y) {
		this[1] := y, this[3] := x
		return (this)
	}

	SetTranslate(x, y) {
		this[6] := x, this[7] := y
		return (this)
	}

	Multiply(matrix, matrixOrder := 0) {
		if (matrixOrder) {
			a11 := this[0], a12 := this[1], a21 := this[3], a22 := this[4], a31 := this[6], a32 := this[7]
		  , b11 := matrix[0], b12 := matrix[1], b21 := matrix[3], b22 := matrix[4], b31 := matrix[6], b32 := matrix[7]
		}
		else {
			a11 := matrix[0], a12 := matrix[1], a21 := matrix[3], a22 := matrix[4], a31 := matrix[6], a32 := matrix[7]
		  , b11 := this[0], b12 := this[1], b21 := this[3], b22 := this[4], b31 := this[6], b32 := this[7]
		}

		return (this.Set(a11*b11 + a12*b21, a11*b12 + a12*b22, a21*b11 + a22*b21, a21*b12 + a22*b22, a31*b11 + a32*b21 + b31, a31*b12 + a32*b22 + b32))
	}

	Invert() {
		m11 := this[0], m12 := this[1], m21 := this[3], m22 := this[4]

		if ((d := m11*m22 - m21*m12) == 0) {
			return (False)
		}

		m31 := this[6], m32 := this[7]

		return (this.Set(m22/d, -m12/d, -m21/d, m11/d, (m21*m32 - m22*m31)/d, -(m11*m32 - m12*m31)/d))
	}

	Rotate(theta, matrixOrder := 0) {
		c := Cos(theta), s := Sin(theta)

		; [ cos(θ)   sin(θ)   0]
		; [-sin(θ)   cos(θ)   0]
		; [   0         0     1]

		if (matrixOrder) {
			a11 := this[0], a12 := this[1], a21 := this[3], a22 := this[4], a31 := this[6], a32 := this[7]

			return (this.Set(a11*c + a12*-s, a11*s + a12*c, a21*c + a22*-s, a21*s + a22*c, a31*c + a32*-s, a31*s + a32*c))
		}
		else {
			b11 := this[0], b12 := this[1], b21 := this[3], b22 := this[4]

			return (this.Set(c*b11 + s*b21, c*b12 + s*b22, -s*b11 + c*b21, -s*b12 + c*b22, this[6], this[7]))
		}
	}

	;* RotateWithTranslation(theta, x, y[, matrixOrder])
	;* Description:
		;* Planar rotation about a point.
	RotateWithTranslation(theta, x, y, matrixOrder := 0) {
		c := Cos(theta), s := Sin(theta)

		; [          cos(θ)                      sin(θ)             0]
		; [         -sin(θ)                      cos(θ)             0]
		; [x*(1 - cos(θ)) + y*sin(θ)   -x*sin(θ) + y*(1 - cos(θ))   1]

		if (matrixOrder) {
			a11 := this[0], a12 := this[1], a21 := this[3], a22 := this[4], a31 := this[6], a32 := this[7]

			return (this.Set(a11*c + a12*-s, a11*s + a12*c, a21*c + a22*-s, a21*s + a22*c, a31*c + a32*-s + x*(1 - c) + y*s, a31*s + a32*c - x*s + y*(1 - c)))
		}
		else {
			b11 := this[0], b12 := this[1], b21 := this[3], b22 := this[4]

			return (this.Set(c*b11 + s*b21, c*b12 + s*b22, -s*b11 + c*b21, -s*b12 + c*b22, this[6] + x*(1 - c) + y*s, this[7] - x*s + y*(1 - c)))
		}
	}

	Scale(x, y, matrixOrder := 0) {
		; [x   0   0]
		; [0   y   0]
		; [0   0   1]

		if (matrixOrder) {
			this[0] *= x, this[1] *= y, this[3] *= x, this[4] *= y, this[6] *= x, this[7] *= y
			return (this)
		}
		else {
			this[0] *= x, this[1] *= x, this[3] *= y, this[4] *= y
			return (this)
		}
	}

	ScaleWithTranslation(sx, sy, dx, dy, matrixOrder := 0) {
		; [    sx             0        0]
		; [     0            sy        0]
		; [dx*(1 - sx)   dy*(1 - sy)   1]

		if (matrixOrder) {
			this[0] *= sx, this[1] *= sy, this[3] *= sx, this[4] *= sy, this[6] := this[6]*sx + dx*(1 - sx), this[7] := this[7]*sy + dy*(1 - sy)
			return (this)
		}
		else {
			b11 := this[0], b12 := this[1], b21 := this[3], b22 := this[4]

			return (this.Set(sx*b11, sx*b12, sy*b21, sy*b22, dx*(1 - sx)*b11 + dy*(1 - sy)*b21 + this[6], dx*(1 - sx)*b12 + dy*(1 - sy)*b22 + this[7]))
		}
	}

	Shear(x, y, matrixOrder := 0) {
		; [1   y   0]
		; [x   1   0]
		; [0   0   1]

		if (matrixOrder) {
			a11 := this[0], a21 := this[3], a31 := this[6]

			this[0] += this[1]*x, this[1] += a11*y, this[3] += this[4]*x, this[4] += a21*y, this[6] += this[7]*x, this[7] += a31*y
			return (this)
		}
		else {
			b21 := this[3], b22 := this[4]

			this[3] := x*this[0] + b21, this[4] := x*this[1] + b22, this[0] += y*b21, this[1] += y*b22
			return (this)
		}
	}

	Translate(x, y, matrixOrder := 0) {
		; [1   0   0]
		; [0   1   0]
		; [x   y   1]

		if (matrixOrder) {
		  	this[6] += x, this[7] += y
			return (this)
		}
		else {
			this[6] += x*this[0] + y*this[3], this[7] += x*this[1] + y*this[4]
			return (this)
		}
	}
}