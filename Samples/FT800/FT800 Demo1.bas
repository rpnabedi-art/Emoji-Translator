' Demo Set 1
' FT800 platform.
' Original code http://www.ftdichip.com/Support/SoftwareExamples/EVE/FT800_SampleApp_1.0.zip
' Requires Bascom 2.0.7.8 or greater

$Regfile = "M328pdef.dat"
$Crystal = 8000000
$Baud = 19200
$HwStack = 120
$SwStack = 120
$FrameSize = 400
$NOTYPECHECK

Config ft800=spi , ftsave=0, ftdebug=0 , ftcs=portb.2, ftpd=portb.1

Config Base = 0
Config Submode = New
Config Spi = Hard, Interrupt = Off, Data_Order = Msb, Master = Yes, Polarity = Low, Phase = 0, Clockrate = 4, Noss = 1
SPSR = 1  ' Makes SPI run at 8Mhz instead of 4Mhz

Declare Sub Screen (ByVal Characters As String)
Declare Sub Logo
Declare Sub Calibrate1
Declare Sub Calibrate2
Declare Sub Touch
Declare Sub Widget_Clock
Declare Sub Widget_Gauge
Declare Sub Widget_Gradient
Declare Sub Widget_Keys
Declare Sub Widget_Keys_Interactive
Declare Sub Widget_Progressbar
Declare Sub Widget_Scroll
Declare Sub Widget_Slider
Declare Sub Widget_Dial
Declare Sub Widget_Toggle
Declare Sub Widget_Spinner
Declare Sub PowerMode
Declare Sub Fadein
Declare Sub FadeOut
Declare Sub PlayMuteSound
Declare Sub PowerModeSwitch (Byval pwrmode AS LONG)

$Include "FT800.inc"
$Include "FT800_Functions.inc"

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
' Bitmap format of font wrt bitmap formats supported by FT800 - L1, L4, L8
Dim FontBitmapFormat As Dword
' Font line stride in FT800 ROM
Dim FontLineStride As Dword
' Font width in pixels
Dim FontWidthInPixels As Dword
' Font height in pixels
Dim FontHeightInPixels As Dword
' Pointer to font graphics raw data
Dim PointerToFontGraphicsData As Dword

Dim Display_fontstruct As Byte At FontWidth(1) Overlay

if FT800_Init()=1 then  END    ' Initialise the FT800

$include "screenshot.inc"

   '<< Un-Rem each demo to view ! >>
'------------------------------
   ' Set 1  Demo's
'------------------------------

 '  Screen "Set1 START"
  ' Logo
Calibrate1
'   Calibrate2
'   Touch
   Widget_Clock
'   Widget_Gauge
'   Widget_Gradient
'   Widget_Keys
'   Widget_Keys_Interactive
'   Widget_Progressbar
'   Widget_Scroll
'   Widget_Slider
 '  Widget_Dial
'   Widget_Toggle
'   Widget_Spinner
PowerMode
   Screen "Set1 END!"

Do
Loop

End

'------------------------------------------------------------------------------------------------------------
Sub Screen (ByVal Characters As String)
'------------------------------------------------------------------------------------------------------------

   ClearColorRGB &HFF, &HFF, &HFF  ' background colour
   Clear_B 1, 1, 1

   ColorRGB &H80, &H80, &H00
   CmdText FT_DispWidth/2, FT_DispHeight/2, 31, OPT_CENTER, Characters

   UpdateScreen

End Sub ' Screen

'------------------------------------------------------------------------------------------------------------
Sub Logo
'------------------------------------------------------------------------------------------------------------

   Local TempW As Word

   CmdLogo

   WaitCmdFifoEmpty

   Do
      TempW = Rd16(REG_CMD_WRITE)
   Loop Until TempW = 0

   ClearFifoPtr ' Always run this after the Logo has finished its demo.

   WaitCmdFifoEmpty

End Sub ' Logo

'------------------------------------------------------------------------------------------------------------
Sub Calibrate1
'------------------------------------------------------------------------------------------------------------

   TouchCal

End Sub ' Calibrate

'------------------------------------------------------------------------------------------------------------
Sub Calibrate2
'------------------------------------------------------------------------------------------------------------
   'Make your own custom message

   CmdDlStart
   ClearScreen
   CmdText FT_DispWidth/2, FT_DispHeight/2, 26, OPT_CENTERX OR OPT_CENTERY, "Please tap on dot"
   CmdCalibrate
   UpdateScreen

End Sub ' Calibrate2

'------------------------------------------------------------------------------------------------------------
Sub Touch
'------------------------------------------------------------------------------------------------------------
'  API To explain the usage Of touch engine

   Local wbutton As Long, hbutton As Long, tagval As Long, tagoption As Long
   Local ReadWord As Dword, Tmp As Dword
   Local xvalue As Integer, yvalue As Integer, pendown As Integer, TempI As Integer '<--- temporari
   Local StringArray As String * 50
   Local Temp1 As Integer, Temp2 As Integer

   '***********************************************************************
   ' Below Code demonstrates the usage Of touch function. Display info
   ' touch raw, touch Screen, touch tag, raw adc And resistance values
   '***********************************************************************

   wbutton = FT_DispWidth / 8
   hbutton = FT_DispHeight / 8

   Do

      ClearScreen
      ColorRGB 255, 255, 255
      TagMask 0

      ' Touch Raw XY
      ReadWord = Rd32 (REG_TOUCH_RAW_XY)
      yvalue = ReadWord And &Hffff
      Tmp = ReadWord
      Shift Tmp, Right,16
      xvalue = Tmp And &Hffff
      StringArray = "Touch Raw XY (" + Str(xvalue) + "," + Str(yvalue) + ")"
      CmdText FT_DispWidth / 2, 10, 26, OPT_CENTER, StringArray

      ' Touch RZ
      ReadWord = 0
      ReadWord = Rd16(REG_TOUCH_RZ)
      StringArray = "Touch RZ (" + Str(ReadWord) + ")"
      CmdText FT_DispWidth / 2, 25, 26, OPT_CENTER, StringArray

      ReadWord = Rd32(REG_TOUCH_SCREEN_XY)
      yvalue =  ReadWord And &Hffff
      Tmp = ReadWord
      Shift Tmp, Right,16
      xvalue =  Tmp And &Hffff
      StringArray = "Touch Screen XY (" + Str(xvalue) + "," + Str(yvalue) + ")"
      CmdText FT_DispWidth / 2, 40, 26, OPT_CENTER, StringArray

      ReadWord = 0
      ReadWord = Rd8(REG_TOUCH_TAG)
      StringArray = "Touch TAG (" + Str(ReadWord) + ")"
      CmdText FT_DispWidth / 2, 55, 26, OPT_CENTER, StringArray

      tagval = ReadWord
      ReadWord = Rd32 (REG_TOUCH_DIRECT_XY)
      yvalue = ReadWord And &H03ff
      Tmp = ReadWord
      Shift Tmp, Right, 16
      xvalue = Tmp And &H03ff
      Shift ReadWord, Right, 31
      pendown = ReadWord And &H01
      StringArray = "Touch Direct XY (" + Str(xvalue) + "," + Str(yvalue) + "," + Str(pendown) + ")"
      CmdText FT_DispWidth/2, 70, 26, OPT_CENTER, StringArray

      ReadWord = Rd32(REG_TOUCH_DIRECT_Z1Z2)
      yvalue = ReadWord And &H03ff
      Tmp = ReadWord
      Shift Tmp, Right, 16
      xvalue = Tmp And &H03ff
      StringArray = "Touch Direct Z1Z2 (" + Str(xvalue) + "," + Str(yvalue) + ")"
      CmdText FT_DispWidth/2, 85, 26, OPT_CENTER, StringArray

      CmdFgColor &H008000
      TagMask 1

      Tag 12
      tagoption = 0
      If tagval = 12 Then tagoption = OPT_FLAT
      Const Y4 = FT_DispWidth / 4
      Const Y2 = FT_DispHeight * 2 / 4
      Temp1 = wbutton / 2
      Temp2 = hbutton / 2
      CmdButton Y4 - Temp1, Y2 - Temp2, wbutton, hbutton, 26, tagoption, "Tag12"

      Tag 13
      tagoption = 0
      If tagval = 13 Then tagoption = OPT_FLAT
      Const Y3 = FT_DispWidth * 3 / 4
      Const Y8 = FT_DispHeight * 3 / 4
      CmdButton Y3 - Temp1, Y8 - Temp2, wbutton, hbutton, 26, tagoption, "Tag13"

      CmdFgColor &H000080
      Tag 14
      If tagval = 14 Then Exit Do
      CmdButton Y4 - Temp1, Y8 - Temp2, wbutton, hbutton, 26, 0, "EXIT"

      UpdateScreen

      waitms 30

   Loop

