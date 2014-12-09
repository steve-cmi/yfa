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
      $(ui.item).closest('tbody').find('input.sort-value').each(function(index, element) {
        $(element).val(index + 1);
      });
    }
  });

  // Automatically submit remote forms on change
  $('form[data-remote="true"] input, form[data-remote="true"] select, form[data-remote="true"] textarea').change(function () {
    $(this).closest('form[data-remote="true"]').submit();
  })

});
