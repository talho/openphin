(function($) {
  $('.edit_user_profile .add_device').live('click', function(e) {
    $('.edit_user_profile #new_device').show();
    $(this).hide();
    return false;
  });
  
  $(function() {
    $('.edit_user_profile #new_device:not:has(.errorMessages)').hide();
  })
})(jQuery);