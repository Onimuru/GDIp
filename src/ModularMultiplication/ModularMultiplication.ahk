;=====         Auto-execute         =========================;
;===============           Setting            ===============;

#Include, %A_ScriptDir%\..\..\..\AutoHotkey\lib\General.ahk
#Include, %A_ScriptDir%\..\..\..\AutoHotkey\lib\ObjectOriented.ahk
#Include, %A_ScriptDir%\..\..\..\AutoHotkey\lib\Math.ahk
#Include, %A_ScriptDir%\..\..\lib\GDIp.ahk

#KeyHistory 0
#NoEnv
#Persistent
#SingleInstance, Force

CoordMode, Mouse, Screen
ListLines, Off
Process, Priority, , R
SetBatchLines, -1
SetControlDelay, -1
SetWorkingDir, % A_ScriptDir . "\.."

;===============           Variable           ===============;

IniRead, vDebug, % A_WorkingDir . "\..\AutoHotkey\cfg\Settings.ini", Debug, Debug
Global vDebug

vRadius := 150, vDiameter := vRadius*2
Global oCanvas := new GDIp.Canvas([A_ScreenWidth - vRadius*2.5, 0, vRadius*2.5, vRadius*2.5 + 5], "-Caption +AlwaysOnTop +ToolWindow +OwnDialogs +E0x20", "gCanvas1")

vFocus := WinExist("A")

;===============             GUI              ===============;

Gui, gControl: New, -Caption +AlwaysOnTop +ToolWindow +OwnDialogs +LastFound +HwndgControl
WinSet, Transparent, 127.5
Gui, Color, 0xFFFFFF
Gui, Show, % "x" . A_ScreenWidth - vRadius*2.5 - 210 . A_Space . "y" . vRadius*1.5 - 40 . A_Space . "w140 h80 NA", gControl
;===== Reset ============================================================
Gui, Add, Button, x5 y5 w20 h20 gResetSectors, &R
;===== Sector count ============================================================
Gui, Add, Edit, x30 y5 w45 h20 Center Number Limit5
Gui, Add, UpDown, Left Range0-500 gCreateSectors vvSectors 0x80
;===== Multiple ============================================================
Gui, Add, Edit, x80 y5 w55 h20 Center Number Limit5 v__vMultiplier1
Gui, Add, UpDown, Left Range-1-1 gOffsetEdit v__Multiplier2 -2
;===== Color setting ============================================================
Gui, Add, DropDownList, x5 y30 w105 h20 r4 gColorSetting vvColorSetting, Solid|Distance Alpha|Distance Color|Oscillate Color
;===== Cycle ============================================================
Gui, Add, Button , x115 y30 w20 h20 gCycle, &C
;===== Pen width ============================================================
Gui, Add, Edit, x5 y55 w30 h20 Left Number +HwndgDefault1
Gui, Add, UpDown, Left Wrap Range1-3 +HwndgDefault2 gPenWidth
Gui, Add, Edit, x5 y105 w30 h20 Left Number
Gui, Add, UpDown, Left Wrap Range1-3 gPenWidth
;===== AntiAlias ============================================================
Gui, Add, Checkbox, x40 y55 w18 h20 Checked +HwndgDefault3 gAntiAlias
Gui, Add, Checkbox, x40 y105 w18 h20 Checked gAntiAlias
;===== NSFW ============================================================
Gui, Add, Button, x58 y55 w52 h20 +HwndgDefault4 gNSFW, &NSFW
Gui, Add, Button, x58 y105 w52 h20 gNSFW, NSFW
;===== Help ============================================================
Gui, Add, Button, x115 y55 w20 h20 +HwndgDefault5 gHelp, &H
Gui, Add, Button, x115 y105 w20 h20 gHelp, &H
;===== Sine wave ============================================================
Gui, Add, Edit, w20 h20 Center Disabled Hidden +HwndgExtended1 v__Frequency1
Gui, Add, Slider, x5 y55 w108 h20 AltSubmit Hidden Buddy2__Frequency1 Range0-60 Thick10 TickInterval10 +HwndgExtended2 gOffsetEdit v__Frequency2
Gui, Add, Edit, w20 h20 Center Disabled Hidden +HwndgExtended3 v__Phase1
Gui, Add, Slider, x5 y80 w108 h20 AltSubmit Hidden Buddy2__Phase1 Range0-12 Thick10 TickInterval2 +HwndgExtended4 gOffsetEdit v__Phase2

;===============            Other             ===============;

ControlClick, Button1, , , , , NA  ;* Click the Reset button to pass on information that would otherwise have to be defined and set everything to default.

