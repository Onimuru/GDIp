/*
;* enum ImageFlags  ;: https://docs.microsoft.com/en-us/windows/win32/api/gdiplusimaging/ne-gdiplusimaging-imageflags
	0x00000000 = ImageFlagsNone
	0x00000001 = ImageFlagsScalable
	0x00000002 = ImageFlagsHasAlpha
	0x00000004 = ImageFlagsHasTranslucent
	0x00000008 = ImageFlagsPartiallyScalable
	0x00000010 = ImageFlagsColorSpaceRGB
	0x00000020 = ImageFlagsColorSpaceCMYK
	0x00000040 = ImageFlagsColorSpaceGRAY
	0x00000080 = ImageFlagsColorSpaceYCBCR
	0x00000100 = ImageFlagsColorSpaceYCCK
	0x00001000 = ImageFlagsHasRealDPI
	0x00002000 = ImageFlagsHasRealPixelSize
	0x00010000 = ImageFlagsReadOnly
	0x00020000 = ImageFlagsCaching

;* enum ImageLockMode  ;: https://docs.microsoft.com/en-us/windows/win32/api/gdiplusimaging/ne-gdiplusimaging-imagelockmode
	0x0001 = ImageLockModeRead
	0x0002 = ImageLockModeWrite
	0x0004 = ImageLockModeUserInputBuf

;* enum PixelFormat  ;: https://docs.microsoft.com/en-us/openspecs/windows_protocols/ms-emfplus/47cbe48e-d13c-450b-8a23-6aa95488428e
	0x00030101 = PixelFormat1bppIndexed
	0x00030402 = PixelFormat4bppIndexed
	0x00030803 = PixelFormat8bppIndexed
	0x00101004 = PixelFormat16bppGrayScale
	0x00021005 = PixelFormat16bppRGB555
	0x00021006 = PixelFormat16bppRGB565
	0x00061007 = PixelFormat16bppARGB1555
	0x00021808 = PixelFormat24bppRGB
	0x00022009 = PixelFormat32bppRGB
	0x0026200A = PixelFormat32bppARGB
	0x000E200B = PixelFormat32bppPARGB
	0x0010300C = PixelFormat48bppRGB
	0x0034400D = PixelFormat64bppARGB
	0x001A400E = PixelFormat64bppPARGB

;* enum RotateFlipType  ;: https://docs.microsoft.com/en-us/windows/win32/api/gdiplusimaging/ne-gdiplusimaging-rotatefliptype
	0 = RotateNoneFlipNone || Rotate180FlipXY
	1 = Rotate90FlipNone || Rotate270FlipXY
	2 = Rotate180FlipNone || RotateNoneFlipXY
	3 = Rotate270FlipNone || Rotate90FlipXY
	4 = RotateNoneFlipX || Rotate180FlipY
	5 = Rotate90FlipX || Rotate270FlipY
	6 = Rotate180FlipX || RotateNoneFlipY
	7 = Rotate270FlipX || Rotate90FlipY
*/

;* GDIp.GdipCreateBitmap(width, height[, pixelFormat, stride, [__Structure] scan0])
;* Parameter:
	;* pixelFormat - See PixelFormat enumeration.
CreateBitmap(width, height, pixelFormat := 0x26200A, stride := 0, scan0 := 0) {
	Local

	if (status := DllCall("Gdiplus\GdipCreateBitmapFromScan0", "UInt", width, "UInt", height, "UInt", stride, "UInt", pixelFormat, "Ptr", scan0, "Ptr*", pBitmap := 0, "Int")) {  ;: https://docs.microsoft.com/en-us/windows/win32/api/gdiplusheaders/nf-gdiplusheaders-bitmap-bitmap(int_int_int_pixelformat_byte)
		throw (Exception(FormatStatus(status)))
	}

	return ({"Ptr": pBitmap
		, "Base": this.__Bitmap})
}

;~ CreateBitmapFromDirectDrawSurface()

CreateBitmapFromFile(file, useICM := 0) {
	Local

	if (status := (useICM)
		? (DllCall("Gdiplus\GdipCreateBitmapFromFileICM", "Ptr", &file, "Ptr*", pBitmap := 0, "Int"))
		: (DllCall("Gdiplus\GdipCreateBitmapFromFile", "Ptr", &file, "Ptr*", pBitmap := 0, "Int"))) {
		throw (Exception(FormatStatus(status)))
	}

	return ({"Ptr": pBitmap
		, "Base": this.__Bitmap})
}

;~ CreateBitmapFromGdiDIB

