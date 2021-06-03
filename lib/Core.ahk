;============ Auto-Execute ====================================================;
;======================================================  Setting  ==============;

#Requires AutoHotkey v2.0-a134-d3d43350

;======================================================  Include  ==============;

#Include %A_LineFile%\..\ObjectOriented\Array.ahk
#Include %A_LineFile%\..\ObjectOriented\Object.ahk
#Include %A_LineFile%\..\String\String.ahk

#Include %A_LineFile%\..\Structure\Structure.ahk

#Include %A_LineFile%\..\Core\Direct2D.ahk
#Include %A_LineFile%\..\Core\GDI.ahk
#Include %A_LineFile%\..\Core\GDIp.ahk

;============== Function ======================================================;
;======================================================  Library  ==============;

LoadLibrary(libraryName) {
	static loaded := FreeLibrary("__SuperSecretString")

	if (!loaded.HasProp(libraryName)) {
		if (!(ptr := DllCall("Kernel32\LoadLibrary", "Str", libraryName, "Ptr"))) {
			throw (ErrorFromMessage(DllCall("Kernel32\GetLastError")))
		}

		loaded.%libraryName% := {Count: 0
			, Ptr: ptr}
	}

	loaded.%libraryName%.Count++

	return (loaded.%libraryName%.Ptr)
}

FreeLibrary(libraryName) {
	static loaded := {ComCtl32: {Ptr: DllCall("Kernel32\GetModuleHandle", "Str", "ComCtl32", "Ptr")}, Gdi32: {Ptr: DllCall("Kernel32\GetModuleHandle", "Str", "Gdi32", "Ptr")}, Kernel32: {Ptr: DllCall("Kernel32\GetModuleHandle", "Str", "Kernel32", "Ptr")}, User32: {Ptr: DllCall("Kernel32\GetModuleHandle", "Str", "User32", "Ptr")}}  ;* "User32", "Kernel32", "ComCtl32" and "Gdi32" are already loaded.

	if (libraryName == "__SuperSecretString") {
		return (loaded)
	}
	else if (Type(libraryName) == "Object") {
		if (--loaded.%libraryName := libraryName.Name%.Count) {
			return (False)
		}
	}

	if (!(libraryName ~= "i)ComCtl32|Gdi32|Kernel32|User32")) {
		if (loaded.HasProp(libraryName)) {
			loaded.DeleteProp(libraryName)
		}

		if (handle := DllCall("Kernel32\GetModuleHandle", "Str", libraryName, "Ptr")) {  ;* If the library module is already in the address space of the script's process.
			if (!DllCall("Kernel32\FreeLibrary", "Ptr", handle, "UInt")) {
				throw (ErrorFromMessage(DllCall("Kernel32\GetLastError")))
			}

			return (True)
		}
	}

	return (False)
}

GetProcAddress(libraryName, functionName) {
	if (functionName == "*") {
		static library := {Call: (*) => ({Class: "Library",
			__Delete: FreeLibrary})}

		(o := library.Call()).Name := libraryName
			, p := (ptr := LoadLibrary(libraryName)) + NumGet(ptr + 0x3C, "Int") + 24

		static offset := (A_PtrSize == 4) ? (92) : (108)

		if (NumGet(p + offset, "UInt") < 1 || (ts := NumGet(p + offset + 4, "UInt") + ptr) == ptr || (te := NumGet(p + offset + 8, "UInt") + ts) == ts) {
			return (o)
		}

		loop (n := ptr + NumGet(ts + 32, "UInt"), NumGet(ts + 24, "UInt")) {
			if (p := NumGet(n + (A_Index - 1)*4, "UInt")) {
				o.%f := StrGet(ptr + p, "CP0")% := DllCall("Kernel32\GetProcAddress", "Ptr", ptr, "AStr", f, "Ptr")

				if (SubStr(f, -1) == "W") {
					o.%SubStr(f, 1, -1)% := o.%f%
				}
			}
		}

		return (o)
	}

	return (DllCall("Kernel32\GetProcAddress", "Ptr", DllCall("Kernel32\GetModuleHandle", "Str", libraryName, "Ptr"), "AStr", functionName, "Ptr"))
}

;=================================================== Error Handling ===========;