End Sub ' Touch

'------------------------------------------------------------------------------------------------------------
Sub Widget_Clock
'------------------------------------------------------------------------------------------------------------
   ' API To demonstrate clock widget

   '***********************************************************************
   ' Below Code demonstrates the usage Of clock function. Clocks can be
   ' constructed Using flat Or 3d effect. Clock background And foreground
   ' colors can be Set by gbcolor And colorrgb. Clock can be constructed
   ' With multiple options such As no background, no needles, no pointer.
   '***********************************************************************

   Local xOffset As Integer, yOffset As Integer, cRadius As Word, xDistBtwClocks As Integer
   Local Tempi As Long, Tempj As Long
   Local Tempx As Dword

   xDistBtwClocks = FT_DispWidth / 5
   cRadius = xDistBtwClocks / 2
   Tempi = FT_DispWidth / 64
   cRadius = cRadius - Tempi

   ' Download the Bitmap Data for lena faced clock
   TempX = Loadlabel(Bitmap_RawData)
   RdFlash_WrFT800 RAM_G, TempX , Header_Stride(0+_base) * Header_Height(0+_base)

   ' Draw clock With blue As background And read As needle Color
   CmdDlstart
   ClearColorRGB 64, 64, 64
   Clear_B 1, 1, 1
   ColorRGB 255, 255, 255

   xOffset = xDistBtwClocks / 2
   yOffset = cRadius + 5

    ' flat effect And Default, blue bg
   CmdBgColor &H0000ff
   ColorRGB &Hff, &H00, &H00
   CmdClock xOffset, yOffset, cRadius, OPT_FLAT, 30, 100, 5, 10
   Tempi = yOffset + cRadius
   Tempi = Tempi + 6
   CmdText  xOffset, Tempi, 26, OPT_CENTER, "Flat effect" ' Text info

   ' no seconds needle, green bg
   CmdBgColor &H00ff00
   ColorRGB &Hff, &H00, &H00
   CmdFgColor &Hff0000
   xOffset = xOffset + xDistBtwClocks
   CmdClock xOffset, yOffset, cRadius, OPT_NOSECS, 10, 10, 5, 10
   Color_A 255
   CmdText xOffset, Tempi, 26, OPT_CENTER, "No Secs" ' Text info

   ' no background Color
   CmdBgColor &H00ffff
   ColorRGB &Hff, &Hff, &H00
   xOffset =  xOffset + xDistBtwClocks
   CmdClock xOffset, yOffset, cRadius, OPT_NOBACK, 10, 10, 5, 10
   CmdText  xOffset, Tempi, 26, OPT_CENTER, "No BG" ' Text info

   ' No ticks, purple bg
   CmdBgColor &Hff00ff
   ColorRGB &H00, &Hff, &Hff
   xOffset = xOffset + xDistBtwClocks
   CmdClock xOffset, yOffset, cRadius, OPT_NOTICKS, 10, 10, 5, 10
   CmdText  xOffset, Tempi, 26, OPT_CENTER, "No Ticks" ' Text info

   ' No hands, grey bg
   CmdBgColor &H808080
   ColorRGB &H00, &Hff, &H00
   xOffset = xOffset + xDistBtwClocks
   CmdClock xOffset, yOffset, cRadius, OPT_NOHANDS, 10, 10, 5, 10
   CmdText  xOffset, Tempi, 26, OPT_CENTER, "No Hands" ' Text info

   ' Bigger clock
   Tempi = cRadius + 10
   yOffset = yOffset + Tempi
   Tempi = 2 * cRadius
   Tempi = Tempi + 15
   cRadius = FT_DispHeight - Tempi
   Tempi = cRadius - 25
   cRadius = Tempi / 2
   xOffset = cRadius + 10
   yOffset = yOffset + cRadius
   yOffset = yOffset + 5
   ColorRGB &H00, &H00, &Hff
   CmdClock xOffset, yOffset, cRadius, 0, 10, 10, 5, 10

   Tempi = 2 * cRadius
   xOffset = xOffset + Tempi
   xOffset = xOffset + 10

   ' Lena clock With no background And no ticks
   LineWidth 10 * 16
   ColorRGB &Hff, &Hff, &Hff
   Begin_G RECTS

   Tempi = xOffset - cRadius
   Tempi = Tempi + 10
   Tempi = Tempi * 16
   Tempj = yOffset - cRadius
   Tempj = Tempj + 10
   Tempj = Tempj * 16
   Vertex2F Tempi, Tempj

   Tempi = xOffset + cRadius
   Tempi = Tempi - 10
   Tempi = Tempi * 16
   Tempj = yOffset + cRadius
   Tempj = Tempj - 10
   Tempj = Tempj * 16
   Vertex2F Tempi, Tempj
   End_G

   Color_A &Hff
   ColorRGB &Hff, &Hff, &Hff
   ColorMask 0, 0, 0, 1
   Clear_B 1, 1, 1
   Begin_G RECTS

   Tempi = xOffset - cRadius
   Tempi = Tempi + 12
   Tempi = Tempi * 16
   Tempj = yOffset - cRadius
   Tempj = Tempj + 12
   Tempj = Tempj * 16
   Vertex2F Tempi, Tempj

   Tempi = xOffset + cRadius
   Tempi = Tempi - 12
   Tempi = Tempi * 16
   Tempj = yOffset + cRadius
   Tempj = Tempj - 12
   Tempj = Tempj * 16
   Vertex2F Tempi, Tempj
   End_G

   ColorMASK 1, 1, 1, 1
   BlendFunc DST_ALPHA, ONE_MINUS_DST_ALPHA

   ' Lena Bitmap - Scale proportionately wrt Output resolution
   Tempi = 65536 * 2
   Tempi = Tempi * cRadius
   Tempi = Tempi / Header_Width(0+_base)

   Tempj = 65536 * 2
   Tempj = Tempj * cRadius
   Tempj = Tempj / Header_Height(0+_base)
   CmdScale Tempi, Tempj

   CmdSetMatrix
   Begin_G BITMAPS
   BitmapSource 0
   BitmapLayout Header_Format(0+_base) , Header_Stride(0+_base) , Header_Height(0+_base)
   BitmapSize BILINEAR, BORDER, BORDER, cRadius * 2,  cRadius * 2

   Tempi = xOffset - cRadius
   Tempi = Tempi * 16
   Tempj = yOffset - cRadius
   Tempj = Tempj * 16
   Vertex2F Tempi, Tempj
   End_G

   BlendFunc SRC_ALPHA, ONE_MINUS_SRC_ALPHA

   CmdSetMatrix
   ColorRGB &Hff, &Hff, &Hff
   CmdClock xOffset, yOffset, cRadius, OPT_NOTICKS Or OPT_NOBACK, 10, 10, 5, 10

   UpdateScreen

   Wait 2

