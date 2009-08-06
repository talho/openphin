jQuery.fn.liveFilter = function(){
	var input = this;
  var list = this.parents('fieldset').find('ul');
  if ( list.length ) {
    var rows = list.children('li'),
      cache = rows.map(function(){
        return $(this).find('label').text().toLowerCase();
      });
      
    this
      .keydown(keyCheck).keyup(filter).keyup();
  }
    
  return this;
    
	function keyCheck(e) {
		if (e.keyCode == '13') // Stop enter key from submitting the form
			return false;
	}

  function filter(e){
    var term = jQuery.trim( jQuery(this).val().toLowerCase() ), scores = [];
    console.log(cache);
    if ( !term || input.hasClass('empty') ) {
			console.log('here');
      rows.show();
    } else {
      rows.hide();

      cache.each(function(i){
        var score = this.score(term);
        if (score > 0) { scores.push([score, i]); }
      });

      jQuery.each(scores.sort(function(a, b){return b[0] - a[0];}), function(){
        jQuery(rows[ this[1] ]).show();
      });
    }
  }
};