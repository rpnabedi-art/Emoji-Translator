'--------------------------------------------------------------
'                   M644.BAS
'--------------------------------------------------------------
$regfile = "M644def.dat"

'the following setting was used for this sample
'$prog &HFF , &HE2 , &H99 , &HFF                             ' generated. Take care that the chip supports all fuse bytes.
$hwstack = 40
$swstack = 40
$framesize = 40



'This file is intended to test the Mega644
'The M644 has the JTAG enabled by default so you can not use
'pins PORTC.2-PORTC.5

'Use the following code to disable JTAG
Mcusr = &H80
Mcusr = &H80
'Or program the fuse bit
$crystal = 8000000
$baud = 19200

On Int0 Testisr0
Enable Int0

Config Clock = Soft                                         ' clock crystal connected to portC.6 and portC.7
Enable Interrupts

Config Pinb.2 = Output
Config Com1 = Dummy , Synchrone = 0 , Parity = None , Stopbits = 1 , Databits = 8 , Clockpol = 0
'Config Adc = Single , Prescaler = Auto , Reference = Internal_1.1
Config Adc = Single , Prescaler = Auto , Reference = Internal_2.56


Dim Tel As Word
Do
  Tel = Tel + 1
  Print "hello world " ; Tel ; "  " ; Time$ ; "  " ; Getadc(0)
  Waitms 1000
  Toggle Portb.2
Loop

'this is a nice way to check if the program does not reset.

Testisr0:
!  nop
Return

End