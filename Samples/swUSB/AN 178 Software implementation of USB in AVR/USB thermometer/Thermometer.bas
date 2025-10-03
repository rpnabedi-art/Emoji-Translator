'Test setup is on the STK500 with Vtarget set to 3.6V
'Using an atmega644 and external 12MHz crystal
'
'when you connect the RS232 SPARE to your COM port of your PC
'you must connect TXD SPARE to PORTD.1 (txd pin)

'Save about 38 bytes of code size
$noramclear

'Enable debugging output
'0 = disable
'1 = debugging messages
'2 = dbg frame/stack output
Const Usbdebug = 0

#if Usbdebug = 2
$dbg
#endif

$hwstack = 64
$swstack = 64
$framesize = 64


$regfile = "m8def.dat"
'$regfile = "m644def.dat"
'$regfile = "ATtiny461.dat"

$crystal = 12000000

#if Usbdebug > 0
'$baud = 57600
'Open "coma.0:57600,8,n,1" For Output As #1
#endif


$eepromhex                                        'for STK500 programmer


'Include the software USB library
$lib "swusb.lbx"
$external _swusb
$external Crcusb
Declare Function Crcusb(buffer() As Byte , Count As Byte) As Word

Declare Sub Usb_reset()
Declare Sub Usb_processsetup(txstate() As Byte)
Declare Sub Usb_send(txstate() As Byte , Byval Count As Byte)
Declare Sub Usb_senddescriptor(txstate() As Byte , Maxlen As Byte)

'*******************************************************************************
'*************************** Begin USB Configuration ***************************
'
'Set the following parameters to match your hardware configuration and USB
'device parameters.

'******************************* USB Connections *******************************

'Define the AVR port that the two USB pins are connected to
_usb_port Alias Portd
_usb_pin Alias Pind
_usb_ddr Alias Ddrd

'Define the D+ and D- pins. (put D+ on an interrupt pin)
Const _usb_dplus = 2
Const _usb_dminus = 3


'Configure the pins as inputs
Config Pind.2 = Input
Config Pind.3 = Input



'disable pullups
_usb_port._usb_dplus = 0
_usb_port._usb_dminus = 0

'*******************************************************************************
'************************* USB Configuration Constants *************************

'Use EEPROM or FLASH to store USB descriptors
'1 = EEPROM, 0 = FLASH.  Storing to EEPROM will reduce code size slightly.
Const _usb_use_eeprom = 0

'Don't wait for sent packets to be ACK'd by the host before marking the
'transmission as complete.  This option breaks the USB spec but improves
'throughput with faster polling speeds.
'This may cause reliability issues.  Should leave set to 0 to be safe.
Const _usb_assume_ack = 0

'  *************************** Device Descriptor *****************************

'USB Vendor ID and Product ID (Assigned by USB-IF)
Const _usb_vid = &HAAAA
Const _usb_pid = &HEF02

'USB Device Release Number (BCD)
Const _usb_devrel = &H0001

'USB Release Spec (BCD)
Const _usb_spec = &H0110

'USB Device Class, subclass, and protocol (assigned by USB-IF).
'&h00 = Class defined by interface. (HID is defined in the interface)
'&hFF = Vendor-defined class (You must write your own PC driver)
'See http://www.usb.org/developers/defined_class  for more information
Const _usb_devclass = 0
Const _usb_devsubclass = 0
Const _usb_devprot = 0

'These are _indexes_ to UNICODE string descriptors for the manufacturer,
'product name, and serial number.  0 means there is no descriptor.
Const _usb_imanufacturer = 1
Const _usb_iproduct = 2
Const _usb_iserial = 0

'Number of configurations for this device.  Don't change this unless
'you know what you are doing.  Ordinarily it should just be 1.
Const _usb_numconfigs = 1

'  *************************** Config Descriptor *****************************

'The number of interfaces for this device (Typically 1)
Const _usb_numifaces = 1

'Configuration Number (do not edit)
Const _usb_confignum = 1

