/*
;* enum MatrixOrder  ;: https://docs.microsoft.com/en-us/windows/win32/api/gdiplusenums/ne-gdiplusenums-matrixorder
	0 = MatrixOrderPrepend
	1 = MatrixOrderAppend
*/

;* GDIp.CreateMatrix([m11, m12, m21, m22, dx, dy])
;* Return:
	;* [Matrix]
static CreateMatrix(m11 := 1, m12 := 0, m21 := 0, m22 := 1, dx := 0, dy := 0) {
	if (status := DllCall("Gdiplus\GdipCreateMatrix2", "Float", m11, "Float", m12, "Float", m21, "Float", m22, "Float", dx, "Float", dy, "Ptr*", &(pMatrix := 0), "Int")) {
		throw (ErrorFromStatus(status))
	}

	(instance := this.Matrix()).Ptr := pMatrix
	return (instance)
}

/*
** Matrix Class: https://docs.microsoft.com/en-us/dotnet/api/system.drawing.drawing2d.matrix?view=net-5.0. **
*/

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
	;* Return:
		;* [Integer]
	IsIdentityMatrix() {
		if (status := DllCall("Gdiplus\GdipIsMatrixIdentity", "Ptr", this.Ptr, "UInt*", &(bool := False), "Int")) {
			throw (ErrorFromStatus(status))
		}

		return (bool)
	}

	IsInvertible {
		Get {
			return (this.IsInvertible())  ;* Determinant does not equal 0.
		}
	}

	;* matrix.IsInvertible()
	;* Return:
		;* [Integer]
	IsInvertible() {
		if (status := DllCall("Gdiplus\GdipIsMatrixInvertible", "Ptr", this.Ptr, "UInt*", &(bool := False), "Int")) {
			throw (ErrorFromStatus(status))
		}

		return (bool)
	}

	;--------------- Method -------------------------------------------------------;

	;* matrix.Set(m11, m12, m21, m22, m31, m32)
	;* Parameter:
		;* [Float] m11
		;* [Float] m12
		;* [Float] m21
		;* [Float] m22
		;* [Float] m31
		;* [Float] m32
	Set(m11, m12, m21, m22, m31, m32) {
		if (status := DllCall("Gdiplus\GdipSetMatrixElements", "Ptr", this.Ptr, "Float", m11, "Float", m12, "Float", m21, "Float", m22, "Float", m31, "Float", m32, "Int")) {
			throw (ErrorFromStatus(status))
		}
	}

	;* matrix.SetIdentity()
	SetIdentity() {
		if (status := DllCall("Gdiplus\GdipResetMatrix", "Ptr", this.Ptr, "Int")) {
			throw (ErrorFromStatus(status))
		}
	}

	;* matrix.Multiply(matrix[, matrixOrder]) - Updates this matrix with the product of itself and another matrix.
	;* Parameter:
		;* [Matrix] matrix - See MatrixOrder enumeration.
		;* [Integer] matrixOrder - See MatrixOrder enumeration.
	Multiply(matrix, matrixOrder := 0) {
		if (status := DllCall("Gdiplus\GdipMultiplyMatrix", "Ptr", this.Ptr, "Ptr", matrix.Ptr, "Int", matrixOrder, "Int")) {
			throw (ErrorFromStatus(status))
		}
	}

	;* matrix.Invert() - If the matrix is invertible, this function replaces its elements  with the elements of its inverse.
	Invert() {
		if (status := DllCall("Gdiplus\GdipInvertMatrix", "Ptr", this.Ptr, "Int")) {
			throw (ErrorFromStatus(status))
		}
	}

	;* matrix.Rotate(angle[, matrixOrder]) - Updates this matrix with the product of itself and a rotation matrix.
	;* Parameter:
		;* [Float] angle - Simple precision value that specifies the angle of rotation (in degrees). Positive values specify clockwise rotation.
		;* [Integer] matrixOrder - See MatrixOrder enumeration.
	Rotate(angle, matrixOrder := 0) {
		if (status := DllCall("Gdiplus\GdipRotateMatrix", "Ptr", this.Ptr, "Float", angle, "Int", matrixOrder, "Int")) {
			throw (ErrorFromStatus(status))
		}
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
	}
}