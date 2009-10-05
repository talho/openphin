$(document).ready(function(){
	$("li.faq .answer").hide();
	$("a.faq").bind("click", function(e){
		$(".answer", $(this).parent()).slideToggle(500);
	});
});