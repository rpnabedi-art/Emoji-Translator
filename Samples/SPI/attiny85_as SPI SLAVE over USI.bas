
' Using USI as an SPI slave with Attiny85

' 1. First we configure the USI in Three-wire Mode
' 2. Setup the USI Overflow Interrupt
' 3. And wait until the USI Oveflow Interrupt is fired
' 4. Then we read the USI Data-Register and clear the USI Interrupt flag

' The ATTINY85 work with 3.3 V so we can direct connect it to an ATXMEGA


' Following you find also a SPI configuration with an XMEGA as SPI Master which I have tested with this SPI Slave

'(
Config Spid = Hard , Master = Yes , Mode = 0 , Clockdiv = Clk128 , Data_order = Msb , Ss = Auto
'SS = Auto set the Slave Select (SS) automatically before a print #X or input #X command  (including initialization of the pin)
'Master SPI clock = 32MHz/Clk128 = 250KHz
Open "SPID" For Binary As #12
')

$regfile = "ATtiny85.DAT"                         'Controllertyp
$crystal = 8000000                                'internal crystal
$hwstack = 32                                     'Stack
$swstack = 10                                     'in this sample code no LOCAL variable inside a SUB or function!!
$framesize = 30

Dim B As Byte
Dim Usi_data_ready As Bit

Config Portb.1 = Output                           'DO   ---> MISO of ATXMEGA (PD6)

Config Portb.2 = Output                           'USCK ---> SCK of ATXMEGA  (PD7)
Set Portb.2                                       'enable Pullup

Config Portb.0 = Input                            'DI   ---> MOSI of ATXMEGA (PD5)
Set Portb.0                                       'enable Pullup

'We do not use Slave Select in this example but this would be the configuration
Config Portb.4 = Input                            'Slave Select
set  PORTB.4                                    ' enable Pullup
ss alias pinb.4


Config Portb.3 = Output                           'Serial Debug output
Open "comb.3:9600,8,n,1" For Output As #1
Print #1 , "serial output"

'Init USI as SPI Slave in USICR = USI Control Register
Set Usicr.usiwm0                                  'Three-wire mode. Uses DO, DI, and USCK pins.
Set Usicr.usics1                                  'Clock Source: External, positive edge ; External, both edges
Set Usicr.usioie                                  'USI Counter Overflow Interrupt Enable


On Usi_ovf Usi_overflow_int
Enable Usi_ovf
Enable Interrupts


Do
  If Usi_data_ready = 1 Then
      Reset Usi_data_ready
      Print #1 , B                                'print the received byte over debug output
  End If
Loop

End                                               'end program


' After eight clock pulses (i.e., 16 clock edges) the 4-Bit USI counter will generate an overflow interrupt
' A USI Overflow Int can also wakeup the Attiny from Idle mode if needed
Usi_overflow_int:
     Set Usi_data_ready
     B = Usidr
     Usisr = &B01_000000                          'Reset Overflow Flag and reset 4-Bit USI counter
return