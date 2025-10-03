'-----------------------------------------------------------------------------------------
'                     1200.bas
' Notice that the 1200 support is very limited.
' For the best result you should write the program in ASM
'-----------------------------------------------------------------------------------------
$crystal = 1000000
$regfile = "1200def.dat"
$tiny
$noramclear
$hwstack = 0
$swstack = 0
$framesize = 0
Dim I As Iram Byte At 18
Config Portb = Output
Do
   Portb = 0
   For I = 1 To 100
   Next
   Portb = 255
   For I = 1 To 100
   Next
Loop