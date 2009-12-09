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
    $("#documents_progress_panel").css("z-index", "10");
    dp.load(site,"",function(responseText, textStatus, XMLHttpRequest){
        if(textStatus.toLowerCase() != "success") {
            alert("The documents panel could not be loaded.");
            return;
        }
        activateMediaPanelActions();
        
        var dp = $("#documents_panel span.documents");
        dp.load("/inbox","",function(e) {
          $("#documents_progress_panel").css("z-index", "-10");
          activateDocumentsPanelActions();
        });
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
    $("#documents_progress_panel").css("z-index", "10");
    site = $(this).attr("href");
    dp.load(site,"",function(responseText, textStatus, XMLHttpRequest){
      if(textStatus != "success") {
        alert("Error loading, please try again.");
        return;
      }
      $("#documents_progress_panel").css("z-index", "-10");
      activateDocumentsPanelActions();
    });
    return false;
  });

  $(".media_list input:checkbox").bind("click", function(e) {
    if($(this).attr("checked") == true) {
      var item = this;
      $(".media_list input:checked").each(function() {
        if(this != item) $(this).attr("checked",false);
      });
    }
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

  var myform = $(".media_list div#new_folder form#new_folder");
  myform.ajaxForm({
    target: "#documents_panel",
    beforeSend: function(response) {
      $("#documents_progress_panel").css("z-index", "10");      
    },
    success: function(data, textStatus) {
      activateMediaPanelActions();
      reloadDocumentsDocumentPanel();
    },
    error: function(request,textStatus,errorThrown) {
      alert("Could not create new folder.  Please try again.");
      activateMediaPanelActions();
      reloadDocumentsDocumentPanel();
    }
  });
  new_folder.bind("click", function(e) {
    $(".media_list div#new_share:visible").slideToggle("fast");
    $("span.media_list").children("div#new_folder").slideToggle("slow");
  });
}

function setMediaNewShareEvents() {
  var new_share = $("ul.media_toolbar li#new_share");

  var myform = $(".media_list div#new_share form");
  myform.ajaxForm({
      target: "#documents_panel",
      beforeSend: function(response) {
        $("#documents_progress_panel").css("z-index", "10");
      },
      success: function(data, textStatus) {
        activateMediaPanelActions();
        reloadDocumentsDocumentPanel();
      },
      error: function(request,textStatus,errorThrown) {
        alert("Could not create new folder.  Please try again.");
        activateMediaPanelActions();
        reloadDocumentsDocumentPanel();
      }
    });
  new_share.bind("click", function(e) {
    $("span.media_list").children("div#new_folder:visible").slideToggle("fast");
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
      $(".media_list div#deletion").remove();
      if(delete_share.length > 0) {
        $(".media_list").append("<div id='deletion' style='position: fixed; left: 75px; bottom: 75px; border: medium solid black; z-index: 2; background-color: #FFFFD6; overflow: auto; height: 300px; width: 200px;'>Loading share deletion panel...</div>");
        var dp = $("#deletion");
        dp.load(site,"",function(responseText, textStatus, XMLHttpRequest){
          if(textStatus != "success") {
            alert("Error deleting share, please try again.");
            return false;
          }
          var myform = $("#deletion form");
          myform.ajaxForm({
            target: "#documents_panel",
            beforeSend: function(response) {
              dp.remove();
              $("#documents_progress_panel").css("z-index", "10");
            },
            success: function(data, textStatus) {
              activateMediaPanelActions();
              reloadDocumentsDocumentPanel();
            },
            error: function(request,textStatus,errorThrown) {
              alert("Failed to invite specified audience");
              activateMediaPanelActions();
              reloadDocumentsDocumentPanel();
            }
          });
          dp.append("<div id='close' style='position: absolute; right: 0px; top: 0px; border: medium solid black; border-top: none; border-right: none; cursor: pointer;'>close</div>");
          $("#deletion #close").bind('click', function(e) {
             dp.remove();
          });
        });
      } else {
        alert("You cannot delete this share.");
      }
      return;
    }

    if($("ul.folders input:checked").length > 0) {
      share = $("ul.folders input:checked:first")
      delete_share = share.closest("li").children("a.destroy");
      confirmed = share.closest("li").children("a.confirm").length;
      site = delete_share.attr("href");
      if((confirmed > 0 && confirm("'This folder contains files which will be deleted if you choose to delete this folder.  Are you sure you want to delete this folders?")) || confirmed == 0) {
        $("#documents_progress_panel").css("z-index", "10");      
        $("#documents_panel").load(site,{_method: "delete"},function(data, textStatus) {
          if(textStatus.toLowerCase() != "success") {
            alert("Failed to delete folder, please try again.");
          }
          activateMediaPanelActions();
          reloadDocumentsDocumentPanel();
        });
      }
    }
  });
}

