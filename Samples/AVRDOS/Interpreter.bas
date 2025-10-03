' Getting USER-Input and executes Commands
$nocompile

Declare Sub Docommand()
Declare Sub Extracttoken()
Declare Function Getnexttokenstr(byval Pblen_max As Byte ) As String
Declare Function Getnexttokenlong(byval Plmin As Long , Byval Plmax As Long ) As Long
Declare Sub Printparametererrorl(plparamlow As Long , Plparamhigh As Long)
Declare Sub Printparametercounterror(byval Psparm_anzahl As String)
Declare Sub Getinput(byval Pbbyte As Byte)
Declare Sub Printprompt()
Declare Function Getlongfrombuffer(pbsramarray As Byte , Byval Pbpos As Word) As Long
Declare Function Getwordfrombuffer(pbsramarray As Byte , Byval Pbpos As Word) As Word

Declare Sub Writefiledivvariables(pfn As Byte , Pbyte As Byte , Pint As Integer , Pword As Word , Plong As Long , Psingle As Single , Pstring As String , Pdummy As Byte)
Declare Sub Readfiledivvariables(pfn As Byte , Pbyte As Byte , Pint As Integer , Pword As Word , Plong As Long , Psingle As Single , Pstring1 As String , Pstring2 As String , Pdummy As Byte)
Dim Transferbuffer_write As Word
Const Cpno = 0                                              '
Const Cpyes = 1

Const Cptoken_max = 10                                      ' Count of Tokens in USER-Input
Const Cpstrsep = " "                                        ' Blank: Separator between tokens
Dim Abinterpreterbuffer(512) As Byte
Const Cpcinput_len = 80                                     ' max. length of user-Input
Dim Gspcinput As String * 80                                ' holds user-input
Dim Gbposstrparts(cptoken_max) As Byte                      ' for analysing user-input
Dim Gblenstrparts(cptoken_max) As Byte                      '
Dim Gbcnttoken As Byte                                      ' found tokens in user-input
Dim Gbtoken_actual As Byte                                  ' actual handled token of user-input
Dim Gbpcinputerror As Byte                                  ' holds error-code during analysing user-input
Dim Gbpcinputpointer As Byte                                ' string-pointer during user-input
Dim Gstestline As String * 40


Gbpcinputpointer = 1

Dim Tbyte1 As Byte

Dim Gwtemp1 As Word
Dim Bsec As Byte , Bmin As Byte , Bhour As Byte , Bday As Byte , Bmonth As Byte , Byear As Byte

'End


Sub Getinput(pbbyte As Byte)
    ' stores bytes from user and wait for CR (&H13)
   Print #1 , Chr(pbbyte);                                  ' echo back to user
   Select Case Pbbyte
      Case &H0D                                             ' Line-end?
         Print #1 , Chr(&H0a)
         Docommand                                          ' analyse command and execute
         Gbpcinputpointer = 1                               ' reset for new user-input
         Gspcinput = ""
         Printprompt
      Case &H08                                             ' backspace ?
         Decr Gbpcinputpointer
      Case Else                                             ' store user-input
         Mid(gspcinput , Gbpcinputpointer , 1) = Pbbyte
         Incr Gbpcinputpointer
         Mid(gspcinput , Gbpcinputpointer , 1) = &H00       ' string-terminator
         If Gbpcinputpointer > Cpcinput_len Then            'don't exceed input-string
            Gbpcinputpointer = Cpcinput_len
            Print #1 , &H08
         End If
   End Select
End Sub


