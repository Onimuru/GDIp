;* ** Useful Links **
;* GDIp enums: https://github.com/lstratman/Win32Interop/blob/master/User32/Enums.cs

GetDC(hWnd := 0) {
	if (!hDC := DllCall("User32\GetDC", "Ptr", hWnd, "Ptr")) {
		throw (Exception(Format("0x{:X}", A_LastError), 0, FormatMessage(A_LastError)))
	}

	Static instance := {"__Class": "__DC"
			, "__Delete": Func("ReleaseDC")}

	(DC := new instance()).Handle := hDC
		, DC.WindowHandle := hWnd

	return (DC)
}

;* GetDCEx(hwnd[, DCX, rgnClip])
;* Parameter:
	;* DCX:
		;? 0x000001: DCX_WINDOW
		;? 0x000002: DCX_CACHE
		;? 0x000020: DCX_PARENTCLIP
		;? 0x000010: DCX_CLIPSIBLINGS
		;? 0x000008: DCX_CLIPCHILDREN
		;? 0x000004: DCX_NORESETATTRS
		;? 0x000400: DCX_LOCKWINDOWUPDATE
		;? 0x000040: DCX_EXCLUDERGN
		;? 0x000100: DCX_EXCLUDEUPDATE
		;? 0x000080: DCX_INTERSECTRGN
		;? 0x000200: DCX_INTERSECTUPDATE
		;? 0x100000: DCX_NORECOMPUTE
		;? 0x200000: DCX_VALIDATE
GetDCEx(hwnd, DCX := 0, rgnClip := 0) {
	if (!hDC := DllCall("User32\GetDCEx", "Ptr", hwnd, "Ptr", rgnClip, "UInt", DCX, "Ptr")) {
		throw (Exception(Format("0x{:X}", A_LastError), 0, FormatMessage(A_LastError)))
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
		throw (Exception(Format("0x{:X}", A_LastError), 0, FormatMessage(A_LastError)))
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