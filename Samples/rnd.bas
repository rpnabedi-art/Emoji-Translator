'-----------------------------------------------------------------------------------------
'name                     : RND.bas
'copyright                : (c) 1995-2011, MCS Electronics
'purpose                  : demo: RND
'micro                    : Mega88
'suited for demo          : yes
'commercial addon needed  : no
'-----------------------------------------------------------------------------------------
$RegFile = "m88def.dat"
$Crystal = 8000000
$baud = 19200

Dim I As Word                                               ' dim variable
Do
  I = Rnd(20)                                               'get random number (0-19)
  Print I                                                   'print the value
Loop                                                        'for ever
End
