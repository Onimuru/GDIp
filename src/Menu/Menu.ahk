;============ Auto-execute ====================================================;
;=======================================================  Admin  ===============;

if (!A_IsAdmin || !(DllCall("GetCommandLine", "Str") ~= " /restart(?!\S)")) {
	try {
		Run, % Format("*RunAs {}", (A_IsCompiled) ? (A_ScriptFullPath . " /restart") : (A_AhkPath . " /restart " . A_ScriptFullPath))
	}

	ExitApp
}

;======================================================  Setting  ==============;

#InstallKeybdHook
#InstallMouseHook
#KeyHistory, 0
#NoEnv
;#NoTrayIcon
;#Persistent  ;* ** Any script that calls OnMessage anywhere is automatically persistent. **
#SingleInstance, Force
#Warn, ClassOverwrite, MsgBox
#WinActivateForce

CoordMode, Mouse, Screen
CoordMode, ToolTip, Screen
;DetectHiddenWindows, On
ListLines, Off
Process, Priority, , Realtime
SendMode, Input
SetBatchLines, -1
SetKeyDelay, -1, -1
SetTitleMatchMode, 2
SetWinDelay, -1
SetWorkingDir, % A_ScriptDir . "\..\.."

;======================================================== Menu ================;

Menu, Tray, Icon, % A_WorkingDir . "\res\Image\Icon\Triangle.ico"
;Menu, Tray, NoStandard
;Menu, Tray, Add
;Menu, Tray, Add, [&1] Settings, Settings
;Menu, Tray, Add
;Menu, Tray, Add, [&8] Pause, Pause
;Menu, Tray, Add, [&9] Suspend, Suspend
;Menu, Tray, Add
;Menu, Tray, Add, [&9] Exit, Exit

;====================================================== Variable ==============;

Global Debug := Settings.Debug
	, WindowMessage := DllCall("RegisterWindowMessage", "Str", "WindowMessage", "UInt")

;======================================================== GDIp ================;

GDIp.Startup()

Global Canvas := new GDIp.Canvas(0, 0, Settings.Diameter, Settings.Diameter, "+AlwaysOnTop -Caption +ToolWindow +E0x20", "NA", "Canvas", 4, 7)  ;!  +E0x203 (multiple windows???)

	, Primary := []
	, Secondary := []

Global vCx, vCy

CreateSections(Settings.Radius, Settings.Sections, Settings.FakeSections, Settings.Colors, Settings.Overlap)

GDIp.Shutdown()

;=======================================================  Group  ===============;

for i, v in [A_ScriptName, "Core.ahk", "Assert.ahk", "Console.ahk", "String.ahk", "General.ahk", "Color.ahk", "Math.ahk", "GDIp.ahk", "Geometry.ahk"] {
	GroupAdd, % "Library", % v
}

;======================================================== Hook ================;

OnMessage(WindowMessage, "WindowMessage")

OnExit("Exit")

;======================================================== Test ================;

;=======================================================  Other  ===============;

Hotkey, % Settings.Launch.Join(""), Show, On

exit

;=============== Hotkey =======================================================;
;=======================================================  Mouse  ===============;

;====================================================== Keyboard ==============;

#If (WinActive("ahk_group Library"))

	$F10::
		ListVars
		return

	~$^s::
		Critical, On

		Sleep, 200
		Reload

		return

#If

~$Esc::
	if (KeyWait("Esc", "T1")) {
		Exit()
	}

	return

;==============  Include  ======================================================;

#Include, %A_ScriptDir%\..\..\lib\Core.ahk
;#Include, %A_ScriptDir%\..\..\lib\Assert\Assert.ahk

#Include, %A_ScriptDir%\..\..\lib\Console\Console.ahk
#Include, %A_ScriptDir%\..\..\lib\String\String.ahk
#Include, %A_ScriptDir%\..\..\lib\General\General.ahk

