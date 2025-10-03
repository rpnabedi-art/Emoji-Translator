'----------------------------------------------------------------
'                          (c) 1995-2005, MCS
'                 single_scientific.bas
' demonstation of scientific , single output
'----------------------------------------------------------------

$regfile = "m88def.dat"
$crystal = 8000000
$baud = 19200
$hwstack = 40
$swstack = 40
$framesize = 40


'you can view the difference by compiling and simulating  this sample with the
'line below remarked and active
'Config Single = Scientific , Digits = 7

Dim S As Single
S = 1
Do
  S = S / 10
  Print S
Loop