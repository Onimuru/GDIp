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

for i, v in [
	"Core.ahk",
		"Array.ahk", "Object.ahk", "String.ahk",

		"Structure.ahk",

		"GDI.ahk",
		"GDIp.ahk",
			"Canvas.ahk", "Bitmap.ahk", "Graphics.ahk", "Brush.ahk", "Pen.ahk", "Path.ahk", "Matrix.ahk",

	"Assert.ahk", "Console.ahk",

	"Color.ahk", "Geometry.ahk",
		"Vec2.ahk", "Vec3.ahk", "TransformMatrix.ahk", "RotationMatrix.ahk", "Matrix3.ahk", "Ellipse.ahk", "Rect.ahk"
	"Math.ahk"] {
	GroupAdd("Library", v)
}

;====================================================== Variable ==============;

global A_Debug := IniRead(A_WorkingDir . "\cfg\Settings.ini", "Debug", "Debug")
	, A_WindowMessage := DllCall("RegisterWindowMessage", "Str", "WindowMessage", "UInt")

;======================================================== GDIp ================;

GDIp.Startup()

global Grid := CreateGrid(A_ScreenWidth - 640 - 50, 50 + 48, 640)
	, Nodes := []

loop ((width := Grid.Width)/32) {
	outerIndex := A_Index - 1

	for index, offset in Range(Round(width/2) - outerIndex*16, width - outerIndex*16, 16) {
		Nodes.Push(Vec2(offset, index*8 + outerIndex*8 + 7 + 16 + 32))  ;* `+ 32` accounts for the gap at the top.
	}
}

DrawTiles(Grid, Nodes, A_WorkingDir . "\res\Image\Isometric\Tile.png")
Grid.Update()

global Layers := []

loop (3) {
	Layers.Push(CreateLayer(A_ScreenWidth - 640 - 50, 50 + 48 - 16*(A_index - 1), 640, (A_index = 1) ? (Grid.Handle) : (Layers[-1].Handle), True))
}

global Overlay := CreateOverlay(0, 32, Grid.Width, Grid.Height - 32, Grid.Handle, True)

