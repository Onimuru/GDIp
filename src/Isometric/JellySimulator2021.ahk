;============ Auto-execute ====================================================;
;======================================================  Setting  ==============;

;#NoTrayIcon
#SingleInstance
#Warn All, MsgBox
#Warn LocalSameAsGlobal, Off
#WinActivateForce

CoordMode("Mouse", "Screen")
CoordMode("ToolTip", "Screen")
;DetectHiddenWindows(True)
InstallKeybdHook(True)
InstallMouseHook(True)
ListLines(False)
Persistent(True)
ProcessSetPriority("High")
SetKeyDelay(-1, -1)
SetWinDelay(-1)
SetWorkingDir(A_ScriptDir . "\..\..")

;==============  Include  ======================================================;

#Include %A_ScriptDir%\..\..\lib\Core.ahk

#Include %A_ScriptDir%\..\..\lib\Console\Console.ahk

#Include %A_ScriptDir%\..\..\lib\Color\Color.ahk
#Include %A_ScriptDir%\..\..\lib\Math\Math.ahk
#Include %A_ScriptDir%\..\..\lib\Geometry.ahk

;======================================================== Menu ================;

TraySetIcon(A_WorkingDir . "\res\Image\Icon\1.ico")

;=======================================================  Group  ===============;

GroupAdd("Library", "Core.ahk")
	, GroupAdd("Library", "Array.ahk"), GroupAdd("Library", "Object.ahk"), GroupAdd("Library", "String.ahk")

	, GroupAdd("Library", "Structure.ahk")

	, GroupAdd("Library", "GDI.ahk")
	, GroupAdd("Library", "GDIp.ahk")
		, GroupAdd("Library", "Bitmap.ahk"), GroupAdd("Library", "Graphics.ahk"), GroupAdd("Library", "Brush.ahk"), GroupAdd("Library", "Pen.ahk"), GroupAdd("Library", "Path.ahk"), GroupAdd("Library", "Matrix.ahk")

GroupAdd("Library", "Assert.ahk"), GroupAdd("Library", "Console.ahk")

GroupAdd("Library", "Color.ahk"), GroupAdd("Library", "Geometry.ahk")
	, GroupAdd("Library", "Vec2.ahk"), GroupAdd("Library", "Vec3.ahk"), GroupAdd("Library", "TransformMatrix.ahk"), GroupAdd("Library", "RotationMatrix.ahk"), GroupAdd("Library", "Matrix3.ahk"), GroupAdd("Library", "Ellipse.ahk"), GroupAdd("Library", "Rect.ahk")
GroupAdd("Library", "Math.ahk")

;====================================================== Variable ==============;

global A_Debug := IniRead(A_WorkingDir . "\cfg\Settings.ini", "Debug", "Debug")
	, A_WindowMessage := DllCall("RegisterWindowMessage", "Str", "WindowMessage", "UInt")

;======================================================== GDIp ================;

GDIp.Startup()

global Grid := CreateGrid(A_ScreenWidth - 640 - 50, 50 + 48, 640), Layers := CreateLayers(Grid.x, Grid.y, Grid.Width), Overlay := CreateOverlay(Grid.x, Grid.y + 32, Grid.Width)

;======================================================== Hook ================;

OnMessage(A_WindowMessage, __WindowMessage)

OnExit(__Exit)

;======================================================== Test ================;

;=======================================================  Other  ===============;

exit

;=============== Hotkey =======================================================;
;=======================================================  Mouse  ===============;

;====================================================== Keyboard ==============;

#HotIf (WinActive(A_ScriptName) || WinActive("ahk_group Library"))

	$F10:: {
		ListVars
	}

	~$^s:: {
		Critical(True)

		Sleep(200)
		Reload
	}

#HotIf

;===============  Label  =======================================================;

;============== Function ======================================================;
;======================================================== Hook ================;

__WindowMessage(wParam := 0, lParam := 0, msg := 0, hWnd := 0) {
	switch (wParam) {
		case 0xCE00:
		case 0x1000:
			if (!(A_Debug := IniRead(A_WorkingDir . "\cfg\Settings.ini", "Debug", "Debug"))) {
				ToolTip("", , , 20)
			}

			return (True)
	}

	return (-1)
}

__Exit(exitReason, exitCode) {
	Critical(True)

;	GDIp.Shutdown()

	ExitApp
}

