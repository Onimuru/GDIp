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
#DllLoad "Gdiplus"

;======================================================  Include  ==============;

#Include %A_LineFile%\..\..\Math\Math.ahk

;===============  Class  =======================================================;

/*
** GDIp_Enums: https://github.com/mono/libgdiplus/blob/main/src/gdipenums.h **

;* enum ColorAdjustType  ;: https://docs.microsoft.com/en-us/windows/win32/api/gdipluscolormatrix/ne-gdipluscolormatrix-coloradjusttype
	0 = ColorAdjustTypeDefault
	1 = ColorAdjustTypeBitmap
	2 = ColorAdjustTypeBrush
	3 = ColorAdjustTypePen
	4 = ColorAdjustTypeText
	5 = ColorAdjustTypeCount
	6 = ColorAdjustTypeAny

;* enum ColorChannelFlags  ;: https://docs.microsoft.com/en-us/windows/win32/api/gdipluscolor/ne-gdipluscolor-colorchannelflags
	0 = ColorChannelFlagsC
	1 = ColorChannelFlagsM
	2 = ColorChannelFlagsY
	3 = ColorChannelFlagsK
	4 = ColorChannelFlagsLast

;* enum ColorMatrixFlags  ;: https://docs.microsoft.com/en-us/windows/win32/api/gdipluscolormatrix/ne-gdipluscolormatrix-colormatrixflags
	0 = ColorMatrixFlagsDefault
	1 = ColorMatrixFlagsSkipGrays
	2 = ColorMatrixFlagsAltGray

;* enum FontStyle  ;: https://docs.microsoft.com/en-us/windows/win32/api/gdiplusenums/ne-gdiplusenums-fontstyle
	0 = FontStyleRegular
	1 = FontStyleBold
	2 = FontStyleItalic
	3 = FontStyleBoldItalic
	4 = FontStyleUnderline
	8 = FontStyleStrikeout

;* enum StringAlignment  ;: https://docs.microsoft.com/en-us/windows/win32/api/gdiplusenums/ne-gdiplusenums-stringalignment
	0 = StringAlignmentNear - Left/Top.
	1 = StringAlignmentCenter
	2 = StringAlignmentFar - Right/Bottom.

;* enum StringDigitSubstitute  ;: https://docs.microsoft.com/en-us/windows/win32/api/gdiplusenums/ne-gdiplusenums-stringdigitsubstitute
	0 = StringDigitSubstituteUser
	1 = StringDigitSubstituteNone
	2 = StringDigitSubstituteNational
	3 = StringDigitSubstituteTraditional

;* enum StringFormatFlags  ;: https://docs.microsoft.com/en-us/windows/win32/api/gdiplusenums/ne-gdiplusenums-stringformatflags
	0x00000001 = StringFormatFlagsDirectionRightToLeft
	0x00000002 = StringFormatFlagsDirectionVertical
	0x00000004 = StringFormatFlagsNoFitBlackBox - Parts of characters are allowed to overhang the string's layout rectangle.
	0x00000020 = StringFormatFlagsDisplayFormatControl - Unicode layout control characters are displayed with a representative character.
	0x00000400 = StringFormatFlagsNoFontFallback - Prevent using an alternate font  for characters that are not supported in the requested font.
	0x00000800 = StringFormatFlagsMeasureTrailingSpaces - The spaces at the end of each line are included in a string measurement.
	0x00001000 = StringFormatFlagsNoWrap - Disable text wrapping.
	0x00002000 = StringFormatFlagsLineLimit - Only entire lines are laid out in the layout rectangle.
	0x00004000 = StringFormatFlagsNoClip - Characters overhanging the layout rectangle and text extending outside the layout rectangle are allowed to show.

;* enum StringTrimming  ;: https://docs.microsoft.com/en-us/windows/win32/api/gdiplusenums/ne-gdiplusenums-stringtrimming
	0 = StringTrimmingNone
	1 = StringTrimmingCharacter
	2 = StringTrimmingWord
	3 = StringTrimmingEllipsisCharacter
	4 = StringTrimmingEllipsisWord
	5 = StringTrimmingEllipsisPath

;* enum Unit  ;: https://docs.microsoft.com/en-us/windows/win32/api/gdiplusenums/ne-gdiplusenums-unit
	0 = UnitWorld - World coordinate (non-physical unit).
	1 = UnitDisplay - Variable (only for PageTransform).
	2 = UnitPixel - Each unit is one device pixel.
	3 = UnitPoint - Each unit is a printer's point, or 1/72 inch.
	4 = UnitInch
	5 = UnitDocument - Each unit is 1/300 inch.

;* enum WrapMode  ;: https://docs.microsoft.com/en-us/windows/win32/api/gdiplusenums/ne-gdiplusenums-wrapmode
	0 = WrapModeTile - Tiling without flipping.
	1 = WrapModeTileFlipX - Tiles are flipped horizontally as you move from one tile to the next in a row.
	2 = WrapModeTileFlipY - Tiles are flipped vertically as you move from one tile to the next in a column.
	3 = WrapModeTileFlipXY - Tiles are flipped horizontally as you move along a row and flipped vertically as you move along a column.
	4 = WrapModeClamp - No tiling takes place.
*/

