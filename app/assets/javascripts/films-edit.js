$(document).ready(function() {

  // Watch for title and tagline changes to warn them about long titles
  $("#film_title, #film_tagline").on("change", function() {
    var title = $("#film_title").val();
    var tagline = $("#film_tagline").val();
    if (!tagline && (title.indexOf(":") >= 0 && title.length > 30 || title.length > 40)) {
      $("#title_length_warning").show();
    } else {
      $("#title_length_warning").hide();
    }
  });

  // Toggle audition controls
  $("#film_auditions_enabled").on('change', function() {
    $("#aud_enabled_wrapper").toggle( $(this).is(":checked") );
  });

  // Trigger audition saves
  $("#film_auditions_enabled, #film_aud_info").on('change', function() {
    $(this).closest('form').submit();
  });

  hookupPersonAutoComplete();

});

function remove_fields(link) {
  $(link).prev("input[type=hidden]").val("1");
  $(link).closest("tr").hide();
  return false;
}

function remove_added_fields(link) {
  $(link).closest("tr").remove();
  return false;
}

function add_fields(trigger, association, content) {
  var new_id = new Date().getTime();
  var regexp = new RegExp("new_" + association, "g");
  var content = $(content.replace(regexp, new_id));
  $(trigger).closest('thead').next().append(content);
  if (association == "film_positions" || association == "permissions") hookupPersonAutoComplete();
  return false;
}

// Function used to render an indiviudal entry in the auto complete
var renderItem = function( ul, item ) {
  var text = item.fname + " " + item.lname;
  if (item.college) {
    text += " (" + item.college + " '" + item.year + ")";
  }
  return $( "<li></li>" )
    .data( "item.autocomplete", item )
    .append( "<a>" + text + "</a>" )
    .appendTo( ul );
};

// Hookup both existing and newly created objects
var hookupPersonAutoComplete = function() {
  $( ".autocomplete-person:not(.ui-autocomplete-input)" ).each(function (i) {
     $(this).autocomplete({
        source: "/search/lookup?type=people",
        minLength: 2,
        select: function( event, ui ) {
          $(this).val(ui.item.fname + " " + ui.item.lname);
          $(this).parent().find(".person_id").val(ui.item.id);
          return false;
        }
      }).data( "ui-autocomplete" )._renderItem = renderItem;
  });
}
