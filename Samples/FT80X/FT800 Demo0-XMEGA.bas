' Demo Set 0
' FT800 platform.
' Original code http://www.ftdichip.com/Support/SoftwareExamples/EVE/FT800_SampleApp_1.0.zip
' Requires Bascom 2.0.7.8 or greater
$regfile = "xm128a1def.dat"
$crystal = 32000000
$hwstack = 80
$swstack = 80
$framesize = 350

Config Osc = Enabled , 32mhzosc = Enabled
Config Sysclock = 32mhz                                     '--> 32MHz

Config Com1 = 19200 , Mode = Asynchroneous , Parity = None , Stopbits = 1 , Databits = 8
Open "COM1:" For Binary As #1

Config Submode = New
$NOTYPECHECK
Config Base = 0

Config Ft800 = Spid , Ftsave = 0 , Ftdebug = 0 , Ftcs = Portd.4 , Ftpd = Portd.0  ' Olimex
Config Spid = Hard , Master = Yes , Mode = 0 , Clockdiv = Clk32 , Data_order = Msb , Ss = none

Declare Sub Screen (ByVal Characters As String)
Declare Sub Points
Declare Sub Line_s
Declare Sub Rectangles
Declare Sub Bitmap
Declare Sub BitmapPalette
Declare Sub Fonts
Declare Sub Text_8x8
Declare Sub Text_VGA
Declare Sub Bar_Graph
Declare Sub LineStrips
Declare Sub EdgeStrips
Declare Sub Scissor
Declare Sub Polygon
Declare Sub Cube
Declare Sub Ball_Stencil
Declare Sub FtdiString
Declare Sub StreetMap
Declare Sub AdditiveBlendText
Declare Sub MacroUsage
Declare Sub AdditiveBlendPoints

Declare Function Lerp (ByVal t As Single, ByVal a As Single, ByVal b As Single) As Long
Declare Function smoothlerp (ByVal t As Single, ByVal a As Single, ByVal b As Single) As Single

$Include "FT80x.inc"
$Include "FT80x_Functions.inc"

Spiinit

Dim Header_Format(3) As Byte
Dim Header_Width(3) As Integer
Dim Header_Height(3) As Integer
Dim Header_Stride(3) As Integer
Dim Header_Arrayoffset(3) As Long

Header_Format(0 + _base) = RGB565
Header_Width(0+_base) = 40
Header_Height(0+_base) = 40
Header_Stride(0+_base) = 80
Header_Arrayoffset(0+_base) = 0

Header_Format(1+_base) = PALETTED
Header_Width(1+_base) = 40
Header_Height(1+_base) = 40
Header_Stride(1+_base) = 40
Header_Arrayoffset(1+_base) = 0

Header_Format(2+_base) = PALETTED
Header_Width(2+_base) = 480
Header_Height(2+_base) = 272
Header_Stride(2+_base) = 480
Header_Arrayoffset(2+_base) = 0

' Type FT_Gpu_Fonts_t
' FT800 font table structure
' Font table address in ROM can be found by reading the address from 0xFFFFC location.
' 16 font tables are present at the address read from location 0xFFFFC

' Width of each character font from 0 to 127
Dim FontWidth (Ft_Numchar_Per_Font) As Byte
' Bitmap format of font wrt bitmap formats supported by FT800 - Bitmap_Fmt_L1, Bitmap_Fmt_L4, Bitmap_Fmt_L8
Dim FontBitmapFormat As Dword
' Font line stride in FT800 ROM
Dim FontLineStride As Dword
' Font width in pixels
Dim FontWidthInPixels As Dword
' Font height in pixels
Dim FontHeightInPixels As Dword
' Pointer to font graphics raw data
Dim PointerToFontGraphicsData As Dword

Dim Display_fontstruct As Byte At FontWidth(_base) Overlay

if FT800_Init()=1 Then END    ' Initialise the FT800

'<< Un-Rem any of the demo's, compile and run ! >>
'------------------------------
' Set 0  Demo's
'------------------------------
Screen "Set0 START"
  Points
  Line_s
  Rectangles
  Bitmap
  BitmapPalette
  Fonts
  Text_8x8
  Text_VGA
  Bar_graph
  LineStrips
'  EdgeStrips
'  Scissor
'  Polygon
'  Cube
'  Ball_Stencil
'  FtdiString
'  StreetMap
'  AdditiveBlendText
'  MacroUsage
'  AdditiveBlendPoints
Screen "Set0 END!"


End

'------------------------------------------------------------------------------------------------------------
Sub Screen (ByVal Characters As String)
'------------------------------------------------------------------------------------------------------------

   ClearColorRGB &HFF, &HFF, &HFF  ' background colour
   Clear_B 1, 1, 1

   ColorRGB &H80, &H80, &H00
   CmdText FT_DispWidth/2, FT_DispHeight/2, 31, OPT_CENTER, Characters

   UpdateScreen

   Wait 1

End Sub ' Screen

