'------------------------------------------------------------------
'                           SENDSPI.BAS
'                          (c) MCS Electronics
' sample shows how to create a SPI MASTER
'Use together with spi-slave.bas
'------------------------------------------------------------------
' Tested on the STK500. The STK200 will NOT work.
' Use the STK500 or another circuit
' connect MISO, PB6(pin 18) to slave MISO
'         MOSI, PB5(pin 17) to slave MOSI
'         CLOCK,PB7(pin 19) to slave CLOCK
'         SS,   PB4(pin 16) to slave SS


$regfile = "m88def.dat"
$crystal = 8000000
$baud = 19200
$framesize = 128
$hwstack = 40
$swstack = 40

'config the SPI in master mode.The clock must be a quarter of the slave cpu
Config Spi = Hard , Interrupt = Off , Data Order = Msb , Master = Yes , Polarity = Low , Phase = 0 , Clockrate = 128

Declare Sub Spidbg(byval S As String)

'init the spi pins
Spiinit

Dim B As Byte , Bfromslave As Byte , L As Byte

' Spidbg "this is a test"
'unremark 

Do
  'send 1 byte

  Bfromslave = Spimove(b)
  Print Bfromslave ; " received from slave"
  'as an alternative you can send data and display the last received value
  '  Spiout B , 1
  '  Print Spdr ; " received from slave"
  Wait 1
  B = B + 1
Loop
End


Sub Spidbg(byval S As String)
    L = Len(s)
    Dim J As Byte
    Dim Krk As String * 1
    For J = 1 To L
      Krk = Mid(s , J , 1)
      Spiout Krk , 1
      Waitms 10
    Next
End Sub