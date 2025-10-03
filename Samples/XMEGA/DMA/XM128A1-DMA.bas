'----------------------------------------------------------------
'                  (c) 1995-2011, MCS
'                   xm128A1-DMA.bas
'  This sample demonstrates DMA with an Xmega128A1
'-----------------------------------------------------------------
$RegFile = "xm128a1def.dat"
$Crystal = 32000000
$HWstack = 64
$SWstack = 40
$FrameSize = 40


'first enable the osc of your choice
Config Osc = Enabled , 32mhzosc = Enabled

'configure the systemclock
Config Sysclock = 32mhz , Prescalea = 1 , Prescalebc = 1_1

Config Com1 = 38400 , Mode = Asynchroneous , Parity = None , Stopbits = 1 , Databits = 8

Dim ar(100) As Byte, dest(100) As Byte,j As Byte ,w As Word

For j = 1 To 100
  ar(j) = j ' create an array and assign a value
Next

Print "DMA DEMO"
Config dma = enabled, doublebuf = disabled,cpm = RR ' enable DMA

'you can configure 4 DMA channels
Config dmach0 = enabled ,burstlen = 8,chanrpt = enabled, tci = Off,eil = Off, sar = none,sam = inc,dar = none,dam = inc ,trigger = 0,btc = 100 ,repeat = 1,sadr = Varptr(ar(1)),dadr = Varptr(dest(1))

Start DMACH0 ' this will do a manual/software DMA transfer, when trigger<>0 you can use a hardware event as a trigger source

For j = 1 To 50
  Print j ; "-" ; ar(j) ; "-" ; dest(j)  ' print the values
Next
End
