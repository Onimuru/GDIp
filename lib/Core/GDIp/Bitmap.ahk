/*
* MIT License
*
* Copyright (c) 2021 Onimuru
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in all
* copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
* SOFTWARE.
*/

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

	return (this.Bitmap(pBitmap))
}

;* GDIp.CreateBitmapFromBase64(base64)
;* Parameter:
	;* [String] base64
;* Return:
	;* [Bitmap]
static CreateBitmapFromBase64(base64) {  ;* ** Conversion: https://base64.guru/converter/encode/image/bmp **
	base64 := StrPtr(base64)

	if (!DllCall("Crypt32\CryptStringToBinary", "Ptr", base64, "UInt", 0, "UInt", 0x00000001, "Ptr", 0, "UInt*", &(bytes := 0), "Ptr", 0, "Ptr", 0, "UInt")) {  ;? 0x00000001 = CRYPT_STRING_BASE64  ;: https://docs.microsoft.com/en-us/windows/win32/api/wincrypt/nf-wincrypt-cryptstringtobinarya
		throw (ErrorFromMessage(DllCall("Kernel32\GetLastError")))
	}

	if (!DllCall("Crypt32\CryptStringToBinary", "Ptr", base64, "UInt", 0, "UInt", 0x00000001, "Ptr", (buffer := Structure(bytes)).Ptr, "UInt*", &bytes, "Ptr", 0, "Ptr", 0, "UInt")) {
		throw (ErrorFromMessage(DllCall("Kernel32\GetLastError")))
	}

	if (!(pStream := DllCall("Shlwapi\SHCreateMemStream", "Ptr", buffer.Ptr, "UInt", bytes, "Ptr"))) {
		throw (MemoryError("E_OUTOFMEMORY"))
	}

	bitmap := this.CreateBitmapFromStream(pStream, True)
	ObjRelease(pStream)

	return (bitmap)
}

;* GDIp.CreateBitmapFromBitmapWithEffect(bitmap, effect[, x, y, width, height])
;* Parameter:
	;* [Bitmap] bitmap
	;* [Effect] effect
	;* [Integer] x
	;* [Integer] y
	;* [Integer] width
	;* [Integer] height
;* Return:
	;* [Bitmap]
static CreateBitmapFromBitmapWithEffect(bitmap, effect, x := unset, y := unset, width := unset, height := unset) {
	if (IsSet(x) && IsSet(y) && IsSet(width) && IsSet(height)) {
		static rect := Structure.CreateRect(0, 0, 0, 0, "Int")

		rect.NumPut(0, "Int", x, "Int", y, "Int", width, "Int", height)

		if (status := DllCall("Gdiplus\GdipBitmapCreateApplyEffect", "Ptr*", bitmap, "Int", 1, "Ptr", effect, "Ptr", rect.Ptr, "Ptr", 0, "Ptr*", &(pBitmap := 0), "UInt", 0, "Ptr*", 0, "Int", 0, "Int")) {
			throw (ErrorFromStatus(status))
		}
	}
	else if (status := DllCall("Gdiplus\GdipBitmapCreateApplyEffect", "Ptr*", bitmap, "Int", 1, "Ptr", effect, "Ptr", 0, "Ptr", 0, "Ptr*", &(pBitmap := 0), "UInt", 0, "Ptr*", 0, "Int", 0, "Int")) {
		throw (ErrorFromStatus(status))
	}

	return (this.Bitmap(pBitmap))
}

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

	return (this.Bitmap(pBitmap))
}

;~ CreateBitmapFromGDIDIB

;* GDIp.CreateBitmapFromGraphics(graphics, width, height)
;* Parameter:
	;* [Graphics] graphics - Graphics object that contains information used to initialize certain properties (for example, dots per inch) of the new Bitmap object.
	;* [Integer] width
	;* [Integer] height
;* Return:
	;* [Bitmap]
static CreateBitmapFromGraphics(graphics, width, height) {
	if (status := DllCall("Gdiplus\GdipCreateBitmapFromGraphics", "Int", width, "Int", height, "Ptr", graphics, "Ptr*", &(pBitmap := 0), "Int")) {
		throw (ErrorFromStatus(status))
	}

	return (this.Bitmap(pBitmap))
}

;* GDIp.CreateBitmapFromHBITMAP(bitmap[, hPalette])
;* Parameter:
	;* [HBitmap] bitmap
	;* [Integer] hPalette
