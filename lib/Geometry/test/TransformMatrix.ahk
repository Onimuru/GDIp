;============ Auto-execute ====================================================;
;======================================================  Setting  ==============;

#SingleInstance
#Warn All, MsgBox
#Warn LocalSameAsGlobal, Off

ListLines(False)
SetWorkingDir(A_ScriptDir . "\..\..\..")

;==============  Include  ======================================================;

#Include %A_ScriptDir%\..\..\Assert\Assert.ahk
#Include %A_ScriptDir%\..\..\Console\Console.ahk

#Include %A_ScriptDir%\..\..\Geometry.ahk
#Include %A_ScriptDir%\..\..\Math\Math.ahk

;======================================================== Menu ================;

TraySetIcon(A_WorkingDir . "\res\Image\Icon\0.ico")

;=======================================================  Group  ===============;

for i, v in [
	"TransformMatrix.ahk",
	"Math.ahk"] {
	GroupAdd("Library", v)
}

;======================================================== Test ================;
;-------------------------------------------------------  __New  ---------------;
Assert.SetLabel("__New")

Assert.IsEqual(TransformMatrix(), "[1, 0, 0, 0, 1, 0, 0, 0, 1]")
Assert.IsEqual(TransformMatrix(0, 1, 3, 4, 6, 7), "[0, 1, 0, 3, 4, 0, 6, 7, 1]")

;------------------------------------------------------- Equals ---------------;
Assert.SetLabel("Equals")

Assert.IsFalse(TransformMatrix.Equals(TransformMatrix(), "[1, 0, 0, 0, 1, 0, 0, 0, 1]"))
Assert.IsTrue(TransformMatrix.Equals(TransformMatrix(0, 1, 3, 4, 6, 7), TransformMatrix(0, 1, 3, 4, 6, 7)))

;------------------------------------------------------ Multiply --------------;
Assert.SetLabel("Multiply")

Assert.IsEqual(TransformMatrix.Multiply(TransformMatrix(0, 1, 3, 4, 50, 50), TransformMatrix(5, 6, 8, 9, 25, 85)), "[8, 9, 0, 47, 54, 0, 675, 835, 1]")
Assert.IsEqual(TransformMatrix(0, 1, 3, 4, 50, 50).Multiply(TransformMatrix(5, 6, 8, 9, 25, 85), True), "[8, 9, 0, 47, 54, 0, 675, 835, 1]")
Assert.IsEqual(TransformMatrix(0, 1, 3, 4, 50, 50).Multiply(TransformMatrix(5, 6, 8, 9, 25, 85)), "[18, 29, 0, 27, 44, 0, 305, 415, 1]")

;----------------------------------------------------  Determinant  ------------;
Assert.SetLabel("Determinant")

Assert.IsEqual(TransformMatrix.Determinant(TransformMatrix(0)), 0)
Assert.IsEqual(TransformMatrix.Determinant(TransformMatrix(2)), 2)
Assert.IsEqual(TransformMatrix.Determinant(TransformMatrix(0, 1, 3, 4, 50, 50)), -3)

;------------------------------------------------------- Invert ---------------;
Assert.SetLabel("Invert")

Assert.IsEqual(TransformMatrix.Invert(TransformMatrix(0, 1, 3, 4)), "[-1.3333333333333333, 0.33333333333333331, 0, 1, -0, 0, -0, -0, 1]")
Assert.IsEqual(TransformMatrix(0, 1, 3, 4, 5, 5).Invert(), TransformMatrix.Invert(TransformMatrix(0, 1, 3, 4, 5, 5)))

;------------------------------------------------------- Rotate ---------------;
Assert.SetLabel("Rotate")

Assert.IsEqual(TransformMatrix.Rotate(TransformMatrix(0, 1, 3, 4), Math.ToRadians(45), True), "[-0.70710678118653814, 0.7071067811865569, 0, -0.70710678118648174, 4.9497474683058424, 0, 0, 0, 1]")
Assert.IsEqual(TransformMatrix(0, 1, 3, 4).Rotate(Math.ToRadians(45), True), "[-0.70710678118653814, 0.7071067811865569, 0, -0.70710678118648174, 4.9497474683058424, 0, 0, 0, 1]")

;-------------------------------------------------------  Scale  ---------------;
Assert.SetLabel("Scale")

