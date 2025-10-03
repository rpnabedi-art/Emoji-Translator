'------------------------------------------------------------------------------
'name                     : asc.bas
'copyright                : (c) 1995-2013, MCS Electronics
'purpose                  : demonstrates ASC function
'micro                    : Mega88
'suited for demo          : yes
'commercial addon needed  : no
'------------------------------------------------------------------------------

$RegFile = "m88def.dat"                                     ' specify the used micro
$crystal = 8000000                                          ' used crystal frequency
$baud = 19200                                               ' use baud rate
$hwstack = 32                                               ' default use 32 for the hardware stack
$swstack = 10                                               ' default use 10 for the SW stack
$framesize = 40                                             ' default use 40 for the frame space

Config Com1 = Dummy , Synchrone = 0 , Parity = None , Stopbits = 1 , Databits = 8 , Clockpol = 0


Dim A As Byte , S As String * 10 , idx as Byte
Print "ASC demo"
S = "ABC"
A = Asc(s)
Print A                                                     'will print 65

print "test with index"
a= asc(s,0) : print a                                       'invalid range will return 0
a= asc(s,2) : print a
a= asc(s,100) : print a                                     'invalid range will return 0


End