class GDIp {

	__New(params*) {
        throw (Error("This class must not be constructed.", -1))
	}

	;--------------- Method -------------------------------------------------------;

	;* GDIp.Startup()
	static Startup() {
		if (this.HasProp("Token")) {
			return (False)
		}

		static input := Structure.CreateGDIplusStartupInput()

		if (status := DllCall("Gdiplus\GdiplusStartup", "Ptr*", &(pToken := 0), "Ptr", input.Ptr, "Ptr", 0, "Int")) {  ;: https://docs.microsoft.com/en-us/windows/win32/api/gdiplusinit/nf-gdiplusinit-gdiplusstartup
			throw (ErrorFromStatus(status))
		}

		return (!!(this.Token := pToken))
	}

	;* GDIp.Shutdown()
	static Shutdown() {
		if (this.HasProp("Token")) {
			if (status := DllCall("Gdiplus\GdiplusShutdown", "Ptr", this.DeleteProp("Token"))) {
				throw (ErrorFromStatus(status))
			}

			return (True)
		}

		return (False)
	}

	;---------------  Class  -------------------------------------------------------;
	;--------------------------------------------------  ImageAttributes  ----------;

	;* GDIp.CreateImageAttributes()
	;* Return:
		;* [ImageAttributes]
	static CreateImageAttributes() {
		if (status := DllCall("Gdiplus\GdipCreateImageAttributes", "Ptr*", &(pImageAttributes := 0), "Int")) {
			throw (ErrorFromStatus(status))
		}

		return (this.ImageAttributes(pImageAttributes))
	}

	class ImageAttributes {
		Class := "ImageAttributes"

		__New(pImageAttributes) {
			this.Ptr := pImageAttributes
		}

		;* imageAttributes.Clone()
		;* Return:
			;* [ImageAttributes]
		Clone() {
			if (status := DllCall("Gdiplus\GdipCloneImageAttributes", "Ptr", this.Ptr, "Ptr*", &(pImageAttributes := 0), "Int")) {
				throw (ErrorFromStatus(status))
			}

			return (GDIp.ImageAttributes(pImageAttributes))
		}

		__Delete() {
			if (status := DllCall("Gdiplus\GdipDisposeImageAttributes", "Ptr", this.Ptr, "Int")) {
				throw (ErrorFromStatus(status))
			}
		}

		;--------------- Method -------------------------------------------------------;

		;* imageAttributes.SetAdjustType(adjustType, enableFlag)
		;* Description:
			;* Enables or disables color adjustment for a specified category.
		;* Parameter:
			;* [Integer] adjustType - See ColorAdjustType enumeration.
			;* [Integer] enableFlag - Boolean value that specifies whether a color adjustment is enabled for the category specified by `adjustType`.
		SetAdjustType(adjustType, enableFlag) {
			if (status := DllCall("Gdiplus\GdipSetImageAttributesNoOp", "Ptr", this.Ptr, "Int", adjustType, "UInt", enableFlag, "Int")) {
				throw (ErrorFromStatus(status))
			}
		}

