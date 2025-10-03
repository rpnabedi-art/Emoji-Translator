'----------------------------------------------------------------------------
'                PC AT-KEYBOARD Sample
'              (c) 2001-2013 MCS Electronics
'----------------------------------------------------------------------------
'For this example :
'connect PC AT keyboard clock to PIND.2 on the 8535
'connect PC AT keyboard data to PIND.4 on the 8535

$RegFile = "8535def.dat"
'The GetATKBD() function does not use an interrupt.
'But we use INT0 to handle it with interrupts


'configure the pins to use for the clock and data
'can be any pin that can serve as an input
'Keydata is the label of the key translation table
Config Keyboard = Pind.2 , Data = Pind.4 , Keydata = Keydta

'variables needed for the buffer
Const Bufsize = 10
Dim Buf As String * Bufsize , _rkbd As Byte , _wkbd As Byte , _ckbd As Byte

'we need int0 that gets triggered when there is a key pressed
On Int0 Isr0 Nosave
Enable Int0
Enable Interrupts

'Dim some used variables
Dim S As String * 12
Dim B As Byte

'In this example we use SERIAL(COM) INPUT redirection
$serialinput = Mykbd

'Show the program is running
Print "hello"

Do
   'The following code is remarked but show how to use the GetATKBD() function
   ' B = Getatkbd()     'get a byte and store it into byte variable
   'When no real key is pressed the result is 0
   'So test if the result was > 0
   ' If B > 0 Then
   '    Print B ; Chr(b)
   ' End If

   'The purpose of this sample was how to use a PC AT keyboard
   'The input that normally comes from the serial port is redirected to the
   'external keyboard so you use it to type

   ' the wait will demonstrate that it works on the background
   wait 1
   Input "Name " , S
   'and show the result
   Print S
Loop
End


' this routine gets called when INPUT is used
'it expects the data in R24
$Asm
Mykbd:
   lds r24,{_ckbd}                  ; get counter
   tst r24
   breq mykbd                      ;0 so test again

   dec r24                         ;adjust counter byte
   sts {_ckbd},r24                  ;store

   push r25                        ;save
   lds r25,{_rkbd}                  ;get read pointer
   Loadadr Buf , X
   add r26,r25
   clr r24
   adc r27,r24
   ld r24,x
   inc r25
   cpi r25,Bufsize
   brne mykbd1
   clr r25
Mykbd1:
   sts {_rkbd},r25
   pop r25
   Ret
$End Asm

'Since we do a redirection we call the routine from the redirection routine
'
Isr0:
   'we come here when input is required from the COM port
   'So we pass the key into R24 with the GetATkbd function
   ' We need some ASM code to save the registers used by the function
   $asm
      push r16           ; save used register
      push r25
      push r26
      push r27
      push r24
      in r24,sreg
      push r24

      rCall _getatkbd    ; call the function
      tst r24            ; check for zero
      breq Kbdinput1a    ; yes
      push r24
      lds r25,{_ckbd}    ; get byte counter
      inc r25
      sts {_ckbd},r25    ; save number of bytes in buffer
      lds r25,{_wkbd}    ; get write pointer
      Loadadr Buf , X
      add r26,r25        ; add pointer to it
      clr r24
      adc r27,r24
      pop r24
      st x,r24           ; save data in buffer

      inc r25            ; increase write buffer pointer
      cpi r25,Bufsize    ; is it at the end?
      Brne kbdinput1
      clr r25
Kbdinput1:
      sts {_wkbd},r25    ; save write pointer
Kbdinput1a:
      pop r24
      Out Sreg , R24
      pop r24
      pop r27            ; we got a valid key so restore registers
      pop r26
      pop r25
      pop r16
   $end Asm
   'just return
Return


B = Getatkbd()

'This is the key translation table

Keydta:
   'normal keys lower case
   Data 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , &H5E , 0
   Data 0 , 0 , 0 , 0 , 0 , 113 , 49 , 0 , 0 , 0 , 122 , 115 , 97 , 119 , 50 , 0
   Data 0 , 99 , 120 , 100 , 101 , 52 , 51 , 0 , 0 , 32 , 118 , 102 , 116 , 114 , 53 , 0
   Data 0 , 110 , 98 , 104 , 103 , 121 , 54 , 7 , 8 , 44 , 109 , 106 , 117 , 55 , 56 , 0
   Data 0 , 44 , 107 , 105 , 111 , 48 , 57 , 0 , 0 , 46 , 45 , 108 , 48 , 112 , 43 , 0
   Data 0 , 0 , 0 , 0 , 0 , 92 , 0 , 0 , 0 , 0 , 13 , 0 , 0 , 92 , 0 , 0
   Data 0 , 60 , 0 , 0 , 0 , 0 , 8 , 0 , 0 , 49 , 0 , 52 , 55 , 0 , 0 , 0
   Data 48 , 44 , 50 , 53 , 54 , 56 , 0 , 0 , 0 , 43 , 51 , 45 , 42 , 57 , 0 , 0

   'shifted keys UPPER case
   Data 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0
   Data 0 , 0 , 0 , 0 , 0 , 81 , 33 , 0 , 0 , 0 , 90 , 83 , 65 , 87 , 34 , 0
   Data 0 , 67 , 88 , 68 , 69 , 0 , 35 , 0 , 0 , 32 , 86 , 70 , 84 , 82 , 37 , 0
   Data 0 , 78 , 66 , 72 , 71 , 89 , 38 , 0 , 0 , 76 , 77 , 74 , 85 , 47 , 40 , 0
   Data 0 , 59 , 75 , 73 , 79 , 61 , 41 , 0 , 0 , 58 , 95 , 76 , 48 , 80 , 63 , 0
   Data 0 , 0 , 0 , 0 , 0 , 96 , 0 , 0 , 0 , 0 , 13 , 94 , 0 , 42 , 0 , 0
   Data 0 , 62 , 0 , 0 , 0 , 8 , 0 , 0 , 49 , 0 , 52 , 55 , 0 , 0 , 0 , 0
   Data 48 , 44 , 50 , 53 , 54 , 56 , 0 , 0 , 0 , 43 , 51 , 45 , 42 , 57 , 0 , 0