'Index of UNICODE string descriptor that describes this config (0 = None)
Const _usb_iconfig = 2

'&H80 = device powered from USB bus.
'&HC0 = self-powered (has a power supply)
Const _usb_powered = &H80                         '&HC0

'Required current in 2mA increments (500mA max)
Const _usb_maxpower = 150                         '150 * 2mA = 300mA

'  ************************** Interface Descriptor ***************************

'Number of interfaces for this device (1 or 2)
Const _usb_ifaces = 1

'Interface number
Const _usb_ifaceaddr = 0

'Alternate index
Const _usb_alternate = 0

'Number of endpoints for this interface (excluding endp 0)
Const _usb_ifaceendpoints = 2

'USB Interface Class, subclass, and protocol (assigned by USB-IF).
'&h00 = RESERVED
'&hFF = Vendor-defined class (You must write your own PC driver)
'       Other values are USB interface device class. (such as HID)
'See http://www.usb.org/developers/defined_class  for more information
Const _usb_ifclass = 3
Const _usb_ifsubclass = 0
Const _usb_ifprotocol = 0

'Index to UNICODE string descriptor for this interface (0 = None)
Const _usb_iiface = 0

'  ************************* Optional HID Descriptor *************************
'HID class devices are things like keyboard, mouse, joystick.
'See http://www.usb.org/developers/hidpage/  for the specification,
'tools, and resources.

'Note that for a HID device, the device class, subclass, and protocol
'must be 0. The interface class must be 3 (HID).
'Interface subclass and protocol must be 0 unless you are making a
'keyboard or a mouse that supports the predefined boot protocol.
'See pages 8 and 9 of the HID 1.11 specification PDF.

'Number of HID descriptors (EXCLUDING report and physical)
'If you are not making a HID device, then set this constant to 0
Const _usb_hids = 1

'BCD HID releasenumber.  Current spec is 1.11
Const _usb_hid_release = &H0111

'Country code from page 23 of the HID 1.11 specifications.
'Usually the country code is 0 unless you are making a keyboard.
Const _usb_hid_country = 0

'The number of report and physical descriptors for this HID
'Must be at least 1! All HID devices have at least 1 report descriptor.
Const _usb_hid_numdescriptors = 1

'Use a software tool to create the report descriptor and $INCLUDE it.


'  ************************* Endpoint Descriptor(s) **************************

'Endpoint 0 is not included here.  These are only for optional
'endpoints.
'Note: HID devices require 1 interrupt IN endpoint

'Address of optional endpoints (Must be > 0. comment-out to not use)
Const _usb_endp2addr = 1
Const _usb_endp3addr = 2

'Valid types are 0 for control or 3 for interrupt
Const _usb_endp2type = 3
Const _usb_endp3type = 3

'Directions are: 0=Out, 1=In.  Ignored by control endpoints
Const _usb_endp2direction = 1
Const _usb_endp3direction = 0

'Polling interval (ms) for interrupt endpoints.  Ignored by control endpoints
' (Must be at least 10)
Const _usb_endp2interval = 200
Const _usb_endp3interval = 100

'*******************************************************************************
'The includes need to go right here--between the configuration constants above
'and the start of the program below.  The includes will automatically calculate
'constants based on the above configuration, dimension required variables, and
'allocate transmit and receive buffers.  Nothing inside the includes file needs
'to be modified.
$include "swusb-includes.bas"
'*******************************************************************************

'**************************** USB Interrupt And Init ***************************
'Set all the variables, flags, and sync bits to their initial states
Call Usb_reset()



Const _usb_intf = Intf0
Config Int0 = Rising
On Int0 Usb_isr Nosave
Enable Int0


'*******************************************************************************
'*************************** End Of USB Configuration **************************
Config Timer1 = Timer , Prescale = 256
On Timer1 Setflag Nosave
Enable Timer1

Config 1wire = Portc.5

Dim 1wire_array(9) As Byte
Dim W_1wire As Word
Dim Dsid1(8) As Byte
Dim Flaginputtermo As Byte

