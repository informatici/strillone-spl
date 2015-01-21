<?
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

function trace($text) {
	$handle = fopen("tmp/log.txt","a+");
	fwrite($handle, "[Trace] ".$text."\n");
	fclose($handle);
}

?>
