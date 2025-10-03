'--------------------------------------------------------------
'                        EDBexperiment12a.bas
'       Experiment 12a for the Educational Development Board
'                  (c) 1995-2006, MCS Electronics
'                        Fileversion 1.0
'--------------------------------------------------------------
'
'Purpose:
'This program shows a counter without anti bounce
'
'Conclusions:
'This program cannot be used since it counts inadequate.


$regfile = "m88def.dat"                                     'To tell Bascom which chip we use
$crystal = 8000000
$baud = 19200
$hwstack = 40
$swstack = 40
$framesize = 40

Dim Count As Byte
Count = 0

Config Pind.7 = Input                                       'Configure Pin D7 as input
Config Pinb.1 = Output                                      'Configure Pin B1 as output

Print "Counter"

Do                                                          'Do...loop will loop forever
   Portb.1 = Pind.7                                         'Assign the output with the input value

   If Pind.7 = 0 Then                                       'If key is pressed
      Count = Count + 1                                     'Count up
      Print Count                                           'And print count
      Waituntil1:                                           '
      If Pind.7 = 0 Then Goto Waituntil1                    'As long as we keep de switch down do nothing
   End If



Loop

End