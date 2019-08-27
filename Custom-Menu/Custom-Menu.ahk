;===== Auto execute ================================================================================

#KeyHistory 0
#NoEnv
#Persistent
#SingleInstance, Force
#WinActivateForce

#Include, %A_ScriptDir%\..\..\..\lib\GDIp.ahk
#Include, %A_ScriptDir%\..\..\..\lib\Array.Prototype.ahk

CoordMode, Mouse, Screen
CoordMode, ToolTip, Screen
DetectHiddenWindows, On
ListLines, Off
Process, Priority, , R
SendMode, Input
SetBatchLines, -1
SetKeyDelay, -1
SetTitleMatchMode, 2	;Not needed?
SetWinDelay, -1
SetWorkingDir, % A_ScriptDir

;===== Admin

If (!(A_IsAdmin || RegExMatch(DllCall("GetCommandLine", "str"), " /restart(?!\S)"))) {
	Try
		Run, % *RunAs (A_IsCompiled ? A_AhkPath " /restart " A_ScriptFullPath : A_ScriptFullPath " /restart")

	ExitApp
}

;===== Menu

Menu, Tray, Icon, mstscax.dll, 10, 1     ;https://diymediahome.org/windows-icons-reference-list-with-details-locations-images/
Menu, Tray, NoStandard
Menu, Tray, Add
Menu, Tray, Add, [&1] Settings, Settings
Menu, Tray, Add
Menu, Tray, Add, [&8] Pause, Pause
Menu, Tray, Add, [&9] Suspend, Suspend
Menu, Tray, Add
Menu, Tray, Add, [&9] Exit, Exit

;===== Settings

Global vRadius, vDiameter
	, vSections, vFakeSections

	, vSettingsDir := A_ScriptDir . "\" . SubStr(A_ScriptName, 1, -4) . ".ini"

;----- Properties:
IniRead, vRadius, % vSettingsDir, Properties, Radius
vDiameter := vRadius*2
IniRead, vSections, % vSettingsDir, Properties, Sections
IniRead, vFakeSections, % vSettingsDir, Properties, FakeSections

;----- Appearance:
IniRead, vOverlap, % vSettingsDir, Appearance, Overlap
IniRead, vFontsize, % vSettingsDir, Appearance, Fontsize
IniRead, vColor, % vSettingsDir, Appearance, Color
vColor := [StrSplit(vColor, ", ")[1], StrSplit(vColor, ", ")[2], StrSplit(vColor, ", ")[3]]  ;https://www.w3schools.com/colors/colors_picker.asp

;----- Mechanics:
IniRead, vClockwise, % vSettingsDir, Mechanics, Clockwise
IniRead, vDelay, % vSettingsDir, Mechanics, Delay
IniRead, vSound, % vSettingsDir, Mechanics, Sound

;----- Hotkeys:
IniRead, vHotkey_Launch, % vSettingsDir, Hotkeys, Launch
vHotkey_Launch := [StrSplit(vHotkey_Launch, ", ")[1], StrSplit(vHotkey_Launch, ", ")[2]]

;----- Internal:
Global vDebug := [1]
	, vCanvas := new Canvas(vDiameter*1.5, vDiameter*1.5)

;===== Gui ============================================================
pBrush_NonExist := Gdip_BrushCreateSolid(0x00000000)

;----- Gui00:
Gui00 := Create_Layered_GUI("Gui00", "+AlwaysOnTop -Caption -DPIScale +ToolWindow")

