;============ Auto-execute ====================================================;
;======================================================  Setting  ==============;

#InstallKeybdHook
#InstallMouseHook
#KeyHistory, 0
#NoEnv
;#NoTrayIcon
;#Persistent
#SingleInstance, Force
#Warn, ClassOverwrite, MsgBox

CoordMode, Mouse, Screen
CoordMode, ToolTip, Screen
;DetectHiddenWindows, On
ListLines, Off
Process, Priority, , High
SendMode, Input
SetBatchLines, -1
SetTitleMatchMode, 2
SetWorkingDir, % A_ScriptDir . "\..\.."

;==============  Include  ======================================================;

#Include, %A_ScriptDir%\..\..\lib\Core.ahk
#Include, %A_ScriptDir%\..\..\lib\Assert\Assert.ahk

#Include, %A_ScriptDir%\..\..\lib\General\General.ahk

#Include, %A_ScriptDir%\..\..\lib\Color\Color.ahk
#Include, %A_ScriptDir%\..\..\lib\Math\Math.ahk
#Include, %A_ScriptDir%\..\..\lib\Geometry.ahk

;======================================================== Menu ================;

Menu, Tray, Icon, % A_WorkingDir . "\res\Image\Icon\2.ico"

;====================================================== Variable ==============;

Global Debug := Settings.Debug
	, WindowMessage := DllCall("RegisterWindowMessage", "Str", "WindowMessage", "UInt")

;======================================================== GDIp ================;

;======================================================== Hook ================;

OnMessage(WindowMessage, "WindowMessage")

OnExit("Exit")

;======================================================== Test ================;

;=======================================================  Other  ===============;

exit

;=============== Hotkey =======================================================;

#If (WinActive(A_ScriptName))

	$F10::
		ListVars
		return

	~$^s::
		Critical, On

		Sleep, 200
		Reload

		return

#If

#If (Debug)

#If

;===============  Label  =======================================================;

;============== Function ======================================================;
;======================================================== Hook ================;

WindowMessage(wParam := 0, lParam := 0) {
	switch (wParam) {
		case 0xCE01:
			MsgBox(111)
		case 0xCE02:
			MsgBox(222)
		case 0xCE03:
			MsgBox(333)
		case 0xCE04:
			MsgBox(444)
		case 0xCE05:
			MsgBox(555)
		case -1:
			IniRead, Debug, % A_WorkingDir . "\cfg\Settings.ini", Debug, Debug

			if (!Debug) {
				ToolTip, , , , 20
			}

			return (0)
	}

	return (-1)
}

Exit() {
	Critical, On

	ExitApp
}

;=======================================================  Other  ===============;

;===============  Class  =======================================================;

Class Settings {
	Debug[] {
		Get {
			Local

			IniRead, debug, % A_ScriptDir . "\..\cfg\Settings.ini", Debug, Debug
			ObjRawSet(this, "Debug", debug)

			return (debug)
		}
	}
}