Sub Docommand
   ' interpretes the user-input and execute
   ' Local variables
   Local Lbyte1 As Byte , Lbyte2 As Byte , Lbyte3 As Byte
   Local Lint1 As Integer , Lint2 As Integer
   Local Lword1 As Word , Lword2 As Word , Lword3 As Word
   Local Llong1 As Long , Llong2 As Long , Llong3 As Long , Llong4 As Long
   Local Lsingle1 As Single
   Local Lbpos As Byte

   Local Lstoken As String * 20                             ' Hold Tokens
   Local Lblen As Byte
   Local Lwsrampointer As Word
   Ldumpbase = 0
   Extracttoken                                             ' token analysing
   Gbtoken_actual = 0                                       ' reset to beginn of line (first token)
   Gbpcinputerror = Cpno
   Gwtemp1 = 1
   If Gbcnttoken > 0 Then                                   ' is there any input

      Lstoken = Getnexttokenstr(20)                         ' get first string-token = command
      Lstoken = Ucase(lstoken)                              ' all uppercase
      Lwsrampointer = Varptr(abinterpreterbuffer(1))
                                         ' Pointer to SRAM Buffer
      Select Case Lstoken
         Case "CFI"                                         ' Show CF-Card Information Block
              Print #1 , "Read Card Info"
              Lbyte1 = Drivegetidentity(lwsrampointer)      ' read Info to SRAM
              Transferbuffer_write = 0
              Sramdump Lwsrampointer , 512 , Ldumpbase      ' Dump SRAM
              ' Get Count of Sectors in Compactflash-Card
              Llong1 = Getlongfrombuffer(abinterpreterbuffer(1) , 120) : Llong2 = Llong1 * 512
              Print #1 , Llong1 ; " Sectors = " ; Llong2 ; " Bytes"
              ' Get Buffersize of Compactflash-Card
              Lword1 = Getwordfrombuffer(abinterpreterbuffer(1) , 42)
              Llong2 = Lword1 * 512
              Print #1 , "CF-Buffersize = " ; Lword1 ; " Sectors = " ; Llong2 ; " Bytes"

         Case "CFR"                                         ' Reset Compactflash Card
              Lbyte1 = Drivereset()

         Case "MBR"                                         ' Show Masterboot record = Sector 0
            Llong1 = 0
            Print #1 , "Read Master Boot Record ... " ;
            Lbyte1 = Drivereadsector(lwsrampointer , Llong1 )       ' read Sector to abInterpreterBuffer
            Transferbuffer_write = 0
            Print #1 , "done"
            Sramdump Lwsrampointer , 512 , Ldumpbase        ' show abInterpreterBuffer
            Print #1 , " " : Print #1 , "Partition-Table" : Print #1 , " "
            Lword1 = 446                                    ' first partition entry starts at 446
            For Lbyte1 = 1 To 4
               Lword2 = Lword1 + 1
               If Abinterpreterbuffer(lword2) > 0 Then
                  Print #1 , "Partition " ; Lbyte1 ; " " ;
                  Lword2 = Lword1 + 8
                  Llong1 = Getlongfrombuffer(abinterpreterbuffer(1) , Lword2)
                  Lword2 = Lword1 + 12
                  Llong2 = Getlongfrombuffer(abinterpreterbuffer(1) , Lword2)
                  Llong3 = Llong1 + Llong2
                  Print #1 , "Sector: " ; Llong1 ; " to " ; Llong3 ; " = " ; Llong2 ; " Sectors; ";
                  Lword2 = Lword1 + 5
                  Lbyte1 = Abinterpreterbuffer(lword2)
                  Print #1 , "File-System Type: " ; Hex(lbyte1)
               End If
               Lword1 = Lword1 + 16
            Next

         Case "SD"                                          ' Sector Dump
            If Gbcnttoken = 2 Then
               Llong1 = Getnexttokenlong(0 , 2000000)
               Llong2 = Llong1
            Elseif Gbcnttoken = 3 Then
               Llong1 = Getnexttokenlong(0 , 2000000)
               Llong2 = Getnexttokenlong(llong1 , 2000000)
            Else
                Printparametercounterror "1, 2 "
                Exit Sub
            End If
            If Gbpcinputerror = Cpno Then
               Print #1 , "Dump Sectors from " ; Llong1 ; " to " ; Llong2
               For Llong3 = Llong1 To Llong2
                   Print #1 , "Read Sector: " ; Llong3 ; " ... " ;
                   Lwsrampointer = Varptr(abinterpreterbuffer(1))
                   Lbyte1 = Drivereadsector(lwsrampointer , Llong3)
                   Print "Driver-Return=" ; Lbyte1 ; " TO= " ; Gwtemp1
                   Transferbuffer_write = 0
                   Print #1 , " done"
                   Ldumpbase = 0
                   Lwsrampointer = Varptr(abinterpreterbuffer(1))
                   Sramdump Lwsrampointer , 512 , Ldumpbase
               Next
            End If

         Case "MD"                                          ' Memory Dump
              Lword2 = 512
              If Gbcnttoken = 1 Then
              Elseif Gbcnttoken = 2 Then
                 Llong1 = Getnexttokenlong(0 , &HFFFF)
                 Lwsrampointer = Llong1                     ' assign to word
              Elseif Gbcnttoken = 3 Then
                 Llong1 = Getnexttokenlong(0 , &HFFFF)
                 Lwsrampointer = Llong1                     ' assign to word
                 Llong2 = Getnexttokenlong(1 , &HFFFF)
                 Lword2 = Llong2
              Else
                  Printparametercounterror "0, 1, 2 "
              End If
              If Gbpcinputerror = Cpno Then
                 Ldumpbase = Lwsrampointer
                 Sramdump Lwsrampointer , Lword2 , Ldumpbase       ' Show 512 Bytes
              End If

         Case "SW"                                          ' Sector Write
            If Gbcnttoken = 3 Then
               Llong1 = Getnexttokenlong(0 , 2000000)
               Llong2 = Getnexttokenlong(1 , &H7F)
               Llong2 = Llong2 - 1
               Llong3 = Llong1 + Llong2
            Elseif Gbcnttoken = 4 Then
               Llong1 = Getnexttokenlong(0 , 2000000)
               Llong2 = Getnexttokenlong(1 , &H7F)
               Llong2 = Llong2 - 1
               Llong3 = Llong1 + Llong2
               Llong4 = Getnexttokenlong(0 , &HFFFF)
               Lwsrampointer = Llong4
            Else
               Printparametercounterror "2, 3 "
               Exit Sub
            End If
            If Gbpcinputerror = Cpno Then
               Print #1 , "Write " ; Lbyte1 ; " Sector(s) to " ; Llong1 ; " at CF-Card from " ;
               If Gbcnttoken = 4 Then
                  Print #1 , "SRAM Address " ; Hex(lwsrampointer) ; " ... " ;
               Else
                  Print #1 , "Transfer-Buffer ... " ;
               End If
               For Llong2 = Llong1 To Llong3
                  Print #1 , "Write Sector " ; Llong2 ; " from SRAM " ; Hex(lwsrampointer)
                  Lbyte1 = Drivewritesector(lwsrampointer , Llong2)
                  Print "Driver-Return=" ; Lbyte1 ; " TO= " ; Gwtemp1
                  Print #1 , " done"
                  If Gbcnttoken = 4 Then
                     Lwsrampointer = Lwsrampointer + 512
                  End If
               Next
            End If


         Case "TESTSW"                                      ' Sector Write
            If Gbcnttoken = 3 Then
               Llong1 = Getnexttokenlong(0 , 2000000)
               Llong2 = Getnexttokenlong(1 , 100)
               Llong2 = Llong2 - 1
               Llong3 = Llong1 + Llong2
            Else
               Printparametercounterror "2, 3 "
               Exit Sub
            End If
            If Gbpcinputerror = Cpno Then
               Lbyte1 = 0
               For Llong2 = 1 To 512
                  Abinterpreterbuffer(llong2) = Lbyte1
                  Incr Lbyte1
               Next

               Print #1 , "Write " ; Lbyte1 ; " Sector(s) to " ; Llong1 ; " at CF-Card from " ;

               For Llong2 = Llong1 To Llong3
                  Print #1 , "Write Sector " ; Llong2 ; " from SRAM " ; Hex(lwsrampointer)
                  Lbyte1 = Drivewritesector(lwsrampointer , Llong2)
                  Print "Driver-Return=" ; Lbyte1 ; " TO= " ; Gwtemp1
                  Print #1 , " done"

                     Lwsrampointer = Lwsrampointer + 4

               Next
            End If


        Case "TESTSWF"                                      ' Sector Write
            If Gbcnttoken = 3 Then
               Llong1 = Getnexttokenlong(0 , 2000000)
               Llong2 = Getnexttokenlong(1 , 10000)
               Llong2 = Llong2 - 1
               Llong3 = Llong1 + Llong2
            Else
               Printparametercounterror "2, 3 "
               Exit Sub
            End If
            If Gbpcinputerror = Cpno Then
               Lbyte1 = 0
               For Llong2 = 1 To 512
                  Abinterpreterbuffer(llong2) = Lbyte1
                  Incr Lbyte1
               Next

               Print #1 , "Write " ; Lbyte1 ; " Sector(s) to " ; Llong1 ; " at CF-Card from " ;
               Print #1 , Time$
               For Llong2 = Llong1 To Llong3
                  'print #1 , "Write Sector " ; lLong2 ; " from SRAM " ; hex(lwSRAMPointer)
                  Lbyte1 = Drivewritesector(lwsrampointer , Llong2)
                  If Lbyte1 <> 0 Then
                     Exit For
                  End If
                  'print "Driver-Return=" ; lbyte1 ; " TO= " ; gwTemp1


                     Lwsrampointer = Lwsrampointer + 1

               Next
               Print #1 , " done at " ; Time$
            End If

         Case "TESTVAR"

            If Gbcnttoken = 8 Then
               Llong1 = Getnexttokenlong(1 , 255)
               Lbyte1 = Llong1                              ' Filenumber
               Llong1 = Getnexttokenlong(0 , 255)
               Lbyte2 = Llong1                              ' TestByte
               Llong1 = Getnexttokenlong( -30000 , 30000)
               Lint1 = Llong1                               ' TestInt
               Llong1 = Getnexttokenlong(0 , 60000)
               Lword1 = Llong1                              ' TEstWord
               Llong1 = Getnexttokenlong( -1000000 , 1000000)
               Lstoken = Getnexttokenstr(10)
               Lsingle1 = Val(lstoken)
               Lstoken = Getnexttokenstr(20)
               If Gbpcinputerror = Cpno Then
                  Writefiledivvariables Lbyte1 , Lbyte2 , Lint1 , Lword1 , Llong1 , Lsingle1 , Lstoken , Lbyte1
               End If
               Printdoserror
            Else
               Printparametercounterror "7 "
            End If

         Case "TESTVARR"

              If Gbcnttoken = 2 Then
                 Llong1 = Getnexttokenlong(1 , 255)
                 Lbyte1 = Llong1
                 If Gbpcinputerror = Cpno Then
                    Readfiledivvariables Lbyte1 , Lbyte2 , Lint1 , Lword1 , Llong1 , Lsingle1 , Lstoken , Gstestline , Lbyte1
                    Print #1 , Gstestline ; " " ; Lbyte2 ; " " ; Lint1 ; " " ; Lword1 ; " " ; Llong1 ; " " ; Lsingle1 ; " " ; Lstoken
                    Printdoserror

                 End If
              Else
                 Printparametercounterror "1 "
              End If

         Case "MT"                                          ' Fill Memory with Text
            If Gbcnttoken > 1 Then
               Lbyte1 = Gbposstrparts(2)
               Do
                 Incr Transferbuffer_write
                 Lstoken = Mid(gspcinput , Lbyte1 , 1)
                 Lbyte2 = Asc(lstoken)
                 If Lbyte2 = 0 Then                         ' String Terminator
                    Exit Do
                 End If
                 Abinterpreterbuffer(transferbuffer_write) = Lbyte2
                 Incr Lbyte1
               Loop Until Transferbuffer_write > 511
               Decr Transferbuffer_write                    ' 1 based to 0 based
           End If

         Case "MP"                                          ' Memory Pointer for MB and MT
              If Gbcnttoken = 2 Then
                 Llong1 = Getnexttokenlong(0 , 511)
                 If Gbpcinputerror = Cpno Then
                    Transferbuffer_write = Llong1
                 End If
              Else
                  Printparametercounterror "1 "
              End If

         Case "MB"                                          'Fill Memory with Same Byte
            If Gbcnttoken > 1 Then
               For Lbyte1 = 2 To Gbcnttoken
                   Llong1 = Getnexttokenlong(0 , 255)
                   If Gbpcinputerror = Cpno Then
                      Incr Transferbuffer_write
                      Lbyte2 = Llong1
                      Abinterpreterbuffer(transferbuffer_write) = Lbyte2
                      If Transferbuffer_write >= 511 Then
                         Exit For
                      End If
                   Else
                      Exit For
                   End If
               Next
            End If

         Case "MF"

            Llong2 = Transferbuffer_write : Llong3 = 511
            If Gbcnttoken = 2 Then
               Llong1 = Getnexttokenlong(0 , 255)
            Elseif Gbcnttoken = 3 Then
               Llong1 = Getnexttokenlong(0 , 255)
               Llong2 = Getnexttokenlong(0 , 511)
            Elseif Gbcnttoken = 4 Then
               Llong1 = Getnexttokenlong(0 , 255)
               Llong2 = Getnexttokenlong(0 , 511)
               Llong3 = Getnexttokenlong(llong2 , 511)
            Else
                Printparametercounterror "1, 2, 3 "
                Exit Sub
            End If
            If Gbpcinputerror = Cpno Then
               Lbyte1 = Llong1
               Incr Llong2 : Lword2 = Llong2
               Incr Llong3 : Lword3 = Llong3
               For Lword1 = Lword2 To Lword3
                   Abinterpreterbuffer(lword1) = Lbyte1
               Next
               Transferbuffer_write = Lword1 - 1
            End If

