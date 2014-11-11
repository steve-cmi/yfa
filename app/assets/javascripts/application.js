// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require jquery
//= require jquery_ujs
//= require jquery-ui/datepicker
//= require jquery-ui/autocomplete
//= require jquery-ui/sortable
//= require jquery.timepicker
//= require jquery.lazyload.min
//= require rails.validations
//= require rails.validations.custom
//= require jquery.datepair
//= require best_in_place

$(document).ready(function() {
  /* Activating Best In Place */
  jQuery(".best_in_place").best_in_place();

  /* Activate some bootstrap stuff */
  $("[rel=tooltip]").tooltip();
  $("[rel=tooltip]").on("click", function(e) {
  	e.preventDefault();
  });

  // Smooth scrolling handler for calendar page, maybe other stuff too?
  $("#nav-films li a[href*=#]").click(function () {
    this.blur();
    smoothScrollTo(this.hash);
    return false;
  });

  // When scrolled down, move the bar with the window
  var $scrollers = $('.scroll-fixed-top');
  var positions = $scrollers.map(function() { return $(this).offset().top; });
  $(window).debounce('scroll', function() {
    var st = $(window).scrollTop();
    $scrollers.each(function(i) {
      if (st > positions[i]) {
        $(this).addClass('fixed');
      } else {
        $(this).removeClass('fixed');
      }
    });
  }, 20);

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

function smoothScrollTo(hash) {
    $("html:not(:animated),body:not(:animated)").animate({
        scrollTop: $(hash).offset().top - ($("#nav-films").is(".fixed") ? 0 : $("#nav-films").outerHeight() + 20) - 60
    }, 650);
}

// jQuery.debounce from https://github.com/diaspora/jquery-debounce
(function(a){function b(a,b){var c=this,d,e;return function(){return e=Array.prototype.slice.call(arguments,0),d=clearTimeout(d,e),d=setTimeout(function(){a.apply(c,e),d=0},b),this}}a.extend(a.fn,{debounce:function(a,c,d){this.bind(a,b.apply(this,[c,d]))}})})(jQuery)