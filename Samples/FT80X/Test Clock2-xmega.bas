' For use with the FT800
' Original example posted by mathiasw at http://gameduino2.proboards.com/thread/42/clock-demo
' Requires Bascom 2.0.7.8 or greater

$regfile = "xm128a1def.dat"
$crystal = 32000000
$hwstack = 80
$swstack = 80
$framesize = 350

Config Osc = Enabled , 32mhzosc = Enabled
Config Sysclock = 32mhz                                     '--> 32MHz

Config Com1 = 19200 , Mode = Asynchroneous , Parity = None , Stopbits = 1 , Databits = 8
Open "COM1:" For Binary As #1

Config Submode = New
$NOTYPECHECK
Config Base = 0

Config Ft800 = Spid , Ftsave = 0 , Ftdebug = 0 , Ftcs = Portd.4 , Ftpd = Portd.0  ' Olimex
Config Spid = Hard , Master = Yes , Mode = 0 , Clockdiv = Clk32 , Data_order = Msb , Ss = none

$Include "FT80x.inc"
$Include "FT80x_Functions.inc"
'---------------------------
CONST FACE_HANDLE = &H0
CONST FACE_WIDTH = &HD6
CONST FACE_HEIGHT = &HD6
CONST FACE_CELLS = &H1
CONST HOUR_HANDLE = &H1
CONST HOUR_WIDTH = &H78
CONST HOUR_HEIGHT = &H79
CONST HOUR_CELLS = &H1
CONST MINUTE_HANDLE = &H2
CONST MINUTE_WIDTH = &H98
CONST MINUTE_HEIGHT = &H98
CONST MINUTE_CELLS = &H1
CONST SECOND_HANDLE = &H3
CONST SECOND_WIDTH = &HB3
CONST SECOND_HEIGHT = &HB3
CONST SECOND_CELLS = &H1
CONST SMALL_HANDLE = &H4
CONST SMALL_WIDTH = &H23
CONST SMALL_HEIGHT = &H23
CONST SMALL_CELLS = &H1
CONST ASSETS_END = &H38F9C

Dim t As Byte
Dim facex As Word
Dim facey As Word
Dim offset_sec As Byte
Dim center_sec As Byte
Dim offset_min As Byte
Dim center_min As Byte
Dim offset_hor As Byte
Dim center_hor As Byte
Dim offset_sm1 As Byte
Dim center_sm1 As Byte
Dim angles As Integer
Dim anglem As Integer
Dim angleh As Integer
Dim angles1 As Integer
Dim angles2 As Integer
Dim angles3 As Integer

Dim Tempw As Word
Dim Dloffset As Word

facex = 133
facey = 29
offset_sec = 18
center_sec = 90
offset_min = 32
center_min = 76
offset_hor = 48
center_hor = 60
offset_sm1 = 18
center_sm1 = 18
angles = 0
anglem = 0
angleh = 0
angles1 = 0
angles2 = 0
angles3 = 0

$Include "FT80x.inc"
$Include "FT80x_Functions.inc"

Spiinit

If FT800_Init()=1 Then End   ' Initialise the FT800

Tempdw = Loadlabel(clock_assets)
Loadcmd Tempdw , 18733

Do

   ClearScreen

   Begin_g Bitmaps
   Vertex2ii facex, facey, Face_Handle, 0

   Cmdtranslate center_sm1 * 65536 , center_sm1 * 65536
   Cmdrotatea angles1
   Cmdtranslate -center_sm1 * 65536 , -center_sm1 * 65536
   Cmdsetmatrix
   Vertex2ii facex + 90, facey + 34, Small_Handle, 0
   Cmdtranslate center_sm1 * 65536 , center_sm1 * 65536
   Cmdrotatea -angles1
   Cmdtranslate -center_sm1 * 65536 , -center_sm1 * 65536

   Cmdtranslate center_sm1 * 65536 , center_sm1 * 65536
   Cmdrotatea angles2
   Cmdtranslate -center_sm1 * 65536 , -center_sm1 * 65536
   CmdSetMatrix
   Vertex2ii facex + 90, facey + 147, Small_Handle, 0
   Cmdtranslate center_sm1 * 65536 , center_sm1 * 65536
   Cmdrotatea -angles2
   Cmdtranslate -center_sm1 * 65536 , -center_sm1 * 65536

   Cmdtranslate center_sm1 * 65536 , center_sm1 * 65536
   Cmdrotatea angles3
   Cmdtranslate -center_sm1 * 65536 , -center_sm1 * 65536
   CmdSetMatrix
   Vertex2ii facex + 34, facey + 89, Small_Handle, 0
   Cmdtranslate center_sm1 * 65536 , center_sm1 * 65536
   Cmdrotatea -angles3
   Cmdtranslate -center_sm1 * 65536 , -center_sm1 * 65536

   Cmdtranslate center_hor * 65536 , center_hor * 65536
   Cmdrotatea angleh
   Cmdtranslate -center_hor * 65536 , -center_hor * 65536
   CmdSetMatrix
   Vertex2ii facex + offset_hor, facey + offset_hor, Hour_Handle, 0
   Cmdtranslate center_hor * 65536 , center_hor * 65536
   Cmdrotatea -angleh
   Cmdtranslate -center_hor * 65536 , -center_hor * 65536

   Cmdtranslate center_min * 65536 , center_min * 65536
   Cmdrotatea anglem
   Cmdtranslate -center_min * 65536 , -center_min * 65536
   CmdSetMatrix
   Vertex2ii facex + offset_min, facey + offset_min, Minute_Handle, 0
   Cmdtranslate center_min * 65536 , center_min * 65536
   Cmdrotatea -anglem
   Cmdtranslate -center_min * 65536 , -center_min * 65536

   Cmdtranslate center_sec * 65536 , center_sec * 65536
   Cmdrotatea angles
   Cmdtranslate -center_sec * 65536 , -center_sec * 65536
   CmdSetMatrix
   Vertex2ii facex + offset_sec, facey + offset_sec, Second_Handle, 0
   Cmdtranslate center_sec * 65536 , center_sec * 65536
   Cmdrotatea -angles
   Cmdtranslate -center_sec * 65536 , -center_sec * 65536

   CmdLoadIdentity
   Updatescreen

   incr angles
   If angles > 360 Then angles = 1
   anglem  = angles * 2  ' for test: minute rotates double the angle of seconds
   angleh  = angles * 3  ' for test: minute rotates double the angle of seconds
   angles1 = angles * 4  ' for test: minute rotates double the angle of seconds
   angles2 = angles * 5  ' for test: minute rotates double the angle of seconds
   angles3 = angles * 6  ' for test: minute rotates double the angle of seconds


Loop


End

'------------------------------------------------------------------------------------------------------------
$include "TestClock2.inc"