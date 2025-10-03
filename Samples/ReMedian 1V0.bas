'*******************************************************************************
'                       MEDIAN ESTIMATOR FOR CONTINOUS DATA
'*******************************************************************************
' A superior substitute for simple avaraging is to use a Median filter.
' The complexity is usuallay prohibative but this recursive algorithm is fast
' and use limited CPU and storage resources.
'
' It is based on theory by Peter J Rousseeuw and Gilbert W basset
' Paper: "The Remedian, A robust Averaging Method Fpr Large Data Sets"
' ftp://ftp.win.ua.ac.be/pub/preprints/90/Remrob90.pdf

' Upside:
' 1. Insensitive to outliers (Very important!)
' 2. Uses very little RAM even for long sequences.
' 3. Marginally slower than "standard median algo"
' 4. Easy coding, but relies on an efficient sort function

' Downside:
' 5. Sensitive to outliers in excell of 50%
' 6. Result is an estimate of the median. Not exact median, but normally very close.


'*****************************  H I S T O R Y  ********************************
' 1.0  Working version for Bascom AVR
'******************************************************************************

Const Proj = "REMEDIAN "
Const Majrev = 1                                            'Major revision number
Const Minrev = 0                                            'Minor revision number
Const Datum = "2011-05-23"
Const Comp = "Monolitsystem AB"
Const Auth = "Per Svensson"
Const Compiler = "BasCom 2.0.5.0"

$regfile = "m128def.dat"
$Crystal = 32000000                                             'CLOCK Hz
$Timeout = 20000000                                             'Tstop (COMMON TO ALL UARTS) (20e6 ~ 10s at XTAL=32Mhz)
Config Base = 1


'Stack Settings:
$hwstack = 64
$swstack = 64
$framesize = 64


Declare Function Remedian(byval Newdata As Integer , Byval Bpar As Byte , Byval Kpar As Byte , _
                   Arr1() As Integer , Arr2() As Integer , Arr3() As Integer , _
                   P1 As Byte , P2 As Byte , P3 As Byte , Median As Integer ) As Byte


'CONSTANTS:
'----------
Const Nul = "{000}"
Const Tab = "{009}"
Const Crlf = "{013}{010}"
Const Cr = "{013}"
Const Lf = "{010}"
Const Ctrl_r = "{018}"                                      '^R  (Reboot)
Const Esc = "{027}"
Const Ff = "{012}"                                          'Form Feed
Const Pi = 3.141595


'GENERAL VARIABLES
'------------------

'Integers (16bit)
Dim Indata As Integer
Dim Sampnum As Integer                                      'Number of Newdata entries
Dim Remaining As Integer                                    'Number of samples till next estimate


'Bytes
Dim B1 As Byte
Dim B2 As Byte
Dim Bsize As Byte                                           'REMEDIAN parameter "b"
Dim Ksize As Byte                                           'REMEDIAN parameter "k"


'Arrays and pointers used by the REMEDIAN() routine
'to make it reusable for more than one channel
Dim Ar1(15) As Integer
Dim Ar2(15) As Integer
Dim Ar3(15) As Integer
Dim Median As Integer
Dim Ptr1 As Byte , Ptr2 As Byte , Ptr3 As Byte              'Array pointers (One for each Voltage array)



'Write Version# etc...
'--------------------------------
B1 = Majrev
B2 = Minrev
Print Proj ; Crlf ; "Firmware: " ; Str(b1) ; "." ; Str(b2) ; "  " ; Datum ; Crlf



'===============================================================================
'
'                      M     M      A       III   N    N
'                      MM   MM     A A       I    NN   N
'                      M M M M    A   A      I    N N  N
'                      M  M  M   A A A A     I    N  N N
'                      M     M  A       A    I    N   NN
'                      M     M A         A  III   N    N
'
'===============================================================================

'Change these two as you please
Bsize = 5                                                   '[3-15] Length of each array (must be an odd number)
Ksize = 3                                                   '[1-3] Number of declared arrays (or less)



Sampnum = Bsize ^ Ksize
Print Crlf ; "Median will be calculated for series of " ; Sampnum ; " samples"
Print "(Change Bsize and Ksize for other lengths)"
Print "(Also - change INDATA to se how noise affects the result)"
Print

Ptr1 = 0 : Ptr2 = 0 : Ptr3 = 0                              'Init
Sampnum = 0
Do
   Incr Sampnum
   Decr Remaining
   Indata = 900 + Rnd(200)                                  'Random stimuli around 1000 (Change as you please)
   If Remedian(indata , Bsize , Ksize , Ar1(1) , Ar2(1) , Ar3(1) , Ptr1 , Ptr2 , Ptr3 , Median ) = 1 Then       'Median of 5^3 = 125 samples
      Print Crlf ; "Xnew(" ; Sampnum ; ")   Median=" ; Median
   Else
      Print ".";
   End If
