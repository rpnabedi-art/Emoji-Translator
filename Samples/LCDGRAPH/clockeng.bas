'------------------------------------------------------------
'                      CLOCK english.BAS
'this program is derived from megaclock.bas from (c) 2000-2003 MCS Electronics
'modified by JP Duval 03/04/03  Mon anniversaire !
'some names are in english some others are in french...
'this program is a free one, you can copy for private use but not for trade.
' no responsability can be evoqued against the author.
'------------------------------------------------------------
'First you must connect a 32.768 Hz xtal between PC6 and PC7 (TOSC1 and TOSC2)
' you must have also a good setting of fuses CKSEL (8MHz internal)
' CKSEL   3,2,1,0= 0100 (0 means fuse is programmed)
' HW stack=80, Soft Stack =64, Frame=64 but I think we can reduce all of them
' Config Clock uses and creates the internal variables:
' _day , _month, _year , _sec, _hour, _min (bytes) You can use as  : _day = 1
' or in reverse : myday =_day
' we use a T6963C graphic display 240 * 128 from Densitron  -17V included
' portD=data D0=DB0.....D7=DB7  port B= control see the config line
'
'-------------------------------------------------------------
$regfile = "M32def.dat"       'specific file for the µP
$hwstack = 40
$swstack = 40
$framesize = 40


Mcusr = &H80       'desable the JTAG for mega323 et 32
Mcusr = &H80       '   //        //        //
'$baud = 9600  'Attention don't use in HW if port D is used for data
Wait 1
Enable Interrupts       ' config clock uses a Timer interrup
$lib "eurotimedate.lbx"       ' thanks  !
'  constants---------------------------------------------------------------
Const Pirad = 3.1415926 / 180       'use for angle calculation
Const Bigradius = 58       'the biggest circle
Const Radius = 54       'the circle under the biggest use for Railway
Const Smallradius = 10       ' The circle uses for hand
Const Houradius = 40       ' The invisible circle of hours
Const Minuteradius = 50       ' the invisible circle of minutes
Const Littleradius = 3       'the tiny circle around the second hand
Const Placeradius = 44       'place of center of tiny circle on the second hand
Const Seconderadius = 52       ' the invisible circle of seconds
Const Angle = 90       ' 90° à mid time
Const Black = 255       ' to see the draw
Const Centrex = 120       'center X
Const Centrey = 66       'center Y
'  variables -------------------------------------------------------------
' Some variables are used for different jobs
' for ex : Xseconde, Yseconde, X, Y, Ax, Ay,J
Dim Xseconde As Single , Yseconde As Single
Dim Startx As Single , Starty As Single , Endy As Single , Endx As Single
Dim Seconde As Integer , Minute As Integer , Heure As Integer
Dim Jour(7) As String * 9 , Mois(12) As String * 10 , Flagj As Bit , Color As Byte
Dim Lejour As String * 9 , Lemois As String * 10 , Indexjour As Byte , Indexmois As Byte
Dim Cosangle As Single , Sinangle As Single , Angle_rad As Single
Dim Angleplus As Single , Angleheure As Single , W As Single
Dim X As Byte , Y As Byte , Ax As Byte , Ay As Byte , J As Byte , K As Integer
' sub and functions-------------------------------------------------------
Declare Sub Anglerad(w As Single)
Declare Sub Jobseconde(color As Byte , Seconde As Integer)
Declare Sub Jobminute(color As Byte , Minute As Integer)
Declare Sub Jobheure(seconde As Integer , Angleplus As Single)
'  config ----------------------------------------------------------------
' Port A is reserved for a futur analogic use
' GraphicLCD data : D control : B
' PortC6 and PortC7 are use for the xtal 32KHz
' PortC0 and PortC1 are uses for the buttons
' PC0 is the ajustement button, PC1 is the ENTER they are used like this:
'                     __
'---VCC----R10K|----o  o-------ground
'              |_______________________portC0 or PortC1
Config Pinc.0 = Input
Config Pinc.1 = Input
Config Graphlcd = 240 * 128 , Dataport = Portd , Controlport = Portb , Ce = 1 , Cd = 4 , Wr = 0 , Rd = 2 , Reset = 3 , Fs = 7 , Mode = 6
Config Date = Dmy , Separator = /       ' ANSI-Format
Config Clock = Soft       ' , Gosub = Sectic (non use here)
'---------------the main--------------------------------------------------
'initialising
Indexjour = 1       'index of the day
Indexmois = 1       'index of the month
Seconde = _sec
Cls
Gosub Tableau       ' tableau of the day and month (we can use data too)
Cursor On , Blink
Gosub Reglage       ' adjustement of parameters
Cls
Gosub Railway       ' railway with sleepers !
Cursor Off , Noblink
Do
 Heure = _hour
 Gosub Ecritla_date       ' write the date
  Do
   If Pinc.0 = 0 Or Pinc.1 = 0 Then
      Cursor On , Blink
      Gosub Reglage
      Cls
      Gosub Railway
      Gosub Ecritla_date
      Cursor Off , Noblink
   End If
   If Seconde <> _sec Then
     Seconde = _sec
     If Seconde = 0 Then
     Cls
     Gosub Railway
     Gosub Ecritla_date
     End If
     Minute = _min
     If Heure <> _hour Then Exit Do
     Color = 0       'deletting
     Call Jobseconde(color , Seconde)
     Call Jobminute(color , Minute)
     Call Jobheure(seconde , Angleplus)
     Color = 255       'writing
     Call Jobseconde(color , Seconde)
     Call Jobminute(color , Minute)
     Call Jobheure(seconde , Angleplus)
   End If
  Loop
  Flagj = 1       ' to check and to rewrite date
  Angleplus = 0
