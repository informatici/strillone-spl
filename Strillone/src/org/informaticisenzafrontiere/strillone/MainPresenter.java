package org.informaticisenzafrontiere.strillone;

import java.util.HashMap;
import java.util.LinkedList;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import android.annotation.SuppressLint;
import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.SharedPreferences;
import android.util.Log;
import android.widget.EditText;

import org.informaticisenzafrontiere.strillone.http.GiornaleRequestHandler;
import org.informaticisenzafrontiere.strillone.http.RequestHandler;
import org.informaticisenzafrontiere.strillone.http.TestateRequestHandler;
import org.informaticisenzafrontiere.strillone.util.App;
import org.informaticisenzafrontiere.strillone.util.Configuration;
import org.informaticisenzafrontiere.strillone.xml.Giornale;
import org.informaticisenzafrontiere.strillone.xml.Testate;

public class MainPresenter {
	
	private final static String TAG = MainPresenter.class.getSimpleName();
	
	private IMainActivity mainActivity;
	private Map<String, Giornale> giornali;
	
	private AlertDialog.Builder dilogBuilder;
	
	public MainPresenter(IMainActivity mainActivity) {
		this.mainActivity = mainActivity;
		this.giornali = new HashMap<String, Giornale>();
	}
	
	public void downloadHeaders() {
		RequestHandler requestHandler = new TestateRequestHandler(this);
		requestHandler.handleRequest();
	}
	
	public void downloadGiornale() {
		//String urlTestata = this.mainActivity.getURLTestata();
		String urlTestata = this.mainActivity.getResourceTestata();
		
		// Find the file name.
		Pattern pattern = Pattern.compile("([^\\/]+)$");
		Matcher matcher = pattern.matcher(urlTestata);
		
		if (!matcher.find()) {
			this.mainActivity.notifyCommunicationError(App.getInstance().getString(R.string.connecting_error_reading_newspaper));
		} else {
			String filename = matcher.group(1);
			if (Configuration.DEBUGGABLE) Log.d(TAG, "filename" + filename);
			
			Giornale giornale;
			if ((giornale = this.giornali.get(filename)) == null) {
				RequestHandler requesthandler = new GiornaleRequestHandler(this, urlTestata, filename);
				requesthandler.handleRequest();
			} else {
				this.mainActivity.notifyGiornaleReceived(giornale);
			}
		}
		
	}
	
	public void notifyErrorDowloadingHeaders(String message) {
		this.mainActivity.notifyErrorDowloadingHeaders(message);
	}
	
	public void notifyCommunicationError(String message) {
		this.mainActivity.notifyCommunicationError(message);
	}
	
	public void notifyHeadersReceived(Testate testate) {
		this.mainActivity.notifyHeadersReceived(testate);
	}
	
	public void notifyGiornaleReceived(String filename, Giornale giornale) {
		this.giornali.put(filename, giornale);
		this.mainActivity.notifyGiornaleReceived(giornale);
	}
	
	public void switchBetaState() {
		Configuration.BETA = !Configuration.BETA;
		downloadHeaders();
	}
	
	public void setServerURL(final MainActivity m) {
		dilogBuilder=new AlertDialog.Builder(m);
		final EditText txtInput = new EditText(m);
		txtInput.setText(Configuration.URL );
		
		dilogBuilder.setTitle("URL del Server");
		dilogBuilder.setView(txtInput);
		dilogBuilder.setPositiveButton("Ok", new DialogInterface.OnClickListener() {
			
			@Override
			public void onClick(DialogInterface dialog, int which) {
				Configuration.URL=txtInput.getText().toString();
				downloadHeaders();
				SharedPreferences sharedPreferences =   m.getSharedPreferences("Miei Dati", Context.MODE_PRIVATE);
				SharedPreferences.Editor editor=sharedPreferences.edit();
				editor.putString("URLServer", Configuration.URL);
				editor.commit();
			}
		});
		dilogBuilder.setNegativeButton("Cancel",  new DialogInterface.OnClickListener() {
			
			@Override
			public void onClick(DialogInterface dialog, int which) {
							
			}
		});
		AlertDialog alertDialog= dilogBuilder.create();
		alertDialog.show();
		
	}
	
	@SuppressLint("DefaultLocale")
	public LinkedList<String> splitString(String s, int interval) {
		LinkedList<String> matchList = new LinkedList<String>();
		Pattern regex = Pattern.compile(String.format(".{1,%d}(?:\\s|$)", interval), Pattern.DOTALL);
		Matcher regexMatcher = regex.matcher(s);
		while (regexMatcher.find()) {
		    matchList.add(regexMatcher.group());
		}
		
		return matchList;
	}

}
