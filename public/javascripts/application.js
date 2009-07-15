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
})(jQuery);


$(function() {  
  $('select.crossSelect[multiple="multiple"]').crossSelect({clickSelects: true});
  
  $("#alert_user_ids").fcbkcomplete({
    json_url: '/users/search',
    json_cache: true,
    filter_case: false,
    filter_hide: true,
    filter_selected: true,
    firstselected: true,
    newel: true
  });
  
});

// function jsAddRole()
// {
//     var rselect=$("#phin_roles_select")[0];
//     var jselect=$("#phin_jurisdictions_select")[0];
//     var list=$("#phin_role_list ul")[0];
//     var idx=role_ct++;
//     $(list).append(
// 
//         "<li><input type='hidden' name='phin_roles["+(idx)+"][role_id]' value='"+
//             $(rselect.options[rselect.selectedIndex]).val()+"'/>"+
//             "<input type='hidden' name='phin_roles["+(idx)+"][jurisdiction_id]' value='"+
//             $(jselect.options[jselect.selectedIndex]).val()+"'/>"+
//             $(rselect.options[rselect.selectedIndex]).text()+" (" +
//             $(jselect.options[jselect.selectedIndex]).text()+ ")</li>");
//     
// }
// 
// $(document).ready(function() {  
//   $("input#phin_person_first_name").autocomplete({
//     ajax: "auto_complete_for_phin_person_first_name" 
//   })
// });
// 
// function remove_role(id)
// {
//   if(id+"" == "undefined") return;
//   
//   var list=$("#phin_role_list ul")[0];
//   var rselect=$("#phin_roles_"+id)[0];
//   $(rselect).append(
//     "<input type='hidden' name='phin_roles["+(id)+"][_delete]' value='true'/>"
//   );
//   $(rselect).slideUp(1000);
// }