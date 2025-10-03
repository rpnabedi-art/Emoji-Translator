'-----------------------------------------------------------------------------------------
'name                     : timer1.bas
'copyright                : (c) 1995-2005, MCS Electronics
'purpose                  : show using Timer1
'micro                    : 90S8515
'suited for demo          : yes
'commercial addon needed  : no
'-----------------------------------------------------------------------------------------

$regfile = "8515def.dat"                                    ' specify the used micro
$crystal = 4000000                                          ' used crystal frequency
$baud = 19200                                               ' use baud rate
$hwstack = 32                                               ' default use 32 for the hardware stack
$swstack = 10                                               ' default use 10 for the SW stack
$framesize = 40                                             ' default use 40 for the frame space


Dim W As Word

'The TIMER1 is a versatile 16 bit TIMER.
'This example shows how to configure the TIMER

'First like TIMER0 , it can be set to act as a TIMER or COUNTER
'Lets configute it as a TIMER that means that it will count and that
'the input is provided by the internal clock.
'The internal clock can be divided by 1,8,64,256 or 1024
Config Timer1 = Timer , Prescale = 1024


'You can read or write to the timer with the COUNTER1 or TIMER1 variable
W = Timer1
Timer1 = W


'To use it as a COUNTER, you can choose on which edge it is trigereed
Config Timer1 = Counter , Edge = Falling , Prescale = 1
'Config Timer1 = Counter , Edge = Rising

'Also you can choose to capture the TIMER registers to the INPUT CAPTURE registers
'With the CAPTURE EDGE = , you can specify to capture on the falling or rising edge of
'pin ICP
Config Timer1 = Counter , Edge = Falling , Capture_Edge = Falling , Prescale = 1024
'Config Timer1 = Counter , Edge = Falling , Capture Edge = Rising

'To allow noise canceling you can also provide :
Config Timer1 = Counter , Edge = Falling , Capture_Edge = Falling , Noise_Cancel = 1 , Prescale = 1

'to read the input capture register :
W = Capture1
'to write to the capture register :
Capture1 = W





'The TIMER also has two compare registers A and B
'When the timer value matches a compare register, an action can be performed
Config Timer1 = Counter , Edge = Falling , Compare A = Set , Compare B = Toggle , Clear Timer = 1
'SET , will set the OC1X pin
'CLEAR, will clear the OC1X pin
'TOGGLE, will toggle the OC1X pin
'DISCONNECT, will disconnect the TIMER from output pin OC1X
'CLEAR TIMER will clear the timer on a compare A match

'To read write the compare registers, you can use the COMPARE1A and COMPARE1B variables
Compare1a = W
W = Compare1a


'And the TIMER can be used in PWM mode
'You have the choice between 8,9 or 10 bit PWM mode
'Also you can specify if the counter must count UP or down after a match
'to the compare registers
'Note that there are two compare registers A and B
Config Timer1 = Pwm , Pwm = 8 , Compare A Pwm = Clear Up , Compare B Pwm = Clear Up , Prescale = 1

'to set the PWM registers, just assign a value to the compare A and B registers
Compare1a = 100
Compare1b = 200

'Or for better reading :
Pwm1a = 100
Pwm1b = 200

End