'----------------------------------------------------------------
'                  (c) 1995-2010, MCS
'                      xm128-XRAM-SDRAM-XPLAIN.bas
'  This sample demonstrates the Xmega128A1 XRAM SDRAM
'-----------------------------------------------------------------

$RegFile = "xm128a1def.dat"
$crystal = 32000000
$hwstack = 64
$swstack = 64
$framesize = 64
$xramsize = &H800000


'First Enable The Osc Of Your Choice
Config Osc = Enabled , 32mhzosc = Enabled


'configure the systemclock
Config Sysclock = 32mhz , Prescalea = 1 , Prescalebc = 1_1

'for xplain we need 9600 baud
Config Com1 = 9600 , Mode = Asynchroneous , Parity = None , Stopbits = 1 , Databits = 8

Dim B As Byte , B1 As Byte , B2 As Byte
Config Porte = Output
For B = 1 To 5
  Toggle Porte
  Waitms 1000
Next

Print "Xplain SDRAM test"
'the XPLAIN has a 64 MBit SDRAM which is 8 MByte, it is connected in 3 port, 4 bit databus mode
'in the PDF of the SDRAM you can see it is connected as 16 Meg x 4. Refreshcount is 4K and the row address is A0-A11, column addressing is A0-A9
Config Xram = 3port , Sdbus = 4 , Sdcol = 10 , Sdcas = 3 , Sdrow = 12 , Refresh = 500 , Initdelay = 3200 , Modedelay = 2 , Rowcycledelay = 7 , Rowprechargedelay = 7 , Wrdelay = 1 , Esrdelay = 7 , Rowcoldelay = 7 , Modesel3 = Sdram , Adrsize3 = 8m , Baseadr3 = &H0000
'the config above will set the port registers correct. it will also wait for Ebi_cs3_ctrlb.7
'for all other modes you need to do this yourself !

Dim X(100000) As Xram Byte                                  ' use huge memory

X(80000) = 80

Print X(80000)


Print "SRAM"
X(10000) = 100                                              ' this will use normal SRAM
B = X(10000)
Print "result : " ; B

End