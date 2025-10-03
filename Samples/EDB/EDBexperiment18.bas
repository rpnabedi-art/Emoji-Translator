'--------------------------------------------------------------
'                        EDBexperiment18.bas
'       Experiment 18 for the Educational Development Board
'                  (c) 1995-2006, MCS Electronics
'                        Fileversion 1.0
'--------------------------------------------------------------
'
'Purpose:
'This program shows a seconds timer
'
'Conclusions:
'You should now know how to use internal timers

$regfile = "m88def.dat"
$crystal = 8000000
$baud = 19200
$hwstack = 40
$swstack = 40
$framesize = 40

Dim Secondcount As Word
Dim Seconds As Word

'The following code shows how to use the TIMER0 in interrupt mode

'Configute the timer to use the clock divided by 1024
Config Timer0 = Timer , Prescale = 1024

'Define the interrupt handler, an interrupt occurs after the timer has overflowm
On Ovf0 Tim0_isr

Print
Print "Seconds running:"

Enable Timer0                                               ' enable the timer interrupt
Enable Interrupts                                           'allow interrupts to occur

Do
   'your program goes here
Loop

'The following code is executed when the timer rolls over
'31 times per second
Tim0_isr:
  Print Seconds ; Chr(13);

  Secondcount = Secondcount + 1                             'Counts overflows
  If Secondcount > 31 Then                                  'Every 31'st overflow is one second
     Seconds = Seconds + 1                                  'Count seconds
     Secondcount = 0
  End If
Return

End