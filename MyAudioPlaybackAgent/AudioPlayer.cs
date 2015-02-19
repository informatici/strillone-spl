using System;
using System.Diagnostics;
using System.Windows;
using Microsoft.Phone.BackgroundAudio;

namespace MyAudioPlaybackAgent
{
    public class AudioPlayer : AudioPlayerAgent
    {
        /// <remarks>
        /// Le istanze di AudioPlayer possono condividere lo stesso processo.
        /// I campi statici possono essere utilizzati per condividere lo stato tra le istanze di AudioPlayer
        /// o per comunicare con l'agente di flusso audio.
        /// </remarks>
        static AudioPlayer()
        {
            // La sottoscrizione del gestore eccezioni gestite
            Deployment.Current.Dispatcher.BeginInvoke(delegate
            {
                Application.Current.UnhandledException += UnhandledException;
            });
        }

        /// Codice da eseguire in caso di eccezioni non gestite
        private static void UnhandledException(object sender, ApplicationUnhandledExceptionEventArgs e)
        {
            if (Debugger.IsAttached)
            {
                // Si è verificata un'eccezione non gestita; inserire un'interruzione nel debugger
                Debugger.Break();
            }
        }

        /// <summary>
        /// Chiamata eseguita quando cambia lo stato della riproduzione, eccetto che per lo stato di errore (vedere OnError)
        /// </summary>
        /// <param name="player">BackgroundAudioPlayer</param>
        /// <param name="track">La traccia riprodotta in corrispondenza del cambiamento di stato della riproduzione</param>
        /// <param name="playState">Il nuovo stato della riproduzione del lettore</param>
        /// <remarks>
        /// Impossibile annullare i cambiamenti di stato della riproduzione. I cambiamenti vengono generati anche se l'applicazione
        /// ha causato il cambiamento dello stato stesso, presupponendo che l'applicazione abbia acconsentito esplicitamente al callback.
        ///
        /// Eventi rilevanti dello stato della riproduzione:
        /// (a) TrackEnded: richiamato quando il lettore non contiene una traccia corrente. L'agente può impostare la traccia successiva.
        /// (b) TrackReady: è stata impostata una traccia audio, la quale è pronta per la riproduzione.
        ///
        /// Chiamare NotifyComplete() solo una volta, dopo il completamento della richiesta dell'agente, inclusi i callback asincroni.
        /// </remarks>
        protected override void OnPlayStateChanged(BackgroundAudioPlayer player, AudioTrack track, PlayState playState)
        {
            switch (playState)
            {
                case PlayState.TrackEnded:
                    player.Track = GetPreviousTrack();
                    break;
                case PlayState.TrackReady:
                    player.Play();
                    break;
                case PlayState.Shutdown:
                    // TODO: Gestire qui lo stato di arresto (ad esempio, salvare lo stato)
                    break;
                case PlayState.Unknown:
                    break;
                case PlayState.Stopped:
                    break;
                case PlayState.Paused:
                    break;
                case PlayState.Playing:
                    break;
                case PlayState.BufferingStarted:
                    break;
                case PlayState.BufferingStopped:
                    break;
                case PlayState.Rewinding:
                    break;
                case PlayState.FastForwarding:
                    break;
            }

            NotifyComplete();
        }

