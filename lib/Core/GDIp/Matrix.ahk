;* GDIp.CreateMatrix()
;* Return:
	;* [Matrix]
static CreateMatrix() {
	if (status := DllCall("Gdiplus\GdipCreateMatrix", "Ptr*", &(pMatrix := 0), "Int")) {
		throw (ErrorFromStatus(status))
	}

	(instance := this.Matrix()).Ptr := pMatrix
	return (instance)
}

class Matrix {
	Class := "Matrix"

	;* matrix.Clone()
	;* Return:
		;* [Matrix]
	Clone() {
		if (status := DllCall("Gdiplus\GdipCloneMatrix", "Ptr", this.Ptr, "Ptr*", &(pMatrix := 0), "Int")) {
			throw (ErrorFromStatus(status))
		}

		(instance := GDIp.Matrix()).Ptr := pMatrix
		return (instance)
	}

	__Delete() {
		if (status := DllCall("Gdiplus\GdipDeleteMatrix", "Ptr", this.Ptr, "Int")) {
			throw (ErrorFromStatus(status))
		}
	}

	;-------------- Property ------------------------------------------------------;

	IsIdentityMatrix {
		Get {
			return (this.IsIdentityMatrix())
		}
	}

	;* matrix.IsIdentityMatrix()
	IsIdentityMatrix() {
		if (status := DllCall("Gdiplus\GdipIsMatrixIdentity", "Ptr", this.Ptr, "UInt*", &(bool := 0), "Int")) {
			throw (ErrorFromStatus(status))
		}

		return (bool)
	}

	IsInvertible {
		Get {
			return (this.IsInvertible())
		}
	}

	;* matrix.IsInvertible()
	IsInvertible() {
		if (status := DllCall("Gdiplus\GdipIsMatrixInvertible", "Ptr", this.Ptr, "UInt*", &(bool := 0), "Int")) {
			throw (ErrorFromStatus(status))
		}

		return (bool)
	}

	;--------------- Method -------------------------------------------------------;  ;~ REAL is a typedef for a float.

	;* matrix.Invert() - If the matrix is invertible, this function replaces its elements  with the elements of its inverse.
	Invert() {
		if (status := DllCall("Gdiplus\GdipInvertMatrix", "Ptr", this.Ptr, "Int")) {
			throw (ErrorFromStatus(status))
		}

		return (True)
	}

	;* matrix.Translate(x, y[, matrixOrder]) - Updates this matrix with the product of itself and a scaling matrix.
	;* Parameter:
		;* [Float] x - Single precision value that specifies the horizontal component of the translation.
		;* [Float] y - Single precision value that specifies the vertical component of the translation.
		;* [Integer] matrixOrder - See MatrixOrder enumeration.
	Translate(x, y, matrixOrder := 0) {
		if (status := DllCall("Gdiplus\GdipTranslateMatrix", "Ptr", this.Ptr, "Float", x, "Float", y, "Int", matrixOrder, "Int")) {
			throw (ErrorFromStatus(status))
		}

		return (True)
	}

	;* matrix.Rotate(angle[, matrixOrder]) - Updates this matrix with the product of itself and a rotation matrix.
	;* Parameter:
		;* [Float] angle - Simple precision value that specifies the angle of rotation in degrees. Positive values specify clockwise rotation.
		;* [Integer] matrixOrder - See MatrixOrder enumeration.
	Rotate(angle, matrixOrder := 0) {
		if (status := DllCall("Gdiplus\GdipRotateMatrix", "Ptr", this.Ptr, "Float", angle, "Float", matrixOrder, "Int")) {
			throw (ErrorFromStatus(status))
		}

		return (True)
	}

	;* matrix.Multiply(matrix[, matrixOrder]) - Updates this matrix with the product of itself and another matrix.
	;* Parameter:
		;* [Matrix] matrix - See MatrixOrder enumeration.
		;* [Integer] matrixOrder - See MatrixOrder enumeration.
	Multiply(matrix, matrixOrder := 0) {
		if (status := DllCall("Gdiplus\GdipMultiplyMatrix", "Ptr", this.Ptr, "Ptr", matrix.Ptr, "Int", matrixOrder, "Int")) {
			throw (ErrorFromStatus(status))
		}

		return (True)
	}

	;* matrix.Scale(x, y[, matrixOrder]) - Updates this matrix with the product of itself and a scaling matrix.
	;* Parameter:
		;* [Float] x - Simple precision value that specifies the horizontal scale factor.
		;* [Float] y - Simple precision value that specifies the vertical scale factor.
		;* [Integer] matrixOrder - See MatrixOrder enumeration.
	Scale(x, y, matrixOrder := 0) {
		if (status := DllCall("Gdiplus\GdipScaleMatrix", "Ptr", this.Ptr, "Float", x, "Float", y, "Int", matrixOrder, "Int")) {
			throw (ErrorFromStatus(status))
		}

		return (True)
	}

	;* matrix.Shear(x, y[, matrixOrder]) - Updates this matrix with the product of itself and a shearing matrix.
	;* Parameter:
		;* [Float] x - Simple precision value that specifies the horizontal shear factor.
		;* [Float] y - Simple precision value that specifies the vertical shear factor.
		;* [Integer] matrixOrder - See MatrixOrder enumeration.
	Shear(x, y, matrixOrder := 0) {
		if (status := DllCall("Gdiplus\GdipShearMatrix", "Ptr", this.Ptr, "Float", x, "Float", y, "Int", matrixOrder, "Int")) {
			throw (ErrorFromStatus(status))
		}

		return (True)
	}

	;* matrix.Reset()
	Reset() {
		if (status := DllCall("gdiplus\GdipResetMatrix", "Ptr", this.Ptr, "Int")) {
			throw (ErrorFromStatus(status))
		}

		return (True)
	}
}