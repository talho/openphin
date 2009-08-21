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
      $('a.add_new_device').show();
    });
    $("a.add_new_device").click(function(){
      dev_type=$("select#device_type option:selected").val();
      params="";
      $("p."+dev_type+" input").each(function(){
        params="device_type="+dev_type+"&"+$(this).attr("name")+"="+$(this).val();
      });

      $.ajax({
        type: "POST",
        url: DEVICE_POST_URL,
        data: params,
        dataType: "html",
        success: function(data, status){
          $("#devices .data-list").append(data);
          
        }
      });
      $(".new_device").hide();
      $("form a.add_device").show();

    });
  });
  
  $(function() {
    $('.edit_user_profile #new_device:not:has(.errorMessages)').hide();
  });


})(jQuery);

