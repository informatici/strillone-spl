<?php
ini_set('max_execution_time', 3000);
    $file1 = 'feeds/radio_manuale.xml';
    $file2 = 'feeds/radio_automatiche.xml';
    $fileout = 'feeds/radio.xml'; 
    
    
    
    $xml1 = simplexml_load_file( $file1 );
    
    
    radioAutomatiche($file2);
    
    $xml2 = simplexml_load_file( $file2 );
    
    foreach( $xml2->sezione as $sezione) {
	$a= $xml1->addChild( $sezione->getName() , $sezione );
	
        foreach( $sezione->children() as $child ) {
		$b=$a->addChild( $child->getName() , $child );
                foreach( $child->children() as $nipote ) {
                    $b->addChild( $nipote->getName() , $nipote );
                } 
	    }
    }
    
 
    
    $fh = fopen( $fileout, 'w') or die ( "can't open file $fileout" );
    fwrite( $fh, $xml1->asXML() );
    fclose( $fh );
    
    
    $xml3 = simplexml_load_file( $fileout );
    echo " \r\n ";
    echo "______________________CONTROLLO DELLA VALIDITA' DEI LINK_____________________\r\n";
     foreach( $xml3->sezione as $sezione) {
	$e=true;
	while($e==true){
	    
	    foreach( $sezione->children() as $child ) {
		    
		    $url=$child->testo;
		if ($url!=""){
		    $headers = @get_headers($url, 6);
		    if ((!@stringEndsWith($headers[0],'OK'))or $headers ==null ) {
			echo $child->titolo;
			echo "_________Errore di connessione!";
			echo " \r\n";
			$dom=dom_import_simplexml($child);
			$dom->parentNode->removeChild($dom);
			
			$e=true;
			}
		    else
		    {
			//echo $child->titolo;
			//echo " \r\n ";
			$e=false;
		    }
		}
		
	    }
	}
     }
     echo " \r\n ";
     echo "_______________________________SALVATAGGIO_________________________________\r\n";
     $fh = fopen( $fileout, 'w') or die ( "can't open file $fileout" );
    fwrite( $fh, $xml3->asXML() );
    fclose( $fh );
    
function stringEndsWith($whole, $end)
{
    return (strpos($whole, $end, strlen($whole) - strlen($end)) !== false);
}

function radioAutomatiche($file)
{
    $doc = new DOMDocument( );
    $ele = $doc->createElement( 'giornale' );
    $root=$doc->appendChild( $ele );
    $ele = $doc->createElement( 'sezione' );
    //$ele->nodeValue = 'Hello XML World';
    $root=$root->appendChild( $ele );
    $ele = $doc->createElement( 'nome' );
    $ele->nodeValue = 'Radio italiane shoutcast';
    $root->appendChild( $ele );
    echo " \r\n ";
    echo "______________________RICERCA DELLE RADIO IN AUTOMATICO______________________\r\n";
    
    
    for ($i = 1100; $i <= 1600; $i++){//1600
	$headers = @get_headers('http://shoutcast.unitedradio.it:'.$i, 6);
	if ($headers[0] == 'ICY 200 OK') {
	    
	    $articolo=$doc->createElement( 'articolo' );
	    
	    $titolo=$doc->createElement( 'titolo' );
	    if($headers['icy-name']){
		$titolo->nodeValue = $headers['icy-name'];
	    }
	    else{
		$titolo->nodeValue = "Anonima";
	    }
	    echo $headers['icy-name']." porta n#: ".$i."\r\n";
	    $testo=$doc->createElement( 'testo' );
	    $testo->nodeValue = 'http://shoutcast.unitedradio.it:'.$i;
	    $articolo->appendChild($titolo);
	    $articolo->appendChild($testo);
	    $root->appendChild( $articolo );
	    
	}
	
    }
    echo " \r\n ";
    echo "_________________________SALVATAGGIO RADIO AUTOMATICHE_____________________\r\n";
    
   
    $fh = fopen( $file, 'w') or die ( "can't open file $fileout" );
    fwrite( $fh, $doc->saveXML());
    fclose( $fh );
}
    
?>