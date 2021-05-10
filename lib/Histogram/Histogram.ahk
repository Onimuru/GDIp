;============ Auto-execute ====================================================;
;======================================================  Setting  ==============;

#KeyHistory, 0
#NoEnv
;#NoTrayIcon
#Persistent
#SingleInstance, Force
#Warn, ClassOverwrite, MsgBox

CoordMode, Mouse, Screen
CoordMode, ToolTip, Screen
ListLines, Off
Process, Priority, , High
SendMode, Input
SetBatchLines, -1
SetTitleMatchMode, 2
SetWorkingDir, % A_ScriptDir . "\..\.."

;==============  Include  ======================================================;

#Include, %A_ScriptDir%\..\..\lib\Core.ahk

#Include, %A_ScriptDir%\..\..\lib\Console\Console.ahk
#Include, %A_ScriptDir%\..\..\lib\General\General.ahk

#Include, %A_ScriptDir%\..\..\lib\Color\Color.ahk
#Include, *i %A_ScriptDir%\..\..\lib\Math\Math.ahk

;======================================================== Menu ================;

Menu, Tray, Icon, % A_WorkingDir . "\res\Image\Icon\Triangle.ico"

;====================================================== Variable ==============;

Global Debug := Settings.Debug
	, WindowMessage := DllCall("RegisterWindowMessage", "Str", "WindowMessage", "UInt")

;=======================================================  Group  ===============;

for i, v in [A_ScriptName, "Core.ahk", "Assert.ahk", "Console.ahk", "String.ahk", "General.ahk", "Color.ahk", "Math.ahk", "GDIp.ahk", "Geometry.ahk"] {
	GroupAdd, % "Library", % v
}

;======================================================== Test ================;

if (Debug) {
	data1 := [], data2 := [],data3 := []

	loop, % 5000 {
		data2.Push(Math.Random.MarsagliaPolar(-1)), data3.Push(Math.Random.Ziggurat(1))
	}

	loop, % (5000, min := 0x7FFFFFFF, max := -0x7FFFFFFF) {
		index := A_Index - 1
			, number1 := data2[index]
			, number2 := data3[index]

		if (min > number1) {
			min := number1
		}

		if (min > number2) {
			min := number2
		}

		if (max < number1) {
			max := number1
		}

		if (max < number2) {
			max := number2
		}
	}

	loop, % 5000 {
		data1.Push(Math.Random.Uniform(min, max))
	}

;	new Histogram(A_ScreenWidth - (500 + 50 + 10), 50, 500, 350, 25, "R", data1, data2, data3)

	new Histogram(A_ScreenWidth - (350 + 50 + 10), 50, 350, 350, 10, "R", [1, 2, 3, 4, 5, 5, 6, 7, 8, 9], [15, 15, 15, 15, 15, 16, 16, 16, 16, 16], [21, 22, 23, 24, 25, 25, 26, 27, 28, 29])
}

;=======================================================  Other  ===============;

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

LowLevelKeyboardProc(nCode, wParam, lParam) {  ;: https://gist.github.com/Onimuru/56174b571cea83882f9e2634fa4fe4d4
	Critical, On

	if (wParam == 0x100) {  ;? 0x100 = WM_KEYDOWN
		if (GetKeyName(Format("vk{:X}", NumGet(lParam + 0, "UInt"))) == "Escape") {
			while (Histogram.Instances.Count()) {
				Gui, % Format("{}: Destroy", Histogram.Instances.RemoveAt(Histogram.Instances.MinIndex()).Handle)
			}

			Histogram.Delete("KeyboardHook")

			return (0)
		}
	}

	return (DllCall("CallNextHookEx", "Ptr", 0, "Int", nCode, "UInt", wParam, "UInt", lParam))
}

SetWindowsHookEx(idHook, callback) {
	if (!hHook := DllCall("SetWindowsHookEx", "Int", idHook, "Ptr", RegisterCallback(callback, "Fast"), "Ptr", DllCall("GetModuleHandle", "UInt", 0, "Ptr"), "UInt", 0, "Ptr")) {
		throw (Exception(Format("0x{:X}", A_LastError), -1, FormatMessage(A_LastError)))
	}

	Static instance := {"__Class": "__HookEx"
			, "__Delete": Func("UnhookWindowsHookEx")}

	(hookEx := new instance()).Handle := hHook

	return (hookEx)
}

