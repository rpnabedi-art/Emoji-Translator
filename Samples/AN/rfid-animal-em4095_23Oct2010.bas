$regfile = "m8def.dat"
$hwstack = 64
$swstack = 64
$framesize = 64
$crystal = 7372800
$baud = 9600
Config Com1 = Dummy , Synchrone = 0 , Parity = None , Stopbits = 1 , Databits = 8 , Clockpol = 0



'Configure some pins used to control the em4095 chip
Shd_pin Alias Portc.1                                       'A High level voltage forces the em4095 circuit into sleep mode
Mod_pin Alias Portc.2                                       'A High level voltage modulates the em4095 antenna
Config Shd_pin = Output
Config Mod_pin = Output
Reset Mod_pin                                               'Sleep mode is off
Reset Shd_pin                                               'No modulation


'Dimension the variables needed to run the readhitag command
'-------------------------------------------------------------------------------------------------
'
'You need 10 bytes to store the tag data
Dim Tagdata(10) As Byte
'The tag id will be in byte 1,2,3,4 and 5 of tagdata (LS-Byte to MS-Byte)

'The Countrycode will be in the 6. and 7. byte of tagdata
Dim Country As Word At Tagdata(6) Overlay

'Readhitag will give a error code back
'You need one byte to store the error code
Dim Tag_err As Byte
'Error code is:
'0 = timeout, no valid id read
'1 = a sync was received but the crc was wrong
'2 = a valid tag id was received, the crc was ok

'You need a string with 12 characters if you want to convert the binary id into a decimal ascii id
'The id of the animal transponder is given in decimal, e.g. your cat could have a transponder
'with the id "094190000056", this would be in Hex "15EE2957B8". In your "Certification of
'Vaccination" for your cat you would find that number in decimal (276094190000056). The 276 in that
'number is the country code, in this case the code for Germany.
Dim Str_tagid As String * 12


'Use of the AnimalID EM4095 Library
'-------------------------------------------------------------------------------------------------
'
'Instead of Timer0 you can use Timer2 if the Chip has one.
'To use Timer2 define a constant with "Const _htrc_timer = 2"
'To use Timer0 as in the original library define "Const _htrc_timer = 0" or omit this line.
Const _htrc_timer = 0

'with _HTRC_FRAME=1 the timing of the received signal will stricter be proved, this
'needs more program space, but avoids false "sync received" states (Basic HTRC Error code 1)
'the "valid tag received" state is not affected, but the receiving range can be a bit shorter
Const _htrc_frame = 1

'use the AnimalID-Library
$lib "AnimalID_em4095.lib"

'Hitag= 64      -> divider for the used timer
'Type = Htrc110 -> set constants and variables as for the htrc110.lib
'Dout = PIN...  -> Pin used to read the em4095 output "Demod_Out"
'Int  = @INT0   -> The used interrupt
Config Hitag = 64 , Type = Htrc110 , Dout = Pind.2 , Int = @int0

'The function "ID2String" will convert the 5 byte ID from the tag into a ascii string. You need a string
'with a length of min. 12 bytes.
$external Id2string
Declare Function Id2string() As String
'
'-------------------------------------------------------------------------------------------------
'END of "Use of the AnimalID HTRC110 Library"



On Int0 Checkints Nosave                                    ' PIND.2 is INT0
Config Int0 = Change                                        'you must configure the pin to work in pin change intertupt mode
Enable Interrupts

Print
Print "Animal ID Reader with em4095"
Wait 1

Do
   Tag_err = Readhitag(tagdata(1))                          'try to receive an id
   Str_tagid = Id2string()                                  'convert the received bytes into decimal

   If Tag_err = 2 Then                                      'sync and crc was ok -> the tag id is ok
      Print
      'transmit the decimal id
      Print Country ; Str_tagid ; " dec "
      'and the hex
      Print Hex(country) ; " " ; Hex(tagdata(5)) ; Hex(tagdata(4)) ; Hex(tagdata(3)) ; Hex(tagdata(2)) ; Hex(tagdata(1)) ; " Hex"
   Else
      If Tag_err = 1 Then                                   'only sync was ok. crc was false
         Print "'";
      Else
         Print ".";                                         'Tag_err=0 -> no sync was received, no valid crc, no valid tag id
      End If
   End If
   Waitms 200                                               'wait a little
Loop


'this routine is called by the interrupt routine
Checkints:
  Call _checkhitag                                          'you must call this label
Return
