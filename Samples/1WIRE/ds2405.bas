'-------------------------------------------------------------------------------
'                             (c) 2003-2015 MCS Electronics
'                         ds2405 1wire sample
'-------------------------------------------------------------------------------
$regfile = "M88def.dat"
$crystal = 4000000
$baud = 19200
$hwstack = 40
$swstack = 40
$framesize = 40

Config 1wire = Portb.0                                      'use this pin
'On the STK200 jumper B.0 must be inserted
'Use a 4k7 pull up resistor when not using the STK

'we need some space from at least 8 bytes to store the ID
Dim Reg_no(8) As Byte

'we need a loop counter
Dim I As Byte

'Now search for the first device on the bus
Do
   Reg_no(1) = 1wsearchfirst()
   1wreset                                                   ' reset the bus
   1wwrite &H55
   1wwrite Reg_no(1) , 8                                     ' write the ID
   'the ds2405 will change state now and we need to read 1 byte to determine the new state
   I = 1wread(1 , Pinb , 0)                                  ' get the new state
   Print I
   '0 means pull down on
   '255 means pull down off
   Waitms 1000                                               ' wait for 1 sec
Loop
End                                                         'end program