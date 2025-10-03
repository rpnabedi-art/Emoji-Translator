'-------------------------------------------------------------------------------
'                            (c) 2004-2010 MCS Electronics
'                This demo shows an example of the TWI in SLAVE mode
'                       Not all AVR chips have TWI (hardware I2C)
'  This demo is a Mega88 I2C A/D converter slave chip
'  This demo also shows that PORTB can be set for example to be used as an output
' NOTICE that this demo will only work with the TWI slave library which is avaialble as an add on
' SDA pin is PORTC.4 (pin 27)
' SCL pin is PORTC.5 (pin 28)
'-------------------------------------------------------------------------------
$regfile = "M88def.dat"                                     ' the chip we use
$crystal = 8000000                                          ' crystal oscillator value
$baud = 19200                                               ' baud rate
$hwstack = 40
$swstack = 20
$framesize = 40

'$lib "i2c_twi-slave.lbx"

Print "MCS Electronics M88 TWI-slave demo"
Print "Use with M88-TWI master demo"

Config Adc = Single , Prescaler = Auto , Reference = Avcc
'Now give power to the chip
Start Adc

Dim W As Word
Config Portb = Output

Dim Status As Byte                                          'only for debug
'Print Hex(status)

Config Twislave = &H70 , Btr = 2 , Bitrate = 100000
'                   ^--- slave address
'                         ^---------- 2 bytes to receive
'                                     ^--- bitrate is 100 KHz


'The variables  Twi , Twi_btr and Twi_btw are created by the compiler. These are all bytes
'The TWI interrupt is enabled but you need to enabled the global interrupt


Enable Interrupts

'this is just an empty loop but you could perform other tasks there
Do
  'Print Getadc(0)
  'Waitms 500
  nop
Loop
End




'The following labels are called from the library. You need to insert code in these subroutines
'Notice that the PRINT commands are remarked.
'You can unmark them and see what happens, but it will result in occasional errors in the transmission
'The idea is that you write your code in the called labels. And this code must execute in as little time
'as possible. So when you slave must read the A/D converter, you can best do it in the main program
'then the data is available when the master needs it, and you do not need to do the conversion which cost time.


'A master can send or receive bytes.
'A master protocol can also send some bytes, then receive some bytes
'The master and slave must match.

'the following labels are called from the library  when master send stop or start
Twi_stop_rstart_received:
 ' Print "Master sent stop or repeated start"
Return

'master sent our slave address and will not send data
Twi_addressed_goread:
 ' Print "We were addressed and master will send data"
Return


Twi_addressed_gowrite:
 ' Print "We were addressed and master will read data"
Return

'this label is called when the master sends data and the slave has received the byte
'the variable TWI holds the received value
Twi_gotdata:
   'Print "received : " ; Twi ; " byte no : " ; Twi_btw
   Select Case Twi_btw
     Case 1 : Portb = Twi                                   ' first byte
     Case 2:                                                'you can set another port here for example
   End Select                                               ' the setting of portb has nothing to do with the ADC
Return

'this label is called when the master receives data and needs a byte
'the variable twi_btr is a byte variable that holds the index of the needed byte
'so when sending multiple bytes from an array, twi_btr can be used for the index
Twi_master_needs_byte:
  'Print "Master needs byte : " ; Twi_btr
  Select Case Twi_btr
    Case 1:                                                 ' first byte
              W = Getadc(0)                                 'in this example the conversion is done here
              ' but a better option would have been to just pass the value of W and do the conversion in the main loop
              'Print "ADC-SLAVE:" ; W
              Twi = Low(w)
    Case 2                                                  ' send second byte
              Twi = High(w)
  End Select
Return


'when the mast has all bytes received this label will be called
Twi_master_need_nomore_byte:
 ' Print "Master does not need anymore bytes"
Return

Mydbg:
'  Print Hex(status)
Return