package org.informaticisenzafrontiere.strillone;

import java.io.IOException;
import java.net.MalformedURLException;
import java.net.URL;
import java.text.SimpleDateFormat;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.Locale;

import org.informaticisenzafrontiere.strillone.ui.StrilloneButton;
import org.informaticisenzafrontiere.strillone.ui.StrilloneProgressDialog;
import org.informaticisenzafrontiere.strillone.util.Configuration;
import org.informaticisenzafrontiere.strillone.xml.Articolo;
import org.informaticisenzafrontiere.strillone.xml.Giornale;
import org.informaticisenzafrontiere.strillone.xml.Sezione;
import org.informaticisenzafrontiere.strillone.xml.Testata;
import org.informaticisenzafrontiere.strillone.xml.Testate;

import android.media.AudioManager;
import android.media.MediaPlayer;
import android.media.ToneGenerator;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.os.PowerManager;
import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.ClipData.Item;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.res.AssetFileDescriptor;
import android.speech.tts.TextToSpeech;
import android.speech.tts.TextToSpeech.OnInitListener;
import android.speech.tts.TextToSpeech.OnUtteranceCompletedListener;
import android.util.Log;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.View;
import android.widget.LinearLayout;
import android.widget.Toast;

@SuppressLint("NewApi") public class MainActivity extends Activity implements IMainActivity, OnInitListener, OnUtteranceCompletedListener, Handler.Callback {
	
	private final static String TAG = MainActivity.class.getSimpleName();
	
	enum NavigationLevel {
		TESTATE, SEZIONI, ARTICOLI;
	}
	
	private MainPresenter mainPresenter;
	
	private TextToSpeech textToSpeech;
	private StrilloneButton upperLeftButton;
	private StrilloneButton upperRightButton;
	private StrilloneButton lowerLeftButton;
	private StrilloneButton lowerRightButton;
	private StrilloneProgressDialog progressDialog;
	private PowerManager.WakeLock wakeLock = null;
	private MediaPlayer mp;;
	
	private Testate testate;
	private Giornale giornale;
	
	private NavigationLevel navigationLevel;
	private int iTestata;
	private int iSezione;
	private int iArticolo;
	
	private int maxTestate;
	private int maxSezioni;
	private int maxArticoli;
	
	// Determines whether there is at the beginning of the navigation of newspapers.
	private boolean lowerEndTestate;
	
	// Determines whether there is at the end of the navigation of newspapers.
	private boolean upperEndTestate;
	
	private boolean lowerEndSezioni;
	private boolean upperEndSezioni;
	private boolean lowerEndArticoli;
	private boolean upperEndArticoli;
	private int i=0;
	private boolean option=false;
	
	private boolean reloadHeaders = false;
	
	private LinkedList<String> sentences;
	
	private SimpleDateFormat sdf = new SimpleDateFormat("EEEE dd MMMM yyyy", Locale.getDefault());

	public MainActivity() {
		this.mainPresenter = new MainPresenter(this);
	}
	
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        
        this.upperLeftButton = getUpperLeftButton();
        this.upperRightButton = getUpperRightButton();
        this.lowerLeftButton = getLowerLeftButton();
        this.lowerRightButton = getLowerRightButton();
        this.mp= new MediaPlayer();
        SharedPreferences sharedPreferences= getSharedPreferences("Miei Dati", Context.MODE_PRIVATE);
        Configuration.URL= sharedPreferences.getString("URLServer", Configuration.URL);
        
        this.upperLeftButton.setOnLongClickListener(new View.OnLongClickListener() {
			
			public boolean onLongClick(View v) {
				// If it is a text "splitted" because too long, 
				//empty your message queues so that the stop may not 
				//play the next message.
	    		if (MainActivity.this.sentences != null)
	    			MainActivity.this.sentences.clear();
				
				MainActivity.this.textToSpeech.stop();
				MainActivity.this.textToSpeech.speak(getResources().getString(R.string.nav_closing_app), TextToSpeech.QUEUE_FLUSH, null);
				
				Intent startMain = new Intent(Intent.ACTION_MAIN);
				startMain.addCategory(Intent.CATEGORY_HOME);
				startMain.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
				startActivity(startMain);
				
				return true;
			}
		});
        
