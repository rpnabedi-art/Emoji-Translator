
' Demo_Sprites.bas for the FT800 - Eve Version
' Original Example from James Bowman, Arduino 2 - Examples - Basic - Frizz
' http://excamera.com/sphinx/gameduino2/
' Bascom 2.0.7.7
$regfile = "xm128a1def.dat"
$crystal = 32000000
$hwstack = 52
$swstack = 52
$framesize = 60

Config Osc = Enabled , 32mhzosc = Enabled
Config Sysclock = 32mhz                                     '--> 32MHz

'configure the priority
'Config Priority = Static , Vector = Application , Lo = Enabled
Config Com1 = 19200 , Mode = Asynchroneous , Parity = None , Stopbits = 1 , Databits = 8
Open "COM1:" For Binary As #1

Config Submode = New

Config ft800=spic ,  ftcs=portc.4, ftpd=portc.0

Config Spic = Hard , Master = Yes , Mode = 0 , Clockdiv = Clk32 , Data_order = Msb , Ss = none
'C.4-SS , C.5-MOSI , C.6-MISO  , C.7-SCK
'C.2 and C.3 used for RS232
'C0 - Power down pin
'C4 - chip select


$Include "FT800.inc"
$Include "FT800_Functions.inc"

declare Sub Fizz()

' General Program Variables and Declarations
Dim I As Byte


Spiinit
'Enable Interrupts


If FT800_Init() = 1 Then
   Print "Error with FT800"
   End
End If


Do
   Fizz

   Waitms 250
Loop

End

'-----------------------------------------------------------

Sub Fizz()
   local c1 as byte,c2 as byte ,c3 as byte, x as word


   ClearScreen

   Begin_G FTPOINTS

   For I = 0 to 99
      c1=rnd(256) : c2=rnd(256) : c3=rnd(256) : x= rnd(ft_dispwidth)
      PointSize rnd(800)
      ColorRGB c1 , c2 , c3
      Color_A rnd(256)
      Vertex2ii rnd(Ft_DispHeight) , x , 0 , 0
   Next
   UpdateScreen
End sub