Loop
Stop
'---------------------------------------------------------------------
' sub and functions-----------------------------------------
Sub Anglerad(w As Single)       ' calculation of  sin and cos not for hours of railway
W = W * 6       '
Angle_rad = Angle - W
Angle_rad = Angle_rad * Pirad
Sinangle = Sin(angle_rad) : Cosangle = Cos(angle_rad)
End Sub
'-----the seconds---------------------------------------------------
Sub Jobseconde(color , Seconde)
If Color = 0 Then       'deletting of previous
W = Seconde - 1
Else
W = Seconde
End If
Call Anglerad(w)
W = Seconderadius * Cosangle       '  X of hand
Xseconde = Centrex + W
W = Seconderadius * Sinangle       ' Y of the hand
Yseconde = Centrey - W
Xseconde = Round(xseconde) : Yseconde = Round(yseconde)
X = Int(xseconde) : Y = Int(yseconde)
Line(centrex , Centrey) -(x , Y) , Color       'the hand
'where is the tiny circle
W = Placeradius * Cosangle
Startx = Centrex + W       '   petit cercle
W = Placeradius * Sinangle
Starty = Centrey - W       '  petit cercle
Startx = Round(startx) : Starty = Round(starty)
 X = Int(startx) : Y = Int(starty)
Circle(x , Y) , Littleradius , Color       'the tiny circle
Circle(centrex , Centrey) , Smallradius , Black       'the circle of 10
End Sub
'--------------- minutes-------------------------------------
Sub Jobminute(color , Minute)
If Color = 255 Then
   W = Minute
Elseif Color = 0 And _sec = 0 Then
   W = Minute - 1       'deletting of previous
   Goto Suite
End If
     Suite:
     Call Anglerad(w)
     W = Minuteradius * Cosangle       '  X of hand
     Xseconde = Centrex + W
     W = Minuteradius * Sinangle       '  Y of hand
     Yseconde = Centrey - W
     Xseconde = Round(xseconde) : Yseconde = Round(yseconde)
     X = Int(xseconde) : Y = Int(yseconde)
     Line(centrex , Centrey) -(x , Y) , Color       'main hand
     W = Smallradius * Sinangle
     Endx = Centrex + W
     W = Smallradius * Cosangle
     Endy = Centrey + W
     Endx = Round(endx) : Endy = Round(endy)
     Ax = Int(endx) : Ay = Int(endy)
     Line(centrex , Centrey) -(ax , Ay) , Color       'base of triangle
     Line(x , Y) -(ax , Ay) , Color       'hypotenuse
