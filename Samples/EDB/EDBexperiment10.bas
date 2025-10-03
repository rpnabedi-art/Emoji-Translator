'--------------------------------------------------------------
'                     EDBexperiment10.bas
'       Experiment 10 for the Educational Development Board
'                  (c) 1995-2006, MCS Electronics
'                        Fileversion 1.0
'--------------------------------------------------------------
'
'Purpose:
'This program shows how to use a matrix keyboard with interrupts
'
'Conclusions:
'You should be able to read the keys pressed on the matrix

$regfile = "m88def.dat"                                     'Define the chip we use
$crystal = 8000000                                          'Define speed of internal oscillator
$baud = 19200                                               'Define UART BAUD rate
$hwstack = 40
$swstack = 40
$framesize = 40

'Specify which port must be used all 8 pins of the port are used
Config Kbd = Portb

'Dimension a variable that receives the value of the pressed key
Dim B As Byte
Dim Matrixkey As Byte
Matrixkey = 255

'(
Remark On Pcint Interrupts
Pcint Interrupts Can Be Generated Thru Any Pcint Pin , Bit There Are Only 3 Interrupt Sources.
The Pin Change Interrupt Pcint2 Will Trigger If Any Enabled Pcint23..16 Pin Toggles.
The Pin Change Interrupt Pcint1 Will Trigger If Any Enabled Pcint14..8 Pin Toggles.
The Pin Change Interrupt Pcint0 Will Trigger If Any Enabled Pcint7..0 Pin Toggles.
The Pcmsk2 , Pcmsk1 And Pcmsk0 Registers Control Which Pins Contribute To The Pin Change
Interrupts. Pin Change Interrupts On Pcint23..0 Are Detected Asynchronously.
This Implies That These Interrupts Can Be Used For
Waking The Part Also From Sleep Modes Other Than Idle Mode.
')

'This examples uses pin1 of the matrix connected to pb0, pin2 to pb1 etc.
'Change the PCMSK0 mask if you use a different pinning.
Pcmsk0 = &B00001111                                         'This sets the interrupt mask

On Pcint0 Matrixinput                                       'On interrupt goto  MATRIXINPUT
Enable Pcint0                                               'Enable interrupts
Enable Interrupts

Do
   Print "Running and ready to receive a key"               'At power up there is always an interrupt key 16
   'You can insert your program here                         'because the PINT interrupts work on toggle
Loop

Matrixinput:                                                'If we do not disable the interrupts
   Disable Interrupts                                       'GetKBD would generate interrupts
   Waitms 2                                                 'That we cannot use
   B = Getkbd()  'Look in the help file on how to connect the matrix keyboard
   Waitms 2                                                 'Waitms anti bounce

   If B < 16 Then Print "Keynr.: " ; B ; " received"        '16 is no key pressed, so if 16 do nothing

   Select Case B
      Case 0 : Goto 0_handler                               'Goto handler
      Case 1 : Print "1_handler"                            'Define your own here
      Case 2 : Print "2_handler"
      Case 3 : Print "3_handler"
      Case 4 : Print "4_handler"
      Case 5 : Print "5_handler"
      Case 6 : Print "6_handler"
      Case 7 : Print "7_handler"
      Case 8 : Print "8_handler"
      Case 9 : Print "9_handler"
      Case 10 : Print "10_handler"
      Case 11 : Print "11_handler"
      Case 12 : Print "12_handler"
      Case 13 : Print "13_handler"
      Case 14 : Print "14_handler"
      Case 15 : Print "15_handler"
      Case 16 : Goto Return_from_interrupt
   End Select                                               'On 16 do nothing

   'When no key is pressed 16 will be returned

   Return_from_interrupt:
   Enable Interrupts

Return

0_handler:                                                  'An example of a handler routine
   Print "This is the 0_handler"
   'more statements here
Goto Wait_for_matrix_16                                     'Will wait until no key is pressed
                                                            'before enableing the interrupts

Wait_for_matrix_16:
   B = Getkbd()
   If B = 16 Then Goto Return_from_interrupt                'Will wait until no key is pressed
                                                             'before enableing the interrupts
Goto Wait_for_matrix_16

End