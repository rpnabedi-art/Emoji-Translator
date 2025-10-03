'--------------------------------------------------------------
'                        EDBexperiment1.bas
'       Experiment 1 for the Educational Development Board
'                  (c) 1995-2006, MCS Electronics
'                        Fileversion 1.0
'--------------------------------------------------------------
'
'Purpose:
'This program assigns the value of Pind.7 to Pinb.1.
'
'Conclusions:
'You should be able to switch the led with a key press.


$regfile = "m88def.dat"                                     'To tell Bascom which chip we use
$crystal = 8000000

$hwstack = 40
$swstack = 40
$framesize = 40


Config Pind.7 = Input                                       'Configure Pin D7 as input
Config Pinb.1 = Output                                      'Configure Pin B1 as output


Do                                                          'Do...loop will loop forever
   Portb.1 = Pind.7                                         'Assign the output with the input value
Loop

End