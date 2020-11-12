;=====         Auto-execute         =========================;
;===============           Setting            ===============;

#Include, %A_ScriptDir%\..\..\..\lib\Color.ahk
#Include, %A_ScriptDir%\..\..\..\lib\General.ahk
#Include, %A_ScriptDir%\..\..\..\lib\ObjectOriented.ahk
#Include, %A_ScriptDir%\..\..\..\lib\Math.ahk
#Include, %A_ScriptDir%\..\..\..\lib\GDIp.ahk
#Include, %A_ScriptDir%\..\..\..\lib\Geometry.ahk

#KeyHistory 0
#NoEnv
#Persistent
#SingleInstance, Force

ListLines, Off
Process, Priority, , R
SetBatchLines, -1
SetWorkingDir, % A_ScriptDir . "\..\..\.."

;===============           Variable           ===============;

IniRead, vDebug, % A_WorkingDir . "\cfg\Settings.ini", Debug, Debug
Global vDebug
	, oCanvas := new GDIp.Canvas({"x": A_ScreenWidth - (150*2 + 50 + 10 + 1), "y": 50, "Width": 150*2 + 10, "Height": 150*2 + 10}, "-Caption +AlwaysOnTop +ToolWindow +OwnDialogs +E0x20")
		, oBrush := [new GDIp.Brush(), new GDIp.LineBrush(new Rectangle(5, 5, oCanvas.Rectangle.Width - 10, oCanvas.Rectangle.Height - 10), [Color.Random(), Color.Random()])]
		, oPen := [new GDIp.Pen(), new GDIp.Pen(oBrush[1])]

	, oObject := {"Rectangle": new Rectangle(5, 5, oCanvas.Rectangle.Width - 10, oCanvas.Rectangle.Height - 10)
		, "SpeedRatio": 1}

	, oMatrix3 := new Matrix3()
		, vTheta_x := 0, vTheta_y := 0, vTheta_z := 0, vOffset_z := 2

	, oCube := new Cube(1.0)

;===============            Other             ===============;

OnExit("Exit"), Update()

Exit

;=====            Hotkey            =========================;

#If (WinActive(A_ScriptName) || WinActive("GDIp.ahk") || WinActive("Geometry.ahk"))

	~$^s::
		Critical

		Sleep, 200
		Reload
		Return

	$F10::ListVars

#If

*!q::
*!a::
*!w::
*!s::
*!e::
*!d::
*!r::
*!f::
	Return

~$Esc::
	If (KeyWait("Esc", "T1")) {
		Exit()
	}

	Return

;=====           Function           =========================;

Exit() {
	Critical

	GDIp.Shutdown()
	ExitApp
}

Update() {
	Static __Step := [1/60*3.1415926535897932, 2*(1/60)]

	If (QueryPerformanceCounter_Passive()) {
		oCanvas.DrawRectangle(oPen[0], oObject.Rectangle)

		If (GetKeyState("Alt", "P")) {
			If (GetKeyState("q", "P")) {
				vTheta_x := Mod(vTheta_x + __Step[0], Math.Tau)
			}
			Else If (GetKeyState("a", "P")) {
				vTheta_x := Mod(vTheta_x - __Step[0], Math.Tau)
			}

			If (GetKeyState("w", "P")) {
				vTheta_y := Mod(vTheta_y + __Step[0], Math.Tau)
			}
			Else If (GetKeyState("s", "P")) {
				vTheta_y := Mod(vTheta_y - __Step[0], Math.Tau)
			}

			If (GetKeyState("e", "P")) {
				vTheta_z := Mod(vTheta_z + __Step[0], Math.Tau)
			}
			Else If (GetKeyState("d", "P")) {
				vTheta_z := Mod(vTheta_z - __Step[0], Math.Tau)
			}

			If (GetKeyState("r", "P")) {
				vOffset_z += __Step[1]
			}
			Else If (GetKeyState("f", "P")) {
				vOffset_z := Max(2, vOffset_z - __Step[1])
			}
		}

		o := []
			, oMatrix3 := Matrix3.Multiply(Matrix3.Multiply(Matrix3.RotateX(vTheta_x), Matrix3.RotateY(vTheta_y)), Matrix3.RotateZ(vTheta_z))

		For i, v in oCube.Vertices {
			v := Vector3.Transform(v, oMatrix3).Add({"x": 0, "y": 0, "z": vOffset_z})

			o[i] := ToScreenSpace.Transform(v)
		}

		For i, v in oCube.Indices {
			oCanvas.DrawLine(oPen[0], o[v[0]], o[v[1]])
		}

		oCanvas.Update()
	}

	SetTimer, Update, -1
}

;=====            Class             =========================;

Class ToScreenSpace {
	Static vWidth := 155.0000000000000000, vHeight := 155.0000000000000000  ;* Static vars are evaluated before `oCanvas` is created so these variables need to be changed manually.

	Transform(oVector3) {
		z := 1/oVector3.z

		oVector3.x := (oVector3.x*z + 1)*this.vWidth, oVector3.y := (-oVector3.y*z + 1)*this.vHeight

		Return, (oVector3)
	}
}

Class Cube {
	__New(vSize) {
		s := vSize/2.0

		Return, ({"Vertices": [new Vector3(-s, -s, -s), new Vector3(s, -s, -s), new Vector3(-s,  s, -s), new Vector3(s,  s, -s), new Vector3(-s, -s,  s), new Vector3(s, -s,  s), new Vector3(-s,  s,  s), new Vector3(s,  s,  s)]
			, "Indices": [[0, 1], [1, 3], [3, 2], [2, 0]
				, [0, 4], [1, 5], [3, 7], [2, 6]
				, [4, 5], [5, 7], [7, 6], [6, 4]]})
	}
}