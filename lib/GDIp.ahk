;==============  Include  ======================================================;

#Include, %A_LineFile%\..\Core.ahk

#Include, %A_LineFile%\..\Math\Math.ahk

;============== Function ======================================================;

GetDC(hWnd := 0) {
	if (!hDC := DllCall("User32\GetDC", "Ptr", hWnd, "Ptr")) {
		throw (Exception(Format("0x{:X}", A_LastError), 0, FormatMessage(A_LastError)))
	}

	Static instance := {"__Class": "__DC"
			, "__Delete": Func("ReleaseDC")}

	(DC := new instance()).Handle := hDC
		, DC.WindowHandle := hWnd

	return (DC)
}

;* GetDCEx(hwnd[, flags, rgnClip])
;* Parameters:
	;* flags:
		;? 0x000001: DCX_WINDOW
		;? 0x000002: DCX_CACHE
		;? 0x000020: DCX_PARENTCLIP
		;? 0x000010: DCX_CLIPSIBLINGS
		;? 0x000008: DCX_CLIPCHILDREN
		;? 0x000004: DCX_NORESETATTRS
		;? 0x000400: DCX_LOCKWINDOWUPDATE
		;? 0x000040: DCX_EXCLUDERGN
		;? 0x000100: DCX_EXCLUDEUPDATE
		;? 0x000080: DCX_INTERSECTRGN
		;? 0x000200: DCX_INTERSECTUPDATE
		;? 0x100000: DCX_NORECOMPUTE
		;? 0x200000: DCX_VALIDATE
GetDCEx(hwnd, flags := 0, rgnClip := 0) {
	if (!hDC := DllCall("User32\GetDCEx", "Ptr", hwnd, "Ptr", rgnClip, "UInt", flags, "Ptr")) {
		throw (Exception(Format("0x{:X}", A_LastError), 0, FormatMessage(A_LastError)))
	}

	Static instance := {"__Class": "__DC"
			, "__Delete": Func("ReleaseDC")}

	(DC := new instance()).Handle := hDC
		, DC.WindowHandle := hWnd

	return (DC)
}

ReleaseDC(DC) {
	if (!DC.Handle) {
		MsgBox("ReleaseDC()")
	}

	if (!DllCall("User32\ReleaseDC", "Ptr", DC.WindowHandle, "Ptr", DC.Handle, "Int")) {
		throw (Exception(Format("0x{:X}", A_LastError), 0, FormatMessage(A_LastError)))
	}

	return (True)
}

UpdateLayeredWindow(hWnd, DC, x := "", y := "", width := "", height := "", alpha := 0xFF) {
	if (x == "" || y == "" || width == "" || height == "") {
		Static rect := CreateRect(0, 0, 0, 0, "UInt")

		if (DllCall("Dwmapi\DwmGetWindowAttribute", "Ptr", hWnd, "UInt", 9, "Ptr", rect.Ptr, "UInt", 16, "UInt")) {
			if (!DllCall("User32\GetWindowRect", "Ptr", hWnd, "Ptr", rect.Ptr, "UInt")) {
				throw (Exception(Format("0x{:X}", A_LastError), 0, FormatMessage(A_LastError)))
			}
		}

		if (x == "") {
			x := rect.NumGet(0, "Int")

			if (width == "") {
				width := Abs(rect.NumGet(8, "Int") - x)
			}
		}
		else if (width == "") {
			width := Abs(rect.NumGet(8, "Int") - rect.NumGet(0, "Int"))
		}

		if (y == "") {
			y := rect.NumGet(4, "Int")

			if (height == "") {
				height := Abs(rect.NumGet(12, "Int") - y)
			}
		}
		else if (height == "") {
			height := Abs(rect.NumGet(12, "Int") - rect.NumGet(4, "Int"))
		}
	}

	if (!DllCall("User32\UpdateLayeredWindow", "Ptr", hWnd, "Ptr", 0, "Int64*", x | y << 32, "Int64*", width | height << 32, "Ptr", DC.Handle, "Int64*", 0, "UInt", 0, "UInt*", alpha << 16 | 1 << 24, "UInt", 0x00000002, "UInt")) {
		throw (Exception(Format("0x{:X}", A_LastError), 0, FormatMessage(A_LastError)))
	}

	return (True)
}

;===============  Class  =======================================================;

