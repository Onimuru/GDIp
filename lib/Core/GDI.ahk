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

;============ Auto-execute ====================================================;
;======================================================  Setting  ==============;

#Requires AutoHotkey v2.0-a134-d3d43350

;===============  Class  =======================================================;

/*
;* enum DeviceCaps  ;: http://msaccessgurus.com/VBA/Code/API_GetDeviceCaps_ppi.htm
	0x00 = DRIVERVERSION
	0x02 = TECHNOLOGY
	0x04 = HORZSIZE
	0x06 = VERTSIZE
	0x08 = HORZRES
	0x0A = VERTRES
	0x0C = BITSPIXEL
	0x0E = PLANES
	0x10 = NUMBRUSHES
	0x12 = NUMPENS
	0x14 = NUMMARKERS
	0x16 = NUMFONTS
	0x18 = NUMCOLORS
	0x1A = PDEVICESIZE
	0x1C = CURVECAPS
	0x1E = LINECAPS
	0x20 = POLYGONALCAPS
	0x22 = TEXTCAPS
	0x24 = CLIPCAPS
	0x26 = RASTERCAPS
	0x28 = ASPECTX
	0x2A = ASPECTY
	0x2C = ASPECTXY
	0x58 = LOGPIXELSX
	0x5A = LOGPIXELSY
	0x68 = SIZEPALETTE
	0x6A = NUMRESERVED
	0x6C = COLORRES
	0x6E = PHYSICALWIDTH
	0x6F = PHYSICALHEIGHT
	0x70 = PHYSICALOFFSETX
	0x71 = PHYSICALOFFSETY
	0x72 = SCALINGFACTORX
	0x73 = SCALINGFACTORY
	0x74 = VREFRESH
	0x77 = BLTALIGNMENT
	0x78 = SHADEBLENDCAPS
	0x79 = COLORMGMTCAPS

;* enum StretchMode
	1 = STRETCH_ANDSCANS
	2 = STRETCH_ORSCANS
	3 = STRETCH_DELETESCANS
	4 = STRETCH_HALFTONE

;* enum TernaryRasterOperations
	0x00000042 = BLACKNESS - Fills the destination rectangle using the color associated with palette index 0.
	0x40000000 = CAPTUREBLT - Includes any window that are layered on top of your window in the resulting image.
	0x00550009 = DSTINVERT - Inverts the destination rectangle.
	0x00C000CA = MERGECOPY - Merges the color of the source rectangle with the brush currently selected in hDest, by using the AND operator.
	0x00BB0226 = MERGEPAINT - Merges the color of the inverted source rectangle with the colors of the destination rectangle by using the OR operator.
	0x80000000 = NOMIRRORBITMAP - Prevents the bitmap from being mirrored.
	0x00330008 = NOTSRCCOPY - Copies the inverted source rectangle to the destination.
	0x001100A6 = NOTSRCERASE - Combines the colors of the source and destination rectangles by using the OR operator and then inverts the resultant color.
	0x00F00021 = PATCOPY - Copies the brush selected in hdcDest, into the destination bitmap.
	0x005A0049 = PATINVERT - Combines the colors of the brush currently selected in hDest, with the colors of the destination rectangle by using the XOR operator.
	0x00FB0A09 = PATPAINT - Combines the colors of the brush currently selected in hDest, with the colors of the inverted source rectangle by using the OR operator. The result of this operation is combined with the color of the destination rectangle by using the OR operator.
	0x008800C6 = SRCAND - Combines the colors of the source and destination rectangles by using the AND operator.
	0x00CC0020 = SRCCOPY - Copies the source rectangle directly to the destination rectangle.
	0x00440328 = SRCERASE - Combines the inverted color of the destination rectangle with the colors of the source rectangle by using the AND operator.
	0x00660046 = SRCINVERT - Combines the colors of the source and destination rectangles by using the XOR operator.
	0x00EE0086 = SRCPAINT - Combines the colors of the source and destination rectangles by using the OR operator.
	0x00FF0062 = WHITENESS - Fills the destination rectangle using the color associated with index 1 in the physical palette.
*/

