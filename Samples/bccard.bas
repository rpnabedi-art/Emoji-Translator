'------------------------------------------------------------------------------
'                         BCCARD.BAS
' This AN shows how to use the BasicCard from Zeitcontrol
'                         www.basiccard.com
'suited for demo          : no
'commercial addon needed  : YES
'------------------------------------------------------------------------------
'connections:
' C1 = +5V
' C2 = PORTD.4 - RESET
' C3 = PIN 4   - CLOCK
' C5 = GND
' C7 = PORTD.5 - I/O

'  /--------------------------------\
'  |                                |
'  |     C1  C5                     |
'  |     C2  C6                     |
'  |     C3  C7                     |
'  |     C4  C8                     |
'  |                                |
'  \--------------------------------/
'
$regfile = "2313def.dat"
$hwstack = 16
$swstack = 24
$framesize = 24
$lib "bccard.lib"
'----------- configure the pins we use ------------
Config Bccard = PORTD , Io = 5 , Reset = 4
'                                    ^ PORTD.4
'                        ^------------ PORTD.5
'               ^--------------------- PORT D

'Load the sample calc.bas into the basiccard


' Now define the procedure in BASCOM
' We pass a string and also receive a string
Bcdef Calc(string)

'We need to dim the following variables
'SW1 and SW2 are returned by the BasicCard
'BC_PCB must be set to 0 before you start a session


'Our program uses a string to pass the data so DIM it
Dim S As String * 15

'Baudrate might be changed
$baud = 9600
' Crystal used must be 3579545 since it is connected to the Card too
$crystal = 3579545


'Perform an ATR
Bcreset


'Now we call the procedure in the BasicCard
'bccall funcname(nad,cla,ins,p1,p2,PRM as TYPE,PRM as TYPE)
S = "1+1+3"                                                 ' we want to calculate the result of this expression

Bccall Calc(0 , &H20 , 1 , 0 , 0 , S)
'                                  ^--- variable to pass that holds the expression
'                              ^------- P2
'                          ^----------- P1
'                      ^--------------- INS
'                 ^-------------------- CLA
'           ^-------------------------- NAD
'For info about NAD, CLA, INS, P1 and P2 see your BasicCard manual
'if an error occurs ERR is set
' The BCCALL returns also the variables SW1 and SW2
Print "Result of calc : " ; S
Print "SW1 = " ; Hex(sw1)
Print "SW2 = " ; Hex(sw2)
'Print Hex(_bc_pcb)  ' for test you can see that it toggles between 0 and 40
Print "Error : " ; Err

'You can call this or another function again in this session

S = "2+2"
Bccall Calc(0 , &H20 , 1 , 0 , 0 , S)
Print "Result of calc : " ; S
Print "SW1 = " ; Hex(sw1)
Print "SW2 = " ; Hex(sw2)
'Print Hex(_bc_pcb)  ' for test you can see that it toggles between 0 and 40
Print "Error : " ; Err


'perform another ATR
Bcreset
Input "expression " , S
Bccall Calc(0 , &H20 , 1 , 0 , 0 , S)
Print "Answer : " ; S


'----and now perform an ATR as a function
Dim Buf(25) As Byte , I As Byte
Buf(1) = Bcreset()
For I = 1 To 25
  Print I ; "  " ; Hex(buf(i))
Next
'typical returns :
'TS = 3B
'T0 = EF
'TB1 = 00
'TC1 = FF
'TD1 = 81  T=1 indication
'TD2 = 31  TA3,TB3 follow T=1 indicator
'TA3 = 50 or 20  IFSC ,50 =Compact Card, 20 = Enhanced Card
'TB3 = 45  BWT blocl waiting time
'T1 -Tk = 42 61 73 69 63 43 61 72 64 20 5A 43 31 32 33 00 00
'         B  a  s  i  c  C  a  r  d     Z  C   1  2  3


'dim some variables
Dim B As Byte , W As Word , L As Long


Print "ECHO"
'try the echotest command
BcDef Echotest(Byte)
B = 100
Bccall Echotest(0 , &HC0 , &H14 , 1 , 0 , B)
Print B


Print "PRM"
'and another test
'define the procedure in the BasicCard program
BcDef Paramtest(Byte , Word , Long)


'assign the variables
B = 1 : W = &H1234 : L = &H12345678

BcCall Paramtest(0 , &HF6 , 1 , 0 , 0 , B , W , L)
Print Hex(sw1) ; Spc(3) ; Hex(sw2)
'and see that the variables are changed by the BasicCard !
Print B ; Spc(3) ; Hex(w) ; "  " ; Hex(l)


End                                                         'end program
