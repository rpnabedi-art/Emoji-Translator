$nocompile

'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
'  +
'  + File NAME      rfm23b_functions.inc
'  +
'  + DESCRIPTION:   SUB and FUNCTIONS for RFM23B
'  +
'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
'  +
'  + SUB NAME: Rf23b_write(byval Addr As Byte , Byval Value As Byte)
'  +
'  + DESCRIPTION:   This sub writes a byte to RFM23B registers
'  +
'  + INPUT:         Register Address and Value to write
'  +
'  + RETURN:        None
'  +
'  + NOTES:         None
'  +
'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

' Rf23b_write
'     15       14      13      12      11      10      9       8      7        6       5        4      3       2       1       0
'  +-------+-------+-------+-------+-------+-------+-------+-------+-------+-------+-------+-------+-------+-------+-------+-------+
'  |  R/W  |  A6   |   A5  |  A4   |  A3   |   A2  |  A1   |  A0   |  D7   |   D6  |   D5  |   D4  |   D3  |  D2   |   D1  |  D0   |
'  +-------+-------+-------+-------+-------+-------+-------+-------+-------+-------+-------+-------+-------+-------+-------+-------+
'  <-----------------------Address--------------------------------><---------------------Data Value-------------------------------->

Sub Rf23b_write(byval Addr As Byte , Byval Value As Byte)
   Reset Nsel                                     ' RFM23B Slave Select
   Set Addr.7                                     'Set write bit
   Spiout Addr , 1                                ' Write Address
   Spiout Value , 1                               ' Write Data Byte
   Set Nsel
End Sub

'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
'  +
'  + SUB NAME:      Rf23b_write_value_by_ref(byval Addr As Byte , Value As Byte)
'  +
'  + DESCRIPTION:   Write a Byte to a RFM23B Register Adress BY REFERENCE
'  +
'  + INPUT:         Register Address and Value (BY REFERENCE) to write
'  +
'  + RETURN:        None
'  +
'  + NOTES:         None
'  +
'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
Sub Rf23b_write_value_by_ref(byval Addr As Byte , Byref Value As Byte)
   Reset Nsel                                     ' RFM23B Slave Select
   Set Addr.7                                     'Set write bit
   Spiout Addr , 1                                ' Write Address
   Spiout Value , 1                               ' Write Data Byte
   Set Nsel
End Sub

'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
'  +
'  + FUNCTION NAME: Rf23b_read(byval Address As Byte) As Byte
'  +
'  + DESCRIPTION:   Read a Register Byte from RFM23B
'  +
'  + INPUT:         Register Address
'  +
'  + RETURN:        Value (the register content)
'  +
'  + NOTES:         None
'  +
'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
Function Rf23b_read(byval Address As Byte) As Byte
   Reset Nsel
   Spiout Address , 1                             'write register address
   Spiin Rf23b_read , 1                           'store register value in Rf23b_read
   Set Nsel
End Function

'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
'  +
'  + SUB NAME:      Rf23b_fifo_burst_read(length As Byte)
'  +
'  + DESCRIPTION:   BURST Read several Register of RFM23B
'  +                The address of the register will be sent only once.
'  +
'  + INPUT:         length (BY REFERENCE)
'  +                fifo_pointer (BY REF). e.g. fifo_pointer = 1, length = 32 --> Rx(1).....Rx(32)
'  + RETURN:        The RFM23B will return Bytes until the chip select (nSEL) goes High
'  +
'  + NOTES:         None
'  +               33 , 32            fifo_pointer = 1 + 32 = 33 + 32 = 65 + 32 = 97
'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
Sub Rf23b_fifo_burst_read(fifo__pointer As Byte , Length As Byte)
   Local X As Byte , Y As Byte
   X = Fifo_access                                'Address for FIFO read
   Y = Fifo__pointer                              'Start value to fill the Rx() Array
   Length = Fifo__pointer + Length
   Length = Length - 1                            'Rx(1) ....Rx(32)   next is   Rx(33) ...Rx(64)  next is  Rx(65) ....Rx(96)
   Reset Nsel
   Spiout X , 1                                   'write fifo register address only once
    For X = Y To Length
       Spiin Rx(x) , 1                            'Read the FIFO in burst mode
    Next
   Set Nsel
End Sub