End Sub ' Widget_Clock

'------------------------------------------------------------------------------------------------------------
Sub Widget_Gauge
'------------------------------------------------------------------------------------------------------------
   ' API To demonstrate guage widget

   '***********************************************************************
   ' Below Code demonstrates the usage Of gauge function. Gauge can be
   ' constructed Using flat Or 3d effect. Gauge background And foreground
   ' colors can be Set by gbcolor And colorrgb. Gauge can be constructed
   ' With multiple options such As no background, no minors/majors And
   ' no pointer.
   '***********************************************************************

   Local xOffset As Integer, yOffset As Integer, cRadius As Integer, xDistBtwClocks As Integer
   Local Tempi As Long, Tempj As Long
   Local Tempx As Dword

   xDistBtwClocks = FT_DispWidth / 5
   cRadius = xDistBtwClocks / 2
   Tempi = FT_DispWidth / 64
   cRadius = cRadius - Tempi

   ' Download the Bitmap Data for lena faced clock
   TempX = Loadlabel(Bitmap_RawData)
   RdFlash_WrFT800 RAM_G, TempX , Header_Stride(0+_base) * Header_Height(0+_base)

   ' Draw clock With blue As background And read As needle Color
   CmdDlstart
   ClearColorRGB 64, 64, 64
   Clear_B 1, 1, 1
   ColorRGB 255, 255, 255

   xOffset = xDistBtwClocks / 2
   yOffset = cRadius + 5

    ' flat effect And Default, blue bg
   CmdBgColor &H0000ff
   ColorRGB &Hff, &H00, &H00
   CmdGauge xOffset, yOffset, cRadius, OPT_FLAT, 5, 4, 45, 100
   Tempi = yOffset + cRadius
   Tempi = Tempi + 6
   CmdText  xOffset, Tempi, 26, OPT_CENTER, "Flat effect" ' Text info

   ' no seconds needle, green bg
   CmdBgColor &H00ff00
   ColorRGB &Hff, &H00, &H00
   CmdFgColor &Hff0000
   xOffset = xOffset + xDistBtwClocks
   CmdGauge xOffset, yOffset, cRadius, 0, 5, 1, 60, 100
   Color_A 255
   CmdText xOffset, Tempi, 26, OPT_CENTER, "3d effect" ' Text info

   ' no background Color
   CmdBgColor &H00ffff
   ColorRGB &Hff, &Hff, &H00
   xOffset =  xOffset + xDistBtwClocks
   CmdGauge xOffset, yOffset, cRadius, OPT_NOBACK, 1, 6, 90, 100
   CmdText  xOffset, Tempi, 26, OPT_CENTER, "No BG" ' Text info

   ' No ticks, purple bg
   CmdBgColor &Hff00ff
   ColorRGB &H00, &Hff, &Hff
   xOffset = xOffset + xDistBtwClocks
   CmdGauge xOffset, yOffset, cRadius, OPT_NOTICKS, 5, 4, 20, 100
   CmdText  xOffset, Tempi, 26, OPT_CENTER, "No Ticks" ' Text info

   ' No hands, grey bg
   CmdBgColor &H808080
   ColorRGB &H00, &Hff, &H00
   xOffset = xOffset + xDistBtwClocks
   CmdGauge xOffset, yOffset, cRadius, OPT_NOHANDS,  5, 4, 55, 100
   CmdText  xOffset, Tempi, 26, OPT_CENTER, "No Hands" ' Text info

   ' Bigger Gauge
   Tempi = cRadius + 10
   yOffset = yOffset + Tempi
   Tempi = 2 * cRadius
   Tempi = Tempi + 15
   cRadius = FT_DispHeight - Tempi
   Tempi = cRadius - 25
   cRadius = Tempi / 2
   xOffset = cRadius + 10
   yOffset = yOffset + cRadius
   yOffset = yOffset + 5

   CmdBgColor &H808000
   ColorRGB &Hff, &Hff, &Hff
   CmdGauge xOffset, yOffset, cRadius, OPT_NOPOINTER, 5, 4, 80, 100
   ColorRGB &Hff, &H00, &H00
   CmdGauge xOffset, yOffset, cRadius, OPT_NOTICKS Or OPT_NOBACK, 5, 4, 30, 100

   Tempi = 2 * cRadius
   xOffset = xOffset + Tempi
   xOffset = xOffset + 10

   ' Lena clock With no background And no ticks
   PointSize cRadius * 16
   ColorRGB &Hff, &Hff, &Hff
   Begin_G FTPOINTS
   Vertex2F xOffset * 16, yOffset * 16
   End_G
   Color_A &Hff
   ColorRGB &Hff, &Hff, &Hff
   ColorMask 0, 0, 0, 1
   Clear_B 1, 1, 1
   Begin_G FTPOINTS
   Tempi = cRadius - 2
   Tempi = Tempi * 16
   PointSize Tempi
   Vertex2F xOffset * 16, yOffset * 16
   End_G
   ColorMASK 1, 1, 1, 1
   BlendFunc DST_ALPHA, ONE_MINUS_DST_ALPHA

   ' Lena Bitmap - Scale proportionately wrt Output resolution
   Tempi = 65536 * 2
   Tempi = Tempi * cRadius
   Tempi = Tempi / Header_Width(0+_base)

   Tempj = 65536 * 2
   Tempj = Tempj * cRadius
   Tempj = Tempj / Header_Height(0+_base)
   CmdScale Tempi, Tempj
   CmdSetMatrix

   Begin_G BITMAPS
   BitmapSource 0
   BitmapLayout Header_Format(0+_base) , Header_Stride(0+_base) , Header_Height(0+_base)
   BitmapSize BILINEAR, BORDER, BORDER, 2 * cRadius, 2 * cRadius
   Tempi = xOffset - cRadius
   Tempi = Tempi * 16
   Tempj = yOffset - cRadius
   Tempj = Tempj * 16
   Vertex2F Tempi, Tempj
   End_G
   BlendFunc SRC_ALPHA, ONE_MINUS_SRC_ALPHA
   CmdSetMatrix
   ColorRGB &Hff, &Hff, &Hff
   CmdGauge xOffset, yOffset, cRadius, OPT_NOTICKS Or OPT_NOBACK, 5, 4, 30, 100

   UpdateScreen

   Wait 2

