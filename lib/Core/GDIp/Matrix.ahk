/*
* MIT License
*
* Copyright (c) 2021 Onimuru
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in all
* copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
* SOFTWARE.
*/

/*
;* enum MatrixOrder  ;: https://docs.microsoft.com/en-us/windows/win32/api/gdiplusenums/ne-gdiplusenums-matrixorder
	0 = MatrixOrderPrepend
	1 = MatrixOrderAppend
*/

;* GDIp.CreateMatrix([m11, m12, m21, m22, m31, m32])
;* Return:
	;* [Matrix]
static CreateMatrix(m11 := 1, m12 := 0, m21 := 0, m22 := 1, m31 := 0, m32 := 0) {
	if (status := DllCall("Gdiplus\GdipCreateMatrix2", "Float", m11, "Float", m12, "Float", m21, "Float", m22, "Float", m31, "Float", m32, "Ptr*", &(pMatrix := 0), "Int")) {
		throw (ErrorFromStatus(status))
	}

	return (this.Matrix(pMatrix))
}

/*
** Matrix Class: https://docs.microsoft.com/en-us/dotnet/api/system.drawing.drawing2d.matrix?view=net-5.0. **
*/

class Matrix {
	Class := "Matrix"

	__New(pMatrix) {
		this.Ptr := pMatrix
	}

	;* matrix.Clone()
	;* Return:
		;* [Matrix]
	Clone() {
		if (status := DllCall("Gdiplus\GdipCloneMatrix", "Ptr", this.Ptr, "Ptr*", &(pMatrix := 0), "Int")) {
			throw (ErrorFromStatus(status))
		}

		return (GDIp.Matrix(pMatrix))
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
			return (this.IsInvertible())
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

	static Equals(matrix1, matrix2) {
		if (status := DllCall("Gdiplus\GdipIsMatrixEqual", "Ptr", matrix1, "Ptr", matrix2, "Int*", &(bool := 0), "Int")) {
			throw (ErrorFromStatus(status))
		}

		return (bool)
	}

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

		return (this)
	}

	;* matrix.SetIdentity()
	SetIdentity() {
		if (status := DllCall("Gdiplus\GdipResetMatrix", "Ptr", this.Ptr, "Int")) {
			throw (ErrorFromStatus(status))
		}

		return (this)
	}

	;* matrix.Multiply(matrix[, matrixOrder])
	;* Description:
		;* Updates this matrix with the product of itself and another matrix.
	;* Parameter:
		;* [Matrix] matrix - See MatrixOrder enumeration.
		;* [Integer] matrixOrder - See MatrixOrder enumeration.
	Multiply(matrix, matrixOrder := 0) {
		if (status := DllCall("Gdiplus\GdipMultiplyMatrix", "Ptr", this.Ptr, "Ptr", matrix, "Int", matrixOrder, "Int")) {
			throw (ErrorFromStatus(status))
		}

		return (this)
	}

	;* matrix.Invert()
	;* Description:
		;* If the matrix is invertible, this function replaces its elements  with the elements of its inverse.
	Invert() {
		if (status := DllCall("Gdiplus\GdipInvertMatrix", "Ptr", this.Ptr, "Int")) {
			throw (ErrorFromStatus(status))
		}

		return (this)
	}

	;* matrix.Rotate(angle[, matrixOrder])
	;* Description:
		;* Updates this matrix with the product of itself and a rotation matrix.
	;* Parameter:
		;* [Float] angle - Simple precision value that specifies the angle of rotation (in degrees). Positive values specify clockwise rotation.
		;* [Integer] matrixOrder - See MatrixOrder enumeration.
	Rotate(angle, matrixOrder := 0) {
		if (status := DllCall("Gdiplus\GdipRotateMatrix", "Ptr", this.Ptr, "Float", angle, "Int", matrixOrder, "Int")) {
			throw (ErrorFromStatus(status))
		}

		return (this)
	}

