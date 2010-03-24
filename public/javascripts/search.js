(function($) {
	
	$( document ) . ready ( 
	  function() {
	    $( 'div.advance_search_user' ).before( '<p><a class="advance_search_user" href="#">Advance Search</a></p>' );
	    $( 'div.advance_search_user' ).hide();
	    $('a.advance_search_user').toggle ( 
	      function() {
	        $(this.parentNode.nextSibling).slideDown('slow');
	        $(this).html('Quick Search');
	      },
	      function() {
	        $(this.parentNode.nextSibling).slideUp('slow');
			$('div.advance_search_user option').removeAttr('selected');
			$('div.advance_search_user input').val('');
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