End Sub ' Widget_Gauge

'------------------------------------------------------------------------------------------------------------
Sub Widget_Gradient
'------------------------------------------------------------------------------------------------------------
   ' API To demonstrate gradient widget

   '***********************************************************************
   ' Below Code demonstrates the usage Of gradient function. Gradient func
   ' can be used To construct three effects - horizontal, vertical And
   ' diagonal effects.
   '***********************************************************************

   Local wScissor As Integer, hScissor As Integer, xOffset As Integer, yOffset As Integer
   Local Tempi As Integer, Tempj As Integer

   wScissor = FT_DispWidth - 40
   wScissor = wScissor / 3

   hScissor = FT_DispHeight - 60
   hScissor = hScissor / 2

   xOffset = 10
   yOffset = 20

   ' Draw gradient
   CmdDlstart
   ClearColorRGB 64, 64, 64
   Clear_B 1, 1, 1
   ColorRGB 255, 255, 255
   ScissorSize wScissor, hScissor
   ' Horizontal gradient effect
   ScissorXY xOffset, yOffset ' Clip the Display
   CmdGradient xOffset, yOffset, &H808080, xOffset + wScissor, yOffset, &Hffff00
   ' Vertical gradient effect
   xOffset =  xOffset + wScissor
   xOffset = xOffset  + 10
   ScissorXY xOffset, yOffset ' Clip the Display
   CmdGradient xOffset, yOffset, &Hff0000, xOffset, yOffset + hScissor, &H00ff00
   ' diagonal gradient effect
   xOffset = xOffset + wScissor
   xOffset = xOffset + 10
   ScissorXY xOffset, yOffset ' Clip the Display
   CmdGradient xOffset, yOffset, &H800000, xOffset + wScissor, yOffset + hScissor, &Hffffff
    ' Diagonal gradient With Text info
   xOffset = 10
   yOffset = yOffset + hScissor
   yOffset = yOffset + 20
   ScissorSize wScissor, 30
   Tempi = hScissor / 2
   Tempi = Tempi + yOffset
   Tempi = Tempi - 15
   ScissorXY xOffset, Tempi ' Clip the Display
   Tempj = hScissor / 2
   Tempj = Tempi + yOffset
   Tempj = Tempi + 15
   CmdGradient xOffset, Tempi, &H606060, xOffset + wScissor, Tempj, &H404080
   Tempi = wScissor / 2
   Tempi = Tempi + xOffset
   Tempj = hScissor / 2
   Tempj = Tempj + yOffset
   CmdText Tempi, Tempj, 28, OPT_CENTER, "Heading 1" ' Text info

   ' Draw horizontal, vertical And diagonal With alpha
   xOffset = xOffset + wScissor
   xOffset = xOffset + 10
   ScissorSize wScissor, hScissor
   ScissorXY xOffset, yOffset ' Clip the Display
   CmdGradient xOffset, yOffset, &H808080, xOffset + wScissor, yOffset, &Hffff00
   wScissor = wScissor - 30
   hScissor = hScissor - 30
   ScissorSize wScissor, hScissor
   xOffset = xOffset + 15
   yOffset = yOffset + 15
   ScissorXY xOffset, yOffset 'Clip the Display
   CmdGradient xOffset, yOffset, &H800000, xOffset, yOffset + hScissor, &Hffffff
   wScissor = wScissor - 30
   hScissor = hScissor - 30
   ScissorSize wScissor, hScissor
   xOffset = xOffset + 15
   yOffset = yOffset + 15
   ScissorXY xOffset, yOffset ' Clip the Display
   CmdGradient xOffset, yOffset, &H606060, xOffset + wScissor, yOffset + hScissor, &H404080

   ' Display the Text wrt gradient
   wScissor = FT_DispWidth - 40
   wScissor = wScissor / 3

   hScissor = FT_DispHeight - 60
   hScissor = hScissor / 2

   xOffset = wScissor / 2
   xOffset = xOffset + 10

   yOffset = 25 + hScissor
   yOffset = yOffset + 5

   ScissorXY 0,0 'Set To Default values
   ScissorSize 512, 512
   CmdText xOffset, yOffset, 26, OPT_CENTER, "Horizontal grad" ' Text info
   xOffset = xOffset + wScissor
   xOffset = xOffset + 10
   CmdText xOffset, yOffset, 26, OPT_CENTER, "Vertical grad" ' Text info
   xOffset = xOffset + wScissor
   xOffset = xOffset + 10
   CmdText xOffset, yOffset, 26, OPT_CENTER, "Diagonal grad" ' Text info

   UpdateScreen

   Wait 2

End Sub ' Widget_Gradient

'------------------------------------------------------------------------------------------------------------
Sub Widget_Keys
'------------------------------------------------------------------------------------------------------------
   ' API To demonstrate keys widget

   '***********************************************************************
   ' Below Code demonstrates the usage Of keys function. keys Function
   ' draws buttons With characters given As Input parameters. Keys support
   ' Flat And 3D effects, draw At (x,y) coordinates Or center Of the Display
   ' inbuilt Or Custom fonts can be used For Key Display
   '***********************************************************************

   Local TextFont As Integer, Tempi As Integer
   Local ButtonW As Integer, ButtonH As Integer, yBtnDst As Integer, yOffset As Integer, xOffset As Integer

   TextFont = 29
   ButtonW = 30
   ButtonH = 30
   yBtnDst = 5

   #If WQVGA = 0
      TextFont = 27
      ButtonW = 22
      ButtonH = 22
      yBtnDst = 3
   #EndIf

   CmdDlstart
   ClearColorRGB 64, 64, 64
   Clear_B 1, 1, 1
   ColorRGB &Hff, &Hff, &Hff
   ' Draw keys With flat effect
   CmdFgColor &H404080
   CmdKeys 10, 10, 4 * ButtonW, 30, TextFont, OPT_FLAT, "ABCD"
   CmdText 10, 45, 26, 0, "Flat effect" ' Text info
   ' Draw keys With 3d effect
   CmdFgColor  &H800000
   xOffset = 4 * ButtonW
   xOffset = xOffset + 20
   CmdKeys xOffset, 10, 4 * ButtonW, 30, TextFont, 0, "ABCD"
   CmdText xOffset, 45, 26, 0, "3D effect" ' Text info
   ' Draw keys With center option
   CmdFgColor &Hffff000
   Tempi = 4 * ButtonW
   Tempi = Tempi + 20
   xOffset = xOffset + Tempi
   CmdKeys xOffset, 10, FT_DispWidth - 230, 30, TextFont, OPT_CENTER, "ABCD"
   CmdText xOffset, 45, 26, 0, "Option Center" ' Text info

   yOffset = 80 + 10
    ' Construct a simple keyboard - note that the tags associated With the keys are the character values given In the arguments
   CmdFgColor &H404080
   CmdGradColor &H00ff00
   CmdKeys yBtnDst, yOffset, 10 * ButtonW, ButtonH, TextFont, OPT_CENTER, "qwertyuiop"
   CmdGradColor &H00ffff
   yOffset = yOffset + ButtonH
   yOffset = yOffset + yBtnDst
   CmdKeys yBtnDst, yOffset, 10 * ButtonW, ButtonH, TextFont, OPT_CENTER, "asdfghijkl"
   CmdGradColor &Hffff00
   yOffset = yOffset + ButtonH
   yOffset = yOffset + yBtnDst
   CmdKeys yBtnDst, yOffset, 10 * ButtonW, ButtonH, TextFont, OPT_CENTER Or Asc("z"), "zxcvbnm" 'higlight button z
   yOffset = yOffset + ButtonH
   yOffset = yOffset + yBtnDst
   CmdButton yBtnDst, yOffset, 10 * ButtonW, ButtonH, TextFont, OPT_CENTER, " " ' mandatory To give '\0' at the end to make sure coprocessor understands the string end
   yOffset = 80 + 10
   CmdKeys 11 * ButtonW, yOffset, 3 * ButtonW, ButtonH, TextFont, 0, "789"
   yOffset = yOffset + ButtonH
   yOffset = yOffset + yBtnDst
   CmdKeys 11 * ButtonW, yOffset, 3 * ButtonW, ButtonH, TextFont, 0, "456"
   yOffset = yOffset + ButtonH
   yOffset = yOffset + yBtnDst
   CmdKeys 11 * ButtonW, yOffset, 3 * ButtonW, ButtonH, TextFont, 0, "123"
   yOffset = yOffset + ButtonH
   yOffset = yOffset + yBtnDst
   Color_A 255
   CmdKeys 11 * ButtonW, yOffset, 3 * ButtonW, ButtonH, TextFont, (0 Or Asc("0")), "0." 'higlight button 0

   UpdateScreen

   Wait 2

