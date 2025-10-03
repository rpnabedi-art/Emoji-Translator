'-----------------------------------------------------------------------------------------------------
'name                     : 1wireDS2450.bas
'copyright                : (c) 1995-2015, MCS Electronics
'purpose                  : demonstrates use of the Dallas Semi Conductor DS2450S 1-Wire A/D convertor
'micro                    : Mega48
'suited for demo          : yes
'commercial addon needed  : no
' pull-up of 4K7 required to VCC from Portb.3
' DS2450S serial A/D Converter connected to Portb.3
'
' Channels A & B are set up for 16bit resolution and 5.12 volt input range
'
' Channels C & D are switched outputs for control
'-----------------------------------------------------------------------------------------------------

$regfile = "m48def.dat"
$crystal = 8000000

$hwstack = 32                                               'default use 32 for the hardware stack
$swstack = 10                                               'default use 10 for the SW stack
$framesize = 40                                             'default use 40 for the frame space

Config 1wire = Portb.3                                      'use this pin
'On the STK200 jumper B.3 must be inserted
Dim Dummy As Byte , I As Byte , Highbyte(4) As Byte , Lowbyte(4) As Byte
Dim Crcread As Byte , Adval As Word
'Dim Volts As Single , Chvolts As Single

Const 16_bit = 65535

Declare Sub Crc_get()                                       'this sub makes two reads for the CRC16 bytes from the 1-wire bus

'***********************************1-WIRE Command Constants*********************************
Const 1w_readmem = &HAA
Const 1w_writemem = &H55
Const 1w_convertch = &H3C
Const 1w_readrom = &H33
Const 1w_matchrom = &H55
Const 1w_skiprom = &HCC
Const 1w_searchrom = &HF0
Const 1w_conditsrc = &HEC
Const 1w_ovdrvskprom = &H3C
Const 1w_ovdrvmtchrom = &H69
Const 1w_vccoperation = &H40
'***********************************DS2450 Command Summary***********************************
'AAh = Read Memory
'55h = Write Memory(master TXs to the slave in a single drop mode)
'3Ch = Convert (immediately followed by Converson Mask byte and Preset Mask byte)
'33h = Read ROM
'55h = Match ROM (used to identify a single address on 1-wire bus)
'CCh = Skip Rom (can be used on single drop applications)
'F0h = Search ROM (used to search and identify mutiple bus address)
'ECh = Conditional Search
'3Ch = Overdrive Skip ROM (used to skip ROM when in Overdirve TX speed)
'69h = Overdrive Match ROM (used to identify a address when in Overdrive TX speed)

'***********************************END 1-WIRE Command Constants*****************************


'************************************BEGIN DS2450 Setup**************************************


'***************Setup device upon startup*******************************
'IF 1-WIRE device is Vcc powered 40h must be written to address 001Ch.  This causes
'the device to remain powered during conversion and frees the uProcessor to do
'other things and then return to read the conversion results.

1wreset                                                   'reset the device

'*************************Setup 2450 device for VCC operation*********************************
1wwrite 1w_skiprom                                        'Skip ROM
1wwrite 1w_writemem                                       'Write Memory
1wwrite &H1C                                              'Write to 001C
1wwrite &H00
1wwrite 1w_vccoperation                                   'VCC Operation keeps device active!!

Crc_get                                                   'Read in 2 bytes 16bits
Dummy = 1wread(1)                                         'read dummy byte

'*************************END Setup 2450 device for VCC operation*********************************

'**************Setup device channels for operations***********************************************
'Channel setup Notes: Memory Page for Channel Setup begins at 08H thru 0FH
'Channel A shown other similar
'Channel A Control register configuration Address 08h
' OE OC DC DC RC3 RC2 RC1 RC0
'msb                      lsb
'OE = Output Enable 1 enables output 0 disables output
'OC = Output Control if OE=1 then OC=1 Output is OFF OC=0 Output is ON
'DC = Dont Care or "0"
'RC3-RC0 = Channel Resolution 0000=16 bits 1111=15 bits
'
'Channel A Control register configuration Address 09h
' POR DC AFH AFL AEH AEL DC IR
'msb                       lsb
'POR = Power On Reset 'set this to 0 to clear after configuration
'DC = Dont Care or "0"
'AFH = Alarm Flag High Limit - ADC result is greater than high alarm limit
'AFL = Alarm Flag Low Limit - ADC result is less than low alarm limit
'AEH = Alarm Enable High limit if AEH=1 then alarm limit is enabled
'AEL = Alarm Enable Low limit if AEL=1 then alarm limit is enabled
'IR = Input Resolution IR=0 2.56V/resolution IR=1 5.12V/resolution
'
'Repeat for other channels incrementing the address accordingly


1wreset                                                   'reset the device
'Write to locations beginning at 00 08
1wwrite 1w_skiprom                                        'Skip ROM
1wwrite 1w_writemem                                       'Write Memory
1wwrite &H08                                              'Write to 00 08
1wwrite &H00


