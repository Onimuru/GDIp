/*
;* enum BrushType  ;: https://docs.microsoft.com/en-us/windows/win32/api/gdiplusenums/ne-gdiplusenums-brushtype
	0 = BrushTypeSolidColor
	1 = BrushTypeHatchFill
	2 = BrushTypeTextureFill
	3 = BrushTypePathGradient
	4 = BrushTypeLinearGradient

;* enum HatchStyle  ;: https://docs.microsoft.com/en-us/windows/win32/api/gdiplusenums/ne-gdiplusenums-hatchstyle
	0 = HatchStyleHorizontal || HatchStyleMin
	1 = HatchStyleVertical
	2 = HatchStyleForwardDiagonal
	3 = HatchStyleBackwardDiagonal
	4 = HatchStyleCross || HatchStyleLargeGrid
	5 = HatchStyleDiagonalCross
	6 = HatchStyle05Percent
	7 = HatchStyle10Percent
	8 = HatchStyle20Percent
	9 = HatchStyle25Percent
	10 = HatchStyle30Percent
	11 = HatchStyle40Percent
	12 = HatchStyle50Percent
	13 = HatchStyle60Percent
	14 = HatchStyle70Percent
	15 = HatchStyle75Percent
	16 = HatchStyle80Percent
	17 = HatchStyle90Percent
	18 = HatchStyleLightDownwardDiagonal
	19 = HatchStyleLightUpwardDiagonal
	20 = HatchStyleDarkDownwardDiagonal
	21 = HatchStyleDarkUpwardDiagonal
	22 = HatchStyleWideDownwardDiagonal
	23 = HatchStyleWideUpwardDiagonal
	24 = HatchStyleLightVertical
	25 = HatchStyleLightHorizontal
	26 = HatchStyleNarrowVertical
	27 = HatchStyleNarrowHorizontal
	28 = HatchStyleDarkVertical
	29 = HatchStyleDarkHorizontal
	30 = HatchStyleDashedDownwardDiagonal
	31 = HatchStyleDashedUpwardDiagonal
	32 = HatchStyleDashedHorizontal
	33 = HatchStyleDashedVertical
	34 = HatchStyleSmallConfetti
	35 = HatchStyleLargeConfetti
	36 = HatchStyleZigZag
	37 = HatchStyleWave
	38 = HatchStyleDiagonalBrick
	39 = HatchStyleHorizontalBrick
	40 = HatchStyleWeave
	41 = HatchStylePlaid
	42 = HatchStyleDivot
	43 = HatchStyleDottedGrid
	44 = HatchStyleDottedDiamond
	45 = HatchStyleShingle
	46 = HatchStyleTrellis
	47 = HatchStyleSphere
	48 = HatchStyleSmallGrid
	49 = HatchStyleSmallCheckerBoard
	50 = HatchStyleLargeCheckerBoard
	51 = HatchStyleOutlinedDiamond
	52 = HatchStyleSolidDiamond || HatchStyleMax
	53 = HatchStyleTotal

;* enum LinearGradientMode  ;: https://docs.microsoft.com/en-us/windows/win32/api/gdiplusenums/ne-gdiplusenums-lineargradientmode
	0 = LinearGradientModeVertical
	1 = LinearGradientModeHorizontal
	2 = LinearGradientModeBackwardDiagonal
	3 = LinearGradientModeForwardDiagonal

;* enum MatrixOrder  ;: https://docs.microsoft.com/en-us/windows/win32/api/gdiplusenums/ne-gdiplusenums-matrixorder
	0 = MatrixOrderPrepend
	1 = MatrixOrderAppend

;* enum WrapMode  ;: https://docs.microsoft.com/en-us/windows/win32/api/gdiplusenums/ne-gdiplusenums-wrapmode
	0 = WrapModeTile - Tiling without flipping.
	1 = WrapModeTileFlipX - Tiles are flipped horizontally as you move from one tile to the next in a row.
	2 = WrapModeTileFlipY - Tiles are flipped vertically as you move from one tile to the next in a column.
	3 = WrapModeTileFlipXY - Tiles are flipped horizontally as you move along a row and flipped vertically as you move along a column.
	4 = WrapModeClamp - No tiling takes place.
*/

;------------- SolidBrush -----------------------------------------------------;

;* GDIp.CreateSolidBrush(color)
;* Parameter:
	;* [Integer] color
;* Return:
	;* [Brush]
static CreateSolidBrush(color)  {
	if (status := DllCall("Gdiplus\GdipCreateSolidFill", "UInt", color, "Ptr*", &(pBrush := 0), "Int")) {
		throw (ErrorFromStatus(status))
	}

	(instance := this.SolidBrush()).Ptr := pBrush
	return (instance)
}

class SolidBrush {
	Class := "Brush"

