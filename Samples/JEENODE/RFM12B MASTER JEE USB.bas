

' Hardware: JEE NODE USB V3 running at 16MHz internal, 3.3 Volt
' http://jeelabs.net/projects/hardware/wiki/JeeNode_USB

' FUNCTION: RFM12B MASTER

' Thanks to Holli for his RFM12 code examples which was a starting point for this example

' MCS Bootloader using 57600 Baud, Reset = Reset Button

' Debug output Baudrate = 57600

' SENSOR ID = 20
' Frequency = 869,92MHz
' RM12B Baudrate = 4,8 kbit

' PROTOCOL:

'       Preamble        syncword                 Data Bytes
'  +-------+-------+-------+-------+-------+-------+...+-------+-------+
'  | &HAA  | &HAA  | &H2D  | &HDH  |  ID   | Byte0 |   | Byte6 |  CRC  |
'  +-------+-------+-------+-------+-------+-------+...+-------+-------+


'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
' --> Follow Regulations  !!!
' --> In Europe:
' --> http://www.erodocdb.dk/Docs/doc98/official/pdf/CEPTREP038.PDF
' --> http://www.bundesnetzagentur.de/cae/servlet/contentblob/38206/publicationFile/2580/ShortRangeDevicesSRD_ID17299pdf.pdf
'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

' Receiver Control Command:
' RSSIsetth = -91dBm , LNA = 0dBm
' RSSIth = RSSIsetth + G LNA =  -91dBm + 0dBm = -91dBm


'Hyperterminal output of this Example:
'ARSSI output Signal, Sensor ID2 , Temperatur of DS18B20 or Value of Byte 2 (depending on Sensor), Byte 2 and Byte 3 of Receive Array


'(
...
ARSSI=979.7 mV --> ID2= 22.2  °C    Rx = 99/1
ARSSI=978.6 mV --> ID2= 22.2  °C    Rx = 99/1
ARSSI=431.8 mV --> ID3= 1   Rx = 1/17
ARSSI=402.8 mV --> ID3= 131   Rx = 131/0
ARSSI=979.7 mV --> ID2= 22.1  °C    Rx = 98/1
ARSSI=1006.5 mV --> ID2= 22.1  °C    Rx = 97/1
ARSSI=962.5 mV --> ID2= 22.1  °C    Rx = 97/1
ARSSI=980.8 mV --> ID2= 22.1  °C    Rx = 97/1
ARSSI=977.5 mV --> ID2= 22.1  °C    Rx = 97/1
ARSSI=978.6 mV --> ID2= 22.1  °C    Rx = 97/1
ARSSI=720.8 mV --> ID1= 6.0  °C    Rx = 96/0
...

')

$regfile = "m328pdef.dat"
$crystal = 16e6                                   '16MHz
$hwstack = 80
$swstack = 80
$framesize = 100

Config Submode = New                              'there is no need to DECLARE a sub/function before you call it but....(see helpfile)

Config Watchdog = 512                             '1 Second
Start Watchdog




'---------Variables-------------------------------------------------------------
Dim Count As Byte
Dim Temp As Byte
Dim Cmd(2) As Byte
Dim Sdi(2) As Byte
Dim Stat(2) As Byte                               'Array for Status Register Bytes
'RECEIVE ARRAY
Dim Rx(8) As Byte
'TRANSMITT ARRAY
Dim Tx(8) As Byte
Dim Fifo(4) As Byte
Dim Rxcounter As Byte
Dim Ds18b20_integer_temp As Integer
Dim Ds18b20_single_temp As Single
Dim 1_wire_string As String * 7
Dim W As Word
dim adc_value as integer
dim adc_single as single



'---------Interfaces------------------------------------------------------------
Config Com1 = 57600 , Synchrone = 0 , Parity = None , Stopbits = 1 , Databits = 8 , Clockpol = 0

'Config SPI for RFM12 for ATMEGA328P
Config Spi = Hard , Interrupt = Off , Data Order = Msb , Master = Yes , Polarity = Low , Phase = 0 , Clockrate = 16 , Noss = 0 , Spiin = 0
Spiinit

