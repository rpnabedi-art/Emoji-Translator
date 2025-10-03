'------------------------------------------------------------------------------
'name                     : basmon_test.bas
'copyright                : (c) 1995-2013, MCS Electronics
'purpose                  : demonstrates usage of simulator & basmon
'micro                    : Mega48
'suited for demo          : yes
'commercial addon needed  : no
'------------------------------------------------------------------------------
$regfile = "m48def.dat"                                     ' we use the M48
$crystal = 8000000
$baud = 19200

$hwstack = 32
$swstack = 8
$framesize = 24


Config Portb = Output
Do
   Incr Portb
Loop