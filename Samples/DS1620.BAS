'-----------------------------------------------------------------------------
'                          (c) 1999-2013 MCS Electronics
'                    DS1620.BAS  A Temperature sensor sample
'  This example shows how you can mix assembly with BASIC
'  Note that the  DS1620 stores the temperature in twos complement.
'-----------------------------------------------------------------------------

$RegFile = "m88def.dat"
$crystal = 8000000
$Baud = 19200
$HWstack = 40
$SWstack = 40
$FrameSize = 40


'[ALIAS PINS for better reading and easy changing]
Ds_rst1 Alias Portb.7                     'reset pin. Connect to pin 3
Ds_rst2 Alias Portb.5                     'reset pin. Connect to pin 3
Ds_dat Alias Portb.4                      'DQ(data pin). Connect to pin 1
Ds_dati Alias Pinb.4                      'DQ(data pin). Used for reading
Ds_clk Alias Portb.6                      'Clock pin. Connect to pin 2

'[DIM GLOBAL variables]
Dim Temperature As Word
Dim Dum As Byte , Command As Byte , Readwrite As Byte , Wdata As Word
Dim Dummy as word

'[DECLARE SUBS]
Declare Sub Dsinit (byval which as byte)
Declare Sub Ds1620(byval which as byte , byval Cmd As Byte , Byval Rw As Byte , Wdata As Word)


'[Init program]
Dsinit 1                                  'init chip 1
Dsinit 2                                  'init chip 2
Wdata = 27 : Shift Wdata , Left           'set high temperature limit to 27 C
Ds1620 1 , &H01 , 0 , Wdata               'write high temp set data to chip
Wdata = 28 : Shift Wdata , Left           'set high temperature limit to 28 C
Ds1620 2 , &H01 , 0 , Wdata               'write high temp set data to chip

Wdata = 25 : Shift Wdata , Left           'set low temperature limit to 25 C
Ds1620 1 , &H02 , 0 , Wdata               'write low temp set data to chip
Wdata = 26 : Shift Wdata , Left           'set low temperature limit to 26 C
Ds1620 2 , &H02 , 0 , Wdata               'write low temp set data to chip

'[MAIN program]
Do
   'do ds1620 #1
   Ds1620 1 , &HAA , 1 , Temperature      'read temperature
   Dum = Low(temperature) And 1           'get the LS bit (indicates 0,5 C)

   Shift Temperature , Right              'place bits into right place (divide by 2)
   Print "T1 = " ; Temperature ; "." ;    'print temp
   If Dum = 1 Then Print "5" Else Print "0"       'was there a half degree step?

   Ds1620 1 , &HAC , 1 , Wdata : Print "Config 1 = " ; Hex(wdata);       'get config register
   Dummy = wdata and 64
   if Dummy > 0 then
      Print " Over temperature";
   end if
   Dummy = wdata and 32
   if Dummy > 0 then
      Print " Under temperature";
   end if
   Print " "

   Ds1620 1 , &HA1 , 1 , Wdata : Dummy = Wdata / 2 : Print Hex(wdata) ; " T high = " ; Dummy       'get temp high
   Ds1620 1 , &HA2 , 1 , Wdata : Dummy = Wdata / 2 : Print Hex(wdata) ; " T low = " ; Dummy       'get temp low

   Wdata = 2
   Ds1620 1 , &H0C , 0 , Wdata            'reset config, clear TH,TL


   'do ds1620 #2
   Ds1620 2 , &HAA , 1 , Temperature      'read temperature
   Dum = Low(temperature) And 1           'get the LS bit (indicates 0,5 C)

   Shift Temperature , Right              'place bits into right place (divide by 2)
   Print "T2 = " ; Temperature ; "." ;    'print temp
   If Dum = 1 Then Print "5" Else Print "0"       'was there a half degree step?

   Ds1620 2 , &HAC , 1 , Wdata : Print "Config 2 = " ; Hex(wdata);       'get config register
   Dummy = wdata and 64
   if Dummy > 0 then
      Print " Over temperature";
   end if
   Dummy = wdata and 32
   if Dummy > 0 then
      Print " Under temperature";
   end if
   Print " "

   Ds1620 2 , &HA1 , 1 , Wdata : Dummy = Wdata / 2 : Print Hex(wdata) ; " T high = " ; Dummy       'get temp high
   Ds1620 2 , &HA2 , 1 , Wdata : Dummy = Wdata / 2 : Print Hex(wdata) ; " T low = " ; Dummy       'get temp low

   Print " "                              'blank line

   Wdata = 2
   Ds1620 2 , &H0C , 0 , Wdata            'reset config, clear TH,TL

   Wait 3
Loop


sub dsinit(byval which as byte)
   Portb = &B01000000                     'set initial state
   Ddrb = &B11110000                      'set data direction

   Waitms 1
   select case which
      case 1 : Set Ds_rst1                   'set reset
      case 2 : Set Ds_rst2                   'set reset
   end select
