'-------------------------------------------------------------------------------
'                            (c) 2004-2015 MCS Electronics
'       This demo demonstrates the USI I2C slave and emulates an EEPROM chip
'          This is part of the I2C Slave library which is a commercial addon library
'          Not all AVR chips have an USI !!!!
'-------------------------------------------------------------------------------
' This is a simple sample. the master sends the address of the slave, the WORD address
'  of the memory location, and a byte to store or read
'------------------------------------------------------------------------------
' The matching master code to write
'   i2cstart : i2cwbyte &H40 : i2cwbyte low(address) : i2cwbyte high(address) : i2cwbyte value : i2cstop
' The mathing master code to read
'   i2cstart : i2cwbyte &H40 : i2cwbyte low(address) : i2cwbyte high(address) : i2crepstart : i2cwbyte &H41 : i2cRbyte value, nack : i2cstop
'See also the eeprom_master.bas

$regfile = "attiny2313.dat"
'$regfile = "attiny85.dat"
$crystal = 8000000
$hwstack = 44
$swstack = 16
$framesize = 28
config CLOCKDIV=1
'I2C pins on tiny2313 connected like :
'PB5 SDA
'PB7 SCL

'I2C pins on tiny85 connected like :
'PB0 SDA
'PB2 SCL

config BASE=0                                               'arrays start at address 0

Const Cprint = 0                                           'make 0 for chips that have NO UART, make 1 when the micro has a UART and you want to show data on the terminal

#if cPrint
   Config Com1 = 19200 , Synchrone = 0 , Parity = None , Stopbits = 1 , Databits = 8 , Clockpol = 0
   print "USI DEMO"
#endif


config usi = twislave , address = &H40                      'bascom uses 8 bit i2c address (7 bit shifted to the left with one bit)

dim epr(128) as Eram byte                 'for easy access to the memory
dim wAdres as Word, bValue as Byte
dim bAdresL as Byte at Wadres overlay     'overlay with wAdres LSB
dim bAdresH as Byte at Wadres+1 overlay   'overlay with wAdres MSB

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
Twi_start_received:
   #if cprint
      Print "Master sent start or repeated start"
   #endif
Return

Twi_stop_received:
   #if cprint
      Print "Master sent stop"
   #endif
Return

'master sent our slave address and will now send data
Twi_addressed_goread:
   #if cprint
      Print "We were addressed and master will send data"
   #endif
Return


Twi_addressed_gowrite:
   #if cprint
      Print "We were addressed and master will read data"
   #endif
Return

'this label is called when the master sends data and the slave has received the byte
'the variable TWI holds the received value
Twi_gotdata:
   #if cprint
      Print "received : " ; Twi ; " byte no : " ; Twi_btw ; "-"; usidr
   #endif
   Select Case Twi_btw
      Case 1 : bAdresL=TWI 'first byte is LSB
      Case 2 : bAdresH=TWI 'second byte is MSB
      case 3 :
         #if cprint
            print "address:" ; wAdres
         #endif
         epr(wAdres)=twi 'write to eeprom in case we receive a third byte which should only happen when we write to the slave
   End Select

'if you want to auto inc wAdres, use this code instead:
'   Select Case Twi_btw
'      Case 1 : bAdresL=TWI 'first byte is LSB
'      Case 2 : bAdresH=TWI 'second byte is MSB
'      case else : epr(wAdres)=twi 'write to eeprom in case we receive a third byte which should only happen when we write to the slave
'                 incr wAdres
'   End Select
Return

'this label is called when the master receives data and needs a byte
'the variable twi_btr is a byte variable that holds the index of the needed byte
'so when sending multiple bytes from an array, twi_btr can be used for the index
Twi_master_needs_byte:
   #if cprint
      Print "Master needs byte : " ; Twi_btr
      print "address:" ; wAdres
   #endif
   twi=epr(wAdres) 'return the data from EEPROM
   'when you want to support auto adres increase add this :
   'incr wAdres
Return
