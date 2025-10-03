$nocompile

Declare Sub Usb_reset()
Declare Sub Usb_processsetup(txstate() As Byte)
Declare Sub Usb_send(txstate() As Byte , Byval Count As Byte)
Declare Sub Usb_senddescriptor(txstate() As Byte , Maxlen As Byte)

'*************************** USB configuration *********************************
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
Const _usb_dminus = 4

Ddrb = &B11100000                                 'Port B direction: 1 - output
Portb = &B00011111                                'Port B state: 00000000
Ddrc = &B11111111                                 'Port C direction: 1 - output
Portc = &B00000000                                'Port C state: 00000000
Ddrd = &B10101011                                 'Port D direction: 1 - output
Portd = &B01000000                                'Port D state: 00000000

'disable pullups
_usb_port._usb_dplus = 0
_usb_port._usb_dminus = 0

'*******************************************************************************
'************************* USB Configuration Constants *************************
'Don't wait for sent packets to be ACK'd by the host before marking the
'transmission as complete.  This option breaks the USB spec but improves
'throughput with faster polling speeds.
'This may cause reliability issues.  Should leave set to 0 to be safe.
Const _usb_assume_ack = 0

'***************************** Device Descriptor *******************************

'USB Vendor ID and Product ID (Assigned by USB-IF)
Const _usb_vid = &HBBBB
Const _usb_pid = &HEF33

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

'***************************** Конфигурация дискиптора *************************

'The number of interfaces for this device
Const _usb_numifaces = 2                          'Now we have 2 interfaces  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

'Configuration Number (do not edit)
Const _usb_confignum = 1

'Index of UNICODE string descriptor that describes this config (0 = None)
Const _usb_iconfig = 0                            'Not needed   !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

Const _usb_powered = &HA0                         'Device powered from USB bus and can wakeup it !!!!!!!!!!!!!!!!!

'Required current in 2mA increments (500mA max)
Const _usb_maxpower = 50                          '50 * 2mA = 100mA

'**************************** Interface Descriptor *****************************

'Number of interfaces for this device (1 or 2)
Const _usb_ifaces = 2                             'Now we have 2 interfaces  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

'Interface numbers
Const _usb_ifaceaddr = 0
Const _usb_ifaceaddr1 = 1                         'Second Interface number  **************************************

'Alternate indexes
Const _usb_alternate = 0
Const _usb_alternate1 = 0                         'Second Interface Alternate index  *****************************

'Number of endpoints for each interface (excluding endp 0)
Const _usb_ifaceendpoints = 1                     'First Interface Endpoint !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
Const _usb_ifaceendpoints1 = 1                    'Second Interface Endpoint *************************************

'USB Interface Class, subclass, and protocol (assigned by USB-IF).
'&h00 = RESERVED
'&hFF = Vendor-defined class (You must write your own PC driver)
'       Other values are USB interface device class. (such as HID)
'See http://www.usb.org/developers/defined_class  for more information
Const _usb_ifclass = 3                            'Interrupt class
Const _usb_ifclass1 = 3                           'Interrupt class  **********************************************

Const _usb_ifsubclass = 1                         'Keyboard subclass is 1 !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
Const _usb_ifsubclass1 = 0                        'Multimedia subclass is 0 ************************************

Const _usb_ifprotocol = 1                         'For first interface   !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
Const _usb_ifprotocol1 = 0                        'For second interface  *****************************************

'Index to UNICODE string descriptor for this interface (0 = None)
Const _usb_iiface = 0
Const _usb_iiface1 = 0                            'The same for second interface *********************************

'*************************** Optional HID Descriptor ***************************
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
Const _usb_hids = 2                               'Now we have 2 HIDs !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

'BCD HID releasenumber.  Current spec is 1.11
Const _usb_hid_release = &H0111

'Country code from page 23 of the HID 1.11 specifications.
'Usually the country code is 0 unless you are making a keyboard.
Const _usb_hid_country = 0

'The number of report and physical descriptors for this HID
'Must be at least 1! All HID devices have at least 1 report descriptor.
Const _usb_hid_numdescriptors = 1                 'Here we set the number of descriptors for each interface separately, but use it twice

'Use a software tool to create the report descriptor and $INCLUDE it.


'*************************** Endpoint Descriptor(s) ****************************

'Endpoint 0 is not included here.  These are only for optional
'endpoints.
'Note: HID devices require 1 interrupt IN endpoint

'Address of optional endpoints (Must be > 0. comment-out to not use)
Const _usb_endp2addr = 1
Const _usb_endp3addr = 2

'Valid types are 0 for control or 3 for interrupt
Const _usb_endp2type = 3
Const _usb_endp3type = 3

