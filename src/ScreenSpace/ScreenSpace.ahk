;=====         Auto-execute         =========================;
;===============           Settings           ===============;

#Include, %A_ScriptDir%\..\..\..\AutoHotkey\lib\Color.ahk
#Include, %A_ScriptDir%\..\..\..\AutoHotkey\lib\General.ahk
#Include, %A_ScriptDir%\..\..\..\AutoHotkey\lib\ObjectOriented.ahk
#Include, %A_ScriptDir%\..\..\..\AutoHotkey\lib\Math.ahk
#Include, %A_ScriptDir%\..\..\lib\GDIp.ahk
#Include, %A_ScriptDir%\..\..\lib\Geometry.ahk

#KeyHistory 0
#NoEnv
#Persistent
#SingleInstance, Force

CoordMode, Mouse, Screen
ListLines, Off
Process, Priority, , R
SetBatchLines, -1
SetWorkingDir, % A_ScriptDir . "\..\.."

;===============           Variable           ===============;

IniRead, vDebug, % A_WorkingDir . "\..\AutoHotkey\cfg\Settings.ini", Debug, Debug
Global vDebug

Global oCanvas := new GDIp.Canvas([0, 0, A_ScreenWidth, A_ScreenHeight], "-Caption +AlwaysOnTop +ToolWindow +OwnDialogs +E0x20")
	, oPen := [new GDIp.Pen(new GDIp.LinearGradientBrush([5, 5, oCanvas.Size.Width - 10, oCanvas.Size.Height - 10], [Color.Random(), Color.Random()]))]

;===============            Other             ===============;

oCanvas.DrawLines(oPen[0], [{"x": 0, "y": 0}, {"x": A_ScreenWidth/2 - 1, "y": 0}, {"x": A_ScreenWidth/2 - 1, "y": A_ScreenHeight/2 - 1}, {"x": 0, "y": A_ScreenHeight/2 - 1}, {"x": 0, "y": 0}])  ;* Top left.
oCanvas.DrawLines(oPen[0], [{"x": A_ScreenWidth/2, "y": 0}, {"x": A_ScreenWidth - 1, "y": 0}, {"x": A_ScreenWidth - 1, "y": A_ScreenHeight/2 - 1}, {"x": A_ScreenWidth/2, "y": A_ScreenHeight/2 - 1}, {"x": A_ScreenWidth/2, "y": 0}])  ;* Top right.
oCanvas.DrawLines(oPen[0], [{"x": A_ScreenWidth/2, "y": A_ScreenHeight/2}, {"x": A_ScreenWidth - 1, "y": A_ScreenHeight/2}, {"x": A_ScreenWidth - 1, "y": A_ScreenHeight - 1}, {"x": A_ScreenWidth/2, "y": A_ScreenHeight - 1}, {"x": A_ScreenWidth/2, "y": A_ScreenHeight/2}])  ;* Bottom right.
oCanvas.DrawLines(oPen[0], [{"x": 0, "y": A_ScreenHeight/2}, {"x": A_ScreenWidth/2 - 1, "y": A_ScreenHeight/2}, {"x": A_ScreenWidth/2 - 1, "y": A_ScreenHeight - 1}, {"x": 0, "y": A_ScreenHeight - 1}, {"x": 0, "y": A_ScreenHeight/2}])  ;* Bottom left

oCanvas.Update()

Exit

;=====            Hotkey            =========================;

#If (WinActive(A_ScriptName) || WinActive("GDIp.ahk") || WinActive("Geometry.ahk"))

	~$^s::
		Critical

		Sleep, 200
		Reload
		Return

	$F10::ListVars

#IF

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