;==============  Include  ======================================================;

#Include, %A_LineFile%\..\ObjectOriented\ObjectOriented.ahk
#Include, %A_LineFile%\..\Structure\Structure.ahk

;============== Function ======================================================;
;======================================================  Library  ==============;

FreeLibrary(libraryName) {  ;: https://www.autohotkey.com/boards/viewtopic.php?p=48392#p48392
	Static loaded := {"ComCtl32": {"Ptr": DllCall("Kernel32\GetModuleHandle", "Str", "ComCtl32", "Ptr")}, "Gdi32": {"Ptr": DllCall("Kernel32\GetModuleHandle", "Str", "Gdi32", "Ptr")}, "Kernel32": {"Ptr": DllCall("Kernel32\GetModuleHandle", "Str", "Kernel32", "Ptr")}, "User32": {"Ptr": DllCall("Kernel32\GetModuleHandle", "Str", "User32", "Ptr")}}  ;* "User32", "Kernel32", "ComCtl32" and "Gdi32" are already loaded.

	if (libraryName == "__SuperSecretString") {
		return (loaded)
	}
	else if (Type(libraryName) == "Library") {
		if (--loaded[libraryName.Name].Count) {
			return (0)
		}

		libraryName := libraryName.Name
	}

	if (!(libraryName ~= "i)ComCtl32|Gdi32|Kernel32|User32")) {
		if (loaded.HasKey(libraryName)) {
			loaded.Delete(libraryName)
		}

		if (handle := DllCall("Kernel32\GetModuleHandle", "Str", libraryName, "Ptr")) {  ;* If the library module is already in the address space of the script's process.
			if (!DllCall("Kernel32\FreeLibrary", "Ptr", handle, "UInt")) {
				throw (Exception(Format("0x{:X}", A_LastError), 0, FormatMessage(A_LastError)))
			}

			return (1)
		}
	}

	return (0)
}

LoadLibrary(libraryName) {
	Static loaded := FreeLibrary("__SuperSecretString")

	if (!loaded.HasKey(libraryName)) {
		if (!ptr := DllCall("Kernel32\LoadLibrary", "Str", libraryName, "Ptr")) {
			throw (Exception(Format("0x{:X}", A_LastError), 0, FormatMessage(A_LastError)))
		}

		loaded[libraryName] := {"Count": 0
			, "Ptr": ptr}
	}

	return (loaded[libraryName].Ptr, loaded[libraryName].Count++)
}

GetProcAddress(libraryName, functionName) {
	ptr := LoadLibrary(libraryName)

	if (functionName == "*") {
		Static library := {"__Class": "Library"
			, "__Delete": Func("FreeLibrary")}

		(o := new library()).Name := libraryName
			, p := ptr + NumGet(ptr + 0x3C, "Int") + 24

		if (NumGet(p + ((A_PtrSize == 4) ? (92) : (108)), "UInt") < 1 || (ts := NumGet(p + ((A_PtrSize == 4) ? (96) : (112)), "UInt") + ptr) == ptr || (te := NumGet(p + (A_PtrSize == 4) ? (100) : (116), "UInt") + ts) == ts) {
			return (o)
		}

		loop % (NumGet(ts + 24, "UInt"), n := ptr + NumGet(ts + 32, "UInt")) {
			if (p := NumGet(n + (A_Index - 1)*4, "UInt")) {
				o[f := StrGet(ptr + p, "CP0")] := DllCall("Kernel32\GetProcAddress", "Ptr", ptr, "AStr", f, "Ptr")

				if (SubStr(f, 0) == ((A_IsUnicode) ? "W" : "A")) {
					o[SubStr(f, 1, -1)] := o[f]
				}
			}
		}

		return (o)
	}

	return (DllCall("Kernel32\GetProcAddress", "Ptr", DllCall("Kernel32\GetModuleHandle", "Str", libraryName, "Ptr"), "AStr", functionName, "Ptr"))
}

;=================================================== Error Handling ===========;

;* FormatMessage(messageID)
FormatMessage(messageID) {  ;: https://docs.microsoft.com/en-us/windows/win32/api/winbase/nf-winbase-formatmessage
	Local

	if (!length := DllCall("Kernel32\FormatMessage", "UInt", 0x1100, "Ptr", 0, "UInt", messageID, "UInt", 0, "Ptr*", buffer := 0, "UInt", 0, "Ptr", 0, "UInt")) {
		return (FormatMessage(DllCall("Kernel32\GetLastError")))
	}

	return (StrGet(buffer, length - 2), DllCall("Kernel32\LocalFree", "Ptr", buffer, "Ptr"))  ;* Account for the newline and carriage return characters.
}

;* FormatStatus(status)
FormatStatus(status) {
	Local

	Static GDIp := {"1": "GenericError", "2": "InvalidParameter", "3": "OutOfMemory", "4": "ObjectBusy", "5": "InsufficientBuffer", "6": "NotImplemented", "7": "Win32Error", "8": "WrongState", "9": "Aborted", "10": "FileNotFound", "11": "ValueOverflow", "12": "AccessDenied", "13": "UnknownImageFormat", "14": "FontFamilyNotFound", "15": "FontStyleNotFound", "16": "NotTrueTypeFont", "17": "UnsupportedGdiplusVersion", "18": "GdiplusNotInitialized", "19": "PropertyNotFound", "20": "PropertyNotSupported", "21": "ProfileNotFound"}  ;: https://docs.microsoft.com/en-us/windows/win32/api/gdiplustypes/ne-gdiplustypes-status

	return (GDIp[status])
}

;======================================================  General  ==============;

Class(variable) {
    if (IsObject(variable) && ObjGetCapacity(variable) == "") {
		Static regExMatchObject := NumGet(&(m, RegExMatch("", "O)", m))), boundFuncObject := NumGet(&(f := Func("Func").Bind())), fileObject := NumGet(&(f := FileOpen("*", "w"))), enumeratorObject := NumGet(&(e := ObjNewEnum({})))

        return ((IsFunc(variable)) ? ("FuncObject") : ((ComObjType(variable) != "") ? ("ComObject") : ((NumGet(&variable) == boundFuncObject) ? ("BoundFuncObject ") : ((NumGet(&variable) == regExMatchObject) ? ("RegExMatchObject") : ((NumGet(&variable) == fileObject) ? ("FileObject") : ((NumGet(&variable) == enumeratorObject) ? ("EnumeratorObject") : ("Property")))))))
	}

	return (RegExReplace(variable.__Class, "S)(.*?\.)(?!.*?\..*?)"))
}

;* Type(variable)
Type(variable) {  ;: https://www.autohotkey.com/boards/viewtopic.php?f=6&t=2306
    if (IsObject(variable)) {
		return ("Object")
	}

	if (InStr(variable, ".")) {
		variable := variable + 0  ;* Account for floats being treated as strings as they're stored in the string buffer.
	}

    return ([variable].GetCapacity(0) != "") ? ("String") : ((InStr(variable, ".")) ? ("Float") : ("Integer"))
}