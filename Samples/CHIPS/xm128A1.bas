'----------------------------------------------------------------
'                  (c) 1995-2010, MCS
'                      xm128A1.bas
'  This sample demonstrates the Xmega128A1
'-----------------------------------------------------------------

$regfile = "xm128a1def.dat"
$crystal = 32000000
$hwstack = 64
$swstack = 40
$framesize = 40


'$timeout = 8000000     TIMEOUT WILL WORK FOR ALL UARTS
Porta = 0

'first enable the osc of your choice
Config Osc = Enabled , 32mhzosc = Enabled

'configure the systemclock
Config Sysclock = 32mhz , Prescalea = 1 , Prescalebc = 1_1

Dim N As String * 16 , B As Byte
Config Com1 = 38400 , Mode = Asynchroneous , Parity = None , Stopbits = 1 , Databits = 8
Config Input1 = Cr , Echo = Crlf                            ' CR is used for input, we echo back CR and LF

Open "COM1:" For Binary As #1
'       ^^^^ change from COM1-COM8

Config Portb = Output
Config Portd = Output

Waitms 500

Print #1 , "Xmega revision:" ; Mcu_revid                    ' make sure it is 7 or higher !!! lower revs have many flaws

Config Eeprom = Mapped                                      ' when using EEPROM , add this config command

'setup the DACA
Config Daca = Enabled , Io0 = Enabled , Channel = Single , Reference = Int1v , Interval = 64 , Refresh = 64
Daca0 = 4095                                                '1 V output on porta.2
'Start Daca ' to enabled it
'Stop Daca ' to diabled it

'setup the ADC-A converter
Config Adca = Single , Convmode = Unsigned , Resolution = 12bit , Dma = Off , Reference = Int1v , Event_mode = None , Prescaler = 32 , Ch0_gain = 1 , Ch0_inp = Single_ended , Mux0 = 0       'you can setup other channels as well

Dim Teller As Long
Dim Le As Eram Long                                         ' eram var
Dim L As Long                                               ' normal var
Dim S As String * 12
Dim Sse As Eram String * 12
L = &H12345678
Le = L
L = 0
L = Le
S = "some string"
Sse = S                                                     'write to ERAM
S = ""
S = Sse
Print #1 , "string:" ; S
Print #1 , Hex(l)                                           'test if it worked

Dim W As Word
Do
  W = Getadc(adca , 0)
  Print #1 , W
  Waitms 500
Loop Until Inkey(#1) = 27

Dim Buart_channel As Byte
For Buart_channel = 0 To 7                                  'when using a variable, notice that the index is 0 based !
    Print #buart_channel , "UART :" ; Buart_channel
    B = Inkey(#buart_channel)                               ' check for data
    If B <> 0 Then                                          'if we have data it means we are connected to some data source
       B = Waitkey(#buart_channel)                          ' wait for more data this will block
       Input #buart_channel , "Name " , S
    End If
Next


Dim Bspivar As Byte , Ar(4) As Byte
Bspivar = 1
'SPI, Master|Slave , MODE, clock division
Config Spic = Hard , Master = Yes , Mode = 0 , Clockdiv = Clk2 , Data_order = Msb
Config Spid = Hard , Master = Yes , Mode = 1 , Clockdiv = Clk8 , Data_order = Lsb
Config Spie = Hard , Master = Yes , Mode = 2 , Clockdiv = Clk4 , Data_order = Msb
Config Spif = Hard , Master = Yes , Mode = 3 , Clockdiv = Clk32 , Data_order = Msb

Open "SPIC" For Binary As #10
Open "SPID" For Binary As #11
Open "SPIE" For Binary As #12
Open "SPIF" For Binary As #13
Open "SPI" For Binary As #bspivar                           ' use a dynamic channel
'SPI channel only suppor PRINT and INPUT
Print #10 , "to spi" ; W
Input #10 , Ar(1) , W
Print #bspivar , W
Input #bspivar , W

'the is NO CLOSE for SPI


'configure the priority
'config priority=static|roundrobin,vector=application|boot,HI=enabled|disabled, LO=enabled|disabled,ME=enabled|disabled
Config Priority = Static , Vector = Application , Lo = Enabled

'test an interrupts
On Usartc0_rxc Rxc_isr
Enable Usartc0_rxc , Lo
Enable Interrupts


Dim Tel As Byte
Tel = 65
Do
  Teller = 0
  'Print #1 , "press ESC key"
  'Do
  '   Tel = Inkey(#1)
  '   Print #1 , Tel
  '   Waitms 100
  'Loop Until Tel = 27

  Tel = Waitkey(#1)
  Print #1 , Tel
  Input #1 , "name?" , N
  Print #1 , N
  Print #1 , Teller
Loop


Rxc_isr:
 Toggle Portb
 Incr Teller
Return