'---------Ports-----------------------------------------------------------------
Config Portd.2 = Input
Nirq Alias Pind.2
'---------Interrupts------------------------------------------------------------
Config Int0 = Falling                             'PD2 = RFM12 Nirq
On Int0 Nirq_isr
Enable Int0

'---------ADC-------------------------------------------------------------------
'In order to measure the ARSSI Signal you need to solder a wire from RFM12B to an analog input of Jee Node
Config Adc = Single , Prescaler = Auto, reference = INTERNAL_1.1
'Voltage Reference = 1.1Volt
'Vin = (ADC_value * Vref)/1024 [V] = adc_value * 1.07421875 [mV]
Const Adc_factor = 1.07421875



'---------SUB functions---------------------------------------------------------
' Config Submode = New  is used !

'                                                  &H80E7
'  +---------+--------+                    +---------+---------+
'  | Cmd(1)  | Cmd(2) |     for Example    |    80   |   E7    |
'  +---------+--------+                    +---------+---------+
'By Value
Sub Rfm12b_cmd(byval Tmp As Word)
   Disable Int0
   Cmd(2) = Low(tmp)
   Cmd(1) = High(tmp)
   Spiout Cmd(1) , 2
   Enable Int0
End Sub

'                                                  &H80E7
'  +---------+--------+                    +---------+---------+
'  | Cmd(1)  | Cmd(2) |     for Example    |    80   |   E7    |
'  +---------+--------+                    +---------+---------+
'By Reference
Sub Rfm12b_cmd_ref(tmp As Word)
   Disable Int0
   Cmd(2) = Low(tmp)
   Cmd(1) = High(tmp)
   Spiout Cmd(1) , 2
   Enable Int0
End Sub


'  +---------+--------+
'  | &H00    |  &H00  |
'  +---------+--------+
Sub Rfm12b_read_status()
   Cmd(2) = &H00
   Cmd(1) = &H00
   Spiout Cmd(1) , 2                              'Write &H0000 to read status register
   Spiin Stat(1) , 2                              'Read the 2 Status Register Bytes
End Sub


'  +---------+--------+
'  | &HB8    |Sdi_Byte|
'  +---------+--------+
'By Reference
Sub Rfm12b_spi_send(sdi_byte As Byte)
   Disable Int0
   Bitwait Nirq , Reset
   Sdi(1) = Tramsmit_write_command                '&HB8
   Sdi(2) = Sdi_byte
   Spiout Sdi(1) , 2
   Enable Int0
End Sub

'  +---------+--------+
'  | &HB8    |Sdi_Byte|
'  +---------+--------+
'By Value
Sub Rfm12b_spi_send_val(byval Sdi_byte As Byte)
   Disable Int0
   Bitwait Nirq , Reset
   Sdi(1) = Tramsmit_write_command                '&HB8
   Sdi(2) = Sdi_byte
   Spiout Sdi(1) , 2
   Enable Int0
End Sub


Sub Rfm12_set_output_power(byval Out_power As Word)       '0 = Max output
    'Transmit Control Command [&H9850] = (Sign = Pos Frequency Shift, Deviation = 90KHz, Power Out = 0dB maximum
    Select Case Out_power
     Case 0 :
        Out_power = &H9850
      '  Print #1 , "Max Outut"                    ' Max output (-0dB)
     Case 1 :
        Out_power = &H9851
      '  Print #1 , "-3dB"                         '  (-3dB)
     Case 2 :
        Out_power = &H9852
      '  Print #1 , "-6dB"                         '  (-6dB)
     Case 3 :
        Out_power = &H9854
      '  Print #1 , "-12dB"                        '  (-12dB)
     Case 4 :
        Out_power = &H9855
     '   Print #1 , "-18dB"                        '  (-18dB)
     Case 5 :
        Out_power = &H9856
     '   Print #1 , "-21dB"                        '  (-21dB)
    End Select

    Call rfm12B_cmd(out_power)
End Sub


