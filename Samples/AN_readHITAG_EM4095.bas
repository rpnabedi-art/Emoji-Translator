'-------------------------------------------------------------------------------
'                  (c) 1995-2013 MCS Electronics
'  This sample will read a HITAG chip based on the EM4095 chip
'  Consult EM4102 and EM4095 datasheets for more info
'-------------------------------------------------------------------------------
'  The EM4095 was implemented after an idea of Gerhard Günzel
'  Gerhard provided the hardware and did research at the coil and capacitors.
'  The EM4095 is much simpler to use than the HTRC110. It need less pins.
'  A reference design with all parts is available from MCS
'  This AN is suitable for the 1.11.9.0 demo
'-------------------------------------------------------------------------------
$RegFile = "M88def.dat"
$baud = 19200
$crystal = 8000000
$hwstack = 40
$swstack = 40
$framesize = 40


Declare Function Havetag(b() As Byte ) As Byte

'Make SHD and MOD low
_md Alias Portd.4
Config _md = Output
_md = 0

_shd Alias Portd.5
Config _shd = Output
_shd = 0

Relay Alias Portd.2
Config Relay = Output

S3 Alias Pinb.0
S2 Alias Pinb.2
S1 Alias Pinb.1
Portb = &B111                                               ' these are all input pins and we activate the pull up resistor

Config Clock = Soft                                         'we use a clock
Config Date = Dmy , Separator = Minus
Enable Interrupts                                           ' the clock and RFID code need the int
Date$ = "15-12-07"                                          ' just a special date to start with
Time$ = "00:00:00"

'Config Lcd Sets The Portpins Of The Lcd
Config Lcdpin = Pin , Db4 = Portc.2 , Db5 = Portc.3 , Db6 = Portc.4 , Db7 = Portc.5 , E = Portc.1 , Rs = Portc.0
Config Lcd = 16x2                                         '16*2 type LCD screen
Cls
             Lcd " EM4095 sample"
Lowerline : Lcd "MCS Electronics"

Dim Tags(5) As Byte                                         'make sure the array is at least 5 bytes
Dim J As Byte , Idx As Byte
Dim Eramdum As Eram Byte                                    ' do not use first position
Dim Etagcount As Eram Byte                                  ' number of stored tags
Dim Etags(100) As Eram Byte                                 'room for 20 tags
Dim Stags(100) As Byte                                      'since we have enough SRAM store them in sram too
Dim Btags As Byte , Tmp1 As Byte , Tmp2 As Byte
Dim K As Byte , Tel As Byte , M As Byte

Config Hitag = 64 , Type = Em4095 , Demod = PIND.3 , Int = INT1
Print "EM4095 sample"
'you could use the PCINT option too, but you must mask all pins out so it will only respond to our pin
' Pcmsk2 = &B0000_0100
' On Pcint2 Checkints
' Enable Pcint2
On Int1 Checkints Nosave                                    'we use the INT1 pin all regs are saved in the lib
Config Int1 = Change                                        'we have to config so that on each pin change the routine will be called
Enable Interrupts                                           'as last we have to enable all interrupts


'read eeprom and store in sram
'when the program starts we read the EEPROM and store it in SRAM
For Idx = 1 To 100                                          'for all stored tags
   Stags(idx) = Etags(idx)
   Print Hex(stags(idx)) ; ",";
Next

Btags = Etagcount                                           ' get number of stored tags
If Btags = 255 Then                                         ' an empty cell is  FF (255)
   Print "No tags stored yet"
   Btags = 0 : Etagcount = Btags                            ' reset and write to eeprom
Else                                                        ' we have some tags
   For J = 1 To Btags
       Tmp2 = J * 5                                         'end
       Tmp1 = Tmp2 - 4                                      'start
       Print "RFID ; " ; J                                  ' just for debug
       For Idx = Tmp1 To Tmp2
         Print Hex(stags(idx)) ; ",";
       Next
       Print
   Next
End If

Do
   Print "Check..."
   Upperline : Lcd Time$ ; " Detect"
   If Readhitag(tags(1)) = 1 Then                           'this will enable INT1
      Lowerline
      For J = 1 To 5
         Print Hex(tags(j)) ; ",";
         Lcd Hex(tags(j)) ; ","
      Next
      M = Havetag(tags(1))                                  'check if we have this tag already
      If M > 0 Then
         Print "Valid TAG ;" ; M
         Relay = 1                                          'turn on relay
         Waitms 2000                                        'wait 2 secs
         Relay = 0                                          'relay off
      End If
      Print
  Else
     Print "Nothing"
  End If
  If S3 = 0 Then                                            'user pressed button 3
     Print "Button 3"
     Cls : Lcd "Add RFID"
     Do
       If Readhitag(tags(1)) = 1 Then                       'this will enable INT1
          If Havetag(tags(1)) = 0 Then                      'we do not have it yet
             If Btags < 20 Then                                'will it fit?
                Incr Btags                                     'add one
                Etagcount = Btags
                Idx = Btags * 5                                'offset
                Idx = Idx - 4
                Lowerline
                For J = 1 To 5
                  Lcd Hex(tags(j)) ; ","
                  Stags(idx) = Tags(j)
                  Etags(idx) = Tags(j)
                  Incr Idx
                Next
                Cls
                Lcd "TAG stored" : Waitms 1000
             End If
          End If
          Exit Do
       End If
     Loop
  End If
  If S2 = 0 Then
     Print "Button 2"
  End If
  If S1 = 0 Then
     Print "Button 1"
  End If

  Waitms 500
Loop



'check to see if a tag is stored already
'return 0 if not stored
'return value 1-20 if stored
Function Havetag(b() As Byte ) As Byte
  Print "Check if we have TAG : ";
  For K = 1 To 5
     Print Hex(b(k)) ; ","
  Next


  For K = 1 To 20
    Tmp2 = K * 5                                            'end addres
    Tmp1 = Tmp2 - 4                                         'start
    Tel = 0
    For Idx = Tmp1 To Tmp2
       Incr Tel
       If Stags(idx) <> B(tel) Then                         'if they do not match
          Exit For                                          'exit and try next
       End If
    Next

    If Tel = 5 Then                                         'if we did found 5 matching bytes we have a match
       Print "We have one"
       Havetag = K                                          'set index
       Exit Function
    End If
  Next
  Havetag = 0                                               'assume we have nothing yet

End Function


Checkints:
 Call _checkhitag                                           'in case you have used a PCINT, you could have other code here as well
Return