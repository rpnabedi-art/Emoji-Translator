'---------------------------------------------------------
'              (c) 1995-2013, MCS ELectronics
'   demo for $INITMICRO directive
'---------------------------------------------------------

'when it is important that a portpin is set to a logic level as quick
'as possible at startup, you do not want to wait until all initialisation
'code has executed (stack setup, clear of ram, init lcd etc.)

'Here is where you can use $INITMICRO

$regfile = "2313def.dat"
$hwstack = 24
$swstack = 16
$framesize = 16

$initmicro

Print Version()                                             'show date and time of compilation

Print Portb
Do
  !nop
Loop
End



'do not write a complete application in this routine.
'only perform needed init functions
_init_micro:
  Config Portb = Output
  Portb = 3
Return