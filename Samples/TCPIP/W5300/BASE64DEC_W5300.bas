'-----------------------------------------------------------------------------------------
'name                     : base64dec_W5300.bas
'copyright                : (c) 1995-2012, MCS Electronics
'purpose                  : demo: base64enc and base64dec
'micro                    : Mega2560
'suited for demo          : no, needs library only included in the full version
'commercial addon needed  : no
'-----------------------------------------------------------------------------------------
$regfile = "m2560def.dat"                                   ' specify the used micro
$crystal = 16000000                                          ' used crystal frequency
$baud = 19200                                               ' use baud rate
$hwstack = 32                                               ' default use 32 for the hardware stack
$swstack = 10                                               ' default use 10 for the SW stack
$framesize = 40                                             ' default use 40 for the frame space


Dim S As String * 15 , Z As String * 15

Print "Demo of BASE64 encoding and decoding"
Print "Notice that an encoded string is 125% longer"
S = "mark:mark"                                             'bWFyazptYXJr

'encode the string into base64
Z = Base64enc(s)
Print Z

S = ""                                                      ' clear s

'and decode it back
S = Base64dec(z)
Print S                                                     'mark:mark

End