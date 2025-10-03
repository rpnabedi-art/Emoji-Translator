$regfile = "attiny15.dat"
$tiny
$crystal = 1000000
$noramclear
$hwstack = 0
$swstack = 0
$framesize = 0

Dim A As Iram Byte
Dim B As Iram Byte
A = 100 : B = 5
A = A + B
end