Dim Resetcounter As Word
Dim Idlemode As Byte


Enable Interrupts


   W_1wire = 1wirecount()
   Dsid1(1) = 1wsearchfirst()
   1wreset                                        ' reset the bus
   1wwrite &HCC                                   ' skip rom
   1wwrite &H44                                   ' Convert T
   Timer1 = 0
   Flaginputtermo = 0

Do
   Resetcounter = 0

   'Check for reset here
   While _usb_pin._usb_dminus = 0
      Incr Resetcounter
      If Resetcounter = 1000 Then
         Call Usb_reset()
      End If
   Wend

   'Check for received data
   If _usb_status._usb_rxc = 1 Then
      If _usb_status._usb_setup = 1 Then
         'Process a setup packet/Control message
         Call Usb_processsetup(_usb_tx_status(1))
      Elseif _usb_status._usb_endp1 = 1 Then
         ' Input data endpoints
      End If
      'Reset the RXC bit and set the RTR bit (ready to receive a new packet)
      _usb_status._usb_rtr = 1
      _usb_status._usb_rxc = 0
   End If



   If Flaginputtermo = 1 Then
       Flaginputtermo = 0
       1wverify Dsid1(1)
       1wwrite &HBE
       1wire_array(1) = 1wread(9)
       1wreset                                    ' reset the bus
       1wwrite &HCC                               ' skip rom
       1wwrite &H44                               ' Convert T
    'Queue data to be sent on endpoint 2 (HID report)
     If _usb_tx_status2._usb_txc = 1 Then
       _usb_tx_buffer2(2) = 1wire_array(1)
       _usb_tx_buffer2(3) = 1wire_array(2)
       Call Usb_send(_usb_tx_status2(1) , 2)      ' Send data (2 bytes) in PC
     End If
   End If



Loop

End

'*******************************************************************************
'******************** Descriptors stored in EEPROM or FLASH ********************
'                  Do not change the order of the descriptors!
'
#if _usb_use_eeprom = 1
   $eeprom
#else
   $data
#endif

'Device Descriptor
_usb_devicedescriptor:
Data 18 , 18 , _usb_desc_device , _usb_specl , _usb_spech , _usb_devclass
Data _usb_devsubclass , _usb_devprot , 8 , _usb_vidl , _usb_vidh , _usb_pidl
Data _usb_pidh , _usb_devrell , _usb_devrelh , _usb_imanufacturer
Data _usb_iproduct , _usb_iserial , _usb_numconfigs


'Retrieving the configuration descriptor also gets all the interface and
'endpoint descriptors for that configuration.  It is not possible to retrieve
'only an interface or only an endpoint descriptor.  Consequently, this is a
'large transaction of variable size.
_usb_configdescriptor:
Data _usb_descr_total , 9 , _usb_desc_config , _usb_descr_totall
Data _usb_descr_totalh , _usb_numifaces , _usb_confignum , _usb_iconfig
Data _usb_powered , _usb_maxpower

'_usb_IFaceDescriptor
Data 9 , _usb_desc_iface , _usb_ifaceaddr , _usb_alternate
Data _usb_ifaceendpoints , _usb_ifclass , _usb_ifsubclass , _usb_ifprotocol
Data _usb_iiface

#if _usb_hids > 0
'_usb_HIDDescriptor
Data _usb_hid_descr_len , _usb_desc_hid , _usb_hid_releasel , _usb_hid_releaseh
Data _usb_hid_country , _usb_hid_numdescriptors

'Next follows a list of bType and wLength bytes/words for each report and
'physical descriptor.  There must be at least 1 report descriptor.  In practice,
'There are usually 0 physical descriptors and only 1 report descriptor.
Data _usb_desc_report
Data 33 , 0
'End of report/physical descriptor list
#endif

#if _usb_endpoints > 1
'_usb_EndpointDescriptor
Data 7 , _usb_desc_endpoint , _usb_endp2attr , _usb_endp2type , 8 , 0
Data _usb_endp2interval
#endif

