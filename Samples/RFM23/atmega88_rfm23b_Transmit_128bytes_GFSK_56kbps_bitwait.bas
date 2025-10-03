
'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
'  +
'  + FILE NAME:     atmega88_rfm23b_Transmit_128bytes_GFSK_56kbps_bitwait.bas
'  +
'  + DESCRIPTION:   RFM23B with ATMEGA88
'  +                Transmit 128 Byte using Bitwait (Interrupts disabled)
'  +                How to Send Longer than 64 bytes of Payload (transmit and Receive Packets With Longer Payloads Of Up To 255 Bytes)
'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

 ' 1) Fill 64bytes into the FIFO                          '64 Byte sent
 ' 2) Start Tx
 ' 3) Wait for the TX FIFO Almost Empty interrupt
 ' 4) Fill next 32 bytes into the FIFO                    '96 Bytes sent
 ' 5) Wait for the TX FIFO Almost Empty interrupt
 ' 6) Fill next 32 bytes into the FIFO                    '128 Bytes sent
 ' 7) Wait for the packet sent interrupt                  'Ready



 '     Tx FIFO (64 Byte)
 '  +-----------+
 '  |           |
 '  |- - - - - -|- -  Tx FIFO almost full threshold
 '  |           |
 '  |           |
 '  |           |
 '  |           |
 '  |           |
 '  |           |
 '  |           |
 '  |           |
 '  |           |
 '  |- - - - - -|- - Tx FIFO almost empty threshold (in this example = 10 Byte)
 '  |           |
 '  +-----------+



 '     Rx FIFO (64 Byte)
 '  +-----------+
 '  |           |
 '  |- - - - - -|- -  Rx FIFO almost full threshold  (in this example = 54 Byte)
 '  |           |
 '  |           |
 '  |           |
 '  |           |
 '  |           |
 '  |           |
 '  |           |
 '  |           |
 '  |           |
 '  |           |
 '  |           |
 '  +-----------+



 ' Used data sheets:
 '                 Silicon Labs Si4430/31/32-B1  (Rev 1.1 10/10)
 '                 Silicon Labs AN440: EZRadioPRO Detailed Register Descriptions.
 '                 Silicon Labs AN593: TEMPERATURE SENSOR USAGE AND FREQUENCY CALIBRATION FOR THE Si4X3X
 '                 Silicon Labs AN415: PROGRAMMING GUIDE


' Hardware Connections:

' ATMEGA88                       RFM23B
' ATMEGA88 Portb.2         ----> nSEL (RFM23B)
' ATMEGA88 Portb.3         ----> SDI  (RFM23B)
' ATMEGA88 Portb.4         ----> SDO  (RFM23B)
' ATEMGA88 Portb.5         ----> SCK  (RFM23B)
' ATMEGA88 Portd.2 (INT0)  ----> nIRQ (RFM23B)

'                          (RFM23B) GPIO0 <----> TX_ANT (RFM23B)
'                          (RFM23B) GPIO1 <----> RX_ANT (RFM23B)
'                          (RFM23B) SDN (Shutdown) <---> GND


' RFM23B Settings:
' Modulation:               GFSK
' Manchester Code:          Disabled
' Frequency:                868.00 MHz
' Baud:                     56 kbps
' AFC:                      enable
' Deviation:                45KHz
' CRC:                      enable (CRC16-IBM)
' Header:                   We use one (of the four) header byte as  node address filter (broadcast is also enabled)
' Sync:                     2DD4
' Payload Length:           8 Byte
' Preamble Threshold:       16 Bit
' Preamble Length:          32 Bit
' Packet Length:            the packet length is included in the transmit header
'

' Transmit and Receive Packets Using the FIFO

