'*******************************************************************************
'
' Module:   HELLO.BAS
'
' Revision:   1.01
'
' Date: 12/19/2006
'
' Description:  Hello example
'
'*******************************************************************************
' ATMEGA 2560
$regfile = "m2560def.dat"
'{TOOLKITDIR}\bascomp {SOURCEFILE} hw=64 ss=64 fr=64 chip=43
$hwstack=64
$swstack=64
$FrameSize=64
'*******************************************************************************
$crystal = 14745600
$baud = 19200
Config Com1 = Dummy , Synchrone = 0 , Parity = None , Stopbits = 1 , Databits = 8 , Clockpol = 0
'
Do
   Print "Hello World!"
   WaitMs 250
Loop
End
