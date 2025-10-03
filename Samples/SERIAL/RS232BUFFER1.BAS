'-----------------------------------------------------------------------------------------
'name                     : rs232buffer1.bas
'copyright                : (c) 1995-2005, MCS Electronics
'purpose                  : shows the difference between normal and buffered
'                           serial INPUT
'micro                    : Mega161
'suited for demo          : yes
'commercial addon needed  : no
'-----------------------------------------------------------------------------------------

$regfile = "m2560def.dat"                                   ' specify the used micro
$crystal = 8000000                                          ' used crystal frequency
$hwstack = 40                                               ' default use 32 for the hardware stack
$swstack = 40                                               ' default use 10 for the SW stack
$framesize = 40                                             ' default use 40 for the frame space

' Works only for chips with 2 UARTS or more

Config Com2 = 19200 , Synchrone = 0 , Parity = None , Stopbits = 1 , Databits = 8 , Clockpol = 0
'first compile and run this program with the line below remarked
'Config Serialin1 = Buffered , Size = 20


'dim a variable
Dim Nm As String * 5


Open "com2:" For Binary As #1
'the enabling of interrupts is not needed for the normal serial mode
'So the line below must be remarked to for the first test
Enable Interrupts

Print #1 , "Start"
Do
   If Ischarwaiting(#1) = 1 Then                            'was there a char?
      Nm = Waitkey(#1)                                      'get it
      Print #1 , Nm                                         'print it
   End If

   Wait 1                                                   'wait 1 second
Loop
Close #1

'You will see that when you slowly enter characters in the terminal emulator
'they will be received/displayed.
'When you enter them fast you will see that you loose some chars

'NOW remove the remarks from line 11 and 18
'and compile and program and run again
'This time the chars are received by an interrupt routine and are
'stored in a buffer. This way you will not loose characters providing that
'you empty the buffer
'So when you fast type abcdefg, they will be printed after each other with the
'1 second delay

