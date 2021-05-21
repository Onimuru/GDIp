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
	0 = RotateNoneFlipNone
	1 = Rotate90FlipNone
	2 = Rotate180FlipNone
	3 = Rotate270FlipNone
	4 = RotateNoneFlipX
	5 = Rotate90FlipX
	6 = Rotate180FlipX
	7 = Rotate270FlipX
	RotateNoneFlipY = Rotate180FlipX
	Rotate90FlipY = Rotate270FlipX
	Rotate180FlipY = RotateNoneFlipX
	Rotate270FlipY = Rotate90FlipX
	RotateNoneFlipXY = Rotate180FlipNone
	Rotate90FlipXY = Rotate270FlipNone
	Rotate180FlipXY = RotateNoneFlipNone
	Rotate270FlipXY = Rotate90FlipNone
*/

;* GDIp.CreateBitmap(width, height[, pixelFormat, stride, scan0])
;* Parameter:
	;* [Integer] width
	;* [Integer] height
	;* [Integer] pixelFormat - See PixelFormat enumeration.
	;* [Integer] stride
	;* [Structure] scan0
;* Return:
	;* [Bitmap]
static CreateBitmap(width, height, pixelFormat := 0x26200A, stride := 0, scan0 := 0) {
	if (status := DllCall("Gdiplus\GdipCreateBitmapFromScan0", "UInt", width, "UInt", height, "UInt", stride, "UInt", pixelFormat, "Ptr", scan0, "Ptr*", &(pBitmap := 0), "Int")) {  ;: https://docs.microsoft.com/en-us/windows/win32/api/gdiplusheaders/nf-gdiplusheaders-bitmap-bitmap(int_int_int_pixelformat_byte)
		throw (ErrorFromStatus(status))
	}

	(instance := this.Bitmap()).Ptr := pBitmap
	return (instance)
}

;~ CreateBitmapFromDirectDrawSurface()

;* GDIp.CreateBitmapFromFile(file[, useICM])
;* Parameter:
	;* [String] file
	;* [Integer] useICM
;* Return:
	;* [Bitmap]
static CreateBitmapFromFile(file, useICM := False) {
	if (status := (useICM)
		? (DllCall("Gdiplus\GdipCreateBitmapFromFileICM", "Ptr", StrPtr(file), "Ptr*", &(pBitmap := 0), "Int"))
		: (DllCall("Gdiplus\GdipCreateBitmapFromFile", "Ptr", StrPtr(file), "Ptr*", &(pBitmap := 0), "Int"))) {
		throw (ErrorFromStatus(status))
	}

	(instance := this.Bitmap()).Ptr := pBitmap
	return (instance)
}

;~ CreateBitmapFromGdiDIB

;* GDIp.CreateBitmapFromGraphics(graphics, width, height)
;* Parameter:
	;* [Graphics] graphics
	;* [Integer] width
	;* [Integer] height
;* Return:
	;* [Bitmap]
static CreateBitmapFromGraphics(graphics, width, height) {
	if (status := DllCall("Gdiplus\GdipCreateBitmapFromGraphics", "Int", width, "Int", height, "Ptr", graphics.Ptr, "Ptr*", &(pBitmap := 0), "Int")) {
		throw (ErrorFromStatus(status))
	}

	(instance := this.Bitmap()).Ptr := pBitmap
	return (instance)
}

;~ CreateBitmapFromHBITMAP
;~ CreateBitmapFromHICON
;~ CreateBitmapFromResource

;* GDIp.CreateBitmapFromScreen([x, y, width, height])
;* Parameter:
	;* [Integer] x
	;* [Integer] y
	;* [Integer] width
	;* [Integer] height
;* Return:
	;* [Bitmap]
