;* GDIp.GdipCreateBitmap(width, height[, pixelFormat, stride, [Struct] scan0])
CreateBitmap(width, height, pixelFormat := 0x26200A, stride := 0, scan0 := 0) {
	Local

	if (status := DllCall("Gdiplus\GdipCreateBitmapFromScan0", "UInt", width, "UInt", height, "UInt", stride, "UInt", pixelFormat, "Ptr", scan0, "Ptr*", pBitmap := 0, "Int")) {  ;: https://docs.microsoft.com/en-us/windows/win32/api/gdiplusheaders/nf-gdiplusheaders-bitmap-bitmap(int_int_int_pixelformat_byte)
		throw (Exception(FormatStatus(status)))
	}

	return ({"Ptr": pBitmap
		, "Base": this.__Bitmap})
}

CreateBitmapFromFile(file) {
	Local

	if (status := DllCall("Gdiplus\GdipCreateBitmapFromFile", "Ptr", &file, "Ptr*", pBitmap := 0, "Int")) {
		throw (Exception(FormatStatus(status)))
	}

	return ({"Ptr": pBitmap
		, "Base": this.__Bitmap})
}

CreateBitmapFromGraphics(gaphics, width, height) {
	Local

	if (status := DllCall("Gdiplus\GdipCreateBitmapFromGraphics", "Int", width, "Int", height, "Ptr", graphics.Ptr, "Ptr*", pBitmap := 0, "Int")) {
		throw (Exception(FormatStatus(status)))
	}

	return ({"Ptr": pBitmap
		, "Base": this.__Bitmap})
}

CreateBitmapFromHWnd(hWnd, client := True) {
	hWnd := RegExReplace(hWnd, "i)ahk_id\s?")

	if (DllCall("User32\IsIconic", "Ptr", hWnd, "UInt")) {
		DllCall("User32\ShowWindow", "ptr", hWnd, "Int", 4)  ;* Restore the window if it is minimized as it must be visible for capture.
	}

	Static rect := CreateRect(0, 0, 0, 0, "Int")

	if (client) {
		if (!DllCall("User32\GetClientRect", "Ptr", hWnd, "Ptr", rect.Ptr, "UInt")) {
			throw (Exception(Format("0x{:X}", A_LastError), 0, FormatMessage(A_LastError)))
		}
	}
	else if (DllCall("Dwmapi\DwmGetWindowAttribute", "Ptr", hWnd, "UInt", 9, "UPtr", rect.Ptr, "UInt", 16, "UInt")) {
		if (!DllCall("User32\GetWindowRect", "Ptr", hWnd, "Ptr", rect.Ptr, "UInt")) {
			throw (Exception(Format("0x{:X}", A_LastError), 0, FormatMessage(A_LastError)))
		}
	}

	DC := GDI.CreateCompatibleDC()
	bitmap := GDI.CreateDIBSection(CreateBitmapInfoHeader(rect.NumGet(8, "Int"), -rect.NumGet(12, "Int")), DC)
		, DC.SelectObject(bitmap)

	if (!DllCall("User32\PrintWindow", "Ptr", hWnd, "Ptr", DC.Handle, "UInt", 2 + client, "UInt")) {
		throw (Exception(Format("0x{:X}", A_LastError), 0, FormatMessage(A_LastError)))
	}

	if (status := DllCall("Gdiplus\GdipCreateBitmapFromHBITMAP", "Ptr", DC.Reset("__Bitmap"), "Ptr", 0, "Ptr*", pBitmap := 0, "Int")) {
		throw (Exception(FormatStatus(status)))
	}

	return ({"Ptr": pBitmap
		, "Base": this.__Bitmap})
}

CreateBitmapFromScreen(params*) {
	switch (params.Length()) {
		case 4: {
			x := params[1], y := params[2]
				, width := params[3], height := params[4]
		}
		case 1: {

		}
		Default: {
			x := DllCall("User32\GetSystemMetrics", "Int", 76), y := DllCall("User32\GetSystemMetrics", "Int", 77)
				, width := DllCall("User32\GetSystemMetrics", "Int", 78), height := DllCall("User32\GetSystemMetrics", "Int", 79)
		}
	}

	DC := GDI.CreateCompatibleDC()
	bitmap := GDI.CreateDIBSection(CreateBitmapInfoHeader(width, -height), DC)
		, DC.SelectObject(bitmap)

	GDI.BitBlt(DC, 0, 0, width, height, GetDC(), x, y, 0x00CC0020 | 0x40000000)  ;? 0x00CC0020 = SRCCOPY, 0x40000000 = CAPTUREBLT

	if (status := DllCall("Gdiplus\GdipCreateBitmapFromHBITMAP", "Ptr", DC.Reset("__Bitmap"), "Ptr", 0, "Ptr*", pBitmap := 0, "Int")) {
		throw (Exception(FormatStatus(status)))
	}

	return ({"Ptr": pBitmap
		, "Base": this.__Bitmap})
}