#if _usb_endpoints > 2
'_usb_EndpointDescriptor
Data 7 , _usb_desc_endpoint , _usb_endp3attr , _usb_endp3type , 8 , 0
Data _usb_endp3interval
#endif

#if _usb_hids > 0
_usb_hid_reportdescriptor:
Data 33                                           ' Length = 33 bytes
Data &H06 , &H00 , &HFF                           ' Usage_page(vendor Defined Page 1)
Data &H09 , &H01                                  ' Usage(vendor Usage 1)
Data &HA1 , &H02                                  ' Collection(logical)

Data &H09 , &H01                                  ' Usage(pointer)
Data &H15 , &H00                                  ' Logical_minimum(0)
Data &H25 , &HFF                                  ' Logical_maximum(255)
Data &H75 , &H08                                  ' Report_size(8)
Data &H95 , &H02                                  ' Report_count(2)
Data &H81 , &H02                                  ' Input(data , Var , Abs)

Data &H09 , &H01                                  ' Usage(pointer)
Data &H15 , &H00                                  ' Logical_minimum(0)
Data &H26 , &HFF , 0                              ' Logical_maximum(255)
Data &H75 , &H08                                  ' Report_size(8)
Data &H95 , &H01                                  ' Report_count(1)
Data &H91 , &H02                                  ' Output(data , Var , Abs)

Data &HC0                                         ' End_collection

#endif

'*****************************String descriptors********************************
'Yes, they MUST be written like "t","e","s","t".  Doing so pads them with
'0's.  If you write it like "test," I promise you it won't work.

'Default language descriptor (index 0)
_usb_langdescriptor:
Data 4 , 4 , _usb_desc_string , 09 , 04           '&h0409 = English

'Manufacturer Descriptor (unicode)
_usb_mandescriptor:
Data 14 , 14 , _usb_desc_string
Data "o" , "l" , "l" , "o" , "p" , "a"

'Product Descriptor (unicode)
_usb_proddescriptor:
Data 44 , 44 , _usb_desc_string
Data "o" , "l" , "l" , "o" , "p" , "a" , "'" , "s" , " " , "g" , "a" , "m" , "e" , "p" , "a" , "d" , " "
Data "v" , "1" , "." , "0"



'*******************************************************************************



'*******************************************************************************
'******************************** Subroutines **********************************
'*******************************************************************************

Sub Usb_processsetup(txstate() As Byte)
Senddescriptor = 0
#if Usbdebug = 2
Dbg
#endif
   'Control transfers reset the sync bits like so
   Txstate(1) = _usb_setup_sync

   'These are the standard device, interface, and endpoint requests that the
   'USB spec requires that we support.
   Select Case _usb_rx_buffer(2)
      'Standard Device Requests
      Case &B10000000:
         Select Case _usb_rx_buffer(3)
'            CASE _usb_REQ_GET_STATUS:
            Case _usb_req_get_descriptor:
               Select Case _usb_rx_buffer(5)
                  Case _usb_desc_device:
                     #if Usbdebug = 1
                        Print "GETDD"
                     #endif
                     'Send the device descriptor
                     #if _usb_use_eeprom = 1
                        Readeeprom _usb_eepromaddrl , _usb_devicedescriptor
                     #else
                        Restore _usb_devicedescriptor
                     #endif
                     Senddescriptor = 1
                  Case _usb_desc_config:
                     #if Usbdebug = 1
                        Print "GETCD"
                     #endif
                     'Send the configuration descriptor
                     #if _usb_use_eeprom = 1
                        Readeeprom _usb_eepromaddrl , _usb_configdescriptor
                     #else
                        Restore _usb_configdescriptor
                     #endif
                     Senddescriptor = 1
                  Case _usb_desc_string:
                     Select Case _usb_rx_buffer(4)
                        Case 0:
                           'Send the language descriptor
                           #if _usb_use_eeprom = 1
                              Readeeprom _usb_eepromaddrl , _usb_langdescriptor
                           #else
                              Restore _usb_langdescriptor
                           #endif
                           Senddescriptor = 1
                        Case 1:
                           'Send the manufacturer descriptor
                           #if _usb_use_eeprom = 1
                              Readeeprom _usb_eepromaddrl , _usb_mandescriptor
                           #else
                              Restore _usb_mandescriptor
                           #endif
                           Senddescriptor = 1
                        Case 2:
                           'Send the product descriptor
                           #if _usb_use_eeprom = 1
                              Readeeprom _usb_eepromaddrl , _usb_proddescriptor
                           #else
                              Restore _usb_proddescriptor
                           #endif
                           Senddescriptor = 1
                     End Select
               End Select