' ----------------------------------------------------------------------------
         Case "FS"                                          ' init File Syste,
            Lbyte1 = 1
            Lbyte1 = Initfilesystem(lbyte1)
            If Lbyte1 = 0 Then
               Print #1 , "Filesystem: " ; Gbfilesystem
               Print #1 , "FAT Start Sector: " ; Glfatfirstsector
               Print #1 , "Root Start Sector: " ; Glrootfirstsector
               Print #1 , "Data First Sector: " ; Gldatafirstsector
               Print #1 , "Max. Cluster Nummber: " ; Gwmaxclusternumber
               Print #1 , "Sectors per Cluster: " ; Gbsectorspercluster
               Print #1 , "Root Entries: " ; Gwrootentries
               Print #1 , "Sectors per FAT: " ; Gwsectorsperfat
               Print #1 , "Number of FATs: " ; Gbnumberoffats
            Else
               Printdoserror
            End If

         Case "DIR"                                         ' Directory
           If Gbcnttoken = 1 Then
               Lstoken = "*.*"
               Directory Lstoken
           Elseif Gbcnttoken = 2 Then
               Lstoken = Getnexttokenstr(12)
               Lstoken = Trim(lstoken)
               Directory Lstoken
           Else
              Printparametercounterror "0 or 1 "
           End If

          Case "DIRT"                                       ' Directory
           If Gbcnttoken = 1 Then
               Lstoken = "*.*"
               Lword1 = 7
               Directory1 Lstoken , Lword1
           Elseif Gbcnttoken = 3 Then
               Lstoken = Getnexttokenstr(12)
               Lstoken = Trim(lstoken)
               Llong1 = Getnexttokenlong(0 , 1000)
               Lword1 = Llong1
               Directory1 Lstoken , Lword1
           Else
              Printparametercounterror "0 or 1 "
           End If
          Case "DIR$"                                       ' Directory
           If Gbcnttoken = 1 Then
               Gstestline = Dir()
               Print #1 , Gstestline
               Printdoserror
           Elseif Gbcnttoken = 2 Then
               Lstoken = Getnexttokenstr(12)
               Lstoken = Trim(lstoken)
               Gstestline = Dir(lstoken)
               Print Gstestline
               Printdoserror
           Else
              Printparametercounterror "0 or 1 "
           End If


         Case "FILEDATETIMEB"
           If Gbcnttoken = 1 Then
               Bsec = Filedatetime()
               If Gbdoserror = 0 Then
                  Print #1 , Byear ; " " ; Bmonth ; " " ; Bday ; " " ; Bhour ; " " ; Bmin ; " " ; Bsec
               Else
                  Printdoserror
               End If
           Elseif Gbcnttoken = 2 Then
               Lstoken = Getnexttokenstr(12)
               Lstoken = Trim(lstoken)
               Bsec = Filedatetime(lstoken)
               If Gbdoserror = 0 Then
                  Print #1 , Byear ; " " ; Bmonth ; " " ; Bday ; " " ; Bhour ; " " ; Bmin ; " " ; Bsec
               Else
                  Printdoserror
               End If
           Else
              Printparametercounterror "0 or 1 "
           End If


         Case "FILEDATETIMES"
           If Gbcnttoken = 1 Then
               Gstestline = Filedatetime()
               Print Gstestline
               Printdoserror
           Elseif Gbcnttoken = 2 Then
               Lstoken = Getnexttokenstr(12)
               Lstoken = Trim(lstoken)
               Gstestline = Filedatetime(lstoken)
               Print Gstestline
               Printdoserror
           Else
              Printparametercounterror "0 or 1 "
           End If

         Case "FILELEN"
           If Gbcnttoken = 1 Then
               Llong1 = Filelen()
               Print #1 , Llong1
               Printdoserror
           Elseif Gbcnttoken = 2 Then
               Lstoken = Getnexttokenstr(12)
               Lstoken = Trim(lstoken)
               Llong1 = Filelen(lstoken)
               Print Llong1
               Printdoserror
           Else
              Printparametercounterror "0 or 1 "
           End If

         Case "GETATTR"
           If Gbcnttoken = 1 Then
               Lbyte1 = Getattr0()
               Print #1 , Bin(lbyte1)
               Printdoserror
           Elseif Gbcnttoken = 2 Then
               Lstoken = Getnexttokenstr(12)
               Lstoken = Trim(lstoken)
               Lbyte1 = Getattr(lstoken)
               Print #1 , Bin(lbyte1)
               Printdoserror
           Else
              Printparametercounterror "0 or 1 "
           End If


         Case "TYPE"                                        ' Type ASCII-file (sector by sector)
           If Gbcnttoken = 2 Then
               Lstoken = Getnexttokenstr(12)
               Lstoken = Trim(lstoken)
               Lbyte1 = Printfile(lstoken)
               Printdoserror
           Else
              Printparametercounterror "1 "
           End If

        Case "DUMP"                                         ' Dump file
           If Gbcnttoken = 2 Then
               Lstoken = Getnexttokenstr(12)
               Lstoken = Trim(lstoken)
               Lbyte1 = Dumpfile(lstoken)
               Printdoserror
           Else
              Printparametercounterror "1 "
           End If

         Case "TYPEB"                                       ' type ASCII-file (byte by byte)
           If Gbcnttoken = 2 Then
               Lstoken = Getnexttokenstr(12)
               Lstoken = Trim(lstoken)
               Lbyte1 = Printfileb(lstoken)
               Printdoserror
           Else
              Printparametercounterror "1 "
           End If


         Case "FOO"                                         ' File open for Output
            If Gbcnttoken > 1 Then
               Lstoken = Getnexttokenstr(12)
               Lstoken = Trim(lstoken)
               If Gbcnttoken > 2 Then
                  Llong1 = Getnexttokenlong(1 , 255)
                  Lbyte2 = Llong1
                  Open Lstoken For Output As #lbyte2
               Else
                  Lbyte2 = Freefile()
                  Open Lstoken For Output As #lbyte2
               End If
               If Gbdoserror <> 0 Then
                  Printdoserror
               Else
                  Print #1 , "File# = " ; Lbyte2
               End If
           Else
              Printparametercounterror "1 "
           End If

         Case "FOI"                                         ' File open for Input
            If Gbcnttoken > 1 Then
               Lstoken = Getnexttokenstr(12)
               Lstoken = Trim(lstoken)
               If Gbcnttoken > 2 Then
                  Llong1 = Getnexttokenlong(1 , 255)
                  Lbyte2 = Llong1
                  Open Lstoken For Input As #lbyte2
               Else
                  Lbyte2 = Freefile()
                  Open Lstoken For Input As #lbyte2
               End If
               If Gbdoserror <> 0 Then
                  Printdoserror
               Else
                  Print #1 , "File# = " ; Lbyte2
               End If
           Else
              Printparametercounterror "1 "
           End If


        Case "FOB"                                          ' File open for Binary
            If Gbcnttoken > 1 Then
               Lstoken = Getnexttokenstr(12)
               Lstoken = Trim(lstoken)
               If Gbcnttoken > 2 Then
                  Llong1 = Getnexttokenlong(1 , 255)
                  Lbyte2 = Llong1
                  Open Lstoken For Binary As #lbyte2
               Else
                  Lbyte2 = Freefile()
                  Open Lstoken For Binary As #lbyte2
               End If
               If Gbdoserror <> 0 Then
                  Printdoserror
               Else
                  Print #1 , "File# = " ; Lbyte2
               End If
           Else
              Printparametercounterror "1 "
           End If

        Case "FOA"                                          ' File open for Append
            If Gbcnttoken > 1 Then
               Lstoken = Getnexttokenstr(12)
               Lstoken = Trim(lstoken)
               If Gbcnttoken > 2 Then
                  Llong1 = Getnexttokenlong(1 , 255)
                  Lbyte2 = Llong1
                  Open Lstoken For Append As #lbyte2
               Else
                  Lbyte2 = Freefile()
                  Open Lstoken For Append As #lbyte2
               End If
               If Gbdoserror = 0 Then
                  Print #1 , "File# = " ; Lbyte2
               Else
                  Printdoserror
               End If
            Else
              Printparametercounterror "1 "
            End If

       Case "RLI"                                           ' File line input
            If Gbcnttoken = 2 Then
               Llong1 = Getnexttokenlong(1 , 255)           ' file#
               Lbyte1 = Llong1
               If Gbpcinputerror = Cpno Then
                  Line Input #lbyte1 , Gstestline
                  If Gbdoserror <> 0 Then
                     Printdoserror
                  Else
                     Print #1 , Gstestline
                  End If
                End If
            Else
               Printparametercounterror "1 "
            End If

        Case "LOC"                                          ' File Location last read/write
             If Gbcnttoken = 2 Then
                Llong1 = Getnexttokenlong(1 , 255)
                If Gbpcinputerror = Cpno Then
                   Lbyte1 = Llong1
                   Llong2 = Loc(#lbyte1)
                   If Gbdoserror = 0 Then
                      Print #1 , Llong2
                   Else
                      Printdoserror
                   End If
                End If
             End If

        Case "LOF"                                          ' File Length
             If Gbcnttoken = 2 Then
                Llong1 = Getnexttokenlong(1 , 255)
                If Gbpcinputerror = Cpno Then
                   Lbyte1 = Llong1
                   Llong2 = Lof(#lbyte1)
                   If Gbdoserror = 0 Then
                      Print #1 , Llong2
                   Else
                       Printdoserror
                   End If
                End If
             Else
                Printparametercounterror "1 "
             End If

        Case "SEEK"                                         ' next byte position to read/write in file
             If Gbcnttoken = 2 Then
                Llong1 = Getnexttokenlong(1 , 255)
                If Gbpcinputerror = Cpno Then
                   Lbyte1 = Llong1
                   Llong2 = Seek(#lbyte1)
                   If Gbdoserror = 0 Then
                      Print #1 , Llong2
                   Else
                       Printdoserror
                   End If
                End If
             Elseif Gbcnttoken = 3 Then
                Llong1 = Getnexttokenlong(1 , 255)
                Llong2 = Getnexttokenlong(1 , 10000000)
                If Gbpcinputerror = Cpno Then
                   Lbyte1 = Llong1
                   Seek #lbyte1 , Llong2
                   Printdoserror
                End If
             Else
                Printparametercounterror "1 or 2 "
             End If

         Case "DEL"                                         ' delete file
            If Gbcnttoken = 2 Then
               Lstoken = Getnexttokenstr(12)
               Lstoken = Trim(lstoken)
               Kill Lstoken
               Printdoserror
           Else
              Printparametercounterror "1 "
           End If

         Case "WLI"                                         ' Write line to file
            If Gbcnttoken = 3 Then
               Llong1 = Getnexttokenlong(1 , 255)
               Lbyte1 = Llong1
               Lstoken = Getnexttokenstr(20)
               'print #lbyte1 , tstr1
               Print #lbyte1 , Lstoken
               Printdoserror
            Else
               Printparametercounterror "1 "
            End If

         Case "WLIM"                                        ' write multiple lines to file
            If Gbcnttoken = 5 Then
               Llong1 = Getnexttokenlong(1 , 255)
               Llong2 = Getnexttokenlong(1 , 10000)
               Llong3 = Getnexttokenlong(1 , 100000)
               Lbyte1 = Llong1
               Lstoken = Getnexttokenstr(20)
               If Gbpcinputerror = Cpno Then
                  For Llong4 = Llong2 To Llong3
                     Gstestline = Lstoken + " "
                     Gstestline = Lstoken + Str(llong4)

                    Print #lbyte1 , Gstestline
                    If Gbdoserror <> 0 Then
                       Printdoserror
                       Exit For
                    End If
                  Next
               End If
            Else
               Printparametercounterror "4 "
            End If


         Case "WBY"                                         ' Write byte to file
            If Gbcnttoken = 3 Then
               Llong1 = Getnexttokenlong(1 , 255)
               Lbyte1 = Llong1
               Lstoken = Getnexttokenstr(1)
               Lbyte3 = Asc(lstoken)                        ' get first character
               Lbyte2 = Filebyteoutput(lbyte1 , Lbyte3)
               Printdoserror
            Else
               Printparametercounterror "2 "
            End If

         Case "RBY"                                         ' Read Byte from File
            If Gbcnttoken = 2 Then
               Llong1 = Getnexttokenlong(1 , 255)
               Lbyte1 = Llong1
               Lbyte2 = Filebyteinput(lbyte1 )
               If Gbdoserror <> 0 Then
                  Printdoserror
               Else
                  Print #1 , Chr(lbyte2)
               End If
            Else
               Printparametercounterror "1 "
            End If

         Case "CLOSE"                                       ' Close file
            If Gbcnttoken = 2 Then
               Llong1 = Getnexttokenlong(1 , 255)
               Lbyte1 = Llong1
               Close #lbyte1
               Printdoserror
            Else
               Printparametercounterror "1 "
            End If

         Case "FLUSH"                                       ' flush file
            Lbyte2 = 0
            If Gbcnttoken = 1 Then
               Flush
            Elseif Gbcnttoken = 2 Then
               Llong1 = Getnexttokenlong(1 , 255)
               Lbyte1 = Llong1
               Flush #lbyte1

            Else
               Printparametercounterror "0 or 1 "
            End If
            Printdoserror

         Case "BSAVE"                                       ' save SRAM to file
            If Gbcnttoken = 4 Then
                Lstoken = Getnexttokenstr(12)               ' Filename
                Llong1 = Getnexttokenlong(0 , &HFFFF)       ' Start
                Llong2 = Getnexttokenlong(1 , &HFFFF)       ' Length
                Lword1 = Llong1 : Lword2 = Llong2
                If Gbpcinputerror = Cpno Then
                    Bsave Lstoken , Lword1 , Lword2
                    Printdoserror
                End If
             Else
               Printparametercounterror "3 "
            End If

        Case "BLOAD"                                        ' load SRAM with file content
            If Gbcnttoken = 3 Then
                Lstoken = Getnexttokenstr(20)               ' Filename
                Llong1 = Getnexttokenlong(0 , &HFFFF)       ' Start
                Lword1 = Llong1
                If Gbpcinputerror = Cpno Then
                    Bload Lstoken , Lword1
                    Printdoserror
                End If
             Else
               Printparametercounterror "2 "
            End If

        Case "FILEATTR"                                     ' File open mode
            If Gbcnttoken = 2 Then
               Llong1 = Getnexttokenlong(1 , 255)
               Lbyte1 = Llong1
               Lbyte2 = Fileattr(lbyte1)
               If Lbyte2 <> 0 Then
                  Print #1 , Lbyte2
               Else
                  Printdoserror
               End If
            Else
               Printparametercounterror "1 "
            End If

        Case "FREEFILE"                                     ' File open mode
            If Gbcnttoken = 1 Then
               Lbyte2 = Freefile()
               If Lbyte2 <> 0 Then
                  Print #1 , Lbyte2
               Else
                  Printdoserror
               End If
            Else
               Printparametercounterror "no "
            End If

        Case "EOF"                                          ' File open mode
            If Gbcnttoken = 2 Then
               Llong1 = Getnexttokenlong(1 , 255)
               Lbyte1 = Llong1
               Lbyte2 = Eof(#lbyte1)
               If Gbdoserror = 0 Then
                  Print #1 , Lbyte2
               Else
                  Printdoserror
               End If
            Else
               Printparametercounterror "1 "
            End If


         Case "PUTL"
            If Gbcnttoken > 2 Then
               Llong1 = Getnexttokenlong(1 , 255)
               Llong2 = Getnexttokenlong( -10000000 , 10000000)
               Lbyte1 = Llong1
               If Gbcnttoken > 3 Then
                  Llong3 = Getnexttokenlong(1 , 10000000)
                  Put #lbyte1 , Llong2 , Llong3
               Else
                  Put #lbyte1 , Llong2
               End If
               Printdoserror
            Else
               Printparametercounterror "2 or 3 "
            End If

         Case "GETL"
            If Gbcnttoken > 1 Then
               Llong1 = Getnexttokenlong(1 , 255)
               Lbyte1 = Llong1
               If Gbcnttoken > 2 Then
                  Llong3 = Getnexttokenlong(1 , 10000000)
                  Get #lbyte1 , Llong2 , Llong3
               Else
                  Get #lbyte1 , Llong2
               End If
               If Gbdoserror <> 0 Then
                  Printdoserror
               Else
                  Print #1 , Llong2
               End If
            Else
               Printparametercounterror "1 or 2 "
            End If


         Case "PUTB"
            If Gbcnttoken > 2 Then
               Llong1 = Getnexttokenlong(1 , 255)
               Llong2 = Getnexttokenlong(0 , 255)
               Lbyte1 = Llong1
               Lbyte3 = Llong2
               If Gbcnttoken > 3 Then
                  Llong3 = Getnexttokenlong(1 , 10000000)
                  Put #lbyte1 , Lbyte3 , Llong3
               Else
                  Put #lbyte1 , Lbyte3
               End If
               Printdoserror
            Else
               Printparametercounterror "2 or 3 "
            End If

         Case "GETB"
            If Gbcnttoken > 1 Then
               Llong1 = Getnexttokenlong(1 , 255)
               Lbyte1 = Llong1
               If Gbcnttoken > 2 Then
                  Llong3 = Getnexttokenlong(1 , 10000000)
                  Get #lbyte1 , Lbyte3 , Llong3
               Else
                  Get #lbyte1 , Lbyte3
               End If
               If Gbdoserror <> 0 Then
                  Printdoserror
               Else
                  Print #1 , Lbyte3
               End If
            Else
               Printparametercounterror "1 or 2 "
            End If

         Case "PUTI"
            If Gbcnttoken > 2 Then
               Llong1 = Getnexttokenlong(1 , 255)
               Llong2 = Getnexttokenlong( -32767 , 32767)
               Lbyte1 = Llong1
               Lint1 = Llong2
               If Gbcnttoken > 3 Then
                  Llong3 = Getnexttokenlong(1 , 10000000)
                  Put #lbyte1 , Lint1 , Llong3
               Else
                  Put #lbyte1 , Lint1
               End If
               Printdoserror
            Else
               Printparametercounterror "2 or 3 "
            End If

         Case "PUTW"
            If Gbcnttoken > 2 Then
               Llong1 = Getnexttokenlong(1 , 255)
               Llong2 = Getnexttokenlong(0 , 65635)
               Lbyte1 = Llong1
               Lword1 = Llong2
               If Gbcnttoken > 3 Then
                  Llong3 = Getnexttokenlong(1 , 10000000)
                  Put #lbyte1 , Lword1 , Llong3
               Else
                  Put #lbyte1 , Lword1
               End If
               Printdoserror
            Else
               Printparametercounterror "2 or 3 "
            End If

         Case "GETI"
            If Gbcnttoken > 1 Then
               Llong1 = Getnexttokenlong(1 , 255)
               Lbyte1 = Llong1
               If Gbcnttoken > 2 Then
                  Llong3 = Getnexttokenlong(1 , 10000000)
                  Get #lbyte1 , Lint1 , Llong3
               Else
                  Get #lbyte1 , Lint1
               End If
               If Gbdoserror <> 0 Then
                  Printdoserror
               Else
                  Print #1 , Lint1
               End If
            Else
               Printparametercounterror "1 or 2 "
            End If

         Case "GETW"
            If Gbcnttoken > 1 Then
               Llong1 = Getnexttokenlong(1 , 255)
               Lbyte1 = Llong1
               If Gbcnttoken > 2 Then
                  Llong3 = Getnexttokenlong(1 , 10000000)
                  Get #lbyte1 , Lword1 , Llong3
               Else
                  Get #lbyte1 , Lword1
               End If
               If Gbdoserror <> 0 Then
                  Printdoserror
               Else
                  Print #1 , Lword1
               End If
            Else
               Printparametercounterror "1 or 2 "
            End If

         Case "PUTS"
            If Gbcnttoken > 2 Then
               Llong1 = Getnexttokenlong(1 , 255)
               Lstoken = Getnexttokenstr(20) : Lstoken = Trim(lstoken) : Lsingle1 = Val(lstoken)
               Lbyte1 = Llong1
               If Gbcnttoken > 3 Then
                  Llong3 = Getnexttokenlong(1 , 10000000)
                  Put #lbyte1 , Lsingle1 , Llong3
               Else
                  Put #lbyte1 , Lsingle1
               End If
               Printdoserror
            Else
               Printparametercounterror "2 or 3 "
            End If

         Case "GETS"
            If Gbcnttoken > 1 Then

               Llong1 = Getnexttokenlong(1 , 255)
               Lbyte1 = Llong1
               If Gbcnttoken > 2 Then
                  Llong3 = Getnexttokenlong(1 , 10000000)
                  Get #lbyte1 , Lsingle1 , Llong3
               Else
                  Get #lbyte1 , Lsingle1
               End If
               If Gbdoserror <> 0 Then
                  Printdoserror
               Else
                  Print #1 , Lsingle1
               End If
            Else
               Printparametercounterror "1 or 2 "
            End If

         Case "PUTT"
            If Gbcnttoken > 2 Then
               Llong1 = Getnexttokenlong(1 , 255)
               Lstoken = Getnexttokenstr(20) : Lstoken = Trim(lstoken)
               Lbyte1 = Llong1
               If Gbcnttoken > 3 Then
                  Llong3 = Getnexttokenlong(1 , 100000000)
                  Llong4 = Getnexttokenlong(1 , 255)
                  Put #lbyte1 , Lstoken , Llong3 , Llong4
               Else
                  Put #lbyte1 , Lstoken
               End If
               Printdoserror
            Else
               Printparametercounterror "2 or 3 "
            End If

         Case "GETT"
            If Gbcnttoken > 1 Then
               Lstoken = ""
               Llong1 = Getnexttokenlong(1 , 255)
               Lbyte1 = Llong1
               If Gbcnttoken > 2 Then
                  Llong3 = Getnexttokenlong(1 , 100000000)
                  Llong4 = Getnexttokenlong(1 , 255)
                  Get #lbyte1 , Lstoken , Llong3 , Llong4
               Else
                  Get #lbyte1 , Lstoken
               End If
               If Gbdoserror <> 0 Then
                  Printdoserror
               Else
                  Print #1 , Lstoken
               End If
            Else
               Printparametercounterror "1 or 2 "
            End If

         Case "TIME"

            If Gbcnttoken = 1 Then
               Print #1 , Time$
            Elseif Gbcnttoken = 2 Then
               Time$ = Getnexttokenstr(8)
            Else
               Printparametercounterror "0 or 1"
            End If

         Case "DATE"

            If Gbcnttoken = 1 Then
               Print #1 , Date$
            Elseif Gbcnttoken = 2 Then
               Date$ = Getnexttokenstr(8)
            Else
               Printparametercounterror "0 or 1"
            End If


         Case "DISKFREE"

            If Gbcnttoken = 1 Then
               Llong1 = Diskfree()
               Print #1 , Llong1
            End If

         Case "DISKSIZE"
            Llong1 = Disksize()
            Print Llong1

         Case "ERROR"
            Print #1 , "Last Error: " ; Gbdoserror


         Case Else

            Print #1 , "Command '" ; Gspcinput ; "' not recognized"

      End Select

      If Transferbuffer_write > 511 Then
         Transferbuffer_write = 0
      End If

   End If
End Sub



Sub Extracttoken
' Counts the Token in the Input-String: gsPCInput
' following variable and arrays are filled
' cntToken: Cont of Token
' PosStrParts: positions, where the tokens start
' LenStrParts: Count of bytes of each token

   Local Lstrlen As Byte
   Local Lparseend As Byte
   Local Lpos1 As Byte , Lpos2 As Byte
   ' Init arrays with 0
   For Gbcnttoken = 1 To Cptoken_max
      Gbposstrparts(gbcnttoken) = 0 : Gblenstrparts(gbcnttoken) = 0
   Next

   Gbcnttoken = 0
   Gspcinput = Trim(gspcinput)
   Lstrlen = Len(gspcinput)                                 ' how long is string
   If Lstrlen = 0 Then                                      'no Input ?
      Exit Sub
   End If
   Lparseend = 0
   Lpos1 = 0
   For Gbcnttoken = 1 To Cptoken_max
      Incr Lpos1
      Lpos2 = Instr(lpos1 , Gspcinput , Cpstrsep)           ' find next blank
      If Lpos2 = 0 Then                                     ' no more found?
         Lpos2 = Lstrlen : Incr Lpos2 : Lparseend = 1
      End If
      Gblenstrparts(gbcnttoken) = Lpos2 - Lpos1             ' Lenght of token
      Gbposstrparts(gbcnttoken) = Lpos1
      If Lparseend = 1 Then
         Exit For
      End If
      Lpos1 = Lpos2
   Next
End Sub


Function Getnexttokenstr(byval Pblen_max As Byte ) As String
   ' Returns next String-token from Input
   ' Parameter: pbLen_Max: Limit for string-length
   Local Lbpos As Byte
   Local Lblen As Byte
   Incr Gbtoken_actual                                      ' switch to new/next token
   Lbpos = Gbposstrparts(gbtoken_actual)                    ' at which position in string
   Lblen = Gblenstrparts(gbtoken_actual)                    ' how long
   If Lblen > Pblen_max Then Lblen = Pblen_max              ' to long?
   Getnexttokenstr = Mid(gspcinput , Lbpos , Lblen)         ' return string
End Function


Function Getnexttokenlong(byval Plmin As Long , Byval Plmax As Long ) As Long
   ' returns a Long-Value from next Token and check for inside lower and upper limit
   ' plMin: minimum limit for return-value
   ' plMax: maximum limit for return-value
   Local Lbpos As Byte
   Local Lblen As Byte
   Local Lstoken As String * 12
   Incr Gbtoken_actual                                      ' switch to new/next token
   Lbpos = Gbposstrparts(gbtoken_actual)                    ' at which position in string
   Lblen = Gblenstrparts(gbtoken_actual)                    ' how long
   If Lblen > 12 Then Lblen = 12                            ' to long?
   If Mid(gspcinput , Lbpos , 1) = "$" Then                 ' Is input a HEX vlue?
      Incr Lbpos : Decr Lblen                               ' adjust pointer to jump over $
      Lstoken = Mid(gspcinput , Lbpos , Lblen)
      Getnexttokenlong = Hexval(lstoken)
   Else
       Lstoken = Mid(gspcinput , Lbpos , Lblen)
       Getnexttokenlong = Val(lstoken)
   End If
   Select Case Getnexttokenlong                             ' check for limits
      Case Plmin To Plmax                                   ' within limits, noting to do
      Case Else
         Gbpcinputerror = Cpyes                             ' Set Error Sign
         Print #1 , Spc(lbpos) ; "^ " ; "Parameter Error ";
         Printparametererrorl Plmin , Plmax                 ' with wanted limits
   End Select
End Function


Sub Printparametercounterror(byval Psparm_anzahl As String * 10)
   ' User message for wrong count of parameter
   Print #1 , "? " ; Psparm_anzahl ; " " ; "Parameter " ; "expected "
End Sub

Sub Printparametererrorl(plparamlow As Long , Plparamhigh As Long)
   ' Print Limits at wrong Input - value
   Print #1 , " [ " ; Plparamlow ; " ] - [ " ; Plparamhigh ; " ] " ; "expected "
End Sub


Sub Printprompt()
    Print #1 ,
    Print #1 , Hex(transferbuffer_write) ; ">" ;
End Sub


Function Getlongfrombuffer(pbsramarray As Byte , Byval Pbpos As Word) As Long
   ' Extract a Long-Value from a Byte-Array
   ' pbSRAMArray: Byte-array, from which the Long-value should be extracted
   ' pbPos: Position, at which the Long-Value starts (0-based)
   Loadadr Pbsramarray , Z
   Loadadr Pbpos , X
   ld r24, x+
   ld r25, x+
   add zl, r24
   adc zh, r25
   Loadadr Getlongfrombuffer , X
   ldi r24, 4
   !Call _mem2_copy
End Function


Function Getwordfrombuffer(pbsramarray As Byte , Byval Pbpos As Word) As Word
   ' Extract a Word-value from a Byte-Array
   ' pbSRAMArray: Byte-array, from which the Word-value should be extracted
   ' pbPos: Position, at which the Word-Value starts (0-based)
   Loadadr Pbsramarray , Z
   Loadadr Pbpos , X
   ld r24, x+
   ld r25, x+
   add zl, r24
   adc zh, r25
   Loadadr Getwordfrombuffer , X
   ldi r24, 2
   !Call _mem2_copy
End Function


Sub Sramdump(pwsrampointer As Word , Byval Pwlength As Word , Plbase As Long)
    ' Dump a Part of SRAM to Print-Output #1
    ' pwSRAMPointer: (Word) Variable which holds the address of SRAM to dump
    ' pwLength: (Word) Count of Bytes to be dumped (1-based)
    Local Lsdump As String * 16
    Local Lbyte1 As Byte , Lbyte2 As Byte
    Local Lword1 As Word , Lword2 As Word
    Local Llong1 As Long

    If Pwlength > 0 Then
      Decr Pwlength
      For Lword1 = 0 To Pwlength
         Lword2 = Lword1 Mod 16
         If Lword2 = 0 Then
            If Lword1 > 0 Then
               Print #1 , "  " ; Lsdump
            End If
            Llong1 = Plbase + Lword1
            Print #1 , Hex(llong1) ; "  " ;
            Lsdump = "                "
            Lbyte2 = 1
         End If
         Lbyte1 = Inp(pwsrampointer)
         Incr Pwsrampointer
         Print #1 , Hex(lbyte1) ; " " ;
         If Lbyte1 > 31 Then
            Mid(lsdump , Lbyte2 , 1) = Lbyte1
         Else
             Mid(lsdump , Lbyte2 , 1) = "."
         End If
         Incr Lbyte2
      Next
      Print #1 , "  " ; Lsdump
    End If
    Plbase = Plbase + Pwlength
End Sub

' -----------------------------------------------------------------------------
' copy Memory from (Z) nach (X)
' counts of bytes in r24
_mem2_copy:
   ld r25, z+
   st x+, r25
   dec r24
   brne _mem2_copy
   ret


Sub Writefiledivvariables(pfn As Byte , Pbyte As Byte , Pint As Integer , Pword As Word , Plong As Long , Psingle As Single , Pstring As String. Pdummy As Byte)
$external _getfilehandle , _filewritecomma , _filewritecrlf , _filewritedecbyte , _filewritedecint , _filewritedecword , _filewritedeclong , _filewritedecsingle
$external _filewritestrconst , _filewritestringquotationmark

    ' first get the file handle
    Loadadr Pfn , X
    ld r24, X
    !Call _GetFileHandle
    brcs _WriteFileDivVariables1

    ' now little bit tricky to load filehandle to Y+0/1 and keep link to Parameter of variable
    adiw yl, 2                                              ' store pointer to filehandle into last dummy variable pointer
    st -Y, zh                                               ' pointer to file handle
    st -Y, zl
    Ldi ZL,Low(_STRING150 * 2)
    Ldi ZH,High(_STRING150 * 2)
    !call _SET_RAMPZ
    !Call _FileWriteStrConst
    !Call _FileWriteComma

    ' Now a byte
    Loadadr Pbyte , Z
    !Call _FileWriteDecByte

    ' Now a comma
    !Call _FileWriteComma

    ' Now an integer
    Loadadr Pint , Z
    !Call _FileWriteDecInt

    ' Now a comma
    !Call _FileWriteComma

    ' now a Word
    Loadadr Pword , Z
    !Call _FileWriteDecWord

    ' now a Comma
    !Call _FileWriteComma

    ' Now a long
    Loadadr Plong , Z
    !Call _FileWriteDecLong

    ' Now a comma
    !Call _FileWriteComma

    ' Now a single
    Loadadr Psingle , Z
    !Call _FileWriteDecSingle

    ' now a comma
    !Call _FileWriteComma

    ' Now a normal string
    Loadadr Pstring , X
    !Call _FileWriteStringQuotationMark

    ' Now finish line with CR-LF
    !Call _FileWriteCRLF

    ' now should Y-Pointer be adjusted, but here not because of above mentioned trick
    'adiw yl, 2
_writefiledivvariables1:
End Sub


Sub Readfiledivvariables(pfn As Byte , Pbyte As Byte , Pint As Integer , Pword As Word , Plong As Long , Psingle As Single , Pstring1 As String , Pstring2 As String , Pdummy As Byte)
$external _getfilehandle , _filereaddec2num , _filereaddecsingle
$external _filereadstring

    ' first get the file handle
    Loadadr Pfn , X
    ld r24, X
    !Call _GetFileHandle
    brcs _ReadFileDivVariables1

    ' now little bit tricky to load filehandle to Y+0/1 and keep link to Parameter of variable
    adiw yl, 2                                              ' store pointer to filehandle into last dummy variable pointer
    st -Y, zh                                               ' pointer to file handle
    st -Y, zl

    Loadadr Pstring2 , X
    ldi r20, 20
    !call _FileReadString


    !Call _FileReadDec2Num
    ' Now a byte
    Loadadr Pbyte , X
    st X, r16

    ' Now an integer
    !Call _FileReadDec2Num
    Loadadr Pint , X
    st X+, r16
    st X, r17


    ' now a Word
    !Call _FileReadDec2Num
    Loadadr Pword , X
    st X+, r16
    st X+, r17

    ' Now a long

    !Call _FileReadDec2Num
    Loadadr Plong , X
    st X+, r16
    st X+, r17
    st X+, r18
    st X+, r19

    ' Now a single
    !Call _FileReadDecSingle
    Loadadr Psingle , X
    st X+, r13
    st X+, r14
    st X+, r15
    st X+, r16

    ' Now a string
    Loadadr Pstring1 , X
    ldi r20, 20
    !call _FileReadString



    ' now should Y-Pointer be adjusted, but here not because of above mentioned trick
    'adiw yl, 2
_readfiledivvariables1:
End Sub

