
'Output from example program:

'(

-----M25P16---Test----

Df_read_id = 20/20/15/10/00/00/00/00/00/00/00/00/00/00/00/00/00/00/00/00/
--page Nr 1 written--

--read from page Nr 1 --

1/2/3/4/5/6/7/8/9/10/11/12/13/14/15/16/17/18/19/20/21/22/23/24/25/26/27/28/29/30/31/32/33/34/35/36/37/38/39/40/41/42/43/44/45/46/47/48/49/50/51/52/53/54/55/56/57/58/59/60/61/62/63/64/65/66/67/68/69/70/71/72/73/74/75/76/77/78/79/80/81/82/83/84/85/86/87/88/89/90/91/92/93/94/95/96/97/98/99/100/101/102/103/104/105/106/107/108/109/110/111/112/113/114/115/116/117/118/119/120/121/122/123/124/125/126/127/128/129/130/131/132/133/134/135/136/137/138/139/140/141/142/143/144/145/146/147/148/149/150/151/152/153/154/155/156/157/158/159/160/161/162/163/164/165/166/167/168/169/170/171/172/173/174/175/176/177/178/179/180/181/182/183/184/185/186/187/188/189/190/191/192/193/194/195/196/197/198/199/200/201/202/203/204/205/206/207/208/209/210/211/212/213/214/215/216/217/218/219/220/221/222/223/224/225/226/227/228/229/230/231/232/233/234/235/236/237/238/239/240/241/242/243/244/245/246/247/248/249/250/251/252/253/254/255/0/


')






$regfile = "m328pdef.dat"
$crystal = 16e6                                             '16MHz
$hwstack = 110
$swstack = 110
$framesize = 160

