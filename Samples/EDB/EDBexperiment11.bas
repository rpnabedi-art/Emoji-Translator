'--------------------------------------------------------------
'                        EDBexperiment11.bas
'       Experiment 11 for the Educational Development Board
'                  (c) 1995-2006, MCS Electronics
'                        Fileversion 1.0
'--------------------------------------------------------------
'
'Purpose:
'This showshow to use an RC5 remote control
'
'Conclusions:
'You should be able to use an RC5 remote control

$regfile = "m88def.dat"
$crystal = 8000000
$hwstack = 40
$swstack = 40
$framesize = 40

$baud = 19200
'Use byte library for smaller code
$lib "mcsbyte.lbx"

'This example shows how to decode RC5 remote control signals

'The GETRC5 function uses TIMER0 and the TIMER0 interrupt.
'The TIMER0 settings are restored however so only the interrupt can not
'be used anymore for other tasks

'Tell the compiler which pin we want to use for the receiver input
Config Rc5 = Pind.4

'The interrupt routine is inserted automatic but we need to make it occur
'so enable the interrupts
Enable Interrupts

'Reserve space for variables
Dim Address As Byte , Command As Byte
Print "Waiting for RC5..."

Do
   'Now check if a key on the remote is pressed.
   'Note that at startup all pins are set for INPUT
   'so we don't set the direction here.
   Getrc5(address , Command)

   If Command > 127 Then Command = Command - 128            'This removes the toggle bit
   Print Address ; "  " ; Command

   Loop
End