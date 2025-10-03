'-----------------------------------------------------------------
'                       RC5SEND.BAS
'                   (c) 2003-2005 MCS Electronics
' code based on application note from Ger Langezaal
'   +5V <---[A Led K]---[220 Ohm]---> Pb.3 for 2313.
' RC5SEND is using TIMER1, no interrupts are used
' The resistor must be connected to the OC1(A) pin , in this case PB.3
'-----------------------------------------------------------------
$regfile = "2313def.dat"
$crystal = 4000000
$hwstack = 40
$swstack = 40
$framesize = 40


Dim Togbit As Byte , Command As Byte , Address As Byte

Command = 12                                                ' power on off
Togbit = 0                                                  ' make it 0 or 32 to set the toggle bit
Address = 0
Do
   Waitms 500
   Rc5send Togbit , Address , Command
   'or use the extended RC5 send code. You can not use both
   'make sure that the MS bit is set to 1, so you need to send
   '&B10000000 this is the minimal requirement
   '&B11000000 this is the normal RC5 mode
   '&B10100000 here the toggle bit is set
   ' Rc5sendext &B11000000 , Address , Command
Loop

End