' Set up Channel A for 16 bit resolution
1wwrite &H00                                              '16 bit resoultion
Crc_get                                                   'Read in 2 bytes 16bits
Dummy = 1wread(1)                                         'read dummy byte
' 5.12 Volt range
1wwrite &H01                                              '5.12 Volt Range
Crc_get                                                   'Read in 2 bytes 16bits
Dummy = 1wread(1)                                         'read dummy byte

' Set up Channel B for 16 bit resolution
1wwrite &H00                                              '16 bit resoultion
Crc_get                                                   'Read in 2 bytes 16bits
Dummy = 1wread(1)                                         'read dummy byte
' 5.12 Volt range
1wwrite &H01                                              '5.12 Volt Range
Crc_get                                                   'Read in 2 bytes 16bits
Dummy = 1wread(1)                                         'read dummy byte

  ' Set up Channel C for output 1
1wwrite &HC0                                              'Output Open/Output OFF C0 is OFF 80 is ON
Crc_get                                                   'Read in 2 bytes 16bits
Dummy = 1wread(1)                                         'read dummy byte
' 5.12 Volt range
1wwrite &H00                                              'Doesn't matter space keeper
Crc_get                                                   'Read in 2 bytes 16bits
Dummy = 1wread(1)                                         'read dummy byte

' Set up Channel D for output 0
1wwrite &HC0                                              'Output Open/Output OFF
Crc_get                                                   'Read in 2 bytes 16bits
Dummy = 1wread(1)                                         'read dummy byte
' 5.12 Volt range
1wwrite &H00                                              'Doesn't matter space keeper
Crc_get                                                   'Read in 2 bytes 16bits
Dummy = 1wread(1)                                         'read dummy byte
'************************************END DS2450 Setup**************************************
Do

   Wait 1                                                      'misc delay for RS-232 output

'******************************Begin Conversion in DS2450**********************************
'Conversion Notes: When the conversion command is issued h3C it is followed by the
'Conversion Mask byte and then the Preset Mask byte
'the channel can be continously read until the result is FFh which indicates
'conversion has been completed.
'
'Alternatively you can go do other things for a minimum of 160uSec+(no Cha*resolution*80us)
'if the DS2450 is Vcc powered.  If not must provide strong pullup to pin for this time.

'Conversion Mask and Register Preset configuration
'Convert Mask
'DC DC DC DC ChD ChC ChB ChA
'DC = Dont Care or "0"
'ChD-ChA = Set bit to 1 to enable conversion of that channel 0= no conversion
'Preset Mask
'Sd Cd Sc Cc Sb Cb Sa Ca
'S = Set causes data register for channel (a-d)to be set to all 1's
'C = Clear causes data register for channel (a-d)to be set to all 0's


   1wreset                                                   'reset the device

   1wwrite 1w_skiprom                                        'Skip ROM
   1wwrite 1w_convertch                                      'Begin Conversion
   1wwrite &H0F                                              'Convert Mask 0000|DCBA ie 0F=0000|1111
   1wwrite &H00                                              'Preset Mask Set=D Clear=d DdCcBbAa ie 55=0101|0101

   Crc_get                                                   'Read in 2 bytes 16bits

   'Do
     ' Dummy = 1wread(1)                                  'read dummy byte  if you are going to POLL data
   'Loop Until Dummy = &HFF                              'until end of conversion =HFF

   Waitms 6                                                  'use formula to calculate exact duration for channels
'******************************End DS2450 Conversion***************************************

'******************************Read DS2450 Conversion Results******************************
   1wreset                                                   'reset the device
   1wwrite 1w_skiprom                                        'Skip ROM
   1wwrite 1w_readmem                                        'Read Memory
   1wwrite &H00                                              'Read Channel A
   1wwrite &H00                                              'Address 0000 and 0001

   For I = 1 To 4
      Lowbyte(i) = 1wread(1)
      Highbyte(i) = 1wread(1)
   Next
'*************************************Format Results**************************************
   For I = 1 To 4
      Adval = Makeint(lowbyte(i) , Highbyte(i))
      ' uncomment the two lines below for formatting the output on other than 2k devices

      'Chvolts = Adval \ 16_bit * 5.12
      'Print "ChNo :"; I ; Chvolts

      'comment the two lines below for formatting the output on other than 2k devices
      Adval = Makeint(lowbyte(i) , Highbyte(i))
      Print I ; "CHA " ; Adval
      'Print   Bin(lowbyte(i)) ; Bin(highbyte(i))

   Next
'************************************End Format Results**********************************

'******************************End  DS2450 Conversion Results******************************

Loop

Sub Crc_get()                                               'this sub ensures that all crc operations are handled the same
   Crcread = 1wread(2)
   'Crcread = 1wread()
End Sub