'  +-------+-------+-------+-------+-------+-------+-------+-------+-------+-------+-------+-------+-------+-------+
'  |   P   |   P   |   P   |   P   |  2D   |   D4  | HEADER|Length |Data 0 |Data 1 |  .... |Data 63|  CRC  |   CRC |
'  +-------+-------+-------+-------+-------+-------+-------+-------+-------+-------+-------+-------+-------+-------+
'  <-------32Bit Preamble-------- -><Sync. Pattern ><-Addr->       <----------Data (Payload)------><--16-Bit CRC-->


$regfile = "m88def.dat"
$crystal = 8000000                                'internal 8MHz
$hwstack = 80
$swstack = 80
$framesize = 100
$baud = 19200

Config Submode = New
Config Watchdog = 1024
Start Watchdog


'CHOOSE THE TX Output Power here:                  <<<<<<<<<<<<<<<<<<<<<<<<--------------------------------

'Const Tx_ouput_power = &B0000_1000                '-8dBm
'Const Tx_ouput_power = &B0000_1001                '-5dBm
'Const Tx_ouput_power = &B0000_1010                '-2dBm
'Const Tx_ouput_power = &B0000_1011                '+1dBm
'Const Tx_ouput_power = &B0000_1100                '+4dBm
'Const Tx_ouput_power = &B0000_1101                '+7dBm
'Const Tx_ouput_power = &B0000_1110                '+10dBm
Const Tx_ouput_power = &B0000_1111                '+13dBm   (Full Tx Power)

'-----Port Configuration--------------------------------------------------------
Config Portb.0 = Output
Led Alias Portb.0                                 'LED
Config Portd.2 = Input                            'RFM23B nIRQ IN
Nirq Alias Pind.2
Config Portb.2 = Output                           'RFM23B nSEL OUT
Nsel Alias Portb.2
Set Nsel

'------Interrupts---------------------------------------------------------------
On Int0 Nirq_int
Config Int0 = Falling
Enable Int0

'-----Timer1 (4 Second Tick)-------------------------------------------------------
Config Timer1 = Timer , Prescale = 1024
On Timer1 Timer_irq
Const Timerpreload = 34286
Enable Timer1

'------constants----------------------------------------------------------------
Const Gpio_2_direct_digital_out = &B11001010      'Configure GPIO2 Pin as Output
Const Adcstart_adcdone = 7                        'Bit 7 of Register Adc_configuration
Const Temp_range_0_128_c = &HA0                   'Temperature Sensor Range Selection:  0....128 degree C (8mV per degree C)  , ADC8 LSB = 0.5 degree C
Const Rfm13b_software_reset = &H80

'------Variables----------------------------------------------------------------
Dim I As Byte
Dim Read_result As Byte
Dim Rfm23b_interrupt_status As Word
Dim Temp_sensor_single As Single
Dim Tx(129) As Byte
Dim Send_string As String * 128 At Tx(1) Overlay
Dim Rx(129) As Byte                               'Payload array
Dim Receive_string As String * 128 At Rx(1) Overlay       '8 Ascii + 0 termination  = 9
Dim Node_address As Byte
Dim Valid_transmitter_address As Byte
Dim Device_stat As Byte
Dim Received_address As Byte
Dim Arssi As Byte
Dim Afc_correction_values As Byte
Dim Afc_correction_single As Single
Dim Address_filter_pass As Byte
Dim Header_check_filter As Byte
Dim Txfifo_almost_empty_counter As Byte : Txfifo_almost_empty_counter = 0
'Flags
Dim Flags As Byte
Data_received Alias Flags.0
Receiver_on Alias Flags.1
Transmitter_on Alias Flags.2
Packet_sent_interrupt Alias Flags.3
Four_second_tick Alias Flags.4
Tx_fifo_almost_empty Alias Flags.5


'------includes-----------------------------------------------------------------
$include "rfm23b_register_constants.inc"
$include "rfm23b_functions.inc"
$include "rfm23b_init.inc"

