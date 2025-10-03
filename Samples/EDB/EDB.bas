$prog &HFF , &HE2 , &HDF , &HF8                             ' generated. Take care that the chip supports all fuse bytes.'----------------------------------------------------------------
'                          (c) 1995-2005, MCS
'                        BootEDB.bas
'  This Bootloader is for the BASCOM-EDB
'  VERSION 3 of the BOOTLOADER.
'-----------------------------------------------------------------
'This sample will be extended to support other chips with bootloader
'The loader is supported from the IDE

$crystal = 8000000
'$crystal = 14745600
$baud = 38400                                               'this loader uses serial com
'It is VERY IMPORTANT that the baud rate matches the one of the boot loader
'do not try to use buffered com as we can not use interrupts
$hwstack = 40
$swstack = 40
$framesize = 40



'$regfile = "m8def.dat"
'Const Loaderchip = 8

'$regfile = "m168def.dat"
'Const Loaderchip = 168

'$regfile = "m16def.dat"
'Const Loaderchip = 16

'$regfile = "m32def.dat"
'Const Loaderchip = 32

$regfile = "m88def.dat"
Const Loaderchip = 88

'$regfile = "m162def.dat"
'Const Loaderchip = 162

'$regfile = "m128def.dat"
'Const Loaderchip = 128

'$regfile = "m64def.dat"
'Const Loaderchip = 64

#if Loaderchip = 88                                         'Mega88
    $loader = $c00                                          'this address you can find in the datasheet
    'the loader address is the same as the boot vector address
    Const Maxwordbit = 5
    Const Maxpages = 96 - 1                                 ' total WORD pages  available for program
    Config Com1 = Dummy , Synchrone = 0 , Parity = None , Stopbits = 1 , Databits = 8 , Clockpol = 0
#endif

#if Loaderchip = 168                                        'Mega168
    $loader = $1c00                                         'this address you can find in the datasheet
    'the loader address is the same as the boot vector address
    Const Maxwordbit = 6
    Config Com1 = Dummy , Synchrone = 0 , Parity = None , Stopbits = 1 , Databits = 8 , Clockpol = 0
#endif

#if Loaderchip = 32                                         ' Mega32
    $loader = $3c00                                         ' 1024 words
    Const Maxwordbit = 6                                    'Z6 is maximum bit                                   '
    Config Com1 = Dummy , Synchrone = 0 , Parity = None , Stopbits = 1 , Databits = 8 , Clockpol = 0
#endif
#if Loaderchip = 8                                          ' Mega8
    $loader = $c00                                          ' 1024 words
    Const Maxwordbit = 5                                    'Z5 is maximum bit                                   '
    Config Com1 = Dummy , Synchrone = 0 , Parity = None , Stopbits = 1 , Databits = 8 , Clockpol = 0
#endif
#if Loaderchip = 161                                        ' Mega161
    $loader = $1e00                                         ' 1024 words
    Const Maxwordbit = 6                                    'Z6 is maximum bit                                   '
#endif
#if Loaderchip = 162                                        ' Mega162
    $loader = $1c00                                         ' 1024 words
    Const Maxwordbit = 6                                    'Z6 is maximum bit                                   '
    Config Com1 = Dummy , Synchrone = 0 , Parity = None , Stopbits = 1 , Databits = 8 , Clockpol = 0
#endif

#if Loaderchip = 64                                         ' Mega64
    $loader = $7c00                                         ' 1024 words
    Const Maxwordbit = 7                                    'Z7 is maximum bit                                   '
    Config Com1 = Dummy , Synchrone = 0 , Parity = None , Stopbits = 1 , Databits = 8 , Clockpol = 0
#endif

#if Loaderchip = 128                                        ' Mega128
    $loader = &HFC00                                        ' 1024 words
    Const Maxwordbit = 7                                    'Z7 is maximum bit                                   '
    Config Com1 = Dummy , Synchrone = 0 , Parity = None , Stopbits = 1 , Databits = 8 , Clockpol = 0
#endif

