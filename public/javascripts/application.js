// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

function jsAddRole()
{
    var rselect=$("#phin_roles_select")[0];
    var list=$("#phin_role_list ul")[0];
    $(list).append(
        "<li><input type='hidden' name='phin_roles["+(role_ct++)+"][id]' value='"+
            $(rselect.options[rselect.selectedIndex]).val()+"'/>"+
            $(rselect.options[rselect.selectedIndex]).text()+"</li>");
    
}

$(document).ready(function() {  
  $("input#phin_person_first_name").autocomplete({
    ajax: "auto_complete_for_phin_person_first_name" 
  })
});