End Sub
'---------------- hours---------------------------------------------
Sub Jobheure(seconde , Angleplus )
   Angleheure = Heure * 30
   If Seconde = 0 And Color = 0 Then       'delete of previous
         Color = 0
   Else
       Color = 255
   End If
   If Seconde = 0 And Color = 255 Then
    Angleplus = Angleplus + 0.5
   End If
   Angleheure = Angleheure + Angleplus
   Angle_rad = Angle - Angleheure
   Angle_rad = Angle_rad * Pirad
   Sinangle = Sin(angle_rad) : Cosangle = Cos(angle_rad)
   W = Houradius * Cosangle       '  X of hand
   Xseconde = Centrex + W
   W = Houradius * Sinangle       '  Y of hand
   Yseconde = Centrey - W
   Xseconde = Round(xseconde) : Yseconde = Round(yseconde)
   X = Int(xseconde) : Y = Int(yseconde)
   Line(centrex , Centrey) -(x , Y) , Color       'main side of hand

   W = Smallradius * Sinangle
   Xseconde = Centrex - W
   W = Smallradius * Cosangle
   Yseconde = Centrey - W
   Xseconde = Round(xseconde) : Yseconde = Round(yseconde)
   Ax = Int(xseconde) : Ay = Int(yseconde)
   Line(centrex , Centrey) -(ax , Ay) , Color       ' base of triangle
   Line(x , Y) -(ax , Ay) , Color       'hypotenuse
End Sub

'----the gosub ---------------------------------------
Ecritla_date:
Locate 1 , 1 : Lcd Spc(39)
If _hour = 0 And Flagj = 1 Then       'flagj to do only one time
   Indexjour = Indexjour + 1
   If Indexjour = 8 Then
       Indexjour = 1
   End If
   Lejour = Jour(indexjour)
   If _day = 1 And Indexmois = 1 Then
       Lemois = Mois(2)
       Indexmois = 2
   Elseif _day = 29 And Indexmois = 2 Then
          _day = 1
          Lemois = Mois(3)
          Indexmois = 3
   Elseif _day = 1 And Indexmois = 3 Then
       Lemois = Mois(4)
       Indexmois = 4
   Elseif _day = 1 And Indexmois = 5 Then
       Lemois = Mois(6)
       Indexmois = 6
   Elseif _day = 1 And Indexmois = 7 Then
       Lemois = Mois(8)
       Indexmois = 8
   Elseif _day = 1 And Indexmois = 8 Then
       Lemois = Mois(9)
       Indexmois = 9
   Elseif _day = 1 And Indexmois = 10 Then
       Lemois = Mois(11)
       Indexmois = 11
   Elseif _day = 1 And Indexmois = 12 Then
       Lemois = Mois(1)
       Indexmois = 1
   Elseif _day = 31 And Indexmois = 4 Then
       _day = 1
       Lemois = Mois(5)
       Indexmois = 5
   Elseif _day = 31 And Indexmois = 6 Then
          _day = 1
       Lemois = Mois(7)
       Indexmois = 7
   Elseif _day = 31 And Indexmois = 9 Then
       _day = 1
       Lemois = Mois(10)
       Indexmois = 10
   Elseif _day = 31 And Indexmois = 11 Then
          _day = 1
       Lemois = Mois(12)
       Indexmois = 12
   End If
End If
Flagj = 0
Lejour = Jour(indexjour)
Lemois = Mois(indexmois)
Lejour = Rtrim(lejour)
Lejour = Lejour + " "
Lemois = " " + Lemois
Lemois = Rtrim(lemois)
X = Len(lejour)
Y = Len(lemois)
X = X + Y : X = X + 2 : X = X / 2       'to put the date in the center
X = 20 - X       '
 Locate 1 , X : Lcd Lejour : Lcd _day : Lcd Lemois
Flagj = 0
Return
'---------------------------------------------------------------
Reglage:
Encore:
' Day------------------------
Locate 1 , 29 : Lcd "         "
Locate 1 , 29 : Lcd " SETTING "
Locate 2 , 29 : Lcd "   Day "
Waitms 400
Do
   Locate 3 , 30 : Lcd Jour(indexjour)
If Pinc.0 = 0 Then
   Indexjour = Indexjour + 1
   Waitms 200
End If
If Indexjour = 8 Then
   Indexjour = 1
   Locate 3 , 30 : Lcd Jour(indexjour)