End Sub ' Widget_Keys

'------------------------------------------------------------------------------------------------------------
Sub Widget_Keys_Interactive
'------------------------------------------------------------------------------------------------------------

   '***********************************************************************
   ' Below Code demonstrates the usage Of keys function. keys Function
   ' draws buttons With characters given As Input parameters. Keys support
   ' Flat And 3D effects, draw At (x,y) coordinates Or center Of the Display
   ' , inbuilt Or Custom fonts can be used For Key Display
   '***********************************************************************

   Local loopflag As Integer, TextFont As Integer, ButtonW As Integer, ButtonH As Integer, yBtnDst As Integer
   Local yOffset As Integer, xOffset As Integer
   Local CurrTag As Byte, PrevTag As Byte, Pendown As Byte
   Local CurrTextIdx As Long
   Local Tmp As Dword
   Local DispText As String * 25

   TextFont = 29
   ButtonW  = 30
   ButtonH  = 30
   yBtnDst  = 5
   CurrTag = 0
   PrevTag = 0
   Pendown = 1
   CurrTextIdx = 0
   DispText = ""

   #If WQVGA = 0
      TextFont = 27
      ButtonW = 22
      ButtonH = 22
      yBtnDst = 3
   #EndIf


   Do

      ' Check the user Input And Then add the characters into Array
      CurrTag = Rd8(REG_TOUCH_TAG)
      Tmp = Rd32(REG_TOUCH_DIRECT_XY)
      Shift Tmp, Right, 32

      Pendown = Tmp
      Pendown = Pendown And &H01

      ' check whether pwndown has happened
      If CurrTag <> 0 Then
         Incr CurrTextIdx
         DispText = DispText + Chr(CurrTag)
         ' Clear All the charaters after 100 are pressed

         If CurrTag = "*" Then Exit Do

         If CurrTextIdx > 24 Then
            DispText = ""
            CurrTextIdx = 0
         End If
      End If

      CmdDlstart
      ClearColorRGB 64, 64, 64
      Clear_B 1, 1, 1
      ColorRGB &Hff, &Hff, &Hff

      CmdText 20, FT_DispHeight - 30, 23, 0, "Press * key to exit"

      ' Draw Text entered by user
      TagMask 0
      CmdText FT_DispWidth / 2, 40, TextFont, OPT_CENTER, DispText ' Text info
      TagMask 1

      yOffset = 80 + 10
      ' Construct a simple keyboard - note that the tags associated With the keys are the character values given In the arguments
      CmdFgColor &H404080
      CmdGradColor &H00ff00
      CmdKeys  yBtnDst, yOffset, 10 * ButtonW, ButtonH, TextFont, OPT_CENTER Or CurrTag, "qwertyuiop"
      CmdGradColor &H00ffff
      yOffset = yOffset + ButtonH
      yOffset = yOffset + yBtnDst
      CmdKeys  yBtnDst, yOffset, 10 * ButtonW, ButtonH, TextFont, OPT_CENTER Or CurrTag, "asdfghjkl"
      CmdGradColor &Hffff00
      yOffset = yOffset + ButtonH
      yOffset = yOffset + yBtnDst
      CmdKeys yBtnDst, yOffset, 10 * ButtonW, ButtonH, TextFont, OPT_CENTER Or CurrTag, "zxcvbnm"
      yOffset = yOffset + ButtonH
      yOffset = yOffset + yBtnDst
      Tag 32 ' Space

      If CurrTag = 32 Then ' Space
         ' mandatory To give '\0' at the end to make sure coprocessor understands the string end
         CmdButton yBtnDst, yOffset, 10 * ButtonW, ButtonH, TextFont, OPT_CENTER Or OPT_FLAT, " "
      Else
         ' mandatory To give '\0' at the end to make sure coprocessor understands the string end
         CmdButton yBtnDst, yOffset, 10 * ButtonW, ButtonH, TextFont, OPT_CENTER , "space"
      End If

      yOffset = 80 + 10
      CmdKeys 11 * ButtonW, yOffset, 3 * ButtonW, ButtonH, TextFont, CurrTag, "789"
      yOffset = yOffset + ButtonH
      yOffset = yOffset + yBtnDst
      CmdKeys 11 * ButtonW, yOffset, 3 * ButtonW, ButtonH, TextFont, CurrTag, "456"
      yOffset = yOffset + ButtonH
      yOffset = yOffset + yBtnDst
      CmdKeys 11 * ButtonW, yOffset, 3 * ButtonW, ButtonH, TextFont, CurrTag, "123"
      yOffset = yOffset + ButtonH
      yOffset = yOffset + yBtnDst
      Color_A 255
      CmdKeys 11 * ButtonW, yOffset, 3 * ButtonW, ButtonH, TextFont, CurrTag, "0.*" ' higlight button 0

      UpdateScreen

      Waitms 100
      PrevTag = CurrTag

   Loop

End Sub ' Widget_Keys_Interactive

