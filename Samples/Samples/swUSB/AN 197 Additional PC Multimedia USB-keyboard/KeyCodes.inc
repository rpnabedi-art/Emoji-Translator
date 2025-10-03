$nocompile
'******************************* Key codes *************************************
Key_codes:
$eeprom

Data 255                                                    'First byte is empty
'----------------------------- Basic Layout ------------------------------------
Data 1 , 35 , 2                                             '1 - Browser
Data 1 , 138 , 1                                            '2 - Mail
Data 1 , 33 , 2                                             '3 - Search
Data 1 , 148 , 1                                            '4 - My PC
Data 1 , 146 , 1                                            '5 - Calculator
Data 1 , 181 , 0                                            '6 - FastForward
Data 1 , 182 , 0                                            '7 - Rewind
Data 1 , 183 , 0                                            '8 - Stop
Data 1 , 205 , 0                                            '9 - Play/Pause
Data 1 , 226 , 0                                            '10 - Mute
Data 1 , 234 , 0                                            '11 - Volume-
Data 1 , 233 , 0                                            '12 - Volume+
Data 2 , 129 , 0                                            '13 - Power
Data 2 , 131 , 0                                            '14 - Wake Up
Data 2 , 130 , 0                                            '15 - Standby
Data 4 , 0 , 61                                             '16 - Close (Alt+F4)
Data 8 , 0 , 7                                              '17 - Turn/Open (Win+D)
Data 4 , 0 , 40                                             '18 - Full Size (Alt+Enter)
Data 5 , 0 , 76                                             '19 - CTRL + ALT + DEL
Data 8 , 0 , 8                                              '20 - Explorer (Win+E)
Data 1 , 0 , 6                                              '21 - Copy (Ctrl+C)
Data 1 , 0 , 25                                             '22 - Insert (Ctrl+V)
Data 1 , 0 , 27                                             '23 - Cut (Ctrl+X)
Data 1 , 0 , 22                                             '24 - Save (Ctrl+S)
Data 1 , 0 , 29                                             '25 - Undo (Ctrl+Z)
Data 8 , 0 , 72                                             '26 - System (Win+Pause/Break)
Data 4 , 0 , 44                                             '27 - System Menu (Alt+Space)
Data 3 , 0 , 17                                             '28 - Create A New Folder (Ctrl+Shift+N)
Data 6 , 0 , 70                                             '29 - High Contrast ON or OFF (Left Alt+Left Shift+PrtScn)
Data 2 , 0 , 67                                             '30 - Shortcut menu (Shift+F10)
Data 3 , 0 , 41                                             '31 - Task Manager (Ctrl+Shift+Esc)
Data 8 , 0 , 24                                             '32 - Ease of Access Center (Win+U)
Data 8 , 0 , 10                                             '33 - Gadgets (Win+G)
Data 8 , 0 , 19                                             '34 - Presentation mode (Win+P)
Data 255 , 255 , 255

'--------------------------- Microsoft Word Layout -----------------------------
Data 5 , 0 , 6                                              '1 - Insert © (Alt+Ctrl+C)
Data 5 , 0 , 21                                             '2 - Insert ® (Alt+Ctrl+R)
Data 5 , 0 , 23                                             '3 - Insert ™ (Alt+Ctrl+T)
Data 5 , 0 , 55                                             '4 - Insert ... (Alt+Ctrl+.)
Data 5 , 0 , 9                                              '5 - Insert a footnote (Alt+Ctrl+F)
Data 5 , 0 , 7                                              '6 - Insert an endnote (Alt+Ctrl+D)
Data 1 , 0 , 14                                             '7 - Insert a hyperlink (Ctrl+K)
Data 6 , 0 , 7                                              '8 - Insert current date (Alt+Shift+D)
Data 6 , 0 , 23                                             '9 - Insert time (Alt+Shift+T)
Data 1 , 0 , 66                                             '10 - Insert an empty {} field (Ctrl+F9)
Data 1 , 0 , 46                                             '11 - Apply/remove subscript (Ctrl+=)
Data 3 , 0 , 46                                             '12 - Apply/remove superscript (Ctrl+Shift+=)
Data 3 , 0 , 7                                              '13 - Apply/remove double-underline (Ctrl+Shift+D)
Data 3 , 0 , 4                                              '14 - Apply/remove all capitals (Ctrl+Shift+A)
Data 3 , 0 , 14                                             '15 - Apply/remove small capitals (Ctrl+Shift+K)
Data 2 , 0 , 60                                             '16 - All upper / first letter upper / all lower-case (Shift+F3)
Data 3 , 0 , 37                                             '17 - Display nonprinting characters (Ctrl+Shift+*)
Data 1 , 0 , 6                                              '18 - Copy (Ctrl+C)
Data 1 , 0 , 25                                             '19 - Paste (Ctrl+V)
Data 1 , 0 , 27                                             '20 - Cut (Ctrl+X)
Data 1 , 0 , 60                                             '21 - Cut to the Spike (Ctrl+F3)
Data 3 , 0 , 60                                             '22 - Paste from the Spike (Ctrl+Shift+F3)
Data 1 , 0 , 29                                             '23 - Undo (Ctrl+Z)
Data 1 , 0 , 28                                             '24 - Redo (Ctrl+Y)
Data 1 , 0 , 7                                              '25 - Font dialog (Ctrl+D)
Data 1 , 0 , 48                                             '26 - Increase font size (Ctrl+])
Data 1 , 0 , 47                                             '27 - Decrease font size (Ctrl+[)
Data 1 , 0 , 9                                              '28 - Search menu (Ctrl+F)
Data 1 , 0 , 11                                             '29 - Find and replace dialog (Ctrl+H)
Data 2 , 0 , 61                                             '30 - Repeat find (Shift+F4)
Data 1 , 0 , 63                                             '31 - Switch between documents (Ctrl+F6)
Data 3 , 0 , 10                                             '32 - Statistic (Ctrl+Shift+G)
Data 1 , 0 , 19                                             '33 - Print (Ctrl+P)
Data 1 , 0 , 22                                             '34 - Save (Ctrl+S)
Data 255 , 255 , 255

'End so on... up to 170 combinations

$data