' Test Clock
' For use with the FT800
' Original example posted by mathiasw at http://gameduino2.proboards.com/thread/42/clock-demo
' Requires Bascom 2.0.7.8 or greater

$regfile = "xm128a1def.dat"
$crystal = 32000000
$hwstack = 52
$swstack = 80
$framesize = 128

Config Osc = Enabled , 32mhzosc = Enabled
Config Sysclock = 32mhz                                     '--> 32MHz

'configure the priority
'Config Priority = Static , Vector = Application , Lo = Enabled
Config Com1 = 19200 , Mode = Asynchroneous , Parity = None , Stopbits = 1 , Databits = 8
Open "COM1:" For Binary As #1

Config Submode = New
Config ft800=spic ,  ftcs=portc.4, ftpd=portc.0
Config Spic = Hard , Master = Yes , Mode = 0 , Clockdiv = Clk32 , Data_order = Msb , Ss = none
Config Base = 0


Declare Sub Load_Jpeg(Byval file As Byte)
Declare Sub Imageviewer
Declare Sub Loadimage2ram (Byval bmphandle As Byte)
Declare Function FindFile(Byref File As String * 12) As Byte


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

   waitms 10
   angle=angle+6
   if angle>360 then angle=0
Loop


End

'------------------------------------------------------------------------------------------------------------
$include "TestClock.inc"