		;* imageAttributes.SetColorKeys(colorLow, colorHigh[, adjustType, enableFlag])
		;* Description:
			;* Sets the color key (transparency range) for a specified category.
		;* Parameter:
			;* [Integer] colorLow - Color that specifies the low color-key value.
			;* [Integer] colorHigh - Color that specifies the high color-key value.
			;* [Integer] adjustType - See ColorAdjustType enumeration.
			;* [Integer] enableFlag - Boolean value that specifies whether a separate transparency range is enabled for the category specified by `adjustType`.
		SetColorKeys(colorLow, colorHigh, adjustType := 0, enableFlag := True) {
			if (status := DllCall("Gdiplus\GdipSetImageAttributesColorKeys", "Ptr", this.Ptr, "Int", adjustType, "UInt", enableFlag, "UInt", colorLow, "UInt", colorHigh, "Int")) {
				throw (ErrorFromStatus(status))
			}
		}

		;* imageAttributes.SetColorMatrix(colorMatrix[, adjustType, enableFlag, flags, grayMatrix])
		;* Description:
			;* Sets the color-adjustment matrix for a specified category.
		;* Parameter:
			;* [Structure] colorMatrix - A 5x5 color-adjustment matrix structure.
			;* [Integer] adjustType - See ColorAdjustType enumeration.
			;* [Integer] enableFlag - Boolean value that specifies whether a separate color adjustment is enabled for the category specified by `adjustType`.
			;* [Integer] flags - See ColorMatrixFlags enumeration.
			;* [Structure] grayMatrix - A 5x5 color-adjustment matrix structure used for adjusting gray shades when the value of `flags` is `ColorMatrixFlagsAltGray`.
		SetColorMatrix(colorMatrix, adjustType := 0, enableFlag := True, flags := 0, grayMatrix := 0) {
			if (status := DllCall("Gdiplus\GdipSetImageAttributesColorMatrix", "Ptr", this.Ptr, "Int", adjustType, "UInt", enableFlag, "Ptr", colorMatrix.Ptr, "Ptr", grayMatrix, "Int", flags, "Int")) {
				throw (ErrorFromStatus(status))
			}
		}

		;* imageAttributes.SetGamma(gamma[, adjustType, enableFlag])
		;* Description:
			;* Sets the gamma value for a specified category.
		;* Parameter:
			;* [Float] gamma
			;* [Integer] adjustType - See ColorAdjustType enumeration.
			;* [Integer] enableFlag - Boolean value that specifies whether a separate gamma is enabled for the category specified by `adjustType`.
		SetGamma(gamma, adjustType := 0, enableFlag := True) {
			if (status := DllCall("Gdiplus\GdipSetImageAttributesGamma", "Ptr", this.Ptr, "Int", adjustType, "UInt", enableFlag, "Float", gamma, "Int")) {
				throw (ErrorFromStatus(status))
			}
		}

		;* imageAttributes.SetICMMode(bool)
		;* Parameter:
			;* [Integer] bool
		SetICMMode(bool) {
			if (status := DllCall("Gdiplus\GdipSetImageAttributesICMMode", "Ptr", this.Ptr, "UInt", bool, "Int")) {
				throw (ErrorFromStatus(status))
			}
		}

		;* imageAttributes.SetOutputChannel(channelFlags[, adjustType, enableFlag])
		;* Description:
			;* Sets the CMYK output channel for a specified category.
		;* Parameter:
			;* [Integer] channelFlags - See ColorChannelFlags enumeration.
			;* [Integer] adjustType - See ColorAdjustType enumeration.
			;* [Integer] enableFlag - Boolean value that specifies whether a separate output channel is enabled for the category specified by `adjustType`.
		SetOutputChannel(channelFlags, adjustType := 0, enableFlag := True) {
			if (status := DllCall("Gdiplus\GdipSetImageAttributesOutputChannel", "Ptr", this.Ptr, "Int", adjustType, "UInt", enableFlag, "Int", channelFlags, "Int")) {
				throw (ErrorFromStatus(status))
			}
		}

