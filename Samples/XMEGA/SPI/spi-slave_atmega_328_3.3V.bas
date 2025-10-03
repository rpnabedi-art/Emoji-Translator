'----------------------------------------------------------------
'                  (c) 1995-2011, MCS
'                spi-slave_atmega_328_3.3V.bas
'  This sample demonstrates the SPI slave mode
'  there is a matching SPI master named xm128A1_SPI_MASTER.bas
'  contributed by MAK3
'-----------------------------------------------------------------

' This is the SPI Slave which belong to XM128A1_spi_MASTER.bas

$regfile = "m328pdef.dat"
$crystal = 16000000                               '= overclocking at 3.3 Volt
$hwstack = 64
$swstack = 40
$framesize = 40
$baud = 19200

Dim B As Byte , Rbit As Bit
Dim My_byte As Byte , Spi_status As Byte


'First configure the MISO pin
Config Pinb.4 = Output                            ' MISO
Config Pinb.2 = Input                             'Slave Select
Config Pinb.0 = Output                            'LED
Led Alias Portb.0
Wait 1
Set Led                                           'Low active



#autocode
'Then configure the SPI hardware SPCR register
Config SPIHard = hard , Interrupt = On , Data_Order = Msb , Master = No , Polarity = Low , Phase = 0 , Clockrate = 4

#endautocode
'Then init the SPI pins directly after the CONFIG SPI statement.
Spiinit


'specify the SPI interrupt
On Spi Spi_isr

'enable global interrupts
Enable Interrupts

Dim Test_counter As Byte


Do
  If Rbit = 1 Then
     Print "B = " ; B                             'This is what we Receive from SPI Master
     My_byte = B                                  'Save B in My_byte
     Enable Spi                                   'Enable SPI Interrupt
     Reset Rbit
     Incr Test_counter
     Spdr = Test_counter                          'This is what we want to send back to SPI MASTER
  End If
Loop


'Interrupt routine
Spi_isr:
  If Pinb.2 = 0 Then                                        'Check if Slave is selected
    Spi_status = Spsr                                       ' Read Status Register before reading SPI Data to clear SPIF
    B = Spdr
    Disable Spi                                             'Disable SPI Interrupt
    Set Rbit
  End If
Return
