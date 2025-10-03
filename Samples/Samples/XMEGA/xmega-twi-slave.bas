'------------------------------------------------------------------------------
'name                     : xmega-twi-slave.bas
'copyright                : (c) 1995-2013, MCS Electronics
'purpose                  : demonstrates Xmega TWI slave add on
'micro                    : Xmega128A1
'suited for demo          : yes
'commercial addon needed  : yes
'------------------------------------------------------------------------------

$regfile = "xm128a1def.dat"
$crystal = 32000000
$hwstack = 64
$swstack = 40
$framesize = 40


'first enable the osc of your choice
Config Osc = Enabled , 32mhzosc = Enabled

'configure the systemclock
Config Sysclock = 32mhz , Prescalea = 1 , Prescalebc = 1_1

Config Com1 = 19200 , Mode = Asynchroneous , Parity = None , Stopbits = 1 , Databits = 8
'Config Serialin = Buffered , Size = 50

'Enable Interrupts
Open "COM1:" For Binary As #1

Open "TWID" For Binary As #4                                ' or use TWIC,TWIE oR TWIF
Config Twid = 100000                                        'CONFIG TWI will ENABLE the TWI master interface
'you can also use TWIC, TWID, TWIE of TWIF
'!!!!!!!!!!!   WITHOUT a channel identifier, TWIC will be used !!!!!!!!!!!!!!
'SCL is on pin 1
'SDA is on pin 0
'This demo uses TWID as master and TWIC as SLAVE
'Thus portc.0 connects with portD.0 and
'     portc.1 connects with portD.1

'The TWIC when used as a slave has megaAVR compatible labels
'The TWID,TWIE and TWIF have unique new labelnames
'These labels are the labels in your code which are called from the slave ISR.
'For example : Twi_addressed_gowrite  is named TwiD_addressed_gowrite for TWID


Dim Twi_start As Byte , j as byte , b as byte
I2cinit #4                                                  'init the master
config TWIcslave = &H70 , btr = 2                           'use address &H70 which is &H38 in 7-bit i2c notation

Enable INTERRUPTS                                           'for the slave to work we must enable global interrupts

do
   Print #1 , "test xmega"

   For J = 0 To 120 Step 1                                  'notice that we scan odd and even addresses
      I2cstart #4                                           'send start
      I2cwbyte J , #4                                       'send value of J
      If Err = 0 Then                                         ' no errors
         Print #1 , "FOUND : " ; Hex(j)
         if j.0 = 0 then                                    'ONLY if R/W bit is not set we may write data !!!
            I2cwbyte 100 , #4                               'just write to values to the slave
            I2cwbyte 101 , #4
         else                                               'read
            I2crbyte b , Ack , #4 : print #1 , "GOT : " ; b 'read 2 bytes
            I2crbyte b , nAck , #4 : print #1 , "GOT : " ; b
         end if
      End If
      I2cstop #4                                            'done
   Next
   waitms 2000                                              'wait some time
loop


'the following labels are called from the library  when master send stop or start
'notice that these label names are valid for TWIC.
'for TWID the name would be TWID_stop_rstart_received:
Twi_stop_rstart_received:
   Print #1 , "Master sent stop or repeated start"
Return

'master sent our slave address and will not send data
Twi_addressed_goread:
   Print #1 , "We were addressed and master will send data"
Return


Twi_addressed_gowrite:
   Print #1 , "We were addressed and master will read data"
Return

'this label is called when the master sends data and the slave has received the byte
'the variable TWIx holds the received value
'The x is the TWI interface letter
Twi_gotdata:
   Print #1 , "received : " ; Twic ; " byte no : " ; Twic_btw
   'here you would do something with the received data
   '   Select Case Twic_btw
   '     Case 1 : Portb = Twi                                   ' first byte
   '     Case 2:                                                'you can set another port here for example
   '   End Select
Return

'this label is called when the master receives data and needs a byte
'the variable twix_btr is a byte variable that holds the index of the needed byte
'so when sending multiple bytes from an array, twix_btr can be used for the index
'again the variable name depends on the twi interface
Twi_master_needs_byte:
   Print #1 , "Master needs byte : " ; Twic_btr
   Select Case Twic_btr
      Case 1:                                                 ' first byte
         twic = 66                                     'we assign a value but this could be any value you want
      Case 2                                                  ' send second byte
         twic = 67
   End Select
Return


'when the mast has all bytes received this label will be called
Twi_master_need_nomore_byte:
   Print #1 , "Master does not need anymore bytes"
Return

End