'------------------------------------------------------------------------------------------------------------
Sub Widget_Progressbar
'------------------------------------------------------------------------------------------------------------
   ' API To demonstrate progress bar widget

   '***********************************************************************
   ' Below Code demonstrates the usage Of progress function. Progress func
   ' draws Process bar With fgcolor For the % completion And bgcolor For
   ' % remaining. Progress bar supports flat And 3d effets
   '***********************************************************************

   Local xOffset As Integer, yOffset As Integer, yDist As Integer, ySz As Integer

   yDist = FT_DispWidth / 12
   ySz   = FT_DispWidth / 24

   CmdDlstart
   ClearColorRGB 64, 64, 64
   Clear_B 1, 1, 1
   ColorRGB &Hff, &Hff, &Hff
   ' Draw progress bar With flat effect
   ColorRGB &Hff, &Hff, &Hff
   CmdBgColor &H404080
   CmdProgress 20, 10, 120, 20, OPT_FLAT, 50, 100 'note that h/2 will be added On both sides Of the progress bar
   Color_A 255
   CmdText 20, 40, 26, 0, "Flat effect" ' Text info
   ' Draw progress bar With 3d effect
   ColorRGB &H00, &Hff, &H00
   CmdBgColor &H800000
   CmdProgress 180, 10, 120, 20, 0, 75, 100
   Color_A 255
   CmdText 180, 40, 26, 0, "3D effect" ' Text info
   ' Draw progress bar With 3d effect And String On top
   ColorRGB &Hff, &H00, &H00
   CmdBgColor &H000080
   CmdProgress 30, 60, 120, 30, 0, 19660, 65535
   ColorRGB &Hff, &Hff, &Hff
   CmdText 78, 68, 26, 0, "30 %" ' Text info

   xOffset = 20
   yOffset = 120
   ColorRGB &H00, &Ha0, &H00
   CmdBgColor &H800000
   CmdProgress xOffset, yOffset, 150, ySz, 0, 10, 100
   CmdBgColor &H000080
   yOffset = yOffset + yDist
   CmdProgress xOffset, yOffset, 150, ySz, 0, 40, 100
   CmdBgColor &Hffff00
   yOffset = yOffset + yDist
   CmdProgress  xOffset, yOffset, 150, ySz, 0, 70, 100
   CmdBgColor &H808080
   yOffset = yOffset + yDist
   CmdProgress xOffset, yOffset, 150, ySz, 0, 90, 100

   CmdText xOffset + 180, 70, 26, 0, "40 % TopBottom" ' Text info
   CmdProgress xOffset + 180, 100, ySz, 150, 0, 40, 100

   UpdateScreen

   Wait 2

End Sub ' Widget_Progressbar

'------------------------------------------------------------------------------------------------------------
Sub Widget_Scroll
'------------------------------------------------------------------------------------------------------------
   ' API To demonstrate Scroll widget

   '***********************************************************************
   ' Below Code demonstrates the usage Of Scroll function. Scroll Function
   ' draws Scroll bar With fgcolor For inner Color And current location And
   ' can be given by Val parameter
   '***********************************************************************

   Local xOffset As Integer, yOffset As Integer, xDist As Integer, yDist As Integer, wSz As Integer

   xDist = FT_DispWidth / 12
   yDist = FT_DispWidth / 12

   CmdDlstart
   ClearColorRGB 64, 64, 64
   Clear_B 1, 1, 1
   ColorRGB &Hff, &Hff, &Hff
   ' Draw Scroll bar With flat effect
   CmdFgColor &Hffff00
   CmdBgColor &H404080
   CmdScrollbar 20, 10, 120, 8, OPT_FLAT, 20, 30, 100 ' note that h/2 Size will be added On both sides Of the progress bar
   Color_A 255
   CmdText 20, 40, 26, 0, "Flat effect" ' Text info
   ' Draw Scroll bar With 3d effect
   CmdFgColor &H00ff00
   CmdBgColor &H800000
   CmdScrollbar 180, 10, 120, 8, 0, 20, 30, 100
   Color_A 255
   CmdText 180, 40, 26, 0, "3D effect" ' Text info

   xOffset = 20
   yOffset = 120
   wSz = FT_DispWidth / 2
   wSz = wSz - 40
   ' Draw horizontal Scroll bars
   CmdFgColor &H00a000
   CmdBgColor &H800000
   CmdScrollbar xOffset, yOffset, wSz, 8, 0, 10, 30, 100
   CmdBgColor &H000080
   yOffset = yOffset + yDist
   CmdScrollbar xOffset, yOffset, wSz, 8, 0, 30, 30, 100
   Color_A 255
   CmdBgColor &Hffff00
   yOffset = yOffset + yDist
   CmdScrollbar xOffset, yOffset, wSz, 8, 0, 50, 30, 100
   CmdBgColor &H808080
   yOffset = yOffset + yDist
   CmdScrollbar xOffset, yOffset, wSz, 8, 0, 70, 30, 100

   xOffset = FT_DispWidth / 2
   xOffset = xOffset + 40
   yOffset = 80
   wSz = FT_DispHeight - 100
   ' draw vertical Scroll bars
   CmdBgColor &H800000
   CmdScrollbar xOffset, yOffset, 8, wSz, 0, 10, 30, 100
   CmdBgColor &H000080
   xOffset = xOffset + xDist
   CmdScrollbar xOffset, yOffset, 8, wSz, 0, 30, 30, 100
   Color_A 255
   CmdBgColor &Hffff00
   xOffset = xOffset + xDist
   CmdScrollbar xOffset, yOffset, 8, wSz, 0, 50, 30, 100
   CmdBgColor &H808080
   xOffset = xOffset + xDist
   CmdScrollbar xOffset, yOffset, 8, wSz, 0, 70, 30, 100

   UpdateScreen

   Wait 2

End Sub ' Widget_Scroll

'------------------------------------------------------------------------------------------------------------
Sub Widget_Slider
'------------------------------------------------------------------------------------------------------------
   ' API To demonstrate slider widget

   '***********************************************************************
   ' Below Code demonstrates the usage Of slider function. Slider Function
   ' draws slider bar With fgcolor For inner Color And bgcolor For the knob
   ' , contains Input parameter For position Of the knob
   '***********************************************************************

   Local xOffset As Integer, yOffset As Integer, xDist As Integer, yDist As Integer, wSz As Integer
   xDist = FT_DispWidth / 12
   yDist = FT_DispWidth / 12

   CmdDlstart
   ClearColorRGB 64, 64, 64
   Clear_B 1, 1, 1
   ColorRGB &Hff, &Hff, &Hff
   ' Draw Scroll bar With flat effect
   CmdFgColor &Hffff00
   CmdBgColor &H000080
   CmdSlider 20, 10, 120, 10, OPT_FLAT, 30, 100  ' note that h/2 Size will be added On both sides Of the progress bar
   Color_A 255
   CmdText 20, 40, 26, 0, "Flat effect" ' Text info
   ' Draw Scroll bar With 3d effect
   CmdFgColor &H00ff00
   CmdBgColor &H800000
   CmdSlider 180, 10, 120, 10, 0, 50, 100
   Color_A 255
   CmdText 180, 40, 26, 0, "3D effect" ' Text info

   xOffset = 20
   yOffset = 120
   wSz = FT_DispWidth / 2
   wSz = wSz - 40
   ' Draw horizontal slider bars
   CmdFgColor &H00a000
   CmdBgColor &H800000
   ColorRGB 41, 1, 5
   CmdSlider xOffset, yOffset, wSz, 10, 0, 10, 100
   ColorRGB 11, 7, 65
   CmdBgColor &H000080
   yOffset = yOffset + yDist
   CmdSlider xOffset, yOffset, wSz, 10, 0, 30, 100
   Color_A 255
   CmdBgColor &Hffff00
   ColorRGB 87, 94, 9
   yOffset = yOffset + yDist
   CmdSlider xOffset, yOffset, wSz, 10, 0, 50, 100
   CmdBgColor &H808080
   ColorRGB 51, 50, 52
   yOffset = yOffset + yDist
   CmdSlider xOffset, yOffset, wSz, 10, 0, 70, 100

   xOffset = FT_DispWidth / 2
   xOffset = xOffset + 40
   yOffset = 80
   wSz = FT_DispHeight - 100
   ' draw vertical slider bars
   CmdBgColor &H800000
   CmdSlider xOffset, yOffset, 10, wSz, 0, 10, 100
   CmdBgColor &H000080
   xOffset = xOffset + xDist
   CmdSlider xOffset, yOffset, 10, wSz, 0, 30, 100
   Color_A 255
   CmdBgColor &Hffff00
   xOffset = xOffset + xDist
   CmdSlider xOffset, yOffset, 10, wSz, 0, 50, 100
   CmdBgColor &H808080
   xOffset = xOffset + xDist
   CmdSlider xOffset, yOffset, 10, wSz, 0, 70, 100

   UpdateScreen

   Wait 2

