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
	if($('#health_professional:checked').lenght > 0) $('fieldset#health_professional_fields *:input').val('');

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
        if($("#documents_panel:hidden").length == 1) reloadDocumentsPanel();
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

function reloadDocumentsPanel(site){
    var dp = $("#documents_panel");
    if(jQuery.trim(site) == "") site = "/documents_panel";
    $("#documents_panel span.container").replaceWith("Loading Documents, please wait...");
    dp.load(site,"",function(responseText, textStatus, XMLHttpRequest){
        if(textStatus.toLowerCase() != "success") {
            alert("The documents panel could not be loaded.");
            return;
        }
        activateMediaPanelActions();

        var dp = $("#documents_panel span.documents");
        dp.load("/inbox");
    });
}

function reloadMediaListPanel(site, fetch_doc) {
  site = typeof(site) != "undefined" ? site : "/media_list";
  fetch_doc = typeof(fetch_doc) != "undefined" ? fetch_doc : true;
  if(site == "") site = "/media_list";

  if(fetch_doc == true) {
    var dp = $("#documents_panel span.media_list");
    dp.load(site,"",function(responseText, textStatus, XMLHttpRequest){
        if(textStatus.toLowerCase() != "success") {
            alert("The documents panel could not be loaded.");
            return;
        }
        activateMediaPanelActions();
        return true;
    });
  } else {
    activateMediaPanelActions();
  }
}

function activateMediaPanelActions() {
  $(".media_list a").bind("click", function(e) {
    e.stopPropagation();
    e.preventDefault();
    var dp = $("#documents_panel span.documents");
    site = $(this).attr("href");
    dp.load(site,"",function(responseText, textStatus, XMLHttpRequest){
      if(textStatus != "success") {
        alert("Error loading, please try again.");
        return;
      }
    });
    return false;
  });

  $('ul.check_selector>li>ul.folders>li>input').after('<a href="#" class="toggle closed" style="margin-left: 20px">Toggle</a>');
  $('ul.check_selector>li>ul.folders>li>a>label').css('margin-left','20px');
  $('ul.check_selector ul ul').hide();

  $('ul.check_selector a.toggle').click(function() {
    $(this).toggleClass('closed').siblings('ul').toggle();
    $(this).parent().children(".select_all").toggle();
    return false;
  })

  tieDocumentsFolderNavigation();
}

function tieDocumentsFolderNavigation(){
  setMediaNewFolderEvents();
  setMediaNewShareEvents();
  setMediaMoveEditEvents();
  setMediaRenameFolderEvents();
  setMediaDeleteItemEvents();
  setMediaInviteEvents();
  setMediaUnsubscribeEvents();
}

function setMediaNewFolderEvents() {
  var new_folder = $("ul.media_toolbar li#new_folder");

  $(".media_list div#new_folder input#folder_submit").bind("click", function(e) {
    e.stopPropagation();
    e.preventDefault();
    myform = $(".media_list div#new_folder form#new_folder");
    $.post(myform.attr("action"),myform.serializeArray(),function(data, textStatus) {
      if(textStatus.toLowerCase() == "success") {
        reloadMediaListPanel();
      }
    });
    return false;
  });
  new_folder.bind("click", function(e) {
    $(".media_list div#new_share:visible").slideToggle("fast");
    $(".media_list div#new_folder").slideToggle("slow");
  });
}

function setMediaNewShareEvents() {
  var new_share = $("ul.media_toolbar li#new_share");

  $(".media_list div#new_share input#channel_submit").bind("click", function(e) {
    e.stopPropagation();
    e.preventDefault();
    myform = $(".media_list div#new_share form");
    $.post(myform.attr("action"),myform.serializeArray(),function(data, textStatus) {
      if(textStatus.toLowerCase() == "success") {
        reloadMediaListPanel("");
      }
    });
    return false;
  });
  new_share.bind("click", function(e) {
    $(".media_list div#new_folder:visible").slideToggle("fast");
    $(".media_list div#new_share").slideToggle("slow");
  });
}

function setMediaMoveEditEvents() {
  var move_edit = $("ul.media_toolbar li#move_edit");

}

function setMediaRenameFolderEvents() {
  var rename_folder = $("ul.media_toolbar li#rename_folder");

}