Class GDI {

	CreateCompatibleDC(DC := "") {
		if (!hDC := DllCall("Gdi32\CreateCompatibleDC", "Ptr", DC.Handle, "Ptr")) {
			throw (Exception(Format("0x{:X}", A_LastError), 0, FormatMessage(A_LastError)))
		}

		return ({"Handle": hDC  ;~ Memory DC
			, "Base": this.__CompatibleDC})
	}

	Class __CompatibleDC {
		Static OriginalObjects := {}

		__Delete() {
			if (!this.Handle) {
				MsgBox("CompatibleDC.__Delete()")
			}

			this.Reset()
			DllCall("Gdi32\DeleteDC", "Ptr", this.Handle)
		}

		SelectObject(object) {
			Local

			switch (class := Class(object)) {
				case "__Bitmap", "__Brush", "__Pen", "__Region", "__Font": {
					if (!handle := DllCall("Gdi32\SelectObject", "Ptr", this.Handle, "Ptr", object.Handle, "Ptr")) {  ;* If an error occurs and the selected object is not a region, the return value is NULL. Otherwise, it is HGDI_ERROR.
						throw (Exception(Format("0x{:X}", A_LastError), 0, FormatMessage(A_LastError)))
					}

					if (!this.OriginalObjects.HasKey(class)) {  ;* Save the handle to any original, default objects that are replaced.
						this.OriginalObjects[class] := handle
					}

					return (True)
				}
			}

			return (False)
		}

		Reset(class := "") {
			Local

			if (this.OriginalObjects.HasKey(class)) {
				if (!handle := DllCall("Gdi32\SelectObject", "Ptr", this.Handle, "Ptr", this.OriginalObjects.Remove(class), "Ptr")) {
					throw (Exception(Format("0x{:X}", A_LastError), 0, FormatMessage(A_LastError)))
				}

				return (handle)
			}
			else if (!class) {
				for k, handle in this.OriginalObjects {
					if (!DllCall("Gdi32\SelectObject", "Ptr", this.Handle, "Ptr", handle, "Ptr")) {
						throw (Exception(Format("0x{:X}", A_LastError), 0, FormatMessage(A_LastError)))
					}
				}

				return (True
					, this.OriginalObjects := {})
			}

			return (False)
		}
	}

	;* GDI.Bitmap.CreateBitmap(width, height[, bitCount, planes, [ByRef] pBits])
	CreateBitmap(width, height, bitCount := 32, planes := 1, ByRef pBits := 0) {
		if (!handle := DllCall("Gdi32\CreateBitmap", "Int", width, "Int", height, "UInt", planes, "UInt", bitCount, "Ptr", pBits, "Ptr")) {
			throw (Exception(Format("0x{:X}", A_LastError), 0, FormatMessage(A_LastError)))
		}

		return ({"Handle": handle   ;~ DDB (monochrome)
			, "Base": this.__Bitmap})
	}

	;* GDI.Bitmap.CreateCompatibleBitmap(width, height[, DC])
	CreateCompatibleBitmap(width, height, DC := "") {
		if (!DC) {
			DC := GetDC()
		}

		if (!handle := DllCall("Gdi32\CreateCompatibleBitmap", "Ptr", DC.Handle, "Int", width, "Int", height, "Ptr")) {
			throw (Exception(Format("0x{:X}", A_LastError), 0, FormatMessage(A_LastError)))
		}

		return ({"Handle": handle  ;~ DDB
			, "Base": this.__Bitmap})
	}

	;* GDI.Bitmap.CreateDIBSection(bitmapInfo[, DC, usage, [ByRef] pBits, hSection, offset])
	CreateDIBSection(bitmapInfo, DC := "", usage := 0, ByRef pBits := 0, hSection := 0, offset := 0) {
		if (!DC) {
			DC := GetDC()
		}

		if (!handle := DllCall("Gdi32\CreateDIBSection", "Ptr", DC.Handle, "Ptr", bitmapInfo.Ptr, "UInt", usage, "Ptr*", pBits, "Ptr", hSection, "UInt", offset, "Ptr")) {
			throw (Exception(Format("0x{:X}", A_LastError), 0, FormatMessage(A_LastError)))
		}

		return ({"Handle": handle  ;~ DIB
			, "Base": this.__Bitmap})
	}

	Class __Bitmap {

		__Delete() {
			if (!this.Handle) {
				MsgBox("Bitmap.__Delete()")
			}

			DllCall("Gdi32\DeleteObject", "Ptr", this.Handle, "UInt")  ;* If the specified handle is not valid or is currently selected into a DC, the return value is zero.
		}

		GetPtr(palette := 0) {
			Local

			if (status := DllCall("gdiplus\GdipCreateBitmapFromHBITMAP", "Ptr", this.Handle, "Ptr", palette.Handle, "Ptr*", pBitmap := 0, "Int")) {  ;* Creates a GDI+ bitmap object from a GDI bitmap handle.
				throw (Exception(FormatStatus(status)))
			}

			return (pBitmap)
		}
	}

	;* GDI.BitBlt([DC] destinationDC[, x1, y1, width, height, [DC] sourceDC, x2, y2, rasterOperation])
	;* Parameters:
		;* rasterOperation:
			;? 0x00000042: BLACKNESS
			;? 0x40000000: CAPTUREBLT
			;? 0x00550009: DSTINVERT
			;? 0x00C000CA: MERGECOPY
			;? 0x00BB0226: MERGEPAINT
			;? 0x80000000: NOMIRRORBITMAP
			;? 0x00330008: NOTSRCCOPY
			;? 0x001100A6: NOTSRCERASE
			;? 0x00F00021: PATCOPY
			;? 0x005A0049: PATINVERT
			;? 0x00FB0A09: PATPAINT
			;? 0x008800C6: SRCAND
			;? 0x00CC0020: SRCCOPY
			;? 0x00440328: SRCERASE
			;? 0x00660046: SRCINVERT
			;? 0x00EE0086: SRCPAINT
			;? 0x00FF0062: WHITENESS
	BitBlt(destinationDC, x1, y1, width, height, sourceDC, x2, y2, rasterOperation := 0x00CC0020) {
		if (!DllCall("Gdi32\BitBlt", "Ptr", destinationDC.Handle, "Int", x1, "Int", y1, "Int", width, "Int", height, "Ptr", sourceDC.Handle, "Int", x2, "Int", y2, "UInt", rasterOperation)) {  ;: https://docs.microsoft.com/en-us/windows/win32/api/wingdi/nf-wingdi-bitblt
			throw (Exception(Format("0x{:X}", A_LastError), 0, FormatMessage(A_LastError)))
		}

		return (False)
	}

	MaskBlt(destinationDC, destinationPoint, size, sourceDC, sourcePoint, mask, offsetPoint, rasterOperation := 0x00CC0020) {  ;: https://docs.microsoft.com/en-us/windows/win32/api/wingdi/nf-wingdi-maskblt
		return (False)
	}

	PlgBlt(destinationDC, destinationPoint, size, sourceDC, sourcePoint, mask, offsetPoint, rasterOperation := 0x00CC0020) {  ;: https://docs.microsoft.com/en-us/windows/win32/api/wingdi/nf-wingdi-plgblt
		return (False)
	}

	;* DC.DeviceCaps(DC, index)
	;* Parameters:
		;* index:
			;? 0x00: DRIVERVERSION
			;? 0x02: TECHNOLOGY
			;? 0x04: HORZSIZE
			;? 0x06: VERTSIZE
			;? 0x08: HORZRES
			;? 0x0A: VERTRES
			;? 0x58: LOGPIXELSX
			;? 0x5A: LOGPIXELSY
			;? 0x0C: BITSPIXEL
			;? 0x0E: PLANES
			;? 0x10: NUMBRUSHES
			;? 0x12: NUMPENS
			;? 0x14: NUMMARKERS
			;? 0x16: NUMFONTS
			;? 0x18: NUMCOLORS
			;? 0x28: ASPECTX
			;? 0x2A: ASPECTY
			;? 0x2C: ASPECTXY
			;? 0x1A: PDEVICESIZE
			;? 0x24: CLIPCAPS
			;? 0x68: SIZEPALETTE
			;? 0x6A: NUMRESERVED
			;? 0x6C: COLORRES
			;? 0x6E: PHYSICALWIDTH
			;? 0x6F: PHYSICALHEIGHT
			;? 0x70: PHYSICALOFFSETX
			;? 0x71: PHYSICALOFFSETY
			;? 0x74: VREFRESH
			;? 0x72: SCALINGFACTORX
			;? 0x73: SCALINGFACTORY
			;? 0x77: BLTALIGNMENT
			;? 0x78: SHADEBLENDCAPS
			;? 0x26: RASTERCAPS
			;? 0x1C: CURVECAPS
			;? 0x1E: LINECAPS
			;? 0x20: POLYGONALCAPS
			;? 0x22: TEXTCAPS
			;? 0x79: COLORMGMTCAPS
	GetDeviceCaps(DC, index) {
		Local

		information := DllCall("Gdi32\GetDeviceCaps", "Ptr", DC.Handle, "Int", index, "Int")

		switch (index) {  ;? http://msaccessgurus.com/VBA/Code/API_GetDeviceCaps_ppi.htm
			case 0x02: {
				Static technology := ["DT_PLOTTER", "DT_RASDISPLAY", "DT_RASPRINTER", "DT_RASCAMERA", "DT_CHARSTREAM", "DT_METAFILE", "DT_DISPFILE"]

				information := technology[information]
			}
			case 0x78: {
				Static shadeBlendCaps := {0x00000000: "SB_NONE", 0x00000001: "SB_CONST_ALPHA", 0x00000002: "SB_PIXEL_ALPHA", 0x00000004: "SB_PREMULT_ALPHA", 0x00000010: "SB_GRAD_RECT", 0x00000020: "SB_GRAD_TRI"}

				information := shadeBlendCaps[information]
			}
		}

		return (information)
	}
}

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

	;--------------- Bitmap -------------------------------------------------------;

	;* GDIp.GdipCreateBitmap(width, height[, format, stride, [Struct] scan0])
	GdipCreateBitmap(width, height, format := 0x26200A, stride := 0, scan0 := 0) {
		Local

		if (status := DllCall("Gdiplus\GdipCreateBitmapFromScan0", "UInt", width, "UInt", height, "UInt", stride, "UInt", format, "Ptr", scan0, "Ptr*", pBitmap := 0, "Int")) {  ;: https://docs.microsoft.com/en-us/windows/win32/api/gdiplusheaders/nf-gdiplusheaders-bitmap-bitmap(int_int_int_pixelformat_byte)
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

	CreateBitmapFromHBITMAP(bitmap, palette := 0) {
		Local

		if (status := DllCall("Gdiplus\GdipCreateBitmapFromHBITMAP", "Ptr", bitmap.Handle, "Ptr", palette.Handle, "Ptr*", pBitmap := 0, "Int")) {  ;* Do not pass to the GdipCreateBitmapFromHBITMAP function a GDI bitmap or a GDI palette that is currently (or was previously) selected into a device context.
			throw (Exception(FormatStatus(status)))
		}

		return (pBitmap)
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

	CreateFromScreen(params*) {
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
		;* Parameters:
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

	;-------------- Graphics ------------------------------------------------------;

	CreateGraphicsFromBitmap(bitmap) {
		Local

		if (status := DllCall("Gdiplus\GdipGetImageGraphicsContext", "Ptr", bitmap.Ptr, "Ptr*", pGraphics := 0, "Int")) {
			throw (Exception(FormatStatus(status)))
		}

		return ({"Ptr": pGraphics
			, "Base": this.__Graphics})
	}

	CreateGraphicsFromDC(DC) {
		Local

		if (status := DllCall("Gdiplus\GdipCreateFromHDC", "Ptr", DC.Handle, "Ptr*", pGraphics := 0, "Int")) {
			throw (Exception(FormatStatus(status)))
		}

		return ({"Ptr": pGraphics
			, "Base": this.__Graphics})
	}

	Class __Graphics {

		__Delete() {
			if (!this.Ptr) {
				MsgBox("Graphics.__Delete()")
			}

			DllCall("Gdiplus\GdipDeleteGraphics", "Ptr", this.Ptr)
		}

		;* graphics.CreatePtr(width, height)
		CreatePtr(width, height) {
			Local

			if (status := DllCall("Gdiplus\GdipCreateBitmapFromGraphics", "Int", width, "Int", height, "Ptr", this.Ptr, "Ptr*", pBitmap := 0, "Int")) {
				throw (Exception(FormatStatus(status)))
			}

			return (pBitmap)
		}

		;-------------- Property ------------------------------------------------------;

		CompositingMode[] {
			Set {
				return (value, this.SetCompositingMode(value))
			}
		}

		;* graphics.SetCompositingMode(mode)
		;* Parameters:
			;* mode:
				;? 0: SourceOver (blend)
				;? 1: SourceCopy (overwrite)
		SetCompositingMode(mode := 0) {
			Local

			if (status := DllCall("Gdiplus\GdipSetCompositingMode", "Ptr", this.Ptr, "Int", mode, "Int")) {
				throw (Exception(FormatStatus(status)))
			}

			return (True)
		}

		InterpolationMode[] {
			Set {
				return (value, this.SetInterpolationMode(value))
			}
		}

		;* graphics.SetInterpolationMode(mode)
		;* Parameters:
			;* mode:
				;? 0: Default
				;? 1: LowQuality
				;? 2: HighQuality
				;? 3: Bilinear
				;? 4: Bicubic
				;? 5: NearestNeighbor
				;? 6: HighQualityBilinear
				;? 7: HighQualityBicubic
		SetInterpolationMode(mode := 0) {
			Local

			if (status := DllCall("Gdiplus\GdipSetInterpolationMode", "Ptr", this.Ptr, "Int", mode, "Int")) {
				throw (Exception(FormatStatus(status)))
			}

			return (True)
		}

		SmoothingMode[] {
			Set {
				return (value, this.SetSmoothingMode(value))
			}
		}

		;* graphics.SetSmoothingMode(mode)
		;* Parameters:
			;* mode:
				;? 0: Default
				;? 1: HighSpeed
				;? 2: HighQuality
				;? 3: None
				;? 4: AntiAlias
		SetSmoothingMode(mode := 0) {
			Local

			if (status := DllCall("Gdiplus\GdipSetSmoothingMode", "Ptr", this.Ptr, "Int", mode, "Int")) {
				throw (Exception(FormatStatus(status)))
			}

			return (True)
		}

		TextRenderingHint[] {
			Set {
				return (value, this.SetTextRenderingHint(value))
			}
		}

		;* graphics.SetTextRenderingHint(hint)
		;* Parameters:
			;* hint:
				;? 0: SystemDefault
				;? 1: SingleBitPerPixelGridFit
				;? 2: SingleBitPerPixel
				;? 3: AntiAliasGridFit
				;? 4: AntiAlias
				;? 5: ClearTypeGridFit
		SetTextRenderingHint(hint := 0) {
			Local

			if (status := DllCall("Gdiplus\GdipSetTextRenderingHint", "Ptr", this.Ptr, "Int", hint, "Int")) {
				throw (Exception(FormatStatus(status)))
			}

			return (True)
		}

		;--------------- Method -------------------------------------------------------;
		;------------------------------------------------------  Control  --------------;

		Clear(color := 0x00000000) {
			if (status := DllCall("Gdiplus\GdipGraphicsClear", "Ptr", this.Ptr, "UInt", color, "Int")) {
				throw (Exception(FormatStatus(status)))
			}

			return (True)
		}

		;--------------------------------------------------  World Transform  ----------;

		;* graphics.Translate(x, y)
		Translate(x, y) {
			if (status := DllCall("Gdiplus\GdipTranslateWorldTransform", "Ptr", this.Ptr, "Float", x, "Float", y, "Int", 1, "Int")) {
				throw (Exception(FormatStatus(status)))
			}

			return (True)
		}

		;* graphics.Rotate(angle[, x, y]))
		Rotate(angle, x := "", y := "") {
			if (x == "" || y == "") {
				if (status := DllCall("Gdiplus\GdipRotateWorldTransform", "Ptr", this.Ptr, "Float", angle, "Int", 1, "Int")) {
					throw (Exception(FormatStatus(status)))
				}
			}
			else {
				if (status := DllCall("Gdiplus\GdipTranslateWorldTransform", "Ptr", this.Ptr, "Float", -x, "Float", -y, "Int", 1, "Int")) {
					throw (Exception(FormatStatus(status)))
				}

				if (status := DllCall("Gdiplus\GdipRotateWorldTransform", "Ptr", this.Ptr, "Float", angle, "Int", 1, "Int")) {
					throw (Exception(FormatStatus(status)))
				}

				if (status := DllCall("Gdiplus\GdipTranslateWorldTransform", "Ptr", this.Ptr, "Float", x, "Float", y, "Int", 1, "Int")) {
					throw (Exception(FormatStatus(status)))
				}
			}

			return (True)
		}

		Reset() {
			if (status := DllCall("Gdiplus\GdipResetWorldTransform", "Ptr", this.Ptr, "Int")) {
				throw (Exception(FormatStatus(status)))
			}

			return (True)
		}

		Scale(x, y) {
			if (status := DllCall("Gdiplus\GdipScaleWorldTransform", "Ptr", this.Ptr, "Float", x, "Float", y, "Int", 1, "Int")) {
				throw (Exception(FormatStatus(status)))
			}

			return (True)
		}

		;------------------------------------------------------- Bitmap ---------------;

		DrawBitmap(bitmap, destinationRect := "", sourceRect := "", unit := 2, imageAttributes := "") {
			Local

			if (status := (sourceRect)
				? (DllCall("Gdiplus\GdipDrawImageRectRect", "Ptr", this.Ptr, "Ptr", bitmap.Ptr, "Float", destinationRect.x, "Float", destinationRect.y, "Float", destinationRect.Width, "Float", destinationRect.Height, "Float", sourceRect.x, "Float", sourceRect.y, "Float", sourceRect.Width, "Float", sourceRect.Height, "Int", unit, "Ptr", imageAttributes.Ptr, "Ptr", 0, "Ptr", 0, "Int"))
				: ((destinationRect)
					? (DllCall("Gdiplus\GdipDrawImageRect", "Ptr", this.Ptr, "Ptr", bitmap.Ptr, "Float", destinationRect.x, "Float", destinationRect.y, "Float", destinationRect.Width, "Float", destinationRect.Height, "Int"))
					: (DllCall("Gdiplus\GdipDrawImageRect", "Ptr", this.Ptr, "Ptr", bitmap.Ptr, "Float", 0, "Float", 0, "Float", bitmap.Width, "Float", bitmap.Height, "Int")))) {
				throw (Exception(FormatStatus(status)))
			}

			return (True)
		}

		;-------------------------------------------------------- Fill ----------------;

		;* Graphics.FillRectangle([Brush] brush, [Rect] object)
		FillRectangle(brush, object) {

			if (status := DllCall("Gdiplus\GdipFillRectangle", "Ptr", this.Ptr, "Ptr", brush.Ptr, "Float", object.x, "Float", object.y, "Float", object.Width, "Float", object.Height, "Int")) {
				throw (Exception(FormatStatus(status)))
			}

			return (True)
		}

		;-------------------------------------------------------- Draw ----------------;

		;* graphics.DrawEllipse(([Pen] pen, [Rect] object)
		DrawEllipse(pen, object) {
			Local

			if (status := DllCall("Gdiplus\GdipDrawEllipse", "Ptr", this.Ptr, "Ptr", pen.Ptr, "Float", object.x, "Float", object.y, "Float", object.Width - (width := pen.Width), "Float", object.Height - width, "Int")) {
				throw (Exception(FormatStatus(status)))
			}

			return (True)
		}

		;* graphics.DrawRectangle([Pen] pen, [Rect] object)
		DrawRectangle(pen, object) {
			Local

			if (status := DllCall("Gdiplus\GdipDrawRectangle", "Ptr", this.Ptr, "Ptr", pen.Ptr, "Float", object.x, "Float", object.y, "Float", object.Width - (width := pen.Width), "Float", object.Height - width, "Int")) {
				throw (Exception(FormatStatus(status)))
			}

			return (True)
		}

		;* graphics.DrawLine([Pen] pen, [Vec2] object1, [Vec2] object2)
		DrawLine(pen, object1, object2) {
			Local

			if (status := DllCall("Gdiplus\GdipDrawLine", "Ptr", this.Ptr, "Ptr", pen.Ptr, "Float", object1.x, "Float", object1.y, "Float", object2.x, "Float", object2.y, "Int")) {
				throw (Exception(FormatStatus(status)))
			}

			return (True)
		}
	}

	;--------------- Canvas -------------------------------------------------------;

	;* GDIp.CreateCanvas(x, y, width, height[, guiOptions, showOptions, smoothing, interpolation])
	CreateCanvas(x, y, width, height, guiOptions := "", showOptions := "NA", title := "", smoothing := 4, interpolatiom := 7) {
		Gui, % Format("{}: New", title), % Format("{} +hWndhWnd +E0x80000", RegExReplace(guiOptions, "\+E0x80000"))  ;* Create a layered window (`"+E0x80000"` must be used for `UpdateLayeredWindow` to work).
		Gui, Show, % showOptions, % title

		instance := {"Handle": hWnd  ;* Save a handle to the window in order to update it.
			, "Base": this.__Canvas}

		instance.DC := GDI.CreateCompatibleDC()  ;* Get a memory DC compatible with the screen.
		instance.Bitmap := GDI.CreateDIBSection(CreateBitmapInfoHeader(width, -height), instance.DC)  ;* Create a GDI bitmap.
			, instance.DC.SelectObject(instance.Bitmap)  ;* Select the DIB into the memory DC.

		(instance.Graphics := this.CreateGraphicsFromDC(instance.DC)).SetSmoothingMode(smoothing)
			, instance.Graphics.SetInterpolationMode(interpolatiom)

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

	;---------------  Brush  -------------------------------------------------------;

	CreateBrush(color := 0xFFFFFFFF)  {
		Local

		if (status := DllCall("Gdiplus\GdipCreateSolidFill", "UInt", color, "Ptr*", pBrush := 0, "Int")) {
			throw (Exception(FormatStatus(status)))
		}

		return ({"Ptr": pBrush
			, "Base": this.__Brush})
	}

	Class __Brush {

		__Delete() {
			if (!this.Ptr) {
				MsgBox("Brush.__Delete()")
			}

			DllCall("Gdiplus\GdipDeleteBrush", "Ptr", this.Ptr)
		}

		Clone() {
			if (status := DllCall("Gdiplus\GdipCloneBrush", "Ptr", this.Ptr, "Ptr*", pBrush := 0, "Int")) {
				throw (Exception(FormatStatus(status)))
			}

			return ({"Ptr": pBrush
				, "Base": this.Base})
		}

		Color[] {
			Get {
				return (this.GetColor())
			}

			Set {
				return (value, this.SetColor(value))
			}
		}

		GetColor() {
			Local

			if (status := DllCall("Gdiplus\GdipGetSolidFillColor", "Ptr", this.Ptr, "UInt*", color := 0, "Int")) {
				throw (Exception(FormatStatus(status)))
			}

			return (Format("0x{:X}", color))
		}

		SetColor(color := 0xFFFFFFFF) {
			Local

			if (status := DllCall("Gdiplus\GdipSetSolidFillColor", "Ptr", this.Ptr, "UInt", color, "Int")) {
				throw (Exception(FormatStatus(status)))
			}

			return (True)
		}
	}

	;-------------  Linebrush  -----------------------------------------------------;

	;* GDIp.CreateLineBrush(x1, y1, x2, y2, color1, color2[, wrapMode])
	;* Parameters:
		;* wrapMode:
			;? 0: Tiling without flipping
			;? 1: Tiles are flipped horizontally as you move from one tile to the next in a row
			;? 2: Tiles are flipped vertically as you move from one tile to the next in a column
			;? 3: Tiles are flipped horizontally as you move along a row and flipped vertically as you move along a column
			;? 4: No tiling takes place
	CreateLineBrush(x1, y1, x2, y2, color1, color2, wrapMode := 0) {
		Static point1 := CreatePoint(0, 0, "Float"), point2 := CreatePoint(0, 0, "Float")

		point1.NumPut(0, "Float", x1, "Float", y1), point2.NumPut(0, "Float", x2, "Float", y2)

		if (status := DllCall("Gdiplus\GdipCreateLineBrush", "Ptr", point1.Ptr, "Ptr", point2.Ptr, "UInt", color1, "UInt", color2, "UInt", wrapMode, "Ptr*", pBrush := 0, "Int")) {
			throw (Exception(FormatStatus(status)))
		}

		return ({"Ptr": pBrush
			, "Base": this.__LineBrush})
	}

	CreateLineBrushFromRect(x, y, width, height, color1, color2, gradientMode := 0, wrapMode := 0) {
		Static rect := CreateRect(0, 0, 0, 0, "Float")

		rect.NumPut(0, "Float", x, "Float", y, "Float", width, "Float", height)

		if (status := DllCall("Gdiplus\GdipCreateLineBrushFromRect", "Ptr", rect.Ptr, "UInt", color1, "UInt", color2, "UInt", gradientMode, "UInt", wrapMode, "Ptr*", pBrush := 0, "Int")) {
			throw (Exception(FormatStatus(status)))
		}

		return ({"Ptr": pBrush
			, "Base": this.__LineBrush})
	}

	CreateLineBrushFromRectWithAngle(x, y, width, height, color1, color2, angle := 0, wrapMode := 0) {
		Static rect := CreateRect(0, 0, 0, 0, "Float")

		rect.NumPut(0, "Float", x, "Float", y, "Float", width, "Float", height)

		if (status := DllCall("Gdiplus\GdipCreateLineBrushFromRectWithAngle", "Ptr", rect.Ptr, "UInt", color1, "UInt", color2, "Float", angle, "UInt", 0, "UInt", wrapMode, "Ptr*", pBrush := 0, "Int")) {
			throw (Exception(FormatStatus(status)))
		}

		return ({"Ptr": pBrush
			, "Base": this.__LineBrush})
	}

	Class __LineBrush extends GDIp.__Brush {

		Color[] {
			Get {
				return (this.GetColor())
			}

			Set {
				return (value, this.SetColor(value))
			}
		}

		GetColor() {
			Static colors := new Structure(8)

			if (status := DllCall("Gdiplus\GdipGetLineColors", "Ptr", this.Ptr, "Ptr", colors.Ptr, "Int")) {
				throw (Exception(FormatStatus(status)))
			}

			return ([Format("0x{:X}", colors.NumGet(0, "UInt")), Format("0x{:X}", colors.NumGet(4, "UInt"))])
		}

		SetColor(color1 := 0xFFFFFFFF, color2 := 0xFFFFFFFF) {
			Local

			if (status := DllCall("Gdiplus\GdipSetLineColors", "Ptr", this.Ptr, "UInt", color1, "UInt", color2, "Int")) {
				throw (Exception(FormatStatus(status)))
			}

			return (True)
		}
	}

	;----------------  Pen  --------------------------------------------------------;

	CreatePen(color := 0xFFFFFFFF, width := 1) {
		Local

		if (status := DllCall("Gdiplus\GdipCreatePen1", "UInt", color, "Float", width, "Int", 2, "Ptr*", pPen := 0, "Int")) {
			throw (Exception(FormatStatus(status)))
		}

		return ({"Ptr": pPen
			, "Base": this.__Pen})
	}

	CreatePenFromBrush(brush, width := 1) {
		Local

		if (status := DllCall("Gdiplus\GdipCreatePen2", "Ptr", brush.Ptr, "Float", width, "Int", 2, "Ptr*", pPen := 0, "Int")) {
			throw (Exception(FormatStatus(status)))
		}

		return ({"Ptr": pPen
			, "Base": this.__Pen})
	}

	Class __Pen {

		__Delete() {
			if (!this.Ptr) {
				MsgBox("Pen.__Delete()")
			}

			DllCall("Gdiplus\GdipDeletePen", "Ptr", this.Ptr)
		}

		Clone() {
			Local

			if (status := DllCall("Gdiplus\GdipClonePen", "Ptr", this.Ptr, "Ptr*", pPen, "Int")) {
				throw (Exception(FormatStatus(status)))
			}

			return ({"Ptr": pPen
				, "Base": this.Base})
		}

		BrushFill[] {
			Set {
				return (value, this.SetBrushFill(value))
			}
		}

		SetBrushFill(brush) {
			Local

			if (status := DllCall("Gdiplus\GdipSetPenBrushFill", "Ptr", this.Ptr, "Ptr", brush.Ptr, "Int")) {
				throw (Exception(FormatStatus(status)))
			}

			return (True)
		}

		Color[] {
			Get {
				return (this.GetColor())
			}

			Set {
				return (value, this.SetColor(value))
			}
		}

		GetColor() {
			Local

			if (status := DllCall("Gdiplus\GdipGetPenColor", "Ptr", this.Ptr, "UInt*", color := 0, "Int")) {  ;* `GetColor()` throws an exception if the Pen object inherited it's color from a LineBrush object.
				throw (Exception(FormatStatus(status)))
			}

			return (Format("0x{:X}", color))
		}

		SetColor(color := 0xFFFFFFFF) {
			Local

			if (status := DllCall("Gdiplus\GdipSetPenColor", "Ptr", this.Ptr, "UInt", color, "Int")) {
				throw (Exception(FormatStatus(status)))
			}

			return (True)
		}

		Width[] {
			Get {
				return (this.GetWidth())
			}

			Set {
				return (value, this.SetWidth(value))
			}
		}

		GetWidth() {
			Local

			if (status := DllCall("Gdiplus\GdipGetPenWidth", "Ptr", this.Ptr, "Float*", width := 0, "Int")) {
				throw (Exception(FormatStatus(status)))
			}

			return (~~width)
		}

		SetWidth(width := 1) {
			Local

			if (status := DllCall("Gdiplus\GdipSetPenWidth", "Ptr", this.Ptr, "Float", width, "Int")) {
				throw (Exception(FormatStatus(status)))
			}

			return (True)
		}
	}
}