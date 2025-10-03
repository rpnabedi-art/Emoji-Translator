'------------------------------------------------------------------------------
' BASCOM-AVR - FT801 Circles.bas
' Code demonstrates individually moving 5 circles,  VM801P - FT801 Capacitive Touch LCD
' Original code from:
' http://www.ftdichip.com/Support/SoftwareExamples/EVE/FTDI_V1.4.0_03272015(FT801).zip
' Requires Bascom 2.0.7.9
'------------------------------------------------------------------------------

$Regfile = "M328pdef.dat"
$Crystal = 16000000
$Baud = 57600
$HwStack = 90
$SwStack = 90
$FrameSize = 250
$NOTYPECHECK

Config Submode = New
Config Base = 0
Config Ft800 = Spi , ftsave = 0, ftdebug = 0 , Ftcs = Portb.1 , Ftpd = Portd.4, LCD_CALIBRATION=1 ' VM801P - FTDI
Config Spi = Hard, Interrupt = Off, Data_Order = Msb, Master = Yes, Polarity = Low, Phase = 0, Clockrate = 4, Noss = 0

SPSR = 1  ' Makes SPI run at 8Mhz instead of 4Mhz
Spiinit

$Include "FT80x.inc"
$Include "FT80x_Functions.inc"

Const NO_OF_CIRCLE = 5

Declare Sub CheckCircleTouchGood (Byval valz As Long, Byval TouchNum As Byte, Byval i As Byte)
Declare Function CirclePlot(Byref X As Integer, Byref Y As Integer, Byref Valz As Byte) As Integer
Declare Sub ConcentricCircles (Byval C1 As Integer, Byval R As Integer, Byval G As Integer, Byval B As Integer)
Declare Sub TouchPoints(Byval C1X As Integer, Byval C1Y As Integer, Byval i As Byte)
Declare Sub PlotXY()
Declare Sub Circles()
Declare Sub StoreTouch(Byval Touchval As Long, Byval TouchNo As Byte)

If FT800_Init() = 1 Then
   ' put your own message if not successfull.
   End ' Initialise the FT800
Else
   ' Print "Success"
End if

Dim TN(NO_OF_CIRCLE,NO_OF_CIRCLE) As Byte
Dim Tsq1(NO_OF_CIRCLE) As Long
Dim C1X(NO_OF_CIRCLE) As Long
Dim C1Y(NO_OF_CIRCLE) As LOng
Dim TouchX(NO_OF_CIRCLE) As Long
Dim TouchY(NO_OF_CIRCLE) As Long

Circles

Do
Loop

End

'------------------------------------------------------------------------------
Sub Circles()
'------------------------------------------------------------------------------

   Dim CircleNo(NO_OF_CIRCLE) As Byte
   Dim valx(NO_OF_CIRCLE) As Long, xx As Long
   Local i As Byte, j As Byte

   i=0: j=0

   Wr8 Reg_cTouch_Extended, Reg_cTouch_Extended ' set mode to extended for FT801

  ' calculate the intital radius of the circles before the touch happens
   Tsq1(0)= 50
   C1X(0) = 190
   C1Y(0) = 136

   For i = 1 to NO_OF_CIRCLE-1

      Tsq1(i) = Tsq1(i - 1) + 30
      C1X(i)  = C1X(i - 1) - 30
      C1Y(i)  = 136

   Next

   Do
      Clear_B 1, 1, 1             ' clear the color component
      ClearColorRGB 255, 255, 255 ' set the Clear color

    ' values of the five touches are stored here
      valx(0) = Rd32(REG_CTOUCH_TOUCH0_XY)      ' first touch
      valx(1) = Rd32(REG_CTOUCH_TOUCH1_XY)      ' second touch
      valx(2) = Rd32(REG_CTOUCH_TOUCH2_XY)      ' third touch
      valx(3) = Rd32(REG_CTOUCH_TOUCH3_XY)      ' fourth touch
      valx(4) = Rd16(REG_CTOUCH_TOUCH4_X)       ' fifth touch

      xx = valx(4)
      Shift xx, Left, 16, Signed
      xx = xx OR Rd16(REG_CTOUCH_TOUCH4_Y)
      valx(4) = xx

      For i = 0 to NO_OF_CIRCLE-1

         StoreTouch valx(i), i

      Next

    ' The plot is drawn here
      PlotXY

    ' check which circle has been touched based on the coordinates and store the number of the circle touched
      For i = 0 to NO_OF_CIRCLE-1
         CheckCircleTouchGood valx(0), 0, i
         CheckCircleTouchGood valx(1), 1, i
         CheckCircleTouchGood valx(2), 2, i
         CheckCircleTouchGood valx(3), 3, i
         CheckCircleTouchGood valx(4), 4, i
      Next

    ' calculate the radius of each circle according to the touch of each individual circle
      For i = 0 To NO_OF_CIRCLE-1

         Tsq1(i) = CirclePlot( C1X(i), C1Y(i), i)

      Next

    ' with the calculated radius draw the circles as well as the Touch points
      For i = 0 To  NO_OF_CIRCLE-1

         ConcentricCircles Tsq1(i), 255, 0, 0
         TouchPoints C1X(i), C1Y(i), i + 1

      Next


      End_G
      UpdateScreen



   Loop