CreateBitmapFromGraphics(graphics, width, height) {
	Local

	if (status := DllCall("Gdiplus\GdipCreateBitmapFromGraphics", "Int", width, "Int", height, "Ptr", graphics.Ptr, "Ptr*", pBitmap := 0, "Int")) {
		throw (Exception(FormatStatus(status)))
	}

	return ({"Ptr": pBitmap
		, "Base": this.__Bitmap})
}

;~ CreateBitmapFromHBITMAP
;~ CreateBitmapFromHICON
;~ CreateBitmapFromResource

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

;~ CreateBitmapFromStream, CreateBitmapFromStreamICM

CreateBitmapFromWindow(hWnd, client := True) {
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

;~ CreateHBITMAPFromBitmap
;~ CreateHICONFromBitmap

Class __Bitmap {  ;~ http://paulbourke.net/dataformats/bitmaps/

	__Delete() {
		if (!this.HasKey("Ptr")) {
			MsgBox("Bitmap.__Delete()")
		}

		DllCall("Gdiplus\GdipDisposeImage", "Ptr", this.Ptr)
	}

	;* bitmap.Clone([x, y, width, height, pixelFormat])
	;* Parameter:
		;* pixelFormat - See PixelFormat enumeration.
	Clone(x := "", y := "", width := "", height := "", pixelFormat := "") {
		Local

		if (status := (x == "" || y == "" || width == "" || height == "")
			? (DllCall("Gdiplus\GdipCloneImage", "Ptr", this.Ptr, "Ptr*", pBitmap := 0, "Int"))  ;* The new bitmap will have the same PixelFormat.
			: (DllCall("Gdiplus\GdipCloneBitmapArea", "Float", x, "Float", y, "Float", width, "Float", height, "UInt", (pixelFormat) ? (pixelFormat) : (this.GetPixelFormat()), "Ptr", this.Ptr, "Ptr*", pBitmap := 0, "Int"))) {
			throw (Exception(FormatStatus(status)))
		}

		return ({"Ptr": pBitmap
			, "Base": this.Base})
	}

	;-------------- Property ------------------------------------------------------;

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

	Flags[] {
		Get {
			return (this.GetFlags())
		}
	}

	;* bitmap.GetFlags()
	;* Return:
		;* * - See ImageFlags enumeration.
	GetFlags() {
		Local

		if (status := DllCall("Gdiplus\GdipGetImageFlags", "Ptr", this.Ptr, "UInt*", flags := 0, "Int")) {
			throw (Exception(FormatStatus(status)))
		}

		return (Format("0x{:08X}", flags))
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

	GetPixel(x, y) {
		Local

		if (this.HasKey("BitmapData")) {
			color := NumGet(this.BitmapData.Scan0 + x*4 + y*this.BitmapData.Stride, "UInt")
		}
		else {
			Static GdipBitmapGetPixel := DllCall("Kernel32\GetProcAddress", "Ptr", handle := DllCall("Kernel32\LoadLibrary", "Str", "Gdiplus", "Ptr"), "AStr", "GdipBitmapGetPixel", "Ptr") + !DllCall("Kernel32\FreeLibrary", "Ptr", handle, "UInt")

			DllCall(GdipBitmapGetPixel, "Ptr", this.Ptr, "Int", x, "Int", y, "UInt*", color)  ;~ No error handling.
		}

		return (Format("0x{:08X}", color))
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
				loop, % (width, x := reset) {
					Numput(color, scan0 + 4*x++ + y*stride, "UInt")
				}

				y++
			}
		}
		else {
			Static GdipBitmapSetPixel := DllCall("Kernel32\GetProcAddress", "Ptr", handle := DllCall("Kernel32\LoadLibrary", "Str", "Gdiplus", "Ptr"), "AStr", "GdipBitmapSetPixel", "Ptr") + !DllCall("Kernel32\FreeLibrary", "Ptr", handle, "UInt")

			switch (params.Length()) {
				case 2: {
					DllCall(GdipBitmapSetPixel, "Ptr", this.Ptr, "Int", Math.Max(params[1], 0), "Int", Math.Max(params[2], 0), "Int", color)
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

			loop, % (height, pBitmap := this.Ptr) {
				loop, % (width, x := reset) {
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

	;* bitmap.GetPixelFormat()
	;* Return:
		;* * - See PixelFormat enumeration.
	GetPixelFormat() {
		Local

		if (status := DllCall("Gdiplus\GdipGetImagePixelFormat", "Ptr", this.Ptr, "UInt*", pixelFormat := 0, "Int")) {
			throw (Exception(FormatStatus(status)))
		}

		return (Format("0x{:08X}", pixelFormat))
	}

	GetThumbnail(width, height) {
		Local

		if (status := DllCall("Gdiplus\GdipGetImageThumbnail", "Ptr", bitmap.Ptr, "UInt", width, "UInt", height, "Ptr*", pBitmap := 0, "Ptr", 0, "Ptr", 0, "Int")) {
			throw (Exception(FormatStatus(status)))
		}

		return ({"Ptr": pBitmap
			, "Base": this.Base})
	}

	;--------------- Method -------------------------------------------------------;

	;~ ApplyEffect
	;~ ConvertFormat
	;~ CreateApplyEffect
	;~ GetHistogram
	;~ GetHistogramSize
	;~ SetResolution

	;* bitmap.LockBits([x, y, width, height, pixelFormat, lockMode])
	;* Parameter:
		;* pixelFormat - See PixelFormat enumeration.
		;* lockMode - See ImageLockMode enumeration.
	LockBits(x := 0, y := 0, width := "", height := "", lockMode := 0x0003, pixelFormat := "") {  ;? http://supercomputingblog.com/graphics/using-lockbits-in-gdi/
		Local

		if (!this.HasKey("BitmapData")) {
			if (width == "") {
				if (height == "") {
					DllCall("Gdiplus\GdipGetImageDimension", "Ptr", this.Ptr, "Float*", width := 0, "Float*", height := 0)
				}
				else {
					DllCall("Gdiplus\GdipGetImageWidth", "Ptr", this.Ptr, "UInt*", width := 0, "Int")
				}
			}
			else if (height == "") {
				DllCall("Gdiplus\GdipGetImageHeight", "Ptr", this.Ptr, "UInt*", height := 0, "Int")
			}

			Static bitmapData := CreateBitmapData()

			if (status := DllCall("Gdiplus\GdipBitmapLockBits", "Ptr", this.Ptr, "Ptr", CreateRect(x, y, width, height, "UInt").Ptr, "UInt", lockMode, "UInt", (pixelFormat) ? (pixelFormat) : (this.GetPixelFormat()), "Ptr", bitmapData.Ptr, "Int")) {  ;: https://docs.microsoft.com/en-us/windows/win32/api/gdiplusheaders/nf-gdiplusheaders-bitmap-lockbits
				throw (Exception(FormatStatus(status)))
			}

			this.BitmapData := bitmapData  ;~ LockBits returning too much data: https://github.com/dotnet/runtime/issues/28600.

			return (True)
		}

		return (False)
	}

	UnlockBits() {
		Local

		if (this.HasKey("BitmapData")) {
			if (status := DllCall("Gdiplus\GdipBitmapUnlockBits", "Ptr", this.Ptr, "Ptr", this.Remove("BitmapData").Ptr, "Int")) {  ;: https://docs.microsoft.com/en-us/windows/win32/api/gdiplusheaders/nf-gdiplusheaders-bitmap-lockbits
				throw (Exception(FormatStatus(status)))
			}

			return (True)
		}

		return (False)
	}

	;* bitmap.RotateFlip(rotateType)
	;* Parameter:
		;* rotateType - See RotateFlipType enumeration.
	RotateFlip(rotateType) {
		Local

		if (status := DllCall("Gdiplus\GdipImageRotateFlip", "Ptr", this.Ptr, "Int", rotateType, "Int")) {
			throw (Exception(FormatStatus(status)))
		}

		return (True)
	}

	SaveToFile(file) {
		if (status := DllCall("Gdiplus\GdipGetImageEncodersSize", "UInt*", number := 0, "UInt*", size := 0), "Int") {
			throw (Exception(FormatStatus(status)))
		}

		if (status := DllCall("Gdiplus\GdipGetImageEncoders", "UInt", number, "UInt", size, "Ptr", (imageCodecInfo := new Structure(size)).Ptr, "Int")) {  ;* Fill a buffer with the available encoders.
			throw (Exception(FormatStatus(status)))
		}

		loop, % (number, RegExMatch(file, "\.\w+$", extension)) {
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

CreateCachedBitmap(bitmap, graphics) {
	if (status := DllCall("Gdiplus\GdipCreateCachedBitmap", "Ptr", bitmap.Ptr, "Ptr", graphics.Ptr, "Ptr*", pCachedBitmap := 0, "Int")) {
		throw (Exception(FormatStatus(status)))
	}

	return ({"Ptr": pCachedBitmap
		, "Base": this.__CachedBitmap})
}

Class __CachedBitmap {

	__Delete() {
		if (!this.HasKey("Ptr")) {
			MsgBox("CachedBitmap.__Delete()")
		}

		DllCall("Gdiplus\GdipDeleteCachedBitmap", "Ptr", this.Ptr)
	}
}