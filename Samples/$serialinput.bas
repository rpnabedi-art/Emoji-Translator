'-------------------------------------------------------------------------------
'name                     : $serialinput.bas
'copyright                : (c) 1995-2013, MCS Electronics
'purpose                  : demonstrates $SERIALINPUT redirection of serial input
'micro                    : Mega88
'suited for demo          : yes
'commercial addon needed  : no
'-------------------------------------------------------------------------------

$RegFile = "m88def.dat"
$Crystal = 8000000
$Baud = 19200

$HWstack = 32
$SWstack = 8
$FrameSize = 24

'dimension used variables
Dim S As String * 10
Dim W As Long

'inform the compiler which routine must be called to get serial characters
$SerialInput = Myinput

'make a never ending loop
Do
  'ask for name
  Input "name " , S
  Print S
  'error is set on time out
  Print "Error " ; ERR
Loop

End

'custom character handling  routine
'instead of saving and restoring only the used registers
'and write full ASM code, we use Pushall and PopAll to save and restore
'all registers so we can use all BASIC statements
'$SERIALINPUT requires that the character is passed back in R24
Myinput:
  Pushall                                                   'save all registers
  W = 0                                                       'reset counter
Myinput1:
  Incr W                                                     'increase counter
  !Sbis USR, 7                                                ' Wait for character
  !Rjmp Myinput2                                              'no charac waiting so check again
  PopAll                                                     'we got something
  ERR = 0                                                    'reset error
  !In _temp1, UDR                                             ' Read character from UART
Return                                                     'end of routine
Myinput2:
  If W > 1000000 Then                                        'with 4 MHz ca 10 sec delay
    !rjmp Myinput_exit                                       'waited too long
  Else
    Goto Myinput1                                           'try again
  End If
Myinput_exit:
  PopAll                                                      'restore registers
  ERR = 1                                                     'set error variable
  !ldi R24, 13                                                 'fake enter so INPUT will end
Return