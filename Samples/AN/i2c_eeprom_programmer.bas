'--------------------------------------------------------------------
'                       I2C Eeprom programmer
'Upload your Eeprom files through serial connection in the I2c Eeprom
'       No extended address supported, so max 512K Eeprom
'     By Evert Dekker 2008 i2cprogrammer@Evertdekker dotje com
'                Created with Bascom-Avr: 1.11.9.0.100
'--------------------------------------------------------------------

$regfile = "m88def.DAT"
$crystal = 8000000
$baud = 19200
$hwstack = 70
$swstack = 70
$framesize = 60

$lib "I2C_TWI.LBX"                                          'Setting up i2c hardware bus
Config Twi = 400000                                         'Hardware i2c bus speed
I2cinit
Config Scl = Portc.5                                        'TWI (i2c) ports on the Mega88
Config Sda = Portc.4
Const Addressw = &B10100000                                 'slave write address eeprom
Const Addressr = &B10100001                                 'slave read address eeprom


Dim Startbyte As Byte , Instring As String * 45 , Instring2 As String * 45 , Complete As Bit
Dim Temp As Byte , Temps As String * 3
Dim Bytecount As Byte , Addresshigh As Byte , Addresslow As Byte , Recordtype As Byte , Databyte(16) As Byte , Checksm As Byte
Dim Lus As Byte , Pos As Byte , Checksum_calc As Byte , Checksum_error As Bit

Enable Urxc
Enable Interrupts
On Urxc Bytereceived_isr


'=== Main  ===
Do
   If Complete = 1 Then                                     'Wait until the buffer is filled with one line
      Gosub Process_buffer                                  'Process the buffer
      Gosub Calculate_checksum                              'Calculate the cheksum
      If Recordtype = &H01 Then                             'EOF finished, send a ACK and return
         Print "Y";
      Else
         If Checksum_error = 0 Then                         'If there's no error continue
            Select Case Recordtype                          'do something with the recordtype
               Case &H00                                    'Data byte
                  Gosub Prog_eeprom                         'Recordtype &H00 = databyte, so lets programm the Eeprom
               Case &H02                                    'Extended Linear Address Records, not (yet) supported
                  ! nop
            End Select
            Print "Y";                                      'Checksum ok, send a ACK
         Else
            Print "Z";                                      'Checksum error send a Nack
         End If
      End If
      Complete = 0 :                                        'Reset the variable
   End If
Loop
End


Prog_eeprom:
   I2cstart                                                'start condition
   I2cwbyte Addressw                                       'slave address
   I2cwbyte Addresshigh                                    'Highaddress of EEPROM
   I2cwbyte Addresslow                                     'Lowaddress of EEPROM
   For Lus = 1 To Bytecount
      I2cwbyte Databyte(lus)                               'value to write
   Next Lus
   I2cstop                                                 'stop condition
   Waitms 10                                               'wait for 10 milliseconds
Return


Process_buffer:
   Temps = Mid(instring2 , 1 , 2) : Bytecount = Hexval(temps)  'Read the numbers of bytes
   Temps = Mid(instring2 , 3 , 2) : Addresshigh = Hexval(temps)'Read the high adress
   Temps = Mid(instring2 , 5 , 2) : Addresslow = Hexval(temps) 'Read the low adress
   Temps = Mid(instring2 , 7 , 2) : Recordtype = Hexval(temps) 'Read the recordtype
   For Lus = 1 To Bytecount                                    'Process the number of data bytes
      Pos = Lus * 2
      Pos = Pos + 7
      Temps = Mid(instring2 , Pos , 2) : Databyte(lus) = Hexval(temps)       'Read the databytes
   Next Lus
   Pos = Pos + 2                                               'read the last byte
   Temps = Mid(instring2 , Pos , 2) : Checksm = Hexval(temps)  'Read checksum
Return


Calculate_checksum:
   Temp = 0                                                    'Add up all the databytes
   Temp = Temp + Bytecount
   Temp = Temp + Addresshigh
   Temp = Temp + Addresslow
   Temp = Temp + Recordtype
   For Lus = 1 To Bytecount
      Temp = Temp + Databyte(lus)
   Next Lus
   Checksum_calc = 256 - Temp                                  'taking its two's complement
   If Checksum_calc <> Checksm Then                            'Compare it with the readed value
      Checksum_error = 1
   Else
      Checksum_error = 0
   End If
Return

Bytereceived_isr:
   Temp = Udr                                                  'get the binary value that came across
   If Temp = &H0D Then                                         'Received CR = end of line, line complete
      If Len(instring) < 8 Then                                'To short, startover again
         Complete = 0
         Instring = ""
      Else
         Complete = 1                                          'String is complete set the flag
         Instring2 = Instring
      End If
   End If

   If Startbyte = &H3A Then                                    'we have previously received the start byte and this is now data
      If Temp > &H0F Then                                      'Add incoming data to buffer
         Instring = Instring + Chr(temp)
         If Len(instring) > 45 Then Instring = ""              'String is to long, reset and startover again
      End If
   End If

   If Temp = &H3A Then                                         'if we received an : then its the beginning of an new line.
      Startbyte = Temp
      Complete = 0
      Instring = ""
   End If
Return