		;* imageAttributes.SetThreshold(threshold[, adjustType, enableFlag])
		;* Description:
			;* Sets the threshold (transparency range) for a specified category.
		;* Parameter:
			;* [Float] threshold
			;* [Integer] adjustType - See ColorAdjustType enumeration.
			;* [Integer] enableFlag - Boolean value that specifies whether a separate threshold is enabled for the category specified by `adjustType`.
		SetThreshold(threshold, adjustType := 0, enableFlag := True) {
			if (status := DllCall("Gdiplus\GdipSetImageAttributesThreshold", "Ptr", this.Ptr, "Int", adjustType, "UInt", enableFlag, "Float", threshold, "Int")) {
				throw (ErrorFromStatus(status))
			}
		}

		;* imageAttributes.SetWrapMode(wrapMode, color)
		;* Description:
			;* Sets the wrap mode of this ImageAttributes object.
		;* Parameter:
			;* [Integer] wrapMode - See WrapMode enumeration.
			;* [Integer] color
		SetWrapMode(wrapMode, color) {
			if (status := DllCall("Gdiplus\GdipSetImageAttributesWrapMode", "Ptr", this.Ptr, "Int", wrapMode, "UInt", color, "UInt", 0, "Int")) {
				throw (ErrorFromStatus(status))
			}
		}

		;* imageAttributes.Reset(adjustType)
		;* Parameter:
			;* [Integer] adjustType - See ColorAdjustType enumeration.
		Reset(adjustType) {
			if (status := DllCall("Gdiplus\GdipResetImageAttributes", "Ptr", this.Ptr, "Int", adjustType, "Int")) {
				throw (ErrorFromStatus(status))
			}
		}

		;* imageAttributes.ResetColorMatrix(adjustType)
		;* Description:
			;* Sets the color-adjustment matrix of a specified category to identity matrix.
		;* Parameter:
			;* [Integer] adjustType - See ColorAdjustType enumeration.
		ResetColorMatrix(adjustType) {
			if (status := DllCall("Gdiplus\GdipSetImageAttributesToIdentity", "Ptr", this.Ptr, "Int", adjustType, "Int")) {
				throw (ErrorFromStatus(status))
			}
		}
	}

	;------------------------------------------------------- Effect ---------------;

	;~ CreateEffect
	;~ DeleteEffect
	;~ GetEffectParameters
	;~ GetEffectParameterSize
	;~ SetEffectParameters

	;------------------------------------------------------- Bitmap ---------------;

	#Include %A_LineFile%\..\GDIp\Bitmap.ahk

	;------------------------------------------------------ Graphics --------------;

	#Include %A_LineFile%\..\GDIp\Graphics.ahk

	;-------------------------------------------------------  Brush  ---------------;

	#Include %A_LineFile%\..\GDIp\Brush.ahk

	;--------------------------------------------------------  Pen  ----------------;

	#Include %A_LineFile%\..\GDIp\Pen.ahk

	;------------------------------------------------------- Matrix ---------------;

	#Include %A_LineFile%\..\GDIp\Matrix.ahk

	;-------------------------------------------------------- Path ----------------;

	#Include %A_LineFile%\..\GDIp\Path.ahk

	;------------------------------------------------------- Region ---------------;

	;* GDIp.CreateRegion()
	;* Return:
		;* [Region]
	static CreateRegion() {
		if (status := DllCall("Gdiplus\GdipCreateRegion", "Ptr*", &(pRegion := 0), "Int")) {
			throw (ErrorFromStatus(status))
		}

		return (this.Region(pRegion))
	}

	class Region {
		Class := "Region"

		__New(pRegion) {
			this.Ptr := pRegion
		}

		;* region.Clone()
		;* Return:
			;* [Region]
		Clone() {
			if (status := DllCall("Gdiplus\GdipCloneRegion", "Ptr", this.Ptr, "Ptr*", &(pRegion := 0), "Int")) {
				throw (ErrorFromStatus(status))
			}

			return (GDIp.Region(pRegion))
		}

		__Delete() {
			if (status := DllCall("Gdiplus\GdipDeleteRegion", "Ptr", this.Ptr, "Int")) {
				throw (ErrorFromStatus(status))
			}
		}

		;-------------- Property ------------------------------------------------------;

		;* region.IsEmpty(graphics)
		;* Parameter:
			;* [Graphics] graphics
		;* Return:
			;* [Integer]
		IsEmpty(graphics) {
			if (status := DllCall("Gdiplus\GdipIsEmptyRegion", "Ptr", this.Ptr, "Ptr", graphics, "UInt*", &(bool := False), "Int")) {
				throw (ErrorFromStatus(status))
			}

			return (bool)
		}

