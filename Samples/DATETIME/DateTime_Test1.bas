'-------------------------------------------------------------------------------
'                           DateTime_test.bas
'   This sample show how to use the Date-Time routines from the DateTime.Lib
'   written by Josef Franz Vögel
'-------------------------------------------------------------------------------

' choose the micro you use
$regfile = "M103DEF.DAT"
$hwstack = 40
$swstack = 40
$framesize = 40



Const Clockmode = 1
'use i2c for the clock

#if Clockmode = 1
  Config Clock = Soft                   ' we use build in clock
  Disable Interrupts                    ' NOTE that in normal cases you MUST enable the interrupts
#else
  Config Clock = User                   ' we use I2C for the clock
  'configure the scl and sda pins
  Config Sda = Portd.6
  Config Scl = Portd.5

  'address of ds1307
  Const Ds1307w = &HD0                  ' Addresses of Ds1307 clock
  Const Ds1307r = &HD1
#endif


'configure the date format
Config Date = YMD , SEPARATOR=MINUS     ' ANSI-Format
'This sample does not have the clock started so interrupts are not enabled
' Enable Interrupts

'dim the used variables
Dim lVar1 as Long
Dim mDay as Byte
Dim Bweekday As Byte , Strweekday As String * 10
Dim strDate as String * 8
Dim strtime as String * 8
Dim bSec as Byte , bMin as Byte , bHour as Byte
Dim bDay as Byte , bMonth as Byte , bYear as Byte
Dim lSecOfDay as Long
Dim wSysDay as Word
Dim lSysSec as Long
Dim wDayOfYear as Word




' =================== DayOfWeek =============================================
' Example 1 with internal RTC-Clock

_day = 4 : _month = 11 : _year = 2      ' Load RTC-Clock for example - testing
Bweekday = Dayofweek()
strWeekDay = Lookupstr(bWeekDay , WeekDays)
print "Weekday-Number of " ; Date$ ; " is " ; bWeekday ; " = " ; strWeekday


' Example 2 with defined Clock - Bytes (Day / Month / Year)
Bday = 26 : Bmonth = 11 : Byear = 2
Bweekday = Dayofweek(bday)
strWeekDay = Lookupstr(bWeekDay , WeekDays)
Strdate = Date(bday)
print "Weekday-Number of Day=" ; bDay ; " Month=" ; bMonth ; " Year=" ; bYear ; " is " ; bWeekday ; " (" ; date(bDay) ; ") = " ; strWeekday


' Example 3 with System Day
Wsysday = 2000                          ' that is 2005-06-23
Bweekday = Dayofweek(wsysday)
strWeekDay = Lookupstr(bWeekDay , WeekDays)
print "Weekday-Number of System Day " ; wSysDay ; " (" ; date(wSysDay) ; ") is " ; bWeekday ; " = " ; strWeekday



' Example 4 with System Second
Lsyssec = 123456789                     ' that is 2003-11-29 at 21:33:09
Bweekday = Dayofweek(lsyssec)
strWeekDay = Lookupstr(bWeekDay , WeekDays)
print "Weekday-Number of System Second " ; lSysSec ; " (" ; date(lSysSec) ; ") is " ; bWeekday ; " = " ; strWeekday




' Example 5 with Date-String
Strdate = "04-11-02"                    ' we have configured Date in ANSI
Bweekday = Dayofweek(strdate)
strWeekDay = Lookupstr(bWeekDay , WeekDays)
print "Weekday-Number of " ; strDate ; " is " ; bWeekday ; " = " ; strWeekday




' ================= Second of Day =============================================
' Example 1 with internal RTC-Clock
_Sec = 12 : _Min = 30 : _Hour = 18      ' Load RTC-Clock for example - testing

Lsecofday = Secofday()
print "Second of Day of " ; time$ ; " is " ; lSecOfDay


