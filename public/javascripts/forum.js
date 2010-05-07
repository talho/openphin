(function($) {

	// build the new topic div
	$( document ) . ready ( 
	  function() {
	    $( 'div.new_topic' ).before( '<p><a class="new_topic" href="#"><img id="new_topic_image" src="/images/arrow_right.png" />New Topic</a></p>' );
	    $( 'div.new_topic' ).hide();
	    $('a.new_topic').toggle ( 
	      function() {
	        $(this.parentNode.nextSibling).slideDown('slow');
			$("#new_topic_image").attr('src','images/arrow_down.png');
	      },
	      function() {
	        $(this.parentNode.nextSibling).slideUp('slow');
			$("#new_topic_image").attr('src','images/arrow_right.png');
	      }
	    )
	  }
	)

	// build the edit comment div
	$( document ) . ready ( 
	  function() {
	    $( 'div.edit_comment' ).before( '<p><a class="edit_comment" href="#"><img src="/images/pencil.png" />Edit Comment</a></p>' );
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

	// expand jurisdiction parent of the audience form if a child is selected
	$( document ) . ready ( 
	  function() {
		$('.form_audience ul.check_selector>li>ul').find('li>input:checked:first').parent().parent().toggle();
	  }
	)

})(jQuery);


