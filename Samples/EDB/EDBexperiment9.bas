'--------------------------------------------------------------
'                        EDBexperiment9.bas
'       Experiment 9 for the Educational Development Board
'                  (c) 1995-2006, MCS Electronics
'                        Fileversion 1.0
'--------------------------------------------------------------
'
'Purpose:
'This program shows how to use a PS/2 keyboard as input device
'
'Conclusions:
'You should be able to use keyboard

$regfile = "m88def.dat"
$crystal = 8000000
$baud = 19200
$hwstack = 40
$swstack = 40
$framesize = 40


'Configure the pins to use for the clock and data
'Can be any pin that can serve as an input
'Keydata is the label of the key translation table
Config Keyboard = Pind.7 , Data = Pind.0 ,  Keydata = Keydta

'Dim some used variables
Dim S As String * 12
Dim B As Byte

'In this example we use SERIAL(COM) INPUT redirection
$serialinput = Kbdinput

'Show the program is running
Print "Hello"

Do
   'The GetATKBD() function does not use an interrupt.
   'But it waits until a key was pressed!
   B = Getatkbd()                                           'Get a byte and store it into byte variable
  'When no real key is pressed the result is 0
  'So test if the result was > 0
   If B > 0 Then
      Print Chr(b)
   End If

  'The purpose of this sample was how to use a PS/2 or PC AT keyboard
  'The input that normally comes from the serial port is redirected to the
  'external keyboard.

Loop
End





'THIS CODE DERIVED FROM KEYBOARD.BAS FILE IN BASCOM SAMPLES DIRECTORY
'Since we do a redirection we call the routine from the redirection routine
'
Kbdinput:
 'we come here when input is required from the COM port
 'So we pass the key into R24 with the GetATkbd function
' We need some ASM code to save the registers used by the function
$asm
 push r16           ; save used register
 push r25
 push r26
 push r27

Kbdinput1:
 rCall _getatkbd    ; call the function
 tst r24            ; check for zero
 breq Kbdinput1     ; yes so try again
 pop r27            ; we got a valid key so restore registers
 pop r26
 pop r25
 pop r16
 $end Asm
 'just return
Return

'The tricky part is that you MUST include a normal call to the routine
'otherwise you get an error
'This is no clean solution and will be changed
B = Getatkbd()

'This is the key translation table

Keydta:
'normal keys lower case
Data 0 , 0 , 0 , 0 , 0 , 200 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , &H5E , 0
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