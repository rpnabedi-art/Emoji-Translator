'-----------------------------------------------------------------------------------------
'name                     : hexval.bas
'copyright                : (c) 1995-2013, MCS Electronics
'purpose                  : demo: HEXVAL
'micro                    : Mega88
'suited for demo          : yes
'commercial addon needed  : no
'-----------------------------------------------------------------------------------------

$regfile = "m88def.dat"                                     ' specify the used micro
$crystal = 8000000                                          ' used crystal frequency
$baud = 19200                                               ' use baud rate
$hwstack = 32                                               ' default use 32 for the hardware stack
$swstack = 10                                               ' default use 10 for the SW stack
$framesize = 40                                             ' default use 40 for the frame space

Config Com1 = Dummy , Synchrone = 0 , Parity = None , Stopbits = 1 , Databits = 8 , Clockpol = 0

Dim L As Long

Dim S As String * 8
Do
  Input "Hex value " , S
  L = HexVal(S)
  Print L ; Spc(3) ; Hex(l)                                 'hex is the counter part of hexval
Loop