End Sub ' End of Circles

'------------------------------------------------------------------------------
Sub CheckCircleTouchGood (Byval valz As Long, Byval TouchNum As Byte, Byval i As Byte)
'------------------------------------------------------------------------------

   Local CX As Long
   Local CY As Long
   Local j  As Integer
   Local AllClear As Integer
   Local TempL As Long
   Local TempL2 As Long

   j=0: AllClear = 0: cx = 0: cy = 0

   TempL = valz
   Shift TempL, Right, 16, Signed

   If TempL <> -32768 Then

      CX = TempL
      CY = valz AND &Hffff

      For j = 0 to NO_OF_CIRCLE-1

         If  TN(TouchNum,j) = 0 Then

            If AllClear <> 10 Then
               AllClear = j
            End If

         Else
            AllClear = 10
         End If

      Next

      If AllClear <> 10 Then
         AllClear = 1
      End If

      If AllClear = 1 Then

         If TN(TouchNum,i) <> 1 Then

            ' check which circle being touched falls according to its coordinates and set its flag
            TempL = C1X(i) - 15
            TempL2 = C1X(i) + 15
            If CX > TempL AND CX < TempL2 Then

               TempL = C1Y(i) - 30
               TempL2 = C1Y(i) + 30
               If CY > TempL AND CY < TempL2  Then
                  C1X(i) = CX
                  C1Y(i) = CY
                  TN(TouchNum,i) = 1
               End If

            End If

         End If

         AllClear = 0

      End If

      If TN(TouchNum,i) = 1 Then

         C1X(i) = CX
         C1Y(i) = CY
      End If

   Else

      TN(TouchNum,i) = 0

   End If

End Sub ' End of CheckCircleTouchGood

'------------------------------------------------------------------------------
Function CirclePlot(Byref X As Integer, Byref Y As Integer, Byref Valz As Byte) As Integer
'------------------------------------------------------------------------------
   Dim Xsq1(NO_OF_CIRCLE) As Long
   Dim Ysq1(NO_OF_CIRCLE) As Long
   Local TempL As Long

   Const v1 = FT_DispWidth / 2
   Const v2 = FT_DispHeight / 2

   Xsq1(Valz) = X - v1
   TempL = Xsq1(Valz)
   Xsq1(Valz) = Xsq1(Valz) * TempL

   Ysq1(Valz) = Y - v2
   TempL = Ysq1(Valz)
   Ysq1(Valz) = Ysq1(Valz) * TempL

   Tsq1(Valz) = Xsq1(Valz) + Ysq1(Valz)
   Tsq1(Valz) = sqr(Tsq1(Valz))

   CirclePlot = Tsq1(Valz)

