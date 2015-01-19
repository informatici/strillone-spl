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

namespace Shoutcast.Sample.Phone.Background
{
    using System;
    using System.Windows;
    using System.Windows.Threading;
    using Microsoft.Phone.BackgroundAudio;
    using Microsoft.Phone.Controls;
    using Microsoft.Phone.Shell;

    /// <summary>
    /// This class represents the main page of our Windows Phone application.
    /// </summary>
    [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Design", "CA1001:TypesThatOwnDisposableFieldsShouldBeDisposable", Justification = "When the page is unloaded, the ShoutcastMediaStreamSource is disposed.")]
    public partial class MainPage : PhoneApplicationPage
    {
        /// <summary>
        /// Index for the play button in the ApplicationBar.Buttons.
        /// </summary>
        private const int PlayButtonIndex = 0;

        /// <summary>
        /// Index for the pause button in the ApplicationBar.Buttons.
        /// </summary>
        private const int PauseButtonIndex = 1;

        /// <summary>
        /// Private field that stores the timer for updating the UI
        /// </summary>
        private DispatcherTimer timer;

        /// <summary>
        /// Initializes a new instance of the MainPage class.
        /// </summary>
        public MainPage()
        {
            InitializeComponent();
            Loaded += new RoutedEventHandler(this.MainPage_Loaded);
        }

        /// <summary>
        /// Method called when the main page is loaded.
        /// </summary>
        /// <param name="sender">Sender of the event.</param>
        /// <param name="e">The RoutedEventArgs instance associated with this event.</param>
        private void MainPage_Loaded(object sender, RoutedEventArgs e)
        {
            // Initialize a timer to update the UI every half-second.
            this.timer = new DispatcherTimer();
            this.timer.Interval = TimeSpan.FromSeconds(0.5);
            this.timer.Tick += new EventHandler(this.UpdateState);

            BackgroundAudioPlayer.Instance.PlayStateChanged += new EventHandler(this.Instance_PlayStateChanged);

            if (BackgroundAudioPlayer.Instance.PlayerState == PlayState.Playing)
            {
                // If audio was already playing when the app was launched, update the UI.
                // positionIndicator.IsIndeterminate = false;
                // positionIndicator.Maximum = BackgroundAudioPlayer.Instance.Track.Duration.TotalSeconds;
                this.UpdateButtons(false, true);
                this.UpdateState(null, null);
            }
        }

        /// <summary>
        /// PlayStateChanged event handler.
        /// </summary>
        /// <param name="sender">Sender of the event.</param>
        /// <param name="e">The EventArgs instance associated with this event.</param>
        private void Instance_PlayStateChanged(object sender, EventArgs e)
        {
            // This is wonky
            PlayState playState = PlayState.Unknown;
            try
            {
                playState = BackgroundAudioPlayer.Instance.PlayerState;
            }
            catch (InvalidOperationException)
            {
                playState = PlayState.Stopped;
            }

            switch (playState) 
            {
                case PlayState.Playing:
                    // Update the UI.
                    // positionIndicator.IsIndeterminate = false;
                    // positionIndicator.Maximum = BackgroundAudioPlayer.Instance.Track.Duration.TotalSeconds;
                    this.UpdateButtons(false, true);
                    this.UpdateState(null, null);

                    // Start the timer for updating the UI.
                    this.timer.Start();
                    break;

                case PlayState.Paused:
                    // Stop the timer for updating the UI.
                    this.timer.Stop();

                    // Update the UI.
                    this.UpdateButtons(true, false);
                    this.UpdateState(null, null);
                    break;
                case PlayState.Stopped:
                    // Stop the timer for updating the UI.
                    this.timer.Stop();

                    // Update the UI.
                    this.UpdateButtons(true, false);
                    this.UpdateState(null, null);
                    break;
                default:
                    break;
            }
        }

        /// <summary>
        /// Helper method to update the state of the ApplicationBar.Buttons
        /// </summary>
        /// <param name="playBtnEnabled">true if the Play button should be enabled, otherwise, false.</param>
        /// <param name="pauseBtnEnabled">true if the Pause button should be enabled, otherwise, false.</param>
        private void UpdateButtons(bool playBtnEnabled, bool pauseBtnEnabled)
        {
            // Set the IsEnabled state of the ApplicationBar.Buttons array
            ((ApplicationBarIconButton)ApplicationBar.Buttons[PlayButtonIndex]).IsEnabled = playBtnEnabled;
            ((ApplicationBarIconButton)ApplicationBar.Buttons[PauseButtonIndex]).IsEnabled = pauseBtnEnabled;
        }

        /// <summary>
        /// Updates the status indicators including the State, Track title, 
        /// </summary>
        /// <param name="sender">Sender of the event.</param>
        /// <param name="e">The EventArgs instance associated with this event.</param>
        private void UpdateState(object sender, EventArgs e)
        {
            txtState.Text = string.Format("State: {0}", BackgroundAudioPlayer.Instance.PlayerState);

            AudioTrack audioTrack = BackgroundAudioPlayer.Instance.Track;

            if (audioTrack != null)
            {
                txtTitle.Text = string.Format("Title: {0}", audioTrack.Title);
                txtArtist.Text = string.Format("Artist: {0}", audioTrack.Artist);

                // Set the current position on the ProgressBar.
                // positionIndicator.Value = BackgroundAudioPlayer.Instance.Position.TotalSeconds;

                // Update the current playback position.
                TimeSpan position = new TimeSpan();
                position = BackgroundAudioPlayer.Instance.Position;
                textPosition.Text = String.Format("{0:d2}:{1:d2}:{2:d2}", position.Hours, position.Minutes, position.Seconds);

                // Update the time remaining digits.
                // TimeSpan timeRemaining = new TimeSpan();
                // timeRemaining = audioTrack.Duration - position;
                // textRemaining.Text = String.Format("-{0:d2}:{1:d2}:{2:d2}", timeRemaining.Hours, timeRemaining.Minutes, timeRemaining.Seconds);
            }
        }

        /// <summary>
        /// Click handler for the Play button
        /// </summary>
        /// <param name="sender">Sender of the event.</param>
        /// <param name="e">The EventArgs instance associated with this event.</param>
        private void PlayButtonClick(object sender, EventArgs e)
        {
            // Tell the backgound audio agent to play the current track.
            BackgroundAudioPlayer.Instance.Track = new AudioTrack(null, "SKY.FM", null, null, null, "http://scfire-ntc-aa05.stream.aol.com:80/stream/1006", EnabledPlayerControls.Pause);
            BackgroundAudioPlayer.Instance.Volume = 1.0d;
        }

        /// <summary>
        /// Click handler for the Pause button
        /// </summary>
        /// <param name="sender">Sender of the event.</param>
        /// <param name="e">The EventArgs instance associated with this event.</param>
        private void PauseButtonClick(object sender, EventArgs e)
        {
            // Tell the backgound audio agent to pause the current track.
            // We need to stop the timer before anything
            this.timer.Stop();
            BackgroundAudioPlayer.Instance.Stop();
            this.UpdateState(null, null);
        }
    }
}