﻿#pragma checksum "C:\Users\Francesco\Desktop\Src\Shoutcast.Sample\MainPage.xaml" "{406ea660-64cf-4c82-b6f0-42d48172a799}" "28A921BFF6814523B99E9B7A2E1F570A"
//------------------------------------------------------------------------------
// <auto-generated>
//     Il codice è stato generato da uno strumento.
//     Versione runtime:4.0.30319.34014
//
//     Le modifiche apportate a questo file possono provocare un comportamento non corretto e andranno perse se
//     il codice viene rigenerato.
// </auto-generated>
//------------------------------------------------------------------------------

using System;
using System.Windows;
using System.Windows.Automation;
using System.Windows.Automation.Peers;
using System.Windows.Automation.Provider;
using System.Windows.Controls;
using System.Windows.Controls.Primitives;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Ink;
using System.Windows.Input;
using System.Windows.Interop;
using System.Windows.Markup;
using System.Windows.Media;
using System.Windows.Media.Animation;
using System.Windows.Media.Imaging;
using System.Windows.Resources;
using System.Windows.Shapes;
using System.Windows.Threading;


namespace Shoutcast.Sample {
    
    
    public partial class MainPage : System.Windows.Controls.UserControl {
        
        internal System.Windows.Controls.Grid LayoutRoot;
        
        internal System.Windows.Controls.TextBlock statusTextBlock;
        
        internal System.Windows.Controls.RadioButton mp3StreamRadioButton;
        
        internal System.Windows.Controls.RadioButton aacStreamRadioButton;
        
        private bool _contentLoaded;
        
        /// <summary>
        /// InitializeComponent
        /// </summary>
        [System.Diagnostics.DebuggerNonUserCodeAttribute()]
        public void InitializeComponent() {
            if (_contentLoaded) {
                return;
            }
            _contentLoaded = true;
            System.Windows.Application.LoadComponent(this, new System.Uri("/Shoutcast.Sample;component/MainPage.xaml", System.UriKind.Relative));
            this.LayoutRoot = ((System.Windows.Controls.Grid)(this.FindName("LayoutRoot")));
            this.statusTextBlock = ((System.Windows.Controls.TextBlock)(this.FindName("statusTextBlock")));
            this.mp3StreamRadioButton = ((System.Windows.Controls.RadioButton)(this.FindName("mp3StreamRadioButton")));
            this.aacStreamRadioButton = ((System.Windows.Controls.RadioButton)(this.FindName("aacStreamRadioButton")));
        }
    }
}