static CreateBitmapFromScreen(params*) {
	switch (params.Length) {
		case 4:
			x := params[0], y := params[1]
				, width := params[2], height := params[3]
		case 1:

		default:
			x := DllCall("User32\GetSystemMetrics", "Int", 76), y := DllCall("User32\GetSystemMetrics", "Int", 77)
				, width := DllCall("User32\GetSystemMetrics", "Int", 78), height := DllCall("User32\GetSystemMetrics", "Int", 79)
	}

	DC := GDI.CreateCompatibleDC()
	bitmap := GDI.CreateDIBSection(Structure.CreateBitmapInfoHeader(width, -height), DC)
		, DC.SelectObject(bitmap)

	GDI.BitBlt(DC, 0, 0, width, height, GetDC(), x, y, 0x40CC0020)  ;? 0x40CC0020 = SRCCOPY | CAPTUREBLT

	if (status := DllCall("Gdiplus\GdipCreateBitmapFromHBITMAP", "Ptr", bitmap.Handle, "Ptr", 0, "Ptr*", &(pBitmap := 0), "Int")) {
		throw (ErrorFromStatus(status))
	}

	(instance := this.Bitmap()).Ptr := pBitmap
	return (instance)
}

;~ CreateBitmapFromStream, CreateBitmapFromStreamICM

;* GDIp.CreateBitmapFromWindow(hWnd[, client])
;* Parameter:
	;* [Integer] hWnd
	;* [Integer] client
;* Return:
	;* [Bitmap]
static CreateBitmapFromWindow(hWnd, client := True) {
	if (DllCall("User32\IsIconic", "Ptr", hWnd, "UInt")) {
		DllCall("User32\ShowWindow", "ptr", hWnd, "Int", 4)  ;* Restore the window if it is minimized as it must be visible for capture.
	}

	static rect := Structure.CreateRect(0, 0, 0, 0, "Int")

	if (client) {
		if (!(DllCall("User32\GetClientRect", "Ptr", hWnd, "Ptr", rect.Ptr, "UInt"))) {
			throw (ErrorFromMessage(DllCall("Kernel32\GetLastError")))
		}
	}
	else if (DllCall("Dwmapi\DwmGetWindowAttribute", "Ptr", hWnd, "UInt", 9, "UPtr", rect.Ptr, "UInt", 16, "UInt")) {
		if (!(DllCall("User32\GetWindowRect", "Ptr", hWnd, "Ptr", rect.Ptr, "UInt"))) {
			throw (ErrorFromMessage(DllCall("Kernel32\GetLastError")))
		}
	}

	DC := GDI.CreateCompatibleDC()
	bitmap := GDI.CreateDIBSection(Structure.CreateBitmapInfoHeader(rect.NumGet(8, "Int"), -rect.NumGet(12, "Int")), DC)
		, DC.SelectObject(bitmap)

	if (!(DllCall("User32\PrintWindow", "Ptr", hWnd, "Ptr", DC.Handle, "UInt", 2 + client, "UInt"))) {
		throw (ErrorFromMessage(DllCall("Kernel32\GetLastError")))
	}

	if (status := DllCall("Gdiplus\GdipCreateBitmapFromHBITMAP", "Ptr", bitmap.Handle, "Ptr", 0, "Ptr*", &(pBitmap := 0), "Int")) {
		throw (ErrorFromStatus(status))
	}

	(instance := this.Bitmap()).Ptr := pBitmap
	return (instance)
}

;~ CreateHBITMAPFromBitmap
;~ CreateHICONFromBitmap

/*
** A Beginners Guide to Bitmaps: http://paulbourke.net/dataformats/bitmaps/. **
*/

class Bitmap {
	Class := "Bitmap"

	;* bitmap.Clone([x, y, width, height, pixelFormat])
	;* Parameter:
		;* [Float] x
		;* [Float] y
		;* [Float] width
		;* [Float] height
		;* [Integer] pixelFormat - See PixelFormat enumeration.
	;* Note:
		;~ The new bitmap will have the same pixel format.
	;* Return:
		;* [Bitmap]
	Clone(x := unset, y := unset, width := unset, height := unset, pixelFormat := unset) {
		if (status := (IsSet(x) && IsSet(y) && IsSet(width) && IsSet(height))
			? (DllCall("Gdiplus\GdipCloneBitmapArea", "Float", x, "Float", y, "Float", width, "Float", height, "UInt", (IsSet(pixelFormat)) ? (pixelFormat) : (this.GetPixelFormat()), "Ptr", this.Ptr, "Ptr*", &(pBitmap := 0), "Int"))
			: (DllCall("Gdiplus\GdipCloneImage", "Ptr", this.Ptr, "Ptr*", &(pBitmap := 0), "Int"))) {
			throw (ErrorFromStatus(status))
		}

		(instance := GDIp.Bitmap()).Ptr := pBitmap
		return (instance)
	}

