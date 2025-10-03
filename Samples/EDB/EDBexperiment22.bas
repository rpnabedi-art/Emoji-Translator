'--------------------------------------------------------------
'                        EDBexperiment22.bas
'       Experiment 22 for the Educational Development Board
'                  (c) 1995-2006, MCS Electronics
'                        Fileversion 1.0
'--------------------------------------------------------------
'
'Purpose:
'This program shows how to use the Quasar Stepper Motor Driver
'
'Conclusions:
'You should be able to use stepper motors

$regfile = "m88def.dat"                                     'To tell Bascom which chip we use
$crystal = 8000000
$hwstack = 40
$swstack = 40
$framesize = 40

Config Pind.0 = Output                                      'Configure Pin D1 as output
Config Pind.1 = Output

Stap Alias Portd.0
Direction Alias Portd.1

set Direction

Do
   'Reset Direction  'Un remark this line if you wish to change the motors direction
   Set Stap                                                 'Send a pulse to the motor
   Waitms 250                                               'Wait a moment so we can see it
   Reset Stap                                               'Send a pulse to the motor
   Waitms 250                                               'Wait a moment so we can see it
Loop

End