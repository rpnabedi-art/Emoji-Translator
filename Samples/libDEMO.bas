'-------------------------------------------------------------------------
'                           LIBDEMO.BAS
'                      (c) 2000-2013 MCS Electronics
'In order to let this work you must put the mylib.lib file in the LIB dir
'And compile it to a LBX
'-------------------------------------------------------------------------
$regfile = "m88def.dat"

'define the used library
$lib "mylib.lib"

'also define the used routines
$external Test , testconst

'this is needed so the parameters will be placed correct on the stack
Declare Sub Test(byval X As Byte , Y As Byte)

'reserve some space
Dim Z As Byte

'call our own sub routine
Call Test(1 , Z)

'z will be 2 in the used example
End