function setMediaDeleteItemEvents() {
  var delete_item = $("ul.media_toolbar li#delete");
  delete_item.bind("click", function(e) {
    if($("ul.shares input:checked").length > 0) {
      share = $("ul.shares input:checked:first")
      delete_share = share.closest("li").children("a.remove_share");
      site = delete_share.attr("href");
      $(".media_list").append("<div id='deletion' style='position: fixed; left: 75px; bottom: 75px; border: medium solid black; z-index: 2; background-color: #FFFFD6; overflow: auto; height: 300px; width: 200px;'>Loading share deletion panel...</div>");
      var dp = $("#deletion");
      dp.load(site,"",function(responseText, textStatus, XMLHttpRequest){
        if(textStatus != "success") {
          alert("Error deleting share, please try again.");
          return false;
        }
        $("#deletion input#channel_submit").bind("click", function(e) {
          e.stopPropagation();
          e.preventDefault();
          action = $("#deletion form").attr("action");
          data = $("#deletion form").serializeArray();
          $.post(action,data,function(data, textStatus) {
            if(textStatus.toLowerCase() != "success") {
              alert("Failed to invite specified audience");
              return false;
            }
            dp.remove();
            reloadMediaListPanel("");
          });
          return false;
        });
        dp.append("<div id='close' style='position: absolute; right: 0px; top: 0px; border: medium solid black; border-top: none; border-right: none; cursor: pointer;'>close</div>");
        $("#deletion #close").bind('click', function(e) {
           dp.remove();
        });
      });
      return;
    }

    if($("ul.folders input:checked").length > 0) {
      share = $("ul.folders input:checked:first")
      delete_share = share.closest("li").children("a.destroy");
      confirmed = share.closest("li").children("a.confirm").length;
      site = delete_share.attr("href");
      if((confirmed > 0 && confirm("'This folder contains files which will be deleted if you choose to delete this folder.  Are you sure you want to delete this folders?")) || confirmed == 0) {
        $.post(site,{_method: "delete"},function(data, textStatus) {
          if(textStatus.toLowerCase() != "success") {
            alert("Failed to delete folder, please try again.");
            return false;
          }
          reloadMediaListPanel("");
        });
      }
    }
  });
}

function setMediaInviteEvents() {
  var invite = $("ul.media_toolbar li#invite");
  invite.bind("click", function(e) {
    if($("ul.shares input:checked").length > 0) {
      $(".media_list").append("<div id='invitation' style='position: fixed; left: 75px; bottom: 75px; border: medium solid black; z-index: 2; background-color: #FFFFD6'>Loading invitation panel...</div>");
      var dp = $("#invitation");
      share = $("ul.shares input:checked:first")
      invite = share.closest("li").children("a.invite");
      site = invite.attr("href");
      dp.load(site,"",function(responseText, textStatus, XMLHttpRequest){
        if(textStatus != "success") {
          alert("Error loading, please try again.");
          return false;
        }
        $("#invitation input#channel_submit").bind("click", function(e) {
          e.stopPropagation();
          e.preventDefault();
          action = $("#invitation form").attr("action");
          data = $("#invitation form").serializeArray();
          $.post(action,data,function(data, textStatus) {
            if(textStatus.toLowerCase() != "success") {
              alert("Failed to invite specified audience");
              return false;
            }
            dp.remove();
            reloadMediaListPanel("");
          });
          return false;
        });
        dp.append("<div id='close' style='position: absolute; right: 0px; top: 0px; border: medium solid black; border-top: none; border-right: none; cursor: pointer;'>close</div>");
        $("#invitation #close").bind('click', function(e) {
           dp.remove();
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
    }
  });
}

function setMediaUnsubscribeEvents() {
  var unsubscribe = $("ul.media_toolbar li#unsubscribe");

  unsubscribe.bind("click", function(e) {
    if($("ul.shares input:checked").length > 0) {
      share = $("ul.shares input:checked:first");
      unsubscribe = share.closest("li").children("a.unsubscribe");
      if(unsubscribe.length == 0) {
        alert("Cannot unsubscribe from this share.");
        return;
      }
      site = unsubscribe.attr("href");
      if(confirm("Are you sure you want to unsubscribe from this share?")) {
        $.post(site,{_method: "delete"},function(data, textStatus) {
          if(textStatus.toLowerCase() != "success") {
            alert("Could not unsubscribe from share, please try again.");
            return;
          }
          reloadMediaListPanel("");
        });
        return false;
      }
    }
  });
}

function tieDocumentsDocumentNavigation(){
  var new_folder = $("ul.documents_toolbar li#new_folder");
  var new_share = $("ul.documents_toolbar li#new_share");
  var move_edit = $("ul.documents_toolbar li#move_edit");
  var rename_folder = $("ul.documents_toolbar li#rename_folder");
  var delete_item = $("ul.documents_toolbar li#delete");
  var invite = $("ul.documents_toolbar li#new_folder");
  var unsubscribe = $("ul.documents_toolbar li#new_folder");


}
