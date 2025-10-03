'--------------------------------------------------------------------------------
'name                     : bch_fnc_zeh.bas
'copyright                : (c) 1995-2013, MCS Electronics
'purpose                  : Data Transmission and Error detection with Correction
'micro                    : 90S8515
'suited for demo          : no
'commercial addon needed  : no
'use in simulator         : not possible
'--------------------------------------------------------------------------------
' Application Note                                                                                                     *
'===============================================================================
' Encodes 21 -bit Data Word Into 32 -bit Extended Bch 32.21 Word               *
'                                                                              *
' This code is used in the POCSAG protocol specification for pagers.           *
'                                                                              *
' In this specific case, there is no need to use the Berlekamp-Massey          *
' algorithm, since the error locator polynomial is of at most degree 2.        *
' Instead, we simply solve by hand two simultaneous equations to give          *
' the coefficients of the error locator polynomial in the case of two          *
' errors. In the case of one error, the location is given by the first         *
' syndrome.                                                                    *
'                                                                              *
' This program derivates from the original bch2.c, which was written           *
' to simulate the encoding/decoding of primitive binary BCH codes.             *
' Part of this program is adapted from a Reed-Solomon encoder/decoder          *
' program,  'rs.c', to the binary case.                                        *
'                                                                              *
'-------------------------------------------------------------------------------
' Extended Code Bch 32.21 Correction Using Zeh Functions                       *
' The Idea And The Original Algorithm Were Proposed By K. Borisov              *
' C Source Code(c)vlv                                                          *
'*******************************************************************************
' Ported to BASCOM AVR by M/S PACTINDIA on 27.04.2002                          *
' Written by Srikanth Kamath; e-mail: panther@vasnet.co.in                     *
'                                                                              *
' (c) Copyright 2002 Panther Electronics ; www.pactindia.com/bascom.htm        *
'                                                                              *
' COPYRIGHT NOTICE: This program is free for non-commercial purposes.          *
' You may implement this program for any non-commercial application. You may   *
' also implement this program for commercial purposes, provided that you       *
' obtain my written permission. Any modification of this program is covered    *
' by this copyright.                                                           *
'                                                                              *
'===============================================================================
'*******************************************************************************
' The Bch 32.21 Codeword Is Treated As Long Int Data Size is 21 bits           *
' The Function Corrects Up To 2 Errors And Detects At Least 3 Errors.          *
' The Error Value Is Amount Of Errors(0 , 1 , 2).                              *
' If The Error Is Not Correctable , Error Value Is 0xff And The Codeword       *
' Is Not Changed.                                                              *
'*******************************************************************************
' The Encoding part is of size  700byte this should gointo the transmitting uC *
' The Decoding part is of size 1900byte this should gointo the Reciever uC     *
' The Test part is the routine that you must change to in the TX uC to encode  *
' and similarly the Test part must change in the TR uC to decode               *
'===============================================================================
' BUGS:                                                                        *
' Fixed on 5.5.2002,                                                           *
' The error are now correctly reported 0,1,2 or 255                            *                                                                       *
' 27.4.2002 The corrected_data is either +1 or -1 at times from actual         *
' encodded_data But this does not effect the decode or error correction        *
' Also the error no reported is not related to no of error but detected        *
'-------------------------------------------------------------------------------
' Warranty & Disclaimer:                                                       *
'                                                                              *
' We do not guarantee that this module is free from defects or bug's in normal *
' use/service, and that these module will perform to the current specification *
' in accordance with, and subject to, the company’s standard warranty which    *
' is detailed in Panther Electronics Purchase order Acknowledgement.           *
'                                                                              *
' We assumes no responsibility for the use of any circuits / code described in *
' this book / e-book/ manual, nor does the company assumes responsibility for  *
' the functioning of undescribed features or parameters.                       *
'                                                                              *
' In absence of a written agreement to the contrary, Panther Electronics       *
' assumes no liability with respect to the use of semiconductors devices/codes *
' described and used in this module for product design or infringements of     *
' patents or copyrights of third parties.                                      *
'                                                                              *
' These are control modules /codes only and not tested with for full           *
' functionality with the controlled units and products. These modules are not  *
' authorised for use as critical components or systems and the use as such     *
' implies that the user bears all risk of such use.                            *
'*******************************************************************************
' Many Many Thanks to                                                          *
' Mark Albert's, Eric Baron, Udo, Jack Tidwel and all other who have helped    *
'==============================================================================*

