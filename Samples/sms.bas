'------------------------------------------------------------------------------
'                                 SMS.BAS
'                       (c) 2002-2011 MCS Electronics
' This sample shows how to use AT command on a GSM mode
' The GSM modems are available from www.mcselec.com
'------------------------------------------------------------------------------

$regfile = "m88def.dat"

'XTAL = 10 MHZ
$crystal = 10000000

'By default the modem works at 9600 baud
$baud = 9600

'HW stack 20, SW stack 8 , frame 10
$hwstack = 20
$swstack = 8
$framesize = 24


'some subroutines
Declare Sub Getline(s As String)
Declare Sub Flushbuf()
Declare Sub Showsms(s As String )


'used variables
Dim I As Byte , B As Byte
Dim Sret As String * 66 , Stemp As String * 6

'we use a serial input buffer
Config Serialin = Buffered , Size = 12                      ' buffer is small a bigger chip would allow a bigger buffer

'enable the interrupts because the serial input buffer works interrupts driven
Enable Interrupts

'define a constant to enable LCD feedback
Const Uselcd = 1
Const Senddemo = 1                                          ' 1= send an sms
Const Pincode = "AT+CPIN=1234"                              ' pincode change it into yours!
Const Phonenumber = "AT+CMGS=+31653123456"                  ' phonenumber to send sms to

#if Uselcd = 1
   Cls
   Lcd "SMS Demo"
#endif

'wait until the mode is ready after power up
Waitms 3000

#if Uselcd = 1
   Lcd "Init modem"
#endif


Print "AT"                                                  ' send AT command twice to activate the modem
Print "AT"
Flushbuf                                                    ' flush the buffer
Print "ATE0"
#if Uselcd = 1
   Home Lower
#endif

Do
   Print "AT" :                                              ' Waitms 100
   Getline Sret                                              ' get data from modem
   #if Uselcd = 1
      Lcd Sret                                              ' feedback on display
   #endif
Loop Until Sret = "OK"                                      ' modem must send OK
Flushbuf                                                    ' flush the input buffer
#if Uselcd = 1
   Home Upper : Lcd "Get pin mode"
#endif
Print "AT+cpin?"                                            ' get pin status
Getline Sret
#if Uselcd = 1
   Home Lower : Lcd Sret
#endif
If Sret = "+CPIN: SIM PIN" Then
   Print Pincode                                            ' send pincode
End If
Flushbuf
#if Uselcd = 1
   Home Upper : Lcd "set text mode"
#endif
Print "AT+CMGF=1"                                           ' set SMS text mode
Getline Sret                                                ' get OK status
#if Uselcd = 1
   Home Lower : Lcd Sret
#endif

'sms settings
Print "AT+CSMP=17,167,0,0"
Getline Sret
Print "AT+CNMI=0,1,2,0,0"
Getline Sret

#if Senddemo = 1
   #if Uselcd = 1
      Home Upper : Lcd "send sms"
   #endif
   Print Phonenumber
   Waitms 100
   Print "BASCOM AVR SMS" ; Chr(26)
   Getline Sret
   #if Uselcd = 1
      Home Lower : Lcd Sret                                 'feedback
   #endif
#endif


'main loop
Do
   Getline Sret                                             ' wait for a modem response
   #if Uselcd = 1
      Cls
      Lcd "Msg from modem"
      Home Lower : Lcd Sret
   #endif
   I = Instr(sret , ":")                                    ' look for :
   If I > 0 Then                                            'found it
      Stemp = Left(sret , I)
      Select Case Stemp
         Case "+CMTI:" : Showsms Sret                       ' we received an SMS
            ' hanle other cases here
      End Select
   End If
Loop                                                        ' for ever


'subroutine that is called when a sms is received
's hold the received string
'+CMTI: "SM",5
Sub Showsms(s As String )
   #if Uselcd = 1
      Cls
   #endif
   I = Instr(s , ",")                                      ' find comma
   I = I + 1
   Stemp = Mid(s , I)                                      ' s now holds the index number
   #if Uselcd = 1
      Lcd "get " ; Stemp
      Waitms 1000                                          'time to read the lcd
   #endif

   Print "AT+CMGR=" ; Stemp                                ' get the message
   Getline S                                               ' header   +CMGR: "REC READ","+316xxxxxxxx",,"02/04/05,01:42:49+00"
   #if Uselcd = 1
      Lowerline
      Lcd S
   #endif
   Do
      Getline S                                            ' get data from buffer
      Select Case S
         Case "PORT" :                                     'when you send PORT as sms text, this will be executed
            #if Uselcd = 1
               Cls : Lcd "do something!"
            #endif
         Case "OK" : Exit Do                               ' end of message
         Case Else
      End Select
   Loop
   #if Uselcd = 1
      Home Lower : Lcd "remove sms"
   #endif
   Print "AT+CMGD=" ; Stemp                                ' delete the message
   Getline S                                               ' get OK
   #if Uselcd = 1
      Lcd S
   #endif
End Sub


'get line of data from buffer
Sub Getline(s As String)
   S = ""
   Do
      B = Inkey()
      Select Case B
         Case 0                                               'nothing
         Case 13                                              ' we do not need this one
         Case 10 : If S <> "" Then Exit Do                    ' if we have received something
         Case Else
            S = S + Chr(b)                                     ' build string
      End Select
   Loop
End Sub

'flush input buffer
Sub Flushbuf()
   Waitms 100                                                'give some time to get data if it is there
   Do
      B = Inkey()                                             ' flush buffer
   Loop Until B = 0
End Sub