Loop, 4 {
	If (A_Index = 1) {
		pBrush_Exist := Gdip_CreateLineBrushFromRect(0, 0, vDiameter, vDiameter, vColor[1], vColor[0], 2, 0)

		Gdip_FillEllipse(vCanvas.G, pBrush_Exist, 0, 0, vDiameter, vDiameter)
	}

	Else If (A_Index = 2) {
		pBrush_Exist := Gdip_CreateLineBrushFromRect(0, 0, vDiameter, vDiameter, vColor[0], vColor[1], 2, 0)

		Gdip_FillEllipse(vCanvas.G, pBrush_Exist, vOverlap*2, vOverlap*2, vDiameter - vOverlap*4, vDiameter - vOverlap*4)
	}

	Else If (A_Index = 3) {
		pBrush_Exist := Gdip_CreateLineBrushFromRect(0, 0, vDiameter, vDiameter, vColor[1], vColor[0], 2, 0)

		Gdip_FillEllipse(vCanvas.G, pBrush_Exist, vRadius/3 - vOverlap, vRadius/3 - vOverlap, vDiameter - vDiameter/3 + vOverlap*2, vDiameter - vDiameter/3 + vOverlap*2)
	}

	Else {
		pBrush_Exist := Gdip_BrushCreateSolid("0x4D" . SubStr(vColor[1], 5))

		Gdip_FillEllipse(vCanvas.G, pBrush_Exist, 0, 0, vDiameter, vDiameter)
	}

	Gdip_SetCompositingMode(vCanvas.G, 1)
	If (A_Index = 1)
		Gdip_FillEllipse(vCanvas.G, pBrush_NonExist, vOverlap, vOverlap, vDiameter - vOverlap*2, vDiameter - vOverlap*2)

	Else If (A_Index = 2)
		Gdip_FillEllipse(vCanvas.G, pBrush_NonExist, vRadius/3 - vOverlap*2, vRadius/3 - vOverlap*2, vDiameter - vDiameter/3 + vOverlap*4, vDiameter - vDiameter/3 + vOverlap*4)

	Else If (A_Index = 4)
		Gdip_FillEllipse(vCanvas.G, pBrush_NonExist, vRadius/3, vRadius/3, vDiameter - vDiameter/3, vDiameter - vDiameter/3)

	Gdip_SetCompositingMode(vCanvas.G, 0), Gdip_DeleteBrush(pBrush_Exist)
}

Gdip_DeleteBrush(pBrush_Exist)
pBrush_Exist := Gdip_CreateLineBrushFromRect(0, 0, vDiameter, vDiameter, "0x4D" . SubStr(vColor[1], 5), "0x4D" . SubStr(vColor[0], 5), 2, 0)	;pBrush_Exist := Gdip_BrushCreateSolid("0x0D" . SubStr(vColor[1], 5))

Gdip_FillEllipse(vCanvas.G, pBrush_Exist, vRadius/3 - vOverlap, vRadius/3 - vOverlap , vDiameter - vDiameter/3 + vOverlap*2, vDiameter - vDiameter/3 + vOverlap*2)

UpdateLayeredWindow(Gui00, vCanvas.hdc), Gdip_GraphicsClear(vCanvas.G)
If (vDebug[0])
	Gui, Gui00: Show, NA

;----- Gui00_Banner:
Gui00_Banner := Create_Layered_GUI("Gui00_Banner", "-Caption -DPIScale +OwnerGui00 +ToolWindow +E0x20")

Gdip_DeleteBrush(pBrush_Exist)
pBrush_Exist := Gdip_CreateLineBrushFromRect(0, 0, vDiameter, vDiameter, vColor[(vOverlap ? 1 : 0)], vColor[(vOverlap ? 0 : 1)], 2, 1)

Gdip_SetCompositingMode(vCanvas.G, 1)
Gdip_FillEllipse(vCanvas.G, pBrush_Exist, vRadius/3 - vOverlap, vRadius/3 - vOverlap, vDiameter - vDiameter/3 + vOverlap*2, vDiameter - vDiameter/3 + vOverlap*2)
Gdip_FillEllipse(vCanvas.G, pBrush_NonExist, vRadius/3, vRadius/3, vDiameter - vDiameter/3, vDiameter - vDiameter/3)

Gdip_SetCompositingMode(vCanvas.G, 0)
Gdip_FillRectangle(vCanvas.G, pBrush_Exist, vRadius/3 - 1, vRadius - vRadius/12, vDiameter - (vDiameter/3) + 2, vRadius/6)  ;**(x - 1), y, **(w - 2), h

UpdateLayeredWindow(Gui00_Banner, vCanvas.hdc), Gdip_GraphicsClear(vCanvas.G), Gdip_SetCompositingMode(vCanvas.G, 1)
If (vDebug[0])
	Gui, Gui00_Banner: Show, NA

;----- Gui00_Text:

Gui, Gui00_Text: New, -Caption -DPIScale +HwndGui00_Text +OwnerGui00_Banner +LastFound +ToolWindow +E0x20
Gui, Gui00_Text: Color, 0x808080
Gui, Gui00_Text: Font, % "Bold s" . vFontsize, Arial Black
Gui, Gui00_Text: Add, Text, % "x0 y" . vFontsize/2 + 1 . A_Space . "w" . vDiameter - vDiameter/3 + 1 . A_Space . "c" . 0x000000 . A_Space . "BackgroundTrans Center vvText", Default text  ;x, **(y + vFontsize/2 + 1), **(w + 1)
WinSet, TransColor, 0x808080
Gui, Gui00_Text: Show, % "w" . vDiameter - vDiameter/3 + 1 . A_Space . "Hide", Gui00_Text  ;**(w + 1)
If (vDebug[0])
	Gui, Gui00_Text: Show, % "x" . vRadius/3 . A_Space . "y" . vRadius - vFontsize*1.5 . A_Space . "NA"  ;x, **(y - vFontsize*1.5)

;----- Gui__:

Gdip_DeleteBrush(pBrush_Exist)
pBrush_Exist := Gdip_CreateLineBrushFromRect(0, 0, vDiameter, vDiameter, "0x99" . SubStr(vColor[1], 5), "0x99" . SubStr(vColor[0], 5), 2, 1)

Loop, % (vSections - vFakeSections)*2 {
	vHandle := (A_Index > vSections - vFakeSections ? "sGui" . SubStr("0" . A_Index - vSections + vFakeSections, -1) : "Gui" . SubStr("0" . A_Index, -1))

	%vHandle% := Create_Layered_GUI(vHandle, "-Caption -DPIScale +OwnerGui00_Banner +ToolWindow")

	If (A_Index = vSections - vFakeSections + 1) {
		Gdip_DeleteBrush(pBrush_Exist)
		pBrush_Exist := Gdip_CreateLineBrushFromRect(0, 0, vDiameter, vDiameter, "0xE6" . SubStr(vColor[2], 5), "0xE6" . SubStr(vColor[0], 5), 2, 1)
	}

	Gdip_FillEllipse(vCanvas.G, pBrush_Exist, 0, 0, vDiameter, vDiameter)

	;Gdip_TranslateWorldTransform() by -180° to have Gui01 top and center:
	Gdip_TranslateWorldTransform(vCanvas.G, vRadius, vRadius), Gdip_RotateWorldTransform(vCanvas.G, -180/vSections + 360/vSections*(A_Index - 1) + 360/vSections*vFakeSections*(A_Index > vSections - vFakeSections)), Gdip_TranslateWorldTransform(vCanvas.G, -vRadius, -vRadius)

	Gdip_FillEllipse(vCanvas.G, pBrush_NonExist, vRadius/3, vRadius/3, vDiameter - vDiameter/3, vDiameter - vDiameter/3)
	Gdip_FillRectangle(vCanvas.G, pBrush_NonExist, 0, 0, vRadius - (vOverlap ? 2.5*(vOverlap/5) : 0.55), vDiameter)     ;x, y, **(w - 1), h

	Gdip_TranslateWorldTransform(vCanvas.G, vRadius, vRadius), Gdip_RotateWorldTransform(vCanvas.G, 360/vSections), Gdip_TranslateWorldTransform(vCanvas.G, -vRadius, -vRadius)

	Gdip_FillRectangle(vCanvas.G, pBrush_NonExist, vRadius + (vOverlap ? 2.5*(vOverlap/5) : 0.55), 0, vRadius, vDiameter)     ;**(x + 1), y, w, h

	UpdateLayeredWindow(%vHandle%, vCanvas.hdc), Gdip_GraphicsClear(vCanvas.G), Gdip_ResetWorldTransform(vCanvas.G)
	If (vDebug[0])
		Gui, %vHandle%: Show, % "x" . (vDiameter + 5)*((A_Index > vSections - vFakeSections) + 1) . " NA"
}

vCanvas.ShutDown()

Hotkey, % vHotkey_Launch[0] . vHotkey_Launch[1], Show, On

OnExit, Exit

Exit

;===== Labels ================================================================================

Settings:
	Return

