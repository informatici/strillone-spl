<?php
    $file1 = 'feeds/radio_manuale.xml';
    $file2 = 'feeds/radio_automatiche.xml';
    $fileout = 'feeds/radio.xml'; // da cambiare in feeds/radio.xml
    $xml1 = simplexml_load_file( $file1 );
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
		
               // foreach( $child->children() as $url ) {
		    //->testo
		    
		//echo $url;
		$url=$child->testo;
		//echo $url;
		
	    
	    if ($url!=""){
		$headers = @get_headers($url, 6);
		if ($headers !=null){
		    
		    //substr_compare($headers[0], 'OK', strlen($headers[0]) - 2, 2) === 0
		    
		    //if ($headers[0] != 'ICY 200 OK') {
		    if (!stringEndsWith($headers[0],'OK')) {
			echo $url;
			echo "        NON VA############## ";
			echo $headers[0];
			
			//$xml3->removeChild($child);
			
			//$child->parentNode->removeChild($child);
			//$child->removeChild($child->childNodes->item(1));
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
			//unset($xml3->$sezione->$child);
			//$child->parentNode->removeChild($child);
			$child->testo="http://www.suoniemusica.com/public/sound/2553.mp3";
		}
		
	    }
	    
	    echo "<br>";
		
	    
	  
		//}
		
	}
     }
     
     $fh = fopen( $fileout, 'w') or die ( "can't open file $fileout" );
    fwrite( $fh, $xml3->asXML() );
    fclose( $fh );
    
function stringEndsWith($whole, $end)
{
    return (strpos($whole, $end, strlen($whole) - strlen($end)) !== false);
}
    
?>