Function Rfm12_low_batt_value(byval Batt_val As Byte) As Word
    Select Case Batt_val
      Case 0 : Rfm12_low_batt_value = &HC005      '2.7 Volt  , 1MHz
      Case 1 : Rfm12_low_batt_value = &HC008      '3.0 Volt  , 1MHz
      Case 2 : Rfm12_low_batt_value = &HC00A      '3.2 Volt  , 1MHz
      Case 3 : Rfm12_low_batt_value = &HC00C      '3.4 Volt  , 1MHz
      Case Else : Rfm12_low_batt_value = &HC000   '2.2 Volt   , 1MHz
    End Select
End Function

'---------Constants-------------------------------------------------------------
Const Sensor_id = 20
'CONFIGURATION SETTING
Const Configuration_setting = &H80E7              '868MHz, 12pF, Enable TX Register, Enable Rx Fifo

'POWER MANAGEMENT
'To Decrease Tx / Rx Turnaround Time , It Is Possible To Leave The Baseband Section Powered On.
'Switching To Rx Mode Means Disabling The Pa And Enabling The Rf Frontend.
'Since the baseband block is already on, the internal startup calibration will not be performed, the turnaround time will be shorter.
'The synthesizer also has an internal startup calibration procedure. If quick RX/TX switching needed it may worth to leave this block on.
Const Enable_receiver = &H82D9
Const Enable_transmitter = &H8279

'FREQUENCY SETTING
Const Rfm12b_frequency = &HA7C0                   '869,92MHz
'BAUDRATE (DATARATE)
Const Baudrate = &HC647                           ' 4,789 kbps

'RECEIVER CONTROL
'optimal receiver baseband bandwidth (BW) and transmitter deviation frequency  settings:
' 2.4 kbs, 4.8kbs, 9.6 kbs or 19.2 kbs --> BW = 67KHz , Ffsk = 45KHz
Const Receiver_control = &H94C2
'DATA FILTER SETTING
' Clock recovery = Fast
' Clock recovery lock control = fast mode, fast attack and fast release (4 to 8-bit preamble (1010...) is recommended)
' Filter Type = Digital Filter
' The Data Quality Detector = 5
Const Data_filter = &HC2ED

'FIFO AND RESET MODE
' F3...F0 = FIFO IT level = 8  (Interrupt after 8 Bits in FIFO)
' sp = synchron pattern length = 2 Byte (High Byte = &H2D, Low Byte = &HD4)
' al = FIFO fill start condition at synchron pattern
' ff = FIFO enable
' dr = Disables the highly sensitive RESET mode

'   Bits of FIFO and Reset Mode Command
'   <-------- FIFO IT level------->
'  +-------+-------+-------+-------+-------+-------+-------+-------+
'  | F3    |  F2   |  F1   | F0    |   sp  |  al   |   ff  |  dr   |
'  +-------+-------+-------+-------+-------+-------+-------+-------+
Const Init_fifo = &HCA81
Const Enable_fifo = &HCA83

'AUTOMATIC FREQUENCY CONTROL (AFC)
'  +-------+-------+-------+-------+-------+-------+-------+-------+
'  | a1    |  a0   |  rl1  |  rl0  |   st  |  fi   |   oe  |  en   |
'  +-------+-------+-------+-------+-------+-------+-------+-------+
' as..a0 = Automatic operation mode selector --> (a1=0, a0=1) The circuit measures the frequency offset only once after power up
' rl1..rl0 = Range limit
' st = when st goes to high, the actual latest calculated frequency error is stored into the offset register of the AFC block.
' fi = Switches the circuit to high accuracy (fine) mode
' oe = Enables the frequency offset register
' en = Enables the calculation of the offset frequency by the AFC circuit
Const Auto_frequ_control = &HC483

'TX CONTROL
Const Tx_control = &H9820

'PLL SETTINGS
Const Pll_settings = &HCC77

Const Wakeup_timer = &HE000
Const Low_duty_cycle = &HC800
Const Dummy_byte = &HAA
Const Tramsmit_write_command = &HB8               'SPI TX command high byte
Const Rfm12_software_reset = &HFE00               'Software reset: Sending FE00h command to the chip triggers software reset. For more details see the Reset modes section.
Const Sleep_mode = &H8205                         'RFM12B SLEEP MODE
Const Ffit = 7                                    'FFIT Bit in Status Register

