'-------------------------------------------------------------------------------
'                            ROUND_FIX_INT.BAS
'-------------------------------------------------------------------------------
$REGFILE="m88DEF.DAT"
$hwstack = 40
$swstack = 40
$framesize = 40


Dim S As Single , Z As Single
For S = -10 To 10 Step 0.5
  Print S ; Spc(3) ; Round(s) ; Spc(3) ; Fix(s) ; Spc(3) ; Int(s)
Next
End