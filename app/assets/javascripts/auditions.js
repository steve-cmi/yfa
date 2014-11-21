$(document).ready(function() {
  /* Setup audition module, TODO: pull out elsewhere...only in two places */
  $("#audition_slots").on('click', '.hide-all,.show-all', manageAuditionEllipsis);
});

function manageAuditionEllipsis(e) {
 e.preventDefault();
 var hide = $(this).is(".hide-all");
 var $table = $(this).closest("table");
 $table.find(".ellipsis").toggle(hide);
 $table.find(".condensed").toggle(!hide);
 $table.find(".hide-all").toggle(!hide);
 $table.find(".show-all").toggle(hide);
}

$(document).ready(function() {
	// There will be no enter key submissions here
	$("form").bind("keypress", function(e) {
        if (e.keyCode == 13) return false;
  });
});
