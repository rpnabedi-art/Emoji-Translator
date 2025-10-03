' Plot
' FT800 platform.
' Original code from http://gameduino2.proboards.com/thread/11/screen-plotting

' Comments by James Bowman:
' Sets up the whole screen as a framebuffer, in PALETTED mode, which should be good for the fractals.
' setpal() sets palette entry 'i' to a 32-bit ARGB color, and plot(x, y, i) sets a single pixel to index 'i'.

' Requires Bascom 2.0.7.8 or greater

$Regfile = "M328pdef.dat"
$Crystal = 16000000
$Baud = 57600
$HwStack = 80
$SwStack = 80
$FrameSize = 300

'Config ft800=spi , ftsave=0, ftdebug=0 , ftcs=portb.0 ', platform=gameduino2, lcd_rotate=1 ' Gameduino2
Config Ft800 = Spi , Ftsave = 0 , Ftdebug = 0 , Ftcs = Portd.4 , Ftpd = Portd.3  ' 4D AdamShield
'Config Ft800 = Spi , Ftcs = Portb.1 , Ftpd = Portd.4 ' VM801P

Config Base = 0
Config Submode = New
Config Spi = Hard, Interrupt = Off, Data_Order = Msb, Master = Yes, Polarity = Low, Phase = 0, Clockrate = 4, Noss = 1
SPSR = 1  ' Makes SPI run at 8Mhz instead of 4Mhz


Config RND = 32

$Include "FT80x.inc"
$Include "FT80x_Functions.inc"

Declare Sub setup
Declare Sub setpal (Byval i As Byte, Byval argb As Long)
Declare Sub plot (Byval x As Integer, Byval y As Integer, Byval i As Long)

dim dw as Dword
dim d1 as Dword
dim d2 as Dword

Spiinit


If FT800_Init() = 1 Then
   print "END"
   END    ' Initialise the FT800
end if

Setup

Do
   d1 = rnd(Ft_DispWidth-1)
   d2 = rnd(Ft_DispHeight-1)
   plot d1, d2, rnd(255)
Loop



END

'------------------------------------------------------------------------------------------------------------
Sub Setup
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
End Sub ' Setup

'------------------------------------------------------------------------------------------------------------
Sub SetPal (Byval i As Byte, Byval argb As Long)
'------------------------------------------------------------------------------------------------------------

   Local Temp1 As Long

   Temp1 =  i * 4
   Temp1 = Temp1 + Ram_Pal
   Wr32  Temp1 , argb

End Sub ' SetPal

'------------------------------------------------------------------------------------------------------------
Sub Plot(Byval x As Integer, Byval y As Integer, Byval i As Long)
'------------------------------------------------------------------------------------------------------------

   Local Temp1 As Long

   If x < Ft_DispWidth AND y < Ft_DispHeight Then

      Temp1 = Ft_DispWidth * y
      Temp1 = Temp1 + x
      Wr8 Temp1, i

   End If

End Sub ' Plot