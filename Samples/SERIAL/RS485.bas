'------------------------------------------------------------------------------
'name                     : .bas
'copyright                : (c) 1995-2005, MCS Electronics
'purpose                  : demonstrates
'micro                    : Mega48
'suited for demo          : yes
'commercial addon needed  : no
'------------------------------------------------------------------------------
$regfile = "m48def.dat"                                     ' we use the M48
$crystal = 8000000
$baud = 19200

$hwstack = 32
$swstack = 32
$framesize = 32

Config Print0 = Portb.0 , Mode = Set
Config Pinb.0 = Output                                      'set the direction yourself

Dim Resp As String * 10
Dim S As String * 10
S = "string"
Do
   Print "test message"
   Print S
   Input Resp                                               ' get response
Loop