'*******************************************************************************
'*------------------------ Multimedia USB HID keyboard -------------------------
'*******************************************************************************
'*                                                                             *
'*                             BASCOM-AVR v.2.0.7.4                            *
'*                              Rubashka Vasiliy                               *
'*                                  Ukraine                                    *
'*                                   2011                                      *
'*                     Multimedia added by MrShilov © 2012                     *
'*                                                                             *
'*******************************************************************************
$noramclear
$hwstack = 40
$swstack = 40
$framesize = 50
$regfile = "m8adef.dat"
$crystal = 12000000
'-------------------------------------------------------------------------------
'Config Error = Ignore , 380 = Ignore                        'For 2.0.7.6 version!!!
$lib "swusb.lbx"                                  'Sofware USB library
$external _swusb
$external Crcusb
Declare Function Crcusb(buffer() As Byte , Count As Byte) As Word

$include "USB_config.inc"                         'USB configuration
'**************************** USB Interrupt And Init ***************************
Call Usb_reset()
Const _usb_intf = Intf0
Config Int0 = Rising
On Int0 Usb_isr Nosave
Enable Int0

'********************************* Variables ***********************************
Const Pause = 70                                  'USB sending delay in ms
Const Phrase_length = 9                           'Lenght of custom phrase (see "Phrase_letters" Data)
Dim Resetcounter As Word
Dim Idlemode As Byte
Dim Flaginputmsg As Byte
Dim Key(35) As Byte
Dim K As Byte
Dim First_byte As Byte
Dim Second_byte As Byte
Dim Third_byte As Byte

Status_led Alias Portd.7                          'Red Status LED
Numlock_led Alias Portd.0                         'Green NumLock LED
Capslock_led Alias Portd.1                        'Green CapsLock LED
Scrolllock_led Alias Portd.3                      'Green ScrollLock LED
Layout Alias Portd.6                              'Layout radio-button

Config Timer1 = Timer , Prescale = 256
On Timer1 Setflag
Enable Timer1

_usb_tx_buffer2(2) = 0                            ' modifier    - (Ctrl, Alt, Shift, Win combination)
_usb_tx_buffer2(3) = 0                            ' reserved
_usb_tx_buffer2(4) = 0                            ' keycode 0
_usb_tx_buffer2(5) = 0                            ' keycode 1
_usb_tx_buffer2(6) = 0                            ' keycode 2
_usb_tx_buffer2(7) = 0                            ' keycode 3
_usb_tx_buffer2(8) = 0                            ' keycode 4
_usb_tx_buffer2(9) = 0                            ' keycode 5

'********************************** Program ************************************
Portc = 1 : Portb.5 = 1                           'Activating scan lines

Status_led = 1 : Waitms 100                       'Just flash the "STATUS LED", device started :)
Status_led = 0 : Waitms 300
Status_led = 1 : Waitms 100
Status_led = 0 : Waitms 300
Status_led = 1 : Waitms 100
Status_led = 0

Enable Interrupts
'********************************* Main Loop ***********************************
Do

   Resetcounter = 0

   'Check for reset here
   While _usb_pin._usb_dminus = 0
      Incr Resetcounter
      If Resetcounter = 1000 Then
         Call Usb_reset()
      End If
   Wend

   If _usb_status._usb_rxc = 1 Then               'Check for received data
      If _usb_status._usb_setup = 1 Then
         Call Usb_processsetup(_usb_tx_status(1))  'Process a setup packet/control message
      End If
      'Reset the RXC bit and set the RTR bit (ready to receive a new packet)
      _usb_status._usb_rtr = 1
      _usb_status._usb_rxc = 0
   End If

  If Flaginputmsg = 1 Then                        'Scan & send on timer interrupt

'**************************** Keyboard Scanning ********************************

   '             1 Col 2 Col 3 Col 4 Col 5 Col 6 Col 7 Col
   '              PC5   PC4   PC3   PC2   PC1   PC0   PB5
   '               |     |     |     |     |     |     |
   '               V     V     V     V     V     V     V
   '               |     |     |     |     |     |     |
   '1 line PB4 <---0-----0-----0-----0-----0-----0-----0---
   '               |     |     |     |     |     |     |
   '2 line PB3 <---0-----0-----0-----0-----0-----0-----0---
   '               |     |     |     |     |     |     |
   '3 line PB2 <---0-----0-----0-----0-----0-----0-----0---
   '               |     |     |     |     |     |     |
   '4 line PB1 <---0-----0-----0-----0-----0-----0-----0---
   '               |     |     |     |     |     |     |
   '5 line PB0 <---0-----0-----0-----0-----0-----0-----0---
   '               |     |     |     |     |     |     |

   Portc.5 = 0 : Waitus 50 : Key(1) = Pinb.4 : Key(8) = Pinb.3 : Key(15) = Pinb.2 : Key(22) = Pinb.1 : Key(29) = Pinb.0 : Portc.5 = 1
   Portc.4 = 0 : Waitus 50 : Key(2) = Pinb.4 : Key(9) = Pinb.3 : Key(16) = Pinb.2 : Key(23) = Pinb.1 : Key(30) = Pinb.0 : Portc.4 = 1
   Portc.3 = 0 : Waitus 50 : Key(3) = Pinb.4 : Key(10) = Pinb.3 : Key(17) = Pinb.2 : Key(24) = Pinb.1 : Key(31) = Pinb.0 : Portc.3 = 1
   Portc.2 = 0 : Waitus 50 : Key(4) = Pinb.4 : Key(11) = Pinb.3 : Key(18) = Pinb.2 : Key(25) = Pinb.1 : Key(32) = Pinb.0 : Portc.2 = 1
   Portc.1 = 0 : Waitus 50 : Key(5) = Pinb.4 : Key(12) = Pinb.3 : Key(19) = Pinb.2 : Key(26) = Pinb.1 : Key(33) = Pinb.0 : Portc.1 = 1
   Portc.0 = 0 : Waitus 50 : Key(6) = Pinb.4 : Key(13) = Pinb.3 : Key(20) = Pinb.2 : Key(27) = Pinb.1 : Key(34) = Pinb.0 : Portc.0 = 1
   Portb.5 = 0 : Waitus 50 : Key(7) = Pinb.4 : Key(14) = Pinb.3 : Key(21) = Pinb.2 : Key(28) = Pinb.1 : Key(35) = Pinb.0 : Portb.5 = 1

