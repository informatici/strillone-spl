<?php
ini_set('max_execution_time', 3000);
    $file1 = 'feeds/radio_manuale.xml';
    $file2 = 'feeds/radio_automatiche.xml';
    $fileout = 'feeds/radio.xml'; // da cambiare in feeds/radio.xml
    
    
    
    $xml1 = simplexml_load_file( $file1 );
    $xml2 = simplexml_load_file( $file2 );
    
    radioAutomatiche('feeds/radio_automatiche.xml');
    
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
   
     foreach( $xml3->sezione as $sezione) {
	
        foreach( $sezione->children() as $child ) {
		
		$url=$child->testo;
		
	    
	    if ($url!=""){
		$headers = @get_headers($url, 6);
		if ($headers !=null){
		   
		    //if ($headers[0] != 'ICY 200 OK') {
		    if (!stringEndsWith($headers[0],'OK')) {
			echo $url;
			echo "        NON VA############## ";
			echo $headers[0];
			$child->testo="http://www.suoniemusica.com/public/sound/2553.mp3";
			
			}
		    else
		    {
			echo $url;
			echo "        Funziona";
		    }
		}else{
		    
		    echo $url;
			echo "        NON VA############## ";
			$child->testo="http://www.suoniemusica.com/public/sound/2553.mp3";
		}
		
	    }
	    echo "<br>";
	}
     }
     
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
    
    
    
    for ($i = 1100; $i <= 1600; $i++){//1600
	$headers = @get_headers('http://shoutcast.unitedradio.it:'.$i, 2);
	if ($headers[0] == 'ICY 200 OK') {
	    $articolo=$doc->createElement( 'articolo' );
	    
	    $titolo=$doc->createElement( 'titolo' );
	    $titolo->nodeValue = $headers['icy-name'];
	    echo $headers['icy-name']." porta n°:".$i."<br>";
	    $testo=$doc->createElement( 'testo' );
	    $testo->nodeValue = 'http://shoutcast.unitedradio.it:'.$i;
	    $articolo->appendChild($titolo);
	    $articolo->appendChild($testo);
	    $root->appendChild( $articolo );
	    
	}
	
    }
    echo $i."....<br>";
    echo "        SALVATAGGIO________________________";
    
   
    $fh = fopen( $file, 'w') or die ( "can't open file $fileout" );
    fwrite( $fh, $doc->saveXML());
    fclose( $fh );
}
    
?>