;* ErrorFromMessage(messageID)
ErrorFromMessage(messageID) {
	if (!(length := DllCall("Kernel32\FormatMessage", "UInt", 0x1100  ;? 0x1100 = FORMAT_MESSAGE_FROM_SYSTEM | FORMAT_MESSAGE_ALLOCATE_BUFFER
		, "Ptr", 0, "UInt", messageID, "UInt", 0, "Ptr*", &(buffer := 0), "UInt", 0, "Ptr", 0, "Int"))) {  ;: https://docs.microsoft.com/en-us/windows/win32/api/winbase/nf-winbase-formatmessage
		return (ErrorFromMessage(DllCall("Kernel32\GetLastError")))
	}

	message := StrGet(buffer, length - 2)  ;* Account for the newline and carriage return characters.
	DllCall("Kernel32\LocalFree", "Ptr", buffer)

	return (Error(Format("0x{:X}", messageID), -1, message))
}

;* ErrorFromStatus(status)
ErrorFromStatus(status) {
	static statusLookup := Map(1, "GenericError", 2, "InvalidParameter", 3, "OutOfMemory", 4, "ObjectBusy", 5, "InsufficientBuffer", 6, "NotImplemented", 7, "Win32Error", 8, "WrongState", 9, "Aborted", 10, "FileNotFound", 11, "ValueOverflow", 12, "AccessDenied", 13, "UnknownImageFormat", 14, "FontFamilyNotFound", 15, "FontStyleNotFound", 16, "NotTrueTypeFont", 17, "UnsupportedGdiplusVersion", 18, "GdiplusNotInitialized", 19, "PropertyNotFound", 20, "PropertyNotSupported", 21, "ProfileNotFound")  ;: https://docs.microsoft.com/en-us/windows/win32/api/gdiplustypes/ne-gdiplustypes-status

	return (Error(status, -2, statusLookup[status]))
}

;======================================================= MSVCRT ===============;

MemCopy(dest, src, bytes) {
	return (DllCall("msvcrt\memcpy", "Ptr", dest, "Ptr", src, "UInt", bytes))
}

MemMove(dest, src, bytes) {
	return (DllCall("msvcrt\memmove", "Ptr", dest, "Ptr", src, "UInt", bytes))
}

MemoryDifference(ptr1, ptr2, num) {
   return DllCall("msvcrt\memcmp", "ptr", ptr1, "ptr", ptr2, "int", num)
}

;======================================================= User32 ===============;

/*
** User32_Enums: https://github.com/lstratman/Win32Interop/blob/master/User32/Enums.cs **

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
*/

;* GetDC([hWnd])
;* Parameter:
	;* [Integer] hWnd - A handle to the window whose DC is to be retrieved. If this value is NULL, this function retrieves the DC for the entire screen.
GetDC(hWnd := 0) {
	if (!(hDC := DllCall("User32\GetDC", "Ptr", hWnd, "Ptr"))) {
		throw (ErrorFromMessage(DllCall("Kernel32\GetLastError")))
	}

	static instance := {Call: (*) => ({Class: "DC",
		__Delete: ReleaseDC})}

	(DC := instance.Call()).Handle := hDC
		, DC.Window := hWnd

	return (DC)
}

;* GetDCEx([hWnd, flags, hRegion])
;* Parameter:
	;* [Integer] hWnd - A handle to the window whose DC is to be retrieved. If this value is NULL, this function retrieves the DC for the entire screen.
	;* [Integer] flags - See DCX enumeration.
	;* [Integer] hRegion - A handle to a clipping region that may be combined with the visible region of the DC.
GetDCEx(hWnd := 0, flags := 0, hRegion := 0) {
	if (!(hDC := DllCall("User32\GetDCEx", "Ptr", hWnd, "Ptr", hRegion, "UInt", flags, "Ptr"))) {
		throw (ErrorFromMessage(DllCall("Kernel32\GetLastError")))
	}

	static instance := {Call: (*) => ({Class: "DC",
		__Delete: ReleaseDC})}

	(DC := instance.Call()).Handle := hDC
		, DC.Window := hWnd

	return (DC)
}

;* ReleaseDC(DC)
;* Parameter:
	;* [DC] DC - A DC object to be released.
;* Note:
	;~ This function should not be called manually. DC objects will call this automatically when they are deleted.
ReleaseDC(DC) {
	if (!DllCall("User32\ReleaseDC", "Ptr", DC.Window, "Ptr", DC.Handle, "Int")) {
		throw (ErrorFromMessage(DllCall("Kernel32\GetLastError")))
	}
}

