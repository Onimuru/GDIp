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

	(DC := (new instance())).Handle := hDC
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

	return (0)
}

;===============  Class  =======================================================;

Class GDI {

	Class Bitmap {

		;* new GDI.Bitmap(bitmapInfo[, DC, usage, pBits, hSection, offset])
		;* new GDI.Bitmap(DC, width, height)
		;* new GDI.Bitmap(width, height[, bitCount, planes, pBits])
		__New(params*) {
			switch (Class(params[1])) {
				case "__Structure": {
					if (!handle := DllCall("Gdi32\CreateDIBSection"
							, "Ptr", (params[2]) ? (params[2].Handle) : (GetDC()), "Ptr", params[1].Ptr, "UInt", params[3], "Ptr*", params[4], "Ptr", params[5], "UInt", params[6], "Ptr")) {
						throw (Exception(Format("0x{:X}", A_LastError), 0, FormatMessage(A_LastError)))
					}

					return ({"Handle": handle  ;~ DIB
						, "Base": this.__Bitmap})
				}
				case "__CompatibleDC", "__DC": {
					if (!handle := DllCall("Gdi32\CreateCompatibleBitmap"
							, "Ptr", params[1].Handle, "Int", Round(params[2]), "Int", Round(params[3]), "Ptr")) {
						throw (Exception(Format("0x{:X}", A_LastError), 0, FormatMessage(A_LastError)))
					}

					return ({"Handle": handle  ;~ DDB
						, "Base": this.__Bitmap})
				}
				Default: {
					if (!handle := DllCall("Gdi32\CreateBitmap"
							, "Int", Round(params[1]), "Int", Round(params[2]), "UInt", (params[4]) ? (params[4]) : (1), "UInt", (params[3]) ? (params[3]) : (32), "Ptr", Round(params[5]), "Ptr")) {
						throw (Exception(Format("0x{:X}", A_LastError), 0, FormatMessage(A_LastError)))
					}

					return ({"Handle": handle   ;~ DDB (monochrome)
						, "Base": this.__Bitmap})
				}
			}
		}

		;* GDI.Bitmap.BitBlt([DC] destinationDC[, x1, y1, width, height, [DC] sourceDC, x2, y2, rasterOperation])
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
		BitBlt(destinationDC, x1, y1, width, height, sourceDC, sourcePoint, rasterOperation := 0x00CC0020) {
			if (!DllCall("Gdi32\BitBlt", "Ptr", destinationDC.Handle, "Int", x1, "Int", y1, "Int", width, "Int", height, "Ptr", sourceDC.Handle, "Int", x2, "Int", y2, "UInt", rasterOperation)) {  ;: https://docs.microsoft.com/en-us/windows/win32/api/wingdi/nf-wingdi-bitblt
				throw (Exception(Format("0x{:X}", A_LastError), 0, FormatMessage(A_LastError)))
			}

			return (0)
		}

		MaskBlt(destinationDC, destinationPoint, size, sourceDC, sourcePoint, mask, offsetPoint, rasterOperation := 0x00CC0020) {  ;: https://docs.microsoft.com/en-us/windows/win32/api/wingdi/nf-wingdi-maskblt
			return (1)
		}

		PlgBlt(destinationDC, destinationPoint, size, sourceDC, sourcePoint, mask, offsetPoint, rasterOperation := 0x00CC0020) {  ;: https://docs.microsoft.com/en-us/windows/win32/api/wingdi/nf-wingdi-plgblt
			return (1)
		}

		Class __Bitmap {

			__Delete() {
				if (!this.Handle) {
					MsgBox("Bitmap.__Delete()")
				}

				DllCall("Gdi32\DeleteObject", "Ptr", this.Handle, "UInt")  ;* If the specified handle is not valid or is currently selected into a DC, the return value is zero.
			}

			CreatePtr(hPalette := 0) {
				Local

				DllCall("Gdiplus\GdipCreateBitmapFromHBITMAP", "Ptr", this.Handle, "Ptr", hPalette, "Ptr*", pBitmap := 0)  ;* Do not pass to the GdipCreateBitmapFromHBITMAP function a GDI bitmap or a GDI palette that is currently (or was previously) selected into a device context.

				return (pBitmap)
			}
		}
	}

	Class DC {

		__New(DC := "") {
			return (this.CreateCompatibleDC(DC))
		}

		CreateCompatibleDC(DC := "") {
			if (!hDC := DllCall("Gdi32\CreateCompatibleDC", "Ptr", DC.Handle, "Ptr")) {
				throw (Exception(Format("0x{:X}", A_LastError), 0, FormatMessage(A_LastError)))
			}

			return ({"Handle": hDC  ;~ Memory DC
				, "Base": this.__CompatibleDC})
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
					}
				}
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

					this.OriginalObjects := {}

					return (0)
				}
			}
		}
	}
}