	__Delete() {
		if (status := DllCall("Gdiplus\GdipDisposeImage", "Ptr", this.Ptr, "Int")) {
			throw (ErrorFromStatus(status))
		}
	}

	;-------------- Property ------------------------------------------------------;

	Width {
		Get {
			return (this.GetWidth())
		}
	}

	;* bitmap.GetWidth()
	;* Return:
		;* [Integer]
	GetWidth() {
		if (status := DllCall("Gdiplus\GdipGetImageWidth", "Ptr", this.Ptr, "UInt*", &(width := 0), "Int")) {
			throw (ErrorFromStatus(status))
		}

		return (width)
	}

	Height {
		Get {
			return (this.GetHeight())
		}
	}

	;* bitmap.GetHeight()
	;* Return:
		;* [Integer]
	GetHeight() {
		if (status := DllCall("Gdiplus\GdipGetImageHeight", "Ptr", this.Ptr, "UInt*", &(height := 0), "Int")) {
			throw (ErrorFromStatus(status))
		}

		return (height)
	}

	Flags {
		Get {
			return (this.GetFlags())
		}
	}

	;* bitmap.GetFlags()
	;* Return:
		;* [Integer] - See ImageFlags enumeration.
	GetFlags() {
		if (status := DllCall("Gdiplus\GdipGetImageFlags", "Ptr", this.Ptr, "UInt*", &(flags := 0), "Int")) {
			throw (ErrorFromStatus(status))
		}

		return (flags)
	}

	Pixel[params*] {
		Get {
			return (this.GetPixel(params[0], params[1]))
		}
	}

	;* bitmap.GetPixel(x, y)
	;* Parameter:
		;* [Integer] x
		;* [Integer] y
	;* Return:
		;* [Integer]
	GetPixel(x, y) {
		if (this.HasProp("BitmapData")) {
			color := NumGet(this.BitmapData.Scan0 + x*4 + y*this.BitmapData.Stride, "UInt")
		}
		else {
			static GdipBitmapGetPixel := DllCall("Kernel32\GetProcAddress", "Ptr", handle := DllCall("Kernel32\LoadLibrary", "Str", "Gdiplus", "Ptr"), "AStr", "GdipBitmapGetPixel", "Ptr") + !DllCall("Kernel32\FreeLibrary", "Ptr", handle, "UInt")

			DllCall(GdipBitmapGetPixel, "Ptr", this.Ptr, "Int", x, "Int", y, "UInt*", color)  ;~ No error handling.
		}

		return (color)
	}

