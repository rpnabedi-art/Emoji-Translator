'--------------------------------------------------------------
'name                     : ltrim.bas
'copyright                : (c) 1995-2005, MCS Electronics
'purpose                  : demonstrates LTRIM string function
'micro                    : Mega48
'suited for demo          : yes
'commercial addon needed  : no
'--------------------------------------------------------------

$regfile = "m48def.dat"                                     ' specify the used micro
$hwstack = 32                                               ' default use 32 for the hardware stack
$swstack = 10                                               'default use 10 for the SW stack
$framesize = 40                                             'default use 40 for the frame space
$crystal = 4000000                                          ' used crystal frequency
$baud = 19200                                               ' use baud rate
Config Com1 = Dummy , Synchrone = 0 , Parity = None , Stopbits = 1 , Databits = 8 , Clockpol = 0

Stop Watchdog
Dim S As String * 10                                        ' reserve space for string


S = " abc "                                                 ' assign the string
Print "{" ; S ; "}"                                         ' print the original string
Print "{" ; Ltrim(s) ; "}"                                  'print the string with the spaces to the left removed


Do
    Input "Enter value for S " , S
    Print "{" ; S ; "}"
    Print "{" ; Ltrim(s) ; "}"
Loop
End