#if Loaderchip = 16                                         ' Mega16
    $loader = $1c00                                         ' 1024 words
    Const Maxwordbit = 6                                    'Z6 is maximum bit                                   '
    Config Com1 = Dummy , Synchrone = 0 , Parity = None , Stopbits = 1 , Databits = 8 , Clockpol = 0
#endif



Const Maxword =(2 ^ Maxwordbit) * 2                         '128
Const Maxwordshift = Maxwordbit + 1
Const Cdebug = 0                                            ' leave this to 0

#if Cdebug
   Print Maxword
   Print Maxwordshift
'   Print Maxpages
#endif



'Dim the used variables
Dim Bstatus As Byte , Bretries As Byte , Bblock As Byte , Bblocklocal As Byte
Dim Bcsum1 As Byte , Bcsum2 As Byte , Buf(128) As Byte , Csum As Byte
Dim J As Byte , Spmcrval As Byte                            ' self program command byte value

Dim Z As Long                                               'this is the Z pointer word
Dim Vl As Byte , Vh As Byte                                 ' these bytes are used for the data values
Dim Wrd As Word , Page As Word                              'these vars contain the page and word address
Dim Bkind As Byte , Bstarted As Byte
'Mega 88 : 32 words, 128 pages



Disable Interrupts                                          'we do not use ints


'Waitms 100                                                  'wait 100 msec sec
'We start with receiving a file. The PC must send this binary file

'some constants used in serial com
Const Nak = &H15
Const Ack = &H06
Const Can = &H18

'we use some leds as indication in this sample , you might want to remove it
Config Pind.7 = Output
Portd.7 = 0

$timeout = 100000                                           'we use a timeout
'When you get LOADER errors during the upload, increase the timeout value
'for example at 16 Mhz, use 200000

Bretries = 5                                                'we try 5 times
Testfor123:
#if Cdebug
    Print "Try " ; Bretries
    Print "Wait"
#endif
Bstatus = Waitkey()                                         'wait for the loader to send a byte
#if Cdebug
   Print "Got "
#endif

Print Chr(bstatus);

If Bstatus = 123 Then                                       'did we received value 123 ?
   Bkind = 0                                                'normal flash loader
   Goto Loader
Elseif Bstatus = 124 Then                                   ' EEPROM
   Bkind = 1                                                ' EEPROM loader
   Goto Loader
Elseif Bstatus <> 0 Then
   Decr Bretries
   If Bretries <> 0 Then Goto Testfor123                    'we test again
End If

For J = 1 To 10                                             'this is a simple indication that we start the normal reset vector
   Toggle Portd.7 : Waitms 100
Next

#if Cdebug
  Print "RESET"
#endif
Goto _reset                                                 'goto the normal reset vector at address 0


'this is the loader routine. It is a Xmodem-checksum reception routine
Loader:
  #if Cdebug
      Print "Clear buffer"
  #endif
  Do
     Bstatus = Waitkey()
  Loop Until Bstatus = 0


  For J = 1 To 3                                            'this is a simple indication that we start the normal reset vector
     Toggle Portd.7 : Waitms 50
  Next

  If Bkind = 0 Then
     Spmcrval = 3 : Gosub Do_spm                            ' erase  the first page
     Spmcrval = 17 : Gosub Do_spm                           ' re-enable page
  End If


Bretries = 10                                               'number of retries

