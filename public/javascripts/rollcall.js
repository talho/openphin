(function($) {
  $(function() {
    $(document).ready(function() {
      $(".school_selection select#district_id").change(function() {
         $(".school_selection select#school_id option:selected").attr('selected', '');
         $(".school_selection select#school_id option:first").attr('selected', 'selected');
         $("form").submit();
      });
    });
  });
})(jQuery);