'-----------------------------------------------------------------------------------------
'name                     : ps2_kbdemul.bas
'copyright                : (c) 1995-2005, MCS Electronics
'purpose                  : PS2 AT Keyboard emulator
'micro                    : M88
'suited for demo          : no, ADD ON NEEDED
'commercial addon needed  : yes
'-----------------------------------------------------------------------------------------

$regfile = "m88def.dat"                                     ' specify the used micro
$crystal = 16000000                                         ' used crystal frequency
$baud = 19200                                               ' use baud rate
$hwstack = 40                                               ' default use 40 for the hardware stack
$swstack = 32                                               ' default use 32 for the SW stack
$framesize = 40                                             ' default use 40 for the frame space

$lib "mcsbyteint.lbx"                                       ' use optional lib since we use only bytes

'configure PS2 AT pins
Enable Interrupts                                           ' you need to turn on interrupts yourself since an INT is used
Config Atemu = Int1 , Data = Pind.3 , Clock = Pind.2
'                 ^------------------------ used interrupt
'                              ^----------- pin connected to DATA
'                                       ^-- pin connected to clock
'Note that the DATA must be connected to the used interrupt pin


Waitms 500                                                  ' optional delay

'rcall _AT_KBD_INIT
Print "Press t for test, and set focus to the editor window"
Dim Key2 As Byte , Key As Byte
Do
    Key2 = Waitkey()                                        ' get key from terminal
    Select Case Key2
      Case "t" :
      Waitms 1500
      Sendscankbd Mark                                      ' send a scan code
      Case Else
    End Select
Loop
Print Hex(key)

Mark:                                                       ' send mark
Data 12 , &H3A , &HF0 , &H3A , &H1C , &HF0 , &H1C , &H2D , &HF0 , &H2D , &H42 , &HF0 , &H42
'    ^ send 12 bytes
'           m                    a                   r                    k