function setMediaInviteEvents() {
  var invite = $("ul.media_toolbar li#invite");
  invite.bind("click", function(e) {
    if($("ul.shares input:checked").length > 0) {
      $(".media_list div#invitation").remove();
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

        var myform = $("#invitation form");
        myform.ajaxForm({
          beforeSend: function(response) {
            dp.remove();
            $("#documents_progress_panel").css("z-index", "10");
          },
          target: "#documents_panel",
          success: function(data, textStatus) {
            activateMediaPanelActions();
            reloadDocumentsDocumentPanel();
          },
          error: function(request,textStatus,errorThrown) {
            alert("Failed to invite specified audience");
            activateMediaPanelActions();
            reloadDocumentsDocumentPanel();
          }
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
        $("#documents_progress_panel").css("z-index", "10");
        $("#documents_panel").load(site,{_method: "delete"},function(data, textStatus) {
          if(textStatus.toLowerCase() != "success") {
            alert("Could not unsubscribe from share, please try again.");
          }
          activateMediaPanelActions();
          reloadDocumentsDocumentPanel();
        });
        return false;
      }
    }
  });
}

function reloadDocumentsDocumentPanel(site) {
  if(typeof site == "undefined") site = "/inbox";

  var dp = $("#documents_panel span.documents");
  dp.load(site,"",function(responseText, textStatus, XMLHttpRequest){
    if(textStatus != "success") {
      alert("Error loading, please try again.");
      return;
    }
    activateDocumentsPanelActions();
  });
}

function activateDocumentsPanelActions() {
  $("#documents_progress_panel").css("z-index", "-10");
  $(".documents input:checkbox").bind("click", function(e) {
    if($(this).attr("checked") == true) {
      var item = this;
      $(".documents input:checked").each(function() {
        if(this != item) $(this).attr("checked",false);
      });
    }
  });

  tieDocumentsDocumentNavigation();
}

function tieDocumentsDocumentNavigation(){
  setDocumentUploadEvents();
  setDocumentNewFolderEvents();
  setDocumentSendEvents();
  setDocumentAddToShareEvents();
  setDocumentMoveEditEvents();
  setDocumentDeleteItemEvents();
}

function detectAuthenticityToken(responseXML) {
  // A little bit of voodoo because jQuery.form uses an iframe when submitting form data with file uploads
  // and can't detect the success of the iframe so always returns success
  // Detects for the presence of the authenticity token meta tag in the fetched page

  return responseXML.evaluate("count(//head/meta[@id='authenticity-token'])",responseXML, null, XPathResult.NUMBER_TYPE,null).numberValue > 0 ? true : false;
}

function setDocumentUploadEvents() {
  var upload_document = $("ul.documents_toolbar li#upload_document");
  var upload_document_form = $("span.documents div.upload_document form");
  var upload_document_submit = $("span.documents div.upload_document input#document_submit");

  upload_document_form.ajaxForm({
    target: "span.documents",
    beforeSend: function(response) {
      $("#documents_progress_panel").css("z-index", "10");
    },
    complete: function(response, textStatus) {
      loaded = detectAuthenticityToken(response.responseXML);
      if(!loaded) alert("Error creating new folder, please try again.");
      activateDocumentsPanelActions();
    }
  });

  upload_document.bind("click", function(e) {
    var new_folder_div = $("span.documents").children("div#new_folder:visible");
    var upload_document_div = $("span.documents div.upload_document");
    new_folder_div.slideToggle("fast");
    upload_document_div.slideToggle("slow");
  });
}

function setDocumentNewFolderEvents() {
  var new_folder = $("ul.documents_toolbar li#new_folder");

  var myform = $("span.documents div#new_folder form");
  myform.ajaxForm({
    beforeSend: function(response) {
      $("#documents_progress_panel").css("z-index", "10");
    },
    complete: function(response, textStatus) {
      reloadDocumentsPanel();
    }
  });

  new_folder.bind("click", function(e) {
    var upload_document_div = $("div.upload_document:visible");
    var new_folder_div = $("span.documents").children("div#new_folder");
    upload_document_div.slideToggle("fast");
    new_folder_div.slideToggle("slow");
  });
}

function setDocumentSendEvents() {
  var send = $("ul.documents_toolbar li#send");
  send.bind("click", function(e) {
    if($("ul.documents input:checked").length > 0) {
      $("span.documents div#send").remove();
      $("span.documents").append("<div id='send' style='position: fixed; left: 75px; bottom: 75px; border: medium solid black; z-index: 2; background-color: #FFFFD6'>Loading sending panel...</div>");
      var dp = $("span.documents div#send");
      file = $("ul.documents input:checked:first");
      link = file.closest("li").children("a.send");
      site = link.attr("href");
      dp.load(site,"",function(responseText, textStatus, XMLHttpRequest){
        if(textStatus != "success") {
          alert("Error loading, please try again.");
          return false;
        }
        $("form.edit_document").ajaxForm({
          target: "span.documents",
          beforeSend: function(response) {
            dp.remove();
            $("#documents_progress_panel").css("z-index", "10");
          },
          success: function(data, textStatus) {
            activateDocumentsPanelActions();
            dp.remove();
          },
          error: function(request,textStatus,errorThrown) {
            alert("Document was unable to be sent.  Please try again.");
            dp.remove();
          }
        });
        dp.append("<div id='close' style='position: absolute; right: 0px; top: 0px; border: medium solid black; border-top: none; border-right: none; cursor: pointer;'>close</div>");
        $("#send #close").bind('click', function(e) {
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

function setDocumentAddToShareEvents() {
  var add_to_share = $("ul.documents_toolbar li#add_to_share");

  add_to_share.bind("click", function(e) {
    if($("ul.documents input:checked").length > 0) {
      $("span.documents div#share").remove();
      $("span.documents").append("<div id='share' style='position: fixed; left: 75px; bottom: 75px; border: medium solid black; z-index: 2; background-color: #FFFFD6'>Loading sharing panel...</div>");
      var dp = $("span.documents div#share");
      file = $("ul.documents input:checked:first");
      link = file.closest("li").children("a.add_share");
      site = link.attr("href");
      dp.load(site,"",function(responseText, textStatus, XMLHttpRequest){
        if(textStatus != "success") {
          alert("Error loading, please try again.");
          return false;
        }
        $("form.edit_document").ajaxForm({
          target: "span.documents",
          beforeSend: function(response) {
            dp.remove();
            $("#documents_progress_panel").css("z-index", "10");
          },
          success: function(data, textStatus) {
            activateDocumentsPanelActions();
            dp.remove();
          },
          error: function(request,textStatus,errorThrown) {
            alert("Document was unable to be sent.  Please try again.");
            dp.remove();
          }
        });
        dp.append("<div id='close' style='position: absolute; right: 0px; top: 0px; border: medium solid black; border-top: none; border-right: none; cursor: pointer;'>close</div>");
        $("#share #close").bind('click', function(e) {
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

function setDocumentMoveEditEvents() {
  var move_edit = $("ul.documents_toolbar li#move_edit");
  move_edit.bind("click", function(e) {
    if($("ul.documents input:checked").length > 0) {
      $("span.documents div#move_edit").remove();
      $("span.documents").append("<div id='move_edit' style='position: fixed; left: 75px; bottom: 75px; border: medium solid black; z-index: 2; background-color: #FFFFD6; width: 250px;'>Loading move/edit panel...</div>");
      var dp = $("span.documents div#move_edit");
      file = $("ul.documents input:checked:first");
      link = file.closest("li").children("a.move_edit");
      site = link.attr("href");
      dp.load(site,"",function(responseText, textStatus, XMLHttpRequest){
        if(textStatus != "success") {
          alert("Error loading, please try again.");
          return false;
        }

        child = $("form select#document_folder_id");
        child.closest("form").ajaxForm({
          target: "span.documents",
          beforeSend: function(response) {
            dp.remove();
            $("#documents_progress_panel").css("z-index", "10");
          },
          success: function(data, textStatus) {
            activateDocumentsPanelActions();
          },
          error: function(request,textStatus,errorThrown) {
            alert("Document was unable to be sent.  Please try again.");
          }
        });

        child = $("form input#document_file");
        child.closest("form").ajaxForm({
          target: "span.documents",
          complete: function(response, textStatus) {
            loaded = detectAuthenticityToken(response.responseXML);
            dp.remove();
            if(loaded) {
              activateDocumentsPanelActions();
            } else {
              alert("Error updating document, please try again.");
              reloadDocumentsDocumentPanel();
            }
          }
        });
        dp.append("<div id='close' style='position: absolute; right: 0px; top: 0px; border: medium solid black; border-top: none; border-right: none; cursor: pointer;'>close</div>");
        $("#move_edit #close").bind('click', function(e) {
          dp.remove();
        });
      });
    }
  });
}

function setDocumentDeleteItemEvents() {
  var delete_item = $("ul.documents_toolbar li#delete");
  
  delete_item.bind("click", function(e) {
    e.stopPropagation();
    e.preventDefault();
    if($("ul.documents input:checked").length > 0) {
      if(confirm("Are you sure you want to delete this item?  If this item is in a share, it will only remove it from the share and not from it's folder.")) {
        $("#documents_progress_panel").css("z-index", "10");
        item = $("ul.documents input:checked:first");
        link = item.closest("li").children("a.destroy");
        action = link.attr("href");
        $("span.documents").load(action,{_method: "delete"},function(data, textStatus) {
          if(textStatus.toLowerCase() != "success") {
            alert("Failed to delete item, please try again.");
            return false;
          }
          activateDocumentsPanelActions();
        });
      }
    }
    return false;
  });
}