'------------------------------------------------------------------------------------------------------------
Sub Points
'------------------------------------------------------------------------------------------------------------

   ' Example code to display few points at various offsets with various colors
   ' Construct Display List of points

   Wr32 RAM_DL + 0 , _ClearColorRGB(128, 128, 128)
   Wr32 RAM_DL + 4 , _Clear_B(1,1,1)
   Wr32 RAM_DL + 8 , _ColorRGB (128, 0, 0)
   Wr32 RAM_DL + 12, _PointSize(5 * 16)
   Wr32 RAM_DL + 16, _Begin_G (FTPOINTS)
   Wr32 RAM_DL + 20, _VERTEX2F( FT_DispWidth / 5 * 16, FT_DispHeight / 2 * 16)
   Wr32 RAM_DL + 24, _ColorRGB (0, 128, 0)
   Wr32 RAM_DL + 28, _PointSize (15 * 16)
   Wr32 RAM_DL + 32, _VERTEX2F(FT_DispWidth * 2 / 5 * 16, FT_DispHeight / 2 * 16)
   Wr32 RAM_DL + 36, _ColorRGB (0, 0, 128)
   Wr32 RAM_DL + 40, _PointSize (25 * 16)
   Wr32 RAM_DL + 44, _VERTEX2F (FT_DispWidth * 3 / 5 * 16, FT_DispHeight / 2 * 16)
   Wr32 RAM_DL + 48, _ColorRGB (128, 128, 0)
   Wr32 RAM_DL + 52, _PointSize (35 * 16)
   Wr32 RAM_DL + 56, _VERTEX2F (FT_DispWidth * 4 / 5 * 16, FT_DispHeight / 2 * 16)
   Wr32 RAM_DL + 60, _Display_E()  ' display the image

   ' Do a swap
   DLSwap

   Wait 1

End Sub ' Points

'------------------------------------------------------------------------------------------------------------
Sub Line_s
'------------------------------------------------------------------------------------------------------------

   ClearScreen   ' Always use this on your Second line
   ColorRGB 128, 0, 0
   LineWidth 5 * 16

   Begin_G LINES

   Vertex2F (FT_DispWidth / 4) * 16, (FT_DispHeight - 25) / 2 * 16
   Vertex2F (FT_DispWidth / 4) * 16, (FT_DispHeight + 25) / 2 * 16
   ColorRGB 0, 128, 0
   LineWidth 10 * 16

   Vertex2F (FT_DispWidth * 2) / 4 * 16, (FT_DispHeight - 40) / 2 * 16
   Vertex2F (FT_DispWidth * 2) / 4 * 16, (FT_DispHeight + 40) / 2 * 16
   ColorRGB 128, 128, 0
   LineWidth 20 * 16

   Vertex2F (FT_DispWidth * 3) / 4 * 16, (FT_DispHeight - 55) / 2 * 16
   Vertex2F (FT_DispWidth * 3) / 4 * 16, (FT_DispHeight + 55) / 2 * 16

   UpdateScreen

   Wait 1

End Sub ' Lines

'------------------------------------------------------------------------------------------------------------
Sub Rectangles
'------------------------------------------------------------------------------------------------------------

   ClearScreen   ' Always use this on your Second line

   ColorRGB 0, 0, 128
   LineWidth 1 * 16 ' LINE_WIDTH is used for corner curvature

   Begin_G RECTS

   Vertex2F ((FT_DispWidth/4) - 2) * 16, ((FT_DispHeight - 25)/2) * 16
   Vertex2F ((FT_DispWidth/4) + 2) * 16, ((FT_DispHeight + 25)/2) * 16
   ColorRGB 0, 128, 0
   LineWidth 5 * 16

   Vertex2F ((FT_DispWidth * 2) / 4 - 5) * 16, (FT_DispHeight - 40) / 2 * 16
   Vertex2F ((FT_DispWidth * 2) / 4 + 5) * 16, (FT_DispHeight + 40) / 2 * 16
   ColorRGB 128, 128, 0
   LineWidth 10 * 16

   Vertex2F ((FT_DispWidth * 3) / 4 - 10) * 16, (FT_DispHeight - 55) / 2 * 16
   Vertex2F ((FT_DispWidth * 3) / 4 + 10) * 16, (FT_DispHeight + 55) / 2 * 16

   UpdateScreen

   Wait 1

End Sub  ' Rectangles

'------------------------------------------------------------------------------------------------------------
Sub Bitmap
'------------------------------------------------------------------------------------------------------------

   Local BMoffsetx As Integer
   Local BMoffsety As Integer
   Local Ln1 As Dword
   Local Ln2 As Dword

   ' Copy raw data into address 0 followed by generation of bitmap
   TempDW = Loadlabel(Bitmap_RawData)
   RdFlash_WrFT800 RAM_G, TempDW , Header_Stride(0+_base) * Header_Height(0+_base)

   ClearScreen

   ColorRGB 255, 255, 255
   BitmapSource RAM_G
   BitmapLayout  Header_Format(0+_base), Header_Stride(0+_base), Header_Height(0+_base)
   BitmapSize NEAREST, Border, Border, Header_Width(0+_base), Header_Height(0+_base)
   Begin_G BITMAPS ' start drawing bitmaps
   Const AW = (FT_DispWidth / 4)
   Ln1 = Header_Width(0+_base) / 2
   Const AX = FT_DispHeight / 2
   Ln2 = Header_Height(0+_base) / 2
   BMoffsetx = AW - Ln1
   BMoffsety = AX - Ln2
   Vertex2II BMoffsetx, BMoffsety, 0, 0
   ColorRGB 255, 64, 64  ' red At (200, 120)
   Const AY = FT_DispWidth * 2 / 4
   Const AZ = FT_DispHeight / 2
   BMoffsetx = AY - Ln1
   BMoffsety = AZ - Ln2
   Vertex2II BMoffsetx, BMoffsety, 0, 0
   ColorRGB 64, 180, 64 ' green At (216, 136)
   BMoffsetx = BMoffsetx + Ln1
   BMoffsety = BMoffsety + Ln2
   Vertex2II BMoffsetx, BMoffsety, 0, 0
   ColorRGB 255, 255, 64 ' transparent yellow At (232, 152)
   Color_A 150
   BMoffsetx = BMoffsetx + Ln1
   BMoffsety = BMoffsety + Ln2
   Vertex2II BMoffsetx, BMoffsety, 0, 0
   Color_A 255
   ColorRGB 255, 255, 255
   Vertex2F -10 * 16, -10 * 16 'For -ve coordinates use vertex2f instruction

   UpdateScreen

   Wait 1

