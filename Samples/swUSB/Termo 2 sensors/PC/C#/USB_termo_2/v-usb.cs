using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Runtime.InteropServices;   
 
namespace USB_termo_2
{
    class v_usb
    {
        [DllImport("HID_Lib_PB.dll", CharSet = CharSet.Ansi, SetLastError = true, ExactSpelling = true)]
        public static extern int HID_OpenDevice(int PID, int VID, short VersionNumber, short Index);
        [DllImport("HID_Lib_PB.dll", CharSet = CharSet.Ansi, SetLastError = true, ExactSpelling = true)]
        public static extern int HID_GetFeature(int Handle, byte[] buffer, int LenBuffer);
        [DllImport("HID_Lib_PB.dll", CharSet = CharSet.Ansi, SetLastError = true, ExactSpelling = true)]
        public static extern int HID_SetFeature(int Handle, byte[] buffer, int LenBuffer);
        [DllImport("HID_Lib_PB.dll", CharSet = CharSet.Ansi, SetLastError = true, ExactSpelling = true)]
        public static extern int HID_CloseDevice(int Handle);
        [DllImport("HID_Lib_PB.dll", CharSet = CharSet.Ansi, SetLastError = true, ExactSpelling = true)]
        public static extern int HID_ReadDevice(int Handle, byte[] buffer, int LenBuffer);
        [DllImport("HID_Lib_PB.dll", CharSet = CharSet.Ansi, SetLastError = true, ExactSpelling = true)]
        public static extern int HID_WriteDevice(int Handle, byte[] buffer, int LenBuffer);
        [DllImport("HID_Lib_PB.dll", CharSet = CharSet.Ansi, SetLastError = true, ExactSpelling = true)]
        public static extern int HID_GetInputReport(int Handle, ref byte[] buffer, int LenBuffer);
        [DllImport("HID_Lib_PB.dll", CharSet = CharSet.Ansi, SetLastError = true, ExactSpelling = true)]
        public static extern int HID_SetOutputReport(int Handle, ref byte[] buffer, int LenBuffer);
        [DllImport("HID_Lib_PB.dll", CharSet = CharSet.Ansi, SetLastError = true, ExactSpelling = true)]
        public static extern int HID_GetNumInputBuffers(int Handle);
        [DllImport("HID_Lib_PB.dll", CharSet = CharSet.Ansi, SetLastError = true, ExactSpelling = true)]
        public static extern int HID_DeviceTest(int PID, int VID, short VersionNumber, short Index);

    }
}
