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

//= require trix
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
    document.location.hash = ''
    window.initPlayers($(".uv"))
  })
  function exitHandler() {
    var fullscreen = document.webkitIsFullScreen || document.mozFullScreen || document.msFullscreenElement

    if (fullscreen !== true) {
      sleep(200).then(function() {
        var frame = document.getElementsByTagName("iframe")[0]
        frame.style.position = null
        frame.style.top = null
        frame.style.left = null
        frame.style.width = "100%"
        frame.style.height = "100%"
      })
    } else {
      sleep(200).then(function() {
        var frame = document.getElementsByTagName("iframe")[0]
        frame.style.position = "absolute"
      })
    }
  }
  function sleep(time) {
    return new Promise(function(resolve) { setTimeout(resolve, time) } )
  }
  if (document.addEventListener) {
    document.addEventListener("webkitfullscreenchange",function() { exitHandler(this) }, false)
    document.addEventListener("mozfullscreenchange",function() { exitHandler(this) }, false)
    document.addEventListener("fullscreenchange",function() { exitHandler(this) }, false)
    document.addEventListener("MSFullscreenChange",function() { exitHandler(this) }, false)
  }
  $(".viewer").trigger("resize")
})
