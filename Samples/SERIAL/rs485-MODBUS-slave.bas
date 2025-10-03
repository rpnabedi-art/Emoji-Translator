'-----------------------------------------------------------------------------------------
'name                     : rs485-MODBUS-slave.bas
'copyright                : (c) 1995-2012, MCS Electronics
'purpose                  : MODBUS slave demo
'micro                    : Mega162
'suited for demo          : yes
'commercial addon needed  : Not to be included with the DEMO 
'-----------------------------------------------------------------------------------------

$regfile = "m162def.dat"                                    ' specify the used micro
$crystal = 8000000
$baud = 19200                                               ' use baud rate
$hwstack = 42                                               ' default use 42 for the hardware stack
$swstack = 40                                               ' default use 40 for the SW stack
$framesize = 40                                             ' default use 40 for the frame space
$lib "modbus.lbx"                                           ' include special lib

Const Mdbg = 0                                              'use some debugging
Const Mdbghex = 0                                           'show only hex data traffic
Const Registersize = 5                                      'CHANGE THIS in the num of registers your client supports
Const Regbytes = 1 + 1 + 2 + 2 + 2 + 1 +(registersize * 2)  'slave + address+startadr+regs+crc+1+data

'declare the sub routines
Declare Sub Modbustask()
Declare Sub Modbus03(addr3 As Word , Idx3 As Byte , Wval3 As Word)
Declare Sub Modbus06(addr3 As Word , Wval3 As Word)
Declare Sub Modbus16(addr3 As Word , Idx As Byte , Bv As Byte)
Declare Sub Modbus16w(addr3 As Word , Idx As Byte , Bw As Word)


'configure the RS485 pin
Rs485dir Alias Portb.1
Config Rs485dir = Output
Rs485dir = 0

'enable RS485 com
'Config Print1 = Portb.1 , Mode = Set

'See Using RS485 in the help
'         TX    RX
' COM0   PD.1   PD.0   rs232
' COM1   PB.3   PB.2   rs485
'           PB.1       data direction rs485

'config RS232 for the first UART
Config Com1 = Dummy , Synchrone = 0 , Parity = None , Stopbits = 1 , Databits = 8 , Clockpol = 0
'config RS485 for the second UART
Config Com2 = 9600 , Synchrone = 0 , Parity = Even , Stopbits = 1 , Databits = 8 , Clockpol = 0

'we use buffered serial input so all data is processed on the background
Config Serialin1 = Buffered , Size = 50 , Bytematch = All


'we need a timer to detect a frame start
'a start always is 3,5 characters bit time
'a gap of 1,5 characters bittime means new data will follow
'at 9600 baud, (1/9600)*8=1/1200 Hz = 0.83 ms
'we do not take stopbit and we mul by 4 for 4 characters
Const Tm_frame =(1 /(9600 / 8)) * 4
'we will use timer 0
Genreload Timer0 , Tm_frame , _rl , _ts
Tccr0 = _ts                                                 'prescale value for tm_frame overflow
Timer0 = _rl                                                ' reload value for tm_frame

On Timer0 Isr_tmr0                                          'ISR for timer 0 overflow
Enable Timer0

'use OPEN/CLOSE for using the second UART
Open "COM2:" For Binary As #1

'dimension some MODBUS SPECIFIC variables
Dim Mbchar As Byte , Mbstate As Byte , Mbslave As Byte , Mbfunc As Byte , Mbadrw As Word , Mbcount As Byte , Mbregw As Word , Mberr As Byte
Dim Mbdatacount As Byte , Mbdata(regbytes) As Byte , Mbcheckw As Word , Mbruncheck(regbytes) As Byte , Mbruncount As Byte , Mbw As Word
Dim Mbj As Byte


'some user variables
Dim Wtochange(4) As Word , L As Long
Dim W1 As Word , B1 As Byte

Wtochange(1) = 1000                                         'when we run this is the default value
Wtochange(2) = 2001                                         'when we run this is the default value
Wtochange(3) = 3003                                         'when we run this is the default value
Wtochange(4) = 4004                                         'when we run this is the default value

'some samples use slave address 1, 2 or ..
Mbslave = 1                                                 'the slave address
Mbstate = 99                                                ' no data yet
Print "RS-485 MODBUS slave :" ; Hex(mbslave)

