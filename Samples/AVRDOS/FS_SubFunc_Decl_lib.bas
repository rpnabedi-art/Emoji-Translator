'==============================================================================
' BASCOM - ASM Interface routines
'==============================================================================
$nocompile

Declare Function Getattr(psfilename As String) As Byte
Function Getattr(psfilename As String) As Byte
$external _getattr
   Loadadr Psfilename , X
   Loadadr Getattr , Z
   !Call _GetAttr
End Function


Declare Function Getattr0() As Byte
Function Getattr0() As Byte
$external _getattr
   Loadadr Getattr0 , Z
   !Call _GetAttr0
End Function


Declare Function Filebyteinput(byval Pbfilenumber As Byte) As Byte

Function Filebyteinput(byval Pbfilenumber As Byte) As Byte
$external _filebyteinput
   Loadadr Pbfilenumber , X
   ld r24, X
   !Call _FileByteInput
   Loadadr Filebyteinput , X
   st X, r24
End Function


Declare Function Filebyteoutput(byval Pbfilenumber As Byte , Pbvariable As Byte) As Byte


Function Filebyteoutput(byval Pbfilenumber As Byte , Pbvariable As Byte) As Byte
$external _filebyteoutput
   Loadadr Pbfilenumber , X
   ld r24, X
   Loadadr Pbvariable , X
   ld r25, X
   !Call _FileByteOutput
   Loadadr Filebyteoutput , X
   st X, r25                                                ' error code
End Function



'*******************************************************************************
' functions for the Test - Interpreter but for other use as well
'*******************************************************************************


' Declaration of Functions
Declare Sub Sramdump(pwsrampointer As Word , Byval Pwlength As Word , Plbase As Long)

Declare Sub Printdoserror()
' Print DOS Error Number
Sub Printdoserror()
   If Gbdoserror > 0 Then
      Print "DOS Error: " ; Gbdoserror
   End If
End Sub


Declare Sub Directory(pstr1 As String)
' Read and print Directory, Filename, Date, Time, Size
' Input Filename in form "name.ext"
Sub Directory(pstr1 As String)
   Local Lfilename As String * 12                           ' hold file name for print
   Local Lwcounter As Word , Lfilesizesum As Long           ' for summary
   Local Lbyte1 As Byte , Llong1 As Long

   Lwcounter = 0 : Lfilesizesum = 0
   Lfilename = Dir(pstr1)
   While Lfilename <> ""
      Print Lfilename;
      Lbyte1 = 14 - Len(lfilename)
      Print Spc(lbyte1);
      Lbyte1 = Getattr0()
      Llong1 = Filelen()
      Print Filedate() ; " " ; Filetime() ; " " ; Bin(lbyte1) ; " " ; Llong1
      Incr Lwcounter : Lfilesizesum = Lfilesizesum + Llong1
      Lfilename = Dir()
   Wend
   Print Lwcounter ; " File(s) found with " ; Lfilesizesum ; " Byte(s)"
End Sub


Declare Sub Directory1(pstr1 As String , Pdays As Word)

' Read and print Directory and show Filename, Date, Time, Size
' for all files matching pStr1 and create/update younger than pDays
Sub Directory1(pstr1 As String , Pdays As Word)
   Local Lfilename As String * 12                           ' hold file name for print
   Local Lwcounter As Word , Lfilesizesum As Long           ' for summary
'   Local lByte1 as Byte , lLong1 as Long
   Local Lwnow As Word , Lwdays As Word
   Local Lsec As Byte , Lmin As Byte , Lhour As Byte , Lday As Byte , Lmonth As Byte , Lyear As Byte
   Print "Listing of all Files matching " ; Pstr1 ; " and  create/last update date within " ; Pdays ; " days"
   Lwnow = Sysday()
   Lwcounter = 0 : Lfilesizesum = 0
   Lfilename = Dir(pstr1)
   While Lfilename <> ""
      Lsec = Filedatetime()
      Lwdays = Lwnow - Sysday(lday)                         ' Days between Now and last File Update
      If Lwdays <= Pdays Then                               ' days smaller than desired with parameter
         Print Lfilename ; Filedate() ; " " ; Filetime() ; " " ; Filelen()
         Incr Lwcounter : Lfilesizesum = Filelen() + Lfilesizesum
      End If
      Lfilename = Dir()
   Wend
   Print Lwcounter ; " File(s) found with " ; Lfilesizesum ; " Byte(s)"
End Sub



