;* GDIp.CreateCanvas(x, y, width, height[, guiOptions, showOptions, smoothing, interpolation])
CreateCanvas(x, y, width, height, guiOptions := "", showOptions := "NA", title := "", smoothing := 4, interpolation := 7) {
	Gui, % Format("{}: New", title), % Format("{} +hWndhWnd +E0x80000", RegExReplace(guiOptions, "\+E0x80000"))  ;* Create a layered window (`"+E0x80000"` must be used for `UpdateLayeredWindow` to work).
	Gui, Show, % showOptions, % title

	instance := {"Handle": hWnd  ;* Save a handle to the window in order to update it.
		, "Base": this.__Canvas}

	instance.DC := GDI.CreateCompatibleDC()  ;* Get a memory DC compatible with the screen.
	instance.Bitmap := GDI.CreateDIBSection(CreateBitmapInfoHeader(width, -height), instance.DC)  ;* Create a GDI bitmap.
		, instance.DC.SelectObject(instance.Bitmap)  ;* Select the DIB into the memory DC.

	(instance.Graphics := this.CreateGraphicsFromDC(instance.DC)).SetSmoothingMode(smoothing)
		, instance.Graphics.SetInterpolationMode(interpolation)

	instance.Update(x, y, width, height)

	return (instance)
}

Class __Canvas {

	__Delete() {
		if (!this.Handle) {
			MsgBox("Canvas.__Delete()")
		}

		Gui, % Format("{}: Destroy", this.Handle)
	}

	IsVisible[] {
		Get {
			Local

			detect := A_DetectHiddenWindows
			DetectHiddenWindows, Off

			exist := WinExist("ahk_id" . this.Handle)

			DetectHiddenWindows, % detect

			return (!!exist)
		}
	}

	Title[] {
		Get {
			Local

			detect := A_DetectHiddenWindows
			DetectHiddenWindows, On

			WinGetTitle, title, % "ahk_id" . this.Handle

			DetectHiddenWindows, % detect

			return (title)
		}

		Set {
			WinSetTitle, % this.Handle, , % value

			return (value)
		}
	}

	Clear() {
		this.Graphics.Clear()
	}

	Reset() {
		this.Graphics.Reset()
	}

	Hide() {
		Gui, % Format("{}: Hide", this.Handle)
	}

	Show(options := "NA") {
		Gui, % Format("{}: Show", this.Handle), % options
	}

	Update(x := "", y := "", width := "", height := "", alpha := "") {
		Static point := CreatePoint(0, 0, "UInt"), size := CreateSize(0, 0), blend := CreateBlendFunction(0xFF)

		if (x != "") {
			point.NumPut(0, "UInt", this.x := x)
		}

		if (y != "") {
			point.NumPut(4, "UInt", this.y := y)
		}

		if (width != "") {
			size.NumPut(0, "UInt", this.Width := width)
		}

		if (height != "") {
			size.NumPut(4, "UInt", this.Height := height)
		}

		if (alpha != "") {
			blend.NumPut(2, "UChar", this.Alpha := alpha)
		}

		if (!DllCall("User32\UpdateLayeredWindow", "Ptr", this.Handle, "Ptr", 0, "Ptr", point.Ptr, "Ptr", size.Ptr, "Ptr", this.DC.Handle, "Int64*", 0, "UInt", 0, "Ptr", blend.Ptr, "UInt", 0x00000002, "UInt")) {
			throw (Exception(Format("0x{:X}", A_LastError), 0, FormatMessage(A_LastError)))
		}

		return (True)
	}
}