'-----XTEA----------------------------------------------------------------------
'The XTEA encryption/decryption has a small footprint
'XTEA processes data in blocks of 8 bytes. So the minumum length of the data is 8 bytes.
'A 128 bit key is used to encrypt/decrypt the data. You need to supply this in an array of 8 bytes.

'Using the encoding on a string can cause problems when the data contains a 0. This is the end of the string marker.

Dim String_key As String * 16                     ' This String have actually 17 Byte where Byte 17 is the 0 termination for the string !
Dim Key(16) As Byte At String_key Overlay         ' 128 bit key
String_key = "Bascom-AVR Rocks"                   ' 128-Bit Key  (overlayed over String_key)

'-------SPI configuration-------------------------------------------------------
Config Spi = Hard , Interrupt = Off , Data Order = Msb , Master = Yes , Polarity = Low , Phase = 0 , Clockrate = 4 , Noss = 1 , Spiin = 0
Spiinit
'SPI clockrate = 8MHz/4 = 2MHz

Reset Watchdog

Call Rfm23b_init()

'+++++++++++++++ NODE SPECIFIC INITIALIZATION+++++++++++++++++++++++++++++++++++
' Automatic header generation and qualification by RFM23B (up to four bytes)
' For example, a node just wants to receive packets from a specific node or group of nodes.

'                                                   <HEADER>
'  +-------+-------+-------+-------+-------+-------+-------+-------+-------+-------+-------+-------+-------+-------+
'  |   P   |   P   |   P   |   P   |  2D   |   D4  | HEADER|Length |Data 0 |Data 1 |  .... |Data 63|  CRC  |   CRC |
'  +-------+-------+-------+-------+-------+-------+-------+-------+-------+-------+-------+-------+-------+-------+


'  Value in RECEIVED_HEADER_3 (e.g. = 1 )         -->+-----+
'                                                    |     |
'  Value in HEADER_ENABLE_3   (e.g. = &B11111111) -->|TRUE | ----> header OK !
'                                                    |     |
'  Value in CHECK_HEADER_3    (e.g. = 1 )         -->+-----+

' If any of the received header bytes fails the filter check, the header bit in the Device Status register is set.

' SET NODE ADDRESS = 2
   Node_address = 2
Call Rf23b_write_value_by_ref(transmit_header_3 , Node_address)       '3A    'Header 3  = ADDRESS   ;   &HFF = broadcast message

'With address_filter_pass you can define which address will be passed (beside broadcast = &HFF )
  Address_filter_pass = 1
Call Rf23b_write_value_by_ref(check_header_3 , Address_filter_pass)       '3F    'Header 3  = ADDRESS   (Check for Address)

 'The filter should check every single bit
 ' for example you could also check for &B0000_1111. Then only the lower nibble will be checked
  Header_check_filter = &B11111111
Call Rf23b_write_value_by_ref(header_enable_3 , Header_check_filter)       '3F

'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


Print "--- RFM23B - ATMEGA88  ---"
Print
Print "Device Type   : " ; Hex(rf23b_read(&H00))
Print "Device Version: " ; Hex(rf23b_read(&H01))
Print
Print "Node Address = " ; Node_address
Print "This Node receive from Address " ; Address_filter_pass ; "   and broadcast address (&HFF)"

' Device Status Register
'      7         6       5         4        3        2       1       0
'  +--------+--------+--------+--------+--------+--------+--------+--------+
'  |Overflow|Underfl |Rx Empty|Head Err|Freq Err|reserved|  CPS1  | CPS0   |
'  +--------+--------+--------+--------+--------+--------+--------+--------+
'  <---------FIFO------------>                           <Chip Power State >
'Print "Device Status : " ; Bin(rf23b_read(&H02))

Enable Interrupts
Disable Int0

