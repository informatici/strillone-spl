/* jTestata : jQuery testata parser plugin
 * Copyright (C) 2013 rodenic
 */

jQuery.getTestata = function(options) {
    options = jQuery.extend({

        url: null,
        data: null,
        cache: true,
        success: null,
        failure: null,
        error: null,
        global: true

    }, options);

    if (options.url) {
        if (jQuery.isFunction(options.failure) && jQuery.type(options.error)==='null') {
          // Handle legacy failure option
          options.error = function(xhr, msg, e){
            options.failure(msg, e);
          }
        } else if (jQuery.type(options.failure) === jQuery.type(options.error) === 'null') {
          // Default error behavior if failure & error both unspecified
          options.error = function(xhr, msg, e){
            window.console&&console.log('getTestata non riesce a caricare il file', xhr, msg, e);
          }
        }

        return $.ajax({
            type: 'GET',
            url: options.url,
            data: options.data,
            cache: options.cache,
            dataType: (jQuery.browser.msie) ? "text" : "xml",
            success: function(xml) {
                var feed = new JTestata(xml);
                if (jQuery.isFunction(options.success)) options.success(feed);
            },
            error: options.error,
            global: options.global
        });

    }
};

function JTestata(xml) {
    if (xml) this.parse(xml);
};

JTestata.prototype = {

    parse: function(xml) {

        if (jQuery.browser.msie) {
            var xmlDoc = new ActiveXObject("Microsoft.XMLDOM");
            xmlDoc.loadXML(xml);
            xml = xmlDoc;
        }

        if (jQuery('testate', xml).length == 1) {
            this.type = 'testate';
            var feedClass = new JTes(xml);
        }

        if (feedClass) jQuery.extend(this, feedClass);
    }
};

function JTes(xml) {
    this._parse(xml);
};

JTes.prototype  = {

    _parse: function(xml) {

        this.testate = new Array();
		
        var feed = this;
        
        jQuery('testata', xml).each(function(index) {
        
            var testata = new JTestata();
            testata.lingua = jQuery(this).find('lingua').eq(0).text();
            testata.nome = jQuery(this).find('nome').eq(0).text();
            testata.edizione = jQuery(this).find('edizione').eq(0).text();
	    testata.resource = jQuery(this).find('resource').eq(0).text();
			
            feed.testate.push(testata);
			var indice_testata = index;
			
        });
    }
};       
