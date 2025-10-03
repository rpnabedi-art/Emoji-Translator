'---------------------------------------------------------------------------
'                            PS2_EMUL.BAS
'                  (c) 2002-2003 MCS Electronics
'                        PS2 Mouse emulator
' NOTE THAT THE LIBRARY IS AN OPTIONAL ONE and by default is not included !
'---------------------------------------------------------------------------
$regfile = "2313def.dat"
$crystal = 4000000
$baud = 19200
$hwstack = 24
$swstack = 8
$framesize = 16

$lib "mcsbyteint.lbx"                   ' use optional lib since we use only bytes



'configure PS2 pins
Config Ps2emu = Int1 , Data = Pind.3 , Clock = Pinb.0
'                 ^------------------------ used interrupt
'                              ^----------- pin connected to DATA
'                                       ^-- pin connected to clock
'Note that the DATA must be connected to the used interrupt pin


Waitms 500                              ' optional delay

Enable Interrupts                       ' you need to turn on interrupts yourself since an INT is used

Print "Press u,d,l,r,b, or t"
Dim Key As Byte
Do
    Key = Waitkey()                     ' get key from terminal
    Select Case Key
      Case "u" : Ps2mousexy  0 , 10 , 0       ' up
      Case "d" : Ps2mousexy  0 , -10 , 0       ' down
      Case "l" : Ps2mousexy  -10 , 0 , 0       ' left
      Case "r" : Ps2mousexy  10 , 0 , 0       ' right
      Case "b" : Ps2mousexy  0 , 0 , 1 ' left button  pressed
                 Ps2mousexy  0 , 0 , 0 ' left button released
      Case "t" : Sendscan Mouseup       ' send a scan code
      Case Else
    End Select
Loop


Mouseup:
Data 3 , &H08 , &H00 , &H01             ' mouse up by 1 unit