Sub Rfm12_init()
   Disable Int0
   Call Rfm12b_cmd(&H0000)                        'intitial SPI transfer added to avoid power-up problem
   W = Rfm12_low_batt_value(0)                    '0 = 2.7 Volt
   Call Rfm12b_cmd_ref(w)                         'Low Battery Detect @ 2.7 Volt , Clock from AVR = appx. 1 MHz
   Call Rfm12b_cmd(configuration_setting)         'Configuration Settings Command, 868MHz, 12pF, Enable TX Register, Enable Rx Fifo
   Call Rfm12b_cmd(enable_receiver)               'power management: enable receiver, disable clock output
   Call Rfm12b_cmd(rfm12b_frequency)              '869,92MHz
   Call Rfm12b_cmd(baudrate)                      'Datarate
   Call Rfm12b_cmd(receiver_control)              'Receiver Control Command
   Call Rfm12b_cmd(data_filter)                   'Data Filter Command
   Call Rfm12b_cmd(auto_frequ_control)            'AFC
   Call Rfm12b_cmd(tx_control)
   Call Rfm12b_cmd(pll_settings)
   Call Rfm12_set_output_power(0)                 'Transmit Control Command [&H9850] = (Sign = Pos Frequency Shift, Deviation = 90KHz, Power Out = 0dB maximum
   Call Rfm12b_cmd(wakeup_timer)                  'Wake Up Timer Command
   Call Rfm12b_cmd(low_duty_cycle)                'Low Duty Cycle Command
   Call Rfm12b_cmd(enable_fifo)                   'enable FIFO
   Enable Int0
End Sub




Sub Rfm12_send(byval Number_of_bytes As Byte)
     Local Count_ As Byte
      Disable Int0
      'TX, send Bytes
      Call Rfm12b_cmd(&H0000)                     'read status
      Call Rfm12b_cmd(enable_transmitter)         'Enable SENDER , DISABLE RECEIVER
      Call Rfm12b_spi_send_val(&Haa)              'Preamble
      Call Rfm12b_spi_send_val(&Haa)              'Preamble
      Call Rfm12b_spi_send_val(&H2d)              'SYNCHRON WORD (HIGH BYTE)   --> 'SYNCHRON PATTERN = 2 Byte = &H2DD4
      Call Rfm12b_spi_send_val(&Hd4)              'SYNCHRON WORD (LOW BYTE)
      '3 Bytes Data
      For Count_ = 1 To Number_of_bytes
        Call Rfm12b_spi_send(tx(count_))
      Next Count_
      'Dummy Bytes
      'send 2 dummy bytes to empty TX FIFO
      Call Rfm12b_spi_send_val(dummy_byte)        'DUMMY BYTE
      Call Rfm12b_spi_send_val(dummy_byte)        'DUMMY BYTE
      Call Rfm12b_cmd(enable_receiver)            'ENABLE RECEIVER, DISABLE TRANSMITTER
      Enable Int0
End Sub

Enable Interrupts

