'-------------------------------------------------------------------
'                        RC5.BAS
'                (c) 1999-2013 MCS Electronics
'         based on Atmel AVR410 application note
'-------------------------------------------------------------------
$regfile = "m88def.dat"
'$regfile = "m1284pdef.dat"
$hwstack=32
$swstack=16
$framesize=24

$Crystal = 16000000
$Baud = 19200

'This example shows how to decode RC5 remote control signals
'with a SFH506-35 IR receiver.

'Connect to input to PIND.2 for this example
'The GETRC5 function uses TIMER0 and the TIMER0 interrupt.
'The TIMER0 settings are restored however so only the interrupt can not
'be used anymore for other tasks


'tell the compiler which pin we want to use for the receiver input

Config Rc5 = PIND.2 , Wait = 2000

'the interrupt routine is inserted automatic but we need to make it occur
'so enable the interrupts
Enable Interrupts

'reserve space for variables
Dim Address As Byte , Command As Byte
Print "Waiting for RC5..."

Do
  'now check if a key on the remote is pressed
  'Note that at startup all pins are set for INPUT
  'so we dont set the direction here
  'If the pins is used for other input just unremark the next line
  'Config Pind.2 = Input
  GetRC5(Address , Command)

  'we check for the TV address and that is 0
  If Address = 0 Then
    'clear the toggle bit
    'the toggle bit toggles on each new received command
    'toggle bit is bit 7. Extended RC5 bit is in bit 6
    Command = Command And &B01111111
    Print Address ; "  " ; Command
  End If
Loop
End