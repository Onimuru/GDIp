;============ Auto-execute ====================================================;
;======================================================  Setting  ==============;

;#NoTrayIcon
#SingleInstance
#Warn All, MsgBox
#Warn LocalSameAsGlobal, Off
#WinActivateForce

CoordMode("Mouse", "Screen")
CoordMode("ToolTip", "Screen")
;DetectHiddenWindows(True)
InstallKeybdHook(True)
InstallMouseHook(True)
ListLines(False)
Persistent(True)
ProcessSetPriority("High")
SetKeyDelay(-1, -1)
SetWinDelay(-1)
SetWorkingDir(A_ScriptDir . "\..\..")

;==============  Include  ======================================================;

#Include %A_ScriptDir%\..\..\lib\Core.ahk

#Include %A_ScriptDir%\..\..\lib\Console\Console.ahk
#Include %A_ScriptDir%\..\..\lib\General\General.ahk

#Include %A_ScriptDir%\..\..\lib\Color\Color.ahk
#Include %A_ScriptDir%\..\..\lib\Math\Math.ahk
;#Include %A_ScriptDir%\..\..\lib\Geometry.ahk

;======================================================== Menu ================;

TraySetIcon(A_WorkingDir . "\res\Image\Icon\2.ico")

;====================================================== Variable ==============;

global A_Debug := IniRead(A_WorkingDir . "\cfg\Settings.ini", "Debug", "Debug")
	, A_WindowMessage := DllCall("RegisterWindowMessage", "Str", "WindowMessage", "UInt")

;======================================================== GDIp ================;

;======================================================== Hook ================;

OnMessage(A_WindowMessage, __WindowMessage)

OnExit(__Exit)

;======================================================== Test ================;

;=======================================================  Other  ===============;

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

#HotIf (A_Debug)

#HotIf

;===============  Label  =======================================================;

;============== Function ======================================================;
;======================================================== Hook ================;

__WindowMessage(wParam := 0, lParam := 0, msg := 0, hWnd := 0) {
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
		case 0x1000:
			if (!(A_Debug := IniRead(A_WorkingDir . "\cfg\Settings.ini", "Debug", "Debug"))) {
				ToolTip("", , , 20)
			}

			return (True)
	}

	return (-1)
}

__Exit(exitReason, exitCode) {
	Critical(True)

	ExitApp
}

;=======================================================  Other  ===============;

GetTime() {
	DllCall("QueryPerformanceCounter", "Int64*", &(current := 0))

	return (current)
}

;===============  Class  =======================================================;