package org.informaticisenzafrontiere.unileo4light.xml;

public class TestateXMLHandler extends XMLHandler {

	@Override
	protected Class<? extends XMLMessage> getXMLMessageClass() {
		return Testate.class;
	}

}
