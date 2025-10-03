' Test Clock
' For use with the FT800
' Original example posted by mathiasw at http://gameduino2.proboards.com/thread/42/clock-demo
' Requires Bascom 2.0.7.8 or greater

$Regfile = "M328pdef.dat"
$Crystal = 8000000
$Baud = 19200
$HwStack = 128
$SwStack = 128
$FrameSize = 320
$NOTYPECHECK

Config ft800=spi , ftsave=0, ftdebug=0

Config Base = 0
Config Submode = New
Config Spi = Hard, Interrupt = Off, Data_Order = Msb, Master = Yes, Polarity = Low, Phase = 0, Clockrate = 4, Noss = 1
SPSR = 1  ' Makes SPI run at 8Mhz instead of 4Mhz

Declare Sub Load_Jpeg(Byval file As Byte)
Declare Sub Imageviewer
Declare Sub Loadimage2ram (Byval bmphandle As Byte)
Declare Function FindFile(Byref File As String * 12) As Byte

ft800_CS Alias Portb.2
Config ft800_CS = Output
ft800_CS = 1

ft800_Pd Alias PortB.1
Config ft800_Pd = Output
ft800_Pd = 1


$Include "FT800.inc"
$Include "FT800_Functions.inc"

CONST SECOND25PCT_HANDLE = &H3

Dim t As Byte
Dim angle As Integer
Dim Deg As Dword
Dim TempW As word
Dim dloffset As Word

Spiinit

if FT800_Init()=1 Then END    ' Initialise the FT800

TempDW = LoadLabel(clock_assets)
LoadCmd TempDW, 21070

Angle = 360 / 60              ' Angle corresponding to ONE second

Do

   Clear_B 1,1,1
   COLORRGB 255,255,255

   Begin_G BITMAPS
   Vertex2ii 2, 2, 0, 0
   Cmdtranslate  111 * 65536, 111 * 65536

   CmdRotateA angle
   Cmdtranslate  -111 * 65536, -111 * 65536
   CmdSetMatrix
   Vertex2ii 24, 24, SECOND25PCT_HANDLE, 0

   Cmdloadidentity
   UpdateScreen

   waitms 1000

Loop


End

'------------------------------------------------------------------------------------------------------------
$include "TestClock.inc"