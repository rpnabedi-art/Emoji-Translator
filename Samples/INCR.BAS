'-----------------------------------------------------------------------------------------
'name                     : incr.bas
'copyright                : (c) 1995-2013, MCS Electronics
'purpose                  : demo: INCR
'micro                    : Mega88
'suited for demo          : yes
'commercial addon needed  : no
'-----------------------------------------------------------------------------------------
$RegFile = "m88def.dat"
$crystal = 8000000
$baud = 19200
$hwstack = 32

Dim A As Byte

A = 5                                   'assign value to a
Incr A                                  'inc (by one)
Print A                                 'print it
End