OnExit("Exit"), OnMessage(0x101, "WM_KEYUP")  ;* Hack to register 0-9 and Enter on Edit1 and Edit2.

Exit

;=====            Hotkey            =========================;

#If (WinActive(A_ScriptName))

	~$^s::
		Critical
		SetTitleMatchMode, 2

		Sleep, 200
		Reload
		Return

	$F10::ListVars

#IF

$Space::
	If (!KeyWait("Space", "T0.5")) {
		Send, {Space}
		Return
	}

	GoSub, NSFW
	Return

*$Escape::
	If (!KeyWait("Escape", "T1")) {
		Send, {Esc}
		Return
	}

	Exit()
	Return

;=====            Label             =========================;

ResetSectors:
	If (vCycle)
		GoSub, Cycle  ;*Toggle vCycle off if its on.

	;*Set all the controls (with the exception of vAntiAlias and vHelp) to their default values:
	Loop, 6
		GuiControl, , % "Edit" . A_Index, % (A_Index == 1 ? (vSectors := 200) : A_Index == 2 ? (vMultiplier := 2.0) : A_Index <= 4 ? (vPenWidth := 1) : A_Index == 5 ? (vFrequency := 2.0) : (vPhase := 0.0))
	Loop, 2
		GuiControl, , % "msctls_trackbar32" . A_Index, % (A_Index == 1 ? 20 : 0)
	GuiControl, Choose, ComboBox1, 1
	Gui, gControl: Submit, NoHide

	;* Transform the Gui back to default if necessary:
	If ((vGuiMode2 := vGuiMode2 ? vGuiMode2 : "Default") != (vGuiMode1 := vColorSetting := "Default"))
		TransformGui()

	If (vFocus) {
		WinActivate, % "ahk_id" . vFocus

		VarSetCapacity(vFocus, 0)
	}

	GoSub, UpdateCanvas  ;* Draw the ellipse and clear the graphics.
	Return

OffsetEdit:
	If (A_GuiControl == "__Multiplier2") {
		;* Offset vMultiplier and reset __Multiplier2 (the internal UpDown2 variable) back to 0:
		GuiControl, , __vMultiplier1, % (vMultiplier := Round(__Multiplier2 <= 0 ? (__vMultiplier1 - 0.1) < 0.1 ? 0 : __vMultiplier1 > 500 ? 499.9 : (__vMultiplier1 - 0.1) : (__vMultiplier1 + 0.1) > 499.9 ? 500.0 : (__vMultiplier1 + 0.1), 1))
		GuiControl, , __Multiplier2, % (__Multiplier2 := 0)

		GoTo, ColorSetting
	}
	;* Offset vFrequency and vPhase:
	GuiControl, , __Frequency1, % (vFrequency := Round(__Frequency2/10, 1))
	GuiControl, , __Phase1, % (vPhase := Round(__Phase2/2, 1))
ColorSetting:
	Gui, gControl: Submit, NoHide

	;* Transform the Gui if necessary:
	If (vGuiMode2 != (vGuiMode1 := ((vColorSetting := RegExReplace(vColorSetting, A_Space, "_")) = "Oscillate_Color" ? "Extended" : "Default")))
		TransformGui()

	vGuiMode2 := vGuiMode1  ;* Track the current Gui mode.

	If (vCycle)
		Return  ;* vCycle has CreateSectors on a timer so stop here.
