' Mandelbrot2
' FT800 platform.
' Original Code by matchy -> http://gameduino2.proboards.com/thread/11/screen-plotting
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

Config Base = 0
Config Submode = New
Config Spi = Hard, Interrupt = Off, Data_Order = Msb, Master = Yes, Polarity = Low, Phase = 0, Clockrate = 4, Noss = 1
SPSR = 1  ' Makes SPI run at 8Mhz instead of 4Mhz


$Include "FT80x.inc"
$Include "FT80x_Functions.inc"

Declare Sub setup()
Declare Sub setpal (Byval i As Byte, Byval argb As Long)
Declare Sub plot (Byval x As Integer, Byval y As Integer, Byval i As Long)
Declare Sub draw_mandlebrot

Spiinit

Dim ___rseed as word : ___rseed = 53444
Dim dw as Dword
Dim brot_type As Byte


if FT800_Init()=1 then end   ' Initialise the FT800

setup

Do

   draw_mandlebrot
   dw = rnd(65535)
   ___rseed = dw

   setup

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
      setpal i, rnd(16777216) or &Hff000000
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
Sub draw_mandlebrot
'------------------------------------------------------------------------------------------------------------

   Local x0 As Single, y0 As Single, x As Single, y As Single, xtemp As Single
   Local Temp1 As Single, Temp2 As Single, Temp3 As Single , Temp4 As Single

   Local Temp5 As Integer, Temp6 As Integer, Temp7 As Integer, Temp8 As Integer

   Local iteration As Integer
   Local plot_x As Word, plot_y As Word
   Local plot_color As Dword

   y0 = 0
   x  = 0
   y  = 0
   xtemp = 0
   iteration = 0
   plot_x = 0
   plot_y = 0

   Incr brot_type

   If brot_type > 1 Then brot_type = 0

   For plot_y = 0 to Ft_DispHeight-1

      For plot_x = 0 to Ft_DispWidth-1

         x0 = plot_x
         y0 = plot_y
         Temp1 = x0 / 100
         x0 = Temp1 - 2.5

         Temp1 = y0 / 60
         y0 = Temp1 - 2
         x = 0
         y = 0
         xtemp = 0
         iteration = 0


         Do
            Temp1 = x * x
            Temp2 = y * y
            Temp3 = Temp1 + Temp2

            If Temp3 > 4 OR iteration > 8 Then Exit Do

            Select Case brot_type
               Case 0
'                 xtemp = x*x - y*y + x0
                  xtemp = x * x
                  Temp1 = y * y
                  xtemp = xtemp - Temp1
                  xtemp = xtemp + x0

'                 y = 2 * x * y + y0
                  Temp1 = y
                  y = 2 * x
                  y = y * Temp1
                  y = y + y0
               Case 1
'                 xtemp = x*x*x - 3*x*y*y + x0
                  xtemp = x * x
                  xtemp = xtemp * x

                  Temp1 = 3 * x
                  Temp1 = Temp1 * y
                  Temp1 = Temp1 * y
                  xtemp = xtemp - Temp1
                  xtemp = xtemp + x0

'                 y = 3*x*x*y - y*y*y + y0
                  Temp2 = y
                  y = 3 * x
                  y = y * x
                  y = y * Temp2

                  Temp1 = Temp2 * Temp2
                  Temp1 = Temp1 * Temp2
                  y = y - Temp1
                  y = y + y0

            End Select

            x = xtemp
            Incr iteration

         Loop

         Temp1 = x * x
         Temp2 = y * y

         Temp5 = iteration MOD 8

         Temp4 = Temp1 + Temp2

         If Temp4 < 4 Then
            plot_color = Temp5 * 16
         Else
            plot_color = Temp5 * 16
            plot_color = plot_color + 128
         End If

         plot plot_x, plot_y, plot_color

      Next

   Next


End Sub