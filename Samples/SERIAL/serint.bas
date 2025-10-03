'--------------------------------------------------------------------
'                      SERINT.BAS
'                  (c) 1999-2005 MCS Electronics
'  serial interrupt example for AVR
' also look at CONFIG SERIALIN for buffered input routines
'--------------------------------------------------------------------
$regfile = "m88def.dat"
$baud = 19200
$crystal = 8000000
$hwstack = 40
$swstack = 40
$framesize = 40


Const Cmaxchar = 20                                         'number of characters

Dim B As Bit                                                'a flag for signalling a received character
Dim Bc As Byte                                              'byte counter
Dim Buf As String * Cmaxchar                                'serial buffer
Dim D As Byte

'Buf = Space(20)
'unremark line above for the MID() function in the ISR
'we need to fill the buffer with spaces otherwise it will contain garbage

Bc = 0
Print "Start"

On Urxc Rec_isr                                             'define serial receive ISR
Enable Urxc                                                 'enable receive isr



Enable Interrupts                                           'enable interrupts to occur

Do
  If B = 1 Then                                             'we received something
     Disable Serial
     Print "{" ; Buf ; "}"                                  'print buffer
     Print "BC:" ; Bc                                       'print character counter


     'now check for buffer full
     If Bc = Cmaxchar Then                                  'buffer full
        Buf = ""                                            'clear
        Bc = 0                                              'rest character counter
     End If

     Reset B                                                'reset receive flag
     Enable Serial
  End If
Loop

Rec_isr:
  D = Udr                                                   'read UDR only once
  Print "*"                                                 ' show that we got here
  If Bc < Cmaxchar Then                                     'does it fit into the buffer?
     Incr Bc                                                'increase buffer counter

     If D = 13 Then                                         'return?
        Buf = Buf + Chr(0)
        Bc = Cmaxchar                                       'at the end
     Else
        Buf = Buf + Chr(d)                                  'add to buffer
     End If


    ' Mid(buf , Bc , 1) = Udr
    'unremark line above and remark the line with Chr() to place
    'the character into a certain position
     'B = 1                                                    'set flag
  End If
  B = 1                                                     'set flag
Return