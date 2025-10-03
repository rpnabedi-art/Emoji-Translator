'------------------------------------------------------------------------------
' BASCOM-AVR - FT801 Bars.bas
' Bouncing Squares Demo using VM801P - Capacitive Touch LCD
' Original code from:
' http://www.ftdichip.com/Support/SoftwareExamples/EVE/FTDI_V1.4.0_03272015(FT801).zip
' Requires Bascom 2.0.7.9 or greater
'------------------------------------------------------------------------------

$Regfile = "M328pdef.dat"
$Crystal = 16000000
$Baud = 57600
$HwStack = 90
$SwStack = 90
$FrameSize = 200
$NOTYPECHECK

Config Submode = New
Config Base = 0
Config Ft800 = Spi , ftsave = 0, ftdebug = 0 , Ftcs = Portb.1 , Ftpd = Portd.4, LCD_CALIBRATION=1 ' VM801P - FTDI
Config Spi = Hard, Interrupt = Off, Data_Order = Msb, Master = Yes, Polarity = Low, Phase = 0, Clockrate = 4, Noss = 0

SPSR = 1  ' Makes SPI run at 8Mhz instead of 4Mhz
Spiinit

$Include "FT80x.inc"
$Include "FT80x_Functions.inc"

Declare Sub BouncingSquares()
Declare Sub CheckTouch (Byval Tx1 As Integer, Byval val1 As Long)
Declare Sub BouncingSquaresCall (Byval BRx As Integer, Byval BRy As Integer, Byval MovingRy As Integer, Byval SqNumber As Byte)
Declare Sub RectangleCalc(Byval Arrayno As Byte)
Declare Function MovingRect(Byval BRy As Integer, Byval MovingRy As Integer, Byval EndPtReach As Byte) As Integer

Const NO_OF_RECTS = 5 ' don't go more than 5
Dim BRy(NO_OF_RECTS) As Integer, BRx(NO_OF_RECTS) As Integer, My(NO_OF_RECTS) As Integer
Dim E(NO_OF_RECTS) As Byte
Dim RectNo(NO_OF_RECTS) As Byte



If FT800_Init() = 1 Then
   ' put your own message if not successfull.
   End ' Initialise the FT800
Else
   ' Print "Success"
End if

BouncingSquares

Do
Loop

End

'-------------------------------------------------------------------------------------------
Sub BouncingSquares()
'-------------------------------------------------------------------------------------------
   Local i As Byte
   Local TmpL As Long
 local s as long
   Dim RectX(NO_OF_RECTS) As Integer
   Dim valx(NO_OF_RECTS) As Long

   i = 0

  ' Calculate the X vertices where the five rectangles have to be placed
   For i = 1 to 4
      RectX(0) = 60
      RectX(i) = RectX(i - 1) + 80
   Next

   ' Set Mode to Extended for FT801
   Wr8 Reg_cTouch_Extended, Reg_cTouch_Extended



   Do

      ClearColorRGB 0, 0, 0 ' set the Clear color
      Clear_B 1, 1, 1       ' clear the color component

      valx(0) = Rd32(REG_CTOUCH_TOUCH0_XY)    ' first touch
      valx(1) = Rd32(REG_CTOUCH_TOUCH1_XY)    ' second touch
      valx(2) = Rd32(REG_CTOUCH_TOUCH2_XY)    ' third touch
      valx(3) = Rd32(REG_CTOUCH_TOUCH3_XY)    ' fourth touch
      valx(4) = Rd16(REG_CTOUCH_TOUCH4_X)     ' fifth touch
      TmpL = valx(4)
      Shift TmpL, Left, 16, Signed
      valx(4) = TmpL OR Rd16(REG_CTOUCH_TOUCH4_Y)

    ' Check which rectangle is being touched using the coordinates and move the respective smaller rectangle
      For i = 0 to NO_OF_RECTS-1
         TmpL = valx(i)
         Shift TmpL, Right, 16, Signed
         CheckTouch TmpL, valx(i)

         BouncingSquaresCall RectX(i), BRy(i), My(i), i
      Next

      UpdateScreen ' render the display list and wait for the completion of the DL
   Loop

End Sub ' End of BouncingSquares()

