$regfile = "attiny167.dat"
$crystal = 8000000
$hwstack = 24
$swstack = 16
$framesize = 32
$baud = 115200
Config Clockdiv = 1

Config Porta.1 = Output                                     'TX must be made an output
Porta.0 = 1                                                 'pull up on RX

Do
  Print "Hello world"
  If Inkey() <> 0 Then
     Print "RX test"
  End If
  Waitms 500
Loop
End