Pause:
	If (!A_IsSuspended) {
		Menu, Tray, Icon, mstscax.dll, 10, 1

		Hotkey, % vHotkey_Launch[0] . vHotkey_Launch[1], Show, On
	}
	Menu, Tray, UnCheck, [&8] Pause

	If (vPause := !vPause) {
		Menu, Tray, Check, [&8] Pause

		If (!A_IsSuspended) {
			Menu, Tray, Icon, wmploc.dll, 152, 1

			Hotkey, % vHotkey_Launch[0] . vHotkey_Launch[1], Show, Off
		}
	}

	Pause, -1
	Return

Suspend:
	If (!A_IsPaused) {
		Menu, Tray, Icon, mstscax.dll, 10, 1

		Hotkey, % vHotkey_Launch[0] . vHotkey_Launch[1], Show, On
	}
	Menu, Tray, UnCheck, [&9] Suspend

	If (vSuspend := !vSuspend) {
		Menu, Tray, Check, [&9] Suspend

		If (!A_IsPaused) {
			Menu, Tray, Icon, wmploc.dll, 152, 1

			Hotkey, % vHotkey_Launch[0] . vHotkey_Launch[1], Show, Off
		}
	}

	Suspend, -1
	Return

Exit:
	ExitApp
	Return

Show:
	KeyWait, % SubStr(A_ThisHotkey, StrLen(vHotkey_Launch[0]) + 1), T0.5
	If (ErrorLevel) {
		MouseGetPos, vCx, vCy
		Global vCx, vCy
			, vCurrentGui := ""

		Loop, % (vSections - vFakeSections)*2 {
			vHandle := SubStr("sGui", -2 - (A_Index > vSections - vFakeSections)) . SubStr("0" . A_Index - (A_Index > vSections - vFakeSections)*(vSections - vFakeSections), -1)

			Gui, %vHandle%: Show, % "x" . vCx - vRadius . A_Space . "y" . vCy - vRadius . A_Space . (A_Index > vSections - vFakeSections ? "Hide" : "NA")
		}
		Gui, Gui00: Show, % "x" . vCx - vRadius . A_Space . "y" . vCy - vRadius . A_Space . "NA"
		Gui, Gui00_Banner: Show, % "x" . vCx - vRadius . A_Space . "y" . vCy - vRadius . A_Space . "Hide"
		Gui, Gui00_Text: Show, % "x" . vCx - vRadius + vRadius/3 . A_Space . "y" . vCy - vRadius + (vRadius - vFontsize*1.5) . A_Space . "Hide"

		OnMessage("0x200", "msgHandler"), OnMessage("0x2A3", "msgHandler")

		Hotkey, $WheelUp, Cycle, On
		Hotkey, $WheelDown, Cycle, On
		Hotkey, $Esc, Cancel, On

		KeyWait, % SubStr(A_ThisHotkey, StrLen(vHotkey_Launch[0]) + 1)

		Goto, Hide
	}

	Send, % "{" . SubStr(A_ThisHotkey, StrLen(vHotkey_Launch[0]) + 1) . "}"
	Return

Cancel:
	SetTimer, Mouse, Delete

	If (vCurrentGui)
		guiHandler(Gui%vCurrentGui%, sGui%vCurrentGui%), vCurrentGui := ""

	Sleep, % vDelay
