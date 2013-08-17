$(window).resize(function() {
  var height = $(window).height();
  $("#body").css('height', height);
});

var timeZone = jstz.determine();
document.cookie = 'time_zone='+timeZone.name()+';';