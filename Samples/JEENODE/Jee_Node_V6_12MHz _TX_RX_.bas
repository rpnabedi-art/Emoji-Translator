
' JEE NODE V6 running at 12MHz external, 3.3 Volt, Watchdog (WDTON) Fuse Bit enabled
' http://jeelabs.net/projects/hardware/wiki/JeeNode

' FUNCTION: RFM12B Slave: Send 8 Bytes every 8 Seconds and acknowledge from Master

' Thanks to Holli for his RFM12 code examples which was a starting point for this example


' SENSOR ID = 2
' Frequency = 869,92MHz
' Baudrate = 4,8 kbit



' This example is enabling the Low Battery Detection in RFM12B to test this feature
' (We set the Battery Detector to 3.4V to test the Low Battery Detector  (just for testing))


'PROTOCOL:

'       Preamble        syncword                 Data Bytes
'  +-------+-------+-------+-------+-------+-------+...+-------+-------+
'  | &HAA  | &HAA  | &H2D  | &HDH  |  ID   | Byte0 |   | Byte6 |  CRC  |
'  +-------+-------+-------+-------+-------+-------+...+-------+-------+
'  <-Byte->




'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
' --> Follow Regulations  !!!
' --> In Europe:
' --> http://www.erodocdb.dk/Docs/doc98/official/pdf/CEPTREP038.PDF
' --> http://www.bundesnetzagentur.de/cae/servlet/contentblob/38206/publicationFile/2580/ShortRangeDevicesSRD_ID17299pdf.pdf
'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++





$regfile = "m328pdef.dat"
$crystal = 12000000                               '12MHz
$hwstack = 70
$swstack = 70
$framesize = 160

'$noramclear
Config Submode = New


Config Watchdog = 512                             '512ms
Start Watchdog

Config Com1 = 19200 , Synchrone = 0 , Parity = None , Stopbits = 1 , Databits = 8 , Clockpol = 0
'---------Constants-------------------------------------------------------------
Const Hard = 1
Const Soft = 0
Const Spi_mode = Hard


Const Sensor_id = 2

'CONFIGURATION SETTING
Const Configuration_setting = &H80E7              '868MHz, 12pF, Enable TX Register, Enable Rx Fifo

'POWER MANAGEMENT
'To Decrease Tx / Rx Turnaround Time , It Is Possible To Leave The Baseband Section Powered On.
'Switching To Rx Mode Means Disabling The Pa And Enabling The Rf Frontend.
'Since the baseband block is already on, the internal startup calibration will not be performed, the turnaround time will be shorter.
'The synthesizer also has an internal startup calibration procedure. If quick RX/TX switching needed it may worth to leave this block on.
Const Enable_receiver = &H82DD                    'Also Enable Low Battery Detector
Const Enable_transmitter = &H827D                 'Also Enable Low Battery Detector

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
Dim Abort As Bit : Reset Abort
Dim Ds18b20_integer_temp As Integer
Dim Ds18b20_single_temp As Single
Dim 1_wire_string As String * 7
Dim Crc8_value As Byte
Dim Ds18b20_scratchpad(9) As Byte
Dim 1_wire_sensor_id(8) As Byte
Dim Number_of_1_wire_devices As Word
Dim 1_wire_toggle As Bit : Reset 1_wire_toggle
Dim Send_byte As Byte
Dim Four_second_tick As Bit : Four_second_tick = 0
Dim W As Word
Dim Rfm12b_data_ready As Bit



'---------Interfaces------------------------------------------------------------
'Config SPI for RFM12
#if Spi_mode = Hard
    Config Spi = Hard , Interrupt = Off , Data Order = Msb , Master = Yes , Polarity = Low , Phase = 0 , Clockrate = 16 , Noss = 0 , Spiin = 0
#else
    Config Spi = Soft , Din = Pinb.4 , Dout = Portb.3 , Ss = Portb.2 , Clock = Portb.5       'ATMEGA328P
#endif
Spiinit