;* Return:
	;* [Bitmap]
static CreateBitmapFromHBITMAP(bitmap, hPalette := 0) {
	if (status := DllCall("Gdiplus\GdipCreateBitmapFromHBITMAP", "Ptr", bitmap.Handle, "Ptr", hPalette, "Ptr*", &(pBitmap := 0), "Int")) {
		throw (ErrorFromStatus(status))
	}

	return (this.Bitmap(pBitmap))
}

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

	return (this.CreateBitmapFromHBITMAP(bitmap))
}

;* GDIp.CreateBitmapFromStream(stream[, useICM])
;* Parameter:
	;* [Structure] stream
	;* [Integer] useICM
;* Return:
	;* [Bitmap]
static CreateBitmapFromStream(stream, useICM := False) {
	if (status := (useICM)
		? (DllCall("Gdiplus\GdipCreateBitmapFromStreamICM", "Ptr", stream, "Ptr*", &(pBitmap := 0), "Int"))
		: (DllCall("Gdiplus\GdipCreateBitmapFromStream", "Ptr", stream, "Ptr*", &(pBitmap := 0), "Int"))) {
		throw (ErrorFromStatus(status))
	}

	return (this.Bitmap(pBitmap))
}

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
		if (!DllCall("User32\GetClientRect", "Ptr", hWnd, "Ptr", rect.Ptr, "UInt")) {
			throw (ErrorFromMessage(DllCall("Kernel32\GetLastError")))
		}
	}
	else if (DllCall("Dwmapi\DwmGetWindowAttribute", "Ptr", hWnd, "UInt", 9, "UPtr", rect.Ptr, "UInt", 16, "UInt")) {
		if (!DllCall("User32\GetWindowRect", "Ptr", hWnd, "Ptr", rect.Ptr, "UInt")) {
			throw (ErrorFromMessage(DllCall("Kernel32\GetLastError")))
		}
	}

	DC := GDI.CreateCompatibleDC()
	bitmap := GDI.CreateDIBSection(Structure.CreateBitmapInfoHeader(rect.NumGet(8, "Int"), -rect.NumGet(12, "Int"), 32, 0x0000), DC)
		, DC.SelectObject(bitmap)

	if (!DllCall("User32\PrintWindow", "Ptr", hWnd, "Ptr", DC.Handle, "UInt", 2 + client, "UInt")) {  ;? 2 = PW_RENDERFULLCONTENT, 1 = PW_CLIENTONLY
		throw (ErrorFromMessage(DllCall("Kernel32\GetLastError")))
	}

	return (this.CreateBitmapFromHBITMAP(bitmap))
}

;* GDIp.CreateHBITMAPFromBitmap(bitmap[, background])
;* Parameter:
	;* [Bitmap] bitmap
	;* [Integer] background - Color that specifies the background color. This parameter is ignored if the bitmap is totally opaque.
;* Return:
	;* [HBitmap]
static CreateHBITMAPFromBitmap(bitmap, background := 0xFFFFFFFF) {
	if (status := DllCall("Gdiplus\GdipCreateHBITMAPFromBitmap", "Ptr", bitmap, "Ptr*", (hBitmap := 0), "UInt", background, "Int")) {
		throw (ErrorFromStatus(status))
	}

	return (GDI.HBitmap(hBitmap))
}

;* GDIp.CreateThumbnail(bitmap, width, height)
;* Parameter:
	;* [Bitmap] bitmap
	;* [Integer] width
	;* [Integer] height
;* Return:
	;* [Bitmap]
static CreateThumbnail(bitmap, width, height) {
	if (status := DllCall("Gdiplus\GdipGetImageThumbnail", "Ptr", bitmap, "UInt", width, "UInt", height, "Ptr*", &(pBitmap := 0), "Ptr", 0, "Ptr", 0, "Int")) {
		throw (ErrorFromStatus(status))
	}

	return (GDIp.Bitmap(pBitmap))
}

;~ CreateHICONFromBitmap

/*
** A Beginners Guide to Bitmaps: http://paulbourke.net/dataformats/bitmaps/. **
*/

class Bitmap {
	Class := "Bitmap"