		;--------------- Method -------------------------------------------------------;

		;* region.Translate(x, y)
		;* Parameter:
			;* [Float] x
			;* [Float] y
		Translate(x, y) {
			if (status := DllCall("Gdiplus\GdipTranslateRegion", "Ptr", this.Ptr, "Float", x, "Float", y, "Int")) {
				throw (ErrorFromStatus(status))
			}
		}

		;* region.Transform(matrix)
		;* Parameter:
			;* [Matrix] matrix
		Transform(matrix) {
			if (status := DllCall("Gdiplus\GdipTransformRegion", "Ptr", this.Ptr, "Ptr", matrix, "Int")) {
				throw (ErrorFromStatus(status))
			}
		}
	}

	;----------------------------------------------------- FontFamily -------------;  ;~ A font family is a group of fonts that have the same typeface but different styles.

	;* GDIp.CreateFontFamilyFromName([name, fontCollection])
	;* Parameter:
		;* [String] name
		;* [FontCollection] fontCollection
	;* Return:
		;* [FontFamily]
	static CreateFontFamilyFromName(name := "Fira Code Retina", fontCollection := 0) {
		if (status := DllCall("Gdiplus\GdipCreateFontFamilyFromName", "Ptr", StrPtr(name), "Ptr", fontCollection, "Ptr*", &(pFontFamily := 0), "Int")) {
			throw (ErrorFromStatus(status))
		}

		return (this.FontFamily(pFontFamily))
	}

	class FontFamily {
		Class := "FontFamily"

		__New(pFontFamily) {
			this.Ptr := pFontFamily
		}

		;* fontFamily.Clone()
		;* Return:
			;* [FontFamily]
		Clone() {
			if (status := DllCall("Gdiplus\GdipCloneFontFamily", "Ptr", this.Ptr, "Ptr*", &(pFontFamily := 0), "Int")) {
				throw (ErrorFromStatus(status))
			}

			return (GDIp.FontFamily(pFontFamily))
		}

		__Delete() {
			if (status := DllCall("Gdiplus\GdipDeleteFontFamily", "Ptr", this.Ptr, "Int")) {
				throw (ErrorFromStatus(status))
			}
		}

		;-------------- Property ------------------------------------------------------;

		Name {
			Get {
				return (this.GetName())
			}
		}

		;* fontFamily.GetName()
		;* Parameter:
			;* [Integer] language - See https://robotics.ee.uwa.edu.au/courses/robotics/project/festo/(D)%20FST4.21-110802/SDK/Localization/LANGID.H.
		;* Return:
			;* [String] - The name of this font family.
		GetName(language := 0x00) {
			if (status := DllCall("Gdiplus\GdipGetFamilyName", "Ptr", this.Ptr, "Ptr", (name := Structure(64)).Ptr, "UShort", language, "Int")) {  ;? LF_FACESIZE = 32
				throw (ErrorFromStatus(status))
			}

			return (name.StrGet())
		}
	}

	;-------------------------------------------------------- Font ----------------;

	;* GDIp.CreateFont(fontFamily, size[, style, unit])
	;* Parameter:
		;* [FontFamily] fontFamily
		;* [Float] size
		;* [Integer] style - See FontStyle enumeration.
		;* [Integer] unit - See Unit enumeration.
	;* Return:
		;* [Font]
	static CreateFont(fontFamily, size, style := 0, unit := 2) {
		if (status := DllCall("Gdiplus\GdipCreateFont", "Ptr", fontFamily.Ptr, "Float", size, "Int", style, "UInt", unit, "Ptr*", &(pFont := 0), "Int")) {
			throw (ErrorFromStatus(status))
		}

		return (this.Font(pFont))
	}

	;* GDIp.CreateFontFromDC(DC)
	;* Parameter:
		;* [DC] DC
	;* Return:
		;* [Font]
	static CreateFontFromDC(DC) {
		if (status := DllCall("Gdiplus\GdipCreateFontFromDC", "Ptr", DC.Handle, "Ptr*", &(pFont := 0), "Int")) {
			throw (ErrorFromStatus(status))
		}

		return (this.Font(pFont))
	}

