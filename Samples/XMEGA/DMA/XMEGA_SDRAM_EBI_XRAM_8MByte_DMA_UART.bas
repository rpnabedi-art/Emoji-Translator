

' Serial UART E0 (COM5) Data over DMA to XRAM

' When data like ASCII arrive in usarte0_data (the data receive register of UART 0 on Port E ) the data will be transfered over DMA Channel 0 to the
' XRAM position of Array X.

' DMA DATA Transfer:
' A Data Transfer copies one, two, four, or eight bytes from the source to the destination address in one Burst Transfer

' DMA Block Transfer:
' A Block Transfer is the operation of performing all data transfers necessary to transfer the number of bytes given by the BLOCK SIZE.

' DMA Transaction:
' A DMA Transaction is the whole operation with all data transfers and repeated block transfers.

' In the following example every ARRAY_SIZE Bytes the DMA Transaction Complete Interrupt is fired and you can analyze the data in the main loop

' A Transaction in the following example is  20 Byte ( when Array_size = 20 ) which will set the Block Transfer Count (Btc).


' After loading the program in the ATXMEGA128A1 you can open a Terminal Program and send ASCII to the ATXMEGA over UART E0.
' After sending the 20 Byte ( when Array_size = 20 ) a DMA Interrupt is generated.

' The BTC (Block Transfer Count) which is also the 16-Bit TRFCNT Register can be set up to 64KByte

' So there is no interrupt or CPU intervention needed during receiving bytes from UART
' which is especially nice with big data streams from Serial Interfaces


$regfile = "xm128a1def.dat"
$crystal = 32000000                               '32MHz
$hwstack = 64
$swstack = 64
$framesize = 64

$initmicro                                        'initmmicro is used here to reset the ATXMEGA in order to flash the ATXMEGE over Bootloader


' First Enable The Osc Of Your Choice
Config Osc = Enabled , 32mhzosc = Enabled         '32MHz
' configure the systemclock
Config Sysclock = 32mhz , Prescalea = 1 , Prescalebc = 1_1       '32MHz

Enable Interrupts
Config Priority = Static , Vector = Application , Lo = Enabled

' for xplain you need 9600 baud
' Config Com1 = 9600 , Mode = Asynchroneous , Parity = None , Stopbits = 1 , Databits = 8


Config Com5 = 57600 , Mode = Asynchroneous , Parity = None , Stopbits = 1 , Databits = 8
Open "COM5:" For Binary As #2

Dim B As String * 1
Dim Index As Dword
Dim Memory_address As Word

Dim Dma_ready As Bit
Dim Dma_channel_0_error As Bit

 Const Array_size = 20                            '<<<<<<<<<<<<<<<<<<<<<----------------------------------------------

 ' DMA Interrupt
 On Dma_ch0 Dma_ch0_int
'Interrupt will be enabled with  Tci = XX in Config DMAX


Print #2 , "---Start of XRAM and Serial Data over UART to DMA Demo for XMEGA---"
Print #2 ,




' Demoboards like XPLAIN has a 64 MBit SDRAM (MT48LC16M4A2TG) which is 8 MByte, it is connected in 3 port, 4 bit databus mode
' http://www.micron.com/products/ProductDetails.html?product=products/dram/sdram/MT48LC16M4A2TG-75
' in the PDF of the SDRAM you can see it is connected as 16 Meg x 4. Refreshcount is 4K and the row address is A0-A11, column addressing is A0-A9
' SDRAM = SYNCHRONOUS DRAM
Config Xram = 3port , Sdbus = 4 , Sdcol = 10 , Sdcas = 3 , Sdrow = 12 , Refresh = 500 , Initdelay = 3200 , Modedelay = 2 , Rowcycledelay = 7 , Rowprechargedelay = 7 , Wrdelay = 1 , Esrdelay = 7 , Rowcoldelay = 7 , Modesel3 = Sdram , Adrsize3 = 8m , Baseadr3 = &H0000
' the config above will set the port registers correct. it will also wait for Ebi_cs3_ctrlb.7
' for all other modes you need to do this yourself !

$xramsize = 8000000                               ' 8 MByte


Dim Dummy(49151) As Xram Byte                     'Dummy Array up to address 65534 (two byte before 64KByte boundary)
Dim X(1000) As Xram Byte                          'Address of X(1) = 65535 which is the last byte of the 64KByte so X(1) is within 64KByte


