'-------------------------------------------------------------------------------
'copyright                : (c) 1995-2005, MCS Electronics
'micro                    : Mega48
'suited for demo          : yes
'commercial addon needed  : no
'purpose                  : demonstrates DEG2RAD function

'-------------------------------------------------------------------------------
$REGFILE="m88DEF.DAT"
$hwstack = 40
$swstack = 40
$framesize = 40


Dim S As Single
S = 90

S = Deg2Rad(s)
Print S
S = Rad2deg(s)
Print S
End