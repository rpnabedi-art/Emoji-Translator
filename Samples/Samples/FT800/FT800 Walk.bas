' FT800 Walk.bas for the FT800
' Based on the Gameduino 2 library by James Bowman, http://excamera.com/sphinx/gameduino2/
' Requires Bascom 2.0.7.8 or greater

$Regfile = "M328pdef.dat"
$Crystal = 16000000
$Baud = 19200
$HwStack = 32
$SwStack = 64
$FrameSize = 64

Config ft800=spi , ftsave=0, ftdebug=0 , ftcs=portb.0 ', ftpd=portb.0 ' Gameduino2
'Config ft800=spi , ftsave=0, ftdebug=0 , ftcs=portb.2 , ftpd=portd.4

Config Base = 0
Config Submode = New
Config Spi = Hard, Interrupt = Off, Data_Order = Msb, Master = Yes, Polarity = Low, Phase = 0, Clockrate = 4, Noss = 0
SPSR = 1  ' Makes SPI run at 8Mhz instead of 4Mhz

$Include "FT800.inc"
$Include "FT800_Functions.inc"

Spiinit

If FT800_Init() = 1 Then End

CONST WALK_HANDLE = &H0
CONST WALK_WIDTH = &H20
CONST WALK_HEIGHT = &H20
CONST WALK_CELLS = &H8
CONST ASSETS_END = &H4000

Tempdw = Loadlabel(Walk)
Loadcmd Tempdw , 1707

Dim i As Integer
Dim a(255) As Word
'Note Ti Integer is declared in FT800.Inc

For i = 0 to 255
   a(i) = rnd(512)
Next

Do

   ClearColorRGBdw &H0000E0
   Clear_B 1,1,1
   Begin_G BITMAPS

   For i = 0 to 255
      ColorRGB i, i, i
      Ti = a(i)
      Shift Ti, Right, 2
      Ti = Ti AND 7
      Vertex2ii a(i), i, WALK_HANDLE, Ti

      a(i) = a(i) + 1
      a(i) = a(i) AND 511

   Next

   UpdateScreen

Loop

End

'------------------------------------------------------------------------------------------------------------
$include "Walk_Assets.inc"