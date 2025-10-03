$nocompile

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
Const _usb_RXC = 7      'USB Receive Complete / Data in RX buffer
Const _usb_RTR = 6      'USB Ready to Receive
Const _usb_Ignore= 5    'USB Ignore this packet flag
Const _usb_Setup = 4    'USB Setup phase
Const _usb_Endp3 = 3    'USB Endpoint Address bit 3
Const _usb_Endp2 = 2    'USB Endpoint Address bit 2
Const _usb_Endp1 = 1    'USB Endpoint Address bit 1
Const _usb_Endp0 = 0    'USB Endpoint Address bit 0

'Status flags for endpoints and sending a USB packet
Const _usb_RxSync = 7   'Receive sync bit for endpoint (DATAx toggling)
Const _usb_TxSync = 6   'Send sync bit for endpoint    (DatAx toggling)
Const _usb_TXC    = 5   'USB Transmit Complete flag
Const _usb_RTT    = 4   'USB Ready To Transmit flag

Const _usb_Endp_Init = 2^_usb_TXC
Const _usb_Setup_Sync = 2^_usb_TXC + 2^_usb_TxSync
Const _usb_SyncMask = 2^_usb_TxSync + 2^_usb_RxSync

'PID bytes that apply to low-speed devices
Const _usb_PID_OUT = &B11100001
Const _usb_PID_IN = &B01101001
Const _usb_PID_SETUP = &B00101101
Const _usb_PID_DATA0 = &B11000011
Const _usb_PID_DATA1 = &B01001011
Const _usb_PID_ACK = &B11010010
Const _usb_PID_NAK = &B01011010
Const _usb_PID_STALL = &B00011110

'PID bytes that do not apply to low-speed devices (for reference only)
Const _usb_PID_SOF = &B10100101
Const _usb_PID_DATA2 = &B10000111
Const _usb_PID_MDATA = &B00001111
Const _usb_PID_NYET = &B10010110
Const _usb_PID_PRE = &B00111100
Const _usb_PID_ERR = &B00111100
Const _usb_PID_SPLIT = &B01111000
Const _usb_PID_PING = &B10110100

'Common requests
Const _usb_REQ_GET_STATUS = 0
Const _usb_REQ_CLEAR_FEATURE = 1
Const _usb_REQ_SET_FEATURE = 3
Const _usb_REQ_SET_ADDRESS = 5
Const _usb_REQ_GET_DESCRIPTOR = 6
Const _usb_REQ_SET_DESCRIPTOR = 7
Const _usb_REQ_GET_CONFIG = 8
Const _usb_REQ_SET_CONFIG = 9
Const _usb_REQ_GET_IFACE = &h0A
Const _usb_REQ_SET_IFACE = &h11
Const _usb_REQ_SYNCH_FRAME = &h12

'HID Class Requests
Const _usb_REQ_GET_REPORT = 1
Const _usb_REQ_GET_IDLE = 2
Const _usb_REQ_GET_PROTOCOL = 3
Const _usb_REQ_SET_REPORT = 9
Const _usb_REQ_SET_IDLE = &h0A
Const _usb_REQ_SET_PROTOCOL = &h0B

'Descriptor types
Const _usb_DESC_DEVICE = 1
Const _usb_DESC_CONFIG = 2
Const _usb_DESC_STRING = 3
Const _usb_DESC_IFACE = 4
Const _usb_DESC_ENDPOINT = 5
Const _usb_DESC_HID = &h21
Const _usb_DESC_REPORT = &h22
Const _usb_DESC_PHYSICAL = &h23


'Bitmask to pick off just the dplus and dminus pins of the port
Const _usb_pinmask =(2 ^ _usb_dplus) + (2 ^ _usb_dminus)

#if _usb_Powered = &hC0
   Const _usb_devstatus = 1
#else
   Const _usb_devstatus = 0
#endif

'Automatically set the number of endpoints
#if varexist("_usb_Endp3Addr")
   #if varexist("_usb_Endp2Addr")
      Const _usb_Endpoints = 3
   #else
      Const _usb_Endpoints = 2
   #endif
#else
   #if varexist("_usb_Endp2Addr")
      Const _usb_Endpoints = 2
   #else
      Const _usb_Endpoints = 1
   #endif
#endif

'Generate the attribute bytes for endpoint descriptors
#if varexist("_usb_Endp2Addr")
Const _usb_Endp2Attr = _usb_Endp2Addr + (_usb_Endp2Direction * &H80)
#endif
#if varexist("_usb_Endp3Addr")
Const _usb_Endp3Attr = _usb_Endp3Addr + (_usb_Endp3Direction * &H80)
#endif

'Total length of the configuration descriptor plus descendant descriptors
Const _usb_Descr_Total = (_usb_Endpoints-1) * 7 + (_usb_IFaces * 9) + (_usb_HIDs * 9) + 9

