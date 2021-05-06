Class GDIp {

	__New(params*) {
        throw (Exception("GDIp.__New()", -1, "This class object should not be constructed."))
	}

	Startup() {
		Local

		if (!this.Token) {
			LoadLibrary("Gdiplus")

			if (status := DllCall("Gdiplus\GdiplusStartup", "Ptr*", pToken := 0, "Ptr", CreateGDIplusStartupInput().Ptr, "Ptr", 0, "Int")) {  ;: https://docs.microsoft.com/en-us/windows/win32/api/gdiplusinit/nf-gdiplusinit-gdiplusstartup
				throw (Exception(FormatStatus(status)))
			}

			return (True
				, this.Token := pToken)
		}

		return (False)
	}

	Shutdown() {
		if (this.Token) {
			DllCall("Gdiplus\GdiplusShutdown", "Ptr", this.Remove("Token"))

			FreeLibrary("Gdiplus")

			return (True)
		}

		return (False)
	}

	#Include, %A_LineFile%\..\GDIp\__Canvas.ahk

	#Include, %A_LineFile%\..\GDIp\__Bitmap.ahk

	#Include, %A_LineFile%\..\GDIp\__Graphics.ahk

	#Include, %A_LineFile%\..\GDIp\__Brush.ahk

	#Include, %A_LineFile%\..\GDIp\__Pen.ahk
}