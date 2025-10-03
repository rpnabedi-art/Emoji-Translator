'-----------------------------------------------------------------
'                       SENDRC6.BAS
'                   (c) 2003 MCS Electronics
' code based on application note from Ger Langezaal
'   +5V <---[A Led K]---[220 Ohm]---> Pb.3 for 2313.
' RC6SEND is using TIMER1, no interrupts are used
' The resistor must be connected to the OC1(A) pin , in this case PB.3
'-----------------------------------------------------------------
$regfile = "2313def.dat"
$crystal = 4000000
$hwstack = 40
$swstack = 40
$framesize = 40


Dim Togbit As Byte , Command As Byte , Address As Byte

'this controls the TV but you could use rc6send to make your DVD region free as well :-)
'Just search the net for the codes you need to send. Do not ask me for info please.
Command = 32                                                ' channel next
Togbit = 0                                                  ' make it 0 or 32 to set the toggle bit
Address = 0
Do
   Waitms 500
   Rc6send Togbit , Address , Command
Loop
End