<?php

/*
	Copyright© 2012,2013 Informatici Senza Frontiere Onlus
	http://www.informaticisenzafrontiere.org

    This file is part of Strillone - spoken news for visually impaired people.

    Strillone is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    Strillone is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with Strillone.  If not, see <http://www.gnu.org/licenses/>.
*/

$item = array();

$item[0]['lingua'] = 'it';
$item[0]['nome'] = 'repubblica punto it';
$item[0]['input_file'] = 'http://www.walks.to/strillone/feeds/repubblicait.xml';
$item[0]['output_file'] = 'repubblicait';
$item[0]['reorder'] = false;
$item[0]['asis'] = true;
$item[0]['beta'] = true;

$item[1]['lingua'] = 'it';
$item[1]['nome'] = 'go bari';
$item[1]['input_file'] = 'http://www.go-bari.it/xmlArticoli.php';
$item[1]['output_file'] = 'go_bari';
$item[1]['reorder'] = true;
$item[1]['asis'] = false;
$item[1]['beta'] = false;

$item[2]['lingua'] = 'it';
$item[2]['nome'] = 'go fasano';
$item[2]['input_file'] = 'http://gofasano.it/xmlArticoli.php';
$item[2]['output_file'] = 'go_fasano';
$item[2]['reorder'] = true;
$item[2]['asis'] = false;
$item[2]['beta'] = false;

$item[3]['lingua'] = 'it';
$item[3]['nome'] = 'favole e racconti';
$item[3]['input_file'] = 'http://www.walks.to/strillone/feeds/favole_racconti.xml';
$item[3]['output_file'] = 'favole_racconti';
$item[3]['reorder'] = false;
$item[3]['asis'] = true;
$item[3]['beta'] = false;

$item[4]['lingua'] = 'it';
$item[4]['nome'] = 'onu organizzazione delle nazioni unite';
$item[4]['input_file'] = 'http://www.walks.to/strillone/feeds/dudu_onu.xml';
$item[4]['output_file'] = 'dudu_onu';
$item[4]['reorder'] = false;
$item[4]['asis'] = true;
$item[4]['beta'] = false;

$item[5]['lingua'] = 'en';
$item[5]['nome'] = 'test inglese';
$item[5]['input_file'] = 'http://www.walks.to/strillone/feeds/test_inglese.xml';
$item[5]['output_file'] = 'test_inglese';
$item[5]['reorder'] = false;
$item[5]['asis'] = true;
$item[5]['beta'] = false;

$item[6]['lingua'] = 'pt';
$item[6]['nome'] = 'test portoghese';
$item[6]['input_file'] = 'http://www.walks.to/strillone/feeds/test_portoghese.xml';
$item[6]['output_file'] = 'test_portoghese';
$item[6]['reorder'] = false;
$item[6]['asis'] = true;
$item[6]['beta'] = false;

$today = date("Y-m-d");

$w = 'testate';

if (isset($_SERVER['argc'])) {
	$arguments = getopt('w:');
}

if (
(isset($_GET['w']) && ($_GET['w'] != '') && ($_GET['w'] == 'testate'))
||
(isset($arguments['w']) && ($arguments['w'] != '') && ($arguments['w'] == 'testate'))
) {

// XML FILE FOR ANDROID SYSTEMS
$file_xml_content = "<?xml version='1.0' encoding='ISO-8859-1'?>
<testate>\r\n\r\n";

for ($i = 0; $i<count($item); $i++) {

	$beta = '';
	if ($item[$i]['beta']) {
		$beta = "<beta>true</beta>";
	}

	$file_xml_content .= "	<testata>
		<lingua>" . $item[$i]['lingua'] . "</lingua>
		<nome>" . $item[$i]['nome'] . "</nome>
		<edizione>" . $today . "</edizione>
		<url>http://www.walks.to/strillone/feeds/" . $item[$i]['output_file'] . ".xml</url>"
		. $beta . 		
	"</testata>\r\n\r\n";

}
	
$file_xml_content .= "</testate>";

$file_xml = './feeds/testate.xml';

$pointer_file_xml = fopen(($file_xml),'w') or die("can't open file");

fwrite($pointer_file_xml, $file_xml_content);
fclose($pointer_file_xml);

// JSON FILE FOR ANDROID SYSTEMS
$file_json_content = '{"testate":{"testata":[';

for ($i = 0; $i<count($item); $i++) {

	$beta = '';
	if ($beta) {
		$beta = ',"beta":"true"';
	}

$file_json_content .= 
'{"lingua":"' . $item[$i]['lingua'] . '","nome":"' . $item[$i]['nome'] . '","edizione":"' . $today . '","url":"http://www.walks.to/strillone/feeds/' . $item[$i]['output_file'] . '.json"' . $beta . '}';

	if ($i<(count($item)-1)) {
		$file_json_content .= ',';
	}

}
	
$file_json_content .= ']}}';

$file_json = './feeds/testate.json';

$pointer_file_json = fopen(($file_json),'w') or die("can't open file");

fwrite($pointer_file_json, $file_json_content);
fclose($pointer_file_json);

}

