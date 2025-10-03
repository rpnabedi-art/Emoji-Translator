'---------------------------------------------------------------
'        RTS - CTS support demo file
'
$regfile = "m32def.dat"
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


Config Serialout = Buffered , Size = 20
Config Serialin = Buffered , Size = 5 , Bytematch = None , Cts = Pind.6 , Rts = Pind.5 , Threshold_full = 3 , Threshold_empty = 2

'CTS is the CTS pin to use which is an input pin.
'RTS is the RTS pin to use which is an output pin.
'It is important that pins are used that are bit addressable. (address below &H3F)

'the internal constant _RTSCTS will be set to 1 if CTS-RTS is used
'the following internal constants will be set, depending on the used pin.
'Const _rtscts = 1
'Const _ctsin = Pind
'Const _ctspin = 6

'Const _rtsport = Portd
'Const _rtspin = 5


Enable Interrupts                                           ' buffered com needs int enabled

Dim Tel As Byte , A As Byte
Dim W As Byte , B As Byte
Do
   Print "test " ; Tel
   Tel = Tel + 1
   Waitms 500
   If Ischarwaiting() = 1 Then
       A = Waitkey()
       If A = 27 Then
          Print Bufspace(1)                                 ' serial input buffer free space
       End If
   End If
Loop