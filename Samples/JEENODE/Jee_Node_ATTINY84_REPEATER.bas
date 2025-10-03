
' JEE NODE Micro V1 running at 8MHz internal, 3.3 Volt and Watchdog Timer DISABLED by fuse bit (WTDON)

' FUNCTION: REPEATER --> Wait on Data from Sensor ID 3 and send this data out again after  waiting

' The Universal Serial Interface (USI) is used in 3 wire mode to run the ATTINY84 as an SPI Master

' Thanks to Holli for his RFM12 code examples which was a starting point for this example


' SENSOR ID = 3
' Frequency = 869,92MHz
' Baudrate = 4,8 kbit

' PROTOCOL:

'       Preamble        syncword                 Data Bytes
'  +-------+-------+-------+-------+-------+-------+...+-------+-------+
'  | &HAA  | &HAA  | &H2D  | &HDH  |  ID   | Byte0 |   | Byte6 |  CRC  |
'  +-------+-------+-------+-------+-------+-------+...+-------+-------+


'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
' --> Follow Regulations  !!!
' --> http://www.erodocdb.dk/Docs/doc98/official/pdf/CEPTREP038.PDF
' --> http://www.bundesnetzagentur.de/cae/servlet/contentblob/38206/publicationFile/2580/ShortRangeDevicesSRD_ID17299pdf.pdf
'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


$regfile = "attiny84.dat"
$crystal = 8000000                                '8MHz (internal RC)
$hwstack = 80
$swstack = 80
$framesize = 100

Config Watchdog = 512
Start Watchdog

Config Submode = New                              'there is no need to DECLARE a sub/function before you call it but....(see helpfile)
'---------Constants-------------------------------------------------------------
Const Yes = 1
Const No = 0
Const Sensor_id = 3
Const Enable_debug_output = Yes

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
Const Receiver_control = &H94A1
'DATA FILTER SETTING
' Clock recovery = Fast
' Clock recovery lock control = fast mode, fast attack and fast release (4 to 8-bit preamble (1010...) is recommended)
' Filter Type = Digital Filter
' The Data Quality Detector = 5
Const Data_filter = &HC2AC

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

Const Low_battery_detect_clock = &HC0C0
Const Wakeup_timer = &HE000
Const Low_duty_cycle = &HC800

Const Dummy_byte = &HAA
Const Tramsmit_write_command = &HB8               'SPI TX command high byte
Const Rfm12_software_reset = &HFE00               'Software reset: Sending FE00h command to the chip triggers software reset. For more details see the Reset modes section.
Const Sleep_mode = &H8205                         'RFM12B SLEEP MODE
'---------Variables-------------------------------------------------------------
Dim Count As Byte
Dim Temp As Byte
Dim Cmd(2) As Byte
Dim Sdi(2) As Byte
Dim Stat(2) As Byte                               'Array for Status Register Bytes
Dim Rfm12b_status As Word
'RECEIVE ARRAY
Dim Rx(8) As Byte
'TRANSMITT ARRAY
Dim Tx(8) As Byte
Dim Fifo(4) As Byte
Dim Rxcounter As Byte
Dim W As Word
Dim Second_tick As Bit
Dim Test As Byte
Dim Rfm12b_data_ready As Bit

Dim Ds18b20_integer_temp As Integer
Dim Ds18b20_single_temp As Single

'---------Interfaces------------------------------------------------------------
#if Enable_debug_output = Yes
 'Open a TRANSMIT channel for output
  Open "coma.3:19200,8,n,1" For Output As #1
#endif

'---------Using ATTINY as SPI MASTER over USI-----------------------------------
Config Porta.4 = Output                           'USCK ----> SCK (RFM12B)
Config Porta.5 = Output                           'DO   ----> SDI (RFM12B)
Config Porta.6 = Input                            'DI   ----> SDO (RFM12B)
Set Porta.6                                       'Pullup

Config Portb.2 = Input                            'INT0 = Portb.2 with an ATTINY84 -----> iRQ (RFM12B)
Nirq Alias Pinb.2

Config Portb.1 = Output                           'Slave Select (SS) ----> SEL (RFM12B)
Set Portb.1
Sel Alias Portb.1

Set Usicr.usiwm0                                  'Three-wire mode. Uses DO, DI, and USCK pins.

