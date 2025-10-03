'----------------------------------------------------------------
'                  (c) 1995-2011, MCS
'                 DS2482-100_XMEGA.bas
'  This sample demonstrates the I2C to 1wire bridge
'  contributed by MAK3
'-----------------------------------------------------------------

' Example for I2C to 1-Wire Bridge
' MAXIM DS2482-100
' Functions according Datasheet     http://datasheets.maxim-ic.com/en/ds/DS2482-100.pdf
' I2C Address = &H36 (A0 = High , A1 = High)

' I²C Host Interface, Supports 100kHz and 400kHz I²C Communication Speeds
' 1-Wire Master IO with Selectable Active or Passive 1-Wire Pullup
' Standard and Overdrive 1-Wire Communication Speeds
' Internal, factory-trimmed timers relieve the system host processor from generating time-critical 1-Wire waveforms

$RegFile = "xm128a1def.dat"                       'ATXMEGA128A1
$Crystal = 32000000                               '32MHz
$HWstack = 84
$SWstack = 80
$FrameSize = 80


Config Osc = Enabled , 32mhzosc = Enabled         '32MHz
Config Sysclock = 32mhz                           '32MHz

Config Com1 = 57600 , Mode = Asynchroneous , Parity = None , Stopbits = 1 , Databits = 8
Open "COM1:" For Binary As #1
WaitmS 2
Print
Print "---Example for DS2482-100 I2C to 1-WIRE Bridge---"
Print

Config Priority = Static , Vector = Application , Lo = Enabled , Med = Enabled , Hi = Enabled


'Init I2C Interface on Port D
Dim Twi_start As Byte                             ' This Variable is used by the I2C functions
Open "TWID" For Binary As #2                      ' Pull-Up resistor (4K7) on SDA and SCL to Vcc = 3,3V
'Portd.0                                           ' SDA Pin of Port D (ATXMEGA128A1)
'Portd.1                                           ' SCL Pin of Port D (ATXMEGA128A1)
Config Twid = 100000                              ' Set TWI Baud Rate and Enable TWI Master
I2Cinit #2                                        ' set i2c pins to right state , open collector , pull up activated

'--------------------------------------------------------------------------------

Dim K As Byte
Dim Temperature As Integer
Dim Temp_single As Single
Dim Fahrenheit As Single
Dim Ds2482_status As Byte
Dim Ds2482_error As Byte                          '0 = OK , 1 = ERROR
Dim Rom(8) As Byte                                '8Byte Array for ROM Data
Dim 1_wire_presence As Byte                       '= 1-Wire Presence_pulse_detect (Bit 1 from  DS2482 Status Register)
Dim Scratchpad(9) As Byte                         'DS18B20 or DS18S20  Scratchpad




'DS2482-100-Constants
Const Ds2482_addr = &H36                          'I2C address = &h36 (A0 = High, A1 = High)
Const Ds2482_addr_read = &H37
Const Drst = &HF0                                 'Command "Device Reset", F0h
Const Wcfg = &HD2                                 'Command "Write Configuration", D2h
Const Srp = &HE1                                  'Command "Set Read Pointer", E1h
Const Wrst = &HB4                                 'Command "1-Wire Reset", B4h
Const Wwb = &HA5                                  'Command "1-Wire Write Byte", A5h
Const Wrb = &H96                                  'Command "1-Wire Read Byte", 96h
Const Wsb = &H87                                  'Command "1-Wire Single Bit", 87h
Const Wt = &H78                                   'Command "1-Wire Triplet", 78h

'DS2482-100 REGISTER Address
Const Ds2482_sreg = &HF0                          'Status Register
Const Dreg = &HE1                                 'Read Data Register
Const Creg = &HC3                                 'Configuration REGISTER

'1-Wire commands over DS2482-100
Const Read_rom = &H33                             'Read ROM
Const Match_rom = &H55                            'Match ROM
Const Skip_rom = &HCC                             'Skip ROM
Const Search_rom = &HF0                           'Search ROM