        /// <summary>
        /// Chiamata eseguita quando l'utente richiede un'azione tramite l'interfaccia utente fornita dall'applicazione o dal sistema
        /// </summary>
        /// <param name="player">BackgroundAudioPlayer</param>
        /// <param name="track">La traccia riprodotta in corrispondenza del cambiamento di stato della riproduzione</param>
        /// <param name="action">L'azione richiesta dall'utente</param>
        /// <param name="param">I dati associati all'azione richiesta.
        /// Nella versione corrente questo parametro può essere utilizzato solo con l'azione Seek,
        /// per indicare la posizione richiesta di una traccia audio</param>
        /// <remarks>
        /// Le azioni dell'utente non apportano automaticamente cambiamenti nello stato del sistema. L'agente è responsabile
        /// dell'esecuzione delle azioni dell'utente, se supportate.
        ///
        /// Chiamare NotifyComplete() solo una volta, dopo il completamento della richiesta dell'agente, inclusi i callback asincroni.
        /// </remarks>
        protected override void OnUserAction(BackgroundAudioPlayer player, AudioTrack track, UserAction action, object param)
        {
            switch (action)
            {
                case UserAction.Play:
                    if (player.PlayerState != PlayState.Playing)
                    {
                        try
                        {
                            player.Play();
                        }
                        catch 
                        {

                        }
                    }
                    break;
                case UserAction.Stop:
                     try
                        {
                    player.Stop();
                        }
                     catch
                     {

                     }
                    break;
                case UserAction.Pause:
                    player.Pause();
                    break;
                
            }

            NotifyComplete();
        }

        /// <summary>
        /// Implementa la logica necessaria per ottenere l'istanza di AudioTrack successiva.
        /// In una playlist l'origine può essere un file, una richiesta Web, ecc.
        /// </summary>
        /// <remarks>
        /// L'URI di AudioTrack determina l'origine, che può essere:
        /// (a) File di spazio di memorizzazione isolato (URI relativo, rappresenta il percorso nello spazio di memorizzazione isolato)
        /// (b) URL HTTP (URI assoluto)
        /// (c) MediaStreamSource (null)
        /// </remarks>
        /// <returns>istanza di AudioTrack o null se la riproduzione è stata completata</returns>
        private AudioTrack GetNextTrack()
        {
            // TODO: aggiungere la logica per ottenere la traccia audio successiva

            AudioTrack track = null;

            // specificare la traccia

            return track;
        }

        /// <summary>
        /// Implementa la logica necessaria per ottenere l'istanza di AudioTrack precedente.
        /// </summary>
        /// <remarks>
        /// L'URI di AudioTrack determina l'origine, che può essere:
        /// (a) File di spazio di memorizzazione isolato (URI relativo, rappresenta il percorso nello spazio di memorizzazione isolato)
        /// (b) URL HTTP (URI assoluto)
        /// (c) MediaStreamSource (null)
        /// </remarks>
        /// <returns>istanza di AudioTrack o null se la traccia precedente non è consentita</returns>
        private AudioTrack GetPreviousTrack()
        {
            // TODO: aggiungere la logica per ottenere la traccia audio precedente

            AudioTrack track = null;

            // specificare la traccia

            return track;
        }

        /// <summary>
        /// Chiamata eseguita quando si verifica un errore relativo alla riproduzione, ad esempio quando il download di AudioTrack non viene eseguito correttamente
        /// </summary>
        /// <param name="player">BackgroundAudioPlayer</param>
        /// <param name="track">La traccia che ha restituito l'errore</param>
        /// <param name="error">L'errore che si è verificato</param>
        /// <param name="isFatal">Se true, la riproduzione non può continuare e la riproduzione della traccia verrà interrotta</param>
        /// <remarks>
        /// Questo metodo non viene chiamato in tutti i casi. Ad esempio, se l'agente in background
        /// stesso rileva un'eccezione non gestita, non verrà richiamato per gestire i propri errori.
        /// </remarks>
        protected override void OnError(BackgroundAudioPlayer player, AudioTrack track, Exception error, bool isFatal)
        {
            if (isFatal)
            {
                Abort();
            }
            else
            {
                NotifyComplete();
            }

        }

        /// <summary>
        /// Chiamata eseguita quando la richiesta dell'agente viene annullata
        /// </summary>
        /// <remarks>
        /// Dopo l'annullamento della richiesta, l'agente impiega 5 secondi per completare l'operazione,
        /// chiamando NotifyComplete()/Abort().
        /// </remarks>
        protected override void OnCancel()
        {

        }
    }
}