adc_value = getadc(0)       'Dummy measurement
'###############################################################################
Main_program:                                     'just a label
       Print "Start ID 20 -> Master"
       Reset Watchdog

       adc_value = getadc(0)
       adc_single = adc_value * adc_factor
       print "ARSSI=" ; fusing(adc_single, "#.#") ; " mV"

       Call Rfm12_init()                          'RFM12B Initilization

       adc_value = getadc(0)
       adc_single = adc_value * adc_factor
       print "ARSSI=" ; fusing(adc_single, "#.#") ; " mV"

      Do

         Reset Watchdog

         If Rxcounter = 8 Then                           'wait until 8 byte received
            Rxcounter = 0

            Call rfm12B_cmd(init_fifo)                'Init FIFO
            Call rfm12B_cmd(enable_fifo)              'enable FIFO

             'Print "Low Batt=" ; Stat(1).2 ; " DRSSI=" ; Stat(1).0 ; "-->   " ;
             'Print "DQD = " ; Stat(2).7 ; " --> " ;

             'ARSSI Signal
             adc_single = adc_value * adc_factor
             print "ARSSI=" ; fusing(adc_single, "#.#") ; " mV --> " ;


                                'In Rx(1) there is the Sensor ID
                    Select Case Rx(1)             'Sensor ID
                      Case 1:                             'Sensor 1

                         'There is a DS18B20 connected to Sensor 1 so we caluclate the temperature here
                         Ds18b20_integer_temp = Makeint(rx(2) , Rx(3))
                         Ds18b20_single_temp = Ds18b20_integer_temp * 0.0625
                         1_wire_string = Fusing(ds18b20_single_temp , "#.#")
                         Print "ID1= " ; 1_wire_string ; "  °C " ; "   Rx = " ; Rx(2) ; "/" ; Rx(3)

                      Case 2:                             'Sensor 2

                         'There is a DS18B20 connected to Sensor 2 so we caluclate the temperature here
                         Ds18b20_integer_temp = Makeint(rx(2) , Rx(3))
                         Ds18b20_single_temp = Ds18b20_integer_temp * 0.0625
                         1_wire_string = Fusing(ds18b20_single_temp , "#.#")
                         Print "ID2= " ; 1_wire_string ; "  °C " ; "   Rx = " ; Rx(2) ; "/" ; Rx(3)

                         'RFM12B Master Send back an Acknowledge to the Jee Node  (Send 2 Bytes)
                         Tx(1) = Sensor_id
                         Tx(2) = &B11111110       'Send Ack = 254
                         Call Rfm12_send(2)       'Send 2 Bytes

                      Case 3:                     'Sensor 3

                         Print "ID3= " ; Rx(2) ; "   Rx = " ; Rx(2) ; "/" ; Rx(3)

                         'RFM12B Master Send back an Acknowledge to the Jee Node  (Send 2 Bytes)
                         Tx(1) = Sensor_id
                         Tx(2) = &B00000010       'Send Ack = 2
                         Call Rfm12_send(2)       'Send 2 Bytes

                      Case 4:                     'Sensor 4

                         Print "ID4= " ; Rx(2) ; "   Rx = " ; Rx(2) ; "/" ; Rx(3)

                   End Select



        End If                                    'If Rxcounter = 8 Then

        If Nirq = 0 Then Gosub Nirq_isr           'This is to avoid RFM "hang-up's" due to bad RX quality

       Loop

End                                               'end program
'###############################################################################
'---------Interrupt Service Routines--------------------------------------------

'Nirq Is A General Interrupt. When An Nirq Interrupt Is Generated , It Can Be Caused By One Of The 4 Interrupts:

'1)   FFIT
'2)   FFOV
'3)   Wake-Up timer
'4)   Low battery detection

'To know which of the causes generated the interupt the first 4 bits of the Status Read Register must be read.
'FFIT is a specific interrupt for the FIFO.


'Rfm12b_status
'     15       14      13      12      11      10      9       8      7        6       5        4      3       2       1       0
'  +-------+-------+-------+-------+-------+-------+-------+-------+-------+-------+-------+-------+-------+-------+-------+-------+
'  | FFIT  | POR   |  FFOV | WKUP  | EXT   |  LBD  | FFEM  | RSSI  | DQD   |  CRL  | ATGL  | OFFS6 | OFFS3 | OFFS2 | OFFS1 | OFFS0 |
'  +-------+-------+-------+-------+-------+-------+-------+-------+-------+-------+-------+-------+-------+-------+-------+-------+
'  <-----------------------Stat(1)--------------------------------><----------------------Stat(2)---------------------------------->

Nirq_isr:
  If Nirq = 0 Then                                'check NIRQ is really low
     Call Rfm12b_read_status()                    'Read the RFM12B Status Register

    If Stat(1).ffit = 1 Then                      'Bit 7 is the FFIT Bit
     ' FFIT = The number of data bits in the RX FIFO has reached the pre-programmed limit (Can be cleared by any of the FIFO read methods)
       Incr Rxcounter
       Spiin Fifo(1) , 3
       Rx(rxcounter) = Fifo(3)
       if rxcounter = 1 then adc_value = getadc(0)
    End If
  End If

Return