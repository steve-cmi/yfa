// Two functions to deal with adding new fields for embedded relationships
function remove_fields(link) {
  $(link).prev("input[type=hidden]").val("1");
  $(link).closest("li").hide();
  return false;
}

function add_fields(trigger_obj, association, content) {
  var new_id = new Date().getTime();
  var regexp = new RegExp("new_" + association, "g");
  var $content = $(content.replace(regexp, new_id));


  // Bind the new function for the elements we're adding
  var change_function = function() {
  	$content.find("a.remove").show();
  	add_fields($content, association, content);
  };

  // Bind the event to trigger just once for the elements we are adding, hide remove till they edit
  $content.one("change", "input,select", change_function);
  $content.find("a.remove").hide();

	// Manual hack for the first run
  if($(trigger_obj).is("a")) {
  	$(trigger_obj).parent().after($content);
  	if(association == "screenings")
  		datify($(trigger_obj).parent().next());
  	$(trigger_obj).parent().remove();
  } else {
  	$(trigger_obj).after($content);
  }
  
  if(association == "screenings")
  	datify($(trigger_obj).next());
  if(association == "film_positions" || association == "permissions")
  	hookupPersonAutoComplete();
}

// Add tech ops to the list when they change something and the student is blank
function watchTechOps() {
	$("#tech_ops").empty();
	$("#film_positions input[name*=name]").each(function() {
		if($(this).val() == "" && $(this).siblings("[name*=_destroy]").val() != 1 && $(this).siblings("[name*=position_id]").val() != "") {
			$el = $("<li />");
			$el.html("<span>" + $(this).siblings("[name*=assistant]").val() + " " + $(this).siblings("[name*=position_id]").children(":selected").text() + "</span>");
			$("#tech_ops").append($el);
		}
	});
}

// If they manually change the name after autocompleting...remove the person_id
function protectAutocomplete() {
	$(this).siblings("[name*=person_id]").val("");
}

// Function to hookup the datepickers (auto-loaded on page load in another lib)
function datify(parent_el) {
	$(parent_el).find('input.date').each(function(){
		var $this = $(this);
		$this.datepicker({ 'dateFormat': 'm/d/yy' });

		if ($this.hasClass('start') || $this.hasClass('end')) {
			$this.on('changeDate change', doDatepair);
		}
	});

	$(parent_el).find('input.time').each(function() {
		var $this = $(this);
		var opts = { 'filmDuration': true, 'timeFormat': 'g:ia', 'scrollDefaultNow': true };

		if ($this.hasClass('start') || $this.hasClass('end')) {
			opts.onSelect = doDatepair;
		}

		$this.timepicker(opts);
	});
}

// Submit on poster upload so we can see changes immediately (sort of)
function handleFileChange() {
	// First, handle custom display of file select
	var $this = $(this),
      $val = $this.val(),
      valArray = $val.split('\\'),
      newVal = valArray[valArray.length-1],
      $button = $this.siblings('.btn-text'),
      $fileName = $("#upload-file");
      
    if(newVal !== '') {
        $button.text( $button.attr('data-selected-text') );
        $fileName.html("Selected file: <em>" + newVal + "</em>");
    } else {
        $button.text( $button.attr('data-default-text') );
        $fileName.empty();
    }
	
	// This seems jank, but I guess it's how the plugin works for validations
	var $form = $('form.edit_film');
	var id = $form.attr("id");
	var validators = window.ClientSideValidations.forms[id].validators;
	if ($form.isValid(validators)) {
	    $form.data("remote", true);
	    $form.attr("data-remote", true);
	    $form.submit();
	} else {
		alert('Please fill out the missing fields to preview your poster');
	}
}