	;* matrix.RotateWithTranslation(angle, dx, dy[, matrixOrder])
	;* Parameter:
		;* [Float] angle - Simple precision value that specifies the angle of rotation (in degrees). Positive values specify clockwise rotation.
		;* [Float] dx
		;* [Float] dy
		;* [Integer] matrixOrder - See MatrixOrder enumeration.
	RotateWithTranslation(angle, dx, dy, matrixOrder := 0) {
		theta := angle*0.017453292519943
			, c := Cos(theta), s := Sin(theta)

		static matrix := Structure(24)

		if (status := DllCall("Gdiplus\GdipGetMatrixElements", "Ptr", this.Ptr, "Ptr", matrix.Ptr, "Int")) {
			throw (ErrorFromStatus(status))
		}

		if (matrixOrder) {
			a11 := matrix.NumGet(0, "Float"), a12 := matrix.NumGet(4, "Float"), a21 := matrix.NumGet(8, "Float"), a22 := matrix.NumGet(12, "Float"), a31 := matrix.NumGet(16, "Float"), a32 := matrix.NumGet(20, "Float")

			return (this.Set(a11*c + a12*-s, a11*s + a12*c, a21*c + a22*-s, a21*s + a22*c, a31*c + a32*-s + dx*(1 - c) + dy*s, a31*s + a32*c - dx*s + dy*(1 - c)))
		}
		else {
			b11 := matrix.NumGet(0, "Float"), b12 := matrix.NumGet(4, "Float"), b21 := matrix.NumGet(8, "Float"), b22 := matrix.NumGet(12, "Float")

			return (this.Set(c*b11 + s*b21, c*b12 + s*b22, -s*b11 + c*b21, -s*b12 + c*b22, matrix.NumGet(16, "Float") + dx*(1 - c) + dy*s, matrix.NumGet(20, "Float") - dx*s + dy*(1 - c)))
		}
	}

	;* matrix.Scale(x, y[, matrixOrder])
	;* Description:
		;* Updates this matrix with the product of itself and a scaling matrix.
	;* Parameter:
		;* [Float] x - Simple precision value that specifies the horizontal scale factor.
		;* [Float] y - Simple precision value that specifies the vertical scale factor.
		;* [Integer] matrixOrder - See MatrixOrder enumeration.
	Scale(x, y, matrixOrder := 0) {
		if (status := DllCall("Gdiplus\GdipScaleMatrix", "Ptr", this.Ptr, "Float", x, "Float", y, "Int", matrixOrder, "Int")) {
			throw (ErrorFromStatus(status))
		}

		return (this)
	}

	;* matrix.ScaleWithTranslation(sx, sy, dx, dy[, matrixOrder])
	;* Parameter:
		;* [Float] sx
		;* [Float] sy
		;* [Float] dx
		;* [Float] dy
		;* [Integer] matrixOrder - See MatrixOrder enumeration.
	ScaleWithTranslation(sx, sy, dx, dy, matrixOrder := 0) {
		static matrix := Structure(24)

		if (status := DllCall("Gdiplus\GdipGetMatrixElements", "Ptr", this.Ptr, "Ptr", matrix.Ptr, "Int")) {
			throw (ErrorFromStatus(status))
		}

		if (matrixOrder) {
			return (this.Set(matrix.NumGet(0, "Float")*sx, matrix.NumGet(4, "Float")*sy, matrix.NumGet(8, "Float")*sx, matrix.NumGet(12, "Float")*sy, matrix.NumGet(16, "Float")*sx + dx*(1 - sx), matrix.NumGet(20, "Float")*sy + dy*(1 - sy)))
		}
		else {
			b11 := matrix.NumGet(0, "Float"), b12 := matrix.NumGet(4, "Float"), b21 := matrix.NumGet(8, "Float"), b22 := matrix.NumGet(12, "Float")

			return (this.Set(sx*b11, sx*b12, sy*b21, sy*b22, dx*(1 - sx)*b11 + dy*(1 - sy)*b21 + matrix.NumGet(16, "Float"), dx*(1 - sx)*b12 + dy*(1 - sy)*b22 + matrix.NumGet(20, "Float")))
		}
	}

	;* matrix.Shear(x, y[, matrixOrder])
	;* Description:
		;* Updates this matrix with the product of itself and a shearing matrix.
	;* Parameter:
		;* [Float] x - Simple precision value that specifies the horizontal shear factor.
		;* [Float] y - Simple precision value that specifies the vertical shear factor.
		;* [Integer] matrixOrder - See MatrixOrder enumeration.
	Shear(x, y, matrixOrder := 0) {
		if (status := DllCall("Gdiplus\GdipShearMatrix", "Ptr", this.Ptr, "Float", x, "Float", y, "Int", matrixOrder, "Int")) {
			throw (ErrorFromStatus(status))
		}

		return (this)
	}

	;* matrix.Translate(x, y[, matrixOrder])
	;* Description:
		;* Updates this matrix with the product of itself and a scaling matrix.
	;* Parameter:
		;* [Float] x - Single precision value that specifies the horizontal component of the translation.
		;* [Float] y - Single precision value that specifies the vertical component of the translation.
		;* [Integer] matrixOrder - See MatrixOrder enumeration.
	Translate(x, y, matrixOrder := 0) {
		if (status := DllCall("Gdiplus\GdipTranslateMatrix", "Ptr", this.Ptr, "Float", x, "Float", y, "Int", matrixOrder, "Int")) {
			throw (ErrorFromStatus(status))
		}

		return (this)
	}
}