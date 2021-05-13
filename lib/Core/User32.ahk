;* ** Useful Links **
;* User32 enums: https://github.com/lstratman/Win32Interop/blob/master/User32/Enums.cs

/*
;* enum DCX
	0x00000001 = DCX_WINDOW
	0x00000002 = DCX_CACHE
	0x00000020 = DCX_PARENTCLIP
	0x00000010 = DCX_CLIPSIBLINGS
	0x00000008 = DCX_CLIPCHILDREN
	0x00000004 = DCX_NORESETATTRS
	0x00000400 = DCX_LOCKWINDOWUPDATE
	0x00000040 = DCX_EXCLUDERGN
	0x00000100 = DCX_EXCLUDEUPDATE
	0x00000080 = DCX_INTERSECTRGN
	0x00000200 = DCX_INTERSECTUPDATE
	0x00100000 = DCX_NORECOMPUTE
	0x00200000 = DCX_VALIDATE

;* enum WS
	0x00000000 = WS_OVERLAPPED || WS_TILED
	0x80000000 = WS_POPUP
	0x40000000 = WS_CHILD || WS_CHILDWINDOW
	0x20000000 = WS_MINIMIZE || WS_ICONIC
	0x10000000 = WS_VISIBLE
	0x08000000 = WS_DISABLED
	0x04000000 = WS_CLIPSIBLINGS
	0x02000000 = WS_CLIPCHILDREN
	0x01000000 = WS_MAXIMIZE
	0x00C00000 = WS_CAPTION
	0x00800000 = WS_BORDER
	0x00400000 = WS_DLGFRAME
	0x00200000 = WS_VSCROLL
	0x00100000 = WS_HSCROLL
	0x00080000 = WS_SYSMENU
	0x00040000 = WS_THICKFRAME || WS_SIZEBOX
	0x00020000 = WS_GROUP
	0x00010000 = WS_TABSTOP
	0x00020000 = WS_MINIMIZEBOX
	0x00010000 = WS_MAXIMIZEBOX
	WS_TILEDWINDOW = (WS_OVERLAPPED | WS_CAPTION | WS_SYSMENU | WS_THICKFRAME | WS_MINIMIZEBOX | WS_MAXIMIZEBOX)
	WS_OVERLAPPEDWINDOW = (WS_OVERLAPPED | WS_CAPTION | WS_SYSMENU | WS_THICKFRAME | WS_MINIMIZEBOX | WS_MAXIMIZEBOX)
	WS_POPUPWINDOW = (WS_POPUP | WS_BORDER | WS_SYSMENU)
*/

GetDC(hWnd := 0) {
	if (!hDC := DllCall("User32\GetDC", "Ptr", hWnd, "Ptr")) {
		throw (Exception(Format("0x{:X}", A_LastError), , FormatMessage(A_LastError)))
	}

	Static instance := {"__Class": "__DC"
			, "__Delete": Func("ReleaseDC")}

	(DC := new instance()).Handle := hDC
		, DC.WindowHandle := hWnd

	return (DC)
}

;* GetDCEx(hwnd[, flags, rgnClip])
;* Parameter:
	;* flags - See DCX enumeration.
GetDCEx(hwnd, flags := 0, rgnClip := 0) {
	if (!hDC := DllCall("User32\GetDCEx", "Ptr", hwnd, "Ptr", rgnClip, "UInt", flags, "Ptr")) {
		throw (Exception(Format("0x{:X}", A_LastError), , FormatMessage(A_LastError)))
	}

	Static instance := {"__Class": "__DC"
			, "__Delete": Func("ReleaseDC")}

	(DC := new instance()).Handle := hDC
		, DC.WindowHandle := hWnd

	return (DC)
}

ReleaseDC(DC) {
	if (!DC.Handle) {
		MsgBox("ReleaseDC()")
	}

	if (!DllCall("User32\ReleaseDC", "Ptr", DC.WindowHandle, "Ptr", DC.Handle, "Int")) {
		throw (Exception(Format("0x{:X}", A_LastError), , FormatMessage(A_LastError)))
	}

	return (True)
}

GetDesktopWindow() {
	return (DllCall("User32\GetDesktopWindow", "Ptr"))
}

;* Parameter:
	;* flags:
		;? 1 = PW_CLIENTONLY
PrintWindow(hWnd, DC, flags := 2) {
	if (!DllCall("User32\PrintWindow", "Ptr", hWnd, "Ptr", DC.Handle, "UInt", flag, "Int"s)) {
		throw (Exception(Format("0x{:X}", A_LastError), , FormatMessage(A_LastError)))
	}

	return (True)
}

UpdateLayeredWindow(hWnd, DC, x := "", y := "", width := "", height := "", alpha := 0xFF) {
	if (x == "" || y == "" || width == "" || height == "") {
		Static rect := CreateRect(0, 0, 0, 0, "UInt")

		if (DllCall("Dwmapi\DwmGetWindowAttribute", "Ptr", hWnd, "UInt", 9, "Ptr", rect.Ptr, "UInt", 16, "UInt")) {
			if (!DllCall("User32\GetWindowRect", "Ptr", hWnd, "Ptr", rect.Ptr, "UInt")) {
				throw (Exception(Format("0x{:X}", A_LastError), 0, FormatMessage(A_LastError)))
			}
		}

		if (x == "") {
			x := rect.NumGet(0, "Int")

			if (width == "") {
				width := Abs(rect.NumGet(8, "Int") - x)
			}
		}
		else if (width == "") {
			width := Abs(rect.NumGet(8, "Int") - rect.NumGet(0, "Int"))
		}

		if (y == "") {
			y := rect.NumGet(4, "Int")

			if (height == "") {
				height := Abs(rect.NumGet(12, "Int") - y)
			}
		}
		else if (height == "") {
			height := Abs(rect.NumGet(12, "Int") - rect.NumGet(4, "Int"))
		}
	}

	if (!DllCall("User32\UpdateLayeredWindow", "Ptr", hWnd, "Ptr", 0, "Int64*", x | y << 32, "Int64*", width | height << 32, "Ptr", DC.Handle, "Int64*", 0, "UInt", 0, "UInt*", alpha << 16 | 1 << 24, "UInt", 0x00000002, "UInt")) {
		throw (Exception(Format("0x{:X}", A_LastError), 0, FormatMessage(A_LastError)))
	}

	return (True)
}