GetDesktopWindow() {
	return (DllCall("User32\GetDesktopWindow", "Ptr"))
}

;* PrintWindow(hWnd, DC[, flags])
;* Parameter:
	;* [Integer] hWnd - A handle to the window that will be copied.
	;* [DC] DC - A DC object to copy the window into.
	;* [Integer] flags - The drawing options.
PrintWindow(hWnd, DC, flags := 2) {
	if (!DllCall("User32\PrintWindow", "Ptr", hWnd, "Ptr", DC.Handle, "UInt", flags, "Int")) {
		throw (ErrorFromMessage(DllCall("Kernel32\GetLastError")))
	}
}

;/*
;** A Guide to WIN32 Clipping Regions: https://www.codeproject.com/articles/2095/a-guide-to-win32-clipping-regions. **
;*/

SetWindowRgn(hWnd, x, y, width, height) {
	if (!(hRgn := DllCall("Gdi32\CreateEllipticRgn", "Int", x, "Int", y, "Int", width + 1, "Int", height + 1))) {  ;: https://docs.microsoft.com/en-us/windows/win32/api/wingdi/nf-wingdi-createellipticrgn
		throw (ErrorFromMessage(DllCall("Kernel32\GetLastError")))
	}

	if (!DllCall("User32\SetWindowRgn", "Ptr", hWnd, "Ptr", hRgn, "UInt", 0, "UInt")) {  ;: https://docs.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-setwindowrgn
		throw (ErrorFromMessage(DllCall("Kernel32\GetLastError")))
	}

	DllCall("Gdi32\DeleteObject", "Ptr", hRgn, "UInt")
}

;* UpdateLayeredWindow(hWnd, DC[, x, y, width, height, alpha])
;* Parameter:
	;* [Integer] hWnd - A handle to a layered window.
	;* [DC] DC - A DC object to update the layered window with.
	;* [Integer] x - The x component of the structure that specifies the new screen position of the layered window.
	;* [Integer] y - The y component of the structure that specifies the new screen position of the layered window.
	;* [Integer] width - The width component of the structure that specifies the new size of the layered window.
	;* [Integer] height - The height component of the structure that specifies the new size of the layered window.
	;* [Integer] alpha - Transparency value to be used when composing the layered window.
UpdateLayeredWindow(hWnd, DC, x := unset, y := unset, width := unset, height := unset, alpha := 0xFF) {
	if (!(IsSet(x) && IsSet(y) && IsSet(width) && IsSet(height))) {
		static rect := Structure.CreateRect(0, 0, 0, 0, "UInt")

		if (DllCall("Dwmapi\DwmGetWindowAttribute", "Ptr", hWnd, "UInt", 9, "Ptr", rect.Ptr, "UInt", 16, "UInt")) {
			if (!DllCall("User32\GetWindowRect", "Ptr", hWnd, "Ptr", rect.Ptr, "UInt")) {
				throw (ErrorFromMessage(DllCall("Kernel32\GetLastError")))
			}
		}

		if (!IsSet(x)) {
			x := rect.NumGet(0, "Int")

			if (!IsSet(width)) {
				width := Abs(rect.NumGet(8, "Int") - x)
			}
		}
		else if (!IsSet(width)) {
			width := Abs(rect.NumGet(8, "Int") - rect.NumGet(0, "Int"))
		}

		if (!IsSet(y)) {
			y := rect.NumGet(4, "Int")

			if (!IsSet(height)) {
				height := Abs(rect.NumGet(12, "Int") - y)
			}
		}
		else if (!IsSet(height)) {
			height := Abs(rect.NumGet(12, "Int") - rect.NumGet(4, "Int"))
		}
	}

	if (!DllCall("User32\UpdateLayeredWindow", "Ptr", hWnd, "Ptr", 0, "Int64*", x | y << 32, "Int64*", width | height << 32, "Ptr", DC.Handle, "Int64*", 0, "UInt", 0, "UInt*", alpha << 16 | 1 << 24, "UInt", 0x00000002, "UInt")) {
		throw (ErrorFromMessage(DllCall("Kernel32\GetLastError")))
	}
}

;===============  Class  =======================================================;

/*
** About Windows: https://docs.microsoft.com/en-us/windows/win32/winmsg/about-windows. **
*/

class LayeredWindow {

