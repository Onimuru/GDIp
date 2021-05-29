/*
** About Windows: https://docs.microsoft.com/en-us/windows/win32/winmsg/about-windows. **
*/

;* GDIp.CreateCanvas(x, y, width, height[, windowProc, windowClassName, windowClassStyles, title, extendedWindowStyles, windowStyles, smoothing, interpolation])
;* Parameter:
	;* [Integer] x
	;* [Integer] y
	;* [Integer] width
	;* [Integer] height
	;* [Func] windowProc
	;* [String] windowClassName
	;* [Integer] windowClassStyles
	;* [String] title
	;* [Integer] extendedWindowStyles
	;* [Integer] windowStyles
	;* [Integer] smoothing
	;* [Integer] interpolation
static CreateCanvas(x, y, width, height, windowProc := False, windowClassName := "Canvas", windowClassStyles := 0x00000000, title := "Title", extendedWindowStyles := 0x00000000, windowStyles := 0x00000000, smoothing := 4, interpolation := 7) {
	if (windowProc) {
		if (!(windowProc is Func || windowProc is Closure)) {
			throw (TypeError(Format("{} is not a valid callback function.", Type(windowProc)), -1))
		}
	}
	else {
		windowProc := (hWnd, uMsg, wParam, lParam) => (DllCall("User32\DefWindowProc", "Ptr", hWnd, "UInt", uMsg, "Ptr", wParam, "Ptr", lParam, "Ptr"))
	}

	static CS_BYTEALIGNCLIENT := 0x00001000, CS_BYTEALIGNWINDOW := 0x00002000, CS_CLASSDC := 0x00000040, CS_DBLCLKS := 0x00000008, CS_DROPSHADOW := 0x00020000, CS_GLOBALCLASS := 0x00004000, CS_HREDRAW := 0x00000002, CS_NOCLOSE := 0x00000200, CS_OWNDC := 0x00000020, CS_PARENTDC := 0x00000080, CS_SAVEBITS := 0x00000800, CS_VREDRAW := 0x00000001  ;: https://docs.microsoft.com/en-us/windows/win32/winmsg/window-class-styles

	if (!(windowClassStyles)) {
		windowClassStyles := CS_HREDRAW | CS_VREDRAW  ;~ `WS_EX_LAYERED` cannot be used if the window has a class style of either `CS_OWNDC` or `CS_CLASSDC`.
	}
	else if (windowClassStyles is Array) {
		windowClassStyles := windowClassStyles.Reduce((accumulator, currentValue, *) => (accumulator |= %currentValue%), 0)
	}

	wndClassEx := Structure.CreateWndClassEx(windowClassStyles, CallbackCreate(windowProc, "F"), 0, 0, DllCall("GetModuleHandle", "Ptr", 0, "Ptr"), 0, DllCall("LoadCursor", "Ptr", 0, "Ptr", 32512, "Ptr"), 0, 0, StrPtr(windowClassName), 0)

	if (!(DllCall("User32\RegisterClassEx", "Ptr", wndClassEx, "UShort"))) {  ;~ If you register the window class by using `"User32\RegisterClassExA"`, the application tells the system that the windows of the created class expect messages with text or character parameters to use the ANSI character set; if you register it by using `"User32\RegisterClassExW"`, the application requests that the system pass text parameters of messages as Unicode. All window classes that an application registers are unregistered when it terminates.
		throw (ErrorFromMessage(DllCall("Kernel32\GetLastError")))
	}

	static WS_EX_ACCEPTFILES := 0x00000010, WS_EX_APPWINDOW := 0x00040000, WS_EX_CLIENTEDGE := 0x00000200, WS_EX_COMPOSITED := 0x02000000, WS_EX_CONTEXTHELP := 0x00000400, WS_EX_CONTROLPARENT := 0x00010000, WS_EX_DLGMODALFRAME := 0x00000001, WS_EX_LAYERED := 0x00080000, WS_EX_LAYOUTRTL := 0x00400000, WS_EX_LEFT := 0x00000000, WS_EX_LEFTSCROLLBAR := 0x00004000, WS_EX_LTRREADING := 0x00000000, WS_EX_MDICHILD := 0x00000040, WS_EX_NOACTIVATE := 0x08000000, WS_EX_NOINHERITLAYOUT := 0x00100000, WS_EX_NOPARENTNOTIFY := 0x00000004, WS_EX_NOREDIRECTIONBITMAP := 0x00200000, WS_EX_OVERLAPPEDWINDOW := 0x00000300, WS_EX_PALETTEWINDOW := 0x00000188, WS_EX_RIGHT := 0x00001000, WS_EX_RIGHTSCROLLBAR := 0x00000000, WS_EX_RTLREADING := 0x00002000, WS_EX_STATICEDGE := 0x00020000, WS_EX_TOOLWINDOW := 0x00000080, WS_EX_TOPMOST := 0x00000008, WS_EX_TRANSPARENT := 0x00000020, WS_EX_WINDOWEDGE := 0x00000100  ;: https://docs.microsoft.com/en-us/windows/win32/winmsg/extended-window-styles

	if (!(extendedWindowStyles)) {
		extendedWindowStyles := (WS_EX_LAYERED | WS_EX_NOACTIVATE | WS_EX_TOOLWINDOW | WS_EX_TOPMOST | WS_EX_TRANSPARENT) & ~(WS_EX_DLGMODALFRAME | WS_EX_CLIENTEDGE | WS_EX_STATICEDGE)
	}
	else if (extendedWindowStyles is Array) {
		extendedWindowStyles := extendedWindowStyles.Reduce((accumulator, currentValue, *) => (accumulator |= %currentValue%), 0)
	}

	static WS_BORDER := 0x00800000, WS_CAPTION := 0x00C00000, WS_CHILD := 0x40000000, WS_CHILDWINDOW := 0x40000000, WS_CLIPCHILDREN := 0x02000000, WS_CLIPSIBLINGS := 0x04000000, WS_DISABLED := 0x08000000, WS_DLGFRAME := 0x00400000, WS_GROUP := 0x00020000, WS_HSCROLL := 0x00100000, WS_ICONIC := 0x20000000, WS_MAXIMIZE := 0x01000000, WS_MAXIMIZEBOX := 0x00010000, WS_MINIMIZE := 0x20000000, WS_MINIMIZEBOX := 0x00020000, WS_OVERLAPPED := 0x00000000, WS_OVERLAPPEDWINDOW := 0x00CF0000, WS_POPUP := 0x80000000, WS_POPUPWINDOW := 0x80880000, WS_SIZEBOX := 0x00040000, WS_SYSMENU := 0x00080000, WS_TABSTOP := 0x00010000, WS_THICKFRAME := 0x00040000, WS_TILED := 0x00000000, WS_TILEDWINDOW := 0xCF0000, WS_VISIBLE := 0x10000000, WS_VSCROLL := 0x00200000  ;: https://docs.microsoft.com/en-us/windows/win32/winmsg/window-styles

	if (!(windowStyles)) {
		windowStyles := WS_POPUPWINDOW & ~(WS_CAPTION | WS_MAXIMIZEBOX | WS_MINIMIZEBOX | WS_SIZEBOX)
	}
	else if (windowStyles is Array) {
		windowStyles := windowStyles.Reduce((accumulator, currentValue, *) => (accumulator |= %currentValue%), 0x00000000)
	}

	if (!(hWnd := DllCall("User32\CreateWindowEx", "UInt", extendedWindowStyles, "Str", windowClassName, "Str", title, "UInt", windowStyles, "Int", x, "Int", y, "Int", width, "Int", height, "Ptr", A_ScriptHwnd, "Ptr", 0, "Ptr", DllCall("GetModuleHandle", "Ptr", 0, "Ptr"), "Ptr", 0, "Ptr"))) {  ;: https://docs.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-createwindowexw
		throw (ErrorFromMessage(DllCall("Kernel32\GetLastError")))
	}

	(instance := GDIp.Canvas(hWnd)).Handle := hWnd  ;* Save a handle to the window in order to update it.
	instance.Class := windowClassName

	instance.DC := GDI.CreateCompatibleDC()  ;* Get a memory DC compatible with the screen.
	instance.Bitmap := GDI.CreateDIBSection(Structure.CreateBitmapInfoHeader(width, -height), instance.DC)  ;* Create a GDI bitmap.
		, instance.DC.SelectObject(instance.Bitmap)  ;* Select the DIB into the memory DC.

	(instance.Graphics := this.CreateGraphicsFromDC(instance.DC)).SetSmoothingMode(smoothing)
		, instance.Graphics.SetInterpolationMode(interpolation)

	instance.Point := Structure.CreatePoint(x, y, "UInt"), instance.Size := Structure.CreateSize(width, height), instance.Blend := Structure.CreateBlendFunction(0xFF)

	instance.Show()

	return (instance)
}

