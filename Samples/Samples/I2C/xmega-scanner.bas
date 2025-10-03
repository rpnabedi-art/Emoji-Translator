'------------------------------------------------------------------
'                    (c) 1995-2014 MCS
'                      xmega-scanner.bas
'purpose : scan all i2c addresses to find slave chips
'Micro: Xmega128A1
'------------------------------------------------------------------
$regfile = "xM128a1def.dat"                                 ' the used chip
$crystal = 32000000                                         ' frequency used
$hwstack = 40
$swstack = 40
$framesize = 40

'first enable the osc of your choice
Config Osc = Enabled , 32mhzosc = Enabled

'configure the systemclock
Config Sysclock = 32mhz , Prescalea = 1 , Prescalebc = 1_1

Config Com1 = 19200 , Mode = Asynchroneous , Parity = None , Stopbits = 1 , Databits = 8
'Config Serialin = Buffered , Size = 50
Config Twic = 100000                                        'CONFIG TWI will ENABLE the TWI master interface
'Enable Interrupts
Open "COM1:" For Binary As #1

i2cinit

Dim Twi_start As Byte , j as byte , b as byte

Print "Scan start"
For B = 0 To 254 Step 2                                     'for all odd addresses
  I2cstart                                                  'send start
  I2cwbyte B                                                'send address
  If Err = 0 Then                                           'we got an ack
     Print "Slave at : " ; B ; " hex : " ; Hex(b) ; " bin : " ; Bin(b)
  End If
  I2cstop                                                   'free bus
Next
Print "End Scan"
End