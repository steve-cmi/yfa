$(document).ready(function() {
  $("table#audition_groups").
    on('click', '.hide-all,.show-all', manageAuditionEllipsis).
    on("click", "button.single-remove", removeSingleAudition).
    on("click", "button.block-remove", removeBlockAudition);
});

function manageAuditionEllipsis(e) {
  e.preventDefault();
  var hide = $(this).is(".hide-all");
  var tbody = $(this).closest("tfoot").prev();
  tbody.find(".ellipsis").toggle(hide);
  tbody.find(".condensed").toggle(!hide);
  tbody.next().find(".hide-all").toggle(!hide);
  tbody.next().find(".show-all").toggle(hide);
}

function removeSingleAudition(e) {
  if (confirm("This audition will be deleted. There is no undo. Are you sure?")) {
    e.preventDefault();
    var aud_id = $(this).closest("tr").data("audition-id");
    send_destroy([aud_id]);
  }
}

function removeBlockAudition(e) {
  var audition_ids = $(this).closest("tfoot").prev().find("tr").map(function() { return $(this).data("audition-id"); });
  if (confirm("These "+audition_ids.length+" auditions will be deleted. There is no undo. Are you sure?")) {
    e.preventDefault();
    send_destroy($.makeArray(audition_ids));
  }
}

// Make a destroy call to remove the passed ids
function send_destroy(ids) {
  var url = $("form.auditions").attr("action");
  $.ajax({
    url: url,
    data: {destroy_ids: ids},
    type: "PUT",
    success: function(data) {
      eval(data);
    }
  })
}
