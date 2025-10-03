'------------------------------------------------------------------
'                           SPI-SLAVE-DBG.BAS
'                          (c) MCS Electronics
' sample shows how to create a SPI SLAVE Debugger
' use together with sendspi.bas
'------------------------------------------------------------------
$regfile = "m88def.dat"
$crystal = 8000000
$baud = 19200
$hwstack = 44
$swstack = 40
$framesize = 40




Dim B As Byte , Rbit As Bit , Bsend As Byte , K As Byte
Dim Buf As String * 80 , S As String * 1

'First configure the MISO pin
Config Pinb.4 = Output                                      ' MISO

'Then configure the SPI hardware SPCR register
Config Spi = Hard , Interrupt = On , Data Order = Msb , Master = No , Polarity = Low , Phase = 0 , Clockrate = 128

'Then init the SPI pins directly after the CONFIG SPI statement.
Spiinit


'specify the SPI interrupt
On Spi Spi_isr

'enable global interrupts
Enable Interrupts

'show that we started

Print "DEBUGGER Start"
Spdr = 0                                                    ' start with sending 0 the first time
Do
  K = Inkey()
  If Rbit = 1 Then
     Print Chr(b);                                          ' just send byte to serial port
     Reset Rbit
     Spdr = K                                               'you could assing a value here to SPDR
  End If
  ' your code goes here
Loop



'Interrupt routine
'since we used NOSAVE, we must save and restore the registers ourself
'when this ISR is called it will send the content from SPDR to the master
'the first time this is 0
Spi_isr:
  Rbit = 1
  B = Spdr
Return                                                      ' this will generate a reti