End If
Loop Until Pinc.1 = 0
Lejour = Jour(indexjour)
 Waitms 300
'- Month------------------------
Locate 4 , 30 : Lcd "  Month "
Do
Locate 5 , 30 : Lcd Mois(indexmois)
If Pinc.0 = 0 Then
   Indexmois = Indexmois + 1
      Waitms 200
End If
If Indexmois = 13 Then
   Indexmois = 1
   Locate 5 , 30 : Lcd Mois(indexmois)
End If
Loop Until Pinc.1 = 0
Lemois = Mois(indexmois)
   Waitms 300
'-Day of month--------------------
J = 1
Locate 6 , 39 : Lcd "Day of Mth"
Do
   Locate 7 , 33 : Lcd J
   If Pinc.0 = 0 Then
      J = J + 1
      Waitms 200
   End If
   If J = 32 Then
      Locate 7 , 33 : Lcd "1   "
   J = 1
End If
Loop Until Pinc.1 = 0
_day = J
   Waitms 300
'- Hours---------------------------
J = 0
Locate 8 , 30 : Lcd " Hours"
Do
  Locate 9 , 33 : Lcd J
  If Pinc.0 = 0 Then
      J = J + 1
      Waitms 200
  End If
  If J = 24 Then
  Locate 9 , 33 : Lcd "0   "
   J = 0
End If
Loop Until Pinc.1 = 0
_hour = J
   Waitms 300
'- Minutes-------------------------
J = 0
Locate 10 , 30 : Lcd "Minutes"
Do
   Locate 11 , 33 : Lcd J
   If Pinc.0 = 0 Then
    J = J + 1
    Waitms 200
   End If
If J = 60 Then
   Locate 11 , 33 : Lcd "    "
   J = 0
End If
Loop Until Pinc.1 = 0
_min = J : Angleplus = J : Angleplus = Angleplus * 0.5
   Waitms 500
' Ok-----------------------------
Do

   Locate 12 , 30 : Lcd "OK=Right"
   Locate 13 , 30 : Lcd "Again=L"
   If Pinc.0 = 0 Then
   Cls
   Goto Encore
   Waitms 200
   End If
   Waitms 200
Loop Until Pinc.1 = 0
Cursor Off , Noblink
Cls
Return
'-----------------------------------------------

Tableau:
Jour(1) = "MONDAY   "
Jour(2) = "TUESDAY  "
Jour(3) = "WEDNESDAY"
Jour(4) = "THURSDAY "
Jour(5) = "FRIDAY   "
Jour(6) = "SATURDAY "
Jour(7) = "SUNDAY   "
'-----------------------
Mois(1) = "JANUARY  "
Mois(2) = "FEBRUARY "
Mois(3) = "MARCH    "
Mois(4) = "APRIL    "
Mois(5) = "MAY      "
Mois(6) = "JUNE     "
Mois(7) = "JULY     "
Mois(8) = "AUGUST   "
Mois(9) = "SEPTEMBER"
Mois(10) = "OCTOBER  "
Mois(11) = "NOVEMBER "
Mois(12) = "DECEMBER "
Return
'-------------------------------------------
Railway:       'Draw 2 circles and sleepers
Cursor Off , No Blink
Circle(centrex , Centrey) , Bigradius , Black
Circle(centrex , Centrey) , Radius , Black
Waitms 200
Circle(centrex , Centrey) , Bigradius , Black
Circle(centrex , Centrey) , Radius , Black
For K = 0 To 360 Step 30
    Angle_rad = Angle - K : Angle_rad = Angle_rad * Pirad
    Sinangle = Sin(angle_rad) : Cosangle = Cos(angle_rad)
    W = Radius * Cosangle
    Startx = Centrex + W
    W = Radius * Sinangle
    Starty = Centrey - W
    W = Bigradius * Cosangle
    Endx = Centrex + W
    W = Bigradius * Sinangle
    Endy = Centrey - W
    Startx = Round(startx) : Starty = Round(starty)
    X = Int(startx) : Y = Int(starty)
    Endx = Round(endx) : Endy = Round(endy)
    Ax = Int(endx) : Ay = Int(endy)
    Line(x , Y) -(ax , Ay) , Black       'sleppers
Next
 K = 0
Return