'DS2482-100 Sub's
Declare Sub Ds2482_init()
Declare Sub Ds2482_1_wire_reset()
Declare Sub Ds2482_write_byte(ByVal Sendbyte As Byte)
Declare Sub Ds2482_read_byte(read_data As Byte)
Declare Sub Ds2482_get_rom()                      'READ ROM
Declare Sub Ds2482_match_rom()



Main:

Call Ds2482_init()
Call Ds2482_1_wire_reset()

Print "Now we Read the ROM of the 1-Wire Device..."
Call Ds2482_get_rom()

Print "ROM = " ;
For K = 1 To 8
  Print Rom(K) ; "   " ;
Next
Print

' print 1-Wire Family (DS18B20 or DS2405.......)
Print "It is a " ;
Select Case Rom(1)                                ' First Byte is 1-Wire Family Code
  Case &H05 : Print "DS2405"
  Case &H10 : Print "DS18S20"
  Case &H20 : Print "DS2450"
  Case &H27 : Print "DS2417"
  Case &H28 : Print "DS18B20"
  Case Else
    Print "Unknown Family Code"
    If 1_wire_presence = 0 Then Print "There is no 1-Wire Device !"
End Select
Print



Do

  Call Ds2482_match_rom()                           'Match ROM
  Call Ds2482_write_byte(&H44)                      'initiates the first temperature conversion

  Wait 1                                            'A Better option than wait 1 would be using a Counter but this is easier for an example

  Call Ds2482_match_rom()                           'Match ROM
  Call Ds2482_write_byte(&HBE)                      'READ SCRATCHPAD [BEh]


  For K = 1 To 9
    Call Ds2482_read_byte(Scratchpad(K))
  Next K

  If Scratchpad(9) = Crc8(Scratchpad(1) , 8) Then   'Cyclic Redundancy Check
    Temperature = MakeInt(Scratchpad(1) , Scratchpad(2))

    'Check for 1-Wire Family Code
    If Rom(1) = &H28 Then Temp_single = Temperature * 0.0625       ' This is for DS18 B 20  with  12-bit resolution
    If Rom(1) = &H10 Then Temp_single = Temperature * 0.5       ' This is for DS18 S 20 with  9-bit resolution or DS18B20 with 9-Bit resolution

    'Celsuis
    Print Fusing(Temp_single , "#.#") ; " °C" ; "  " ;

    'Fahrenheit
    Fahrenheit = Temp_single * 9
    Fahrenheit = Fahrenheit / 5
    Fahrenheit = Fahrenheit + 32
    Print Fusing(Fahrenheit , "#.#") ; " °F"
  End If

Loop

End                                               'end program


'INIT
Sub Ds2482_init()
  Local X As Byte
  I2Cstart #2
  I2CWbyte Ds2482_addr , #2                   'I2C address from DS2482
  I2CWbyte Drst , #2                          'Command "Device Reset", F0h
  I2CrepStart #2
  I2CWbyte Ds2482_addr_read , #2
  I2CRbyte X , Nack , #2                      'READ STATUSREGISTER (Read Pointer points already to Status Register)
  Ds2482_status = X
  I2Cstop #2
End Sub


'1-WIRE RESET
Sub Ds2482_1_wire_reset()
  Local X As Byte , Poll As Byte

  I2Cstart #2
  I2CWbyte Ds2482_addr , #2
  I2CWbyte Wrst , #2                            'Command "1-Wire Reset", B4h
  I2CrepStart #2
  I2CWbyte Ds2482_addr_read , #2                'I2C Lese-Adresse von DS2482

  'loop checking 1WB bit for completion of 1-Wire operation
  ' abort if poll limit reached (poll limit = 20)
  For Poll = 1 To 20
    I2CRbyte X , Ack , #2                      'Read Status Register

    'The PPD bit (Presence_pulse_detect) is updated with every 1-Wire Reset command.
    'If the DS2482 detects a presence pulse from a 1-Wire device at tMSP during
    'the Presence Detect cycle, the PPD bit will be set to 1.
    If X.1 = 1 Then
      1_wire_presence = 1                  '1-Wire Device present
    Else
      1_wire_presence = 0                  'No 1-Wire Device present
    End If

    If X.0 = 0 Then                            'Is Bit0 = 0 --> 1-Wire line is free (The 1WB bit reports to the host processor whether the 1-Wire line is busy.)
      Ds2482_error = 0
      Exit For                                'When Line is free exit For Loop
    End If
  Next

  I2CRbyte X , Nack , #2                        'Read Status Register
  Ds2482_status = X
  If X.0 = 1 Then Ds2482_error = 1              ' Error when line is still not free
  I2Cstop #2