Class __Bitmap {  ;~ http://paulbourke.net/dataformats/bitmaps/

	__Delete() {
		if (!this.HasKey("Ptr")) {
			MsgBox("GDIp.Bitmap.__Delete()")
		}

		DllCall("Gdiplus\GdipDisposeImage", "Ptr", this.Ptr)
	}

	CreateHandle(background := 0xFFFFFFFF) {
		Local

		if (status := DllCall("Gdiplus\GdipCreateHBITMAPFromBitmap", "Ptr", this.Ptr, "Ptr*", hBitmap := 0, "UInt", background, "Int")) {
			throw (Exception(FormatStatus(status)))
		}

		return (hBitmap)
	}

	Clone() {
		Local

		if (status := DllCall("Gdiplus\GdipCloneImage", "Ptr", this.Ptr, "Ptr*", pBitmap := 0, "Int")) {  ;* The new bitmap will have the same PixelFormat.
			throw (Exception(FormatStatus(status)))
		}

		return ({"Ptr": pBitmap
			, "Base": this.Base})
	}

	Width[] {
		Get {
			return (this.GetWidth())
		}
	}

	GetWidth() {
		Local

		if (status := DllCall("Gdiplus\GdipGetImageWidth", "Ptr", this.Ptr, "UInt*", width := 0, "Int")) {
			throw (Exception(FormatStatus(status)))
		}

		return (width)
	}

	Height[] {
		Get {
			return (this.GetHeight())
		}
	}

	GetHeight() {
		Local

		if (status := DllCall("Gdiplus\GdipGetImageHeight", "Ptr", this.Ptr, "UInt*", height := 0, "Int")) {
			throw (Exception(FormatStatus(status)))
		}

		return (height)
	}

	Pixel[params*] {
		Get {
			return (this.GetPixel(params[1], params[2]))
		}

		Set {
			params.Push(value)
			this.SetPixel(params*)

			return (value)
		}
	}

	SetPixel(params*) {
		Local color := params.RemoveAt(params.MaxIndex())

		if (this.HasKey("BitmapData")) {
			switch (params.Length(), stride := this.BitmapData.NumGet(8, "Int"), scan0 := this.BitmapData.NumGet(16, "Ptr")) {  ;* The Stride data member is negative if the pixel data is stored bottom-up.
				case 2: {
					Numput(color, scan0 + Math.Max(params[1], 0)*4 + Math.Max(params[2], 0)*stride, "UInt")
				}
				case 4: {
					reset := Math.Max(params[1], 0)
						, y := Math.Max(params[2], 0), width := Math.Clamp(params[3], 0, this.BitmapData.NumGet(0, "UInt")) - reset, height := Math.Clamp(params[4], 0, this.BitmapData.NumGet(4, "UInt")) - y
				}
				Default: {
					reset := 0
						, y := 0, width := this.BitmapData.NumGet(0, "UInt"), height := this.BitmapData.NumGet(4, "UInt")
				}
			}

			loop, % height {
				x := reset

				loop, % width {
					Numput(color, scan0 + 4*x++ + y*stride, "UInt")
				}

				y++
			}
		}
		else {
			Static GdipBitmapSetPixel := DllCall("Kernel32\GetProcAddress", "Ptr", handle := DllCall("Kernel32\LoadLibrary", "Str", "Gdiplus", "Ptr"), "AStr", "GdipBitmapSetPixel", "Ptr") + !DllCall("Kernel32\FreeLibrary", "Ptr", handle, "UInt")

			switch (params.Length(), pBitmap := this.Ptr) {
				case 2: {
					DllCall(GdipBitmapSetPixel, "Ptr", pBitmap, "Int", Math.Clamp(params[1], 0), "Int", Math.Clamp(params[2], 0), "Int", color)
				}
				case 4: {
					reset := Math.Max(params[1], 0)
						, y := Math.Max(params[2], 0), width := Math.Clamp(params[3], 0, this.Width) - reset, height := Math.Clamp(params[4], 0, this.Height) - y
				}
				Default: {
					reset := 0
						, y := 0, width := this.Width, height := this.Height
				}
			}

			loop, % height {
				x := reset

				loop, % width {
					DllCall(GdipBitmapSetPixel, "Ptr", pBitmap, "Int", x++, "Int", y, "UInt", color)
				}

				y++
			}
		}

		return (True)
	}

	PixelFormat[] {
		Get {
			return (this.GetPixelFormat())
		}
	}


	GetPixel(x, y) {
		Local

		if (this.HasKey("BitmapData")) {
			color := NumGet(this.BitmapData.Scan0 + x*4 + y*this.BitmapData.Stride, "UInt")
		}
		else {
			DllCall("Gdiplus\GdipBitmapGetPixel", "Ptr", this.Ptr, "Int", x, "Int", y, "UInt*", color := 0)
		}

		return (Format("0x{:X}", color))
	}

	GetPixelFormat() {
		Local

		if (status := DllCall("Gdiplus\GdipGetImagePixelFormat", "Ptr", this.Ptr, "UInt*", pixelFormat := 0, "Int")) {
			throw (Exception(FormatStatus(status)))
		}

		return (pixelFormat)
	}

	;* bitmap.LockBits([x, y, width, height, pixelFormat, flags])
	;* Parameter:
		;* flags:
			;? 0x0001: ImageLockModeRead
			;? 0x0002: ImageLockModeWrite
			;? 0x0004: ImageLockModeUserInputBuf
	LockBits(x := 0, y := 0, width := 0, height := 0, pixelFormat := "", flags := 0x0003) {  ;? http://supercomputingblog.com/graphics/using-lockbits-in-gdi/
		if (!this.HasKey("BitmapData")) {
			if (!width) {
				width := this.Width
			}

			if (!height) {
				height := this.Height
			}

			Static bitmapData := CreateBitmapData()

			if (status := DllCall("Gdiplus\GdipBitmapLockBits", "Ptr", this.Ptr, "Ptr", CreateRect(x, y, width, height, "UInt").Ptr, "UInt", flags, "Int", (pixelFormat == "") ? (this.PixelFormat) : (pixelFormat), "Ptr", bitmapData.Ptr, "Int")) {  ;: https://docs.microsoft.com/en-us/windows/win32/api/gdiplusheaders/nf-gdiplusheaders-bitmap-lockbits
				throw (Exception(FormatStatus(status)))
			}

			return (True
				, this.BitmapData := bitmapData)  ;~ LockBits returning too much data: https://github.com/dotnet/runtime/issues/28600.
		}

		return (False)
	}

	UnlockBits() {
		if (this.HasKey("BitmapData")) {
			if (status := DllCall("Gdiplus\GdipBitmapUnlockBits", "Ptr", this.Ptr, "Ptr", this.BitmapData.Ptr, "Int")) {  ;: https://docs.microsoft.com/en-us/windows/win32/api/gdiplusheaders/nf-gdiplusheaders-bitmap-lockbits
				throw (Exception(FormatStatus(status)))
			}

			return (True
				, this.Delete("BitmapData"))
		}

		return (False)
	}

	SaveToFile(file) {
		if (status := DllCall("Gdiplus\GdipGetImageEncodersSize", "UInt*", number := 0, "UInt*", size := 0), "Int") {  ;: https://docs.microsoft.com/en-us/windows/win32/gdiplus/-gdiplus-retrieving-the-class-identifier-for-an-encoder-use
			throw (Exception(FormatStatus(status)))
		}

		if (status := DllCall("Gdiplus\GdipGetImageEncoders", "UInt", number, "UInt", size, "Ptr", (imageCodecInfo := new Structure(size)).Ptr, "Int")) {  ;* Fill a buffer with the available encoders.
			throw (Exception(FormatStatus(status)))
		}

		RegExMatch(file, "\.\w+$", extension)

		loop, % number {
			if (InStr(StrGet(imageCodecInfo.NumGet(A_PtrSize*3 + (offset := (48 + A_PtrSize*7)*(A_Index - 1)) + 32, "Ptr"), "UTF-16"), "*" . extension)) {
				pCodec := imageCodecInfo.Ptr + offset  ;* Get the pointer to the matching encoder.

				break
			}
		}

		if (!pCodec) {
			throw (Exception("Could not find a matching encoder for the specified file format."))
		}

		if (status := DllCall("Gdiplus\GdipSaveImageToFile", "Ptr", this.Ptr, "Ptr", &file, "Ptr", pCodec, "UInt", 0, "Int")) {
			throw (Exception(FormatStatus(status)))
		}

		return (True)
	}
}