!  ldi r16,$0C                            'write config command
!  rcall Wbyte                            'write the byte
!  ldi r16,2                              'cpu = 1
!  rcall Wbyte                            'write byte
   select case which
      case 1 : Reset Ds_rst1              'set reset
      case 2 : Reset Ds_rst2              'set reset
   end select
   Waitms 100                             'waste time to store value in eeprom

   select case which
      case 1 : Set Ds_rst1                   'set reset
      case 2 : Set Ds_rst2                   'set reset
   end select
!  ldi r16,$EE                            'start conversion
!  rcall Wbyte                            'write byte
   select case which
      case 1 : Reset Ds_rst1              'set reset
      case 2 : Reset Ds_rst2              'set reset
   end select
End Sub

'ASM subroutine
'uses R25
'IN : R16 , byte to write
'OUT : -
Wbyte:
!  ldi r25,8                               'load loop counter
Wbyte1:
  Reset Ds_dat                            'reset data bit
!  lsr r16                                 'shift in carry
!  brcc Wbyte2                             'jump if cleared
  Set Ds_dat                              'set data bit to 1

Wbyte2:
!  rcall Smallwait                         'wait
  Reset Ds_clk                            'clock low
!  rcall Smallwait                         'wait
  Set Ds_clk                              'clock high
!  dec r25                                 'decrease loop counter
!  brne Wbyte1                             'if not done 8 bits do it again
!ret                                       'return

'BASIC/ASM SUBROUTINE
'IN : cmd, command byte
'     rw,  0 for Writing, 1 for Reading
'     wdata, data to write or read

'Note that in some cases 9 bits must be read/written
'We write/read 16 bits. But this is no problem for the chip
'Values of CMD can be:
'&HAA  - read temperature
'&H01  - write temperature High
'&H02  - write temperature Low
'&HA1  - read temperature High
'&HA2  - read temperature Low
'&HA0  - read counter
'&HA9  - read slope
'&HEE  - start conversion
'&H22  - stop conversion
'&H0C  - write config register
'&HAC  - read config register
'The config register has 7 bit flags
'BIT7  BIT6  BIT5  BIT4  BIT3  BIT2  BIT1  BIT0
'DONE  THF   TLF   NVB   1     0     CPU   1SHOT
'DONE - conversion done bit. 1 = conversion in progress
'THF - Temp high flag. Set 1 when temp is greater or equal to TH (set with &H01)
'TLF - Temp low flag. Set 1 when temp is lower or equal to TL (set with &H02)
'      THF and TLF must be cleared by writing to the config register
'NVB - Non volatile busy flag. 1 = write in progress
'CPU - CPU use bit. CPU=1 will operate in 3-wire mode that this example uses
'1SHOT- One shot mode when set. We use continious mode (0)

sub ds1620(byval which as byte, byval cmd as byte, byval rw as byte, wData as word)
   Set Ds_dat                             'set DQ to 1
   Set Ddrb.4                             'set data direction to output
   select case which
      case 1 : Set Ds_rst1                'enable communication
      case 2 : Set Ds_rst2                'enable communication
   end select

   Loadadr Cmd , X                        'load address of cmd into X(R26:R27)
!  ld R16,X                               'get value into r16
!  rcall Wbyte                            'write command byte

   If Rw = 1 Then                         'we want to read
      Loadadr Wdata , X                   'load X pointer with address of data variable
      Reset Ddrb.4                        'now it is an input pin
!     ldi r24,2                           'read 2 bytes
Getds1620_3:
!     ldi r25,8                           '8 bits to get
'      clr r16
Getds1620_2:
      Reset Ds_clk                        'clock low
!     rcall Smallwait                     'wait
!      clc                                 'clear carry
!      sbic PINB,4                         'if bit is 0 skip next instruction
!      sec                                 'set carry
!      ror r16                             'rotate c flag into r16
      Set Ds_clk                          'clock high
!      rcall Smallwait                     'wait
!      dec r25                             'decrease loop counter
!      brne Getds1620_2                    'again for 8 bits
!      st x+,r16                           'done 8 bits so store in variable
!      dec r24                             'byte counter
!      brne Getds1620_3                    'do for 2 bytes
   Else                                   'we want to write
      Loadadr Wdata , X                   'load X pointer with address of data variable
!      ld R16,X+                           'get value into R16
!      rcall Wbyte                         'write byte
!      ld R16,X                            'get MSB of data
!      rcall Wbyte                         'and write
   End If

   select case which
      case 1 : Reset Ds_rst1              'end of communication
      case 2 : Reset Ds_rst2              'end of communication
   end select
End Sub

'ASM SUB routine
'USES : R23
'IN : -
'OUT : -
Smallwait:
!  ldi r23,20                              'load register 23 with 20
Smallwait1:
!  dec r23                                 'decrease register content
!  brne Smallwait1                         'if not zero, loop to smallwait1
!ret

