;* ** Useful Links **
;* GDIp enums: https://github.com/mono/libgdiplus/blob/main/src/gdipenums.h

GetRotatedTranslation(width, height, angle, ByRef xTranslation, ByRef yTranslation) {
	angle := (angle >= 0) ? (Mod(angle, 360)) : (360 - Mod(-angle, -360))

	if ((angle >= 0) && (angle <= 90)) {
		xTranslation := height*Sin(Math.ToRadians(angle)), yTranslation := 0
	}
	else if ((angle > 90) && (angle <= 180)) {
		radians := Math.ToRadians(angle), cos := Cos(radians)
			, xTranslation := (height*Sin(radians)) - (width*cos), yTranslation := -height*cos
	}
	else if ((angle > 180) && (angle <= 270)) {
		radians := Math.ToRadians(angle), cos := Cos(radians)
			, xTranslation := -(width*cos), yTranslation := -(height*cos) - (width*Sin(radians))
	}
	else if ((angle > 270) && (angle <= 360)) {
		xTranslation := 0, yTranslation := -width*Sin(Math.ToRadians(angle))
	}
}

GetRotatedDimensions(width, height, angle, ByRef rotatedWidth, ByRef rotatedHeight) {
	angle := (angle >= 0) ? (Mod(angle, 360)) : (360 - Mod(-angle, -360))
		, radians := Math.ToRadians(angle)

	sin := Sin(radians), cos := Cos(radians)
		, rotatedWidth := Abs(width*cos) + Abs(height*sin), rotatedHeight := Abs(width*sin) + Abs(height*cos)
}

