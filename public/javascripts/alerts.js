(function($) {
  $('#preview .edit').live('click', function(e) {
    $('#preview, #edit').toggle();
    return false;
  });
  
  $(function() {
    $('#edit.preview').hide();
  })
})(jQuery);