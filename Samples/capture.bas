'-----------------------------------------------------------------------------------------
'name                     : capture.bas
'copyright                : (c) 1995-2013, MCS Electronics
'purpose                  : demonstrates TIMER1 in capture mode
'micro                    : M88
'suited for demo          : yes
'commercial addon needed  : no
'-----------------------------------------------------------------------------------------

$RegFile = "m88def.dat"
$hwstack = 40                                               ' default use 32 for the hardware stack
$swstack = 10                                               ' default use 10 for the SW stack
$framesize = 40                                             ' default use 40 for the frame space


'You can run the timer/counter in TIMER or COUNTER mode
'In order to measure a pulse you could run it in TIMER mode
'In TIMER mode the TIMER is updated with the CLOCK
'You must choose the CLOCK with the PRESCALE =  1,8,64,256 or 1024 option
'The prescale factor depends on the signal frequency you want to capture
'
'You also can provide which edge will trigger the capturing with the CAPTURE EDGE = Falling or Rising
'And you can set NOISE cancelling on

'This will give the following CONFIG TIMER1 statement
Config Timer1 = Timer , Prescale = 1 , Capture_Edge = Falling , Noise_Cancel = 1

$crystal = 8000000
$baud = 19200
'with a division of 1 we get the timer updated with 0.125 uS steps
'Overflow will occur after 65535 * .125 uS = 8191 uS = 8.1 mS

'dimension word variable to hold the value of the capture register
Dim Wcap As Word , Oldw As Word

'we will use the capture interrupt to retrieve the capture value
On Capture1 Isr_cap1
'You can also use NOSAVE
'ON capture1 Isr_cap1 NOSAVE
'In that case you must save and restore the used registers yourself.
'In this example the used registers are : r24,r25,r26,r27

Print "Capture test"

'enable the capture interrupt
Enable Capture1

'enable interrupts to occur
Enable Interrupts


Do
   'your main code goes here
   'check the value to see it is different
   'Only used to print when really needed
   If Wcap <> Oldw Then
      Print "capture value " ; Wcap
      Oldw = Wcap
   End If
Loop

'this ISR is executed when there is a falling edge on the ICP pin (pin 14 of up)
Isr_cap1:
  'when NOSAVE is used also use unmark the following code
  'Push R24
  'push r25
  'push r26
  'push r27


  'get the capture register
  Wcap = Capture1
  'clear the timer value
  Timer1 = 0

  'when NOSAVE is used also use unmark the following code
  'pop r27
  'pop r26
  'pop r25
  'pop r24
Return

'------------------- The following code must be remarked --------------
'and doesnt work together with the code above !!

'To save resources such as interrupts you can also create a special routine
'In this example the pulse will start with a rising edge and stays high
'for T1. The period duration is T2 which is 1 mS

'make pin an input
Config Pind.0 = Input
Do
  Gosub Getpulse
  Print Wcap
Loop

Getpulse:
  'wait until the signal goes high
  Wcap = 0                                                  'clear variable
Getpulse_1:
!  sbis PIND,0      ; skip next if the bit is SET
!  rjmp Getpulse_1  ; not skipped so it was 0
Getpulse_2:
  Incr Wcap
!  sbic PIND,0      ; skip netx if the bit is 0
!  rjmp Getpulse_2  ; not skipped so it is high
Return