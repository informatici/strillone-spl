//-----------------------------------------------------------------------
// <copyright file="MainPage.xaml.cs" company="Andrew Oakley">
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
    using System.Globalization;
    using System.Windows;
    using System.Windows.Controls;
    using System.Windows.Media;
    using Silverlight.Media;

    /// <summary>
    /// This class represents the main page of our Silverlight application.
    /// </summary>
    [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Design", "CA1001:TypesThatOwnDisposableFieldsShouldBeDisposable", Justification = "When the page is unloaded, the ShoutcastMediaStreamSource is disposed.")]
    public partial class MainPage : UserControl
    {
        /// <summary>
        /// ShoutcastMediaStreamSource representing a Shoutcast stream.
        /// </summary>
        private ShoutcastMediaStreamSource source;

        /// <summary>
        /// Boolean to stop the status update if an error has occured.
        /// </summary>
        private bool errorOccured;

        /// <summary>
        /// Initializes a new instance of the MainPage class.
        /// </summary>
        public MainPage()
        {
            InitializeComponent();
        }

        /// <summary>
        /// Gets the media element resource of the page.
        /// </summary>
        private MediaElement MediaPlayer
        {
            get { return this.Resources["mediaPlayer"] as MediaElement; }
        }

        /// <summary>
        /// Event handler called when the buffering progress of the media element has changed.
        /// </summary>
        /// <param name="sender">Sender of the event.</param>
        /// <param name="e">RoutedEventArgs associated with this event.</param>
        private void BufferingProgressChanged(object sender, RoutedEventArgs e)
        {
            this.UpdateStatus();
        }

        /// <summary>
        /// Event handler called when the an exception is thrown parsing the streaming media.
        /// </summary>
        /// <param name="sender">Sender of the event.</param>
        /// <param name="e">ExceptionRoutedEventArgs associated with this event.</param>
        private void MediaFailed(object sender, ExceptionRoutedEventArgs e)
        {
            this.errorOccured = true;
            this.statusTextBlock.Text = string.Format(CultureInfo.InvariantCulture, "Error:  {0}", e.ErrorException.Message);
        }

        /// <summary>
        /// Event handler called when the play button is clicked.
        /// </summary>
        /// <param name="sender">Sender of the event.</param>
        /// <param name="e">RoutedEventArgs associated with this event.</param>
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Reliability", "CA2000:Dispose objects before losing scope", Justification = "This would need to be handled in a real application.")]
        private void PlayClick(object sender, RoutedEventArgs e)
        {
            this.ResetMediaPlayer();

            Uri uri = new Uri(this.mp3StreamRadioButton.IsChecked.Value ?
                "http://scfire-ntc-aa05.stream.aol.com:80/stream/1006" : // MP3
                "http://72.26.204.18:6116"); // AAC+
            this.source = new ShoutcastMediaStreamSource(uri);
            this.source.MetadataChanged += this.MetadataChanged;
            this.MediaPlayer.SetSource(this.source);
            this.MediaPlayer.Play();
        }

        /// <summary>
        /// Event handler called when the metadata of the Shoutcast stream source changes.
        /// </summary>
        /// <param name="sender">Sender of the event.</param>
        /// <param name="e">MpegMetadataEventArgs associated with this event.</param>
        private void MetadataChanged(object sender, RoutedEventArgs e)
        {
            this.UpdateStatus();
        }

        /// <summary>
        /// Updates the text block to show the MediaStreamSource's status in the UI.
        /// </summary>
        private void UpdateStatus()
        {
            // If we have an error, we don't want to overwrite the error status.
            if (this.errorOccured)
            {
                return;
            }

            MediaElementState state = this.MediaPlayer.CurrentState;
            string status = string.Empty;
            switch (state)
            {
                case MediaElementState.Buffering:
                    status = string.Format(CultureInfo.InvariantCulture, "Buffering...{0:0%}", this.MediaPlayer.BufferingProgress);
                    break;
                case MediaElementState.Playing:
                    status = string.Format(CultureInfo.InvariantCulture, "Title: {0}", this.source.CurrentMetadata.Title);
                    break;
                default:
                    status = state.ToString();
                    break;
            }

            this.statusTextBlock.Text = status;
        }

        /// <summary>
        /// Event handler called when the media element state changes.
        /// </summary>
        /// <param name="sender">Sender of the event.</param>
        /// <param name="e">RoutedEventArgs associated with this event.</param>
        private void CurrentStateChanged(object sender, RoutedEventArgs e)
        {
            this.UpdateStatus();
        }

        /// <summary>
        /// Resets the media player.
        /// </summary>
        private void ResetMediaPlayer()
        {
            if ((this.MediaPlayer.CurrentState != MediaElementState.Stopped) && (this.MediaPlayer.CurrentState != MediaElementState.Closed))
            {
                this.MediaPlayer.Stop();
                this.MediaPlayer.Source = null;
                this.source.Dispose();
                this.source = null;
            }

            this.errorOccured = false;
        }

        /// <summary>
        /// Event handler called when this page is unloaded.
        /// </summary>
        /// <param name="sender">Sender of the event.</param>
        /// <param name="e">RoutedEventArgs associated with this event.</param>
        private void PageUnloaded(object sender, RoutedEventArgs e)
        {
            this.ResetMediaPlayer();
        }
    }
}
