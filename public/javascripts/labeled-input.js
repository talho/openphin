// Mark VanHolstyn, Mutually Human Software
$(document).ready(function() {
  var hideLabel = function() {
    if($(this).attr("value") == $(this).attr("data-label")) {
      $(this).attr("value", "");
      $(this).removeClass("label");
    }
  };
  
  var showLabel = function() {
    if($(this).attr("value") == "") { 
      $(this).attr("value", $(this).attr("data-label"));
      $(this).addClass("label");
    }
  };
  
  $("form.edit_user").livequery("submit", function() {
    $(this).select('input[data-label], textarea[data-label]').each(hideLabel);
  });
  $('input[data-label], textarea[data-label]').livequery("focus", hideLabel);
  $('input[data-label], textarea[data-label]').livequery("blur", showLabel);
  $('input[data-label], textarea[data-label]').each(showLabel);
});
