(function($) {
	
	$( document ) . ready ( 
	  function() {
	    $( 'div.new_topic' ).before( '<p><a class="new_topic" href="#">New Topic</a></p>' );
	    $( 'div.new_topic' ).hide();
	    $('a.new_topic').toggle ( 
	      function() {
	        $(this.parentNode.nextSibling).slideDown('slow');
	        $(this).html('Hide New Topic');
	      },
	      function() {
	        $(this.parentNode.nextSibling).slideUp('slow');
	        $(this).html('New Topic');
	      }
	    )
	  }
	)

	$( document ) . ready ( 
	  function() {
	    $( 'div.edit_comment' ).before( '<p><a class="edit_comment" href="#">Edit Comment</a></p>' );
	    $( 'div.edit_comment' ).hide();
	    $('a.edit_comment').toggle ( 
	      function() {
	        $(this.parentNode.nextSibling).slideDown('slow');
	        $(this).html('Hide Edit Comment');
	      },
	      function() {
	        $(this.parentNode.nextSibling).slideUp('slow');
	        $(this).html('Edit Comment');
	      }
	    )
	  }
	)

})(jQuery);


