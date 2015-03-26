<?
$sUrl = 'http://www.go-bari.it/xmlArticoli.php';
$file_xml = file_get_contents($sUrl);

// VAI CON L'ALGORITMO!
$dom = new DOMDocument();
$dom->load($sUrl,LIBXML_DTDLOAD|LIBXML_DTDATTR);

/*create the xPath object _after_  loading the xml source, otherwise the query won't work:*/
$xPath = new DOMXPath($dom);

/*now get the nodes in a DOMNodeList:*/
$lingua = $xPath->query("//*[local-name() = 'lingua']");
$testata = $xPath->query("//*[local-name() = 'testata']");
$edizione = $xPath->query("//*[local-name() = 'edizione']");
$nodeList = $xPath->query("//*[local-name() = 'sezione']");

/*create a new DOMDocument and add a root element:*/
$newDom = new DOMDocument('1.0','UTF-8');
$newDom->formatOutput = true;
$newDom->preserveWhiteSpace = false ;
$root = $newDom->createElement('giornale');
$newLingua = $newDom->createElement('lingua', $lingua->item(0)->nodeValue);
$newTestata = $newDom->createElement('testata', $testata->item(0)->nodeValue);
$newEdizione = $newDom->createElement('edizione', $edizione->item(0)->nodeValue);
$root->appendChild($newLingua);
$root->appendChild($newTestata);
$root->appendChild($newEdizione);
$sections = array();

/* append all nodes from $nodeList to the new dom, as children of $root:*/
foreach ($nodeList as $domElement){
 	$figli = $domElement->childNodes ;
	foreach ($figli as $singleNode){
	if($singleNode->nodeType != 3){
		if($singleNode->nodeName == "nome"){
			if(!array_key_exists($singleNode->nodeValue, $sections)){
				$sections[$singleNode->nodeValue] = array();
			}
		 	$var = $singleNode->nextSibling->nextSibling;
			$tempArray = array();
			foreach($var->childNodes as $node)
			{
				if($node->nodeName=="titolo")
					$tempArray['titolo'] = $node->nodeValue;
				else if ($node->nodeName=="testo")
					$tempArray['testo'] =  $node->nodeValue;
			}
		$sections[$singleNode->nodeValue][]= $tempArray;
		}
	}
	}
}
foreach($sections as $key => $section ){
	$nodeSection = $newDom->createElement('sezione');
	$newDom->appendChild($nodeSection);
	$namenode = $newDom->createElement('nome', $key);
	$nodeSection->appendChild($namenode);
	foreach($section as $child){ 
		$articolo = $newDom->createElement('articolo');
		//$titolo = $newDom->createElement('titolo', $child['titolo']);
		//$testo = $newDom->createElement('testo', $child['testo']);
		$titolo = $newDom->createElement('titolo');
		$corpotitolo = $newDom->createCDATASection($child['titolo']);
		$testo = $newDom->createElement('testo');
		$corpotesto = $newDom->createCDATASection($child['testo']);
		$testo->appendChild($corpotesto);
		$titolo->appendChild($corpotitolo);
		$articolo->appendChild($titolo);
		$articolo->appendChild($testo);
		$nodeSection->appendChild($articolo);
	}	
	$root->appendChild($nodeSection);
}
$newDom->appendChild($root);
//$urlsave = './newDOM.xml';
//$newDom->saveXML();



header('Content-Type: text/xml; charset=UTF-8');
echo $newDom->saveXML();

?>