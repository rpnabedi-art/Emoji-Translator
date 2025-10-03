'--------------------------------------------------------------
'                        ATtiny88.bas
'                      tiny88 sample file
'                  (c) 1996-2014, MCS Electronics
'--------------------------------------------------------------
$regfile = "attiny88.dat"
$crystal = 8000000
Config Clockdiv = 1                                         ' disable the 8 divider that is enabled by default
$hwstack = 40
$swstack = 16
$framesize = 24

' too nad this chip does not have a UART
Open "comd.1:19200,8,n,1" For Output As #1
Open "comd.0:19200,8,n,1" For Input As #2

Config Portb = Output

Dim B As Byte , W As Word

Dim K As Byte
Do
  K = Waitkey(#2)
  Print #1 , K
  Incr B
  Portb = Not Portb
  Print #1 , "hello tiny88 " ; B
  'we print the variable to see if the micro does not reset
  'when it resets it will never reach 255
  Waitms 500
Loop Until K = 27


Config Adc = Single , Prescaler = Auto , Reference = Internal
Start Adc
Do
   'in version 1.11.7.6 the GETADC() supports an offset parameter
   'you can use this to add an offset to the channel.
   'For example to use the differential and GAIN settings of some new AVRS's
   Print #1 , "ch0 " ; : W = Getadc(0 , 0) : Print #1,W
   Print #1 , "ch1 " ; Getadc(1)
   Waitms 1000
Loop

End