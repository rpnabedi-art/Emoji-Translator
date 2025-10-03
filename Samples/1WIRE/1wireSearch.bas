'--------------------------------------------------------------------------------
'name                     : 1wireSearch.bas
'copyright                : (c) 1995-2015, MCS Electronics
'purpose                  : demonstrates 1wsearch
'micro                    : Mega88
'suited for demo          : yes
'commercial addon needed  : no
'--------------------------------------------------------------------------------

$regfile = "m88def.dat"
$crystal = 8000000
$baud = 19200
$hwstack = 32                                               ' default use 32 for the hardware stack
$swstack = 10                                               'default use 10 for the SW stack
$framesize = 40                                             'default use 40 for the frame space

Config 1wire = Portb.2                                      'use this pin
'On the STK200 jumper B.2 must be inserted

'The following internal bytes are used by the scan routines
'___1w_bitstorage , Byte used for bit storage :
'      lastdeviceflag bit 0
'      id_bit         bit 1
'      cmp_id_bit     bit 2
'      search_dir     bit 3
'___1wid_bit_number, Byte
'___1wlast_zero,  Byte
'___1wlast_discrepancy , Byte
'___1wire_data , string * 7 (8 bytes)

'[DIM variables used]
'we need some space from at least 8 bytes to store the ID
Dim Reg_no(8) As Byte

'we need a loop counter and a word/integer for counting the ID's on the bus
Dim I As Byte , W As Word

'Now search for the first device on the bus
Reg_no(1) = 1wsearchfirst()

For I = 1 To 8                                              'print the number
   Print Hex(reg_no(i));
Next
Print

Do
  'Now search for other devices
   Reg_no(1) = 1wsearchnext()
   For I = 1 To 8
      Print Hex(reg_no(i));
   Next
   Print
Loop Until Err = 1



'When ERR = 1 is returned it means that no device is found anymore
'You could also count the number of devices
W = 1wirecount()
'It is IMPORTANT that the 1wirecount function returns a word/integer
'So the result variable must be of the type word or integer
'But you may assign it to a byte or long too of course
Print W


'as a bonus the next routine :
' first fill the array with an existing number
Reg_no(1) = 1wsearchfirst()
' unremark next line to chance a byte to test the ERR flag
'Reg_no(1) = 2
'now verify if the number exists
1wverify Reg_no(1)
Print Err
'err =1 when the ID passed n reg_no() does NOT exist
' optinal call it with pinnumber line  1wverify reg_no(1),pinb,1

'As for the other 1wire statements/functions, you can provide the port and pin number as anoption
'W = 1wirecount(pinb , 1)                                    'for example look at pin PINB.1
End