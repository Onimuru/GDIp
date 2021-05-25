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
	"Vec2.ahk",
	"Math.ahk"] {
	GroupAdd("Library", v)
}

;======================================================== Test ================;
;-------------------------------------------------------  __New  ---------------;
Assert.SetLabel("__New")

Assert.IsEqual(Vec2(), {x: 0, y: 0})
Assert.IsEqual(Vec2(1, 1), {x: 1, y: 1})

;-------------------------------------------------------  Clone  ---------------;
Assert.SetLabel("Clone")

Assert.IsEqual(Vec2(1, 2).Clone(), {x: 1, y: 2})

;------------------------------------------------------- Equals ---------------;
Assert.SetLabel("Equals")

Assert.IsFalse(Vec2.Equals(Vec2(2, 1), {x: 2, y: 1}))
Assert.IsTrue(Vec2.Equals(Vec2(2, 1), Vec2(2, 1)))

;------------------------------------------------------- Divide ---------------;
Assert.SetLabel("Divide")

Assert.IsEqual(Vec2.Divide(Vec2(2, 2), {x: 2, y: 2}), {x: 1, y: 1})
Assert.IsEqual(Vec2.Divide(Vec2(50, 50), Vec2(2, 5)), {x: 25, y: 10})

Assert.IsEqual(Vec2(50, 50).Divide(Vec2(2, 5)), {x: 25, y: 10})
Assert.IsEqual(Vec2(50, 50).DivideScalar(10), {x: 5, y: 5})

;------------------------------------------------------ Multiply --------------;
Assert.SetLabel("Multiply")

Assert.IsEqual(Vec2.Multiply(Vec2(2, 2), {x: 2, y: 2}), {x: 4, y: 4})
Assert.IsEqual(Vec2.Multiply(Vec2(9, 3), Vec2(3, -1)), {x: 27, y: -3})

Assert.IsEqual(Vec2(50, 50).Multiply(Vec2(2, 1)), {x: 100, y: 50})
Assert.IsEqual(Vec2(50, 50).MultiplyScalar(10), {x: 500, y: 500})

;--------------------------------------------------------  Add  ----------------;
Assert.SetLabel("Add")

Assert.IsEqual(Vec2.Add(Vec2(2, 2), {x: 2, y: 2}), {x: 4, y: 4})
Assert.IsEqual(Vec2.Add(Vec2(1, 3), Vec2(2, -2)), {x: 3, y: 1})
Assert.IsEqual(Vec2.AddScalar(Vec2(1, 3), -2), {x: -1, y: 1})

Assert.IsEqual(Vec2(1, 3).Add(Vec2(2, -2)), {x: 3, y: 1})
Assert.IsEqual(Vec2(1, 3).AddScalar(-2), {x: -1, y: 1})

;------------------------------------------------------ Subtract --------------;
Assert.SetLabel("Subtract")

Assert.IsEqual(Vec2.Subtract(Vec2(2, 2), {x: 2, y: 2}), {x: 0, y: 0})
Assert.IsEqual(Vec2.Subtract(Vec2(1, 3), Vec2(2, -7)), {x: -1, y: 10})

Assert.IsEqual(Vec2(2, 2).Subtract({x: 2, y: 2}), {x: 0, y: 0})
Assert.IsEqual(Vec2(1, 3).SubtractScalar(2), {x: -1, y: 1})

;------------------------------------------------------ Distance --------------;
Assert.SetLabel("Distance")

Assert.IsEqual(Vec2.Distance(Vec2(10, 5), Vec2(11, 7)), 2.23606797749979)

;--------------------------------------------------  Distancesquared  ----------;
Assert.SetLabel("DistanceSquared")

Assert.IsEqual(Vec2.DistanceSquared(Vec2(1, 1), Vec2(3, 2)), 5)

;-------------------------------------------------------  Cross  ---------------;
Assert.SetLabel("Cross")

Assert.IsEqual(Vec2.Cross(Vec2(1, 1), Vec2(3, 2)), -1)
Assert.IsEqual(Vec2.Cross(Vec2(10, 5), Vec2(11, 7)), 15)

;--------------------------------------------------------  Dot  ----------------;
Assert.SetLabel("Dot")

Assert.IsEqual(Vec2.Dot(Vec2(1, 2), Vec2(3, 4)), 11)
Assert.IsEqual(Vec2.Dot(Vec2(10, 5), Vec2(11, 7)), 145)

;-----------------------------------------------------  Transform  -------------;
Assert.SetLabel("Transform")