	;* bitmap.SetPixel([x, y, width, height, ]color)
	;* Parameter:
		;* [Integer] x
		;* [Integer] y
		;* [Integer] width
		;* [Integer] height
		;* [Integer] color
	SetPixel(params*) {
		color := params.Pop()

		if (this.HasProp("BitmapData")) {
			stride := this.BitmapData.NumGet(8, "Int"), scan0 := this.BitmapData.NumGet(16, "Ptr")

			switch (params.Length) {
				case 2:
					Numput("UInt", color, scan0 + Math.Max(params[0], 0)*4 + Math.Max(params[1], 0)*stride)
				case 4:
					reset := Math.Max(params[0], 0)
						, y := Math.Max(params[1], 0), width := Math.Clamp(params[2], 0, this.BitmapData.NumGet(0, "UInt")) - reset, height := Math.Clamp(params[3], 0, this.BitmapData.NumGet(4, "UInt")) - y
				default:
					reset := 0
						, y := 0, width := this.BitmapData.NumGet(0, "UInt"), height := this.BitmapData.NumGet(4, "UInt")
			}

			loop (height) {
				loop (x := reset, width) {
					Numput("UInt", color, scan0 + 4*x++ + y*stride) ;~ The Stride data member is negative if the pixel data is stored bottom-up.
				}

				y++
			}
		}
		else {
			static GdipBitmapSetPixel := DllCall("Kernel32\GetProcAddress", "Ptr", handle := DllCall("Kernel32\LoadLibrary", "Str", "Gdiplus", "Ptr"), "AStr", "GdipBitmapSetPixel", "Ptr") + !DllCall("Kernel32\FreeLibrary", "Ptr", handle, "UInt")

			switch (params.Length) {
				case 2:
					DllCall(GdipBitmapSetPixel, "Ptr", this.Ptr, "Int", Math.Max(params[0], 0), "Int", Math.Max(params[1], 0), "Int", color)
				case 4:
					reset := Math.Max(params[0], 0)
						, y := Math.Max(params[1], 0), width := Math.Clamp(params[2], 0, this.Width) - reset, height := Math.Clamp(params[3], 0, this.Height) - y
				default:
					reset := 0
						, y := 0, width := this.Width, height := this.Height
			}

			pBitmap := this.Ptr

			loop (height) {
				loop (x := reset, width) {
					DllCall(GdipBitmapSetPixel, "Ptr", pBitmap, "Int", x++, "Int", y, "UInt", color)
				}

				y++
			}
		}
	}

	PixelFormat {
		Get {
			return (this.GetPixelFormat())
		}
	}

	;* bitmap.GetPixelFormat()
	;* Return:
		;* [Integer] - See PixelFormat enumeration.
	GetPixelFormat() {
		if (status := DllCall("Gdiplus\GdipGetImagePixelFormat", "Ptr", this.Ptr, "UInt*", &(pixelFormat := 0), "Int")) {
			throw (ErrorFromStatus(status))
		}

		return (pixelFormat)
	}

