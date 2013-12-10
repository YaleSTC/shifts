$(function() {
  $('#cropbox').Jcrop({
    onChange: update_crop,
    onSelect: update_crop,
    setSelect: [0, 0, 500, 500],
    aspectRatio: 1
  });
});
function update_crop(coords) {
  $('#crop_x').val(coords.x);
  $('#crop_y').val(coords.y);
  $('#crop_w').val(coords.w);
  $('#crop_h').val(coords.h);
}

$(document).ready(function(){
 $(".cropFields").hide();
  $(".show_hide").show();
    $('.show_hide').click(function(){
    $(".cropFields").slideToggle();
  return false;
    });
});
