package org.informaticisenzafrontiere.unileo4light.xml;

import java.util.List;

import org.simpleframework.xml.ElementList;
import org.simpleframework.xml.Root;

@Root(name="testate")
public class Testate extends XMLMessage {

	@ElementList(name="testata", type=Testata.class, inline=true)
	private List<Testata> testate;
	
	public Testate() { }

	public List<Testata> getTestate() {
		return testate;
	}

	public void setTestate(List<Testata> testate) {
		this.testate = testate;
	}
	
}
