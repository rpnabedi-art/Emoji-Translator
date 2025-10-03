' Mandelbrot1
' FT800 platform.
' Original Code by jls -> http://gameduino2.proboards.com/thread/11/screen-plotting
' Requires Bascom 2.0.7.8 or greater

$Regfile = "M328pdef.dat"
$Crystal = 16000000
$Baud = 57600
$HwStack = 80
$SwStack = 80
$FrameSize = 300
$NOTYPECHECK

'Config ft800=spi , ftsave=0, ftdebug=0 , ftcs=portb.0 ', platform=gameduino2, lcd_rotate=1 ' Gameduino2
Config Ft800 = Spi , Ftsave = 0 , Ftdebug = 0 , Ftcs = Portd.4 , Ftpd = Portd.3  ' 4D AdamShield
'Config Ft800 = Spi , Ftcs = Portb.1 , Ftpd = Portd.4 ' VM801P

Config rnd = 32
Config Base = 0
Config Submode = New
Config Spi = Hard, Interrupt = Off, Data_Order = Msb, Master = Yes, Polarity = Low, Phase = 0, Clockrate = 4, Noss = 1
SPSR = 1  ' Makes SPI run at 8Mhz instead of 4Mhz

$Include "FT80x.inc"
$Include "FT80x_Functions.inc"

Declare Sub setup
Declare Sub setpal (Byval i As Byte, Byval argb As Long)
Declare Sub plot (Byval x As Integer, Byval y As Integer, Byval i As Long)

Dim col As Byte
Dim cnt As Integer
Dim oldx As Single
Dim oldy As Single
Dim a As Single
Dim b As Single
Dim c As Single
Dim x As Single
Dim y As Single
Dim Temp1 As Single
Dim Temp2 As Single
Dim Temp3 As Single
Dim Temp4 As Single
Dim Temp5 As Single

dim dw as Dword

Const W1 = Ft_DispWidth / 2
Const Y1 = Ft_DispHeight / 2

Spiinit

if FT800_Init()=1 then end   ' Initialise the FT800

setup

a = 0.5
b = -0.6
c = 0.7
x = 1
y = 0
col = 1

Do
   oldx = x
   oldy = y

   Temp1 = Abs(oldx)
   Temp1 = oldx / Temp1

   Temp2 = b * oldx
   Temp2 = Temp2 - c
   Temp3 = Abs(Temp2)
   Temp2 = Sqr(Temp3)

   Temp3 = Temp1 * Temp2
   x = oldy - Temp3

   y = a - oldx

   If cnt = 1500 Then
      Incr col
      cnt = 0
   End If

   Incr cnt
   Temp4 = 7 * x
   Temp5 = 7 * y
   plot W1 + Temp4 , Y1 + Temp5, col

Loop

END

'------------------------------------------------------------------------------------------------------------
Sub setup
'------------------------------------------------------------------------------------------------------------

   Local i As Byte

   CmdMemset 0, 0, Ft_DispWidth * Ft_DispHeight
   ClearScreen
   BitmapLayout PALETTED, Ft_DispWidth , Ft_DispHeight
   BitmapSize NEAREST, BORDER, BORDER, Ft_DispWidth, Ft_DispHeight
   BitmapSource 0
   Begin_G BITMAPS
   Vertex2ii 0, 0, 0, 0

   UpdateScreen

   setpal 0, &H00000000

   For i = 1 to 255
      setpal i, rnd(16777215) or &Hff000000
   Next

End Sub

'------------------------------------------------------------------------------------------------------------
Sub setpal (Byval i As Byte, Byval argb As Long)
'------------------------------------------------------------------------------------------------------------

   Local Temp1 As Long

   Temp1 =  i * 4
   Temp1 = Temp1 + Ram_Pal
   Wr32  Temp1 , argb

End Sub

'------------------------------------------------------------------------------------------------------------
Sub plot(Byval x As Integer, Byval y As Integer, Byval i As Long)
'------------------------------------------------------------------------------------------------------------

   Local Temp1 As Long

   If x < Ft_DispWidth AND y < Ft_DispHeight Then

      Temp1 = Ft_DispWidth * y
      Temp1 = Temp1 + x
      Wr8 Temp1, i

   End If

End Sub

'------------------------------------------------------------------------------------------------------------