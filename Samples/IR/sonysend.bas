'-----------------------------------------------------------------
'                       SONYSEND.BAS
'                   (c) 2002-2003 MCS Electronics
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


Do
   Waitms 500
   Sonysend &HA90
Loop

End
