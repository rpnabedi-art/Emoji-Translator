'------------------------------------------------------------------------
'                      CAN-Elektor.bas
'    bascom-avr demo for Auto-CANtroller board
'------------------------------------------------------------------------
$regfile = "m32can.dat"                                     ' processor we use

$Crystal = 12000000                                         ' Crystal 12 MHz
$HWstack = 64
$SWstack = 32
$FrameSize = 40

'$prog &HFF , &HCF , &HD9 , &HFF                             ' generated. Take care that the chip supports all fuse bytes.
Config PORTA = OUTPUT                                       ' LED
Config PORTC = INPUT                                        ' DIP switch
PORTC = 255                                                 ' activate pull up

Config Com2 = 19200 , Synchrone = 0 , Parity = None , Stopbits = 1 , Databits = 8 , Clockpol = 0
Open "COM2:" For Binary As #2

Dim _can_page As Byte , _canid As Dword , _can_int_idx As Byte , _can_mobints As Word
Dim Breceived As Byte , Bok As Byte , Bdil As Byte

On CAN_INT ISR_Can_int                                      ' define the CAN interrupt
Enable Interrupts                                           ' enable interrupts

CANreset                                                    ' reset can controller
CANclearAllMOBs                                             ' clear alle message objects
CANbaud = 125000                                            ' use 125 KB

Config Canbusmode = Enabled                                 ' enabled,standby,listening
Config Canmob = 0 , Bitlen = 11 , Idtag = &H0120 , Idmask = &H0120 , Msgobject = Receive , Msglen = 1 , Autoreply = Disabled       'first mob  is used for receiving data
Config Canmob = 1 , Bitlen = 11 , Idtag = &H0120 , Msgobject = Disabled , Msglen = 1       ' this mob is used for sending data

CANGIE = &B10111000                                         ' CAN GENERAL INTERRUPT and TX and RX and ERR
Print #2 , "Start"

Do
   If PINC <> Bdil Then                                      ' if the switch changed
      Bdil = PINC                                            ' save the value
      Bok = CANsend(1 , PINC)                                ' send one byte using MOB 1
      Print #2 , "OK:" ; Bok                                 ' should be 0 if it was send OK
   End If
Loop

'*********************** CAN CONTROLLER INTERRUPT ROUTINE **********************
'multiple objects can generate an interrupt
ISR_Can_int:
   _can_page = CANPAGE                                      ' save can page because the main program can access the page too
   CANgetInts                                                ' read all the interrupts into variable _can_mobints
   For _can_int_idx = 0 To 14                               ' for all message objects
      If _can_mobints._can_int_idx = 1 Then                 ' if this message caused an interrupt

         CANselPage _can_int_idx                            ' select message object

         If CANSTMOB.5 = 1 Then                              ' we received a frame
            _canid = CANID()                                 ' read the identifier
            Print #2 , Hex(_canid)

            Breceived = CANreceive(PORTA)                    ' read the data and store in PORTA
            Print #2 , "Got : " ; Breceived ; " bytes"       ' show what we received
            Print #2 , Hex(PORTA)
            Config Canmob = -1 , Bitlen = 11 , Msgobject = Receive , Msglen = 1 , Autoreply = Disabled , Clearmob = No
            ' reconfig with value -1 for the current MOB and do not set ID and MASK
         Elseif CANSTMOB.6 = 1 Then                          'transmission ready
            Config Canmob = -1 , Bitlen = 11 , Msgobject = Disabled , Msglen = 1 , Clearmob = No
            ' reconfig with value -1 for the current MOB and do not set ID and MASK
         Elseif CANSTMOB.0 = 1 Then                          'ack error when sending data                         'transmission ready
            Print #2 , "ERROR:" ; Hex(CANSTMOB)
            Config Canmob = -1 , Bitlen = 11 , Msgobject = Disabled , Msglen = 1 , Clearmob = No
         End If
      End If
   Next
   CANSIT1 = 0 : CANSIT2 = 0 : CANGIT = CANGIT                ' clear interrupt flags
   CANPAGE = _can_page                                        ' restore page
Return