	__New(pBitmap) {
		this.Ptr := pBitmap
	}

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
	Clone(x := unset, y := unset, width := unset, height := unset, pixelFormat := 0) {
		if (status := (IsSet(x) && IsSet(y) && IsSet(width) && IsSet(height))
			? (DllCall("Gdiplus\GdipCloneBitmapArea", "Float", x, "Float", y, "Float", width, "Float", height, "UInt", pixelFormat || this.GetPixelFormat(), "Ptr", this.Ptr, "Ptr*", &(pBitmap := 0), "Int"))
			: (DllCall("Gdiplus\GdipCloneImage", "Ptr", this.Ptr, "Ptr*", &(pBitmap := 0), "Int"))) {
			throw (ErrorFromStatus(status))
		}

		return (GDIp.Bitmap(pBitmap))
	}

	__Delete() {
		if (status := DllCall("Gdiplus\GdipDisposeImage", "Ptr", this.Ptr, "Int")) {
			throw (ErrorFromStatus(status))
		}
	}

	;-------------- Property ------------------------------------------------------;

	Rect[&unit := 0] {
		Get {
			return (this.GetRect(&unit))
		}
	}

	;* bitmap.GetRect([&unit])
	;* Return:
		;* [Object]
	GetRect(&unit := 0) {
		static rect := Structure.CreateRect(0, 0, 0, 0, "Float")

		if (status := DllCall("Gdiplus\GdipGetImageBounds", "Ptr", this.Ptr, "Ptr", rect.Ptr, "Int*", &unit, "Int")) {
			throw (ErrorFromStatus(status))
		}

		return ({x: rect.NumGet(0, "Float"), y: rect.NumGet(4, "Float"), Width: rect.NumGet(8, "Float"), Height: rect.NumGet(12, "Float")})
	}

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

	Resolution {
		Set {
			this.SetResolution(value*)

			return (value)
		}
	}

	;* bitmap.SetResolution(xDpi, yDpi)
	;* Parameter:
		;* [Integer] xDpi
		;* [Integer] yDpi
	SetResolution(xDpi, yDpi) {
		if (status := DllCall("Gdiplus\GdipBitmapSetResolution", "Ptr", this.Ptr, "Float", xDpi, "Float", yDpi, "Int")) {
			throw (ErrorFromStatus(status))
		}
	}

	HorizontalResolution {
		Get {
			return (this.GetHorizontalResolution())
		}
	}

	;* bitmap.GetHorizontalResolution()
	;* Return:
		;* [Integer]
	GetHorizontalResolution() {
		if (status := DllCall("Gdiplus\GdipGetImageHorizontalResolution", "Ptr", this.Ptr, "UInt*", &(xDpi := 0), "Int")) {
			throw (ErrorFromStatus(status))
		}

		return (xDpi)
	}

	VerticalResolution {
		Get {
			return (this.GetVerticalResolution())
		}
	}

	;* bitmap.GetVerticalResolution()
	;* Return:
		;* [Integer]
	GetVerticalResolution() {
		if (status := DllCall("Gdiplus\GdipGetImageVerticalResolution", "Ptr", this.Ptr, "UInt*", &(yDpi := 0), "Int")) {
			throw (ErrorFromStatus(status))
		}

		return (yDpi)
	}

	;--------------- Method -------------------------------------------------------;

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
			static procAddress := DllCall("Kernel32\GetProcAddress", "Ptr", DllCall("Kernel32\GetModuleHandle", "Str", "Gdiplus", "Ptr"), "AStr", "GdipBitmapGetPixel", "Ptr")