Enable Interrupts                                           'the serial buffered input need this turned on

'Osccal = &H40                                               'MY CHIP NEEDED THIS BUT TRY TO REMARK THIS LINE

Do
   If Ischarwaiting(#1) = 0 Then                            'when there is no data
      Print "no data waiting : " ; Hex(l)                   'print the default value
      For B1 = 1 To 4
         Print "wtochange " ; B1 ; " value : " ; Wtochange(b1)
      Next
      Waitms 1000                                           'some delay
   Else                                                     'we have data waiting from the master
   ' either call it manual in your main loop or you buffered input with BYTEMATCH=ALL option
   '  Modbustask                                             'call this once in a while
   End If
Loop

'----------------------------------------------
' This is the task that process the data sent
' by the master
'----------------------------------------------
Sub Modbustask()

   While Ischarwaiting(#1) <> 0                             'as long as there is data in the buffer
     Mbchar = Waitkey(#1)                                   'get a char
     #if Mdbg
       Print Hex(mbchar) ; ",";                             'for debugging
     #endif
     If Mbstate = 0 Then                                    ' nothing received yet

        If Mbchar = Mbslave Then                            ' slave addressed
           Mbstate = 1                                      '  go to next state
           Mbruncount = 0                                   ' reset the counter
           Gosub Add2checksum                               ' add the received byte to checksum
        Else
           Mbstate = 99
        End If
     Elseif Mbstate = 1 Then                                ' we expect a valid function now
        Gosub Add2checksum                                  ' add it
        Mbstate = 2                                         ' next state
        Mbcount = 0                                         ' reset counter
        Mbfunc = Mbchar
        Select Case Mbfunc                                  ' determine the function
           Case 3 : Mbfunc = 3                              ' read register
           Case 6 : Mbfunc = 6                              ' write register
           Case 16 : Mbfunc = 16                            ' write multiple registers
           Case Else                                        'the function is not supported
             Mberr = 1 : Gosub Mberror : Exit While         'report error
        End Select
     Elseif Mbstate = 2 Then                                ' get starting address
        Gosub Add2checksum

        Incr Mbcount                                        ' increase address counter
        If Mbcount = 1 Then                                 ' first MSB
           Mbadrw = Makeint(0 , Mbchar)                     ' set byte
        Else                                                ' LSB of address
           Mbadrw = Mbadrw + Mbchar                         ' add LSB
           Mbstate = 3                                      ' next state
           Mbcount = 0                                      ' reset counter
        End If
     Elseif Mbstate = 3 Then                                ' address received what follows depends on the function
        'func 03 : number of regs (word)
        'func 06 : value (word)
        'func 16 : number of regs (word)
        Gosub Add2checksum

        Incr Mbcount
        If Mbcount = 1 Then                                 'we store this data in mbregW anyway
           Mbregw = Makeint(0 , Mbchar)
        Else
           Mbregw = Mbregw + Mbchar
           Mbcount = 0
           Mbstate = 4                                      ' next state
        End If
     Elseif Mbstate = 4 Then                                ' now we must handle things different
        'func 03 : checksum
        'func 06 : checksum
        'func 16 : byte counter, data, checksum
         If Mbfunc = 16 Then
            Gosub Add2checksum

            Mbdatacount = Mbchar                            ' store number of bytes to receive
            Mbstate = 5                                     ' to next state
            Mbcount = 0                                     ' reset counter
         Else                                               ' must be checksum
            Mbcheckw = Mbchar                               ' LSB first
            Mbstate = 6                                     ' next state
         End If
     Elseif Mbstate = 5 Then                                ' only for function 16 we get some more data
         'function 16
         Gosub Add2checksum

         Incr Mbcount                                       ' increase byte counter
         If Mbcount <= Regbytes Then
            Mbdata(mbcount) = Mbchar                        ' store data
         Else                                               'does not fit so do not store
              'set error here later
         End If
         If Mbcount = Mbdatacount Then                      ' if we reached the bytecount of data
            Mbstate = 7                                     ' advance to state for function 16
         End If
     Elseif Mbstate = 7 Then                                ' state for function 16

         Mbcheckw = Mbchar                                  ' LSB first
         Mbstate = 6                                        ' next state which is state to get checksum
     Elseif Mbstate = 6 Then                                ' we need MSB of checksum
         Mbcheckw = Makeint(mbcheckw , Mbchar)
         'now we received all the data we needed so go check crc
         Mbw = Crcmb(mbruncheck(1) , Mbruncount)            ' calculate CRC16
         If Mbcheckw = Mbw Then                             'when it matches
            #if Mdbg
               Print "CRC ok"
            #endif
            '--------- CRC OK, so now prepare a reply ----------
            Mbchar = Low(mbw) : Gosub Add2checksum
            Mbchar = High(mbw) : Gosub Add2checksum

            #if Mdbghex                                     ' if we only want the hex data shown
                Gosub Showdatareceived
            #endif

            Select Case Mbfunc
              Case 3 :                                      'read function 3

                       If Mbregw > Registersize Then        ' size out of bounds
                           Mberr = 3 : Gosub Mberror : Exit While
                       End If

                       Mbruncount = 0                       'reset counter
                       Mbchar = Mbslave : Gosub Add2checksum
                       Mbchar = Mbfunc : Gosub Add2checksum


                       Mbchar = Mbregw * 2                  ' number of bytes
                       Gosub Add2checksum
                       For Mbj = 1 To Mbregw                ' for all registers
                           Modbus03 Mbadrw , Mbj , Mbw      ' call user sub
                           Mbchar = High(mbw) : Gosub Add2checksum
                           Mbchar = Low(mbw) : Gosub Add2checksum
                       Next
                       'now calc CRC
                       Mbw = Crcmb(mbruncheck(1) , Mbruncount)
                       Mbchar = Low(mbw) : Gosub Add2checksum       ' we add it but we do not need to calc anymore
                       Mbchar = High(mbw) : Gosub Add2checksum       ' we add it but we do not need to calc anymore

                       #if Mdbghex                          ' if we only want the hex data shown
                           Gosub Showdatasent
                       #endif

                       Set Rs485dir
                       For Mbj = 1 To Mbruncount
                         Print #1 , Chr(mbruncheck(mbj));   'send out this data
                       Next
                       Reset Rs485dir

              Case 6                                        'function 6, write register
                       Modbus06 Mbadrw , Mbregw

                       #if Mdbghex                          ' if we only want the hex data shown
                           Gosub Showdatasent
                       #endif

                       Set Rs485dir
                       For Mbj = 1 To Mbruncount            'function 6 only need to echo original data
                         Print #1 , Chr(mbruncheck(mbj));
                       Next
                       Reset Rs485dir

              Case 16                                       'function 16, wite multiple registers
                       Mbruncount = 6                       'set to end of register count

                       '----- this one is when you want to pass bytes ---------
                       'For Mbj = 1 To Mbdatacount           ' for all BYTES
                       '    Modbus16 Mbadrw , Mbj , Mbdata(1)
                       'Next

                       '------ this one is when you want to pass word registers----
                       For Mbj = 1 To Mbregw                ' for all WORD registers
                           $asm
                           lds r24,{mbj}                    ' get index
                           dec r24                          'offset
                           lsl r24                          'we use words
                           Loadadr Mbdata(1) , X            'load X pointer with base address
                           add r26,r24
                           clr r25
                           adc r27,r25
                           ld r24,x+                        ' load data from array
                           ld r25,x
                           sts {mbw},r25
                           Sts {mbw + 1} , R24
                           $end Asm
                           Modbus16w Mbadrw , Mbj , Mbw
                       Next

                       'now calc CRC
                       Mbw = Crcmb(mbruncheck(1) , Mbruncount)
                       Mbchar = Low(mbw) : Gosub Add2checksum       ' we add it but we do not need to calc anymore
                       Mbchar = High(mbw) : Gosub Add2checksum       ' we add it but we do not need to calc anymore

                       #if Mdbghex                          ' if we only want the hex data shown
                           Gosub Showdatasent
                       #endif

                       Set Rs485dir
                       For Mbj = 1 To Mbruncount
                         Print #1 , Chr(mbruncheck(mbj));
                       Next
                       Reset Rs485dir

            End Select
         End If
         Mbstate = 99
     End If
     #if Mdbg
       Print "STATE:" ; Mbstate
     #endif
   Wend

   Exit Sub


'add data to checksum
Add2checksum:
  Incr Mbruncount
  If Mbruncount <= Regbytes Then
     Mbruncheck(mbruncount) = Mbchar                        'store data
  Else                                                      'we will set an error here later

  End If
Return

'report an error
'actual error is passed in mbERR
Mberror:
   Mbruncount = 0                                           'reset counter
   Mbchar = Mbslave : Gosub Add2checksum
   Mbchar = Mbfunc Or &H80 : Gosub Add2checksum             'set upper bit to flag error
   Mbchar = Mberr : Gosub Add2checksum                      'add actual error
   Mbw = Crcmb(mbruncheck(1) , Mbruncount)
   Mbchar = Low(mbw) : Gosub Add2checksum                   ' we add it but we do not need to calc anymore
   Mbchar = High(mbw) : Gosub Add2checksum                  ' we add it but we do not need to calc anymore

   Set Rs485dir
   For Mbj = 1 To 5
       Print #1 , Chr(mbruncheck(mbj));
   Next
   Reset Rs485dir
   Mbstate = 99                                             ' not valid go to state 98
Return


#if Mdbghex
Showdatareceived:
   Print "Data received:"
   For Mbj = 1 To Mbruncount
     Print Hex(mbruncheck(mbj))
   Next
Return

Showdatasent:
   Print "Data sent back:"
   For Mbj = 1 To Mbruncount
     Print Hex(mbruncheck(mbj))
   Next
Return

#endif

End Sub

'this routine is called when we have received a character from the RS485
Serial1bytereceived:
   If Mbstate = 99 Then
      Mbchar = Waitkey(#1)
   Else
      Modbustask                                            ' call the task from here
   End If
   Timer0 = _rl                                             ' reload again
Return

'executes after 2 character time out
Isr_tmr0:
   If Mbstate = 99 Then
      Mbstate = 0                                           ' now we can start
   End If
   Timer0 = _rl                                             ' reload again
Return

'function : 3
'addr3    : contains the address
'Idx3     : contains an index. It is 1 for the first register, 2 for the second register, etc
' Notice that these variables are passed by reference. So do NOT change addr3 and Idx3 values !
Sub Modbus03(addr3 As Word , Idx3 As Byte , Wval3 As Word)
     'we need to put data in wval3
     Dim Mbx As Word
     Mbx = Addr3 + Idx3                                     ' in case we want to read multiple regs
     Select Case Mbx
       Case 1 : Wval3 = Wtochange(1)
       Case 2 : Wval3 = Wtochange(2)
       Case 3 : Wval3 = Wtochange(3)
       Case 4 : Wval3 = Wtochange(4)
     End Select                                             'we simply assign the index in this sample
End Sub

'function : 6
'addr3    : contains the address
'wval3    : must be assigned by the user
Sub Modbus06(addr3 As Word , Wval3 As Word)
    'we need to write a value here
    Mbx = Addr3 + 1
    Select Case Mbx
      Case 1 : Wtochange(1) = Wval3                         'change it
      Case 2 : Wtochange(2) = Wval3
      Case 3 : Wtochange(3) = Wval3
      Case 4 : Wtochange(4) = Wval3
    End Select
End Sub

'function : 16
'addr3    : starting address
'idx      : byte index to the data
'bv       : value to set
Sub Modbus16(addr3 As Word , Idx As Byte , Bv As Byte)
  Select Case Addr3
    Case 1 : W1 = Varptr(wtochange(1))
    Case 2 : W1 = Varptr(wtochange(2))
    'could be a long or single too
  End Select

  'typical you would handle this different for each address.
  'Only you know what the master will send for each address
End Sub


'same as abvove but this one works with word registers instead of passing bytes
Sub Modbus16w(addr3 As Word , Idx As Byte , Bw As Word)
  W1 = Addr3 + Idx
  Select Case W1
    Case 1 : Wtochange(1) = Bw
    Case 2 : Wtochange(2) = Bw
    Case 3 : Wtochange(3) = Bw
    Case 4 : Wtochange(4) = Bw
    'could be a long or single too
  End Select
End Sub