'-------------------------------------------------------------------------------------------
Sub CheckTouch (Byval Tx1 As Integer, Byval val1 As Long)
'-------------------------------------------------------------------------------------------

   Local MovingRy1 As Integer, Arrayno As Byte
   Local TmpL As Long
   Local i As Byte

   i = 0
   Arrayno = 255


  ' Check which rectangle is being touched according to the coordinates
   If Tx1      >= 60 AND Tx1 <= 105 Then
      Arrayno = 0
   ElseIf Tx1 >= 140 AND Tx1 <= 185 Then
      Arrayno = 1
   ElseIf Tx1 >= 220 AND Tx1 <= 265 Then
      Arrayno = 2
   ElseIf Tx1 >= 300 AND Tx1 <= 345 Then
      Arrayno = 3
   ElseIf Tx1 >= 380 AND Tx1 <= 425 Then
      Arrayno = 4
   End If

  ' Set the flag for the rectangle being touched
   RectNo(Arrayno) = 1

  ' store the vertices of the rectangle selected according to the flag
   TmpL = val1
   Shift TmpL, Right, 16, Signed

   If TmpL <> -32768 Then
      BRx(Arrayno) = TmpL
      BRy(Arrayno) = val1 AND &Hffff
   End If

  ' limit the Bigger rectangle's height
   If BRy(Arrayno) <= 60 Then
      BRy(Arrayno) = 60
   End If

  ' According to the bigger rectangle values move the smaller rectangles
   For i = 0 to NO_OF_RECTS-1
      RectangleCalc i
   Next

End Sub ' End of CheckTouch

'-------------------------------------------------------------------------------------------
Sub BouncingSquaresCall (Byval BRx As Integer, Byval BRy As Integer, Byval MovingRy As Integer, Byval SqNumber As Byte)
'-------------------------------------------------------------------------------------------

   Local MovingRx As Integer, I1 As Integer, I2 As Integer
   Local R1 As Integer, G1 As Integer, B_1 As Integer, R2 As Integer, G2 As Integer, B2 As Integer

   MovingRx = BRx

   If BRy <= 60  Then BRy = 60
   If BRy >= 260 Then BRy = 260

  ' different colours are set for the different rectangles
   If SqNumber = 0 Then
      R1 = 63: G1 = 72:  B_1 = 204
      R2 = 0:  G2 = 255: B2 = 255
   ElseIf SqNumber = 1 Then
      R1 = 255: G1 = 255: B_1 = 0
      R2 = 246: G2 = 89: B2 = 12
   ElseIf SqNumber = 2 Then
      R1 = 255: G1 = 0:  B_1 = 0
      R2 = 237: G2 = 28: B2 = 36
   ElseIf SqNumber = 3 Then
      R1 = 131: G1 = 171: B_1 = 9
      R2 = 8:   G2 = 145: B2 = 76
   ElseIf SqNumber = 4 Then
      R1 = 141: G1 = 4: B_1 = 143
      R2 = 176: G2 = 3: B2 = 89
   End If

   ' Draw the rectanles here
   Begin_G RECTS 'begin RECTS primitives
   ColorRGB R1, G1, B_1 'set the color
   LineWidth 10 * 16

   Vertex2f BRx * 16, BRy * 16
   I1 = BRx + 45
   Vertex2f I1 * 16, 260 * 16

   ColorRGB R2, G2, B2
   LineWidth 5 * 16
   Vertex2f MovingRx * 16, MovingRy * 16
   I1 = MovingRy + 10
   I2 = MovingRx + 45
   Vertex2f I2 * 16, I1 * 16

End Sub 'End of  BouncingSquaresCall

'-------------------------------------------------------------------------------------------
Sub RectangleCalc(Byval Arrayno As Byte)
'-------------------------------------------------------------------------------------------

   Local Arr As Byte
   Local MovingRy1 As Integer, leap As Integer, I1 As Integer

   leap = 0

   If RectNo(Arrayno) = 1 Then
      Arr = Arrayno
    ' the limits for the smaller rectangles forward and backward movement is set here
      I1 = My(Arr) + 25

      If My(Arr) = 0 AND I1 < BRy(Arr) Then
         E(Arr) = 0 ' inc
      ElseIf I1 >= BRy(Arr) Then
         E(Arr) = 1  ' dec
      End If

    ' the smaller rectangles are moved accordingly according to the flags set above ion this function call
      Waitms 1
      MovingRy1 = MovingRect( BRy(Arr), My(Arr), E(Arr))

      If BRy(Arr) = 0 Then MovingRy1 = 4

      My(Arr) = MovingRy1

      I1 = BRy(Arr) - 15
      If My(Arr) > I1 Then
         leap = My(Arr) - BRy(Arr)
         I1 = leap + 25
         My(Arr) = My(Arr) - I1
      End If
   End If

End Sub ' End of RectangleCalc

'-------------------------------------------------------------------------------------------
Function MovingRect(Byval BRy As Integer, Byval MovingRy As Integer, Byval EndPtReach As Byte) As Integer
'-------------------------------------------------------------------------------------------

   If MovingRy <= 0 Then
      EndPtReach = 0
      MovingRy = 1
   End If

   If EndPtReach = 1 AND MovingRy > 0 Then
      MovingRy = MovingRy - 1 ' the smaller rectangles are moved behind
   Elseif EndPtReach = 0 Then
      MovingRy =  MovingRy + 2 ' the smaller rectangles are moved forward slightly faster
   End If

   MovingRect = MovingRy

End Function ' End of MovingRect


'-------------------------------------------------------------------------------------------