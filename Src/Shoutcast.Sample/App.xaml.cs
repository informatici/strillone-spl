//-----------------------------------------------------------------------
// <copyright file="App.xaml.cs" company="Andrew Oakley">
//     Copyright (c) 2010 Andrew Oakley
//     This program is free software: you can redistribute it and/or modify
//     it under the terms of the GNU Lesser General Public License as published by
//     the Free Software Foundation, either version 3 of the License, or
//     (at your option) any later version.
//
//     This program is distributed in the hope that it will be useful,
//     but WITHOUT ANY WARRANTY; without even the implied warranty of
//     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//     GNU Lesser General Public License for more details.
//
//     You should have received a copy of the GNU Lesser General Public License
//     along with this program.  If not, see http://www.gnu.org/licenses.
// </copyright>
//-----------------------------------------------------------------------

namespace Shoutcast.Sample
{
    using System;
    using System.Net;
    using System.Net.Browser;
    using System.Windows;

    /// <summary>
    /// This class represents our Silverlight application.
    /// </summary>
    public partial class App : Application
    {
        /// <summary>
        /// Initializes a new instance of the App class.
        /// </summary>
        public App()
        {
            HttpWebRequest.RegisterPrefix("http://", WebRequestCreator.ClientHttp);
            HttpWebRequest.RegisterPrefix("https://", WebRequestCreator.ClientHttp);

            this.Startup += this.Application_Startup;
            this.Exit += this.Application_Exit;
            this.UnhandledException += this.Application_UnhandledException;

            InitializeComponent();
        }

        /// <summary>
        /// Method called on application startup.
        /// </summary>
        /// <param name="sender">Sender of the event.</param>
        /// <param name="e">EventArgs associated with this event.</param>
        private void Application_Startup(object sender, StartupEventArgs e)
        {
            this.RootVisual = new MainPage();
        }

        /// <summary>
        /// Method called on application exit.
        /// </summary>
        /// <param name="sender">Sender of the event.</param>
        /// <param name="e">EventArgs associated with this event.</param>
        private void Application_Exit(object sender, EventArgs e)
        {
        }

        /// <summary>
        /// Event handler called when an unhandled exception is thrown by a Silverlight application.
        /// </summary>
        /// <param name="sender">Sender of the event.</param>
        /// <param name="e">ApplicationUnhandledExceptionEventArgs associated with this event.</param>
        private void Application_UnhandledException(object sender, ApplicationUnhandledExceptionEventArgs e)
        {
            // If the app is running outside of the debugger then report the exception using
            // the browser's exception mechanism. On IE this will display it a yellow alert 
            // icon in the status bar and Firefox will display a script error.
            if (!System.Diagnostics.Debugger.IsAttached)
            {
                // NOTE: This will allow the application to continue running after an exception has been thrown
                // but not handled. 
                // For production applications this error handling should be replaced with something that will 
                // report the error to the website and stop the application.
                e.Handled = true;
                Deployment.Current.Dispatcher.BeginInvoke(delegate { this.ReportErrorToDOM(e); });
            }
        }

        /// <summary>
        /// Reports the error to the DOM hosting the Silverlight control.
        /// </summary>
        /// <param name="e">ApplicationUnhandledExceptionEventArgs associated with this event.</param>
        private void ReportErrorToDOM(ApplicationUnhandledExceptionEventArgs e)
        {
            try
            {
                string errorMsg = e.ExceptionObject.Message + e.ExceptionObject.StackTrace;
                errorMsg = errorMsg.Replace('"', '\'').Replace("\r\n", @"\n");

                System.Windows.Browser.HtmlPage.Window.Eval("throw new Error(\"Unhandled Error in Silverlight Application " + errorMsg + "\");");
            }
            catch (Exception)
            {
            }
        }
    }
}