Class GDIp {

	__New(params*) {
        throw (Exception("GDIp.__New()", -1, "This class must not be constructed."))
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

	#Include, %A_LineFile%\..\GDIp\Canvas.ahk

	#Include, %A_LineFile%\..\GDIp\Bitmap.ahk

	CreateImageAttributes() {
		Local

		if (status := DllCall("Gdiplus\GdipCreateImageAttributes", "Ptr*", pImageAttributes := 0, "Int")) {
			throw (Exception(FormatStatus(status)))
		}

		return ({"Ptr": pImageAttributes
			, "Base": this.__ImageAttributes})
	}

	Class __ImageAttributes {

		__Delete() {
			if (!this.Ptr) {
				MsgBox("FontFamily.__Delete()")
			}

			DllCall("Gdiplus\GdipDisposeImageAttributes", "Ptr", this.Ptr)
		}

		;--------------- Method -------------------------------------------------------;

		Clone() {
			Local

			if (status := DllCall("Gdiplus\GdipCloneImageAttributes", "Ptr", this.Ptr, "Ptr*", pImageAttributes := 0, "Int")) {
				throw (Exception(FormatStatus(status)))
			}

			return ({"Ptr": pImageAttributes
				, "Base": this.Base})
		}
	}

	#Include, %A_LineFile%\..\GDIp\Graphics.ahk

	#Include, %A_LineFile%\..\GDIp\Brush.ahk

	#Include, %A_LineFile%\..\GDIp\Pen.ahk

	;* GDIp.CreateFont([__FontFamily] fontFamily, size[, style, unit])
	;* Parameter:
		;* style:  ;: https://docs.microsoft.com/en-us/dotnet/api/system.drawing.fontstyle?view=net-5.0
			;? 0: FontStyleRegular
			;? 1: FontStyleBold
			;? 2: FontStyleItalic
			;? 4: FontStyleUnderline
			;? 8: FontStyleStrikeout
	CreateFont(fontFamily, size, style := 0, unit := 2) {
		Local

		if (status := DllCall("Gdiplus\GdipCreateFont", "Ptr", fontFamily.Ptr, "Float", size, "Int", style, "UInt", unit, "Ptr*", pFont := 0, "Int")) {
			throw (Exception(FormatStatus(status)))
		}

		return ({"Ptr": pFont
			, "Base": this.__Font})
	}

	Class __Font {

		__Delete() {
			if (!this.Ptr) {
				MsgBox("Font.__Delete()")
			}

			DllCall("Gdiplus\GdipDeleteFont", "Ptr", this.Ptr)
		}
	}

	CreateFontFamilyFromName(name := "Fira Code Retina") {
		Local

		if (status := DllCall("Gdiplus\GdipCreateFontFamilyFromName", "Str", name, "Ptr", 0, "Ptr*", pFontFamily := 0, "Int")) {
			throw (Exception(FormatStatus(status)))
		}

		return ({"Ptr": pFontFamily
			, "Base": this.__FontFamily})
	}

	Class __FontFamily {

		__Delete() {
			if (!this.Ptr) {
				MsgBox("FontFamily.__Delete()")
			}

			DllCall("Gdiplus\GdipDeleteFontFamily", "Ptr", this.Ptr)
		}
	}

	;* GDIp.CreateStringFormat([stringFormatFlags, language])
	;* Parameter:
		;* stringFormatFlags:  ;: https://docs.microsoft.com/en-us/windows/win32/api/gdiplusenums/ne-gdiplusenums-stringformatflags
			;? 0x00000001: StringFormatFlagsDirectionRightToLeft
			;? 0x00000002: StringFormatFlagsDirectionVertical
			;? 0x00000004: StringFormatFlagsNoFitBlackBox
			;? 0x00000020: StringFormatFlagsDisplayFormatControl
			;? 0x00000400: StringFormatFlagsNoFontFallback
			;? 0x00000800: StringFormatFlagsMeasureTrailingSpaces
			;? 0x00001000: StringFormatFlagsNoWrap
			;? 0x00002000: StringFormatFlagsLineLimit
			;? 0x00004000: StringFormatFlagsNoClip
		;* language - Sixteen-bit value that specifies the language to use.
	CreateStringFormat(stringFormatFlags := 0, language := 0) {
		Local

		if (status := DllCall("Gdiplus\GdipCreateStringFormat", "UInt", stringFormatFlags, "Int", language, "Ptr*", pStringFormat := 0, "Int")) {
			throw (Exception(FormatStatus(status)))
		}

		return ({"Ptr": pStringFormat
			, "Base": this.__StringFormat})
	}

	Class __StringFormat {

		__Delete() {
			if (!this.Ptr) {
				MsgBox("StringFormat.__Delete()")
			}

			DllCall("Gdiplus\GdipDeleteStringFormat", "Ptr", this.Ptr)
		}

		StringAlignment[] {
			Set {
				this.SetAlign(value)

				return (value)
			}
		}

		;* stringFormat.SetAlign(stringAlignment)
		;* Parameter:
			;* stringAlignment:  ;: https://docs.microsoft.com/en-us/windows/win32/api/gdiplusenums/ne-gdiplusenums-stringalignment
				;? 0: StringAlignmentNear - Left.
				;? 1: StringAlignmentCenter
				;? 2: StringAlignmentFar - Right.
		SetAlign(stringAlignment) {
			Local

			if (status := DllCall("Gdiplus\GdipSetStringFormatAlign", "Ptr", this.Ptr, "Int", stringAlignment, "Int")) {
				throw (Exception(FormatStatus(status)))
			}

			return (True)
		}

		LineAlign[] {
			Set {
				this.SetLineAlign(value)

				return (value)
			}
		}

		;* stringFormat.SetLineAlign(stringAlignment)
		;* Parameter:
			;* stringAlignment:  ;: https://docs.microsoft.com/en-us/windows/win32/api/gdiplusenums/ne-gdiplusenums-stringalignment
				;? 0: StringAlignmentNear - Top.
				;? 1: StringAlignmentCenter
				;? 2: StringAlignmentFar - Bottom.
		SetLineAlign(stringAlignment) {
			Local

			if (status := DllCall("Gdiplus\GdipSetStringFormatLineAlign", "Ptr", this.Ptr, "Int", stringAlignment, "Int")) {
				throw (Exception(FormatStatus(status)))
			}

			return (True)
		}
	}
}