Hide:
	OnMessage("0x200", ""), OnMessage("0x2A3", "")

	SetTimer, Mouse, Delete

	Hotkey, $WheelUp, Cycle, Off
	Hotkey, $WheelDown, Cycle, Off
	Hotkey, $Esc, Cancel, Off

	If (vDebug[0])
		ToolTip

	Loop, % vSections - vFakeSections {
		vHandle := "Gui" . (vCurrentGui ? (vCurrentGui := SubStr("0" . (((vCurrentGui += vClockwise) > vSections) ? 1 : (vCurrentGui < 1) ? vSections : vCurrentGui), -1)) : SubStr("0" . A_Index, -1))

		If (!vCurrentGui || !vDelay) {
			Gui, %vHandle%: Hide

			If (A_Index = vSections - vFakeSections) {
				Gui, Gui00: Hide
				Gui, Gui00_Banner: Hide
				Gui, Gui00_Text: Hide
			}
		}

		Else {
			If (A_Index < vSections - vFakeSections) {
				guiHandler(sGui%vCurrentGui%, Gui%vCurrentGui%)

				Sleep, % vDelay
			}

			Else {
				Gui, Gui00: Hide
				Gui, Gui00_Banner: Hide
				Gui, Gui00_Text: Hide

				Loop, % vSections - vFakeSections {
					vHandle := "sGui" . (vCurrentGui := SubStr("0" . (((vCurrentGui += vClockwise) > vSections) ? 1 : (vCurrentGui < 1) ? vSections : vCurrentGui), -1))
					Gui, %vHandle%: Hide
				}

				vClipboard := ClipboardAll
				Clipboard := ""     ;For better compatibility with Clipboard History.
				Send, ^c
				ClipWait, 0.2
				If (ErrorLevel)
				{
					Clipboard := vClipboard
					Return
				}

				TempText := Clipboard

				If (vCurrentGui = 1)		;lowercase
					StringLower, TempText, TempText

				Else If (vCurrentGui = 2)	;UPPERCASE
					StringUpper, TempText, TempText

				Else If (vCurrentGui = 3) {	;Sentence case
					StringLower, TempText, TempText
					TempText := RegExReplace(TempText, "((?:^|[.!?]\s+)[a-z])", "$u1")
				}

				Else If (vCurrentGui = 4)	;Title Case
					StringLower, TempText, TempText, T

				Else If (vCurrentGui = 5)	;Fix Linebreaks
					TempText := RegExReplace(TempText, "\R", "`r`n")

				Else If (vCurrentGui = 6) {	;Reverse
					TempText := [StrReplace(TempText, Chr(29), "`r`n")]
					Loop, Parse, % TempText[0]
						TempText[1] := A_LoopField . TempText[1]

					TempText := StrReplace(TempText[1], "`r`n", Chr(29))
				}

				Else If (vCurrentGui = 7) {	;RegExReplace     **List common matches.
					TempText := [TempText, SafeInput("Enter Pattern", "RegEx Pattern:", (vPattern := vPattern ? vPattern : "\d+(\.\d+)*"))]
					If (ErrorLevel)
					{
						Clipboard := vClipboard
						Return
					}
					vPattern := TempText[1]

					TempText[2] := SafeInput("Enter Replacement", "Replacement: ", vReplacement)
					If (ErrorLevel)
					{
						Clipboard := vClipboard
						Return
					}
					vReplacement := TempText[2]

					TempText := RegExReplace(TempText[0], TempText[1], TempText[2])
				}
;				Else						;Sort
;					SortText("CL D`n")
;					Sort, TempText, % p

				Clipboard := TempText
				Send, ^v
				Sleep, 25
				Clipboard := vClipboard

				If (InStr(TempText, "`n"))
					Loop, Parse, TempText, `n, `r
						TempText := ((TempText && A_Index > 1) ? TempText : 0) + StrLen(A_LoopField) + (A_Index > 1)
				Else
					TempText := StrLen(TempText)

				Send, % "+{Left" . A_Space . TempText . "}"
			}

			SafeInput(p1, p2, p3 = "") {
				f := WinExist("A")

				InputBox, v2, %p1%, %p2%, , , 125, , , , , %p3%     ;OutputVar, Title, Prompt, , , Height, , , , , Default
				WinActivate, % "ahk_id" . f

				Return (v2)
			}
		}
	}

	Return

Cycle:
	If (A_TimeSincePriorHotkey >= 25) {
		If (vCurrentGui)
			guiHandler(Gui%vCurrentGui%, sGui%vCurrentGui%)
		vCurrentGui := SubStr("0" . (vCurrentGui ? ((vCurrentGui += {"$WheelUp": -1, "$WheelDown": 1}[A_ThisHotkey]) > vSections) ? 1 : (vCurrentGui < 1) ? vSections : vCurrentGui : 1), -1)

		guiHandler(sGui%vCurrentGui%, Gui%vCurrentGui%, 1)
	}
	Return

;===== Functions ================================================================================

Class Canvas {
	__New(_w, _h, _smoothing := 4, _interpolation := 7) {
		this.Layered := {"w": _w
			, "h": _h}

		this.Layered.pToken := Gdip_Startup()
		this.Layered.hbm := CreateDIBSection(_w, _h), this.Layered.hdc := CreateCompatibleDC(), this.Layered.obm := SelectObject(this.Layered.hdc, this.Layered.hbm)
		this.Layered.G := Gdip_GraphicsFromHDC(this.Layered.hdc), Gdip_SetSmoothingMode(this.Layered.G, _smoothing), Gdip_SetInterpolationMode(this.Layered.G, _interpolation)

		Return (this.Layered)
	}

	ShutDown() {
		SelectObject(this.Layered.hdc, this.Layered.obm), DeleteObject(this.Layered.hbm), DeleteDC(this.Layered.hdc), Gdip_DeleteGraphics(this.Layered.G)
		Gdip_Shutdown(this.Layered.pToken)
	}
}

