'---------------------------------------------------------------------
'                   SQ-SEN-200.BAS
'           (c) 1995-2011, MCS Electronics
'       Test the signalquest SQ-SEN-200 movement sensor
' The SQ-SEN-200 is a small (SMT) movement sensor. It requires almost no power
' it is very sensitive for omnidirectional movements
'---------------------------------------------------------------------
$RegFile = "m88def.dat"
$Crystal = 8000000

$Baud = 19200

'The sensor is connected to ground. The other pin is connected to PIND3
'An external pull up resistor of 6.8 M ohm was used(use 4M7 as a starting value)
'This is the so called "minimum setup". It has already very good results
Config Pind.3 = Input

Const Test = 2                                              ' test sample 1 or 2


Dim B As Bit , Oldbit As Bit
#if Test = 1
  Do
    B = Pind.3                                                ' get a peek on the pin
    If B <> Oldbit Then                                       'if it was different
       Print B                                                ' we get a movement
       Oldbit = B                                             'remember result
    End If
  Loop

#else

  'you can add an additional check
  Dim Btel As Byte , Bmove As Byte
  Do
    Btel = 0 : Bmove = 0
    Do
      Incr Btel
      B = PIND.3                                               ' get a peek on the pin
      If B <> Oldbit Then                                      'if it was different
        Oldbit = B                                            'remember result
        Incr Bmove                                            ' increase counter
      End If
    Loop Until Btel = 0
    If Bmove >= 2 Then
      Print "moved  " ; Bmove
    Else
      '   Print "not moved  " ; Bmove
    End If
  Loop
  'this sample will count the number of changes.
  'and when you change the condition >=2 , you can make the appliction more or less sensitive
  'you can also test shorter


#endif

End

