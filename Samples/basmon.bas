'-----------------------------------------------------------------------
'                        (c) 2000-2013 MCS Electronics
'                            BASMON.BAS
'  9 sept 2000 : added support for BUS attached LCD displays
' 26 oct  2005 : basmon modified to work with M48
'-----------------------------------------------------------------------
' This file is intended to be used with the simulator
' It allows you to simulate the ports in hardware
' This is how it works:
' This monitor program must be changed for the chip you use.
' In this form it is used for the 90S2313. You only need to select a different DAT file
' Compile this program for your micro and program it into a chip.
' Label this chip with BASMON. It is best to set the lock bits
' The chip must be put in the target device.
' The target device must have a serial port with a MAX-232 connected to a COMM port of the PC
' This is the same COMM port used for the Terminal emulator.
' The Simulator will send commands to the monitor program when a port chances.
' This program will receive these statements and set the ports.
' very simple :-) And cost effective
' With the hardware simulation you can use LCD statement and all PORT related statements.
' I2C can be used too. 1wire is time critical and can not be used.
' So when timing is not important it will work
'In the Simulator you must press the Chip button to allow serial communications.


'When using together with a LCD display in bus mode , be sure to activate external memory access
'in the compiler options
'-----------------------------------------------------------------------

'regfile must match the chip you use in your target system
'$regfile = "2313def.dat"
'$regfile = "m128def.dat"
'$regfile = "m162def.dat"
$regfile = "m88def.dat"
'crystal must match too
$crystal = 8000000
'$crystal = 4000000
'baudrate must match the baudrate of the terminal emulator
'lets use 19200
$baud = 19200
Config Clockdiv = 1                                         ' some chips like mega88 have DIV8 fusebit set. So we need to override this
$HWstack = 32
$SWstack = 32
$FrameSize = 32

'now all this program have to do is wait for commands
'the protocol is easy
'xyz
'^--- command can be W for write, R for read, T for test
' ^-- address to read or write
'  ^- when writing this byte is the value to write, when reading this program will send the value
'T will echo back OK


'[variables]
Dim Krk As Byte                                             'command
Dim Address As Word                                         'address
Dim Adrl As Byte , Adrh As Byte                             'for new OUT command
Dim Vl As Byte                                              'value
'[main program]
Print "BASMON Version 1.01"

Do
  Krk = Waitkey()
  If Krk = "T" Then                                         'check if it is attached
     Print Chr(13);                                         'it is working
  Elseif Krk = "W" Then
     Address = Waitkey()                                    'wait for address
     Vl = Waitkey()                                         'wait for value
     Out Address , Vl                                       'write value
     Print Chr(13);                                         'confirm
  Elseif Krk = "R" Then
     Address = Waitkey()                                    ' wait for address
     Vl = Inp(address)                                      'get value
     Print Chr(vl);                                         'write back value
  Elseif Krk = "O" Then
     Adrl = Waitkey()                                       'wait for LSB of address
     Adrh = Waitkey()                                       'wait for MSB
     Vl = Waitkey()                                         'wait for data
     Address = Adrh * 256
     Address = Address + Adrl
     Out Address , Vl
     Print Chr(13);
  Elseif Krk = "?" Then                                     ' just echo for test
     Print "?";
  End If
Loop                                                        'for ever