End Sub ' Widget_Slider

'------------------------------------------------------------------------------------------------------------
Sub Widget_Dial
'------------------------------------------------------------------------------------------------------------
'API To demonstrate dial widget

    '***********************************************************************
    ' Below Code demonstrates the usage Of dial function. Dial Function
    ' draws rounded bar With fgcolor For knob Color And colorrgb For Pointer
    ' , contains Input parameter For angle Of the Pointer
    '***********************************************************************

   CmdDlstart
   ClearColorRGB 64, 64, 64
   Clear_B 1, 1, 1
   ColorRGB &Hff, &Hff, &Hff
   ' Draw dial With flat effect
   CmdFgColor &Hffff00
   CmdBgColor &H000080
   CmdDial 50, 50, 40, OPT_FLAT, 0.2 * 65535 ' 20%
   Color_A 255
   CmdText 15, 90, 26, 0, "Flat effect"  ' Text info
   ' Draw dial With 3d effect
   CmdFgColor &H00ff00
   CmdBgColor &H800000
   CmdDial 140, 50, 40, 0, 0.45 * 65535  ' 45%
   Color_A 255
   CmdText 105, 90, 26, 0, "3D effect" 'Text info

   ' Draw increasing dials horizontally
   CmdFgColor &H800000
   ColorRGB 41, 1, 5
   CmdDial 30, 160, 20, 0, 0.30 * 65535
   CmdText 20, 180, 26, 0, "30 %" 'Text info
   ColorRGB 11, 7, 65
   CmdFgColor &H000080
   CmdDial 100, 160, 40, 0, 0.45 * 65535
   Color_A 255
   CmdText 90, 200, 26, 0, "45 %"  ' Text info
   CmdFgColor &Hffff00
   ColorRGB 87, 94, 9
   CmdDial 210, 160, 60, 0, 0.60 * 65535
   CmdText 200, 220, 26, 0, "60 %"  ' Text info
   CmdFgColor &H808080

   #If WQVGA = 1
      ColorRGB 51, 50, 52
      CmdDial 360, 160, 80, 0, 0.75 * 65535
      CmdText 350, 240, 26, 0, "75 %" ' Text info
   #EndIf

   UpdateScreen

   Wait 2

End Sub ' Widget_Dial

'------------------------------------------------------------------------------------------------------------
Sub Widget_Toggle
'------------------------------------------------------------------------------------------------------------
   '***********************************************************************
   ' Below Code demonstrates the usage Of Toggle function. Toggle Function
   ' draws Line With inside knob To Choose between Left And right. Toggle
   ' inside Color can be changed by bgcolor And knob Color by fgcolor. Left
   ' Right texts can be written And the Color Of the Text can be changed by
   ' colorrgb graphics Function
   '***********************************************************************

   Local xOffset As Integer, yOffset As Integer, yDist As Integer

   yDist = 40

   CmdDlstart
   ClearColorRGB 64, 64, 64
   Clear_B 1, 1, 1
   ColorRGB &Hff, &Hff, &Hff
   ' Draw Toggle With flat effect
   CmdFgColor &Hffff00
   CmdBgColor &H000080

   ColorRGB &Hff, &Hff, &Hff

   CmdToggle 40, 10, 60, 27, OPT_FLAT, 0.5 * 65535, "no" + gap + "yes"  ' circle radius will be Extended On both the horizontal sides
   Color_A 255
   CmdText 40, 40, 26, 0, "Flat effect" 'Text info
   ' Draw Toggle bar With 3d effect
   CmdFgColor &H00ff00
   CmdBgColor &H800000
   CmdToggle 140, 10, 30, 27, 0, 65535, "stop" + gap + "run"
   Color_A 255
   CmdText 140, 40, 26, 0, "3D effect"  ' Text info

   xOffset = 40
   yOffset = 80
   ' Draw horizontal Toggle bars
   CmdBgColor &H800000
   CmdFgColor &H410105
   CmdToggle xOffset, yOffset, 30, 27, 0, 65535, "-ve" + gap + "+ve"
   CmdFgColor &H0b0721
   CmdBgColor &H000080
   yOffset = yOffset + yDist
   CmdToggle xOffset, yOffset, 50, 27, 0, .25 * 65535, "zero" + gap + "one"
   CmdBgColor &Hffff00
   CmdFgColor &H575e1b
   ColorRGB 0, 0, 0
   yOffset = yOffset + yDist
   CmdToggle xOffset, yOffset, 80, 27, 0, 0.5 * 65535, "exit" + gap + "init"
   CmdBgColor &H808080
   CmdFgColor &H333234
   ColorRGB &Hff, &Hff, &Hff
   yOffset = yOffset + yDist
   CmdToggle xOffset, yOffset, 30, 27, 0, 65535, "off" + gap +  "on"

   UpdateScreen

   Wait 2

End Sub ' Widget_Toggle

