(function($) {

	$( document ) . ready (
	  function() {
        $('div#search-results div.pagination').children('a').click(function(e){
          uri = $(this).attr("href").split("?")[0];
          uriparams = $(this).attr("href").split("?")[1];
          params = deParam(uriparams);
          myform = '<form method="post" action="' + uri +'">';
          $.each(params, function(key, value) {
            switch(key) {
                case "jurisdiction_ids[]":
                case 'role_ids[]':
                      $.each(value.split(","), function(pindex, pvalue){
                          myform += '<input type="hidden" name="' + key + '" value="' + pvalue + '">'
                      });
                    break;
                default:
                  myform += '<input type="hidden" name="' + key + '" value="' + value + '">'
                  break;
            }
          })
          myform += '<input type="hidden" name="authenticity_token" value="' + $("meta#authenticity-token").attr('content') + '" >'
          myform += '</form>'
          myform = $(myform).appendTo('body');
          myform.submit();

          return false;
        });


        function deParam(URIstring) { // takes a string of &-separated html parameters and returns a hash.  Duplicate keys are comma-separated in the hash
            var regexResults;
            var urlParams = {};
            var decodedParams = function (s) { return decodeURIComponent(s.replace(/\+/g, " ")); };
            var regex_string = /([^&=]+)=?([^&]*)/g;

            while (regexResults = regex_string.exec(URIstring)) {
               if ($.trim(urlParams[decodedParams(regexResults[1])]) == "") {
                    urlParams[decodedParams(regexResults[1])] = decodedParams(regexResults[2]);
               } else {
                    urlParams[decodedParams(regexResults[1])] += ',' + decodedParams(regexResults[2]);
               }

            }
            return urlParams;
        };


	    $( 'div.advance_search_user' ).before( '<p><a class="advance_search_user" href="#">Advanced Search</a></p>' );
	    $( 'div.advance_search_user' ).hide();
	    $('a.advance_search_user').toggle (
	      function() {
	        $(this.parentNode.nextSibling).slideDown('slow');
			$('div.quick_search_user input').val('');
		    $( 'div.quick_search_user' ).hide();
	        $(this).html('Quick Search');
	      },
	      function() {
	        $(this.parentNode.nextSibling).slideUp('slow');
			$('div.advance_search_user option').removeAttr('selected');
			$('div.advance_search_user input').val('');
		    $( 'div.quick_search_user' ).show();
	        $(this).html('Advanced Search');
	      }
	    )
	  }
	)

	$( document ) . ready (
	  function() {
	    $( 'p.search_user_explanation' ).before( '<p><a class="search_user_explanation" href="#">Willcard (*) Explanation</a></p>' );
	    $( 'p.search_user_explanation' ).hide();
	    $('a.search_user_explanation').toggle (
	      function() {
	        $(this.parentNode.nextSibling).slideDown('slow');
	        $(this).html('Willcard (*) Explanation');
	      },
	      function() {
	        $(this.parentNode.nextSibling).slideUp('slow');
	        $(this).html('Willcard (*) Explanation');
	      }
	    )
	  }
	)

})(jQuery);