'The Data Output (DO) pin overrides the corresponding bit in the PORTA
'register. However, the corresponding DDRA bit still controls the data direction.
'When the port pin is set as input the pin pull-up is controlled by the PORTA bit.
'The Data Input (DI) and Serial Clock (USCK) pins do not affect the normal port
'operation. When operating as master, clock pulses are software generated by
'toggling the PORTA register, while the data direction is set to output. The
'USITC bit in the USICR Register can be used for this purpose.

Const Usi_clk_low = &B0001_0001
Const Usi_clk_high = &B0001_0011

'Wirte or read a byte over USI in SPI Master Mode
Function Usi_byte(usi_out As Byte) As Byte
    Local I As Byte
     Usidr = Usi_out                              'Byte to write over USI
       For I = 1 To 8
          Usicr = Usi_clk_low                     'Toggle the USI Clock to send or receive the single bits over USI
          Usicr = Usi_clk_high
       Next
    Usi_byte = Usidr                              'Byte received over USI
End Function


'---------Ports-----------------------------------------------------------------

Config Int0 = Falling                             'PD2 = RFM12 Nirq
On Int0 Nirq_isr
Enable Int0

'---------SUB functions---------------------------------------------------------
' Config Submode = New  is used !

'                                                  &H80E7
'  +---------+--------+                    +---------+---------+
'  | Cmd(1)  | Cmd(2) |     for Example    |    80   |   E7    |
'  +---------+--------+                    +---------+---------+
'By Value
Sub Rfm12b_cmd(byval Tmp As Word)
   Local Usi_return As Byte
   Disable Interrupts
   Cmd(2) = Low(tmp)
   Cmd(1) = High(tmp)
   Reset Sel
   Usi_return = Usi_byte(cmd(1))
   Usi_return = Usi_byte(cmd(2))
   Set Sel
   Enable Interrupts
End Sub

'                                                  &H80E7
'  +---------+--------+                    +---------+---------+
'  | Cmd(1)  | Cmd(2) |     for Example    |    80   |   E7    |
'  +---------+--------+                    +---------+---------+
'By Reference
Sub Rfm12b_cmd_ref(tmp As Word)
   Local Usi_return As Byte
   Disable Interrupts
   Cmd(2) = Low(tmp)
   Cmd(1) = High(tmp)
   Reset Sel
   Usi_return = Usi_byte(cmd(1))
   Usi_return = Usi_byte(cmd(2))
   Set Sel
   Enable Interrupts
End Sub


'  +---------+--------+
'  | &H00    |  &H00  |
'  +---------+--------+
'Wirte or read a byte over USI in SPI Master Mode
Function Rfm12b_read_status(byval Usi_w_out As Word) As Word
    Local I As Byte , Usi_ret As Byte , Low_byte As Byte , High_byte As Byte
    Low_byte = Low(usi_w_out)
    High_byte = High(usi_w_out)
    Disable Interrupts

       Reset Sel                                  'slave select
       'send 2 Bytes
       Usidr = Low_byte                           'Byte to write over USI
       For I = 1 To 8
          Usicr = Usi_clk_low                     'Toggle the USI Clock to send or receive the single bits over USI
          Usicr = Usi_clk_high
       Next

       Usidr = High_byte                          'Byte to write over USI
       For I = 1 To 8
          Usicr = Usi_clk_low                     'Toggle the USI Clock to send or receive the single bits over USI
          Usicr = Usi_clk_high
       Next
       Set Sel


       Reset Sel
       'receive 2 Bytes
        Usidr = 0

       For I = 1 To 8
          Usicr = Usi_clk_low                     'Toggle the USI Clock to send or receive the single bits over USI
          Usicr = Usi_clk_high
       Next

      High_byte = Usidr                           'Byte received over USI

      For I = 1 To 8
          Usicr = Usi_clk_low                     'Toggle the USI Clock to send or receive the single bits over USI
          Usicr = Usi_clk_high
       Next
      Set Sel
      Low_byte = Usidr                            'Byte received over USI

      Rfm12b_read_status = Makeint(low_byte , High_byte)
      Enable Interrupts
End Function