Config Submode = New                                        'there is no need to DECLARE a sub/function before you call it but....(see helpfile)

 ' The M25P16 is an 16Mb (2Mb x 8) serial Flash memory
 ' The memory can be programmed 1 to 256 bytes at a time using the PAGE PROGRAM
 ' command. It is organized as 32 sectors, each containing 256 pages. Each page is 256
 ' bytes wide. Memory can be viewed either as 8,192 pages or as 2,097,152 bytes. The entire
 ' memory can be erased using the BULK ERASE command, or it can be erased one
 ' sector at a time using the SECTOR ERASE command.

 ' Sector = 256 pages * 256 bytes = 65536 --> &H00000000 .......&H0000FFFF

 'Memory Map
 ' Sector         Address Start           Address End
 '   31           &H001F0000              &H001FFFFF
 '   30           &H001E0000              &H001EFFFF
 '  ...           .........               ..........
 '  ...           .........               ..........
 '   1            &H00010000              &H0001FFFF
 '   0            &H00000000              &H0000FFFF




 'Hardware connections
 '
 'Atmega328p [Pinb.0] = Chip Select -----> M25P16 [CS]
 'Atmega328p [MISO]  -----> M25P16 [MISO]
 'Atmega328p [SCK]  -----> M25P16 [SCK]
 'Atmega328p [MOSI]  -----> M25P16 [MOSI]


 Config Portb.0 = Output
 Cs_m25p16 Alias Portb.0
 Set Cs_m25p16                                              'De-select (Low active)

 'Command Set Codes
 Const Write_enable = &H06                               'The WRITE ENABLE command sets the write enable latch (WEL) bit.
 Const Write_disable = &H04                              'The WRITE DISABLE command resets the write enable latch (WEL) bit.
 Const Read_identification = &H9F
 Const Read_status_register = &H05
 Const Write_status_register = &H01
 Const Read_data_bytes = &H03
 Const Read_data_bytes_higher_speed = &H0B
 Const Page_program = &H02
 Const Sector_erase = &HD8
 Const Bulk_erase = &HC7
 Const Deep_power_down = &HB9
 Const Release_from_deep_power_down = &HAB
 Const Wel = 1                                           'write enable latch bit
 Const Wip = 0                                           'write in progress bit
 Const Srwd = 7                                          'satus register write protect


 Dim Df_status As Byte
 Dim I As Word
 Dim Df_24_bit_address As Long

 Dim Df_array(256) As Byte

 Dim Df_page_number As Word

 Function Df_read_status() As Byte
     Local Tempvar As Byte
     Tempvar = Read_status_register                      'READ STATUS REGISTER
     Disable Interrupts
     Reset Cs_m25p16                                     'Chip Select
     Spiout Tempvar , 1                                  'Read Status Register
     Spiin Df_read_status , 1
     Set Cs_m25p16                                       'Deselect Chip
     Enable Interrupts
 End Function

 Sub Df_read_id()
     Local Tempvar As Byte
     Tempvar = Read_identification                       'READ IDENTIFICATION
     Disable Interrupts
     Reset Cs_m25p16                                     'Chip Select
     Spiout Tempvar , 1
     Spiin Df_array(1) , 20                              'Read 3 Byte
     Set Cs_m25p16                                       'Deselect Chip
     Enable Interrupts
 End Sub

 Sub Df_deep_powerdown_mode()
      Local Tempvar As Byte
       Tempvar = Deep_power_down
       Disable Interrupts
      Reset Cs_m25p16
      Spiout Tempvar , 1                                 ' Deep_power_down
      Set Cs_m25p16
      Enable Interrupts
      Waitus 4
 End Sub

 Sub Df_release_from_powerdown()
      Local Tempvar As Byte
       Tempvar = Release_from_deep_power_down
      Disable Interrupts
      Reset Cs_m25p16
      Spiout Tempvar , 1                                 ' Release_from_deep_power_down
      Set Cs_m25p16
      Enable Interrupts
      Waitus 30
 End Sub

 Sub Df_page_write(page_number As Word)
      Local Tempvar As Byte , I As Word , Templong As Long
      Local 24_bit_address_1 As Byte , 24_bit_address_2 As Byte , 24_bit_address_3 As Byte , Y As Word


      Templong = Page_number * 256
      '24-Bit Address
      I = Templong
      Y = Highw(templong)
      24_bit_address_1 = Low(i)                          'Bit 7  ......Bit 0
      24_bit_address_2 = High(i)                         'Bit 15 ......Bit 8
      24_bit_address_3 = Low(y)                          'Bit 23 ..... Bit 16

      Disable Interrupts

      Tempvar = Write_enable
      Reset Cs_m25p16
      Spiout Tempvar , 1                                 ' WRITE ENABLE
      Set Cs_m25p16

      Do
       Tempvar = Df_read_status()
      Loop Until Tempvar.1 = 1                           'Wait until The write enable latch (WEL) is set

      Tempvar = Page_program
      Reset Cs_m25p16
      Spiout Tempvar , 1                                 ' PAGE PROGRAM

      '24-Bit address
      Spiout 24_bit_address_3 , 1                        'Bit 23 ..... Bit 16
      Spiout 24_bit_address_2 , 1                        'Bit 15 ......Bit 8
      Spiout 24_bit_address_1 , 1                        'Bit 7  ......Bit 0


      For I = 1 To 256
        Spiout Df_array(i) , 1                           'Send 256 Byte
       Next I
      Set Cs_m25p16                                      'Deselect Chip

      Do
       Tempvar = Df_read_status()
      Loop Until Tempvar.0 = 0                           'Wait until WIP is Reset

      Enable Interrupts
  End Sub



  Sub Df_page_read(page_number As Word)
      Local Tempvar As Byte , I As Word , Templong As Long
      Local 24_bit_address_1 As Byte , 24_bit_address_2 As Byte , 24_bit_address_3 As Byte , Y As Word


      Templong = Page_number * 256
      '24-Bit Address
      I = Templong
      Y = Highw(templong)
      24_bit_address_1 = Low(i)                          'Bit 7  ......Bit 0
      24_bit_address_2 = High(i)                         'Bit 15 ......Bit 8
      24_bit_address_3 = Low(y)                          'Bit 23 ..... Bit 16

      Disable Interrupts
      Tempvar = &H0B                                     ' FAST Read Data Bytes
      Reset Cs_m25p16
      Spiout Tempvar , 1

      '24-Bit address

      Spiout 24_bit_address_3 , 1                        'Bit 23 ..... Bit 16
      Spiout 24_bit_address_2 , 1                        'Bit 15 ......Bit 8
      Spiout 24_bit_address_1 , 1                        'Bit 7  ......Bit 0

      Spiin Tempvar , 1                                  'DUMMY READ

      For I = 1 To 256
       Spiin Df_array(i) , 1
      Next I
      Set Cs_m25p16                                      'Deselect Chip

      Enable Interrupts
  End Sub

  Sub Df_sector_erase(page_number As Word)               'The SECTOR ERASE command sets to 1 (FFh) all bits inside the chosen sector.
      Local Tempvar As Byte , I As Word , Templong As Long
      Local 24_bit_address_1 As Byte , 24_bit_address_2 As Byte , 24_bit_address_3 As Byte , Y As Word


      Templong = Page_number * 256
      '24-Bit Address
      I = Templong                                       'First two byte
      Y = Highw(templong)                                'last byte
      24_bit_address_1 = Low(i)                          'Bit 7  ......Bit 0
      24_bit_address_2 = High(i)                         'Bit 15 ......Bit 8
      24_bit_address_3 = Low(y)                          'Bit 23 ..... Bit 16

      Disable Interrupts

      Tempvar = Write_enable
      Reset Cs_m25p16
      Spiout Tempvar , 1                                 ' WRITE ENABLE
      Set Cs_m25p16

      Do
       Tempvar = Df_read_status()
      Loop Until Tempvar.wel = 1                         'Wait until The write enable latch (WEL) is set

      Tempvar = Sector_erase
      Reset Cs_m25p16
      Spiout Tempvar , 1                                 ' SECTOR ERASE

      '24-Bit address
      'Any address inside the sector is a valid address for the SECTOR ERASE command

      Spiout 24_bit_address_3 , 1                        'Bit 23 ..... Bit 16
      Spiout 24_bit_address_2 , 1                        'Bit 15 ......Bit 8
      Spiout 24_bit_address_1 , 1                        'Bit 7  ......Bit 0
      Set Cs_m25p16                                      'Deselect Chip

      'The WIP bit is 1 during the self-timed SECTOR ERASE
      Do
       Tempvar = Df_read_status()
      Loop Until Tempvar.0 = 0                           'Wait until WIP is Reset

      Enable Interrupts
  End Sub



