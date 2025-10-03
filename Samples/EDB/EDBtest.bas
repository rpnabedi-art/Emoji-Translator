'--------------------------------------------------------------
'                         EDBtest.bas
'       HW Testfile for the Educational Development Board
'                  (c) 1995-2006, MCS Electronics
'                        Fileversion 1.0
'--------------------------------------------------------------
'
'Purpose:
'This test program flashes LED D3 on the EDB with 200ms interval.
'
'Conclusions:
'If the LED flashes the EDB's power supply is OK and the
'controller works.
'
'If the led doesn't flash, read chapter 2.4, troubleshooting of the EDB manual


$regfile = "m88def.dat"                                     'To tell Bascom which chip we use
$crystal = 8000000
$baud = 38400
$hwstack = 40
$swstack = 40
$framesize = 40


Config Pind.7 = Output                                      'Configure Pin D1 as output


Do                                                          'Do...loop will loop forever
   Set Portd.7                                               'Switch the LED off (negative logic)
   Waitms 50                                                'Wait a moment so we can see it
   Reset Portd.7                                             'Switch the LED on
   Waitms 50                                                'Wait a moment so we can see it
Loop

End