'***************************** Sending messages ********************************
      For K = 1 To 34
         If Key(k) = 0 Then Goto Sending_combination
      Next K
      Goto Sending_phrase

'-------------------------------------------------------------------------------
      Sending_combination:
      K = K * 3                                   'Key combination address in EEPROM
      If Layout = 0 Then K = K + 105              'Second layout
      Readeeprom Third_byte , K
      Decr K
      Readeeprom Second_byte , K
      Decr K
      Readeeprom First_byte , K

      If Second_byte = 0 Then                     'Keyboard command

         If _usb_tx_status._usb_txc = 1 Then
            Status_led = 1                        'Status LED On
            _usb_tx_buffer2(2) = First_byte
            _usb_tx_buffer2(3) = 0
            _usb_tx_buffer2(4) = Third_byte
            Call Usb_send(_usb_tx_status2(1) , 8) 'Sending command
            Waitms Pause
         End If

         If _usb_tx_status._usb_txc = 1 Then
            _usb_tx_buffer2(2) = 0
            _usb_tx_buffer2(3) = 0
            _usb_tx_buffer2(4) = 0
            Call Usb_send(_usb_tx_status2(1) , 8) 'Sending reset
            Status_led = 0                        'Status LED Off
         End If
         Goto Sending_phrase                      'All done

      Else

         If _usb_tx_status._usb_txc = 1 Then      'Multimedia command
            Status_led = 1                        'Status LED On
            _usb_tx_buffer3(2) = First_byte
            _usb_tx_buffer3(3) = Second_byte
            _usb_tx_buffer3(4) = Third_byte
            Call Usb_send(_usb_tx_status3(1) , 3) 'Sending multimedia
            Waitms Pause
         End If

         If _usb_tx_status._usb_txc = 1 Then
            _usb_tx_buffer3(2) = First_byte
            _usb_tx_buffer3(3) = 0
            _usb_tx_buffer3(4) = 0
            Call Usb_send(_usb_tx_status3(1) , 3) 'Sending reset
            Status_led = 0                        'Status LED Off
         End If

      End If

'***************************** Sending Phrase **********************************

      Sending_phrase:
      If Key(35) = 0 Then                         'Key ¹35 is for sending phrase to PC
         Status_led = 1                           'Status LED On
         Restore Phrase_letters
         For K = 1 To Phrase_length
            Read Third_byte
            If _usb_tx_status._usb_txc = 1 Then
               If Third_byte = 45 Then
                  _usb_tx_buffer2(2) = 0          '"Shift" is not pressed- dash is normal (not "Underscore")
               Else
                  _usb_tx_buffer2(2) = 2          '"Shift" is pressed - all letters are capital
               End If
               _usb_tx_buffer2(3) = 0
               _usb_tx_buffer2(4) = Third_byte
               Call Usb_send(_usb_tx_status2(1) , 8)       'Sending one letter
               Waitms Pause
            End If
         Next K                                   'Next letter
         If _usb_tx_status._usb_txc = 1 Then
            _usb_tx_buffer2(2) = 0
            _usb_tx_buffer2(3) = 0
            _usb_tx_buffer2(4) = 0
            Call Usb_send(_usb_tx_status2(1) , 8) 'Sending reset
         End If
         Status_led = 0                           'Status LED Off
      End If

  End If

Loop

End

'*******************************************************************************
$include "KeyCodes.inc"                           'Key combinatons stored in EEPROM
$include "Descriptors.inc"                        'USB descriptors
'*******************************************************************************
Phrase_letters:
Data 5 , 4 , 22 , 6 , 18 , 45 , 4 , 25 , 21       'Phrase is "BASCOM-AVR"

'*************************** Timer1 Interrupt **********************************
Setflag:
Timer1 = 60000
  Flaginputmsg = 1
Return