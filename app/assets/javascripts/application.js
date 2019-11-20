// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require bootstrap-sprockets
// Required by Blacklight
//= require blacklight/blacklight
//= require 'blacklight_advanced_search'
//= require 'blacklight_range_limit'
//= require trix
//= require chosen-jquery
//= require_tree .

$(document).ready(function() {
  $("*[data-manifest-uri]").click(function(e) {
    e.preventDefault()
    if($(this).parent().hasClass("active")) {
      return
    }
    $(".uv").attr("data-uri", $(this).attr("data-manifest-uri"))
    $("*[data-manifest-uri]").parent().removeClass("active")
    $(this).parent().addClass("active")
    version_id = $(this).attr("data-version-id")
    $(".linked-books").hide()
    $("#" + version_id).show()
    document.location.hash = ''
    $("#uv-frame").attr("src", "https://figgy.princeton.edu/uv/uv?reload="+Date.now()+"#?manifest="+encodeURIComponent($(".uv").attr("data-uri")))
  })
  /**
   * Integration for the chosen jQuery plugin
   * Please see https://rubygems.org/gems/chosen-rails
   */
  $('.chosen-select').chosen({
    allow_single_deselect: true,
    no_results_text: 'No results matched'
  });
})