Do
  Reset Watchdog

  If Four_second_tick = 1 Then                    ' 4 second Tick
     Reset Four_second_tick

          Set Led

          Send_string = "Hello Bascom Freaks ! In this example we send out 128 Byte Buffer by RFM23B with help from FIFO threshold interrupts !!!!!!!!!!!"
         'Print Send_string
         Print "String length = " ; Len(send_string) ; " Byte"
          Call Rf23b_write(transmit_packet_length , 128)       'Set the Transmitt Packet Length to 128 Byte

       '[1] - - - - - - - - Fill 64bytes into the FIFO - - - - - - - - - - - - -
         '  Xteaencode Tx(1) , Key(1) , 64         ' XTEA encode the data (needs to be a multiple of 8 Bytes)
           Call Rf23b_fifo_burst_write(1 , 64)    'Write Tx(S) Array to FIFO in Burst Mode , S = 1

       '[2] Disable all other interrupts and enable the FIFO ALMOST EMPTY interrupt only.
           Call Rf23b_write(interrupt_enable_1 , &H20)
           Call Rf23b_write(interrupt_enable_2 , &H00)
       '[3] read interrupt status registers to release all pending interrupts
           Rfm23b_interrupt_status = Rf23b_int_burst_read()
       '[4] enable transmitter
           Call Rf23b_write(operating_function_control_1 , &B00001001)       'Enable Tx

       '[5] wait for the packet sent interrupt
           Bitwait Nirq , Reset
           'read interrupt status registers to clear the interrupt flags and release NIRQ pin
           Rfm23b_interrupt_status = Rf23b_int_burst_read()

       '[6] after TX FIFO Almost Empty write the next 32 Byte in to the FIFO
           Call Rf23b_fifo_burst_write(65 , 32)   'Write Tx(S) Array to FIFO in Burst Mode , S = 65

           Bitwait Nirq , Reset
           'read interrupt status registers to clear the interrupt flags and release NIRQ pin
           Rfm23b_interrupt_status = Rf23b_int_burst_read()
       '[7] after TX FIFO Almost Empty write the next 32 Byte in to the FIFO
           Call Rf23b_fifo_burst_write(97 , 32)   'Write Tx(S) Array to FIFO in Burst Mode , S = 97

       '[8] Disable all other interrupts and enable the packet sent interrupt only.
           Call Rf23b_write(interrupt_enable_1 , &B0000_0100)       'Enable ONLY Packet Sent Interrupt (enpksent)
           Call Rf23b_write(interrupt_enable_2 , &B0000_0000)       'All Interrupts in this register disabled

       '[9] wait for the packet sent interrupt
           Bitwait Nirq , Reset
           'read interrupt status registers to clear the interrupt flags and release NIRQ pin
           Rfm23b_interrupt_status = Rf23b_int_burst_read()

       '[10] Switch off Transmitter
           Call Rf23b_write(operating_function_control_1 , &B00000001)       'DISABLE Tx , DISABLE Rx

           Reset Led

 End If                                           ' Four_second_tick

Loop

End                                               'end program

'---------Interrupt Service Routine---------------------------------------------

' INT0 is disabled in this example
Nirq_int:

    'read interrupt status registers to clear the interrupt flags and release NIRQ pin
  '  Rfm23b_interrupt_status = Rf23b_int_burst_read()

'  Rfm23b_interrupt_status =
'      15       14       13       12       11       10       9        8         7         6       5         4        3        2       1       0
'  +--------+--------+--------+--------+--------+--------+--------+--------+--------+--------+--------+--------+--------+--------+--------+--------+
'  |iswdet  |ipreaval|ipreain | irssi  |  iwut  |  ilbd  |ichiprdy| ipor   | ifferr |itxffafu|itxffaem|irxffafu| iext   |ipksent |ipkvalid|icrcerr |
'  +--------+--------+--------+--------+--------+--------+--------+--------+--------+--------+--------+--------+--------+--------+--------+--------+

Return

Timer_irq:
  Timer1 = Timerpreload                           '4 Second Tick at 8MHz
  Set Four_second_tick
Return