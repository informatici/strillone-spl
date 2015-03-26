var URLServer="http://localhost/strillonews"
var giornale = new Array();
var testata = new Array();

var tree_level = 'testata';
var testata_position = -1;
var sezione_position = -1;
var articolo_position = -1;

var	my_jPlayer;

var isCtrl = false;
var isAltGr = false;

$(window).keydown(function(event) {

	var keydowned;

	if (window.event) {
		keydowned = window.event.keyCode;
	} else if (event) {
		keydowned = event.which;
	}

	switch (keydowned) {
		case 17:
		isCtrl = true;
		break;

		case 18:
		isAltGr = true;
		break;

		default:
		break;
	}

});

$(window).keyup(function(event) {

	var keyupped;

	if (window.event) {
		keyupped = window.event.keyCode;
	} else if (event) {
		keyupped = event.which;
	}

	switch (keyupped) {
		case 17:
		isCtrl = false;
		break;

		case 18:
		isAltGr = false;
		break;

		default:
		break;
	}

});

$(document).ready(function() {

	$('#lower_right').focus();

	$(document).keypress(function(e) {

		var tasto = 0;
		if (e.which) {
			tasto = e.which;
		} else if (e.charCode) {
			tasto = e.charCode;
		}

		if (isAltGr) {
		}

		switch (tasto) {


			case 232:
			naviga('upper_left');
			break;

			case 43:
			naviga('upper_right');
			break;

			case 224:
			naviga('lower_left');
			break;

			case 249:
			naviga('lower_right');
			break;
			
			default:
			break;

		}

	});

	// Local copy of jQuery selectors, for performance.
	my_jPlayer = $("#jquery_jplayer");

	// Some options
	var	opt_play_first = false, // If true, will attempt to auto-play the default track on page loads. No effect on mobile devices, like iOS.
		opt_auto_play = true, // If true, when a track is selected, it will auto-play.
		opt_text_playing = "Now playing", // Text when playing
		opt_text_selected = "Track selected"; // Text when not playing

	// A flag to capture the first track
	var first_track = true;

	// Instance jPlayer
	my_jPlayer.jPlayer({
		swfPath: "./scripts/",
		cssSelectorAncestor: "#container",
		supplied: "mp3",
		solution:"flash,html",
		wmode: "window"
	});

	var screen_width = $(window).width();
	var screen_half_width = Math.floor(screen_width/2);

	var screen_height = $(window).height();
	var screen_half_height = Math.floor(screen_height/2);
	
	$('#container').width(screen_width).height(screen_height);
	$('#upper_left,#upper_right,#lower_left,#lower_right').width(screen_half_width).height(screen_half_height);
	
	$('.buttons').bind('click',function(e) {
		naviga(this.id);
	});
	
    jQuery.getTestata({
	//url: './newspapers',
        url: URLServer+'/newspapers',
        success: function(feed) {
			testata['testate'] = feed.testate;
        }
    });

});