End Sub ' Bitmap

'------------------------------------------------------------------------------------------------------------
Sub BitmapPalette
'------------------------------------------------------------------------------------------------------------

   Local BMoffsetx As Integer
   Local BMoffsety As Integer
   Local Ln1 As Dword
   Local Ln2 As Dword

   TempDW = Loadlabel(paletteraw)
   RdFlash_WrFT800 RAM_G,   TempDW , Header_Stride(1+_base) * Header_Height(1+_base)
   TempDW = Loadlabel(paletteLUT)
   RdFlash_WrFT800 RAM_PAL, TempDW , 1022

   ClearScreen
   ColorRGB 255, 255, 255
   BitmapSource RAM_G
   BitmapLayout Header_Format(1+_base), Header_Stride(1+_base), Header_Height(1+_base)
   BitmapSize NEAREST, Border, Border, Header_Width(1+_base), Header_Height(1+_base)
   Begin_G BITMAPS ' start drawing bitmaps
   Const DA = FT_DispWidth / 4
   Ln1 = Header_Width(1+_base) / 2
   Const DB = FT_DispHeight / 2
   Ln2 = Header_Height(1+_base) / 2
   BMoffsetx = DA - Ln1
   BMoffsety = DB - Ln2
   Vertex2II BMoffsetx, BMoffsety, 0, 0

   UpdateScreen

   Wait 1

End Sub ' BitmapPalette

'------------------------------------------------------------------------------------------------------------
Sub Fonts
'------------------------------------------------------------------------------------------------------------
' Inbuilt Font example For proportionate And non proportionate Text - hello world

   Local B As Byte
   Local i As byte
   Local j As byte
   Local hoffset As word
   Local voffset As word
   Local stringlen As byte
   Local FontTableAddress As Dword
   Local Display_string As String * 20

   Display_string = "Hello World"

   hoffset = FT_DispWidth - 100
   hoffset = hoffset / 2

   voffset = FT_DispHeight / 2

   ' Read the Font address From &HFFFFC location
   FontTableAddress = Rd32(&HFFFFC)
   stringlen = Len(Display_string)

   For i = 0 To 15

      ' Read the Font table From hardware
      TempDW = i * FT_FONT_TABLE_SIZE
      TempDW = TempDW  + FontTableAddress
      RdFT800_WrMem TempDW, Display_fontstruct, FT_FONT_TABLE_SIZE

      Clear_B 1, 1, 1 ' Clear Screen
      ColorRGB 255, 255, 255 ' Clear Screen

      ' Display String At the center Of Display
      Begin_G BITMAPS

      hoffset = FT_DispWidth - 120
      hoffset = hoffset / 2

      voffset = FT_DispHeight - FontHeightInPixels
      voffset = voffset / 2

      ' Display hello world by offsetting wrt char Size
      For j = 1 To stringlen
         B = Asc(Display_string, j)
         Vertex2II hoffset, voffset, i + 16, B
         hoffset = hoffset + FontWidth(B+_base)
      Next j

      UpdateScreen

      Wait 1

   Next i

End Sub ' Fonts

'------------------------------------------------------------------------------------------------------------
Sub Text_8x8
'------------------------------------------------------------------------------------------------------------
' Display text8x8 Of abcdefgh

   Local Text_Array As String * 10
   Local String_size As Long

   ' Write the Data into RAM_G
   Text_Array = "abcdefgh"
   String_size = Len(Text_Array)

   RdMem_WrFT800 RAM_G, varptr(Text_Array), String_size

   ClearScreen

   BitmapSource RAM_G
   BitmapLayout TEXT8X8, 8 , 1 ' Bitmap_Fmt_L1 format, Each Input Data element is in 1 byte size
   BitmapSize NEAREST, Border, REPEAT, 8 * 8, 8 * 2 ' Output Is 8x8 format - draw 8 characters In horizontal repeated In 2 Line

   Begin_G BITMAPS
   ' Display Text 8x8 At hoffset, voffset location
   VerteX2F 16 * 16, 16 * 16

   BitmapLayout TEXT8X8, 4, 2 ' Bitmap_Fmt_L1 format And Each datatype Is 1 Byte Size
   BitMapSize NEAREST, REPEAT, Border, 8 * 16, 8 * 2 ' Each character Is 8x8 In Size -  so draw 32 characters In horizontal And 32 characters In vertical
   VerteX2F (FT_DispWidth / 2) * 16, (FT_DispHeight / 2) * 16

   UpdateScreen

   Wait 1

End Sub ' Text_8x8

'------------------------------------------------------------------------------------------------------------
Sub Text_VGA
'------------------------------------------------------------------------------------------------------------
' Display textVGA Of Random values

   ' Write the Data into RAM_G
   Local String_size As Long
   Local i As Long
   Local Char As Dword
   Dim Text_Array(320) As Byte


   For i = 0 To 319
      Text_Array(i+_base) = Rnd(255)
   Next i

   'Char = VarPtr(Text_Array(0+_base))
   String_size = 320
   RdMem_WrFT800 RAM_G, Text_Array(_base), String_size

   ClearScreen
   BitmapSource RAM_G

   ' mandatory For textvga As background Color Is also one Of the parameter In textvga format
   BlendFunc ONE, ZERO

   'draw 8x8
   BitmapLayout TEXTVGA, 2 * 4, 8 'Bitmap_Fmt_L1 format, but Each Input Data element is of 2 bytes in size
   BitmapSize NEAREST, Border, Border, 8 * 8, 8 * 8 'Output Is 8x8 format - draw 8 characters In horizontal And 8 vertical
   Begin_G BITMAPS
   VerteX2F 32 * 16, 32 * 16
   End_G

   'draw textvga
   BitMapLayout TEXTVGA, 2 * 16, 8 'Bitmap_Fmt_L1 format but Each datatype Is 16Bit Size
   BitmapSize NEAREST, Border, REPEAT, 8 * 32, 8 * 32 '8 Pixels per character And 32 rows/colomns
   Begin_G BITMAPS
   ' Display textvga At hoffset, voffset location
   Vertex2F (FT_DispWidth / 2) * 16, (FT_DispHeight / 2) * 16
   End_G

   UpdateScreen

   Wait 1

