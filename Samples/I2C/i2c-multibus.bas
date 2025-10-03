'------------------------------------------------------------------------------
'name                     : I2C-multibus.bas
'copyright                : (c) 1995-2014, MCS Electronics
'purpose                  : demonstrates I2C multibus library
'micro                    : Mega88
'suited for demo          : no, lib not included in demo
'commercial addon needed  : no
'------------------------------------------------------------------------------
$regfile="m88def.dat"
$crystal=8000000
$hwstack=32
$swstack=24
$framesize=24

config i2cbus=0,scl=portc.0,sda= portc.1 'each bus requires a configuration of the SCL and SDA pins
config i2cbus=1,scl=portc.2,sda= portc.3 'this sample creates 4 busses
config i2cbus=2,scl=portd.2,sda= portd.3
config i2cbus=3,scl=portd.4,sda= portd.5

Dim j as Byte

For j=0 to 3                              'the first bus is 0 !!!
  i2cbus=j                                'select the BUS
  i2cinit                                 'init the pins and state
Next

do
  for j=0 to 3
    i2cbus=j                              'select the bus
    I2CSend &H40, &B01010101              'send some data
  next
  waitms 100
loop

end