class Canvas {

	__New(hWnd) {
		this.Handle := hWnd
	}

	__Delete() {
		if (!(DllCall("User32\DestroyWindow", "Ptr", this.Handle, "UInt"))) {  ;~ If the specified window is a parent or owner window, DestroyWindow automatically destroys the associated child or owned windows when it destroys the parent or owner window. The function first destroys child or owned windows, and then it destroys the parent or owner window.
			throw (ErrorFromMessage(DllCall("Kernel32\GetLastError")))
		}

		;~ If the window being destroyed is a child window that does not have the WS_EX_NOPARENTNOTIFY style, a WM_PARENTNOTIFY message is sent to the parent.

		if (!(DllCall("User32\UnregisterClass", "Ptr", StrPtr(this.Class), "Ptr", 0, "UInt"))) {
			throw (ErrorFromMessage(DllCall("Kernel32\GetLastError")))
		}
	}

	IsVisible {
		Get {
			return (DllCall("IsWindowVisible", "Ptr", this.Handle, "UInt"))  ;~ If the specified window, its parent window, its parent's parent window, and so forth, have the WS_VISIBLE style, the return value is nonzero. Otherwise, the return value is zero.

			;~ If you need to check the `WS_VISIBLE` flag for a specific window you can do `GetWindowLong(hWnd, GWL_STYLE)` and test for `WS_VISIBLE`.
		}
	}

