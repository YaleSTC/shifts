$("td.clickable_signup").simpletip({

  onBeforeShow: function(){
    var text = this.getParent().get(0).id;
    text = text.split("||");

    this.load('/shifts/new', "tooltip=true&shift%5Bstart%5D="+text[1]+"&shift%5Blocation_id%5D="+text[0]);
  },

  content: 'loading...',
  position: ["0", "26px"],
  fixed: true,
  persistent: true,
  focus: true

});

$("a.clickable_edit").simpletip({
  onBeforeShow: function(){
    this.getParent().get(0).href = "javascript: return false;";
    var text = this.getParent().get(0).id;
    text = text.split("||");
    var params = "tooltip=true";
    if (text[0] == "edit") {
      this.load('/shifts/edit/'+text[1], params);
    }
    else {
      params += "&shift%5Bstart%5D="+text[1]+"&shift%5Blocation_id%5D="+text[0];
      this.load('/shifts/new/', params);
    }
  },

  content: 'loading...',
  position: ["0", "26px"],
  fixed: true,
  persistent: true,
  focus: true

});

//update tooltips when a new ajax result is returned
$(".updated").ajaxSuccess(function(evt, request, settings){
  $(".updated td.clickable_signup").simpletip({
  
    onBeforeShow: function(){
      var text = this.getParent().get(0).id;
      text = text.split("||");
  
      this.load('/shifts/new', "tooltip=true&shift%5Bstart%5D="+text[1]+"&shift%5Blocation_id%5D="+text[0]);
    },
  
    content: 'loading...',
    position: ["0", "26px"],
    fixed: true,
    persistent: true,
    focus: true
  
  });
  
  $(".updated a.clickable_edit").simpletip({

    onBeforeShow: function(){
      this.getParent().get(0).href = "javascript: return false;";
      var text = this.getParent().get(0).id;
      text = text.split("||");
      var params = "tooltip=true";
      if (text[0] == "edit") {
        this.load('/shifts/edit/'+text[1], params);
      }
      else {
        params += "&shift%5Bstart%5D="+text[1]+"&shift%5Blocation_id%5D="+text[0];
        this.load('/shifts/new/', params);
      }
    },

    content: 'loading...',
    position: ["0", "26px"],
    fixed: true,
    persistent: true,
    focus: true

  });
});