function setupMoreLessToggle(linkId, textId) {
  // Wire the link to toggle between show more/show less
  $(linkId).click(function () {
    if ($(linkId).text() == "Show Less") {
      $(textId).addClass("truncate-line-clamp");
      $(linkId + " i").toggleClass("bi-caret-up bi-caret-down");
      $(linkId + " span").text("Show More");
    } else {
      $(textId).removeClass("truncate-line-clamp");
      $(linkId + " i").toggleClass("bi-caret-up bi-caret-down");
      $(linkId + " span").text("Show Less");
    }
    return false;
  });

  // Only show the link it text was indeed truncated
  // https://rubyyagi.com/how-to-truncate-long-text-and-show-read-more-less-button/
  // We are adding 30 to the offsetHeight value to prevent false positives for truncation caused by use of quotes for notes field
  var el = $(textId)[0];
  if (el !== undefined) {
    var textTruncated =
      el.offsetHeight + 30 < el.scrollHeight || el.offsetWidth < el.scrollWidth;
    console.log(textTruncated);
    if (!textTruncated) {
      $(linkId).addClass("invisible");
    }
  }
}
