'-------------------------------------------
'              (c) 1999-2013 MCS Electronics
'               IDLE.BAS
'-------------------------------------------
$regfile = "8515def.dat"
$baud = 19200
$crystal = 4000000
'set HW stack to 40 for this sample
$hwstack = 40

Print "start"

Config Timer1 = Timer , Prescale = 1024
'at 4 MHz it gives an overflow at 4000000 / (1024*65536)= 16 sec
'we want to have a timer for 2*16=32 secs so we use a variable to count the
'16 secs

Dim Bcounter As Byte

'we can not use a simple IDLE now, we also must take into account
' the value of Bcounter
Enable timer1
Enable Interrupts
On Timer1 Timer1_isr
Do
   Print "idle"
   Do
      Idle
      'we get back when 1 secs are elapsed
      'but we must go back into idle mode if bcounter is not 2 yet
      If Bcounter = 2 Then
         Print "return from idle"
         Bcounter = 0                                         ' reset
         Exit Do                                              ' leave the loop
      End If
   Loop
Loop
End


Timer1_isr:
   Incr Bcounter                                            ' +1
   If Bcounter = 2 Then
      Print "in isr"
   End If
   'idle can not be used into the ISR !!!
Return

End