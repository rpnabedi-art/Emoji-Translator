'-----------------------------------------------------------------------------------------
'name                     : m16.bas
'copyright                : (c) 1995-2005, MCS Electronics
'purpose                  : test file for M16 support
'micro                    : Mega16
'suited for demo          : yes
'commercial addon needed  : no
'-----------------------------------------------------------------------------------------

$regfile = "m16def.dat"                                     ' specify the used micro
$crystal = 8000000                                          ' used crystal frequency
$baud = 19200                                               ' use baud rate
$hwstack = 32                                               ' default use 32 for the hardware stack
$swstack = 10                                               ' default use 10 for the SW stack
$framesize = 40                                             ' default use 40 for the frame space

$lib "mcsbyte.lbx"
Config Com1 = Dummy , Synchrone = 0 , Parity = None , Stopbits = 1 , Databits = 8 , Clockpol = 0


Dim I As Byte

For I = 1 To 250 Step 10
  Waitms 100
  Print "Hello world" ; I
Next

Print "M16 at 8 MHz internal osc"

End

Data "some additonal lines to check programming"
Data "some additonal lines to check programming"
Data "some additonal lines to check programming"
Data "some additonal lines to check programming"
Data "some additonal lines to check programming"
Data "some additonal lines to check programming"
Data "some additonal lines to check programming"
Data "some additonal lines to check programming"
Data "some additonal lines to check programming"
Data "some additonal lines to check programming"
Data "some additonal lines to check programming"
Data "some additonal lines to check programming"
Data "some additonal lines to check programming"
Data "some additonal lines to check programming"
Data "some additonal lines to check programming"
Data "some additonal lines to check programming"
Data "some additonal lines to check programming"
Data "some additonal lines to check programming"
Data "some additonal lines to check programming"
Data "some additonal lines to check programming"
Data "some additonal lines to check programming"
Data "some additonal lines to check programming"
Data "some additonal lines to check programming"
Data "some additonal lines to check programming"
Data "some additonal lines to check programming"
Data "some additonal lines to check programming"