	;* brush.Clone()
	;* Return:
		;* [Brush]
	Clone() {
		if (status := DllCall("Gdiplus\GdipCloneBrush", "Ptr", this.Ptr, "Ptr*", &(pBrush := 0), "Int")) {
			throw (ErrorFromStatus(status))
		}

		(instance := GDIp.SolidBrush()).Ptr := pBrush
		return (instance)
	}

	__Delete() {
		if (status := DllCall("Gdiplus\GdipDeleteBrush", "Ptr", this.Ptr, "Int")) {
			throw (ErrorFromStatus(status))
		}
	}

	;-------------- Property ------------------------------------------------------;

	Color {
		Get {
			return (this.GetColor())
		}

		Set {
			this.SetColor(value)

			return (value)
		}
	}

	;* brush.GetColor()
	;* Return:
		;* [Integer]
	GetColor() {
		if (status := DllCall("Gdiplus\GdipGetSolidFillColor", "Ptr", this.Ptr, "UInt*", &(color := 0), "Int")) {
			throw (ErrorFromStatus(status))
		}

		return (color)
	}

	;* brush.SetColor(color)
	;* Parameter:
		;* [Integer] color
	SetColor(color) {
		if (status := DllCall("Gdiplus\GdipSetSolidFillColor", "Ptr", this.Ptr, "UInt", color, "Int")) {
			throw (ErrorFromStatus(status))
		}
	}

	Type {
		Get {
			return (this.GetType())
		}
	}

	;* brush.GetType()
	;* Return:
		;* [Integer] - See BrushType enumeration.
	GetType() {
		if (status := DllCall("Gdiplus\GdipGetBrushType", "Ptr", this.Ptr, "Int*", &(type := 0), "Int")) {
			throw (ErrorFromStatus(status))
		}

		return (type)
	}
}

;------------- HatchBrush -----------------------------------------------------;

;* GDIp.CreateHatchBrush(foregroundColor, backgroundColor[, style])
;* Parameter:
	;* [Integer] foregroundColor
	;* [Integer] backgroundColor
	;* [Integer] style - See HatchStyle enumeration.
;* Return:
	;* [Brush]
static CreateHatchBrush(foregroundColor, backgroundColor, style := 0) {
	if (status := DllCall("Gdiplus\GdipCreateHatchBrush", "Int", style, "UInt", foregroundColor, "UInt", backgroundColor, "Ptr*", &(pBrush := 0), "Int")) {
		throw (ErrorFromStatus(status))
	}

	(instance := this.HatchBrush()).Ptr := pBrush
	return (instance)
}

class HatchBrush extends GDIp.SolidBrush {

	Color[which] {
		Get {
			return (this.GetColor(which))
		}
	}

	;* GDIp.GetColor()
	;* Return:
		;* [Object]
	GetColor() {
		if (status := DllCall("Gdiplus\GdipGetHatchForegroundColor", "Ptr", this.Ptr, "UInt*", &(foregroundColor := 0), "Int")) {
			throw (ErrorFromStatus(status))
		}

		if (status := DllCall("Gdiplus\GdipGetHatchBackgroundColor", "Ptr", this.Ptr, "UInt*", &(backgroundColor := 0), "Int")) {
			throw (ErrorFromStatus(status))
		}

		return ({ForegroundColor: foregroundColor, BackgroundColor: backgroundColor})
	}

	HatchStyle[which] {
		Get {
			return (this.GetHatchStyle())
		}
	}

	;* hatchBrush.GetHatchStyle()
	;* Return:
		;* [Integer] - See HatchStyle enumeration.
	GetHatchStyle() {
		if (status := DllCall("Gdiplus\GdipGetHatchStyle", "Ptr", this.Ptr, "Int*", &(style := 0), "Int")) {
			throw (ErrorFromStatus(status))
		}

		return (style)
	}
}

;------------ TextureBrush ----------------------------------------------------;

;* GDIp.CreateTextureBrush(bitmap[, wrapMode, x, y, width, height, imageAttributes])
;* Parameter:
	;* [Bitmap] bitmap
	;* [Integer] wrapMode - See WrapMode enumeration.
	;* [Float] x
	;* [Float] y
	;* [Float] width
	;* [Float] height
	;* [ImageAttributes] imageAttributes
;* Return:
	;* [Brush]
static CreateTextureBrush(bitmap, wrapMode := 0, x := unset, y := unset, width := unset, height := unset, imageAttributes := unset) {
	if (!(IsSet(x) && IsSet(y) && IsSet(width) && IsSet(height))) {
		if (status := DllCall("Gdiplus\GdipCreateTexture", "Ptr", bitmap.Ptr, "UInt", wrapMode, "Ptr*", &(pBrush := 0), "Int")) {
			throw (ErrorFromStatus(status))
		}
	}
	else if (IsSet(imageAttributes)) {
		if (status := DllCall("Gdiplus\GdipCreateTextureIA", "Ptr", bitmap.Ptr, "Ptr", imageAttributes.Ptr, "Float", x, "Float", y, "Float", width, "Float", height, "Ptr*", &(pBrush := 0), "Int")) {
			throw (ErrorFromStatus(status))
		}

		if (status := DllCall("Gdiplus\GdipSetTextureWrapMode", "Ptr", pBrush, "Int", wrapMode, "Int")) {
			throw (ErrorFromStatus(status))
		}
	}
	else {
		if (status := DllCall("Gdiplus\GdipCreateTexture2", "Ptr", bitmap.Ptr, "UInt", wrapMode, "Float", x, "Float", y, "Float", width, "Float", height, "Ptr*", &(pBrush := 0), "Int")) {
			throw (ErrorFromStatus(status))
		}
	}

	(instance := this.TextureBrush()).Ptr := pBrush
	return (instance)
}

