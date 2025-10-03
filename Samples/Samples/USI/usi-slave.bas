'-------------------------------------------------------------------------------
'                            (c) 2004-2014 MCS Electronics
'          This demo demonstrates the USI I2C slave
'          This is part of the I2C Slave library which is a commercial addon library
'          Not all AVR chips have an USI !!!!
'-------------------------------------------------------------------------------

$regfile = "attiny84.dat"

$crystal = 8000000
$hwstack = 40
$swstack = 16
$framesize = 24

const cPrint = 0                                            'make 0 for chips that have NO UART, make 1 when the micro has a UART and you want to show data on the terminal

#if cPrint
   $baud = 19200                                            'only when the processor has a UART
#endif

config usi = twislave , address = &H40                      'bascom uses 8 bit i2c address (7 bit shifted to the left with one bit)

#if cPrint
   print "USI DEMO"
#endif

'do not forget to enable global interrupts since USI is used in interrupt mode
enable interrupts                                           'it is important you enable interrupts

do
   !  nop                                                   ; nothing to do here
loop



'The following labels are called from the library. You need to insert code in these subroutines
'Notice that the PRINT commands are remarked.
'You can unmark them and see what happens, but it will increase code size
'The idea is that you write your code in the called labels. And this code must execute in as little time
'as possible. So when you slave must read the A/D converter, you can best do it in the main program
'then the data is available when the master requires it, and you do not need to do the conversion which cost time.


'A master can send or receive bytes.
'A master protocol can also send some bytes, then receive some bytes
'The master and slave address must match.

'the following labels are called from the library  when master send stop or start
Twi_stop_rstart_received:
   '  Print "Master sent stop or repeated start"
Return

'master sent our slave address and will not send data
Twi_addressed_goread:
   ' Print "We were addressed and master will send data"
Return


Twi_addressed_gowrite:
   '  Print "We were addressed and master will read data"
Return

'this label is called when the master sends data and the slave has received the byte
'the variable TWI holds the received value
Twi_gotdata:
   '   Print "received : " ; Twi ; " byte no : " ; Twi_btw
   Select Case Twi_btw
      Case 1 :                                               'Portd = Twi                                   ' first byte
      Case 2:                                                'you can set another port here for example
   End Select
Return

'this label is called when the master receives data and needs a byte
'the variable twi_btr is a byte variable that holds the index of the needed byte
'so when sending multiple bytes from an array, twi_btr can be used for the index
Twi_master_needs_byte:
   '  Print "Master needs byte : " ; Twi_btr
   Select Case Twi_btr
      Case 1 : twi = 68                                       ' first byte
      Case 2 : twi = 69                                       ' send second byte
   End Select                                                'you could also return the state of a port pin or A/D converter
Return