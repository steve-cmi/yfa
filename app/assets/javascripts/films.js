$(document).ready(function() {

  // Smooth scrolling for Projects page
  $("div.container.films.index #film-controls li a[href*=#]").click(function () {
    this.blur();
    smoothScrollTo(this.hash);
    return false;
  });

  // Initialize lazyload wherever it may occur
  $("img.lazy").lazyload({
    threshold: 400, // picks up images up to 400px "below the fold"
    failure_limit: 6 // ensures up to 6 images can be queued to load at once
  });

});

function smoothScrollTo(hash) {
  $("html:not(:animated),body:not(:animated)").animate({
    scrollTop: $(hash).offset().top
  }, 650);
}
