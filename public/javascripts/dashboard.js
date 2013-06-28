<script>
  initialize("body");

  function initialize(div){
    $(div+' li.click_to_add_new').click(function (e) {
      popup_new($(this), e, this);
      return false;
    });

    $(div+' li.click_to_show').click(function (e) {
      popup_show($(this), e);
      return false;
    });

    // $(div+'div.click_to_show_sub').click(function (e) {
    //   popup_show_sub($(this), e);
    //   return false;
    // });

    $(div+' div.click_to_add_new').click(function (e) {
      popup_generic_new($(this), e);
      return false;
    });

    // $('li.click_to_edit').click(function (e) {
    //   popup_edit($(this), e);
    //   return false;
    // });

    //don't stop links from firing
    // $(div+' li.click_to_show a').click(function (e) {
    //   e.stopPropagation();
    // });
    //
    // $(div+' li.click_to_edit a').click(function (e) {
    //   e.stopPropagation();
    // });
  }

  function popup_new(parent_element, e, raw_element){
    $("#tooltip").remove();

    var elementID = parent_element.attr('id');
    var params = elementID.split("_", 2);
    var locationID = params[0].substring(8); //remove "location" from id
    var date = params[1];

    //cursor position magic
    var relX = e.pageX - getXOffset(parent_element.closest('.events').get(0));
    var widthPercentage = relX / parent_element.closest('.events').width();

    loading_tooltip(e.pageX, e.pageY);
    $.ajax({data:"location_id="+locationID+"&date="+date+"&xPercentage="+widthPercentage, dataType:'script', type:'get', url:'<%= new_shift_path %>', async: false});
  }

  function popup_generic_new(parent_element, e){
    $("#tooltip").remove();

    var elementID = parent_element.attr('id');
    var params = elementID.split("_", 2);
    var locationID = params[0].substring(8); //remove "location" from id
    var date = params[1];

    loading_tooltip(e.pageX, e.pageY);
    $.ajax({data:"location_id="+locationID+"&date="+date, dataType:'script', type:'get', url:'<%= new_shift_path %>', async: false});
  }

  function popup_show(parent_element, e){
    $("#tooltip").remove();

    var id = parent_element.attr('id').substring(5); //remove "shift" from id

    loading_tooltip(e.pageX, e.pageY);
    $.ajax({dataType:'script', type:'get', url:'<%= shifts_path %>/'+id, async: false});
  }

  // function popup_show_sub(parent_element, e){
  //   $("#tooltip").remove();
  //
  //   var id = parent_element.attr('id').substring(3); //remove "shift" from id
  //   alert('testing');
  //   //loading_tooltip(e.pageX, e.pageY);
  //   //$.ajax({dataType:'script', type:'get', url:'<%= shifts_path %>/'+id, async: false});
  // }

  // function popup_edit(parent_element, e){
  //   $("#tooltip").remove();
  //
  //   var id = parent_element.attr('id').substring(8); //remove "timeslot" from id
  //   loading_tooltip(e.pageX, e.pageY);
  //   $.ajax({dataType:'script', type:'get', url:'<%= time_slots_path %>/'+id+'/edit', async: false});
  // }

  function loading_tooltip(x,y){
    $('body').append("<div id='tooltip' style='position: absolute; left:"+x+"px; top:"+y+"px'>Loading...</div>");
  }

  function getXOffset(element){
    var x = 0
    while(element){
        x += element.offsetLeft;
        element = element.offsetParent;
    }
    return x;
  }
</script>