End Sub

'WRITE BYTE
Sub Ds2482_write_byte(sendbyte As Byte)
  Local X As Byte , Poll As Byte

  I2Cstart #2
  I2CWbyte Ds2482_addr , #2
  I2CWbyte Wwb , #2                             ' Command "1-Wire Write Byte", A5h
  I2CWbyte sendbyte , #2                        ' Send 1-Wire command like e.g.  &h33 for Read ROM

  I2CrepStart #2
  I2CWbyte Ds2482_addr_read , #2                'Read Address of DS2482

  'loop checking 1WB bit for completion of 1-Wire operation
  ' abort if poll limit reached (poll limit = 20)
  For Poll = 1 To 20
    I2CRbyte X , Ack , #2                      'Read Status Register

    'The PPD bit (Presence_pulse_detect) is updated with every 1-Wire Reset command.
    'If the DS2482 detects a presence pulse from a 1-Wire device at tMSP during
    'the Presence Detect cycle, the PPD bit will be set to 1.
    If X.1 = 1 Then
      1_wire_presence = 1                  '1-Wire Device present
    Else
      1_wire_presence = 0                  'No 1-Wire Device present
    End If

    If X.0 = 0 Then                            'Is Bit0 = 0 --> 1-Wire line is free (The 1WB bit reports to the host processor whether the 1-Wire line is busy.)
      Ds2482_error = 0
      Exit For                                'When Line is free exit For Loop
    End If
  Next

  I2CRbyte X , Nack , #2                        'Read Status Register
  Ds2482_status = X
  If X.0 = 1 Then Ds2482_error = 1              ' Error when line is still not free
  I2Cstop #2
End Sub

'READ BYTE
Sub Ds2482_read_byte(read_data As Byte)
  Local X As Byte , Poll As Byte

  I2Cstart #2
  I2CWbyte Ds2482_addr , #2
  I2CWbyte Wrb , #2                             'Command "1-Wire Read Byte", 96h

  I2CrepStart #2
  I2CWbyte Ds2482_addr_read , #2

  'loop checking 1WB bit for completion of 1-Wire operation
  ' abort if poll limit reached (poll limit = 20)
  For Poll = 1 To 20
    I2CRbyte X , Ack , #2
    If X.0 = 0 Then                            'The 1WB bit reports to the host processor whether the 1-Wire line is busy.
      Ds2482_error = 0
      Exit For                                 'When Line is free exit For Loop
    End If
  Next

  I2CRbyte X , Nack , #2
  If X.0 = 1 Then Ds2482_error = 1             ' Error when line is still not free

  I2CrepStart #2
  I2CWbyte Ds2482_addr , #2
  I2CWbyte Srp , #2                            'Command "Set Read Pointer", E1h
  I2CWbyte Dreg , #2                           '&HE1   Read Data Register

  I2CrepStart #2
  I2CWbyte Ds2482_addr_read , #2
  I2CRbyte read_data , Nack , #2               'Read one Byte
  I2Cstop #2
End Sub


'GET ROM
Sub Ds2482_get_rom()
  Local X As Byte

  Call Ds2482_1_wire_reset()
  Call Ds2482_write_byte(Read_rom)              'Read_rom = &H33

  For X = 1 To 8
    Call Ds2482_read_byte(Rom(X))
  Next X
End Sub


'MATCH ROM
Sub Ds2482_match_rom()
  Local X As Byte

  Call Ds2482_1_wire_reset()
  Call Ds2482_write_byte(Match_rom)            'Match_rom = &H55
  For X = 1 To 8
    Call Ds2482_write_byte(Rom(X))
  Next X

End Sub