	__New(x, y, width, height, className := "LayeredWindow", classStyle := 0x00000000, windowProc := False, hCursor := 32512  ;? 32512 = OCR_NORMAL
		, title := "No-Face", exStyle := 0x00000000, style := 0x00000000, parent := 0, show := "SW_SHOWNOACTIVATE", alpha := 0xFF, pixelFormat := 0x000E200B, interpolation := 7, smoothing := 4) {
		this.Class := className

		if (!DllCall("User32\GetClassInfoEx", "Ptr", hInstance := DllCall("Kernel32\GetModuleHandle", "Ptr", 0, "Ptr"), "Ptr", classNamePtr := StrPtr(className), "Ptr", sWndClassEx := Structure(cbSize := (A_PtrSize == 8) ? (80) : (48)), "UInt")) {  ;: https://docs.microsoft.com/en-gb/windows/win32/api/winuser/nf-winuser-getclassinfoexa?redirectedfrom=MSDN
			static CS_BYTEALIGNCLIENT := 0x00001000, CS_BYTEALIGNWINDOW := 0x00002000, CS_CLASSDC := 0x00000040, CS_DBLCLKS := 0x00000008, CS_DROPSHADOW := 0x00020000, CS_GLOBALCLASS := 0x00004000, CS_HREDRAW := 0x00000002, CS_NOCLOSE := 0x00000200, CS_OWNDC := 0x00000020, CS_PARENTDC := 0x00000080, CS_SAVEBITS := 0x00000800, CS_VREDRAW := 0x00000001  ;: https://docs.microsoft.com/en-us/windows/win32/winmsg/window-class-styles

			if (!classStyle) {
				classStyle := CS_HREDRAW | CS_VREDRAW  ;~ `WS_EX_LAYERED` cannot be used if the window has a class style of either `CS_OWNDC` or `CS_CLASSDC`.
			}
			else if (classStyle is Array) {
				classStyle := classStyle.Reduce((accumulator, currentValue, *) => (accumulator |= %currentValue%), 0x00000000)
			}

			if (windowProc) {
				if (!(windowProc is Func || windowProc is Closure)) {
					throw (TypeError(Format("{} is not a valid callback function.", Type(windowProc)), -1))
				}
			}
			else {
				windowProc := (hWnd, uMsg, wParam, lParam) => (DllCall("User32\DefWindowProc", "Ptr", hWnd, "UInt", uMsg, "Ptr", wParam, "Ptr", lParam, "Ptr"))
			}

			sWndClassEx.NumPut(0, "UInt", cbSize
				, "UInt", classStyle  ;* style
				, "Ptr", CallbackCreate(windowProc, "F")  ;* lpfnWndProc
				, "Int", 0  ;* cbClsExtra
				, "Int", 0  ;* cbWndExtra
				, "Ptr", hInstance  ;* hInstance
				, "Ptr", 0  ;* hIcon
				, "Ptr", (hCursor) ? (DllCall("LoadCursor", "Ptr", 0, "Ptr", hCursor, "Ptr")) : (0)  ;* hCursor
				, "Ptr", 0  ;* hbrBackground
				, "Ptr", 0  ;* lpszMenuName
				, "Ptr", classNamePtr  ;* lpszClassName
				, "Ptr", 0)  ;* hIconSm

			if (!DllCall("User32\RegisterClassEx", "Ptr", sWndClassEx.Ptr, "UShort")) {  ;: https://docs.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-registerclassexa
				throw (ErrorFromMessage(DllCall("Kernel32\GetLastError")))
			}
		}

		static WS_EX_ACCEPTFILES := 0x00000010, WS_EX_APPWINDOW := 0x00040000, WS_EX_CLIENTEDGE := 0x00000200, WS_EX_COMPOSITED := 0x02000000, WS_EX_CONTEXTHELP := 0x00000400, WS_EX_CONTROLPARENT := 0x00010000, WS_EX_DLGMODALFRAME := 0x00000001, WS_EX_LAYERED := 0x00080000, WS_EX_LAYOUTRTL := 0x00400000, WS_EX_LEFT := 0x00000000, WS_EX_LEFTSCROLLBAR := 0x00004000, WS_EX_LTRREADING := 0x00000000, WS_EX_MDICHILD := 0x00000040, WS_EX_NOACTIVATE := 0x08000000, WS_EX_NOINHERITLAYOUT := 0x00100000, WS_EX_NOPARENTNOTIFY := 0x00000004, WS_EX_NOREDIRECTIONBITMAP := 0x00200000, WS_EX_OVERLAPPEDWINDOW := 0x00000300, WS_EX_PALETTEWINDOW := 0x00000188, WS_EX_RIGHT := 0x00001000, WS_EX_RIGHTSCROLLBAR := 0x00000000, WS_EX_RTLREADING := 0x00002000, WS_EX_STATICEDGE := 0x00020000, WS_EX_TOOLWINDOW := 0x00000080, WS_EX_TOPMOST := 0x00000008, WS_EX_TRANSPARENT := 0x00000020, WS_EX_WINDOWEDGE := 0x00000100  ;: https://docs.microsoft.com/en-us/windows/win32/winmsg/extended-window-styles

		if (!exStyle) {
			exStyle := WS_EX_LAYERED | WS_EX_NOACTIVATE | WS_EX_TOOLWINDOW | WS_EX_TOPMOST | WS_EX_TRANSPARENT
		}
		else if (exStyle is Array) {
			exStyle := (exStyle.Length == 2 && (add := exStyle[0]) is Array && (remove := exStyle[1]) is Array)
				? (add.Reduce((accumulator, currentValue, *) => (accumulator |= %currentValue%), 0x00000000) & ~remove.Reduce((accumulator, currentValue, *) => (accumulator |= %currentValue%), 0x00000000))
				: (exStyle.Reduce((accumulator, currentValue, *) => (accumulator |= %currentValue%), 0x00000000))
		}

		static WS_BORDER := 0x00800000, WS_CAPTION := 0x00C00000, WS_CHILD := 0x40000000, WS_CHILDWINDOW := 0x40000000, WS_CLIPCHILDREN := 0x02000000, WS_CLIPSIBLINGS := 0x04000000, WS_DISABLED := 0x08000000, WS_DLGFRAME := 0x00400000, WS_GROUP := 0x00020000, WS_HSCROLL := 0x00100000, WS_ICONIC := 0x20000000, WS_MAXIMIZE := 0x01000000, WS_MAXIMIZEBOX := 0x00010000, WS_MINIMIZE := 0x20000000, WS_MINIMIZEBOX := 0x00020000, WS_OVERLAPPED := 0x00000000, WS_OVERLAPPEDWINDOW := 0x00CF0000, WS_POPUP := 0x80000000, WS_POPUPWINDOW := 0x80880000, WS_SIZEBOX := 0x00040000, WS_SYSMENU := 0x00080000, WS_TABSTOP := 0x00010000, WS_THICKFRAME := 0x00040000, WS_TILED := 0x00000000, WS_TILEDWINDOW := 0xCF0000, WS_VISIBLE := 0x10000000, WS_VSCROLL := 0x00200000  ;: https://docs.microsoft.com/en-us/windows/win32/winmsg/window-styles

		if (!style) {
			style := WS_POPUPWINDOW & ~WS_CAPTION  ;~ The WS_CAPTION style must be combined with the WS_POPUPWINDOW style to make the window menu visible.
		}
		else if (style is Array) {
			style := (style.Length == 2 && (add := style[0]) is Array && (remove := style[1]) is Array)
				? (add.Reduce((accumulator, currentValue, *) => (accumulator |= %currentValue%), 0x00000000) & ~remove.Reduce((accumulator, currentValue, *) => (accumulator |= %currentValue%), 0x00000000))
				: (style.Reduce((accumulator, currentValue, *) => (accumulator |= %currentValue%), 0x00000000))
		}

		if (!(this.Handle := DllCall("User32\CreateWindowEx"  ;: https://docs.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-createwindowexw
			, "UInt", exStyle  ;* dwExStyle
			, "Ptr", classNamePtr  ;* lpClassName
			, "Str", title  ;* lpWindowName
			, "UInt", style  ;* dwStyle
			, "Int", x
			, "Int", y
			, "Int", width
			, "Int", height
			, "Ptr", parent  ;* hWndParent
			, "Ptr", 0  ;* hMenu
			, "Ptr", hInstance  ;* hInstance
			, "Ptr", 0  ;* lpParam
			, "Ptr"))) {
			throw (ErrorFromMessage(DllCall("Kernel32\GetLastError")))
		}

		if (show) {
			static SW_NORMAL := 1, SW_SHOWNORMAL := 1, SW_SHOWMINIMIZED := 2, SW_MAXIMIZE := 3, SW_SHOWMAXIMIZED := 3, SW_SHOWNOACTIVATE := 4, SW_SHOW := 5, SW_MINIMIZE := 6, SW_SHOWMINNOACTIVE := 7, SW_SHOWNA := 8, SW_RESTORE := 9, SW_SHOWDEFAULT := 10, SW_FORCEMINIMIZE := 11

			try {
				show := %show%
			}

			DllCall("User32\ShowWindow", "Ptr", this.Handle, "Int", show)  ;: https://docs.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-showwindow
		}

		this.Point := Structure.CreatePoint(x, y, "UInt"), this.Size := Structure.CreateSize(width, height), this.Blend := Structure.CreateBlendFunction(alpha)

		this.DC := GDI.CreateCompatibleDC()
			, this.DC.SelectObject(GDI.CreateDIBSection(Structure.CreateBitmapInfoHeader(width, -height, bitCount := 32), this.DC, 0, &(pBits := 0)))

		this.Bitmap := GDIp.CreateBitmap(width, height, pixelFormat, width*(bitCount >> 3), pBits)
		this.Graphics := GDIp.CreateGraphicsFromBitmap(this.Bitmap)
			, this.Graphics.SetInterpolationMode(interpolation), this.Graphics.SetSmoothingMode(smoothing)
	}

