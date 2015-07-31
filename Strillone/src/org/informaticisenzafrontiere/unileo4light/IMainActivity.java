package org.informaticisenzafrontiere.unileo4light;

import org.informaticisenzafrontiere.unileo4light.xml.Giornale;
import org.informaticisenzafrontiere.unileo4light.xml.Testate;

public interface IMainActivity {
	
	public void notifyHeadersReceived(Testate testate);
	
	public String getURLTestata();
	
	public void notifyGiornaleReceived(Giornale giornale);
	
	public void notifyCommunicationError(String message);
	
	public void notifyErrorDowloadingHeaders(String message);

}
