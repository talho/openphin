(function($) {

	$( document ) . ready (
	  function() {
        $('div#search-results div.pagination').children('a').click(function(e){
          uri = $(this).attr("href").split("?")[0];
          uriparams = $(this).attr("href").split("?")[1];
          params = deParam(uriparams);
          myform = '<form method="post" action="' + uri +'">';
          $.each(params, function(key, value) {
            myform += '<input type="hidden" name="' + key + '" value="' + value + '">'
          })
          myform += '<input type="hidden" name="authenticity_token" value="' + $("meta#authenticity-token").attr('content') + '" >'
          myform += '</form>'
          myform = $(myform).appendTo('body');
          myform.submit();

          return false;
        });


        function deParam(q) {
            var e,
            urlParams = {},
            d = function (s) { return decodeURIComponent(s.replace(/\+/g, " ")); },
            r = /([^&=]+)=?([^&]*)/g;

            while (e = r.exec(q)) {
                urlParams[d(e[1])] = d(e[2]);
            }
            return urlParams;
        };


	    $( 'div.advance_search_user' ).before( '<p><a class="advance_search_user" href="#">Advance Search</a></p>' );
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
	        $(this).html('Advance Search');
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