	static RegisterClass(className := "LayeredWindow", classStyle := 0x00000000, windowProc := False, hCursor := 32512) {  ;? 32512 = OCR_NORMAL

	}

	__Delete() {
		try {
			DllCall("User32\DestroyWindow", "Ptr", this.Handle)  ;~ If the specified window is a parent or owner window, DestroyWindow automatically destroys the associated child or owned windows when it destroys the parent or owner window. The function first destroys child or owned windows, and then it destroys the parent or owner window.
		}

		;~ If the window being destroyed is a child window that does not have the WS_EX_NOPARENTNOTIFY style, a WM_PARENTNOTIFY message is sent to the parent.

		try {
			DllCall("User32\UnregisterClass", "Ptr", StrPtr(this.Class), "Ptr", 0)
		}
	}

	IsVisible {
		Get {
			return (DllCall("IsWindowVisible", "Ptr", this.Handle, "UInt"))  ;~ If the specified window, its parent window, its parent's parent window, and so forth, have the WS_VISIBLE style, the return value is nonzero. Otherwise, the return value is zero.

			;~ If you need to check the `WS_VISIBLE` flag for a specific window you can do `GetWindowLong(hWnd, GWL_STYLE)` and test for `WS_VISIBLE`.
		}
	}

	x {
		Get {
			return (this.Point.NumGet(0, "UInt"))
		}
	}

