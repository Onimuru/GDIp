﻿;============ Auto-Execute ====================================================;
;======================================================  Setting  ==============;

#Requires AutoHotkey v2.0-a134-d3d43350

;======================================================  Include  ==============;

#Include %A_LineFile%\..\ObjectOriented\Array.ahk
#Include %A_LineFile%\..\ObjectOriented\Object.ahk
#Include %A_LineFile%\..\String\String.ahk

#Include %A_LineFile%\..\Structure\Structure.ahk

#Include %A_LineFile%\..\Core\GDI.ahk
#Include %A_LineFile%\..\Core\GDIp.ahk

;============== Function ======================================================;
;======================================================  Library  ==============;

LoadLibrary(libraryName) {
	static loaded := FreeLibrary("__SuperSecretString")

	if (!(loaded.HasProp(libraryName))) {
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
			if (!(DllCall("Kernel32\FreeLibrary", "Ptr", handle, "UInt"))) {
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

		if (NumGet(p + ((A_PtrSize == 4) ? (92) : (108)), "UInt") < 1 || (ts := NumGet(p + ((A_PtrSize == 4) ? (96) : (112)), "UInt") + ptr) == ptr || (te := NumGet(p + ((A_PtrSize == 4) ? (100) : (116)), "UInt") + ts) == ts) {
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

;* GetDCEx([hWnd, flags, region])
;* Parameter:
	;* [Integer] hWnd - A handle to the window whose DC is to be retrieved. If this value is NULL, this function retrieves the DC for the entire screen.
	;* [Integer] flags - See DCX enumeration.
	;* [Integer] region - A clipping region that may be combined with the visible region of the DC.
GetDCEx(hWnd := 0, flags := 0, region := 0) {
	if (!(hDC := DllCall("User32\GetDCEx", "Ptr", hWnd, "Ptr", region, "UInt", flags, "Ptr"))) {
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
	if (!(DllCall("User32\ReleaseDC", "Ptr", DC.Window, "Ptr", DC.Handle, "Int"))) {
		throw (ErrorFromMessage(DllCall("Kernel32\GetLastError")))
	}

	return (True)
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
	if (!(DllCall("User32\PrintWindow", "Ptr", hWnd, "Ptr", DC.Handle, "UInt", flags, "Int"))) {
		throw (ErrorFromMessage(DllCall("Kernel32\GetLastError")))
	}

	return (True)
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
			if (!(DllCall("User32\GetWindowRect", "Ptr", hWnd, "Ptr", rect.Ptr, "UInt"))) {
				throw (ErrorFromMessage(DllCall("Kernel32\GetLastError")))
			}
		}

		if (!(IsSet(x))) {
			x := rect.NumGet(0, "Int")

			if (!(IsSet(width))) {
				width := Abs(rect.NumGet(8, "Int") - x)
			}
		}
		else if (!(IsSet(width))) {
			width := Abs(rect.NumGet(8, "Int") - rect.NumGet(0, "Int"))
		}

		if (!(IsSet(y))) {
			y := rect.NumGet(4, "Int")

			if (!(IsSet(height))) {
				height := Abs(rect.NumGet(12, "Int") - y)
			}
		}
		else if (!(IsSet(height))) {
			height := Abs(rect.NumGet(12, "Int") - rect.NumGet(4, "Int"))
		}
	}

	if (!DllCall("User32\UpdateLayeredWindow", "Ptr", hWnd, "Ptr", 0, "Int64*", x | y << 32, "Int64*", width | height << 32, "Ptr", DC.Handle, "Int64*", 0, "UInt", 0, "UInt*", alpha << 16 | 1 << 24, "UInt", 0x00000002, "UInt")) {
		throw (ErrorFromMessage(DllCall("Kernel32\GetLastError")))
	}

	return (True)
}