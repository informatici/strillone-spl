<?php

    ini_set('max_execution_time', 3000); //Tempo di esecuzione massimo impostato a 3000 secondi
    $file1 = 'feeds/radio_manuale.xml';
    $file2 = 'feeds/radio_automatiche.xml';
    $fileout = 'feeds/radio.xml'; 
    
    $xml1 = simplexml_load_file( $file1 );
    
    //Esegue un port scanning di un sito
    //per trovare gli indirizzi delle radio
    radioAutomatiche($file2);
    
    $xml2 = simplexml_load_file( $file2 );
    
    //Fonde i due file xml in uno
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
   
    //Controlla che tutte le foglie del file
    //xml finale siano indirizzi URL corretti 
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
			 $arr[0]='';
			 $arr[1]='';
			 $arr = preg_split('/(?<=[0-9])(?=[a-z]+)/i',$child->titolo);  
			 //split necessario per il tts delle versione web di strillone
			 if (sizeof($arr)>1)
			 {
			   $child->titolo=$arr[0].' '.$arr[1];
			 }
			
			
			
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

class ChildThread extends Thread {
    public $data;
    private $porta;
    
    public function __construct($por)
    {
	$this->porta=$por;
    }

    public function run() {
      $headers = @get_headers('http://shoutcast.unitedradio.it:'.$this->porta,6);
	$this->data = ' ';
	if ($headers[0] == 'ICY 200 OK') {
	    $this->data =$headers['icy-name'];
	}     
    }
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
    
    $b=false;
    for ($i = 1100; $i < 1600; $i++){//1600
	$thread[$i-1100] = new ChildThread($i);
	$thread[$i-1100]->start();
	$connessioni=50; //numero di connessioni massime simultanee
	if ($i % $connessioni ==0){
	 if ($b){   
		echo "Scansione porta n#: ".$i."\r\n";
		for ($a = $i-$connessioni; $a <= $i; $a++){
		    $thread[$a-1100]->join();
		}
	    }
	$b=true;
	}
    }
    for ($a ; $a <1600; $a++){
	    $thread[$a-1100]->join();
	}
    

    for ($i = 1100; $i < 1600; $i++){
	
	if ($thread[$i-1100]->data != ' ') {
	    $articolo=$doc->createElement( 'articolo' );
	    $titolo=$doc->createElement( 'titolo' );
	    if($thread[$i-1100]->data){
		$titolo->nodeValue = $thread[$i-1100]->data;
	    }
	    else{
		$titolo->nodeValue = "Anonima";
	    }
	    $testo=$doc->createElement( 'testo' );
	    $testo->nodeValue = 'http://shoutcast.unitedradio.it:'.$i;
	    $articolo->appendChild($titolo);
	    $articolo->appendChild($testo);
	    $root->appendChild( $articolo );
	}
    }
    echo " \r\n ";
    echo "_______________________________SALVATAGGIO_________________________________\r\n";
    $fh = fopen( $file, 'w') or die ( "can't open file $fileout" );
    fwrite( $fh, $doc->saveXML());
    fclose( $fh );
}
   
?>