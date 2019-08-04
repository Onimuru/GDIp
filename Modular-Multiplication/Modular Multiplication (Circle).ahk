#KeyHistory 0
#NoEnv
#Persistent
#SingleInstance Force

ListLines, Off
Process, Priority, , R
SetBatchLines, -1
SetControlDelay, -1

;Eclipse properties that define the position and proportions of everything else in this script:
{
	vRadius := 150, vDiameter := vRadius*2
	vCx := A_ScreenWidth - vRadius*2.5, vCy := 0
	vSx1 := A_ScreenWidth - vRadius*2.5, vSx2 := vSx1 - vDiameter, vSy1 := vSy2 := vRadius - 40
}

vFocus := WinExist("A")

;Create the Control Gui:
{
	Gui, gControl: New, -Caption +AlwaysOnTop +ToolWindow +OwnDialogs +LastFound +HwndgControl
	WinSet, Transparent, 127.5
	Gui, gControl: Color, 0xFFFFFF
	Gui, gControl: Show, % "x" . vCx - 210 . A_Space . "y" . vRadius*1.5 - 40 . A_Space . "w140 h80 NA", gControl
	;===== Reset ============================================================
	Gui, gControl: Add, Button, x5 y5 w20 h20 gResetSectors, &R
	;===== Sector count ============================================================
	Gui, gControl: Add, Edit, x30 y5 w45 h20 Center Number Limit5
	Gui, gControl: Add, UpDown, Left Range0-500 gCreateSectors vvSectors 0x80
	;===== Multiple ============================================================
	Gui, gControl: Add, Edit, x80 y5 w55 h20 Center Number Limit5 v_vMultiplier1
	Gui, gControl: Add, UpDown, Left Range-1-1 gOffsetEdit v_vMultiplier2 -2
	;===== Color setting ============================================================
	Gui, gControl: Add, DropDownList, x5 y30 w105 h20 r4 gColorSetting vvColorSetting, Solid|Distance Alpha|Distance Color|Oscillate Color
	;===== Cycle ============================================================
	Gui, gControl: Add, Button , x115 y30 w20 h20 gCycle, &C
	;===== Pen width ============================================================
	Gui, gControl: Add, Edit, x5 y55 w30 h20 Left Number +HwndgDefault1
	Gui, gControl: Add, UpDown, Left Wrap Range1-3 +HwndgDefault2 gPenWidth
	Gui, gControl: Add, Edit, x5 y105 w30 h20 Left Number
	Gui, gControl: Add, UpDown, Left Wrap Range1-3 gPenWidth
	;===== AntiAlias ============================================================
	Gui, gControl: Add, Checkbox, x40 y55 w18 h20 Checked +HwndgDefault3 gAntiAlias
	Gui, gControl: Add, Checkbox, x40 y105 w18 h20 Checked gAntiAlias
	;===== NSFW ============================================================
	Gui, gControl: Add, Button, x58 y55 w52 h20 +HwndgDefault4 gNSFW, &NSFW
	Gui, gControl: Add, Button, x58 y105 w52 h20 gNSFW, NSFW
	;===== Help ============================================================
	Gui, gControl: Add, Button, x115 y55 w20 h20 +HwndgDefault5 gHelp, &H
	Gui, gControl: Add, Button, x115 y105 w20 h20 gHelp, &H
	;===== Sine wave ============================================================
	Gui, gControl: Add, Edit, w20 h20 Center Disabled Hidden +HwndgExtended1 v_vFrequency1
	Gui, gControl: Add, Slider, x5 y55 w108 h20 AltSubmit Hidden Buddy2_vFrequency1 Range0-60 Thick10 TickInterval10 +HwndgExtended2 gOffsetEdit v_vFrequency2
	Gui, gControl: Add, Edit, w20 h20 Center Disabled Hidden +HwndgExtended3 v_vPhase1
	Gui, gControl: Add, Slider, x5 y80 w108 h20 AltSubmit Hidden Buddy2_vPhase1 Range0-12 Thick10 TickInterval2 +HwndgExtended4 gOffsetEdit v_vPhase2
}