' Example 2 with defined Clock - Bytes (Second / Minute / Hour)
bSec = 20 : bMin = 1 : bHour = 7
Lsecofday = Secofday(bsec)
print "Second of Day of Sec=" ; bsec ; " Min=" ; bmin ; " Hour=" ; bHour ; " (" ; time(bSec) ; ") is " ; lSecOfDay


' Example 3 with System Second
lSysSec = 1234456789
Lsecofday = Secofday(lsyssec)
print "Second of Day of System Second " ; lSysSec ; "(" ; time(lSysSec) ; ") is " ; lSecOfDay


' Example 4 with Time - String
strTime = "04:58:37"
Lsecofday = Secofday(strtime)
print "Second of Day of " ; strTime ; " is " ; lSecOfDay



' ================== System Second ============================================

' Example 1 with internal RTC-Clock
                          ' Load RTC-Clock for example - testing
_Sec = 17 : _Min = 35 : _Hour = 8 : _Day = 16 : _Month = 4 : _Year = 3

Lsyssec = Syssec()
print "System Second of " ; Time$ ; " at " ; Date$ ; " is " ; lSysSec


' Example 2 with with defined Clock - Bytes (Second, Minute, Hour, Day / Month / Year)
Bsec = 20 : Bmin = 1 : Bhour = 7 : Bday = 22 : Bmonth = 12 : Byear = 1
Lsyssec = Syssec(bsec)
Strtime = Time(bsec)
Strdate = Date(bday)
print "System Second of " ; strTime ; " at " ; strDate ; " is " ; lSysSec


' Example 3 with System Day

wSysDay = 2000
Lsyssec = Syssec(wsysday)
print "System Second of System Day " ; wSysDay ; " (" ; date(wSysDay) ; " 00:00:00) is " ; lSysSec


' Example 4 with Time and Date String
strTime = "10:23:50"
strDate = "02-11-29"                    ' ANSI-Date
lSysSec = SysSec(strTime , strDate)
print "System Second of " ; strTime ; " at " ; strDate ; " is " ; lSysSec       ' 91880630




' ==================== Day Of Year =========================================
' Example 1 with internal RTC-Clock
_day = 20 : _month = 11 : _year = 2     ' Load RTC-Clock for example - testing
Wdayofyear = Dayofyear()
print "Day Of Year of " ; Date$ ; " is " ; wDayOfYear


' Example 2 with defined Clock - Bytes (Day / Month / Year)
Bday = 24 : Bmonth = 5 : Byear = 8
Wdayofyear = Dayofyear(bday)
print "Day Of Year of Day=" ; bDay ; " Month=" ; bMonth ; " Year=" ; bYear ; " (" ; date(bDay) ; ") is " ; wDayOfYear



' Example 3 with Date - String
strDate = "04-10-29"                    ' we have configured ANSI Format
Wdayofyear = Dayofyear(strdate)
print "Day Of Year of " ; strDate ; " is " ; wDayOfYear


' Example 4 with System Second

lSysSec = 123456789
Wdayofyear = Dayofyear(lsyssec)
print "Day Of Year of System Second " ; lSysSec ; " (" ; date(lSysSec) ; ") is " ; wDayOfYear


' Example 5 with System Day
Wsysday = 3000
Wdayofyear = Dayofyear(wsysday)
print "Day Of Year of System Day " ; wSysDay ; " (" ; date(wSysDay) ; ") is " ; wDayOfYear





' =================== System Day ======================================
' Example 1 with internal RTC-Clock
_day = 20 : _Month = 11 : _Year = 2     ' Load RTC-Clock for example - testing
Wsysday = Sysday()
print "System Day of " ; Date$ ; " is " ; wSysDay


' Example 2 with defined Clock - Bytes (Day / Month / Year)
bDay = 24 : bMonth = 5 : bYear = 8
Wsysday = Sysday(bday)
print "System Day of Day=" ; bDay ; " Month=" ; bMonth ; " Year=" ; bYear ; " (" ; date(bDay) ; ") is " ; wSysDay