        this.lowerLeftButton.setOnLongClickListener(new View.OnLongClickListener() {
			@Override
			public boolean onLongClick(View v) {
				// If it is a text "splitted" because too long, 
				//empty your message queues so that the stop may not 
				//play the next message.
	    		if (MainActivity.this.sentences != null)
	    			MainActivity.this.sentences.clear();
				
				MainActivity.this.textToSpeech.stop();
				MainActivity.this.textToSpeech.speak(getResources().getString(R.string.help_text), TextToSpeech.QUEUE_FLUSH, null);
				
				return true;
			}
		});
        
        this.upperRightButton.setOnLongClickListener(new View.OnLongClickListener() {
			
			@Override
			public boolean onLongClick(View v) {
				// If it is a text "splitted" because too long, 
				//empty your message queues so that the stop may not 
				//play the next message.
	    		if (MainActivity.this.sentences != null)
	    			MainActivity.this.sentences.clear();
				
				MainActivity.this.textToSpeech.stop();
				
				// Calculates the position.
				StringBuffer sbPosizione = new StringBuffer(getString(R.string.pos_current));
				if (iTestata < 0) {
					// Is not selected any newspaper.
					sbPosizione.append(getString(R.string.pos_no_header_selected));
				} else {
					Testata testata = MainActivity.this.testate.getTestate().get(iTestata);
					
					sbPosizione.append(testata.getNome());
					sbPosizione.append(", ");
					sbPosizione.append(sdf.format(testata.getEdizione()));
					sbPosizione.append(". ");
					
					if (iSezione < 0) {
						// Is not selected any section.
						sbPosizione.append(getString(R.string.pos_no_section_selected));
					} else {
						Sezione sezione = MainActivity.this.giornale.getSezioni().get(iSezione);
						sbPosizione.append(String.format(getString(R.string.pos_section_selected), sezione.getNome()));
						
						if (iArticolo < 0) {
							sbPosizione.append(getString(R.string.pos_no_article_selected));
						} else {
							Articolo articolo = sezione.getArticoli().get(iArticolo);
							sbPosizione.append(String.format(getString(R.string.pos_article_selected), articolo.getTitolo()));
						}
					}
				}
				
				MainActivity.this.textToSpeech.speak(sbPosizione.toString(), TextToSpeech.QUEUE_FLUSH, null);
				
				return true;
			}
		});
        
        PowerManager pm = (PowerManager)getSystemService(Context.POWER_SERVICE);
		this.wakeLock = pm.newWakeLock(PowerManager.SCREEN_DIM_WAKE_LOCK, TAG);
        
