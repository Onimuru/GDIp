;* ** Useful Links **
;* GDIp enums: https://github.com/mono/libgdiplus/blob/main/src/gdipenums.h

/*
;* FontStyle enumeration (https://docs.microsoft.com/en-us/windows/win32/api/gdiplusenums/ne-gdiplusenums-fontstyle)
	;? 0 = FontStyleRegular
	;? 1 = FontStyleBold
	;? 2 = FontStyleItalic
	;? 3 = FontStyleBoldItalic
	;? 4 = FontStyleUnderline
	;? 8 = FontStyleStrikeout

;* MatrixOrder enumeration (https://docs.microsoft.com/en-us/windows/win32/api/gdiplusenums/ne-gdiplusenums-matrixorder)
	;? 0 = MatrixOrderPrepend
	;? 1 = MatrixOrderAppend

;* StringAlignment enumeration (https://docs.microsoft.com/en-us/windows/win32/api/gdiplusenums/ne-gdiplusenums-stringalignment)
	;? 0 = StringAlignmentNear - Left/Top.
	;? 1 = StringAlignmentCenter
	;? 2 = StringAlignmentFar - Right/Bottom.

;* StringDigitSubstitute enumeration (https://docs.microsoft.com/en-us/windows/win32/api/gdiplusenums/ne-gdiplusenums-stringdigitsubstitute)
	;? 0 = StringDigitSubstituteUser
	;? 1 = StringDigitSubstituteNone
	;? 2 = StringDigitSubstituteNational
	;? 3 = StringDigitSubstituteTraditional

;* StringFormatFlags enumeration (https://docs.microsoft.com/en-us/windows/win32/api/gdiplusenums/ne-gdiplusenums-stringformatflags)
	;? 0x00000001 = StringFormatFlagsDirectionRightToLeft
	;? 0x00000002 = StringFormatFlagsDirectionVertical
	;? 0x00000004 = StringFormatFlagsNoFitBlackBox - Parts of characters are allowed to overhang the string's layout rectangle.
	;? 0x00000020 = StringFormatFlagsDisplayFormatControl - Unicode layout control characters are displayed with a representative character.
	;? 0x00000400 = StringFormatFlagsNoFontFallback - Prevent using an alternate font  for characters that are not supported in the requested font.
	;? 0x00000800 = StringFormatFlagsMeasureTrailingSpaces - The spaces at the end of each line are included in a string measurement.
	;? 0x00001000 = StringFormatFlagsNoWrap - Disable text wrapping.
	;? 0x00002000 = StringFormatFlagsLineLimit - Only entire lines are laid out in the layout rectangle.
	;? 0x00004000 = StringFormatFlagsNoClip - Characters overhanging the layout rectangle and text extending outside the layout rectangle are allowed to show.

;* StringTrimming enumeration (https://docs.microsoft.com/en-us/windows/win32/api/gdiplusenums/ne-gdiplusenums-stringtrimming)
	;? 0 = StringTrimmingNone
	;? 1 = StringTrimmingCharacter
	;? 2 = StringTrimmingWord
	;? 3 = StringTrimmingEllipsisCharacter
	;? 4 = StringTrimmingEllipsisWord
	;? 5 = StringTrimmingEllipsisPath

;* Unit enumeration (https://docs.microsoft.com/en-us/windows/win32/api/gdiplusenums/ne-gdiplusenums-unit)
	;? 0 = UnitWorld - World coordinate (non-physical unit).
	;? 1 = UnitDisplay - Variable (only for PageTransform).
	;? 2 = UnitPixel - Each unit is one device pixel.
	;? 3 = UnitPoint - Each unit is a printer's point, or 1/72 inch.
	;? 4 = UnitInch
	;? 5 = UnitDocument - Each unit is 1/300 inch.
*/

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

	;--------------- Canvas -------------------------------------------------------;

	#Include, %A_LineFile%\..\GDIp\Canvas.ahk

	;----------  Imageattributes  --------------------------------------------------;

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
			if (!this.HasKey("Ptr")) {
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

	;--------------- Bitmap -------------------------------------------------------;

	#Include, %A_LineFile%\..\GDIp\Bitmap.ahk

	;-------------- Graphics ------------------------------------------------------;

	#Include, %A_LineFile%\..\GDIp\Graphics.ahk

	;---------------  Brush  -------------------------------------------------------;

	#Include, %A_LineFile%\..\GDIp\Brush.ahk

	;----------------  Pen  --------------------------------------------------------;

	#Include, %A_LineFile%\..\GDIp\Pen.ahk

	;--------------- Matrix -------------------------------------------------------;

	;* GDIp.CreateMatrix()
	CreateMatrix() {
		Local

		if (status := DllCall("Gdiplus\GdipCreateMatrix", "UPtr*", pMatrix, "Int")) {
			throw (Exception(FormatStatus(status)))
		}

		return ({"Ptr": pMatrix
			, "Base": this.__Matrix})
	}

	Class __Matrix {

		__Delete() {
			if (!this.HasKey("Ptr")) {
				MsgBox("Matrix.__Delete()")
			}

			DllCall("Gdiplus\GdipDeleteMatrix", "Ptr", this.Ptr)
		}

		;-------------- Property ------------------------------------------------------;

		IsIdentityMatrix() {
			Local

			if (status := DllCall("Gdiplus\GdipIsMatrixIdentity", "Ptr", this.Ptr, "UInt*", bool := 0, "Int")) {
				throw (Exception(FormatStatus(status)))
			}

			return (bool)
		}

		IsInvertible() {
			Local

			if (status := DllCall("Gdiplus\GdipIsMatrixInvertible", "Ptr", this.Ptr, "UInt*", bool := 0, "Int")) {
				throw (Exception(FormatStatus(status)))
			}

			return (bool)
		}

		;--------------- Method -------------------------------------------------------;

		Clone() {
			Local

			if (status := DllCall("Gdiplus\GdipCloneMatrix", "Ptr", this.Ptr, "Ptr*", pMatrix := 0, "Int")) {
				throw (Exception(FormatStatus(status)))
			}

			return ({"Ptr": pMatrix
				, "Base": this.Base})
		}

		;* matrix.Invert() - If the matrix is invertible, this function replaces its elements  with the elements of its inverse.
		Invert() {
			Local

			if (status := DllCall("Gdiplus\GdipInvertMatrix", "Ptr", this.Ptr, "Int")) {
				throw (Exception(FormatStatus(status)))
			}

			return (True)
		}

		;* matrix.Multiply([__Matrix] matrix[, matrixOrder]) - Updates this matrix with the product of itself and another matrix.
		;* Parameter:
			;* matrixOrder - See MatrixOrder enumeration.
		Multiply(matrix, matrixOrder := 0) {
			Local

			if (status := DllCall("Gdiplus\GdipMultiplyMatrix", "Ptr", this.Ptr, "Ptr", matrix.Ptr, "Int", matrixOrder, "Int")) {
				throw (Exception(FormatStatus(status)))
			}

			return (True)
		}

		;* matrix.Rotate(angle[, matrixOrder]) - Updates this matrix with the product of itself and a rotation matrix.
		;* Parameter:
			;* angle - Simple precision value that specifies the angle of rotation in degrees. Positive values specify clockwise rotation.
			;* matrixOrder - See MatrixOrder enumeration.
		Rotate(angle, matrixOrder := 0) {
			Local

			if (status := DllCall("Gdiplus\GdipRotateMatrix", "Ptr", this.Ptr, "Int", angle, "Int", matrixOrder, "Int")) {
				throw (Exception(FormatStatus(status)))
			}

			return (True)
		}

		;* matrix.Scale(x, y[, matrixOrder]) - Updates this matrix with the product of itself and a scaling matrix.
		;* Parameter:
			;* x - Simple precision value that specifies the horizontal scale factor.
			;* y - Simple precision value that specifies the vertical scale factor.
			;* matrixOrder - See MatrixOrder enumeration.
		Scale(x, y, matrixOrder := 0) {
			Local

			if (status := DllCall("Gdiplus\GdipScaleMatrix", "Ptr", this.Ptr, "Int", x, "Int", y, "Int", matrixOrder, "Int")) {
				throw (Exception(FormatStatus(status)))
			}

			return (True)
		}

		;* matrix.Shear(x, y[, matrixOrder]) - Updates this matrix with the product of itself and a shearing matrix.
		;* Parameter:
			;* x - Simple precision value that specifies the horizontal shear factor.
			;* y - Simple precision value that specifies the vertical shear factor.
			;* matrixOrder - See MatrixOrder enumeration.
		Shear(x, y, matrixOrder := 0) {
			Local

			if (status := DllCall("Gdiplus\GdipShearMatrix", "Ptr", this.Ptr, "Int", x, "Int", y, "Int", matrixOrder, "Int")) {
				throw (Exception(FormatStatus(status)))
			}

			return (True)
		}

		;* matrix.Translate(x, y[, matrixOrder]) - Updates this matrix with the product of itself and a scaling matrix.
		;* Parameter:
			;* x - Single precision value that specifies the horizontal component of the translation.
			;* y - Single precision value that specifies the vertical component of the translation.
			;* matrixOrder - See MatrixOrder enumeration.
		Translate(x, y, matrixOrder := 0) {
			Local

			if (status := DllCall("Gdiplus\GdipTranslateMatrix", "Ptr", this.Ptr, "Int", x, "Int", y, "Int", matrixOrder, "Int")) {
				throw (Exception(FormatStatus(status)))
			}

			return (True)
		}
	}

	;---------------- Path --------------------------------------------------------;

	#Include, %A_LineFile%\..\GDIp\Path.ahk

	;--------------- Region -------------------------------------------------------;

	CreateRegion() {
	}

	Class __Region {

		__Delete() {
			if (!this.HasKey("Ptr")) {
				MsgBox("Region.__Delete()")
			}

			DllCall("Gdiplus\GdipDeleteRegion", "Ptr", this.Ptr)
		}
	}

	;------------- FontFamily -----------------------------------------------------;

	CreateFontFamilyFromName(name := "Fira Code Retina", fontCollection := 0) {
		Local

		if (status := DllCall("Gdiplus\GdipCreateFontFamilyFromName", "Ptr", &name, "Ptr", fontCollection, "Ptr*", pFontFamily := 0, "Int")) {
			throw (Exception(FormatStatus(status)))
		}

		return ({"Ptr": pFontFamily
			, "Base": this.__FontFamily})
	}

	Class __FontFamily {

		__Delete() {
			if (!this.HasKey("Ptr")) {
				MsgBox("FontFamily.__Delete()")
			}

			DllCall("Gdiplus\GdipDeleteFontFamily", "Ptr", this.Ptr)
		}

		;-------------- Property ------------------------------------------------------;

		Name[] {
			Get {
				return (this.GetName())
			}
		}

		GetName() {
			Local

			VarSetCapacity(fontName, 80)

			if (status := DllCall("Gdiplus\GdipGetFamilyName", "Ptr", this.Ptr, "Ptr", &fontName, "Int")) {
				throw (Exception(FormatStatus(status)))
			}

			return (fontName)
		}

		;--------------- Method -------------------------------------------------------;

		Clone() {
			Local

			if (status := DllCall("Gdiplus\GdipCloneFontFamily", "Ptr", this.Ptr, "Ptr*", pFontFamily := 0, "Int")) {
				throw (Exception(FormatStatus(status)))
			}

			return ({"Ptr": pFontFamily
				, "Base": this.Base})
		}
	}

	;---------------- Font --------------------------------------------------------;

	;* GDIp.CreateFont([__FontFamily] fontFamily, size[, style, unit])
	;* Parameter:
		;* style - See FontStyle enumeration.
		;* unit - See Unit enumeration.
	CreateFont(fontFamily, size, style := 0, unit := 2) {
		Local

		if (status := DllCall("Gdiplus\GdipCreateFont", "Ptr", fontFamily.Ptr, "Float", size, "Int", style, "UInt", unit, "Ptr*", pFont := 0, "Int")) {
			throw (Exception(FormatStatus(status)))
		}

		return ({"Ptr": pFont
			, "Base": this.__Font})
	}

	;* GDIp.CreateFontFromDC([__DC] DC)
	CreateFontFromDC(DC) {
		Local

		if (status := DllCall("Gdiplus\GdipCreateFontFromDC", "Ptr", DC.Handle, "Ptr*", pFont := 0, "Int")) {
			throw (Exception(FormatStatus(status)))
		}

		return ({"Ptr": pFont
			, "Base": this.__Font})
	}

	Class __Font {

		__Delete() {
			if (!this.HasKey("Ptr")) {
				MsgBox("Font.__Delete()")
			}

			DllCall("Gdiplus\GdipDeleteFont", "Ptr", this.Ptr)
		}

		;-------------- Property ------------------------------------------------------;

		FontFamily[] {
			Get {
				return (this.GetFontFamily())
			}
		}

		GetFontFamily() {
			Local

			if (status := DllCall("Gdiplus\GdipGetFamily", "Ptr", this.Ptr, "Ptr*", pFontFamily := 0, "Int")) {
				throw (Exception(FormatStatus(status)))
			}

			return ({"Ptr": pFontFamily
				, "Base": GDIp.__FontFamily})
		}

		Size[] {
			Get {
				return (this.GetSize())
			}
		}

		GetSize() {
			Local

			if (status := DllCall("Gdiplus\GdipGetFontSize", "Ptr", this.Ptr, "Float*", size := 0, "Int")) {
				throw (Exception(FormatStatus(status)))
			}

			return (size)
		}

		Style[] {
			Get {
				return (this.GetStyle())
			}
		}

		;* font.GetStyle()
		;* Return:
			;* style - See FontStyle enumeration.
		GetStyle() {
			Local

			if (status := DllCall("Gdiplus\GdipGetFontStyle", "Ptr", this.Ptr, "Int*", style := 0, "Int")) {
				throw (Exception(FormatStatus(status)))
			}

			return (style)
		}

		Unit[] {
			Get {
				return (this.GetUnit())
			}
		}

		;* font.GetUnit()
		;* Return:
			;* unit - See Unit enumeration.
		GetUnit() {
			Local

			if (status := DllCall("Gdiplus\GdipGetFontUnit", "Ptr", this.Ptr, "Int*", unit := 0, "Int")) {
				throw (Exception(FormatStatus(status)))
			}

			return (unit)
		}

		Height[] {
			Get {
				return (this.GetHeight())
			}
		}

		GetHeight(graphics := 0) {
			Local

			if (status := DllCall("Gdiplus\GdipGetFontHeight", "Ptr", this.Ptr, "Ptr", graphics.Ptr, "Float*", height := 0, "Int")) {
				throw (Exception(FormatStatus(status)))
			}

			return (height)
		}

		;--------------- Method -------------------------------------------------------;

		Clone() {
			Local

			if (status := DllCall("Gdiplus\GdipCloneFont", "Ptr", this.Ptr, "Ptr*", pFont := 0, "Int")) {
				throw (Exception(FormatStatus(status)))
			}

			return ({"Ptr": pFont
				, "Base": this.Base})
		}
	}

	;------------ StringFormat ----------------------------------------------------;

	;* GDIp.CreateStringFormat([flags, language])
	;* Parameter:
		;* flags - See StringFormatFlags enumeration.
		;* language - Sixteen-bit value that specifies the language to use.
	CreateStringFormat(flags := 0, language := 0) {
		Local

		if (status := DllCall("Gdiplus\GdipCreateStringFormat", "UInt", flags, "UInt", language, "Ptr*", pStringFormat := 0, "Int")) {
			throw (Exception(FormatStatus(status)))
		}

		return ({"Ptr": pStringFormat
			, "Base": this.__StringFormat})
	}

	Class __StringFormat {

		__Delete() {
			if (!this.HasKey("Ptr")) {
				MsgBox("StringFormat.__Delete()")
			}

			DllCall("Gdiplus\GdipDeleteStringFormat", "Ptr", this.Ptr)
		}

		;-------------- Property ------------------------------------------------------;

		Flags[] {
			Set {
				this.SetFlags(value)

				return (value)
			}
		}

		;* stringFormat.SetFlags(flags)
		;* Parameter:
			;* flags - See StringFormatFlags enumeration.
		SetFlags(flags) {
			Local

			if (status := DllCall("Gdiplus\GdipSetStringFormatFlags", "Ptr", this.Ptr, "Int", flags, "Int")) {
				throw (Exception(FormatStatus(status)))
			}

			return (True)
		}

		Alignment[] {
			Get {
				return (this.GetAlignment())
			}

			Set {
				this.SetAlignment(value)

				return (value)
			}
		}

		;* stringFormat.GetAlignment()
		;* Return:
			;* alignment - See StringAlignment enumeration.
		GetAlignment() {
			Local

			if (status := DllCall("Gdiplus\GdipGetStringFormatAlign", "Ptr", this.Ptr, "Int*", alignment := 0, "Int")) {
				throw (Exception(FormatStatus(status)))
			}

			return (alignment)
		}

		;* stringFormat.SetAlignment(alignment)
		;* Parameter:
			;* alignment - See StringAlignment enumeration.
		SetAlignment(alignment) {
			Local

			if (status := DllCall("Gdiplus\GdipSetStringFormatAlign", "Ptr", this.Ptr, "Int", alignment, "Int")) {
				throw (Exception(FormatStatus(status)))
			}

			return (True)
		}

		LineAlignment[] {
			Get {
				return (this.GetLineAlignment())
			}

			Set {
				this.SetLineAlignment(value)

				return (value)
			}
		}

		;* stringFormat.GetLineAlignment()
		;* Return:
			;* alignment - See StringAlignment enumeration.
		GetLineAlignment() {
			Local

			if (status := DllCall("Gdiplus\GdipGetStringFormatLineAlign", "Ptr", this.Ptr, "Int*", alignment := 0, "Int")) {
				throw (Exception(FormatStatus(status)))
			}

			return (alignment)
		}

		;* stringFormat.SetLineAlignment(alignment)
		;* Parameter:
			;* alignment - See StringAlignment enumeration.
		SetLineAlignment(alignment) {
			Local

			if (status := DllCall("Gdiplus\GdipSetStringFormatLineAlign", "Ptr", this.Ptr, "Int", alignment, "Int")) {
				throw (Exception(FormatStatus(status)))
			}

			return (True)
		}

		DigitSubstitution[] {
			Get {
				return (this.GetDigitSubstitution())
			}

			Set {
				this.SetDigitSubstitution(value)

				return (value)
			}
		}

		;* stringFormat.GetDigitSubstitution()
		;* Return:
			;* substitute - See StringDigitSubstitute enumeration.
		GetDigitSubstitution() {
			Local

			if (status := DllCall("Gdiplus\GdipGetStringFormatDigitSubstitution", "Ptr", this.Ptr, "UShort*", 0, "Int*", substitute := 0, "Int")) {
				throw (Exception(FormatStatus(status)))
			}

			return (substitute)
		}

		;* stringFormat.SetDigitSubstitution(substitute)
		;* Parameter:
			;* substitute - See StringDigitSubstitute enumeration.
		SetDigitSubstitution(substitute, language := 0) {
			Local

			if (status := DllCall("Gdiplus\GdipSetStringFormatDigitSubstitution", "Ptr", this.Ptr, "UShort", language, "Int", substitute, "Int")) {
				throw (Exception(FormatStatus(status)))
			}

			return (True)
		}

		Trimming[] {
			Get {
				return (this.GetTrimming())
			}

			Set {
				this.SetTrimming(value)

				return (value)
			}
		}

		;* stringFormat.GetTrimming()
		;* Return:
			;* trimMode - See StringTrimming enumeration.
		GetTrimming() {
			Local

			if (status := DllCall("Gdiplus\GdipGetStringFormatTrimming", "Ptr", this.Ptr, "Int*", trimMode := 0, "Int")) {
				throw (Exception(FormatStatus(status)))
			}

			return (trimMode)
		}

		;* stringFormat.SetTrimming(trimMode)
		;* Parameter:
			;* trimMode - See StringTrimming enumeration.
		SetTrimming(trimMode) {
			Local

			if (status := DllCall("Gdiplus\GdipSetStringFormatTrimming", "Ptr", this.Ptr, "Int", trimMode, "Int")) {
				throw (Exception(FormatStatus(status)))
			}

			return (True)
		}

		;--------------- Method -------------------------------------------------------;

		Clone() {
			Local

			if (status := DllCall("Gdiplus\GdipCloneStringFormat", "Ptr", this.Ptr, "Ptr*", pStringFormat := 0, "Int")) {
				throw (Exception(FormatStatus(status)))
			}

			return ({"Ptr": pStringFormat
				, "Base": this.Base})
		}
	}
}