'            CASE _usb_REQ_GET_CONFIG:
         End Select
      Case &B00000000:
         Select Case _usb_rx_buffer(3)
'            CASE _usb_REQ_CLEAR_FEATURE:
'            CASE _usb_REQ_SET_FEATURE:
            Case _usb_req_set_address:
               #if Usbdebug = 1
                  Print "SETA"
               #endif
               'USB status reporting for control writes
               Call Usb_send(txstate(1) , 0)
               While Txstate(1)._usb_txc = 0 : Wend
               'We are now addressed.
               _usb_deviceid = _usb_rx_buffer(4)
'            CASE _usb_REQ_SET_DESCRIPTOR:
            Case _usb_req_set_config:
               #if Usbdebug = 1
                  Print "SETC"
               #endif
               'Have to do status reporting
               Call Usb_send(txstate(1) , 0)
         End Select
      'Standard Interface Requests
      Case &B10000001:
         Select Case _usb_rx_buffer(3)
'            CASE _usb_REQ_GET_STATUS:
'            CASE _usb_REQ_GET_IFACE:
            Case _usb_req_get_descriptor
            '_usb_rx_buffer(4) is the descriptor index and (5) is the type
               Select Case _usb_rx_buffer(5)
                  Case _usb_desc_report:
                     #if Usbdebug = 1
                        Print "GETRD"
                     #endif
                     #if _usb_use_eeprom = 1
                        Readeeprom _usb_eepromaddrl , _usb_hid_reportdescriptor
                     #else
                        Restore _usb_hid_reportdescriptor
                     #endif
                     Senddescriptor = 1
'                  CASE _usb_DESC_PHYSICAL

'                  CASE _USB_DESC_HID

               End Select
         End Select
      'CASE &B00000001:
         'SELECT CASE _usb_rx_buffer(3)
         '   CASE _usb_REQ_CLEAR_FEATURE:

         '   CASE _usb_REQ_SET_FEATURE:

         '   CASE _usb_REQ_SET_IFACE:

         'END SELECT
      'Standard Endpoint Requests
      'CASE &B10000010:
         'SELECT CASE _usb_rx_buffer(3)
         '   CASE _usb_REQ_GET_STATUS:

         'END SELECT
      'CASE &B00000010:
         'SELECT CASE _usb_rx_buffer(3)
         '   CASE _usb_REQ_CLEAR_FEATURE:

         '   CASE _usb_REQ_SET_FEATURE:

         'END SELECT

      'Class specific requests (useful for HID)
      'CASE &b10100001:
         'Class specific GET requests
         'SELECT CASE _usb_rx_buffer(3)
            'CASE _usb_REQ_GET_REPORT:
            'CASE _usb_REQ_GET_IDLE:
            'CASE _usb_REQ_GET_PROTOCOL:
         'END SELECT
         '0-byte answer
         'Call Usb_Send(TxState, 0)
      Case &B00100001:
         'Class specific SET requests
         Select Case _usb_rx_buffer(3)
            'CASE _usb_REQ_SET_REPORT:
            Case _usb_req_set_idle:
               Idlemode = 1
               'Do status reporting
               Call Usb_send(txstate(1) , 0)
            'CASE _usb_REQ_SET_PROTOCOL:
         End Select
   End Select

   If Senddescriptor = 1 Then
      Call Usb_senddescriptor(txstate(1) , _usb_rx_buffer(8))
   End If