Create_Layered_GUI(_name, _options) {
	Gui, % _name . ": New", % _options . " +LastFound +E0x80000"
	Gui, % _name . ": Show", Hide, _name

	UpdateLayeredWindow(WinExist(), vCanvas.hdc, 0, 0, vCanvas.w, vCanvas.h)

	Return (WinExist())
}

guiHandler(_show, _hide, _banner := 0) {
	Critical

	Static a
	If (!a)
		a := ["Default Text", "lowercase", "UPPERCASE", "Sentence case", "Title Case", "Fix Linebreaks", "Reverse", "RegExReplace", "Sort"]

	If (vDebug[0]) {     ;This was primarily an issue because the Mouse timer was allowed to complete it's thread after the WM_MOUSEMOVE thread completed. I have put considerable effort into eliminating that possibily but it's hard to replicate because these messages fire so fast so maybe not...
		If (vCurrentGui = "Gui00")
			MsgBox, % "guiHandler(): 111"
		If (_show = %Gui00%)
			MsgBox, % "guiHandler(): 222"
		If (!_show)
			MsgBox, % "guiHandler(): 333"
		If (_hide = %Gui00%)
			MsgBox, % "guiHandler(): 444"
		If (!_hide)
			MsgBox, % "guiHandler(): 555"
	}

;	If (_show)
		Gui, %_show%: Show, NA
;	If (_hide)
		Gui, %_hide%: Hide

	If (_banner) {
		Gui, Gui00_Banner: Show, NA
		GuiControl, Gui00_Text: Text, vText, % a[vCurrentGui]
		Gui, Gui00_Text: Show, NA
	}
}