End Sub ' Text_VGA

'------------------------------------------------------------------------------------------------------------
Sub Bar_Graph
'------------------------------------------------------------------------------------------------------------

   ' Write the Data into RAM_G
   Local String_size As Long
   Local i As Long
   Local tmpval As Long
   Local tmpidx As Long
   Local tmpL1 As Long
   Local tmpL2 As Long
   Dim Y_Array(512) As Byte


   For i = 0 To 511
      Y_Array(i+_base) = Rnd(128) + 64 'within range
   Next i

   String_size = 512
   RdMem_WrFT800 RAM_G, Y_Array(_base), String_size

   ClearColorRGB 255, 255, 255
   Clear_B 1, 1, 1
   BitmapSource RAM_G
   BitmapLayout BARGRAPH, 256, 1
   ColorRGB 128, 0, 0
   BitmapSize NEAREST, Border, Border, 256, 256
   Begin_G BITMAPS
   ' Display Text 8x8 At hoffset, voffset location
   Vertex2II 0, 0, 0, 0
   Vertex2II 256, 0, 0, 1

   UpdateScreen

   ' Download the DL into DL RAM

   Wait 1

   For i = 0 To 512
      ' tmpval = 128 + (i/3 * qsin(-65536 * i / 48 )) / 65536
      tmpidx = i
      tmpL1 = -65536 * i
      tmpL1 = tmpL1 /48
      tmpL2 = qsin(tmpL1)
      tmpL1 = i/3
      tmpL1 = tmpL1 * tmpL2
      tmpL1 = tmpL1 / 65536
      tmpval = tmpL1 + 128
      Y_Array(i+_base) = tmpval And &Hff
   Next i

   String_size = 512
   RdMem_WrFT800 RAM_G, Y_Array(_base), String_size

   Wait 1

   Clear_B 1, 1, 1 ' Clear Screen
   BitmapSource RAM_G
   BitmapLayout BARGRAPH, 256, 1
   BitmapSize NEAREST, Border, Border, 256, 256
   Begin_G BITMAPS
   ColorRGB 255, 0, 0
   ' Display bargraph At hoffset, voffset location
   Vertex2II 0, 0, 0, 0
   Vertex2II 256, 0, 0, 1
   ColorRGB 0, 0, 0
   Vertex2II 0, 4, 0, 0
   Vertex2II 256, 4, 0, 1

   UpdateScreen

   Wait 1

End Sub ' Bar_Graph

'------------------------------------------------------------------------------------------------------------
Sub LineStrips
'------------------------------------------------------------------------------------------------------------

   ClearColorRGB 5, 45, 10
   ColorRGB 255, 168, 64
   Clear_B 1 ,1 ,1
   Begin_G LINE_STRIP
   Vertex2F 16 * 16, 16 * 16
   Vertex2F (FT_DispWidth * 2 /3)  * 16, (FT_DispHeight * 2 / 3) * 16
   Vertex2F (FT_DispWidth - 80) * 16, (FT_DispHeight - 20) * 16

   UpdateScreen

   Wait 1

End Sub ' LineStrips

'------------------------------------------------------------------------------------------------------------
Sub EdgeStrips
'------------------------------------------------------------------------------------------------------------

   ClearColorRGB 5, 45, 10
   ColorRGB 255, 168, 64
   Clear_B 1 ,1 ,1
   Begin_G EDGE_STRIP_R
   Vertex2F 16 * 16, 16 * 16
   Vertex2F (FT_DispWidth * 2 / 3)  * 16, (FT_DispHeight * 2 / 3) * 16
   Vertex2F (FT_DispWidth - 80) * 16, (FT_DispHeight - 20) * 16

   UpdateScreen

   Wait 1

End Sub ' EdgeStrips

'------------------------------------------------------------------------------------------------------------
Sub Scissor
'------------------------------------------------------------------------------------------------------------

   Clear_B 1,1,1
   ScissorXY 40, 20 ' Scissor rectangle top Left At (40, 20)
   ScissorSize 40, 40 ' Scissor rectangle Is 40 x 40 Pixels
   ClearColorRGB 255, 255, 0 ' CLEER To yellow
   Clear_B 1, 1, 1

   UpdateScreen

   Wait 1

End Sub ' Scissor

