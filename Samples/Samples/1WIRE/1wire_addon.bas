'--------------------------------------------------------------------
'                           (c) 1995-2014 MCS Electronics
' 1wire_addon.bas , demonstration of the special 1wire long range addon
' this file requires a commercial add on library
' BASCOM supports 1wire, and even multiple 1wire busses
' For long distances, you can use 4 pins and some additional electronics to
' compensate for the long wires/bus load
'--------------------------------------------------------------------
$regfile = "m88def.dat"
$crystal = 8000000
$baud = 19200
$hwstack = 40                                               ' default use 32 for the hardware stack
$swstack = 32                                               'default use 10 for the SW stack
$framesize = 40                                             'default use 40 for the frame space


Config 1wire = Portb.4 , Extended = 2 , Drive = Portb.3 , Dpu = Portb.2 , Spu = Portb.5
'This will configure to use PORTB.4 for the SENSE
'                           PORTB.3 for DRIVE
'                           PORTB.2 for DPU
'                           PORTB.5 for SPU
' You must set EXTENDED to 2.
' Note that you must use normal pins, extended port pins(at an extended address) are not supported.

Dim Ar(8) As Byte , I As Byte                               ' dim some variables
Dim X As Byte , W As Word

1wreset                                                     ' reset the bus
Print "1W:" ; Err                                           ' return result,0=OK,1=ERROR

W = 1wirecount()
Print W                                                     ' return number of sensors on the bus

1wwrite &H33                                                'read ROM command
For I = 1 To 8
   Ar(i) = 1wread()                                          'place into array
   Print Hex(ar(i)) ; "," ;
Next
Print

Dim Reg_no(8) As Byte
Reg_no(1) = 1wsearchfirst()                                 ' load with first sensor
Do
  'Now search for other devices
   Reg_no(1) = 1wsearchnext()
   For I = 1 To 8
      Print Hex(reg_no(i));
   Next
   Print
Loop Until Err = 1

End