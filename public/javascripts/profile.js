(function($) {
  $('form a.add_device').live('click', function() {
    $('.new_device').show();
    $(this).hide();
    return false;
  });
  
  $(document).ready(function() {
    $('.edit_user #device_type').change(function() {
      $(this).closest('div.aside').find('p.device').hide();
      $('p.' + $(this).val()).show();
    });
  });
  
  $(function() {
    $('.edit_user_profile #new_device:not:has(.errorMessages)').hide();
  })
})(jQuery);