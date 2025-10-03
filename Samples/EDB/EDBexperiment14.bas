'--------------------------------------------------------------
'                        EDBexperiment14.bas
'       Experiment 14 for the Educational Development Board
'                  (c) 1995-2006, MCS Electronics
'                        Fileversion 1.0
'--------------------------------------------------------------
'
'Purpose:
'This program shows how to use the sound statement
'
'Conclusions:
'You should be able to hear a siren

$regfile = "m88def.dat"
$crystal = 8000000
$baud = 19200
$hwstack = 40
$swstack = 40
$framesize = 40

Dim W As Word

W = 100

   Do
      Sound Portd.3 , 5 , W                                 'SOUND  pin, duration, pulses
      W = W + 1
      If W > 1000 Then W = 100
   Loop


End