'------------------------------------------------------------------------------------------------------------
Sub Widget_Spinner
'------------------------------------------------------------------------------------------------------------
   ' API To demonstrate spinner widget

   '***********************************************************************
   ' Below Code demonstrates the usage Of spinner function. Spinner func
   ' will wait untill Stop command Is sent From the mcu. Spinner has option
   ' For displaying points In circle fashion Or In a Line fashion.
   '***********************************************************************
   Const X2 = FT_DispWidth / 2

   CmdDlstart
   ClearColorRGB 64, 64, 64
   Clear_B 1, 1, 1
   ColorRGB &Hff, &Hff, &Hff
   CmdText FT_DispWidth / 2, 20, 27, OPT_CENTER, "Spinner circle"
   CmdText FT_DispWidth / 2, 80, 27, OPT_CENTER, "Please Wait ..."
   CmdSpinner X2, FT_DispHeight / 2, 0, 1,"" ' Style 0 And Scale 0

   ' Wait till coprocessor completes the operation
   WaitCmdfifoEmpty

   Wait 2

   '*************************** spinner With Style 1 And Scale 1 ****************************************************

   CmdDlstart
   ClearColorRGB 64, 64, 64
   Clear_B 1, 1, 1
   ColorRGB &Hff, &Hff, &Hff
   CmdText FT_DispWidth / 2 , 20, 27, OPT_CENTER, "Spinner line"
   CmdText FT_DispWidth / 2, 80, 27, OPT_CENTER, "Please Wait ..."
   ColorRGB &H00, &H00, &H80
   CmdSpinner X2, FT_DispHeight / 2, 1, 1, "" 'Style 1 And Scale 1

   ' Wait till coprocessor completes the operation
   WaitCmdfifoEmpty

   Wait 2

   CmdDlstart
   ClearColorRGB 64, 64, 64
   Clear_B 1, 1, 1
   ColorRGB &Hff, &Hff, &Hff
   CmdText FT_DispWidth / 2, 20, 27, OPT_CENTER, "Spinner clockhand"
   CmdText FT_DispWidth / 2, 80, 27, OPT_CENTER, "Please Wait ..."
   ColorRGB &H80, &H00, &H00
   CmdSpinner X2, (FT_DispHeight / 2) + 20, 2, 1, "" ' tyle 2 Scale 1

   ' Wait till coprocessor completes the operation
   WaitCmdfifoEmpty

   Wait 2

   CmdDlstart
   ClearColorRGB 64, 64, 64
   Clear_B 1, 1, 1
   ColorRGB &Hff, &Hff, &Hff
   CmdText FT_DispWidth / 2, 20, 27, OPT_CENTER, "Spinner two dots"
   CmdText FT_DispWidth / 2, 80, 27, OPT_CENTER, " Please Wait ..."
   ColorRGB &H80, &H00, &H00
   CmdSpinner X2, (FT_DispHeight / 2) + 20, 3, 1, "" ' Style 3 Scale 0

   ' Wait till coprocessor completes the operation
   WaitCmdfifoEmpty

   Wait 2

   ' Send the Stop command
   CmdSTOP

   ' Update the command buffer pointers - both Read And Write pointers
   WaitCmdfifoEmpty

   Wait 1

End Sub ' Widget_Spinner

'------------------------------------------------------------------------------------------------------------
Sub PowerMode
'------------------------------------------------------------------------------------------------------------

   '******************************************************
   'Senario1: Transition from Active mode to Standby mode.
   '          Transition from Standby mode to Active Mode
   '******************************************************
   Screen "Active Mode"

   ' Switch FT800 from Active to Standby mode
   Fadeout
   PlayMuteSound ' Play mute sound to avoid pop sound
   PowerModeSwitch FT_Gpu_STANDBY

   ' Wake up from Standby first before accessing FT800 registers.
   PowerModeSwitch FT_Gpu_ACTIVE
   Screen "Power Senario 1"
   Fadein
   Wait 3

   '****************************************************
   'Senario2: Transition from Active mode to Sleep mode.
   '          Transition from Sleep mode to Active Mode
   '****************************************************
   ' Switch FT800 from Active to Sleep mode
   Fadeout
   PlayMuteSound  '  Play mute sound to avoid pop sound
   PowerModeSwitch FT_Gpu_SLEEP

   ' Wake up from Sleep
   PowerModeSwitch FT_Gpu_ACTIVE
   Waitms 50
   Screen "Power Senario 2"
   Fadein
   Wait 3

   '*************************************************************************
   'Senario3: Transition from Active mode to PowerDown mode.
   '          Transition from PowerDown mode to Active Mode via Standby mode.
   '*************************************************************************
   ' Switch FT800 from Active to PowerDown mode by sending command
   Fadeout
   PlayMuteSound ' Play mute sound to avoid pop sound
   PowerModeSwitch FT_Gpu_POWERDOWN

   if FT800_Init()=1 then end
   ' Need download display list again because power down mode lost all registers and memory
   Screen "Scenario 3"
   Fadein
   Wait 3

   '*****************************************************************************************
   'Senario4: Transition from Active mode to PowerDown mode by toggling PDN from high to low.
   '          Transition from PowerDown mode to Active Mode via Standby mode.
   '*****************************************************************************************
   ' Switch FT800 from Active to PowerDown mode by toggling PDN
   Fadeout
   PlayMuteSound ' Play mute sound to avoid pop sound
   Powercycle FALSE

   if FT800_Init()=1 then end
   ' Need download display list again because power down mode lost all registers and memory
   Screen "Scenario 4"
   Fadein
   Wait 3

   '*************************************************************************
   'Senario5: Transition from Active mode to PowerDown mode via Standby mode.
   '          Transition from PowerDown mode to Active mode via Standby mode.
   '*************************************************************************
   ' Switch FT800 from Active to standby mode
   Fadeout
   PlayMuteSound ' Play mute sound to avoid pop sound
   PowerModeSwitch FT_Gpu_STANDBY
   Powercycle FALSE
   if FT800_Init()=1 then end

   ' Need download display list again because power down mode lost all registers and memory
   Screen "Scenario 5"
   Fadein
   Wait 3

   '*************************************************************************
   'Senario6: Transition from Active mode to PowerDown mode via Sleep mode.
   '          Transition from PowerDown mode to Active mode via Standby mode.
   '*************************************************************************
   ' Switch FT800 from Active to standby mode
   Fadeout
   PlayMuteSound ' Play mute sound to avoid pop sound
   PowerModeSwitch FT_Gpu_SLEEP
   Powercycle FALSE ' go to powerdown mode
   if FT800_Init()=1 then end

   ' Need download display list again because power down mode lost all registers and memory
   Screen "Scenario 6"
   Fadein
   Wait 3

End Sub ' PowerMode

'------------------------------------------------------------------------------------------------------------
Sub Fadeout
'------------------------------------------------------------------------------------------------------------
   ' API To give fadeout effect by changing the Display PWM From 100 till 0

   Local i AS Long

   For i = 100 To 0 Step -3
      Wr8 REG_PWM_DUTY, i
      Waitms 2
   Next i

End Sub ' Fadeout

'------------------------------------------------------------------------------------------------------------
Sub Fadein
'------------------------------------------------------------------------------------------------------------
   ' API To perform Display fadein effect by changing the Display PWM From 0 till 100 and Finally 128

   Local i AS Long

   For i = 0 To 100 Step 3
      Wr8 REG_PWM_DUTY, i
      Waitms 2
   Next i

    '  Finally make the PWM 100%
   Wr8 REG_PWM_DUTY, 128

End Sub '

'------------------------------------------------------------------------------------------------------------
Sub PlayMuteSound
'------------------------------------------------------------------------------------------------------------

   Wr16 REG_SOUND, &H0060
   Wr8  REG_PLAY, &H01

End Sub ' PlayMuteSound

'------------------------------------------------------------------------------------------------------------
Sub PowerModeSwitch (Byval pwrmode AS LONG)
'------------------------------------------------------------------------------------------------------------

   HostCommand pwrmode

End Sub ' PowerModeSwitch

'------------------------------------------------------------------------------------------------------------

$inc Bitmap_RawData, nosize, "Bitmap_RawData.raw"