'1-Wire interface
1_wire_pin Alias Portc.0                          'PIN for 1-Wire
Config 1wire = 1_wire_pin                       'use this pin
Number_of_1_wire_devices = 1wirecount()
'Print "Number_of_1_wire_devices = " ; Number_of_1_wire_devices
1_wire_sensor_id(1) = 1wsearchfirst()
'Print "ROM = " ; Sensor_id(1) ; "." ; Sensor_id(2) ; "." ; Sensor_id(3) ; "." ; Sensor_id(4) ; "." ; Sensor_id(5) ; "." ; Sensor_id(6) ; "." ; Sensor_id(7) ; "." ; Sensor_id(8)

'---------Ports-----------------------------------------------------------------
Config Portd.2 = Input
Nirq Alias Pind.2

Config Int0 = Falling                             'PD2 = RFM12 Nirq
On Int0 Nirq_isr
Enable Int0

'---------Timer-----------------------------------------------------------------
Config Timer1 = Timer , Prescale = 1024
On Timer1 Timer_irq
Const Timer_preload = 18661                       '4 second tick at 12MHz clock
Enable Timer1

'---------SUB functions---------------------------------------------------------
' Config Submode = New  is used !

'                                                  &H80E7
'  +---------+--------+                    +---------+---------+
'  | Cmd(1)  | Cmd(2) |     for Example    |    80   |   E7    |
'  +---------+--------+                    +---------+---------+
'By Value
Sub Rfm12b_cmd(byval Tmp As Word)
   Cmd(2) = Low(tmp)
   Cmd(1) = High(tmp)
   Spiout Cmd(1) , 2
End Sub

'                                                  &H80E7
'  +---------+--------+                    +---------+---------+
'  | Cmd(1)  | Cmd(2) |     for Example    |    80   |   E7    |
'  +---------+--------+                    +---------+---------+
'By Reference
Sub rfm12B_cmd_ref(tmp As Word)
   Cmd(2) = Low(tmp)
   Cmd(1) = High(tmp)
   Spiout Cmd(1) , 2
End Sub


'  +---------+--------+
'  | &H00    |  &H00  |
'  +---------+--------+
Sub Rfm12b_read_status()
   Disable Interrupts
   Cmd(2) = &H00
   Cmd(1) = &H00
   Spiout Cmd(1) , 2                              'Write &H0000 to read status register
   Spiin Stat(1) , 2                              'Read the 2 Status Register Bytes
   Enable Interrupts
End Sub


'  +---------+--------+
'  | &HB8    |Sdi_Byte|
'  +---------+--------+
'By Reference
Sub Rfm12b_spi_send(sdi_byte As Byte)
   Disable Interrupts
   Bitwait Nirq , Reset
   Sdi(1) = Tramsmit_write_command                '&HB8
   Sdi(2) = Sdi_byte
   Spiout Sdi(1) , 2
   Enable Interrupts
End Sub

'  +---------+--------+
'  | &HB8    |Sdi_Byte|
'  +---------+--------+
'By Value
Sub Rfm12b_spi_send_val(byval Sdi_byte As Byte)
   Disable Interrupts
   Bitwait Nirq , Reset
   Sdi(1) = Tramsmit_write_command                '&HB8
   Sdi(2) = Sdi_byte
   Spiout Sdi(1) , 2
   Enable Interrupts
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


Sub Rfm12_init()

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

End Sub


Sub Rfm12_send(byval Number_of_bytes As Byte)
     Local Count_ As Byte
      Disable interrupts
      'TX, send Bytes
      Call rfm12B_cmd(&H0000)                         'read status
      Call rfm12B_cmd(enable_transmitter)             'Enable SENDER , DISABLE RECEIVER
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
      Call rfm12B_cmd(enable_receiver)                'ENABLE RECEIVER, DISABLE TRANSMITTER
      Enable Interrupts
End Sub

Enable Interrupts