        this.textToSpeech = new TextToSpeech(this, this);
        this.textToSpeech.setOnUtteranceCompletedListener(this);
    }

	@Override
	protected void onResume() {
		super.onResume();
		this.wakeLock.acquire();
	}
	
	@Override
	protected void onPause() {
		if (Configuration.DEBUGGABLE) Log.d(TAG, "onPause()");
		
		// If you are reading an article flushes the buffer of the phrases and stops the TTS.
		if (this.sentences != null) {
			this.sentences.clear();
		}
		this.textToSpeech.stop();
		
		// Release control on standby.
		this.wakeLock.release();
		super.onPause();
	}

	@Override
	protected void onDestroy() {
		if (Configuration.DEBUGGABLE) Log.d(TAG, "onDestroy()");
		this.textToSpeech.shutdown();
		super.onDestroy();
	}

	@Override
	public void onWindowFocusChanged(boolean hasFocus) {
		super.onWindowFocusChanged(hasFocus);
		
		if (hasFocus) {
			LinearLayout containerLinearLayout = (LinearLayout)findViewById(R.id.containerLinearLayout);
			int height = containerLinearLayout.getHeight();
			
	        LinearLayout firstRowButtonsLinearLayout = (LinearLayout)findViewById(R.id.firstRowButtonsLinearLayout);
	        LinearLayout secondRowButtonsLinearLayout = (LinearLayout)findViewById(R.id.secondRowButtonsLinearLayout);
	        
	        LinearLayout.LayoutParams firstRowButtonsLayoutParams = new LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT, height / 2);
	        LinearLayout.LayoutParams secondRowButtonsLayoutParams = new LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT, height / 2);
	        
	        firstRowButtonsLinearLayout.setLayoutParams(firstRowButtonsLayoutParams);
	        secondRowButtonsLinearLayout.setLayoutParams(secondRowButtonsLayoutParams);
		}
	}

	@Override
	public boolean onCreateOptionsMenu(Menu menu) {
				super.onCreateOptionsMenu(menu);
	    MenuInflater inflater = getMenuInflater();
	    inflater.inflate(R.menu.main, menu);

	    return option;
	}
	
	@Override
	public boolean onOptionsItemSelected(MenuItem item) {
	    switch (item.getItemId()) {
	      /*  case R.id.beta:
	        	startProgressDialog(getString(R.string.connecting_headers));
	            this.mainPresenter.switchBetaState();
	            return true;
	      */      
	        case R.id.settings:
	        	 this.mainPresenter.setServerURL(this);
	        	 return true;
	        default:
	            return super.onOptionsItemSelected(item);
	    }
	}
	