	y {
		Get {
			return (this.Point.NumGet(4, "UInt"))
		}
	}

	Width {
		Get {
			return (this.Size.NumGet(0, "UInt"))
		}
	}

	Height {
		Get {
			return (this.Size.NumGet(4, "UInt"))
		}
	}

	Rect[client := True] {
		Get {
			static rect := Structure.CreateRect(0, 0, 0, 0, "Int")

			if (client) {
				if (!DllCall("User32\GetClientRect", "Ptr", this.Handle, "Ptr", pointer := rect.Ptr, "UInt")) {
					throw (ErrorFromMessage(DllCall("Kernel32\GetLastError")))
				}
			}
			else if (DllCall("Dwmapi\DwmGetWindowAttribute", "Ptr", this.Handle, "UInt", 9, "UPtr", pointer := rect.Ptr, "UInt", 16, "UInt")) {
				if (!DllCall("User32\GetWindowRect", "Ptr", this.Handle, "Ptr", pointer, "UInt")) {
					throw (ErrorFromMessage(DllCall("Kernel32\GetLastError")))
				}
			}

			return ({x: x := NumGet(pointer, "Int"), y: y := NumGet(pointer + 4, "Int"), Width: NumGet(pointer + 8, "Int") - x, Height: NumGet(pointer + 12, "Int") - y})  ;~ The coordinates are relative to the upper left corner of the screen, even for a child window.
		}
	}

