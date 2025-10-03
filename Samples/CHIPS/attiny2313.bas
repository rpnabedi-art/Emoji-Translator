$regfile = "attiny2313.dat"
$crystal = 8000000
$baud = 9600
$hwstack = 32
$swstack = 8
$framesize = 16


Waitms 1000
Dim I As Integer
Do
  Incr I
  Print "test " ; I
  Waitms 500
Loop