//    @Override
//	public boolean dispatchPopulateAccessibilityEvent(AccessibilityEvent event) {
//		return true;
//	}

	public void performUpperLeftAction(View v) {
		
		if(!mp.isPlaying()){
	    	if (this.textToSpeech.isSpeaking()) {
	    		// If it is a text "splitted" because too long, 
				//empty your message queues so that the stop may not 
				//play the next message.
	    		if (this.sentences != null)
	    			this.sentences.clear();
	    		
	    		this.textToSpeech.stop();
	    	} else {
	    		if (reloadHeaders) {
	    			startProgressDialog(getString(R.string.connecting_headers));
	    	        this.mainPresenter.downloadHeaders();
	    		} else {
		    		switch (this.navigationLevel) {
						case TESTATE:
							resetNavigation();
				    		this.textToSpeech.speak(getResources().getString(R.string.nav_home), TextToSpeech.QUEUE_FLUSH, null);
							break;
						case SEZIONI:
							// Skip to navigation of newspapers.
							this.navigationLevel = NavigationLevel.TESTATE;
							this.iSezione = -1;
							this.textToSpeech.speak(getResources().getString(R.string.nav_go_testate), TextToSpeech.QUEUE_FLUSH, null);
							break;
						case ARTICOLI:
							// Skip to navigation sections.
							this.navigationLevel = NavigationLevel.SEZIONI;
							this.iArticolo = -1;
							this.textToSpeech.speak(getResources().getString(R.string.nav_go_sezioni), TextToSpeech.QUEUE_FLUSH, null);
							break;
						default:
							break;
					}
	    		}
	    		
	    	}
		}else
			mp.stop();
		
    }
    
    public void performLowerLeftAction(View v) {
    	mp.stop();
    	switch (this.navigationLevel) {
			case TESTATE:
				if (this.iTestata >= 0) {
					//Select your newspaper.
					//startProgressDialog(String.format(getString(R.string.connecting_newspaper), this.testate.getTestate().get(this.iTestata).getNome()));
					this.mainPresenter.downloadGiornale();
					
					this.lowerEndSezioni = true;
					this.upperEndSezioni = false;
				}
				break;
			case SEZIONI:
				if (this.iSezione >= 0) {
		    		// Enter the section.
		    		Sezione sezione = this.giornale.getSezioni().get(iSezione);
		    		this.maxArticoli = sezione.getArticoli().size();
		    		
		    		this.lowerEndArticoli = true;
		    		this.upperEndArticoli = false;
		    		
		    		StringBuilder sbMessaggio = new StringBuilder();
		    		sbMessaggio.append(getResources().getString(R.string.nav_enter_section));
		    		sbMessaggio.append(sezione.getNome());
		    		this.navigationLevel = NavigationLevel.ARTICOLI;
		    		this.textToSpeech.speak(sbMessaggio.toString(), TextToSpeech.QUEUE_FLUSH, null);
	    		}
				break;
			case ARTICOLI:
				if (this.iArticolo >= 0) {
		    		//Read the article.
		    		Sezione sezione = this.giornale.getSezioni().get(iSezione);
		    		Articolo articolo = sezione.getArticoli().get(iArticolo);
		    		
		    		if (articolo.getTesto().length() <= Configuration.SENTENCE_MAX_LENGTH) {
		    			//If the article belongs to the head of the radio, play
		    			if(this.giornale.getTestata().compareTo("Radio Online")==0){
		    				try {
		    					URL url = new URL(articolo.getTesto());
		    					this.textToSpeech.speak(getResources().getString(R.string.buffering), TextToSpeech.QUEUE_FLUSH, null);
		    					mp = new MediaPlayer();
		    					mp.setDataSource(articolo.getTesto());
		    					mp.prepare();
		    					mp.start();
		    				} catch (Exception e) {
		    					this.textToSpeech.speak(getResources().getString(R.string.connecting_error), TextToSpeech.QUEUE_FLUSH, null);
		    				}
		    			}else
		    				this.textToSpeech.speak(articolo.getTesto(), TextToSpeech.QUEUE_FLUSH, null);
		    		} else {
		    			if (Configuration.DEBUGGABLE) Log.d(TAG, "Testo troppo lungo, splitting...");
		    			this.sentences = this.mainPresenter.splitString(articolo.getTesto(), Configuration.SENTENCE_MAX_LENGTH);
		    			int i = this.sentences.size();
		    			if (Configuration.DEBUGGABLE) {
		    				for (int j = 0; j < i; j++) {
		    					Log.d(TAG, "frase " + (j + 1) + ": " + sentences.get(j));
		    				}
		    			}
		    			playNextSentence();
		    		}
	    		}
				break;
			default:
				break;
		}
    }
    
    public void performUpperRightAction(View v) {
    	mp.stop();
    	switch (this.navigationLevel) {
			case TESTATE:
				if (this.lowerEndTestate) {
					if (this.iTestata >= 0) {
						// 
						this.textToSpeech.speak(getString(R.string.nav_first_header), TextToSpeech.QUEUE_FLUSH, null);
					} else {
						// If the app just started or reset.
						this.textToSpeech.speak(getString(R.string.nav_use_lower_button_start_navigation_headers), TextToSpeech.QUEUE_FLUSH, null);
					}
				} else {
					if (!this.upperEndTestate) {
						if (this.iTestata > 0) {
							this.iTestata--;
						}
						
						if (this.iTestata == 0) {
							this.lowerEndTestate = true;
						}
					}
					
					if (this.iTestata >= 0) {
						Testata testata = this.testate.getTestate().get(iTestata);
						
						StringBuilder sb = new StringBuilder();
						sb.append(testata.getNome());
						sb.append(", ");
						sb.append(sdf.format(testata.getEdizione()));
						
						this.textToSpeech.speak(sb.toString(), TextToSpeech.QUEUE_FLUSH, null);
					}
					
					this.upperEndTestate = false;
				}
				
				break;
			case SEZIONI:
				if (this.lowerEndSezioni) {
					if (this.iSezione >= 0) {
						this.textToSpeech.speak(getString(R.string.nav_first_sezione), TextToSpeech.QUEUE_FLUSH, null);
					} else {
						this.textToSpeech.speak(getString(R.string.nav_use_lower_button_start_navigation_sezioni), TextToSpeech.QUEUE_FLUSH, null);
					}
				} else {
					if (!this.upperEndSezioni) {
						if (this.iSezione > 0) {
							this.iSezione--;
						}
						
						if (this.iSezione == 0) {
							this.lowerEndSezioni = true;
						}
					}
					
					if (this.iSezione >= 0) {
		    			Sezione sezione = this.giornale.getSezioni().get(iSezione);
		    			this.textToSpeech.speak(sezione.getNome(), TextToSpeech.QUEUE_FLUSH, null);
		    		}
		    		
		    		this.upperEndSezioni = false;
				}    		
	    		
				break;
			case ARTICOLI:
				if (this.lowerEndArticoli) {
					if (this.iArticolo >= 0) {
						this.textToSpeech.speak(getString(R.string.nav_first_articolo), TextToSpeech.QUEUE_FLUSH, null);
					} else {
						this.textToSpeech.speak(getString(R.string.nav_use_lower_button_start_navigation_articoli), TextToSpeech.QUEUE_FLUSH, null);
					}
				} else {
					if (!this.upperEndArticoli) {
						if (this.iArticolo > 0) {
			    			this.iArticolo--;
			    		}
						
						if (this.iArticolo == 0) {
		    				this.lowerEndArticoli = true;
		    			}
					}
					
					if (this.iArticolo >= 0) {
			    		Sezione sezione = this.giornale.getSezioni().get(iSezione);
			    		Articolo articolo = sezione.getArticoli().get(iArticolo);
			    		this.textToSpeech.speak(articolo.getTitolo(), TextToSpeech.QUEUE_FLUSH, null);
		    		}
		    		
		    		this.upperEndArticoli = false;
				}

				break;
			default:
				break;
		}
    	
    }
    
    public void performLowerRightAction(View v) {
    	mp.stop();
    	switch (this.navigationLevel) {
			case TESTATE:
				if (this.upperEndTestate) {
					this.textToSpeech.speak(getString(R.string.nav_last_header), TextToSpeech.QUEUE_FLUSH, null);
				} else {
					if (!lowerEndTestate || this.iTestata < 0) {
						if (this.iTestata < this.maxTestate - 1) {
							this.iTestata++;
						}
						if (this.iTestata == this.maxTestate - 1) {
							this.upperEndTestate = true;
						}
					}
					
					Testata testata = this.testate.getTestate().get(iTestata);
					
					StringBuilder sb = new StringBuilder();
					sb.append(testata.getNome());
					sb.append(", ");
					sb.append(sdf.format(testata.getEdizione()));
					
					this.textToSpeech.speak(sb.toString(), TextToSpeech.QUEUE_FLUSH, null);
					
					this.lowerEndTestate = false;
				}
				
				break;
			case SEZIONI: {
					if (this.upperEndSezioni) {
						this.textToSpeech.speak(getString(R.string.nav_last_sezione), TextToSpeech.QUEUE_FLUSH, null);
					} else {
						if (!lowerEndSezioni || this.iSezione < 0) {
							if (this.iSezione < this.maxSezioni - 1) {
				    			this.iSezione++;
				    		}
							if (this.iSezione == this.maxSezioni - 1) {
								this.upperEndSezioni = true;
							}
						}
			    		
			    		Sezione sezione = this.giornale.getSezioni().get(iSezione);
			    		this.textToSpeech.speak(sezione.getNome(), TextToSpeech.QUEUE_FLUSH, null);
			    		
			    		this.lowerEndSezioni = false;
					}
					
				}
				break;
			case ARTICOLI: {
					if (this.upperEndArticoli) {
						this.textToSpeech.speak(getString(R.string.nav_last_articolo), TextToSpeech.QUEUE_FLUSH, null);
					} else {
						Sezione sezione = this.giornale.getSezioni().get(iSezione);
						if (!lowerEndArticoli || this.iArticolo < 0) {
				    		int maxArticoli = sezione.getArticoli().size();
				    		
				    		if (this.iArticolo < maxArticoli - 1) {
				    			this.iArticolo++;
				    		}
				    		
				    		if (this.iArticolo == maxArticoli - 1) {
				    			this.upperEndArticoli = true;
				    		}
						}
						
						Articolo articolo = sezione.getArticoli().get(iArticolo);
			    		this.textToSpeech.speak(articolo.getTitolo(), TextToSpeech.QUEUE_FLUSH, null);
			    		
			    		this.lowerEndArticoli = false;
					}	
				}
				
				break;
			default:
				break;
    	}
    	
    }

    public void performSecretButton(View v) {
    	int numeroTap=Configuration.NUMBER_MULTI_TAP;
    	i++;
        Handler handler = new Handler();
        Runnable r = new Runnable() {

            @Override
            public void run() {
                i = 0;
            }
        };

        if (i < 5) {
            //Single click
            handler.postDelayed(r, 250*numeroTap);
        } else if (i == numeroTap) {
            //Double click
            i = 0;
            option=!option;
            this.invalidateOptionsMenu();
            final ToneGenerator tg = new ToneGenerator(AudioManager.STREAM_NOTIFICATION, 80);
            tg.startTone(ToneGenerator.TONE_CDMA_ABBR_INTERCEPT);
        }

    	
    	
    	
    }
    @Override
	public void onInit(int status) {
		if (status == TextToSpeech.SUCCESS) {
			startProgressDialog(getString(R.string.connecting_headers));
	        this.mainPresenter.downloadHeaders();
		} else {
			Toast.makeText(this, R.string.init_ko, Toast.LENGTH_SHORT).show();
			
			ToneGenerator toneGenerator = new ToneGenerator(AudioManager.STREAM_NOTIFICATION, 100);
	        toneGenerator.startTone(ToneGenerator.TONE_PROP_NACK);
		}
	}
    
	
	@Override
	public void onUtteranceCompleted(String utteranceId) {
		playNextSentence();
	}
	
	private void playNextSentence() {
		HashMap<String, String> params = new HashMap<String, String>();
		params.put(TextToSpeech.Engine.KEY_PARAM_UTTERANCE_ID, String.valueOf(sentences.size()));
		this.textToSpeech.speak(sentences.poll(), TextToSpeech.QUEUE_FLUSH, params);
	}

	@Override
	public void notifyCommunicationError(String message) {
		dismissProgressDialog();
		this.textToSpeech.speak(message, TextToSpeech.QUEUE_FLUSH, null);
	}
	
	@Override
	public void notifyErrorDowloadingHeaders(String message) {
		dismissProgressDialog();
		this.textToSpeech.speak(message, TextToSpeech.QUEUE_FLUSH, null);
		this.reloadHeaders = true;
		this.upperLeftButton.setClickable(true);
	}
	
	@Override
	public void notifyHeadersReceived(Testate testate) {
		dismissProgressDialog();
		
		this.reloadHeaders = false;
		this.testate = testate;
		this.maxTestate = testate.getTestate().size();
		this.lowerEndTestate = true;
		this.upperEndTestate = false;
		
		resetNavigation();
		
		// View buttons.
		this.upperLeftButton.setVisibility(View.VISIBLE);
        this.upperRightButton.setVisibility(View.VISIBLE);
        this.lowerLeftButton.setVisibility(View.VISIBLE);
        this.lowerRightButton.setVisibility(View.VISIBLE);
		
		// Enable buttons to touch.
		this.upperLeftButton.setClickable(true);
        this.upperRightButton.setClickable(true);
        this.lowerLeftButton.setClickable(true);
        this.lowerRightButton.setClickable(true);
        
        Toast.makeText(this, R.string.init_ok, Toast.LENGTH_SHORT).show();
        
//        ToneGenerator toneGenerator = new ToneGenerator(AudioManager.STREAM_NOTIFICATION, 100);
//        toneGenerator.startTone(ToneGenerator.TONE_PROP_BEEP);
        try {
        	AssetFileDescriptor descriptor = getAssets().openFd("jingle.mp3");
        	
	        MediaPlayer mediaPlayer = new MediaPlayer();
	        mediaPlayer.setDataSource(descriptor.getFileDescriptor(), descriptor.getStartOffset(), descriptor.getLength());
	        mediaPlayer.prepare();
	        mediaPlayer.start();
        } catch (IOException e) {
        	if (Configuration.DEBUGGABLE) Log.d(TAG, "Eccezione nella riproduzione del jingle.", e);
        }
	}
	
	@Override
	public String getURLTestata() {
		Testata testata = (Testata)this.testate.getTestate().get(iTestata);
		return testata.getUrl();
	}
	
	@Override
	public String getResourceTestata() {
		Testata testata = (Testata)this.testate.getTestate().get(iTestata);
		return testata.getResource();
	}
	
	@Override
	public void notifyGiornaleReceived(Giornale giornale) {
		if (Configuration.DEBUGGABLE) Log.d(TAG, "notifyGiornaleReceived()");
		dismissProgressDialog();
		
		this.navigationLevel = NavigationLevel.SEZIONI;
		this.iSezione = -1;
		this.iArticolo = -1;
		this.maxSezioni = giornale.getSezioni().size();
		
		StringBuilder sb = new StringBuilder();
		sb.append(giornale.getTestata());
		sb.append(getString(R.string.nav_read_success));
		if (Configuration.DEBUGGABLE) Log.d(TAG, "sb: " + sb);
		
		this.giornale = giornale;
		this.textToSpeech.speak(sb.toString(), TextToSpeech.QUEUE_FLUSH, null);
	}
	
	private void resetNavigation() {
		// Initializes the navigation level.
		this.navigationLevel = NavigationLevel.TESTATE;
				
		// Sets the indices to start navigation.
		this.iTestata = -1;
    	this.iSezione = -1;
    	this.iArticolo = -1;
    	
    	this.lowerEndTestate = true;
    	this.upperEndTestate = false;
    	this.lowerEndSezioni = true;
    	this.upperEndSezioni = false;
    	this.lowerEndArticoli = true;
    	this.upperEndArticoli = false;
	}
	
	private StrilloneButton getUpperLeftButton() {
		return (StrilloneButton)findViewById(R.id.upperLeftButton);
	}
	
	private StrilloneButton getUpperRightButton() {
		return (StrilloneButton)findViewById(R.id.upperRightButton);
	}
	
	private StrilloneButton getLowerLeftButton() {
		return (StrilloneButton)findViewById(R.id.lowerLeftButton);
	}
	
	private StrilloneButton getLowerRightButton() {
		return (StrilloneButton)findViewById(R.id.lowerRightButton);
	}
	
	private void startProgressDialog(String message) {
		progressDialog = new StrilloneProgressDialog(this);
		progressDialog.setProgressStyle(StrilloneProgressDialog.STYLE_SPINNER);
		progressDialog.setMessage(message);
		progressDialog.setCancelable(false);
		progressDialog.show();
	}

	private void dismissProgressDialog() {
		if (progressDialog != null) {
			progressDialog.dismiss();
		}
	}
	
	private void playTone() {
		ToneGenerator toneGenerator = new ToneGenerator(AudioManager.STREAM_NOTIFICATION, 100);
        toneGenerator.startTone(ToneGenerator.TONE_PROP_BEEP);
	}

	@Override
	public boolean handleMessage(Message msg) {
		return false;
	}
	
}