' Example 3 with Date - String
strDate = "04-10-29"
Wsysday = Sysday(strdate)
print "System Day of " ; strDate ; " is " ; wSysDay

' Example 4 with System Second
lSysSec = 123456789
Wsysday = Sysday(lsyssec)
print "System Day of System Second " ; lSysSec ; " (" ; date(lSysSec) ; ") is " ; wSysDay



' =================== Time ================================================
' Example 1: Converting defined Clock - Bytes (Second / Minute / Hour) to Time - String
Bsec = 20 : Bmin = 1 : Bhour = 7
Strtime = Time(bsec)
print "Time values: Sec=" ; bsec ; " Min=" ; bmin ; " Hour=" ; bHour ; " converted to string " ; strTime


' Example 2: Converting System Second  to Time - String
Lsyssec = 123456789
Strtime = Time(lsyssec)
Print "Time of Systemsecond " ; Lsyssec ; " is " ; Strtime


' Example 3: Converting Second of Day to Time - String
 Lsecofday = 12345
Strtime = Time(lsecofday)
Print "Time of Second of Day " ; Lsecofday ; " is " ; Strtime


' Example 4: Converting System Second to defined Clock - Bytes (Second / Minute / Hour)

Lsyssec = 123456789
Bsec = Time(lsyssec)
Print "System Second " ; lSysSec ; " converted to Sec=" ; bsec ; " Min=" ; bmin ; " Hour=" ; bHour ; " (" ; time(lSysSec) ; ")"



' Example 5: Converting Second of Day to defined Clock - Bytes (Second / Minute / Hour)
lSecOfDay = 12345
Bsec = Time(lsecofday)
Print "Second of Day " ; lSecOfDay ; " converted to Sec=" ; bsec ; " Min=" ; bmin ; " Hour=" ; bHour ; " (" ; time(lSecOfDay) ; ")"

' Example 6: Converting Time-string to defined Clock - Bytes (Second / Minute / Hour)
strTime = "07:33:12"
Bsec = Time(strtime)
Print "Time " ; strTime ; " converted to Sec=" ; bsec ; " Min=" ; bmin ; " Hour=" ; bHour



' ============================= Date ==========================================

' Example 1: Converting defined Clock - Bytes (Day / Month / Year) to Date - String
bDay = 29 : bMonth = 4 : bYear = 12
Strdate = Date(bday)
print "Dat values: Day=" ; bDay ; " Month=" ; bMonth ; " Year=" ; bYear ; " converted to string " ; strDate


' Example 2: Converting from System Day to Date - String
wSysDay = 1234
Strdate = Date(wsysday)
Print "System Day " ; wSysDay ; " is " ; strDate


' Example 3: Converting from System Second to Date String
lSysSec = 123456789
Strdate = Date(lsyssec)
Print "System Second " ; lSysSec ; " is " ; strDate


' Example 4: Converting SystemDay to defined Clock - Bytes (Day / Month / Year)

wSysDay = 2000
Bday = Date(wsysday)
print "System Day " ; wSysDay ; " converted to Day=" ; bDay ; " Month=" ; bMonth ; " Year=" ; bYear ; " (" ; date(wSysDay) ; ")"


' Example 5: Converting Date - String to defined Clock - Bytes (Day / Month / Year)
strDate = "04-08-31"
Bday = Date(strdate)
print "Date " ; strDate ; " converted to Day=" ; bDay ; " Month=" ; bMonth ; " Year=" ; bYear


' Example 6: Converting System Second to defined Clock - Bytes (Day / Month / Year)
lSysSec = 123456789
Bday = Date(lsyssec)
print "System Second " ; lSysSec ; " converted to Day=" ; bDay ; " Month=" ; bMonth ; " Year=" ; bYear ; " (" ; date(lSysSec) ; ")"



' ================ Second of Day elapsed

