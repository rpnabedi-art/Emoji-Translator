using System.Diagnostics;
using System;
using System.Windows.Forms;
using System.Collections;
using System.Drawing;
using Microsoft.VisualBasic;
using System.Data;
using System.Collections.Generic;


namespace USB_termo_2
{
    public partial class Form1 : Form
    {
        int vid = 0xaaaa;
        int pid = 0xef04;
        short ver = -1;
        short ind = 0;
        int Handless = 0;
        byte[] Buffer = new byte[5];
        int State;
        int res;


        public Form1()
        {
            InitializeComponent();
        }

        private void Form1_Load(object sender, EventArgs e)
        {
            //При открытии формы открыть девайс 
            Handless = v_usb.HID_OpenDevice(pid, vid, ver, ind); 

        }

        private void timer1_Tick(object sender, EventArgs e)
        {
 
        State = v_usb.HID_DeviceTest(pid, vid, ver, ind);

        if (State == 0) //если устройство отключено
            {
            label1.Text = "Девайс отключен";
            label2.Text = "Девайс отключен";
            Buffer[1] = 0;
            Buffer[2] = 0;
            Buffer[3] = 0;
            Buffer[4] = 0;
            }
        else    //если устройство подключено, то вычисляем температуру
            {
                Handless = v_usb.HID_OpenDevice(pid, vid, ver, ind);
                res = v_usb.HID_ReadDevice(Handless, Buffer, Buffer.Length);



            //######################################################################################
            // ВЫЧИСЛЕНИЕ ТЕМПЕРАТУРЫ ИЗ ПРИНЯТЫХ БАЙТОВ И ОТОБРАЖЕНИЕ В НЕОБХОДИМОМ ФОРМАТЕ
                double zamer;
                string  temperatura;

                if (Buffer[1] == 254 || Buffer[2] == 254)
                {
                    label1.ForeColor = Color.Red;
                    label1.Text = "No datchik";
                }
                else
                {
                    zamer = Convert.ToDouble(Buffer[1]) / 16 + Convert.ToDouble(Buffer[2])* 16;
                    if (zamer < 150 && zamer > -50)
                    {
                        temperatura = Strings.Format(zamer, ".0");
                        label1.ForeColor = Color.Black;
                        label1.Text = temperatura + " °C";
                    }
                }
         
            if (Buffer[3] == 254 || Buffer[4] == 254) 
            {
                label2.ForeColor = Color.Red;
                label2.Text = "No datchik";
            }
            else
            {
                zamer = Convert.ToDouble(Buffer[3]) / 16 + Convert.ToDouble(Buffer[4]) * 16;
                if (zamer < 150 && zamer > -50) 
                {
                    temperatura = Strings.Format(zamer, ".0");
                    label2.ForeColor = Color.Black;
                    label2.Text = temperatura + " °C";
                }
            }
            }

            //######################################################################################
            

        }

        private void Form1_FormClosed(object sender, FormClosedEventArgs e)
        {
             //При закрытии формы закрыть девайс
            res = v_usb.HID_CloseDevice(Handless);

        }
    }
}