class TextureBrush extends GDIp.SolidBrush {

	;-------------- Property ------------------------------------------------------;

	Bitmap {
		Get {
			return (this.GetBitmap())
		}
	}

	;* textureBrush.GetBitmap()
	;* Return:
		;* [Bitmap]
	GetBitmap() {
		if (status := DllCall("Gdiplus\GdipGetTextureImage", "Ptr", this.Ptr, "Ptr*", &(pBitmap := 0), "Int")) {
			throw (ErrorFromStatus(status))
		}

		(instance := this.Bitmap()).Ptr := pBitmap
		return (instance)
	}

	WrapMode {
		Get {
			return (this.GetWrapMode())
		}

		Set {
			this.SetWrapMode(value)

			return (value)
		}
	}

	;* textureBrush.GetWrapMode()
	;* Return:
		;* [Integer] - See WrapMode enumeration.
	GetWrapMode() {
		if (status := DllCall("Gdiplus\GdipGetTextureWrapMode", "Ptr", this.Ptr, "Int*", &(wrapMode := 0), "Int")) {
			throw (ErrorFromStatus(status))
		}

		return (wrapMode)
	}

	;* textureBrush.SetWrapMode(wrapMode)
	;* Parameter:
		;* [Integer] wrapMode - See WrapMode enumeration.
	SetWrapMode(wrapMode) {
		if (status := DllCall("Gdiplus\GdipSetTextureWrapMode", "Ptr", this.Ptr, "Int", wrapMode, "Int")) {
			throw (ErrorFromStatus(status))
		}
	}

	Transform {
		Get {
			return (this.GetTransform())
		}

		Set {
			this.SetTransform(value)

			return (value)
		}
	}

	;* textureBrush.GetTransform()
	;* Return:
		;* [Matrix]
	GetTransform() {
		if (status := DllCall("Gdiplus\GdipGetTextureTransform", "Ptr", this.Ptr, "Ptr*", &(pMatrix := 0), "Int")) {
			throw (ErrorFromStatus(status))
		}

		(instance := this.Matrix()).Ptr := pMatrix
		return (instance)
	}

	;* textureBrush.SetTransform(matrix)
	;* Parameter:
		;* [Matrix] matrix
	SetTransform(matrix) {
		if (status := DllCall("Gdiplus\GdipSetTextureTransform", "Ptr", this.Ptr, "Ptr", matrix.Ptr, "Int")) {
			throw (ErrorFromStatus(status))
		}
	}

	;--------------- Method -------------------------------------------------------;
	;-----------------------------------------------------  Transform  -------------;

	;* textureBrush.TranslateTransform(x, y[, matrixOrder])
	;* Parameter:
		;* [Float] x
		;* [Float] y
		;* [Integer] matrixOrder - See MatrixOrder enumeration.
	TranslateTransform(x, y, matrixOrder := 0) {
		if (status := DllCall("Gdiplus\GdipTranslateTextureTransform", "Ptr", this.Ptr, "Float", x, "Float", y, "Int", matrixOrder, "Int")) {
			throw (ErrorFromStatus(status))
		}
	}

	;* textureBrush.RotateTransform(angle[, matrixOrder])
	;* Parameter:
		;* [Float] angle
		;* [Integer] matrixOrder - See MatrixOrder enumeration.
	RotateTransform(angle, matrixOrder := 0) {
		if (status := DllCall("Gdiplus\GdipRotateTextureTransform", "Ptr", this.Ptr, "Float", angle, "Int", matrixOrder, "Int")) {
			throw (ErrorFromStatus(status))
		}
	}

	;* textureBrush.MultiplyTransform(matrix[, matrixOrder])
	;* Parameter:
		;* [Matrix] matrix
		;* [Integer] matrixOrder - See MatrixOrder enumeration.
	MultiplyTransform(matrix, matrixOrder := 0) {
		if (status := DllCall("Gdiplus\GdipMultiplyTextureTransform", "Ptr", this.Ptr, "Ptr", matrix.Ptr, "Int", matrixOrder, "Int")) {
			throw (ErrorFromStatus(status))
		}
	}