;Create Canvas1 (a layered window (+E0x80000) that can be drawn on with Gdip):
{
	pToken := Gdip_Startup()
	hbm1 := CreateDIBSection(vRadius*2.5, vRadius*2.5 + 5), hdc1 := CreateCompatibleDC(), obm1 := SelectObject(hdc1, hbm1)
	G1 := Gdip_GraphicsFromHDC(hdc1), Gdip_SetSmoothingMode(G1, 4), Gdip_SetInterpolationMode(G1, 7)

	Gui, gCanvas1: New, -Caption +AlwaysOnTop +ToolWindow +OwnDialogs +HwndgCanvas1 +E0x80000 +E0x20
	Gui, gCanvas1: Show, NA
}

;Click the Reset button to pass on information that would otherwise have to be defined and set everything to default:
ControlClick, Button1, , , , , NA

;Store the PID of this process for use in FreeMemory:
vPID := DllCall("GetCurrentProcessId")

;Hack to register 0-9 and Enter on Edit1 and Edit2:
OnMessage(0x101, "WM_KEYUP")
OnExit, Exit

Return

/*
	===== Hotkeys ================================================================================
*/

~$^s::
	Critical
	SetTitleMatchMode, 2

	If (WinActive(A_ScriptName)) {
		Sleep, 200
		Reload
	}
	Return

$Space::
	KeyWait, Space, T0.5
	If (!ErrorLevel) {
		Send, {Space}
		Return
	}

	GoSub, NSFW
	Return

*$Escape::
	KeyWait, Escape, T1
	If (!ErrorLevel) {
		Send, {Esc}
		Return
	}

	GoSub, Exit
	Return

/*
	===== Lables ================================================================================
*/