UnhookWindowsHookEx(hookEx) {
	if (!DllCall("UnhookWindowsHookEx", "Ptr", hookEx.Handle, "UInt")) {
		throw (Exception(Format("0x{:X}", A_LastError), -1, FormatMessage(A_LastError)))
	}

	return (True)
}

TrackMouseEvent(hWNDTrack, dwFlags := 0x00000002, dwHoverTime := 400) {  ;: https://docs.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-trackmouseevent
	Static cbSize := 8 + (A_PtrSize*2)

	VarSetCapacity(sEventTrack, cbSize, 0)
		, NumPut(cbSize, sEventTrack, 0, "UInt"), NumPut(dwFlags, sEventTrack, 4, "UInt"), NumPut(hWNDTrack, sEventTrack, 8, "Ptr"), NumPut(dwHoverTime, sEventTrack, 8 + A_Ptrsize, "UInt")  ;: https://docs.microsoft.com/en-us/windows/win32/api/winuser/ns-winuser-trackmouseevent

	return, (DllCall("TrackMouseEvent", "UInt", &sEventTrack, "UInt"))  ;* Non-zero on success.
}

MsgHandler(wParam, lParam, msg, hWND) {
;	ToolTip, % (x := lParam & 0xFFFF) ", " (y := lParam >> 16)  ;* Relative to `A_Gui`.

	if (!A_Gui) {  ;* This is here to ignore `ToolTip` windows.
		return (0)
	}

	switch (msg) {
		case 0x0200: {  ;? 0x0200 = WM_MOUSEMOVE
			Static tracking

			if (!tracking) {
;				ToolTip, % "WM_MOUSEMOVE"

				tracking := TrackMouseEvent(hWND, 0x00000003)  ;? 0x00000003 = TME_LEAVE + TME_HOVER
			}
		}
		;* The mouse left the client area of the window specified in a prior call to TrackMouseEvent. All tracking requested by TrackMouseEvent is canceled when this message is generated. The application must call TrackMouseEvent when the mouse reenters its window if it requires further tracking of mouse hover behavior.
		case 0x02A3: {  ;? 0x02A3 = WM_MOUSELEAVE
			tracking := !TrackMouseEvent(hWND, 0x80000000)  ;? 0x80000000 = TME_CANCEL
		}
		;* The mouse hovered over the client area of the window for the period of time specified in a prior call to TrackMouseEvent. Hover tracking stops when this message is generated. The application must call TrackMouseEvent again if it requires further tracking of mouse hover behavior.
		case 0x02A1: {  ;? 0x02A1 = WM_MOUSEHOVER
			Static perpetual := 0

			if (perpetual) {
				tracking := TrackMouseEvent(hWND, 0x00000001)  ;? 0x00000001 = TME_HOVER
			}
		}
		case 0x0201: {  ;? 0x0201 = WM_LBUTTONDOWN
			Histogram.Delete("KeyboardHook")

			WinGetPos, owx, owy
			MouseGetPos, omx, omy

			while (GetKeyState("LButton", "P")) {
				if (GetKeyState("Escape", "P")) {
					Gui, Show, % Format("x{} y{}", owx, owy)

					break
				}

				WinGetPos, cwx, cwy
				MouseGetPos, cmx, cmy

				Gui, Show, % Format("x{} y{}", cwx - omx + (omx := cmx), cwy - omy + (omy := cmy))

				Sleep, -1
			}

			KeyWait, Escape

			Histogram.KeyboardHook := SetWindowsHookEx(13, "LowLevelKeyboardProc")
		}
;		case 0x0202:  ;? 0x0202 = WM_LBUTTONUP
;			ToolTip, % "WM_LBUTTONUP"
;		case 0x0203:  ;? 0x0203 = WM_LBUTTONDBLCLK
;			ToolTip, % "WM_LBUTTONDBLCLK"
;
;		case 0x0204:  ;? 0x0204 = WM_RBUTTONDOWN
;			ToolTip, % "WM_RBUTTONDOWN"
;		case 0x0205:  ;? 0x0205 = WM_RBUTTONUP
;			ToolTip, % "WM_RBUTTONUP"
;		case 0x0206:  ;? 0x0206 = WM_RBUTTONDBLCLK
;			ToolTip, % "WM_RBUTTONDBLCLK"
;
;		case 0x0207:  ;? 0x0207 = WM_MBUTTONDOWN
;			ToolTip, % "WM_MBUTTONDOWN"
;		case 0x0208:  ;? 0x0208 = WM_MBUTTONUP
;			ToolTip, % "WM_MBUTTONUP"
;		case 0x0209:  ;? 0x0209 = WM_MBUTTONDBLCLK
;			ToolTip, % "WM_MBUTTONDBLCLK"
;
;		case 0x020A:  ;? 0x020A = WM_MOUSEWHEEL (Vertical)
;			ToolTip, % "WM_MOUSEWHEEL"
;		case 0x020E:  ;? 0x020E = WM_MOUSEWHEEL (Horizontal)
;			ToolTip, % "WM_MOUSEWHEEL"
	}
}

