// Ctrl+Enter adds to the report
$('#item').keydown(function (e) {
  if (e.keyCode === 13 && e.ctrlKey) {
    $('#report_item_submit').click();
    e.preventDefault;
  }
});

$('#report_item_submit').click(function () {
  // $('#report_item_submit').attr('disabled', true);
  $(this).hide();
  $('#fake_button').show();
  return true;
});