'------------------------------------------------------------------------------------------------------------
Sub Polygon
'------------------------------------------------------------------------------------------------------------

   Clear_B 1, 1, 1 ' CLear Screen
   ColorRGB 255, 0, 0
   StencilOP Incrx, Incrx
   ColorMask 0,0,0,0 'mask All the colors
   Begin_G EDGE_STRIP_L
   Vertex2II FT_DispWidth / 2, FT_DispHeight / 4 , 0, 0
   Vertex2II FT_DispWidth * 4 / 5, FT_DispHeight * 4 / 5, 0, 0
   Vertex2II FT_DispWidth / 4, FT_DispHeight / 2 , 0, 0
   Vertex2II FT_DispWidth / 2, FT_DispHeight / 4, 0, 0
   End_G
   ColorMask 1,1,1,1 'Enable All the colors
   StencilFunc EQUAL,1,255
   Begin_G EDGE_STRIP_L
   Vertex2II FT_DispWidth, 0, 0, 0
   Vertex2II FT_DispWidth, FT_DispHeight,0,0
   End_G

   ' Draw Lines At the BORDERs To make sure anti aliazing Is also done
   StencilFunc ALWAYS, 0, 255
   LineWidth 1 * 16
   ColorRGB 0, 0, 0
   Begin_G Lines
   Vertex2II FT_DispWidth / 2, FT_DispHeight / 4, 0, 0
   Vertex2II (FT_DispWidth * 4) / 5, (FT_DispHeight * 4) /5, 0, 0
   Vertex2II (FT_DispWidth * 4) / 5, (FT_DispHeight * 4) /5, 0, 0
   Vertex2II FT_DispWidth / 4, FT_DispHeight / 2, 0, 0
   Vertex2II FT_DispWidth / 4, FT_DispHeight / 2, 0, 0
   Vertex2II FT_DispWidth / 2, FT_DispHeight / 4, 0, 0
   End_G

   UpdateScreen

   Wait 1

End Sub ' Polygon

'------------------------------------------------------------------------------------------------------------
Sub Cube
'------------------------------------------------------------------------------------------------------------

   Local cnt As Byte
   Local F0 As Integer, F1 As Integer, F2 As Integer, F3 As Integer, F4 As Integer, F5 As Integer, F6 As Integer
   Local x As Long, y As Long, i As Long, z As Long, f As Long, g As Long
   Local xoffset As Integer, yoffset As Integer, CubeEdgeSz As Integer

   Dim point(30)  As Long
   Dim colorsA(3) As Word
   Dim colorsB(3) As Word
   Dim colorsC(3) As Word
   Dim colorsD(3) As Word
   Dim colorsE(3) As Word
   Dim colorsF(3) As Word

   ' Color vertices
   colorsA(0+_base) = 255
   colorsA(1+_base) = 0
   colorsA(2+_base) = 0

   colorsB(0+_base) = 255
   colorsB(1+_base) = 0
   colorsB(2+_base) = 150

   colorsC(0+_base) = 0
   colorsC(1+_base) = 255
   colorsC(2+_base) = 0

   colorsD(0+_base) = 110
   colorsD(1+_base) = 120
   colorsD(2+_base) = 110

   colorsE(0+_base) = 0
   colorsE(1+_base) = 0
   colorsE(2+_base) = 255

   colorsF(0+_base) = 128
   colorsF(1+_base) = 128
   colorsF(2+_base) = 0

   ' Cube dimention Is Of 100 * 100 * 100
   CubeEdgeSz = 100
   xoffset = FT_DispWidth / 2
   xoffset = xoffset - CubeEdgeSz

   yoffset = FT_DispHeight - CubeEdgeSz
   yoffset = yoffset  / 2

   ' xy plane(front)
   point(0+_base) = _Vertex2F(xoffset * 16, yoffset * 16)
   F0 = xoffset + CubeEdgeSz
   F1 = yoffset + CubeEdgeSz
   point(1+_base) = _Vertex2F(F0 * 16, yoffset * 16)
   point(2+_base) = _Vertex2F(F0 * 16, F1 * 16)
   point(3+_base) = _Vertex2F(xoffset * 16, F1 * 16)
   point(4+_base) = point(0+_base)

   'yz plane (Left)
   F2 = CubeEdgeSz / 2
   x = xoffset + F2            ' xoff+w/2
   y = yoffset - F2            ' yoff-h/2

   F3 = y + CubeEdgeSz
   point(5+_base) = point(0+_base)
   point(6+_base) = _Vertex2F(x * 16, y * 16)
   point(7+_base) = _Vertex2F(x * 16, F3 * 16)
   point(8+_base) = point(3+_base)
   point(9+_base) = point(5+_base)

   'xz plane(top)
   F4  = x + CubeEdgeSz
   point(10+_base) = point(0+_base)
   point(11+_base) = point(1+_base)
   point(12+_base) = _Vertex2F( F4 * 16, y * 16)
   point(13+_base) = point(6+_base)
   point(14+_base) = point(10+_base)

   'xz plane(bottom)
   point(15+_base) = point(3+_base)
   point(16+_base) = point(2+_base)
   point(17+_base) = _Vertex2F(F4 * 16, F3 * 16)
   point(18+_base) = point(7+_base)
   point(19+_base) = point(15+_base)

   'yz plane (Right)
   point(20+_base) = point(2+_base)
   point(21+_base) = point(17+_base)
   point(22+_base) = point(12+_base)
   point(23+_base) = point(1+_base)
   point(24+_base) = point(20+_base)

   'yz plane (back)
   point(25+_base) = point(6+_base)
   point(26+_base) = point(7+_base)
   point(27+_base) = point(17+_base)
   point(28+_base) = point(12+_base)
   point(29+_base) = point(25+_base)

   Clear_B 1, 1, 1
   LineWidth 16
   ClearColorRGB 255, 255, 255
   Clear_B 1, 1, 1
   ColorRGB 255, 255, 255

   ' Draw a cube
   StencilOP Incrx, Incrx
   Color_A 192

   For z = 0 To 5

      Clear_B 0, 1, 1         ' Clear Stencil buffer
      ColorMask 0, 0, 0, 0    ' Mask All the colors And draw one surface
      StencilFunc ALWAYS, 0, 255  ' Stencil Function To increment All the values
      Begin_G EDGE_STRIP_L

      For i = 0 To 4
         cnt = z * 5
         cnt = cnt + i
         Cmd32 point(cnt+_base)
      Next

      End_G
      ' Set the Color And draw a strip
      ColorMask 1, 1, 1, 1
      StencilFunc EQUAL, 1 , 255

      Select Case z
         Case 0
            ColorRGB colorsA(0+_base), colorsA(1+_base), colorsA(2+_base)
         Case 1
            ColorRGB colorsB(0+_base), colorsB(1+_base), colorsB(2+_base)
         Case 2
            ColorRGB colorsC(0+_base), colorsC(1+_base), colorsC(2+_base)
         Case 3
            ColorRGB colorsD(0+_base), colorsD(1+_base), colorsD(2+_base)
         Case 4
            ColorRGB colorsE(0+_base), colorsE(1+_base), colorsE(2+_base)
         Case 5
            ColorRGB colorsF(0+_base), colorsF(1+_base), colorsF(2+_base)
      End Select

      F5 = CubeEdgeSz * 2 : F5=F5 + xoffset
      F6 = CubeEdgeSz * 2 : F6=F6 + yoffset
      Begin_G RECTS
      Vertex2II xoffset, 0, 0, 0
      Vertex2II F5, F6, 0, 0

      End_G
   Next

   UpdateScreen

   Wait 1