#Include, %A_ScriptDir%\..\..\lib\Color\Color.ahk
#Include, %A_ScriptDir%\..\..\lib\Math\Math.ahk
#Include, %A_ScriptDir%\..\..\lib\GDIp.ahk
#Include, %A_ScriptDir%\..\..\lib\Geometry.ahk

;===============  Label  =======================================================;

;============== Function ======================================================;
;======================================================== Hook ================;

WindowMessage(wParam := 0, lParam := 0) {
	switch (wParam) {
		case 0x1000: {
			IniRead, Debug, % A_WorkingDir . "\cfg\Settings.ini", Debug, Debug

			if (!Debug) {
				ToolTip, , , , 20
			}

			return (0)
		}
	}

	return (-1)
}

Exit() {
	Critical, On

	GDIp.Shutdown()

	ExitApp
}

;=======================================================  Other  ===============;

Settings() {

}

Pause() {
	Menu, Tray, ToggleCheck, [&8] Pause
	If (!A_IsSuspended) {
		Menu, Tray, Icon, % (A_IsPaused) ? ("mstscax.dll") : ("wmploc.dll"), % (A_IsPaused) ? (10) : (136), 1
	}

	Hotkey, $RButton, % (A_IsPaused) ? ("Off") : ("On")

	Pause, -1, 1
	Run, % A_WorkingDir . "\bin\Nircmd.exe speak text " . Format("""{}.""", (A_IsPaused) ? ("Paused") : ("Unpaused"))
}

Suspend() {
	winTitle := "ahk_id" . WinGet("ID")

	Menu, Tray, ToggleCheck, [&9] Suspend
	if (!A_IsPaused) {
		Menu, Tray, Icon, % (A_IsSuspended) ? ("mstscax.dll") : ("wmploc.dll"), % (A_IsSuspended) ? (10) : (136), 1
	}

	Suspend, -1
	Run, % A_WorkingDir . "\bin\Nircmd.exe speak text " . Format("""{}.""", (A_IsSuspended) ? ("You're suspended young lady!") : ("Carry on..."))

	if (WinExist(winTitle)) {
		WinActivate, % winTitle
	}
	else {  ;* Restore focus from the taskbar.
		Send, !{Esc}
	}
}

Show() {
	key := RegExReplace(A_ThisHotkey, "[~*$+^! &]|AppsKey")

	KeyWait, % key, T0.5
	if (ErrorLevel) {
		MouseGetPos, vCx, vCy

		for i, child in Canvas.Instances {
			child.Show(Format("x{} y{} {}", vCx - Settings.Radius, vCy - Settings.Radius, (child.Title ~= "((?!sGui00)sGui\d\d)") ? ("Hide") : ("NA")))
		}

		OnMessage("0x200", "MsgHandler"), OnMessage("0x2A3", "MsgHandler"), OnMessage("0x02A1", "MsgHandler")

;		Hotkey, $Esc, Cancel, On

		KeyWait, % key

		Hide()

		return
	}

	Send, % "{" . key . "}"
}

Hide() {
	OnMessage("0x200", ""), OnMessage("0x2A3", ""), OnMessage("0x02A1", "")

	SetTimer, TrackMouse, Delete

;	Hotkey, $Esc, Cancel, Off

	for i, child in Canvas.Instances {
		child.Hide()
	}

	ToolTip()
}