'  +---------+--------+
'  | &HB8    |Sdi_Byte|
'  +---------+--------+
'By Reference
Sub Rfm12b_spi_send(sdi_byte As Byte)
  Local Usi_return As Byte , I As Byte
   Disable Interrupts
   Bitwait Nirq , Reset
   Sdi(1) = Tramsmit_write_command                '&HB8
   Sdi(2) = Sdi_byte
   Reset Sel
   Usi_return = Usi_byte(sdi(1))
   Usi_return = Usi_byte(sdi(2))
   Set Sel
   Enable Interrupts
End Sub

'  +---------+--------+
'  | &HB8    |Sdi_Byte|
'  +---------+--------+
'By Value
Sub Rfm12b_spi_send_val(byval Sdi_byte As Byte)
   Local Usi_return As Byte , I As Byte
   Disable Interrupts
   Bitwait Nirq , Reset
   Sdi(1) = Tramsmit_write_command                '&HB8
   Sdi(2) = Sdi_byte
   Reset Sel
   Usi_return = Usi_byte(sdi(1))
   Usi_return = Usi_byte(sdi(2))
   Set Sel
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

    Call Rfm12b_cmd_ref(out_power)
End Sub



Sub Rfm12_init()
   Disable Interrupts
   Call Rfm12b_cmd(&H0000)                        'intitial SPI transfer added to avoid power-up problem
   Call Rfm12b_cmd(low_battery_detect_clock)      'Low Battery Detect and Clock from AVR
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
   Enable Interrupts
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



Sub Power_reduction()
 'Brown-out Detector is disabled by fuse bit setting
 Prr = &B0000_0101                                'Power Reduction Register
 'Bit0 = 1 --> Power Reduction ADC
 'Bit1 = 0 --> NO Power Reduction USI
 'Bit2 = 1 --> Power Reduction Timer/Counter0
 'Bit3 = 0 --> NO Power Reduction Timer/Counter1
End Sub


Main_program:                                     'just a label
  Print #1 , "Jee Node Micro, ATTINY84 Rx/Tx over USI Node"
  Reset Watchdog
  Enable Interrupts

  Call Power_reduction()                          'Switch of unused parts

  Call Rfm12_init()                               'initialize RFM12B



Do

  Reset Watchdog


  If Rfm12b_data_ready = 1 Then
     Reset Rfm12b_data_ready

      'REPEAT THE OUTPUT OF SENSOR ID 3
     If Rx(1) = 3 Then                            'Repeat the output of Sensor ID 3
          Waitms 100                              'Wait a bit

           Rfm12b_status = Rfm12b_read_status(&H0000)
         ' Print #1 , "> " ; Rfm12b_status.8             'Check RSSI Bit
          'You could use this to check RSSI Bit before sending

           Tx(1) = Rx(1)                          'Sensor ID
           Tx(2) = Rx(2)                          'Testbyte which we will print in the RFM12B Master
           Tx(3) = Rx(3)
           Tx(4) = Rx(4)
           Tx(5) = Rx(5)
           Tx(6) = Rx(6)
           Tx(7) = Rx(7)
           Tx(8) = Rx(8)

           Call Rfm12_send(8)                              'Send 8 Bytes over RFM12B
     End If
  End If


 If Nirq = 0 Then Gosub Nirq_isr                  'This is to avoid RFM "hang-up's" due to bad RX quality
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

Nirq_isr:
  If Nirq = 0 Then                                'check NIRQ is really low
       Rfm12b_status = Rfm12b_read_status(&H0000)

       If Rfm12b_status.15 = 1 Then               'check if it is a FFIT Interrupt
                       Incr Rxcounter

                       Reset Sel                                  'Slave Select
                       Fifo(1) = Usi_byte(count)
                       Fifo(2) = Usi_byte(count)
                       Fifo(3) = Usi_byte(count)
                       Set Sel

                       Rx(rxcounter) = Fifo(3)

                       If Rxcounter = 8 Then      'We wait here for 8 Bytes to be received
                           Rxcounter = 0
                           Set Rfm12b_data_ready
                           Call Rfm12b_cmd(&H0000)
                           Call Rfm12b_cmd(init_fifo)                'init FIFO
                           Call Rfm12b_cmd(enable_fifo)           'enable FIFO
                       End If
        End If

  End If
Return