function naviga(buttonid) {
var audio ;
	switch(buttonid) {
	
		case 'upper_left':
			audio = document.getElementById("a1");
			audio.pause();
			switch (tree_level) {
			
				case 'testata':
				tree_level = 'testata';
				testata_position = 0;
				sezione_position = -1;
				articolo_position = -1;
				blindnews_tts('Inizio navigazione');
				break;
				
				case 'sezione':
				tree_level = 'testata';
				testata_position = -1;
				sezione_position = -1;
				articolo_position = -1;
				blindnews_tts('Navigazione edizioni');
				break;

				case 'articolo':
				articolo_position = -1;
				tree_level = 'sezione';
				blindnews_tts('Navigazione sezioni');
				break;
			
			}
		break;
	
		case 'lower_left':
		audio = document.getElementById("a1");
		audio.pause();
		switch (tree_level) {
		
			case 'testata':
			if (testata['testate'].length > 0) {
				tree_level = 'sezione';
				sezione_position = -1;
				
				if (testata_position < 0) {
					testata_position = 0;
				}
				
				// http://www.bresciaonline.it/or4/or?uid=GDBcarta.main.view&edizione=2013-03-04&id=6TXUTR75

				jQuery.getGiornale({
					url: URLServer+'/newspapers/' + testata['testate'][testata_position]['resource'],
					success: function(feed) {
						giornale['edizione'] = feed.edizione;
						giornale['sezioni'] = feed.sezioni;
						for (i=0; i<giornale['sezioni'].length; i++) {
							giornale['sezioni'][i]['articoli'] = feed.sezioni[i].articoli;
						}
						
					}
				});
				
				blindnews_tts(testata['testate'][testata_position]['nome'] + ", pronta per la lettura");
			} else {
				blindnews_tts("Non ci sono edizioni disponibili.");
			}
			break;
		
			case 'sezione':
			if (giornale['sezioni'][sezione_position]['articoli'].length > 0) {
				tree_level = 'articolo';
				articolo_position = -1;
				blindnews_tts("Sei entrato nella sezione " + giornale['sezioni'][sezione_position]['nome']);
			} else {
				blindnews_tts("La sezione " + giornale['sezioni'][sezione_position]['nome'] + " non contiene articoli");
			}
			break;
			
			case 'articolo':
			if (testata['testate'][testata_position]['resource']=='radio') {
				try {
					var source= document.createElement('source');
					source.src= giornale['sezioni'][sezione_position]['articoli'][articolo_position]['testo'];
					source.autoplay='autoplay';
					audio = document.getElementById("a1");
					audio.replaceChild(source,audio.childNodes[0]);
					var source2= document.createElement('source');
					source2.src= giornale['sezioni'][sezione_position]['articoli'][articolo_position]['testo']+'/;stream.mp3';
					source2.autoplay='autoplay';
					audio.replaceChild(source2,audio.childNodes[1]);
					audio.load();
				}
				catch(err) { }
				
			}else
				blindnews_tts(giornale['sezioni'][sezione_position]['articoli'][articolo_position]['testo']);
			break;
		}
		break;
		
		case 'upper_right':
		audio = document.getElementById("a1");
		audio.pause();
		switch (tree_level) {
		
			case 'testata':
			testata_position--;
			articolo_position = 0;
			sezione_position = 0;
			if (testata_position < 0) {
				testata_position = 0;
			}
			blindnews_tts(testata['testate'][testata_position]['nome'] + ". Edizione del " + data_italiana(testata['testate'][testata_position]['edizione']));
			break;		
		
			case 'sezione':
			sezione_position--;
			articolo_position = 0;
			if (sezione_position < 0) {
				sezione_position = 0;
			}
			blindnews_tts(giornale['sezioni'][sezione_position]['nome']);
			break;
			
			case 'articolo':
			articolo_position--;
			if (articolo_position < 0) {
				articolo_position = 0;
			}
			blindnews_tts(giornale['sezioni'][sezione_position]['articoli'][articolo_position]['titolo']);
			break;

		}
		break;

		case 'lower_right':
		audio = document.getElementById("a1");
		audio.pause();
		switch (tree_level) {
		
			case 'testata':
			testata_position++;
			articolo_position = 0;
			sezione_position = 0;
			if (testata_position >= testata['testate'].length) {
				testata_position = testata['testate'].length-1;
			}
			blindnews_tts(testata['testate'][testata_position]['nome'] + ". Edizione del " + data_italiana(testata['testate'][testata_position]['edizione']));
			break;		
		
			case 'sezione':
			articolo_position = 0;
			sezione_position++;
			if (sezione_position >= giornale['sezioni'].length) {
				sezione_position = giornale['sezioni'].length-1;
			}
			blindnews_tts(giornale['sezioni'][sezione_position]['nome']);
			break;
			
			case 'articolo':
			articolo_position++;
			if (articolo_position >= giornale['sezioni'][sezione_position]['articoli'].length) {
				
				articolo_position = (giornale['sezioni'][sezione_position]['articoli'].length-1);
			}
			blindnews_tts(giornale['sezioni'][sezione_position]['articoli'][articolo_position]['titolo']);
			break;

		}
		break;

	}
}

function blindnews_tts(testo) {
 	$('#speech').val(testo);

	switch (ttse) {
	
		default:
		case 'festival':
		$.post('ajax_festival.php', $('#speechform').serialize(), function(msg) {
			my_jPlayer.jPlayer("setMedia", {
				mp3: "./audio/" + msg
			}).jPlayer("play");
		});
		break;
		
		case 'ivona':
		$.post('ajax_ivona.php', $('#speechform').serialize(), function(msg) {
			my_jPlayer.jPlayer("setMedia", {
				mp3: msg
			}).jPlayer("play");
		});
		break;

		case 'tingwo':
		$.post('ajax_tingwo.php', $('#speechform').serialize(), function(msg) {
			my_jPlayer.jPlayer("setMedia", {
				mp3: msg
			}).jPlayer("play");
		});
		break;

	}

	return false;
}

function data_italiana(data) {
	var datanuova = data.split('-');
	var month=new Array();
	month[0]="Gennaio";
	month[1]="Febbraio";
	month[2]="Marzo";
	month[3]="Aprile";
	month[4]="Maggio";
	month[5]="Giugno";
	month[6]="Luglio";
	month[7]="Agosto";
	month[8]="Settembre";
	month[9]="ottobre";
	month[10]="Novembre";
	month[11]="Dicembre";
	
	return datanuova[2] + " " + month[parseInt(datanuova[1])-1] + " " + datanuova[0];
}