MsgHandler(wParam, lParam, msg, hWnd) {
	Critical, On

	Static currentGui, sections := Settings.Sections

;	x := lParam & 0xFFFF, y := lParam >> 16

	if (!A_Gui) {
		return (0)  ;*** Unwanted WM_MOUSELEAVE: https://stackoverflow.com/questions/51030926/avoid-wm-mouseleave-when-the-cursor-moves-over-a-child-window
	}

	SetTimer, TrackMouse, Delete

;	MsgBox({0x0200: "WM_MOUSEMOVE", 0x02A3: "WM_MOUSELEAVE", 0x02A1: "WM_MOUSEHOVER"}[msg])

	switch (msg) {
		case 0x0200:  ;? 0x0200 = WM_MOUSEMOVE
			if (Debug) {
				ToolTip, % "WM_MOUSEMOVE", vCx - 45, vCy - 10
			}

			OnMessage("0x0200", "")  ;* Stop monitoring WM_MOUSEMOVE messages until WM_MOUSELEAVE is received.

			if (!InStr(A_Gui, "sGui")) {
				if (currentGui) {  ;* This is nessesary to hide sections activated by WheelUp/WheelDown.
					ShowHide(Primary[currentGui], Secondary[currentGui])
				}

				if (A_Gui == "Gui00") {
					if (Debug) {
						ToolTip, % "000 (" currentGui ")", 50, 50, 2
					}

					currentGui := 0
					TrackMouseEvent(hWnd, 0x00000002)

					OnMessage("0x020A", "MsgHandler"), OnMessage("0x020E", "MsgHandler")  ;* Start monitoring WM_MOUSEWHEEL (vertical) and WM_MOUSEWHEEL (horizontal) messages.
				}
				else {
					if (Debug) {
						ToolTip, % "111", 50, 50, 2
					}

					OnMessage("0x020A", ""), OnMessage("0x020E", "")  ;* Stop monitoring WM_MOUSEWHEEL (vertical) and WM_MOUSEWHEEL (horizontal) messages.

					currentGui := (SubStr(A_Gui, -1))
					ShowHide(Secondary[currentGui], Primary[currentGui])

					TrackMouseEvent(Secondary[currentGui].Handle, 0x00000003, 500)  ;? 0x00000003 = TME_LEAVE + TME_HOVER
				}
			}
			else {  ;* Mouse is coming in from outside and entering a sGui variant shown by the `TrackMouse` timer. This also handles the case where the mouse moves too quickly between Gui00 and a sGui variant for WM_MOUSEMOVE to handle the Gui00 entry and instead registers sGui -> sGui.
				if (Debug) {
;					MsgBox(222 " (" currentGui ")")
					ToolTip, % "222", 50, 50, 2
				}

				TrackMouseEvent(hWnd, 0x00000003, 500)
			}

			OnMessage("0x02A3", "MsgHandler")  ;* Start monitoring WM_MOUSELEAVE messages again.

			return (0)

		;* The mouse left the client area of the window specified in a prior call to TrackMouseEvent. All tracking requested by TrackMouseEvent is canceled when this message is generated. The application must call TrackMouseEvent when the mouse reenters its window if it requires further tracking of mouse hover behavior.
		case 0x02A3:  ;? 0x02A3 = WM_MOUSELEAVE
			if (Debug) {
				ToolTip, % "WM_MOUSELEAVE", vCx - 45, vCy - 10
			}

			OnMessage("0x02A3", "")  ;* Stop monitoring WM_MOUSELEAVE messages until WM_MOUSEMOVE is received.

			TrackMouseEvent(hWnd, 0x80000000)  ;? 0x80000000 = TME_CANCEL

			OnMessage("0x0200", "MsgHandler")  ;* Start monitoring WM_MOUSEMOVE messages again.

			if (currentGui && !Primary.Some(Func("TestWindow"))) {  ;*
				Static offset := -90 + 180/sections

				TrackMouse:

				Critical, Off

				MouseGetPos, x, y
				angle := (((angle := DllCall("msvcrt\atan2", "Double", vCy - y, "Double", vCx - x, "Double")*57.295779513082321 + offset) <= 0) ? (angle + 360) : (angle))/360*sections
					, ceiled := Ceil(angle)

				if (currentGui != ceiled) {
					ShowHide(Primary[currentGui], Secondary[currentGui])

					currentGui := SubStr("0" . ceiled, -1)

					if (Debug) {
						if (!currentGui) {
							MsgBox, % "TrackMouse: 111 (" . currentGui . ")"
						}

						if (currentGui == "00") {
							MsgBox, "TrackMouse: 222"
						}

						if (angle <= 0) {
							MsgBox, % "TrackMouse: 333 (" . angle . ")"
						}
					}

					ShowHide(Secondary[currentGui], Primary[currentGui])
				}

				if (Debug) {
					ToolTip, % ((currentGui - 1) ? (currentGui - 1) : (sections)) . " < " . angle + 1 . " > " . ((currentGui < sections) ? (currentGui + 1) : (1)), vCx - 45, vCy - 10
				}

				SetTimer, TrackMouse, -20, 1

				return (0)
			}

			return (0)

		;* The mouse hovered over the client area of the window for the period of time specified in a prior call to TrackMouseEvent. Hover tracking stops when this message is generated. The application must call TrackMouseEvent again if it requires further tracking of mouse hover behavior.
		case 0x02A1:  ;? 0x02A1 = WM_MOUSEHOVER
			Static perpetual := 0

			if (Debug) {
				ToolTip, % "WM_MOUSEHOVER", vCx - 45, vCy - 10
			}

			if (perpetual) {
				TrackMouseEvent(hWnd, 0x00000001)  ;? 0x00000001 = TME_HOVER
			}

			return (0)

		case 0x0201:  ;? 0x0201 = WM_LBUTTONDOWN
			ToolTip, % "WM_LBUTTONDOWN", vCx - 45, vCy - 10
		case 0x0202:  ;? 0x0202 = WM_LBUTTONUP
			ToolTip, % "WM_LBUTTONUP"
		case 0x0203:  ;? 0x0203 = WM_LBUTTONDBLCLK
			ToolTip, % "WM_LBUTTONDBLCLK", vCx - 45, vCy - 10

		case 0x0204:  ;? 0x0204 = WM_RBUTTONDOWN
			ToolTip, % "WM_RBUTTONDOWN", vCx - 45, vCy - 10
		case 0x0205:  ;? 0x0205 = WM_RBUTTONUP
			ToolTip, % "WM_RBUTTONUP", vCx - 45, vCy - 10
		case 0x0206:  ;? 0x0206 = WM_RBUTTONDBLCLK
			ToolTip, % "WM_RBUTTONDBLCLK", vCx - 45, vCy - 10

		case 0x0207:  ;? 0x0207 = WM_MBUTTONDOWN
			ToolTip, % "WM_MBUTTONDOWN", vCx - 45, vCy - 10
		case 0x0208:  ;? 0x0208 = WM_MBUTTONUP
			ToolTip, % "WM_MBUTTONUP", vCx - 45, vCy - 10
		case 0x0209:  ;? 0x0209 = WM_MBUTTONDBLCLK
			ToolTip, % "WM_MBUTTONDBLCLK", vCx - 45, vCy - 10

		case 0x020A:  ;? 0x020A = WM_MOUSEWHEEL (vertical)
			direction := (StrLen(wParam) > 7) ? (-1) : (1)

			if (Debug) {
				ToolTip, % Format("WM_MOUSEWHEEL (vertical): {}", (direction == 1) ? ("Up") : ("Down")), vCx - 45, vCy - 10
			}

;			if (A_TimeSincePriorHotkey >= 25) {
;				if (vCurrentGui) {
;
;				}
;					guiHandler(Gui%vCurrentGui%, sGui%vCurrentGui%)
;				vCurrentGui := SubStr("0" . (vCurrentGui ? ((vCurrentGui += {"$WheelUp": -1, "$WheelDown": 1}[A_ThisHotkey]) > sections) ? 1 : (vCurrentGui < 1) ? sections : vCurrentGui : 1), -1)
;
;				guiHandler(sGui%vCurrentGui%, Gui%vCurrentGui%, 1)
;			}

			return (0)

		case 0x020E:  ;? 0x020E = WM_MOUSEWHEEL (horizontal)
			direction := (StrLen(wParam) > 7) ? (-1) : (1)

			if (Debug) {
				ToolTip, % Format("WM_MOUSEWHEEL (horizontal): {}", (direction == 1) ? ("Right") : ("Left")), vCx - 45, vCy - 10
			}

			return (0)
	}
}

