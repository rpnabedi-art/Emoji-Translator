'--------------------------------------------------------------
'                        EDBexperiment2.bas
'       Experiment 2 for the Educational Development Board
'                  (c) 1995-2006, MCS Electronics
'                        Fileversion 1.0
'--------------------------------------------------------------
'
'Purpose:
'This program 'rotates' the LED's on port D.
'
'Conclusions:
'You should be able to see a moving LED effect.


$regfile = "m88def.dat"                                     'To tell Bascom which chip we use
$crystal = 8000000
$hwstack = 40
$swstack = 40
$framesize = 40

Config Portd = Output                                       'Configure Pin D7 as output

Portd = &B1111110                                           'We start by making pd0 low (led on)

Do
   Rotate Portd , Right , 1                                 'Move the 'bits' one place to the right
                                                             'Now PD1 will light and PD0 goes out.
   Waitms 500                                               'Wait otherwise we cannot see te rotate
Loop

End


