'-----------------------------------------------------------------------------------------
'name                     : ltc1257.bas
'copyright                : (c) 1995-2013, MCS Electronics
'purpose                  : demo: this sample shows how to write to the LTC1257
'micro                    : Mega88
'suited for demo          : yes
'commercial addon needed  : no
'-----------------------------------------------------------------------------------------
$RegFile = "m88def.dat"
$crystal = 8000000

'some aliases
Din Alias PORTB.0
Clock Alias PORTB.1
Cload Alias PORTB.2

Config PORTB = Output

'initial state
Reset Clock
Set Cload

Dim W As Word

'value to write
W = 1000

'12 bits are used so shift to left
Shift W , Left , 4
'shiftout the data
Shiftout Din , Clock , W , 1 , 12 , 10
'give load pulse
Reset Cload
Waitms 1
Set Cload

End