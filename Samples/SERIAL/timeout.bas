'------------------------------------------------------
'                   TIMEOUT.BAS
' demonstration of the $timeout option
'------------------------------------------------------

'most serial communication functions and routines wait until a character
'or end of line is received.
'This blocks execution of your program. SOmething you can change by using buffered input
'There is also another option : using a timeout
'$timeout Does Not Work With Buffered Serial Input

$regfile = "m48def.dat"
$crystal = 8000000
$baud = 19200
$hwstack = 40
$swstack = 40
$framesize = 40



Dim Sname As String * 10
Dim B As Byte
Do
   $timeout = 1000000
   Input "Name : " , Sname
   Print "Hello " ; Sname

   $timeout = 5000000
   Input "Name : " , Sname
   Print "Hello " ; Sname

Loop

'you can re-configure $timeout