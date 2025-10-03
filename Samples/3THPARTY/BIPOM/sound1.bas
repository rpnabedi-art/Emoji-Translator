'*******************************************************************************
'
' Module:   SOUND1.BAS
'
' Revision:   1.01
'
' Date: 1 July 2012
'
' Description:   Generates sound using the buzzer on TB-1 board
'
' (C) 2012 BiPOM Electronics, Inc. - www.bipom.com
'
'*******************************************************************************
' ATMEGA 2560
$regfile = "m2560def.dat"
'*******************************************************************************
$crystal = 14745600
$hwstack=64
$swstack=64
$FrameSize=64


Dim Pulses As Integer , Periods As Integer
Pulses = 10000 : Periods = 1000                             'set variables

Speaker Alias Portb.7                                       'define port pin


'pulses  range from 1-65535
'periods range from 1-65535

Sound Speaker , Pulses , Periods                            'make some noise

End
