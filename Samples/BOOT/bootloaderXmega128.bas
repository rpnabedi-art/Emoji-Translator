'----------------------------------------------------------------
'                          (c) 1995-2009, MCS
'                        BootloaderXmega128.bas
'  This sample demonstrates how you can write your own bootloader
'  in BASCOM BASIC for the XMEGA
'-----------------------------------------------------------------
'The loader is supported from the IDE
$regfile = "xm128a1def.dat"
$crystal = 32000000                                         ' xmega128 is running on 32 MHz
$hwstack = 40
$swstack = 40
$framesize = 40

'first enabled the osc of your choice
Config Osc = Enabled , 32mhzosc = Enabled                   'internal 2 MHz and 32 MHz enabled

'configure the systemclock
Config Sysclock = 32mhz , Prescalea = 1 , Prescalebc = 1_1  ' we will use 32 MHz and divide by 1 to end up with 32 MHz


$loader = &H10000                                           ' bootloader starts after the application
'$bootvector    ' use the interrupt vector table (will increase code size)

'this sample uses 38400 baud. To be able to use the Xplain which has a bootloader working at 9600 baud you need to use 9600 baud
Config Com1 = 38400 , Mode = Asynchroneous , Parity = None , Stopbits = 1 , Databits = 8       ' use USART C0
'COM0-USARTC0, COM1-USARTC2, COM2-USARTD0. etc.


'Config Portc.3 = Output                                     'define TX as output
'Config Pinc.2 = Input

Const Maxwordbit = 7                                        ' Z7 is maximum bit                                   '
Const Maxword =(2 ^ Maxwordbit) * 2                         '128
Const Maxwordshift = Maxwordbit + 1
Const Cdebug = 0                                            ' leave this to 0



'Dim the used variables
Dim Bstatus As Byte , Bretries As Byte , Bmincount As Byte , Bblock As Byte , Bblocklocal As Byte
Dim Bcsum1 As Byte , Bcsum2 As Byte , Buf(128) As Byte , Csum As Byte
Dim J As Byte , Spmcrval As Byte                            ' self program command byte value

Dim Z As Long                                               'this is the Z pointer word
Dim Vl As Byte , Vh As Byte                                 ' these bytes are used for the data values
Dim Wrd As Word , Page As Word                              'these vars contain the page and word address


Disable Interrupts                                          'we do not use ints

'We start with receiving a file. The PC must send this binary file

'some constants used in serial com
Const Nak = &H15
Const Ack = &H06
Const Can = &H18


$timeout = 500000                                           'we use a timeout
'When you get LOADER errors during the upload, increase the timeout value
'for example at 16 Mhz, use 200000

Print "LOADER"
Bretries = 5 : Bmincount = 3                                'we try 10 times and want to get 123 at least 3 times
Do
  Bstatus = Waitkey()                                       'wait for the loader to send a byte
  If Bstatus = 123 Then                                     'did we received value 123 ?
     If Bmincount > 0 Then
        Decr Bmincount
     Else
        Print Chr(bstatus);
        Goto Loader                                         ' yes so run bootloader
     End If
  Else                                                      'we received some other data
     If Bretries > 0 Then                                   'retries left?
        Bmincount = 3
        Decr Bretries
     Else
        Rampz = 0
        Goto Proces_reset                                   'goto the normal reset vector at address 0
     End If
  End If
Loop




'this is the loader routine. It is a Xmodem-checksum reception routine
Loader:
  Do
     Bstatus = Waitkey()
  Loop Until Bstatus = 0

  Spmcrval = &H20 : Gosub Do_spm                            ' erase  all app pages


Bretries = 10                                               'number of retries

Do
  Bblocklocal = 1
  Csum = 0                                                  'checksum is 0 when we start
  Print Chr(nak);                                           ' firt time send a nack
  Do

    Bstatus = Waitkey()                                     'wait for statuse byte

    Select Case Bstatus
       Case 1:                                              ' start of heading, PC is ready to send
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
                  Incr Bblocklocal                          'increase local block count
               Else                                         'no match so send nak
                  Print Chr(nak);
               End If
            Else
               Print Chr(nak);                              'blocks do not match
            End If
       Case 4:                                              ' end of transmission , file is transmitted
             If Wrd > 0 Then                                'if there was something left in the page
                 Wrd = 0                                    'Z pointer needs wrd to be 0
                 Spmcrval = &H24 : Gosub Do_spm             'write page
             End If
             Print Chr(ack);                                ' send ack and ready
             Waitms 20
             Goto Proces_reset
       Case &H18:                                           ' PC aborts transmission
             Goto Proces_reset                              ' ready
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
     Goto Proces_reset                                      'reset chip
  End If
Loop



'write one or more pages
Writepage:
   For J = 1 To 128 Step 2                                  'we write 2 bytes into a page
      Vl = Buf(j) : Vh = Buf(j + 1)                         'get Low and High bytes
      lds r0, {vl}                                          'store them into r0 and r1 registers
      lds r1, {vh}
      Spmcrval = &H23 : Gosub Do_spm                        'write value into page at word address
      Wrd = Wrd + 2                                         ' word address increases with 2 because LS bit of Z is not used
      If Wrd = Maxword Then                                 ' page is full
          Wrd = 0                                           'Z pointer needs wrd to be 0
          Spmcrval = &H24 : Gosub Do_spm                    'write page
          Page = Page + 1                                   'next page
      End If
   Next
Return


Do_spm:
  Z = Page                                                  'make equal to page
  Shift Z , Left , Maxwordshift                             'shift to proper place
  Z = Z + Wrd                                               'add word
  lds r30,{Z}
  lds r31,{Z+1}

  #if _romsize > 65536
      lds r24,{Z+2}
      sts rampz,r24                                         ' we need to set rampz also for the M128
  #endif

  Nvm_cmd = Spmcrval
  Cpu_ccp = &H9D
  spm                                                       'this is an asm instruction
Do_spm_busy:
   lds r23, NVM_STATUS
   sbrc r23,7 ;if  busy bit is cleared  skip next instruc tion
   rjmp do_spm_busy
Return



Proces_reset:
  Rampz = 0
  Goto _reset                                               'start at address 0

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