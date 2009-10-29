// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
(function($) {
  $.ajaxSettings.accepts.html = $.ajaxSettings.accepts.script;
  
  $.authenticityToken = function() {
    return $('#authenticity-token').attr('content');
  };
  
  $(document).ajaxSend(function(event, request, settings) {
    if (settings.type == 'post') {
      settings.data = (settings.data ? settings.data + "&" : "")
          + "authenticity_token=" + encodeURIComponent($.authenticityToken());
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
    if (confirm('Are you sure you want to delete?')) {
      var form = $('<form method="POST"></form>')
        .css({display:'none'})
        .attr('action', this.href)
        .append('<input type="hidden" name="_method" value="delete"/>')
        .append('<input type="hidden" name="authenticity_token" value="' +
          $.authenticityToken() + '"/>')
        .insertAfter(this.parentNode);
      form.submit();
    }
    return false;
  });

})(jQuery);

jQuery(function($) {
  $('#health_professional').toggleCheckbox('#health_professional_fields').click(function() {
	$('#health_professional_fields').toggle();
	$('fieldset#health_professional_fields *:input').val('');

    var public = $.map($("fieldset#health_professional_fields option"), function(item) {
      if ($(item).text() == "Public") return item;
    });
    $(public).attr("selected", "selected");
    $('fieldset#health_professional_fields select#user_role_requests_attributes_0_role_id').selectedIndex = $(public).val();
  });
  
  $('select.crossSelect[multiple="multiple"]').crossSelect({clickSelects: true});
  
  $(".search_user_ids").fcbkcomplete({
    json_url: '/search',
    json_cache: true,
    filter_case: false,
    filter_hide: true,
    filter_selected: true,
    firstselected: true,
    newel: true
  });
});

jQuery(function($) {
  $('.alert .summary').click(function(){
    $(this).parent(".alert").children(".detail").toggle();
  });
});

 $(document).ready(function() {
 	var name_synched = false;

	if(typeof $('#user_display_name').val() != "undefined" && (jQuery.trim($('#user_display_name').val()) == "" || jQuery.trim($('#user_display_name').val()) == jQuery.trim(jQuery.trim($('#user_first_name').val()) + " " + jQuery.trim($('#user_last_name').val())))) name_synched = true;

	display_name_change = function(){
		if (name_synched) {
			$('#user_display_name').val(jQuery.trim((jQuery.trim($('#user_first_name').val()) + " " + jQuery.trim($('#user_last_name').val()))));
		}
		if(jQuery.trim($('#user_display_name').val()) == "" || jQuery.trim($('#user_display_name').val()) == jQuery.trim(jQuery.trim($('#user_first_name').val()) + " " + jQuery.trim($('#user_last_name').val()))) name_synched = true;
		else name_synched = false;
	}

	$('#user_first_name').keyup(display_name_change)
	$('#user_last_name').keyup(display_name_change)
	$('#user_display_name').keyup(function() {
		if(jQuery.trim($('#user_display_name').val()) == "" || jQuery.trim($('#user_display_name').val()) == jQuery.trim(jQuery.trim($('#user_first_name').val()) + " " + jQuery.trim($('#user_last_name').val()))) name_synched = true;
		else name_synched = false;
	});
    $('a.destroy').removeAttr('onclick');
     $("#calendar_panel").hide();
     $("#documents_panel").hide();
     $("#chat_panel").hide();
     $("#links_panel").hide();
		$(".calendar").bind("click", function (e){
			togglePanel("calendar", e);
			return false;
		});
    $(".documents").bind("click", function (e){
	    return togglePanel("documents", e);

    });
    $(".chat").bind("click", function (e){
	    return togglePanel("chat", e);

    });
	  $(".links").bind("click", function (e){
	      return togglePanel("links", e);
    });
   $("#news_articles .article .body p.less a").bind("click", function (e){
     $(this).parent().parent().slideToggle(1000);
     $(this).parent().parent().parent().find(".lede .more").toggle();
     e.stopPropagation();
     e.preventDefault();
     return false;
   });
   $("#news_articles .article .lede p.more a").bind("click", function (e){
     parent = $(this).parent().parent().parent();
     parent.find(".body").slideToggle(1000);
     $(this).parent().toggle();;
     e.stopPropagation();
     e.preventDefault();
     return false;
   });
	 $("#comingsoon a.close").bind("click", toggleComingSoon);
	 $("a.rollcall").bind("click", toggleComingSoon);

});

function toggleComingSoon(e){
	$("#comingsoon").slideToggle(1000);
	e.stopPropagation();
	return false;
}
function togglePanel(panelname, e){
	$("#"+panelname+"_panel").slideToggle(500);
	closeAllPanelsExcept(panelname);
	e.stopPropagation();
	e.preventDefault();
	return false;
}
function closeAllPanels(){
	$("#comingsoon:visible").hide("slide",{direction:"down"},500);
	$(["calendar","documents","chat","links"]).each(function(val){
		$("#"+val+"_panel:visible").slideToggle(500);
	});

}
function closeAllPanelsExcept(exception_name){
	$("#comingsoon:visible").hide("slide",{direction:"down"},500);
	if(exception_name!="links")     $("#links_panel:visible").slideToggle(500);
	if(exception_name!="documents") $("#documents_panel:visible").slideToggle(500);
	if(exception_name!="chat")      $("#chat_panel:visible").slideToggle(500);
	if(exception_name!="calendar")  $("#calendar_panel:visible").slideToggle(500);
}