' Change this to Suit you AVR
$RegFile = "8515def.dat"
'$dbg
' Note this code requires HW10, SS32 and FRAME 43
$HWstack = 10                                               ' default use 32 for the hardware stack
$SWstack = 32                                               'default use 10 for the SW stack
$FrameSize = 43                                             'default use 40 for the frame space

Declare Function Encodebch(datas As Long) As Long
Declare Function Correctbch(encodedbchword As Long) As Long


'***************The test program ***********************************************
' This test is to Show how tHe BCH encoding of 21bit data packet helps in
' error detection and correction of error in asyncrony data transmission
' this BCH encoding and Decoding provides error correction upto 2 error per
' packet of 21bit. Hence the chances of usefull and purpose full transmission
' is garrented


Dim Inputdata As Long
' This is the data to be transmitted
Dim Temp As Byte , Cnt As Byte                              ' temp variables used
Dim Just_tmp As Long                                        ' temp variables used
Dim Corrupted_data As Long
' This is the received data
Dim Decoded_data As Long
' this is the decoded data = inputdata
Dim Encoded_data As Long
' this is the corrected data
Dim Result As Byte
' This is the error no
' NOTE: If Result = &HFF the error could not be corrected hence discard the
' Received data


Do

Main:
  Inputdata = 0
  ' get some random data in
  For Cnt = 1 To 2
    Shift Inputdata , Left , 8
    Temp = Rnd(255)
    Inputdata = Inputdata Xor Temp
  Next

  '**  / / Truncate To 21 Bit
  Inputdata = Inputdata And &H1FFFFFF
  '**  / / Encode To Bch 32.21
  Encoded_data = Encodebch(Inputdata)

  '/ / Corrupt Data(2 Random Errors)
  Corrupted_data = Encoded_data
  'Corrupted_data is the received transmission data
  Temp = Rnd(255)
  Temp = Temp And &H1F
  Set Corrupted_data.Temp
  Just_tmp = Corrupted_data
  Temp = Rnd(255)
  Temp = Temp And &H1F
  Set Corrupted_data.Temp
  Print " Encoded Data with first error " ; Just_tmp ; " with second Second error " ; Corrupted_data

  '// Correct Data
  'Call Correctbch(corrupted_data)
  Just_tmp = Correctbch(Corrupted_data)

  '// Decode Data
  Print "Corrupted_data " ; Corrupted_data ; " EncodedWord " ; Encoded_data ; " Corrected_data " ; Just_tmp
  Decoded_data = Just_tmp
  ' This is the the required to get back the corrected data
  Shift Decoded_data , Right , 11
  ' Can be shift this to Correctbch itself, but kept it here to check  and test

  If Result <> &HFF Then
    If Inputdata <> Decoded_data Then
      Print "         Error check this"
      Print "---------Srikanth Kamath T___________**********"
    Else
      Print "Inputdata " ; Inputdata ; " Decode Data " ; Decoded_data ; " No of Error Corrected " ; Result
      Print "---------Decode Sucessful___________**********"
    End If
  Else
    Print "---------Decode not possible___________**********" ; " No of Error more than 2: " ; Result
  End If
  'Goto Main
Loop


'***************Function Encoded the 21 bit InputData to 32 bit BCH_word********
' This Function Encoded the 21 bit InputData to 32 bit BCH_word