'Directions Are : 0 = Out , 1 = In. Ignored By Control Endpoints
Const _usb_endp2direction = 1
Const _usb_endp3direction = 1                     'Now this point is IN too !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

'Polling interval (ms) for interrupt endpoints.  Ignored by control endpoints
' (Must be at least 10)
Const _usb_endp2interval = 10
Const _usb_endp3interval = 10

'*************************** Support File for SWUSB ***************************
'This file contains constants and variable declarations that should NOT be
'altered.  This code is moved to a separate file to make the main program easier
'to read.
'
'Author     : Rick Richard
'www        : http://www.sloservers.com/swusb
'Created    : Jul 29, 2009
'Version    : 1.00


'Bit positions of the STATUS and STATUS2 flags
Const _usb_rxc = 7                                          'USB Receive Complete / Data in RX buffer
Const _usb_rtr = 6                                          'USB Ready to Receive
Const _usb_ignore = 5                                       'USB Ignore this packet flag
Const _usb_setup = 4                                        'USB Setup phase
Const _usb_endp3 = 3                                        'USB Endpoint Address bit 3
Const _usb_endp2 = 2                                        'USB Endpoint Address bit 2
Const _usb_endp1 = 1                                        'USB Endpoint Address bit 1
Const _usb_endp0 = 0                                        'USB Endpoint Address bit 0

'Status flags for endpoints and sending a USB packet
Const _usb_rxsync = 7                                       'Receive sync bit for endpoint (DATAx toggling)
Const _usb_txsync = 6                                       'Send sync bit for endpoint    (DatAx toggling)
Const _usb_txc = 5                                          'USB Transmit Complete flag
Const _usb_rtt = 4                                          'USB Ready To Transmit flag

Const _usb_endp_init = 2 ^ _usb_txc
Const _usb_setup_sync = 2 ^ _usb_txc + 2 ^ _usb_txsync
Const _usb_syncmask = 2 ^ _usb_txsync + 2 ^ _usb_rxsync

'PID bytes that apply to low-speed devices
Const _usb_pid_out = &B11100001
Const _usb_pid_in = &B01101001
Const _usb_pid_setup = &B00101101
Const _usb_pid_data0 = &B11000011
Const _usb_pid_data1 = &B01001011
Const _usb_pid_ack = &B11010010
Const _usb_pid_nak = &B01011010
Const _usb_pid_stall = &B00011110

'PID bytes that do not apply to low-speed devices (for reference only)
Const _usb_pid_sof = &B10100101
Const _usb_pid_data2 = &B10000111
Const _usb_pid_mdata = &B00001111
Const _usb_pid_nyet = &B10010110
Const _usb_pid_pre = &B00111100
Const _usb_pid_err = &B00111100
Const _usb_pid_split = &B01111000
Const _usb_pid_ping = &B10110100

'Common requests
Const _usb_req_get_status = 0
Const _usb_req_clear_feature = 1
Const _usb_req_set_feature = 3
Const _usb_req_set_address = 5
Const _usb_req_get_descriptor = 6
Const _usb_req_set_descriptor = 7
Const _usb_req_get_config = 8
Const _usb_req_set_config = 9
Const _usb_req_get_iface = &H0A
Const _usb_req_set_iface = &H11
Const _usb_req_synch_frame = &H12

'HID Class Requests
Const _usb_req_get_report = 1
Const _usb_req_get_idle = 2
Const _usb_req_get_protocol = 3
Const _usb_req_set_report = 9
Const _usb_req_set_idle = &H0A
Const _usb_req_set_protocol = &H0B

'Descriptor types
Const _usb_desc_device = 1
Const _usb_desc_config = 2
Const _usb_desc_string = 3
Const _usb_desc_iface = 4
Const _usb_desc_endpoint = 5
Const _usb_desc_hid = &H21
Const _usb_desc_report = &H22
Const _usb_desc_physical = &H23


'Bitmask to pick off just the dplus and dminus pins of the port
Const _usb_pinmask =(2 ^ _usb_dplus) +(2 ^ _usb_dminus)

#if _usb_powered = &HC0
   Const _usb_devstatus = 1
#else
   Const _usb_devstatus = 0
#endif

'Automatically set the number of endpoints
#if Varexist( "_usb_Endp3Addr")
   #if Varexist( "_usb_Endp2Addr")
      Const _usb_endpoints = 3
   #else
      Const _usb_endpoints = 2
   #endif
#else
   #if Varexist( "_usb_Endp2Addr")
      Const _usb_endpoints = 2
   #else
      Const _usb_endpoints = 1
   #endif
#endif

'Generate the attribute bytes for endpoint descriptors
#if Varexist( "_usb_Endp2Addr")
  Const _usb_endp2attr = _usb_endp2addr +(_usb_endp2direction * &H80)
