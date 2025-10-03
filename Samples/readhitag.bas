'--------------------------------------------------------------------------
'                    (c) 1995-2013  , MCS Electronics
' sample : readhitag.bas
' demonstrates usage of the READHITAG() function
'--------------------------------------------------------------------------

$regfile = "m88def.dat"                                     ' specify chip
$crystal = 8000000                                          ' used speed
$baud = 19200                                               'baud rate
'Notice that the CLOCK OUTPUT of the micro is connected to the clock input of the HTRC110
'PORTB.0 of the Mega88 can optional output the clock. You need to set the fusebit for this option
'This way all parts use the Mega88 internal oscillator

'The code is based on Philips(NXP) datasheets and code. We have signed an NDA to get the 8051 code
'You can find more info on Philips website if you want their code
Print "HTC110 demo"

Config Hitag = 64 , Type = Htrc110 , Dout = PIND.2 , Din = PIND.3 , Clock = PIND.4 , Int = INT0
'                ^ use timer0 and select prescale value 64
'                     ^ we used htrc110 chip
'                                      ^-- dout of HTRC110 is connected to PIND.2 which will be set to input mode
'                                                     ^ DIN of HTRC100 is connected to PIND.3 which will be set to output mode
'                                                                    ^clock of HTRC110 is connected to PIND.4 which is set to output mode
'                                                                                     ^ interrupt
'the config statement will generate a number of constante and internal variables used by the code
'the htrc110.lbx library is called

Dim Tags(5) As Byte                                         'each tag has 5 byte serial
Dim J As Byte                                               ' a loop counter

'you need to use a pin that can detect a pin level change
'most INT pins have this option
'OR , you can use the PCINT interrupt that is available on some chips

'In case you want PCINT option
' Pcmsk2 = &B0000_0100        'set the mask to ONLY use the pin connected to DOUT
' On Pcint2 Checkints         'label to be called
' Enable Pcint2               'enable this interrupt

'In case you want to use INT option
On Int0 Checkints                                           ' PIND.2 is INT0
Config Int0 = Change                                        'you must configure the pin to work in pin change intertupt mode

Enable Interrupts                                           ' enable global interrupts

Do
 If Readhitag(tags(1)) = 1 Then                             'check if there is a new tag ID
     For J = 1 To 5                                         'print the 5 bytes
         Print Hex(tags(j)) ; ",";
     Next
  Else                                                      'there was nothing
    Print "Nothing"
  End If
  Waitms 500                                                'some delay
Loop


'this routine is called by the interrupt routine
Checkints:
 Call _checkhitag                                           'you must call this label
 'you can do other things here but keep time to a minimum
Return