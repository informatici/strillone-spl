<?
/*
    Copyright© 2012,2013 Informatici Senza Frontiere Onlus
    http://www.informaticisenzafrontiere.org

    This file is part of "ISA" I Speak Again - ISF project for impaired and blind people.

    "ISA" I Speak Again is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    "ISA" I Speak Again is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with "ISA" I Speak Again.  If not, see <http://www.gnu.org/licenses/>.
 */

include "functions.php";

$available_voices = array();

$available_voices['it'] = array();
$available_voices['en'] = array();

// ITALIAN
$available_voices['it'][0] = 'it_1_f';
$available_voices['it'][1] = 'it_1_m';

//ENGLISH
$available_voices['en'][0] = 'en-gb_1_f';
$available_voices['en'][1] = 'en-gb_1_m';
$available_voices['en'][2] = 'en-us_1_f';
$available_voices['en'][3] = 'en-us_1_m';

$chosen_lang = 'it';
$chosen_voice = $available_voices['it'][1];

if (isset($_POST["language"]) && ($_POST["language"] != '')) {
    $chosen_lang = $_POST["language"];
    $chosen_voice = $available_voices[$_POST["language"]][1];
}

if (isset($_POST["speech"]) && ($_POST["speech"] != '')) {
    
    $speech = stripslashes(trim($_POST["speech"]));
    trace("POST Text: ".$_POST["speech"]);
    trace("URLENCODE:".urlencode($_POST["speech"]));
    $speech = $_POST["speech"];
    $speech = substr($speech, 0, 2048);
    $volume_scale = intval($_POST["volume_scale"]);
    if ($volume_scale <= 0) { $volume_scale = 1; };
    if ($volume_scale > 100) { $volume_scale = 100; };

    if ($speech != '') {
        trace("VOICE: ".$chosen_voice);
        $baseUrl = 'http://webvoice.tingwo.co/';
        $customer_id = 'inform5643218';
        $domain = 'strillone.walks.to';
        $lang = $chosen_lang;
        $voice = $chosen_voice;
        $save = 1;

        $url = $baseUrl.$customer_id.'vox?url='.urlencode($domain).'&voxtext=\pitch=50 \speed=60 '.urlencode($speech).'&lang='.$lang.'&voice='.urlencode($voice).'&save='.$save;

        trace("Tingwo: elaborating...");
        trace("Text: ".$speech);
        trace("Tingwo URL: ".$url);

        $return_value = $url;
    }
      
    // header potrebbe non essere necessario
    header('Content-Type: text/html');
    echo $return_value;
}

?>
