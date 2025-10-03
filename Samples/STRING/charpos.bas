'-------------------------------------------------------------------------------
'                       charpos.bas
'               (c) 1995-2009  MCS Electronics
$regfile = "m88def.dat"
$crystal = 8000000
$baud = 19200
$hwstack = 40
$swstack = 40
$framesize = 40
'-------------------------------------------------------------------------------
Dim S As String * 20
Dim Bpos As Byte
Dim Z As String * 1

Z = "*"
Do
  Input "S:" , S
  Bpos = Charpos(s , Z)
  Print Bpos
Loop Until S = ""


Do
  Input "S:" , S
  Bpos = Charpos(s , "A")                                   ' notice charpos is sensitive to case
  Print Bpos
Loop
