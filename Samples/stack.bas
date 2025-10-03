'this sample shows how to check for the stack sizes
'settings must be :
$regfile = "m88def.dat"

'HW Stack : 8
'Soft Stack : 2
'Frame size : 14

'note that the called routine (_STACKCHECK) will use 4 bytes
'ofhardware stack space
'So when your program works, you may subtract the 4 bytes of the needed hardware stack size
'in your final program that does not include the STCHECK

'testmode =0  will work
'testmode =1 will use too much hardware stack
'testmode =2 will use too much soft stack space
'testmode =3 will use too much frame space
Const Testmode = 0
'compile and test the program with testmode from 0-3


'you need to dim the ERROR byte !!
Dim Error As Byte


#if Testmode = 2
   Declare Sub Pass(z As Long , Byval K As Long)
#else
   Declare Sub Pass()
#endif



Dim I As Long
I = 2
Print I
'call the sub in your code at the deepest level
'normally within a function or sub


#if Testmode = 2
   Call Pass(i , 1)
#else
   Call Pass()
#endif
End



#if Testmode = 2
   Sub Pass(z As Long , Byval K As Long)
#else
  Sub Pass()
#endif
    #if Testmode = 3
       Local S As String * 13
    #else
       Local S As String * 8
    #endif

    Print I
    Gosub Test
End Sub


Test:
#if Testmode = 1
  push r0 ; eat some hardware stack space
  push r1
  push r2
#endif

  ' *** here we call the routine ***
  Stcheck
  ' *** when error <>0 then there is a problem ***
#if Testmode = 1
  pop r2
  pop r1
  pop r0
#endif

Return
