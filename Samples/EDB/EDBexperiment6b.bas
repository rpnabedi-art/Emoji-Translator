'--------------------------------------------------------------
'                        EDBexperiment6b.bas
'       Experiment 6b for the Educational Development Board
'                  (c) 1995-2006, MCS Electronics
'                        Fileversion 1.0
'--------------------------------------------------------------
'
'Purpose:
'This program show how to use the Print ; , Chr() and Waitkey() statement
'
'Conclusions:
'You should bo able to work with the UART now
'
'From this experiment repeating remarks will not be added to the *.bas file

$regfile = "m88def.dat"
$crystal = 8000000
$baud = 19200
$hwstack = 40
$swstack = 40
$framesize = 40


Dim Akey As Byte                                            'Here we declare a byte variable

Print
Print "Hello, hit any alphanumerical key..."
Akey = Waitkey()                                            'Waitkey waits untill a char is received from the UART
Print Akey

Wait 1
Print
Print "Thanks!, as you could see the controller prints a number"
Print "but not the key you pressed."

Wait 1
Print
Print "Now try the enter key..."
Akey = Waitkey()
Akey = Waitkey()
Print Akey

Print
Print "The number you see is the ASCII value of the key you pressed."
Print "We need to convert the number back to the key..."
Print                                                       'Notice what this line does
Print "Please try an alphanumerical key again..."
Akey = Waitkey()
Print Chr(akey)                                             'Notice what this does
Print "That's fine!"

Wait 1
Print
Print "For a lot of functions, just one key is not enough..."
Print "Now type your name and hit enter to confirm"

Dim Inputstring As String * 12                              'Declare a string variable here


Do
Akey = Waitkey()
If Akey = 13 Then Goto Thanks                               'On enter key goto thanks
   Inputstring = Inputstring + Chr(akey)                    'Assign the string
Loop

Thanks:
Print "Thank you " ; Inputstring ; " !"                     'Notice what ; does

Wait 1
Print
Print "Take a look at the program code and try to understand"
Print "how this program works. Also press F1 at the statements"
Print
Print "If you understand everything continue to the next experiment"

End