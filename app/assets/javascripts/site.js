$(document).ready(function() {

  /* Activate Best In Place */
  $(".best_in_place").best_in_place();

  /* Activate Bootstrap Tooltips */
  $(function () {
    $('[data-toggle="tooltip"]').tooltip()
  })

  // Trigger sortable
  $(".sortable").sortable({
    handle: '.drag-handle',
    update: function( event, ui ) {
      $(ui.item).closest('.sortable').find('input.sort-value').each(function(index, element) {
        $(element).val(index + 1);
      });
    }
  });

  // Trigger datepicker
  $.datepicker.setDefaults({
    numberOfMonths: 2,
    dateFormat: 'M d yy' // match the field_date helper
  });
  $(".datepicker").datepicker();
  $(document).on('focus', '.datepicker', function() {this.blur()}); // suppress mobile keyboards

  // Automatically submit remote forms on change
  $('form[data-remote="true"] input, form[data-remote="true"] select, form[data-remote="true"] textarea').change(function () {
    $(this).closest('form[data-remote="true"]').submit();
  })

  // Smart Affix
  // http://codereview.stackexchange.com/questions/84494/smarter-boostrap-affix
  var $attribute = $('[data-smart-affix]');
  $attribute.each(function(){
    $(this).affix({
      offset: {
        top: $(this).offset().top,
      }
    })
  })
  $(window).on("resize", function(){
    $attribute.each(function(){
      $(this).data('bs.affix').options.offset = $(this).offset().top
    })
  })

});
