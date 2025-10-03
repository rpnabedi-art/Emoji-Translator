' Demo_Sprites.bas for the FT800 - Eve Version
' Original Example from James Bowman, Arduino 2 - Examples - Basic - Frizz
' http://excamera.com/sphinx/gameduino2/
' Bascom 2.0.7.8 or greater

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


' General Program Variables and Declarations
Dim I As Byte
Dim C1 as Byte, C2 as Byte, C3 as Byte

Spiinit
'Enable Interrupts

If FT800_Init() = 1 Then
   Print "Error with FT800"
   End
End If


   Do
      GoSub Fizz

      Waitms 200
   Loop

End

'-----------------------------------------------------------
Fizz:
'-----------------------------------------------------------

   ClearScreen

   Begin_G FTPOINTS

   For I = 0 to 99 ' <-- do not make this much higher as the FT800 won't be able to keep up
      C1=Rnd(256): C2=Rnd(256): C3=Rnd(256)
      PointSize Rnd(800)
      ColorRGB C1, C2, C3
      Color_A Rnd(256)
      Vertex2ii Rnd (Ft_DispWidth-1), Rnd(ft_Dispwidth-1), 0, 0
   Next

   UpdateScreen

Return  ' Fizz

'-----------------------------------------------------------