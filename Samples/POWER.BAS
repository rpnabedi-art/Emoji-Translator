'-------------------------------------------
'              (c) 1999-2013 MCS Electronics
'               POWER.BAS
' please check the help for CONFIG POWER, the new power down command
'-------------------------------------------
$regfile = "8515def.dat"
$baud = 19200
$crystal = 4000000
'set HW stack to 40 for this sample

Print "start"

Enable Int0
Enable Interrupts
On Int0 Int0_isr
Do
  Print "power down"
  Powerdown
  Print "return from power down"
Loop
End


Int0_isr:
   Print "in isr"
Return


End