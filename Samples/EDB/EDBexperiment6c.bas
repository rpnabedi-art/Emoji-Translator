'--------------------------------------------------------------
'                        EDBexperiment6c.bas
'       Experiment 6c for the Educational Development Board
'                  (c) 1995-2006, MCS Electronics
'                        Fileversion 1.0
'--------------------------------------------------------------
'
'Purpose:
'This program shows how to use the Open, Close and Inkey() statements
'
'Conclusions:
'You should be able to work with a Software UART

$regfile = "m88def.dat"
$crystal = 8000000
$baud = 19200
$hwstack = 40
$swstack = 40
$framesize = 40

Dim B As Byte
Waitms 100

'Open a TRANSMIT channel for output
Open "comc.1:19200,8,n,1" For Output As #1
Print #1 , "serial output"


'Now open a RECEIVE channel for input
Open "comc.2:19200,8,n,1" For Input As #2
'Since there is no relation between the input and output pin
'there is NO ECHO while keys are typed

Print #1 , "Press any alphanumerical key"



'With INKEY() we can check if there is data available
'To use it with the software UART you must provide the channel
Do
   'Store in byte
   B = Inkey(#2)
   'When the value > 0 we got something
   If B > 0 Then
      Print #1 , Chr(b)                                     'Print the character
   End If
Loop


Close #2                                                    'Close the channels
Close #1

End