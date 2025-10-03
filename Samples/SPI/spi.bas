$REGFILE="m88DEF.DAT"
$hwstack = 40
$swstack = 40
$framesize = 40


Dim B As Byte
Dim A(10) As Byte

Config Spi = Hard , Interrupt = Off , Data Order = Msb , Master = Yes , Polarity = Low , Phase = 0 , Clockrate = 128 

$regfile = "m128def.dat"
Spiinit
B = 5
Spiout A(1) , B

Spiin A(1) , B

A(1) = Spimove(a(2))
End