Main_programm:                                    'just a label

        Reset Watchdog
        Print "---Start Sensor ID = " ; Sensor_id ; " ---"

         Call Rfm12_init()


   Do
         Reset Watchdog






     If Rfm12b_data_ready = 1 Then
        Reset Rfm12b_data_ready

         If Rx(1) = 20 Then                       'Sensor ID from Master  = 20
           Print "Rx(2)=" ; Rx(2)
           Print "Low Batt=" ; Stat(1).2          '; " DRSSI=" ; Stat(1).0       'Byte sent from Master
        End If



     End If



         If Four_second_tick = 1 Then
             Four_second_tick = 0
             '------------------------------------------------------------------
             'Low battery detect, the power supply voltage is below the pre-programmed limit
             'Bit Nr 2 of Stat(1) is the Low Battery Flag

             'Now we set the Battery Detector to 3.4V to test the Low Battery Detector  (just for testing)
              W = Rfm12_low_batt_value(3)         '3 = 3.4V
              Call Rfm12b_cmd_ref(w)              'Low Battery Detect, Clock from AVR = appx. 1 MHz
              '------------------------------------------------------------------
             Toggle 1_wire_toggle                 'toggle between 1-wire convert command and read scratchpad

          If 1_wire_toggle = 0 Then
            1wreset                               'reset the device
            1wwrite &H55                          'skip ROM command
            1wwrite 1_wire_sensor_id(1) , 8       'write ROM Code of Unit
            1wwrite &H44                          'convert command

          Else



            1wreset                               'reset the device
            1wwrite &H55                          'skip ROM command
            1wwrite 1_wire_sensor_id(1) , 8       'write ROM Code of Unit
            1wwrite &HBE                          'read scratchpad
            Ds18b20_scratchpad(1) = 1wread(9)     'Read 9 Data-Bytes

            Crc8_value = Crc8(ds18b20_scratchpad(1) , 8)

             If Crc8_value = Ds18b20_scratchpad(9) Then       'Passt CRC8 ?
               Tx(2) = Ds18b20_scratchpad(1)                 'Nur wenn CRC8 passt !
               Tx(3) = Ds18b20_scratchpad(2)                 'Nur wenn CRC8 passt !

               Ds18b20_integer_temp = Makeint(ds18b20_scratchpad(1) , Ds18b20_scratchpad(2))
               Ds18b20_single_temp = Ds18b20_integer_temp * 0.0625
               Print Fusing(ds18b20_single_temp , "##.#") ; " °C"

               '---------------RFM12----DATA-----------
               Tx(1) = Sensor_id                      'Sensor ID
               'Tx(2) 1 -wire Sensor
               'Tx(3) 1 -wire Sensor
               Tx(4) = 0
               Tx(5) = 0
               Tx(6) = 0
               Tx(7) = 0
               Tx(8) = Crc8(tx(1) , 7)            'CRC8 der 7 Bytes



               'Send 8 Bytes
               Call Rfm12_send(8)                 'Send 8 Bytes

              End If
           End If
         End If

         If Nirq = 0 Then Gosub Nirq_isr           'This is to avoid RFM "hang-up's" due to bad RX quality
     Loop

End                                               'end program

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
'     7                                                         0     7                                                        0
'  <-----------------------Stat(1)--------------------------------><----------------------Stat(2)---------------------------------->

Nirq_isr:
  If Nirq = 0 Then                                'check NIRQ is really low
    Call Rfm12b_read_status()                     'Read the RFM12B Status Register

    If Stat(1).ffit = 1 Then                      'Bit 7 is the FFIT Bit
     ' FFIT = The number of data bits in the RX FIFO has reached the pre-programmed limit (Can be cleared by any of the FIFO read methods)
       Incr Rxcounter
       Spiin Fifo(1) , 3
       Rx(rxcounter) = Fifo(3)

       If Rxcounter = 2 Then                           'we wait for 2 Bytes
           Rxcounter = 0
           Set Rfm12b_data_ready
           'Clear FIFO
           Call Rfm12b_cmd(init_fifo)             'init FIFO
           Call Rfm12b_cmd(enable_fifo)           'enable FIFO
       End If
    End If
  End If

Return

Timer_irq:
    Timer1 = Timer_preload                        '4 second tick at 12MHz clock
    Set Four_second_tick
Return