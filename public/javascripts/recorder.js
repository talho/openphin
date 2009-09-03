(function($) {
  $(function() {
  	$('.success, .failure, .waiting').hide();
	$('ul.check_selector #alert_device_phone_device').click(function() {
		if($('applet').length == 0) {
			addRecorderApplet();
		}
		if ($('ul.check_selector #alert_device_email_device:checked').length == 0) {
			$('.audio').toggle();
		}
	});
	$('ul.check_selector #alert_device_email_device').click(function() {
		if($('applet').length == 0) {
			addRecorderApplet();
		}
		if ($('ul.check_selector #alert_device_phone_device:checked').length == 0) {
			$('.audio').toggle();
		}
	});
  })
})(jQuery);

function uploadComplete(){
  $('.failure, .waiting').hide();
  $('.success').show();
  $('.audio button.upload').removeAttr('disabled');
  $('#details button.audience').removeAttr('disabled');
  $('ul.progress a[href=#details]').removeAttr('disabled');
  $('ul.progress a[href=#audience]').removeAttr('disabled');
  $('ul.progress a[href=#preview]').removeAttr('disabled');
}

function uploadFailure(){
  $('.success, .waiting').hide();
  $('.failure').show();
  $('.audio button.upload').removeAttr('disabled');
  $('#details button.audience').removeAttr('disabled');
  $('ul.progress a[href=#details]').removeAttr('disabled');
  $('ul.progress a[href=#audience]').removeAttr('disabled');
  $('ul.progress a[href=#preview]').removeAttr('disabled');
}

function addRecorderApplet(){
	applet = $('.audio .applet').html().substring(4,$('.audio .applet').html().length - 3);

	$('.audio .applet').html(applet);
	$('.audio').append('<button class="upload">Upload Audio</button>');
	$('.audio button.upload').click(function() {
	  if(typeof document.JavaSonicRecorderUploader != "undefined") {
	  	token = $("#filename").attr("value");
	 	document.JavaSonicRecorderUploader.setUploadCompletionScript('uploadComplete();');
	    document.JavaSonicRecorderUploader.setUploadFailureScript('uploadFailure();');
	    document.JavaSonicRecorderUploader.addNameValuePair('token', token);
	    $('.success, .failure').hide();
	    $('.waiting').show();
		$('.audio button.upload').attr('disabled', 'disabled');
	    $('#details button.audience').attr('disabled', 'disabled');
		$('ul.progress a[href=#details]').attr('disabled', 'disabled');
		$('ul.progress a[href=#audience]').attr('disabled', 'disabled');
		$('ul.progress a[href=#preview]').attr('disabled', 'disabled');
	    document.JavaSonicRecorderUploader.sendRecordedMessage();
	  } else {
		alert("Failed up upload audio")
	  }
	  return false;
	});
}