CreateSectors:
	Critical

	;* Increment vMultiplier and __vMultiplier1 (the internal Edit2 variable) if vCycle is on:
	If (vCycle)
		ControlSetText, Edit2, % (vMultiplier := __vMultiplier1 := Round(vMultiplier + (vMultiplier >= 500 ? -500 : 0.05), 2)), % "ahk_id" gControl

	Loop, % vSectors {
		;* Calculate the xy coordinates of the start and end of the line that needs to be drawn:
		a := Math.ToRadians(-360/vSectors), i := A_Index - 1

		v := a*Format("{:0.6f}", i)
		x1 := vRadius*Cos(v), y1 := vRadius*Sin(v)

		v := a*i*Mod(vMultiplier, vSectors)
		x2 := vRadius*Cos(v), y2 := vRadius*Sin(v)

		;* Calculate the color of the line that needs to be drawn:
		Switch (vColorSetting) {
			Case "Distance_Alpha":
				;* Calculate the distance between the xy coordinates and translate that into a range of 0-255:
				v := Abs(Floor(Sqrt((x2 - x1)**2 + (y2 - y1)**2)/vDiameter*255) - 255)
				c := Format("{:#X}{:02X}{2:02X}{2:02X}", v, 255)
			Case "Distance_Color":
				;* Calculate the distance between the xy coordinates and translate that into a range of 0-240 with an offset to have red (160) at the center:
				v := (v := Floor(Sqrt((x2 - x1)**2 + (y2 - y1)**2)/vDiameter*240) + 160) + (v > 240 ? -240 : 0)
				c := Format("{:#X}{:06X}", 255, DllCall("shlwapi\ColorHLSToRGB", UInt, v, UInt, 120, UInt, 240))
			Case "Oscillate_Color":
				;* Calculate values for R, G and B on out of sync sine waves and translate that to a range of 0-255:
				v := [Sin((f := Math.Pi*vFrequency/vSectors*i + vPhase))*127.5 + 127.5, Sin(f + 2.094395)*127.5 + 127.5, Sin(f + 4.188790)*127.5 + 127.5]
				c := Format("{:#X}{:02X}{:02X}{:02X}", 255, v[0], v[1], v[2])

				;* Draw a visualization (not accurate because the values stay possitive but it looks better as a complete sine wave (-1 to 1)) of the outcome of the R, G and B sine waves and increase the pen width by 25% for an overlap to avoid ridges at high sector count:
				oCanvas.DrawLine(pPen := new GDIp.Pen(c, (w := vDiameter/vSectors)*1.25), [{"x": (x := i*w + (w/2)), "y": (Abs((v := Sin(f - vPhase))) < 0.000001 ? 1 : 0) + vRadius*0.25}, {"x": x, "y": v*20 + vRadius*0.25}])
			Default:
				c := Format("{:#X}{:02X}{2:02X}{2:02X}", 255, 255)
		}

		;* Draw the line:
		oCanvas.DrawLine(pPen := new GDIp.Pen(c, vPenWidth), [{"x": x1 + vRadius, "y": y1 + vRadius*1.5}, {"x": x2 + vRadius, "y": y2 + vRadius*1.5}])
	}

	UpdateCanvas:
		;* Draw the outline ellipse and clean up:
		pPen := new GDIp.Pen("0x80FFFFFF", 1)

		If (vGuiMode1 == "Extended")
			oCanvas.DrawLine(pPen, [{"x": 0, "y": vRadius*0.25}, {"x": vDiameter, "y": vRadius*0.25}])
		oCanvas.DrawEllipse(pPen, {"x": 0, "y": vRadius*0.5, "Width": vDiameter, "Height": vDiameter})

		oCanvas.Update()
	Return

Cycle:
	SetTimer, CreateSectors, % ((vCycle := !vCycle) ? 50 : "Off")  ;* Toggle vCycle.
	Return

PenWidth:
	;* Can't assign the same variable to two controls and moving an Edit with a buddy screws up the buddy control so need to ensure they match here. Changing one, changes the other:
	ControlGetText, vPenWidth, % (vGuiMode1 != "Extended" ? "Edit3" : "Edit4"), % "ahk_id" . gControl
	GuiControl, , % (vGuiMode1 != "Extended" ? "Edit4" : "Edit3"), % vPenWidth
	If (!vCycle)
		Gosub, CreateSectors
	Return

AntiAlias:
	oCanvas.SmoothingMode := (vAntiAlias := !vAntiAlias) ? 3 : 4  ;? 3 = None, 4= AntiAlias.
	GuiControl, , % (vGuiMode1 != "Extended" ? "Button4" : "Button3"), % (vAntiAlias ? 0 : 1)
	If (!vCycle)
		Gosub, CreateSectors
	Return

NSFW:
	Gui, gControl: Show, NA
	Gui, gCanvas1: Show, NA
	If (vHelp)
		Gui, gCanvas2: Show, NA
	If (vNSFW := !vNSFW) {
		If (vCycle)
			Gosub, Cycle
		Gui, gControl: Hide
		Gui, gCanvas1: Hide
		If (vHelp)
			Gui, gCanvas2: Hide
	}
	Return

