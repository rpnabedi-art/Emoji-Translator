
' JEE NODE Micro V1 running at 8MHz internal, 3.3 Volt

' FUNCTION: Send 8 Bytes every 8 seconds and go to Power Down Mode for 8 Seconds until the Watchdog wake up the Attiny84....

' The Universal Serial Interface (USI) is used in 3 wire mode to run the ATTINY84 as an SPI Master

' Thanks to Holli for his RFM12 code examples which was a starting point for this example

' In Power Down Mode I measured 5µA for the Jee Node micro (attiny84 + RFM12B)
' Which matches the values in data sheet: ATTINY84 WDT enabled, VCC = 3V --> 4.5µA
' Plus the 0.3µA from RFM12B in PowerDown = app. 5 µA



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
' --> In Europe:
' --> http://www.erodocdb.dk/Docs/doc98/official/pdf/CEPTREP038.PDF
' --> http://www.bundesnetzagentur.de/cae/servlet/contentblob/38206/publicationFile/2580/ShortRangeDevicesSRD_ID17299pdf.pdf
'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


$regfile = "attiny84.dat"
$crystal = 8000000                                '8MHz (internal RC)
$hwstack = 80
$swstack = 80
$framesize = 120

$noramclear

Config Watchdog = 8192                            '8 Second
Start Watchdog

Config Submode = New                              'there is no need to DECLARE a sub/function before you call it but....(see helpfile)
'---------Constants-------------------------------------------------------------
Const Yes = 1
Const No = 0
Const Sensor_id = 4

'++++++++++++++++++++++++++++++++
Const Enable_debug_output = Yes
'++++++++++++++++++++++++++++++++


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
Const Ffit = 7                                    'FFIT Bit in Status Register
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
Dim Test As Byte


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
   Call Rfm12b_cmd(&H0000)                        'intitial SPI transfer added to avoid power-up problem
   Enable Interrupts
End Sub


Sub Rfm12_send(byval Number_of_bytes As Byte)
     Local Count_ As Byte
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
End Sub



Sub Power_reduction(byval Reduction As Byte)
 'Brown-out Detector is disabled by fuse bit setting
 If Reduction = 0 Then
    Prr = &B0000_0101                                'Power Reduction Register
    'Bit0 = 1 --> Power Reduction ADC
    'Bit1 = 0 --> NO Power Reduction USI
    'Bit2 = 1 --> Power Reduction Timer/Counter0
    'Bit3 = 0 --> NO Power Reduction Timer/Counter1
 Else
     Prr = &B0000_1111                            'SWITCH OFF ALL PARTS
     'DIDR0  Digital Input Disable Register 0
     Didr0 = &B00000110                           'When this bit is written logic one, the digital input buffer on the AIN1/0 pin is disabled.
     'Disable ADC
     Reset Adcsra.7                               'By writing it to zero, the ADC is turned off.
     'Disable Analog Comparator
     Set Acsr.7                                   'When this bit is written logic one, the power to the Analog Comparator is switched off.

     'NOW we set all Pin to a defined level with Pullup
     Config Porta.0 = input
     Set Porta.0
     Config Porta.1 = input
     Set Porta.1
     Config Porta.2 = input
     Set Porta.2
     Config Porta.3 = input                      'debug input
     Set Porta.3
     Config Porta.4 = input                       'USCK ----> SCK (RFM12B)
     Set Porta.4
     Config Porta.5 = input                       'DO   ----> SDI (RFM12B)
     Set Porta.5
     Config Porta.6 = input                       'DI   ----> SDO (RFM12B)
     Set Porta.6                                  'Pullup
     Config Porta.7 = input
     Set Porta.7
     Config Portb.0 = input
     Set Portb.0
     Config Portb.1 = input                       'Slave Select (SS) ----> SEL (RFM12B)
     Set Portb.1
     Config Portb.2 = input                       'INT0 = Portb.2 with an ATTINY84 -----> iRQ (RFM12B)
     Set Portb.2
     Config Portb.3 = input
     'Portb.3 = RESET
 End If

End Sub


Main_program:                                     'just a label

  Call Rfm12_init()                               'initialize RFM12B

  Call Power_reduction(0)                         'Switch of unused parts

  #if Enable_debug_output = Yes
       Print #1 , "Jee Node Micro, ATTINY84 Tx --> Power Down"
  #endif




  Reset Watchdog

  Incr Test                                       'will be incremented because of $noramclear

  #if Enable_debug_output = Yes
       Print #1 , "Test= " ; Test
  #endif

  Tx(1) = 3                                       'Sensor ID
  Tx(2) = Test                                    'Testbyte which we will print in the RFM12B Master
  Tx(3) = 0
  Tx(4) = 0
  Tx(5) = 0
  Tx(6) = 0
  Tx(7) = 0
  Tx(8) = Crc8(tx(1) , 7)                         'Cyclic Redundancy Check

 Call Rfm12_send(8)                               'Send 8 Bytes over RFM12B

 'Power Management Command = &H8201 (disable Tx, disable Rx, disable Base Band Block , disable synthesizer , disable osc , disable Low Batt detector, disable wake-up timer
 Call Rfm12b_cmd(&H8201)                          'RFM12B SLEEP MODE
 Call Power_reduction(1)
 Enable Interrupts
 '----------------
 Power Powerdown
 '----------------
 'Wakeup over Watchdog timeout after 8 Seconds
End                                               'end program

