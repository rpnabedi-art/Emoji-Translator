
'Example to copy a SRAM Array to a XRAM Array over Direct Memory Access (DMA)



$regfile = "xm128a1def.dat"
$crystal = 32000000
$hwstack = 64
$swstack = 40
$framesize = 40



'first enable the osc of your choice
Config Osc = Enabled , 32mhzosc = Enabled

'configure the systemclock
Config Sysclock = 32mhz , Prescalea = 1 , Prescalebc = 1_1

' for xplain you need 9600 baud
' Config Com1 = 9600 , Mode = Asynchroneous , Parity = None , Stopbits = 1 , Databits = 8

Config Com5 = 57600 , Mode = Asynchroneous , Parity = None , Stopbits = 1 , Databits = 8
Open "COM5:" For Binary As #1

'SRAM Variables
Dim Ar(100) As Byte , J As Word , W As Word
Dim B As Byte


' Demoboards like XPLAIN has a 64 MBit SDRAM (MT48LC16M4A2TG) which is 8 MByte, it is connected in 3 port, 4 bit databus mode
' http://www.micron.com/products/ProductDetails.html?product=products/dram/sdram/MT48LC16M4A2TG-75
' in the PDF of the SDRAM you can see it is connected as 16 Meg x 4. Refreshcount is 4K and the row address is A0-A11, column addressing is A0-A9
' SDRAM = SYNCHRONOUS DRAM
Config Xram = 3port , Sdbus = 4 , Sdcol = 10 , Sdcas = 3 , Sdrow = 12 , Refresh = 500 , Initdelay = 3200 , Modedelay = 2 , Rowcycledelay = 7 , Rowprechargedelay = 7 , Wrdelay = 1 , Esrdelay = 7 , Rowcoldelay = 7 , Modesel3 = Sdram , Adrsize3 = 8m , Baseadr3 = &H0000
' the config above will set the port registers correct. it will also wait for Ebi_cs3_ctrlb.7
' for all other modes you need to do this yourself !

$xramsize = 8000000                               ' 8 MByte

'XRAM Variables
Dim Dest(100) As Xram Byte


for j=1 to 100
  ar(j)=j ' create an array and assign a value
next

Print #1 , "Start DMA DEMO --> copy SRAM Array to XRAM Array"
Config Dma = Enabled , Doublebuf = Disabled , Cpm = Rr       ' enable DMA


'you can configure 4 DMA channels
Config Dmach0 = Enabled , Burstlen = 8 , Chanrpt = Enabled , Tci = Off , Eil = Off , Sar = None , Sam = Inc , Dar = None , Dam = Inc , Trigger = 0 , Btc = 100 , Repeat = 1 , Sadr = Varptr(ar(1)) , Dadr = Varptr(dest(1))

Start Dmach0                                      ' this will do a manual/software DMA transfer, when trigger<>0 you can use a hardware event as a trigger source

'-------------------------------------------------------------------------------
For J = 1 To 50
  B = Dest(j)                                     'This step is needed to work with XRAM above 64KByte
  Print #1 , J ; "-" ; Ar(j) ; "-" ; B             ' print the values
Next

'-------------------------------------------------------------------------------



End

                            'end program




'(
Terminal Output of example:

Start DMA DEMO --> copy SRAM Array to XRAM Array
1-1-1
2-2-2
3-3-3
4-4-4
5-5-5
6-6-6
7-7-7
8-8-8
9-9-9
10-10-10
11-11-11
12-12-12
13-13-13
14-14-14
15-15-15
16-16-16
17-17-17
18-18-18
19-19-19
20-20-20
21-21-21
22-22-22
23-23-23
24-24-24
25-25-25
26-26-26
27-27-27
28-28-28
29-29-29
30-30-30
31-31-31
32-32-32
33-33-33
34-34-34
35-35-35
36-36-36
37-37-37
38-38-38
39-39-39
40-40-40
41-41-41
42-42-42
43-43-43
44-44-44
45-45-45
46-46-46
47-47-47
48-48-48
49-49-49
50-50-50
')