'---------Interfaces------------------------------------------------------------
Config Com1 = 57600 , Synchrone = 0 , Parity = None , Stopbits = 1 , Databits = 8 , Clockpol = 0

'Config SPI
Config Spi = Hard , Interrupt = Off , Data Order = Msb , Master = Yes , Polarity = Low , Phase = 0 , Clockrate = 16 , Noss = 0 , Spiin = 0
Spiinit



Wait 4

Print "-----M25P16---Test----"

Main_program:                                               'just a label

    Enable Interrupts

    Df_page_number = 1                                      'We use here page 1 as an example

    Call Df_release_from_powerdown()

    Call Df_sector_erase(df_page_number)

    Call Df_read_id()
    Print
    Print "Df_read_id = " ;
    For I = 1 To 20
      Print Hex(df_array(i)) ; "/" ;
    Next I




    Print

    For I = 1 To 256
       Df_array(i) = I                                      'Fill the array with something (just for testing)
    Next I



    Call Df_page_write(df_page_number)

    Print "--page Nr " ; Df_page_number ; " written--"

    For I = 1 To 256
       Df_array(i) = 0                                      'Set array to 0 (just for testing)
    Next

    Print

    Print "--read from page Nr " ; Df_page_number ; " --"
    Print


    Call Df_page_read(df_page_number)

    For I = 1 To 256
       Print Df_array(i) ; "/" ;
    Next
       Print

   Call Df_deep_powerdown_mode()                            'External Memory go to sleep !


   '..Do something !
   '.....

   '



End                                                         'end program