;Code by heresy (https://autohotkey.com/board/topic/30042-run-ahk-scripts-with-less-half-or-even-less-memory-usage/) to free memory:
FreeMemory:
	H := DllCall("OpenProcess", "UInt", 0x001F0FFF, "Int", 0, "Int", vPID)

    DllCall("SetProcessWorkingSetSize", "UInt", H, "Int", -1, "Int", -1)
    DllCall("CloseHandle", "Int", H)
	Return

ResetSectors:
	;Toggle vCycle off if its on:
	If (vCycle)
		GoSub, Cycle

	;Trigger the FreeMemory label:
	vFreeMemory := 200

	;Set all the controls (with the exception of vAntiAlias and vHelp) to their default values:
	Loop, 6
		GuiControl, , % "Edit" . A_Index, % (A_Index = 1 ? (vSectors := 200) : A_Index = 2 ? (vMultiplier := 2.0) : A_Index <= 4 ? (vPenWidth := 1) : A_Index = 5 ? (vFrequency := 2.0) : (vPhase := 0.0))
	Loop, 2
		GuiControl, , % "msctls_trackbar32" . A_Index, % (A_Index = 1 ? 20 : 0)
	GuiControl, Choose, ComboBox1, 1
	Gui, gControl: Submit, NoHide

	;Transform the Gui back to default if necessary:
	If ((vGuiMode2 := vGuiMode2 ? vGuiMode2 : "Default") != (vGuiMode1 := vColorSetting := "Default"))
		TransformGui()

	If (vFocus) {
		WinActivate, ahk_id %vFocus%

		VarSetCapacity(vFocus, 0)
	}

	;Draw the eclipse and clear the graphics:
	GoSub, UpdateCanvas
	Return

OffsetEdit:
	If (A_GuiControl = "_vMultiplier2") {
		;Offset vMultiplier and reset _vMultiplier2 (the internal UpDown2 variable) back to 0:
		GuiControl, , _vMultiplier1, % (vMultiplier := Round(_vMultiplier2 <= 0 ? (_vMultiplier1 - 0.1) < 0.1 ? 0 : _vMultiplier1 > 500 ? 499.9 : (_vMultiplier1 - 0.1) : (_vMultiplier1 + 0.1) > 499.9 ? 500.0 : (_vMultiplier1 + 0.1), 1))
		GuiControl, , _vMultiplier2, % (_vMultiplier2 := 0)

		GoTo, ColorSetting
	}
	;Offset vFrequency and vPhase:
	GuiControl, , _vFrequency1, % (vFrequency := Round(_vFrequency2/10, 1))
	GuiControl, , _vPhase1, % (vPhase := Round(_vPhase2/2, 1))
ColorSetting:
	Gui, gControl: Submit, NoHide
	;Transform the Gui if necessary:
	If (vGuiMode2 != (vGuiMode1 := ((vColorSetting := RegExReplace(vColorSetting, A_Space, "_")) = "Oscillate_Color" ? "Extended" : "Default")))
		TransformGui()
	;Track the current Gui mode:
	vGuiMode2 := vGuiMode1

	;vCycle has CreateSectors on a timer so stop here:
	If (vCycle)
		Return
CreateSectors:
	Critical

	;Increment vMultiplier and _vMultiplier1 (the internal Edit2 variable) if vCycle is on:
	If (vCycle)
		ControlSetText, Edit2, % (vMultiplier := _vMultiplier1 := Round(vMultiplier + (vMultiplier >= 500 ? -500 : 0.05), 2)), ahk_id %gControl%

	Loop, % vSectors {
		;Calculate the xy coordinates of the start and end of the line that needs to be drawn:
		{
			a := -360/vSectors*3.1415926535897932384626433832795/180
			i := A_Index - 1

			v := a*Format("{:0.6f}", i)
			x1 := vRadius*Cos(v)
			y1 := vRadius*Sin(v)

			v := a*i*Mod(vMultiplier, vSectors)
			x2 := vRadius*Cos(v)
			y2 := vRadius*Sin(v)
		}

		;Calculate the color of the line that needs to be drawn:
		{
			If (vColorSetting = "Distance_Alpha") {
				;Calculate the distance between the xy coordinates and translate that into a range of 0-255:
				v := Abs(Floor(Sqrt((x2 - x1)**2 + (y2 - y1)**2)/vDiameter*255) - 255)		;Best theorem.
				c := Format("{:#X}{:02X}{2:02X}{2:02X}", v, 255)
			}
			Else If (vColorSetting = "Distance_Color") {
				;Calculate the distance between the xy coordinates and translate that into a range of 0-240 with an offset to have red (160) at the center:
				v := (v := Floor(Sqrt((x2 - x1)**2 + (y2 - y1)**2)/vDiameter*240) + 160) + (v > 240 ? -240 : 0)
				c := Format("{:#X}{:06X}", 255, DllCall("shlwapi\ColorHLSToRGB", UInt, v, UInt, 120, UInt, 240))
			}
			Else If (vColorSetting = "Oscillate_Color") {
				;Calculate values for R, G and B on out of sync sine waves and translate that to a range of 0-255:
				v := [Sin((f := 3.1415926535897932384626433832795*vFrequency/vSectors*i + vPhase))*127.5 + 127.5, Sin(f + 2.094395)*127.5 + 127.5, Sin(f + 4.188790)*127.5 + 127.5]
				c := Format("{:#X}{:02X}{:02X}{:02X}", 255, v[1], v[2], v[3])

				;Draw a visualization (not accurate because the values stay possitive but it looks better as a complete sine wave (-1 to 1)) of the outcome of the R, G and B sine waves and increase the pen width by 25% for an overlap to avoid ridges at high sector count:
				Gdip_DrawLine(G1, (pPen := Gdip_CreatePen(c, (w := vDiameter/vSectors)*1.25)), (x := i*w + (w/2)), (Abs((v := Sin(f - vPhase))) < 0.000001 ? 1 : 0) + vRadius*0.25, x, v*20 + vRadius*0.25), Gdip_DeletePen(pPen)
			}
			Else
				c := Format("{:#X}{:02X}{2:02X}{2:02X}", 255, 255)
		}

		;Draw the line:
		Gdip_DrawLine(G1, (pPen := Gdip_CreatePen(c, vPenWidth)), x1 + vRadius, y1 + vRadius*1.5, x2 + vRadius, y2 + vRadius*1.5), Gdip_DeletePen(pPen)
	}

	UpdateCanvas:
		;Draw the outline eclipse and clean up:
		pPen := Gdip_CreatePen("0x80FFFFFF", 1)
		If (vGuiMode1 = "Extended")
			Gdip_DrawLine(G1, pPen, 0, vRadius*0.25, vDiameter, vRadius*0.25)
		Gdip_DrawEllipse(G1, pPen, 0, vRadius*0.5, vDiameter, vDiameter)
		UpdateLayeredWindow(gCanvas1, hdc1, vCx, vCy, vRadius*2.5, vRadius*2.5 + 5, 255), Gdip_DeletePen(pPen), Gdip_GraphicsClear(G1)

		If (!(vFreeMemory := (vFreeMemory < 200 ? ++vFreeMemory : 0)))
			GoSub, FreeMemory

	Return

Cycle:
	;Toggle vCycle:
	SetTimer, CreateSectors, % ((vCycle := !vCycle) ? 50 : "Off")
	Return

PenWidth:
	;Can't assign the same variable to two controls and moving an Edit with a buddy screws up the buddy control so need to ensure they match here. Changing one, changes the other:
	ControlGetText, vPenWidth, % (vGuiMode1 != "Extended" ? "Edit3" : "Edit4"), ahk_id %gControl%
	GuiControl, , % (vGuiMode1 != "Extended" ? "Edit4" : "Edit3"), % vPenWidth
	If (!vCycle)
		Gosub, CreateSectors
	Return

AntiAlias:
	Gdip_SetSmoothingMode(G1, ((vAntiAlias := !vAntiAlias) ? 3 : 4))		;3 = None, 4= AntiAlias.
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
	;Toggle unless an update (vHelp = "Help") is queued because vGuiMode2 != vGuiMode1:
	If (vHelp := (vHelp = "Help" ? True : !vHelp)) {
		hbm2 := CreateDIBSection(A_ScreenWidth, A_ScreenHeight), hdc2 := CreateCompatibleDC(), obm2 := SelectObject(hdc2, hbm2)
		G2 := Gdip_GraphicsFromHDC(hdc2), Gdip_SetSmoothingMode(G2, 4)
		Gui, gCanvas2: New, -Caption +AlwaysOnTop +ToolWindow +OwnDialogs +HwndgCanvas2 +E0x80000 +E0x20
		Gui, gCanvas2: Show, NA

		Gdip_TextToGraphics(G2, "Reset ⮞", "x"vCx - 276 "y"vRadius*1.5 - 35 "cFFFF0000 r4 s15 Bold", "Arial"), Gdip_TextToGraphics(G2, "Line count ⮟", "x"vCx - 265 "y"vRadius*1.5 - 60 "cFFFFFFFF r4 s15 Bold", "Arial"), Gdip_TextToGraphics(G2, "⮟ Multiplier", "x"vCx - 120 "y"vRadius*1.5 - 60 "cFFFFFFFF r4 s15 Bold", "Arial"), Gdip_TextToGraphics(G2, "⮜ Cycle", "x"vCx - 68 "y"vRadius*1.5 - 9 "cFFFFFFFF r4 s15 Bold", "Arial"), Gdip_TextToGraphics(G2, "Color mode ⮞", "x"vCx - 320 "y"vRadius*1.5 - 9 "cFFFFFFFF r4 s15 Bold", "Arial")
		If (vGuiMode1 != "Extended")
			Gdip_TextToGraphics(G2, "Line width ⮞", "x"vCx - 310 "y"vRadius*1.5 + 16 "cFFFFFFFF r4 s15 Bold", "Arial"), Gdip_TextToGraphics(G2, "AntiAlias ⮝", "x"vCx - 244 "y"vRadius*1.5 + 45 "cFFFFFFFF r4 s15 Bold", "Arial"), Gdip_TextToGraphics(G2, "⮝ Hide gui", "x"vCx - 130 "y"vRadius*1.5 + 45 "cFFFF0000 r4 s15 Bold", "Arial"), Gdip_TextToGraphics(G2, "(Hold spacebar)", "x"vCx - 125 "y"vRadius*1.5 + 60 "cFFFF0000 r4 s15 Bold", "Arial"), Gdip_TextToGraphics(G2, "⮜ Help", "x"vCx - 68 "y"vRadius*1.5 + 17 "cFFFFFFFF r4 s15 Bold", "Arial")
		Else
			Gdip_TextToGraphics(G2, "Frequency ⮞", "x"vCx - 312 "y"vRadius*1.5 + 15 "cFFFFFFFF r4 s15 Bold", "Arial"), Gdip_TextToGraphics(G2, "Phase ⮞", "x"vCx - 279 "y"vRadius*1.5 + 40 "cFFFFFFFF r4 s15 Bold", "Arial"), Gdip_TextToGraphics(G2, "Line width ⮞", "x"vCx - 310 "y"vRadius*1.5 + 68 "cFFFFFFFF r4 s15 Bold", "Arial"), Gdip_TextToGraphics(G2, "AntiAlias ⮝", "x"vCx - 244 "y"vRadius*1.5 + 95 "cFFFFFFFF r4 s15 Bold", "Arial"), Gdip_TextToGraphics(G2, "⮝ Hide gui", "x"vCx - 130 "y"vRadius*1.5 + 95 "cFFFF0000 r4 s15 Bold", "Arial"), Gdip_TextToGraphics(G2, "(Hold spacebar)", "x"vCx - 125 "y"vRadius*1.5 + 110 "cFFFF0000 r4 s15 Bold", "Arial"), Gdip_TextToGraphics(G2, "⮜ Help", "x"vCx - 68 "y"vRadius*1.5 + 68 "cFFFFFFFF r4 s15 Bold", "Arial")
		UpdateLayeredWindow(gCanvas2, hdc2, 0, 0, A_ScreenWidth, A_ScreenHeight)
	}
	Else {
		SelectObject(hdc2, obm2), DeleteObject(hbm2), DeleteDC(hdc2), Gdip_DeleteGraphics(G2)
		Gui, gCanvas2: Destroy
	}

	GoSub, FreeMemory
	Return

Exit:
	Critical

	;Delete Gdip assets:
	SelectObject(hdc1, obm1), DeleteObject(hbm1), DeleteDC(hdc1), Gdip_DeleteGraphics(G1)
	If (vHelp)
		SelectObject(hdc2, obm2), DeleteObject(hbm2), DeleteDC(hdc2), Gdip_DeleteGraphics(G2)
	Gdip_Shutdown(pToken)

	ExitApp
	Return

/*
	===== Functions ================================================================================
*/

WM_KEYUP(wParam, lParam) {
	Global
	Local v

	ControlGetFocus, v, ahk_id %gControl%

	If (v ~= "(Edit1|Edit2)" &&  wParam ~= "(13|48|49|50|51|52|53|54|55|56|57|96|97|98|99|100|101|102|103|104|105)") {
		Gui, gControl: Submit, NoHide

		GuiControl, , Edit1, % (vSectors > 2000 ? 2000 : vSectors)
		GuiControl, , Edit2, % (vMultiplier := Format("{:0.1f}", (_vMultiplier1 > 500 ? 500 : _vMultiplier1)))

		vColorSetting := RegExReplace(vColorSetting, A_Space, "_")

		If (wParam = 13)
			If (!vCycle)
				GoSub, CreateSectors
	}
}

TransformGui() {
	Global

	Loop, 5 {
		Control, % (vGuiMode1 != "Extended" ? "Show" : "Hide"), , , % "ahk_id" gDefault%A_Index%
		If (A_Index < 5)
			Control, % (vGuiMode1 != "Extended" ? "Hide" : "Show"), , , % "ahk_id" gExtended%A_Index%
	}
	Gui, gControl: Show, % (vGuiMode1 != "Extended" ? "h80" : "h130") . A_Space . "NA"

	;Switch Help to the new mode if necessary:
	If (vHelp)
		GoSub, % (vHelp := "Help")
}