	;* textureBrush.ScaleTransform(x, y[, matrixOrder])
	;* Parameter:
		;* [Float] x
		;* [Float] y
		;* [Integer] matrixOrder - See MatrixOrder enumeration.
	ScaleTransform(x, y, matrixOrder := 0) {
		if (status := DllCall("Gdiplus\GdipScaleTextureTransform", "Ptr", this.Ptr, "Float", x, "Float", y, "Int", matrixOrder, "Int")) {
			throw (ErrorFromStatus(status))
		}
	}

	;* textureBrush.ResetTransform()
	ResetTransform() {
		if (status := DllCall("Gdiplus\GdipResetTextureTransform", "Ptr", this.Ptr, "Int")) {
			throw (ErrorFromStatus(status))
		}
	}
}

;-------------  PathBrush  -----------------------------------------------------;

;* GDIp.CreatePathBrush(objects*[, wrapMode])
;* Parameter:
	;* [Object]* objects
	;* [Integer] wrapMode - See WrapMode enumeration.
;* Return:
	;* [Brush]
static CreatePathBrush(objects*)  {
	wrapMode := (IsNumber(objects[-1])) ? (objects.Pop()) : (0)

	for index, object in (points := Structure((length := objects.Length)*8), objects) {
		points.NumPut(index*8, "Float", object.x, "Float", object.y)
	}

	if (status := DllCall("Gdiplus\GdipCreatePathGradient", "Ptr", points.Ptr, "Int", length, "Int", wrapMode, "Ptr*", &(pBrush := 0), "Int")) {
		throw (ErrorFromStatus(status))
	}

	(instance := this.PathBrush()).Ptr := pBrush
	return (instance)
}

;* GDIp.CreatePathBrushFromPath(path)
;* Parameter:
	;* [Path] path
;* Return:
	;* [Brush]
static CreatePathBrushFromPath(path) {
	if (status := DllCall("Gdiplus\GdipCreatePathGradientFromPath", "Ptr", path.Ptr, "Ptr*", &(pBrush := 0), "Int")) {
		throw (ErrorFromStatus(status))
	}

	(instance := this.PathBrush()).Ptr := pBrush
	return (instance)
}

class PathBrush extends GDIp.SolidBrush {

	;-------------- Property ------------------------------------------------------;

	WrapMode {
		Get {
			return (this.GetWrapMode())
		}

		Set {
			this.SetWrapMode(value)

			return (value)
		}
	}

	;* pathBrush.GetWrapMode()
	;* Return:
		;* [Integer] - See WrapMode enumeration.
	GetWrapMode() {
		if (status := DllCall("Gdiplus\GdipGetPathGradientWrapMode", "Ptr", this.Ptr, "Int*", &(wrapMode := 0), "Int")) {
			throw (ErrorFromStatus(status))
		}

		return (wrapMode)
	}

	;* pathBrush.SetWrapMode(wrapMode)
	;* Parameter:
		;* [Integer] wrapMode - See WrapMode enumeration.
	SetWrapMode(wrapMode) {
		if (status := DllCall("Gdiplus\GdipSetPathGradientWrapMode", "Ptr", this.Ptr, "Int", wrapMode, "Int")) {
			throw (ErrorFromStatus(status))
		}
	}

	PointCount {
		Get {
			return (this.GetPointCount())
		}
	}

	;* pathBrush.GetPointCount()
	;* Return:
		;* [Integer]
	GetPointCount() {
		if (status := DllCall("Gdiplus\GdipGetPathGradientPointCount", "Ptr", this.Ptr, "Int*", &(count := 0), "Int")) {
			throw (ErrorFromStatus(status))
		}

		return (count)
	}

	CenterPoint {
		Get {
			return (this.GetCenterPoint())
		}
	}

	;* pathBrush.GetCenterPoint()
	;* Return:
		;* [Object]
	GetCenterPoint() {
		static point := Structure(8)

		if (status := DllCall("Gdiplus\GdipGetPathGradientCenterPoint", "Ptr", this.Ptr, "Ptr", point.Ptr, "Int")) {
			throw (ErrorFromStatus(status))
		}

		return ({x: point.NumGet(0, "Float"), y: point.NumGet(4, "Float")})
	}

	;* pathBrush.SetCenterPoint(x, y)
	;* Parameter:
		;* [Float] x
		;* [Float] y
	SetCenterPoint(x, y) {
		static point := Structure(8)
		point.NumPut(0, "Float", x, "Float", y)

		if (status := DllCall("Gdiplus\GdipSetPathGradientCenterPoint", "Ptr", this.Ptr, "Ptr", point.Ptr, "Int")) {
			throw (ErrorFromStatus(status))
		}
	}

	Rect {
		Get {
			return (this.GetRect())
		}
	}

