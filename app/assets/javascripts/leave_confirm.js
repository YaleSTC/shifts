var inFormOrLink=false;

$(document).ready(function(){
  $('a').bind('click', function() { inFormOrLink = true; });
  $('form').bind('submit', function() { inFormOrLink = true; });
});

function setConfirmUnload(on) {
    $(window).on('beforeunload', function(){
      if (on && !inFormOrLink) {
        return unloadMessage(); 
      } 
    })
}


function unloadMessage() {
  return "Your report has not yet been submitted.";
}

$(document).ready(function(){
  if ($('div#submit_button').length) {
    setConfirmUnload(true);
  } else {
    setConfirmUnload(false);
  }
});