Help:
	If (vHelp := (vHelp == "Help" ? True : !vHelp)) {  ;* Toggle unless an update (vHelp == "Help") is queued because vGuiMode2 != vGuiMode1.
		oCanvas2 := "", oCanvas2 := new GDIp.Canvas([0, 0, A_ScreenWidth, A_ScreenHeight - 1], "-Caption +AlwaysOnTop +ToolWindow +OwnDialogs +E0x20", "gCanvas2")
			, oBrush := [new GDIp.Brush(), new GDIp.Brush("0xFFFF0000")]

		v := [A_ScreenWidth - vRadius*2.5, vRadius*1.5]

		oCanvas2.DrawString(oBrush[1], "Reset ⮞", "x" . v[0] - 276 . "y" . v[1] - 35 . "Bold r4 s15"), oCanvas2.DrawString(oBrush[0], "Line count ⮟", "x" . v[0] - 265 . "y" . v[1] - 60 . "Bold r4 s15"), oCanvas2.DrawString(oBrush[0], "⮟ Multiplier", "x" . v[0] - 130 . "y" . v[1] - 60 . "Bold r4 s15"), oCanvas2.DrawString(oBrush[0], "⮜ Cycle", "x" . v[0] - 68 . "y" . v[1] - 9 . "Bold r4 s15"), oCanvas2.DrawString(oBrush[0], "Color mode ⮞", "x" . v[0] - 320 . "y" . v[1] - 9 . "Bold r4 s15")
		If (vGuiMode1 != "Extended") {
			oCanvas2.DrawString(oBrush[0], "Line width ⮞", "x" . v[0] - 310 . "y" . v[1] + 16 . "Bold r4 s15"), oCanvas2.DrawString(oBrush[0], "AntiAlias ⮝", "x" . v[0] - 244 . "y" . v[1] + 45 . "Bold r4 s15"), oCanvas2.DrawString(oBrush[1], "⮝ Hide gui", "x" . v[0] - 130 . "y" . v[1] + 45 . "Bold r4 s15"), oCanvas2.DrawString(oBrush[1], "(Hold spacebar)", "x" . v[0] - 125 . "y" . v[1] + 60 . "Bold r4 s15"), oCanvas2.DrawString(oBrush[0], "⮜ Help", "x" . v[0] - 68 . "y" . v[1] + 17 . "Bold r4 s15")
		}
		Else {
			oCanvas2.DrawString(oBrush[0], "Frequency ⮞", "x" . v[0] - 312 . "y" . v[1] + 15 . "Bold r4 s15"), oCanvas2.DrawString(oBrush[0], "Phase ⮞", "x" . v[0] - 279 . "y" . v[1] + 40 . "Bold r4 s15"), oCanvas2.DrawString(oBrush[0], "Line width ⮞", "x" . v[0] - 310 . "y" . v[1] + 68 . "Bold r4 s15"), oCanvas2.DrawString(oBrush[0], "AntiAlias ⮝", "x" . v[0] - 244 . "y" . v[1] + 95 . "Bold r4 s15"), oCanvas2.DrawString(oBrush[1], "⮝ Hide gui", "x" . v[0] - 130 . "y" . v[1] + 95 . "Bold r4 s15"), oCanvas2.DrawString(oBrush[1], "(Hold spacebar)", "x" . v[0] - 125 . "y" . v[1] + 110 . "Bold r4 s15"), oCanvas2.DrawString(oBrush[0], "⮜ Help", "x" . v[0] - 68 . "y" . v[1] + 68 . "Bold r4 s15")
		}

		oCanvas2.Update()
	}
	Else {
		oCanvas2 := oBrush := ""  ;* __Delete().
	}
	Return

;=====           Function           =========================;

Exit() {
	Critical

	GDIp.Shutdown()
	ExitApp
}

WM_KEYUP(wParam, lParam) {
	Global

	ControlGetFocus, v, ahk_id %gControl%

	If (v ~= "(Edit1|Edit2)" &&  wParam ~= "(13|48|49|50|51|52|53|54|55|56|57|96|97|98|99|100|101|102|103|104|105)") {
		Gui, gControl: Submit, NoHide

		GuiControl, , Edit1, % (vSectors > 2000 ? 2000 : vSectors)
		GuiControl, , Edit2, % (vMultiplier := Format("{:0.1f}", (__vMultiplier1 > 500 ? 500 : __vMultiplier1)))

		vColorSetting := RegExReplace(vColorSetting, A_Space, "_")

		If (wParam == 13)
			If (!vCycle)
				GoSub, CreateSectors
	}
}

TransformGui() {
	Global vGuiMode1, vHelp

	Loop, 5 {
		Control, % (vGuiMode1 != "Extended" ? "Show" : "Hide"), , , % "ahk_id" gDefault%A_Index%
		If (A_Index < 5)
			Control, % (vGuiMode1 != "Extended" ? "Hide" : "Show"), , , % "ahk_id" gExtended%A_Index%
	}
	Gui, gControl: Show, % (vGuiMode1 != "Extended" ? "h80" : "h130") . A_Space . "NA"

	If (vHelp)
		GoSub, % (vHelp := "Help")  ;* Switch Help to the new mode if necessary.
}