for index, block in [11, 1, 2] {
	DrawBlock(Overlay, Vec2(16, 128*0.5 + 64 + 5 - index*(32 + 5) - 1), A_WorkingDir . "\res\Image\Isometric\Cubes\" . SubStr("00" . block, -2) . "_64x64.png", (index = 1) ? (1) : (0x8F/0xFF))
}

Overlay.Graphics.SetCompositingMode(0)

loop (3) {
	DrawPlane(Overlay, Vec2(Overlay.Width - 48, 64 + 7 + (A_Index - 1)*(16 + 5)), A_WorkingDir . "\res\Image\Isometric\Plane.png", (A_Index == 3) ? (1) : (0x8F/0xFF))
}

Overlay.Graphics.SetCompositingMode(1)

Overlay.Update()

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

;=======================================================  Other  ===============;

GetTime() {
	DllCall("QueryPerformanceCounter", "Int64*", &(current := 0))

	return (current)
}

;======================================================== GDIp ================;

CreateGrid(x, y, width) {
	if (!DllCall("User32\GetClassInfoEx", "Ptr", hInstance := DllCall("Kernel32\GetModuleHandle", "Ptr", 0, "Ptr"), "Ptr", lpszClassName := StrPtr("IsometricGrid"), "Ptr", wndClassEx := Structure(cbSize := (A_PtrSize == 8) ? (80) : (48), True), "UInt")) {  ;: https://docs.microsoft.com/en-gb/windows/win32/api/winuser/nf-winuser-getclassinfoexa?redirectedfrom=MSDN
		static CS_BYTEALIGNCLIENT := 0x00001000, CS_BYTEALIGNWINDOW := 0x00002000, CS_CLASSDC := 0x00000040, CS_DBLCLKS := 0x00000008, CS_DROPSHADOW := 0x00020000, CS_GLOBALCLASS := 0x00004000, CS_HREDRAW := 0x00000002, CS_NOCLOSE := 0x00000200, CS_OWNDC := 0x00000020, CS_PARENTDC := 0x00000080, CS_SAVEBITS := 0x00000800, CS_VREDRAW := 0x00000001  ;: https://docs.microsoft.com/en-us/windows/win32/winmsg/window-class-styles

		wndClassEx.NumPut(0, "UInt", cbSize
			, "UInt", CS_HREDRAW | CS_VREDRAW  ;* style
			, "Ptr", CallbackCreate(__WindowProc, "F")  ;* lpfnWndProc
			, "Int", 0  ;* cbClsExtra
			, "Int", 0  ;* cbWndExtra
			, "Ptr", hInstance  ;* hInstance
			, "Ptr", 0  ;* hIcon
			, "Ptr", DllCall("LoadCursor", "Ptr", 0, "Ptr", 32512, "Ptr")  ;? 32512 = OCR_NORMAL  ;* hCursor
			, "Ptr", 0  ;* hbrBackground
			, "Ptr", 0  ;* lpszMenuName
			, "Ptr", lpszClassName  ;* lpszClassName
			, "Ptr", 0)  ;* hIconSm

		/*
		** WM Constants: https://www.pinvoke.net/default.aspx/Constants.WM. **
		*/

		__WindowProc(hWnd, uMsg, wParam, lParam) {
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
						if (Nodes.Has(index)) {
							if (Nodes.Has(previous)) {
								node := Nodes[previous]

								Overlay.Graphics.FillRectangle(nullBrush, node[0] - 16, node[1] - 7 - 16 - 32, 64, 64)
							}

							node := Nodes[index]

							static select := GDIp.CreateBitmapFromFile(A_WorkingDir . "\res\Image\Isometric\Select.png")

							Overlay.Graphics.DrawBitmap(select, node[0] - 16, node[1] - 7 - 16 - 32, 32, 16)
							Overlay.Update()
						}

						previous := index
					}

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

					x := ((lParam & 0xFFFF) - 352)*0.5 + 16, y := (lParam >> 16) - 32

					if (Nodes.Has(index := (xIndex := Floor((y + x)/16)) + (yIndex := Floor((y - x)/16))*(tiles := Grid.Width/32))) {
						(blocks := (layer := Layers[currentLayer]).Blocks)[index] := currentBlock

						xReset := xIndex - 1, yIndex -= 1

						while (++yIndex < tiles) {
							xIndex := xReset, yComponent := yIndex*tiles
								, next := False

							while (++xIndex < tiles) {
								if (block := blocks[index := xIndex + yComponent]) {
									DrawBlock(layer, Nodes[index], A_WorkingDir . "\res\Image\Isometric\Cubes\" . SubStr("00" . block, -2) . "_64x64.png")

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

					x := ((lParam & 0xFFFF) - 352)*0.5 + 16, y := (lParam >> 16) - 32

					if (Nodes.Has(index := (xIndex := Floor((y + x)/16)) + (yIndex := Floor((y - x)/16))*(tiles := Grid.Width/32)) && (blocks := (layer := Layers[currentLayer]).Blocks)[index]) {
						blocks[index] := 0

						layer.Graphics.SetCompositingMode(1)
						DrawBlock(layer, Nodes[index], A_WorkingDir . "\res\Image\Isometric\Cubes\" . SubStr("00" . 1, -2) . "_64x64.png", 0)
						layer.Graphics.SetCompositingMode(0)

						xIndex2 := xIndex, yIndex2 := yIndex
							, xReset := Max(0, xIndex - 1) - 1, yIndex := Max(0, yIndex - 1) - 1, lastActual := index  ;* `lastActual` must be set here to account for a situation where a single block is removed with no blocks to repair.

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
									DrawBlock(layer, Nodes[index], A_WorkingDir . "\res\Image\Isometric\Cubes\" . SubStr("00" . block, -2) . "_64x64.png")

;									if (A_Debug) {
;										layer.Update()
;
;										MsgBox("REPAIR (" xIndex ", " yIndex ")")
;									}

									next := True

									if (xIndex + 1 = tiles) {
										last := index
									}
									else {
										lastActual := index
									}
								}
								else if (xIndex + 1 = tiles || ((IsSet(clear) || (yIndex < yIndex2 && xIndex >= xIndex2) || (xIndex > xIndex2 + 1)) && (!IsSet(last) || index - last > tiles))) {  ;* Here I'm forcing the loop to continue if 1] `yIndex` is less than the y-index of the block that was removed (i.e. on the row above) and `xIndex` is less than the x-index of the block that was removed because the 0 alpha block that removes the block that was there in drawn straight up in screen coordinates so the block "above" the block that was removed is not affected and 2] if `yIndex` is not less than `yIndex2` (same row or greater than the row of the the block that was removed) and `xIndex` is greater than `xIndex2 + 1` because the blocks (if any) to the right, far right and below the removed block will have been clipped.
;									if (A_Debug) {
;										DrawBlock(layer, Nodes[index], A_WorkingDir . "\res\Image\Isometric\Cubes\09_64x64.png")
;										layer.Update()
;
;										if (next) {
;											MsgBox("BREAK (" xIndex ", " yIndex ")")
;										}
;									}

									if (next) {
										last := (!IsSet(last) || index - last - 1 != tiles) ? (index - 1) : (lastActual)  ;* Implement a rudementary "fade" to avoid unnecessary checks.
									}

									break
								}
;								else if (A_Debug) {
;									DrawBlock(layer, Nodes[index], A_WorkingDir . "\res\Image\Isometric\Cubes\06_64x64.png")
;									layer.Update()`
;
;									if (IsSet(last)) {
;										MsgBox("CONTINUE (" xIndex ", " yIndex ")")
;									}
;								}
							}

							if (!next) {
;								if (A_Debug) {
;									MsgBox("SUPER BREAK (" xIndex ", " yIndex ")")
;								}

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

		if (!DllCall("User32\RegisterClassEx", "Ptr", wndClassEx.Ptr, "UShort")) {  ;: https://docs.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-registerclassexa
			throw (ErrorFromMessage(DllCall("Kernel32\GetLastError")))
		}
	}

	static WS_EX_ACCEPTFILES := 0x00000010, WS_EX_APPWINDOW := 0x00040000, WS_EX_CLIENTEDGE := 0x00000200, WS_EX_COMPOSITED := 0x02000000, WS_EX_CONTEXTHELP := 0x00000400, WS_EX_CONTROLPARENT := 0x00010000, WS_EX_DLGMODALFRAME := 0x00000001, WS_EX_LAYERED := 0x00080000, WS_EX_LAYOUTRTL := 0x00400000, WS_EX_LEFT := 0x00000000, WS_EX_LEFTSCROLLBAR := 0x00004000, WS_EX_LTRREADING := 0x00000000, WS_EX_MDICHILD := 0x00000040, WS_EX_NOACTIVATE := 0x08000000, WS_EX_NOINHERITLAYOUT := 0x00100000, WS_EX_NOPARENTNOTIFY := 0x00000004, WS_EX_NOREDIRECTIONBITMAP := 0x00200000, WS_EX_OVERLAPPEDWINDOW := 0x00000300, WS_EX_PALETTEWINDOW := 0x00000188, WS_EX_RIGHT := 0x00001000, WS_EX_RIGHTSCROLLBAR := 0x00000000, WS_EX_RTLREADING := 0x00002000, WS_EX_STATICEDGE := 0x00020000, WS_EX_TOOLWINDOW := 0x00000080, WS_EX_TOPMOST := 0x00000008, WS_EX_TRANSPARENT := 0x00000020, WS_EX_WINDOWEDGE := 0x00000100  ;: https://docs.microsoft.com/en-us/windows/win32/winmsg/extended-window-styles
		, WS_BORDER := 0x00800000, WS_CAPTION := 0x00C00000, WS_CHILD := 0x40000000, WS_CHILDWINDOW := 0x40000000, WS_CLIPCHILDREN := 0x02000000, WS_CLIPSIBLINGS := 0x04000000, WS_DISABLED := 0x08000000, WS_DLGFRAME := 0x00400000, WS_GROUP := 0x00020000, WS_HSCROLL := 0x00100000, WS_ICONIC := 0x20000000, WS_MAXIMIZE := 0x01000000, WS_MAXIMIZEBOX := 0x00010000, WS_MINIMIZE := 0x20000000, WS_MINIMIZEBOX := 0x00020000, WS_OVERLAPPED := 0x00000000, WS_OVERLAPPEDWINDOW := 0x00CF0000, WS_POPUP := 0x80000000, WS_POPUPWINDOW := 0x80880000, WS_SIZEBOX := 0x00040000, WS_SYSMENU := 0x00080000, WS_TABSTOP := 0x00010000, WS_THICKFRAME := 0x00040000, WS_TILED := 0x00000000, WS_TILEDWINDOW := 0xCF0000, WS_VISIBLE := 0x10000000, WS_VSCROLL := 0x00200000  ;: https://docs.microsoft.com/en-us/windows/win32/winmsg/window-styles

	if (!(hWnd := DllCall("User32\CreateWindowEx", "UInt", WS_EX_LAYERED | WS_EX_NOACTIVATE | WS_EX_TOOLWINDOW | WS_EX_TOPMOST  ;* dwExStyle
		, "Ptr", lpszClassName  ;* lpClassName
		, "Str", "NoFace"  ;* lpWindowName
		, "UInt", (WS_CLIPCHILDREN | WS_POPUPWINDOW) & ~(WS_CAPTION | WS_MAXIMIZEBOX | WS_MINIMIZEBOX | WS_SIZEBOX)  ;* dwStyle
		, "Int", x
		, "Int", y
		, "Int", width
		, "Int", height := width*0.5 + 32
		, "Ptr", A_ScriptHwnd  ;* hWndParent
		, "Ptr", 0  ;* hMenu
		, "Ptr", hInstance  ;* hInstance
		, "Ptr", 0  ;* lpParam
		, "Ptr"))) {  ;: https://docs.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-createwindowexw
		throw (ErrorFromMessage(DllCall("Kernel32\GetLastError")))
	}

	instance := Window(hWnd, "IsometricGrid")

	instance.DC := GDI.CreateCompatibleDC()
		, instance.DC.SelectObject(GDI.CreateDIBSection(Structure.CreateBitmapInfoHeader(width, -height, bitCount := 32), instance.DC, 0, &(pBits := 0)))

	instance.Bitmap := GDIp.CreateBitmap(width, height, 0x000E200B, width*(bitCount >> 3), pBits)
	instance.Graphics := GDIp.CreateGraphicsFromBitmap(instance.Bitmap)
		, instance.Graphics.SetInterpolationMode(7), instance.Graphics.SetSmoothingMode(4)

	instance.Point := Structure.CreatePoint(x, y, "UInt"), instance.Size := Structure.CreateSize(width, height), instance.Blend := Structure.CreateBlendFunction(0xFF)

	instance.Show()
	return (instance)
}

CreateLayer(x, y, width, hParent, show) {
	if (!DllCall("User32\GetClassInfoEx", "Ptr", hInstance := DllCall("Kernel32\GetModuleHandle", "Ptr", 0, "Ptr"), "Ptr", lpszClassName := StrPtr("IsometricLayer"), "Ptr", wndClassEx := Structure(cbSize := (A_PtrSize == 8) ? (80) : (48), True), "UInt")) {
		static CS_BYTEALIGNCLIENT := 0x00001000, CS_BYTEALIGNWINDOW := 0x00002000, CS_CLASSDC := 0x00000040, CS_DBLCLKS := 0x00000008, CS_DROPSHADOW := 0x00020000, CS_GLOBALCLASS := 0x00004000, CS_HREDRAW := 0x00000002, CS_NOCLOSE := 0x00000200, CS_OWNDC := 0x00000020, CS_PARENTDC := 0x00000080, CS_SAVEBITS := 0x00000800, CS_VREDRAW := 0x00000001

		wndClassEx.NumPut(0, "UInt", cbSize, "UInt", CS_HREDRAW | CS_VREDRAW, "Ptr", CallbackCreate((hWnd, uMsg, wParam, lParam) => (DllCall("User32\DefWindowProc", "Ptr", hWnd, "UInt", uMsg, "Ptr", wParam, "Ptr", lParam, "Ptr")), "F"), "Int", 0, "Int", 0, "Ptr", hInstance, "Ptr", 0, "Ptr", 0, "Ptr", 0, "Ptr", 0, "Ptr", lpszClassName, "Ptr", 0)

		if (!DllCall("User32\RegisterClassEx", "Ptr", wndClassEx.Ptr, "UShort")) {
			throw (ErrorFromMessage(DllCall("Kernel32\GetLastError")))
		}
	}

	static WS_EX_ACCEPTFILES := 0x00000010, WS_EX_APPWINDOW := 0x00040000, WS_EX_CLIENTEDGE := 0x00000200, WS_EX_COMPOSITED := 0x02000000, WS_EX_CONTEXTHELP := 0x00000400, WS_EX_CONTROLPARENT := 0x00010000, WS_EX_DLGMODALFRAME := 0x00000001, WS_EX_LAYERED := 0x00080000, WS_EX_LAYOUTRTL := 0x00400000, WS_EX_LEFT := 0x00000000, WS_EX_LEFTSCROLLBAR := 0x00004000, WS_EX_LTRREADING := 0x00000000, WS_EX_MDICHILD := 0x00000040, WS_EX_NOACTIVATE := 0x08000000, WS_EX_NOINHERITLAYOUT := 0x00100000, WS_EX_NOPARENTNOTIFY := 0x00000004, WS_EX_NOREDIRECTIONBITMAP := 0x00200000, WS_EX_OVERLAPPEDWINDOW := 0x00000300, WS_EX_PALETTEWINDOW := 0x00000188, WS_EX_RIGHT := 0x00001000, WS_EX_RIGHTSCROLLBAR := 0x00000000, WS_EX_RTLREADING := 0x00002000, WS_EX_STATICEDGE := 0x00020000, WS_EX_TOOLWINDOW := 0x00000080, WS_EX_TOPMOST := 0x00000008, WS_EX_TRANSPARENT := 0x00000020, WS_EX_WINDOWEDGE := 0x00000100
		, WS_BORDER := 0x00800000, WS_CAPTION := 0x00C00000, WS_CHILD := 0x40000000, WS_CHILDWINDOW := 0x40000000, WS_CLIPCHILDREN := 0x02000000, WS_CLIPSIBLINGS := 0x04000000, WS_DISABLED := 0x08000000, WS_DLGFRAME := 0x00400000, WS_GROUP := 0x00020000, WS_HSCROLL := 0x00100000, WS_ICONIC := 0x20000000, WS_MAXIMIZE := 0x01000000, WS_MAXIMIZEBOX := 0x00010000, WS_MINIMIZE := 0x20000000, WS_MINIMIZEBOX := 0x00020000, WS_OVERLAPPED := 0x00000000, WS_OVERLAPPEDWINDOW := 0x00CF0000, WS_POPUP := 0x80000000, WS_POPUPWINDOW := 0x80880000, WS_SIZEBOX := 0x00040000, WS_SYSMENU := 0x00080000, WS_TABSTOP := 0x00010000, WS_THICKFRAME := 0x00040000, WS_TILED := 0x00000000, WS_TILEDWINDOW := 0xCF0000, WS_VISIBLE := 0x10000000, WS_VSCROLL := 0x00200000

	if (!(hWnd := DllCall("User32\CreateWindowEx", "UInt", WS_EX_LAYERED | WS_EX_NOACTIVATE | WS_EX_TOOLWINDOW | WS_EX_TOPMOST | WS_EX_TRANSPARENT, "Ptr", lpszClassName, "Str", "NoFace", "UInt", (WS_CHILDWINDOW | WS_CLIPCHILDREN | WS_POPUPWINDOW) & ~(WS_CAPTION | WS_MAXIMIZEBOX | WS_MINIMIZEBOX | WS_SIZEBOX), "Int", x, "Int", y, "Int", width, "Int", height := width*0.5 + 32, "Ptr", hParent, "Ptr", 0, "Ptr", hInstance, "Ptr", 0, "Ptr"))) {
		throw (ErrorFromMessage(DllCall("Kernel32\GetLastError")))
	}

	instance := Window(hWnd, "IsometricLayer")

	instance.DC := GDI.CreateCompatibleDC()
		, instance.DC.SelectObject(GDI.CreateDIBSection(Structure.CreateBitmapInfoHeader(width, -height), instance.DC))

	instance.Graphics := GDIp.CreateGraphicsFromDC(instance.DC)
		, instance.Graphics.SetCompositingQuality(1), DllCall("Gdiplus\GdipSetPixelOffsetMode", "Ptr", instance.Graphics.Ptr, "Int", 4), instance.Graphics.SetInterpolationMode(7), instance.Graphics.SetSmoothingMode(4)

	instance.Point := Structure.CreatePoint(x, y, "UInt"), instance.Size := Structure.CreateSize(width, height), instance.Blend := Structure.CreateBlendFunction(0xFF)

	if (show) {
		instance.Show()
	}

	instance.Blocks := []

	loop (blocks := instance.Blocks, (width/32)**2) {
		blocks.Push(0)
	}

	return (instance)
}

CreateOverlay(x, y, width, height, hParent, show) {
	if (!DllCall("User32\GetClassInfoEx", "Ptr", hInstance := DllCall("Kernel32\GetModuleHandle", "Ptr", 0, "Ptr"), "Ptr", lpszClassName := StrPtr("IsometricOverlay"), "Ptr", wndClassEx := Structure(cbSize := (A_PtrSize == 8) ? (80) : (48), True), "UInt")) {
		static CS_BYTEALIGNCLIENT := 0x00001000, CS_BYTEALIGNWINDOW := 0x00002000, CS_CLASSDC := 0x00000040, CS_DBLCLKS := 0x00000008, CS_DROPSHADOW := 0x00020000, CS_GLOBALCLASS := 0x00004000, CS_HREDRAW := 0x00000002, CS_NOCLOSE := 0x00000200, CS_OWNDC := 0x00000020, CS_PARENTDC := 0x00000080, CS_SAVEBITS := 0x00000800, CS_VREDRAW := 0x00000001

		wndClassEx.NumPut(0, "UInt", cbSize, "UInt", CS_HREDRAW | CS_VREDRAW, "Ptr", CallbackCreate((hWnd, uMsg, wParam, lParam) => (DllCall("User32\DefWindowProc", "Ptr", hWnd, "UInt", uMsg, "Ptr", wParam, "Ptr", lParam, "Ptr")), "F"), "Int", 0, "Int", 0, "Ptr", hInstance, "Ptr", 0, "Ptr", 0, "Ptr", 0, "Ptr", 0, "Ptr", lpszClassName, "Ptr", 0)

		if (!DllCall("User32\RegisterClassEx", "Ptr", wndClassEx.Ptr, "UShort")) {
			throw (ErrorFromMessage(DllCall("Kernel32\GetLastError")))
		}
	}

	static WS_EX_ACCEPTFILES := 0x00000010, WS_EX_APPWINDOW := 0x00040000, WS_EX_CLIENTEDGE := 0x00000200, WS_EX_COMPOSITED := 0x02000000, WS_EX_CONTEXTHELP := 0x00000400, WS_EX_CONTROLPARENT := 0x00010000, WS_EX_DLGMODALFRAME := 0x00000001, WS_EX_LAYERED := 0x00080000, WS_EX_LAYOUTRTL := 0x00400000, WS_EX_LEFT := 0x00000000, WS_EX_LEFTSCROLLBAR := 0x00004000, WS_EX_LTRREADING := 0x00000000, WS_EX_MDICHILD := 0x00000040, WS_EX_NOACTIVATE := 0x08000000, WS_EX_NOINHERITLAYOUT := 0x00100000, WS_EX_NOPARENTNOTIFY := 0x00000004, WS_EX_NOREDIRECTIONBITMAP := 0x00200000, WS_EX_OVERLAPPEDWINDOW := 0x00000300, WS_EX_PALETTEWINDOW := 0x00000188, WS_EX_RIGHT := 0x00001000, WS_EX_RIGHTSCROLLBAR := 0x00000000, WS_EX_RTLREADING := 0x00002000, WS_EX_STATICEDGE := 0x00020000, WS_EX_TOOLWINDOW := 0x00000080, WS_EX_TOPMOST := 0x00000008, WS_EX_TRANSPARENT := 0x00000020, WS_EX_WINDOWEDGE := 0x00000100
		, WS_BORDER := 0x00800000, WS_CAPTION := 0x00C00000, WS_CHILD := 0x40000000, WS_CHILDWINDOW := 0x40000000, WS_CLIPCHILDREN := 0x02000000, WS_CLIPSIBLINGS := 0x04000000, WS_DISABLED := 0x08000000, WS_DLGFRAME := 0x00400000, WS_GROUP := 0x00020000, WS_HSCROLL := 0x00100000, WS_ICONIC := 0x20000000, WS_MAXIMIZE := 0x01000000, WS_MAXIMIZEBOX := 0x00010000, WS_MINIMIZE := 0x20000000, WS_MINIMIZEBOX := 0x00020000, WS_OVERLAPPED := 0x00000000, WS_OVERLAPPEDWINDOW := 0x00CF0000, WS_POPUP := 0x80000000, WS_POPUPWINDOW := 0x80880000, WS_SIZEBOX := 0x00040000, WS_SYSMENU := 0x00080000, WS_TABSTOP := 0x00010000, WS_THICKFRAME := 0x00040000, WS_TILED := 0x00000000, WS_TILEDWINDOW := 0xCF0000, WS_VISIBLE := 0x10000000, WS_VSCROLL := 0x00200000

	if (!(hWnd := DllCall("User32\CreateWindowEx", "UInt", WS_EX_LAYERED | WS_EX_NOACTIVATE | WS_EX_TOOLWINDOW | WS_EX_TOPMOST | WS_EX_TRANSPARENT, "Ptr", lpszClassName, "Str", "NoFace", "UInt", WS_CHILDWINDOW | WS_OVERLAPPEDWINDOW, "Int", x, "Int", y, "Int", width, "Int", height, "Ptr", hParent, "Ptr", 0, "Ptr", hInstance, "Ptr", 0, "Ptr"))) {
		throw (ErrorFromMessage(DllCall("Kernel32\GetLastError")))
	}

	instance := Window(hWnd, "IsometricOverlay")

	instance.DC := GDI.CreateCompatibleDC()
		, instance.DC.SelectObject(GDI.CreateDIBSection(Structure.CreateBitmapInfoHeader(width, -height), instance.DC, 0, &(pBits := 0)))

	instance.Graphics := GDIp.CreateGraphicsFromDC(instance.DC)
		, instance.Graphics.SetCompositingMode(1), instance.Graphics.SetCompositingQuality(1), DllCall("Gdiplus\GdipSetPixelOffsetMode", "Ptr", instance.Graphics.Ptr, "Int", 4), instance.Graphics.SetInterpolationMode(7), instance.Graphics.SetSmoothingMode(4)

	instance.Point := Structure.CreatePoint(x, y, "UInt"), instance.Size := Structure.CreateSize(width, height), instance.Blend := Structure.CreateBlendFunction(0xFF)
	return (instance)
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
			, window.Graphics.DrawBitmap(tile, node[0] - 16, node[1] - 7 - 32, 32, 32, 0, 0, width, width, 2, pImageAttributes)

		DllCall("Gdiplus\GdipDisposeImageAttributes", "Ptr", pImageAttributes)
	}
	else {
		window.Graphics.DrawBitmap(tiles[file], node[0] - 16, node[1] - 7 - 32, 32, 32)
	}

;	resized := GDIp.CreateBitmap(32, 16, 0x000E200B)
;	graphics := GDIp.CreateGraphicsFromBitmap(resized), graphics.SetInterpolationMode(7), graphics.SetSmoothingMode(4)
;		, graphics.DrawBitmap(tiles[file], 0, 0, 32, 16)
;
;	bitmap.LockBits()
;	resized.LockBits()
;
;	stride1 := resized.BitmapData.NumGet(8, "Int"), scan01 := resized.BitmapData.NumGet(16, "Ptr"), stride2 := bitmap.BitmapData.NumGet(8, "Int"), scan02 := bitmap.BitmapData.NumGet(16, "Ptr")
;		, reset := node[0], y := node[1] - 7
;
;	static height := [4, 8, 12, 16, 20, 24, 28, 32, 32, 28, 24, 20, 16, 12, 8, 4]
;
;	for index, pixels in height {
;		offset := pixels*0.5
;
;		DllCall("msvcrt\memcpy", "Ptr", scan02 + (reset - offset)*4 + (y + index)*stride2, "Ptr", scan01 + (16 - offset)*4 + index*stride1, "UInt", pixels*4)
;	}
;
;	bitmap.UnlockBits()
;	resized.UnlockBits()
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
		graphics.DrawBitmap(tile, node[0] - 16, node[1] - 7 - 16, 32, 32, 0, 0, width, width)
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
			, window.Graphics.DrawBitmap(block, node[0] - 16, node[1] - 7 - 32, 32, 32, 0, 0, width, height, 2, pImageAttributes)

		DllCall("Gdiplus\GdipDisposeImageAttributes", "Ptr", pImageAttributes)
	}
	else {
		window.Graphics.DrawBitmap(blocks[file], node[0] - 16, node[1] - 7 - 32, 32, 32)
	}

;	resized := GDIp.CreateBitmap(32, 32)
;	graphics := GDIp.CreateGraphicsFromBitmap(resized), graphics.SetCompositingMode(1), graphics.SetCompositingQuality(3), graphics.SetInterpolationMode(7), graphics.SetSmoothingMode(4)
;		, graphics.DrawBitmap(blocks[file], 0, 0, 32, 32, 0, 0, 64, 64, 2, imageAttributes := 0)
;
;	bitmap.LockBits()
;	resized.LockBits()
;
;	stride1 := resized.BitmapData.NumGet(8, "Int"), scan01 := resized.BitmapData.NumGet(16, "Ptr"), stride2 := bitmap.BitmapData.NumGet(8, "Int"), scan02 := bitmap.BitmapData.NumGet(16, "Ptr")
;		, reset := node[0], y := node[1] - 16 - 7
;
;	static height := [4, 8, 12, 16, 20, 24, 28, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 28, 24, 20, 16, 12, 8, 4]
;
;	if (IsSet(alpha)) {
;		for index, pixels in height {
;			offset := pixels*0.5
;
;			loop (x1 := 15 - offset, x2 := reset - offset, pixels) {
;				color := NumGet(scan01 + ++x1*4 + index*stride1, "UInt")
;
;				Numput("UInt", (Round((color >> 24)*alpha) << 24) | (color & 0x00FFFFFF), scan02 + ++x2*4 + (y + index)*stride2)
;			}
;		}
;	}
;	else {
;		for index, pixels in height {
;			offset := pixels*0.5
;
;			DllCall("msvcrt\memcpy", "Ptr", scan02 + (reset - offset)*4 + (y + index)*stride2, "Ptr", scan01 + (16 - offset)*4 + index*stride1, "UInt", pixels*4)
;		}
;	}
;
;	bitmap.UnlockBits()
;	resized.UnlockBits()
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

		window.Graphics.DrawBitmap(plane, node[0] - 16, node[1] - 7 - 16, 64, 64, 0, 0, width, width, 2, pImageAttributes)

		DllCall("Gdiplus\GdipDisposeImageAttributes", "Ptr", pImageAttributes)
	}
	else {
		window.Graphics.DrawBitmap(plane, node[0] - 16, node[1] - 7 - 16, 64, 64, 0, 0, width, width)
	}
}

;===============  Class  =======================================================;

class Window {

	__New(hWnd, className) {
		this.Handle := hWnd, this.Class := className
	}

	__Delete() {
		try {
			DllCall("User32\DestroyWindow", "Ptr", this.Handle)  ;~ If the specified window is a parent or owner window, DestroyWindow automatically destroys the associated child or owned windows when it destroys the parent or owner window. The function first destroys child or owned windows, and then it destroys the parent or owner window.
		}

		try {
			DllCall("User32\UnregisterClass", "Ptr", StrPtr(this.Class), "Ptr", 0)
		}
	}

	Rect[which := ""] {
		Get {
			static rect := Structure.CreateRect(0, 0, 0, 0, "Int")

			if (!(DllCall("User32\GetWindowRect", "Ptr", this.Handle, "Ptr", pointer := rect.Ptr, "UInt"))) {
				throw (ErrorFromMessage(DllCall("Kernel32\GetLastError")))
			}

			switch (which) {
				case "Width":
					return (NumGet(pointer + 8, "Int") - NumGet(pointer, "Int"))
				case "Height":
					return (NumGet(pointer + 12, "Int") - NumGet(pointer + 4, "Int"))
			}
		}
	}

	Width {
		Get {
			return (this.Rect["Width"])
		}
	}

	Height {
		Get {
			return (this.Rect["Height"])
		}
	}

	Show() {
		DllCall("User32\ShowWindow", "Ptr", this.Handle, "Int", 4)  ;: https://docs.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-showwindow
	}

	Hide() {
		DllCall("User32\ShowWindow", "Ptr", this.Handle, "Int", 0)
	}

	Update(x := unset, y := unset, width := unset, height := unset, alpha := unset) {
		if (IsSet(x)) {
			if (IsSet(y)) {
				this.Point.NumPut(0, "UInt", x, "UInt", y)
			}
			else {
				this.Point.NumPut(0, "UInt", x)
			}
		}
		else if (IsSet(y)) {
			this.Point.NumPut(4, "UInt", y)
		}

		if (IsSet(width)) {
			if (IsSet(height)) {
				this.Size.NumPut(0, "UInt", width, "UInt", height)
			}
			else {
				this.Size.NumPut(0, "UInt", width)
			}
		}
		else if (IsSet(height)) {
			this.Size.NumPut(4, "UInt", height)
		}

		if (IsSet(alpha)) {
			this.Blend.NumPut(2, "UChar", alpha)
		}

		if (!(DllCall("User32\UpdateLayeredWindow", "Ptr", this.Handle, "Ptr", 0, "Ptr", this.Point.Ptr, "Ptr", this.Size.Ptr, "Ptr", this.DC.Handle, "Int64*", 0, "UInt", 0, "Ptr", this.Blend.Ptr, "UInt", 0x00000002, "UInt"))) {
			throw (ErrorFromMessage(DllCall("Kernel32\GetLastError")))
		}
	}

	AddExStyle(exStyle) {
		DllCall("User32\SetWindowLongPtr", "Ptr", hWnd := this.Handle, "Int", -20, "Ptr", DllCall("User32\GetWindowLongPtr", "Ptr", hWnd, "Int", -20, "Ptr") | exStyle)  ;? -20 = GWL_EXSTYLE
	}

	RemoveExStyle(exStyle) {
		DllCall("User32\SetWindowLongPtr", "Ptr", hWnd := this.Handle, "Int", -20, "Ptr", DllCall("User32\GetWindowLongPtr", "Ptr", hWnd, "Int", -20, "Ptr") & ~(exStyle))
	}
}