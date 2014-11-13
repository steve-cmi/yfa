// $(document).ready(function() {
//   /* Activating Best In Place */
//   jQuery(".best_in_place").best_in_place();

//   /* Activate some bootstrap stuff */
//   $("[rel=tooltip]").tooltip();
//   $("[rel=tooltip]").on("click", function(e) {
//    e.preventDefault();
//   });

//   // Smooth scrolling handler for calendar page, maybe other stuff too?
//   $("#nav-films li a[href*=#]").click(function () {
//     this.blur();
//     smoothScrollTo(this.hash);
//     return false;
//   });

//   // When scrolled down, move the bar with the window
//   var $scrollers = $('.scroll-fixed-top');
//   var positions = $scrollers.map(function() { return $(this).offset().top; });
//   $(window).debounce('scroll', function() {
//     var st = $(window).scrollTop();
//     $scrollers.each(function(i) {
//       if (st > positions[i]) {
//         $(this).addClass('fixed');
//       } else {
//         $(this).removeClass('fixed');
//       }
//     });
//   }, 20);

//   /* Setup audition module, TODO: pull out elsewhere...only in two places */
//   $("#audition_slots").on('click', '.hide-all,.show-all', manageAuditionEllipsis);
// });

// function manageAuditionEllipsis(e) {
//  e.preventDefault();
//  var hide = $(this).is(".hide-all");
//  var $table = $(this).closest("table");
//  $table.find(".ellipsis").toggle(hide);
//  $table.find(".condensed").toggle(!hide);
//  $table.find(".hide-all").toggle(!hide);
//  $table.find(".show-all").toggle(hide);
// }

// function smoothScrollTo(hash) {
//     $("html:not(:animated),body:not(:animated)").animate({
//         scrollTop: $(hash).offset().top - ($("#nav-films").is(".fixed") ? 0 : $("#nav-films").outerHeight() + 20) - 60
//     }, 650);
// }
