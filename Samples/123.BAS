Rem This file contains an error in the include statement
Rem the file a.bas does not exist
Rem It shows that the editor will load this file
Rem and displays the error marker on this line
Rem when you compile the main file : include.bas
$nocompile

Print "hallo"
Print "World"
$Include "a.bas"      'this file does not exist so you will get an error