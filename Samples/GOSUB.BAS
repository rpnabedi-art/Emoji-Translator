'------------------------------------------------------------------------------
'name                     : gosub.bas
'copyright                : (c) 1995-2005, MCS Electronics
'purpose                  : demonstrates  GOTO, GOSUB and RETURN
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

Goto Continue
Print "This code will not be executed"

Continue:                                                   'end a label with a colon
   Print "We will start execution here"
   Gosub Routine
   Print "Back from Routine"
   End





Routine:                                                    'start a subroutine
   Print "This will be executed"
Return                                                      'return from subroutine