			DllCall(procAddress, "Ptr", this.Ptr, "Int", x, "Int", y, "UInt*", &(color := 0))  ;~ No error handling.
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
					Numput("UInt", color, scan0 + x++*4 + y*stride)  ;~ The Stride data member is negative if the pixel data is stored bottom-up.
				}

				y++
			}
		}
		else {
			static procAddress := DllCall("Kernel32\GetProcAddress", "Ptr", DllCall("Kernel32\GetModuleHandle", "Str", "Gdiplus", "Ptr"), "AStr", "GdipBitmapSetPixel", "Ptr")

			switch (params.Length) {
				case 2:
					DllCall(procAddress, "Ptr", this.Ptr, "Int", Math.Max(params[0], 0), "Int", Math.Max(params[1], 0), "Int", color)
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
					DllCall(procAddress, "Ptr", pBitmap, "Int", x++, "Int", y, "UInt", color)
				}

				y++
			}
		}
	}

	;* bitmap.ApplyEffect(effect[, x, y, width, height])
	;* Parameter:
		;* [Effect] effect
		;* [Float] x
		;* [Float] y
		;* [Float] width
		;* [Float] height
	ApplyEffect(effect, x := unset, y := unset, width := unset, height := unset) {
		if (IsSet(x) && IsSet(y) && IsSet(width) && IsSet(height)) {
			static rect := Structure.CreateRect(0, 0, 0, 0, "Int")

			rect.NumPut(0, "Int", x, "Int", y, "Int", width, "Int", height)

			if (status := DllCall("Gdiplus\GdipBitmapApplyEffect", "Ptr", this.Ptr, "Ptr", effect, "Ptr", rect, "UInt", 0, "Ptr*", 0, "Int", 0, "Int")) {
				throw (ErrorFromStatus(status))
			}
		}
		else if (status := DllCall("Gdiplus\GdipBitmapApplyEffect", "Ptr", this.Ptr, "Ptr", effect, "Ptr", 0, "UInt", 0, "Ptr*", 0, "Int", 0, "Int")) {
			throw (ErrorFromStatus(status))
		}
	}

	ConvertFormat(pixelFormat, dithertype, palettetype, colorPalette, alphaThresholdPercent) {
		if (status := DllCall("Gdiplus\GdipBitmapConvertFormat", "Ptr", this.Ptr, "UInt", pixelFormat, "UInt", dithertype, "UInt", palettetype, "Ptr", colorPalette, "UInt", alphaThresholdPercent, "Int")) {  ;: https://docs.microsoft.com/en-us/windows/win32/api/gdiplusheaders/nf-gdiplusheaders-bitmap-lockbits
			throw (ErrorFromStatus(status))
		}
	}

	;~ GetHistogram
	;~ GetHistogramSize

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
	LockBits(x := 0, y := 0, width := unset, height := unset, lockMode := 0x0003, pixelFormat := 0) {  ;? http://supercomputingblog.com/graphics/using-lockbits-in-gdi/
		if (!this.HasProp("BitmapData")) {
			if (!IsSet(width)) {
				if (!IsSet(height)) {
					DllCall("Gdiplus\GdipGetImageDimension", "Ptr", this.Ptr, "Float*", &(width := 0), "Float*", &(height := 0))
				}
				else {
					DllCall("Gdiplus\GdipGetImageWidth", "Ptr", this.Ptr, "UInt*", &(width := 0))
				}
			}
			else if (!IsSet(height)) {
				DllCall("Gdiplus\GdipGetImageHeight", "Ptr", this.Ptr, "UInt*", &(height := 0))
			}

			if (status := DllCall("Gdiplus\GdipBitmapLockBits", "Ptr", this.Ptr, "Ptr", Structure.CreateRect(x, y, width, height, "UInt").Ptr, "UInt", lockMode, "UInt", pixelFormat || this.GetPixelFormat(), "Ptr", (bitmapData := Structure.CreateBitmapData()).Ptr, "Int")) {  ;: https://docs.microsoft.com/en-us/windows/win32/api/gdiplusheaders/nf-gdiplusheaders-bitmap-lockbits
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

	;* bitmap.SaveToFile(file)
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

		if (!pCodec) {
			throw (Error("Could not find a matching encoder for the specified file format."))
		}

		if (status := DllCall("Gdiplus\GdipSaveImageToFile", "Ptr", this.Ptr, "Ptr", StrPtr(file), "Ptr", pCodec, "UInt", 0, "Int")) {
			throw (ErrorFromStatus(status))
		}
	}

	;* bitmap.SaveToStream()
	SaveToStream() {
	}
}

;* GDIp.CreateCachedBitmap(bitmap, graphics)
;* Parameter:
	;* [Bitmap] bitmap
	;* [Graphics] graphics
;* Return:
	;* [CachedBitmap]
static CreateCachedBitmap(bitmap, graphics) {
	if (status := DllCall("Gdiplus\GdipCreateCachedBitmap", "Ptr", bitmap, "Ptr", graphics, "Ptr*", &(pCachedBitmap := 0), "Int")) {
		throw (ErrorFromStatus(status))
	}

	return (this.CachedBitmap(pCachedBitmap))
}

class CachedBitmap {
	Class := "CachedBitmap"

	__New(pCachedBitmap) {
		this.Ptr := pCachedBitmap
	}

	__Delete() {
		if (status := DllCall("Gdiplus\GdipDeleteCachedBitmap", "Ptr", this.Ptr, "Int")) {
			throw (ErrorFromStatus(status))
		}
	}
}