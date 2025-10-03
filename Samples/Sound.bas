'------------------------------------------------------------------------------
'name                     : sound.bas
'copyright                : (c) 1995-2013, MCS Electronics
'purpose                  : demonstrates SOUND
'micro                    : Mega48
'suited for demo          : yes
'commercial addon needed  : no
'------------------------------------------------------------------------------
$RegFile = "m88def.dat"                                     ' we use the M48
$Crystal = 8000000
$Baud = 19200

$HWstack = 32
$SWstack = 32
$FrameSize = 24

Dim Pulses As Word , Periods As Word
Pulses = 1300 : Periods = 637                               'set variables
Speaker Alias PORTB.4                                       'define port pin
Do
  '  Sound Speaker , Pulses , Periods                          'make some noice
  '  Waitms 500
  Sound Speaker , 124 , 675                                   'H2(1/16)
  Sound Speaker , 110 , 758                                   'A2(1/16)
  Sound Speaker , 248 , 675                                   'H2(1/8)
  WaitmS 125                                                  'P(1/16)
  Sound Speaker , 165 , 1011                                  'E2(1/8)
  WaitmS 250                                                  'P(1/8)
  WaitmS 125                                                  'P(1/16)
  Sound Speaker , 131 , 637                                   'C3(1/16)
  Sound Speaker , 124 , 675                                   'H2(1/16)
  Sound Speaker , 131 , 637                                   'C3(1/16)
  WaitmS 125                                                  'P(1/16)
  Sound Speaker , 124 , 675                                   'H2(1/16)
  WaitmS 125                                                  'P(1/16)
  Sound Speaker , 220 , 758
Loop
'note that pulses and periods must have a high value for high XTALS
'sound is only intended to make some noise!

'pulses  range from 1-65535
'periods range from 1-65535

End