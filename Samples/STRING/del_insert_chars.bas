'----------------------------------------------------------------
'                  (c) 1995-2011, MCS
'                   del_insert_chars.bas
'  This sample demonstrates the delchar, delchars and insertchar statements
'-----------------------------------------------------------------
$regfile="m88def.dat"
$crystal = 8000000
$hwstack = 40
$swstack = 40
$framesize = 40

dim s as string * 30
s = "This is a test string" ' create a string
delchar s, 1                ' remove the first char
print s                     ' print it

insertchar s,1, "t"         ' put a small t back
print s

delchars s,"s"              ' remove all s
print s
end
