'---------------------------------------------------------------
'        RTS - CTS support demo file
'
$regfile = "m128def.dat"
$crystal = 8000000
$baud = 19200
$hwstack = 40
$swstack = 40
$framesize = 40


'---------------------------------------------------------------
'serial buffered input and output are extended with CTS-RTS handshake.
'RTS will be 0 initial. When the input buffer is full, RTS will be made 1.
'WHen the input buffer is read with the serial commands and thus get room again, RTS will be made 0 again

'The same is used for CTS. CTS is an input pin which will be checked before sending data
'from the output buffer. If CTS is made 1 by the sender, it means the other buffer is full and we may not
'send any data. Thus only when CTS is 0, we may send data.


'Config Serialout = Buffered , Size = 10
'Config Serialin = Buffered , Size = 5 , Bytematch = None , Cts = Pind.6 , Rts = Pind.5

Config Serialout1 = Buffered , Size = 10
Config Serialin1 = Buffered , Size = 5 , Cts = Pind.4 , Rts = Pind.3, Threshold_full = 3 , Threshold_empty = 2      

'CTS is the CTS pin to use which is an input pin.
'RTS is the RTS pin to use which is an output pin.
'It is important that pins are used that are bit addressable. (address below &H3F)

'the internal constant _RTSCTS1 will be set to 1 if CTS-RTS for the second UART is used
'the following internal constants will be set, depending on the used pin.
'Const _rtscts1 = 1
'Const _ctsin1 = Pind
'Const _ctspin1 = 4

'Const _rtsport1 = Portd
'Const _rtspin1 = 3
Open "com2:" For Binary As #2                               ' get a fake handle


Enable Interrupts                                           ' buffered com needs int enabled

Dim Tel As Byte , A As Byte
Dim W As Byte , B As Byte
Do
   Print "test " ; Tel
   Tel = Tel + 1
   Waitms 500
   If Ischarwaiting(#2) = 1 Then
       A = Waitkey(#2)
       If A = 27 Then
          Print Bufspace(3)                                 ' serial input buffer free space
       End If
   End If
Loop

Close #2