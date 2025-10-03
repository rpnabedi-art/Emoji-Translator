'--------------------------------------------------------------
'                        EDBexperiment6a.bas
'       Experiment 6a for the Educational Development Board
'                  (c) 1995-2006, MCS Electronics
'                        Fileversion 1.0
'--------------------------------------------------------------
'
'Purpose:
'Send "Hello World" message to the computers COM port
'
'Conclusions:
'You should be able to print something to the COM port

$regfile = "m88def.dat"                                     'To tell Bascom which chip we use
$crystal = 8000000                                          'Define internal oscillator speed
$baud = 19200                                               'Define baud rate 19200
$hwstack = 40
$swstack = 40
$framesize = 40


Do
   Print "Hello World"                                      'The print statements sends a string to the UART
   Waitms 50
Loop

End