	;* bitmap.GetThumbnail(width, height)
	;* Parameter:
		;* [Integer] width
		;* [Integer] height
	;* Return:
		;* [Bitmap]
	GetThumbnail(width, height) {
		if (status := DllCall("Gdiplus\GdipGetImageThumbnail", "Ptr", this.Ptr, "UInt", width, "UInt", height, "Ptr*", &(pBitmap := 0), "Ptr", 0, "Ptr", 0, "Int")) {
			throw (ErrorFromStatus(status))
		}

		(instance := GDIp.Bitmap()).Ptr := pBitmap
		return (instance)
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
		;* [Integer] x
		;* [Integer] y
		;* [Integer] width
		;* [Integer] height
		;* [Integer] pixelFormat - See PixelFormat enumeration.
		;* [Integer] lockMode - See ImageLockMode enumeration.
	;* Return:
		;* [Integer] - Boolean value that indicates if the bitmap was locked.
	LockBits(x := 0, y := 0, width := unset, height := unset, lockMode := 0x0003, pixelFormat := unset) {  ;? http://supercomputingblog.com/graphics/using-lockbits-in-gdi/
		if (!(this.HasProp("BitmapData"))) {
			if (!(IsSet(width))) {
				if (!(IsSet(height))) {
					DllCall("Gdiplus\GdipGetImageDimension", "Ptr", this.Ptr, "Float*", &(width := 0), "Float*", &(height := 0))
				}
				else {
					DllCall("Gdiplus\GdipGetImageWidth", "Ptr", this.Ptr, "UInt*", &(width := 0))
				}
			}
			else if (!(IsSet(height))) {
				DllCall("Gdiplus\GdipGetImageHeight", "Ptr", this.Ptr, "UInt*", &(height := 0))
			}

			static bitmapData := Structure.CreateBitmapData()

			if (status := DllCall("Gdiplus\GdipBitmapLockBits", "Ptr", this.Ptr, "Ptr", Structure.CreateRect(x, y, width, height, "UInt").Ptr, "UInt", lockMode, "UInt", (IsSet(pixelFormat)) ? (pixelFormat) : (this.GetPixelFormat()), "Ptr", bitmapData.Ptr, "Int")) {  ;: https://docs.microsoft.com/en-us/windows/win32/api/gdiplusheaders/nf-gdiplusheaders-bitmap-lockbits
				throw (ErrorFromStatus(status))
			}

			return (!!(this.BitmapData := bitmapData))  ;~ LockBits returning too much data: https://github.com/dotnet/runtime/issues/28600.
		}

		return (False)
	}

	;* bitmap.UnlockBits()
	;* Return:
		;* [Integer] - Boolean value that indicates if the bitmap was unlocked.
	UnlockBits() {
		if (this.HasProp("BitmapData")) {
			if (status := DllCall("Gdiplus\GdipBitmapUnlockBits", "Ptr", this.Ptr, "Ptr", this.DeleteProp("BitmapData").Ptr, "Int")) {  ;: https://docs.microsoft.com/en-us/windows/win32/api/gdiplusheaders/nf-gdiplusheaders-bitmap-lockbits
				throw (ErrorFromStatus(status))
			}

			return (True)
		}

		return (False)
	}

	;* bitmap.RotateFlip(rotateType)
	;* Parameter:
		;* [Integer] rotateType - See RotateFlipType enumeration.
	RotateFlip(rotateType) {
		if (status := DllCall("Gdiplus\GdipImageRotateFlip", "Ptr", this.Ptr, "Int", rotateType, "Int")) {
			throw (ErrorFromStatus(status))
		}
	}

	;* bitmap.RotateFlip(file)
	;* Parameter:
		;* [String] file
	SaveToFile(file) {
		if (status := DllCall("Gdiplus\GdipGetImageEncodersSize", "UInt*", &(number := 0), "UInt*", &(size := 0), "Int")) {
			throw (ErrorFromStatus(status))
		}

		if (status := DllCall("Gdiplus\GdipGetImageEncoders", "UInt", number, "UInt", size, "Ptr", (imageCodecInfo := Structure(size)).Ptr, "Int")) {  ;* Fill a buffer with the available encoders.
			throw (ErrorFromStatus(status))
		}

		loop (extension := RegExReplace(file, ".*(\.\w+)$", "$1"), number) {
			if (InStr(StrGet(imageCodecInfo.NumGet(A_PtrSize*3 + (offset := (48 + A_PtrSize*7)*(A_Index - 1)) + 32, "Ptr"), "UTF-16"), "*" . extension)) {
				pCodec := imageCodecInfo.Ptr + offset  ;* Get the pointer to the matching encoder.

				break
			}
		}

		if (!(pCodec)) {
			throw (Error("Could not find a matching encoder for the specified file format."))
		}

		if (status := DllCall("Gdiplus\GdipSaveImageToFile", "Ptr", this.Ptr, "Ptr", StrPtr(file), "Ptr", pCodec, "UInt", 0, "Int")) {
			throw (ErrorFromStatus(status))
		}
	}
}

;* GDIp.CreateCachedBitmap(bitmap, graphics)
;* Parameter:
	;* [Bitmap] bitmap
	;* [Graphics] graphics
;* Return:
	;* [CachedBitmap]
static CreateCachedBitmap(bitmap, graphics) {
	if (status := DllCall("Gdiplus\GdipCreateCachedBitmap", "Ptr", bitmap.Ptr, "Ptr", graphics.Ptr, "Ptr*", &(pCachedBitmap := 0), "Int")) {
		throw (ErrorFromStatus(status))
	}

	(instance := this.CachedBitmap()).Ptr := pCachedBitmap
	return (instance)
}

class CachedBitmap {
	Class := "CachedBitmap"

	__Delete() {
		if (status := DllCall("Gdiplus\GdipDeleteCachedBitmap", "Ptr", this.Ptr, "Int")) {
			throw (ErrorFromStatus(status))
		}
	}
}