Loop
'-------------------------------- END OF MAIN --------------------------------------------------------




'###############################################################################
'#                          SUBROUTINES
'###############################################################################


Function Remedian(byval Newdata As Integer , Byval Bpar As Byte , Byval Kpar As Byte , _
          Arr1() As Integer , Arr2() As Integer , Arr3() As Integer , _
          P1 As Byte , P2 As Byte , P3 As Byte , Median As Integer ) As Byte
'A superior substitute for simple avaraging
'This Median estimator is fast and use limited CPU and storage resources.
'MEDIAN is the return variable.
'NEWDATA is entered sequencially, and an estimated median will come out every B^K call,
'so it takes Bpar^Kpar calls before all array elements are filled, giving a first accurate estimate of MEDIAN.
'Bpar = Length of each array (must be an odd number)
'Kpar = Number of declared arrays (or less)
'OBS *** It is assumed that CONFIG BASE=1 ***

'It is based on theory by Peter J Rousseeuw and Gilbert W basset
'Paper: "The Remedian, A robust Averaging Method Fpr Large Data Sets"
'ftp://ftp.win.ua.ac.be/pub/preprints/90/Remrob90.pdf

'Arr1-Arr4 are four integer arrays. Each of length Bpar
'P1-P3 are pointers to the three median sub arrays

'MEDIAN LENGTH:  (Number of data samples required for each estimated median)
'          | Bpar=3  | Bpar=5  | Bpar=7  | Bpar=9  | Bpar=11  | Bpar=13  | Bpar=15 |
'----------|---------|---------|---------|---------|----------|----------|---------|
'| Kpar=1: |     3   |      5  |      7  |      9  |      11  |      13  |     15  |
'| Kpar=2: |     9   |     25  |     49  |     81  |     121  |     169  |    225  |
'| Kpar=3: |    27   |    125  |    343  |    729  |    1331  |     169  |   3375  |
'| Kpar=4: |    81   |    625  |   2401  |   5103  |   14641  |   28561  |  50625  | Kpar >= 4 is not implemented in
'----------|---------|---------|---------|---------|----------|----------|---------| this code but can easily be added


'BENCHMARK:  (Number of CPU cycles required per data sample)
'Each data entry will result in 0-4 sorting actions.
'The overhead when no sorting is needed is only 190 CPU cycles for data entry.
'Each sorting consumes extra cycles, and in the worst case we need B sortings.
'This happens when the last sample in a series is entered, and a new Median is computed.
'CPU loading is consequently very uneven.


Local Pmid As Byte                                          'The mid element contains the median after sorting
Local Mtemp As Integer

    Pmid = Bpar + 2
    Shift Pmid , Right , 1                                  ' (Bpar/2)+1

    Incr P1
    Arr1(p1) = Newdata
    If P1 >= Bpar Then
       P1 = 0                                               'Circular buffer pointer for Array 1
       Sort Arr1(1) , Bpar
       Mtemp = Arr1(pmid)                                   'Median from Array 1
'       Print "X(" ; Sampnum ; ")=" ; Newdata ; Tab ; "    M1=" ; Mtemp       'DEBUG
       If Kpar = 1 Then Goto Remed_exit_new                 'Only one array used
       Incr P2
       Arr2(p2) = Mtemp
       If P2 >= Bpar Then
          P2 = 0                                            'Circular buffer pointer for Array 2
          Sort Arr2(1) , Bpar
          Mtemp = Arr2(pmid)                                'Median from Array 2
'          Print "X(" ; Sampnum ; ")=" ; Newdata ; Tab ; "      M2=" ; Mtemp       'DEBUG
          If Kpar = 2 Then Goto Remed_exit_new              'Only two arrays used
          Incr P3
          Arr3(p3) = Mtemp
          If P3 >= Bpar Then
             P3 = 0                                         'Circular buffer pointer for Array 3
             Sort Arr3(1) , Bpar
             Mtemp = Arr3(pmid)                             'Median from Array 3
'             Print "X(" ; Sampnum ; ")=" ; Newdata ; Tab ; "        M3=" ; Mtemp       'DEBUG
             Goto Remed_exit_new                            'All four arrays used
          End If
       End If
    End If

    Remedian = 0                                            'No change
    Exit Function

    Remed_exit_new:
    Median = Mtemp                                          'Update the Median return value
    Remedian = 1                                            'And flag a change

End Function
'-------------------------------------------------------------------------------


End