Class GDIp {

	;------------  Constructor  ----------------------------------------------------;

	__New(params*) {
        throw (Exception("GDIp.__New()", -1, "This class object should not be constructed."))
	}

	;--------------- Method -------------------------------------------------------;

	Startup() {
		if (!this.Token) {
			LoadLibrary("Gdiplus")

			if (error := DllCall("Gdiplus\GdiplusStartup", "Ptr*", pToken, "Ptr", CreateGDIplusStartupInput().Ptr, "Ptr", 0, "Int")) {  ;: https://docs.microsoft.com/en-us/windows/win32/api/gdiplusinit/nf-gdiplusinit-gdiplusstartup
				throw (Exception(Format("0x{:X}", error), 0, FormatStatus(error)))
			}

			this.Token := pToken

			return (1)
		}

		return (0)
	}

	Shutdown() {
		if (this.Token) {
			DllCall("Gdiplus\GdiplusShutdown", "Ptr", this.Remove("Token"))

			FreeLibrary("Gdiplus")

			return (1)
		}

		return (0)
	}

	;------------ Nested Class ----------------------------------------------------;

	Class Canvas {

		__Init() {
			if (!GDIp.Token) {
				throw (Exception("GDIp Not Started", -1, "You must call `GDIp.Startup()` before initializing this class."))
			}
		}

		;* new GDIp.Canvas(x, y, width, height[, guiOptions, showOptions, smoothing, interpolation])
		__New(x, y, width, height, guiOptions := "", showOptions := "NA", title := "", smoothing := 4, interpolatiom := 7) {
			Gui, % Format("{}: New", title), % Format("{} +hWndhWnd +E0x80000", RegExReplace(guiOptions, "\+E0x80000"))  ;* Create a layered window (`"+E0x80000"` must be used for `UpdateLayeredWindow` to work).
			Gui, Show, % showOptions, % title

			instance := {"Handle": hWnd  ;* Save a handle to the window in order to update it.
				, "Base": this.__Canvas}

			instance.DC := new GDI.DC()  ;* Get a memory DC compatible with the screen.
			instance.Bitmap := new GDI.Bitmap(CreateBitmapInfoHeader(width, -height), instance.DC)  ;* Create a GDI bitmap.
				, instance.DC.SelectObject(instance.Bitmap)  ;* Select the DIB into the memory DC.
			instance.Graphics := new GDIp.Graphics(instance.DC, smoothing, interpolatiom)

			return (instance, instance.Update(x, y, width, height))
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
					ObjRawSet(this, "Title", title)

					DetectHiddenWindows, % detect

					return (title)
				}

				Set {
					WinSetTitle, % this.Handle, , % value
					ObjRawSet(this, "Title", value)

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
				Static point := CreatePoint(0, 0)

				if (x != "") {
					point.NumPut(0, "UInt", this.x := x)
				}

				if (y != "") {
					point.NumPut(4, "UInt", this.y := y)
				}

				Static size := CreateSize(0, 0)

				if (width != "") {
					size.NumPut(0, "UInt", this.Width := width)
				}

				if (height != "") {
					size.NumPut(4, "UInt", this.Height := height)
				}

				if (alpha != "") {
					Static blend := CreateBlendFunction(0xFF)

					blend.NumPut(2, "UChar", this.Alpha := alpha)
				}

				if (!DllCall("User32\UpdateLayeredWindow", "Ptr", this.Handle, "Ptr", 0, "Ptr", point.Ptr, "Ptr", size.Ptr, "Ptr", this.DC.Handle, "Int64*", 0, "UInt", 0, "Ptr", blend.Ptr, "UInt", 0x00000002, "UInt")) {
					throw (Exception(Format("0x{:X}", A_LastError), 0, FormatMessage(A_LastError)))
				}

				return (1)
			}
		}
	}

	Class Bitmap {

		__Init() {
			if (!GDIp.Token) {
				throw (Exception("GDIp Not Started", -1, "You must call `GDIp.Startup()` before initializing this class."))
			}
		}

		;* new GDIp.Bitmap([Array] size[, format, stride, [Structure] scan0])
		;* new GDIp.Bitmap([Array] rect)
		;* new GDIp.Bitmap(hWnd)
		;* new GDIp.Bitmap(file)
		__New(source, params*) {
			Local

			switch (Class(source)) {
				case "__Array": {
					switch (source.Length) {
						case 2: {
							DllCall("Gdiplus\GdipCreateBitmapFromScan0", "UInt", source[0], "UInt", source[1], "UInt", Round(params[2]), "UInt", (params[1]) ? (params[1]) : (0x26200A), "Ptr", (params[3]) ? (params[3]) : (0), "Ptr*", pBitmap := 0)  ;: https://docs.microsoft.com/en-us/windows/win32/api/gdiplusheaders/nf-gdiplusheaders-bitmap-bitmap(int_int_int_pixelformat_byte)

							instance := {"Ptr": pBitmap
								, "Base": this.__Bitmap}
						}
						case 4: {
							instance := this.CreateFromScreen(source)
						}
					}
				}
				Default: {
					if (DllCall("IsWindow", "Ptr", RegExReplace(source, "i)ahk_id\s?"), "UInt")) {
						instance := this.CreateFromHWnd(source)
					}
					else if (FileExist(source)) {
						instance := this.CreateFromFile(source)
					}
					else {
						MsgBox("GDIp.Bitmap.__New(): " . Class(source))
					}
				}
			}

			return (instance)
		}
	}

	Class Graphics {

		__Init() {
			if (!GDIp.Token) {
				throw (Exception("GDIp Not Started", -1, "You must call `GDIp.Startup()` before initializing this class."))
			}
		}

		__New(source, smoothing := 0, interpolation := 0) {
			Local

			switch (Class(source)) {
				case "__CompatibleDC", "__DC": {
					GDIp.LastStatus := DllCall("Gdiplus\GdipCreateFromHDC", "Ptr", source.Handle, "Ptr*", pGraphics := 0)
				}
				case "__Bitmap": {
					GDIp.LastStatus := DllCall("Gdiplus\GdipGetImageGraphicsContext", "Ptr", source.Ptr, "Ptr*", pGraphics := 0)
				}
				Default: {
					MsgBox("Graphics.__New(): " . (Clipboard := Class(source)))
				}
			}

			if (GDIp.LastStatus) {
				return (GDIp.LastStatus)
			}

			DllCall("Gdiplus\GdipSetSmoothingMode", "Ptr", pGraphics, "Int", smoothing)
			DllCall("Gdiplus\GdipSetInterpolationMode", "Ptr", pGraphics, "Int", interpolation)

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

			;-------------- Property ------------------------------------------------------;

			;* Graphics.CompositingMode := value
			;* Parameters:
				;* value:
					;? 0: SourceOver (blend)
					;? 1: SourceCopy (overwrite)
			CompositingMode[] {
				Set {
					if (error := DllCall("Gdiplus\GdipSetCompositingMode", "Ptr", this.Ptr, "Int", Math.Clamp(value, 0, 1), "Int")) {
						throw (Exception(Format("0x{:X}", error), 0, FormatStatus(error)))
					}

					return (value)
				}
			}

			;* Graphics.InterpolationMode := value
			;* Parameters:
				;* value:
					;? 0: Default
					;? 1: LowQuality
					;? 2: HighQuality
					;? 3: Bilinear
					;? 4: Bicubic
					;? 5: NearestNeighbor
					;? 6: HighQualityBilinear
					;? 7: HighQualityBicubic
			InterpolationMode[] {
				Set {
					if (error := DllCall("Gdiplus\GdipSetInterpolationMode", "Ptr", this.Ptr, "Int", Math.Clamp(value, 0, 7), "Int")) {
						throw (Exception(Format("0x{:X}", error), 0, FormatStatus(error)))
					}

					return (value)
				}
			}

			;* Graphics.SmoothingMode := value
			;* Parameters:
				;* value:
					;? 0: Default
					;? 1: HighSpeed
					;? 2: HighQuality
					;? 3: None
					;? 4: AntiAlias
			SmoothingMode[] {
				Set {
					if (error := DllCall("Gdiplus\GdipSetSmoothingMode", "Ptr", this.Ptr, "Int", Math.Clamp(value, 0, 4), "Int")) {
						throw (Exception(Format("0x{:X}", error), 0, FormatStatus(error)))
					}

					return (value)
				}
			}

			;* graphics.SmoothingMode := value
			;* Parameters:
				;* value:
					;? 0: SystemDefault
					;? 1: SingleBitPerPixelGridFit
					;? 2: SingleBitPerPixel
					;? 3: AntiAliasGridFit
					;? 4: AntiAlias
					;? 5: ClearTypeGridFit
			TextRendering[] {
				Set {
					if (error := DllCall("Gdiplus\GdipSetTextRenderingHint", "Ptr", this.Ptr, "Int", Math.Clamp(value, 0, 5), "Int")) {
						throw (Exception(Format("0x{:X}", error), 0, FormatStatus(error)))
					}

					return (value)
				}
			}

			;--------------- Method -------------------------------------------------------;
			;--------------------------------------------------------  Pen  ----------------;

			;* Graphics.DrawRectangle([Pen] pen, [Rect] rect)
			DrawRectangle(pen, rect) {
				Local

				width := pen.Width

				if (error := DllCall("Gdiplus\GdipDrawRectangle", "Ptr", this.Ptr, "Ptr", pen.Ptr, "Float", rect.x, "Float", rect.y, "Float", rect.Width - width, "Float", rect.Height - width, "Int")) {
					throw (Exception(Format("0x{:X}", error), 0, FormatStatus(error)))
				}

				return (0)
			}

			;------------------------------------------------------  Control  --------------;

			;* Note:
				;* Using clipping regions you can clear a particular area on the graphics rather than clearing the entire graphics.
			Clear(color := 0x00000000) {
				if (error := DllCall("Gdiplus\GdipGraphicsClear", "Ptr", this.Ptr, "UInt", color, "Int")) {
					throw (Exception(Format("0x{:X}", error), 0, FormatStatus(error)))
				}

				return (0)
			}
		}
	}

	Class Pen {

		__Init() {
			if (!GDIp.Token) {
				throw (Exception("GDIp Not Started", -1, "You must call `GDIp.Startup()` before initializing this class."))
			}
		}

		__New(source := 0xFFFFFFFF, width := 1) {
			Local

			if (error := (IsObject(source)) ? (DllCall("Gdiplus\GdipCreatePen2", "Ptr", source.Ptr, "Float", width, "Int", 2, "Ptr*", pPen := 0, "Int")) : (DllCall("Gdiplus\GdipCreatePen1", "UInt", source, "Float", width, "Int", 2, "Ptr*", pPen := 0, "Int"))) {
				throw (Exception(Format("0x{:X}", error), 0, FormatStatus(error)))
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

			Brush[] {
				Set {
					if (error := DllCall("Gdiplus\GdipSetPenBrushFill", "Ptr", this.Ptr, "Ptr", value.Ptr, "Int")) {
						throw (Exception(Format("0x{:X}", error), 0, FormatStatus(error)))
					}

					return (value)
				}
			}

			Color[] {
				Get {
					Local

					if (error := DllCall("Gdiplus\GdipGetPenColor", "Ptr", this.Ptr, "UInt*", color := 0, "Int")) {
						throw (Exception(Format("0x{:X}", error), 0, FormatStatus(error)))
					}

					return (Format("0x{:X}", color))
				}

				Set {
					if (error := DllCall("Gdiplus\GdipSetPenColor", "Ptr", this.Ptr, "UInt", value, "Int")) {
						throw (Exception(Format("0x{:X}", error), 0, FormatStatus(error)))
					}

					return (value)
				}
			}

			Width[] {
				Get {
					Local

					if (error := DllCall("Gdiplus\GdipGetPenWidth", "Ptr", this.Ptr, "Float*", width := 0, "Int")) {
						throw (Exception(Format("0x{:X}", error), 0, FormatStatus(error)))
					}

					return (~~width)
				}

				Set {
					if (error := DllCall("Gdiplus\GdipSetPenWidth", "Ptr", this.Ptr, "Float", value, "Int")) {
						throw (Exception(Format("0x{:X}", error), 0, FormatStatus(error)))
					}

					return (value)
				}
			}

			Clone() {
				if (error := DllCall("Gdiplus\GdipClonePen", "Ptr", this.Ptr, "Ptr*", pPen, "Int")) {
					throw (Exception(Format("0x{:X}", error), 0, FormatStatus(error)))
				}

				return ({"Ptr": pPen
					, "Base": this.Base})
			}
		}
	}
}