// Set the ordering (if applicable) of cast and crew
function setPositionOrderingAndSubmit(e) {
	if($("input[name=order_crew]").is(":checked")) {
		$("#film_positions input[name*=listing_order]").each(function(i) {
			$(this).val(i);
		});
	} else {
		$("#film_positions input[name*=listing_order]").removeAttr("value");
	}

	if($("input[name=order_cast]").is(":checked")) {
		$("#film_cast input[name*=listing_order]").each(function(i) {
			$(this).val(i);
		});
	} else {
		$("#film_cast input[name*=listing_order]").removeAttr("value");
	}

	// TODO: This is a disgusting hack. It really should just be one form...not sure how to pull that off
	// copy over other inputs
	$primary_form = $("form.edit_film").eq(0);
	$("form.edit_film").eq(1).find("input:not([type=hidden]),select,textarea").appendTo($primary_form);
	$("form.edit_film").eq(2).find("input:not([type=hidden]),select,textarea").appendTo($primary_form);

	$primary_form[0].submit();
}

// Hookup the autocompletes on page load
$(document).ready(function() {
	// Add a holder for the required asterisks
	$("input.required, select.required, textarea.required").after("<span class='required' />");

	// Bind accent color changer to change the css class
	var available_colors = $.makeArray($("input[name*=accent_color]").map(function() { return $(this).attr("value") }));
	$("input[name*=accent_color]").on("change", function() {
		$(".frontpage-preview").find(".item .row").removeClass(available_colors.join(" ")).addClass($(this).val());
	});

	// Bind the live-preview updates, change data-fields equal to input id
	$("form").on("change", "input, textarea, select", function() {
		$("[data-field=" + $(this).attr("id") + "]").text($(this).val());
	});

	$("input, textarea, select").each(function() {
		if($(this).val() != "")
			$("[data-field=" + $(this).attr("id") + "]").text($(this).val());
	});

	// Watch for title and tagline changes to warn them about long titles
	$("#film_title, #film_tagline").on("change", watchForLongTitles);

	$("#film_positions").on("change", "input, select", watchTechOps);
	$("#film_positions").on("click", ".remove", watchTechOps);
	$("form").on("change","[name*=name]",protectAutocomplete);

	$("#film_poster").on("change", handleFileChange);

	// Click all the add links to convert them to fields
	// TODO: Just render them in the first place
	$("a.add-link").click();
	watchTechOps();

	// Manage filming/hiding of the audition groups
	$("#aud_enabled_wrapper").toggle( $("#film_auditions_enabled").is(":checked") );
	$("#film_auditions_enabled").on('change',function() { $("#aud_enabled_wrapper").toggle( $(this).is(":checked") )});

	// Make the audition form submit the correct form
	$(".auditions input[type=submit]").on("click",function(e) { e.preventDefault(); e.stopImmediatePropagation(); $(this).closest("form").submit()});

	// Allow sorting of people/films
	$("#submit").on('click', setPositionOrderingAndSubmit);
    $( "#film_positions, #film_cast" ).sortable();

    // Broken in FF. Also, even needed?
    //$( "#film_positions, #film_cast" ).disableSelection();

	// Since the timepicker is nested in a label, we need to prevent
	// label clicks from doing anything if they are on the time select list
	$("form").on("click","label", function(e) { 
	  if($(e.target).is("li.ui-timepicker-selected")) {
	     e.preventDefault();
	   }
	});

	hookupPersonAutoComplete();
	
});

var watchForLongTitles = function() {
	var title = $("#film_title").val();
	var tagline = $("#film_tagline").val();
	if (!tagline && (title.indexOf(":") >= 0 && title.length > 30 || title.length > 40)) {
		$("#title_length_warning").show();
	} else {
		$("#title_length_warning").hide();
	}
};

//Function used to render an indiviudal entry in the auto complete
var renderItem = function( ul, item ) {
	var text = item.fname + " " + item.lname;
	if(item.college)
		text += " (" + item.college + " " + item.year + ")";
	return $( "<li></li>" )
		.data( "item.autocomplete", item )
		.append( "<a>" + text + "</a>" )
		.appendTo( ul );
};

// Indemnipotent (or whatever) so we can re-run to hookup newly created objects
var hookupPersonAutoComplete = function() {
	$( ".person:not(.ui-autocomplete-input)" ).each(function (i) {
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