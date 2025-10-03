'-----------------------------------------------------------------------------------------
'name                     : rs232buffer.bas
'copyright                : (c) 1995-2005, MCS Electronics
'purpose                  : example shows the difference between normal and buffered
'                           serial INPUT
'micro                    : Mega48
'suited for demo          : yes
'commercial addon needed  : no
'-----------------------------------------------------------------------------------------

$regfile = "m48def.dat"                                     ' specify the used micro
$crystal = 8000000                                          ' used crystal frequency
$baud = 19200                                               ' use baud rate
$hwstack = 32                                               ' default use 32 for the hardware stack
$swstack = 10                                               ' default use 10 for the SW stack
$framesize = 40                                             ' default use 40 for the frame space

'first compile and run this program with the line below remarked
Config Serialin = Buffered , Size = 20


Dim Nm As String * 1

'the enabling of interrupts is not needed for the normal serial mode
'So the line below must be remarked to for the first test
Enable Interrupts

Print "Start"
Do
   'get a char from the UART

   If Ischarwaiting() = 1 Then                              'was there a char?
      Nm = Waitkey()
      Print Nm                                              'print it
   End If

   Wait 1                                                   'wait 1 second
Loop

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

'Using the CONFIG SERIAL=BUFFERED, SIZE = 10 for example will
'use some SRAM memory
'The following internal variables will be generated :
'_Rs_head_ptr0   BYTE , a pointer to the location of the start of the buffer
'_Rs_tail_ptr0   BYTE , a pointer to the location of tail of the buffer
'_RS232INBUF0 BYTE ARRAY , the actual buffer with the size of SIZE