'-----------------------------------------------------------------------------------------
'name                     : m163.bas
'copyright                : (c) 1995-2005, MCS Electronics
'purpose                  : Test file for M163 support
'micro                    : Mega163
'suited for demo          : yes
'commercial addon needed  : no
'-----------------------------------------------------------------------------------------

$regfile = "m163def.dat"                                    ' specify the used micro
$crystal = 1000000                                          ' used crystal frequency
$baud = 19200                                               ' use baud rate
$hwstack = 32                                               ' default use 32 for the hardware stack
$swstack = 10                                               ' default use 10 for the SW stack
$framesize = 40                                             ' default use 40 for the frame space

Dim I As Byte

'this code learned that a value of 175 works for the internal osc
'for the demo I skip it however
Goto Test
For I = 1 To 255 Step 10
  Osccal = I
  Waitms 100
  Print "Hello world" ; I
Next

Test:
Osccal = 175
Print "M163"
End