	Rect[which := ""] {
		Get {
			static rect := Structure.CreateRect(0, 0, 0, 0, "Int")

			if (!(DllCall("User32\GetWindowRect", "Ptr", this.Handle, "Ptr", pointer := rect.Ptr, "UInt"))) {
				throw (ErrorFromMessage(DllCall("Kernel32\GetLastError")))
			}

			switch (which) {
				case "x":
					return (NumGet(pointer, "Int"))
				case "y":
					return (NumGet(pointer + 4, "Int"))
				case "Width":
					return (NumGet(pointer + 8, "Int") - NumGet(pointer, "Int"))
				case "Height":
					return (NumGet(pointer + 12, "Int") - NumGet(pointer + 4, "Int"))
				default:
					return ({x: x := NumGet(pointer, "Int"), y: y := NumGet(pointer + 4, "Int"), Width: NumGet(pointer + 8, "Int") - x, Height: NumGet(pointer + 12, "Int") - y})
			}
		}
	}

	x {
		Get {
			return (this.Rect["x"])
		}
	}

	y {
		Get {
			return (this.Rect["y"])
		}
	}

	Width {
		Get {
			return (this.Rect["Width"])
		}
	}

	Height {
		Get {
			return (this.Rect["Height"])
		}
	}

	Title {
		Get {
			return (WinGetTitle(this.Handle))
		}

		Set {
			WinSetTitle(value, this.Handle)

			return (value)
		}
	}

	;* canvas.Show([nCmdShow])
	Show(nCmdShow := "SW_SHOWNOACTIVATE") {
		static SW_NORMAL := 1, SW_SHOWNORMAL := 1, SW_SHOWMINIMIZED := 2, SW_MAXIMIZE := 3, SW_SHOWMAXIMIZED := 3, SW_SHOWNOACTIVATE := 4, SW_SHOW := 5, SW_MINIMIZE := 6, SW_SHOWMINNOACTIVE := 7, SW_SHOWNA := 8, SW_RESTORE := 9, SW_SHOWDEFAULT := 10, SW_FORCEMINIMIZE := 11

		try {
			nCmdShow := %nCmdShow%
		}

		DllCall("User32\ShowWindow", "Ptr", this.Handle, "Int", nCmdShow)  ;: https://docs.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-showwindow
	}

	;* canvas.Hide()
	Hide() {
		DllCall("User32\ShowWindow", "Ptr", this.Handle, "Int", 0)
	}

	;* canvas.Clear()
	Clear() {
		return (this.Graphics.Clear())
	}

	;* canvas.Reset()
	Reset() {
		return (this.Graphics.Reset())
	}

	;* canvas.Update([x, y, width, height, alpha])
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

		if (!(DllCall("User32\UpdateLayeredWindow", "Ptr", this.Handle, "Ptr", 0, "Ptr", this.Point.Ptr, "Ptr", this.Size.Ptr, "Ptr", this.DC.Handle, "Int64*", 0, "UInt", 0, "Ptr", this.Blend.Ptr, "UInt", 0x00000002, "UInt"))) {
			throw (ErrorFromMessage(DllCall("Kernel32\GetLastError")))
		}
	}
}