'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
'  +
'  + SUB NAME:      Rf23b_int_burst_read(length As Byte)
'  +
'  + DESCRIPTION:   BURST Read of interrupt status register 1 and 2
'  +                The address of the register will be sent only once.
'  +
'  + INPUT:         None
'  +
'  + RETURN:        The RFM23B will return the contenct of interrupt status register as a word
'  +                Low Byte = Interrupt Status Register 1
'  +                High Byte = Interrupt Status Register 2
'  +
'  + NOTES:         None
'  +
'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
Function Rf23b_int_burst_read() As Word
   Local X As Byte , Stat_1 As Byte , Stat_2 As Byte
   X = Interrupt_status_1                         'Address of interrupt status register 1
   Reset Nsel
   Spiout X , 1                                   'write fifo register address only once
   Spiin Stat_1 , 1                               'Read the interrupt status register 1
   Spiin Stat_2 , 1                               'Read the interrupt status register 2
   Set Nsel
   Rf23b_int_burst_read = Makeint(stat_1 , Stat_2)
End Function

'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
'  +
'  + SUB NAME:      Rf23b_fifo_burst_write(byval Length As Byte)
'  +
'  + DESCRIPTION:   BURST Write several Register of RFM23B
'  +                The address of the register will be sent only once.
'  +                Then you can send bytes until (nSEL) goes high
'  + INPUT:         Start value of the Tx() Array and how much bytes should be written
'  +                e.g.: start_at = 1 and length = 64 then it write to FIFO Tx(1)......Tx(64)
'  +                e.g.: start_at = 65 and length = 32 then it write to FIFO Tx(65)......Tx(96)
'  + RETURN:        None
'  +
'  + NOTES:         None
'  +
'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
Sub Rf23b_fifo_burst_write(byval Start_at As Byte , Byval Length As Byte)
   Local X As Byte , Y As Byte
   X = Fifo_access

   If Start_at = 1 Then Y = Length                'Tx(1) ....Tx(64)  -->  Tx(65) .....Tx(96)

   If Start_at > 1 Then
      Y = Start_at + Length                       '65 + 32 = 97 - 1 = 96   .....
      Y = Y - 1
   End If

   Set X.7                                        'Set write bit
   Reset Nsel
   Spiout X , 1                                   'write fifo register address only once
    For X = Start_at To Y
       Spiout Tx(x) , 1                           'Read the FIFO in burst mode
    Next
   Set Nsel
End Sub

'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
'  +
'  + FUNCTION NAME: Rf23b_read_temp_sensor(byval Temp_sensor_range As Byte) As Byte
'  +
'  + DESCRIPTION:   Read the internal temperatur sensor value
'  +
'  + INPUT:         Temperatur Sensor Range
'  +
'  + RETURN:        ADC Value (the register content)
'  +
'  + NOTES:         None
'  +
'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
Function Rf23b_read_temp_sensor(byval Temp_sensor_range As Byte) As Byte
    'Set Internal Temperatur Sensor Range (0.....128 degree C or -40...216 degree F and so forth)
    Call Rf23b_write(temperature_sensor_control , Temp_sensor_range)
    'Read Temp Sensor
    Call Rf23b_write(adc_configuration , &B1000_0000)       'Start ADC measurement  of internal temp sensor , Reference = bandgap voltage (1.2 V)
   'During conversion the adcstart/adcdone bit is 0
    Do
      Read_result = Rf23b_read(adc_configuration)
    Loop Until Read_result.adcstart_adcdone = 1   'wait until conversion is done (appx. 350uS)

    Rf23b_read_temp_sensor = Rf23b_read(adc_value)       'Read the ADC Value (0 = 0 degree C and 255 = 128 degree C)
End Function