	;* pathBrush.GetRect()
	;* Return:
		;* [Object]
	GetRect() {
		static rect := Structure(16)

		if (status := DllCall("Gdiplus\GdipGetPathGradientRect", "Ptr", this.Ptr, "Ptr", rect.Ptr, "Int")) {
			throw (ErrorFromStatus(status))
		}

		return ({x: rect.NumGet(0, "Float"), y: rect.NumGet(4, "Float"), Width: rect.NumGet(8, "Float"), Height: rect.NumGet(12, "Float")})
	}

	FocusScales {
		Get {
			return (this.GetFocusScales())
		}

		Set {
			this.SetFocusScales(value)

			return (value)
		}
	}

	;* pathBrush.GetFocusScales()
	;* Return:
		;* [Object]
	GetFocusScales() {
		static point := Structure(8)

		if (status := DllCall("Gdiplus\GdipGetPathGradientFocusScales", "Ptr", this.Ptr, "Float*", &(x := 0), "Float*", &(y := 0), "Int")) {
			throw (ErrorFromStatus(status))
		}

		return ({x: x, y: y})
	}

	;* pathBrush.SetFocusScales(x, y)
	;* Parameter:
		;* [Float] x - Scalar in the range (0.0, 1.0).
		;* [Float] y - Scalar in the range (0.0, 1.0).
	SetFocusScales(x, y) {
		if (status := DllCall("Gdiplus\GdipSetPathGradientFocusScales", "Ptr", this.Ptr, "Float", x, "Float", y, "Int")) {
			throw (ErrorFromStatus(status))
		}
	}

	CenterColor {
		Get {
			return (this.GetCenterColor())
		}

		Set {
			this.SetCenterColor(value)

			return (value)
		}
	}

	;* pathBrush.GetCenterColor()
	;* Return:
		;* [Integer]
	GetCenterColor() {
		if (status := DllCall("Gdiplus\GdipGetPathGradientCenterColor", "Ptr", this.Ptr, "UInt*", &(color := 0), "Int")) {
			throw (ErrorFromStatus(status))
		}

		return (color)
	}

	;* pathBrush.SetCenterColor(color)
	;* Parameter:
		;* [Integer] color
	SetCenterColor(color) {
		if (status := DllCall("Gdiplus\GdipSetPathGradientCenterColor", "Ptr", this.Ptr, "UInt", color, "Int")) {
			throw (ErrorFromStatus(status))
		}
	}

	SurroundColorCount {
		Get {
			return (this.GetSurroundColorCount())
		}
	}

	;* pathBrush.GetSurroundColorCount()
	;* Return:
		;* [Integer]
	GetSurroundColorCount() {
		if (status := DllCall("Gdiplus\GdipGetPathGradientSurroundColorCount", "Ptr", this.Ptr, "UInt*", &(count := 0), "Int")) {
			throw (ErrorFromStatus(status))
		}

		return (count)
	}

	;* pathBrush.GetSurroundColors()
	;* Return:
		;* [Array]
	GetSurroundColors() {
		if (status := DllCall("Gdiplus\GdipGetPathGradientSurroundColorsWithCount", "Ptr", this.Ptr, "Ptr", (struct := Structure((count := this.GetSurroundColorCount())*4)).Ptr, "Int*", &(count), "Int")) {
			throw (ErrorFromStatus(status))
		}

		loop (array := [], count) {
			array.Push(struct.NumGet((A_Index - 1)*4, "UInt"))
		}

		return (array)
	}

	;* pathBrush.SetSurroundColors(colors*)
	;* Parameter:
		;* [Integer]* colors
	SetSurroundColors(colors*) {
		for index, color in (struct := Structure((length := colors.Length)*4), colors) {
			struct.NumPut(index*4, "UInt", color)
		}

		if (status := DllCall("Gdiplus\GdipSetPathGradientSurroundColorsWithCount", "Ptr", this.Ptr, "Ptr", struct.Ptr, "Int*", length, "Int")) {
			throw (ErrorFromStatus(status))
		}
	}

	GammaCorrection {
		Get {
			return (this.GetGammaCorrection())
		}

		Set {
			this.SetGammaCorrection(value)

			return (value)
		}
	}

	;* pathBrush.GetGammaCorrection()
	;* Return:
		;* [Integer]
	GetGammaCorrection() {
		if (status := DllCall("Gdiplus\GdipGetPathGradientGammaCorrection", "Ptr", this.Ptr, "UInt*", &(bool := 0), "Int")) {
			throw (ErrorFromStatus(status))
		}

		return (bool)
	}

	;* pathBrush.SetGammaCorrection(useGammaCorrection)
	;* Parameter:
		;* [Integer] useGammaCorrection - Boolean value that indicates if gamma correction should be used or not.
	SetGammaCorrection(useGammaCorrection) {
		if (status := DllCall("Gdiplus\GdipSetPathGradientGammaCorrection", "Ptr", this.Ptr, "UInt", useGammaCorrection, "Int")) {
			throw (ErrorFromStatus(status))
		}
	}

