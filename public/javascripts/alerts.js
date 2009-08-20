(function($) {
  $(function() {
		$('input[type=submit]').addClass('submit');
		$('ul.progress a:not([href=#preview])').click(function() {
			$(this).parents('ul').find('a').removeClass('current');
			$(this).addClass('current');
			$('#details, #audience, #preview').hide();
			var selector = $(this).attr('href');
			$('' + selector).show();
			return false;
		});
		$('ul.check_selector #alert_device_phone_device').click(function() {
			$('div.audio').toggle();
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
			$(this).parents('form').submit();
		});
		
		$('ul#alerts a.view_more, ul#alerts a.view_less').click(function() {
		  $(this).closest('li').toggleClass('more');
		  return false;
		});

    //select all child jurisdictions of the jur. for this link
    $("a.select_all").click(function(){
      $(this).parent().find(":checkbox").attr("checked", "true");
    });

  })
})(jQuery);