package org.informaticisenzafrontiere.unileo4light.xml;

public class GiornaleXMLHandler extends XMLHandler {

	@Override
	protected Class<? extends XMLMessage> getXMLMessageClass() {
		return Giornale.class;
	}

}
