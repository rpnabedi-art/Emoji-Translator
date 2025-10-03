'----------------------------------------------------------------
'                 (c) 1995-2011, MCS Electronics
'                     DMA and UART.bas
' sample written by MAK3
'----------------------------------------------------------------
' You need Bascom-AVR 2.0.6.0 to run this example

' UART C0 over DMA to SRAM

' Serial Input Buffer over DMA
' The Data over UART C0 will be stored in receive_array with array_size
' Every array_size Bytes the DMA Trasaction Complete Interrupt is fired and you can analyze the data

' So there is no interrupt or CPU intervention needed during receiving bytes from UART which is especially nice with big data streams from Serial Interfaces


$regfile = "xm128a1def.dat"
'$regfile = "xm32a4def.dat"
$crystal = 32000000                                         '32MHz
$hwstack = 64
$swstack = 40
$framesize = 40


Config Osc = Enabled , 32mhzosc = Enabled
Config Sysclock = 32mhz                                     '--> 32MHz

'Serial Interface to PC
Config Com5 = 57600 , Mode = Asynchroneous , Parity = None , Stopbits = 1 , Databits = 8
Open "COM5:" For Binary As #1


Print #1 , "UART C0 over DMA to SRAM"


Const Array_size = 8

Dim Receive_array(array_size) As Byte
Dim Dma_ready As Bit
Dim Dma_channel_0_error As Bit
Dim X As Byte

' DMA Interrupt
On Dma_ch0 Dma_ch0_int
'Interrupt will be enabled with  Tci = XX in Config DMAX

Config Dma = Enabled , Doublebuf = Disabled , Cpm = Ch0rr123       ' enable DMA,

'you can configure 4 DMA channels
Config Dmach0 = Enabled , Burstlen = 1 , Chanrpt = Enabled , Tci = Lo , Eil = Lo , Singleshot = Enabled , _
Sar = Burst , Sam = Fixed , Dar = Transaction , Dam = Inc , Trigger = &H4B , Btc = Array_size , Repeat = 0 , Sadr = Varptr(usartc0_data) , Dadr = Varptr(receive_array(1))


'Trigger Base Value = &H4B + Receive complete (RXC) &H00 --> &H4B
'Note that unlimited repeat count can be achieved by enabling repeat mode and setting the repeat count to zero (Chanrpt = Enabled     and    Repeat = 0)

' Destination Address of Array will be reloaded after each Transaction (Dar = transaction)

Config Priority = Static , Vector = Application , Lo = Enabled , Med = Enabled
Enable Interrupts

'-------------------------[Main Loop]-------------------------------------------
Do

  If Dma_ready = 1 Then
    Reset Dma_ready

    Print #1 , "---------"
    ' Do something with the data here.....

    ' like Print Results back to COM1
    For X = 1 To Array_size
      Print #1 , Chr(receive_array(x))
    Next
  End If


Loop
'-------------------------------------------------------------------------------


End                                                         'end program

'-------------------------[Interrupt Service Routines]--------------------------

' Dma_ch0_int is for DMA Channel ERROR Interrupt A N D for TRANSACTION COMPLETE Interrupt
' Which Interrupt fired must be checked in Interrupt Service Routine
Dma_ch0_int:

If Dma_intflags.0 = 1 Then                                  'Channel 0 Transaction Interrupt Flag
  Set Dma_intflags.0                                        'Clear the Channel 0 Transaction Complete flag
  Set Dma_ready
End If

If Dma_intflags.4 = 1 Then                                  'Channel 0 ERROR Flag
  Set Dma_intflags.4                                        'Clear the flag
  Set Dma_channel_0_error                                   'Channel 0 Error
End If

Return