msgHandler(_wParam, _lParam, _msg, _hwnd) {
	Critical

	Thread, NoTimers     ;Not nessesary anymore since the Mouse timer has a lower priority but it does stop infinite debug MsgBox queueing.

	Static m, h
	If (!m)    ;TME skelleton to insert the hwnd of a window that we want to trigger a WM_MOUSELEAVE msg.
		VarSetCapacity(m, A_Ptrsize = 8 ? 24 : 16, 0), NumPut(A_Ptrsize = 8 ? 24 : 16, m, 0, "UInt"), NumPut(0x00000002, m, 4, "UInt") ;, NumPut(0, m, A_Ptrsize + 8, "UInt")     ;cbSize (DWORD), dwFlags (DWORD), dwHoverTime (DWORD, ignored)
	If (!h)    ;An array containing Gui00 and all Gui__ (not sGui__) hwnds for use in WM_MOUSELEAVE. Alternatively I could use the Pythagoras' Theorem but I think this is faster and more reliable considering vRadius could potentially be a float and we're messuring in pixels.
		Loop, % vSections + 1
			vHandle := "Gui" . SubStr("0" . A_Index - 1, -1), h ? h[A_Index - 1] := %vHandle% : h := [%vHandle%]

	SetTimer, Mouse, Delete

	If (_msg = 0x200) {     ;WM_MOUSEMOVE
		If (h.Includes(_hwnd)) {
			If (A_Gui = "Gui00") {
				If (vDebug[0])
					vDebug[1] := "000`n"

				Gui, Gui00_Banner: Hide
				Gui, Gui00_Text: Hide

				If (vCurrentGui)     ;This is nessesary to hide sections activated by anything below after re-entering Gui00.
					guiHandler(Gui%vCurrentGui%, sGui%vCurrentGui%)
				vCurrentGui := ""

				NumPut(_hwnd, m, 8, "Ptr")

				Hotkey, $WheelUp, Cycle, On
				Hotkey, $WheelDown, Cycle, On
			}

			Else {
				If (vDebug[0])
					vDebug[1] .= "111`n"

				If (vCurrentGui)     ;This is nessesary to hide sections activated by WheelUp/WheelDown.
					guiHandler(Gui%vCurrentGui%, sGui%vCurrentGui%)
				vCurrentGui := (SubStr(A_Gui, -1))

				guiHandler(sGui%vCurrentGui%, Gui%vCurrentGui%, 1)

				;WM_MOUSELEAVE is received too soon so this is here as a bandaid.
				Loop {
					Sleep, 25     ;Sleep must be before Break because the OS will return true since the window is logically visible (I guess) when it isn't technically there yet and it creates a WM_MOUSELEAVE(because the mouse is not over this hwnd yet**) -> WM_MOUSEMOVE -> WM_MOUSELEAVE... loop. Need to look into that sometime.

					If (DllCall("IsWindowVisible", A_PtrSize ? "Ptr" : "UInt", sGui%vCurrentGui%))
						Break
				}
				NumPut(sGui%vCurrentGui%, m, 8, "Ptr")	;I used to have this below and the function would get 2 WM_MOUSEMOVE msgs (one for Gui__ and then one for sGui__) before setting TME but that caused issues with thread interuption. This is more optimised anyway if you overlook the loop.

				Hotkey, $WheelUp, Cycle, Off
				Hotkey, $WheelDown, Cycle, Off
			}
		}

		Else {     ;This is nessesary to put a new hwnd in TME after the mouse has been outside the Gui Collective(tm).
			If (vDebug[0]) {
				vDebug[1] .= "222`n"

				ToolTip
			}

			NumPut(_hwnd, m, 8, "Ptr")
		}

		DllCall("TrackMouseEvent", "Ptr", &m)

		;Stop monitoring WM_MOUSEMOVE messages until WM_MOUSELEAVE is received:
		OnMessage("0x200", "")

		Return (0)
	}

	Else If (_msg = 0x2A3) {     ;WM_MOUSELEAVE
		If (vDebug[0])
			vDebug[1] .= "333`n"

		;Start monitoring WM_MOUSEMOVE messages again:
		OnMessage("0x200", "msgHandler")

		;Check if the mouse has left the Gui Collective(tm):
		MouseGetPos, , , w
		If (!h.Includes(w)) {
			If (vDebug[0])
				vDebug[1] .= "444`n"

			Mouse:
				Static o
				If (!o)
					o := -90 + 180/vSections

				If (!vCurrentGui) {     ;I can't remember why this was nessesary, probably just system lag.
					If (vDebug[0])
						TrayTip, Mouse(), No reference..., 3

					MouseMove, vCx, vCy, 0

					Return (0)
				}

				MouseGetPos, x, y	;, w
;				If (!h.Includes(w)) {
					a := ((a := DllCall("msvcrt.dll\atan2", "Double", vCy - y, "Double", vCx - x, "Cdecl Double")*57.29577951307855 + o) <= 0 ? a + 360 : a)/360*vSections

					If (vCurrentGui != Ceil(a)) {
						guiHandler(Gui%vCurrentGui%, sGui%vCurrentGui%)
						vCurrentGui := SubStr("0" . (vCurrentGui := Ceil(a)), -1)

						If (vDebug[0]) {
							If (!vCurrentGui)
								MsgBox, "Mouse: 111"
							If (vCurrentGui = "00")
								MsgBox, "Mouse: 222"
							If (a <= 0)
								MsgBox, % "Mouse: 333"
						}

;						If (vCurrentGui)
						guiHandler(sGui%vCurrentGui%, Gui%vCurrentGui%, 1)
					}

;					If (vDebug[0])
;						ToolTip, % (vCurrentGui - 1 ? vCurrentGui - 1 : vSections) . " < " . a + 1 . " > " . (vCurrentGui < vSections ? vCurrentGui + 1 : 1), vCx + vDiameter*1.5, vCy

					SetTimer, Mouse, -50, 1     ;Priority 1 so this thread is above the default (0) but less than any new msgHandler() threads as they're Critical, to give them time to kill this thread. This removes the need to have redundancies here and in guiHandler().
;				}

;				Else If (vDebug[0])
;					TrayTip, Mouse(), Wrong w..., 3

				Return (0)
		}
	}

	Return (0)
}

/*
	===== Hotkeys ================================================================================
*/

~$^s::
	Critical

	If (WinActive(A_ScriptName)) {
		Sleep, 200
		Reload
	}
	Return

~$F10::
	If (WinActive(A_ScriptName))
		ListVars
	Return