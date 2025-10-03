'-----------------------------------------------------------------------------------------
'name                     : do_loop.bas
'copyright                : (c) 1995-2013, MCS Electronics
'purpose                  : demo: DO, LOOP
'micro                    : Mega48
'suited for demo          : yes
'commercial addon needed  : no
'-----------------------------------------------------------------------------------------

$regfile = "m48def.dat"                                     ' specify the used micro
$crystal = 8000000                                          ' used crystal frequency
$baud = 19200                                               ' use baud rate
$hwstack = 32                                               ' default use 32 for the hardware stack
$swstack = 10                                               ' default use 10 for the SW stack
$framesize = 40                                             ' default use 40 for the frame space

Dim A As Byte

A = 1                                                       'assign a var
Do                                                          'begin a do..loop
   Print A                                                  'print var
   Incr A                                                    'increase by one
Loop Until A = 10                                           'do until a=10
End

'You can write a never-ending loop with the following code
Do
   'Your code goes here
Loop