	AddExStyle(exStyle) {
		DllCall("User32\SetWindowLongPtr", "Ptr", hWnd := this.Handle, "Int", -20, "Ptr", DllCall("User32\GetWindowLongPtr", "Ptr", hWnd, "Int", -20, "Ptr") | exStyle)  ;? -20 = GWL_EXSTYLE

		if (!DllCall("User32\SetWindowPos", "Ptr", this.Handle, "Ptr", 0, "Int", 0, "Int", 0, "Int", 0, "Int", 0, "UInt", 0x0027, "UInt")) {  ;? 0x0027 = SWP_FRAMECHANGED | SWP_NOMOVE | SWP_NOSIZE | SWP_NOZORDER  ;: https://docs.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-setwindowpos
			throw (ErrorFromMessage(DllCall("Kernel32\GetLastError")))
		}
	}

	RemoveExStyle(exStyle) {
		DllCall("User32\SetWindowLongPtr", "Ptr", hWnd := this.Handle, "Int", -20, "Ptr", DllCall("User32\GetWindowLongPtr", "Ptr", hWnd, "Int", -20, "Ptr") & ~(exStyle))

		if (!DllCall("User32\SetWindowPos", "Ptr", this.Handle, "Ptr", 0, "Int", 0, "Int", 0, "Int", 0, "Int", 0, "UInt", 0x0027, "UInt")) {
			throw (ErrorFromMessage(DllCall("Kernel32\GetLastError")))
		}
	}

	ToggleExStyle(exStyle) {
		DllCall("User32\SetWindowLongPtr", "Ptr", hWnd := this.Handle, "Int", -20, "Ptr", DllCall("User32\GetWindowLongPtr", "Ptr", hWnd, "Int", -20, "Ptr") ^ exStyle)

		if (!DllCall("User32\SetWindowPos", "Ptr", this.Handle, "Ptr", 0, "Int", 0, "Int", 0, "Int", 0, "Int", 0, "UInt", 0x0027, "UInt")) {
			throw (ErrorFromMessage(DllCall("Kernel32\GetLastError")))
		}
	}

	;* window.Show([flag])
	Show(flag := "SW_SHOWNOACTIVATE") {
		static SW_NORMAL := 1, SW_SHOWNORMAL := 1, SW_SHOWMINIMIZED := 2, SW_MAXIMIZE := 3, SW_SHOWMAXIMIZED := 3, SW_SHOWNOACTIVATE := 4, SW_SHOW := 5, SW_MINIMIZE := 6, SW_SHOWMINNOACTIVE := 7, SW_SHOWNA := 8, SW_RESTORE := 9, SW_SHOWDEFAULT := 10, SW_FORCEMINIMIZE := 11

		try {
			flag := %flag%
		}

		DllCall("User32\ShowWindow", "Ptr", this.Handle, "Int", flag)  ;: https://docs.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-showwindow
	}

	Hide() {
		DllCall("User32\ShowWindow", "Ptr", this.Handle, "Int", 0)
	}

	;* window.Clear()
	Clear() {
		return (this.Graphics.Clear())
	}

	;* window.Reset()
	Reset() {
		return (this.Graphics.Reset())
	}

	;* window.Update([x, y, width, height, alpha])
	;* Parameter:
		;* [Integer] x
		;* [Integer] y
		;* [Integer] width
		;* [Integer] height
		;* [Integer] alpha
	Update(x := unset, y := unset, width := unset, height := unset, alpha := unset) {
		if (IsSet(x)) {
			if (IsSet(y)) {
				this.Point.NumPut(0, "UInt", x, "UInt", y)
			}
			else {
				this.Point.NumPut(0, "UInt", x)
			}
		}
		else if (IsSet(y)) {
			this.Point.NumPut(4, "UInt", y)
		}

		if (IsSet(width)) {
			if (IsSet(height)) {
				this.Size.NumPut(0, "UInt", width, "UInt", height)
			}
			else {
				this.Size.NumPut(0, "UInt", width)
			}
		}
		else if (IsSet(height)) {
			this.Size.NumPut(4, "UInt", height)
		}

		if (IsSet(alpha)) {
			this.Blend.NumPut(2, "UChar", alpha)
		}

		if (!DllCall("User32\UpdateLayeredWindow", "Ptr", this.Handle, "Ptr", 0, "Ptr", this.Point.Ptr, "Ptr", this.Size.Ptr, "Ptr", this.DC.Handle, "Int64*", 0, "UInt", 0, "Ptr", this.Blend.Ptr, "UInt", 0x00000002, "UInt")) {
			throw (ErrorFromMessage(DllCall("Kernel32\GetLastError")))
		}
	}
}