Function Encodebch(datas As Long) As Long

  Local Tmp_enc As Long , Ci As Byte , Ltmp_enc As Long

  Ltmp_enc = datas
  '/ / Divide By Polynom
  For Ci = 0 To 20
    Shift Ltmp_enc , Left , 1
    Tmp_enc = Ltmp_enc And &H200000
    If Tmp_enc <> 0 Then
      Ltmp_enc = Ltmp_enc Xor &H1B4800
    End If
  Next

  '/ / Allign The Remainder
  Shift Ltmp_enc , Right , 10
  Ltmp_enc = Ltmp_enc And &H7FE

  ' / / Add Data
  Tmp_enc = datas
  Shift Tmp_enc , Left , 11
  Ltmp_enc = Ltmp_enc Or Tmp_enc
  Encodebch = Ltmp_enc
  ' / / Calculate Parity
  Ci = 0
  While Ltmp_enc <> 0
    Tmp_enc = Ltmp_enc And 1
    'debug
    Ci = Ci Xor Low(Tmp_enc)
    '             Tmp_enc2 = Tmp_enc2 Xor Tmp_enc
    '             Ci = Low(tmp_enc2)
    Shift Ltmp_enc , Right , 1
  Wend

  ' / / Add Parity
  Encodebch = Encodebch Or Ci
End Function


'-------------------------------------------------------------------------------
'END OF*********Function Encoded the 21 bit InputData to 32 bit BCH_word********


'***************The decoding and error correction start*************************
'*************************Correction Itself*************************************
' Using the zeh function
Declare Function Makesyndrome(x As Long , ByVal Polynom As Byte) As Byte
Declare Function Inverbit(bch_word As Long , ByVal Bitno As Byte) As Long

Function Correctbch(encodedbchword As Long) As Long
  Local Sa As Byte , Sb As Byte , Parity As Byte , Dist As Byte , Tmplong As Long , Tmp As Byte , Ltmp As Long

  Ltmp = encodedbchword
  ' / / Calculate Syndromes A And B
  Sa = Makesyndrome(Ltmp , &H05)
  Sb = Makesyndrome(Ltmp , &H1D)

  ' / / Calculate Parity
  Parity = 0

  While Ltmp <> 0
    Tmplong = Ltmp And 1
    Tmp = Low(Tmplong)
    Parity = Parity Xor Tmp
    Shift Ltmp , Right , 1
  Wend

  ' / / Check Syndromes
  If Sa = 0 And Sb <> 0 Then
    Result = &HFF
    Correctbch = encodedbchword
    Exit Function
  End If

  If Sb = 0 And Sa <> 0 Then
    Result = &HFF
    Correctbch = encodedbchword
    Exit Function
  End If

  '// If Both Syndromes Are 0(no Code Errors)
  If Sa = 0 And Sb = 0 Then
    If Parity = 0 Then
      '// No Errors
      Result = 0
      Correctbch = encodedbchword
      Exit Function
    End If
    'debug
    Correctbch = encodedbchword Xor 1
    Result = 1
    Exit Function
  End If

  Sa = LookUp(Sa , Table_sa)
  Sb = LookUp(Sb , Table_sb)
  '// If Both Syndromes Are Indicating One Error
  If Sa = Sb Then
    Correctbch = Inverbit(encodedbchword , Sa)
    ' debug 1
    ' If(parity! = 0) Return 1 ; / / One Error
    'Tmp = 0
    'If Parity = 0 Then
    '   Set Tmp.0
    'Else
    '    Reset Tmp.0
    'End If
    '--- debug 1
    If Parity <> 0 Then
      Result = 1
      Exit Function
    End If
    ' debug 1
    Correctbch = Correctbch Xor 1
    Result = 2
    Exit Function
  End If

  '// More Then Two Errors - Not Correctable
  If Parity <> 0 Then
    Result = &HFF
    Correctbch = encodedbchword
    Exit Function
  End If

  Dist = Sa - Sb
  '// Modulo 1f
  Tmp = Dist And &H80
  If Tmp <> 0 Then
    Dist = Dist + &H1F
  End If

  '// Find Distance Between Errors
  Dist = LookUp(Dist , Table_dist)

  '// Not Correctable
  If Dist = &HFF Then
    Result = &HFF
    Correctbch = encodedbchword
    Exit Function
  End If

  '// Correct 1 -st Error Location
  Tmp = LookUp(Dist , Dist_correction_table)
  Sa = Sa - Tmp

  '// Modulo 31
  Tmp = Sa And &H80
  If Tmp <> 0 Then
    Sa = Sa + &H1F
  End If

  '/ / Correct 1 -st Error
  Tmp = Sa + 1
  Correctbch = Inverbit(encodedbchword , Tmp)

  '// Find 2 -nd Error Location
  Sa = Sa + Dist

  '// Modulo 31
  If Sa >= 31 Then
    Sa = Sa - 31
  End If

  '//Correct 2 -nd Error
  Tmp = Sa + 1
  Correctbch = Inverbit(Correctbch , Tmp)
  Result = 2
