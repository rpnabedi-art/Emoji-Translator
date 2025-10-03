
'-------------------------------------------------------------------------------
'Cleaned-up version of the MCS Bootloader
'-------------------------------------------------------------------------------

'http://www.mcselec.com/index2.php?option=com_forum&Itemid=59&page=viewtopic&t=7357&highlight=cleanedup+mcs+bootloader


'-------------------------------------------------------------------------------
'Set the Lock and Fuse bits as you like, do not use this values after $prog
'Choose "Bootsize 1024 words" and "Reset vector is bootloader"
'Set the $crystal, $baud and $timeout as you like.
'-------------------------------------------------------------------------------
$crystal = 16e6                                   'Jee Node is running at 16MHz
$baud = 57600                                     '57600 Baud
$timeout = 400000                                 'usual timeout = 400000 with 16MHz
$hwstack = 40
$swstack = 40
$framesize = 40

'-------------------------------------------------------------------------------
'Uncomment the lines that correspond to your type of AVR
'-------------------------------------------------------------------------------
'$regfile = "m8def.dat"
'$regfile = "m48def.dat"
'$regfile = "m88def.dat"
'$loader  = $C00            'set the bootsize to 1024 words under flash size
'const PageMSB = 5          '32 words in a page reguires 5 bits

'$regfile = "m16def.dat"
'$regfile = "m162def.dat"
'$regfile = "m165def.dat"
'$regfile = "m168def.dat"
'$regfile = "m169def.dat"
'$loader  = $1C00           'set the bootsize to 1024 words under flash size
'const PageMSB = 6          '64 words in a page reguires 6 bits

'$regfile = "m161def.dat"
'$loader  = $1E00
'const PageMSB = 6

'$regfile = "m32def.dat"
'$regfile = "m325def.dat"
$regfile = "m328pdef.dat"
'$regfile = "m329def.dat"
'$regfile = "m645def.dat"
'$regfile = "m649def.dat"
'$regfile = "usb162.dat"
$loader = $3c00                                   'sets the bootsize to 1024 words under flash size
Const Pagemsb = 6                                 '64 words in a page reguires 6 bits

'$regfile = "m406def.dat"
'$loader  = $4C00           'sets the bootsize to 1024 words under flash size
'const PageMSB = 6          '64 words in a page reguires 6 bits

'$regfile = "m164pdef.dat"
'$loader  = $1C00           'sets the bootsize to 1024 words under flash size
'const PageMSB = 7          '128 words in a page reguires 7 bits

'$regfile = "m324pdef.dat"
'$loader  = $3C00           'sets the bootsize to 1024 words under flash size
'const PageMSB = 7          '128 words in a page reguires 7 bits

'$regfile = "m64def.dat"
'$regfile = "m640def.dat"
'$regfile = "m644def.dat"
'$regfile = "m644pdef.dat"
'$loader  = $7C00           'sets the bootsize to 1024 words under flash size
'const PageMSB = 7          '128 words in a page reguires 7 bits

'$regfile = "m128def.dat"
'$regfile = "m1280def.dat"
'$regfile = "m1281def.dat"
'$regfile = "m128can.dat"
'$regfile = "usb1287.dat"
'$loader  = $FC00           'sets the bootsize to 1024 words under flash size
'const PageMSB = 7          '128 words in a page reguires 7 bits

'$regfile = "m2560def.dat"
'$regfile = "m2561def.dat"
'$loader  = $1FC00          'sets the bootsize to 1024 words under flash size
'const PageMSB = 7          '128 words in a page reguires 7 bits

'-------------------------------------------------------------------------------
'uncomment the next two lines to enable RS485 support
'-------------------------------------------------------------------------------
'config PINE.2 = output                                     'change the PIN to
'config print = PortE.2, mode = set                         'the really used pin

Config Com1 = Dummy , Synchrone = 0 , Parity = None , Stopbits = 1 , Databits = 8 , Clockpol = 0

Dim Retries As Byte
Dim Receivedbyte As Byte
Dim Kindofdata As Byte
Dim Spmcsrvalue As Byte
Dim Calculatedchecksum As Byte
Dim Receivedblock As Byte
Dim Countedblock As Byte
Dim Invertedblock As Byte
Dim Receivedchecksum As Byte
Dim Receivedbytes(128) As Byte
Dim J As Byte
Dim Vl As Byte
Dim Vh As Byte
Dim Wrd As Word
Dim Page As Word
Dim Z As Long