/*
** WM Constants: https://www.pinvoke.net/default.aspx/Constants.WM. **
*/

__GridProc(hWnd, uMsg, wParam, lParam) {
	static currentLayer := 0, currentBlock := 1
		, nullBrush := GDIp.CreateSolidBrush(0x00000000)

	switch (uMsg) {
		case 0x0200:  ;? 0x0200 = WM_MOUSEMOVE
			static tracking := False

			if (!tracking) {
				tracking := TrackMouseEvent(hWnd, 0x00000003)  ;? 0x00000003 = TME_LEAVE + TME_HOVER

				Overlay.Show()

				if (A_Debug) {
					ToolTip("MOVE", 5, 5, 20)
				}
			}

			static previous := 0

			if ((index := ScreenToGridIndexTransform(lParam & 0xFFFF, lParam >> 16)) != previous) {
				nodes := Grid.Nodes

				if (nodes.Has(index)) {
					if (nodes.Has(previous)) {
						node := nodes[previous]

						Overlay.Graphics.FillRectangle(nullBrush, node[0] - 16, node[1] - 7 - 16 - 32, 64, 64)
					}

					node := nodes[index]

					static select := GDIp.CreateBitmapFromFile(A_WorkingDir . "\res\Image\Isometric\Select.png")

					Overlay.Graphics.DrawImageRect(select, node[0] - 16, node[1] - 7 - 16 - 32, 32, 16)
					Overlay.Update()
				}

				previous := index
			}

			return 0

		case 0x02A3:  ;? 0x02A3 = WM_MOUSELEAVE
			Critical(True)

			tracking := !(TrackMouseEvent(hWnd, 0x80000000))  ;? 0x80000000 = TME_CANCEL

			Overlay.Hide()

			if (A_Debug) {
				ToolTip("LEAVE", 5, 5, 20), ToolTip()
			}
		case 0x02A1:  ;? 0x02A1 = WM_MOUSEHOVER
			static perpetual := False

			if (perpetual) {
				tracking := TrackMouseEvent(hWnd, 0x00000001)  ;? 0x00000001 = TME_HOVER
			}

		case 0x0201:  ;? 0x0201 = WM_LBUTTONDOWN
			Critical(True)

			nodes := Grid.Nodes
				, x := ((lParam & 0xFFFF) - 352)*0.5 + 16, y := (lParam >> 16) - 32

			if (nodes.Has(index := (xIndex := Floor((y + x)/16)) + (yIndex := Floor((y - x)/16))*(tiles := Grid.Width/32))) {
				(blocks := (layer := Layers[currentLayer]).Blocks)[index] := currentBlock

				xReset := xIndex - 1, yIndex -= 1

				while (++yIndex < tiles) {
					xIndex := xReset, yComponent := yIndex*tiles
						, next := False

					while (++xIndex < tiles) {
						if (block := blocks[index := xIndex + yComponent]) {
							DrawBlock(layer, nodes[index], A_WorkingDir . "\res\Image\Isometric\Cubes\" . SubStr("00" . block, -2) . "_64x64.png")

							next := True

							if (xIndex + 1 = tiles) {
								last := index
							}
							else {
								lastActual := index
							}
						}
						else if (xIndex + 1 = tiles || !IsSet(last) || index - last > tiles) {
							if (next) {
								last := (!IsSet(last) || index - last - 1 != tiles) ? (index - 1) : (lastActual)
							}

							break
						}
					}

					if (!next) {
						break
					}
				}

				layer.Update()
			}
		;case 0x0202:  ;? 0x0202 = WM_LBUTTONUP
		;case 0x0203:  ;? 0x0203 = WM_LBUTTONDBLCLK

		case 0x0204:  ;? 0x0204 = WM_RBUTTONDOWN
			Critical(True)

			nodes := Grid.Nodes
				, x := ((lParam & 0xFFFF) - 352)*0.5 + 16, y := (lParam >> 16) - 32

			if (nodes.Has(index := (xIndex := Floor((y + x)/16)) + (yIndex := Floor((y - x)/16))*(tiles := Grid.Width/32)) && (blocks := (layer := Layers[currentLayer]).Blocks)[index]) {
				blocks[index] := 0

				layer.Graphics.SetCompositingMode(1)
				DrawBlock(layer, nodes[index], A_WorkingDir . "\res\Image\Isometric\Cubes\" . SubStr("00" . 1, -2) . "_64x64.png", 0)
				layer.Graphics.SetCompositingMode(0)

				xIndex2 := xIndex, yIndex2 := yIndex
					, xReset := Max(xIndex - 2, 0) - 1, yIndex := Max(yIndex - 2, 0) - 1, lastActual := Max(index - 40, 0)  ;* `lastActual` must be set here to account for a situation where a single block is removed with no blocks to repair.

				while (++yIndex < tiles) {
					xIndex := xReset, yComponent := yIndex*tiles

					if (yIndex <= yIndex2 + 1) {
						next := True  ;* Force the loop to continue if it is still in the `xIndex - 1, yIndex - 1` to `xIndex - 1, yIndex + 1` area as that covers any potentially clipped blocks.
					}
					else {
						next := False

						if (!IsSet(clear) && yIndex > yIndex2 + 2) {
							clear := True
						}
					}

					while (++xIndex < tiles) {
						if (block := blocks[index := xIndex + yComponent]) {
							DrawBlock(layer, nodes[index], A_WorkingDir . "\res\Image\Isometric\Cubes\" . SubStr("00" . block, -2) . "_64x64.png")

							if (A_Debug) {
								layer.Update()

								MsgBox("REPAIR (" xIndex ", " yIndex ")")
							}

							next := True

							if (xIndex + 1 = tiles) {
								last := index
							}
							else {
								lastActual := index
							}
						}
						else if (xIndex + 1 = tiles || ((IsSet(clear) || (yIndex < yIndex2 && xIndex >= xIndex2) || (xIndex > xIndex2 + 1)) && (!IsSet(last) || index - last > tiles))) {  ;* Here I'm forcing the loop to continue if 1] `yIndex` is less than the y-index of the block that was removed (i.e. on the row above) and `xIndex` is less than the x-index of the block that was removed because the 0 alpha block that removes the block that was there in drawn straight up in screen coordinates so the block "above" the block that was removed is not affected and 2] if `yIndex` is not less than `yIndex2` (same row or greater than the row of the the block that was removed) and `xIndex` is greater than `xIndex2 + 1` because the blocks (if any) to the right, far right and below the removed block will have been clipped.
							if (A_Debug) {
								DrawBlock(layer, nodes[index], A_WorkingDir . "\res\Image\Isometric\Cubes\09_64x64.png")
								layer.Update()

								if (next) {
									MsgBox("BREAK (" xIndex ", " yIndex ")")
								}
							}

							if (next) {
								last := (!IsSet(last) || index - last - 1 != tiles) ? (index - 1) : (lastActual)  ;* Implement a rudementary "fade" to avoid unnecessary checks.
							}

							break
						}
						else if (A_Debug) {
							DrawBlock(layer, nodes[index], A_WorkingDir . "\res\Image\Isometric\Cubes\06_64x64.png")
							layer.Update()

							if (IsSet(last)) {
								MsgBox("CONTINUE (" xIndex ", " yIndex ")")
							}
						}
					}

					if (!next) {
						if (A_Debug) {
							MsgBox("SUPER BREAK (" xIndex ", " yIndex ")")
						}

						break
					}
				}

				layer.Update()
			}
		;case 0x0205:  ;? 0x0205 = WM_RBUTTONUP
		;case 0x0206:  ;? 0x0206 = WM_RBUTTONDBLCLK

		;case 0x0207:  ;? 0x0207 = WM_MBUTTONDOWN
		;case 0x0208:  ;? 0x0208 = WM_MBUTTONUP
		;case 0x0209:  ;? 0x0209 = WM_MBUTTONDBLCLK

		case 0x020A:  ;? 0x020A = WM_MOUSEWHEEL (Vertical)
			;ToolTip(Format("WM_MOUSEWHEEL {}", ((wParam >> 16) == 120) ? ("UP") : ("DOWN")))

			Critical(True)

			static alpha := 0x8F/0xFF

			if (GetKeyState("Ctrl", "P")) {
				currentLayer := ((currentLayer += ((wParam >> 16) == 120) ? (1) : (-1)) < 0) ? (3 - Mod(-currentLayer, 3)) : (Mod(currentLayer, 3))
					, graphics := Overlay.Graphics

				graphics.FillRectangle(nullBrush, Overlay.Width - 64, 32 + 7, 64, 96)

				graphics.SetCompositingMode(0)

				loop (Layers.Length) {
					DrawPlane(Overlay, Vec2(Overlay.Width - 48, 64 + 7 + (A_Index - 1)*(16 + 5)), A_WorkingDir . "\res\Image\Isometric\Plane.png", (A_Index + currentLayer = 3) ? (1) : (alpha))
				}

				graphics.SetCompositingMode(1)
			}
			else {
				currentBlock := ((currentBlock += ((wParam >> 16) == 120) ? (1) : (-1)) < 1) ? (12 - Mod(1 - currentBlock, 11)) : (1 + Mod(currentBlock - 1, 11))

				for index, block in [(currentBlock == 1) ? (11) : (currentBlock - 1), currentBlock, (currentBlock == 11) ? (1) : (currentBlock + 1)] {
					DrawBlock(Overlay, Vec2(16, 128*0.5 + 64 + 5 - index*(32 + 5) - 1), A_WorkingDir . "\res\Image\Isometric\Cubes\" . SubStr("00" . block, -2) . "_64x64.png", (index = 1) ? (1) : (alpha))
				}
			}

			Overlay.Update()
		;case 0x020E:  ;? 0x020E = WM_MOUSEWHEEL (Horizontal)
			;ToolTip(Format("WM_MOUSEWHEEL {}", ((wParam >> 16) == 120) ? ("RIGHT") : ("LEFT")))
	}

	TrackMouseEvent(hWnd, dwFlags := 0x00000002, dwHoverTime := 400) {
		static eventTrack := Structure.CreateTrackMouseEvent(A_ScriptHwnd)

		eventTrack.NumPut(4, "UInt", dwFlags, "Ptr", hWnd, "UInt", dwHoverTime)

		return (DllCall("TrackMouseEvent", "Ptr", eventTrack.Ptr, "UInt"))  ;* Non-zero on success.  ;: https://docs.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-trackmouseevent
	}

	ScreenToGridTransform(x, y) {
		; [0.5   -0.5   0]
		; [ 1      1    0]
		; [ 0      0    1]

		x *= 0.5

		return (Vec2(x + y, y - x))
	}

	ScreenToGridIndexTransform(x, y) {
		static height := Grid.Height, tiles := Grid.Width/32

		x := (x - height)*0.5 + 16, y -= 32  ;* Account for the gap at the top with `x + 16` and `y - 32`.

		return (Floor((x + y)/16) + Floor((y - x)/16)*tiles)
	}

	GridToScreenTransform(x, y) {
		; [ 1   0.5   0]
		; [-1   0.5   0]
		; [ 0    0    1]

		return (Vec2(x - y, (x + y)*0.5))
	}

	return (DllCall("User32\DefWindowProc", "Ptr", hWnd, "UInt", uMsg, "UPtr", wParam, "Ptr", lParam, "Ptr"))
}

;======================================================== GDIp ================;

CreateGrid(x, y, width) {
	nodes := (grid := LayeredWindow(x, y, width, width*0.5 + 32, "IsometricGrid", ["CS_HREDRAW", "CS_VREDRAW"], __GridProc, 32512, False, ["WS_EX_LAYERED", "WS_EX_NOACTIVATE", "WS_EX_TOOLWINDOW", "WS_EX_TOPMOST"], ["WS_CLIPCHILDREN", "WS_POPUPWINDOW"], False, "SW_SHOWNOACTIVATE", 0xFF, 0x000E200B)).Nodes := []

	loop ((width := grid.Width)/32) {
		outerIndex := A_Index - 1

		for index, offset in Range(Round(width/2) - outerIndex*16, width - outerIndex*16, 16) {
			nodes.Push(Vec2(offset, index*8 + outerIndex*8 + 7 + 16 + 32))  ;* `+ 32` accounts for the gap at the top.
		}
	}

	DrawTiles(grid, nodes, A_WorkingDir . "\res\Image\Isometric\Tile.png")
	grid.Update()

	return (grid)
}

CreateLayers(x, y, width, number := 3) {
	layers := []

	loop (number) {
		layers.Push(LayeredWindow(x, y - 16*(A_index - 1), width, width*0.5 + 32, "IsometricLayer", ["CS_HREDRAW", "CS_VREDRAW"], False, False, False, ["WS_EX_LAYERED", "WS_EX_NOACTIVATE", "WS_EX_TOOLWINDOW", "WS_EX_TRANSPARENT"], ["WS_CHILDWINDOW", "WS_CLIPCHILDREN", "WS_POPUP"], (A_index = 1) ? (Grid.Handle) : (layers[-1].Handle)))

		blocks := layers[-1].Blocks := []

		loop ((width/32)**2) {
			blocks.Push(0)
		}
	}

	return (layers)
}

CreateOverlay(x, y, width) {
	overlay := LayeredWindow(x, y, width, width*0.5, "IsometricLayer", False, False, False, False, ["WS_EX_LAYERED", "WS_EX_NOACTIVATE", "WS_EX_TOOLWINDOW", "WS_EX_TRANSPARENT"], ["WS_OVERLAPPEDWINDOW"], Grid.Handle, 0)

	static SWP_ASYNCWINDOWPOS := 0x4000, SWP_DEFERERASE := 0x2000, SWP_DRAWFRAME := 0x0020, SWP_FRAMECHANGED := 0x0020, SWP_HIDEWINDOW := 0x0080, SWP_NOACTIVATE := 0x0010, SWP_NOCOPYBITS := 0x0100, SWP_NOMOVE := 0x0002, SWP_NOOWNERZORDER := 0x0200, SWP_NOREDRAW := 0x0008, SWP_NOREPOSITION := 0x0200, SWP_NOSENDCHANGING := 0x0400, SWP_NOSIZE := 0x0001, SWP_NOZORDER := 0x0004, SWP_SHOWWINDOW := 0x0040

	if (!DllCall("User32\SetWindowPos", "Ptr", overlay.Handle, "Ptr", 0, "Int", 0, "Int", 0, "Int", 0, "Int", 0, "UInt", SWP_NOMOVE | SWP_NOREDRAW | SWP_NOSENDCHANGING | SWP_NOSIZE, "UInt")) {  ;: https://docs.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-setwindowpos
		throw (ErrorFromMessage(DllCall("Kernel32\GetLastError")))
	}

	for index, block in (alpha := 0x8F/0xFF, [11, 1, 2]) {
		DrawBlock(overlay, Vec2(16, 128*0.5 + 64 + 5 - index*(32 + 5) - 1), A_WorkingDir . "\res\Image\Isometric\Cubes\" . SubStr("00" . block, -2) . "_64x64.png", (index == 1) ? (1) : (alpha))
	}

	overlay.Graphics.SetCompositingMode(0)

	loop (width := overlay.Width - 48, 3) {
		DrawPlane(overlay, Vec2(width, 64 + 7 + (A_Index - 1)*(16 + 5)), A_WorkingDir . "\res\Image\Isometric\Plane.png", (A_Index == 3) ? (1) : (alpha))
	}

	overlay.Graphics.SetCompositingMode(1)

	return (overlay)
}

DrawTile(window, node, file, alpha := unset) {
	static tiles := Map()

	if (!tiles.Has(file)) {
		try {
			tiles[file] := GDIp.CreateBitmapFromFile(file)
		}
		catch {
			(tiles[file] := GDIp.CreateBitmap(64, 32)).LockBits(), stride := tiles[file].BitmapData.NumGet(8, "Int"), scan0 := tiles[file].BitmapData.NumGet(16, "Ptr")
				, reset := 31, y := 0

			for index, pixels in [4, 8, 12, 16, 20, 24, 28, 32, 36, 40, 44, 48, 52, 56, 60, 64, 64, 60, 56, 52, 48, 44, 40, 36, 32, 28, 24, 20, 16, 12, 8, 4] {
				loop (x := (reset - pixels/2), pixels) {
					Numput("UInt", (A_Index == 1 || A_Index == 2 || A_Index == pixels - 1 || A_Index == pixels) ? (0xFF000000) : (Color(0x80, "AliceBlue")), scan0 + ++x*4 + (y + index)*stride)
				}
			}

			tiles[file].UnlockBits()
			tiles[file].SaveToFile(file)
		}
	}

	if (IsSet(alpha)) {
		DllCall("Gdiplus\GdipCreateImageAttributes", "Ptr*", &(pImageAttributes := 0))

		static colorMatrix := Structure.CreateColorMatrix()

		colorMatrix.NumPut(72, "Float", alpha)

		if (status := DllCall("Gdiplus\GdipSetImageAttributesColorMatrix", "Ptr", pImageAttributes, "Int", 0, "Int", 1, "Ptr", colorMatrix.Ptr, "Ptr", 0, "Int", 0, "UInt")) {
			throw (ErrorFromStatus(status))
		}

		tile := tiles[file], width := tile.Width
			, window.Graphics.DrawImageRectRect(tile, node[0] - 16, node[1] - 7 - 32, 32, 32, 0, 0, width, width, pImageAttributes)

		DllCall("Gdiplus\GdipDisposeImageAttributes", "Ptr", pImageAttributes)
	}
	else {
		window.Graphics.DrawImageRect(tiles[file], node[0] - 16, node[1] - 7 - 32, 32, 32)
	}
}

DrawTiles(window, nodes, file) {
	static tiles := Map()

	if (!tiles.Has(file)) {
		try {
			tiles[file] := GDIp.CreateBitmapFromFile(file)
		}
		catch {
			(tiles[file] := GDIp.CreateBitmap(64, 32)).LockBits(), stride := tiles[file].BitmapData.NumGet(8, "Int"), scan0 := tiles[file].BitmapData.NumGet(16, "Ptr")
				, reset := 31, y := 0

			for index, pixels in [4, 8, 12, 16, 20, 24, 28, 32, 36, 40, 44, 48, 52, 56, 60, 64, 64, 60, 56, 52, 48, 44, 40, 36, 32, 28, 24, 20, 16, 12, 8, 4] {
				loop (x := (reset - pixels/2), pixels) {
					Numput("UInt", (A_Index == 1 || A_Index == 2 || A_Index == pixels - 1 || A_Index == pixels) ? (0xFF000000) : (Color(0x80, "AliceBlue")), scan0 + ++x*4 + (y + index)*stride)
				}
			}

			tiles[file].UnlockBits()
			tiles[file].SaveToFile(file)
		}
	}

	tile := tiles[file], width := tile.Width
		, graphics := window.Graphics

	for node in nodes {
		graphics.DrawImageRectRect(tile, node[0] - 16, node[1] - 7 - 16, 32, 32, 0, 0, width, width)
	}
}

DrawBlock(window, node, file, alpha := unset) {
	static blocks := Map()

	if (!blocks.Has(file)) {
		try {
			blocks[file] := GDIp.CreateBitmapFromFile(file)
		}
		catch {
			(blocks[file] := GDIp.CreateBitmap(64, 64)).LockBits(), stride := blocks[file].BitmapData.NumGet(8, "Int"), scan0 := blocks[file].BitmapData.NumGet(16, "Ptr")
				, reset := 31, y := 0

			for index, pixels in [4, 8, 12, 16, 20, 24, 28, 32, 36, 40, 44, 48, 52, 56, 60, 64, 64, 60, 56, 52, 48, 44, 40, 36, 32, 28, 24, 20, 16, 12, 8, 4] {
				loop (x := (reset - pixels/2), pixels) {
					Numput("UInt", (A_Index == 1 || A_Index == 2 || A_Index == pixels - 1 || A_Index == pixels) ? (0xFF000000) : (0xFF00FF00), scan0 + ++x*4 + (y + index)*stride)
				}
			}

			for index, pixels in (reset -= 32, y += 17, range := [2, 4, 6, 8, 10, 12, 14, 16, 18, 20, 22, 24, 26, 28, 30, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 30, 28, 26, 24, 22, 20, 18, 16, 14, 12, 10, 8, 6, 4, 2]) {
				loop (x := (reset += (A_Index > 32)*2), pixels) {
					Numput("UInt", (A_Index == 1 || (index > 30 && A_Index == 2) || (index > 14 && A_Index == pixels)) ? (0xFF000000) : (0xFF00FF00), scan0 + ++x*4 + (y + index)*stride)
				}
			}

			for index, pixels in (reset += 34, range) {
				loop (x := (reset -= (A_Index < 17)*2), pixels) {
					Numput("UInt", ((index < 32 && A_Index == pixels) || (index > 14 && A_Index == 1) || (index > 30 && (A_Index == pixels - 1 || A_Index == pixels))) ? (0xFF000000) : (0xFF00FF00), scan0 + ++x*4 + (y + index)*stride)
				}
			}

			blocks[file].UnlockBits()
			blocks[file].SaveToFile(file)
		}
	}

	if (IsSet(alpha)) {
		DllCall("Gdiplus\GdipCreateImageAttributes", "Ptr*", &(pImageAttributes := 0))

		static colorMatrix := Structure.CreateColorMatrix()

		colorMatrix.NumPut(72, "Float", alpha)

		if (status := DllCall("Gdiplus\GdipSetImageAttributesColorMatrix"
			, "Ptr", pImageAttributes  ;* imageattr
			, "Int", 0  ;* type
			, "Int", 1  ;* enableFlag
			, "Ptr", colorMatrix.Ptr  ;* colorMatrix
			, "Ptr", 0  ;* grayMatrix
			, "Int", 0  ;* flags
			, "UInt")) {  ;: https://docs.microsoft.com/en-us/windows/win32/api/gdiplusimageattributes/nf-gdiplusimageattributes-imageattributes-setcolormatrix
			throw (ErrorFromStatus(status))
		}

		DllCall("Gdiplus\GdipGetImageDimension", "Ptr", (block := blocks[file]).Ptr, "Float*", &(width := 0), "Float*", &(height := 0))
			, window.Graphics.DrawImageRectRect(block, node[0] - 16, node[1] - 7 - 32, 32, 32, 0, 0, width, height, pImageAttributes)

		DllCall("Gdiplus\GdipDisposeImageAttributes", "Ptr", pImageAttributes)
	}
	else {
		window.Graphics.DrawImageRect(blocks[file], node[0] - 16, node[1] - 7 - 32, 32, 32)
	}
}

DrawPlane(window, node, file, alpha := unset) {
	static planes := Map()

	if (!planes.Has(file)) {
		try {
			planes[file] := GDIp.CreateBitmapFromFile(file)
		}
		catch {
			(planes[file] := GDIp.CreateBitmap(64, 32)).LockBits(), stride := planes[file].BitmapData.NumGet(8, "Int"), scan0 := planes[file].BitmapData.NumGet(16, "Ptr")
				, reset := 31, y := 0

			for index, pixels in [4, 8, 12, 16, 20, 24, 28, 32, 36, 40, 44, 48, 52, 56, 60, 64, 64, 60, 56, 52, 48, 44, 40, 36, 32, 28, 24, 20, 16, 12, 8, 4] {
				loop (x := (reset - pixels/2), pixels) {
					Numput("UInt", (A_Index == 1 || A_Index == 2 || A_Index == pixels - 1 || A_Index == pixels) ? (0xFF000000) : (Color(0x80, "AliceBlue")), scan0 + ++x*4 + (y + index)*stride)
				}
			}

			planes[file].UnlockBits()
			planes[file].SaveToFile(file)
		}
	}

	plane := planes[file], width := plane.Width

	if (IsSet(alpha)) {
		DllCall("Gdiplus\GdipCreateImageAttributes", "Ptr*", &(pImageAttributes := 0))

		static colorMatrix := Structure.CreateColorMatrix()

		colorMatrix.NumPut(72, "Float", alpha)

		if (status := DllCall("Gdiplus\GdipSetImageAttributesColorMatrix"
			, "Ptr", pImageAttributes  ;* imageattr
			, "Int", 0  ;* type
			, "Int", 1  ;* enableFlag
			, "Ptr", colorMatrix.Ptr  ;* colorMatrix
			, "Ptr", 0  ;* grayMatrix
			, "Int", 0  ;* flags
			, "UInt")) {  ;: https://docs.microsoft.com/en-us/windows/win32/api/gdiplusimageattributes/nf-gdiplusimageattributes-imageattributes-setcolormatrix
			throw (ErrorFromStatus(status))
		}

		window.Graphics.DrawImageRectRect(plane, node[0] - 16, node[1] - 7 - 16, 64, 64, 0, 0, width, width, pImageAttributes)

		DllCall("Gdiplus\GdipDisposeImageAttributes", "Ptr", pImageAttributes)
	}
	else {
		window.Graphics.DrawImageRectRect(plane, node[0] - 16, node[1] - 7 - 16, 64, 64, 0, 0, width, width)
	}
}