End Function


'-------------------------------------------------------------------------------
'END OF*******************Correction Itself*************************************




'************************Divide By Polynom**************************************

'Sub Makesyndrome(x As Long , Byval Polynom As Byte)
Function Makesyndrome(x As Long , ByVal Polynom As Byte) As Byte
  Local Tmp_syn As Long , Cntr As Byte , L_polynom As Long , Tmp_syn2 As Long

  Tmp_syn = x And &HFFFFFFFE
  L_polynom = Polynom
  Shift L_polynom , Left , 27

  ' / / Calculate The Syndrome
  For Cntr = 0 To 30
    Tmp_syn2 = Tmp_syn And &H80000000
    If Tmp_syn2 <> 0 Then
      Shift Tmp_syn , Left , 1
      Tmp_syn = Tmp_syn Xor L_polynom
    Else
      Shift Tmp_syn , Left , 1
    End If
  Next
  Shift Tmp_syn , Right , 27
  Makesyndrome = Tmp_syn

End Function
'-------------------------------------------------------------------------------
'END OF******************Divide By Polynom**************************************




'***************Invert Bit At The Position Bitno********************************

'Sub Inverbit(bch_word As Long , Byval Bitno)
Function Inverbit(bch_word As Long , ByVal Bitno As Byte) As Long
  Local Tmp_inver As Long
  Tmp_inver = 0
  Set Tmp_inver.Bitno
  Inverbit = bch_word Xor Tmp_inver
End Function
'-------------------------------------------------------------------------------
'END OF*********Invert Bit At The Position Bitno********************************



'****************Syndrome A Error Position Table********************************

Table_sa:
Data &H00 , &H1B , &H1C , &H0E , &H1D , &H01 , &H0F , &H07
Data &H1E , &H19 , &H02 , &H17 , &H10 , &H04 , &H08 , &H13
Data &H1F , &H06 , &H1A , &H0D , &H03 , &H12 , &H18 , &H16
Data &H11 , &H15 , &H05 , &H0C , &H09 , &H0A , &H14 , &H0B

Table_sb:
Data &H00 , &H1B , &H1C , &H10 , &H1D , &H05 , &H11 , &H02
Data &H1E , &H16 , &H06 , &H0C , &H12 , &H14 , &H03 , &H19
Data &H1F , &H0E , &H17 , &H0A , &H07 , &H08 , &H0D , &H09
Data &H13 , &H18 , &H15 , &H0B , &H04 , &H01 , &H1A , &H0F

Table_dist:
Data &HFF , &HFF , &HFF , &H03 , &HFF , &HFF , &H06 , &H0B
Data &HFF , &HFF , &HFF , &HFF , &H0C , &HFF , &H09 , &H08
Data &HFF , &H0E , &HFF , &H0A , &HFF , &HFF , &HFF , &H04
Data &H07 , &H05 , &HFF , &H02 , &H0D , &H01 , &H0F , &HFF

Dist_correction_table:
Data &HFF , &H13 , &H06 , &H1E , &H0B , &H03 , &H1C , &H17
Data &H15 , &H11 , &H05 , &H14 , &H18 , &H0F , &H0E , &H19