	;* pathBrush.SetLinearBlend(focus[, scale])
	;* Parameter:
		;* [Float] focus - Number in the range (0.0, 1.0) that specifies where the center color will be at its highest intensity.
		;* [Float] scale - Number in the range (0.0, 1.0) that specifies the maximum intensity of center color that gets blended with the boundary color.
	SetLinearBlend(focus, scale := 1.0) {
		if (status := DllCall("Gdiplus\GdipSetPathGradientLinearBlend", "Ptr", this.Ptr, "Float", focus, "Float", scale, "Int")) {
			throw (ErrorFromStatus(status))
		}
	}

	;* pathBrush.SetSigmaBlend(focus[, scale])
	;* Parameter:
		;* [Float] focus - Number in the range (0.0, 1.0) that specifies where the center color will be at its highest intensity.
		;* [Float] scale - Number in the range (0.0, 1.0) that specifies the maximum intensity of center color that gets blended with the boundary color.
	SetSigmaBlend(focus, scale := 1.0) {
		if (status := DllCall("Gdiplus\GdipSetPathGradientSigmaBlend", "Ptr", this.Ptr, "Float", focus, "Float", scale, "Int")) {
			throw (ErrorFromStatus(status))
		}
	}

	Transform {
		Get {
			return (this.GetTransform())
		}

		Set {
			this.SetTransform(value)

			return (value)
		}
	}

	;* pathBrush.GetTransform()
	;* Return:
		;* [Matrix]
	GetTransform() {
		if (status := DllCall("Gdiplus\GdipGetPathGradientTransform", "Ptr", this.Ptr, "Ptr*", &(pMatrix := 0), "Int")) {
			throw (ErrorFromStatus(status))
		}

		(instance := this.Matrix()).Ptr := pMatrix
		return (instance)
	}

	;* pathBrush.SetTransform(matrix)
	;* Parameter:
		;* [Matrix] matrix
	SetTransform(matrix) {
		if (status := DllCall("Gdiplus\GdipSetPathGradientTransform", "Ptr", this.Ptr, "Ptr", matrix.Ptr, "Int")) {
			throw (ErrorFromStatus(status))
		}
	}

	;--------------- Method -------------------------------------------------------;
	;-----------------------------------------------------  Transform  -------------;

	;* pathBrush.TranslateTransform(x, y[, matrixOrder])
	;* Parameter:
		;* [Float] x
		;* [Float] y
		;* [Integer] matrixOrder
	TranslateTransform(x, y, matrixOrder := 0) {
		if (status := DllCall("Gdiplus\GdipTranslatePathGradientTransform", "Ptr", this.Ptr, "Float", x, "Float", y, "Int", matrixOrder, "Int")) {
			throw (ErrorFromStatus(status))
		}
	}

	;* pathBrush.RotateTransform(angle[, matrixOrder])
	;* Parameter:
		;* [Float] angle
		;* [Integer] matrixOrder
	RotateTransform(angle, matrixOrder := 0) {
		if (status := DllCall("Gdiplus\GdipRotatePathGradientTransform", "Ptr", this.Ptr, "Float", angle, "Int", matrixOrder, "Int")) {
			throw (ErrorFromStatus(status))
		}
	}

	;* pathBrush.MultiplyTransform(matrix[, matrixOrder])
	;* Parameter:
		;* [Matrix] matrix
		;* [Integer] matrixOrder
	MultiplyTransform(matrix, matrixOrder := 0) {
		if (status := DllCall("Gdiplus\GdipMultiplyPathGradientTransform", "Ptr", this.Ptr, "Ptr", matrix.Ptr, "Int", matrixOrder, "Int")) {
			throw (ErrorFromStatus(status))
		}
	}

	;* pathBrush.ScaleTransform(x, y[, matrixOrder])
	;* Parameter:
		;* [Float] x
		;* [Float] y
		;* [Integer] matrixOrder
	ScaleTransform(x, y, matrixOrder := 0) {
		if (status := DllCall("Gdiplus\GdipScalePathGradientTransform", "Ptr", this.Ptr, "Float", x, "Float", y, "Int", matrixOrder, "Int")) {
			throw (ErrorFromStatus(status))
		}
	}

	;* pathBrush.ResetTransform()
	ResetTransform() {
		if (status := DllCall("Gdiplus\GdipResetPathGradientTransform", "Ptr", this.Ptr, "Int")) {
			throw (ErrorFromStatus(status))
		}
	}
}

;------------  LinearBrush  ----------------------------------------------------;

;* GDIp.CreateLinearBrush(x1, y1, x2, y2, color1, color2[, wrapMode])
;* Parameter:
	;* [Float] x1
	;* [Float] y1
	;* [Float] x2
	;* [Float] y2
	;* [Integer] color1
	;* [Integer] color2
	;* [Integer] wrapMode - See WrapMode enumeration.
;* Return:
	;* [Brush]