Do
  Bstarted = 0                                              ' we were not started yet
  Csum = 0                                                  'checksum is 0 when we start
  Print Chr(nak);                                           ' firt time send a nack
  Do

    Bstatus = Waitkey()                                     'wait for statuse byte

    Select Case Bstatus
       Case 1:                                              ' start of heading, PC is ready to send
            Incr Bblocklocal                                'increase local block count
            Csum = 1                                        'checksum is 1
            Bblock = Waitkey() : Csum = Csum + Bblock       'get block
            Bcsum1 = Waitkey() : Csum = Csum + Bcsum1       'get checksum first byte
            For J = 1 To 128                                'get 128 bytes
              Buf(j) = Waitkey() : Csum = Csum + Buf(j)
            Next
            Bcsum2 = Waitkey()                              'get second checksum byte
            If Bblocklocal = Bblock Then                    'are the blocks the same?
               If Bcsum2 = Csum Then                        'is the checksum the same?
                  Gosub Writepage                           'yes go write the page
                  Print Chr(ack);                           'acknowledge
               Else                                         'no match so send nak
                  Print Chr(nak);
               End If
            Else
               Print Chr(nak);                              'blocks do not match
            End If
       Case 4:                                              ' end of transmission , file is transmitted
             If Wrd > 0 Then                                'if there was something left in the page
                 Wrd = 0                                    'Z pointer needs wrd to be 0
                 Spmcrval = 5 : Gosub Do_spm                'write page
                 Spmcrval = 17 : Gosub Do_spm               ' re-enable page
             End If
             Print Chr(ack);                                ' send ack and ready

             Portd.7 = 0                                    ' simple indication that we are finished and ok
             Waitms 20
             Goto _reset                                    ' start new program
       Case &H18:                                           ' PC aborts transmission
             Goto _reset                                    ' ready
       Case 123 : Exit Do                                   'was probably still in the buffer
       Case 124 : Exit Do
       Case Else
          Exit Do                                           ' no valid data
    End Select
  Loop
  If Bretries > 0 Then                                      'attempte left?
     Waitms 1000
     Decr Bretries                                          'decrease attempts
  Else
     Goto _reset                                            'reset chip
  End If
Loop



'write one or more pages
Writepage:
 If Bkind = 0 Then
   For J = 1 To 128 Step 2                                  'we write 2 bytes into a page
      Vl = Buf(j) : Vh = Buf(j + 1)                         'get Low and High bytes
!      lds r0, {vl}                                          'store them into r0 and r1 registers
!      lds r1, {vh}
      Spmcrval = 1 : Gosub Do_spm                           'write value into page at word address
      Wrd = Wrd + 2                                         ' word address increases with 2 because LS bit of Z is not used
      If Wrd = Maxword Then                                 ' page is full
          Wrd = 0                                           'Z pointer needs wrd to be 0
          Spmcrval = 5 : Gosub Do_spm                       'write page
          Spmcrval = 17 : Gosub Do_spm                      ' re-enable page


          If Page < Maxpages Then                           'only if we are not erasing the bootspace
             Page = Page + 1                                'next page
             Spmcrval = 3 : Gosub Do_spm                    ' erase  next page
             Spmcrval = 17 : Gosub Do_spm                   ' re-enable page
          Else
             Portd.7 = 0 : Waitms 200
          End If
      End If
   Next

 Else                                                       'eeprom
     For J = 1 To 128
       Writeeeprom Buf(j) , Wrd
       Wrd = Wrd + 1
     Next
 End If
 Toggle Portd.7 : Waitms 10 : Toggle Portd.7                'indication that we write
Return


Do_spm:
  Bitwait Spmcsr.0 , Reset                                  ' check for previous SPM complete
  Bitwait Eecr.1 , Reset                                    'wait for eeprom

  Z = Page                                                  'make equal to page
  Shift Z , Left , Maxwordshift                             'shift to proper place
  Z = Z + Wrd                                               'add word
!  lds r30,{Z}
!  lds r31,{Z+1}

  #if Loaderchip = 128
!      lds r24,{Z+2}
!      sts rampz,r24                                         ' we need to set rampz also for the M128
  #endif

  Spmcsr = Spmcrval                                         'assign register
!  spm                                                       'this is an asm instruction
!  nop
!  nop
Return


'How you need to use this program:
'1- compile this program
'2- program into chip with sample elctronics programmer
'3- select MCS Bootloader from programmers
'4- compile a new program for example M88.bas
'5- press F4 and reset your micro
' the program will now be uploaded into the chip with Xmodem Checksum
' you can write your own loader.too
'A stand alone command line loader is also available


'How to call the bootloader from your program without a reset ???
'Do
'   Print "test"
'   Waitms 1000
'   If Inkey() = 27 Then
'      Print "boot"
'      Goto &H1C00
'   End If
'Loop

'The GOTO will do the work, you need to specify the correct bootloader address
'this is the same as the $LOADER statement.