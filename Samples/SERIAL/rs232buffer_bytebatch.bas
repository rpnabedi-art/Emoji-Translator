'-----------------------------------------------------------------------------------------
'name                     : rs232buffer_bytematch.bas
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
Config Serialin = Buffered , Size = 20 , Bytematch = 65

'when BYTEMATCH=ALL is used the label called is Serial0ByteReceived

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


'when the specified byte is received the following label is called
'in this case A is checked
Serial0charmatch:
  Print "We got a match!"
Return

