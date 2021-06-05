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

;* enum CombineMode  ;: https://docs.microsoft.com/en-us/windows/win32/api/gdiplusenums/ne-gdiplusenums-combinemode
	0 = CombineModeReplace
	1 = CombineModeIntersect
	2 = CombineModeUnion
	3 = CombineModeXor
	4 = CombineModeExclude
	5 = CombineModeComplement

;* enum CurveAdjustments  ;: https://docs.microsoft.com/en-us/windows/win32/api/gdipluseffects/ne-gdipluseffects-curveadjustments
	0 = AdjustExposure
	1 = AdjustDensity
	2 = AdjustContrast
	3 = AdjustHighlight
	4 = AdjustShadow
	5 = AdjustMidtone
	6 = AdjustWhiteSaturation
	7 = AdjustBlackSaturation

;* enum CurveChannel  ;: https://docs.microsoft.com/en-us/windows/win32/api/gdipluseffects/ne-gdipluseffects-curvechannel
	0 = CurveChannelAll
	1 = CurveChannelRed
	2 = CurveChannelGreen
	3 = CurveChannelBlue

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
	;------------------------------------------------------- Effect ---------------;

	;* GDIp.CreateBlurEffect(radius, expandEdge)
	;* Parameter:
		;* [Float] radius - Real number that specifies the blur radius (the radius of the Gaussian convolution kernel) in pixels. The radius must be in the range 0 through 255. As the radius increases, the resulting bitmap becomes more blurry.
		;* [Integer] expandEdge - Boolean value that specifies whether the bitmap expands by an amount equal to the blur radius. If TRUE, the bitmap expands by an amount equal to the radius so that it can have soft edges. If FALSE, the bitmap remains the same size and the soft edges are clipped.
	;* Return:
		;* [Effect]
	static CreateBlurEffect(radius, expandEdge) {
		static GUID := CLSIDFromString("{633C80A4-1843-482B-9EF2-BE2834C5FDD4}")  ;? {0x633C80A4, 0x1843, 0x482B, {0x9E, 0xF2, 0xBE, 0x28, 0x34, 0xC5, 0xFD, 0xD4}}

		if (status := DllCall("Gdiplus\GdipCreateEffect", "Ptr", GUID, "Ptr*", &(pEffect := 0), "Int")) {
			throw (ErrorFromStatus(status))
		}

		(params := Structure(8)).NumPut(0, "Float", radius, "UInt", expandEdge)  ;: https://docs.microsoft.com/en-us/windows/win32/api/gdipluseffects/ns-gdipluseffects-blurparams

		if (status := DllCall("Gdiplus\GdipSetEffectParameters", "Ptr", pEffect, "Ptr", params, "UInt", 8, "Int")) {
			throw (ErrorFromStatus(status))
		}

		return (this.Effect(pEffect))
	}

	;* GDIp.CreateSharpenEffect(radius, amount)
	;* Parameter:
		;* [Float] radius - Specifies the sharpening radius (the radius of the convolution kernel) in pixels. The radius must be in the range 0 through 255. As the radius increases, more surrounding pixels are involved in calculating the new value of a given pixel.
		;* [Float] amount - Real number in the range 0 through 100 that specifies the amount of sharpening to be applied. A value of 0 specifies no sharpening. As the value of amount increases, the sharpness increases.
	;* Return:
		;* [Effect]
	static CreateSharpenEffect(radius, amount) {
		static GUID := CLSIDFromString("{63CBF3EE-C526-402C-8F71-62C540BF5142}")  ;? {0x63CBF3EE, 0xC526, 0x402C, {0x8F, 0x71, 0x62, 0xC5, 0x40, 0xBF, 0x51, 0x42}}

		if (status := DllCall("Gdiplus\GdipCreateEffect", "Ptr", GUID, "Ptr*", &(pEffect := 0), "Int")) {
			throw (ErrorFromStatus(status))
		}

		(params := Structure(8)).NumPut(0, "Float", radius, "Float", amount)  ;: https://docs.microsoft.com/en-us/windows/win32/api/gdipluseffects/ns-gdipluseffects-sharpenparams

		if (status := DllCall("Gdiplus\GdipSetEffectParameters", "Ptr", pEffect, "Ptr", params, "UInt", 8, "Int")) {
			throw (ErrorFromStatus(status))
		}

		return (this.Effect(pEffect))
	}

	;* GDIp.CreateColorMatrixEffect(colorMatrix)
	;* Parameter:
		;* [Structure] colorMatrix - A 5x5 matrix structure to apply.
	;* Return:
		;* [Effect]
	static CreateColorMatrixEffect(colorMatrix) {
		static GUID := CLSIDFromString("{718F2615-7933-40E3-A511-5F68FE14DD74}")  ;? {0x718F2615, 0x7933, 0x40E3, {0xA5, 0x11, 0x5F, 0x68, 0xFE, 0x14, 0xDD, 0x74}}

		if (status := DllCall("Gdiplus\GdipCreateEffect", "Ptr", GUID, "Ptr*", &(pEffect := 0), "Int")) {
			throw (ErrorFromStatus(status))
		}

		if (status := DllCall("Gdiplus\GdipSetEffectParameters", "Ptr", pEffect, "Ptr", colorMatrix, "UInt", 100, "Int")) {  ;: https://docs.microsoft.com/en-us/windows/win32/api/gdipluseffects/nf-gdipluseffects-colormatrixeffect-setparameters
			throw (ErrorFromStatus(status))
		}

		return (this.Effect(pEffect))
	}

	;* GDIp.CreateColorLUTEffect()
	;* Return:
		;* [Effect]
	static CreateColorLUTEffect() {
		static GUID := CLSIDFromString("{A7CE72A9-0F7F-40D7-B3CC-D0C02D5C3212}")  ;? {0xA7CE72A9, 0xF7F, 0x40D7, {0xB3, 0xCC, 0xD0, 0xC0, 0x2D, 0x5C, 0x32, 0x12}}

		if (status := DllCall("Gdiplus\GdipCreateEffect", "Ptr", GUID, "Ptr*", &(pEffect := 0), "Int")) {
			throw (ErrorFromStatus(status))
		}

		return (this.Effect(pEffect))
	}

	;* GDIp.CreateBrightnessContrastEffect(brightness, contrast)
	;* Parameter:
		;* [Integer] brightness - Integer in the range -255 through 255 that specifies the brightness level. If the value is 0, the brightness remains the same. As the value moves from 0 to 255, the brightness of the image increases. As the value moves from 0 to -255, the brightness of the image decreases.
		;* [Integer] contrast - Integer in the range -100 through 100 that specifies the contrast level. If the value is 0, the contrast remains the same. As the value moves from 0 to 100, the contrast of the image increases. As the value moves from 0 to -100, the contrast of the image decreases.
	;* Return:
		;* [Effect]
	static CreateBrightnessContrastEffect(brightness, contrast) {
		static GUID := CLSIDFromString("{D3A1DBE1-8EC4-4C17-9F4C-EA97AD1C343D}")  ;? {0xD3A1DBE1, 0x8EC4, 0x4C17, {0x9F, 0x4C, 0xEA, 0x97, 0xAD, 0x1C, 0x34, 0x3D}}

		if (status := DllCall("Gdiplus\GdipCreateEffect", "Ptr", GUID, "Ptr*", &(pEffect := 0), "Int")) {
			throw (ErrorFromStatus(status))
		}

		(params := Structure(8)).NumPut(0, "Int", brightness, "Int", contrast)  ;: https://docs.microsoft.com/en-us/windows/win32/api/gdipluseffects/ns-gdipluseffects-brightnesscontrastparams

		if (status := DllCall("Gdiplus\GdipSetEffectParameters", "Ptr", pEffect, "Ptr", params, "UInt", 8, "Int")) {
			throw (ErrorFromStatus(status))
		}

		return (this.Effect(pEffect))
	}

	;* GDIp.CreateHueSaturationLightnessEffect(hue, saturation, lightness)
	;* Parameter:
		;* [Integer] hue - Integer in the range -180 through 180 that specifies the change in hue. A value of 0 specifies no change. Positive values specify counterclockwise rotation on the color wheel. Negative values specify clockwise rotation on the color wheel.
		;* [Integer] saturation - Integer in the range -100 through 100 that specifies the change in saturation. A value of 0 specifies no change. Positive values specify increased saturation and negative values specify decreased saturation.
		;* [Integer] lightness - Integer in the range -100 through 100 that specifies the change in lightness. A value of 0 specifies no change. Positive values specify increased lightness and negative values specify decreased lightness.
	;* Return:
		;* [Effect]
	static CreateHueSaturationLightnessEffect(hue, saturation, lightness) {
		static GUID := CLSIDFromString("{8B2DD6C3-EB07-4D87-A5F0-7108E26A9C5F}")  ;? {0x8B2DD6C3, 0xEB07, 0x4D87, {0xA5, 0xF0, 0x71, 0x8, 0xE2, 0x6A, 0x9C, 0x5F}}

		if (status := DllCall("Gdiplus\GdipCreateEffect", "Ptr", GUID, "Ptr*", &(pEffect := 0), "Int")) {
			throw (ErrorFromStatus(status))
		}

		(params := Structure(12)).NumPut(0, "Int", hue, "Int", saturation, "Int", lightness)  ;: https://docs.microsoft.com/en-us/windows/win32/api/gdipluseffects/ns-gdipluseffects-huesaturationlightnessparams

		if (status := DllCall("Gdiplus\GdipSetEffectParameters", "Ptr", pEffect, "Ptr", params, "UInt", 12, "Int")) {
			throw (ErrorFromStatus(status))
		}

		return (this.Effect(pEffect))
	}

	;* GDIp.CreateLevelsEffect(highlight, midtone, shadow)
	;* Parameter:
		;* [Integer] highlight - Integer in the range 0 through 100 that specifies which pixels should be lightened. You can use this adjustment to lighten pixels that are already lighter than a certain threshold. Setting highlight to 100 specifies no change. Setting highlight to t specifies that a color channel value is increased if it is already greater than t percent of full intensity. For example, setting highlight to 90 specifies that all color channel values greater than 90 percent of full intensity are increased.
		;* [Integer] midtone - Integer in the range -100 through 100 that specifies how much to lighten or darken an image. Color channel values in the middle of the intensity range are altered more than color channel values near the minimum or maximum intensity. You can use this adjustment to lighten (or darken) an image without loosing the contrast between the darkest and lightest portions of the image. A value of 0 specifies no change. Positive values specify that the midtones are made lighter, and negative values specify that the midtones are made darker.
		;* [Integer] shadow - Integer in the range 0 through 100 that specifies which pixels should be darkened. You can use this adjustment to darken pixels that are already darker than a certain threshold. Setting shadow to 0 specifies no change. Setting shadow to t specifies that a color channel value is decreased if it is already less than t percent of full intensity. For example, setting shadow to 10 specifies that all color channel values less than 10 percent of full intensity are decreased.
	;* Return:
		;* [Effect]
	static CreateLevelsEffect(highlight, midtone, shadow) {
		static GUID := CLSIDFromString("{99C354EC-2A31-4F3A-8C34-17A803B33A25}")  ;? {0x99C354EC, 0x2A31, 0x4F3A, {0x8C, 0x34, 0x17, 0xA8, 0x3, 0xB3, 0x3A, 0x25}}

		if (status := DllCall("Gdiplus\GdipCreateEffect", "Ptr", GUID, "Ptr*", &(pEffect := 0), "Int")) {
			throw (ErrorFromStatus(status))
		}

		(params := Structure(12)).NumPut(0, "Int", highlight, "Int", midtone, "Int", shadow)  ;: https://docs.microsoft.com/en-us/windows/win32/api/gdipluseffects/ns-gdipluseffects-levelsparams

		if (status := DllCall("Gdiplus\GdipSetEffectParameters", "Ptr", pEffect, "Ptr", params, "UInt", 12, "Int")) {
			throw (ErrorFromStatus(status))
		}

		return (this.Effect(pEffect))
	}

	;* GDIp.CreateTintEffect(hue, amount)
	;* Parameter:
		;* [Integer] hue - Integer in the range -180 through 180 that specifies the hue to be strengthened or weakened. A value of 0 specifies blue. A positive value specifies a clockwise angle on the color wheel. For example, positive 60 specifies cyan and positive 120 specifies green. A negative value specifies a counter-clockwise angle on the color wheel. For example, negative 60 specifies magenta and negative 120 specifies red.
		;* [Integer] amount - Integer in the range -100 through 100 that specifies how much the hue (given by the hue parameter) is strengthened or weakened. A value of 0 specifies no change. Positive values specify that the hue is strengthened and negative values specify that the hue is weakened.
	;* Return:
		;* [Effect]
	static CreateTintEffect(hue, amount) {
		static GUID := CLSIDFromString("{1077AF00-2848-4441-9489-44AD4C2D7A2C}")  ;? {0x1077AF00, 0x2848, 0x4441, {0x94, 0x89, 0x44, 0xAD, 0x4C, 0x2D, 0x7A, 0x2C}}

		if (status := DllCall("Gdiplus\GdipCreateEffect", "Ptr", GUID, "Ptr*", &(pEffect := 0), "Int")) {
			throw (ErrorFromStatus(status))
		}

		(params := Structure(8)).NumPut(0, "Int", hue, "Int", amount)  ;: https://docs.microsoft.com/en-us/windows/win32/api/gdipluseffects/ns-gdipluseffects-tintparams

		if (status := DllCall("Gdiplus\GdipSetEffectParameters", "Ptr", pEffect, "Ptr", params, "UInt", 8, "Int")) {
			throw (ErrorFromStatus(status))
		}

		return (this.Effect(pEffect))
	}

	;* GDIp.CreateColorBalanceEffect(cyanRed, magentaGreen, yellowBlue)
	;* Parameter:
		;* [Integer] cyanRed - Integer in the range -100 through 100 that specifies a change in the amount of red in the image. If the value is 0, there is no change. As the value moves from 0 to 100, the amount of red in the image increases and the amount of cyan decreases. As the value moves from 0 to -100, the amount of red in the image decreases and the amount of cyan increases.
		;* [Integer] magentaGreen - Integer in the range -100 through 100 that specifies a change in the amount of green in the image. If the value is 0, there is no change. As the value moves from 0 to 100, the amount of green in the image increases and the amount of magenta decreases. As the value moves from 0 to -100, the amount of green in the image decreases and the amount of magenta increases.
		;* [Integer] yellowBlue - Integer in the range -100 through 100 that specifies a change in the amount of blue in the image. If the value is 0, there is no change. As the value moves from 0 to 100, the amount of blue in the image increases and the amount of yellow decreases. As the value moves from 0 to -100, the amount of blue in the image decreases and the amount of yellow increases.
	;* Return:
		;* [Effect]
	static CreateColorBalanceEffect(cyanRed, magentaGreen, yellowBlue) {
		static GUID := CLSIDFromString("{537E597D-251E-48DA-9664-29CA496B70F8}")  ;? {0x537E597D, 0x251E, 0x48DA, {0x96, 0x64, 0x29, 0xCA, 0x49, 0x6B, 0x70, 0xF8}}

		if (status := DllCall("Gdiplus\GdipCreateEffect", "Ptr", GUID, "Ptr*", &(pEffect := 0), "Int")) {
			throw (ErrorFromStatus(status))
		}

		(params := Structure(12)).NumPut(0, "Int", cyanRed, "Int", magentaGreen, "Int", yellowBlue)  ;: https://docs.microsoft.com/en-us/windows/win32/api/gdipluseffects/ns-gdipluseffects-colorbalanceparams

		if (status := DllCall("Gdiplus\GdipSetEffectParameters", "Ptr", pEffect, "Ptr", params, "UInt", 12, "Int")) {
			throw (ErrorFromStatus(status))
		}

		return (this.Effect(pEffect))
	}

	;* GDIp.CreateRedEyeCorrectionEffect(objects*)
	;* Parameter:
		;* [Integer] objects - Any number of objects with `x`, `y`, `Width` and `Height` properties which specify areas of the bitmap to which red eye correction should be applied.
	;* Return:
		;* [Effect]
	static CreateRedEyeCorrectionEffect(objects*) {
		static GUID := CLSIDFromString("{74D29D05-69A4-4266-9549-3CC52836B632}")  ;? {0x74D29D05, 0x69A4, 0x4266, {0x95, 0x49, 0x3C, 0xC5, 0x28, 0x36, 0xB6, 0x32}}

		if (status := DllCall("Gdiplus\GdipCreateEffect", "Ptr", GUID, "Ptr*", &(pEffect := 0), "Int")) {
			throw (ErrorFromStatus(status))
		}

		for index, rect in (areas := Structure(bytes := (numberOfAreas := objects.Length)*16), objects) {
			areas.NumPut(index*16, "Int", rect.x, "Int", rect.y, "Int", rect.x + rect.Width - 1, "Int", rect.y + rect.Height - 1)  ;: https://docs.microsoft.com/en-us/windows/win32/api/windef/ns-windef-rect
		}

		(params := Structure(16)).NumPut(0, "UInt", numberOfAreas, "UInt", 0, "Ptr", areas.Ptr)  ;: https://docs.microsoft.com/en-us/windows/win32/api/gdipluseffects/ns-gdipluseffects-redeyecorrectionparams

		if (status := DllCall("Gdiplus\GdipSetEffectParameters", "Ptr", pEffect, "Ptr", params.Ptr, "UInt", 16 + bytes, "Int")) {
			throw (ErrorFromStatus(status))
		}

		return (this.Effect(pEffect))
	}

	;* GDIp.CreateRedEyeCorrectionEffect(adjustment, channel, adjustValue)
	;* Parameter:
		;* [Integer] adjustment - See CurveAdjustments enumeration.
		;* [Integer] channel - See CurveChannel enumeration.
		;* [Integer] adjustValue - Integer that specifies the intensity of the adjustment. The range of acceptable values depends on which adjustment is being applied:
			; AdjustExposure - In the [-255, 255] interval.
			; AdjustDensity - In the [-255, 255] interval.
			; AdjustContrast - In the [-100, 100] interval.
			; AdjustHighlight - In the [-100, 100] interval.
			; AdjustShadow - In the [-100, 100] interval.
			; AdjustMidtone - In the [-100, 100] interval.
			; AdjustWhiteSaturation - In the [0, 255] interval.
			; AdjustBlackSaturation - In the [0, 255] interval.
	;* Return:
		;* [Effect]
	static CreateColorCurveEffect(adjustment, channel, adjustValue) {
		static GUID := CLSIDFromString("{DD6A0022-58E4-4A67-9D9B-D48EB881A53D}")  ;? {0xDD6A0022, 0x58E4, 0x4A67, {0x9D, 0x9B, 0xD4, 0x8E, 0xB8, 0x81, 0xA5, 0x3D}}

		if (status := DllCall("Gdiplus\GdipCreateEffect", "Ptr", GUID, "Ptr*", &(pEffect := 0), "Int")) {
			throw (ErrorFromStatus(status))
		}

		(params := Structure(12)).NumPut(0, "Int", adjustment, "Int", channel, "Int", adjustValue)  ;: https://docs.microsoft.com/en-us/windows/win32/api/gdipluseffects/ns-gdipluseffects-colorcurveparams

		if (status := DllCall("Gdiplus\GdipSetEffectParameters", "Ptr", pEffect, "Ptr", params, "UInt", 12, "Int")) {
			throw (ErrorFromStatus(status))
		}

		return (this.Effect(pEffect))
	}

	class Effect {
		Class := "Effect"

		__New(pEffect) {
			this.Ptr := pEffect
		}

		__Delete() {
			if (status := DllCall("Gdiplus\GdipDeleteEffect", "Ptr", this.Ptr, "Int")) {
				throw (ErrorFromStatus(status))
			}
		}
	}

	;------------------------------------------------------- Matrix ---------------;

	#Include %A_LineFile%\..\GDIp\Matrix.ahk

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

	;------------------------------------------------------- Bitmap ---------------;

	#Include %A_LineFile%\..\GDIp\Bitmap.ahk

	;------------------------------------------------------ Graphics --------------;

	#Include %A_LineFile%\..\GDIp\Graphics.ahk

	;-------------------------------------------------------  Brush  ---------------;

	#Include %A_LineFile%\..\GDIp\Brush.ahk

	;--------------------------------------------------------  Pen  ----------------;

	#Include %A_LineFile%\..\GDIp\Pen.ahk

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

	;* GDIp.CreateRegionFromPath(path)
	;* Parameter:
		;* [Path] path
	;* Return:
		;* [Region]
	static CreateRegionFromPath(path) {
		if (status := DllCall("Gdiplus\GdipCreateRegionPath", "Ptr", path, "Ptr*", &(pRegion := 0), "Int")) {
			throw (ErrorFromStatus(status))
		}

		return (this.Region(pRegion))
	}

	;* GDIp.CreateRegionFromRect(x, y, width, height)
	;* Parameter:
		;* [Float] x
		;* [Float] y
		;* [Float] width
		;* [Float] height
	;* Return:
		;* [Region]
	static CreateRegionFromRect(x, y, width, height) {
		static rect := Structure.CreateRect(0, 0, 0, 0, "Float")

		rect.NumPut(0, "Float", x, "Float", y, "Float", width, "Float", height)

		if (status := DllCall("Gdiplus\GdipCreateRegionRect", "Ptr", rect.Ptr, "Ptr*", &(pRegion := 0), "Int")) {
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

		Rect[graphics] {
			Get {
				return (this.GetRect(graphics))
			}
		}

		;* region.GetRect(graphics)
		;* Parameter:
			;* [Graphics] graphics - Graphics object that contains the world and page transformations required to calculate the device coordinates of this region.
		;* Return:
			;* [Object]
		GetRect(graphics) {
			static rect := Structure.CreateRect(0, 0, 0, 0, "Float")

			if (status := DllCall("Gdiplus\GdipGetRegionBounds", "Ptr", this.Ptr, "Ptr", graphics, "Ptr", rect.Ptr, "Int")) {
				throw (ErrorFromStatus(status))
			}

			return ({x: rect.NumGet(0, "Float"), y: rect.NumGet(4, "Float"), Width: rect.NumGet(8, "Float"), Height: rect.NumGet(12, "Float")})
		}

		IsEmpty[graphics] {
			Get {
				return (this.IsEmpty(graphics))
			}
		}

		;* region.IsEmpty(graphics)
		;* Parameter:
			;* [Graphics] graphics - Graphics object that contains the world and page transformations required to calculate the device coordinates of this region.
		;* Return:
			;* [Integer]
		IsEmpty(graphics) {
			if (status := DllCall("Gdiplus\GdipIsEmptyRegion", "Ptr", this.Ptr, "Ptr", graphics, "UInt*", &(bool := 0), "Int")) {
				throw (ErrorFromStatus(status))
			}

			return (bool)
		}

		IsInfinite[graphics] {
			Get {
				return (this.IsInfinite(graphics))
			}
		}

		;* region.IsInfinite(graphics)
		;* Parameter:
			;* [Graphics] graphics - Graphics object that contains the world and page transformations required to calculate the device coordinates of this region.
		;* Return:
			;* [Integer]
		IsInfinite(graphics) {
			if (status := DllCall("Gdiplus\GdipIsInfiniteRegion", "Ptr", this.Ptr, "Ptr", graphics, "UInt*", &(bool := 0), "Int")) {
				throw (ErrorFromStatus(status))
			}

			return (bool)
		}

		IsPointVisible[graphics, x, y] {
			Get {
				return (this.IsPointVisible(graphics, x, y))
			}
		}

		;* region.IsPointVisible(graphics, x, y)
		;* Parameter:
			;* [Graphics] graphics - Graphics object that contains the world and page transformations required to calculate the device coordinates of this region.
			;* [Float] x
			;* [Float] y
		;* Return:
			;* [Integer]
		IsPointVisible(graphics, x, y) {
			if (status := DllCall("Gdiplus\GdipIsVisibleRegionPoint", "Ptr", this.Ptr, "Float", x, "Float", y, "Ptr", graphics, "UInt*", &(bool := 0), "Int")) {
				throw (ErrorFromStatus(status))
			}

			return (bool)
		}

		IsRectVisible[graphics, x, y, width, height] {
			Get {
				return (this.IsRectVisible(graphics, x, y, width, height))
			}
		}

		;* region.IsRectVisible(graphics, x, y, width, height)
		;* Parameter:
			;* [Graphics] graphics - Graphics object that contains the world and page transformations required to calculate the device coordinates of this region.
			;* [Float] x
			;* [Float] y
			;* [Float] width
			;* [Float] height
		;* Return:
			;* [Integer]
		IsRectVisible(graphics, x, y, width, height) {
			if (status := DllCall("Gdiplus\GdipIsVisibleRegionRect", "Ptr", this.Ptr, "Float", x, "Float", y, "Float", width, "Float", height, "Ptr", graphics, "UInt*", &(bool := 0), "Int")) {
				throw (ErrorFromStatus(status))
			}

			return (bool)
		}

		;--------------- Method -------------------------------------------------------;

		;* GDIp.Region.Equals(graphics, region1, region2)
		;* Parameter:
			;* [Graphics] graphics - Graphics object that contains the world and page transformations required to calculate the device coordinates of this region.
			;* [Region] region1
			;* [Region] region2
		;* Return:
			;* [Integer]
		static Equals(graphics, region1, region2) {
			if (status := DllCall("Gdiplus\GdipIsEqualRegion", "Ptr", region1, "Ptr", region2, "Ptr", graphics, "UInt*", &(bool := 0), "Int")) {
				throw (ErrorFromStatus(status))
			}

			return (bool)
		}

		SetEmpty() {
			if (status := DllCall("Gdiplus\GdipSetEmpty", "Ptr", this.Ptr, "Int")) {
				throw (ErrorFromStatus(status))
			}
		}

		SetInfinite() {
			if (status := DllCall("Gdiplus\GdipSetInfinite", "Ptr", this.Ptr, "Int")) {
				throw (ErrorFromStatus(status))
			}
		}

		;* region.CombinePath(path, combineMode)
		;* Parameter:
			;* [Path] path
			;* [Integer] combineMode - See CombineMode enumeration.
		CombinePath(path, combineMode) {
			if (status := DllCall("Gdiplus\GdipCombineRegionPath", "Ptr", this.Ptr, "Ptr", path, "Int", combineMode, "Int")) {
				throw (ErrorFromStatus(status))
			}
		}

		;* region.CombineRect(x, y, width, height, combineMode)
		;* Parameter:
			;* [Float] x
			;* [Float] y
			;* [Float] width
			;* [Float] height
			;* [Integer] combineMode - See CombineMode enumeration.
		CombineRect(x, y, width, height, combineMode) {
			static rect := Structure.CreateRect(0, 0, 0, 0, "Float")

			rect.NumPut(0, "Float", x, "Float", y, "Float", width, "Float", height)

			if (status := DllCall("Gdiplus\GdipCombineRegionRect", "Ptr", this.Ptr, "Ptr", rect.Ptr, "Int", combineMode, "Int")) {
				throw (ErrorFromStatus(status))
			}
		}

		;* region.CombineRegion(region, combineMode)
		;* Parameter:
			;* [Region] region
			;* [Integer] combineMode - See CombineMode enumeration.
		CombineRegion(region, combineMode) {
			if (status := DllCall("Gdiplus\GdipCombineRegionRegion", "Ptr", this.Ptr, "Ptr", region, "Int", combineMode, "Int")) {
				throw (ErrorFromStatus(status))
			}
		}

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