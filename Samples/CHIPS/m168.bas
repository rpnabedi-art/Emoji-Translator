'--------------------------------------------------------------------------------
'name                     : m168.bas
'copyright                : (c) 1995-2005, MCS Electronics
'purpose                  : demonstrates M168 and clockdiv
'micro                    : Mega168
'suited for demo          : yes
'commercial addon needed  : no
'--------------------------------------------------------------------------------
$regfile = "m168def.dat"
$crystal = 8000000
$baud = 19200
$hwstack = 40
$swstack = 40
$framesize = 40


Config Com1 = Dummy , Synchrone = 0 , Parity = None , Stopbits = 1 , Databits = 8 , Clockpol = 0

'you can specify loadersize in the program but also in the IDE
'$loadersize = 1024

Config Portb = Output
Dim J As Byte

Config Clockdiv = 1                                         'cpu runs at 8 Mhz now
Gosub Doleds                                                ' 1 sec flash

Config Clockdiv = 8                                         '1 Mhz speed
Gosub Doleds                                                'leds go slow on 8 Secs

Config Clockdiv = 64                                        'divide by 64
Gosub Doleds                                                'very, very slow

End



'just toggle the leds a bit
Doleds:
  For J = 1 To 10
    Toggle Portb
    Waitms 1000
  Next
Return