'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
'  +
'  + SUB NAME:      Rf23b_enable_rx_and_rx_int()
'  +
'  + DESCRIPTION:   Enable the receiver chain
'  +                Enable the valid packet receive interrupt
'  +                Enable CRC Interrupt
'  + INPUT:         None
'  +
'  + RETURN:        None
'  +
'  + NOTES:         None
'  +
'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
Sub Rf23b_enable_rx_and_rx_int(byval En_rx_fifo_almost_full As Byte)
  'enable receiver chain

  ' ENABLE Register (Operating Mode and Function Control 1)
  '      7         6       5         4        3        2       1       0
  '  +--------+--------+--------+--------+--------+--------+--------+--------+
  '  | swres  |enLoBatt|Wake-up |32KHz Xt| Tx on  | Rx on  |PLL on  | XTAL on|
  '  +--------+--------+--------+--------+--------+--------+--------+--------+
   Call Rf23b_write(operating_function_control_1 , &B00000101)       'Rx On

  'Enable 2  interrupts:
  ' a) one which shows that a valid packet received: 'ipkval'
  ' b) second shows if the packet received with incorrect CRC: 'icrcerror'
     If En_rx_fifo_almost_full = 0 Then Call Rf23b_write(interrupt_enable_1 , &H03)
  'Enable  3 interrupts:
  ' a) one which shows that a valid packet received: 'ipkval'
  ' b) second shows if the packet received with incorrect CRC: 'icrcerror'
  ' c) RX fifo almost full int (irxffafull)
     If En_rx_fifo_almost_full = 1 Then Call Rf23b_write(interrupt_enable_1 , &H13)

   Call Rf23b_write(interrupt_enable_2 , &H00)

  'read interrupt status registers to release all pending interrupts
  'read interrupt status registers to clear the interrupt flags and release NIRQ pin
    Read_result = Rf23b_read(interrupt_status_1)    'read the Interrupt Status1 register
    Read_result = Rf23b_read(interrupt_status_2)  'read the Interrupt Status2 register
End Sub

'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
'  +
'  + SUB NAME:      Rf23b_enable_tx_and_tx_int()
'  +
'  + DESCRIPTION:   Enable the packet sent interrupt only (Read status register to clear interrupt flags)
'  +                All other interrupts will be disabled
'  +                Enable Transmitter
'  + INPUT:         None
'  +
'  + RETURN:        None
'  +
'  + NOTES:         None
'  +
'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
Sub Rf23b_enable_tx_and_tx_int()
     Disable Interrupts
    'Disable all other interrupts and enable the packet sent interrupt only.
    'This will be used for indicating the successful packet transmission for the MCU
     Call Rf23b_write(interrupt_enable_1 , &B0000_0100)       'Enable ONLY Packet Sent Interrupt (enpksent)
     Call Rf23b_write(interrupt_enable_2 , &B0000_0000)       'All Interrupts in this register disabled
    'Read interrupt status registers. It clear all pending interrupts and the nIRQ pin goes back to high.
    'read interrupt status registers to clear the interrupt flags and release NIRQ pin
     Read_result = Rf23b_read(interrupt_status_1)     'read the Interrupt Status1 register
     Read_result = Rf23b_read(interrupt_status_2)     'read the Interrupt Status2 register

    'enable transmitter
    'The radio forms the packet and send it automatically.
     Call Rf23b_write(operating_function_control_1 , &B00001001)       'Enable Tx
     Enable Interrupts
End Sub

'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
'  +
'  + SUB NAME:      Reset_the_rx_fifo()
'  +
'  + DESCRIPTION:   Reset the FIFO by setting and resetting the ffclrrx bit
'  +                Enable Transmitter
'  + INPUT:         None
'  +
'  + RETURN:        None
'  +
'  + NOTES:         None
'  +
'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
Sub Reset_the_rx_fifo()
     'This has to be a two writes operation: Setting ffclrrx =1 followed by ffclrrx = 0 will clear the contents of the RX FIFO.
      Call Rf23b_write(operating_function_control_2 , &B00000010)       'set ffclrrx
      Call Rf23b_write(operating_function_control_2 , &B00000000)       'Reset ffclrrx
      'enable the receiver chain again
      Call Rf23b_write(operating_function_control_1 , &B00000101)       'Enable Rx
End Sub

'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
'  +
'  + FUNCTION NAME: Rf23b_afc()
'  +
'  + DESCRIPTION:   Calculate Auto Frequency Compensation (AFC)
'  +                Calculate the AFC Correction (AFC Correction = 156.25Hz x (hbsel +1) x afc_corr[7: 0] )
'  +                Setting hbsel = 1 will choose the frequency range from 480....960 MHz (high bands)
'  + INPUT:         None
'  +
'  + RETURN:        AFC Correction [Hz]
'  +
'  + NOTES:         AFC Correction = 156.25Hz x (hbsel +1) x afc_corr[7: 0]
'  +                AFC Correction [Hz] = 156.25Hz * (1 + 1 ) *  Afc_correction_values
'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
Function Rf23b_afc(afc_correction_val As Byte) As Single
           Local Afc_correction As Single
         ' Afc_correction_single = 156.25 * 2
           Afc_correction = 312.5
           Afc_correction = Afc_correction * Afc_correction_val
          Rf23b_afc = Afc_correction
End Function
