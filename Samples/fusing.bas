'------------------------------------------------------------------------------
'name                     : fusing.bas
'copyright                : (c) 1995-2013, MCS Electronics
'purpose                  : demonstrates  FUSING
'micro                    : Mega48
'suited for demo          : yes
'commercial addon needed  : no
'------------------------------------------------------------------------------
$regfile = "m48def.dat"                                     ' we use the M48
$crystal = 8000000
$baud = 19200

$hwstack = 32
$swstack = 8
$framesize = 24

Dim S As Single , Z As String * 10

'now assign a value to the single
S = 123.45678
'when using str() you can convert a numeric value into a string
Z = Str(s)
Print Z                                                     'prints 123.456779477

Z = Fusing(s , "#.##")

'now use some formatting with 2 digits behind the decimal point with rounding
Print Fusing(s , "#.##")                                    'prints 123.46

'now use some formatting with 2 digits behind the decimal point without rounding
Print Fusing(s , "#.&&")                                    'prints 123.45

'The mask must start with #.
'It must have at least one # or & after the point.
'You may not mix & and # after the point.
End