' +-------------------+   &H000000
' |                   |
' |    I/O memory     |
' |    (max 4KByte)   |
' +-------------------+   &H001000
' |     EEPROM        |
' |    (max 4KByte)   |
' |                   |
' +-------------------+   &H002000
' |     SRAM          |
' |     (max 16KByte) |
' |                   |
' +-------------------+   &H004000   Start of XRAM but also XRAM Adress =  16384 is first address of Dummy(1)
' |                   |  Address of Dummy(1) = 16384
' |  Dummy(49151)     |
' |  As Xram Byte     |
' |*******************|  Address of X(1) = 65535
' |  X(1000)          |
' |  As Xram Byte     |
' |*******************|
' |                   |
' |  Free XRAM        |
' +-------------------+    External Memory = 7.98 MByte


' The free XRAM can be calculated by:
' 8000000 Byte - 16384(SRAM) Byte - 49151 Byte - 1000 Byte = 7933465 Byte


'----------------------------DMA configutations---------------------------------



 Config Dma = Enabled , Doublebuf = Disabled , Cpm = Ch0rr123       ' enable DMA,

'you can configure 4 DMA channels
Config Dmach0 = Enabled , Burstlen = 1 , Chanrpt = Enabled , Tci = Lo , Eil = Lo , SINGLESHOT = enabled ,  _
 Sar = Burst , Sam = Fixed , Dar = Transaction , Dam = Inc , Trigger = &H8B , Btc = Array_size , Repeat = 0 , Sadr = Varptr(usarte0_data) , Dadr = Varptr(x(1))

' usarte0_data --> Receive Data from USART E0 = COM5

' Trigger Base Value for USART E0 = COM5 = &H8B + Receive complete (RXC) &H00 --> &H8B
' Note that unlimited repeat count can be achieved by enabling repeat mode and setting the repeat count to zero (Chanrpt = Enabled     and    Repeat = 0)

' Destination Address of Array will be reloaded after each Transaction

' Source Address (Sadr) = Adress of USARTE0_DATA

'----------------------------DMA configutations---------------------------------


' Now we want to find out the first Address of the XRAM Variable
Memory_address = Varptr(x(1))                     'Varptr works up to 64KByte (16-Bit) te but not above !
Print #2 , "The x(1) XRAM Adress =  " ; Memory_address       'This is 16384 which is the first Byte after the 16KByte SRAM of XMEGA !

'-------------------------[Main Loop]-------------------------------------------
 Do

  'Software Reset of XEMGA when pressing button on PINE.5
  If Pine.5 = 0 Then                              'Software Reset over a button swiching to GND (used for Bootloader)
     Waitms 50
     Cpu_ccp = &HD8                            'enable change of protected Registers for following 4 CPU Instruction Cycles
     Rst_ctrl.0 = 1                               'Initiate Software Reset by setting Bit0 of RST_CTRL Register
  End If


 if dma_ready = 1 then
     reset dma_ready

     Print #2 , "---------"
    ' Do something with the data here.....

    ' like Print Results back to COM5
      For Index = 1 To Array_size
         B = Chr(x(index))                        'Send back the 20 Byte which we have sent to the XRAM over UART and DMA
         Print #2 , B
      next
 end if


 Loop
'-------------------------------------------------------------------------------
End


'Label for $initmicro
_init_micro:
 Config Porte.5 = Input
 Porte_pin5ctrl = Bits(3 , 4)                     ' Enable Pullup
Return



'-------------------------[Interrupt Service Routines]--------------------------

 ' Dma_ch0_int is for DMA Channel ERROR Interrupt A N D for TRANSACTION COMPLETE Interrupt
 ' Which Interrupt fired must be checked in Interrupt Service Routine
 Dma_ch0_int:

    If Dma_intflags.0 = 1 Then      'Channel 0 Transaction Interrupt Flag
       set Dma_intflags.0  'Clear the Channel 0 Transaction Complete flag
       Set Dma_ready
    end if

    If Dma_intflags.4 = 1 Then  'Channel 0 ERROR Flag
       set Dma_intflags.4 'Clear the flag
       set dma_Channel_0_error   'Channel 0 Error
    end if

 Return