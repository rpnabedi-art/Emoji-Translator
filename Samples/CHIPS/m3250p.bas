'--------------------------------------------------------------
'                   M3250p.BAS
'--------------------------------------------------------------
$regfile = "M3250pdef.dat"

'This file is intended to test the Mega3250p
'The M325 has the JTAG enabled by default so you can not use
'pins PORTF.4-PORTF.7

'Use the following code to disable JTAG
'Mcusr = &H80
'Mcusr = &H80
'Or program the fuse bit
$crystal = 8000000
$baud = 19200
$hwstack = 40
$swstack = 40
$framesize = 40



Config Pinb.2 = Output
Config Com1 = Dummy , Synchrone = 0 , Parity = None , Stopbits = 1 , Databits = 8 , Clockpol = 0

Dim Tel As Word
Do
  Tel = Tel + 1
  Print "hello world " ; Tel
  Waitms 1000
  Toggle Portb.2
Loop

'this is a nice way to check if the program does not reset.
'since a reset would cause the "tel" variable not to increase

End