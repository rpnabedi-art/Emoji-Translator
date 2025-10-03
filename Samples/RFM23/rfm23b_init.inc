$nocompile

'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
'  +
'  + File NAME      rfm23b_init.inc
'  +
'  + DESCRIPTION:   Initialization of RFM23B Registers
'  +
'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++




'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
'  +
'  + SUB NAME:      Rfm23b_init()
'  +
'  + DESCRIPTION:   Initialize all RFM23B Register according the Excel config tool
'  +
'  + INPUT:         None
'  +
'  + RETURN:        None
'  +
'  + NOTES:         None
'  +
'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

'(

' RFM23B Settings:

' Modulation:               GFSK
' Manchester Code:          Disabled
' Frequency:                868.00 MHz
' Baud:                     56 kbps
' AFC:                      enable
' Deviation:                45KHz
' CRC:                      enable (CRC16-IBM)
' Header:                   We use one (of the four) header byte for the address (broadcast is also enabled)
' Sync:                     2DD4
' Payload Length:           8 Byte
' Preamble Threshold:       16 Bit
' Preamble Length:          32 Bit
' Packet Length:            the packet length is included in the transmit header




Following the register content calculated by the Excel Tool for SI4431:

Address
Register  Value
1C        95
1D        40


20        6B
21        01
22        31
23        D6
24        02
25        FC
2A        3C
2C        28
2D        16
2E        29

30        AD
32        88
33        12
34        08
35        22
36        2D
37        D4
38        00
39        00
3A        01
3B        00
3C        00
3D        00
3E        08
3F        01
40        00
41        00
42        00
43        FF
44        FF
45        F8
46        FF



6E        0E
6F        56

70        0C
71        23
72        48

75        73
76        64
77        00