static CreateLinearBrush(x1, y1, x2, y2, color1, color2, wrapMode := 0) {
	static point1 := Structure.CreatePoint(0, 0, "Float"), point2 := Structure.CreatePoint(0, 0, "Float")
	point1.NumPut(0, "Float", x1, "Float", y1), point2.NumPut(0, "Float", x2, "Float", y2)

	if (status := DllCall("Gdiplus\GdipCreateLineBrush", "Ptr", point1.Ptr, "Ptr", point2.Ptr, "UInt", color1, "UInt", color2, "UInt", wrapMode, "Ptr*", &(pBrush := 0), "Int")) {
		throw (ErrorFromStatus(status))
	}

	(instance := this.LinearBrush()).Ptr := pBrush
	return (instance)
}

;* GDIp.CreateLinearBrushFromRect(x, y, width, height, color1, color2[, gradientMode, wrapMode])
;* Parameter:
	;* [Float] x
	;* [Float] y
	;* [Float] width
	;* [Float] height
	;* [Integer] color1
	;* [Integer] color2
	;* [Integer] gradientMode - See LinearGradientMode enumeration.
	;* [Integer] wrapMode - See WrapMode enumeration.
;* Return:
	;* [Brush]
static CreateLinearBrushFromRect(x, y, width, height, color1, color2, gradientMode := 0, wrapMode := 0) {
	static rect := Structure.CreateRect(0, 0, 0, 0, "Float")
	rect.NumPut(0, "Float", x, "Float", y, "Float", width, "Float", height)

	if (status := DllCall("Gdiplus\GdipCreateLineBrushFromRect", "Ptr", rect.Ptr, "UInt", color1, "UInt", color2, "UInt", gradientMode, "UInt", wrapMode, "Ptr*", &(pBrush := 0), "Int")) {
		throw (ErrorFromStatus(status))
	}

	(instance := this.LinearBrush()).Ptr := pBrush
	return (instance)
}

;* GDIp.CreateLinearBrushFromRectWithAngle(x, y, width, height, color1, color2, angle[, wrapMode])
;* Parameter:
	;* [Float] x
	;* [Float] y
	;* [Float] width
	;* [Float] height
	;* [Integer] color1
	;* [Integer] color2
	;* [Float] angle
	;* [Integer] wrapMode - See WrapMode enumeration.
;* Return:
	;* [Brush]
static CreateLinearBrushFromRectWithAngle(x, y, width, height, color1, color2, angle, wrapMode := 0) {
	static rect := Structure.CreateRect(0, 0, 0, 0, "Float")
	rect.NumPut(0, "Float", x, "Float", y, "Float", width, "Float", height)

	if (status := DllCall("Gdiplus\GdipCreateLineBrushFromRectWithAngle", "Ptr", rect.Ptr, "UInt", color1, "UInt", color2, "Float", angle, "UInt", 0, "UInt", wrapMode, "Ptr*", &(pBrush := 0), "Int")) {
		throw (ErrorFromStatus(status))
	}

	(instance := this.LinearBrush()).Ptr := pBrush
	return (instance)
}

class LinearBrush extends GDIp.SolidBrush {

	;-------------- Property ------------------------------------------------------;

	Color {
		Get {
			return (this.GetColor())
		}

		Set {
			this.SetColor(value[0], value[1])

			return (value)
		}
	}

	;* linearBrush.GetColor()
	;* Return:
		;* [Array]
	GetColor() {
		static colors := Structure(8)

		if (status := DllCall("Gdiplus\GdipGetLineColors", "Ptr", this.Ptr, "Ptr", colors.Ptr, "Int")) {
			throw (ErrorFromStatus(status))
		}

		return ([colors.NumGet(0, "UInt"), colors.NumGet(4, "UInt")])
	}

	;* linearBrush.SetColor(color1, color2)
	;* Parameter:
		;* [Integer] color1
		;* [Integer] color2
	SetColor(color1, color2) {
		if (status := DllCall("Gdiplus\GdipSetLineColors", "Ptr", this.Ptr, "UInt", color1, "UInt", color2, "Int")) {
			throw (ErrorFromStatus(status))
		}
	}

	WrapMode {
		Get {
			return (this.GetWrapMode())
		}

		Set {
			this.SetWrapMode(value)

			return (value)
		}
	}

	;* linearBrush.GetWrapMode()
	;* Return:
		;* [Integer] - See WrapMode enumeration.
	GetWrapMode() {
		if (status := DllCall("Gdiplus\GdipGetLineWrapMode", "Ptr", this.Ptr, "Int*", &(wrapMode := 0), "Int")) {
			throw (ErrorFromStatus(status))
		}

		return (wrapMode)
	}

	;* linearBrush.SetWrapMode(wrapMode)
	;* Parameter:
		;* [Integer] wrapMode - See WrapMode enumeration.
	SetWrapMode(wrapMode) {
		if (status := DllCall("Gdiplus\GdipSetLineWrapMode", "Ptr", this.Ptr, "Int", wrapMode, "Int")) {
			throw (ErrorFromStatus(status))
		}
	}