#endif
#if Varexist( "_usb_Endp3Addr")
  Const _usb_endp3attr = _usb_endp3addr +(_usb_endp3direction * &H80)
#endif

'Total length of the configuration descriptor plus descendant descriptors
Const _usb_descr_total =(_usb_endpoints -1) * 7 +(_usb_ifaces * 9) +(_usb_hids * 9) + 9

#if Varexist( "EIFR")
  _usb_ifr Alias Eifr                             'Interrupt flag register: EIFR, GIFR
#else
  _usb_ifr Alias Gifr
#endif

'************* Break the descriptor WORDs into high and low BYTES **************
'A workaround for limitations/bugs in BASCOM "DATA" statements
' (needed for descriptors)
Const _usb_spech = Hbyte(_usb_spec)
Const _usb_specl = Lbyte(_usb_spec)
Const _usb_vidh = Hbyte(_usb_vid)
Const _usb_vidl = Lbyte(_usb_vid)
Const _usb_pidh = Hbyte(_usb_pid)
Const _usb_pidl = Lbyte(_usb_pid)
Const _usb_devrelh = Hbyte(_usb_devrel)
Const _usb_devrell = Lbyte(_usb_devrel)
Const _usb_descr_totalh = Hbyte(_usb_descr_total)
Const _usb_descr_totall = Lbyte(_usb_descr_total)
Const _usb_hid_releaseh = Hbyte(_usb_hid_release)
Const _usb_hid_releasel = Lbyte(_usb_hid_release)
Const _usb_hid_descr_len =(6 +(3 * _usb_hid_numdescriptors))

'This is a fix applied to the length of the configuration descriptor.
'The configuration descriptor can not be a multiple of 8, or else Windows
'will not enmerate the device correctly.  So we will pad the descriptor by
'one byte, if necessary.
#if _usb_descr_total Mod 8 = 0
  Const _usb_descr_total2 = _usb_descr_total + 1
#else
  Const _usb_descr_total2 = _usb_descr_total
#endif

'Packets consist of a PID byte, up to 8 bytes of data, and 2 CRC bytes
Const _usb_packetsize = 1 + 8 + 2

'Make a receive buffer the size of 2 packets
Const _usb_rx_bufsize = _usb_packetsize * 2

'Allocate a transmit buffer of one packet plus status byte per endpoint
Const _usb_tx_bufsize = _usb_packetsize + 1
Const _usb_tx_rawbufsize = _usb_tx_bufsize * _usb_endpoints

'*******************************************************************************



'Device ID (assigned by USB host, for internal use)
Dim _usb_deviceid As Byte

'Allocate a receive buffer
Dim _usb_rx_buffer(_usb_rx_bufsize) As Byte
Dim _usb_rx_count As Byte

'Allocate a contiguous space for all transmit buffers
Dim _usb_tx_rawbuffer(_usb_tx_rawbufsize) As Byte

'Set up overlays that point to the status bytes and transmit buffers
Dim _usb_tx_status(1) As Byte At _usb_tx_rawbuffer Overlay
Dim _usb_tx_buffer(_usb_packetsize) As Byte At _usb_tx_rawbuffer + 1 Overlay
#if Varexist( "_usb_Endp3Addr")
   #if Varexist( "_usb_Endp2Addr")
      Dim _usb_tx_status2(1) As Byte At _usb_tx_status + _usb_tx_bufsize Overlay
      Dim _usb_tx_status3(1) As Byte At _usb_tx_status2 + _usb_tx_bufsize Overlay
      Dim _usb_tx_buffer2(_usb_packetsize) As Byte At _usb_tx_buffer + _usb_tx_bufsize Overlay
      Dim _usb_tx_buffer3(_usb_packetsize) As Byte At _usb_tx_buffer2 + _usb_tx_bufsize Overlay
   #else
      Dim _usb_tx_status3(1) As Byte At _usb_tx_status + _usb_tx_bufsize Overlay
      Dim _usb_tx_buffer3(_usb_packetsize) As Byte At _usb_tx_buffer + _usb_tx_bufsize Overlay
   #endif
#else
   #if Varexist( "_usb_Endp2Addr")
      Dim _usb_tx_status2(1) As Byte At _usb_tx_status + _usb_tx_bufsize Overlay
      Dim _usb_tx_buffer2(_usb_packetsize) As Byte At _usb_tx_buffer + _usb_tx_bufsize Overlay
   #endif
#endif

'Outogoing CRC word
Dim _usb_crc As Word
Dim _usb_crcl As Byte At _usb_crc Overlay
Dim _usb_crch As Byte At _usb_crc + 1 Overlay


'Status flags for the received USB packet
Dim _usb_status As Byte

'Status flags (token data) for the currently incoming USB packet
Dim _usb_status2 As Byte

'A flag used during enumeration
Dim Senddescriptor As Byte