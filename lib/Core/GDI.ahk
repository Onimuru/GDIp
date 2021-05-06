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
	;* Parameter:
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
	;* Parameter:
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