function setConfirmUnload(on) {
    window.onbeforeunload = (on) ? unloadMessage : null;
    }

  function unloadMessage() {
    return "Your report has not yet been submitted.";
    }

  $(document).ready(function() {
    setConfirmUnload(true);
    $("#submit_button_div :button").click(function(){
      setConfirmUnload(false);
    });
  });

