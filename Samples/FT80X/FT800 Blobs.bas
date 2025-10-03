' FT800 Blobs.bas for the FT800
' Based on the Gameduino 2 library by James Bowman, http://excamera.com/sphinx/gameduino2/
' Requires Bascom 2.0.7.8 or greater

$Regfile = "M328pdef.dat"
$Crystal = 16000000
$Baud = 57600
$HwStack = 100
$SwStack = 100
$FrameSize = 400
$NOTYPECHECK

'Config ft800=spi , ftsave=0, ftdebug=0 , ftcs=portb.0 ', platform=gameduino2, lcd_rotate=1 ' Gameduino2
Config Ft800 = Spi , Ftsave = 0 , Ftdebug = 0 , Ftcs = Portd.4 , Ftpd = Portd.3  ' 4D AdamShield
'Config Ft800 = Spi , Ftcs = Portb.1 , Ftpd = Portd.4 ' VM801P

Config Base = 0
Config Submode = New
Config Spi = Hard, Interrupt = Off, Data_Order = Msb, Master = Yes, Polarity = Low, Phase = 0, Clockrate = 4, Noss = 0
SPSR = 1  ' Makes SPI run at 8Mhz instead of 4Mhz

$Include "FT80x.inc"
$Include "FT80x_Functions.inc"

Spiinit

If FT800_Init() = 1 Then End

Const NBLOBS = 128
Const OFFSCREEN  = -16384

Dim r As Byte
Dim g As Byte
Dim b As Byte

Dim i As Integer
Dim j As Byte
Dim TempI2 As Integer
Dim TempI As Integer
Dim _NBLOBS As Byte

Dim k As DWord
Dim TouchX As Word At k + 2 Overlay
Dim TouchY As Word At k + 0 Overlay

Dim blob_i As Byte
Dim blobsx(NBLOBS) As Integer
Dim blobsy(NBLOBS) As Integer

For i = 0 to NBLOBS-1
   blobsx(i) = OFFSCREEN
   blobsy(i) = OFFSCREEN
Next

Do

   k = RD32(Reg_Touch_Screen_XY)

   If TouchX <> 32768 Then
      Shift TouchX, Left, 4, Signed
      Shift TouchY, Left, 4, Signed
      blobsx(blob_i) = TouchX
      blobsy(blob_i) = TouchY
   Else
      blobsx(blob_i) = OFFSCREEN
      blobsy(blob_i) = OFFSCREEN
   End if

   blob_i = blob_i + 1
   _NBLOBS = NBLOBS - 1
   blob_i = blob_i AND _NBLOBS

   ClearColorRGBdw &HE0E0E0
   Clear_B 1,1,1

   Begin_G FTPOINTS

   For i = 0 to NBLOBS-1
      ' Blobs fade away and as well as they age
      TempI2 = i
      Shift TempI2, Left, 1, Signed
      Color_A TempI2

      TempI2 = i
      Shift TempI2, Left, 3, Signed
      TempI = 1024 + 16
      TempI = TempI - TempI2
      PointSize TempI

      ' Random color for each blob, keyed from (blob_i + i)
      j = blob_i + i
      _NBLOBS = NBLOBS -1
      j = j AND _NBLOBS

      r = j * 17
      g = j * 23
      b = j * 147

      ColorRGB r, g, b
      ' Draw it
      Vertex2f blobsx(j), blobsy(j)

   Next

   UpdateScreen

Loop

End