End Sub ' Cube

'------------------------------------------------------------------------------------------------------------
Sub Ball_Stencil
'------------------------------------------------------------------------------------------------------------
   ' First draw points followed by Lines To Create 3d ball kind Of effect
   Local xball As Integer, yball As Integer, rball As Integer, numpoints As Integer, numlines As Integer
   Local i As Integer, asize As Integer, aradius As Integer, gridsize As Integer
   Local asmooth As Long, loopflag As Long, dispa As Long, dispr As Long, displ As Long, Temp1 As Long, Temp2 As Long
   Local dispb As Long, xflag As Long, yflag As Long, tempsmooth As Long
   Local TempDB As Single

   xball   = FT_DispWidth/2
   yball   = 120
   rball   = FT_DispWidth/8
   numpoints = 6
   numlines= 8
   gridsize= 20
   dispr   = FT_DispWidth - 10
   displ   = 10
   dispa   = 10
   dispb   = FT_DispHeight - 10
   xflag   = 1
   yflag   = 1

   Temp1 = dispr - displ
   Temp2 = Temp1 Mod gridsize
   dispr = dispr - Temp2

   Temp1 = dispb - dispa
   Temp2 = Temp1 Mod gridsize
   dispb = dispb - Temp2

   ' Write the Play sound
   Wr16 Reg_Sound, &H50

   loopflag = 100

   While loopflag > 0

      Temp1 = xball + rball
      Temp1 = Temp1 + 2
      Temp2 = xball - rball
      Temp2 = Temp2 - 2
      If Temp1 >= dispr Or Temp2 <= displ Then
         xflag = xflag Xor 1
         Wr8 Reg_Play, 1
      End If

      Temp1 = yball + rball
      Temp1 = Temp1 + 8
      Temp2 = yball - rball
      Temp2 = Temp2 - 8

      If Temp1 >= dispb Or Temp2 <= dispa Then
         yflag = yflag Xor 1
         Wr8 Reg_Play, 1
      End If

      If xflag > 0 Then
         xball = xball + 2
      Else
         xball = xball - 2
      End If

      If yflag > 0  Then
         yball = yball + 8
      Else
         yball = yball - 8
      End If

      ClearColorRGB 128, 128, 0
      Clear_B 1, 1, 1   ' Clear Screen
      StencilOP IncrX, IncrX
      ColorRGB 0, 0, 0
      ' draw grid
      LineWidth 16
      Begin_G LINES

      Temp1 = dispr - displ
      Temp1 = Temp1 / gridsize

      For i = 0 To Temp1
         Temp2 = gridsize * i
         Temp2 = Temp2 + displ
         Vertex2F Temp2 * 16, dispa * 16
         Vertex2F Temp2 * 16, dispb * 16
      Next i

      Temp1 = dispb - dispa
      Temp1 = Temp1 / gridsize

      For i = 0 To Temp1
         Temp2 =  gridsize * i
         Temp2 = Temp2 + dispa
         Vertex2F displ * 16, Temp2 * 16
         Vertex2F dispr * 16, Temp2 * 16
      Next i

      End_G
      ColorMask 0, 0, 0, 0 'mask All the colors
      PointSize rball * 16
      Begin_G FTPOINTS
      Vertex2F xball * 16, yball * 16
      StencilOP Incrx, Zero
      StencilFunc GEQUAL, 1, 255
      ' one side points

      For i = 1 To numpoints
         asize = i * rball
         asize = asize * 2
         Temp1 = numpoints + 1
         asize = asize / Temp1

         TempDB = 2 * rball
         Temp2 = TempDB
         TempDB = asize / TempDB
         asmooth = smoothlerp(TempDB, 0, Temp2)

         If asmooth > rball Then
            'change the offset To -ve
            tempsmooth = asmooth - rball
            Temp1 = rball * rball
            Temp2 = tempsmooth * tempsmooth
            Temp1 = Temp1 + Temp2
            Temp2 = 2 * tempsmooth
            aradius = Temp1 / Temp2
            PointSize aradius * 16
            Temp1 = xball - aradius
            Temp1 = Temp1 + tempsmooth
            Vertex2F Temp1 * 16, yball * 16

         Else
            tempsmooth = rball - asmooth
            Temp1 = rball * rball
            Temp2 = tempsmooth * tempsmooth
            Temp1 = Temp1 + Temp2
            Temp2 = 2 * tempsmooth
            aradius = Temp1 / Temp2
            PointSize aradius * 16
            Temp1 = xball+ aradius
            Temp1 = Temp1 - tempsmooth
            Vertex2F Temp1 * 16, yball * 16
         End If
      Next i

      End_G
      Begin_G LINES

      ' draw Lines - Line should be At least radius diameter
      For i = 1 To numlines
         Temp1 = i * rball
         Temp1 = Temp1 * 2
         Temp1 = Temp1 / numlines
         asize = Temp1


         TempDB = 2 * rball
         Temp2 = TempDB
         TempDB = asize / TempDB

         asmooth = smoothlerp (TempDB, 0 , Temp2)
         LineWidth asmooth * 16
         Temp1 = xball - rball
         Temp2 = yball - rball
         Vertex2F Temp1 * 16, Temp2 * 16
         Temp1 = xball + rball
         Temp2 = yball - rball
         Vertex2F Temp1 * 16, Temp2 * 16

      Next i

      End_G
      ColorMask 1, 1, 1, 1 ' Enable All the colors
      StencilFunc ALWAYS, 1, 255
      StencilOP KEEP, KEEP
      ColorRGB 255, 255, 255
      PointSize rball * 16
      Begin_G FTPOINTS
      Temp1 = xball - 1
      Temp2 = yball - 1
      Vertex2F Temp1 * 16, Temp2 * 16
      ColorRGB 0, 0, 0 ' shadow
      Color_A 160
      Temp1 = xball + 16
      Temp2 = yball + 8
      Vertex2F Temp1 * 16, Temp2 * 16
      Color_A 255
      ColorRGB 255, 255, 255
      Vertex2F xball * 16, yball * 16
      ColorRGB 255, 0, 0
      StencilFunc GEQUAL, 1, 1
      StencilOP KEEP, KEEP
      Vertex2F xball * 16, yball * 16
      End_G

      UpdateScreen

      Waitms 30

      Decr loopflag

   Wend