if (
(isset($_GET['w']) && ($_GET['w'] != '') && ($_GET['w'] == 'edizioni'))
||
(isset($arguments['w']) && ($arguments['w'] != '') && ($arguments['w'] == 'edizioni'))
) {

for ($i = 0; $i<count($item); $i++) {

	$file_output_content = '';

	if (!$item[$i]['asis']) {

		// applico alcune trasformazioni affinché il file sia letto bene da tutti i sistemi

		$wrongs = array();
		$rights = array();

		$wrongs[] = 'version="1.0"?'; 	$rights[] = 'version="1.0" encoding="iso-8859-1"?';
		$wrongs[] = '&nbsp;'; 			$rights[] = ' ';
		$wrongs[] = '\r\n\r\n'; 		$rights[] = '\r\n';

		$wrongs[] = '&ldquo;'; 			$rights[] = '"';
		$wrongs[] = '&rdquo;'; 			$rights[] = '"';
		$wrongs[] = '&rsquo;'; 			$rights[] = '\'';
		$wrongs[] = '&lsquo;'; 			$rights[] = '\'';
		$wrongs[] = '&raquo;'; 			$rights[] = '"';
		$wrongs[] = '&laquo;'; 			$rights[] = '"';

		$wrongs[] = '&deg;'; 			$rights[] = '°';
		$wrongs[] = '&ndash;'; 			$rights[] = '-';
		$wrongs[] = '<nome>'; 			$rights[] = '<nome><![CDATA[';
		$wrongs[] = '</nome>'; 			$rights[] = ']]></nome>';

		$wrongs[] = '&agrave;'; 		$rights[] = 'à';
		$wrongs[] = '&eacute;'; 		$rights[] = 'é';
		$wrongs[] = '&egrave;'; 		$rights[] = 'è';
		$wrongs[] = '&Egrave;'; 		$rights[] = 'É';
		$wrongs[] = '&igrave;'; 		$rights[] = 'ì';
		$wrongs[] = '&ograve;'; 		$rights[] = 'ò';
		$wrongs[] = '&ugrave;'; 		$rights[] = 'ù';

		$wrongs[] = '…'; 				$rights[] = '...';

		$wrongs[] = '(function(d, s, id) { var js, fjs = d.getElementsByTagName(s)[0]; if (d.getElementById(id)) return; js = d.createElement(s); js.id = id; js.src =';
		$rights[] = '';
		$wrongs[] = '"//connect.facebook.net/it_IT/all.js#xfbml=1";';
		$rights[] = '';
		$wrongs[] = " fjs.parentNode.insertBefore(js, fjs); }(document, 'script', 'facebook-jssdk'));";
		$rights[] = '';

		$file_output_content = file_get_contents($item[$i]['input_file']);
		$file_output_content = str_replace($wrongs,$rights,$file_output_content);

		if ($item[$i]['reorder']) {

			$dom = new DOMDocument();
			$dom->load($item[$i]['input_file'],LIBXML_DTDLOAD|LIBXML_DTDATTR);

			/*create the xPath object _after_  loading the xml source, otherwise the query won't work:*/
			$xPath = new DOMXPath($dom);

			/*now get the nodes in a DOMNodeList:*/
			$lingua = $xPath->query("//*[local-name() = 'lingua']");
			$testata = $xPath->query("//*[local-name() = 'testata']");
			$edizione = $xPath->query("//*[local-name() = 'edizione']");
			$nodeList = $xPath->query("//*[local-name() = 'sezione']");

			/*create a new DOMDocument and add a root element:*/
			$newDom = new DOMDocument('1.0','iso-8859-1');
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
								$tempArray['testo'] = str_replace($wrongs,$rights,$tempArray['testo']);
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

			$file_output_content = $newDom->saveXML();

		}

		$file_xml = './feeds/' . $item[$i]['output_file'] . '.xml';

		$pointer_file_xml = fopen(($file_xml),'w') or die("can't open file");

		fwrite($pointer_file_xml, $file_output_content);
		fclose($pointer_file_xml);

	}

	$file_json_content = simplexml_load_file('./feeds/' . $item[$i]['output_file'] . '.xml','SimpleXMLElement', LIBXML_NOCDATA);
	$file_json_content = json_encode($file_json_content);
	$file_json_content = str_replace("\\t"," ",$file_json_content);
	$file_json_content = str_replace("\\n"," ",$file_json_content);
	$file_json_content = str_replace("\\\""," ",$file_json_content);
	$file_json_content = '{"giornale":' . $file_json_content . '}';

	$file_json = './feeds/' . $item[$i]['output_file'] . '.json';

	$pointer_file_json = fopen(($file_json),'w') or die("can't open file");

	fwrite($pointer_file_json, $file_json_content);
	fclose($pointer_file_json);

}
	
}

?>
