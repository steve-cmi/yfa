$(document).ready(function() {

	// There will be no enter key submissions here
	$("form").bind("keypress", function(e) {
    if (e.keyCode == 13) return false;
  });
  
  // When the form is submited alter the path to go to the right place (selected show)
  $("form.auto-id").on("submit", function(e) {
    var url = $(this).attr("action").replace("id",$(this).find("select").val());
    $(this).attr("action",url);
  });

  // When the form is submited alter the path to go to the right place (selected show)
  $("form.auto-slug").on("submit", function(e) {
    var url = $(this).attr("action").replace("slug",$(this).find("select").val());
    $(this).attr("action",url);
  });

});