;* CreateTrackMouseEvent(hWnd, (flags), (hoverTime))
;* Description:
	;* Used by the TrackMouseEvent function to track when the mouse pointer leaves a window or hovers over a window for a specified amount of time.
CreateTrackMouseEvent(hWnd, flags := 0x00000002, hoverTime := 400) {  ;: https://docs.microsoft.com/en-us/windows/win32/api/winuser/ns-winuser-trackmouseevent
	Static size := 8 + A_PtrSize*2

	trackMouseEvent := new Structure(size)
	trackMouseEvent.NumPut(0, "UInt", size, "UInt", flags, "Ptr", hWnd, "UInt", hoverTime)

	return (trackMouseEvent)
}  ;? TRACKMOUSEEVENT, *LPTRACKMOUSEEVENT;

TrackMouseEvent(hWnd, flags := 0x00000002, hoverTime := 400) {  ;: https://docs.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-trackmouseevent
	Static trackMouseEvent := CreateTrackMouseEvent(0)

	trackMouseEvent.NumPut(4, "UInt", flags, "Ptr", hWnd, "UInt", hoverTime)

	return (DllCall("TrackMouseEvent", "UInt", trackMouseEvent.Ptr, "UInt"))  ;* Non-zero on success.
}

ShowHide(show, hide) {
	show.Show()
	loop {
		Sleep, 20
	} until (show.IsVisible)

	hide.Hide()
}