Lsecofday = Secofday()
_Hour = _Hour + 1
lVar1 = SecElapsed(lSecOfDay)
print lVar1

Lsyssec = Syssec()
_Day = _day + 1
Lvar1 = Syssecelapsed(lsyssec)
print lVar1






looptest:

' Initialising for testing
_day = 1
_month = 1
_year = 1
_sec = 12
_min = 13
_hour = 14



do
   if _year > 50 then
      exit do
   end if

  _sec = _sec + 7
  if _sec > 59 then
     incr _min
     _sec = _sec - 60
  end if

  _min = _min + 2
  if _min > 59 then
     incr _hour
     _min = _min - 60
  end if

  _hour = _hour + 1
  if _hour > 23 then
     incr _day
     _hour = _hour - 24
  end if

  _day = _day + 1


  if _day > 28 then
     select case _month
        case 1
           mday = 31
        case 2
           mday = _year and &H03
           if mday = 0 then
              mday = 29
           else
              mday = 28
           end if
        case 3
           mday = 31
        case 4
           mday = 30
        case 5
           mday = 31
        case 6
           mday = 30
        case 7
           mday = 31
        case 8
           mday = 31
        case 9
           mday = 30
        case 10
           mday = 31
        case 11
           mday = 30
        case 12
           mday = 31
     end select
     if _day > mday then
        _day = _day - mday
        incr _month
        if _month > 12 then
           _month = 1
           incr _year
        end if
     end if
  end if
  if _year > 99 then
     exit do
  end if

Lsecofday = Secofday()
Lsyssec = Syssec()
Bweekday = Dayofweek()
Wdayofyear = Dayofyear()
Wsysday = Sysday()


print time$ ; " " ; date$ ; " " ; lSecOfDay ; " " ; lSysSec ; " " ; bWeekDay ; " " ; wDayOfYear ; " " ; wSysDay


loop
End


'only when we use I2C for the clock we need to set the clock date time
#if Clockmode = 0
'called from datetime.lib
Dim Weekday As Byte
Getdatetime:
  I2cstart                              ' Generate start code
  I2cwbyte Ds1307w                      ' send address
  I2cwbyte 0                            ' start address in 1307

  I2cstart                              ' Generate start code
  I2cwbyte Ds1307r                      ' send address
  I2crbyte _sec , Ack
  I2crbyte _min , Ack                   ' MINUTES
  I2crbyte _hour , Ack                  ' Hours
  I2crbyte Weekday , Ack                ' Day of Week
  I2crbyte _day , Ack                   ' Day of Month
  I2crbyte _month , Ack                 ' Month of Year
  I2crbyte _year , Nack                 ' Year
  I2cstop
  _sec = Makedec(_sec) : _min = Makedec(_min) : _hour = Makedec(_hour)
  _day = Makedec(_day) : _month = Makedec(_month) : _year = Makedec(_year)
Return

Setdate:
  _day = Makebcd(_day) : _month = Makebcd(_month) : _year = Makebcd(_year)
  I2cstart                              ' Generate start code
  I2cwbyte Ds1307w                      ' send address
  I2cwbyte 4                            ' starting address in 1307
  I2cwbyte _day                         ' Send Data to SECONDS
  I2cwbyte _month                       ' MINUTES
  I2cwbyte _year                        ' Hours
  I2cstop
Return

Settime:
  _sec = Makebcd(_sec) : _min = Makebcd(_min) : _hour = Makebcd(_hour)
  I2cstart                              ' Generate start code
  I2cwbyte Ds1307w                      ' send address
  I2cwbyte 0                            ' starting address in 1307
  I2cwbyte _sec                         ' Send Data to SECONDS
  I2cwbyte _min                         ' MINUTES
  I2cwbyte _hour                        ' Hours
  I2cstop
Return

#endif


WeekDays:
Data "Monday" , "Tuesday" , "Wednesday" , "Thursday" , "Friday" , "Saturday" , "Sunday"