	class Font {
		Class := "Font"

		__New(pFont) {
			this.Ptr := pFont
		}

		;* font.Clone()
		;* Return:
			;* [Font]
		Clone() {
			if (status := DllCall("Gdiplus\GdipCloneFont", "Ptr", this.Ptr, "Ptr*", &(pFont := 0), "Int")) {
				throw (ErrorFromStatus(status))
			}

			return (GDIp.Font(pFont))
		}

		__Delete() {
			if (status := DllCall("Gdiplus\GdipDeleteFont", "Ptr", this.Ptr, "Int")) {
				throw (ErrorFromStatus(status))
			}
		}

		;-------------- Property ------------------------------------------------------;

		FontFamily {
			Get {
				return (this.GetFontFamily())
			}
		}

		;* font.GetFontFamily()
		;* Return:
			;* [FontFamily]
		GetFontFamily() {
			if (status := DllCall("Gdiplus\GdipGetFamily", "Ptr", this.Ptr, "Ptr*", &(pFontFamily := 0), "Int")) {
				throw (ErrorFromStatus(status))
			}

			return (GDIp.FontFamily(pFontFamily))
		}

		Size {
			Get {
				return (this.GetSize())
			}
		}

		;* font.GetSize()
		;* Return:
			;* [Float]
		GetSize() {
			if (status := DllCall("Gdiplus\GdipGetFontSize", "Ptr", this.Ptr, "Float*", &(size := 0), "Int")) {
				throw (ErrorFromStatus(status))
			}

			return (size)
		}

		Style {
			Get {
				return (this.GetStyle())
			}
		}

		;* font.GetStyle()
		;* Return:
			;* [Integer] - See FontStyle enumeration.
		GetStyle() {
			if (status := DllCall("Gdiplus\GdipGetFontStyle", "Ptr", this.Ptr, "Int*", &(style := 0), "Int")) {
				throw (ErrorFromStatus(status))
			}

			return (style)
		}

		Unit {
			Get {
				return (this.GetUnit())
			}
		}

		;* font.GetUnit()
		;* Return:
			;* [Integer] - See Unit enumeration.
		GetUnit() {
			if (status := DllCall("Gdiplus\GdipGetFontUnit", "Ptr", this.Ptr, "Int*", &(unit := 0), "Int")) {
				throw (ErrorFromStatus(status))
			}

			return (unit)
		}

		Height {
			Get {
				return (this.GetHeight())
			}
		}

		;* font.GetHeight([graphics])
		;* Parameter:
			;* [Graphics] graphics - A Graphics object whose unit and vertical resolution are used in the height calculation.
		;* Return:
			;* [Float]
		GetHeight(graphics := 0) {
			if (status := DllCall("Gdiplus\GdipGetFontHeight", "Ptr", this.Ptr, "Ptr", graphics, "Float*", &(height := 0), "Int")) {
				throw (ErrorFromStatus(status))
			}

			return (height)
		}
	}

	;---------------------------------------------------- StringFormat ------------;

	;* GDIp.CreateStringFormat([flags, language])
	;* Parameter:
		;* [Integer] flags - See StringFormatFlags enumeration.
		;* [Integer] language - Sixteen-bit value that specifies the language to use.
	;* Return:
		;* [StringFormat]
	static CreateStringFormat(flags := 0, language := 0) {
		if (status := DllCall("Gdiplus\GdipCreateStringFormat", "UInt", flags, "UInt", language, "Ptr*", &(pStringFormat := 0), "Int")) {
			throw (ErrorFromStatus(status))
		}

		return (this.StringFormat(pStringFormat))
	}

	class StringFormat {
		Class := "StringFormat"

		__New(pStringFormat) {
			this.Ptr := pStringFormat
		}

		;* stringFormat.Clone()
		;* Return:
			;* [StringFormat]
		Clone() {
			if (status := DllCall("Gdiplus\GdipCloneStringFormat", "Ptr", this.Ptr, "Ptr*", &(pStringFormat := 0), "Int")) {
				throw (ErrorFromStatus(status))
			}

			return (GDIp.StringFormat(pStringFormat))
		}

