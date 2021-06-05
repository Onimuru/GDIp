# GDIp

A class based wrapper library of GDI and GDIp functions for use with AutoHotkey v2.*

[ObjectOriented](https://github.com/Onimuru/ObjectOriented) is now fully integrated and you should be aware that that library adjusts arrays to be zero-based.

## Examples

#### Draw a Bitmap and with a Matrix, Effect and ImageAttributes applied

```
; Create a window with the `WS_EX_LAYERED` extended style:
canvas := LayeredWindow(A_ScreenWidth - (150*2 + 50 + 10), 50, 150*2, 150*2)
	, canvasWidth := canvas.Width, canvasHeight := canvas.Height

; Create a GDIp Bitmap (this is just an example, you can use any image here):
bitmap := GDIp.CreateBitmapFromFile(A_WorkingDir . "\res\Image\Texture\sauron-bhole-100x100.png")
	, bitmapWidth := bitmap.Width, bitmapHeight := bitmap.Height

; Create a GDIp Matrix:
matrix := GDIp.CreateMatrix()
matrix.Scale(0.5, 0.5)  ; Scale the image such that it is half it's original size.
matrix.RotateWithTranslation(55, bitmapWidth*0.5*0.5, bitmapHeight*0.5*0.5)  ; Rotate the image 55 degrees around it's center (accounting for the scaling factor here).

; Create a GDIp Effect:
effect := GDIp.CreateBlurEffect(15, False)

; Create a GDIp ImageAttributes:
imageAttributes := GDIp.CreateImageAttributes()
imageAttributes.SetColorMatrix(Structure.CreateNegativeColorMatrix())  ; Apply a negative (5x5) color matrix.

; Draw two lines to demonstrate that the image is in fact rotated around the center of the window:
pen := GDIp.CreatePen(0xFFFFFFFF)

canvas.Graphics.DrawLine(pen, Vec2(0, 0), Vec2(canvasWidth, canvasHeight))
canvas.Graphics.DrawLine(pen, Vec2(canvasWidth, 0), Vec2(0, canvasHeight))

; Translate the graphics to the center of the window minus the dimensions of the scaled image so that the image is drawn in the center of the window:
canvas.Graphics.TranslateTransform(canvasWidth*0.5 - bitmapWidth*0.5*0.5, canvasHeight*0.5 - bitmapWidth*0.5*0.5)

; Apply the Matrix, Effect and ImageAttributes and to the Bitmap and then draw it:
canvas.Graphics.DrawImageFX(bitmap, matrix, effect, 0, 0, bitmapWidth, bitmapHeight, imageAttributes)

; Update the layered window:
canvas.Update()
```
