;============ Auto-execute ====================================================;
;======================================================  Setting  ==============;

#Requires AutoHotkey v2.0-a134-d3d43350
#DllLoad "Gdiplus"

;======================================================  Include  ==============;

#Include %A_LineFile%\..\..\Math\Math.ahk

;============== Function ======================================================;

;GetRotatedTranslation(width, height, angle, ByRef xTranslation, ByRef yTranslation) {
;	angle := (angle >= 0) ? (Mod(angle, 360)) : (360 - Mod(-angle, -360))
;
;	if ((angle >= 0) && (angle <= 90)) {
;		xTranslation := height*Sin(Math.ToRadians(angle)), yTranslation := 0
;	}
;	else if ((angle > 90) && (angle <= 180)) {
;		radians := Math.ToRadians(angle), cos := Cos(radians)
;			, xTranslation := (height*Sin(radians)) - (width*cos), yTranslation := -height*cos
;	}
;	else if ((angle > 180) && (angle <= 270)) {
;		radians := Math.ToRadians(angle), cos := Cos(radians)
;			, xTranslation := -(width*cos), yTranslation := -(height*cos) - (width*Sin(radians))
;	}
;	else if ((angle > 270) && (angle <= 360)) {
;		xTranslation := 0, yTranslation := -width*Sin(Math.ToRadians(angle))
;	}
;}
;
;GetRotatedDimensions(width, height, angle, ByRef rotatedWidth, ByRef rotatedHeight) {
;	angle := (angle >= 0) ? (Mod(angle, 360)) : (360 - Mod(-angle, -360))
;		, radians := Math.ToRadians(angle)
;
;	sin := Sin(radians), cos := Cos(radians)
;		, rotatedWidth := Abs(width*cos) + Abs(height*sin), rotatedHeight := Abs(width*sin) + Abs(height*cos)
;}

;===============  Class  =======================================================;

/*
** GDIp_Enums: https://github.com/mono/libgdiplus/blob/main/src/gdipenums.h **

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

		(instance := this.ImageAttributes()).Ptr := pImageAttributes
		return (instance)
	}

	class ImageAttributes {
		Class := "ImageAttributes"

		;* imageAttributes.Clone()
		;* Return:
			;* [ImageAttributes]
		Clone() {
			if (status := DllCall("Gdiplus\GdipCloneImageAttributes", "Ptr", this.Ptr, "Ptr*", &(pImageAttributes := 0), "Int")) {
				throw (ErrorFromStatus(status))
			}

			(instance := GDIp.ImageAttributes()).Ptr := pImageAttributes
			return (instance)
		}

		__Delete() {
			if (status := DllCall("Gdiplus\GdipDisposeImageAttributes", "Ptr", this.Ptr, "Int")) {
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

		(instance := this.Region()).Ptr := pRegion
		return (instance)
	}

	class Region {
		Class := "Region"

		;* region.Clone()
		;* Return:
			;* [Region]
		Clone() {
			if (status := DllCall("Gdiplus\GdipCloneRegion", "Ptr", this.Ptr, "Ptr*", &(pRegion := 0), "Int")) {
				throw (ErrorFromStatus(status))
			}

			(instance := GDIp.Region()).Ptr := pRegion
			return (instance)
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
			if (status := DllCall("Gdiplus\GdipIsEmptyRegion", "Ptr", this.Ptr, "Ptr", graphics.Ptr, "UInt*", &(bool := False), "Int")) {
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
			if (status := DllCall("Gdiplus\GdipTransformRegion", "Ptr", this.Ptr, "Ptr", matrix.Ptr, "Int")) {
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

		(instance := this.FontFamily()).Ptr := pFontFamily
		return (instance)
	}

	class FontFamily {
		Class := "FontFamily"

		;* fontFamily.Clone()
		;* Return:
			;* [FontFamily]
		Clone() {
			if (status := DllCall("Gdiplus\GdipCloneFontFamily", "Ptr", this.Ptr, "Ptr*", &(pFontFamily := 0), "Int")) {
				throw (ErrorFromStatus(status))
			}

			(instance := GDIp.FontFamily()).Ptr := pFontFamily
			return (instance)
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

		(instance := this.Font()).Ptr := pFont
		return (instance)
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

		(instance := this.Font()).Ptr := pFont
		return (instance)
	}

	class Font {
		Class := "Font"

		;* font.Clone()
		;* Return:
			;* [Font]
		Clone() {
			if (status := DllCall("Gdiplus\GdipCloneFont", "Ptr", this.Ptr, "Ptr*", &(pFont := 0), "Int")) {
				throw (ErrorFromStatus(status))
			}

			(instance := GDIp.Font()).Ptr := pFont
			return (instance)
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

			(instance := GDIp.FontFamily()).Ptr := pFontFamily
			return (instance)
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

		(instance := this.StringFormat()).Ptr := pStringFormat
		return (instance)
	}

	class StringFormat {
		Class := "StringFormat"

		;* stringFormat.Clone()
		;* Return:
			;* [StringFormat]
		Clone() {
			if (status := DllCall("Gdiplus\GdipCloneStringFormat", "Ptr", this.Ptr, "Ptr*", &(pStringFormat := 0), "Int")) {
				throw (ErrorFromStatus(status))
			}

			(instance := GDIp.StringFormat()).Ptr := pStringFormat
			return (instance)
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
			if (status := DllCall("Gdiplus\GdipGetStringFormatTrimming", "Ptr", this.Ptr, "Int*", &(trimMode := 0), "Int")) {
				throw (ErrorFromStatus(status))
			}

			return (trimMode)
		}

		;* stringFormat.SetTrimming(trimMode)
		;* Parameter:
			;* [Integer] trimMode - See StringTrimming enumeration.
		SetTrimming(trimMode) {
			if (status := DllCall("Gdiplus\GdipSetStringFormatTrimming", "Ptr", this.Ptr, "Int", trimMode, "Int")) {
				throw (ErrorFromStatus(status))
			}
		}
	}
}