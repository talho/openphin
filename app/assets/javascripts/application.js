// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
(function($) {
  $.ajaxSettings.accepts.html = $.ajaxSettings.accepts.script;

  $.authenticityToken = function() {
    return $('#authenticity-token').attr('content');
  };

  $(document).ajaxSend(function(event, request, settings) {
    if(settings.type == 'post') {
      settings.data = (settings.data ? settings.data + "&" : "") + "authenticity_token=" + encodeURIComponent($.authenticityToken());
      request.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
    }
  });

  $.fn.toggleCheckbox = function(target) {
    return this.each(function() {
      $(target)[this.checked ? 'show' : 'hide']();
    });
  };

  $('a.destroy').live('click.namespace', function(event) {
    event.preventDefault();
    event.stopImmediatePropagation();
    if(confirm('Are you sure you want to delete?')) {
      $.ajax({
        type : "POST",
        url : this.href,
        data : {
          "_method" : "delete",
          "authenticity_token" : $.authenticityToken()
        },
        dataType : "html",
        success : function() {
          location.reload();
        }
      });
    }
    return false;
  });
})(jQuery);

jQuery(function($) {
  $('#health_professional').toggleCheckbox('#health_professional_fields').click(function() {
    $('#health_professional_fields').toggle();
    if($('#health_professional:checked').length > 0){
      $('fieldset#health_professional_fields *:input').val('');
    }

    var pub = $.map($("fieldset#health_professional_fields option"), function(item) {
      if($(item).text() == "Public"){
        return item;
      }
    });
    $(pub).attr("selected", "selected");
    $('fieldset#health_professional_fields select#user_role_requests_attributes_0_role_id').selectedIndex = $(pub).val();
  });

});

$(document).ready(function() {
  // This code is used to layout three columns on the dashboard page
  if(document.getElementById('right_column')) {
    $("#wrapper").css({
      "width" : "100%"
    })
    $("div#content").css({
      "width" : "100%"
    })
  }

  var name_synched = false;

  if( typeof $('#user_display_name').val() != "undefined" && (jQuery.trim($('#user_display_name').val()) == "" || jQuery.trim($('#user_display_name').val()) == jQuery.trim(jQuery.trim($('#user_first_name').val()) + " " + jQuery.trim($('#user_last_name').val()))))
    name_synched = true;
  display_name_change = function() {
    if(name_synched) {
      $('#user_display_name').val(jQuery.trim((jQuery.trim($('#user_first_name').val()) + " " + jQuery.trim($('#user_last_name').val()))));
    }
    if(jQuery.trim($('#user_display_name').val()) == "" || jQuery.trim($('#user_display_name').val()) == jQuery.trim(jQuery.trim($('#user_first_name').val()) + " " + jQuery.trim($('#user_last_name').val())))
      name_synched = true;
    else
      name_synched = false;
  }

  $('#user_first_name').keyup(display_name_change)
  $('#user_last_name').keyup(display_name_change)
  $('#user_display_name').keyup(function() {
    if(jQuery.trim($('#user_display_name').val()) == "" || jQuery.trim($('#user_display_name').val()) == jQuery.trim(jQuery.trim($('#user_first_name').val()) + " " + jQuery.trim($('#user_last_name').val())))
      name_synched = true;
    else
      name_synched = false;
  });
  $('a.destroy').removeAttr('onclick');

  //Fix for IE7, having issues with children of absolutely positioned parents disappearing on JQuery calls to hide, class, etc
  if(document.all) {
    setTimeout("$('#content').hide();$('#content').show();", 100);
  }
  set800 = false;
  if((screen.width < 1024) && (screen.height < 768)) {
    $('head').append("<link href='/stylesheets/detect800.css' media='screen' rel='stylesheet' type='text/css' />");
    if(document.getElementById('sign_in_form'))
      $('#wrapper').prepend("<div class='flash'><p class='notice'>For optimal experience, please set your resolution to 1024x768 or higher.</p></div>");
    set800 = true;
  }
  $(window).resize(function() {
    if((screen.width < 1024) && (screen.height < 768) && !set800) {
      $('head').append("<link href='/stylesheets/detect800.css' media='screen' rel='stylesheet' type='text/css' />");
      if(document.getElementById('sign_in_form'))
        $('#wrapper').prepend("<div class='flash'><p class='notice'>For optimal experience, please set your resolution to 1024x768 or higher.</p></div>");
      set800 = true;
    } else if((screen.width >= 1024) && (screen.height >= 768) && set800) {
      //link_elements = document.getElementsByTagName('link');
      //document.getElementsByTagName('head')[0].removeChild(link_elements[link_elements.length-1]);
      //$(link_elements[link_elements.length-1]).remove();
      $("link:last").attr('href', '');
      set800 = false;
    }
  });
});