TestWindow(gui) {
	MouseGetPos, , , hWnd

	return (gui.Handle == hWnd)
}

;======================================================== GDIp ================;

CreateSections(radius, sections, fakeSections, colors, overlap) {
	diameter := radius*2
		, brushes := [new GDIp.Brush(colors[0]), new GDIp.Brush(0x00000000)]

	Canvas.Graphics.FillEllipse(brushes[0], new Rect(radius/3 - 5, radius/3 - 5, diameter - diameter/3 + 10, diameter - diameter/3 + 10))

	Primary.Push(Canvas.CreateChild(0, 0, diameter, diameter, "+AlwaysOnTop -Caption -DPIScale -SysMenu +ToolWindow", (Debug) ? ("NA") : ("Hide"), "Gui00"))  ;! Canvas.CreateChild(0, 0, diameter, diameter, "+AlwaysOnTop -Caption -DPIScale +LastFound +Owner +OwnDialogs -SysMenu +ToolWindow", Debug, "Gui00")
	Primary[0].Update(Canvas.DC)

	Canvas.Clear()

	Canvas.Graphics.FillEllipse(brushes[0], new Rect(0, 0, diameter, diameter))

	Canvas.Graphics.CompositingMode := 1

	Canvas.Graphics.FillEllipse(brushes[1], new Rect(radius/3 - 10, radius/3 - 10, diameter - diameter/3 + 20, diameter - diameter/3 + 20))  ;* Inner gap of 5 pixels.

	Secondary.Push(Canvas.CreateChild(0, 0, diameter, diameter, "+AlwaysOnTop -Caption -DPIScale +OwnDialogs -SysMenu +ToolWindow +E0x20", (Debug) ? ("NA") : ("Hide"), "sGui00"))
	Secondary[0].Update(Canvas.DC)

	loop, % (sections - fakeSections)*2 {
		if (A_Index == sections - fakeSections + 1) {
			brushes[0] := new GDIp.Brush(colors[1])
		}

		Canvas.Graphics.FillEllipse(brushes[0], new Rect(0, 0, diameter, diameter))

		Canvas.Graphics.Rotate(-180/sections + 360/sections*(A_Index - 1) + (A_Index > sections - fakeSections)*(360/sections)*fakeSections, radius, radius)  ;* Rotate by -180° to have Gui01 top and center.

		Canvas.Graphics.FillEllipse(brushes[1], new Rect(radius/3, radius/3, diameter - diameter/3, diameter - diameter/3))
		Canvas.Graphics.FillRectangle(brushes[1], new Rect(0, 0, radius - overlap/2, diameter))

		Canvas.Graphics.Rotate(360/sections, radius, radius)

		Canvas.Graphics.FillRectangle(brushes[1], new Rect(radius + overlap/2, 0, radius, diameter))

		Canvas.Graphics.Reset()

		if (A_Index <= sections - fakeSections) {
			(Primary[A_Index] := Canvas.CreateChild(0, 0, diameter, diameter, "+AlwaysOnTop -Caption -DPIScale +OwnerGui00 -SysMenu +ToolWindow", "Hide", "Gui" . SubStr("0" . A_Index, -1), 1)).Update(Canvas.DC)
		}
		else {
			index := A_Index - sections + fakeSections
				, (Secondary[index] := Canvas.CreateChild(0, 0, diameter, diameter, "+AlwaysOnTop -Caption -DPIScale +OwnerGui00 -SysMenu +ToolWindow", "Hide", "sGui" . SubStr("0" . index, -1), 1)).Update(Canvas.DC)
		}

		if (Debug) {
			Gui, Show, % "x" . (diameter + 5)*((A_Index > sections - fakeSections) + 1) . " NA"
		}
	}
}

