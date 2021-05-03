;==============  Include  ======================================================;

#Include, %A_LineFile%\..\ObjectOriented\ObjectOriented.ahk
#Include, %A_LineFile%\..\Structure\Structure.ahk

;============== Function ======================================================;
;======================================================  Library  ==============;

FreeLibrary(library) {  ;: https://www.autohotkey.com/boards/viewtopic.php?p=48392#p48392
	if (--library.Count[library.Ptr] == 0) {
        DllCall("FreeLibrary", "Ptr", library.Ptr)
	}
}

LoadLibrary(fileName) {  ;* "User32", "Kernel32", "ComCtl32" and "Gdi32" are already loaded.
	if (!(ptr := DllCall("LoadLibrary", "Str", fileName, "Ptr"))) {
		return (0)
	}

	Static count := {}

	count[ptr] := (count[ptr]) ? (count[ptr] + 1) : (1)

	Static library := {"Count": count
			, "__Class": "Library"

			, "__Delete": Func("FreeLibrary")}

	(o := new library()).Ptr := ptr
		, p := ptr + NumGet(ptr + 0x3C, "Int") + 24

	if (NumGet(p + ((A_PtrSize == 4) ? (92) : (108)), "UInt") < 1 || (ts := NumGet(p + ((A_PtrSize == 4) ? (96) : (112)), "UInt") + ptr) == ptr || (te := NumGet(p + (A_PtrSize == 4) ? (100) : (116), "UInt") + ts) == ts) {
		return (o)
	}

	loop % (NumGet(ts + 24, "UInt"), n := ptr + NumGet(ts + 32, "UInt")) {
		if (p := NumGet(n + (A_Index - 1)*4, "UInt")) {
			o[f := StrGet(ptr + p, "CP0")] := DllCall("GetProcAddress", "Ptr", ptr, "AStr", f, "Ptr")

			if (SubStr(f, 0) == ((A_IsUnicode) ? "W" : "A")) {
				o[SubStr(f, 1, -1)] := o[f]
			}
		}
	}

	return (o)
}

;=================================================== Error Handling ===========;

;* FormatMessage(messageID)
FormatMessage(messageID) {  ;: https://docs.microsoft.com/en-us/windows/win32/api/winbase/nf-winbase-formatmessage
	if (!length := DllCall("Kernel32\FormatMessage", "UInt", 0x1100, "Ptr", 0, "UInt", messageID, "UInt", 0, "Ptr", (buffer := new Structure(A_PtrSize)).Pointer, "UInt", 0, "UInt*", 0, "UInt")) {
		return (FormatMessage(DllCall("Kernel32\GetLastError")))
	}

	return (StrGet(buffer.NumGet(0, "Ptr"), length - 2))  ;* Account for the newline and carriage return characters.
}

;======================================================  General  ==============;

;* Type(variable)
Type(variable) {  ;: https://www.autohotkey.com/boards/viewtopic.php?f=6&t=2306
    if (IsObject(variable)) {
		Static regExMatchObject := NumGet(&(m, RegExMatch("", "O)", m))), boundFuncObject := NumGet(&(f := Func("Func").Bind())), fileObject := NumGet(&(f := FileOpen("*", "w"))), enumeratorObject := NumGet(&(e := ObjNewEnum({})))

        return ((ObjGetCapacity(variable) != "") ? (RegExReplace(variable.__Class, "S)(.*?\.|__)(?!.*?\..*?)")) : ((IsFunc(variable)) ? ("FuncObject") : ((ComObjType(variable) != "") ? ("ComObject") : ((NumGet(&variable) == boundFuncObject) ? ("BoundFuncObject ") : ((NumGet(&variable) == regExMatchObject) ? ("RegExMatchObject") : ((NumGet(&variable) == fileObject) ? ("FileObject") : ((NumGet(&variable) == enumeratorObject) ? ("EnumeratorObject") : ("Property"))))))))
	}

	if (InStr(variable, ".")) {
		variable := variable + 0  ;* Account for floats being treated as strings as they're stored in the string buffer.
	}

    return ([variable].GetCapacity(0) != "") ? ("String") : ((InStr(variable, ".")) ? ("Float") : ("Integer"))
}