')
Sub Rfm23b_init()
     'Initialization according AN415
     'The power-down pin of the RFM23B radio must be pulled low (radio enabled).
      Waitms 15

    'Software Reset
      Call Rf23b_write(operating_function_control_1 , Rfm13b_software_reset)

      Bitwait Nirq , Reset                        'wait for POR interrupt from the radio (while the nIRQ pin is high)
    'read interrupt status registers to clear the interrupt flags and release NIRQ pin
      Read_result = Rf23b_read(interrupt_status_1)    'read the Interrupt Status1 register
      Read_result = Rf23b_read(interrupt_status_2)    'read the Interrupt Status2 register

      Call Rf23b_write(operating_function_control_1 , &B00000001)       ' Xtal ON

      'set Crystal Oscillator Load Capacitance register
      'I started with &HD7 and changed it to &HD1 after AFC Correction output
      Call Rf23b_write(crystal_osc_load_capacitance , &HD7)       '09  --> Set Xtal Load capacitance


      Call Rf23b_write(microcontroller_output_clock , &H02)       '0A  --> µC Clock out = 10MHz


     'set the modem parameters according to the excel calculator
     'RX GFSK Modem COMMANDS
      Call Rf23b_write(if_filter_bandwidth , &H95)       '1C         <<<<<<<<--------- register content form Excel Tool

        'AFC
      Call Rf23b_write(afc_loop_gearshift_override , &H40)       '1D     enable AFC    <<<<<<<<--------- register content form Excel Tool

      Call Rf23b_write(afc_timing_control , &H0A)     '1E                AFC Timing
      Call Rf23b_write(clock_recovery_gearshift_overr , &H03)       '1F  AFC Timing

      Call Rf23b_write(clock_recovery_oversampling_rat , &H6B)       '20     <<<<<<<<--------- register content form Excel Tool
      Call Rf23b_write(clock_recovery_offset_2 , &H01)       '21             <<<<<<<<--------- register content form Excel Tool
      Call Rf23b_write(clock_recovery_offset_1 , &H31)       '22             <<<<<<<<--------- register content form Excel Tool
      Call Rf23b_write(clock_recovery_offset_0 , &HD6)       '23             <<<<<<<<--------- register content form Excel Tool
      Call Rf23b_write(clock_recovery_tim_loop_gain_1 , &H02)       '24      <<<<<<<<--------- register content form Excel Tool
      Call Rf23b_write(clock_recovery_tim_loop_gain_0 , &HFC)       '25      <<<<<<<<--------- register content form Excel Tool

        'RSSI threshold  = -120dB
       Call Rf23b_write(rssi_thresh_for_clear_ch_indi , &H10)       '27


      Call Rf23b_write(afc_limiter , &H3C)        '2A                   <<<<<<<<--------- register content form Excel Tool

      'Only relevant for OOK mode
      Call Rf23b_write(ook_counter_value_1 , &H28)       '2C                   <<<<<<<<--------- register content form Excel Tool
      Call Rf23b_write(ook_counter_value_2 , &H16)       '2D                   <<<<<<<<--------- register content form Excel Tool
      Call Rf23b_write(slicer_peak_hold , &H29)   '2E                          <<<<<<<<--------- register content form Excel Tool


      'enable the TX packet handler and CRC-16 (IBM) check  --> Excel Calc
      Call Rf23b_write(data_access_control , &HAD)       '30                      <<<<<<<<--------- register content form Excel Tool

      'Enable/disable Received Header Bytes to be Checked Against the Check Header Bytes
      'Enable/disable Broadcast address
      'We use here Header Byte 3 as address Byte
      Call Rf23b_write(header_control_1 , &H88)   '32  --> Header Check Enable    <<<<<<<<--------- register content form Excel Tool

      'Header Length = One Byte (Header 3)
      'skipsyn = 0
      'Header Length = Header 3 (only)
      'Synchronization Word Length = Synchronization Word 3 and 2 (2 Byte)
      'set variable packet length (the length of the payload is defined by the received packet length field of the packet)
      Call Rf23b_write(header_control_2 , &H12)   '33  --> ' Packet Length:            the packet length is included in the transmit header    <<<<<<<<--------- register content form Excel Tool
     'set the preamble length
      Call Rf23b_write(preamble_length , &H08)    '34     Preamle in X * 4 Bit       <<<<<<<<--------- register content form Excel Tool
     'Preamble Detection Threshold
      Call Rf23b_write(preamble_detection_control , &H22)       '35   --> Valid Preamble detected Bits = X * 4Bit    <<<<<<<<--------- register content form Excel Tool

     'Set the sync word pattern to &H2DD4
     Call Rf23b_write(sync_word_3 , &H2D)         '36         <<<<<<<<--------- register content form Excel Tool
     Call Rf23b_write(sync_word_2 , &HD4)         '37         <<<<<<<<--------- register content form Excel Tool
     Call Rf23b_write(sync_word_1 , &H00)         '38        <<<<<<<<--------- register content form Excel Tool
     Call Rf23b_write(sync_word_0 , &H00)         '39        <<<<<<<<--------- register content form Excel Tool

     ' Transmitt Header
     ' Header byte to be transmitted
      Call Rf23b_write(transmit_header_3 , &H00)  '3A    'Header 3  = ADDRESS      &HFF = broadcast message     <<<<<<<<--------- register content form Excel Tool
      Call Rf23b_write(transmit_header_2 , &H00)  '3B    'Header 2  = not used     <<<<<<<<--------- register content form Excel Tool
      Call Rf23b_write(transmit_header_1 , &H00)  '3C    'Header 1  = not used     <<<<<<<<--------- register content form Excel Tool
      Call Rf23b_write(transmit_header_0 , &H00)  '3D    'Header 0  = not used     <<<<<<<<--------- register content form Excel Tool

      'Payload Length (Transmitt Packet Length)
      Call Rf23b_write(transmit_packet_length , &H08)       '3E  --> Payload = 8 Bytes        <<<<<<<<--------- register content form Excel Tool

      'The header check is designed to support 1...4 bytes and broadcast headers
      'the expected value of the header should be programmed in  in Registers 3F .... 42
      Call Rf23b_write(check_header_3 , &H00)     '3F    'Header 3  = ADDRESS            <<<<<<<<--------- register content form Excel Tool
      Call Rf23b_write(check_header_2 , &H00)     '40    'Header 2                   <<<<<<<<--------- register content form Excel Tool
      Call Rf23b_write(check_header_1 , &H00)     '41    'Header 1                   <<<<<<<<--------- register content form Excel Tool
      Call Rf23b_write(check_header_0 , &H00)     '42    'Header 0                   <<<<<<<<--------- register content form Excel Tool

      'Header enable
      'Header Enable bytes 3 to 0 control which bits of the Check Header bytes are checked against the corresponding
      'bits in the Received Header. Only those bits are compared where the enable bits are set to 1.
      Call Rf23b_write(header_enable_3 , &B11111111)       '43                      <<<<<<<<--------- register content form Excel Tool
      Call Rf23b_write(header_enable_2 , &B11111111)       '44   'not used               <<<<<<<<--------- register content form Excel Tool
      Call Rf23b_write(header_enable_1 , &HF8)    '45   'not used               <<<<<<<<--------- register content form Excel Tool
      Call Rf23b_write(header_enable_0 , &B11111111)       '46   'not used               <<<<<<<<--------- register content form Excel Tool



        'AGC On
      Call Rf23b_write(agc_override_1 , &H60)         '69

      'TX Power  = +13dBm
      Call Rf23b_write(tx_power , Tx_ouput_power) '6D

      'set the desired TX data rate (XX kbps)            'values according excel configuration tool
      Call Rf23b_write(tx_data_rate_1 , &H0E)     '6E                <<<<<<<<--------- register content form Excel Tool
      Call Rf23b_write(tx_data_rate_0 , &H56)     '6F                <<<<<<<<--------- register content form Excel Tool

      Call Rf23b_write(modulation_mode_control_1 , &H0C)       '70           <<<<<<<<--------- register content form Excel Tool

      ' Modulation Mode Control
      ' In FIFO mode, the transmit and receive data is stored in integrated FIFO register memory.
      Call Rf23b_write(modulation_mode_control_2 , &H23)       '71    --> FIFO Mode,GFSK Modulation   <<<<<<<<--------- register content form Excel Tool

      'set the desired TX deviation (+-45 kHz)
      Call Rf23b_write(frequency_deviation , &H48)       '72              <<<<<<<<--------- register content form Excel Tool
      Call Rf23b_write(frequency_offset_1 , &H00)     '73
      Call Rf23b_write(frequency_offset_2 , &H00)     '74

      'set the center frequency to XXX MHz              'values according excel configuration tool
      Call Rf23b_write(frequency_band_select , &H73)       '75      --> 73 = 860 - 880MHz Range      <<<<<<<<--------- register content form Excel Tool
      Call Rf23b_write(nominal_carrier_frequency_1 , &H64)       '76                  <<<<<<<<--------- register content form Excel Tool
      Call Rf23b_write(nominal_carrier_frequency_0 , &H00)       '77                  <<<<<<<<--------- register content form Excel Tool

      'Frequency hopping  = OFF
      Call Rf23b_write(frequency_hopping_channel_select , &H00)       '79
      Call Rf23b_write(frequency_hopping_step_size , &H00)       '7A

     'GPIO Port configurations
     Call Rf23b_write(gpio0_configuration , &HF2)     'RFM23B GPIO0 <----> TX_ANT (RFM23B)
     Call Rf23b_write(gpio1_configuration , &HF5)     'RFM23B GPIO1 <----> RX_ANT (RFM23B)
     Call Rf23b_write(gpio2_configuration , &H00)     'µC Clock out
     Call Rf23b_write(i_o_port_configuration , &H00)  'Set port's to 0

     'ADC + Tempsensor Configuration
     Call Rf23b_write(adc_configuration , &H70)       '0F    'ADC Input  = GND
     Call Rf23b_write(adc_sensor_amplifier_offset , &H00)       '10
     Call Rf23b_write(temperature_sensor_control , &H00)       '12
     Call Rf23b_write(temperature_value_offset , &H00)       '13



     'Additional Init for sending data with more then 64Byte length
     'The built-in transmit and receive packet handlers provide three different FIFO status signals:
     '1)  Transmit FIFO Almost Full
     '2)  Transmit FIFO Almost Empty
     '3)  Receive FIFO Almost Full.
     ' These signals can be used by the MCU to send and receive packets that are larger than the built-in FIFOs.

     'set the TX FIFO almost empty threshold to 10 bytes
     Call Rf23b_write(tx_fifo_control_2 , &H0B)   '7D   (Tx Fifo Control 2 Register)
     'set the RX FIFO almost full threshold to 54 bytes
     Call Rf23b_write(rx_fifo_control , &H36)     '7E   (RX FIFO Control register)

    '-----------------------R F M 2 3 B Init    End---------------------------------
End Sub