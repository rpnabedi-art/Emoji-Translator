'------------------------------------------------------------------
'                           SPI-SLAVE.BAS
'                          (c) MCS Electronics
' sample shows how to create a SPI SLAVE
' use together with sendspi.bas
'------------------------------------------------------------------
' Tested on the STK500. The STK200 will NOT work.
' Use the STK500 or another circuit
$regfile = "m88def.dat"
$crystal = 8000000
$baud = 19200
$hwstack = 40
$swstack = 40
$framesize = 40


Dim B As Byte , Rbit As Byte , Bsend As Byte

'First configure the MISO pin
Config Pinb.4 = Output                                      ' MISO

'Then configure the SPI hardware SPCR register to SPI mode 0
Config Spi = Hard , Interrupt = On , Data Order = Msb , Master = No , Polarity = Low , Phase = 0 , Clockrate = 128       'clock rate does not matter for a slave

'Then init the SPI pins directly after the CONFIG SPI statement.
Spiinit


'specify the SPI interrupt
On Spi Spi_isr Nosave

'enable global interrupts
Enable Interrupts

'show that we started
Print "start"
Spdr = 0                                                    ' start with sending 0 the first time
Do
  If Rbit <> 0 Then
    Print "received : " ; B
    Rbit = 0
    Bsend = Bsend + 1 : Spdr = Bsend                        'increase SPDR
  End If
  ' your code goes here
Loop



'Interrupt routine
'since we used NOSAVE, we must save and restore the registers ourself
'when this ISR is called it will send the content from SPDR to the master
'the first time this is 0
Spi_isr:
  push r24    ; save used register
  in r24,sreg ; save sreg
  push r24
  B = Spdr
  Rbit = 1                                                  ' we received something
  pop r24
  !out sreg,r24 ; restore sreg
  pop r24        ; and the used register
Return                                                      ' this will generate a reti