Class GDI {

	__New(params*) {
        throw (Error("This class must not be constructed.", -1))
	}

	;--------------- Method -------------------------------------------------------;

	;* GDI.BitBlt(dDC, dx, dy, width, height, sDC, sx, sy[, operation])
	;* Parameter:
		;* [DC] dDC
		;* [Integer] dx
		;* [Integer] dy
		;* [Integer] width
		;* [Integer] height
		;* [DC] sDC
		;* [Integer] sx
		;* [Integer] sy
		;* [Integer] operation - See TernaryRasterOperations enumeration.
	static BitBlt(dDC, dx, dy, width, height, sDC, sx, sy, operation := 0x00CC0020) {  ;? 0x00CC0020 = SRCCOPY
		if (!DllCall("Gdi32\BitBlt", "Ptr", dDC.Handle, "Int", dx, "Int", dy, "Int", width, "Int", height, "Ptr", sDC.Handle, "Int", sx, "Int", sy, "UInt", operation, "UInt")) {  ;: https://docs.microsoft.com/en-us/windows/win32/api/wingdi/nf-wingdi-bitblt
			throw (ErrorFromMessage(DllCall("Kernel32\GetLastError")))
		}
	}

	static MaskBlt() {  ;: https://docs.microsoft.com/en-us/windows/win32/api/wingdi/nf-wingdi-maskblt
	}

	static PlgBlt() {  ;: https://docs.microsoft.com/en-us/windows/win32/api/wingdi/nf-wingdi-plgblt
	}

	;* GDI.StretchBlt(dDC, dx, dy, dWidth, dHeight, sDC, sx, sy, sWidth, sHeight[, operation])
	;* Parameter:
		;* [DC] dDC
		;* [Integer] dx
		;* [Integer] dy
		;* [Integer] dWidth
		;* [Integer] dHeight
		;* [DC] sDC
		;* [Integer] sx
		;* [Integer] sy
		;* [Integer] sWidth
		;* [Integer] sHeight
		;* [Integer] operation - See TernaryRasterOperations enumeration.
	static StretchBlt(dDC, dx, dy, dWidth, dHeight, sDC, sx, sy, sWidth, sHeight, operation := 0x00CC0020) {  ;? 0x00CC0020 = SRCCOPY
		if (!DllCall("Gdi32\StretchBlt", "Ptr", dDC.Handle, "Int", dx, "Int", dy, "Int", dWidth, "Int", dHeight, "Ptr", sDC.Handle, "Int", sx, "Int", sy, "Int", sWidth, "Int", sHeight, "UInt", operation, "UInt")) {
			throw (ErrorFromMessage(DllCall("Kernel32\GetLastError")))
		}
	}

	;---------------  Class  -------------------------------------------------------;
	;--------------------------------------------------------- DC -----------------;

	;* GDI.CreateCompatibleDC([DC])
	;* Parameter:
		;* [DC] DC
	static CreateCompatibleDC(DC := unset) {
		if (!(hDC := DllCall("Gdi32\CreateCompatibleDC", "Ptr", (IsSet(DC)) ? (DC.Handle) : (0), "Ptr"))) {  ;~ Memory DC
			throw (ErrorFromMessage(DllCall("Kernel32\GetLastError")))
		}

		return (this.CompatibleDC(hDC))
	}

	class CompatibleDC {
		Class := "DC", OriginalObjects := {}

		__New(hDC) {
			this.Handle := hDC
		}

		__Delete() {
			this.Reset()

			if (!DllCall("Gdi32\DeleteDC", "Ptr", this.Handle, "UInt")) {
				throw (ErrorFromMessage(DllCall("Kernel32\GetLastError")))
			}
		}

		;-------------- Property ------------------------------------------------------;

		;* DC.GetDeviceCaps(DC, index)
		;* Parameter:
			;* [DC] DC
			;* [Integer] index - See DeviceCaps enumeration.
		static GetDeviceCaps(index) {
			if (!(information := DllCall("Gdi32\GetDeviceCaps", "Ptr", this.Handle, "Int", index, "Int"))) {  ;: https://docs.microsoft.com/en-us/windows/win32/api/wingdi/nf-wingdi-getdevicecaps
				throw (ErrorFromMessage(DllCall("Kernel32\GetLastError")))
			}

			switch (index) {
				case 0x26:  ;? 0x26 = RASTERCAPS
					static rasterCaps := Map(0x0000, "RC_NONE", 0x0001, "RC_BITBLT", 0x0002, "RC_BANDING", 0x0004, "RC_SCALING", 0x0008, "RC_BITMAP64", 0x0010, "RC_GDI20_OUTPUT", 0x0020, "RC_GDI20_STATE", 0x0040, "RC_SAVEBITMAP", 0x0080, "RC_DI_BITMAP", 0x0100, "RC_PALETTE", 0x0200, "RC_DIBTODEV", 0x0400, "RC_BIGFONT", 0x0800, "RC_STRETCHBLT", 0x1000, "RC_FLOODFILL", 0x2000, "RC_STRETCHDIB", 0x4000, "RC_OP_DX_OUTPUT", 0x8000, "RC_DEVBITS")
					information := shadeBlendCaps[information]
				case 0x78:  ;? 0x78 = SHADEBLENDCAPS
					static shadeBlendCaps := Map(0x00000000, "SB_NONE", 0x00000001, "SB_CONST_ALPHA", 0x00000002, "SB_PIXEL_ALPHA", 0x00000004, "SB_PREMULT_ALPHA", 0x00000010, "SB_GRAD_RECT", 0x00000020, "SB_GRAD_TRI")
					information := shadeBlendCaps[information]
				case 0x02:  ;? 0x02 = TECHNOLOGY
					static technology := ["DT_PLOTTER", "DT_RASDISPLAY", "DT_RASPRINTER", "DT_RASCAMERA", "DT_CHARSTREAM", "DT_METAFILE", "DT_DISPFILE"]
					information := technology[information]
			}

			return (information)
		}

		Layout {
			Get {
				return (this.GetLayout())
			}

			Set {
				this.SetLayout(value)

				return (value)
			}
		}

		;* DC.GetLayout()
		;* Return:
			;* [Integer] layout
		GetLayout() {
			if ((layout := DllCall("Gdi32\SetLayout", this.Handle, "UInt")) == -1) {  ;: https://docs.microsoft.com/en-us/windows/win32/api/wingdi/nf-wingdi-getlayout
				throw (ErrorFromMessage(DllCall("Kernel32\GetLastError")))
			}
		}

		;* DC.SetLayout(layout)
		;* Parameter:
			;* [Integer] layout
		;* Note
			;~ The values returned by GetWindowOrgEx, GetWindowExtEx, GetViewportOrgEx and GetViewportExtEx are not affected by calling SetLayout.
		SetLayout(layout) {
			if (DllCall("Gdi32\SetLayout", this.Handle, "UInt", layout, "UInt") == -1) {  ;: https://docs.microsoft.com/en-us/windows/win32/api/wingdi/nf-wingdi-setlayout
				throw (ErrorFromMessage(DllCall("Kernel32\GetLastError")))
			}
		}

		StretchBltMode {
			Set {
				this.SetStretchBltMode(value)

				return (value)
			}
		}

		;* DC.SetStretchBltMode(stretchMode)
		;* Parameter:
			;* [Integer] stretchMode - See StretchMode enumeration.
		SetStretchBltMode(stretchMode) {
			if (!DllCall("Gdi32\SetStretchBltMode", "Ptr", this.Handle, "Int", stretchMode, "UInt")) {
				throw (ErrorFromMessage(DllCall("Kernel32\GetLastError")))
			}
		}

		;--------------- Method -------------------------------------------------------;

		;* DC.SelectObject(object)
		;* Parameter:
			;* [Object] object
		;* Return:
			;* [Integer] - Boolean value that indicates if an object was selected into this DC.
		SelectObject(object) {
			switch (class := object.Class) {
				case "HBitmap", "__Brush", "__Pen", "__Region", "__Font":
					if (!(hObject := DllCall("Gdi32\SelectObject", "Ptr", this.Handle, "Ptr", object.Handle, "Ptr"))) {  ;~ If an error occurs and the selected object is not a region, the return value is NULL. Otherwise, it is HGDI_ERROR.
						throw (ErrorFromMessage(DllCall("Kernel32\GetLastError")))
					}

					if (!this.OriginalObjects.HasProp(class)) {  ;* Save the handle to any original, default objects that are replaced.
						this.OriginalObjects.%class% := hObject
					}

					return (True)
			}

			return (False)
		}

		;* DC.Reset([class])
		;* Parameter:
			;* [String] class
		;* Return:
			;* [Integer] - Boolean value that indicates if an object was reset.
		Reset(class := "") {
			if (this.OriginalObjects.HasProp(class)) {
				if (!(hObject := DllCall("Gdi32\SelectObject", "Ptr", this.Handle, "Ptr", this.OriginalObjects.DeleteProp(class), "Ptr"))) {
					throw (ErrorFromMessage(DllCall("Kernel32\GetLastError")))
				}

				return (hObject)
			}
			else if (!class) {
				for class in this.OriginalObjects.Clone().OwnProps() {
					if (!DllCall("Gdi32\SelectObject", "Ptr", this.Handle, "Ptr", this.OriginalObjects.DeleteProp(class), "Ptr")) {
						throw (ErrorFromMessage(DllCall("Kernel32\GetLastError")))
					}
				}

				return (True)
			}

			return (False)
		}

;		// Take a snap-shot of the current state of the DC
;		SaveDC(
;			__in HDC hdc,           // Handle to the DC
;		);
;
;		// Restore the DC to a previously saved state
;		RestoreDC (
;			__in HDC hdc,           // Handle to the DC
;			__in int nSavedDC       // Saved state claim ticket
;		);
	}

	;------------------------------------------------------  HBitmap  --------------;

	;* GDI.CreateBitmap(width, height[, bitCount, planes, &bits])
	;* Parameter:
		;* [Integer] width
		;* [Integer] height
		;* [Integer] bitCount
		;* [Integer] planes
		;* [Structure] bits
	;* Return:
		;* [HBitmap]
	static CreateBitmap(width, height, bitCount := 32, planes := 1, &bits := 0) {
		if (!(hBitmap := DllCall("Gdi32\CreateBitmap", "Int", width, "Int", height, "UInt", planes, "UInt", bitCount, "Ptr", bits, "Ptr"))) {  ;~ DDB (monochrome)
			throw (ErrorFromMessage(DllCall("Kernel32\GetLastError")))
		}

		return (this.HBitmap(hBitmap))
	}

	;* GDI.CreateCompatibleBitmap(width, height[, DC])
	;* Parameter:
		;* [Integer] width
		;* [Integer] height
		;* [DC] DC
	;* Return:
		;* [HBitmap]
	static CreateCompatibleBitmap(width, height, DC := 0) {
		if (!(hBitmap := DllCall("Gdi32\CreateCompatibleBitmap", "Ptr", ((IsSet(DC)) ? (DC) : (GetDC())).Handle, "Int", width, "Int", height, "Ptr"))) {  ;~ DDB
			throw (ErrorFromMessage(DllCall("Kernel32\GetLastError")))
		}

		return (this.HBitmap(hBitmap))
	}

	;* GDI.CreateDIBSection(bitmapInfo[, DC, usage, &bits, hSection, offset])
	;* Parameter:
		;* [Structure] bitmapInfo
		;* [DC] DC
		;* [Integer] usage
		;* [Structure] bits
		;* [Integer] hSection
		;* [Integer] offset
	;* Return:
		;* [HBitmap]
	static CreateDIBSection(bitmapInfo, DC := unset, usage := 0, &bits := 0, hSection := 0, offset := 0) {
		if (!(hBitmap := DllCall("Gdi32\CreateDIBSection", "Ptr", ((IsSet(DC)) ? (DC) : (GetDC())).Handle, "Ptr", bitmapInfo.Ptr, "UInt", usage, "Ptr*", &bits, "Ptr", hSection, "UInt", offset, "Ptr"))) {  ;~ DIB
			throw (ErrorFromMessage(DllCall("Kernel32\GetLastError")))
		}

		return (this.HBitmap(hBitmap))
	}

	class HBitmap {  ;~ hBitmaps are word aligned, so a 24 bpp image will use 32 bits of space.
		Class := "HBitmap"

		__New(hBitmap) {
			this.Handle := hBitmap
		}

		__Delete() {
			if (!DllCall("Gdi32\DeleteObject", "Ptr", this.Handle, "UInt")) {
				throw (ErrorFromMessage(DllCall("Kernel32\GetLastError")))
			}
		}
	}
}