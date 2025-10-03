'-----------------------------------------------------------------------------------------
'name                     : lookdown.bas
'copyright                : (c) 1995-2013, MCS Electronics
'purpose                  : demo: LOOKDOWN
'micro                    : Mega88
'suited for demo          : yes
'commercial addon needed  : no
'-----------------------------------------------------------------------------------------
$RegFile = "m88def.dat"

Dim Idx As Integer , Search As Byte , Entries As Byte

'we want to search for the value 3
Search = 3
'there are 5 entries in the table
Entries = 5

'lookup and return the index
Idx = Lookdown(search , Label , Entries)
Print Idx

Search = 1
Idx = Lookdown(search , Label , Entries)
Print Idx


Search = 100
Idx = Lookdown(search , Label , Entries)
Print Idx                                                   ' return -1 if not found


'looking for integer or word data requires that the search variable is
'of the type integer !
Dim Isearch As Integer
Isearch = 400
Idx = Lookdown(isearch , Label2 , Entries)
Print Idx                                                   ' return 3

End


Label:
Data 1 , 2 , 3 , 4 , 5

Label2:
Data 1000% , 200% , 400% , 300%