End Sub ' Ball_Stencil

'------------------------------------------------------------------------------------------------------------
Function Lerp (ByVal t As Single, ByVal a As Single, ByVal b As Single) As Long
'------------------------------------------------------------------------------------------------------------

   Local TempS As Single

   TempS = 1 - t
   TempS = TempS * a

   TempS = TempS + t
   TempS = TempS * b

   Lerp = TempS

End Function ' Lerp
'------------------------------------------------------------------------------------------------------------
Function smoothlerp (ByVal t As Single, ByVal a As Single, ByVal b As Single) As Single
'------------------------------------------------------------------------------------------------------------

   Local TempS As Single
   Local TempT As Single

   TempS = 3 * t
   TempS = TempS * t

   TempT = 2 * t
   TempT = TempT * t
   TempT = TempT * t

   smoothlerp = lerp (TempS-TempT, a, b)

End Function ' smoothlerp

'------------------------------------------------------------------------------------------------------------
Sub FtdiString
'------------------------------------------------------------------------------------------------------------

   Local hoffset As Integer, voffset As Integer, PointSz As Integer

   voffset = FT_DispHeight - 49 '49 Is the Max height of inbuilt Font Handle 31
   voffset = voffset / 2

   hoffset = FT_DispWidth - 144
   hoffset = hoffset / 2
   PointSz = 20
   hoffset = hoffset + PointSz

   Wr32 RAM_DL + 0, _Clear_B(1, 1, 1) ' Clear Screen
   Wr32 RAM_DL + 4, _Begin_G(BITMAPS) ' start drawing bitmaps
   Wr32 RAM_DL + 8, _Vertex2II (hoffset, voffset, 31, 70) ' ascii F in font 31
   hoffset = hoffset + 24
   Wr32 RAM_DL + 12, _Vertex2II (hoffset, voffset, 31, 84) ' ascii T
   hoffset = hoffset + 26
   Wr32 RAM_DL + 16, _Vertex2II (hoffset, voffset, 31, 68) ' ascii D
   hoffset = hoffset + 29
   Wr32 RAM_DL + 20, _Vertex2II (hoffset, voffset, 31, 73) ' ascii I
   Wr32 RAM_DL + 24, _End_G()
   Wr32 RAM_DL + 28, _ColorRGB (160, 22, 22) ' change Color To red
   Wr32 RAM_DL + 32, _PointSize(PointSz * 16) ' Set Point Size
   hoffset = FT_DispWidth - 144
   hoffset = hoffset / 2
   Wr32 RAM_DL + 36, _Begin_G (FTPOINTS)  ' start drawing points
   Wr32 RAM_DL + 40, _Vertex2II (hoffset, FT_DispHeight / 2, 0, 0)  ' red Point
   Wr32 RAM_DL + 44, _End_G()
   Wr32 RAM_DL + 48, _Display_E() ' Display the image
   DLSwap

   Wait 2

End Sub ' FtdiString

'------------------------------------------------------------------------------------------------------------
Sub StreetMap
'------------------------------------------------------------------------------------------------------------

   ' Call And Function Example - simple graph

   ClearColorRGB 236, 232, 224 'light gray
   Clear_B 1, 1, 1
   ColorRGB 170, 157, 136 'medium gray
   LineWidth 63
   Call_C 19 ' draw the streets
   ColorRGB 250, 250, 250 'white
   LineWidth 48
   Call_C 19 'draw the streets
   ColorRGB 0, 0, 0
   Begin_G BITMAPS
   Vertex2II 240,91,27,77 'draw 'Main st.' At (240,91)
   Vertex2II 252,91,27,97
   Vertex2II 260,91,27,105
   Vertex2II 263,91,27,110
   Vertex2II 275,91,27,115
   Vertex2II 282,91,27,116
   Vertex2II 286,91,27,46
   End_G
   Display_E
   Begin_G  Lines
   Vertex2F -160,-20
   Vertex2F 320,4160
   Vertex2F 800,-20
   Vertex2F 1280,4160
   Vertex2F 1920,-20
   Vertex2F 2400,4160
   Vertex2F 2560,-20
   Vertex2F 3040,4160
   Vertex2F 3200,-20
   Vertex2F 3680,4160
   Vertex2F 2880,-20
   Vertex2F 3360,4160
   Vertex2F -20,0
   Vertex2F 5440,-480
   Vertex2F -20,960
   Vertex2F 5440,480
   Vertex2F -20,1920
   Vertex2F 5440,1440
   Vertex2F -20,2880
   Vertex2F 5440,2400
   End_G
   Return_C

   UpdateScreen

   Wait 2