		__Delete() {
			if (status := DllCall("Gdiplus\GdipDeleteStringFormat", "Ptr", this.Ptr, "Int")) {
				throw (ErrorFromStatus(status))
			}
		}

		;-------------- Property ------------------------------------------------------;

		Flags {
			Get {
				return (this.GetFlags())
			}

			Set {
				this.SetFlags(value)

				return (value)
			}
		}

		;* stringFormat.GetFlags()
		;* Return:
			;* [Integer] - See StringFormatFlags enumeration.
		GetFlags() {
			if (status := DllCall("gdiplus\GdipGetStringFormatFlags", "UPtr", this.Ptr, "Int*", &(flags := 0), "Int")) {
				throw (ErrorFromStatus(status))
			}

			return (flags)
		}

		;* stringFormat.SetFlags(flags)
		;* Parameter:
			;* [Integer] flags - See StringFormatFlags enumeration.
		SetFlags(flags) {
			if (status := DllCall("Gdiplus\GdipSetStringFormatFlags", "Ptr", this.Ptr, "Int", flags, "Int")) {
				throw (ErrorFromStatus(status))
			}
		}

		Alignment {
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
			;* [Integer] - See StringAlignment enumeration.
		GetAlignment() {
			if (status := DllCall("Gdiplus\GdipGetStringFormatAlign", "Ptr", this.Ptr, "Int*", &(alignment := 0), "Int")) {
				throw (ErrorFromStatus(status))
			}

			return (alignment)
		}

		;* stringFormat.SetAlignment(alignment)
		;* Parameter:
			;* [Integer] alignment - See StringAlignment enumeration.
		SetAlignment(alignment) {
			if (status := DllCall("Gdiplus\GdipSetStringFormatAlign", "Ptr", this.Ptr, "Int", alignment, "Int")) {
				throw (ErrorFromStatus(status))
			}
		}

		DigitSubstitution {
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
			;* [Integer] - See StringDigitSubstitute enumeration.
		GetDigitSubstitution() {
			if (status := DllCall("Gdiplus\GdipGetStringFormatDigitSubstitution", "Ptr", this.Ptr, "UShort*", 0, "Int*", &(substitute := 0), "Int")) {
				throw (ErrorFromStatus(status))
			}

			return (substitute)
		}

		;* stringFormat.SetDigitSubstitution(substitute[, language])
		;* Parameter:
			;* [Integer] substitute - See StringDigitSubstitute enumeration.
			;* [Integer] language - Sixteen-bit value that specifies the language to use.
		SetDigitSubstitution(substitute, language := 0) {
			if (status := DllCall("Gdiplus\GdipSetStringFormatDigitSubstitution", "Ptr", this.Ptr, "UShort", language, "Int", substitute, "Int")) {
				throw (ErrorFromStatus(status))
			}
		}

		LineAlignment {
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
			;* [Integer] - See StringAlignment enumeration.
		GetLineAlignment() {
			if (status := DllCall("Gdiplus\GdipGetStringFormatLineAlign", "Ptr", this.Ptr, "Int*", &(alignment := 0), "Int")) {
				throw (ErrorFromStatus(status))
			}

			return (alignment)
		}

		;* stringFormat.SetLineAlignment(alignment)
		;* Parameter:
			;* [Integer] alignment - See StringAlignment enumeration.
		SetLineAlignment(alignment) {
			if (status := DllCall("Gdiplus\GdipSetStringFormatLineAlign", "Ptr", this.Ptr, "Int", alignment, "Int")) {
				throw (ErrorFromStatus(status))
			}
		}

		Trimming {
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
			;* [Integer] - See StringTrimming enumeration.
		GetTrimming() {
			if (status := DllCall("Gdiplus\GdipGetStringFormatTrimming", "Ptr", this.Ptr, "Int*", &(trimming := 0), "Int")) {
				throw (ErrorFromStatus(status))
			}

			return (trimming)
		}

		;* stringFormat.SetTrimming(trimming)
		;* Parameter:
			;* [Integer] trimming - See StringTrimming enumeration.
		SetTrimming(trimming) {
			if (status := DllCall("Gdiplus\GdipSetStringFormatTrimming", "Ptr", this.Ptr, "Int", trimming, "Int")) {
				throw (ErrorFromStatus(status))
			}
		}
	}
}