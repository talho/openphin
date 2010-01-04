(function($) {
  $(function() {
    $(document).ready(function() {
      if ($('#alert_device_phone_device:checked,#alert_device_sms_device:checked,#alert_device_fax_device:checked,#alert_device_blackberry_device:checked').length > 0) {
        $('#details .caller_id').show();
      }
      $('#alert_device_fax_device').attr('disabled', true);
    });
    $('input[type=submit]').addClass('submit');
    $('.preview_alert').click(function(e) {
      if ($(".audience_jurisdiction:checked").length == 0 &&
          $(".audience_role:checked").length == 0 &&
          $(".audience_group:checked").length == 0 &&
          $(".search_user_ids option").length == 0) {
        //no audience specified
        alert("You must specify an audience before you can preview the alert.");
        e.preventDefault();
        e.stopImmediatePropagation();
        return false;
      }
    });
    $('ul.progress a:not([href=#preview])').click(function(event) {
      var selector = $(this).attr('href');
      if (selector == '#audience') {
        var cont = true;
        if (jQuery.trim($('#alert_title').val()).length == 0) {
          alert("You must specify a title");
          return false;
        }
        if ($('.alert_device:checked').length == 0) {
          alert("You must specify at least one communication method");
          return false;
        }

        $('.alert_device:checked').each(function() {
          switch ($(this).val())
          {
            case "Device::EmailDevice":
              if (jQuery.trim($('#alert_message').val()) == "") {
                cont = false;
                alert("You must provide a message for an email alert");
              }
              break;
            case "Device::PhoneDevice":
              //if(jQuery.trim($('.short_message').val()) == "" && $('.success:hidden').length != 0) {
              if (jQuery.trim($('.short_message').val()) == "") {
                cont = false;
                //alert("You must provide a short message or voice recording for a phone alert.");
                alert("You must provide a short message for a phone alert.");
              }
              break;
            case "Device::SMSDevice":
              if (jQuery.trim($('.short_message').val()) == "") {
                cont = false;
                alert("You must provide a short message for an SMS alert.");
              }
              break;
            case "Device::FaxDevice":
              if (jQuery.trim($('#alert_message').val()) == "") {
                cont = false;
                alert("You must provide a message for a fax alert.");
              }
              break;
            case "Device::BlackberryDevice":
              if (jQuery.trim($('.short_message').val()) == "") {
                cont = false;
                alert("You must provide a short message for a Blackberry alert.");
              }
              break;
            default:
              cont = false;
          }
        })
        if (cont == false) return false;

      }
      $(this).parents('ul').find('a').removeClass('current');
      $(this).addClass('current');
      $('#details, #audience, #preview').hide();
      $('' + selector).show();
      $('.short_message').keypress(function(event) {
        if ($('.short_message').val().length >= 160) {
          if (event.keyCode == 46 || event.keyCode == 8) {
            $('.maxlen').css('color', '#000000');
            return true;
          }
          else if (event.keyCode > 36 && event.keyCode < 41)
            return true;
          else {
            $('.maxlen').css('color', '#FF0000');
            return false;
          }
        }
        else $('.maxlen').css('color', '#000000');
        return true;
      });
      return false;
    });
    $('#edit fieldset input:checkbox').click(function() {
      $(this).siblings('label').toggleClass('checked');
    });

    $('fieldset.filterable').append('<div class="list_filter"><input type="search" name="q" value="Filter this List" class="empty" /></div>');
    $('div.list_filter input').focus(function() {
      if ($(this).val() == 'Filter this List') {
        $(this).removeClass('empty').val('');
      }
    }).blur(function() {
      if ($(this).val() == '') {
        $(this).addClass('empty').val('Filter this List');
      }
    }).each(function() {
      $(this).liveFilter();
    });

    if ($('ul.progress a[href=#audience]').length > 0)
      $('#details .details').append('<p><button class="audience">Select an Audience &gt;</button></p>');

    $('#details button.audience').click(function() {
      $('ul.progress a[href=#audience]').click();
      return false;
    });

    $('#preview button.edit').click(function() {
      $('ul.progress a[href=#details]').click();
      return false;
    });

    var $current = $('ul.progress a.current');
    if ($current.length > 0) {
      if ($current.attr('href') == '#preview') {
        $('#details, #audience').hide();
        $('#preview').show();
      } else {
        $current.click();
      }
    } else {
      $('ul.progress a:first').click();
    }

    $('ul.check_selector>li>ul>li>ul>li').append('<a href="#" class="toggle closed">Toggle</a>');
    $('ul.check_selector ul ul ul').hide();

    $('ul.check_selector a.toggle').click(function() {
      $(this).toggleClass('closed').siblings('ul').toggle();
      $(this).parent().children(".select_all").toggle();
      return false;
    })

    $('ul.progress a[href=#preview]').click(function() {
      $('.alert_device').each(function() {
        if ($(this).attr("checked")) {
          $(this).parents('form').submit();
        }
      })
    });

    $('ul#alerts a.view_more, ul#alerts a.view_less').click(function() {
      $(this).closest('li').toggleClass('more');
      return false;
    });

    //select all child jurisdictions of the jur. for this link
    $("a.select_all").click(function() {
      if ($(this).text() == "Select all children...") {
        $(this).parent().find(":checkbox").attr("checked", true);
        $(this).text("Unselect all...");
      } else {
        $(this).parent().find(":checkbox").attr("checked", false);
        $(this).text("Select all children...");

      }
    });

    $('ul.check_selector #alert_device_phone_device,#alert_device_sms_device,#alert_device_fax_device,#alert_device_blackberry_device').click(function() {
      if ($('ul.check_selector #alert_device_phone_device:checked').length ||
          $('ul.check_selector #alert_device_sms_device:checked').length ||
          $('ul.check_selector #alert_device_fax_device:checked').length ||
          $('ul.check_selector #alert_device_blackberry_device:checked').length)
        $('#details .caller_id').show();
      else $('#details .caller_id').hide();
    });

    $('#alert_caller_id').keydown(function(event) {
      if(event.keyCode == 46 || event.keyCode == 8 || event.keyCode == 9) return true;
      if(event.keyCode >= 37 && event.keyCode <= 40) return true;
      if(event.keyCode >= 48 && event.keyCode <=57) return true;
      if(event.keyCode >=96 && event.keyCode <= 105) return true;

      return false;
    });
  });
})(jQuery);