End Sub ' StreetMap

'------------------------------------------------------------------------------------------------------------
Sub AdditiveBlendText
'------------------------------------------------------------------------------------------------------------

   ' Usage of Additive Blending - Draw 3 'G's

   Clear_B 1, 1, 1 ' Clear Screen
   Begin_G BITMAPS
   Vertex2II 50, 30, 31, &H47
   Color_A 128
   Vertex2II 58, 38, 31, &H47
   Color_A  64
   Vertex2II 66, 46, 31, &H47
   End_G

   UpdateScreen

   Wait 1

End Sub ' AdditiveBlendText

'------------------------------------------------------------------------------------------------------------
Sub MacroUsage
'------------------------------------------------------------------------------------------------------------
   ' Usage Of Macro

   Local xoffset As Long, yoffset As Long, xflag As Long, yflag As Long, flagloop As Long
   Local Temp1 As Integer

   ' Local p_bmhdr As SAMAPP_Bitmap_header_t

   xflag = 1
   yflag = 1
   flagloop = 1

   xoffset = FT_DispWidth / 3
   yoffset = FT_DispHeight / 2

   ' First Write a valid Macro instruction into macro0
   Wr32 REG_MACRO_0, _Vertex2F(xoffset * 16, yoffset * 16)

   TempDW = Loadlabel(Bitmap_RawData)
   RdFlash_WrFT800 RAM_G, TempDW, Header_Stride(0+_base) * Header_Height(0+_base)

   Clear_B 1, 1, 1 ' Clear Screen
   BitmapSource RAM_G
   BitmapLayout  Header_Format(0+_base), Header_Stride(0+_base), Header_Height(0+_base)
   BitmapSize NEAREST, Border, Border, Header_Width(0+_base), Header_Height(0+_base)

   Begin_G BITMAPS ' start drawing %BITMAPS
   Macro_R 0 ' draw the image At (100,120)
   End_G

   UpdateScreen

   flagloop = 300

   While flagloop > 0
      Temp1 =  xoffset + Header_Width(0+_base)
      If  Temp1 >= FT_DispWidth Or xoffset <= 0 Then
         xflag  = xflag Xor 1
      End If

      Temp1 = yoffset + Header_Height(0+_base)
      If Temp1 >= FT_DispHeight Or yoffset <= 0 Then
         yflag = yflag Xor 1
      End If

      If xflag > 0 Then
         Incr xoffset
      Else
         Decr xoffset
      End If

      If yflag > 0 Then
         Incr yoffset
      Else
         Decr yoffset
      End If

       '  update just the Macro
      Wr32 REG_MACRO_0, _Vertex2F(xoffset * 16, yoffset * 16)
      Waitms 10
      Decr flagloop
   Wend

End Sub ' MacroUsage

'------------------------------------------------------------------------------------------------------------
Sub AdditiveBlendPoints
'------------------------------------------------------------------------------------------------------------
   ' Additive blending Of points - 1000 points

   Local i As Long, hoffset As Long, voffset As Long, flagloop As Long ,j As Long
   Local hdiff As Long, vdiff As Long, PointSz As Long, t As Long
   Local Temp1 As Long, Temp2 As Long, Temp3 As Integer, Temp4 As Integer

   PointSz = 4
   flagloop = 20

   While flagloop > 0

      Clear_B 1, 1, 1  ' Clear Screen
      ColorRGB 20, 91, 20 ' green Color For additive blending
      BlendFunc SRC_ALPHA, ONE 'Input Is Source alpha And destination Is whole Color
      PointSize PointSz * 16
      Begin_G FTPOINTS

      ' First 100 Random values
      For i = 0 To 99
         hoffset = Rnd(FT_DispWidth)
         voffset = Rnd(FT_DispHeight)
         Vertex2F hoffset * 16, voffset * 16
      Next i

      ' Next 480 are sine values Of two cycles
      For i = 0 To 159
         ' i is x offset, y is sinwave
         hoffset = i * 3

         Temp1 = FT_DispWidth / 6
         Temp2 = -65536 * i
         Temp2 = Temp2 / Temp1
         Temp1 = qsin(Temp2)

         Temp2 = FT_DispHeight / 2
         Temp2 = Temp2 * Temp1
         Temp2 = Temp2 / 65536
         Temp1 = FT_DispHeight / 2
         Temp2 = Temp2 + Temp1
         voffset = Temp2

         Vertex2F hoffset * 16, voffset * 16

         For j = 0 To 3
            Temp3 = Rnd(24)
            hdiff = Temp3 - 12
            Temp4 = Rnd(24)
            vdiff = Temp4 - 12
            Temp1 = hoffset + hdiff
            Temp2 = voffset + vdiff
            Vertex2F Temp1 * 16, Temp2 * 16
         Next

      Next

      End_G

      UpdateScreen

      Waitms 10

      Decr flagloop
   Wend

End Sub ' AdditiveBlendPoints

'------------------------------------------------------------------------------------------------------------

$inc Bitmap_RawData, nosize, "Bitmap_RawData.raw"       ' used in SUB Bitmap and SUB MacroUsage
$inc paletteraw, nosize, "lenaface40_palette.raw"       ' used in SUB BitmapPalette
$inc paletteLUT, nosize, "lenaface40_palette_LUT.raw"   ' used in SUB BitmapPalette