#if varexist("EIFR")
_usb_IFR  ALIAS EIFR    'Interrupt flag register: EIFR, GIFR
#else
_usb_IFR  ALIAS GIFR
#endif

'************* Break the descriptor WORDs into high and low BYTES **************
'A workaround for limitations/bugs in BASCOM "DATA" statements
' (needed for descriptors)
Const _usb_SpecH = hbyte(_usb_Spec)
Const _usb_SpecL = lbyte(_usb_Spec)
Const _usb_VIDH = hbyte(_usb_VID)
Const _usb_VIDL = lbyte(_usb_VID)
Const _usb_PIDH = hbyte(_usb_PID)
Const _usb_PIDL = lbyte(_usb_PID)
Const _usb_DevRelH = hbyte(_usb_DevRel)
Const _usb_DevRelL = lbyte(_usb_DevRel)
Const _usb_Descr_TotalH = hbyte(_usb_Descr_Total)
Const _usb_Descr_TotalL = lbyte(_usb_Descr_Total)
Const _usb_HID_ReleaseH = hbyte(_usb_HID_Release)
Const _usb_HID_ReleaseL = lbyte(_usb_HID_Release)
Const _usb_HID_DESCR_LEN = (6 + (3 * _usb_HID_NumDescriptors))

'This is a fix applied to the length of the configuration descriptor.
'The configuration descriptor can not be a multiple of 8, or else Windows
'will not enmerate the device correctly.  So we will pad the descriptor by
'one byte, if necessary.
#if _usb_Descr_Total mod 8 = 0
Const _usb_Descr_Total2 = _usb_Descr_Total + 1
#else
Const _usb_Descr_Total2 = _usb_Descr_Total
#endif

'Packets consist of a PID byte, up to 8 bytes of data, and 2 CRC bytes
Const _usb_packetsize = 1 + 8 + 2

'Make a receive buffer the size of 2 packets
Const _usb_rx_bufsize = _usb_packetsize * 2

'Allocate a transmit buffer of one packet plus status byte per endpoint
Const _usb_tx_bufsize = _usb_packetsize + 1
Const _usb_tx_rawbufsize = _usb_tx_bufsize * _usb_Endpoints

'*******************************************************************************


#if _usb_USE_EEPROM = 1
'Make a pointer for reading descriptors from EEPROM
Dim _usb_EEPROMADDR as word
Dim _usb_EEPROMADDRL as byte at _usb_EEPROMADDR Overlay
Dim _usb_EEPROMADDRH as byte at _usb_EEPROMADDR+1 Overlay
#endif

'Device ID (assigned by USB host, for internal use)
Dim _usb_DeviceID as byte

'Allocate a receive buffer
Dim _usb_rx_buffer(_usb_rx_bufsize ) As Byte
Dim _usb_rx_count as byte

'Allocate a contiguous space for all transmit buffers
Dim _usb_tx_rawbuffer(_usb_tx_rawbufsize) as Byte

'Set up overlays that point to the status bytes and transmit buffers
Dim _usb_tx_status as byte at _usb_tx_rawbuffer overlay
Dim _usb_tx_buffer(_usb_packetsize) as byte at _usb_tx_rawbuffer+1 overlay
#if Varexist( "_usb_Endp3Addr")
   #if Varexist( "_usb_Endp2Addr")
' six1 fix array 2012-11-28
      Dim _usb_tx_status2(3) As Byte At _usb_tx_status + _usb_tx_bufsize Overlay
      Dim _usb_tx_status3 As Byte At _usb_tx_status2 + _usb_tx_bufsize Overlay
      Dim _usb_tx_buffer2(_usb_packetsize) As Byte At _usb_tx_buffer + _usb_tx_bufsize Overlay
      Dim _usb_tx_buffer3(_usb_packetsize) As Byte At _usb_tx_buffer2 + _usb_tx_bufsize Overlay
   #else
      Dim _usb_tx_status3 As Byte At _usb_tx_status + _usb_tx_bufsize Overlay
      Dim _usb_tx_buffer3(_usb_packetsize) As Byte At _usb_tx_buffer + _usb_tx_bufsize Overlay
   #endif
#else
   #if Varexist( "_usb_Endp2Addr")
      Dim _usb_tx_status2 As Byte At _usb_tx_status + _usb_tx_bufsize Overlay
      Dim _usb_tx_buffer2(_usb_packetsize) As Byte At _usb_tx_buffer + _usb_tx_bufsize Overlay
   #endif
#endif


'Outogoing CRC word
Dim _usb_crc as word
Dim _usb_crcL as byte at _usb_crc overlay
Dim _usb_crcH as byte at _usb_crc+1 overlay


'Status flags for the received USB packet
Dim _usb_STATUS as Byte

'Status flags (token data) for the currently incoming USB packet
Dim _usb_STATUS2 as byte

'A flag used during enumeration
Dim SendDescriptor as byte