End Sub

Sub Usb_senddescriptor(txstate() As Byte , Maxlen As Byte)
#if Usbdebug = 2
Dbg
#endif
   'Break the descriptor into packets and send to TxState
   Local Size As Byte
   Local I As Byte
   Local J As Byte
   Local Timeout As Word

   #if _usb_use_eeprom = 1
      'EEPROM access is a little funky.  The size has already been fetched
      'and stored in _usb_EEPROMADDRL, and the address of the descriptor
      'is now in the EEAR register pair.

      Size = _usb_eepromaddrl

      'Fetch the location of the descriptor and use it as an address pointer
      push R24
      in R24, EEARL
      sts {_USB_EEPROMADDRL}, R24
      in R24, eearH
      sts {_USB_EEPROMADDRH}, R24
      pop R24

   #else
      Read Size
   #endif

   #if Usbdebug = 1
      Print Size
      Print Maxlen
   #endif

   If Maxlen < Size Then Size = Maxlen

   I = 2
   For J = 1 To Size
      Incr I
      #if _usb_use_eeprom = 1
         Incr _usb_eepromaddr
         Readeeprom Txstate(i) , _usb_eepromaddr
      #else
         Read Txstate(i)
      #endif

      #if Usbdebug = 1
         Print Bin(txstate(i))
      #endif

      If I = 10 Or J = Size Then
         I = I - 2
         Call Usb_send(txstate(1) , I)
         While Txstate(1)._usb_txc = 0
            Timeout = 0
            'To prevent an infinite loop, check for reset here
            While _usb_pin._usb_dminus = 0
               Incr Timeout
               If Timeout = 1000 Then             '
                  Call Usb_reset()
                  Exit Sub
               End If
            Wend
         Wend
         I = 2
      End If
   Next
End Sub

Sub Usb_send(txstate() As Byte , Byval Count As Byte)
#if Usbdebug = 2
Dbg
#endif



   'Calculates and adds the CRC16,adds the DATAx PID,
   'and signals to the ISR that the data is ready to be sent.
   '
   '"Count" is the DATA payload size.  Range is 0 to 8. Do not exceed 8!

   'Reset all the flags except TxSync and RxSync
   Txstate(1) = Txstate(1) And _usb_syncmask

   'Calculate the 16-bit CRC
   _usb_crc = Crcusb(txstate(3) , Count)

   'Bytes to transmit will be PID + DATA payload + CRC16
   Count = Count + 3
   Txstate(1) = Txstate(1) + Count

   Txstate(count) = Low(_usb_crc)
   Incr Count
   Txstate(count) = High(_usb_crc)


   'Add the appropriate DATAx PID
   Txstate(2) = _usb_pid_data1
   If Txstate(1)._usb_txsync = 0 Then
      Txstate(2) = _usb_pid_data0
   End If

   'The last step is to signal that the packet is Ready To Transmit
   Txstate(1)._usb_rtt = 1
   Txstate(1)._usb_txc = 0
End Sub

Sub Usb_reset()
#if Usbdebug = 2
Dbg
#endif
   'Reset the receive flags
   _usb_status._usb_rtr = 1
   _usb_status._usb_rxc = 0

   'Reset the transmit flags
   _usb_tx_status(1) = _usb_endp_init
   #if Varexist( "_usb_Endp2Addr")
   _usb_tx_status2(1) = _usb_endp_init
   #endif
   #if Varexist( "_usb_Endp3Addr")
   _usb_tx_status3(1) = _usb_endp_init
   #endif

   'Reset the device ID to 0
   _usb_deviceid = 0

   #if Usbdebug = 1
      Print "RESET"
   #endif

   Idlemode = 0

End Sub



Setflag:
  Flaginputtermo = 1
Return