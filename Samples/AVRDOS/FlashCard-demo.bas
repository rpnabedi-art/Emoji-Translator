'-------------------------------------------------------------------------------
'                               FlashCard-Demo.BAS
'    This sample file shows how the AVR-DOS library from Josef Franz Vögel
'    can be used.
'    Because the FAT code needs RAM buffers, you need a Mega103, Mega128
'    or a micro with external memory.
'-------------------------------------------------------------------------------

$regfile = "M128Def.dat"
$crystal = 4000000
$hwstack=128
$swstack=128
$framesize=128
$external Waitms                                            ' one of the libs needs the waitms code
' Check XRAM enabled/disabled and XRAM Size if changing switch XRAMDrive; 1 needs 64kB XRAM enabled
' If use real card in PIN-Mode, you must disable XRAM !!!!!
Const Xramdrive = 1                                         ' 1 for XRAM Drive

Declare Sub Directorylist(pstr1 As String , Byval Pdays As Word)
Declare Sub Testsb(byval Bx As Byte)

Config Date = Dmy , Separator = DOT                         ' the file system uses date and times
Config Clock = Soft                                         ' real clock installed
Enable Interrupts

Time$ = "12:00:00" : Date$ = "05.05.03"                     ' set the time and date
'when you have a clock, the date and time of the clock will be used


' Use Serial 0 for communication with PC-Terminal
$baud = 19200

#if Xramdrive = 0
   Config Serialin = Buffered , Size = 20                  ' do not use it in Simulator-terminal
#endif

Open "Com1:" For Binary As #1                               ' only used to show and check difference with file handles

Print "Lib version : " ; Ver()

' Here you can include the Drive
#if Xramdrive = 0
   $Include "CONFIG_FlashCardDrive.bas"                        ' use real card
'$include "config_flashcard_mmc.bas"
#else
   $xramsize = &H10000
   $Include "CONFIG_XRAMDrive.bas"                             ' simulate with "XRAM-Drive"
#endif

$include "CONFIG_AVR-DOS.Bas"                               ' some constants

' Init Port and Card
Print #1 , "Setup Port and Reset Card ... ";

If Drivecheck() = 0 Then                                    ' we have a card detected
   Print #1 , "OK"
   _temp1 = Driveinit()                                     ' init the drive
Else
   Print #1 , "Card not inserted, check Card!"
   End                                                     'end program
End If

' The card is now setup and the low level card driver routine could be used
' such as ReadSector, WriteSector etc.
' We use the AVD-DOS Filesystem which is compatible with DOS/Windows
' Make sure your CF card is 32MB or bigger. It needs to be formatted with FAT 16
' Smaller cards can only be formatted with FAT12

Print #1 , "Init File System ...  ";

Dim Gbtemp1 As Byte                                         ' scratch byte
Gbtemp1 = Initfilesystem(1)                                 ' we must init the filesystem once
If Gbtemp1 > 0 Then
   Print #1 , "Error " ; Gbtemp1
Else
   Print #1 , " OK"
   Print "Disksize : " ; Disksize()                         ' show disk size in bytes
   Print "Disk free: " ; Diskfree()                         ' show free space too
End If


'dim some test variables
Dim S As String * 60 , Fl As String * 12 , Ff As Byte
Dim Sdatetime As String * 18
Fl = "test.txt"
S = "test this"

'Now we are getting to it
'We can specify a file handle with #1  or #2 etc. or we can ask for a free
' file handle with the FreeFile function. It will return a free handle if there is one.

Ff = Freefile()                                             ' get a file handle

'With this file handle we refer to a file
Open Fl For Output As #ff                                   ' open fikle for output
'  we need to open a file  before we can use the file commands
'  we open it for OUTPUT, INPUT , APPEND or BINARY
'  In this case we open it for OUTPUT because we want to write to the file.
'  If the file existed, the file would be overwritten.
Print #ff , S                                               ' print some data
Print #ff , S
Print #ff , S
Print #ff , "A constant" ; S
Testsb Ff
Close #ff                                                   ' close file

'A file opened if OUTPUT mode is convenient to write string data too
'The next beta will support WRITE too

'We now created a file that contains 3 lines of text.
'We want to append some data to it
S = "this is appended"
Open Fl For Append As #150                                  ' we specify the file number now
Print #150 , S
Close #150