Assert.IsEqual(Vec2.Transform(Vec2(50, 50), TransformMatrix(0.7071067811865569, 0.70710678118653814, -0.70710678118653814, 0.7071067811865569, 99.999999999998124, -41.42135623730951)), {x: 99.999999999999062, y: 29.289321881345245})  ;* 45° rotation matrix with `100, 100` translation.

Assert.IsEqual(Vec2(50, 50).Transform(TransformMatrix(0.7071067811865569, 0.70710678118653814, -0.70710678118653814, 0.7071067811865569, 99.999999999998124, -41.42135623730951)), {x: 99.999999999999062, y: 29.289321881345245})

;-------------------------------------------------------- Lerp ----------------;
Assert.SetLabel("Lerp")

Assert.IsEqual(Vec2.Lerp(Vec2(2, 1), Vec2(3, -2), 0.73), {x: 2.73, y: -1.19})

Assert.IsEqual(Vec2(2, 1).Lerp(Vec2(3, -2), 0.73), {x: 2.73, y: -1.19})

;-------------------------------------------------------  Clamp  ---------------;
Assert.SetLabel("Clamp")

Assert.IsEqual(Vec2.Clamp(Vec2(4, -2), Vec2(1, 1), Vec2(3, 3)), {x: 3, y: 1})

Assert.IsEqual(Vec2(4, -2).Clamp(Vec2(1, 1), Vec2(3, 3)), {x: 3, y: 1})

;----------------------------------------------------  ClampScalar  ------------;
Assert.SetLabel("ClampScalar")

Assert.IsEqual(Vec2(4, -2).ClampScalar(1, 3), {x: 3, y: 1})

;----------------------------------------------------  ClampLength  ------------;
Assert.SetLabel("ClampLength")

Assert.IsEqual(Vec2(4, -2).ClampLength(1, 3), {x: 2.6832815729997477, y: -1.3416407864998738})

;-------------------------------------------------------- Ceil ----------------;
Assert.SetLabel("Ceil")

Assert.IsEqual(Vec2(5.552345, -5.552345).Ceil(1), "{x: 5.6, y: -5.5}")

;-------------------------------------------------------  Floor  ---------------;
Assert.SetLabel("Floor")

Assert.IsEqual(Vec2(5.552345, -5.552345).Floor(1), "{x: 5.5, y: -5.6}")

;--------------------------------------------------------  Fix  ----------------;
Assert.SetLabel("Fix")

Assert.IsEqual(Vec2(5.552345, -5.552345).Fix(1), "{x: 5.5, y: -5.5}")

;-------------------------------------------------------  Round  ---------------;
Assert.SetLabel("Round")

Assert.IsEqual(Vec2(5.552345, -5.552345).Round(1), "{x: 5.6, y: -5.6}")

;--------------------------------------------------------  Min  ----------------;
Assert.SetLabel("Min")

Assert.IsEqual(Vec2.Min(Vec2(2, 1), Vec2(3, -2)), {x: 2, y: -2})

Assert.IsEqual(Vec2(2, 1).Min(Vec2(3, -2)), {x: 2, y: -2})

;--------------------------------------------------------  Max  ----------------;
Assert.SetLabel("Max")

Assert.IsEqual(Vec2.Max(Vec2(2, 1), Vec2(3, -2)), {x: 3, y: 1})

Assert.IsEqual(Vec2(2, 1).Max(Vec2(3, -2)), {x: 3, y: 1})

;------------------------------------------------------- Length ---------------;
Assert.SetLabel("Length")

Assert.IsEqual(Vec2(3, 4).Length, 5)

;---------------------------------------------------  LengthSquared  -----------;
Assert.SetLabel("LengthSquared")

Assert.IsEqual(Vec2(3, 4).LengthSquared, 25)

;-------------------------------------------------------- Copy ----------------;
Assert.SetLabel("Copy")

Assert.IsEqual(Vec2().Copy(Vec2(2, 5)), {x: 2, y: 5})

;--------------------------------------------------------  Set  ----------------;
Assert.SetLabel("Set")

Assert.IsEqual(Vec2(2, 1).Set(-3, 1), {x: -3, y: 1})
Assert.IsEqual(Vec2(2, 1).SetScalar(3), {x: 3, y: 3})

;------------------------------------------------------- Negate ---------------;
Assert.SetLabel("Negate")

Assert.IsEqual(Vec2(10, -5).Negate(), {x: -10, y: 5})

;-----------------------------------------------------  Normalize  -------------;
Assert.SetLabel("Normalize")

Assert.IsEqual(Vec2(10, 5).Normalize(), {x: 0.8944271909999159, y: 0.44721359549995793})
Assert.IsEqual(Vec2(10, 5).Normalize().Length, 0.9999999999999999)

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