'----------------------------------------------------------------------------
'                  (c) 1995-2008
'                 MCS Electronics
' This program will calculate the distance between GPS coordinates
' It also calculates course
'----------------------------------------------------------------------------
$regfile = "m128def.dat"
$framesize = 320
$hwstack = 160
$swstack = 160
$crystal = 16000000
'-------------------------------------------------------------------------------
Const Pi = 3.14159265358979
Const Mpi = Pi / 180
Const Radiusearth = 6371000

Dim Calc_distance As Double
Dim Calc_course_d As Double
Dim Calc_course_m As Double
Dim Calc_course_s As Double

Declare Sub Get_distance_course(byval Lat1 As Double , Byval Lon1 As Double , Byval Lat2 As Double , Byval Lon2 As Double)
'-------------------------------------------------------------------------------

Call Get_distance_course( -9.9666 , 18.0374 , 52.8273 , -8.4409)

If Calc_distance > 1000 Then Calc_distance = Calc_distance / 1000

Print "Distance: " ; Calc_distance
Print "Course: " ; Calc_course_d ; "D " ; Calc_course_m ; "M " ; Calc_course_s ; "S"

End
'-------------------------------------------------------------------------------
Sub Get_distance_course(byval Lat1 As Double , Byval Lon1 As Double , Byval Lat2 As Double , Byval Lon2 As Double)

  Local Tmp As Double , A As Double , B As Double , C As Double , T2 As Double

        ' 1 Degree is 69.096 miles, 1 mile is 1609.34 m
        A = Lat1 * Mpi                                      'Mpi
        A = Cos(a)
        T2 = Lat2 * Mpi : T2 = Cos(t2) : A = A * T2
        T2 = Lon1 * Mpi : T2 = Cos(t2) : A = A * T2
        T2 = Lon2 * Mpi : T2 = Cos(t2) : A = A * T2

        B = Lat1 * Mpi : B = Cos(b)
        T2 = Lon1 * Mpi : T2 = Sin(t2) : B = B * T2
        T2 = Lat2 * Mpi : T2 = Cos(t2) : B = B * T2
        T2 = Lon2 * Mpi : T2 = Sin(t2) : B = B * T2

        C = Lat1 * Mpi : C = Sin(c)
        T2 = Lat2 * Mpi : T2 = Sin(t2) : C = C * T2

        T2 = A + B
        T2 = T2 + C
        A = Abs(t2)

        If A >= 1 Then
           Calc_distance = 0
        Else
           T2 = Acos(t2) : Tmp = T2 : T2 = T2 * Radiusearth
           Calc_distance = T2
        End If


       'Calculate bearing course
        A = Lat2 * Mpi : A = Sin(a)

        B = Lat1 * Mpi : B = Sin(b)
        T2 = Cos(tmp) : B = B * T2

        C = Lat1 * Mpi : C = Cos(c)
        T2 = Sin(tmp) : C = C * T2

        A = A - B
        A = A / C
        A = Acos(a)
        A = Rad2deg(a)

        B = Lon2 * Mpi
        C = Lon1 * Mpi
        Tmp = B - C

        If Tmp < 0.0 Then A = 360 - A

        Calc_course_d = Int(a)
        Tmp = Frac(a)
        Tmp = Tmp * 60
        Calc_course_m = Int(tmp)
        Tmp = Frac(tmp)
        Tmp = Tmp * 60
        Calc_course_s = Round(tmp)
End Sub
