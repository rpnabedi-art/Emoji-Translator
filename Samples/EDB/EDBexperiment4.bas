'--------------------------------------------------------------
'                        EDBexperiment4.bas
'       Experiment 4 for the Educational Development Board
'                  (c) 1995-2006, MCS Electronics
'                        Fileversion 1.0
'--------------------------------------------------------------
'
'Purpose:
'This program flashes Portd.3 and portd.5 on the EDB
'
'Conclusions:
'You should see Portd.3 and 5 flashing

$regfile = "m88def.dat"                                     'To tell Bascom which chip we use
$crystal = 8000000
$hwstack = 40
$swstack = 40
$framesize = 40


Config Pind.3 = Output                                      'Configure Pin D3 as output
Config Pind.5 = Output                                      'Configure Pin D5 as output


Do                                                          'Do...loop will loop forever
   Set Portd.3                                               'Switch Pind.3 on
   Set Portd.5
   Waitms 250                                               'Wait a moment so we can see it
   Reset Portd.3                                             'Switch Pind.3 off
   Reset Portd.5
   Waitms 250                                               'Wait a moment so we can see it
Loop

End