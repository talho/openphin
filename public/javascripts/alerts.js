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
		$('#edit fieldset input:checkbox').click(function() {
			$(this).parents('li').toggleClass('checked');
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
		
		$('ul.progress a[href=#preview]').click(function() {
			$('#new_alert').submit();
		})
  })
})(jQuery);