'-------------------------------------------------------------------------------
'                           DS1307.BAS
' shows how to use the ds1307 clock on the 2313 futurlec board
' it also shows the CONFIG CLOCK=USER option
'-------------------------------------------------------------------------------
$regfile = "2313def.dat"
$crystal = 8000000
$baud = 19200
$lib "mcsbyte.lbx"                                          ' for smaller code
$lib "ds1307clock.lib"                                      ' modified lib
$framesize = 16
$hwstack = 24
$swstack = 16


'configure the scl and sda pins
Config Sda = Portd.6
Config Scl = Portd.5

'address of ds1307
Const Ds1307w = &HD0                                        ' Addresses of Ds1307 clock
Const Ds1307r = &HD1

Config Clock = User                                         ' this will dim the bytes automatic
'dim other needed variables
Dim Weekday As Byte

Print "DS1307"
Waitms 100
' assigning the time will call the SetTime routine
Time$ = "23:58:59"                                          ' to watch the day changing value
Date$ = "11-13-02"                                          ' 13 november 2002
Do
  Print "Date Time : " ; Date$ ; " " ; Time$
  Waitms 500
Loop

End

'called from ds1307clock.lib
Getdatetime:
  I2cstart                                                  ' Generate start code
  I2cwbyte Ds1307w                                          ' send address
  I2cwbyte 0                                                ' start address in 1307

  I2cstart                                                  ' Generate start code
  I2cwbyte Ds1307r                                          ' send address
  I2crbyte _sec , Ack
  I2crbyte _min , Ack                                       ' MINUTES
  I2crbyte _hour , Ack                                      ' Hours
  I2crbyte Weekday , Ack                                    ' Day of Week
  I2crbyte _day , Ack                                       ' Day of Month
  I2crbyte _month , Ack                                     ' Month of Year
  I2crbyte _year , Nack                                     ' Year
  I2cstop
  _sec = Makedec(_sec) : _min = Makedec(_min) : _hour = Makedec(_hour)
  _day = Makedec(_day) : _month = Makedec(_month) : _year = Makedec(_year)
Return

Setdate:
  _day = Makebcd(_day) : _month = Makebcd(_month) : _year = Makebcd(_year)
  I2cstart                                                  ' Generate start code
  I2cwbyte Ds1307w                                          ' send address
  I2cwbyte 4                                                ' starting address in 1307
  I2cwbyte _day                                             ' Send Data to SECONDS
  I2cwbyte _month                                           ' MINUTES
  I2cwbyte _year                                            ' Hours
  I2cstop
Return

Settime:
  _sec = Makebcd(_sec) : _min = Makebcd(_min) : _hour = Makebcd(_hour)
  I2cstart                                                  ' Generate start code
  I2cwbyte Ds1307w                                          ' send address
  I2cwbyte 0                                                ' starting address in 1307
  I2cwbyte _sec                                             ' Send Data to SECONDS
  I2cwbyte _min                                             ' MINUTES
  I2cwbyte _hour                                            ' Hours
  I2cstop
Return