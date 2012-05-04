(function($) {

	// build the new topic div
	$( document ) . ready ( 
	  function() {
	    $( 'div.new_topic' ).before( '<p><a class="new_topic toggle closed" href="#">New Topic</a></p>' );
	    $( 'div.new_topic' ).hide();
	    $('a.new_topic').toggle ( 
	      function() {
	        $(this.parentNode.nextSibling).slideDown('slow');
			$("#new_topic_image").attr('src','assets/arrow_down.png');
	      },
	      function() {
	        $(this.parentNode.nextSibling).slideUp('slow');
			$("#new_topic_image").attr('src','assets/arrow_right.png');
	      }
	    )
	  }
	)

	// build the edit comment div
	$( document ) . ready ( 
	  function() {
	    $( 'div.edit_comment' ).before( '<p><a class="edit_comment" href="#"><img src="/assets/pencil.png" />Edit Comment</a></p>' );
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
		$('.form_audience ul.check_selector>li>ul>li>ul').find('li>ul>li>input:checked').parent().parent().toggle();
	    $('.form_audience ul.check_selector>li>ul>li>ul').find('li>ul>li>input:checked').parent().parent().parent().find('a:first').css('display', 'inline');
	    $('.form_audience ul.check_selector>li>ul>li>ul').find('li>ul>li>input:checked').parent().parent().parent().find('a.toggle.closed').removeClass('closed');
	  }
	)

  // form controller
  $(document).ready(
    function(){
      $('#forum_submit').click(function(e){
        if($('#forum_topic_attributes_name').val().length <= 1){
          alert("You must enter a valid name for the forum.");
          return false;
        }
        if($('#forum_topic_attributes_content').val().length < 1){
          alert('You must enter a topic description.');
          return false;
        }
      })
      $('#topic_submit').click(function(e){
        if($('#topic_name').val().length <= 1){
          alert("You must enter a valid name for the forum.");
          return false;
        }
        if($('#topic_content').val().length < 1){
          alert('You must enter a topic description.');
          return false;
        }
      })
    }
  )
})(jQuery);