Declare Function Printfile(psname As String) As Byte
' Print File Sector by Sector
Function Printfile(psname As String) As Byte
$external _getfreefilenumber , _normfilename , _openfile , _getfilebufferstatus , _filebuffer2x
$external _loadnextfilesector , _closefilehandle , _cleardoserror,

   !call _GetFreeFileNumber                                 ' to get free file# in r24
   brcs _PrintFileEnd                                       ' Error?; if C-set
   push r24                                                 ' File#
   Loadadr Psname , X
   !call _NormFileName                                      ' Result: Z-> Normalized name
   pop r24                                                  ' File#
   ldi r25, cpFileOpenInput                                 ' Read only and archive-bit allowed
   !call _OpenFile                                          ' Search file, set File-handle and load first sector
   brcs _PrintFileEnd                                       ' Error?; if C-set
   sbiw yl, 2                                               ' If Openfile OK! then (Y-2), (Y-1) -> Filehandle
_printfile2:
   !call  _GetFileBufferStatus_Y                            ' Someting to read?
   sbrc r24, dEOF                                           ' End of File?
   rjmp _PrintFile3
   !call _FileBuffer2X
   !call _SendString0                                       ' X at sector-buffer basis
   !call _LoadNextFileSector_Position
   brcc _PrintFile2                                         ' Loop to print next sector; irregular Error if C-set
_printfile3:
   !call _CloseFileHandle_Y
   adiw yl, 2                                               ' Restore Y
   !call _ClearDOSError
_printfileend:
   Loadadr Printfile , X
   st X, r25                                                ' give Error code back
End Function






Declare Function Printfileb(psname As String) As Byte
' Print File Byte by Byte
Function Printfileb(psname As String) As Byte
$external _getfreefilenumber , _normfilename , _openfile , _getfilebufferstatus , _filereadbyte , _closefilehandle
   !call _GetFreeFileNumber                                 ' to get free file# in r24
   brcs _PrintFileBEnd                                      ' Error?; if C-set
   push r24                                                 ' File#
   Loadadr Psname , X
   !call _NormFileName                                      ' Z-> Normalized Name
   pop r24
   ldi r25, cpFileOpenInput                                 ' Read only and archiv-bit allowed
   !call _OpenFile                                          ' Search file and set File-handle and load first sector
   brcs _PrintFileBEnd                                      ' Error?; if C-set
   sbiw yl, 2                                               ' If Openfile OK! then (Y-2), (Y-1) -> Filehandle
_printfileb2:
   !call  _GetFileBufferStatus_Y                            ' Someting to read?
   sbrc r24, dEOF                                           ' End of File?
   rjmp _PrintFileB3
   !call _FileReadByte
   !call _SendChar0
   rjmp _PrintFileB2
_printfileb3:
   !call _CloseFileHandle_Y
   adiw yl, 2
   clr r25                                                  ' Restore Y
_printfilebend:
   Loadadr Printfileb , X
   st X, r25
End Function



Dim Gword1 As Word
Dim Ldumpbase As Long
Declare Function Dumpfile(psname As String) As Byte

Function Dumpfile(psname As String) As Byte
   Ldumpbase = 0
   !call _GetFreeFileNumber                                 ' to get free file# in r24
   brcs _DumpFileEnd                                        ' Error?; if C-set
   push r24                                                 ' File#
   Loadadr Psname , X
   !call _NormFileName                                      ' Result: Z-> Normalized name
   pop r24                                                  ' File#
   ldi r25, cpFileOpenInput                                 ' Read only and archive-bit allowed
   !call _OpenFile                                          ' Search file, set File-handle and load first sector
   brcs _DumpFileEnd                                        ' Error?; if C-set
   sbiw yl, 2                                               ' If Openfile OK! then (Y-2), (Y-1) -> Filehandle
_dumpfile2:
   !call  _GetFileBufferStatus_Y                            ' Someting to read?
   sbrc r24, dEOF                                           ' End of File?
   rjmp _DumpFile3
   !call _FileBuffer2X
   Loadadr Gword1 , Z
   st Z+, xl
   st Z+, xh
   Sramdump Gword1 , 512 , Ldumpbase
   !call _LoadNextFileSector_Position
   brcc _DumpFile2                                          ' Loop to Dump next sector; irregular Error if C-set
_dumpfile3:
   !call _CloseFileHandle_Y
   adiw yl, 2                                               ' Restore Y
   !call _ClearDOSError
_dumpfileend:
   Loadadr Dumpfile , X
   st X, r25                                                ' give Error code back
End Function