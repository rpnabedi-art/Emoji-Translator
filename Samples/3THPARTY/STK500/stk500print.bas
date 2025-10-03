'STK500 sample
'This sample is only intended to show how communication
'with the STK500 work

'the default xtal is 3.68 MHz
$regfile="m88def.dat"
$crystal = 3680000
$baud = 9600
$hwstack=40
$swstack=40
$FrameSize=40

'when you connect the RS232 SPARE to your COM port of your PC
'you must connect TXD SPARE to PORTD.1 when using a 8515(txd pin)

Do
  Print "hello"
  Wait 1
Loop