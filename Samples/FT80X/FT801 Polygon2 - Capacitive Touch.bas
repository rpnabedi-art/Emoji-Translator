'------------------------------------------------------------------------------
' BASCOM-AVR - FT801 Polygon2 - Capacitive Touch.bas
' Code demonstrates the use of gestures using the VM801P - FT801 Capacitive Touch LCD
' Original code from http://www.ftdichip.com/Support/SoftwareExamples/EVE/FT800_SampleApp_1.0.zip
' Requires Bascom 2.0.7.9 or greater.
'------------------------------------------------------------------------------

$Regfile = "M328pdef.dat"
$Crystal = 16000000
$Baud = 57600
$HwStack = 90
$SwStack = 90
$FrameSize = 200
$NOTYPECHECK

Config Base = 0
Config Submode = New

Config Ft800 = Spi , ftsave = 0, ftdebug = 0 , Ftcs = Portb.1 , Ftpd = Portd.4, LCD_CALIBRATION=1 ' VM801P - FTDI

Config Spi = Hard, Interrupt = Off, Data_Order = Msb, Master = Yes, Polarity = Low, Phase = 0, Clockrate = 4, Noss = 0
SPSR = 1  ' Makes SPI run at 8Mhz instead of 4Mhz
Spiinit

$Include "FT80x.inc"
$Include "FT80x_Functions.inc"

Const xoffset = ((FT_DispWidth - 480) / 2)
Const yoffset = ((FT_DispHeight - 272) / 2)

Dim sx(5) As Integer, sy(5) As Integer
Dim cx As Integer, cy As Integer
Dim n As Byte, angles(5) As Byte, No_SD As Byte
Dim x0 As Integer, y0 As Integer, x1 As Integer, y1 As Integer
Dim x(8) As Integer, y(8) As Integer
Dim a As Integer, i As Integer, j As Integer, k As Integer
Dim TempL1 As Single, TempL2 As Single, S1 As Single
Dim TempW1 As Word, TempW2 As Word

Declare Sub Read_Extended (Byref sx() As Integer, Byref sy() As Integer)
Declare Sub v(Byval _x As Integer, Byval _y As Integer)
Declare Function atan2(Byref y As Integer, Byref x As Integer) As Word

If FT800_Init() = 1 Then
   ' put your own message if not successfull.
   End ' Initialise the FT800
Else
   ' Print "Success"
End if

Wr8 Reg_cTouch_Extended, Reg_cTouch_Extended
 dim dd as Long

Do

   ClearColorRGB &H50,0,0
   Clear_B 1,1,1
   CmdGradient 0, 0, &H808080, 0, 272, &H80ff40
   SaveContext

   ColorRGB 0,0,&H80  ' set the color of the string to blue color
   CmdText FT_DispWidth/2, FT_DispHeight/2, 24, OPT_CENTER, "MultiTouch Polygon Demo"
   ColorRGB &H40,&H40,&H40

   Read_Extended sx(), sy()

   cx = 0: cy = 0: n = 0

   For i = 0 to 4
      If sx(i) > -10 Then
         cx = cx + sx(i)
         cy = cy + sy(i)
         Incr n
      End If
   Next

   cx = cx / n
   cy = cy / n


   For i = 0 to 4
      j = sx(i) - cx
      k = sy(i) - cy
      TempW1 = atan2 ( j, k )
      Shift TempW1, Right, 8, SIGNED
      angles(i) = TempW1
   Next

   Gosub Begin

   For a = 0 to 255

      For i = 0 to 4

         If angles(i) = a AND sx(i) > -10 Then
            v 16 * sx(i), 16 * sy(i)
         End If

      Next
   Next

   Gosub Paint

   Color_A 255
   ColorMask 1, 1, 1, 1
   BlendFunc SRC_ALPHA, ONE
   StencilFunc EQUAL, 255, 255
   Begin_G RECTS
   Vertex2II 0, 0, 0, 0
   Vertex2II 480, 272, 0, 0

   RestoreContext
   ColorRGB &H80, &H80, &Hff
   LineWidth 24

   Gosub Outline

   UpdateScreen

Loop

End
'-------------------------------------------------------------------------------------------
Begin:
   Gosub Restart

   ColorMask 0, 0, 0, 0
   StencilOp KEEP, INVERT
   StencilFunc ALWAYS, 255, 255
Return
'-------------------------------------------------------------------------------------------
Restart:

   n = 0
   x0 = 16 * FT_DispWidth
   x1 = 0
   y0 = 16 * FT_DispHeight
   y1 = 0
Return
'-------------------------------------------------------------------------------------------
Paint:

   'max(0, x0)
   'max(0, y0)
   Const A1 = 16 * FT_DispWidth
   Const A2 = 16 * FT_DispHeight
   If x1 > A1 Then x1 = A1
   'x1 = min(16 * FT_DispWidth, x1)
   If y1 > A2 Then y1 = A2
   'y1 = min(16 * FT_DispHeight, y1)
   ScissorXY x0, y0
   TempW1 = x1 - x0: Incr TempW1
   TempW2 = y1 - y0: Incr TempW2
   ScissorSIZE TempW1, TempW2
   Begin_G EDGE_STRIP_B
   Gosub Perim
