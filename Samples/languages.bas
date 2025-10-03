'------------------------------------------------------------------------------
'                         language.bas
'                 (c) 1995-2013 , MCS Electronics
'This example will only work with the resource add on
'resources are only needed for multi language applications
'By changing the LANGUAGE variable all strings used will be shown in the proper language
'------------------------------------------------------------------------------
$RegFile = "m88def.dat"
$crystal = 8000000
$baud = 19200

'a few steps are needed to create a multi language application
'STEP 1, make your program as usual
'STEP 2, generate a file with all string resources using the $RESOURCE DUMP directive
'$resource Dump , "English" , "Dutch" , "German" , "Italian" 'we will use 4 languages
'STEP 3, compile and you will find a file with the BCS extesion
'STEP 4, use Tools, Resource Editor and inport the resources
'STEP 5, add languages, translate the original strings
'STEP 6, compile your program this time with specifying the languages without the DUMP option

$resource "English" , "Dutch" , "German" , "Italian"
'this must be done before you use any other resource !
'in this sample 4 languages are used
'this because all resources found are looked up in the BCR file(BasCom Resource)
Dim S As String * 20
Dim B As Byte

Print "Multi language test"
Do
   Print "This" ;
   S = " is a test" : Print S
   Input "Name " , S
   Print "Hello " ; S


   'now something to look out for !
   'all string data not found in the BCR file is not resourced. so there is no problem with the following:
   If S = "mark" Then
      Print "we can not change names"
   End If

   'but if you want to have "mark" resourced for another sentence you have a problem.
   'the solution is to turn off resourcing
   $resource Off
   Print "mark"
   If S = "mark" Then
      Print "we can not change names"
   End If
   $resource On

   Language = Language + 1
   If Language > 3 Then Language = 0
Loop