;===============  Class  =======================================================;

Class Settings {
	Debug[] {
		Get {
			IniRead, v, % A_ScriptDir . "\..\..\cfg\Settings.ini", Debug, Debug
			ObjRawSet(this, "Debug", v)

			return (v)
		}
	}

	;* Properties

	Radius[] {
		Get {
			IniRead, v, % A_ScriptDir . "\..\..\cfg\Menu.ini", Properties, Radius
			ObjRawSet(this, "Radius", v)

			return (v)
		}
	}

	Diameter[] {
		Get {
			ObjRawSet(this, "Diameter", v := Settings.Radius*2)

			return (v)
		}
	}

	FakeSections[] {
		Get {
			IniRead, v, % A_ScriptDir . "\..\..\cfg\Menu.ini", Properties, FakeSections
			ObjRawSet(this, "FakeSections", v)

			return (v)
		}
	}

	Sections[] {
		Get {
			IniRead, v, % A_ScriptDir . "\..\..\cfg\Menu.ini", Properties, Sections
			ObjRawSet(this, "Sections", v)

			return (v)
		}
	}

	;* Appearance

	Colors[] {
		Get {
			IniRead, v, % A_ScriptDir . "\..\..\cfg\Menu.ini", Appearance, Colors  ;: https://www.w3schools.com/colors/colors_picker.asp
			ObjRawSet(this, "Colors", v := String.Split(v, ", "))

			return (v)
		}
	}

	Fontsize[] {
		Get {
			IniRead, v, % A_ScriptDir . "\..\..\cfg\Menu.ini", Appearance, Fontsize
			ObjRawSet(this, "Fontsize", v)

			return (v)
		}
	}

	Overlap[] {
		Get {
			IniRead, v, % A_ScriptDir . "\..\..\cfg\Menu.ini", Appearance, Overlap
			ObjRawSet(this, "Overlap", v)

			return (v)
		}
	}

	;* Mechanics

	Clockwise[] {
		Get {
			IniRead, v, % A_ScriptDir . "\..\..\cfg\Menu.ini", Mechanics, Clockwise
			ObjRawSet(this, "Clockwise", v)

			return (v)
		}
	}

	Delay[] {
		Get {
			IniRead, v, % A_ScriptDir . "\..\..\cfg\Menu.ini", Mechanics, Delay
			ObjRawSet(this, "Delay", v)

			return (v)
		}
	}

	Sound[] {
		Get {
			IniRead, v, % A_ScriptDir . "\..\..\cfg\Menu.ini", Mechanics, Sound
			ObjRawSet(this, "Sound", v)

			return (v)
		}
	}

	;* Hotkeys

	Launch[] {
		Get {
			IniRead, v, % A_ScriptDir . "\..\..\cfg\Menu.ini", Hotkeys, Launch
			ObjRawSet(this, "Launch", v := String.Split(v, ", "))

			return (v)
		}
	}
}