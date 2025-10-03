'--------------------------------------------------------------
'                          BasmonEDB.bas
'           Basmon for the Educational Development Board
'                  (c) 1995-2006, MCS Electronics
'                        Fileversion 1.0
'--------------------------------------------------------------
'
'This file is copied from the Bascom AVR Samples Directory
'> Part of Update 1 for the Educational Development Board
'Revision Oct. 26 2006
'
'The Simulator will send commands to the monitor program when a port chances.
'This program will receive these statements and set the ports.
'
'With the hardware simulation you can use LCD statement and all PORT related statements.
'I2C can be used too. 1wire is time critical and can not be used.
'So when timing is not important it will work
'
'When using together with an LCD display in bus mode , be sure to activate external memory access
'in the compiler options
'-----------------------------------------------------------------------

$regfile = "m88def.dat"
$crystal = 8000000
$baud = 19200
$hwstack = 40
$swstack = 40
$framesize = 40



'Now all this program have to do is wait for commands
'the protocol is easy:
'xyz
'^--- Command can be W for write, R for read, T for test
' ^-- Address to read or write
'  ^- When writing this byte is the value to write, when reading this
'     program will send the value T will echo back OK


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