Return
'-------------------------------------------------------------------------------------------
Perim:

   If n = 0 then Return

   For i = 0 to n-1
      Vertex2F x(i), y(i)
   Next

   Vertex2F x(0), y(0)
Return
'-------------------------------------------------------------------------------------------
Outline:

   Begin_G LINE_STRIP
   Gosub Perim
Return

'-------------------------------------------------------------------------------------------
Function atan2(Byref y As Integer, Byref x As Integer) As Word
'-------------------------------------------------------------------------------------------

   Local a As Word, xx As Word, xx1 As Word
   Local t As Integer, r as Integer
   Local aa As Byte

   xx = 0


   If y = &H8000 Then Incr y

   If x = &H8000 Then Incr x

   If x <= 0 Then t = 1 Else t = 0
   If y > 0  Then r = 1 Else r = 0

   a = t XOR r
   If  a > 0 Then
      t = x: x = y: y = t
      xx = xx XOR &H4000
   End If

   If x <= 0 Then
      x = -x
   Else
      xx = xx xor &H8000
   End If

   y = abs(y)

   If x > y Then
      t = x: x = y: y = t
      xx = xx xor &H3fff
   End If

   t = x or y
   r = t AND &Hff80

   If r > 0 then
      Shift x, Right, 1, Signed
      Shift y, Right, 1, Signed
   End If

   If y = 0 Then
      a = 0
   ElseIf x = y Then
      a = &h2000
   Else

      xx1 = x
      Shift xx1, Left, 8, Signed
      r = xx1 / y

      aa = lookup(r, atan8)

      xx1 = aa

      Shift xx1, Left, 5, Signed

      a = xx1

   End If

   a = a xor xx

   atan2 = a

End Function

'-------------------------------------------------------------------------------------------
Sub v(Byval _x As Integer, Byval _y As Integer)
'-------------------------------------------------------------------------------------------

   Local TempI As Integer
   TempI = _x
   Shift TempI, Right, 4, SIGNED
   If x0 > TempI Then x0 = TempI ' x0 = min(x0, _x >> 4)
   If x1 < TempI Then x1 = TempI ' x1 = max(x1, _x >> 4)
   TempI = _y
   Shift TempI, Right, 4, SIGNED
   If y0 > TempI Then y0 = TempI ' y0 = min(y0, _y >> 4)
   If y1 < TempI Then y1 = TempI ' y1 = max(y1, _y >> 4)

   x(n) = _x
   y(n) = _y
   Incr n

End Sub

'-------------------------------------------------------------------------------------------
Sub Read_Extended (Byref sx() As Integer, Byref sy() As Integer)
'-------------------------------------------------------------------------------------------

   Local sxy0 As Dword, sxyA As Dword, sxyB As Dword, sxyC As Dword
   Local xx As Dword


   sxy0 = Rd32(Reg_cTouch_Touch0_XY)
   sxyA = Rd32(Reg_cTouch_Touch1_XY)
   sxyB = Rd32(Reg_cTouch_Touch2_XY)
   sxyC = Rd32(Reg_cTouch_Touch3_XY)

   xx = sxy0
   Shift xx, Right, 16, SIGNED
   sx(0+_base) = xx
   sy(0+_base) = sxy0

   xx = sxyA
   Shift xx, Right, 16, SIGNED
   sx(1+_base) = xx
   sy(1+_base) = sxyA

   xx = sxyB
   Shift xx, Right, 16, SIGNED
   sx(2+_base) = xx
   sy(2+_base) = sxyB

   xx = sxyC
   Shift xx, Right, 16, SIGNED
   sx(3+_base) = xx
   sy(3+_base) = sxyC

   sx(4+_base) = Rd16(Reg_cTouch_Touch4_X)
   sy(4+_base) = Rd16(Reg_cTouch_Touch4_Y)

End Sub

'-------------------------------------------------------------------------------------------

atan8:
   Data 0,1,3,4,5,6,8,9,10,11,13,14,15,17,18,19,20,22,23,24,25,27,28,29,30,32,33,34,36,37,38,39,41
   Data 42,43,44,46,47,48,49,51,52,53,54,55,57,58,59,60,62,63,64,65,67,68,69,70,71,73,74,75,76,77
   Data 79,80,81,82,83,85,86,87,88,89,91,92,93,94,95,96,98,99,100,101,102,103,104,106,107,108,109
   Data 110,111,112,114,115,116,117,118,119,120,121,122,124,125,126,127,128,129,130,131,132,133,134
   Data 135,137,138,139,140,141,142,143,144,145,146,147,148,149,150,151,152,153,154,155,156,157,158
   Data 159,160,161,162,163,164,165,166,167,168,169,170,171,172,173,174,175,176,177,177,178,179,180
   Data 181,182,183,184,185,186,187,188,188,189,190,191,192,193,194,195,195,196,197,198,199,200,201
   Data 201,202,203,204,205,206,206,207,208,209,210,211,211,212,213,214,215,215,216,217,218,219,219
   Data 220,221,222,222,223,224,225,225,226,227,228,228,229,230,231,231,232,233,234,234,235,236,236
   Data 237,238,239,239,240,241,241,242,243,243,244,245,245,246,247,248,248,249,250,250,251,251,252
   Data 253,253,254,255,255