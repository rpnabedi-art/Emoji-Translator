'-----------------------------------------------------------------------------------------
'name                     : deboun.bas
'copyright                : (c) 1995-2013, MCS Electronics
'purpose                  : demonstrates DEBOUNCE
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

Config Debounce = 30                                        'when the config statement is not used a default of 25mS will be used but we override to use 30 mS


'Debounce Pind.0 , 1 , Pr 'try this for branching when high(1)
Debounce PIND.0 , 0 , Pr , Sub
Debounce PIND.0 , 0 , Pr , Sub
'                     ^----- label to branch to
'                 ^---------- Branch when P1.0 goes low(0)
'           ^---------------- Examine P1.0

'When Pind.0 goes low jump to subroutine Pr
'Pind.0 must go high again before it jumps again
'to the label Pr when Pind.0 is low

Debounce PIND.0 , 1 , Pr                                  'no branch
Debounce PIND.0 , 1 , Pr                                  'will result in a return without gosub
End

Pr:
  Print "PIND.0 was/is low"
Return