Disable Interrupts

Const Maxword =(2 ^ Pagemsb) * 2
Const Zpagemsb = Pagemsb + 1
Const Soh = &H01
Const Stx = &H02
Const Eot = &H04
Const Ack = &H06
Const Nak = &H15
Const Can = &H18

Retries = 5
Testformagicbyte:
Receivedbyte = Waitkey()
Print Chr(receivedbyte);
If Receivedbyte = 123 Then
  Kindofdata = 0
  Goto Loader
Elseif Receivedbyte = 124 Then
  Kindofdata = 1
  Goto Loader
Elseif Receivedbyte <> 0 Then
  Decr Retries
  If Retries <> 0 Then Goto Testformagicbyte
End If
Goto _reset

Loader:
Do
  Receivedbyte = Waitkey()
Loop Until Receivedbyte = 0

If Kindofdata = 0 Then
  Spmcsrvalue = 3 : Gosub Do_spm
  Spmcsrvalue = 17 : Gosub Do_spm
End If
Retries = 10

Do
  Calculatedchecksum = 0
  Print Chr(nak);
  Do
    Receivedbyte = Waitkey()
    Select Case Receivedbyte
    Case &H01:                                    '<SOH>
      Incr Countedblock
      Calculatedchecksum = 1
      Receivedblock = Waitkey()
      Calculatedchecksum = Calculatedchecksum + Receivedblock
      Invertedblock = Waitkey()
      Calculatedchecksum = Calculatedchecksum + Invertedblock
      For J = 1 To 128
        Receivedbytes(j) = Waitkey()
        Calculatedchecksum = Calculatedchecksum + Receivedbytes(j)
      Next
      Receivedchecksum = Waitkey()
      If Countedblock = Receivedblock Then
        If Receivedchecksum = Calculatedchecksum Then
          Gosub Writepage
          Print Chr(ack);
        Else
          Print Chr(nak);
        End If
      Else
        Print Chr(nak);
      End If
    Case &H04:                                    '<EOT>
      If Wrd > 0 And Kindofdata = 0 Then
        Wrd = 0
        Spmcsrvalue = 5 : Gosub Do_spm
        Spmcsrvalue = 17 : Gosub Do_spm
      End If
      Print Chr(ack);
      Waitms 20
      Goto _reset
    Case &H18:                                    '<CAN>
      Goto _reset
    Case Else
      Exit Do
    End Select
  Loop

  If Retries > 0 Then
    Waitms 1000
    Decr Retries
  Else
    Goto _reset
  End If
Loop

Writepage:
If Kindofdata = 0 Then
  For J = 1 To 128 Step 2
    Vl = Receivedbytes(j)
    Vh = Receivedbytes(j + 1)
!    lds r0, {vl}
!    lds r1, {vh}
    Spmcsrvalue = 1 : Gosub Do_spm
    Wrd = Wrd + 2
    If Wrd = Maxword Then
      Wrd = 0
      Spmcsrvalue = 5 : Gosub Do_spm
      Spmcsrvalue = 17 : Gosub Do_spm
      Page = Page + 1
      Spmcsrvalue = 3 : Gosub Do_spm
      Spmcsrvalue = 17 : Gosub Do_spm
    End If
  Next
Else
  For J = 1 To 128
    Writeeeprom Receivedbytes(j) , Wrd
    Wrd = Wrd + 1
  Next
End If
Return

Do_spm:
  Bitwait Spmcsr.0 , Reset
  Bitwait Eecr.1 , Reset
  Z = Page
  Shift Z , Left , Zpagemsb
  Z = Z + Wrd
!  lds r30, {Z}
!  lds r31, {Z + 1}
  #if _romsize > 65536
!    lds r24, {Z + 2}
!    sts rampz, r24
  #endif
  Spmcsr = Spmcsrvalue
!  spm
!  nop
!  nop
Return

'How to use this program:
'1- compile this program
'2- program into chip
'3- select MCS Bootloader from programmers
'4- compile a new program
'5- press F4 and reset your micro
'the program will be uploaded into the chip

'How to call the bootloader from your program without a reset ???
'  Goto &H1C00
'The GOTO will do the work, you need to specify the correct bootloader address
'this is the same as the $LOADER statement.