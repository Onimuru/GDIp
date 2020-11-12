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
		, vTheta_x := 0, vTheta_y := 0, vTheta_z := 0

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

*$F1::
*$F2::
*$F3::
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
	Static __Step := 1/60*3.1415926535897932

	If (QueryPerformanceCounter_Passive()) {
		oCanvas.DrawRectangle(oPen[0], oObject.Rectangle)

		If (GetKeyState("F1", "P")) {
			vTheta_x := Mod(vTheta_x + __Step, Math.Tau)
		}

		If (GetKeyState("F2", "P")) {
			vTheta_y := Mod(vTheta_y + __Step, Math.Tau)
		}

		If (GetKeyState("F3", "P")) {
			vTheta_z := Mod(vTheta_z + __Step, Math.Tau)
		}

		o := []
			, oMatrix3 := Matrix3.Multiply(Matrix3.Multiply(Matrix3.RotateX(vTheta_x), Matrix3.RotateY(vTheta_y)), Matrix3.RotateZ(vTheta_z))

		For i, v in oCube.Vertices {
			v := Vector3.Transform(v, oMatrix3).Add({"x": 0, "y": 0, "z": 1})

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
		oVector3.x := (oVector3.x + 1)*this.vWidth, oVector3.y := (-oVector3.y + 1)*this.vHeight

		Return, (oVector3)
	}
}

Class Cube {
	__New(vSize) {
		s := vSize/2.0

		Return, ({"Vertices": [new Vector3(-s, -s, -s), new Vector3( s, -s, -s), new Vector3(-s,  s, -s), new Vector3( s,  s, -s), new Vector3(-s, -s,  s), new Vector3( s, -s,  s), new Vector3(-s,  s,  s), new Vector3( s,  s,  s)]
			, "Indices": [[0, 1], [1, 3], [3, 2], [2, 0]
				, [0, 4], [1, 5], [3, 7], [2, 6]
				, [4, 5], [5, 7], [7, 6], [6, 4]]})
	}
}