Assert.IsEqual(TransformMatrix.Scale(TransformMatrix(5, 1, 3, 4), 1, 2.5), TransformMatrix(5, 1, 3, 4).Scale(1, 2.5))
Assert.IsEqual(TransformMatrix.Scale(TransformMatrix(5, 1, 3, 4), 1, 2.5, True), TransformMatrix(5, 1, 3, 4).Scale(1, 2.5, True))
Assert.IsEqual(TransformMatrix(5, 1, 3, 4).Scale(1, 2.5), "[5, 1, 0, 7.5, 10, 0, 0, 0, 1]")
Assert.IsEqual(TransformMatrix(5, 1, 3, 4).Scale(1, 2.5, True), "[5, 2.5, 0, 3, 10, 0, 0, 0, 1]")

;-------------------------------------------------------  Shear  ---------------;
Assert.SetLabel("Shear")

Assert.IsEqual(TransformMatrix.Shear(TransformMatrix(0, 1, 3, 4), 0.85, 1), "[3, 5, 0, 3, 4.8499999999999996, 0, 0, 0, 1]")
Assert.IsEqual(TransformMatrix(0, 1, 3, 4).Shear(0.85, 1), TransformMatrix.Shear(TransformMatrix(0, 1, 3, 4), 0.85, 1))
Assert.IsEqual(TransformMatrix(0, 1, 3, 4).Shear(0.85, 1, True), "[0.84999999999999998, 1, 0, 6.4000000000000004, 7, 0, 0, 0, 1]")

;-----------------------------------------------------  Translate  -------------;
Assert.SetLabel("Translate")

Assert.IsEqual(TransformMatrix.Translate(TransformMatrix(0, 1, 3, 4), 125, -25), TransformMatrix(0, 1, 3, 4).Translate(125, -25))
Assert.IsEqual(TransformMatrix.Translate(TransformMatrix(0, 1, 3, 4), 125, -25, True), TransformMatrix(0, 1, 3, 4).Translate(125, -25, True))
Assert.IsEqual(TransformMatrix(0, 1, 3, 4).Translate(125, -25), "[0, 1, 0, 3, 4, 0, -75, 25, 1]")
Assert.IsEqual(TransformMatrix(0, 1, 3, 4).Translate(125, -25, True), "[0, 1, 0, 3, 4, 0, 125, -25, 1]")

;----------------------------------------------------- IsIdentity -------------;
Assert.SetLabel("IsIdentity")

Assert.IsTrue(TransformMatrix().IsIdentity)
Assert.IsTrue(TransformMatrix(0).SetIdentity().IsIdentity)
Assert.IsFalse(TransformMatrix(0).IsIdentity)

;---------------------------------------------------- IsInvertible ------------;
Assert.SetLabel("IsInvertible")

Assert.IsTrue(TransformMatrix(2, 7, 2, 11).IsInvertible)
Assert.IsTrue(TransformMatrix(-8, -3, 24, 2).IsInvertible)
Assert.IsFalse(TransformMatrix(-5, -25, 1, 5).IsInvertible)

;---------------------------------------------  Composite Transformations  -----;

matrix := TransformMatrix()

theta := Math.ToRadians(125)
	, c := Cos(theta), s := Sin(theta)

matrix.Scale(1, 0.5)
matrix.Translate(50, 0)
matrix.Rotate(theta, True)

Assert.IsEqual(matrix[0], c)
Assert.IsEqual(matrix[1], s)
Assert.IsEqual(matrix[3], -0.5*s)
Assert.IsEqual(matrix[4], 0.5*c)
Assert.IsEqual(matrix[6], 50*c)
Assert.IsEqual(matrix[7], 50*s)

matrix := TransformMatrix()

matrix.Rotate(Math.ToRadians(30), True)
matrix.Scale(1, 2, True)
matrix.Translate(5, 0, True)

Assert.IsEqual(matrix, "[0.86602540378444304, 0.99999999999998468, 0, -0.49999999999999234, 1.7320508075688861, 0, 5, 0, 1]")

;--------------------------------------------------------  Log  ----------------;

Console.Log(Assert.CreateReport())

exit

;=============== Hotkey =======================================================;

#HotIf (WinActive(A_ScriptName) || WinActive("ahk_group Library"))

	$F10:: {
		ListVars
	}

	~$^s:: {
		Critical(True)

		Sleep(200)
		Reload
	}

#HotIf