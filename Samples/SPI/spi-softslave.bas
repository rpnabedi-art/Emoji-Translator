'-------------------------------------------------------------------------------
'                        SPI-SOFTSLAVE.BAS
'                    (c) 2002-2003 MCS Electronics
' sample that shows how to implement a SPI SLAVE with software
'-------------------------------------------------------------------------------
'Some atmel chips like the 2313 do not have a SPI port.
'The BASCOM SPI routines are all master mode routines
'This example show how to create a slave using the 2313
'ISP slave code

'we use the 2313
$regfile = "2313def.dat"
$hwstack = 16
$swstack = 8
$framesize = 16
'XTAL used
$crystal = 4000000

'baud rate
$baud = 19200

'define the constants used by the SPI slave
Const _softslavespi_port = Portd                            ' we used portD
Const _softslavespi_pin = Pind                              'we use the PIND register for reading
Const _softslavespi_ddr = Ddrd                              ' data direction of port D

Const _softslavespi_clock = 5                               'pD.5 is used for the CLOCK
Const _softslavespi_miso = 3                                'pD.3 is MISO
Const _softslavespi_mosi = 4                                'pd.4 is MOSI
Const _softslavespi_ss = 2                                  ' pd.2 is SS
'while you may choose all pins you must use the INT0 pin for the SS
'for the 2313 this is pin 2

'PD.3(7),  MISO  must be output
'PD.4(8),  MOSI
'Pd.5(9) , Clock
'PD.2(6),  SS /INT0

'define the spi slave lib
$lib "spislave.lbx"
'sepcify wich routine to use
$external _spisoftslave

'we use the int0 interrupt to detect that our slave is addressed
On Int0 Isr_sspi Nosave
'we enable the int0 interrupt
Enable Int0
'we configure the INT0 interrupt to trigger when a falling edge is detected
Config Int0 = Falling
'finally we enabled interrupts
Enable Interrupts

'
Dim _ssspdr As Byte                                         ' this is out SPI SLAVE SPDR register
Dim _ssspif As Bit                                          ' SPI interrupt revceive bit
Dim Bsend As Byte , I As Byte , B As Byte                   ' some other demo variables

_ssspdr = 0                                                 ' we send a 0 the first time the master sends data
Do
   If _ssspif = 1 Then
   Print "received: " ; _ssspdr
   Reset _ssspif
   _ssspdr = _ssspdr + 1                                    ' we send this the next time
   End If
Loop