;======================================================== Math ================;

Min2(array) {
	Local

	for i, number in (array, min := 0x7FFFFFFF) {
		if (min > number) {
			min := number
		}
	}

	return (min)
}

Max2(array) {
	Local

	for i, number in (array, max := -0x7FFFFFFF) {
		if (max < number) {
			max := number
		}
	}

	return (max)
}

Mean(array) {
	Local

	for i, number in (array, total := 0, count := 0) {
		total += number, count++
	}

	return (total/count)
}

;======================================================== GDIp ================;

;===============  Class  =======================================================;

Class Settings {
	Debug[] {
		Get {
			IniRead, v, % A_ScriptDir . "\..\cfg\Settings.ini", Debug, Debug
			ObjRawSet(this, "Debug", v)

			return (v)
		}
	}
}

Class Histogram {
	Static Instances := []

	__New(x, y, width, height, bins, options := "", data*) {
;		Local

		Gui, New, +AlwaysOnTop -Caption +ToolWindow +hWndhWnd +E0x80000
		Gui, Show, NA

		this.Instances[&(instance := {"Handle": hWnd
			, "Base": this.__Histogram})] := instance

		GDIp.Startup()

		instance.DC := GDI.CreateCompatibleDC()
		instance.Bitmap := GDI.CreateDIBSection(CreateBitmapInfoHeader(width, -height), instance.DC)
			, instance.DC.SelectObject(instance.Bitmap)

		(instance.Graphics := GDIp.CreateGraphicsFromDC(instance.DC)).SetSmoothingMode(0)
			, instance.Graphics.SetInterpolationMode(0)

		brush := [GDIp.CreateBrush(this.BackgroundColor)], pen := [GDIp.CreatePen(this.BorderColor, 1)]

		bins := [bins]

		for i, v in (data, min := 0x7FFFFFFF, max := -0x7FFFFFFF) {
			for i, v in v {
				if (min > v) {
					min := v
				}

				if (max < v) {
					max := v
				}
			}
		}

		for i, v in (data, threshold := (max - min)/bins[0]) {  ;* Determine the threshold for each bin.
			depth := Round(depth) + 1
				, (bins[depth] := []).Length := bins[0], bins[depth].Fill(0)

			for i, v in v {
				loop, % bins[0] {
					if (v <= min + threshold*A_Index) {
						bins[depth][A_Index - 1]++

						break
					}
				}
			}
		}

;		if (Debug) {
;			loop, % bins[0] {
;				s .= "    " . min + threshold*A_Index . ": " . bins[3][A_Index - 1] . "`n"
;			}
;
;			MsgBox("threshold = " . threshold
;				. "`nbins =`n" . s)
;		}

		offset := Max(width, height)/10
			, background := {"x": 0
				, "y": 0
				, "Width": width
				, "Height": height}
			, outer := {"x": Round(offset/2)
				, "y": Round(offset/2)
				, "Width": Round(width - offset)
				, "Height": Round(height - offset)}
			, inner := {"x": Round(offset/2 + offset/3)
				, "y": Round(offset/2)
				, "Width": (outer.Width & 1) ? (Ceil(outer.Width - offset/3)) : (Floor(outer.Width - offset/3))
				, "Height": Round(outer.Height - offset/3)}

		instance.Graphics.FillRectangle(brush[0], background)  ;* Background.

		for i, v in (bins, max := -0x7FFFFFFF) {
			for i, v in v {
				if (max < v) {
					max := v
				}
			}
		}

		loop, % (depth, h := inner.Height/(max*1), w := (inner.Width*1 - 1)/bins[0]) {  ;* Determine y-axis and x-axis spacing with a ratio of the available space divided by the largest bin and the number of bins respectively.
			for i, v in (bins[A_Index], index := A_Index) {
				Static colors := [0xFAEBD7, 0x00FFFF, 0x7FFFD4, 0xF0FFFF, 0xF5F5DC, 0xFFE4C4, 0x000000, 0xFFEBCD, 0x0000FF, 0x8A2BE2, 0xA52A2A, 0xDEB887, 0x5F9EA0, 0x7FFF00, 0xD2691E, 0xFF7F50, 0x6495ED, 0xFFF8DC, 0xDC143C, 0x00FFFF, 0x00008B, 0x008B8B, 0xB8860B, 0xA9A9A9, 0x006400, 0xBDB76B, 0x8B008B, 0x556B2F, 0xFF8C00, 0x9932CC, 0x8B0000, 0xE9967A, 0x8FBC8F, 0x483D8B, 0x2F4F4F, 0x00CED1, 0x9400D3, 0xFF1493, 0x00BFFF, 0x696969, 0x1E90FF, 0xB22222, 0xFFFAF0, 0x228B22, 0xFF00FF, 0xDCDCDC, 0xF8F8FF, 0xFFD700, 0xDAA520, 0x808080, 0x008000, 0xADFF2F, 0xF0FFF0, 0xFF69B4, 0xCD5C5C, 0x4B0082, 0xFFFFF0, 0xF0E68C, 0xE6E6FA, 0xFFF0F5, 0x7CFC00, 0xFFFACD, 0xADD8E6, 0xF08080, 0xE0FFFF, 0xFAFAD2, 0xD3D3D3, 0x90EE90, 0xFFB6C1, 0xFFA07A, 0x20B2AA, 0x87CEFA, 0x778899, 0xB0C4DE, 0xFFFFE0, 0x00FF00, 0x32CD32, 0xFAF0E6, 0xFF00FF, 0x800000, 0x66CDAA, 0x0000CD, 0xBA55D3, 0x9370DB, 0x3CB371, 0x7B68EE, 0x00FA9A, 0x48D1CC, 0xC71585, 0x191970, 0xF5FFFA, 0xFFE4E1, 0xFFE4B5, 0xFFDEAD, 0x000080, 0xFDF5E6, 0x808000, 0x6B8E23, 0xFFA500, 0xFF4500, 0xDA70D6, 0xEEE8AA, 0x98FB98, 0xAFEEEE, 0xDB7093, 0xFFEFD5, 0xFFDAB9, 0xCD853F, 0xFFC0CB, 0xDDA0DD, 0xB0E0E6, 0x800080, 0xFF0000, 0xBC8F8F, 0x4169E1, 0x8B4513, 0xFA8072, 0xF4A460, 0x2E8B57, 0xFFF5EE, 0xA0522D, 0xC0C0C0, 0x87CEEB, 0x6A5ACD, 0x708090, 0xFFFAFA, 0x00FF7F, 0x4682B4, 0xD2B48C, 0x008080, 0xD8BFD8, 0xFF6347, 0x40E0D0, 0xEE82EE, 0xF5DEB3, 0xFFFFFF, 0xF5F5F5, 0xFFFF00, 0x9ACD32]

				v := {"x": inner.x + w*i, "y": inner.y + inner.Height - h*v, "Width": w, "Height": h*v}

				Random, u, 0, 139

				rgb := (Debug) ? ([0x00FF00, 0xFF0000, 0x0000FF][index - 1]) : (colors[u])

				instance.Graphics.FillRectangle(GDIp.CreateBrush(0x7F << 24 | rgb), v), v.Width += 1
				instance.Graphics.DrawRectangle(GDIp.CreatePen(0xFF << 24 | rgb, 1), v)
			}
		}

;		instance.Graphics.DrawRectangle(pen[0], outer)  ;* Outer.
;		instance.Graphics.DrawRectangle(pen[0], inner)  ;* Inner.

		loop, % ((n := 10) + 1, h := inner.Height/n) {
			v := h*(A_Index - 1) - (A_Index != 1)

			instance.Graphics.DrawLine(pen[0], {"x": outer.x - 5 + 1, "y": outer.y + v}, {"x": outer.x, "y": outer.y + v})  ;* y-axis indicators.
		}

		instance.Graphics.DrawLine(pen[0], {"x": outer.x, "y": outer.y}, {"x": outer.x, "y": outer.y + v})

		loop, % (1 + (n := bins[0]//2), w := (inner.Width/n)) {
			v := w*(A_Index - 1) - (A_Index != 1)

			instance.Graphics.DrawLine(pen[0], {"x": inner.x + v, "y": outer.y + outer.Height}, {"x": inner.x + v, "y": outer.y + outer.Height + 5 - 2})  ;* x-axis indicators.
		}

		instance.Graphics.DrawLine(pen[0], {"x": inner.x, "y": outer.y + outer.Height - 1}, {"x": inner.x + v, "y": outer.y + outer.Height - 1})

		instance.Update(x, y, width, height)

		GDIp.Shutdown()

;		if (Debug) {
;			for i, v in (data, max := -0x7FFFFFFF) {
;				for i, v in v {
;					length := StrLen(v)
;
;					if (max < length) {
;						max := length
;					}
;				}
;			}
;
;			buffer := StrReplace(Format("{:0" . (max*1.5)//2 . "}", 0), "0", A_Space), length := StrLen(buffer)
;				, length := StrLen(buffer)
;
;			Gui, MsgBox: New, +AlwaysOnTop +LastFound +ToolWindow, Beep Boop
;			Gui, Color, 0xFFFFFF
;			Gui, Font, s10, Fira Code Retina
;
;			for i, v in (data, string := buffer . buffer . "Mean" . buffer . buffer . " Min " . buffer . buffer . " Max " . buffer . "`n") {   ;" "
;				mean := Mean(v), min := Min2(v), max := Max2(v)
;					, string .= SubStr("0" . i, -1) . SubStr(buffer . buffer . mean . buffer, 1 + 4 + InStr(mean, "-"), (length*2)*1.5 + Ceil(StrLen(mean)/2))
;						. SubStr(buffer . min . buffer, 1 + 4 + InStr(min, "-"), (length*2)*1.5 + Ceil(StrLen(min)/2) - 6)
;						. SubStr(buffer . max . buffer, 1 + 4 + InStr(max, "-"), (length*2)*1.5 + Ceil(StrLen(max)/2) - 6) . "`n"
;			}
;
;			Gui, Add, Text, 0x000000, % string
;			Gui, Show, % "NA"
;		}

		if (!Histogram.KeyboardHook) {
			Histogram.KeyboardHook := SetWindowsHookEx(13, "LowLevelKeyboardProc")

			for i, v in [0x0200, 0x02A3, 0x02A1, 0x0201, 0x0202, 0x0203, 0x0204, 0x0205, 0x0206, 0x0207, 0x0208, 0x0209, 0x020A, 0x020E] {
				OnMessage(v, "MsgHandler")
			}
		}

		return
	}

	Class __Histogram {
		Update(x, y, width, height, alpha := 0xFF) {
			if (!DllCall("User32\UpdateLayeredWindow", "Ptr", this.Handle, "Ptr", 0, "Int64*", x | y << 32, "Int64*", width | height << 32, "Ptr", this.DC.Handle, "Int64*", 0, "UInt", 0, "UInt*", alpha << 16 | 1 << 24, "UInt", 0x00000002, "UInt")) {
				throw (Exception(Format("0x{:X}", A_LastError), 0, FormatMessage(A_LastError)))
			}
		}
	}

	BorderColor[] {
		Get {
			return (0xFF000000)
		}
	}

	BackgroundColor[] {
		Get {
			return (0xFFFFFFFF)
		}
	}
}