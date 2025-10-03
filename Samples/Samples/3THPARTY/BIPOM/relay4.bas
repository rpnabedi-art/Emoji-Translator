'*******************************************************************************
'
' Module:   RELAY4.BAS
'
' Revision:   1.01
'
' Date: 1 July 2012
'
' Description:   Controls relays on and off on RELAY-4 board
'
' (C) 2012 BiPOM Electronics, Inc. - www.bipom.com
'
'*******************************************************************************
' ATMEGA 2560
$regfile = "m2560def.dat"
$hwstack=64
$swstack=64
$FrameSize=64
'*******************************************************************************
$crystal = 14745600


'I2C BUS CONFIGURATION
Config Scl = Portd.0
Config Sda = Portd.1

'CONFIG I2CDELAY = 25


'declare constants
Const Addressw = &H40
Const Addressr = &H41
Const Pca9554_out_reg = 1
Const Pca9554_conf_reg = 3

'declare subroutines
Declare Sub Relayon(byval Relaynum As Byte )
Declare Sub Relayoff(byval Relaynum As Byte )
Declare Sub Writeexpander(byval Regnum As Byte , Byval Value As Byte)
Declare Sub Onesecdelay()

'declare variables
Dim Value As Byte , Relaynum As Byte
Dim Pca9554_out As Byte
Dim Index As Byte
Dim Regnum As Byte


'Initialize Expander outputs
Call Writeexpander(pca9554_conf_reg , 0)
Pca9554_out = 255

Print "Start"

Do
   Print

   Index = 1

' Turn all relays OFF
   For Index = 1 To 4
      Print "Turn relay # " ; Index ; " OFF"
      Call Relayon(index)
      Call Onesecdelay()
   Next Index

' Turn all relays ON
   For Index = 1 To 4
      Print "Turn relay # " ; Index ; " ON"
      Call Relayoff(index)
      Call Onesecdelay()
   Next Index
Loop
End                                                         ' End Main Program


Sub Onesecdelay()
   Waitms 250
   Waitms 250
   Waitms 250
   Waitms 250
End Sub


' Turn RELAY on, relay number is 1-based
Sub Relayon(relaynum As Byte )
   Value = 1                                           'prepare bit mask
   Relaynum = Relaynum - 1                             'only 0..3 numbers are valid
   Rotate Value , Left , Relaynum                      '
   Value = Value Xor 255                               '
   Pca9554_out = Pca9554_out And Value                 'clear the necessary bit
   Call Writeexpander(pca9554_out_reg , Pca9554_out)   're-write 8-bit expander port
End Sub


' Turn RELAY off, relay number is 1-based
Sub Relayoff(relaynum As Byte )
   Value = 1                                           'prepare bit mask
   Relaynum = Relaynum - 1                             'only 0..3 numbers are valid
   Rotate Value , Left , Relaynum                      '
   Pca9554_out = Pca9554_out Or Value                  'set the necessary bit
   Call Writeexpander(pca9554_out_reg , Pca9554_out)   're-write 8-bit expander port
End Sub


' Write 8-bit expander
Sub Writeexpander(regnum As Byte , Value As Byte)
   I2cstart                                                'start condition
   I2cwbyte Addressw                                       'slave address
   I2cwbyte Regnum                                         'command byte
   I2cwbyte Value                                          'value to write
   I2cstop                                                 'stop condition
End Sub