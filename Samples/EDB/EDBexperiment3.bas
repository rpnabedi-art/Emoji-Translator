'--------------------------------------------------------------
'                        EDBexperiment3.bas
'       Experiment 3 for the Educational Development Board
'                  (c) 1995-2006, MCS Electronics
'                        Fileversion 1.0
'--------------------------------------------------------------
'
'Purpose:
'This test program flashes Portd.1 on the EDB
'
'Conclusions:
'You should see Portd.1 flashing

$regfile = "m88def.dat"                                     'To tell Bascom which chip we use
$crystal = 8000000
$hwstack = 40
$swstack = 40
$framesize = 40

Config Pind.1 = Output                                      'Configure Pin D1 as output


Do                                                          'Do...loop will loop forever
   Set Portd.1                                               'Switch Pind.1 on
   Waitms 250                                               'Wait a moment so we can see it
   Reset Portd.1                                             'Switch Pind.1 off
   Waitms 250                                               'Wait a moment so we can see it
Loop

End