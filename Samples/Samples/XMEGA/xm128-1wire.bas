'--------------------------------------------------------------------------------
'name                     : XM128-1wire.bas
'copyright                : (c) 1995-2010, MCS Electronics
'purpose                  : demonstrates 1wreset, 1wwrite and 1wread()
'micro                    : Xm128A1
'suited for demo          : no
'commercial addon needed  : no
' pull-up of 4K7 required to VCC from Portb.0
' DS2401 serial button connected to Portb.0
'--------------------------------------------------------------------------------
$regfile = "xm128a1def.dat"
$crystal = 32000000
$hwstack = 32                                               ' default use 32 for the hardware stack
$swstack = 32                                               'default use 10 for the SW stack
$framesize = 32                                             'default use 40 for the frame space

'First Enable The Osc Of Your Choice
Config Osc = Enabled , 32mhzosc = Enabled

'configure the systemclock
Config Sysclock = 32mhz , Prescalea = 1 , Prescalebc = 1_1

'configure UART
Config Com1 = 19200 , Mode = Asynchroneous , Parity = None , Stopbits = 1 , Databits = 8


'configure 1wire pin
Config 1wire = Portb.0                                      'use this pin

Dim Ar(8) As Byte , A As Byte , I As Byte

Print "start"

A = 1wirecount()
Print A ; " devices found"

'get first
Ar(1) = 1wsearchfirst()

For I = 1 To 8                                              'print the number
  Print Hex(ar(i));
Next
Print

Do
   'Now search for other devices
   Ar(1) = 1wsearchnext()                                   ' get next device
   For I = 1 To 8
    Print Hex(ar(i));
   Next
   Print
Loop Until Err = 1

Waitms 2000


Do
  1wreset                                                   'reset the device
  Print Err                                                 'print error 1 if error

  1wwrite &H33                                              'read ROM command
'  Ar(1) = 1wread(8)' You Can Use This Instead Of The Code Below

  For I = 1 To 8
    Ar(i) = 1wread()                                        'place into array
  Next

  For I = 1 To 8
     Print Hex(ar(i));                                      'print output
  Next
  Print                                                     'linefeed
  Waitms 1000
Loop


End