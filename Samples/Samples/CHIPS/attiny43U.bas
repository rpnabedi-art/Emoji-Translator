$regfile = "attiny43u.dat"
$crystal = 8000000
$hwstack = 24
$swstack = 16
$framesize = 32

Config Clockdiv = 1                                         'override fuse byte clock divider


Open "COMB.0:9600,8,N,1" For Output As #1

Do
  Print #1 , "Hello world"
  Waitms 500
Loop
End