$RegFile = "m8535.dat"
' NOTICE FROM MCS : SP changed to SPX since SP is a reserved word register
' -----[ Program Description ]--------------------------------------------------
'
' This program implements an PID algorithm in BASCOM
'
' This File is partialy based on a program from ?????? and
' I do not intent to touch any of his rights !!!
' So for correct use of his copyrights please inform as marked below!
' ?????????
'
'
' -----[ Disclaimer ]-----------------------------------------------------------
'
' This example is offered on an "AS IS" basis, no warranty expressed or implied.
' The programers disclaim liability of any damages associated with the use of
' the hardware or software described herein. You use it on your own risk.
' I'm not able to provide any free support.
'
' Copyright (c) 2001 Mike Eitel all rights reserved
'
' -----[ Revision History ]-----------------------------------------------------
'
' 060529 - Version AVRPID Ver .95    Basic PID functionality   Mike Eitel
'
' -----[ Aliases ]--------------------------------------------------------------
$Sim                                                        ' Helps testing in a simulation
' -----[ Constant ]-------------------------------------------------------------

' -----[ Variables ]------------------------------------------------------------
Dim Auto_mode As Bit                                     ' Regulator on ?
Dim Manual_value As Single                               ' Output if not regulating

Dim Spx As Single                                        ' Setpoint
Dim Pv As Single                                         ' Process Value
Dim Cv As Single                                         ' PID output

Dim First_execution As Byte                              ' First start recognition
Dim Initial_error As Single                              ' Startup difference

Dim A As Byte                                            ' Tmp for random
Dim B As Single                                          ' Tmp for random


' -----[ Start of program ]-----------------------------------------------------
' -----[ Start of program ]-----------------------------------------------------
' -----[ Start of program ]-----------------------------------------------------

Auto_mode = 1                                            ' Permanent running choosen
First_execution = 0                                      ' Set permanent running algorithm
Manual_value = 40                                        ' Output if not regulating = on
Spx = 37                                                 ' Value to aim to

Cyclic:
   ' -----[ Start of endless running program ]-------------------------------------
   WaitmS 50                                                ' PID must run deterministic
   ' time slices
   Gosub Regulator                                          ' Call the PID allgorithm
   Gosub Object                                             ' Call the simulated outer loop
   Goto Cyclic

   ' -----[ End of endless running program ]------------------------------------
   ' -----[ End of endless running program ]------------------------------------
   ' -----[ End of endless running program ]------------------------------------


   ' ---------------------------------------------------------------------------
   ' -----------------------------[ Subroutines ]-------------------------------
   ' ---------------------------------------------------------------------------
Object:
   ' -----[ Start of simulated regulation loop ]--------------------------------
   Pv = Pv + Cv                                            ' linear function used

   If Pv = Spx Then                                        ' When PV=SP then make a
      A = Rnd(100)                                         ' random SP jump
      Spx = 1 * A
   End If
Return

Regulator:
   ' -----[ Start of PID Regulator]---------------------------------------------
   ' -----[ Constant ]----------------------------------------------------------
   Const Kp = 0.85                                           ' Proportional factor
   Const Ki = 0.67                                           ' Integration factor
   Const Kd = 0.15                                           ' Derivation factor
   ' -----[ Variables ]---------------------------------------------------------
   'Dim Sp As Single                               ' Setpoint
   'Dim Pv As Single                               ' Process Value
   'Dim Cv As Single                               ' PID output
   '
   'Dim First_execution As Byte                    ' First start recognition
   'Dim Initial_error As Single                    ' Startup difference
   Dim Last_pv As Single                                    ' Last PV
   Dim Last_sp As Single                                    ' Last SP
   Dim Sum_error As Single                                  ' Summed error value
   Dim D_pv As Single                                       ' Derrivated delta PV

   Dim sError As Single                                     ' Difference between SP and PV
   Dim Pterm As Single                                      ' Proportional calculated part
   Dim Iterm As Single                                      ' Integrated calculated part
   Dim Dterm As Single                                      ' Derivated calculated part
   ' -----[ Code ]--------------------------------------------------------------

   If Auto_mode = 1 Then
      ' -------- Regulating modus
      sError = Spx - Pv
      Sum_error = Sum_error + sError
      Iterm = Ki * Sum_error                                ' Integrated CV part

      ' -------- First time startup
      If First_execution < 2 Then
         If First_execution = 0 Then
            Sum_error = Manual_value / Ki
            First_execution = 1
            Initial_error = sError
         End If
         Pterm = 0
         Dterm = 0
         If Initial_error > 0 And sError < 0 Then
            First_execution = 2
            Last_pv = Pv
         End If
         If Initial_error < 0 And sError > 0 Then
            First_execution = 2
            Last_pv = Pv
         End If
         Last_sp = Spx

         ' -------- Normal calculation loop
      Else
         D_pv = Last_pv - Pv
         Last_pv = Pv
         Dterm = Kd * D_pv                                  ' Derivated CV part
         If Spx = Last_sp Then
            ' -------- Normal loop when setpoint not changed
            Pterm = Kp * sError                              ' Proportional CV part
            ' -------- Loop when setpoint changed
         Else
            Pterm = 0
            Dterm = 0
            If Spx > Last_sp And Pv > Spx Then
               Last_sp = Spx
               Last_pv = Pv
            End If
            If Spx < Last_sp And Pv < Spx Then
               Last_sp = Spx
               Last_pv = Pv
            End If
         End If                                             ' Enf of SP change seperation                                   '
      End If                                                ' Enf of first time running seperation                                  '

      Cv = Pterm + Iterm                                    ' Summing of the tree
      Cv = Cv + Dterm                                       ' calculated terms

      ' -------- Forced modus
   Else                                                     ' When running in non regulationg modus
      Cv = Manual_value                                     ' Set output to predefined value
      First_execution = 0                                   ' restart bumpless
   End If
Return