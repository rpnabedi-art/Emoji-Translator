'----------------------------------------------------------------
'                  (c) 1995-2011, MCS
'                      xm128A1_SPI_MASTER.bas
'  This sample demonstrates the Xmega128A1 SPI master mode
'  there is a matching SPI slave named spi-slave_atmega_328_3.3V.bas
'  contributed by MAK3
'-----------------------------------------------------------------

'This is the SPI MASTER which belongs to spi-slave_atmega_328_3.3V.bas, a normal AVR is used as a slave

$regfile = "xm128a1def.dat"
$crystal = 32000000
$hwstack = 64
$swstack = 40
$framesize = 40


Config Osc = Enabled , 32mhzosc = Enabled
Config Sysclock = 32mhz                                     '--> 32MHz

'configure the priority
Config Priority = Static , Vector = Application , Lo = Enabled


Config Com1 = 57600 , Mode = Asynchroneous , Parity = None , Stopbits = 1 , Databits = 8
Waitms 2
Open "COM1:" For Binary As #1
Print #1 ,
Print #1 , "------------SPI MASTER-Slave Test----------------"

' Master = ATXMEGA128A1 running at 3.3 Volt
' Slave = ATMEGA328P running at 3.3 Volt

'We use Port E for SPI
'Ddre = &B1011_0000
'Bit7 = SCK = Output  ------> SCK ATMEGA328P    (PinB.5)
'Bit6 = MISO = Input  ------> MISO ATMEGA328P   (PinB.4)
'Bit5 = MOSI = Output ------> MOSI ATMEGA328P   (PinB.3)
'Bit4 = SS = Output   ------> SS ATMEGA328P     (PinB.2)
Slave_select Alias Porte.4
Set Slave_select

Dim Switch_bit As Bit

Switch Alias Pine.0                                         ' Switch connected to GND
Config Xpin = Porte.0 , Outpull = Pullup



Dim Bspivar As Byte
Dim Spi_send_byte As Byte
Dim Spi_receive_byte As Byte


'SPI, Master|Slave , MODE, clock division
Config Spie = Hard , Master = Yes , Mode = 0 , Clockdiv = Clk32 , Data_order = Msb , Ss = Auto
'SS = Auto set the Slave Select (SS) automatically before a print #X or input #X command  (including initialization of the pin)
'Master SPI clock = 1MHz
Open "SPIE" For Binary As #12


Main:
Config Debounce = 50

Do

 Debounce Switch , 0 , Switch_sub , Sub                     'Switch Debouncing

If Switch_bit = 1 Then                                      'When Switch pressed
   Reset Switch_bit

   Incr Spi_send_byte
   Print "Spi_send_byte = " ; Spi_send_byte

   'SEND TO SLAVE
   Print #12 , Spi_send_byte                                'SEND ONE BYTE TO SLAVE

   Waitms 3

  'READ FROM SLAVE
   Input #12 , Spi_receive_byte                             'READ ONE BYTE FROM SLAVE

   Print #1 , "Spi_receive_byte = " ; Spi_receive_byte
End If


Loop



End                                                         'end program

'there is NO CLOSE for SPI


Switch_sub:
  Set Switch_bit
Return