	Rect {
		Get {
			return (this.GetRect())
		}
	}

	;* linearBrush.GetRect()
	;* Return:
		;* [Object]
	GetRect() {
		static rect := Structure.CreateRect(0, 0, 0, 0, "Float")

		if (status := DllCall("Gdiplus\GdipGetLineRect", "Ptr", this.Ptr, "Ptr", rect.Ptr, "Int")) {
			throw (ErrorFromStatus(status))
		}

		return ({x: rect.NumGet(0, "Float"), y: rect.NumGet(4, "Float"), Width: rect.NumGet(8, "Float"), Height: rect.NumGet(12, "Float")})
	}

	GammaCorrection {
		Get {
			return (this.GetGammaCorrection())
		}

		Set {
			this.SetGammaCorrection(value)

			return (value)
		}
	}

	;* lineBrush.GetGammaCorrection()
	;* Return:
		;* [Integer] - Boolean value that indicates if gamma correction is enabled or not.
	GetGammaCorrection() {
		if (status := DllCall("Gdiplus\GdipGetLineGammaCorrection", "Ptr", this.Ptr, "Int*", &(enabled := 0), "Int")) {
			throw (ErrorFromStatus(status))
		}

		return (enabled)
	}

	;* linearBrush.SetGammaCorrection(useGammaCorrection)
	;* Parameter:
		;* [Integer] useGammaCorrection - Boolean value that indicates if gamma correction should be enabled or not.
	SetGammaCorrection(useGammaCorrection) {
		if (status := DllCall("Gdiplus\GdipSetLineGammaCorrection", "Ptr", this.Ptr, "Int", useGammaCorrection, "Int")) {
			throw (ErrorFromStatus(status))
		}
	}

	Transform {
		Get {
			return (this.GetTransform())
		}

		Set {
			this.SetTransform(value)

			return (value)
		}
	}

	;* lineBrush.GetTransform()
	;* Return:
		;* [Matrix]
	GetTransform() {
		if (status := DllCall("Gdiplus\GdipGetLineTransform", "Ptr", this.Ptr, "Ptr*", &(pMatrix := 0), "Int")) {
			throw (ErrorFromStatus(status))
		}

		(instance := this.Matrix()).Ptr := pMatrix
		return (instance)
	}

	;* linearBrush.SetTransform(matrix)
	;* Parameter:
		;* [Matrix] matrix
	SetTransform(matrix) {
		if (status := DllCall("Gdiplus\GdipSetLineTransform", "Ptr", this.Ptr, "Ptr", matrix.Ptr, "Int")) {
			throw (ErrorFromStatus(status))
		}
	}

	;--------------- Method -------------------------------------------------------;
	;-----------------------------------------------------  Transform  -------------;

	;* linearBrush.TranslateTransform(x, y[, matrixOrder])
	;* Parameter:
		;* [Float] x
		;* [Float] y
		;* [Integer] matrixOrder
	TranslateTransform(x, y, matrixOrder := 0) {
		if (status := DllCall("Gdiplus\GdipTranslateLineTransform", "Ptr", this.Ptr, "Float", x, "Float", y, "Int", matrixOrder, "Int")) {
			throw (ErrorFromStatus(status))
		}
	}

	;* linearBrush.RotateTransform(angle[, matrixOrder])
	;* Parameter:
		;* [Float] angle
		;* [Integer] matrixOrder
	RotateTransform(angle, matrixOrder := 0) {
		if (status := DllCall("Gdiplus\GdipRotateLineTransform", "Ptr", this.Ptr, "Float", angle, "Int", matrixOrder, "Int")) {
			throw (ErrorFromStatus(status))
		}
	}

	;* linearBrush.MultiplyTransform(matrix[, matrixOrder])
	;* Parameter:
		;* [Matrix] matrix
		;* [Integer] matrixOrder
	MultiplyTransform(matrix, matrixOrder := 0) {
		if (status := DllCall("Gdiplus\GdipMultiplyLineTransform", "Ptr", this.Ptr, "Ptr", matrix.Ptr, "Int", matrixOrder, "Int")) {
			throw (ErrorFromStatus(status))
		}
	}

	;* linearBrush.ScaleTransform(x, y[, matrixOrder])
	;* Parameter:
		;* [Float] x
		;* [Float] y
		;* [Integer] matrixOrder
	ScaleTransform(x, y, matrixOrder := 0) {
		if (status := DllCall("Gdiplus\GdipScaleLineTransform", "Ptr", this.Ptr, "Float", x, "Float", y, "Int", matrixOrder, "Int")) {
			throw (ErrorFromStatus(status))
		}
	}

	;* linearBrush.ResetTransform()
	ResetTransform() {
		if (status := DllCall("Gdiplus\GdipResetLineTransform", "Ptr", this.Ptr, "Int")) {
			throw (ErrorFromStatus(status))
		}
	}
}