End Function ' End of CirclePlot

'------------------------------------------------------------------------------
Sub ConcentricCircles (Byval C1 As Integer, Byval R As Integer, Byval G As Integer, Byval B As Integer)
'------------------------------------------------------------------------------

   Local C1X As Integer
   Local TempI As Integer

  ' ClearColorA 0 ' don't use

  ' Using ColorMask to disable color buffer updates, and
  ' set the BlendFunc to a value that writes incoming alpha
  ' directly into the alpha buffer, by specifying a source blend factor
  ' of ONE

   ColorMask 0, 0, 0, 1
   BlendFunc ONE, ONE_MINUS_SRC_ALPHA

  ' Draw the Outer circle
   Begin_G FTPOINTS
   PointSize C1 * 16  ' outer circle
   Vertex2ii 240, 136, 0, 0

  ' Draw the inner circle in a blend mode that clears any drawn
  ' pixels to zero, so the source blend factor is ZERO
   BlendFunc ZERO, ONE_MINUS_SRC_ALPHA
   TempI = C1 - 2
   TempI = TempI * 16

   PointSize TempI ' inner circle
   Vertex2ii 240, 136, 0, 0

  ' Enable the color Mask and the source blend factor is set to DST ALPHA, so the
  ' transparency values come from the alpha buffer
   ColorMask 1, 1, 1, 0
   BlendFunc DST_ALPHA, ONE

  ' draw the outer circle again with the color mask enabled and the blend factor
  ' is set to SRC_ALPHA */
   ColorRGB R , G , B
   PointSize C1 * 16
   Vertex2ii 240, 136, 0, 0

   BlendFunc SRC_ALPHA, ONE_MINUS_SRC_ALPHA
   End_G  ' end the edge strip primitve

End Sub ' End of ConcentricCircles

'------------------------------------------------------------------------------
Sub TouchPoints(Byval C1X As Integer, Byval C1Y As Integer, Byval i As Byte)
'------------------------------------------------------------------------------

  ' Draw the five white circles for the Touch areas with their rescpective numbers
   Begin_G FTPOINTS
   PointSize 14 * 16
   ColorRGB 255 , 255 , 255
   Vertex2ii C1X, C1Y, 0, 0
   ColorRGB 155 , 155 , 0
   CmdNumber C1X, C1Y, 29, OPT_CENTERX OR OPT_CENTERY, i

End Sub ' End of TouchPoints

'------------------------------------------------------------------------------
Sub PlotXY()
'------------------------------------------------------------------------------

   Local i As Byte
   Local PlotHt As Integer, PlotWth As Integer, X As Integer, Y As Integer

   i = 0: PlotHt = 0: PlotWth = 0: X = 0: Y = 0

   PlotHt = FT_DISPHEIGHT / 10
   PlotWth = FT_DISPWIDTH / 10

   ColorRGB 36 , 54 , 125
  ' Horizontal Lines
   For i = 1 to 10

      Y = i * PlotHt
      Begin_G LINES
      LineWidth 1 * 16
      Vertex2f 0, Y * 16
      Vertex2f FT_DispWidth * 16, Y * 16

   Next

  ' Vertical Lines
   For i = 1 to 10
      X = i * PlotWth
      Begin_G LINES
      LineWidth 1 * 16
      Vertex2f X * 16, 0
      Vertex2f X * 16, FT_DispHeight * 16
   Next

   End_G ' end the lines primitve

End Sub ' End of PlotXY

'------------------------------------------------------------------------------
Sub StoreTouch( Byval Touchval As Long, Byval TouchNo As Byte)
'------------------------------------------------------------------------------
   Local TempL As Long

   TempL = Touchval
   Shift TempL, Right,16, Signed

   If TempL <> -32768 Then

      TouchX(TouchNo) = TempL
      TempL = Touchval AND &Hffff
      TouchY(TouchNo) = TempL 'Touchval AND &Hffff
   End If

End Sub ' End of StoreTouch
'------------------------------------------------------------------------------