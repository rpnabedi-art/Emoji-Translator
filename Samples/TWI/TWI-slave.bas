'-------------------------------------------------------------------------------
'                            (c) 2004 MCS Electronics
'                This demo shows an example of the TWI in SLAVE mode
'                       Not all AVR chips have TWI (hardware I2C)
' IMPORTANT : this example ONLY works when you have the TWI slave library
'             which is a commercial add on library, not part of BASCOM
'Use this sample in combination with i2cscan.bas and/or twi-master.bas
'-------------------------------------------------------------------------------
$regfile = "M8def.dat"                                     ' the chip we use
$crystal = 8000000                                          ' crystal oscillator value
$baud = 19200                                               ' baud rate
$hwstack = 40
$swstack = 32
$framesize = 16

Print "MCS Electronics TWI-slave demo"

'Config Twislave = &H70 , Btr = 1 , Bitrate = 100000 , Gencall = 1 , Save = Nosave , Userack = On
Config Twislave = &H70 , Btr = 1 , Bitrate = 100000 , Gencall = 1       ' use this when you write code in the main loop

'In i2c the address has 7 bits. The LS bit is used to indicate read or write
'When the bit is 0, it means a write and a 1 means a read
'When you address a slave with the master in bascom, the LS bit will be set/reset automatic.
'The TWAR register in the AVR is 8 bit with the slave address also in the most left 7 bits
'This means that when you setup the slave address as &H70, TWAR will be set to &H0111_0000
'And in the master you address the slave with address &H70 too.
'The AVR TWI can also recognize the general call address 0. You need to either set bit 0 for example
'by using &H71 as a slave address, or by using GENCALL=1


'when using USERACK=ON, all acks can be changed by the user. just assign the variable TWI_ACK a value of 0, and the slave will send a nack instead of the default ack

'as you might need other interrupts as well, you need to enable them all manual
Enable Interrupts

'this is just an empty loop but you could perform other tasks there
Do
  nop
Loop
End

'A master can send or receive bytes.
'A master protocol can also send some bytes, then receive some bytes
'The master and slave must match.

'the following labels are called from the library
Twi_stop_rstart_received:
  Print "Master sent stop or repeated start"
Return


Twi_addressed_goread:
  Print "We were addressed and master will send data"
'  Twi_ack = 0                                               'Optional You Can Send A Nack By Resetting The Twi_ack Variable
Return


Twi_addressed_gowrite:
  Print "We were addressed and master will read data"
Return


'this label is called when the master sends data and the slave has received the byte
'the variable TWI holds the received value
Twi_gotdata:
   Print "received : " ; Twi
'  Twi_ack = 0                                               'Optional You Can Send A Nack By Resetting The Twi_ack Variable
Return

'this label is called when the master receives data and needs a byte
'the variable twi_btr is a byte variable that holds the index of the needed byte
'so when sending multiple bytes from an array, twi_btr can be used for the index
Twi_master_needs_byte:
  Print "Master needs byte : " ; Twi_btr
  Twi = 65                                                  ' twi must be filled with a value
'  Twi_ack = 0                                               'Optional You Can Send A Nack By Resetting The Twi_ack Variable
Return


'when the mast has all bytes received this label will be called
Twi_master_need_nomore_byte:
  Print "Master does not need anymore bytes"
Return