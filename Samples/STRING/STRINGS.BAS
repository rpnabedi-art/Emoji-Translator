'-----------------------------------------------------------------------------------------
'name                     : strings.bas
'copyright                : (c) 1995-2005, MCS Electronics
'purpose                  : demo : STRING
'micro                    : Mega48
'suited for demo          : yes
'commercial addon needed  : no
'-----------------------------------------------------------------------------------------

$regfile = "m48def.dat"                                     ' specify the used micro
$crystal = 4000000                                          ' used crystal frequency
$baud = 19200                                               ' use baud rate
$hwstack = 32                                               ' default use 32 for the hardware stack
$swstack = 10                                               ' default use 10 for the SW stack
$framesize = 40                                             ' default use 40 for the frame space

Dim S As String * 50                                        'dimension strtring
Dim Z As String * 20                                        'note that the length mustrt be specified
Dim A As Word
Dim Strt As Byte

A = 1000

S = " Hello World  "
Z = Ltrim(s)                                                'new feature
Z = Rtrim(s)                                                'new feature
Z = Trim(s)                                                 'new feature

S = "Hello world"                                           'assign a constrtant to a strtring
Print S                                                     'show it
Z = "!z"                                                    'assign strtring
Print Z

S = Z + " add this too " + Left(s , 5)                      'concatenate a few strtrings
Print S

S = "Test"
S = Right(s , 2) : Print S                                  'return rightportion of strtring

S = "40000"
A = Val(s)                                                  'convert strtring to integer
Print A

S = "1FFF"
A = Hexval(s)                                               'convert hexadecimal strtring
Print A

S = Hex(a)                                                  'convert back
Print S

A = A + 1                                                   'add 1 to it
S = Str(a)                                                  'convert integer to strtring
Print S

S = "A"
A = Asc(s)                                                  'get ASCII value
Print A

S = ""
S = Chr(a)                                                  'convert ascii to strtring
Print S


A = Len(s)                                                  'get length of strtring
Print A

S = "This is a testrt"
Z = Left(s , 4) : Print Z                                   'return left part of strtring

Z = Right(s , 4) : Print Z                                  'return right part of strtring

Strt = 6
Z = Mid(s , Strt , 2) : Print Z                             'return mid of strtring
Z = Mid(s , Strt ) : Print Z                                'no length specified

Z = "12345"
Mid(s , 1 , 2) = Z                                          'change part of strtring
Print S

Mid(s , 1) = Z
Print S


Z = String(10 , 65)                                         'make a strtring with a length of 10 and use character A
Print Z

Z = Space(5) : Print "{" ; Z ; "}"                          'make a strtring with spaces


Input "Name " , S                                           'ask for strtring
Print "Hello " ; S                                          'print it

Restore Company                                             'restrtore label with data
Read S : Print S                                            'read & print
Read S : Print S                                            'again


Do
  Input "string 1" , S                                      'ask for strtring
  Input "string 2" , Z                                      'agian

  If S <> Z Then                                            'compare strtrings
     Print "<>"
  Elseif S = Z Then
     Print "="
  End If
Loop Until S = Z

S = "This is a case TEST"
Z = Lcase(s) : Print Z                                      'convert to lower case
Z = Ucase(s) : Print Z                                      'convert to upper case



End



Company:                                                    'company data
Data "MCS" , "Electronics"