;Class Vector3 {
;
;	;* new Vector3(x [Number || Vector2 || Vector3], (y), (z))
;	__New(vX := 0, vY := "", vZ := "") {
;		If (Math.IsNumeric(vX)) {
;			If (Math.IsNumeric(vY)) {
;				If (Math.IsNumeric(vZ)) {
;					Return, ({"x": vX
;						, "y": vY
;						, "z": vZ
;
;						, "Base": this.__Vector3})
;				}
;
;				Return, ({"x": vX
;					, "y": vY
;					, "z": 0
;
;					, "Base": this.__Vector3})
;			}
;
;			Return, ({"x": vX
;				, "y": vX
;				, "z": vX
;
;				, "Base": this.__Vector3})
;		}
;
;		Return, ({"x": vX.x
;			, "y": vX.y
;			, "z": ((vX.z) ? (vX.z) : (((vY) ? (vY) : (0))))
;
;			, "Base": this.__Vector3})
;	}
;
;	;* Vector3.Multiply(v1 [Vector3], v2 [Vector3 || Number])
;	;* Description:
;		;* Multiply a vector by another vector or a scalar.
;	Multiply(oVector3a, oVector3b) {
;		If (IsObject(oVector3b)) {
;			Return, (new Vector3(oVector3a.x*oVector3b.x, oVector3a.y*oVector3b.y, oVector3a.z*oVector3b.z))
;		}
;
;		Return, (new Vector3(oVector3a.x*oVector3b, oVector3a.y*oVector3b, oVector3a.z*oVector3b))
;	}
;
;	;* Vector3.Divide(v1 [Vector3], v2 [Vector3 || Number])
;	;* Description:
;		;* Divide a vector by another vector or a scalar.
;	Divide(oVector3a, oVector3b) {
;		If (IsObject(oVector3b)) {
;			Return, (new Vector3(oVector3a.x/oVector3b.x, oVector3a.y/oVector3b.y, oVector3a.z/oVector3b.z))
;		}
;
;		Return, (new Vector3(oVector3a.x/oVector3b, oVector3a.y/oVector3b, oVector3a.z/oVector3b))
;	}
;
;	;* Vector3.Add(v1 [Vector3], v2 [Vector3 || Number])
;	;* Description:
;		;* Add to a vector another vector or a scalar.
;	Add(oVector3a, oVector3b) {
;		If (IsObject(oVector3b)) {
;			Return, (new Vector3(oVector3a.x + oVector3b.x, oVector3a.y + oVector3b.y, oVector3a.z + oVector3b.z))
;		}
;
;		Return, (new Vector3(oVector3a.x + oVector3b, oVector3a.y + oVector3b, oVector3a.z + oVector3b))
;	}
;
;	;* Vector3.Subtract(v1 [Vector3], v2 [Vector3 || Number])
;	;* Description:
;		;* Subtract from a vector another vector or scalar.
;	Subtract(oVector3a, oVector3b) {
;		If (IsObject(oVector3b)) {
;			Return, (new Vector3(oVector3a.x - oVector3b.x, oVector3a.y - oVector3b.y, oVector3a.z - oVector3b.z))
;		}
;
;		Return, (new Vector3(oVector3a.x - oVector3b, oVector3a.y - oVector3b, oVector3a.z - oVector3b))
;	}
;
;	;* Vector3.Clamp(v1 [Vector3], v2 [Vector3 || Number], v3 [Vector3 || Number])
;	;* Description:
;		;* Clamp a vector to the given minimum and maximum vectors or values.
;	;* Note:
;		;* Assumes `v2 < v3`.
;	;* Parameters:
;		;* v1:
;			;* Input vector.
;		;* v2:
;			;* Minimum vector or number.
;		;* v3:
;			;* Maximum vector or number.
;	Clamp(oVector3, oVector3Minimum, oVector3Maximum) {
;		If (IsObject(oVector3Minimum) && IsObject(oVector3Maximum)) {
;			Return, (new Vector3(Math.Max(oVector3Minimum.x, Math.Min(oVector3Maximum.x, oVector3.x)), Math.Max(oVector3Minimum.y, Math.Min(oVector3Maximum.y, oVector3.y)), Math.Max(oVector3Minimum.z, Math.Min(oVector3Maximum.z, oVector3.z))))
;		}
;
;		Return, (new Vector3(Math.Max(oVector3Minimum, Math.Min(oVector3Maximum, oVector3.x)), Math.Max(oVector3Minimum, Math.Min(oVector3Maximum, oVector3.y)), Math.Max(oVector3Minimum, Math.Min(oVector3Maximum, oVector3.z))))
;	}
;
;	;* Vector3.Cross(v1 [Vector3], v2 [Vector3])
;	;* Description:
;		;* Calculate the cross product of two vectors.
;	Cross(oVector3a, oVector3b) {
;		Return, (new Vector3(oVector3a.y*oVector3b.z - oVector3a.z*oVector3b.y, oVector3a.z*oVector3b.x - oVector3a.x*oVector3b.z, oVector3a.x*oVector3b.y - oVector3a.y*oVector3b.x))
;	}
;
;	;* Vector3.Distance(v1 [Vector3], v2 [Vector3])
;	;* Description:
;		;* Calculate the distance between two vectors.
;	Distance(oVector3a, oVector3b) {
;		Return, (Sqrt((oVector3a.x - oVector3b.x)**2 + (oVector3a.y - oVector3b.y)**2 + (oVector3a.z - oVector3b.z)**2))
;	}
;
;	;* Vector3.DistanceSquared(v1 [Vector3], v2 [Vector3])
;	DistanceSquared(oVector3a, oVector3b) {
;		Return, ((oVector3a.x - oVector3b.x)**2 + (oVector3a.y - oVector3b.y)**2 + (oVector3a.z - oVector3b.z)**2)
;	}
;
;	;* Vector3.Dot(v1 [Vector3], v2 [Vector3])
;	;* Description:
;		;* Calculate the dot product of two vectors.
;	Dot(oVector3a, oVector3b) {
;		Return, (oVector3a.x*oVector3b.x + oVector3a.y*oVector3b.y + oVector3a.z*oVector3b.z)
;	}
;
;	;* Vector3.Equals(v1 [Vector3], v2 [Vector3])
;	;* Description:
;		;* Indicates whether two vectors are equal.
;	Equals(oVector3a, oVector3b) {
;		Return, (oVector3a.x == oVector3b.x && oVector3a.y == oVector3b.y && oVector3a.z == oVector3b.z)
;	}
;
;	;* Vector3.Lerp(v1 [Vector3], v2 [Vector3], f [Number])
;	;* Description:
;		;* Returns a new vector that is the linear blend of the two given vectors.
;	;* Parameters:
;		;* v1:
;			;* The starting vector.
;		;* v2:
;			;* The vector to interpolate towards.
;		;* f:
;			;* Interpolation factor, typically in the closed interval [0, 1].
;	Lerp(oVector3a, oVector3b, vFactor) {
;		Return, (new Vector3(oVector3a.x + (oVector3b.x - oVector3a.x)*vFactor, oVector3a.y + (oVector3b.y - oVector3a.y)*vFactor, oVector3a.z + (oVector3b.z - oVector3a.z)*vFactor))
;	}
;
;	;* Vector3.Min(v1 [Vector3], v2 [Vector3])
;	Min(oVector3a, oVector3b) {
;		Return, (new Vector3(Math.Min(oVector3a.x, oVector3b.x), Math.Min(oVector3a.y, oVector3b.y), Math.Min(oVector3a.z, oVector3b.z)))
;	}
;
;	;* Vector3.Max(v1 [Vector3], v2 [Vector3])
;	Max(oVector3a, oVector3b) {
;		Return, (new Vector3(Math.Max(oVector3a.x, oVector3b.x), Math.Max(oVector3a.y, oVector3b.y), Math.Max(oVector3a.z, oVector3b.z)))
;	}
;
;	;* Vector3.Transform(v [Vector3], m [Matrix3])
;	Transform(oVector3, oMatrix3) {
;		x := oVector3.x, y := oVector3.y, z := oVector3.z
;			, m := oMatrix3.Elements
;
;		Return, (new Vector3(m[0]*x + m[3]*y + m[6]*z, m[1]*x + m[4]*y + m[7]*z, m[2]*x + m[5]*y + m[8]*z))
;	}
;
;	Class __Vector3 extends __Object {
;
;		__Get(vKey) {
;			Switch (vKey) {
;
;				;* Vector3.Length
;				;* Description:
;					;* Calculates the length (magnitude) of the vector.
;				Case "Length":
;					Return, (Sqrt(this.x**2 + this.y**2 + this.z**2))
;
;				;* Vector3.LengthSquared
;				Case "LengthSquared":
;					Return, (this.x**2 + this.y**2 + this.z**2)
;
;				;* Vector3[0 || 1 || 2]
;				Default:
;					If (Math.IsInteger(vKey)) {
;						Return, ([this.x, this.y, this.z][vKey])
;					}
;			}
;		}
;
;		__Set(vKey, vValue) {
;			Switch (vKey) {
;
;				;* Vector3.Length := Number
;				Case "Length":
;					Return, (this.normalize().multiply(vValue))
;
;				;* Vector3[0 || 1 || 2] := Number
;				Default:
;					switch (vKey) {
;						Case 0:
;							this.x := vValue
;						Case 1:
;							this.y := vValue
;						Case 2:
;							this.z := vValue
;					}
;					Return
;			}
;		}
;
;        Multiply(oVector3) {
;			If (IsObject(oVector3)) {
;				this.x *= oVector3.x, this.y *= oVector3.y, this.z *= oVector3.z
;			}
;			Else {
;				this.x *= oVector3, this.y *= oVector3, this.z *= oVector3
;			}
;
;			Return, (this)
;        }
;
;        Divide(oVector3) {
;			If (IsObject(oVector3)) {
;				this.x /= oVector3.x, this.y /= oVector3.y, this.z /= oVector3.z
;			}
;			Else {
;				this.x /= oVector3, this.y /= oVector3, this.z /= oVector3
;			}
;
;			Return, (this)
;        }
;
;		Add(oVector3) {
;			If (IsObject(oVector3)) {
;				this.x += oVector3.x, this.y += oVector3.y, this.z += oVector3.z
;			}
;			Else {
;				this.x += oVector3, this.y += oVector3, this.z += oVector3
;			}
;
;			Return, (this)
;		}
;
;		Subtract(oVector3) {
;			If (IsObject(oVector3)) {
;				this.x -= oVector3.x, this.y -= oVector3.y, this.z -= oVector3.z
;			}
;			Else {
;				this.x -= oVector3, this.y -= oVector3, this.z -= oVector3
;			}
;
;			Return, (this)
;		}
;
;		Clamp(oVector3Minimum, oVector3Maximum) {
;			If (IsObject(oVector3Minimum) && IsObject(oVector3Maximum)) {
;				this.x := Math.Max(oVector3Minimum.x, Math.Min(oVector3Maximum.x, this.x)), this.y := Math.Max(oVector3Minimum.y, Math.Min(oVector3Maximum.y, this.y)), this.z := Math.Max(oVector3Minimum.z, Math.Min(oVector3Maximum.z, this.z))
;			}
;			Else {
;				this.x := Math.Max(oVector3Minimum, Math.Min(oVector3Maximum, this.x)), this.y := Math.Max(oVector3Minimum, Math.Min(oVector3Maximum, this.y)), this.z := Math.Max(oVector3Minimum, Math.Min(oVector3Maximum, this.z))
;			}
;
;			Return, (this)
;		}
;
;		;* Vector3.Negate()
;		;* Description:
;			;* Inverts this vector.
;		Negate() {
;			this.x *= -1, this.y *= -1, this.z *= -1
;
;			Return, (this)
;		}
;
;		;* Vector3.Normalize()
;		;* Description:
;			;* This method normalises the vector such that it's length/magnitude is 1. The result is called a unit vector.
;        Normalize() {
;			m := this.Length
;
;			If (m) {
;				this.x /= m, this.y /= m, this.z /= m
;			}
;
;			Return, (this)
;        }
;
;		Transform(oMatrix3) {
;			x := this.x, y := this.y, z := this.z
;				, m := oMatrix3.Elements
;
;			this.x := m[0]*x + m[1]*y + m[2]*z, this.y := m[3]*x + m[4]*y + m[5]*z, this.z := m[6]*x + m[7]*y + m[8]*z
;
;			Return, (this)
;		}
;
;		Copy(oVector3) {
;
;			this.x := oVector3.x, this.y := oVector3.y, this.z := oVector3.z
;
;			Return, (this)
;
;		}
;
;		Clone() {
;			Return, (new Vector3(this))
;		}
;	}
;}
;
;Class Matrix3 {
;
;	__New() {
;		Return, ({"Elements": [1, 0, 0, 0, 1, 0, 0, 0, 1]
;			, "Base": this.__Matrix3})
;	}
;
;	Multiply(oMatrix3a, oMatrix3b) {
;		a := oMatrix3a.Elements, b := oMatrix3b.Elements
;
;		;[a11   a12   a13] [b11   b12   b13]   [a11*b11 + a12*b21 + a13*b31   a11*b12 + a12*b22 + a13*b32   a11*b13 + a12*b23 + a13*b33]
;		;[a21   a22   a23]*[b21   b22   b23] = [a21*b11 + a22*b21 + a23*b31   a21*b12 + a22*b22 + a23*b32   a21*b13 + a22*b23 + a23*b33]
;		;[a31   a32   a33] [b31   b32   b33]   [a31*b11 + a32*b21 + a33*b31   a31*b12 + a32*b22 + a33*b32   a31*b13 + a32*b23 + a33*b33]
;
;		Return, ({"Elements": [a[0]*b[0] + a[1]*b[3] + a[2]*b[6], a[0]*b[1] + a[1]*b[4] + a[2]*b[7], a[0]*b[2] + a[1]*b[5] + a[2]*b[8]
;							 , a[3]*b[0] + a[4]*b[3] + a[5]*b[6], a[3]*b[1] + a[4]*b[4] + a[5]*b[7], a[3]*b[2] + a[4]*b[5] + a[5]*b[8]
;							 , a[6]*b[0] + a[7]*b[3] + a[8]*b[6], a[6]*b[1] + a[7]*b[4] + a[8]*b[7], a[6]*b[2] + a[7]*b[5] + a[8]*b[8]]
;
;			, "Base": this.__Matrix3})
;	}
;
;	RotateX(vTheta) {
;		c := Math.Cos(vTheta), s := Math.Sin(vTheta)
;
;		;[1      0         0  ]
;		;[0    cos(a)   sin(a)]
;		;[0   -sin(a)   cos(a)]
;
;		Return, ({"Elements": [1, 0, 0, 0, c, s, 0, -s, c]
;			, "Base": this.__Matrix3})
;	}
;
;	RotateY(vTheta) {
;		c := Math.Cos(vTheta), s := Math.Sin(vTheta)
;
;		;[cos(a)   0   -sin(a)]
;		;[  0      1      0   ]
;		;[sin(a)   0    cos(a)]
;
;		Return, ({"Elements": [c, 0, -s, 0, 1, 0, s, 0, c]
;			, "Base": this.__Matrix3})
;	}
;
;	RotateZ(vTheta) {
;		c := Cos(vTheta), s := Sin(vTheta)
;
;		;[ cos(a)   sin(a)   0]
;		;[-sin(a)   cos(a)   0]
;		;[    0       0      1]
;
;		Return, ({"Elements": [c, s, 0, -s, c, 0, 0, 0, 1]
;			, "Base": this.__Matrix3})
;	}
;
;	Class __Matrix3 {
;
;		Set(oElements) {
;			this.elements := oElements
;
;			Return, (this)
;q
;		}
;
;		RotateX(vTheta) {
;			c := Math.Cos(vTheta), s := Math.Sin(vTheta)
;
;			this.Elements := [1.0, 0.0, 0.0, 0.0, c, s, 0.0, -s, c]
;
;			Return, (this)
;		}
;
;		RotateY(vTheta) {
;			c := Cos(vTheta), s := Sin(vTheta)
;
;			this.Elements := [c, 0.0, -s, 0.0, 1.0, 0.0, s, 0.0, c]
;
;			Return, (this)
;		}
;
;		RotateZ(vTheta) {
;			c := Cos(vTheta), s := Sin(vTheta)
;
;			this.Elements := [c, s, 0.0, -s, c, 0.0, 0.0, 0.0, 1.0]
;
;			Return, (this)
;		}
;
;		Print() {
;			e := this.Elements
;
;			Loop, % 9 {
;				i := A_Index - 1
;					, r .= ((A_Index == 1) ? ("[") : (["`n "][Mod(i, 3)])) . [" "][!(e[i] >= 0)] . e[i] . ((i < 8) ? (", ") : (" ]"))
;			}
;
;			Return, (r)
;		}
;	}
;}