'Ok we want to check if the file contains the written lines
Ff = Freefile()                                             ' get file handle
Open "test.txt" For Input As #ff                            ' we can use a constant for the file too
Print Lof(#ff) ; "  length of file"
Print Fileattr(#ff) ; " file mode"                          ' should be 1 for input
Do
   LineInput #ff , S                                        ' read a line
  ' line input is used to read a line of text from a file
   Print S                                                   ' print on terminal emulator
Loop Until Eof(ff) <> 0
'The EOF() function returns a non-zero number when the end of the file is reached
'This way we know that there is no more data we can read
Close #ff

Ddemo:
'Lets have a look at the file we created
   Print "Dir function demo"
   S = Dir( "*.*")
'The first call to the DIR() function must contain a file mask
' The * means everything.
'
   While Len(s) > 0                                            ' if there was a file found
      Print S ; "  " ; Filedate() ; "  " ; Filetime() ; "  " ; Filelen()
   '   print file , the date the fime was created/changed , the time and the size of the file
      S = Dir()                                                ' get next
   Wend
'Wait 3

'We can use the KILL statement to delete a file.
'A file mask is not supported
   Print "Kill (delete) file demo"
   Kill "test.txt"

   S = Dir( "*.TXT")                                           ' check for TXT files
   While Len(s) > 0
      Print S ; "  " ; Filedate() ; "  " ; Filetime() ; "  " ; Filelen()
      S = Dir()                                                ' get next
   ' the next call to the DIR function must not specify the mask so we get the next file
   Wend
'Wait 3


'for the binary file demo we need some variables of different types
   Dim B As Byte , W As Word , L As Long , Sn As Single , Ltemp As Long
   Dim Stxt As String * 10
   B = 1 : W = 50000 : L = 12345678 : Sn = 123.45 : Stxt = "test"

'open the file in BINARY mode
   Open "test.biN" For Binary As #2
   Put #2 , B                                                  ' write a byte
   Put #2 , W                                                  ' write a word
   Put #2 , L                                                  ' write a long
   Ltemp = Loc(#2) + 1                                         ' get the position of the next byte
   Print Ltemp ; " LOC"                                        ' store the location of the file pointer
   Print Lof(#2) ; "  length of file"
   Print Seek(#2) ; " file pointer"                            ' now you understand difference between loc and seek function
   Print Fileattr(#2) ; " file mode"                           ' should be 32 for binary
   Put #2 , Sn                                                 ' write a single
   Put #2 , Stxt                                               ' write a string

   Flush #2                                                    ' flush to disk
   Close #2

'now open the file again and write only the single
   Open "test.bin" For Binary As #2
   Seek #2 , Ltemp                                             ' set the filepointer
   Sn = 1.23                                                   ' change the single value so we can check it better
   Put #2 , Sn

   L = 1                                                       'specify the file position
   B = Seek(#2 , L)                                            ' reset is the same as using SEEK #2,L
   Get #2 , B                                                  ' get the byte
   Get #2 , W                                                  ' get the word
   Get #2 , L                                                  ' get the long
   Get #2 , Sn                                                 ' get the single
   Get #2 , Stxt                                               ' get the string
   Close #2


'now we send to the RS-232 port the values we read back from the file
   Print B                                                     ' byte must be 1
   Print W                                                     ' word must be 50000
   Print L                                                     ' long must be 12345678
   Print Sn                                                    ' single must be 1.23
   Print Stxt                                                  ' string must be test


'we can print to a file like we print to the RS-232
   Open "file.tst" For Output As #3
   Print #3 , "This is a test" ; B ; " " ; W ; " " ; L ; " " ; Sn
   Close #3

'read back the data
   Open "file.tst" For Input As #3
   LineInput #3 , S
   Print #1 , S                                                'send to terminal emulator
   Close #3


'now the good old bsave and bload
   Dim Ar(100) As Byte , I As Byte
   For I = 1 To 100
      Ar(i) = I                                                 ' fill the array
   Next

   Wait 2

   W = Varptr(ar(1))
   Bsave "josef.img" , W , 100
   For I = 1 To 100
      Ar(i) = 0                                                 '  reset the array
   Next

   Bload "josef.img" , W                                       ' Josef you are amazing !

   For I = 1 To 10
      Print Ar(i) ; " " ;
   Next
   Print

   Print "File demo"
   Print Filelen( "josef.img") ; " length"                     ' length of file
   Print Filetime( "josef.img") ; " time"                      ' time file was changed
   Print Filedate( "josef.img") ; " date"                      ' file date

   Flush                                                       ' flush all open files
   Print "gbDOSerror " ; Gbdoserror
   Print "Finally an advanced dir demo"
   S = "*.*"                                                   ' return anything
   Directorylist S , 2                                         ' show all from the last 2 days

   S = "write"
   Open "write.dmo" For Output As #2
   Write #2 , S , W , L , Sn                                   ' write is also supported
   Close #2

   Open "write.dmo" For Input As #2
   Input #2 , S , W , L , Sn                                   ' write is also supported
   Close #2
   Print S ; "  " ; W ; " " ; L ; "  " ; Sn

' For singles take in mind that the result might differ a bit because of conversion
   Sn = 123.45
   S = Str(sn)                                                 ' create a string
   Print S                                                     ' show result of conversion
   Sn = Val(s)                                                 ' convert from string to single
   Print Sn                                                    ' show result
'When storing singles, better use GET/PUT

   End




' Read and print Directory and show Filename, Date, Time, Size
' for all files matching pStr1 and create/update younger than pDays
Sub Directorylist(pstr1 As String , Byval Pdays As Word)
   Local Lfilename As String * 12                           ' hold file name for print
   Local Lwcounter As Word , Lfilesizesum As Long           ' for summary
   Local Lwnow As Word , Lwdays As Word
   Local Lsec As Byte , Lmin As Byte , Lhour As Byte , Lday As Byte , Lmonth As Byte , Lyear As Byte
   Print "Listing of all Files matching " ; Pstr1 ; " and  create/last update date within " ; Pdays ; " days"
   Lwnow = Sysday()
   Lwcounter = 0 : Lfilesizesum = 0
   Lfilename = Dir(pstr1)
   While Lfilename <> ""
      Lsec = Filedatetime()
      Lwdays = Lwnow - Sysday(lday)                         ' Days between Now and last File Update; uses lDay, lMonth, lYear
      If Lwdays <= Pdays Then                               ' days smaller than desired with parameter
         Print Lfilename ; "  " ; Filedate() ; " " ; Filetime() ; " " ; Filelen()
         Incr Lwcounter : Lfilesizesum = Filelen() + Lfilesizesum
      End If
      Lfilename = Dir()
   Wend
   Print Lwcounter ; " File(s) found with " ; Lfilesizesum ; " Byte(s)"
End Sub


Sub Testsb(byval Bx As Byte)
   Local Zz As String * 5
   Zz = "LOCAL"
   Print #bx , "from sub"
   Print #bx , "local" ; Zz
End Sub