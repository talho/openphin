(function($) {
  $(document).ready(function () {
      $("#devices .data-list .error").hide();
  });

  $('form a.add_device').live('click', function() {
    $('.new_device').show();
    $(this).hide();
    return false;
  });

//  $("fieldset.devices a.destroy").live("click", function(){
//    var device=this;
//    $.ajax({
//      type: "POST",
//        url: $(device).attr("href"),
//        data: {"_method": "delete"},
//        dataType: "html",
//        success: function(data, status){
//          $(device).hide();
//          $(".error").hide();
//        },
//        error: function(request, error){
//          $(".error").show();
//          $("#devices .data-list .error").text("There was an error deleting the device.");
//          $("#devices .data-list .error").effect("highlight", {}, 3000);
//        }
//    })
//  });
  
  $(document).ready(function() {
    $('.edit_user #device_type').change(function() {
      $(this).closest('div.aside').find('p.device').hide();
      $('p.' + $(this).val()).show();
      $('a.add_new_device').show();
      $('a.cancel_new_device').show();
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
          $(".error").hide();
        },
        error: function(request, error){
          $(".error").show();
          $("#devices .data-list .error").text(request.responseText);
          $("#devices .data-list .error").effect("highlight", {}, 3000);
        }
      });
      $('#device_type').val("");
      $("p."+dev_type+" input").each(function(){
        $(this).val("");
      });
      $(".new_device").hide();
      $("form a.add_device").show();

    });
    $("a.cancel_new_device").click(function(){

      dev_type=$("select#device_type option:selected").val();
      $("p."+dev_type+" input").each(function(){
        $(this).val("");
      });
      $(".new_device").hide();
      $("form a.add_device").show();

    });
  
    $('.jurisdiction_select').change(function(){
		if (jQuery.trim($(".role_select").val()).length == 0) {
			$('.role_select option').each(function() {
				if(jQuery.trim(this.text) == "Public") $(".role_select").val(this.value);
			});
		}
    });

  });
  
  $(function() {
    $('.edit_user_profile #new_device:not:has(.errorMessages)').hide();
  });

  $(function() {
    $('.state_jurisdiction').click(function() {
      if($('.state_jurisdiction:checked').length > 0) {
        $('.home_jurisdiction').val("");
        $('.home_jurisdiction').attr("disabled", "disabled");
      } else {
        $('.home_jurisdiction').val("");
        $('.home_jurisdiction').removeAttr("disabled");
      }
    });
  });


})(jQuery);

